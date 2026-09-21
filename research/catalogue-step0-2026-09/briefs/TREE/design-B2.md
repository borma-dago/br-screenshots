# Design sketch · B2 — may a product sit on a non-leaf node?

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.
Numbers: snapshot 2026-09-19, `sql/nodes-full.sql`, `sql/nonleaf-used.sql`, `data/nonleaf-classification.csv`.

## 0 · Today

Nothing forbids it, on either stack, at any layer:

- `Product.main_category` is a bare FK with `on_delete=PROTECT` and **no** `validators=`, no
  `limit_choices_to` (`py/mono/solvent/catalogue/models.py:427-431`).
- `Product.clean()` (`models.py:468-484`) validates `title` and `self.attr.validate_attributes()`. Category
  is not mentioned.
- The single production write path declares `main_category` as a plain `ModelSerializer` field
  (`py/mono/solvent/api/apiproduct/staff_serializers.py:55`); neither `ProductStaffSerializerBase`,
  `ProductCreateSerializer` (`:84`) nor `ProductUpdateSerializer` (`:131`) defines `validate_main_category`.
  DRF's default `PrimaryKeyRelatedField(queryset=Category.objects.all())` accepts any node.
- `catalogue/validators.py` is 47 lines and contains exactly one function, `validate_product_upc` (`:10`).
- The frontend picker renders the `Pilih` button on **every** node unconditionally
  (`ts/libs/category/tree/feature-core/src/lib/category-tree-node/category-tree-node.component.html:1-4`);
  `is_leaf` / `isLeaf` has **zero** hits across `ts/libs` and `ts/apps`.

Result: 19,522 products on non-leaf nodes, 1,724 of them on a root.

## 1 · Option "leaves only"

### The migration this forces

19,522 products need a home before Lock 1 ships. `nonleaf-classification.md` splits them:

| Class | Products | What leaf-only forces |
|---|---|---|
| `under-filed` | 8,374 (42.9%) | move to the child that already fits. **Machine-assignable**: `child_name_hit` is ≥ 0.30 on the worst offenders (`SAYURAN SEGAR` 0.676, `BUAH` 0.706, `ALAT DAPUR` 0.44), and `nearest_child` gives a candidate for the rest. Still a staff review per node |
| `residual-type` | 4,410 (22.6%) | **a new leaf must be invented for each**, because the existing children are facets, not a partition. `Fashion > KACAMATA` (642) needs a `KACAMATA BIASA`; `PAKAIAN DALAM WANITA` (299) needs a `MINISET`; `MENJAHIT` (225) needs a `KANCING`. This is the eBay-seller behaviour reproduced: the record's own `62009` rule, and the live eBay page *"Every eBay listing must be listed in an eBay leaf category"*, push sellers into `… > Other` leaves (evidence in `TREE.md` §B1/3) |
| `mixed` | 3,845 (19.7%) | per-product triage |
| `declared-catch-all` | 1,766 (9.0%) | these *are* the `… LAINNYA` leaves the rule would otherwise create. 12 of them already have children, so leaf-only forces a `LAINNYA > LAINNYA` |
| `root-parking` | 579 (3.0%) | 9 roots; needs a destination leaf per root |
| `not-a-type` | 548 (2.8%) | no product type exists for them at all — see below |

**The `not-a-type` problem is the one leaf-only cannot solve.** Three whole roots are operational or
merchandising containers: `UNUSED` (1,923 products in subtree, containing `AREA DISPLAY > CARDINAL > CARDINAL
OBRAL`), `BELUM DISORTIR > BARANG OBRAL` (1,382), `INVENTORY KANTOR` (78). Leaf-only would move these
products to the deepest node of a tree that is still not a product type. **3,402 products, 3.2% of the
catalogue.**

### Code changes

