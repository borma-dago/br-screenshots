# Design sketch · B3 (= D16) — how deep should leaves go, and what earns a node

Snapshot 2026-09-19. Data: `sql/nodes-full.sql` → `sql/results/nodes-full.csv`;
`node-attribute-need.md`; Shopify corpus `ad206247` via `scripts/shopify_corpus.py` →
`data/shopify-corpus-stats.json`.

## 0 · The shape we actually have

| Measure | Value |
|---|---|
| nodes / used as `main_category` / unused | 1,892 / 1,686 / 206 (159 of them leaves) |
| leaves / internal | 1,553 / 339 |
| depth | max 8; nodes by depth 1→8: 13 · 74 · 453 · 822 · 190 · 120 · 128 · 92 |
| products by depth 1→8 | 1,724 · 11,172 · 24,257 · 49,478 · 5,683 · 6,361 · 3,737 · 3,749 |
| children per internal node | median **4**, mean 5.5, max **90** (`FRESH > SAYURAN SEGAR`) |
| nodes to cover 50 / 80 / 90 / 95 / 99% of products | 114 / 398 / 639 / 869 / **1,278** |
| used nodes with < 10 products | **609**, holding **2,545 products = 2.4%** |
| used nodes with < 3 products | 216, holding 315 |
| used nodes at depth ≥ 6 | 328, holding 13,847 — of which **13,148 are in one root**, `Perawatan Diri & Rumah Tangga` |

**Two readings that change the question.**

1. **The long tail is node-expensive and product-cheap.** 609 nodes (36% of used nodes) hold 2.4% of the
   catalogue. Under option (a) — every used node is a type — a third of the authoring bill buys 2.4% of the
   products.
2. **The depth-8 tree is not the tree.** Depth ≥ 6 is essentially one branch: the household/kitchen branch
   under `Perawatan Diri & Rumah Tangga`, e.g. `… > PERALATAN RUMAH TANGGA > PERALATAN DAN PENYIMPANAN DI
   DAPUR > PERALATAN MAKAN > PIRING > PIRING KERAMIK` (depth 7). The rest of the catalogue is a depth-4 tree.
   A depth rule stated over the whole tree would be a rule about one branch.

## 1 · What earns a node — the four candidate criteria, tested against our data

| Criterion | Test on our tree | Result |
|---|---|---|
| **a distinct attribute set** | `node-attribute-need.md`: 1,686 used nodes → **68 distinct measured need-sets**; 1,394 used leaves → **61**; 98.8% of nodes share a set | **Fails as a node criterion.** If a distinct attribute set earned a node, we would need ~68 nodes, not 1,686. Attributes do not discriminate at our granularity |
| **a browse need** | the frontend has **no faceted search** (`facet` → 0 hits across `ts/libs`, `ts/apps`) and **no multi-level breadcrumb trail** — but an ancestry read path does exist and is wired end to end: `api/apicategory/views.py:46-55` (a cached `ancestors` action returning `get_ancestors_and_self()`), `ts/libs/category/list/data-access/src/lib/category-tree.service.ts:16` (`categoryAncestorsUrl`), and a **one-level-up parent link** rendered on every category detail page (`category-parent-link.component.ts:27`, `category-parent-link-ui.component.ts:26-27` taking `ancestors[length-2]`, mounted at `category-detail-ui.component.html:1`). The picker also **pre-expands the tree along the ancestor chain** to its current value (`category-tree-select.component.ts:50-73`) | Browse is the *only* thing our depth currently serves. Customer navigation is a one-level-at-a-time drill-down (`category-tree-children.component.ts:28-29`, one HTTP call per expand) with a one-hop parent link and no full trail — so depth costs the customer a tap per level going down, and gives one hop back. *(Corrected after red-team round 1, SERIOUS 10: the original "no breadcrumbs, zero hits" was a word-search artefact.)* |
| **a reporting need** | a single-value category filter on **9 read/filter** registrations — 8 admin tables/modals plus the staff product-search filter util (`ts/libs/product/filter/util-core/src/lib/product-filter.util.ts:36`). Twelve `type: 'category-id'` registrations exist in all: those 9, plus 2 write fields (product form, category parent field) and 1 storybook spec (inventory facility, inventory record, reconciliation lines, replenishment create, price purchase ×2, purchasing group product line, product list) — every one `type: 'category-id'`, single value, ancestry-matched through the ES `category` MultiValueField | Satisfied at **any** depth, because the index carries every ancestor id (`catalogue/search_indexes_mixins.py:27-29`). Reporting does not need leaves |
| **a minimum product count** | 609 used nodes hold < 10 products; 216 hold < 3 | The only criterion that actually discriminates. It is also the only one that is a *policy* rather than a fact |

**Judgement:** of the four criteria the card names, three are already satisfied by mechanisms that do not
need the node (ancestry-matched filters, an attribute set shared by 25 other nodes, a drill-down UI that
costs a tap). The one that bites is product count, and it says the bottom third of the tree is not earning
its existence.

## 2 · What the two reference points actually look like

### Shopify (measured from the corpus, `data/shopify-corpus-stats.json`)

| Measure | Whole taxonomy | Food branch (`Food, Beverages & Tobacco`) |
|---|---|---|
| nodes | 14,606 (26 verticals) | **764** |
| leaves | 11,942 | 656 |
| max level (**0-based** — the histogram starts at level 0 with 26 roots, so "max level 7" = eight levels) | 7 | **6** |
| level histogram | 26 · 218 · 1,619 · 4,704 · 5,159 · 2,252 · 557 · 71 | 1 · 4 · 50 · 284 · 349 · 74 · 2 |
| attributes per node | median **6**, mean 6.37, max 28; 152 nodes (1.04%) carry none | median **5**, mean 5.51, max 13; 1 node carries none |
| distinct attribute names used on the branch | 8,500 distinct (id, name) edges overall | **483** |
| distinct attribute **sets** | 7,018 over 14,606 nodes | **330** over 764 nodes; **320** over its 656 leaves |

