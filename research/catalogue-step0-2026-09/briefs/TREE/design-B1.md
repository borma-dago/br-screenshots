# Design sketch · B1 — do nodes have types?

Against the real models at the pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`,
frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`. Every `path:line` re-opened for this sketch.

## 0 · What exists today

`Category` is one class, `py/mono/solvent/catalogue/models.py:93` — `class Category(MP_Node)`. It has no
type discriminator, no `clean()`, and `Meta` carries only `app_label` and `ordering = ["path"]`
(`models.py:100-102`). "Leafness" is not stored: treebeard's `numchild` column exists
(`catalogue/migrations/0001_initial.py:34`) but **`numchild` and `is_leaf` have zero hits in first-party
backend code** — the only leaf-ish helpers are `has_children()` (`models.py:322-323`), `is_has_children`
(`models.py:325-327`) and `get_num_children()` (`models.py:329-330`), and the Angular frontend has **no**
`is_leaf`, `numchild` or `depth` at all (`ts/libs/category/shared/util-core/src/lib/category.model.ts:3-17`
lists `id · name · slug · full_code · code · image · _name_en · _name_id · is_public` and nothing else).
The one surviving consumer of leafness anywhere is the legacy Vue widget,
`/home/irvan/copilot/ts-layer2/js/solvent_js/src/js/solvent/CategorySelectWidget.vue:71-72`
(`if (!result.is_leaf) { option_object.children = null; }`) — and it uses it for *expandability*, not
selectability.

So option (b) — *one kind; "leaf" only means no children today* — is what we have, by omission.

## 1 · Option (a) — two kinds: folders and types

### Shape

Either two models (`CategoryFolder`, `ProductType`) or one model with a hard discriminator and a validator
forbidding products / attributes on a folder.

### What it costs against our models

| Surface | Change |
|---|---|
| `Category` | a new NOT NULL column + a `clean()` and a `CheckConstraint`, neither of which exists today (`models.py:93-330` defines no `clean`, no `Meta.constraints`) |
| Migration | 1,892 rows need a value. **339 internal nodes are not automatically folders**: 292 of them hold products, and `nonleaf-classification.md` finds 21.9% of those products legitimately parked (hand-read, 48 nodes) (`Fashion > KACAMATA` 642, `FASHION ANAK & BAYI` 596, …). A folder/type split must first resolve every one of those 292 |
| `api/apicategory/staff_serializers.py` | `create` (`:69-81`) and `update` (`:83-148`) must refuse a type→folder change while products exist, and refuse `add_child` under a type. Today `create` is four lines around `add_child`/`add_root` |
| `move` | `staff_serializers.py:116` `category.move(computed_parent_new, "last-child")` — a move that gives a type a child silently turns a type into a folder. No guard exists; the only existing guard is treebeard's `InvalidMoveToDescendant` (`:117-120`) |
| Frontend | the Category read model gains a field; the tree node (`category-tree-node.component.html:1-4`) must stop rendering `Pilih` on folders; the picker (`category-id-form-field.component.ts`) must filter. **Both are new behaviour: today every node is selectable.** ⚠ **The one picker component has two consumers with opposite requirements**: the product form (`product-update-staff-form-ui.component.ts:118-122`) must offer only nodes that accept products, while the **category parent picker** (`ts/libs/category/action/ui-form/src/lib/category-form-ui/category-form-ui.component.ts:96-97`, the same formly `type: 'category-id'`) must offer only folders. A single boolean on the component will not serve both |

### The problem it causes

**A type can never gain a child.** Our tree's own history says it does: `Alat dan Buku Tulis > BUKU TULIS`
has 219 products on the parent *and* a child also named `BUKU TULIS`; `SAYURAN SEGAR` grew to 90 children
while keeping 222 products. Under (a) the only way to refine a type is to create a *new* folder, move the
type under it, and re-home every product — a migration per refinement. That is a worse version of the
problem L1 was chosen to avoid.

**And the discriminator duplicates a derived fact.** Under (a) "is a folder" and "has children" must agree,
and nothing in the code enforces both. We would be storing `numchild == 0` twice.

## 2 · Option (b) — one kind, leaf is derived

### Shape

No change. `numchild` already tells you, and `has_children()` already reads it.

### Fit-check

It fits everything: `main_category` is a bare FK with no `limit_choices_to` (`models.py:427-431`), the staff
write path declares it as a plain `ModelSerializer` field with no `validate_main_category`
(`api/apiproduct/staff_serializers.py:55`), and the picker offers every node. **Nothing has to change**, and
`19,522` products stay where they are.

### The problem it causes

It does not answer the question the lock asks. Under Lock 1 the node owns a schema; a node with children and
products owns a schema that its children's products also (under B4=b) inherit. The tree then has no way to
say "this node groups, that node types", and the 3,402 products under `UNUSED` / `BELUM DISORTIR` /
`INVENTORY KANTOR` become three product types with attribute schemas.

## 3 · Option (c) — one kind with a per-node switch

### Shape

```python
class Category(MP_Node):
    ...
    accepts_products: bool = models.BooleanField(default=True, db_index=True)
```

Day-one default `True` = today's behaviour, so the migration is a column add with a default and **no data
change**. Lock condition 5 already asks for exactly this field.

### Where it has to be enforced

