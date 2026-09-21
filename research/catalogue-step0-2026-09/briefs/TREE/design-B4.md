# Design sketch · B4 (= D15) — what flows down, per kind of fact

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.

## 0 · The six kinds of fact a node could carry, and the four mechanisms our code uses

The card names five things that might flow down. They are not one mechanism: our own code carries **six**
kinds of category-derived fact and resolves them by **four** different mechanisms — no flow, computed flow,
materialised-on-the-subtree flow, and materialised-on-the-product flow. *(Count corrected after red-team
round 1, MINOR 25.)*

| Kind of fact | Where it lives today | How it resolves down the tree today |
|---|---|---|
| **attribute definitions** | `ProductAttribute.product_class` FK (`catalogue/models.py:618-624`), one `ProductClass` row, five attributes | **no tree at all** — `ProductClass.default()` is `ProductClass.objects.get()` with no filter (`models.py:88-90`), read by `api/apiproduct/staff_views.py:66-67` and by every create at `api/apiproduct/staff_serializers.py:116-119`. It raises `MultipleObjectsReturned` the first time a second row exists |
| **requiredness** | `ProductAttribute.required` boolean (`models.py:655`), global | same — no tree |
| **age-walling** | `settings.AGE_WALLED_CATEGORY_IDS`, a flat Python list of 8 ids (`apps/solvent/config/settings/base.py:924-937`), read by `Product.age_walled` (`models.py:570-573`) as `self.main_category_id in …` | **exact id, does NOT flow down** |
| **replenishment scope** | `inventory/replenishment/inventory_replenishment_service.py:31-36` | **flows down**: `category.get_descendants_and_self().values_list("id", flat=True)` then `Q(product__main_category__in=descendant_ids)` |
| **public visibility** | `Category.is_public` + `Category.ancestors_are_public` (`models.py:149-157`) | **flows down, materialised**: `set_ancestors_are_public()` (`models.py:271-285`) writes the whole subtree with one `QuerySet.update()` |
| **search browse scope** | `catalogue/search_indexes_mixins.py:22, 27-29` | **flows down, materialised on the product**: `category` is a `MultiValueField` holding `[c.id for c in main_category.get_ancestors_and_self()]` |

**This is already the card's fourth option — "probably per kind of fact, not one switch" — implemented by
accident.** Two facts flow down (visibility, browse scope) and are materialised; one flows down and is
computed at read (replenishment); one does not flow down at all and is demonstrably wrong because of it
(age-walling). The four-value table above is the strongest argument in this brief, and it is from our own
code, not from a platform.

### Age-walling, stated precisely

```python
# py/mono/solvent/catalogue/models.py:570-573
@property
def age_walled(self) -> bool:
    # TODO(irvan): Fix this so this is no longer hardcoded.
    return self.main_category_id in settings.AGE_WALLED_CATEGORY_IDS
```
```python
# py/mono/apps/solvent/config/settings/base.py:924-937
AGE_WALLED_CATEGORY_IDS = [
    17,   # cigarettes parent category
    115,  # lighter
    117,  # cigarettes
    145,  # sex health
    931,  # sex health etc
    932,  # pregnancy test
    933,  # condom
    934,  # lube
]
```
The list names **both** `17 # cigarettes parent category` **and** `117 # cigarettes` — the symptom of an
exact-id match standing in for an ancestry rule. A child added under 17 is silently unwalled. The test
settings set it empty (`shared/test_utils/django/settings.py:173-174`, `AGE_WALLED_CATEGORY_IDS=[]`), so no
test catches it. Downstream the flag is copied into the search index
(`solvent/search/search_indexes.py:45`, `:134-135`) and exposed as a filter
(`api/apisearch/serializers.py:17`) that is **opt-in by the caller** — the integration test asserts the
filter is omitted when the param is absent (`api/apisearch/integration_tests/product_search_age_walled_filter_integration_test.py:39`).

**"Flows down" for age-walling** means: replace the exact-id membership test with an ancestry test. The
cheapest correct form reuses what search already computes — the ancestor-id list — or an
`is_age_walled` boolean on `Category` resolved by `get_ancestors_and_self()`. Either way it is a change to
one property and one settings constant, and it is already listed on the v7 page as decision-free work.

**"Flows down" for replenishment** means: nothing. It already does, and it is the only descendant-scoped
category query in the codebase.