| Surface | path:line | Change |
|---|---|---|
| write path | `api/apiproduct/staff_serializers.py:55` | add `validate_main_category` rejecting `numchild > 0` |
| model | `catalogue/models.py:468-484` | add the check to `Product.clean()` |
| DB | — | **not expressible as a `CheckConstraint`** — it spans `catalogue_product` and `catalogue_category`. Either a trigger, or accept validator-level enforcement. Note the repo's existing DB-level guarantees on this tree are only `full_code` unique (`models.py:139`), `slug` unique (`:126`), `path` unique (`migrations/0001_initial.py:32`) |
| category create | `api/apicategory/staff_serializers.py:69-81` | **`add_child` now invalidates the parent.** Giving a leaf a child turns every one of its products illegal. Needs a guard, which does not exist |
| frontend | `category-tree-node.component.html:1-4`, `category-id-form-field.component.ts` | filter `Pilih` to leaves; requires `numchild`/`is_leaf` on the read model (`category.model.ts:3-17`) and on the serializer (`api/apicategory/serializers.py:9-19`) — **neither carries it today**. The **same picker component** is also the category **parent** picker (`category-form-ui.component.ts:96-97`), which needs the **inverse** filter, so the filter must be a parameter, not a constant |
| product read payloads | `api/apiproduct/serializers.py:127, 137, 201, 208` | `main_category = CategorySerializer()` on both read serializers — any new category field ships to the customer API too |
| legacy | `js/solvent_js/src/js/solvent/CategorySelectWidget.vue:71-72` | already consumes `is_leaf`, from the oscarapi contract, a different API |

### The standing problem it creates

**Every future refinement breaks data.** Under leaf-only, `add_child` on a node holding products is a data
migration. Our tree grows exactly that way — `BUKU TULIS` has a child of the same name; `SAYURAN SEGAR` grew
to 90 children. A rule that makes the ordinary act of refining a category an illegal state is a rule staff
will route around, and the route is a `… LAINNYA` leaf. We already have 48 of those holding 3,591 products.

## 2 · Option "yes, any node"

Nothing changes. The fit-check is §0: it already works, and search already treats browse as ancestry-based
(`catalogue/search_indexes_mixins.py:27-29` indexes `main_category` **plus every ancestor id**), so a product
on `Snack` is found when browsing `Makanan dan Minuman` without any extra work.

The cost is that under Lock 1 the 292 used non-leaf nodes each own a schema that must be *more general* than
its children's — which is exactly the shape B4 has to decide. And the three non-type roots keep their
schemas.

## 3 · Option "per node, an `accepts_products` switch"

Day-one default `True` → **zero-row migration, zero behaviour change**, which is what makes it the only
option that can ship before the 19,522 are cleaned. The switch is then flipped node by node as each is
cleaned, so the clean-up is incremental and each flip is irreversible-by-guard rather than by convention.

Mechanics, guards and the frontend work are identical to B1 option (c) — see `design-B1.md` §3; the two
options are the same column. Lock condition 5 asks for all three pieces: the switch, "a guard on the
category move", and "an owner for the catch-all nodes".

**What the switch does not give you:** a reason. `accepts_products=False` on `Makanan dan Minuman` is
obvious; on `Fashion > KACAMATA` it would be wrong. Nothing in the column records which of the 292 was a
cleanup and which was a policy, so the 292 still need the classification in
`nonleaf-classification.md` before anyone can set them.

## 4 · What a category *move* does under each option

`api/apicategory/staff_serializers.py:104-148` runs inside `transaction.atomic()` and does four things:
`super().update`, optional `category.move(...)` (`:116`) or `promote_to_root` (`:111`, `:150-162`), then a
DFS `full_code` cascade over `get_descendants()` (`:131-146`). Note for the red team: `to_sync` is built at
`:129`, appended at `:146`, and **never read** — a dead local; and the uniqueness check at `:56-67` validates
only the node's own recomputed `full_code`, not the cascaded descendants'.

| Option | What a move newly breaks |
|---|---|
| any node | nothing new |
| leaves only | moving node X under node Y **invalidates every product on Y**. The serializer would need a pre-flight count over `Y.products_with_this_as_main_category` |
| switch | nothing at move time; the switch travels with the node |

Under all three, the move already leaves the search index stale for the subtree's products (no
Category→products reindex exists; see `design-B1.md` §4).


---

## 5 · Corrections after red-team round 1

- **SERIOUS 9** — added the category **parent** picker (`category-form-ui.component.ts:96-97`) as a second,
  oppositely-constrained consumer of the one `category-id` component, and the product **read** serializers
  (`api/apiproduct/serializers.py:127, 137, 201, 208`).
- **SERIOUS 15** — `api/apisearch/filters.py:26-29` is the generic `_handle_equality_filters` helper and
  contains no category; the category query field is `py/mono/solvent/api/apisearch/serializers.py:10`
  (`category = PositiveInteger32Field()`). Corrected in `TREE.md` B2 §4.
- **SERIOUS 6** — the class shares quoted in §1 are updated to the revised classification (hand-read 48
  nodes: under-filed 52.3%, residual-type 21.9%, mixed 10.2%, catch-all 8.9%, not-a-type 3.8%,
  root-parking 3.0%; all 292: 8,374 / 4,410 / 3,845 / 1,766 / 579 / 548).
