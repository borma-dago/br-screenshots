# TREE — what a category node is · Step-0 research brief

**Brief id:** TREE · **Cards:** B1 · B2 · B3 (= D16) · B4 (= D15) · the Step-1 fork · the closed card
"one category per product" · **Date:** 2026-09-19

**Pins (every `path:line` below was re-opened at these, never quoted from memory):**
backend `/home/irvan/copilot/py-5` at `solvent-master` **`4f99dc01c6`** ·
frontend `/home/irvan/copilot/ts-layer2` at `ts-master` **`82187a17bd`** (the `ts/` inside `py-5` is stale and
is not cited anywhere in this brief).

**Data:** BigQuery `solvent-staging.production_append_public`, CDC-deduplicated per BRIEF §3.4, **snapshot
2026-09-19**. Every number carries its SQL file.

**Files beside this one**

| File | What it is |
|---|---|
| `node-attribute-need.md` | **the A3↔B3 shared measurement** — the attribute need per node, measured and inferred, with the mapping's miss rate. ATTR-VALUE cites this for A3 |
| `nonleaf-classification.md` | all 292 used non-leaf nodes classified (B2's research pointer) |
| `fork-shopify-taxonomy.md` | every fork number verified against the corpus on disk, with the commit |
| `design-B1.md` · `design-B2.md` · `design-B3.md` · `design-B4.md` · `design-fork.md` | the design sketches §6 draws on |
| `redteam-round1.md` · `redteam-round2.md` | the adversarial re-verifications this revision answers |
| `sql/*.sql`, `sql/results/*` | `nodes-full.sql` · `nonleaf-used.sql` · `products-titles.sql` + results |
| `scripts/*.py`, `data/*` | corpus and mapping instruments, and their per-node outputs |

**Read first, if you read one thing:** our own code already carries **six kinds of category-derived fact and
resolves them by four different mechanisms**, and one of those answers is a live bug in mechanism
(`design-B4.md` §0). That is the strongest evidence in this brief and it is not from a platform.

> **Revision 3, 2026-09-19 — after red-team rounds 1 and 2** (`redteam-round1.md`: 3 BLOCKING · 14 SERIOUS ·
> 14 MINOR; `redteam-round2.md`: 1 BLOCKING · 10 SERIOUS · 9 MINOR). Every finding is resolved at the root
> and listed, finding by finding, in each card's §8 "Corrections after red-team round 1" and
> "…round 2" tables. What moved a conclusion:
>
> - **B3 §2's tally** — the schema-carrying set is *not* the centrally-authored set; Salesforce is
>   merchant-authored and carries one, and it is the precedent closest to our situation.
> - **B4's precedent denominator**, derived rather than asserted: **1 of 2** like-for-like, not 1 of 5.
>   B4's confidence on (b) for definitions moved **medium → medium-high**.
> - **The mapping in `node-attribute-need.md`**, rebuilt twice. Mapped share 23.4% → 28.8% → **25.7%**, and
>   an over-mapping rate — **~1 in 4 of the mapped rows points at the wrong kind of product** — is now
>   published where revision 1 published none.
> - **The fork's option (c)**, added in revision 2, is now priced: it pays the *same* our→Shopify mapping
>   bill charged against adoption, so the recommendation is **(a) now, (c) deferred** rather than "(a) plus
>   (c)".
>
> **Snapshot bound.** Every dedup subquery in `sql/*.sql` carries
> `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside its
> `ROW_NUMBER` subquery (BRIEF §3.4). All three queries were re-run under the bound and reproduce
> **byte-identical**; no figure in this brief changed as a result.

---

## B1 · Do nodes have types — is a leaf a different kind of thing from an internal node?

*Is Snack a folder that only groups, or a type that can own a schema and hold products?*

### 1 · Options

- **(a) Two kinds: folders and types.** A discriminator on the node (or two models). A folder may not own a
  schema and may not hold products; a type may not have children.
- **(b) One kind; "leaf" only means no children today.** Leafness is derived from `numchild`. The card names
  Shopify.
- **(c) One kind with a per-node switch,** so the rule can tighten later without a migration. The card names
  Akeneo and lock condition 5.

### 2 · Who uses which, who does not

**Split, and lopsided.** Twelve of thirteen ship one kind of node. The card's option (c) is *"One kind with
a per-node switch, so the rule can tighten later without a migration (Akeneo; lock condition 5)"* — and on
the card's own wording **Akeneo is the instance, one of thirteen**. What the record actually says is that
Akeneo's `only_leaves` is a **per-tree** setting, so the correction the evidence supports is a difference of
**scope**, not of existence: *the mechanism the card names exists on one platform, at tree scope, not node
scope.* A narrower reading — a per-**node** switch governing whether a node may own a schema or hold
products — has **zero** instances, and that narrower reading is a definition this brief supplies, not one the
card states. Both readings are carried below.

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | the attribute owner is `ProductType`, published `required: ["marketplaceIds","name","displayName"]`, *"no parent, `ProductTypeList` a flat array"*; the browse tree is a separate object | #10976 §1.1 (2026-08-13 correction note) | **ambiguous** — two *objects*, one kind of node in each |
| **Shopify** | `TaxonomyCategory` `11 fields, whole`: `… isRoot Boolean! isLeaf Boolean! isArchived Boolean!` — three derived flags on one type | #11011 §1.7 | **(b)** |
| **Google** | *"every line is `id - path`"* — there is no node object | #11031 2026-09-15 comment §A; #11013 §1.7 | **(b)**, trivially |
| **eBay** | one node type; `leafCategoryTreeNode` *"`true` on **15,111** nodes and **absent** on the other 1,994"*, `childCategoryTreeNodes` present on exactly those 1,994 | #11045 §1.2 | **(b)** — but see the note below |
| **Walmart** | *"6,967 sibling PT keys in one flat map, `$ref` = **0** across 451,013,258 B"*; *"no category field in the feed at all"* | #11031 2026-09-15 comment §B; #11046 §1.5 | **no tree** |
| **Shopee** | one tree; *"`has_children` =false means the last level category"* | #11047 §1.2 (Guide 209) | **(b)** |
| **Tokopedia Era A** | `Category (field table reproduced whole, 3 of 3 rows) name · id · child []object` | #11048 §1.5 | **(b)** |
| **Tokopedia Era B** | `Category id · parent_id · local_name:string("Home Supplies") · is_leaf:bool · permission_statuses:[]string` | #11048 §1.9 | **ambiguous** — one kind, but `permission_statuses` is a per-node gate (`INVITE_ONLY` categories need *"a separate application through the Qualification Center"*) |
| **Square** | *"**`CatalogCategoryType` has 3 values**: REGULAR_CATEGORY, MENU_CATEGORY, KITCHEN_CATEGORY"*, on a node that also has `is_top_level · parent_category · path_to_root · root_category` | #11049 §1.6 | **(a)** — the only one, and the kinds are *function* (menu, kitchen), not folder/type |
| **Salesforce B2C** | *"**three roles on one `Category` type** — classification 0..1 (attribute set), primary 0..1 per catalog (breadcrumb), assignments 0..N"* | #11031 P1; #11050 §1.5 | **ambiguous** — one kind of node, three roles *per assignment*: only the classification category owns the attribute set |
| **Akeneo** | `Category`: `attributes` **absent**; *"`grep -c attributes Category.orm.yml` = **0**"*. Leaf-only is a **per-tree** `only_leaves` setting | #11069 §1.x; #11031 2026-09-15 comment §B | **(b)** + a **per-tree** switch, not per-node |
| **WooCommerce** | *"a `product_cat` term carries no attribute definitions (9 properties, whole list)"* | #11031 2026-09-15 comment §B; #11080 §1.7 | **(b)** |
| **commercetools** | the `Category` tree owns no attribute definitions; `ProductType` is flat and separate. *(The often-quoted "`leaf` occurs **0** times in 5,366,096 B of spec" is the record's answer to the **non-leaf permission** question, i.e. B2 evidence, not node-kinds evidence — flagged after red-team round 1, MINOR 29)* | #11031 2026-09-15 comment §B; #11081 §1.10 | **(b)** |
| **Magento** | one category entity, with per-node behaviour flags `is_anchor` / `custom_use_parent_settings`; ❗ *"a category carries its **own** `attribute_set_id`, unrelated to its products'"* | #11031 P1; #11082 §1.2, §1.4 | **(b)** + per-node flags that are not "accepts products" |

**Tally, on the card's wording.** (a) two kinds: **1** — Square. (b) one kind, leafness derived: **8** —
Shopify, Google, eBay, Shopee, Tokopedia Era A, WooCommerce, commercetools, Magento. (c) one kind with a
switch that lets the rule tighten without a migration: **1 — Akeneo**, at **tree** scope.
**Tally, on the narrower per-node reading:** (c) = **0**, and Akeneo moves to (b).
**Named ambiguous: Amazon** (type and tree are different objects), **Tokopedia Era B**
(`permission_statuses` gates who may list, not whether the node is a type), **Salesforce** (roles per
assignment, not kinds per node), **Walmart** (no tree exists).

**One classification judgement, declared:** eBay, Shopee and Tokopedia Era B enforce leaf-only. I tally them
to **(b)** because leafness there is still *derived from structure*, not a stored kind — the enforcement is
B2's question, not B1's. A reader who disagrees moves three rows from (b) toward (a); the finding that no
platform has a per-node switch is unaffected.

### 3 · Why

- **Square — stated (the quote) + inference (the reason).**
  **Stated**, #11049 §1.6, a warning about a *consequence*: *"When a seller creates their menu through the
  Square Dashboard, the system automatically creates catalog categories with a `CategoryType` of
  `MENU_CATEGORY`… Filter for categories where `CategoryType = REGULAR_CATEGORY`"*. Square states **no
  reason** for the discriminator existing.
  **Inference:** Square's node kinds exist because two surfaces (till and kitchen display) write into one
  tree, and the quoted warning is the cost of that. *(Split after red-team round 1, SERIOUS 12 — revision 1
  headed this bullet "stated" and called the causal sentence "the only vendor rationale in the row".)*
- **Shopify — inference.** `isLeaf`/`isRoot`/`isArchived` are all derived booleans on one type, and the
  taxonomy is authored centrally by Shopify, not by merchants. A node kind would be a governance affordance
  for authors who do not exist on the merchant side.
- **eBay / Shopee / Tokopedia B — inference, well-evidenced.** Leafness is not a kind because every
  *per-category policy* is keyed on the leaf id. eBay's own live page (collected for this brief, §B2/3)
  lists item conditions, item aspects, parts compatibility, negotiated-price eligibility and
  product-identifier policy, each retrieved *per leaf category*. A second kind of node would need a second
  policy table.
- **Akeneo — structural, stated obliquely.** Category is deliberately not the attribute owner —
  *"A category is a way of classifying products… A product can be classified in **one or n** categories."*
  set against the same page's *"A product can belong to only one family."* (#11069 §1.x). Kinds are
  unnecessary because the *schema* lives on a different object entirely.
- **Magento — inference.** `is_anchor` and `custom_use_parent_settings` are *display* switches on a node
  whose `attribute_set_id` describes the category record itself, not its products (#11082 §1.4). Magento
  needs no folder/type kind because the product's type (`attribute_set_id`) is already a separate,
  unrelated scalar.
- **Not collected:** any vendor statement giving a *reason* for the absence of a node-kind discriminator.
  There is nothing to quote — absence of a feature is rarely explained. The route that would settle it is a
  design note or RFC in the Shopify taxonomy repo's `docs/`, not in our sparse checkout.

### 4 · Our code today

`Category` is one class — `py/mono/solvent/catalogue/models.py:93` `class Category(MP_Node)` — whose
docstring still says *"Merely used for navigational purposes; has no effects on business logic."*
(`models.py:94-96`). `Meta` carries only `app_label` and `ordering = ["path"]` (`:100-102`). There is **no
`clean()` and no `Meta.constraints`** anywhere in `models.py:93-330`.

Leafness is not stored and barely read. `numchild` exists as a column
(`catalogue/migrations/0001_initial.py:34`) and **`numchild` and `is_leaf` have zero hits in first-party
backend code**; the only helpers are `has_children()` (`:322-323`), `is_has_children` (`:325-327`) and
`get_num_children()` (`:329-330`). On the frontend the read model has no structural field at all —
`ts/libs/category/shared/util-core/src/lib/category.model.ts:3-17` is
`id · name · slug · full_code · code · image · _name_en · _name_id · is_public` — and `is_leaf`/`isLeaf`
returns **zero hits across `ts/libs` and `ts/apps`**. The one surviving consumer is the legacy Vue widget
`js/solvent_js/src/js/solvent/CategorySelectWidget.vue:71-72`, and it uses `is_leaf` for *expandability*, not
selectability.

The Vue branch is in fact **dead**: `grep -rn "is_leaf" py/mono --include=*.py` returns **zero** hits, so the
API never emits the field and `!result.is_leaf` is always true — which strengthens the point rather than
qualifying it *(red-team round 1, MINOR 24)*.

Consequently **every tree node renders the "Pilih" button unconditionally** —
`ts/libs/category/tree/feature-core/src/lib/category-tree-node/category-tree-node.component.html:1-4` — and
the one category picker (`ts/libs/category/form/feature-field/src/lib/category-id-form-field/category-id-form-field.component.ts:16-52`,
registered as the formly type `category-id`) accepts any node.

**Per option, what changes:**

| Option | Backend | Frontend |
|---|---|---|
| (a) two kinds | a NOT NULL discriminator + the first `clean()`/`CheckConstraint` this model has ever had; a guard in `api/apicategory/staff_serializers.py:69-81` (create) and `:116` (`category.move`); 339 internal nodes must first be resolved, 292 of which hold products | `category.model.ts:3-17` + `api/apicategory/serializers.py:9-19` gain a field; the tree node and the picker must stop offering folders |
| (b) one kind | **nothing** | **nothing** |
| (c) per-node switch | one `BooleanField(default=True, db_index=True)`; `validate_main_category` in `api/apiproduct/staff_serializers.py:55`; a guard on turning it off in `api/apicategory/staff_serializers.py:83-148` | same field additions; hide `Pilih` where false |

**Consumers a first pass missed** *(added after red-team round 1, SERIOUS 9; full table in `design-B1.md` §"Consumers a first pass missed")*: `py/mono/solvent/catalogue/search_indexes.py:8-22` — **`CategoryIndex`**, the category's own Elasticsearch document, `guid = KeywordField(model_attr="full_code")`, so categories are indexed keyed on **`full_code`**, not `id` · `api/apiproduct/serializers.py:127, 137, 201, 208` — `main_category = CategorySerializer()` on both product **read** serializers, so any new category field ships to the customer API · `catalogue/managers.py:28-31` `CategoryQuerySet.browsable()` — the actual reader of `is_public`/`ancestors_are_public` · `ts/libs/category/action/ui-form/.../category-form-ui.component.ts:96-97` — the category **parent** picker, the same `category-id` component with the **inverse** requirement · `ts/libs/product/filter/util-core/src/lib/product-filter.util.ts:36` — a ninth `category-id` registration.

**Inherits free under all three:** `full_code` cascade (`api/apicategory/staff_serializers.py:131-146`),
`ancestors_are_public` (`models.py:271-285`), age-walling (`models.py:570-573`), replenishment
(`inventory/replenishment/inventory_replenishment_service.py:31-36`) and search browse, which is already
ancestry-based (`catalogue/search_indexes_mixins.py:22, 27-29`).

### 5 · Our numbers

`sql/nodes-full.sql` → `sql/results/nodes-full.csv`, 2026-09-19 (every figure reproduces the BRIEF baseline
exactly): **1,892 nodes · 1,553 leaves · 339 internal · 13 roots · max depth 8 · 1,686 used as
`main_category` · 292 used internal nodes · 1,394 used leaves · 206 unused nodes (159 of them leaves)**.

Children per internal node: median **4**, mean 5.5, max **90**.

The number that decides B1 is not in the baseline: **of the 292 internal nodes that hold products,
`nonleaf-classification.md` finds 21.9% of the products legitimately parked** (hand-read union, **48 nodes
= 70.3%** of the 19,522 — the 40 largest by product count, plus **the 8 rows a random-20 re-read of the tail
judged misclassified**, adopted verbatim). **That union pools a top-by-products stratum with an
error-enriched subsample, so it is not a random sample of anything** *(described correctly after red-team
round 2, SERIOUS 6)*; the 21.5% → 21.9% move is a consequence of the selection, not an independent
confirmation. So "internal node" and "folder" are **not** the same set — 14 of the 48 hand-read are real
types whose children are facets, and 9 of those 14 are in the unbiased top-40 stratum.

### 6 · Cleanest / structurally correct for us

Full sketch: `design-B1.md`. The problems, in one line each:

- **(a)** makes *giving a type a child* an illegal state. Our tree grows exactly that way:
  `Alat dan Buku Tulis > BUKU TULIS` has 219 products on the parent **and** a child of the same name;
  `SAYURAN SEGAR` grew to 90 children while keeping 222 products. It also stores `numchild == 0` twice, and
  it requires resolving all 292 used internal nodes *before* the migration can run.
- **(b)** costs nothing and changes nothing — including the thing Lock 1 needs changed: under it, the three
  non-product roots (`UNUSED` 1,923 products in subtree, `BELUM DISORTIR` 1,401, `INVENTORY KANTOR` 78)
  become product types with attribute schemas.
- **(c)** is a column add with a default and **no data change**, which is the only property that lets it ship
  before the 19,522 are cleaned. Its cost is that `accepts_products` and `numchild` can disagree, and that
  the switch records a policy with no reason attached — so the 292 still need the classification first. It
  also needs a staff surface that does not exist: the admin "Category List" is a **flat paginated table**
  (`ts/libs/category/list/feature-staff/.../category-list-staff.component.ts:27`) and the only way down is
  one page per level.

### 7 · Recommendation

**Judgement: (c), one kind with a per-node switch — but recorded as what it is, a cleanup instrument, not a
model of the world.** Confidence **medium**.

Reasoning: (a) is contradicted by our own tree's growth pattern and has no precedent in the thirteen —
Square's three kinds are a till/kitchen artefact its own vendor warns about. (b) is what we have and cannot
express the three non-product roots. (c) is a zero-row migration, is what lock condition 5 already asks for,
and — crucially — is the only option that lets the 19,522 be cleaned **incrementally**, one node at a time,
with each cleaned node locked behind the guard.

**The correction the recommendation carries, restated after red-team round 1 (SERIOUS 8):** the card and
lock condition 5 attribute the switch to Akeneo, and **on the card's own wording Akeneo is a genuine
instance — one of thirteen.** What the record actually establishes is a **scope** difference: Akeneo's
`only_leaves` is **per-tree**, not per-node (#11031, 2026-09-15 comment §B; restated in #11188's correction
comment). So the honest statement is *"one precedent of thirteen, at tree scope; no precedent at node
scope"* — **not** "zero precedent", which is what revision 1 said. A per-**node** switch would be a first;
the *mechanism* would not.

**What would reopen it:** if the 292 classification shows that almost all are cleanups (it does not —
**21.9%** are real, and red-team round 1 moved that figure up, not down), a switch is over-engineering and
(b) plus a clean-up is enough. If staff cannot be given an owner
for the flag (lock condition 5's third clause), the flag becomes a field nobody sets and (b) is honest.

**What it forces in steps 1–5:** step 1 must decide where the flag is edited, because there is no
`ProductAttribute` UI *and* no category-management UI beyond a flat table — the schema editor of lock
condition 1 and the category editor are the same screen. It also forces D14's second half earlier than step
5: `UNUSED`, `BELUM DISORTIR` and `INVENTORY KANTOR` need a home that is not a product type, and they hold
3,402 live products, not a hypothetical "Promo Ramadan".

### 8 · Limits and corrections

- **Correction to the card:** "one kind with a per-node switch (Akeneo)" — Akeneo's `only_leaves` is
  **per-tree**. Two records say so (#11031 2026-09-15 §B; #11188 comment), and both trace to the same
  2026-09-15 collection, whose corpus (`~/copilot/research/catalogue-decision-2026-09/inheritance/`) is
  **not on this machine** (BRIEF errata). So the per-tree claim is single-route and I could not re-open it.
  The route that would settle it: Akeneo's own `only_leaves` documentation, or the `Category` tree entity in
  the open-source source tree.
- **Square's `category_type` is a function type, not a folder/type kind.** Recording it as "(a)" is the most
  generous possible reading; a stricter reader tallies (a) = 0.
- **Not collected:** any vendor's stated reason for *not* having node kinds.

#### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **SERIOUS 8** | ~~"(c) as the card defines it … **0**. No platform in the thirteen has a per-node switch at all. We would be first."~~ **Struck.** B1 narrowed the card's option (c) and then built "zero precedent" on the narrowing. §2 now tallies against the **card's own wording** — *"One kind with a per-node switch, so the rule can tighten later without a migration (Akeneo; lock condition 5)"* — under which **Akeneo is one instance of thirteen**, and the correction the evidence supports is a **scope** difference (per-**tree**, not per-node). Both readings are carried; §7's headline is restated as *"one precedent of thirteen at tree scope; none at node scope"*. The recommendation (c) and its **medium** confidence are unchanged. |
| **SERIOUS 9** | Five missed consumers added to §4 and to `design-B1.md`: `CategoryIndex` (`catalogue/search_indexes.py:8-22`, the category's own ES document keyed on **`full_code`**), the product **read** serializers (`api/apiproduct/serializers.py:127, 137, 201, 208`), `CategoryQuerySet.browsable()` (`catalogue/managers.py:28-31`), the category **parent** picker (`category-form-ui.component.ts:96-97` — the same `category-id` component with the **inverse** requirement, so option (a)'s "the picker must filter" needs *two opposite* filters), and a ninth `category-id` registration (`product-filter.util.ts:36`). |
| **SERIOUS 12** | The Square "Why" bullet was headed **stated** and ran a causal sentence in the vendor's voice. Split into **stated** (the quote, which is a warning about a *consequence* and gives no reason) and **inference** (the till/kitchen explanation). |
| **MINOR 24** | The legacy Vue `is_leaf` branch is **dead** — `grep -rn "is_leaf" py/mono --include=*.py` → 0 hits, so the API never emits the field. Now said; it strengthens the section's point. |
| **MINOR 29** | The commercetools cell's *"`leaf` occurs 0 times in 5,366,096 B"* is the record's **B2** (non-leaf permission) measurement doing double duty in a B1 matrix. Flagged in the cell; the genuine B1 evidence (*"the `Category` tree owns no attribute definitions"*) was already there and now leads. |
| **SERIOUS 6 (carried)** | §5's residual-type share moves 21.5% → **21.9%** and the hand-read population 40 → **48 nodes (70.3% of the 19,522)**. |


#### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 6 (carried)** | §5's hand-read population is described correctly: the union of **the 40 largest by product count** and **the 8 rows a random-20 tail re-read judged misclassified** — an error-enriched subsample, not "a random 8". The 21.5% → 21.9% move is a selection effect; the head's own unselected share is 21.5% (9 of 40 nodes), which is why the 0.4-point gap changes nothing. |
| **Snapshot bound** | `sql/*.sql` bounded at 2026-09-19 10:27 UTC per BRIEF §3.4; all three re-run **byte-identical**. Every figure in this card is unchanged. |


---

## B2 · Can a product be assigned to a non-leaf node?

### 1 · Options

- **(a) Yes, any node.**
- **(b) Leaves only.**
- **(c) Per node, an "accepts products" switch.**

### 2 · Who uses which, who does not

**Split, 8 against 3, with three rows that do not fit the card's framing.** The card says *"eight of thirteen
platforms"* permit it and *"(eBay, Walmart, Shopee, Tokopedia)"* forbid it. The eight hold. The four do not:
**Walmart has no category tree to be leafy** (its feed carries no category field at all), and Tokopedia's two
eras must be separated — Era B states the rule, Era A's rule was never retrieved as a statement.

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | *"**Yes** — no leaf-only rule; 'most specific' is worded as a performance caution"* | #11031 2026-09-15 comment §B | **(a)** |
| **Shopify** | *"**Yes** — product created on `aa-1-13`, `isLeaf:false`, `userErrors:[]`"* — a live write, not a doc reading | #11031 2026-09-15 comment §B; #11011 rev-5 | **(a)** |
| **Google** | *"**Yes** — discouraged, never forbidden; of 20 ids Google names as submission targets, 14 are parents"* | #11031 2026-09-15 comment §B | **(a)** |
| **eBay** | error `62009`, 400, API_TAXONOMY/REQUEST: *"The specified category ID must be a leaf category."* — reproduced byte-for-byte between the rendered page and the machine-readable contract | #11045 §1.2 (`[R-2]`, `[R-20]`) | **(b)** |
| **Walmart** | *"**No** — the feed takes exactly one product type"*; and *"no category field in the feed at all"* | #11031 2026-09-15 comment §B; #11046 §1.5 | **no tree** — ambiguous |
| **Shopee** | *"Please note that only the category_id with **has_children =false** can be used to create or update products."* | #11047 §1.2, Guide 209 §1.2 `[R-39]` | **(b)** |
| **Tokopedia Era A** | the vendor's own call sequence step 1: `GET /inventory/v1/fs/:fs_id/product/category → leaf category id`. No rule sentence was retrieved | #11048 §2 `[R-18, R-21, R-23]` | **ambiguous** |
| **Tokopedia Era B** | *"It must be a leaf category that corresponds to the category tree type specified in the `category_version` property."* | #11048 §1.6 / §2 `[R-1]` (quoted whole) | **(b)** |
| **Square** | *"**Yes** — the vendor's own example categorises items as 'Clothing', the root"* | #11031 2026-09-15 comment §B; #11049 §1.6 | **(a)** |
| **Salesforce B2C** | *"No leaf rule in any artifact; a vendor fixture assigns a product to `root`, which has a child"* | #11031 2026-09-15 comment §B; #11050 §1.5 | **(a)** |
| **Akeneo** | *"Category yes by default, with a per-tree `only_leaves` setting that makes it leaf-only"* | #11031 2026-09-15 comment §B; #11188 comment | **(a) + a per-tree switch** |
| **WooCommerce** | *"**Yes** — an ordinary `wp_term_relationships` row; nothing tests leafness"* | #11031 2026-09-15 comment §B; #11080 §1.7 | **(a)** |
| **commercetools** | *"**Yes** — `leaf` occurs **0** times in 5,366,096 B of spec"* | #11031 2026-09-15 comment §B; #11081 | **(a)** |
| **Magento** | *"**Yes** — no leafness constraint on `catalog_category_product`"* | #11031 2026-09-15 comment §B; #11082 §1.4 | **(a)** |

**Tally.** (a) any node: **8** — Amazon, Shopify, Google, Square, Salesforce, WooCommerce, commercetools,
Magento. (a) + per-tree switch: **1** — Akeneo. (b) leaves only: **3** — eBay, Shopee, Tokopedia Era B.
**Named ambiguous: Walmart** (no category tree exists; the "no" is about a flat product-type field, not
leafness) and **Tokopedia Era A** (the leaf rule is implied by a call-sequence label only). **(c) a per-node
switch: 0.**

**The shape of the split is the finding.** Every platform in the (b) column is a **marketplace with a
centrally-authored tree**, and every platform in the (a) column either authors nothing (Google, Walmart) or
hands the tree to the merchant (Square, Salesforce, WooCommerce, commercetools, Magento, Akeneo) — with
Shopify and Amazon the two that author centrally *and* still permit it.

### 3 · Why

**eBay — stated, on three surfaces, two of them collected live for this brief.**

1. The Taxonomy contract error (#11045 §1.2, archived capture): *"The specified category ID must be a leaf
   category."* (`62009`).
2. **New collection, 2026-09-19, live, P0:** `https://www.edp.ebay.com/develop/guides-v2/listing-metadata/listing-metadata-guide`
   (HTTP 200, **200,027 B** on disk — revision 1's 38,126 B was `curl`'s compressed-transfer figure;
   corrected after red-team round 2, MINOR 12 — saved at `corpus/why-2026-09/ebay-edp-metadata.html`),
   verbatim:
   *"Every eBay listing must be listed in an eBay leaf category."* and *"Some metadata endpoints only accept
   leaf categories."*
3. **New collection, 2026-09-19, live, P0, a different eBay surface with a different error code:**
   `https://pages.motors.ebay.com/file_exchange/errorcodes.html` (HTTP 200, 63,985 B, saved as
   `corpus/why-2026-09/ebay-2824ab.html`), row **`87`**: *"Invalid Category. The category selected is not a
   leaf category. | Listing will fail."*

**The reason, inference but heavily evidenced by the same page:** the leaf category id is the key for every
per-category policy lookup eBay publishes — the edp guide lists, each *per leaf category*, item conditions
and condition descriptors, item aspects (`getItemAspectsForCategory`, `fetchItemAspects`), parts
compatibility, negotiated-price/Best-Offer eligibility, and the product-identifier policy
(`ProductIdentifierUnavailableText`). A non-leaf assignment would have no row in any of them. eBay's own
mitigation is a suggestion service, named on the same page: *"Use getCategorySuggestions to retrieve the most
relevant eBay leaf categories based on a provided product-related keyword."*

**What sellers do about it — the card's explicit pointer.** Collected 2026-09-19.
On eBay's own community (P0 domain, **user-generated content — evidence of seller behaviour, not of eBay's
rules**), thread *"The category is not valid, select another category."*, opened by `newlifece` 2024-01-11,
12 comments — saved as `corpus/why-2026-09/seller-69be0f.html`, HTTP 200, 909,400 B, all three quotes
grepped in the saved bytes. The seller reports *"I have tried consumer electronics &gt; others and computers
&amp; networking &gt; other and both throw the same 'The category is not valid, select another category'
error."* A reply from `nobody*s_perfect`: *"Do a search for your item, and you'll see what category other
sellers have used."* A third: *"I will just quit using eBay. FB Marketplace here I come!!!"*
A seller-tool vendor's help page (3Dsellers, **S5 — a lead, not data**;
`corpus/why-2026-09/seller-3b9900.html`, HTTP 200, 112,194 B) states the remedy as: *"eBay is requiring that
you define the category specifically… Home, Furniture & DIY -> Kitchen"* fails, *"Home, Furniture & DIY ->
Kitchen -> Kitchen Units & Sets"* succeeds. *(Both artifacts were saved during the red-team fix round —
SERIOUS 11 found they had been quoted without being written to the corpus. Provenance:
`corpus/why-2026-09/PROVENANCE.md`.)*

**So: the observed seller response to leaf-only is to reach for an `… > Other` leaf.** That is precisely the
structure our own tree already has — **44 used catch-all nodes holding 3,591 products, 32 of them leaves**
(48 / 34 counting unused nodes too; the baseline's 42 / 3,566 is used-nodes-only, so 44 / 32 is the
comparable pair — basis added after red-team round 2, MINOR 15) — and it is what a leaf-only rule would
*create more of* here (§6).

- **Shopify — inference.** Permitting it costs nothing because the taxonomy's per-node attribute list exists
  at every level, leaf or not: only 152 of 14,606 nodes have none (measured, `data/shopify-corpus-stats.json`).
- **Google — stated (the quote) + inference (the reason).**
  **Stated**, #11013 §1.7: *"All products are automatically assigned a product category from Google's
  continuously evolving product taxonomy… The Google product category `[google_product_category]` attribute
  can be used to override Google's automatic categorization in specific cases."*
  **Inference:** a leaf rule on a field the platform fills for you would be incoherent. Google states no
  reason for permitting non-leaf assignment. *(Split after red-team round 1, SERIOUS 12.)*
- **Akeneo — inference.** Leaf-only as a *setting* is what you ship when the tree is the merchant's: the
  vendor cannot know whether a given customer's tree is a partition or a facet hierarchy.
- **Not collected:** a vendor statement of *why* Walmart's feed carries no category field. Route: the
  `MP_ITEM` spec's own overview section, in the 451 MB corpus the record measured but which is not on this
  machine.

### 4 · Our code today

**Nothing forbids it, at any layer, on either stack.** Established by search, not by reading:

- `Product.main_category` — `py/mono/solvent/catalogue/models.py:427-431` — FK with
  `on_delete=models.PROTECT` (flipped from CASCADE by `migrations/0015_alter_product_main_category.py:14-22`,
  #11092), **no `validators=`, no `limit_choices_to`**.
- `Product.clean()` — `models.py:468-484` — validates `title` and `self.attr.validate_attributes()`. Category
  is not mentioned, including in its docstring table at `:471-479`.
- The **single production write path**: `api/apiproduct/staff_serializers.py:55` declares `main_category` as
  a plain `ModelSerializer` field on `ProductStaffSerializerBase`, shared by `ProductCreateSerializer`
  (`:84`) and `ProductUpdateSerializer` (`:131`); none defines `validate_main_category`.
- `catalogue/validators.py` is 47 lines and contains exactly one function, `validate_product_upc` (`:10`).
- Frontend: `Pilih` on every node (`category-tree-node.component.html:1-4`); `is_leaf`/`isLeaf` **zero hits**
  across `ts/libs` and `ts/apps`; the product form's single required picker is
  `product-update-staff-form-ui.component.ts:118-122` (`key: 'main_category'`, `type: 'category-id'`,
  `required: true`).

**What already works ancestry-wise, and therefore does not change under any option:** the Elasticsearch
`category` field is a `MultiValueField` holding *the main category plus every ancestor id* —
`catalogue/search_indexes_mixins.py:22, 27-29`, `prepare_category` returning
`[c.id for c in main_category.get_ancestors_and_self()]`, re-declared `faceted=True` on `ProductIndex`
(`solvent/search/search_indexes.py:64-65`). So browsing an ancestor already finds descendants' products, and
so do the **nine read/filter** frontend `type: 'category-id'` registrations. Counted precisely: **twelve** `type: 'category-id'` registrations exist across `ts/libs` + `ts/apps`, decomposing as **8 admin filter tables/modals** (inventory record · replenishment create-filter modal · reconciliation lines · inventory facility · purchasing price-purchase · purchasing group product-line · staff product list `product-table-staff.component.ts:123` · price purchase) **+ 1 filter form util** (`product-filter.util.ts:36`) = **9 read/filter**, plus **2 write fields** (`product-update-staff-form-ui.component.ts:119` and the category **parent** field `category-form-ui.component.ts:97`) and **1 storybook spec**. The query
field is `py/mono/solvent/api/apisearch/serializers.py:10` (`category = PositiveInteger32Field()`), applied
by the generic helper `api/apisearch/filters.py:26-29` (`_handle_equality_filters` → `queryset.filter(**validated_data)`),
which itself contains no category. *(Cite corrected after red-team round 1, SERIOUS 15 — revision 1 cited
`filters.py:26-29` as if it named the category, and referred to "five serializers" that do not exist.)*

Also missed in revision 1 *(SERIOUS 9)*: the product **read** serializers carry the category too —
`api/apiproduct/serializers.py:137` and `:208` (`main_category = CategorySerializer()`), declared at `:127`
and `:201`, with `"age_walled"` at `:76`. Any per-node field added under (a) or (c) ships to the customer
API, not just to staff.

**Per option:** see the table in `design-B2.md` §1. The two lines that matter: **leaf-only makes `add_child`
on a node holding products a data migration** (`api/apicategory/staff_serializers.py:69-81`), and it is
**not expressible as a `CheckConstraint`** because it spans two tables.

### 5 · Our numbers

`sql/nonleaf-used.sql`, `sql/nodes-full.sql`, 2026-09-19 — reproducing the baseline exactly: **19,522
products on non-leaf nodes (18.4%), 1,724 on a root; 292 used non-leaf nodes.**

The card's pointer, executed in full in `nonleaf-classification.md` (all 292 rows in
`data/nonleaf-classification.csv`, with each node's children and a 12-title sample). **48 nodes — 13,718
products, 70.3% — were read one by one**: the 40 largest by product count, plus **the 8 rows that a
random-20 re-read of the tail judged misclassified** (red-team round 1), adopted verbatim. **The 8 are an
error-enriched subsample, not a random 8** — the re-read covered 20 tail rows and tabulated only the ones it
disagreed with, so "the rule agreed on 0 of 8" restates the selection rule rather than measuring the tail
*(described correctly after red-team round 2, SERIOUS 6; the round-1 re-read put tail agreement at ~40–55%,
consistent with the top-40 stratum's 50%)*. The remaining 244 are rule-assigned. Agreement is **20 of 40
(50%) on the unbiased top-by-products stratum** and **20 of 48 (42%) on the pooled union — a lower bound**;
**the rule errs in both directions** — confusion matrix and the eight readings in
`nonleaf-classification.md` §2. Hand-read union:

| Class | Products | Share of the hand-read products |
|---|---|---|
| `under-filed` — a fitting child already exists | 7,168 | **52.3%** |
| `residual-type` — a product genuinely belongs at this level | 2,999 | **21.9%** |
| `mixed` | 1,404 | 10.2% |
| `declared-catch-all` | 1,217 | 8.9% |
| `not-a-type` | 519 | 3.8% |
| `root-parking` | 411 | 3.0% |

**The fourteen residual types all have one shape: the children are facets, not a partition.**
`Fashion > KACAMATA` (642) has children *kids / reading / sun* — an ordinary adult pair has no child.
`PAKAIAN DALAM WANITA` (299) has *bra / knickers / corset / bra-set* — the parked stock is `MINISET`.
`MENJAHIT` (225) has fifteen children, none of which is `KANCING` (buttons), which is what is parked.
`JAM TANGAN` (68, red-team read) has *kids' / men's / women's* and parks unisex couple watches.

**And three roots are not product types at all:** `UNUSED` (subtree 1,923; its depth-2 child is `AREA
DISPLAY`, then brand shop-in-shop areas `ARTEMEDIA` 830, `CARDINAL OBRAL` 353, `CARDINAL NORMAL` 166,
`OLYMPIC` 264, `FOOD COURT` 81), `BELUM DISORTIR` (*not yet sorted*, subtree 1,401, child `BARANG OBRAL`
1,382) and `INVENTORY KANTOR` (78). **3,402 current product rows, 3.2% of the catalogue — 3,209 of them
`is_active`** *(active count added after red-team round 1, MINOR 22)*.

Catch-alls, on the same basis as the baseline *(corrected after red-team round 1, MINOR 31)*: the baseline
pattern (LAINNYA / LAIN-LAIN / OTHER) over **used** nodes gives **42 nodes / 3,566 products**; a slightly
wider pattern that also catches `LAIN LAIN` gives, over **used** nodes, **44 nodes of which 32 are leaves**,
and over **all** nodes **48 of which 34 are leaves** — 3,591 products either way.

### 6 · Cleanest / structurally correct for us

Full sketch: `design-B2.md`.

- **Leaf-only** forces a home for 19,522 products *before Lock 1 ships*, and the 21.9% that are residual types
  force us to **invent a leaf per facet-parent** — a `KACAMATA BIASA`, a `MINISET`, a `KANCING`. That is the
  eBay seller behaviour collected in §3, reproduced in our own tree by design. We already have **44 used
  such nodes (48 counting unused)** *(basis added after red-team round 2, MINOR 15)*. It also makes the ordinary act of refining a category (`add_child`) illegal on any node holding
  products, which is how our tree has actually grown. And it cannot help the 3,402 products whose root is
  not a product type.
- **Any node** is a fit-check pass (§4) and costs nothing, but leaves 292 nodes owning schemas more general
  than their children's, and leaves the three non-type roots owning schemas.
- **The switch** is a zero-row migration, is enforceable at the one write path, and lets the clean-up be
  incremental. Its cost is a second field that can disagree with `numchild`, plus a staff surface that does
  not exist yet.

### 7 · Recommendation

**Judgement: (c) the per-node switch, defaulted to `True`, with the 292 cleaned behind it — and explicitly
NOT leaf-only.** Confidence **high** for "not leaf-only"; **medium** for the switch (same column, same
caveats, as B1).

Reasoning: leaf-only is a marketplace rule, and every platform that has it authors the tree centrally and
publishes a per-leaf policy table that the rule protects. We have neither. Against that, the measured cost
here is 19,522 re-homings of which 22% cannot be re-homed without inventing nodes, plus a permanent tax on
tree refinement. The eight platforms that permit it include both merchant-tool vendors *and* the two
central authors (Amazon, Shopify) — i.e. permitting it is not a merchant-tool compromise, it is the
majority position among central authors too.

**What would reopen it:** if the 292 classification is re-done and finds the residual-type share far below
20%, leaf-only becomes a one-off cleanup rather than a permanent tax. Red-team round 1 moved this figure
**up**, not down — 21.5% → **21.9%** — but only because the 8 tail rows adopted were **selected for being
misclassified**, five of them `residual-type` that the rule had called `under-filed`. **That is a selection
effect, not a measurement** *(red-team round 2, SERIOUS 6)*: it shows the rule under-produces
`residual-type` on at least some of the tail, which points away from the trigger, but it cannot size the
effect. The 244 still-rule-assigned nodes (29.7% of the products) remain the open risk, and the rule's
direction of error on them is **not** established. Or if a channel we must feed requires a leaf assignment — none of ours does today:
the Google Merchant feed builder never touches category (`solvent/third_party_api/google/content/products_api.py:188`,
and `google_product_category|product_type|googleProductCategory` → **zero hits** across
`solvent/third_party_api/google/`).

**What it forces in steps 1–5:** step 1 owns the switch and its guard. The 292 classification becomes a
work item with an owner (lock condition 5's third clause). D14's second half moves earlier: `UNUSED`,
`BELUM DISORTIR`, `INVENTORY KANTOR` and the `AREA DISPLAY` branch need a non-type home before Lock 1 makes
them types.

### 8 · Limits and corrections

- **Correction to the card:** Walmart is listed among the four that forbid non-leaf assignment. Walmart's
  feed has **no category field at all** (#11046 §1.5) — it is not a leaf rule. The honest tally is 3
  leaf-only, not 4.
- **Tokopedia must be split.** Era B states the rule verbatim; Era A's only evidence is a call-sequence
  label. The card's "(… Tokopedia)" conflates them.
- ~~**The 252 rule-assigned non-leaf nodes are weak.** 50% agreement with the hand reading, biased toward
  `mixed`.~~ **Struck** — the counts were superseded and the direction was withdrawn in round 1, yet this
  bullet carried both through revision 2 *(red-team round 2, SERIOUS 3)*. Restated: **the 244 rule-assigned
  nodes (5,804 products, 29.7%) are an estimate.** Agreement with the reading is **20 of 40** over the
  top-by-products stratum and **20 of 48** over the hand-read union — and the union pools that stratum with
  an error-enriched subsample, so 42% is a lower bound, not the rule's accuracy on the tail. **The direction
  of the rule's error is unresolved**; it errs both ways (`nonleaf-classification.md` §2). The route that
  would settle them: read them, as the 40 were.
- **Not collected:** whether any of our 292 was deliberate. There is no field recording intent, and no
  revision-history query was run. `api/category/staff/revision/` exists
  (`ts/libs/shared/history/data-access/src/lib/revision-with-previous-paging.service.ts:62`) and would settle
  it per node.

#### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **SERIOUS 6** | §5 rebuilt on the revised classification. Hand-read population 40 → **48 nodes / 13,718 products (70.3%)**; residual-type **21.5% → 21.9%**; rule agreement **50% (of 40) → 42% (of 48)**. The claim that the rule's error is one-directional is **withdrawn** — the confusion matrix is now published in `nonleaf-classification.md` §2, and the red team's re-read of 8 tail nodes (rule agreed **0 of 8**, five were `residual-type` called `under-filed`/`mixed`) is adopted verbatim. §7's reopen trigger is restated: round 1 moved the figure **away** from the trigger, and the 244 rule-assigned nodes remain the open risk with **no established direction of error**. |
| **SERIOUS 9** | §4 gains the product **read** serializers (`api/apiproduct/serializers.py:127, 137, 201, 208`) — a category field added under any option ships to the customer API, not just to staff. `design-B2.md` gains the category **parent** picker as an oppositely-constrained consumer of the one picker component. |
| **SERIOUS 11** | The seller-behaviour evidence was quoted with **no artifact on disk**, contrary to BRIEF §3.2. Both pages are now saved — `corpus/why-2026-09/seller-69be0f.html` (909,400 B) and `seller-3b9900.html` (112,194 B) — with a provenance table at `corpus/why-2026-09/PROVENANCE.md`. All three quoted sentences, including *"I will just quit using eBay. FB Marketplace here I come!!!"*, verify in the saved bytes; nothing was struck. |
| **SERIOUS 12** | The Google "Why" bullet was headed **stated**; split into **stated** (the automatic-assignment quote) and **inference** (*"a leaf rule on a field the platform fills for you would be incoherent"*). |
| **SERIOUS 15** | ~~"the eight admin category filters (`api/apisearch/filters.py:26-29` and the five serializers listed in `design-B3.md` §1)"~~ **Struck.** `filters.py:26-29` is the generic `_handle_equality_filters` helper and contains no category; the query field is `api/apisearch/serializers.py:10`. And `design-B3.md` §1 lists **eight admin tables**, not five serializers. Both corrected, and the registration count raised to **nine**. |
| **MINOR 22** | "3,402 live products" → **3,402 current rows, 3,209 of them `is_active`**. |
| **MINOR 31** | Catch-all counts mixed denominators against the baseline's used-nodes-only 42/3,566. Both bases now given: **used** nodes 44 (32 leaves), **all** nodes 48 (34 leaves), 3,591 products either way. |


#### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 3** | ~~"The 252 rule-assigned non-leaf nodes are weak. 50% agreement with the hand reading, biased toward `mixed`."~~ **Struck** — this §8 bullet still carried both the superseded counts and the direction round 1 withdrew. Restated: **244** rule-assigned nodes (5,804 products, 29.7%); agreement **20 of 40 (50%)** on the unbiased head, **20 of 48 (42%)** on the pooled union (a lower bound); **direction unresolved**. |
| **SERIOUS 6** | §5 and §7 now describe the 8 adopted tail rows as the **disagreeing subset of a random 20**, state that "the rule agreed on 0 of 8" restates the selection rule, and label the 21.5% → 21.9% move a selection effect rather than an independent confirmation. Round 1's own tail agreement figure (~40–55%) is quoted. |
| **MINOR 12** | §3's eBay edp artifact size ~~38,126 B~~ → **200,027 B** (revision 1 quoted `curl`'s compressed-transfer figure). The Appendix and `PROVENANCE.md` already carried the right number; §3 is where a reader checks the evidence first. |
| **MINOR 15** | §3 and §6 quoted the catch-all count as "48 … 34 leaves" without the basis §5 added. Both now give the **used**-nodes figures (**44 nodes, 32 leaves**), comparable with the baseline's 42, with the all-nodes figures in brackets. |
| **Snapshot bound** | `sql/*.sql` bounded per BRIEF §3.4; re-run **byte-identical**; no figure in this card changed. |


---

## B3 (= D16) · How deep should leaves go? What earns a node its existence?

*For Snack, do we go on to potato snacks? A distinct attribute set, a browse need, a reporting need, a
minimum product count?*

### 1 · Options

The card asks two things — a depth rule, and a criterion. The registry options they feed (step 1, D16) are:
**(a)** every used node is a type, 1,686 schemas · **(b)** a schema on a subset, untyped nodes inherit ·
**(c)** a coarser registry, ~Amazon's 107 food types · **(d, new since #11188)** adopt a vendor taxonomy.
The four candidate criteria are: a distinct attribute set · a browse need · a reporting need · a minimum
product count.

### 2 · Who uses which, who does not

**Split, and it is not about depth — it is about who authors.** Seven of thirteen ship a centrally-authored
classification; six hand the tree to the merchant and ship no opinion on depth at all. **Six of the seven
centrally-authored platforms materialise a schema per node; so does one of the six merchant-authored ones —
Salesforce.** *(Revision 1's "every platform that materialises a schema per node is in the first group" is
contradicted by the tally below; it survived round 1 in this lede sentence — red-team round 2, SERIOUS 2.)* No vendor in the thirteen publishes a
depth rule or an "earns a node" criterion; the closest is Amazon's and Google's "most specific", both worded
as guidance.

| Platform | Size / depth, in the record's own words | Node carries a schema? | Authored by | Cite |
|---|---|---|---|---|
| **Amazon** | `FoodAndBeverages.xsd` roots at `FoodAndBeverages` with `ProductType` an `xsd:choice` of **107 element refs**; the JSON registry floor is **1,640** distinct `…/ProductType/<name>`; *"no global count is well defined"* | yes, per product type, materialised as one JSON Schema per call | **Amazon** — *"❗ Not creatable."* 12 patterns over 877 doc files / 16,441,164 B → **0 hits each** | #10976 §1.1, §1.2 |
| **Shopify** | **14,606** categories, 26 verticals, max level 7; food branch **764** nodes, max level 6 (measured here, `data/shopify-corpus-stats.json`) | yes — median **6** attributes, 1.04% carry none | **Shopify** | #11011 §1.7; corpus `ad206247` |
| **Google** | **5,595** nodes, 21 roots, depth 7 | **no** — *"every line is `id - path`"* | **Google**, and it assigns automatically | #11013 §1.7; #11031 2026-09-15 §A |
| **eBay** | sandbox tree **17,105** nodes, **15,111** leaves (three operations agree); production tree not fetched | yes, per **leaf** — *"Each category has a different set of aspects"* | **eBay** | #11045 §1.2 (X1), §1.2 `[R-2]` |
| **Walmart** | **6,967** product types in one flat map; **383,947** attribute slots, **6,576** distinct names; `$ref` = 0 across 451,013,258 B | yes, materialised in full per product type | **Walmart** | #11031 2026-09-15 §B; #11046 |
| **Shopee** | a tree with `has_children`; size credential-gated and not measured | yes, per leaf — *"Each product category has different attribute data."* | **Shopee** | #11047 §1.2, §2 `[R-39]` |
| **Tokopedia Era A** | *"3-level"* tree (`category_version` `v1`) | axes per category, via `get_variant?cat_id=` | **Tokopedia** | #11048 §1.5, §2 |
| **Tokopedia Era B** | *"For US shops, pass `v2`, which represents the **7-level** category tree. For other regions, `v1` represents the **3-level** category tree and is the default."* | yes, per leaf, via `GET /product/202309/categories/{id}/attributes` | **TikTok Shop** | #11048 §1.9 `[R-92]` |
| **Square** | seller-authored; nodes carry `is_top_level · parent_category · path_to_root · root_category` | **no per-category attribute set exists**; the only gate is `allowed_object_types` | **the merchant** | #11049 §1.6, §1.7 |
| **Salesforce B2C** | merchant-authored catalogs | yes — the classification category's attribute groups, plus *"any parent categories"* | **the merchant** | #11050 §1.5; #11031 2026-09-15 §B |
| **Akeneo** | *"an **unlimited number of levels** (categories, subcategories, subsubcategories..)"* | **no** — `Category.attributes` **absent**; the Family owns the schema | **the merchant** | #11069 §1.x `[R-28][R-74]` |
| **WooCommerce** | merchant-authored `product_cat` terms | **no** — 9 properties, none an attribute set | **the merchant** | #11080 §1.7 |
| **commercetools** | merchant-authored `Category` tree | **no** — `ProductType` is flat and separate | **the merchant** | #11081 §1.10 |
| **Magento** | merchant-authored category EAV tree | **no** for the tree — *"**0 of 63** Catalog tables join a category to a product attribute"* | **the merchant** | #11082 §1.2, §1.4 |

**Tally, derived row by row from the table's own "Node carries a schema?" column** *(BLOCKING 1 —
revision 1 asserted "all seven are in the centrally-authored group" one sentence after naming Salesforce
as a merchant-authored schema carrier; the two were mutually exclusive and the first was false)*:

- **Centrally-authored: 7** — Amazon, Shopify, Google, eBay, Walmart, Shopee, Tokopedia (both eras).
  **Of these, 6 carry a per-node schema; Google does not** (*"every line is `id - path`"*).
- **Merchant-authored: 6** — Square, Salesforce, Akeneo, WooCommerce, commercetools, Magento.
  **Of these, 1 carries a per-node schema: Salesforce.**
- **Node carries a schema: 7 platforms = the 6 central ones + Salesforce.**

So the schema-carrying set is *not* the centrally-authored set. The single merchant-authored platform that
does put a schema on a category tree — Salesforce — is also the only platform in the thirteen that
**inherits** it down that tree (B4), which makes it the closest analogue to our situation, not an outlier to
be set aside.

**Named ambiguous:** none on this axis. **Not measured:** Shopee's tree size (credential-gated, #11068 —
not re-attempted per BRIEF §3.2); eBay's production tree (the 17,105 is the sandbox, stated as such by the
record).

**Granularity spread for the same domain: 107 (Amazon food product types) : 764 (Shopify food branch) :
5,595 (Google, whole taxonomy, no schema) : 14,606 (Shopify, whole).** The spread tracks what the tree is
*for*, not how detailed groceries are.

### 3 · Why

- **Amazon — stated (the facts) + inference (the reason).**
  **Stated**, #10976 §1.1: product types are not creatable — twelve patterns (`create a product type`,
  `request a new product type`, `custom product type`, …) over 877 doc files / 16,441,164 B return
  **0 hits each**; additions are announced through `PRODUCT_TYPE_DEFINITIONS_CHANGE.NewProductTypes`; a
  seller may only *"submit a request to update it using the Category update tool."*
  **Inference:** 107 is small because Amazon, not the seller, pays for every one. Amazon states nothing
  about *why the count is what it is*. *(Split after red-team round 1, SERIOUS 12 — revision 1 headed this
  bullet "stated, and it is a governance reason" and ran the causal sentence in the vendor's voice.)*
  The same record shows the join is mutable in Amazon's hands: of 26,135 flavour-attribute rows in
  the release notes, **15,299** carry *"Attribute is deleted and no longer associated with the product
  type."*
- **Google — stated (the quote) + inference (the reason).**
  **Stated**, #11013 §1.7: *"All products are automatically assigned a product category from Google's
  continuously evolving product taxonomy."*
  **Inference:** depth is cheap for Google because no one authors a schema per node — the taxonomy is an
  ad-targeting classification the platform fills in for you. Google states no reason for its depth.
  *(Split after red-team round 2, SERIOUS 10 — round-1 SERIOUS 12 named four bullets; three were split, this
  was the fourth.)*
- **Shopify — stated as a purpose, not as a depth rule.** The repository README (fetched 2026-09-19,
  `corpus/why-2026-09/shopify-readme-*.md`): *"Our open-source, standardized product taxonomy establishes a
  universal language for product classification"*, *"Spanning 25+ essential verticals"*. No statement about
  depth or about what earns a node was found in the README; the repo's `docs/` was not in our sparse
  checkout.
- **Akeneo — inference.** Unlimited levels with no schema on the category is the only safe default when the
  tree is the customer's: depth cannot be constrained because the vendor does not know what the tree is for.
- **The merchant-tool six — inference, restated after red-team round 1 (BLOCKING 1).** Five of the six ship
  no depth opinion because none of them puts a schema on the category tree at all, so depth costs them
  nothing. **The sixth, Salesforce, is the exception and is the relevant one**: it is merchant-authored,
  it does put attribute groups on the classification category, and it makes depth affordable by
  **inheriting down the tree** — *"the union of global groups + the classification category's groups +
  'any parent categories' of it"*, with *"the sub-category group overrides the parent group"* (#11031,
  2026-09-15 comment §B; ⚠ the record flags this row **single-route**). Revision 1 wrote that the six
  "have nothing to say about it", which deleted the one precedent that speaks directly to our case.
- **Not collected:** any vendor's stated criterion for creating a node. Searched the Shopify README and the
  record's own quotes; nothing. Route that would settle it: the `product-taxonomy` repo's
  `docs/` and its taxonomist contribution guide, which is outside our two sparse paths.

### 4 · Our code today

**Depth is read in exactly three places, and none of them is a business rule about granularity.**

- `api/apicategory/views.py:85` — `self.get_queryset().filter(depth=1)` for the browsable "top" endpoint;
  `api/apicategory/staff_views.py:32` — `Category.objects.filter(depth=1)` when the staff search box is
  empty. Both are "the roots", not a depth rule.
- `catalogue/models.py:277-278` — `path__rstartswith=OuterRef("path")`, `depth__lt=OuterRef("depth")` inside
  `set_ancestors_are_public()`.

Everything else that looks depth-sensitive is ancestry-sensitive and therefore **depth-neutral**: the ES
`category` MultiValueField carries every ancestor id (`catalogue/search_indexes_mixins.py:27-29`);
replenishment scopes by `get_descendants_and_self()`
(`inventory/replenishment/inventory_replenishment_service.py:31-36`); `full_code` is a hyphen-join of the
parent's code and the node's (`catalogue/utils.py:1-2`, `GetItemTypeCategoryFullCode`) cascaded on change
(`api/apicategory/staff_serializers.py:131-146`).

**The frontend pays for depth one tap at a time.** The tree fetches one level per expand —
`ts/libs/category/tree/feature-core/src/lib/category-tree-children/category-tree-children.component.ts:28-29`
calling `api/category/%d/subcategories/` — with no client-side tree cache or index; only the top level is
cached (`ApiEntityStreamPersistentAbstractService`, `shareReplay(1)`). There is **no faceted search**
(`facet` → zero hits across `ts/libs`, `ts/apps`).

**There is no multi-level breadcrumb trail — but an ancestry read path exists and is wired end to end**
*(corrected after red-team round 1, SERIOUS 10; revision 1's "no breadcrumbs, zero hits for `breadcrumb`"
was a word-search artefact)*: `api/apicategory/views.py:46-55` is a cached `ancestors` action returning
`category.get_ancestors_and_self()`; `ts/libs/category/list/data-access/src/lib/category-tree.service.ts:16`
is `categoryAncestorsUrl = 'api/category/%d/ancestors/'`; a **one-level-up parent link** is rendered on
every category detail page (`category-parent-link.component.ts:27` →
`category-parent-link-ui.component.ts:26-27`, taking `ancestors[length-2]`, mounted at
`category-detail-ui.component.html:1`); and the picker **pre-expands the tree along the ancestor chain** to
its current value (`category-tree-select.component.ts:50-73`). So "one level at a time" is true of a cold
drill-down and false of the picker with an initial value.

The admin has no tree at all: the category list is a flat paginated table
(`category-list-staff.component.ts:27`) and the way down is one page per level
(`category-list-children-staff.component.ts:28-32`). And staff tree search silently truncates to the first
DRF page, documented as intentional (`category-search-staff.service.ts:18-42`).

**Per option:** (a) 1,686 nodes each needing a `ProductAttribute.category` row set; (b) rows only where the
set changes — needs B4=(b); (c) a coarser tree, i.e. re-homing, since Lock 1 makes the tree the registry;
(d) the fork. **Inherits free in all four:** everything in the ancestry paragraph above.

### 5 · Our numbers

`sql/nodes-full.sql` → `sql/results/nodes-full.csv`, 2026-09-19. Full table in `design-B3.md` §0.

| Measure | Value |
|---|---|
| max depth | **8** |
| nodes by depth 1→8 | 13 · 74 · 453 · 822 · 190 · 120 · 128 · 92 |
| products by depth 1→8 | 1,724 · 11,172 · 24,257 · **49,478** · 5,683 · 6,361 · 3,737 · 3,749 |
| children per internal node | median **4**, mean 5.5, max **90** |
| nodes to cover 50 / 80 / 90 / 95 / 99% | **114 / 398 / 639 / 869 / 1,278** |
| used nodes with < 10 products | **609**, holding **2,545 = 2.4%** of the catalogue |
| used nodes at depth ≥ 6 | 328, holding 13,847 — **13,148 of them in one root** (`Perawatan Diri & Rumah Tangga`) |

**Two readings that change the question.** (i) The long tail is node-expensive and product-cheap: 36% of
used nodes hold 2.4% of products. (ii) The depth-8 tree is one branch — the household/kitchen branch, e.g.
`… > PERALATAN RUMAH TANGGA > PERALATAN DAN PENYIMPANAN DI DAPUR > PERALATAN MAKAN > PIRING > PIRING
KERAMIK` (depth 7). The rest of the catalogue is a depth-4 tree, and a depth rule stated over the whole tree
would be a rule about one branch.

**The card's own measurement, which I own — `node-attribute-need.md`:**

| Population | Nodes | Distinct attribute-need sets (measured from our titles) | Share sharing a set with another node |
|---|---|---|---|
| all used nodes | 1,686 | **68** | **98.8%** |
| used **leaves** | 1,394 | **61** | **98.7%** |
| the 639 covering 90% | 639 | **47** | — |

drawn from **8** distinct kinds (`net_content` 617 nodes · `colour` 494 · `model_code` 454 · `pack_count`
202 · `flavour` 199 · `scent` 93 · `material` 88 · `garment_size` 49; 369 nodes need none at the 20%
threshold). The inferred route — a vendor taxonomy mapped onto our nodes — answers the same question with
**776 distinct attribute names and 316 distinct sets over the 434 nodes it reaches**, median 8 per node;
**477** names over the 200 mapped nodes inside the 639. On the conservative cut (dropping every mapped row
whose target is level ≤ 2 or non-leaf): **558 names / 220 sets over 284 nodes**, and **330 names over 115
nodes** inside the 639. **And roughly a quarter to a third of the mapped rows point at the wrong kind of
product** — 6 of a random 21, Wilson 95% CI 14–50%; the top-by-products stratum is better at 2 of 16
(12.5%), and product-weighted over the products the sample covers it is 21.5% wrong plus 16.7% ancestor
(`node-attribute-need.md` §2.1). *(Inferred figures rebuilt after red-team round 1 BLOCKING 3 and again
after round 2 SERIOUS 9; the measured figures have never changed and were re-run byte-identical both
times.)*

**Shopify's food branch, measured from the corpus** (`data/shopify-corpus-stats.json`): **764 nodes, 656
leaves, max level 6**, median **5** attributes per node (mean 5.51, max 13, one node with none), **483**
distinct attribute names on the branch, and **320 distinct attribute sets across its 656 leaves** — roughly
one distinct set per two leaves, against our 61 sets across 1,394 leaves.

### 6 · Cleanest / structurally correct for us

Full sketch: `design-B3.md`. The four candidate criteria, tested:

| Criterion | Verdict |
|---|---|
| a **distinct attribute set** | **fails as a node criterion** — 1,686 nodes carry 68 distinct measured sets; 98.8% duplicate another node. If this earned a node we would have ~68 |
| a **browse need** | the only criterion our depth currently serves. The UI is a one-level-at-a-time drill-down with a **one-hop parent link and no full trail**, plus a picker that pre-expands along the ancestor chain — so each level costs a tap going down and gives one hop back *(restated after red-team round 1, SERIOUS 10)* |
| a **reporting need** | already satisfied at any depth: the ES `category` field carries every ancestor id, so all **nine read/filter** `category-id` registrations match a whole subtree from one id (12 registrations in total; decomposition in B2 §4) |
| a **minimum product count** | the only one that discriminates: 609 used nodes hold < 10 products, 216 hold < 3 |

Pruning, priced: a "≥ 10 products or merge into the parent" rule merges **609 nodes and moves 2,545
products**, leaving 1,077 used nodes. At a threshold of 3: 216 nodes, 315 products. Neither is a
recommendation; both are the price tag. The 206 currently unused nodes are separately free to delete — but
**there is no staff delete endpoint**: `CategoryStaffViewSet` carries `CreateModelMixin` and
`UpdateModelMixin` only (`api/apicategory/staff_views.py:37-44`), and deletion happens only through Django
admin (`catalogue/admin.py:60-62`).

### 7 · Recommendation

**Judgement: D16 = (b) — a schema on a subset of nodes, the rest inheriting — with the subset chosen by
"the measured attribute need differs from the parent's", and a separate, lower-priority pruning rule of ≥ 10
products.** Confidence **medium-high** on (b); **low** on the specific pruning threshold, which is a
merchandising call, not a data one.

Reasoning: (a) authors 1,686 schemas of which 1,665 duplicate another node's — the lock's own reopen trigger
("staff cannot keep a ~639-node schema coherent") is that outcome written down in advance. (c) means a
coarser *tree*, because Lock 1 makes the tree the registry — so (c) is re-homing, i.e. a smaller version of
(d). (b) is the only option whose authoring bill is bounded by the number of *distinct sets* at all, rather
than by the number of nodes — **and it is only available if B4 = (b)**. B3 and B4 are one decision wearing
two numbers.

**The bill is a range, and this recommendation assumes the lower half of it** *(put in the reasoning itself
rather than only in the reopen clause — round-1 SERIOUS 17, applied to `TREE.md` in round 2 after the
round-1 write was lost; red-team round 2 BLOCKING 1)*: **68** distinct sets is the measured floor — what our
own titles already distinguish — and `node-attribute-need.md` §0 says explicitly that the measured route
*"**under**-states the need"*. The inferred route gives **316** distinct sets over just the 434 nodes it
reaches (**220** on the conservative cut) — about 0.7 sets per node against the measured route's 0.04 — and
over-states it. A real schema lands between. **So (b)'s advantage over (a) is honestly "tens to low hundreds
of sets versus 1,686 nodes", not "68 versus 1,686".** At the inferred end the gap narrows enough that (a)
plus a good copy-from-sibling affordance becomes competitive, which is the first thing to re-test once any
real schema exists.

**On depth specifically: no depth cap.** Depth is not what costs us — 328 deep nodes hold 13,847 products
and **95%** of them (13,148) are one branch, `Perawatan Diri & Rumah Tangga` *(87% was wrong in revision 1
and was still live in §7 through revision 2 — red-team round 2, BLOCKING 1; §5's own table already carried
13,148 of 13,847, so §7 contradicted §5 four paragraphs apart. The correction strengthens the point)*.
What costs us is *node count without product count*, and that is a
product-count rule, not a depth rule. Every platform that publishes a deep taxonomy is at least as deep as
ours: **Shopify's max level 7 is 0-based, i.e. eight levels — exactly our max depth 8** *(MINOR 28 —
revision 1's "Shopify 7 … deeper than our median" invited the reading that 7 < 8)*; Google depth 7;
eBay ~6 in the sandbox tree; Tokopedia's `v2` tree is 7-level.

**What would reopen it:** a measurement showing the 68 sets are an artefact of my eight detectors rather
than of the catalogue (the honest attack — see `node-attribute-need.md` §4); or a decision that the schema
must carry facts our titles never captured (allergens, halal, storage), in which case the measured floor is
irrelevant and the inferred ceiling is the real bill — **776 names over the 434 mapped nodes, or 558 on the
conservative cut** — with the caveat that about a quarter to a third of those mapped rows point at the wrong
kind of product (`node-attribute-need.md` §2.1). *(715 was the revision-1 figure and was still live here
through revision 2 — red-team round 2, BLOCKING 1.)*

**What it forces in steps 1–5:** D16 cannot be closed before D15, and the schema editor of lock condition 1
must show *inherited* vs *own* rows from day one, because under (b) that distinction is the product. It also
makes "where is a set authored" a first-class staff concept, which the current flat category table cannot
show.

### 8 · Limits and corrections

- **The 68 sets are a property of eight regexes.** Stated with the detectors and the threshold in
  `node-attribute-need.md` §1 and attacked in its §4. A stricter instrument hand-labels a sample per kind;
  not done.
- **`model_code` is not an attribute** (454 nodes). It detects a supplier code embedded in the title. Left
  in the table because removing it would be a classification judgement made inside a measurement.
- **Shopee's tree size and eBay's production tree were not measured** — credential-gated (#11068) and
  out-of-scope respectively. Both are stated as such in the records.
- **Amazon's "107 food types"** is the `xsd:choice` count in the **legacy XSD** registry. The record's own
  correction note says the modern `ProductType` resource is *"flat on the wire"* and that the registry is
  hierarchical on the strength of **one sentence** in one guide. So 107 is a real count of a real artifact,
  not a statement about today's JSON registry.

#### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **BLOCKING 1** | ~~"Node carries a schema: **7** — and **all seven are in the centrally-authored group**. Of the six merchant-authored, exactly one (Salesforce) puts a schema on the category tree at all."~~ **Struck — the two sentences were mutually exclusive and the first was false on the table's own rows.** §2 now derives the tally row by row: centrally-authored **7**, of which **6** carry a per-node schema (**Google does not**); merchant-authored **6**, of which **1** does (**Salesforce**); schema-carrying total **7 = 6 central + Salesforce**. §3's "the merchant-tool six have nothing to say about it" bullet is rewritten: five of the six are silent because they put no schema on the tree, and **the sixth, Salesforce, is the one precedent that speaks directly to our case** — merchant-authored, schema on the category tree, and inheriting down it. Revision 1's wording deleted exactly that precedent. |
| **SERIOUS 10** | ~~"There are **no breadcrumbs** (`breadcrumb` → zero hits across `ts/libs`, `ts/apps`)"~~ **Struck as a word-search artefact.** §4 now cites the ancestry read path that exists — `api/apicategory/views.py:46-55` (cached `ancestors` action), `category-tree.service.ts:16` (`categoryAncestorsUrl`), the one-hop parent link rendered on every category detail page (`category-parent-link-ui.component.ts:26-27`, mounted at `category-detail-ui.component.html:1`), and the picker's ancestor pre-expansion (`category-tree-select.component.ts:50-73`). §6's "browse need" criterion is restated as *"one-level-up link, no full trail"*. |
| **SERIOUS 17** | ⚠️ **This row was wrong when written: the edit reached `design-B3.md` but not `TREE.md` §7 until round 2** (red-team round 2, BLOCKING 1). §7 reasoned from the measured floor (68) while the file's own inferred route says (then) 347 sets over the mapped quarter. The bill is now stated as a **range in the reasoning itself**, not only in the reopen clause: 68 floor · 347 inferred over the 485 mapped (233 conservative) · 1,686 under (a) — and the recommendation says which end it assumes and what re-tests it. (b) stays the recommendation; its advantage over (a) is restated as *"tens to low hundreds of sets versus 1,686 nodes"*. Confidence **medium-high**, unchanged. |
| **BLOCKING 3 (carried)** | ⚠️ **§5 was updated; §7's "the inferred ceiling (715 names)" was not, until round 2** (red-team round 2, BLOCKING 1). §5's inferred figures rebuilt: **715 → 810** names, **290 → 347** sets, over **395 → 485** mapped nodes; **436 over 185 → 491 over 223** inside the 639; conservative cut (**574 / 233 / 309**; **340 over 129**) published; over-mapping rate ~25% added. The **measured** figures — 68 / 61 / 47 sets, 8 kinds — are unchanged and were re-run byte-identical. |
| **SERIOUS 12** | The Amazon "Why" bullet was headed *"stated, and it is a governance reason"*; split into **stated** (non-creatability, the 12-pattern instrument, the Category update tool) and **inference** (*"107 is small because Amazon, not the seller, pays for every one"*). |
| **SERIOUS 9** | The category-filter registration count is **9**, not 8. |
| **MINOR 18** | ~~"87% of them are one branch"~~ → **95%** (13,148 of 13,847). The correction strengthens the claim. ⚠️ **This row was wrong when written: the edit did not reach `TREE.md` §7 until round 2** (red-team round 2, BLOCKING 1). |
| **MINOR 28** | Shopify's `level` is 0-based; "max level 7" is **eight levels = exactly our max depth 8**, now said where the comparison is made. |


#### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **BLOCKING 1** | **§7 had never been edited — three round-1 corrections rows claimed changes that were not in the file.** All three are now applied: ~~"87% of them are one branch"~~ → **95%** (13,148 of 13,847; §5's own table already carried it, so §7 contradicted §5 four paragraphs apart); ~~"the inferred ceiling (715 names)"~~ → **776 over 434 mapped, 558 conservative**, with the over-mapping caveat; and **the bill range is now in the Reasoning paragraph itself** — 68 floor · 316 inferred over the 434 mapped (220 conservative) · 1,686 under (a) — with the restatement *"tens to low hundreds of sets versus 1,686 nodes"*. |
| **SERIOUS 2** | ~~"Every platform that materialises an attribute schema per node is in the first group."~~ **Struck** — round-1 BLOCKING 1's error surviving in the §2 lede, contradicted by the derived tally twenty lines below. Restated: **six of the seven centrally-authored platforms materialise a schema per node; so does one of the six merchant-authored ones — Salesforce.** |
| **SERIOUS 10** | §3's **Google** bullet was the fourth of the four round-1 SERIOUS 12 named, and the only one left unsplit. Now **Stated** (the automatic-assignment quote) + **Inference** (*"depth is cheap because no one authors a schema per node"*). |
| **SERIOUS 9 (carried)** | §5's inferred figures rebuilt on the fixed resolver: **810 → 776** names, **347 → 316** sets, over **485 → 434** mapped; the 639 cut **491 / 223 → 477 / 200**; conservative **574/233/309 → 558/220/284**, **340/129 → 330/115**; over-mapping **25% → 28.6%** on a topped-up random stratum of 21, with the top-by-products stratum (12.5%) and product-weighted figures added. |
| **MINOR 17** | The over-mapping headline now carries all three strata and a product-weighted rate, not only the worst one. |
| **Snapshot bound** | `sql/*.sql` bounded per BRIEF §3.4; re-run **byte-identical**; every measured figure in this card is unchanged. |


---

## B4 (= D15) · What flows down from parent to child, per kind of fact?

*If Food has Rasa, does Instant noodle get it automatically? Same for requiredness, allowed values,
age-walling, replenishment settings, "accepts products".*

### 1 · Options

- **(a) Nothing flows; every node complete on its own.**
- **(b) Inherit with override** (the card names Salesforce: sub-category over parent over global).
- **(c) Universal set on the root, additions on the leaves, nothing in between.**
- **(d) Per kind of fact, not one switch** — attributes may inherit while age-walling must.

### 2 · Who uses which, who does not

**Near-unanimous, and the card states it correctly: one of thirteen inherits attribute definitions down a
category tree.** The columns below are the record's own, from the 2026-09-15 pass on #11031 ("What flows
down a type tree"), which collected seven sub-questions per platform.

| Platform | Child's attribute set ⊇ parent's? — the record's words | Override / removal | Option |
|---|---|---|---|
| **Amazon** | *"No tree on the attribute owner — `ProductType` has exactly 3 properties; set materialised per product type as one JSON Schema per call."* Browse-node refinements: *"219 of 237 parent→child pairs superset, **18 not**"* | *"No mechanism named; the meta-schema vocabulary is 12 keywords, none an override or exclusion keyword"* | **(a)** |
| **Shopify** | *"**No** — materialised per node and the child often drops: **4,668 of 14,580** pairs in the published `v2026-08` file, **4,877** measured live. `\"inherit` → **0** in 95,136,132 B"* | *"Not inheritance; the child's own list is authoritative. Enforced at write"* — the same mutation succeeded on the parent's product and was refused on the child's with *"Owner subtype does not match the metafield definition's constraints."* | **(a)** |
| **eBay** | **Aspects: no** — *"leaf-only and self-contained."* **Category *features*: yes, explicitly** | Features: *"yes — 'override' is eBay's own word and the wire format is built on it"* | **(d)** in practice — two kinds of fact, two answers |
| **Google** | *"No per-node set exists — one global `ProductAttributes` bag; 5 methods, none takes a category"* | *"**Yes for requiredness** — 16 named Apparel sub-categories are Optional where ancestor `166` is Required, as an enumerated prose exception list"* | **(a)** + an enumerated exception list |
| **Walmart** | *"No tree on the attribute owner — 6,967 sibling PT keys in one flat map, `$ref` = **0** across 451,013,258 B; materialised in full per PT (383,947 slots, 6,576 names)"* | *"No child node exists to; every PT and `Visible` carry `\"additionalProperties\": false`"* | **(a)** |
| **Shopee** | *"**No inheritance mechanism at all** — 0 hits across 1,704,281 B + 3,302,641 B"* | *"No override, because no inheritance"* | **(a)** |
| **Tokopedia Era A** | axes come from `get_variant?cat_id=`; no inheritance mechanism named | — | **(a)** |
| **Tokopedia Era B** | *"Bound to one leaf category; no mechanism named. Non-leaf nodes cannot be queried for attributes at all"* | *"No override, because no inheritance"* | **(a)** |
| **Square** | *"**No per-category attribute set exists**; the only gate is `allowed_object_types`"* | *"Nothing inherited for attributes. For `online_visibility` the child could **not** hold a differing value — the parent's write rewrote the child row, same `updated_at` to the millisecond"* | **(a)** for attributes; **forced inheritance** for one other fact |
| **Salesforce B2C** | *"**Yes** — the model is the union of global groups + the classification category's groups + 'any parent categories' of it. ⚠ **Single route**"* | *"**Yes by id collision** — 'the sub-category group overrides the parent group'. *Removal* of a group is never stated"* | **(b)** — the only one |
| **Akeneo** | *"**Yes on the Family tree, SaaS only** — the vendor names it 'Attribute Inheritance'. **Category tree: none.** FamilyVariant levels hold **disjoint** sets: values flow, definitions do not"* | *"Cannot remove an inherited attribute while linked (documented workaround: detach → edit parent → re-attach); completeness requirements explicitly cannot be overridden"* | **(b) on a different object** |
| **WooCommerce** | *"**Neither** — a `product_cat` term carries no attribute definitions… 514 lines contain `product_cat`; **0** also contain `attribute_taxonom`"* | *"Nothing inherited; unset `display_type`/`thumbnail_id` fall back to a **site option**, never the parent"* | **(a)** |
| **commercetools** | *"**`ProductType` is flat** — its property list has no parent, ancestors or children. The `Category` tree owns no attribute definitions"* | *"Nothing inherited on either object"* | **(a)** |
| **Magento** | *"**No** for the category tree — attribute sets are flat (4 columns, no parent); **0 of 63** Catalog tables join a category to a product attribute"* | *"Per node for category EAV (`is_anchor`, `custom_use_parent_settings`); attribute-set 'Based On' copies once with no standing link"* | **(a)**; a **copy-once** mechanism, not inheritance |

*All rows **except Tokopedia Era A**: #11031, comment of 2026-09-15T08:28:21Z, §B (13 rows —
`evidence/issues/11031.md:1338-1352`), which cites the per-platform records. **The Tokopedia Era A row is
this brief's own construction from #11048 §1.5 and §2** (`[R-18, R-21, R-23]`): Era A's axes come from
`GET /inventory/v2/fs/:fs_id/category/get_variant?cat_id=`, reached after step 1 returns a "leaf category
id", and no inheritance mechanism is named anywhere in the Era A corpus. Attribution corrected after
red-team round 1, SERIOUS 4 — the substance was never in dispute, the footnote was.*

**Tally.** (a) nothing flows for attribute definitions: **11 of 14 rows** (Amazon, Shopify, Google, Walmart,
Shopee, Tokopedia A, Tokopedia B, Square, WooCommerce, commercetools, Magento). (b) inherit with override
down a **category** tree: **1** — Salesforce, flagged by the record itself as **⚠ single route**. (b) on a
different object: **1** — Akeneo's Family tree, SaaS/paid edition only. (c) root-set-plus-leaves: **0**.
**Named ambiguous / partial: eBay** (aspects no, category *features* yes — the only platform that answers
per kind of fact), **Google** (no set at all, but requiredness has descendant exceptions as prose),
**Square** (`online_visibility` is *forced* down, observed three ways but stated in no vendor text),
**Magento** (`is_anchor` / "Based On" are per-node and copy-once).

**So the unanimity is narrower than "nothing flows" — and the denominator has to be derived, not asserted.**
*(BLOCKING 2. Revision 1 asserted "1 of 5" and counted eBay as a non-inheritor in the same brief that quotes
eBay's inheritance paragraph as the fullest in the thirteen. Both halves were wrong.)*

**The derivation.** Inheritance down a category tree is only *expressible* where an **internal** category
node owns a per-node attribute schema — otherwise there is nothing for a child to inherit from, and "does
not inherit" is not a choice the platform made. Applying that filter to the table's own rows:

| Platform | Does an **internal** category node own a per-node schema? | Then: does it inherit? |
|---|---|---|
| Amazon | **no** — the attribute owner is `ProductType`, flat, not the category tree | n/a |
| Shopify | **yes** — measured on the corpus: **2,606 of 2,664 internal nodes (97.8%) carry ≥1 attribute**, median 5; **14,254 of 14,580 parent→child pairs (97.8%) have a parent with something to inherit** | **no** — `inherit` = 0 occurrences; 4,569 pairs where the child drops a parent attribute |
| Google | **no** — one global bag, no per-node set | n/a |
| eBay | **no, for aspects** — *"leaf-only and self-contained"* | n/a for aspects; **yes for category *features***, which *are* attached to every node — and eBay inherits those, explicitly, with override |
| Walmart | **no** — flat product-type map, no tree | n/a |
| Shopee | **no** — per leaf only | n/a |
| Tokopedia A | **no** — axes fetched per (leaf) category id | n/a |
| Tokopedia B | **no** — *"Non-leaf nodes cannot be queried for attributes at all"* | n/a |
| Square | **no** — no per-category attribute set exists | n/a |
| **Salesforce** | **yes** — the classification category's attribute groups, unioned with *"any parent categories"* of it | **yes**, with override by id collision. ⚠ record flags the row **single-route** |
| Akeneo | **no** on the category tree (`Category.attributes` absent); **yes on the Family tree**, a different object, SaaS only | **yes**, on the Family tree — *"automatically inherit every attribute from the parent level"* |
| WooCommerce | **no** | n/a |
| commercetools | **no** | n/a |
| Magento | **no** — *"0 of 63 Catalog tables join a category to a product attribute"* | n/a; attribute-set *"Based On"* copies once with no standing link |

**Four defensible denominators, and what each says:**

| Denominator | Reading | Result |
|---|---|---|
| all platforms | the card's framing | **1 of 13** |
| any category tree that owns attributes *anywhere*, leaves included | revision 1's figure | 1 of 5 — **and it is wrong**, because it counts eBay, Shopee and Tokopedia B as having declined something they cannot express |
| **internal category nodes own a per-node schema** — like-for-like with what D15 asks | the only comparison where "inherit or not" is a real choice | **1 of 2 — Shopify does not, Salesforce does** |
| the same, admitting Akeneo's Family tree as a schema-owning tree | broadest honest reading | **2 of 3** |

**The recommendation uses 1 of 2 (and names 2 of 3).** Reconciling eBay: eBay is the platform that
demonstrates the *per-kind-of-fact* answer directly — the fact it attaches only to leaves (aspects) it does
not inherit, and the fact it attaches to every node (category features) it **does**, explicitly, with
override and a published wire format for it. eBay is therefore evidence **for** B4 = per-kind, and evidence
**for** inheritance wherever a fact is attached tree-wide.

### 3 · Why

- **eBay — stated, and it is the fullest statement anywhere in the thirteen.** `GetCategoryFeatures`
  Overview: *"The root node of each category tree has a set of feature and value settings that define the
  top-level defaults for the site. Each child category in the tree inherits its settings from its parent
  category, so the defaults set at the root node flow down through the rest of the tree. That said, there
  are some categories that 'override' the root settings, which means that some categories have default
  settings that differ from the defaults set at the root node."* And on the wire format: *"Due to the large
  number of eBay categories, the response from GetCategoryFeatures uses an **inheritance override model**…
  **Store the data locally and then manage the data on the client side.**"* (#11031, 2026-09-15 comment §B.)
  **Read the second quote as carefully as the first: the only vendor that inherits also says the effective
  set is not recomputed on read.** The artifacts behind these quotes are `web.archive.org` captures dated
  2025-01-12 to 2026-02-08, because `developer.ebay.com` refused all six attempts with HTTP 403 — and it
  refused again for this brief on 2026-09-19 (two URLs, HTTP 403, 1,832 B each).
- **Akeneo — stated.** *"…child families like 'Belts', 'Scarves' or 'Sunglasses', which automatically
  inherit every attribute from the parent level."* (#11031, 2026-09-15 comment §B.) This is the **only**
  quote in the thirteen about attribute *definitions* flowing down — and it is about the Family tree, not
  the category tree, and the feature is absent from the open-source edition.
- **Shopify — inference, strongly constrained.** Shopify authors all 14,606 nodes itself. Inheritance is a
  tool for keeping a hand-authored tree affordable; a central taxonomy team materialises instead, and pays
  for it once. The measured consequence is that children freely *drop* parent attributes
  (4,569 of 14,580 pairs, measured here — see §8), which inheritance-with-override cannot express without a
  tombstone.
- **Salesforce — inference on the *why*; the mechanism is quoted.** Its category tree is the merchant's, and
  its attribute model is a union of *global groups* + the classification category's + its ancestors' — i.e.
  inheritance is how a merchant-authored tree of arbitrary size is kept affordable. That is precisely our
  situation. **The record flags the whole row as single-route.**
- **A correction the record makes about itself, worth carrying:** an earlier pass cited Salesforce's
  *"cannot be overridden"* for the category tree. The 2026-09-15 comment retracts it — that sentence is
  about the **master → variant product tree**, not the category tree, and on the category tree Salesforce's
  own word is "override" (#11031, 2026-09-15 comment §C).
- **Not collected:** any vendor's stated *reason* for materialising rather than inheriting. Route that would
  settle it: a taxonomy design note in the Shopify repo's `docs/`, outside our sparse checkout.

### 4 · Our code today

**Our own code already answers B4 four different ways, for four different kinds of fact.** This is the
strongest evidence in the brief. Full detail: `design-B4.md` §0.

| Kind of fact | Where it lives | Flows down? | Cite |
|---|---|---|---|
| attribute **definitions** | `ProductAttribute.product_class` FK, one `ProductClass` row, 5 attributes | **no tree at all** — `ProductClass.default()` is `ProductClass.objects.get()` with no filter, raising `MultipleObjectsReturned` the moment a second row exists | `catalogue/models.py:618-624`, `:88-90`; read at `api/apiproduct/staff_views.py:66-67` and `api/apiproduct/staff_serializers.py:116-119` |
| **requiredness** | `ProductAttribute.required`, one global boolean | no tree | `catalogue/models.py:655` |
| **age-walling** | a flat list of 8 category ids in settings | **no — exact id match, and it is wrong because of it** | `catalogue/models.py:570-573`; `apps/solvent/config/settings/base.py:924-937` |
| **replenishment scope** | `get_descendants_and_self()` → `Q(product__main_category__in=descendant_ids)` | **yes, computed** | `inventory/replenishment/inventory_replenishment_service.py:31-36` |
| **public visibility** | `is_public` + `ancestors_are_public` | **yes, materialised by a subtree bulk `update()`** | `catalogue/models.py:149-157`, `:271-285` |
| **search browse scope** | ES `category` = main category **plus every ancestor id** | **yes, materialised on the product** | `catalogue/search_indexes_mixins.py:22, 27-29`; `solvent/search/search_indexes.py:64-65` |

**Age-walling, verbatim, because it is the load-bearing example:**

```python
# py/mono/solvent/catalogue/models.py:570-573
@property
def age_walled(self) -> bool:
    # TODO(irvan): Fix this so this is no longer hardcoded.
    return self.main_category_id in settings.AGE_WALLED_CATEGORY_IDS
```
```python
# py/mono/apps/solvent/config/settings/base.py:928-937
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

The list names **both** `17 # cigarettes parent category` **and** `117 # cigarettes` — the fingerprint of an
exact-id match standing in for an ancestry rule. A new child under 17 is silently unwalled. The test
settings set the list empty (`shared/test_utils/django/settings.py:173-174`), so no test catches it. The
flag is copied into the search index (`solvent/search/search_indexes.py:45`, `:134-135`) and exposed as an
**opt-in** query filter — the integration test asserts the filter is omitted when the param is absent
(`api/apisearch/integration_tests/product_search_age_walled_filter_integration_test.py:23`, `:39`).

**Per option, what changes:** `design-B4.md` §§1–3. The cost that decides it: under **(b)** the effective set
is a union over `get_ancestors_and_self()` — a `@cached_property` over one treebeard query
(`catalogue/models.py:287-301`) — which is one extra query per category per request, cheap on a product page
and not cheap on the staff list, the feed or a reindex. eBay's answer to exactly that is *"Store the data
locally."*

**What inherits free:** `is_public`, replenishment and search ancestry already work. **What does not, under
any option:** a category change never reindexes its products. `Category.save()` enqueues only its own
document (`catalogue/models.py:251-253`), the only `post_save` on `Category` recomputes
`ancestors_are_public` (`catalogue/receivers.py:18-20`), and `set_ancestors_are_public()` writes the subtree
with a bulk `QuerySet.update()` that fires **no signal** (`:271-285`). The asymmetry is acknowledged in code
at `solvent/search/receivers.py:26-30`.

### 5 · Our numbers

- **The universal set is one attribute.** Post-condition-2 (weight, length, width, height become NOT NULL
  columns) the entire attribute corpus is `manufacturer`: **46,499 value rows** over 106,161 products, of
  which **15,475 rows carry a junk value** (`{0,-,00,000,.}`) and **12,512 rows carry the literal `'0'`**;
  separately, **5,580 distinct raw values** (5,541 after trim+lower). *(Revision 1 wrote "5,580 distinct raw
  values, of which 15,475 are junk", which is arithmetically impossible — 15,475 is a row count, not a
  distinct-value count. Corrected after red-team round 1, MINOR 21.)* Baseline,
  `sql/results/baseline.json`, 2026-09-19. As measured today it is five attributes and 471,143
  value rows, four of them 106,161 each.
- **What (a) would cost:** 1,686 nodes × their own complete row set, when `node-attribute-need.md` measures
  **68 distinct need-sets** and **98.8%** of nodes sharing a set with another. (a) stores the same set 1,665
  times.
- **What (b) buys:** the 639 nodes covering 90% of products span **47** distinct measured sets. Under (b) the
  authoring bill is the number of *places a set changes*, bounded above by 68.
- **What (c) cannot express:** our food branch is four levels
  (`Makanan dan Minuman > MAKANAN & BAHAN MAKANAN > MIE, BIHUN, KWETIAU INSTAN > MIE INSTAN BUNGKUS`), and
  727 used nodes sit at depth 4 with 328 at depth ≥ 6. "Root plus leaves, nothing in between" has nowhere to
  put `Rasa`.
- **Age-walling, sized (measured 2026-09-19 from `sql/results/nodes-full.csv`).** The 8 listed ids resolve
  to: `17 ROKOK & LAINNYA` (d2, 5 children, 0 direct, **92** in subtree) · `115 LIGHTER ROKOK` (0) ·
  `117 ROKOK` (**92**) · `145 KESEHATAN SEKSUAL` (d3, 4 children, 0 direct, **36** in subtree) ·
  `931` (0) · `932` (**5**) · `933` (**27**) · `934` (**4**). **Total walled today: 128 products.** The union
  of the 8 subtrees is 11 nodes and also 128 products — so **an ancestry rule would newly wall 0 products
  today**. The defect is real in mechanism and **latent in data**: the three descendant nodes the list does
  not name currently hold no products, and the list already works around the problem by naming both the
  parent (17) and the child (117). The cost of the fix is therefore zero re-classification, which makes it
  the cheapest item on the v7 page's decision-free list — and the failure mode is a future child, not a
  current one.

### 6 · Cleanest / structurally correct for us

Full sketch: `design-B4.md`.

- **(a)** gives the simplest editor (one screen, one list, nothing to explain) and the largest authoring
  bill, and it is what the eleven platforms ship — **all of which either author centrally or have no tree on
  the attribute owner**. It has one real advantage over (b) that is easy to miss: **a category move changes
  nothing.** Under (b) a move silently rewrites the effective schema of every product in the subtree, and
  `api/apicategory/staff_serializers.py:104-148` validates nothing beyond `full_code` uniqueness and
  treebeard's `InvalidMoveToDescendant`.
- **(b)** is the only option whose bill is bounded by 68 rather than 1,686. Its costs are concrete: the
  effective set must be computed or materialised (three ways, all priced in `design-B4.md` §2); the move
  becomes a schema migration needing a pre-flight; and the editor must show *inherited from X* vs *own*.
  **Copy Akeneo's restriction — inherit-and-add, override `required`, never remove — and the tombstone
  disappears from the schema entirely.** Akeneo's own words: an inherited attribute cannot be removed while
  linked, and completeness requirements *"explicitly cannot be overridden"*.
- **(c)** matches today's data exactly (one class, five universal attributes) and cannot express
  `Food → Rasa` on a four-level branch. Google is the nearest precedent and it degrades into an enumerated
  prose exception list.

### 7 · Recommendation

**Judgement: D15 is not one switch. Record it as (d) — per kind of fact — with this table as its content,
and attribute definitions answering (b), inherit-and-add with a `required` override and no removal.**
Confidence **high** that D15 must be per-kind; **medium-high** that definitions should be (b) — raised from
*medium* by the derived denominator in §2. *(The judgement line was not updated in round 1 although §7's
closing paragraph and the revision header both recorded the move — red-team round 2, SERIOUS 4.)*

| Kind of fact | Answer | Why |
|---|---|---|
| attribute **definitions** | **(b) inherit, add-and-override, never remove** | 68 sets over 1,686 nodes; Akeneo's no-removal restriction is the cheap form of it |
| **requiredness** | inherits with the definition; a child may tighten, never loosen | Amazon: *"Requiredness is a property of this join, not of the Attribute"* — the same attribute is required for one product type and optional for another, and required at `CHILD` but not at `PARENT` (`evidence/issues/10976.md:158`; empty section marker corrected after red-team round 1, MINOR 30) |
| **allowed values** | inherits; a child may narrow. **A4 decides the value model; TREE states only that narrowing is expressible as an override row and widening is not** | — |
| **age-walling** | **must flow down by ancestry** | today's exact-id list is a live bug (§4); already listed as decision-free work on the v7 page |
| **replenishment** | already flows down | `inventory_replenishment_service.py:31-36` |
| **`accepts_products`** | **must NOT flow down** | a folder's *descendants* include the nodes that do accept products, so inheriting `false` would disable exactly the nodes the flag exists to enable *(justification corrected after red-team round 1, MINOR 26 — "a folder's children are exactly the nodes that do accept products" is false on an 8-deep tree; the conclusion is unchanged)* |
| **`is_public`** | already flows down, materialised | `catalogue/models.py:271-285` |

**On the precedent count, derived in §2:** the like-for-like denominator — platforms whose **internal**
category nodes own a per-node schema, so that inheriting is a real choice — is **Shopify versus Salesforce,
1 of 2**, or **2 of 3** admitting Akeneo's Family tree. It is not 1 of 13, and it is not the 1 of 5 revision
1 asserted. Three of the four platforms revision 1 counted as "declining" to inherit (eBay aspects, Shopee,
Tokopedia B) attach a schema only to leaves and **cannot** express inheritance; eBay, on the fact it *does*
attach to every node, inherits it explicitly.

**This moves the precedent in favour of (b), and it weakens one of the fork's supports.** The only
platform that is both merchant-authored *and* schema-on-the-category-tree — our exact situation — inherits.
The one that does not, Shopify, authors 14,606 nodes centrally with a dedicated team, which is precisely the
condition we do not have. Confidence on (b) for definitions therefore moves **medium → medium-high**; the
fork's "one precedent of thirteen" argument for adoption is correspondingly weaker.

**What would reopen it:** if the effective-set computation measures badly on the staff product list or the
reindex (the eBay caution), (b) becomes "materialise into a join table maintained by a signal", which is (a)
with a generator — a different build, same semantics. If the fork goes to adoption, (b) becomes unnecessary
and D15 collapses to (a).

**What it forces in steps 1–5:** the schema editor (lock condition 1) must show inherited vs own from day
one. The category move needs a pre-flight and a subtree reindex, neither of which exists (#10919's shape,
`catalogue/receivers.py:18-20`). Step 1's D17 (requiredness) is pre-empted: requiredness is per (node,
attribute), because that is what an override row is. And the age-wall fix should be done now, independently
— it is already on the v7 page's decision-free list.

### 8 · Limits and corrections

- **Correction, measured here:** the record says *"**4,668 of 14,580** pairs"* have at least one parent
  attribute absent from the child (#11188 comment; #11031 2026-09-15 §B). Measuring the corpus on disk at
  commit `ad206247` gives **4,569 of 14,580**. The denominator reproduces exactly (14,606 − 26 roots); the
  numerator does not. Recorded, not resolved — both were taken on a "2026-08"-labelled artifact, and ours
  carries the internal build string `2026-11-unstable`. Instrument: `scripts/shopify_corpus.py`.
- **Confirmed, measured here:** `inherit` occurs **0** times in `en/taxonomy.json` (95,139,186 B), 0 in
  `categories.json`, 0 in `attributes.json`.
- **Salesforce, the only (b) precedent, is flagged single-route by the record itself**, and its corpus is not
  on this machine. I could not re-open it. Route: Salesforce B2C Commerce's own catalog/attribute-group
  documentation.
- **Akeneo's Family-tree inheritance is `help.akeneo.com` only and absent from the open-source edition** —
  the record says so. Treat "Akeneo inherits" as a paid-SaaS fact.
- **`developer.ebay.com` refused again for this brief** (2026-09-19, two URLs, HTTP 403, 1,832 B each), so
  the eBay inheritance quotes remain archive captures. The *leaf-only* rule was independently re-collected
  live on two other eBay hosts (§B2/3); the *inheritance* quotes were not.
- **Measured after first draft:** the age-wall ancestry gap costs **0 products today** (§5). My §4 wording
  *"a new child under 17 is silently unwalled"* is prospective, not a description of current damage. Stated
  here rather than softened in §4, because the mechanism is still wrong.

#### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **BLOCKING 2** | ~~"Only Shopify, eBay, Shopee, Tokopedia and Salesforce have a category tree that owns attributes, and of those five, one inherits. That is the honest denominator: **1 of 5, not 1 of 13**."~~ **Struck — asserted, not derived, and contradicted by this brief's own eBay row.** §2 now **derives** it: inheritance is only *expressible* where an **internal** category node owns a per-node schema, which is true of **Shopify** (measured on the corpus: 2,606 of 2,664 internal nodes, 97.8%, carry ≥1 attribute; 14,254 of 14,580 pairs have something inheritable) and **Salesforce**, and of nobody else — eBay's aspects, Shopee's and Tokopedia B's schemas are leaf-only, so they **cannot** express inheritance and have not declined it. Four denominators are published side by side (1 of 13 · 1 of 5 *and why it is wrong* · **1 of 2** like-for-like · 2 of 3 admitting Akeneo's Family tree), and the recommendation states it uses **1 of 2**. eBay is reconciled: it inherits the per-node fact it attaches to every node (category **features**, with override and a published wire format) and does not inherit the leaf-only one (aspects) — which is direct evidence **for** B4 = per-kind. **Confidence on (b) for definitions moves medium → medium-high**, and the fork's "one precedent of thirteen" support is correspondingly weaker. |
| **SERIOUS 4** | The 14-row table was footnoted wholesale to #11031's 2026-09-15 comment §B, which has **13 rows** (`evidence/issues/11031.md:1338-1352`) and **no Tokopedia Era A row**. The footnote now says "all rows except Tokopedia Era A" and cites that row to #11048 §1.5/§2 `[R-18, R-21, R-23]`. Substance unchanged; the attribution was false. |
| **MINOR 21** | ~~"5,580 distinct raw values, **of which** 15,475 are junk"~~ **Struck — arithmetically impossible.** 15,475 is a **row** count. Restated: 46,499 rows, of which 15,475 carry a junk value and 12,512 the literal `'0'`; separately 5,580 distinct raw values (5,541 trim+lower). |
| **MINOR 25** | `design-B4.md` §0 was headed "the **four** kinds of fact" over a six-row table, and this brief's lede said "four ways for four kinds". Both restated as **six kinds, four mechanisms**. |
| **MINOR 26** | ~~"a folder's children are exactly the nodes that do accept products"~~ **Struck — false on an 8-deep tree with 339 internal nodes.** Restated in terms of *descendants*; the conclusion (`accepts_products` must not inherit) is unchanged. |
| **MINOR 30** | The Amazon requiredness cite was an empty section marker `(#10976 §)`; it is `evidence/issues/10976.md:158`. |
| **SERIOUS 14 (carried)** | #10778 was not mentioned anywhere in revision 1. A **"#10778 disposition"** section now precedes the Appendix: **V1 confirmed** (and the fork's vocabulary proposal framed as seeding it, not as a new decision), **C5 confirmed for names / re-expressed for value lists** (B4 §7's "a child may narrow" makes the admissible *value set* a property of the (node, attribute) pair — A4 owns it), **V4 not relied on**, and the #11031 audit's warning honoured (no #10778 figure is quoted anywhere in this brief). |


#### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 4** | The §7 judgement line still read *"**medium** that definitions should be (b)"* while the same section's closing paragraph and the revision header both recorded the move to **medium-high**. The judgement line — the line that exists to be read alone — now says **medium-high**, with the reason. |
| **Snapshot bound** | `sql/*.sql` bounded per BRIEF §3.4; re-run **byte-identical**; the manufacturer and age-wall figures in §5 are unchanged. |


---

## The Step-1 fork · keep authoring our own tree, or adopt the Shopify Standard Product Taxonomy?

*Restructured after red-team round 1 (SERIOUS 13) into the same eight-section shape as B1–B4: revision 1 had
no platform matrix, no "Why" and no "Our code today".*

Every number was re-measured against the corpus on disk. Full verification table, one row per claim:
**`fork-shopify-taxonomy.md`**. Mapping method, both passes and the over-mapping rate:
**`node-attribute-need.md` §2.1 and §3**.

**Corpus and commit:** `corpus/shopify-taxonomy`, sparse clone of `Shopify/product-taxonomy` at
**`ad206247ecc45a95fe4b01bce2ad2f0e7bec3c66`** (2026-08-27, *"Merge pull request #999 from
Shopify/bump-gem-to-1.2.0"*), paths `dist/en` (232 MB) and `dist/id-ID` (203 MB). The build string inside
both `categories.json` files is **`2026-11-unstable`**, not `2026-08`.

### 1 · Options

- **(a) Keep authoring our own tree.** 1,892 nodes stay ours; L1's schema is authored by us; D15 must make
  that affordable.
- **(b) Adopt the Shopify Standard Product Taxonomy** as the tree — 14,606 nodes, 8,240 attribute
  definitions, id-ID published.
- **(c)** *(not on the card, surfaced by the matrix in §2 and carried because the evidence points at it)*
  **keep our tree and hold a mapping to a standard** — the way every platform that touches a second taxonomy
  actually does it, **n = 2** (Shopify's published mapping sets; Tokopedia Era B's dual tree). The other
  twelve rows are silent on the question, and five of them are "not collected" rather than "no"
  *(qualified after red-team round 2, MINOR 18)*.

### 2 · Who uses which, who does not

**Thirteen platforms over fourteen rows** (Tokopedia split into its two eras, as BRIEF §3.1 requires).
**Unanimous, and it is the strongest single signal in this brief: none of the thirteen adopts another
organisation's taxonomy as its own.** Seven author their own classification and publish it; six hand the
tree to the merchant. Where two taxonomies have to meet, every observed mechanism is a **mapping** or a
**dual tree**, never a replacement.

| Platform | Who authors the classification | Does it adopt an external standard? | Does it publish/consume a mapping to another taxonomy? | Cite |
|---|---|---|---|---|
| **Amazon** | Amazon. *"❗ Not creatable"* — 12 patterns over 877 doc files / 16,441,164 B → **0 hits each**; additions announced via `PRODUCT_TYPE_DEFINITIONS_CHANGE.NewProductTypes` | **no** | not collected | #10976 §1.1 |
| **Shopify** | Shopify, centrally; published open-source | **no** — it *is* the standard | **yes, and it is the point**: the same release ships **14,528** Shopify→Google mapping rules, plus four version-migration sets (**5,595** from `2022-02`, 108 from `2025-12`, 50 from `2024-10`, 1 from `2025-09`) | corpus `dist/en/integrations/all_mappings.json`, measured here |
| **Google** | Google, and it **assigns automatically**: *"All products are automatically assigned a product category from Google's continuously evolving product taxonomy"* | **no** | it is the *target* of Shopify's mapping | #11013 §1.7 |
| **eBay** | eBay | **no** | not collected | #11045 §1.2 |
| **Walmart** | Walmart — 6,967 product types in one flat map | **no** | not collected | #11046; #11031 2026-09-15 §B |
| **Shopee** | Shopee — *"Shopee's category tree data applies to all markets"*, with per-market prohibitions | **no** | not collected | #11047 §1.1 |
| **Tokopedia Era A** | Tokopedia — a 3-level tree | **no** | n/a | #11048 §1.5 |
| **Tokopedia Era B** | TikTok Shop — **and it runs two trees at once**, selected by `listing_platform: TIKTOK_SHOP \| TOKOPEDIA`, with the vendor's own instruction *"To list a product on both TikTok Shop and Tokopedia, you must use only categories that are available on both platforms. Please call this API twice to identify the overlapping categories."* | **no** | **yes — a dual tree with a seller-computed overlap**, the closest thing in the thirteen to living with someone else's tree, and it is explicitly *not* a replacement | #11048 §1.9 `[R-4]` |
| **Square** | the merchant | n/a | no | #11049 §1.6 |
| **Salesforce B2C** | the merchant | n/a | no | #11050 §1.5 |
| **Akeneo** | the merchant — *"an **unlimited number of levels**"*, *"you can have multiple category trees"* | n/a | no | #11069 §1.x `[R-74]` |
| **WooCommerce** | the merchant (`product_cat` terms) | n/a | no | #11080 §1.7 |
| **commercetools** | the merchant | n/a | no | #11081 §1.10 |
| **Magento** | the merchant | n/a | no | #11082 §1.4 |

**Tally.** Authors its own and publishes it: **7** (Amazon, Shopify, Google, eBay, Walmart, Shopee,
Tokopedia). Hands the tree to the merchant: **6** (Square, Salesforce, Akeneo, WooCommerce, commercetools,
Magento). **Adopts another organisation's taxonomy as its own tree: 0 of 13.** Publishes or requires a
mapping between two taxonomies: **2** (Shopify → Google and its own versions; Tokopedia Era B's dual tree) —
and that is **n = 2 out of 14 rows, with 5 rows "not collected"** (Amazon, eBay, Walmart, Shopee, and n/a
for Tokopedia Era A), so option (c)'s precedent rests on two cells *(red-team round 2, MINOR 18)*.
**Named ambiguous:** none on this axis — but note that **the six merchant-tool platforms are silent, not
opposed**: they neither adopt nor refuse, because the choice is their customer's. *We are their customer.*
So the 0-of-13 is evidence about what **platforms** do, and only the Tokopedia Era B row is evidence about
what a **seller facing two trees** does.

### 3 · Why

- **Shopify — stated, and it bears directly on adoption.** The repository README (fetched 2026-09-19 at
  `main` and at the pinned commit, byte-identical, md5 `5d197d41f6fc02b731ca95cfa93c9730`,
  `corpus/why-2026-09/shopify-readme-*.md`): *"**🌍 Global Standard**: Our open-source, standardized product
  taxonomy establishes a universal language for product classification"*, *"**👩🏼‍💻 Integration Friendly**:
  With a stable structure and diverse formats our taxonomy is designed for effortless integration into any
  system."* The README's own "Getting started" splits its audience three ways — *"**Integrators**: Those who
  integrate the taxonomy into other systems. You want **stable distribution files**"* versus
  *"**Taxonomists**: Those who want to evolve the taxonomy itself"*. **Shopify's stated model for an outside
  party is integration against distribution files, not local extension**, and its *"🗺️ Mapping to other
  taxonomies"* section describes *"rules that can be used to convert between categories and attributes in
  the Shopify taxonomy to categories and attributes of another taxonomy"*. That is the vendor describing
  option (c).
- **Amazon — stated (facts) + inference (reason).** **Stated:** product types are not creatable (#10976
  §1.1, the 12-pattern instrument). **Inference:** a closed registry is how Amazon keeps 107 food types at
  107; a seller-extensible one would not stay small.
- **Google — stated.** *"All products are automatically assigned a product category…"* (#11013 §1.7): the
  platform does the classification, so there is nothing for a merchant to adopt.
- **Tokopedia Era B — stated, and it is the seller-side rationale we actually need.** The vendor does not
  ask sellers to migrate to one tree; it tells them to hold both and compute the overlap (#11048 §1.9).
- **The merchant-tool six — inference.** None states a position because none owns the tree.
- **Not collected:** any statement by Shopify about whether a third party may extend the taxonomy locally
  and remain compatible. The repo's `docs/` and taxonomist contribution guide are **outside our two sparse
  paths**; one `git sparse-checkout add docs` on the existing clone would settle it. **This is why §7's
  "we cannot extend it" claim is withdrawn** (SERIOUS 7).

### 4 · Our code today

Adoption is not a data migration; it is a re-keying. **Six things are keyed on our own `Category`**, and one
of them on `full_code` rather than `id` *(the sixth was missed in revision 1 — SERIOUS 9)*:

| # | Keyed on | path:line |
|---|---|---|
| 1 | `main_category_id`, exact-id membership — age-walling | `catalogue/models.py:570-573` + `apps/solvent/config/settings/base.py:928-937` |
| 2 | `Category.get_descendants_and_self()` id list — replenishment | `inventory/replenishment/inventory_replenishment_service.py:31-36` |
| 3 | `full_code`, composed from the parent's and cascaded on change | `catalogue/utils.py:1-2`; `api/apicategory/staff_serializers.py:131-146`; `unique=True` at `catalogue/models.py:136-141` |
| 4 | `is_public` + `ancestors_are_public`, materialised over the subtree, read by `CategoryQuerySet.browsable()` | `catalogue/models.py:149-157`, `:271-285`; `catalogue/managers.py:28-31` |
| 5 | the product document's `category` MultiValueField = main category **plus every ancestor id** | `catalogue/search_indexes_mixins.py:22, 27-29`; `solvent/search/search_indexes.py:64-65` |
| 6 | **the category's own Elasticsearch document**, `guid = KeywordField(model_attr="full_code")` | `py/mono/solvent/catalogue/search_indexes.py:8-22` |

Plus every `main_category` FK row (106,161), the one write path
(`api/apiproduct/staff_serializers.py:55`), both product **read** serializers
(`api/apiproduct/serializers.py:127, 137, 201, 208`), and nine frontend `type: 'category-id'` registrations.

**Under (a)** none of this changes. **Under (b)** either our `Category` survives as a shell carrying a
foreign id — in which case we still author and maintain a tree, and have added a mapping to it — or all six
are re-keyed and every category document is rewritten.

**Under (c)** the *schema* cost is one new nullable column (`shopify_taxonomy_id`) and a feed-time lookup —
but **(c) pays the our→Shopify mapping bill in full**, the same bill decisive fact 4 charges against (b):
**74.3% of our used nodes do not map mechanically**, about a quarter to a third of the automated ones point
at the wrong kind, and the largest single component (302 nodes, 40.1% of products) is a decision to turn
gender and age from tree levels into attributes rather than a rename. **(c) is cheaper than (b) only in what
it does not do** — it does not re-home 106,161 products, does not re-key the six things above, and does not
surrender the ability to add `Batik`. *(Priced after red-team round 2, SERIOUS 7: revision 2 introduced (c)
and charged it only the column.)*

### 5 · Our numbers

**The card's claims, verified** (full table with instruments: `fork-shopify-taxonomy.md` §1):

| Card | Measured | |
|---|---|---|
| 14,606 categories | **14,606** in both locales, 26 verticals, max level 7 (0-based → eight levels) | ✅ |
| 8,240 attribute definitions | **8,240** in both locales | ✅ |
| closed value lists | **0** definitions with an empty `values[]`; 74,820 values; median **7**, max 451 | ✅ |
| only 1.0% of nodes have none | **152 / 14,606 = 1.04%** | ✅ |
| median 6 | **6** (mean 6.37, max 28); **93,007** category→attribute edges | ✅ |
| materialised per node, no inheritance | `inherit` → **0** in `taxonomy.json` (95,139,186 B), `categories.json`, `attributes.json`. **4,569 of 14,580** parent→child pairs drop ≥1 parent attribute. **97.8% of internal nodes carry a schema and 97.8% of pairs have something inheritable** — so Shopify *could* inherit and does not | ✅ mechanism; ⚠️ **count**: the record says 4,668 (B4 §8) |
| id-ID published locale | verified whole on the card's own example: `Makanan, Minuman & Tembakau > Item Makanan > Produk Susu > Yoghurt` carries `Informasi alergen` (16) · `Varian beta-kasein` (4) · `Preferensi diet` (28) · `Kandungan lemak` (8) · **`Rasa` (30)** · `Persyaratan penyimpanan` (6) · `Bahan dasar yogurt` (15) | ✅ |
| no net-content or size attribute | **no net-content attribute exists** — only **15** of 8,240 definitions have *any* value matching `^\d+(\.\d+)?\s?(g\|kg\|ml\|l\|oz\|lb\|mg\|cl)`, none a net content. ⚠️ but a base `Size` definition **does** exist (`TaxonomyAttribute/2778`, 80 garment values, 464 categories) | ✅ on substance; ⚠️ card overstates |
| 300 of 8,240 match size/volume/weight | **262** base names match `size\|volume\|weight`; 272 with the 314 renames; 254 distinct edge names | ⚠️ **300 not reproduced** |
| 18 duplicate id-ID `full_name` paths | **18** (36 rows) in `id-ID`, **0** in `en`; 298 vs 205 duplicate leaf names | ✅ |
| MIT | LICENSE is outside our two sparse paths | **not re-verified from the corpus** |

**Three things the card does not carry.**

**(i) The artifact we measured is deprecated.** README, verbatim: *"The committed [`dist/`](./dist/)
directory is deprecated and will be removed on **October 31, 2026**. Migrate to the release-asset URLs above
before then."* Six weeks. Successor: gzip release assets, `stable` and `unstable` channels.

**(ii) It is a translated global taxonomy, not an Indonesian one.** Word-boundary leaf-name probe over both
14,606-node builds. **Absent, 0 hits in either locale:** `Batik` · `Mukena` · `Sajadah` / prayer rug / prayer
mat · `Kebaya` · `Kopiah` · `Peci` · `Sarong` · `Sambal` · `Terasi` / shrimp paste · `Mi Instan` / instant
noodle · `Kapur barus` / mothball. **Present:** `Abaya dan Jilbab`, `Baju Melayu`, `Kaftan` (a 17-node
`Pakaian Tradisional & Seremonial` branch), `Sampo`, `Lipstik`, `Keripik`, `Kerupuk Beras`, `Kecap`,
`Santan & Minuman Kelapa`, `Penanak Nasi` *(the last two corrected after red-team round 1, MINOR 23 —
revision 1 listed the en spellings `Santan` and `Rice Cooker` in an id-ID list)*. Meanwhile `Snack Foods`
carries 44 nodes including `Pork Rinds` (id `Kerupuk Kulit Babi`).

**`Pasta & Noodles` (id `Pasta & Mi`) is a single node, five attributes, no children.** Our
`MIE, BIHUN, KWETIAU INSTAN` branch (node 99) is **7 nodes / 439 products** in subtree; the mie-only
sub-branch the absence bites — node 99 (16) + `MIE INSTAN BUNGKUS` (318) + `MIE INSTAN DALAM KEMASAN CUP`
(60) — is **3 nodes / 394 products**, including node **612**, where the 43 Indomie rows live *(corrected
after red-team round 1, MINOR 19 — revision 1 said "three nodes and 394 products" of the whole branch)*.
**Adoption puts Indomie in the same node as spaghetti and gives it no attribute for 85 g.**

**(iii) Two of the taxonomy's own artifacts disagree about `level`** (#11011 contradiction 8): the release
asset gives `fb-1` → `"level": 1`; the live API gives `fb-1` → level 2.

**Mapping feasibility — rebuilt after red-team round 1 (BLOCKING 3, SERIOUS 5, SERIOUS 16).** The
gender/age qualifier is now stripped from **our side only** and must be recoverable as
`Jenis kelamin sasaran` / `Kelompok usia` on the target; the thirteen root→vertical bindings are a
**preference with a global fallback**, not a filter; the 90% cut is deterministic.

**Rebuilt again after red-team round 2 (SERIOUS 9):** the resolver was silently tie-breaking — 30 of 351
exact-tier rows had more than one identically-normalised candidate and were recorded `EXACT` — and now
returns `AMBIGUOUS` whenever more than one candidate shares the winning name.

| | nodes mapped | products covered | miss |
|---|---|---|---|
| Pass A — literal name identity | 362 of 1,686 (21.5%) | 23,748 (22.4%) | **1,324 nodes (78.5%)** |
| Pass B — + root→vertical preference + the recoverable qualifier collapse | **434 (25.7%)** | **34,671 (32.7%)** | **1,252 nodes (74.3%)**, 71,490 products (67.3%) |

Of the 639 nodes covering 90% of products, pass B maps **200** (161 EXACT + 39 FUZZY), 28 ambiguous, 411
unmapped. Per-node results with tier, scope, target level, leafness and `n_candidates`:
`data/shopify-mapping.csv`.

**And it over-maps.** Hand adjudication of 37 mapped rows (`data/mapping-adjudication.csv`): **6 of a random
21 point at the wrong kind of product — 28.6%, Wilson 95% CI 14–50%** — plus 5 landing on a genuine
ancestor; the top-by-products stratum is better, 2 of 16 (12.5%), and product-weighted over the products the
sample covers the error is 21.5% wrong / 16.7% ancestor. `KAUS PRIA` → men's **undershirts**; `KAUS WANITA`
→ women's **undershirts**; `PERAWATAN MOBIL` → a **service** node; `KIPAS ANGIN` → fan **remote controls**;
`MAKANAN BEKU` → frozen **fish food**; our root `Alat dan Buku Tulis` → a paper-products leaf. **Six of
round 1's seven named wrong matches are single-candidate and survive the round-2 rule: detecting ambiguity
is not detecting wrongness.** So **25.7% is the automation rate, not an accuracy rate: the share of nodes a
machine both places and places correctly is nearer one in five.**

**The miss is an automation miss, not an absence of homes** — three causes, from a 50-node probe
(`data/unmapped-probe.txt`): loanword spelling (`SHAMPOO`/`Sampo`, `LIPSTICK`/`Lipstik`, `BLOUSE`/`Blus`,
`COOKIES & BISKUIT`/`Biskuit`); **a qualifier we make a node and the taxonomy makes an attribute — 302 of
our 1,686 used nodes (17.9%) holding 42,621 products (40.1%), 168 collapsing onto a shared name, of which
106 now map through the recoverable-stripped tiers**; and the genuine holes in (ii).

### 6 · Cleanest / structurally correct for us

| | (a) Keep authoring | (b) Adopt | (c) Keep + map |
|---|---|---|---|
| Tree | 1,892 nodes stay; 609 sub-10-product nodes and 206 unused nodes are ours to prune | re-home 1,686 used nodes; ~74% need hand mapping and ~a quarter to a third of the automated ones are wrong; the Indonesian residue has no home | unchanged |
| Schema authoring | a **range**: 68 sets measured floor · 316 inferred over the mapped share (220 conservative) · 1,686 under D15=(a). Bounded by sets only if B4 = (b) | zero — 93,007 edges arrive materialised | unchanged; the taxonomy becomes a *source* for the attribute catalogue |
| Population | 8 attribute kinds our titles already carry | **776 distinct names** over 434 mapped nodes (**558** conservative); **477** over the 200 inside the 639 (**330** conservative). Nothing in our data fills most of them | whatever we choose to seed |
| Net content / size | ours to design (A4) | **not solved** — still needs an attribute outside the taxonomy | ours to design |
| Governance | we own every change; no external clock | Shopify's cadence; `dist/` retired 2026-10-31; two artifacts disagree on `level`; 18 duplicate id-ID paths | we own the tree, **and we own the mapping** — ours is the one nobody publishes. Shopify's 14,528 Shopify→Google and 5,754 Shopify→Shopify rules **take a Shopify category as input**, so they cover the hop *after* ours and relieve none of it; what they do show is that **re-mapping on every release is a standing cost the vendor itself pays** (5,595 rules to migrate from `2022-02` alone) *(red-team round 2, SERIOUS 8)* |
| **Mapping** *(row added after red-team round 2, SERIOUS 7)* | **none** | the full our→Shopify mapping: 1,252 nodes unmapped mechanically, ~a quarter to a third of the 434 automated ones wrong, 302 gender/age nodes needing a restructuring decision | **the same mapping, in full.** (c) buys its way out of re-homing and re-keying, not out of mapping |
| Our code (§4) | untouched | six keyed things re-keyed, one on `full_code`; every category document rewritten | one nullable column + whatever maintains the mapping |

### 7 · Recommendation

**Judgement: keep authoring our own tree (a). Take the taxonomy as a *source* for the attribute vocabulary
now, and hold (c) — a mapping column — as a named migration path, not as work to start.** Confidence
**medium-high** for (a); **medium** for the vocabulary seeding; and **(c) is explicitly deferred**, because
pricing it properly (§4, `design-fork.md`) shows it pays the *same* our→Shopify mapping bill this section
charges against (b) and today **nothing consumes the id** — the Google feed builder never touches category
(`google_product_category|product_type|googleProductCategory` → 0 hits across
`solvent/third_party_api/google/`). *(Restated after red-team round 2, SERIOUS 7: revision 2 recommended
"(a) plus (c)" while charging (c) only one nullable column.)*

The decisive facts, in order:

1. **No platform in the thirteen adopts another organisation's taxonomy as its own tree (§2), and the two
   that touch a second taxonomy both do it with a mapping or a dual tree** — Shopify ships 14,528
   Shopify→Google rules plus 5,754 version-migration rules; Tokopedia Era B tells sellers to hold both trees
   and compute the overlap. The industry answer to "someone else's tree" is a mapping table.
2. **The taxonomy has no node for instant noodles and no attribute for net content** — the two things our
   own motivating example needs. Adoption pays a re-homing bill and leaves both open.
3. **It has no node for `Batik`, `Mukena`, `Sajadah`, `Kebaya`, `Peci`, `Sarong`, `Sambal`, `Terasi` or
   `Kapur barus`** — roughly 2,800 products by node name. **Adding them locally forks the published set**:
   a local node is not in the standard, so upstream updates and the interoperability the standard buys are
   lost for that branch. *(Restated after red-team round 1, SERIOUS 7. Revision 1 said "a standard taxonomy
   is one we cannot extend" as a flat fact while §7 simultaneously recorded that the contribution guide was
   **not collected**. Nothing prevents extending an MIT-licensed local copy; what is lost is upstream
   alignment. The stronger claim is withdrawn.)*
4. **The mapping does not exist and is the work.** 28.8% maps mechanically, about a quarter of that is
   wrong, and the largest single component of the remainder (302 nodes, 40.1% of products) is not a rename
   but a decision to turn gender and age from tree levels into attributes.
5. **Six pieces of live business logic are keyed on our `Category`** (§4), one of them on `full_code`.

**What we should take from it anyway (judgement, and cheap):** the attribute *vocabulary* — closed,
translated id-ID value lists, MIT-licensed, copyable per node without adopting the tree. See the #10778
disposition below: this is **V1/C5 territory** and is proposed as *seeding* an existing decision, not as a
new one.

**What would reopen it:** if the 302 gender/age nodes are collapsed into attributes anyway (a decision B3
and A3 may force), the largest mapping obstacle disappears — re-run `scripts/shopify_map2.py` after that
decision, not before. Or if a channel obligation requires a standard taxonomy id per product, in which case the answer is (c) —
**but note what the taxonomy does and does not ship**: `dist/en/integrations/google/shopify_2026-08_to_google_2021-09-21.json`
holds 14,528 rules whose *input is a Shopify category*, so it maps Shopify→Google, not ours→anything. The
hop it covers is the one after ours. **The our→Shopify hop is unpublished and is the work in every option
except (a)** *(red-team round 2, SERIOUS 8)*.

**What it forces in steps 1–5:**
- **(a), the recommendation** — D15 = (b) is load-bearing and must be decided first (step 1), and the schema
  editor must show inherited vs own.
- **(b)** — step 1 shrinks to a mapping project and D15 collapses to (a), but D16, D17 and the whole value
  model then inherit Shopify's answers, which is ATTR-VALUE's call to price.
- **(c)**, if a channel ever forces it — step 1 must name an owner for the mapping and pin a release
  channel (`dist/` is retired **2026-10-31**; the successor is `stable` / `unstable` release assets), and
  must accept "unmapped" as a normal state, because **1,252 of 1,686 used nodes are unmapped on day one**.
  Step 5 gains a second opaque external id that must never be re-derived. **(c) relieves nothing in D15 or
  D16** — we still author our own schema. Sketch: `design-fork.md`.
- **The attribute-vocabulary proposal is independent of all three** and can be done under any of them: it
  copies MIT-licensed value lists into our own catalogue (#10778 V1) and needs no node correspondence.

### 8 · Limits and corrections

- `300 of 8,240` **not reproduced**: measured 262 by the stated pattern.
- `4,668 of 14,580` **not reproduced**: measured 4,569 at commit `ad206247`.
- **MIT not re-verified** from the corpus — LICENSE is outside our two sparse paths.
- **"No size attribute" overstated**: a closed garment-size list exists on 464 categories. "No
  **net-content** attribute" is exact and is the load-bearing half.
- **The absence probes are word-boundary leaf-name probes** over `categories.json` in both locales. A node
  could exist under a name none of my synonyms guessed; the residual risk is that the taxonomy names
  `Batik` something else entirely.
- **Not collected:** the taxonomy repo's `docs/` and contribution guide, which is where a statement about
  extending the taxonomy locally would live. One `git sparse-checkout add docs` on the existing clone.
- **§2's 0-of-13 is evidence about platforms, not about sellers.** The six merchant-tool vendors are silent
  on adoption because it is their customer's choice — and we are the customer. Only the Tokopedia Era B row
  speaks to the seller's side.

#### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **SERIOUS 13** | The fork had 7 headings, no platform matrix, no "Why" and no "Our code today". It is now in the **full eight-section shape**, with a 13-row who-uses matrix (§2) whose finding — **0 of 13 adopt, 2 publish or require a mapping** — is new and is now decisive fact 1. |
| **SERIOUS 7** | *"a standard taxonomy is one we cannot extend"* — **struck**. Replaced with what the evidence supports: adding nodes locally **forks the published set**, losing upstream updates and interoperability for that branch. The contribution guide was not collected and is named as the route (§3, §8). |
| **SERIOUS 9** | "all five pieces of business logic are keyed on our `Category.id`" → **six**, the sixth being `CategoryIndex` (`catalogue/search_indexes.py:8-22`), keyed on **`full_code`**, not `id`. §4 is new and lists all six. |
| **BLOCKING 3 / SERIOUS 5 / SERIOUS 16** | Mapping rebuilt: pass A 380→**420**, pass B 395→**485** mapped (23.4%→**28.8%**), products 31.0%→**38.2%**, miss 76.6%→**71.2%**; 90% cut deterministic (**223 / 491**, both scripts agree, and `data/shopify-attrs-for-our-90pct.json` now holds exactly 491). **Over-mapping rate published for the first time** (~25% of a random 20 mapped rows wrong). Ceilings restated as 810 (all mapped) / 574 (conservative). |
| **MINOR 19** | `MIE, BIHUN, KWETIAU INSTAN` is 7 nodes / 439 products in subtree; 394 is the mie-only sub-branch. |
| **MINOR 23** | `Santan` / `Rice Cooker` were en spellings inside an id-ID "present" list → `Santan & Minuman Kelapa` / `Penanak Nasi`. The absence probes, the load-bearing half, all verify. |
| **MINOR 27** | `fork-shopify-taxonomy.md` §4/§5 still said "one precedent of thirteen" for B4; both now carry the derived **1 of 2**. |
| **MINOR 28** | Shopify's `level` is labelled 0-based wherever the depth comparison is made. |

#### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 7** | Option (c) was introduced in revision 2 and **priced at one nullable column**. It is now charged the **full our→Shopify mapping bill** — the same bill decisive fact 4 uses against (b) — in §4, in a new **Mapping** row in §6's table, and in §7. It gains a **step-1 consequence** (owner, release channel, "unmapped" as a normal state for 1,252 of 1,686 nodes) and a **design sketch**, `design-fork.md`. The recommendation is restated: **(a) now, (c) deferred as a named migration path**, because nothing consumes a Shopify id today — the Google feed builder never touches category. |
| **SERIOUS 8** | ~~"the mapping is refreshed on their cadence, which is what their 14,528 + 5,754 published mapping rules exist for"~~ and ~~"the taxonomy already ships the mapping"~~ **Struck.** Every one of those rules takes a **Shopify** category as input: they map Shopify→Google and Shopify→Shopify, i.e. the hop *after* ours. They relieve none of our bill. What they do evidence is that re-mapping on every release is a standing cost the vendor itself pays (5,595 rules for `2022-02` alone). |
| **SERIOUS 9 (carried)** | §5's mapping table rebuilt: pass A **420 → 362**, pass B **485 → 434** (28.8% → **25.7%**), miss **71.2% → 74.3%**, the 639 cut **223 → 200**; over-mapping **25% → 28.6%** with the other two strata and a product-weighted rate. |
| **SERIOUS 11** | `fork-shopify-taxonomy.md` §2.2's Present/Absent lists are synced to this section (`Santan & Minuman Kelapa`, `Penanak Nasi`, `Peci`, unqualified `Sarong`). |
| **MINOR 18** | §1 and §2 now state **n = 2** where option (c)'s precedent is claimed, and name the five "not collected" cells. |
| **MINOR 19 / 20** | The Appendix row said the matrix was *"added in round 1"* (it was added in the round-1 **fix** pass, revision 2) and called it a *"13-row matrix"* (thirteen platforms, **fourteen rows**). Both corrected. |
| **Snapshot bound** | `sql/*.sql` bounded per BRIEF §3.4; re-run **byte-identical**; no fork figure changed as a result. |


## Closed, recorded not reopened · One category per product

**Closed by Irvan, 2026-09-18.** *"A product has exactly one category, as Amazon has exactly one product
type."* First half of D14.

**Recorded here as already true in code, both stacks:**

- `Product.main_category` is a scalar FK, `PROTECT`, non-null —
  `py/mono/solvent/catalogue/models.py:427-431`.
- The M2M does **not exist**. `grep -n "ManyToManyField"` over `catalogue/models.py` returns exactly two
  hits — `attributes` (`:419`) and `ProductRange.products` (`:890`). `ProductCategory`
  (`catalogue/models.py:333-348`, `unique_together ("product","category")`) is a free-standing join table
  with **no production reader or writer**: its only references are Django admin
  (`catalogue/admin.py:12, 22-24, 46, 71`) and a test factory. Live data: **20,520 M2M rows, 20,519 distinct
  products, exactly 1 product with more than one** (`sql/results/baseline.json`, 2026-09-19).
- Frontend: `main_category` is a scalar on all three product models
  (`ts/libs/product/shared/util-core/src/lib/product.model.ts:52, 76, 90`), a single required picker on the
  form (`product-update-staff-form-ui.component.ts:118-122`), and a single-value filter everywhere
  (`product-filter.model.ts:5` `category?: number`). Nothing models a product↔category many-to-many.

**One consequence this brief surfaces, for step 5's D14 second half.** The decision assumes merchandising
nodes are a future problem ("Promo Ramadan"). They are a present one: **3,402 current product rows (3.2%),
of which 3,209 are `is_active`, sit under a root that is not a kind of product** *("live" replaced with the
two exact counts after red-team round 1, MINOR 22)* — `UNUSED` (1,923 in subtree, containing `AREA DISPLAY` and the brand
shop-in-shop areas `ARTEMEDIA` 830, `CARDINAL OBRAL` 353, `CARDINAL NORMAL` 166, `OLYMPIC` 264, `FOOD COURT`
81), `BELUM DISORTIR` (1,401, child `BARANG OBRAL` 1,382) and `INVENTORY KANTOR` (78). Under Lock 1 each
becomes a product type with an attribute schema it cannot meaningfully have. **This is not a reopening of
the closed decision** — one category per product still holds — but it means D14's second half and the dead
`ProductCategory` table have live data attached and should not wait for step 5 behind a hypothetical.

---

## #10778 disposition — confirm · re-express · supersede

*Added after red-team round 1 (SERIOUS 14): `grep -ri "10778"` over this brief returned **zero** hits in
revision 1, although two recommendations sit on #10778's territory. BRIEF §1 requires each standing decision
this brief leans on to be confirmed, re-expressed or proposed superseded, never silently contradicted — and
also warns that "#10778's evidence pass was found unsound in parts (two claims retracted, fabrication-class
citations). Re-verify any #10778 claim you lean on."*

| #10778 item | What it says | TREE's disposition |
|---|---|---|
| **V1** — axis *names* come from a shared staff-extendable catalogue (closed names, open values) | a global name catalogue exists and staff may extend it | **CONFIRM, and propose seeding it.** The fork §7 proposal — take the taxonomy's attribute *vocabulary* without its tree — is exactly V1's catalogue, populated from an MIT-licensed corpus instead of from scratch. **This is a proposal about V1's initial contents, not a change to V1.** Numbers: 8,240 definitions, 0 with an empty value list, median 7 values, id-ID published. The catalogue stays staff-extendable, which is what makes the Indonesian gaps (`Batik`, `Sambal`, `Kapur barus`) survivable. |
| **C5** — one global name catalogue, **not scoped per category** | names are global; categories subscribe | **CONFIRM for names. RE-EXPRESS for value lists.** B4 §7 proposes that a child node may **narrow** an inherited attribute's allowed values. That does not scope the *name* per category — the name stays global, which is C5 — but it does make the *admissible value set* a property of the (node, attribute) pair. If A4 decides values are shared rows, narrowing is a subset relation on those rows and C5 is untouched; if A4 decides otherwise, this needs C5 re-read. **A4 owns it; TREE only states that narrowing is expressible as an override row and widening is not.** |
| **V4** — an axis value is a single text label, hand-ordered by a position column | — | **NOT RELIED ON.** No recommendation in this brief depends on the value shape. Flagged only because the fork's "closed value lists, median 7" facts are input to A4, where the BRIEF's own erratum (the D9-vs-V4 conflict) has to be resolved by ATTR-VALUE, not here. |
| **The #11031 audit's warning on #10778's evidence** | two claims retracted, fabrication-class citations | **HONOURED.** No #10778 figure is quoted in this brief. Every platform claim here is cited to #11031's 2026-09-15 pass or to the per-platform record and, where it was load-bearing, re-collected live (eBay's leaf rule, §B2/3) or re-measured on the corpus (every Shopify number). |

---

## Appendix · what was collected for this brief, and what was not

**New collection (BRIEF §3.2, under the `external-research` skill), all in
`corpus/why-2026-09/`:**

| Artifact | Route | Result |
|---|---|---|
| `https://www.edp.ebay.com/develop/guides-v2/listing-metadata/listing-metadata-guide` | live, P0 | HTTP 200, **200,027 B** on disk — *"Every eBay listing must be listed in an eBay leaf category."*; *"Some metadata endpoints only accept leaf categories."*; the per-leaf policy surface list. *(Revision 1 reported 38,126 B, the figure `curl` printed for the compressed transfer; the saved file is 200,027 B. Corrected after red-team round 1, MINOR 20 — the other three byte counts, 63,985 / 1,832 / 1,832, match exactly.)* |
| `https://pages.motors.ebay.com/file_exchange/errorcodes.html` | live, P0 | HTTP 200, 63,985 B — error **`87`**: *"Invalid Category. The category selected is not a leaf category. \| Listing will fail."* A second eBay surface with a different error code |
| `https://developer.ebay.com/support/kb-article?KBid=648` and `…/trading-user-guide/categories.html` | live | **HTTP 403** ×2, 1,832 B each — unchanged from the record's own finding. `web.archive.org` returned 429 on the availability probe |
| eBay Community thread *"The category is not valid, select another category."* → `corpus/why-2026-09/seller-69be0f.html` | P0 domain, user-generated | **HTTP 200, 909,400 B, saved.** Opened by `newlifece` 2024-01-11, 12 comments. Seller behaviour: *"I have tried consumer electronics &gt; others and computers &amp; networking &gt; other and both throw the same … error."*; *"Do a search for your item, and you'll see what category other sellers have used."* (`nobody*s_perfect`); *"I will just quit using eBay. FB Marketplace here I come!!!"* — all three grepped in the saved bytes |
| 3Dsellers help article on the leaf error → `corpus/why-2026-09/seller-3b9900.html` | **S5 — a lead, not data** | **HTTP 200, 112,194 B, saved.** Remedy stated as drilling to a subcategory |

*(Both seller artifacts were saved during the red-team fix round — SERIOUS 11 found they had been quoted
without being written to the corpus, contrary to BRIEF §3.2. Full provenance table, including the two 403
bodies and the two README copies: `corpus/why-2026-09/PROVENANCE.md`.)*
| `Shopify/product-taxonomy` README at `main` and at `ad206247` | live, P0 | byte-identical (md5 `5d197d41f6fc02b731ca95cfa93c9730`) — the `dist/` deprecation notice, and the "Global Standard / Integration Friendly / Industry Benchmark" framing |

**Corpus left on disk** (not deleted): `corpus/why-2026-09/` (~150 KB) and the pre-existing
`corpus/shopify-taxonomy/` (435 MB, owned by the coordinator).

**Card pointers, and whether each was executed**

| Pointer | Done |
|---|---|
| B1 — eBay's leaf-only rule (62009) and **what sellers do about it** | ✅ three eBay surfaces, two collected live; seller behaviour collected from eBay's own community **and now saved to the corpus** |
| B2 — classify all 292 used non-leaf nodes, publish as a side file | ✅ `nonleaf-classification.md` + `data/nonleaf-classification.csv` (all 292 rows; 48 hand-read after round 1, 244 rule-assigned) |
| B3 — Shopify depth and attributes per node in the food branch, **computed from the corpus** | ✅ `data/shopify-corpus-stats.json`; 764 nodes, max level 6, median 5 attributes, 320 leaf sets |
| B3 — Amazon's 107 food types against Google's 5,595 | ✅ from #10976 §1.1/§1.2 and #11013 §1.7; no new collection needed |
| B3 — **how many of our leaves share an identical attribute need** (shared measurement) | ✅ `node-attribute-need.md` **revision 2**: 61 sets over 1,394 used leaves, 98.7% sharing (measured half unchanged); inferred half rebuilt |
| B4 — eBay's "inheritance override model" | ✅ present in the record verbatim; re-collection blocked by the same 403 |
| B4 — the #11188 survey of 2026-09-15 | ✅ full 13-row table reproduced in B4 §2 |
| B4 — our code: age-walling by exact id list, replenishment by descendants | ✅ both found by search and cited at the pin, plus the 128-product measurement |
| Fork — verify every taxonomy number against the corpus and state the commit | ✅ `fork-shopify-taxonomy.md`; three numbers not reproduced, each recorded |
| Fork — mapping feasibility, ambiguous and unmapped listed | ✅ two passes, rebuilt after round 1; `data/shopify-mapping.csv` + `data/mapping-adjudication.csv` (the over-mapping sample) |
| Fork — **who uses which** (BRIEF §2 names the fork as a card; §4 fixes the eight-section shape) | ✅ **added in the round-1 fix pass (revision 2)** — thirteen platforms over fourteen rows, plus "Why" and "Our code today". *(Round 1 is the report that asked for it; "added in round 1" was wrong — red-team round 2, MINOR 19. "13-row matrix" was also wrong: the table has 14 rows — MINOR 20.)* |

**What I could not collect, and the route that would settle it**

1. **Akeneo's `only_leaves` as a per-tree setting** — single route (#11031's 2026-09-15 pass), whose corpus
   is not on this machine. Route: Akeneo's own category-tree documentation, or the `Category` entity in the
   open-source source tree.
2. **Salesforce's ancestor-walk** — the only (b) precedent in the thirteen, flagged single-route by the
   record. Route: Salesforce B2C Commerce catalog/attribute-group documentation.
3. **A vendor's stated reason for materialising rather than inheriting** — nothing to quote. Route: the
   Shopify taxonomy repo's `docs/` and taxonomist contribution guide, outside our sparse checkout.
4. **Shopee's tree size** and **eBay's production tree** — credential-gated (#11068, not re-attempted) and
   out of scope. Route: a seller credential; a production Taxonomy call.
5. **Why Walmart's feed carries no category field** — route: the `MP_ITEM` spec overview, in a 451 MB corpus
   not on this machine.
6. **Whether any of our 292 non-leaf assignments was deliberate** — route: `api/category/staff/revision/`
   per node.
7. **Whether the 1,252 unmapped nodes have a taxonomy home under a name I did not guess** *(1,291 was the
   revision-2 figure; red-team round 2, MINOR 13)* — route: a
   per-node hand mapping, which *is* the adoption bill and is the number the fork asks the human to price.
