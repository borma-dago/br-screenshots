# design-C3 — one level enforced vs nesting on the self-FK

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`; frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.

## 0 · What nesting would actually be, in shape B

> ⚠️ `VariantGroup` / `catalogue_variantgroup` is a **placeholder name**. Table naming is L2.3 and is
> open (step 5 of the page: *"keep `Product` as the sellable row and name the container"*). Nothing in these
> sketches depends on the name.


```
VariantGroup
  id
  parent_id  bigint NULL REFERENCES catalogue_variantgroup(id) ON DELETE CASCADE   ← the whole of option (b)
  main_category_id, title, slug, description, …
Product
  variant_group_id  NOT NULL  →  which level?  the deepest, always (Akeneo's rule)
```

One nullable self-FK is the entire schema cost. Everything expensive is downstream of it.

We already have the machinery: `Category` is `MP_Node` (`catalogue/models.py:93`, django-treebeard
materialised path) with `depth`, `numchild`, `path`, and an `ancestors_are_public` column
(`catalogue/migrations/0013_…`). So a second tree is not new technology here. That is precisely why the cost
has to be counted somewhere other than the migration.

## 1 · Who nests, and why they nest

**Akeneo — exactly two levels, and the cap is a compiled constant.** `FamilyVariantValidator.php` (7,792 B):
`private const MAXIMUM_LEVEL_NUMBER = 2;` at line 20, enforced at lines 154–197
(`if (self::MAXIMUM_LEVEL_NUMBER < $numberOfLevel)`), with `MAXIMUM_AXES_NUMBER = 5` beside it (#11069 §1.6).
Spec, whole: *"- Number representing the level of the attribute set.\n- It should be equal to 1 or 2.\n- If you
specify the level 2, you have to specify the level 1 as well.\n"* Seven help pages carry *"A number of variant
levels: 1 or 2"*.

**Akeneo's reason is content placement, not the grid.** Its own worked example: *"The attributes that vary by
color (variant level 1) are the composition and the pictures. Finally, the attributes that differ by color and
size (variant level 2) are the EAN, the SKU, and the weight."* (#11031 field survey §B). The intermediate
level exists so that *"the composition and the pictures"* have a home that is neither the whole style nor one
SKU. And the levels are attribute-disjoint by rule: *"Attributes used as axes in one level cannot be used as
axes or as attributes in the other level."* (SaaS `openapi.json` `x-validation-rules`, #11069 §1.6).

**Salesforce — a middle tier for merchandising.** `VariationGroup` sits between master and variant:
*"A variation group is a subset of variations that are part of a base product."* · *"While you assign a
variation group to only one base product, you assign multiple variation groups to that base product."* ·
*"A variation group can include only one value of a variation attribute. For example, it can include color:
green or color: red, but not both."* (#11050 §1.2, Trailhead). It is gated: the XSD carries *"Reserved for
Beta users. Variation groups will not be created and a warning will be logged if the Variation Groups (Beta)
feature is disabled."*, and enabling it turns something else off — *"Agentforce Commerce for B2C disables
slicing … when variation groups exist for a base product, but only for that product."* (#11050 §1.x).

**Shopee nests the axis vocabulary, not the family.** Announcement 873: *"If there are two levels of
variations under this category, `variation_group_id` must be passed."* — the standardised tree is
`variation → variation_group → variation_option` (#11047 §1.4). The **item→model** relationship stays one
level, capped at 2 axes.

**Tokopedia Era B has an above-product object, gated to one market.** `product_families[]`, *"Applicable only
for US local sellers"* (#11048 §1.10).

**Nine are one level, and several say so structurally rather than as prose:**
Amazon — *"Child products are unique, sellable products that are related in our catalog to **a single**,
non-sellable parent product"*, plus *"You must remove a child listing from its current parent-child
relationship before you relate it to a new parent"* and feed error 8032 (#10976 §1.8) ·
Walmart — *"An item can belong to only one variant group."* (`corpus/walmart/wm-multiple-variants.txt`,
fetched 2026-09-19) · eBay and Square, one level (#11031 P2/D12) ·
Magento — `catalog_product_super_link` with `UNIQUE (product_id, parent_id)` (#11082 §1.5) ·
WooCommerce — the child is a `product_variation` post whose `post_parent` is the container, and *a
non-`product` parent is reset to 0* (#11080 §2b) ·
commercetools — `Variant --1..1--> Product` in both models (#11081 §1.6, §1.7) ·
Shopify — `Product → ProductVariant`, one level · Google — a flat `item_group_id` string.

## 2 · The measurement that would justify nesting — and what it shows

Nesting is only worth a column if something needs to live **between** the style and the SKU. A two-axis grid
alone does not need it: one family with two axes expresses the same grid, and D6 already proposes a cap of 3.

**Grids do exist in our data.** `sql/fam-c3-grid.sql`, 2026-09-19, over the 10,090 proxy families (≥2 products
sharing a three-word title prefix inside one `main_category`), splitting each title into a net-content token
(`85 GR`, `500 ML`, …) and the remaining words:

| | Families | Products |
|---|---|---|
| vary on net content only (`units>1`, `rest=1`) | 747 | — |
| vary on the words only (`units≤1`, `rest>1`) | 6,560 | — |
| **vary on BOTH — a grid candidate** | **1,748 (17.3%)** | **8,071** |

The Indomie family is one of them: `INDOMIE GORENG CABE IJO 85 GR` and `INDOMIE GORENG CABE IJO JUMBO 120 GR`
are the same flavour in two sizes, while thirty-one other flavours exist at one size each
(`sql/results/indomie.csv`). That is a ragged grid — 33 flavour values × a size axis that is filled for one
of them. **A ragged grid is the case two axes handle and nesting handles badly**: under nesting, 32 of the 33
flavours would be sub-families of one member each.

**Nothing in our data asks for an intermediate content home.** Akeneo's reason for level 1 is *"the composition
and the pictures"*. Our pictures: only **30,740 of 106,161** products carry any image at all
(`sql/results/baseline.json`), and **5,299 of 10,090 proxy families (52.5%) have no image on any member**
(`sql/fam-c1-sibling-consistency.sql`). There is no photographed-per-colour corpus to hang off a middle level.

## 3 · The apparel re-run (#10943), and why it is a sensitivity analysis

#10943's comment of 2026-08-10 reports *"Of **1,945** apparel-titled live products
(`KAOS|BAJU|CELANA|KEMEJA|JAKET|SERAGAM|PAKAIAN`), only **240 (12.3%)** carry any size token at all — and many
of those express a *range* rather than a single size."* **The regex for "size token" was not published**, so
the re-run is a sensitivity analysis, not a reproduction (`sql/fam-c3-apparel-sensitivity.sql`, 2026-09-19):

| | Rows |
|---|---|
| apparel-titled, all | 2,201 |
| apparel-titled, live (`is_active AND is_public`) | **2,062** (was 1,945 on 2026-08-10) |
| apparel-titled, **active online** | **78** |
| def1 range only (`M-XL`) | 50 |
| def2 unambiguous letters only (`XS`,`XL`,`XXL`,`2L`,`3L`…) | 262 |
| def3 letter size at the **end** of the title | 368 |
| def4 explicit marker word (`SIZE`/`UKURAN`/`UK`/`ALL SIZE`) | 23 |
| **def1 ∪ def2 ∪ def4 — the defensible floor** | **287 (13.9%)** |
| def5 permissive (any letter size anywhere, incl. bare `S`/`M`/`L`) | 688 |

**The defensible floor reproduces #10943's order of magnitude** (287/2,062 = 13.9% against 240/1,945 = 12.3%).

Two things the keyword set does that the original comment did not flag:
- **It is not all apparel.** `CELANA` catches adult and baby pants-type diapers: `LIFREE POPOK CELANA EXTRA
  SERAP XL12` · `LIFREE POPOK CELANA TIPIS L16` · `SOFTEX CELANA MENSTRUASI ISI 2`. Those rows are a genuine
  **size × count grid** — `XL` glued to `12` — and they are grocery, not apparel.
- **Apparel is not an online category today.** 78 of 2,062 live apparel-titled rows are active online
  (3.8%). #10943's own framing — *"the stronger driver is **online ordering**. A customer buying a shirt
  online has to choose a size"* — is a statement about a business we do not currently run on this shelf.

## 3b · The family concept is absent from both stacks — instrumented

⚠️ Added after red-team round 1 (finding 44): `FAMILY.md` C3 §4 asserted this rather than measuring it.

| Pattern | Backend (`py/mono/solvent`, `--include=*.py`) | Frontend (`ts/libs`, `ts/apps`, `--include=*.ts --include=*.html`, `.spec.ts`/`.stories.ts` excluded) |
|---|---|---|
| `VariantGroup` / `variantGroup` | 0 | 0 |
| `variant_group` | 0 | 0 |
| `ProductGroup` / `productGroup` | 0 | 0 |
| `product_group` | 0 | 0 |
| `item_group` | 0 | 0 |
| `family` | — | **3**, and all three are CSS `font-family`: `libs/shared/style/util-font-fit/src/lib/font-fit.ts:18` (a comment), `libs/shared/feature-apps-bootstrap/src/lib/environment-indicator.util.ts:98` and `:133` |
| **positive control** `product.title` / `product.slug` | — | **30 occurrences in 22 files** |

So C3 forks no existing call site in either stack, and the cost of nesting is entirely prospective.

## 4 · What one level enforced actually costs, and what nesting costs

| | One level | Nesting on a self-FK |
|---|---|---|
| Schema | no `parent_id` column — the rule is **unstatable**, not validated | one nullable self-FK, CASCADE |
| "which family is this member in?" | `product.variant_group_id` | a walk, or a materialised path like `Category`'s |
| Lock condition 4's composite-FK axis mirror | mirrors `(group_id, dimension_count)` — one key | must mirror the **deepest** level's key; the middle level's axes are a second key, and "every member fills every axis" becomes "…of every ancestor level" |
| Axis-disjointness across levels | not a concept | a new cross-level validator, Akeneo's rule: *"Attributes used as axes in one level cannot be used as axes or as attributes in the other level."* |
| Elasticsearch collapse (the grouping mechanism) | collapse on `variant_group_id` | collapse must pick a level; collapsing on the leaf group under-groups, on the root over-groups. The record already flags the hit-count problem (`hits.total` is reported before collapsing) — a second level does not add a new class of problem, but it doubles the number of "which key?" decisions |
| Google feed | one `item_group_id` | Google has **one** grouping level; a nested family must flatten to one id anyway, so the second level is invisible to the channel |
| Family-level ranking aggregates (the lock's "most serious open item") | one rollup per group | a rollup per level, or a choice of which level ranks |
| Merge / split UI | two operations | two operations × three placements (same level, promote, demote) |

**The asymmetry is the whole argument.** Adding the column later is one migration with `parent_id` NULL
everywhere and no data to backfill — Lock 2's groups are already the level a nested model would call the
deepest. Removing it later means collapsing real hierarchies someone has authored. So "one level" is the
reversible choice and "nesting" is not.

## 5 · How to enforce one level without writing an enforcement

Do not add a `parent_id` column and do not add a validator that forbids nesting. A rule with no column to
violate cannot be violated, which is the same argument that made shape B beat shape C: *"C7 'exclusion
structural, not advisory' is satisfied by construction under shape B."* If nesting is ever wanted, the
migration is additive and nothing has to be un-done.