## 1 · Option (a) — nothing flows; every node complete on its own (materialised per node)

### Shape

`ProductAttribute.category` FK (Lock 1's rename), and a node's schema is exactly the rows pointing at it.
Effective set = one query, no recursion.

### Cost against our numbers

Every node that holds products needs its own complete row set. Post-condition-2 the universal corpus is
`manufacturer` alone — one attribute — so the day-one materialisation is 1,686 rows. But
`node-attribute-need.md` measures **68 distinct attribute-need sets over those 1,686 nodes, 98.8% of which
share a set with another node**: (a) stores the same set 1,665 times and gives staff no way to say "these
nodes are the same". Adding one attribute to *Food* becomes 1,686 decisions.

### What the schema editor looks like (lock condition 1)

One screen per node, a list of (attribute, required) rows, no inheritance to explain. The simplest editor of
the three — and the one that makes the authoring bill the largest. Shopify, Amazon, Walmart and Shopee all
ship this shape (§2 of `TREE.md` B4) and **all four author the taxonomy centrally**. Akeneo's own words for
the alternative — *"child families like 'Belts', 'Scarves' or 'Sunglasses', which automatically inherit every
attribute from the parent level"* (#11031, 2026-09-15 comment) — describe why.

### What a category move does

Nothing. The node keeps its rows. This is (a)'s real advantage and it is not small: under (b) a move silently
rewrites the effective schema of every product in the subtree, and
`api/apicategory/staff_serializers.py:104-148` currently validates nothing beyond `full_code` uniqueness and
treebeard's `InvalidMoveToDescendant`.

## 2 · Option (b) — inherit down with override

### Shape

Effective set of node N = union over `N.get_ancestors_and_self()` of that node's rows, with a child row of
the same attribute overriding the ancestor's `required` / value list, and (open) a tombstone row to remove.

### How the effective set is computed — and the cost of computing it

`get_ancestors_and_self()` is a `@cached_property` over `list(self.get_ancestors()) + [self]`
(`catalogue/models.py:287-301`); treebeard's `get_ancestors()` on an `MP_Node` is one query using the path
prefix. So the effective set is **one extra query per category, per request**, plus a union in Python. That
is cheap for a product page and **not** cheap for the staff product list, the feed, or a reindex.

Three ways to pay for it, each with a real cost here:

1. **Compute on read.** `api/apiproduct/staff_serializers.py` is the single create/update path and is already
   inside `transaction.atomic()`; adding an ancestor walk there is one query. The product *list* endpoints
   would need `select_related("main_category")` plus a per-category cache. eBay — the only platform that
   inherits and publishes how — explicitly does **not** do this: *"Due to the large number of eBay categories,
   the response from GetCategoryFeatures uses an **inheritance override model**… **Store the data locally and
   then manage the data on the client side.**"* (#11031, 2026-09-15 comment; the underlying artifacts are
   `web.archive.org` captures because `developer.ebay.com` refused with 403).
2. **Materialise into a join table** (`category_id, attribute_id, required, source_category_id`) maintained
   by a signal. Reads become option (a). Writes become a subtree rewrite — the exact shape
   `set_ancestors_are_public()` already uses (`models.py:271-285`), including its defect: it is a bulk
   `QuerySet.update()`, which **fires no signal**, so nothing downstream reindexes.
3. **Materialise onto the product.** Rejected on sight: 106,161 rows rewritten per schema edit.

### What a category move does

**A move rewrites the effective schema of every product in the subtree.** Today a move is
`category.move(computed_parent_new, "last-child")` (`api/apicategory/staff_serializers.py:116`) followed by a
DFS `full_code` cascade (`:131-146`). Under (b) it additionally needs: a pre-flight that lists every attribute
the subtree will gain or lose; a decision on stored `ProductAttributeValue` rows for attributes the subtree
loses (the `unique_together ("attribute","product")` at `models.py:728-730` means they simply become orphans);
and a reindex of the subtree's products, which **does not exist** (see `design-B1.md` §4). The move is
already the operation #11188 §3 flags, and (b) is what makes it a schema migration.

### What the schema editor looks like