So Shopify's food branch is **764 nodes at median 5 attributes**, and its 656 leaves carry **320 distinct
attribute sets** — i.e. roughly one distinct set per two leaves. Our own 1,394 used leaves carry **61**
measured sets. The two numbers are measuring different things (theirs is an authored ideal, ours is what our
titles reveal) and the gap is the whole size of the fork's population bill.

### Amazon vs Google — the granularity spread, from the records

- Amazon, `FoodAndBeverages.xsd`: the schema roots at `FoodAndBeverages` with `ProductType` an `xsd:choice`
  of **107 element refs** (#10976 §1.1 correction note; and *"107 of `FoodAndBeverages.xsd`'s 110 top-level
  elements declare a `Flavor`"*, #10976 §, with the 3 non-product-type exceptions named). Product types are
  **not seller-creatable**: 12 patterns over 877 doc files / 16,441,164 B → **0 hits each** (#10976 §1.1).
- Google: **5,595** nodes, 21 roots, depth 7, and **no per-node attribute set at all** (#11031, 2026-09-15
  comment; #11013 §). Google's own instruction is that assignment is automatic and the attribute is an
  override: *"All products are automatically assigned a product category… The Google product category
  `[google_product_category]` attribute can be used to override Google's automatic categorization in
  specific cases."* (#11013 §1.7).

**The spread is 107 : 764 : 5,595 : 14,606 for the same domain, and the difference tracks what the tree is
for**, not how detailed the world is. Amazon's 107 are *schema* units. Google's 5,595 are *ad-targeting*
units with no schema. Shopify's 14,606 are both. Ours are browse units that Lock 1 is about to make schema
units.

## 3 · The three D16 options against our data

| Option | What it costs here |
|---|---|
| **(a) every used node is a type — 1,686 schemas** | 1,665 of them duplicate another node's set. 609 of them describe < 10 products. Under B4=(a) this is 1,686 authoring decisions; under B4=(b) it is 1,686 nodes that mostly add nothing to their parent |
| **(b) a schema on a subset, untyped nodes inherit** | This is B4=(b) plus a rule for *where* a set is authored. The natural rule from our data: author at the node where the measured set **changes** from the parent's. The bill is a **range, not a number**: **68** distinct sets is the measured floor (what our own titles already distinguish); the inferred route gives **316** distinct sets over just the 434 nodes it reaches (220 on the conservative cut), i.e. ~0.7 sets per node against the measured route's 0.04; (a) would be 1,686. A real schema lands between the floor and the inferred figure, so (b)'s advantage over (a) is "tens to low hundreds vs 1,686", not "68 vs 1,686" *(corrected after red-team round 1, SERIOUS 17)* |
| **(c) a coarser registry, ~Amazon's 107** | Would require collapsing the tree or decoupling schema from tree — but Lock 1 says the category **is** the type, so a coarser registry means a coarser tree, which means re-homing. The lock's own reopen trigger ("staff cannot keep a ~639-node schema coherent") points here |
| **(d, new since #11188) adopt a vendor taxonomy** | `fork-shopify-taxonomy.md` |

## 4 · The pruning question, sized

If "a node must hold ≥ 10 products or be merged into its parent" were applied today:
**609 used nodes merge, 2,545 products move, and 1,077 used nodes remain.** If the threshold is 3:
216 nodes, 315 products. Neither number is a recommendation — both are the price tag.

The 206 currently unused nodes (159 leaves) are free to delete **only** once
`Product.main_category`'s `PROTECT` (`catalogue/models.py:427-431`, migration
`0015_alter_product_main_category.py:14-22`) is satisfied, which it is by definition for an unused node —
but there is **no staff delete endpoint**: `CategoryStaffViewSet` carries `CreateModelMixin` and
`UpdateModelMixin` only (`api/apicategory/staff_views.py:37-44`), and the frontend never calls
`CategoryActionService.delete$`. Deletion today happens only through Django admin
(`catalogue/admin.py:60-62`).


---

## 5 · Corrections after red-team round 1

- **SERIOUS 10** — "no breadcrumbs (zero hits)" replaced with the four cites that exist: the `ancestors`
  endpoint, the ancestors service, the one-hop parent link rendered on every category detail page, and the
  picker's ancestor pre-expansion. The criterion is re-stated as "one-level-up link, no full trail".
- **SERIOUS 17** — the (b) bill is stated as a range (68 floor · 316 inferred over the mapped share · 1,686
  under (a)), in the option table itself and not only in a reopen clause.
- **SERIOUS 9** — the category-filter registration count is **9**, not 8.
- **MINOR 28** — Shopify's `level` is labelled 0-based where the depth comparison is made.


---

## 6 · Corrections after red-team round 2

- **BLOCKING 1 (carried)** — the SERIOUS 17 range edit reached this file in round 1 but **not `TREE.md`**;
  it is now in `TREE.md` B3 §7's Reasoning paragraph as well. The figures here are rebuilt on the round-2
  resolver fix: **316** inferred sets over **434** mapped nodes (220 conservative), not 347 over 485.
- **SERIOUS 9 (carried)** — every inferred figure in §2's comparison moves with the rebuilt mapping; the
  measured figures (68 / 61 / 47 sets, 8 kinds) have never changed.