| Surface | path:line | What to add |
|---|---|---|
| the only production create/update path | `api/apiproduct/staff_serializers.py:55` (`main_category` on `ProductStaffSerializerBase`, shared by `ProductCreateSerializer` and `ProductUpdateSerializer`) | `validate_main_category` refusing a node with `accepts_products=False` |
| the DB | — | a `CheckConstraint` cannot express it (it spans two tables); a `Product.clean()` addition beside the existing one (`models.py:468-484`, which today validates only `title` and `self.attr.validate_attributes()`) plus the serializer is the realistic pair |
| the category move | `api/apicategory/staff_serializers.py:116` | nothing — a move does not change `accepts_products` |
| **turning the switch off** | `api/apicategory/staff_serializers.py:83-148` (`update`) | must refuse while `products_with_this_as_main_category` is non-empty; this is the guard lock condition 5 names |
| frontend picker | `ts/libs/category/form/feature-field/src/lib/category-id-form-field/category-id-form-field.component.ts:44-52` and `category-tree-node.component.html:1-4` | hide / disable `Pilih` where `accepts_products=false`; requires the field on the read model `category.model.ts:3-17` and on `api/apicategory/serializers.py:9-19` (nine fields today) |
| Django admin | `catalogue/admin.py:60-62` `CategoryAdmin(TreeAdmin)` | the field appears automatically |

### Consumers a first pass missed (added after red-team round 1, SERIOUS 9)

| path:line | What it is | Why it matters here |
|---|---|---|
| `py/mono/solvent/catalogue/search_indexes.py:8-22` | **`CategoryIndex`** — the category's own Elasticsearch document, with `guid = KeywordField(model_attr="full_code")` and `autocomplete_en` / `autocomplete_id` | Categories are indexed in their own right, keyed on **`full_code`**, not `id`. Any option that adds a field to `Category` also has to decide whether it is searchable here |
| `py/mono/solvent/api/apiproduct/serializers.py:137` and `:208` (`main_category = CategorySerializer()`), listed in `Meta.fields` at `:127` and `:201`; `:76` `"age_walled"` | the product **read** serializers | A field added to `api/apicategory/serializers.py:9-19` surfaces on every product payload too — customer-facing, not just staff |
| `py/mono/solvent/catalogue/managers.py:28-31` — `CategoryQuerySet.browsable()` = `filter(is_public=True, ancestors_are_public=True)` | the actual reader of the inherited visibility flags | This is what "`ancestors_are_public` inherits for free" means in practice; consumed at `api/apicategory/views.py:60, 73` |
| `ts/libs/product/filter/util-core/src/lib/product-filter.util.ts:36` | a ninth **read/filter** `type: 'category-id'` registration (the staff product-search filter util) | brings the read/filter count to nine, not eight. Twelve registrations exist in total: 9 read/filter + 2 write fields (`product-update-staff-form-ui.component.ts:119`, `category-form-ui.component.ts:97`) + 1 storybook spec |

### What inherits for free

- `full_code` cascade (`staff_serializers.py:131-146`) — untouched.
- `ancestors_are_public` (`models.py:271-285`) — untouched; note it writes the subtree with a bulk
  `QuerySet.update()` that fires **no signal**, so a switch implemented the same way would not reindex.
- Search: `category` is a `MultiValueField` of the main category **plus every ancestor id**
  (`catalogue/search_indexes_mixins.py:22, 27-29`), so browsing a node that no longer accepts products still
  returns its descendants' products. **Leaf-only does not break browse** — that is already ancestry-based.
- Age wall (`models.py:570-573`) and replenishment
  (`inventory/replenishment/inventory_replenishment_service.py:31-36`) — untouched.

### The problem it causes

**Two fields can now disagree.** `accepts_products` and `numchild` are independent, so the tree can hold a
node with children *and* products (which is today's reality, 292 times) *and* a leaf that refuses products
(a folder with no children — a dead end). Neither is wrong, but the staff UI has to explain the difference,
and today there is no category-management UI to put it in: the admin "Category List" is a **flat paginated
table** (`ts/libs/category/list/feature-staff/src/lib/category-list-staff/category-list-staff.component.ts:27`)
and the only way down is one page per level
(`.../category-list-children-staff.component.ts:28-32`).

**And the switch is a policy, not a fact**, so it needs an owner. Lock condition 5's third clause ("an owner
for the catch-all nodes") is the same requirement seen from the data side.

## 4 · Side effect none of the three fixes: a category change never reindexes its products

Worth recording here because every option above makes the category more load-bearing, not less.
`Category.save()` enqueues **only its own** search document (`models.py:251-253`,
`SearchIndexQueue().enqueue_update(self)`), and the only `post_save` receiver on `Category` recomputes
`ancestors_are_public` (`catalogue/receivers.py:18-20`). Meanwhile every product document copies
category-derived data — the `category` MultiValueField of ancestor ids
(`search_indexes_mixins.py:27-29`) and the text blob, which includes `full_name_en`, `full_name_id` and
`full_code` (`templates/search/indexes/catalogue/category_lite.txt:1`, included by `product_text.txt:2`).
Nothing walks Category → products. The asymmetry is acknowledged in code at
`solvent/search/receivers.py:26-30`. Under B1=(c) the switch is one more category-derived fact that does not
propagate.

---

## 5 · Corrections after red-team round 1

- **SERIOUS 9** — five consumers the first pass missed are added in the new section above: `CategoryIndex`
  (the category's own ES document, keyed on `full_code`), the product **read** serializers,
  `CategoryQuerySet.browsable()`, the category **parent** picker (a second, oppositely-constrained consumer
  of the one `category-id` component), and the ninth `category-id` filter registration.
- **SERIOUS 8** — B1's tally of option (c) is re-stated in `TREE.md` against the **card's own wording**
  ("a per-node switch, so the rule can tighten later without a migration"), under which the named instance
  is Akeneo and the honest correction is a **scope** difference (per-tree, not per-node), not "zero
  precedent".
- **MINOR 24** — the legacy Vue widget's `is_leaf` branch is **dead**: `grep -rn "is_leaf" py/mono
  --include=*.py` returns zero hits, so the API never emits the field and `!result.is_leaf` is always true.
  That strengthens the section's point and is now said.