Two lists per node: *inherited from* (with the ancestor named, read-only unless overridden) and *own*. Plus
an override affordance and — if removal is allowed — a tombstone. Akeneo, the only vendor that ships
attribute inheritance, **does not allow removal**: the record's own words are that an inherited attribute
*cannot* be removed while linked, with a documented workaround of detach → edit parent → re-attach, and that
completeness requirements *"explicitly cannot be overridden"* (#11031, 2026-09-15 comment, `#11069`).
**Judgement:** copying that restriction is the cheap path — inherit-and-add, override `required`, never
remove — and it removes the tombstone from the schema entirely.

### What it buys, in our numbers

`node-attribute-need.md`: 68 distinct sets over 1,686 nodes. Under (b), a set authored at the right ancestor
covers its whole subtree. The 639 nodes covering 90% of products span **47** distinct measured sets. The
authoring bill is therefore bounded by the number of *places a set changes*, not by 639.

## 3 · Option (c) — universal set on the root, additions on the leaves, nothing in between

### Shape

Two levels only: a global set (today: the five `ProductAttribute` rows; post-condition-2, `manufacturer`),
plus per-leaf additions.

### Cost

It is (a) with one free level. It matches our *current* data exactly — one `ProductClass`, five universal
attributes — and it is the smallest change from today. But it cannot express `Food → Rasa`: our food branch
is `Makanan dan Minuman > MAKANAN & BAHAN MAKANAN > MIE, BIHUN, KWETIAU INSTAN > MIE INSTAN BUNGKUS`, four
levels, and flavour belongs at level 2 or 3, not at the root and not once per leaf.
**Our depth histogram makes (c) expensive**: 727 used nodes at depth 4, 328 at depth ≥ 6.

Google is the closest thing to a (c) precedent and it is not one: it has **no per-node attribute set at all**
(one global `ProductAttributes` bag), and its one descendant-aware behaviour is an enumerated prose exception
list — *"16 named Apparel sub-categories are Optional where ancestor `166` is Required"* (#11031,
2026-09-15 comment, `#11013`). An enumerated exception list is what (c) degrades into.

## 4 · The recommendation's shape, as a table

| Kind of fact | Proposal | Why |
|---|---|---|
| attribute **definitions** | **inherit with override (b)**, add-and-override only, never remove | 68 sets over 1,686 nodes; Akeneo's own restriction is the cheap form |
| **requiredness** | inherits with the definition; a child may tighten (optional → required), never loosen | Amazon: *"Requiredness is a property of this join, not of the Attribute"* (`evidence/issues/10976.md:158`; the same attribute is required for one product type and optional for another, and required at `CHILD` but not at `PARENT`) — so requiredness must be per (node, attribute), which is what an override row is |
| **allowed values** | inherits; a child may narrow | A4's call; TREE only states that narrowing is expressible as an override row and widening is not |
| **age-walling** | **must flow down by ancestry** | today's exact-id list is wrong (`models.py:570-573` + `base.py:924-937`); already decision-free work on the v7 page |
| **replenishment** | already flows down | `inventory_replenishment_service.py:31-36` |
| **`accepts_products`** | **must NOT flow down** | a folder's *descendants* include the nodes that do accept products, so inheriting `false` would disable exactly the nodes the flag exists to enable. (A folder's immediate children are frequently folders too — on an 8-deep tree with 339 internal nodes that is common; the earlier wording said "exactly the nodes that do accept products", which is false in general. Corrected after red-team round 1, MINOR 26; the conclusion is unchanged.) |
| **`is_public`** | already flows down, materialised | `models.py:271-285` |

**The point (judgement):** a single D15 switch cannot be right, because our own code already answers it four
different ways and one of those answers is a live bug. D15 should be recorded as *per kind of fact*, with the
table above as its content.


---

## 5 · Corrections after red-team round 1

- **MINOR 25** — the heading said "four kinds" over a six-row table. Restated as **six kinds, four
  mechanisms**.
- **MINOR 26** — the `accepts_products` justification ("a folder's children are exactly the nodes that do
  accept products") is false on an 8-deep tree. Restated in terms of descendants; the recommendation is
  unchanged.
- **MINOR 30** — the Amazon requiredness cite was an empty section marker; it is
  `evidence/issues/10976.md:158`.
- **BLOCKING 2** — the precedent denominator for (b) is derived, not asserted, in `TREE.md` B4 §2; the
  like-for-like figure is **1 of 2** (Shopify, Salesforce), not 1 of 5.
