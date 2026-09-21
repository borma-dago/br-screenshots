# FAMILY — Step-0 research brief · cards A5 · C1 · C2 · C3

**Date** 2026-09-19 · **Brief id** FAMILY · **Owner of** A5 (attribute level, subsumes D11, touches D10) ·
C1 (the sibling rule, incl. barcode identity) · C2 (pack / bundle, touches D6 and #11126) · C3 (sub-families,
= D12).

**Pins.** Backend `/home/irvan/copilot/py-5` @ solvent-master `4f99dc01c6`. Frontend
`/home/irvan/copilot/ts-layer2` @ ts-master `82187a17bd`. Every `path:line` below was re-taken at those pins.
⚠️ **Line numbers have moved since the 2026-09-15 field-survey page**, which cites `Product.upc :390 ·
title :398 · description :418 · main_category :434`; at this pin they are `:385 · :392 · :410 · :427`. Where
this brief and that page disagree on a number, this brief's is the current one.

**Numbers.** BigQuery `solvent-staging.production_append_public`, snapshot **2026-09-19 10:27 UTC**. Shared
baseline in `../../sql/results/baseline.json`; everything else this brief measured is in `sql/` beside this
file with its result CSV in `sql/results/`. **All nine queries are pinned to the snapshot** — every
`ROW_NUMBER()` subquery carries
`WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` (17
subqueries across the nine files), per BRIEF §3.4. Verified 2026-09-19: the bounded results are
**byte-identical to the published ones**, and byte-identical again on an immediate second run, so **the
bound corrected no figure** — it made every figure re-derivable at any later date. The unbounded first-run
originals are kept in `sql/unbounded-originals/` with a README saying not to re-run them.

**Revision 3, after red-team round 2** (`redteam-round2.md`, 0 BLOCKING · 3 SERIOUS · 5 MINOR; all round-1
blockers verified fixed). Round 2 changed **no figure and no recommendation**. It corrected the two section
lead sentences that still printed tallies their own sections had withdrawn (A5 §2, C2 §2), two off-by-one
line cites, the boxed C2 judgement's missing qualifiers, and a Meta-artifact note — and it caught that the
SQL had no time bound, which is now fixed at the root for the whole pack. Each affected card's §8 ends with
a **"Corrections after red-team round 2"** list.

**Revision 2, after red-team round 1** (`redteam-round1.md`, 4 BLOCKING · 29 SERIOUS · 13 MINOR). Every
finding is resolved at the root in the section it affects, and each card's §8 ends with a
**"Corrections after red-team round 1"** list naming the finding number and what changed. Three things moved
that a reader of revision 1 should know about: the **title-composition cost** (two call sites → nine, C1 §7),
the **product → search-index reindex fan-out** (absent → a required work item in A5 §4, C1 §4 and
`design-C1.md` §5b), and the **A5 tally** (6/1/4/1 → a1 4 / a2 2 / b 1 / c 4 / d 1, which costs A5-a its
plurality without changing the recommendation).

**Files beside this one**

| File | What it holds |
|---|---|
| `design-A5.md` | the three level options sketched against `ProductAttributeValue`, the family-value attachment, what `SameForAll` costs |
| `design-C1.md` | the sibling rule as DB constraints vs validators; merge/split; the per-field divergence table |
| `design-C2.md` | GS1's three pack rules; count-as-axis vs separate product on our real rows and the real feed |
| `design-C3.md` | one level vs nesting on a self-FK; the grid measurement; the #10943 re-run |
| `sources-new.md` | the new-source pass: Meta, GS1, Walmart — artifacts, two-route table, OPEN rows, counter-evidence searched |
| `sql/*.sql`, `sql/results/*.csv` | **nine** queries, all snapshot-bounded, results beside them (eight from revision 1 plus `fam-a5-indomie-manufacturer.sql`, added in the round-1 fix) |
| `sql/unbounded-originals/` | the nine queries as first run, before the snapshot bound — provenance only, with a README saying not to re-run them |

**Summary of what this brief confirms, re-expresses, or proposes to supersede**

| Standing item | Verdict here |
|---|---|
| #10778 **S1** family never buyable | **confirmed**, and under shape B it is satisfied by construction rather than by a rule (C1 §6) |
| #10778 **C2** family page at every variant's URL, hero by `display_order` | **re-expressed**: the hero survives and is needed; the *bare family URL* half is dropped as unnecessary under shape B (C1 §6) |
| #10778 **M4** a same-product banded or promo pack is an ordinary dimension value | **re-expressed**: true for a same-product multipack (`2×500 ml`), not true for #11126's two-different-products banded pack (C2 §6) |
| #10778 **M9** no cross-brand grouping, advisory only | **confirmed**, with our own numbers for why it cannot be enforced (C1 §5) |
| Tentative 2026-09-15 **`ProductAttributeValue` on the member** | **confirmed as the day-one state**, and A5's recommendation is designed to leave it untouched (A5 §7) |
| Tentative 2026-09-15 **description = family** (evidence-settled) | **confirmed as the home**, **overruled as a silent migration** — our data has 3,912 proxy families with a different description on every member (C1 §5) |
| Baseline **"titles with multiplier N x M = 2,168"** | **corrected**: 2,055 of them carry no unit and are dimensions, not multipacks (C2 §5) |

---

## A5 · Does an attribute belong to the product, to the product variant, or both?

"Product" = the family row Lock 2 gives every product; "product variant" = the sellable member.

### 1 · Options

- **A5-a — pinned on the definition.** Each attribute is family-level or member-level, fixed on the
  definition row. (commercetools `AttributeDefinition.level = Product | Variant`, plus `attributeConstraint:
  SameForAll`.)
- **A5-b — either side, chosen per family.** The family declares which of its attributes vary. (Akeneo's
  family variant distributes attributes across levels.)
- **A5-c — always on the member; the family carries nothing**, shared facts copied across siblings.
- **A5-d — both levels with a read-time fallback** (*extension, with a stated reason*). The member's value
  wins if it has one, otherwise the family's is read. This is not one of the card's three, and it has to be
  on the list because **three of the thirteen records implement it** (Salesforce's documented chain,
  WooCommerce's `'parent'` sentinel, Shopee's weight/dimension fallback) **and because we have already
  adopted it for images** — the 2026-09-15 tentative decision is "member first, family too".

The card's rule, carried forward: *if an attribute is on the product, its variants do not store it; an axis is
variant-level by definition (A2, owned by ATTR-DEF — cite).* A5-d is the one option that breaks the first half
of that rule, which is itself a finding (§6).

### 2 · Who uses which, who does not

**Split, not unanimous, and no option has a plurality once "pinned" is split by mechanism** — the level is
**declared on an attribute definition in 4** (Shopify, Square, Tokopedia Era B, commercetools), **fixed by
the API's structure with no level field anywhere in 2** (Shopee, WooCommerce), **chosen per family in 1**
(Akeneo), **absent — always on the member — in 4** (Amazon, Google, Walmart, Magento), and **a read-time
fallback as the primary model in 1** (Salesforce), with **eBay named ambiguous**. Full tally, with the
reason for the a1/a2 split, below the table.

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | *"Most product facts must be replicated across all listings within the variation family"*; *"a programmatic classification of every populated column found **zero fields populated on the parent row and on no child row**"* across *"all 7"* worked families. ⚠️ The record retracts their independence: *"**The seven flat-file `Example` sheets are one artifact, not seven.** Beauty, FoodAndBeverages, Gourmet, Health, Jewelry, PetSupplies are **cell-identical** (SHA1 of all cell values `c55c37cfc4ba`); Clothing differs only by 5 absent `other-image-url` columns. Only `Flat.File.Home.xls` … is a genuinely independent second route"* (`10976.md:418`) — **two** observations, not seven | #10976 §2 `[E-12][E-28]`, `:391` + `:418` | **c** |
| **Shopify** | `MetafieldDefinition.ownerType : MetafieldOwnerType!` — *"The resource type that the metafield definition is attached to."*; the enum includes **both** `PRODUCT` and `PRODUCTVARIANT`, and a definition names exactly one. ⚠️ The enum's size is version- and route-dependent — 25 at `2026-04`, **26 at `2026-07`**, 26 at `2026-10`, 28 at `unstable`, and Shopify's *published* `2026-07` artifact says 25 against the live proxy's 26 (#11011 contradiction 7); `PRODUCT` and `PRODUCTVARIANT` are in every one of those sets | #11011 §1.8, enum whole at §1.8 | **a** |
| **Google** | *"**Google** and **Walmart** read "member" everywhere because neither has a family object **on the write side**. Google's only group-level values are `item_group_id` **and `item_group_title`**, repeated on every row."* | #11031 field survey §A (`11031.md:1263`) | **c** |
| **eBay** | `aspectApplicableTo ∈ {ITEM, PRODUCT}` — *"This value indicate if the aspect … is a product aspect (relevant to catalog products in the category) or an item/instance aspect, **which is an aspect** whose value will vary based on a particular instance of the product."* Live: *"present on **106,766 of 197,046** (`["PRODUCT"]` 87,560 · `["ITEM"]` 19,206; array length 1 in every instance)"* — the field is `0..N` and is absent on the other 90,280 (`11045.md:116`). ⚠️ `11045.md` **U12-c** records that these bulk counts are *"one artifact read once"*. Structurally there are slots at both levels: `InventoryItemGroup.aspects` and `InventoryItem.product.aspects` | #11045 §1.2 `[R-2]`, §1.4, §1.6 | **ambiguous (a/c)** — see below |
| **Walmart** | no container on the write side; *"shared by repetition, not reference"* | #11046 §2, §2b | **c** |
| **Shopee** | the item carries `attribute_list`; the `model` has **no attribute slot at all**. Three physical fields inherit: *"**Shared fields are inherited, not independently valued by default**"*; vendor text — *"If don't set the weight of this model, will use the weight of item by default. **If set the dimension of this model, them must set the weight of this model.**"* and *"If don't set the dimension of this model, will use the dimension of item by default."* (the second sentence of the weight rule is a conditional revision 1 dropped) | #11047 §1.5 (`11047.md:420, :423, :427-429`), §2b | **a-by-structure** (see the tally note) + a **d** mechanism for `weight`, `dimension`, `pre_order` |
| **Tokopedia Era B** | `attributes[].type`, whole: *"The attribute type. Possible values: - `SALES_PROPERTY`: Indicates sales attributes that define product variants. - `PRODUCT_PROPERTY`: Indicates product attributes that describe the product as a whole."* | #11048 §1.x `[R-2]` | **a** — the cleanest instance in the set |
| **Square** | `CatalogCustomAttributeDefinition.allowed_object_types`, **1..N, required, immutable** — *"The set of `CatalogObject` types that this custom atttribute may be applied to. Currently, only `ITEM`, `ITEM_VARIATION`, `MODIFIER`, `MODIFIER_LIST`, and `CATEGORY` are allowed. At least one type must be included."* (the misspelling is the vendor's); *"an ITEM-allowed definition and an ITEM_VARIATION-allowed definition are **separate definitions**, so values do not flow down"* | #11049 §1.7 `[R-1][R-11]`, §4 | **a**, with the hedge that the array may carry both (`["ITEM","ITEM_VARIATION"]` is the record's example value) |
| **Salesforce B2C** | one `<product>` complexType serves master and variant; *"If the variant does not define an own value, the value is retrieved by fallback from **variation groups (sorted by their position)** or the variation master."* | #11050 §2b `[R-4]`, §1.x | **d** |
| **Magento** | *"There is no inheritance mechanism in the schema"* — no `use_parent` column on any of the five value tables; every EAV value row is keyed `(entity_id, attribute_id, store_id)` so parent and child each own theirs. `is_global` is a **store** scope (`SCOPE_STORE = 0; SCOPE_GLOBAL = 1`), not a product/variant level | #11082 §2b, §1.4 | **c** |
| **WooCommerce** | container-only postmeta is `_product_attributes` (**the whole attribute list**), `_default_attributes`, the `product_cat`/`product_type` terms and the child id list; the variation stores only `attribute_<key>` rows (its selected axis values). Separately, `manage_stock`/`stock_quantity` inherit by an explicit sentinel — `$value = 'parent';` | #11080 §2b `[R-42][R-5][R-75]` | **a** for the attribute system, + a **d** mechanism for stock |
| **commercetools** | `AttributeDefinition.level`, `1..1`, draft default `Variant`; `AttributeLevelEnum.raml` whole: `enum: [Product, Variant]`, *"Product: Attribute is defined at Product level (**not supported** by Product Projection Search)."*; Merchant Center: *"The **Attribute level** option cannot be changed after saving the Attribute."*; gate: *"If the Attribute is defined at Product level, then `attributeConstraint` must be `None`."* ⚠️ `11081.md:913` **U1**: *"**No live response for any object.** Every instance in §2c is a vendor documentation example."* | #11081 §1.2 `[R-1][R-26]`, §2b, §4 U1 | **a** — the canonical **documented** shape |
| **Akeneo** | `FamilyVariant.variant_attribute_sets[].{level, axes, attributes}` assigns each attribute to exactly one level. Vendor instance, whole: `{"code":"clothing_color_size", … "variant_attribute_sets":[{"level":1,"axes":["color"],"attributes":["variation_name","variation_image","composition","color","material"]},{"level":2,"axes":["size"],"attributes":["sku","weight","size","ean"]}]}` | #11069 §2c `[R-74]`, §2b | **b** — the canonical **documented** shape (the instance is a vendor doc page plus a shipped fixture row, not a live read) |

**Tally, split after red-team round 1 (findings 7, 8)** — because "pinned" has two very different
mechanisms and revision 1 counted them as one:

| Bucket | Count | Platforms |
|---|---|---|
| **a1 — the level is a field on an attribute *definition*** | **4** | Shopify (`MetafieldDefinition.ownerType`) · Square (`allowed_object_types`) · Tokopedia Era B (`attributes[].type`) · commercetools (`AttributeDefinition.level`) |
| **a2 — the level is fixed by the API's *structure*, with no level field anywhere** | **2** | Shopee (one item-level `attribute_list`; the model has no attribute slot) · WooCommerce (`_product_attributes` on the parent post, `attribute_<key>` on the variation post) |
| **b — chosen per family** | **1** | Akeneo |
| **c — always on the member / no level concept** | **4** | Amazon · Google · Walmart · Magento |
| **d — both levels, read-time fallback, as the *primary* model** | **1** | Salesforce |
| **ambiguous, named** | **1** | eBay |

**d also appears as a *mechanism beside* another model in three records** — Salesforce's documented chain,
WooCommerce's `$value = 'parent';` stock sentinel, and Shopee's `weight`/`dimension`/`pre_order` fallback —
so "d as a mechanism = 3". Revision 1's §1 said "three of the thirteen implement it" while its tally line
said "d = 1"; both are true of different questions and the tally now prints both.

⚠️ **This costs A5-a its plurality, and the brief accepts that.** Revision 1 counted a = 6 and §7 leaned on
*"the plurality (6 of 13)"*. Applying the brief's own discounting move consistently — *"(c) is what you do
when you have nowhere else to put it"* — Shopee and WooCommerce are structural, not declared, so the
declared-level count is **4**, level-pegged with (c)'s 4. §7's confidence rationale is rewritten accordingly
and no longer rests on plurality.

**Why eBay is ambiguous and not counted.** It has slots at both levels *and* a level-ish flag on the
definition — but `aspectApplicableTo`'s own wording is about **eBay's catalogue product vs a seller's
instance**, not about the seller's `InventoryItemGroup` vs its `InventoryItem`. No retrieved artifact says a
`PRODUCT` aspect must be written on the group. Assigning it to (a) would be my classification, not eBay's
statement, so it stays named.

**The reading that matters more than the tally.** The four (c)s are the four platforms with **no family
*content* row on the write side**: Google and Walmart have no container object there at all, Amazon's parent
and child are rows of one flat schema, Magento's container and child are rows of one table. **(c) is what you
do when you have nowhere else to put it.** Lock 2 has already decided we will have somewhere else.

⚠️ **Narrowed after red-team round 1 (finding 3).** Revision 1 wrote this as *"no family content row"* full
stop, on the strength of a Google quote it had edited — dropping the record's *"on the write side"* scope and
deleting `item_group_title` from Google's group-level values. **Google does carry two group-level values**
(`item_group_id`, `item_group_title`), and C1 §2 leans on the second. The (c) reading survives in the
narrower form above — Google's group-level values are a *key* and a *title*, not a content row — but the
unqualified version rested on a manufactured quotation and is withdrawn.

### 3 · Why each platform chose it

**Stated by the vendor:**
- **commercetools** states the constraint that forces the level's one rule: *"If the Attribute is defined at
  Product level, then `attributeConstraint` must be `None`. Otherwise, an InvalidOperation error is
  returned."* (`AttributeDefinitionDraft.raml:36-41`) — i.e. a product-level attribute cannot also be
  declared same-for-all, because being product-level **is** same-for-all. It also states the cost of the
  level: *"Product: Attribute is defined at Product level (not supported by Product Projection Search)"* —
  the search surface could not read product-level attributes. ⚠️ That caveat names a **deprecated** API:
  `(markDeprecated): true` on `product-projections-search.raml`, and the 2026-08-31 release note *"as of 31
  August 2026, activating Product Projection Search is no longer generally available."* (#11081 §1.2).
- **Amazon** states the replication rule and the enforcement together: *"Required attributes that must be
  identical across a family. Terms like "item type keyword," "model name," "style," and "brand" are key
  non-varying attributes for which all child ASINs must have the same values. **Child ASINs with different
  non-varying attribute values cannot be grouped into a single variation family.**"* (#10976 §2 `[E-25]`).
  The mechanism is admission control, not storage.
- **Akeneo** states what moving a level does to existing data: *"if you move the Description attribute from
  the common attributes to the variant attributes level 1, the description previously filled in will be kept
  for all variant products, but you can change it"* (#11031 field survey §B, help.akeneo.com).
- **Square** states immutability: *"You cannot edit the `source_application`, `type`, `key`,
  `max_allowed_selections`, or `allowed_object_types` of a custom attribute after creation."* (#11049 §1.7).

**Inference, labelled:**
- **Google, Walmart — a flat feed cannot reference.** Both are ingestion formats, not stored catalogues; a
  row is self-describing or it is unusable. Walmart's own record puts it structurally: *"nothing in the 451 MB
  file binds one item's value to another's"* (#11046 §2b). **Inference:** (c) here is a property of the
  transport, not a model choice.
- **Shopee, Tokopedia — a marketplace owns the vocabulary.** Both gate attributes on a leaf category the
  seller does not control (Shopee: *"only last-level categories can retrieve attribute data"*; Tokopedia:
  *"The attributes available for use are determined by the system based on the product's assigned category"*).
  **Inference:** when the platform authors the definition, pinning the level on it costs the seller nothing
  and saves the platform from validating N members.
- **Magento — one table, one value row shape.** With `catalog_product_entity` holding both rows and EAV
  values keyed `(entity_id, attribute_id, store_id)`, a level column would be a second discriminator on a
  schema already discriminated by `type_id` and `store_id`. **Inference:** (c) is the cheapest thing that
  works in an EAV store scoped by website/store view.
- **Salesforce — the fallback exists because one schema type serves both.** With a single `<product>`
  complexType, "which level owns this?" has no schema answer, so it became a read-time rule. **Inference.**

### 4 · Our code today

Full consumer list, `path:line` at the pin, is in **`design-A5.md` §0**. The load-bearing facts:

- The value table is member-only and says so in a constraint: `ProductAttributeValue`
  (`catalogue/models.py:719`) has `product` as a **NOT NULL** FK (`:736`) and
  `Meta.unique_together = ("attribute", "product")` (`:730`).
- The container reads one product: `ProductAttributesContainer.get_values()`
  (`catalogue/product_attributes.py:54-55`) → `self.product.attribute_values.all()`; writes one product:
  `save()` (`:60-64`) → `attribute.save_value(self.product, value)`, whose signature is `(product, value)`
  (`catalogue/models.py:672`).
- **The required-attribute validator is the thing that breaks.** `validate_attributes()`
  (`product_attributes.py:36-52`) loops every attribute of the class and raises *"%(attr)s attribute cannot
  be blank"* when a **required** one has no value **on this product**. It is called from `Product.clean()`
  (`models.py:468-484`, the call at `:484`). `manufacturer` is `required=True`. Move it to family level
  without making the container level-aware and `clean()` fails on all 106,161 rows.
- **The read forks in two places**, not one (⚠️ corrected, red-team finding 12): (i)
  `ProductDetailsSerializer.attribute_values` (`api/apiproduct/serializers.py:207`, prefetched at
  `views.py:60`, sorted by code at `:219-221`); and (ii) `Product.attribute_summary`
  (`catalogue/models.py:521-525`, reading `self.attribute_values.all()`), which is a Django-admin
  `list_display` column at `catalogue/admin.py:37-46` and would **silently drop every family-level value**
  from the admin list if left alone.
- **The write forks in exactly one place** — the two server-side write paths are
  `api/apiproduct/staff_serializers.py:98-128` (`ProductCreateSerializer.create`) and `:132-143`
  (`ProductUpdateSerializer.update`), both inside `transaction.atomic()`, and both go through the same
  `_assign_attributes` (`:65-81`). The fork is a correctness bug if missed: the staff form reads
  `productAddendum.attribute_values` (`ts/libs/product/action/ui-staff-form/.../product-update-staff-form-ui.component.ts:186`)
  and re-posts the same list to the **member's** update endpoint (`:235`).
- **No attribute *value* is indexed or fed**: `py/mono/templates/search/indexes/catalogue/product_text.txt`
  is 3 lines and indexes none; `solvent/search/search_indexes.py:24-75` declares none; the Google feed
  (`third_party_api/google/content/products_api.py:214-224, 230-232, 234-235`) sends 8 attributes and no
  attribute value. Order lines, price, inventory, purchasing, receiving, transport, returns, labels and
  forecast read none either.
- ⚠️ **"Search inherits free" was wrong about the *trigger*** (red-team finding 2). Every reindex in the
  system is `post_save` on **`Product`**: `solvent/catalogue/receivers.py:31-41` →
  `update_products_indexes` + `update_product_dependent_indexes`
  (`solvent/catalogue/index_utils.py:11-16, :19-44`), fanning out to every
  `HasProductDependentSearchIndexModelMixin` subclass (`solvent/catalogue/models_mixins.py:6-31`; at the pin
  `inventory/models.py:19`, `inventory/models.py:121`, `price/purchase/models.py:36`). Under A5-a a
  **family-level value edit fires no receiver at all**. Harmless today, because no attribute value is
  indexed — but it is the *same* missing trigger C1 needs for `description`, so one receiver serves both
  cards. Full surface in `design-C1.md` §5b.
- **Frontend display inherits free**: the spec table renders a flat
  `productAddendum.attribute_values` list (`ts/libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.html:6-20`,
  `.ts:42-56`, hiding only `internalname`). Because the card's rule makes family and member values
  **disjoint**, a merged list is just a longer list of the same shape — no precedence logic reaches the UI.

| Option | Changes | Inherits free |
|---|---|---|
| **A5-a** | `ProductAttribute.level`; `ProductAttributeValue.product` nullable + `variant_group_id` + `CHECK … NOT VALID` then `VALIDATE`; two partial uniques; `validate_attributes()` level-aware **plus a new family-side validator** (nothing calls a family `clean()` today); a family writer; **two** read merges — the detail serializer and `attribute_summary`; the staff form splits the write; **a family-row reindex receiver** shared with C1 | the Google feed, all 20 `Product` relations, the whole read-side frontend (30 `product.title`/`product.slug` occurrences in 22 `ts/` files all consume one API field) |
| **A5-b** | all of the above **plus** a `(group, attribute, level)` through table and a level lookup on every read | the same |
| **A5-c** | nothing | everything |
| — | — | ⚠️ the "search" column of this table was *"inherits free"* in revision 1; it now reads "the Google feed" only, because the reindex trigger does not inherit (finding 2) |
| **A5-d** | all of A5-a **plus** precedence logic everywhere a value is read, because the lists are no longer disjoint | search, feed |

### 5 · Our numbers

`../../sql/results/baseline.json`, 2026-09-19:

| Measure | Value |
|---|---|
| `ProductAttribute` rows | **5** — `manufacturer:text:req · weight:float:req · length:float:req · width:float:req · height:float:req` |
| `ProductAttributeValue` rows | **471,143** — four dimensions 106,161 each, `manufacturer` **46,499** |
| products with no `manufacturer` row | 59,662 |
| **Post-lock-condition-2** (the four dimensions become columns) | **1 definition, 46,499 rows** |

`sql/fam-c1-sibling-consistency.sql`, over 10,090 proxy families (≥2 products sharing a three-word title
prefix inside one `main_category`):

| Measure | Families | Share |
|---|---|---|
| all members share one `manufacturer` value | 3,550 | 35.2% |
| members **disagree** on `manufacturer` | **1,908** | **18.9%** |
| at least one member has **no** `manufacturer` row | 4,731 | 46.9% |
| **no** member has one | 3,717 | 36.8% |

The worked case: all 43 Indomie rows carry a `manufacturer` value, and it is **one** manufacturer under
**nine** raw spellings — **eight** case-insensitively, **seven** after also collapsing internal whitespace
(`sql/fam-a5-indomie-manufacturer.sql`, 2026-09-19; ⚠️ revision 1 printed "seven" from a **hand count** with
no query — that figure was the whitespace-collapsed, case-folded one, and it undercounted the drift it was
there to demonstrate):

| count | value |
|---|---|
| 31 | `PT. INDOFOOD CBP SUKSES MAKMUR TBK` |
| 3 | `PT. INDOFOOD CBP SUKSES MAKMUR` |
| 2 | `PT INDOFOOD CBP SUKSES MAKMUR TBK` |
| 2 | `PT. INDOFOOD CBP SUKSES MAKMUR Tbk` ← **case-only** variant of the first |
| 1 | `PT. INDOFOOD CBP SUKSES MAKMUR Tbk.` ← **case-only** variant (plus a trailing dot) |
| 1 | `PT. INDOFOOD CBP SUKSES MAKMKUR TBK` |
| 1 | `PT. INDOFFOD CBP SUKSES MAKMUR TBK` |
| 1 | `PT. INDOFOOD CBP MAKMUR TBK.` |
| 1 | `PT. INDOFOOD CBP  SUKSES MAKMUR TBK` (double space) |

The two case-only rows are precisely the drift the baseline's own `distinct raw 5,580 / distinct trim+lower
5,541` split exists to measure.

**As-measured vs post-condition-2.** As measured, A5 governs 471,143 rows across 5 definitions. After
condition 2 it governs **46,499 rows across one definition** — and that one definition is the single most
likely candidate for family level, because it is the one whose value is a fact about the brand owner rather
than about the pack.

### 6 · Cleanest / structurally correct for us

Full sketches in **`design-A5.md`**. The problems each option causes:

**A5-a (pinned on the definition).** One real hazard and one real cost.
- *Hazard*: `validate_attributes()` must learn the level **in the same commit that moves the first
  definition** — not in the commit that adds the column. With `level` defaulting to `'member'` nothing
  changes, which is why §7's day-one-no-op claim holds. And the fix has **two** halves, not one: skip
  family-level definitions in the member's loop, **and validate them on the group instead** — and there is
  no family model, nothing calls a family `clean()` and no family write path exists, so the second half is
  new work, not a condition.
- *Cost*: the staff form's read/write asymmetry. If the read merges family values and the write does not
  split them, a staff edit writes a family value onto a member — and the new partial unique index will not
  catch it, because a member row is a legal row.
- *Payoff*: `SameForAll` never needs enforcing. commercetools implements it as an error type
  (`DuplicateAttributeValuesError` — *"The set of attributes must be unique across all variants."*) precisely
  because its own product-level slot cannot carry the constraint; under A5-a "the attribute is on the family"
  **is** the constraint.
- *Day-one cost*: **zero**. `level` defaults to `'member'`, `variant_group_id` stays NULL on all 471,143
  rows, and the tentative decision holds untouched.

**A5-b (per family).** Two structural problems.
- Lock 2 creates 106,161 groups on day one, so a per-family distribution is either 106,161 distributions or a
  default — and the default **is** A5-a under another name.
- **Akeneo's distribution does not live on the family.** It lives on `FamilyVariant`, a reusable structure
  (*"You can create one or more family variants in each family."*). Our analogue of `FamilyVariant` after
  Lock 1 is the **Category**, not the group. So the faithful port of Akeneo is a level column on the
  `(category, attribute)` row that Lock 1 already creates — which is A5-a. **A5-b as the card words it has no
  precedent at the family level in the thirteen.**

**A5-c (always on the member).** It is today, and today's drift is measured: 18.9% of proxy families disagree
on `manufacturer`. The three precedents replicate because they have **no container**; doing it under a
container is the one combination none of the thirteen runs.

**A5-d (fallback).** It is the option our images decision already took, and it is the option the card's rule
forbids. Naming the conflict: *"if an attribute is on the product, its variants do not store it"* and
*"member's images if it has any, otherwise the family's"* are different rules. **Judgement:** keep them
different on purpose. Images are a *presentation* fact with a natural most-specific-match semantics
(Salesforce: *"the system chooses the most specific matching image groups possible"*); an attribute value is a
*data* fact whose second copy is a second truth. The cost of unifying them would be precedence logic in every
reader, for no case our data shows.

### 7 · Recommendation

> **Judgement.** Take **A5-a — the level is pinned on the definition** — implemented as a `level` column on
> `ProductAttribute` (family | member, default `member`) and a nullable `variant_group_id` beside
> `ProductAttributeValue.product` with a `CHECK (num_nonnulls(product_id, variant_group_id) = 1)` and two
> partial unique indexes. Do **not** implement `SameForAll`; family level is it. Do **not** implement A5-d
> for attribute values; keep the fallback for images only, and say on the record that the two rules differ
> deliberately.

**Confidence: moderate-high** — and the rationale is **rewritten after red-team round 1 (finding 7)**.
~~"The option has the plurality (6 of 13)."~~ It does not: applying this brief's own discounting move
consistently, only **4 of 13** put the level on a definition (Shopify, Square, Tokopedia Era B,
commercetools), level-pegged with (c)'s 4. The confidence now rests on the two reasons that survive:
1. **Shape match.** commercetools is the only platform whose structure is ours — a separate container table,
   a level declared on the definition, the container not sellable — and it is the documented shape we would
   be copying (its record's U1 records that no live instance was retrieved).
2. **Zero day-one cost.** Nothing moves: `level` defaults to `'member'`, `variant_group_id` is NULL on all
   471,143 rows, and the 2026-09-15 tentative decision survives unchanged. No other option is free.

**What would reopen it.**
1. **ATTR-DEF's A1 admits per-family variation as a first-class need.** If A1's rule produces attributes
   whose level genuinely differs family by family within one category, A5-b becomes necessary and A5-a
   becomes a lie told by a default.
2. **The staff editor cannot express two levels.** Lock condition 1 makes the schema editor the critical
   path; if the level doubles its complexity in practice, A5-c is the honest retreat and the cost is the
   measured 18.9% drift.
3. **A measured need for member-overrides-family on a data attribute.** Today there is none; if one appears,
   A5-d is the answer and the card's rule has to be rewritten, not patched.

**What it forces in steps 1–5.** Step 1 (the registry): the `(category, attribute)` row gains a third
column beside `required` — `level` — so the schema editor (lock condition 1) must show it, and D17's
requiredness question becomes "required **at which level**". Step 2 (the value): the storage question gains
one clause — whichever of rows-vs-JSONB wins, the owner column is two nullable FKs with a check, not one FK;
a JSONB document per product would need a second document per group. Step 3 (the axis): unchanged — an axis
is member-level by definition, so `level='family'` and `is_axis_eligible` are mutually exclusive, which is a
one-line validator and a free D4 refinement. Step 4 (the group row): D11 is **answered** — partition by
level, each fact stored once, which is the option the page already calls the likely default; D10's field-by-
field list gains the rule "a non-axis attribute moves up only by changing its definition's level, never
per-product"; **and the family-row reindex receiver this card's §4 option table lists is the one C1 §7
specifies — shared, not duplicated** (⚠️ added after red-team round 2, finding 4: A5's table declared the
work item and A5's own handoff paragraph did not mention it). Step 5: nothing.

**A0 ↔ A5, cited not decided.** ATTR-DEF owns visibility per channel (A0). A5 adds `level` beside whatever A0
lands on the same definition row; the two are independent — a family-level attribute can be staff-only and a
member-level one customer-facing. **A4 ↔ A5, cited not decided.** ATTR-VALUE owns the value shape; A5 owns
only which column carries the owner. If A4 makes a value a shared option row, the family-level value is a
second FK from the same row set and this design is unchanged.

### 8 · Limits and corrections

- **The card's own framing of Shopify is wrong and this brief corrects it.** *"Shopify metafields exist on
  both Product and ProductVariant"* is true of the *surface*, but `MetafieldDefinition.ownerType` is a single
  non-null enum value: **each definition is pinned to exactly one owner type**. Shopify is an instance of
  A5-a, not of A5-b.
- **eBay is not assigned an option.** Reason in §2. What would settle it: an artifact stating whether an
  aspect with `aspectApplicableTo: PRODUCT` must be written on `InventoryItemGroup.aspects` rather than on
  `InventoryItem.product.aspects`. #11045's sandbox application token cannot reach the Inventory API
  (403 `1100`); a **user** token would (its H4).
- **Tokopedia Era A was not read for this card.** The two eras are never merged; only Era B's
  `SALES_PROPERTY` / `PRODUCT_PROPERTY` split is used here.
- **Not collected: whether any platform lets a *value* exist at both levels at once for the same
  definition.** Square's `allowed_object_types` array permits `["ITEM","ITEM_VARIATION"]`, which suggests it
  can, but no retrieved artifact states what happens when both carry a value. Route: a Square sandbox write
  setting the same custom-attribute key on an `ITEM` and its `ITEM_VARIATION`, then a read-back.
- **The `level`-immutability question is new work nobody has filed.** commercetools makes it immutable;
  we would have to choose. It belongs to the page's step-5 "what happens to existing products when a schema
  changes" consideration, and this is a concrete instance of it.

**Corrections after red-team round 1** (one line per finding; nothing deleted silently — the struck text is
shown beside the correction):

- **2** — ~~"Inherits free under every option — search…"~~ → §4 now carries the reindex surface:
  `catalogue/receivers.py:31-41`, `catalogue/index_utils.py:11-16, :19-44`, `catalogue/models_mixins.py:6-31`
  with its three subclasses. A family-level value edit fires **no** receiver. Full surface added to
  `design-C1.md` §5b; `design-A5.md` §0's "not readers" block rewritten.
- **3** — ~~"Google … has no family object at all — only a shared `item_group_id`"~~ → the record's sentence
  restored verbatim with the *"on the write side"* scope and `item_group_title` intact (`11031.md:1263`);
  the "no family content row" reading narrowed and the unqualified version withdrawn.
- **6** — ~~"the record does not state the remainder"~~ → the record states it: *"present on 106,766 of
  197,046"* (`11045.md:116`). Clause replaced; `11045.md` U12-c ("one artifact read once") added.
- **7** — the tally is split into **a1 declared (4)** vs **a2 structural (2)**; A5-a loses its plurality and
  §7's confidence rationale is rewritten to rest on the shape match and the zero day-one cost instead.
- **8** — the tally now prints **d as the primary model = 1** and **d as a mechanism beside another = 3**,
  naming Salesforce, WooCommerce and Shopee; §1 and §2 no longer disagree.
- **10** — ~~"seven spellings"~~ (a hand count) → **nine raw / eight case-insensitive / seven
  whitespace-collapsed**, printed whole, with the two case-only variants marked and a new instrument,
  `sql/fam-a5-indomie-manufacturer.sql`.
- **12** — ~~"The read forks in exactly one place"~~ → **two**: the detail serializer **and**
  `Product.attribute_summary` (`catalogue/models.py:521-525`) behind `catalogue/admin.py:37-46`.
- **14** — Amazon's *"all 7"* worked families carry the record's retraction: *"The seven flat-file `Example`
  sheets are one artifact, not seven"* (`10976.md:418`) — two independent observations, not seven.
- **17** — commercetools and Akeneo re-labelled *"the canonical **documented** shape"*, each carrying its
  record's no-live-instance hedge (`11081.md:913` U1 · `11050.md:606` U9 for the Salesforce row in C1).
- **23** — the Shopee inheritance quote was `#11031`'s paraphrase cited to `#11047 §1.9`; replaced with
  `11047.md:423` verbatim plus the vendor text at `:427-429`, **including** the conditional revision 1 dropped
  (*"If set the dimension of this model, them must set the weight of this model."*), re-cited to `#11047 §1.5`.
- **34** — the search template path is `py/mono/templates/…`, not `templates/…`; corrected here and in
  `design-A5.md`.
- **36** — both server-side write paths named: `staff_serializers.py:98-128` (create) and `:132-143` (update).
- **37** — ~~"must learn the level in the same commit that adds it"~~ → *"in the same commit that **moves the
  first definition**"*; the day-one-no-op claim in §7 is the accurate one and stands.
- **38** — the migration sketch in `design-A5.md` now adds the `CHECK` as `NOT VALID` + `VALIDATE CONSTRAINT`
  rather than taking `ACCESS EXCLUSIVE` over 471,143 rows.
- **39** — §6 now carries both halves of the validator fix, and says plainly that the family-side half is new
  work because no family model or family write path exists.
- **42** — `product-addendum-attributes-ui.component.ts` `hiddenAttributes` is at **`:34`**, not `:32`.
- **45** — the frontend sweep is instrumented: **30 `product.title`/`product.slug` occurrences in 22 files**
  (`.spec.ts`/`.stories.ts` excluded), all consuming one API field.

**Corrections after red-team round 2:**

- **1 (§2 lead)** — ~~"Split, not unanimous — 6 / 1 / 4 / 1, one named ambiguous. The plurality pins the
  level on the definition."~~ Both halves were retracted thirteen lines below their own lead. The lead now
  states the corrected split first, as BRIEF §4 requires, and says outright that **no option has a plurality
  once "pinned" is split by mechanism**.
- **3 (snapshot bound)** — all three A5 queries (`fam-a5-indomie-manufacturer.sql` and the two the card
  cites) now carry
  `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside
  every `ROW_NUMBER()` subquery, per the amended BRIEF §3.4. **Every A5 figure is unchanged** — the bounded
  results are byte-identical to the published ones.
- **4** — §7's "what it forces in steps 1–5" now carries the **family-row reindex receiver** that §4's
  option table declares, and states it is **shared with C1 §7, not duplicated**.
- **5** — `search_indexes_mixins.py` product-FK variant is `:40-41`, not `:39-40` (`:39` is blank).
- **6** — `ProductUpdateSerializer.update` is `staff_serializers.py:132-143`, not `:132-144` (`:144` is
  blank). The companion `:98-128` for `create` was already exact.

---

## C1 · What may two siblings differ in, and what must they share?

Under Lock 2 every product has a group, so this defines "sibling" for **106,161** rows and is the rule the
merge and split screens enforce.

### 1 · Options

- **C1-i — strict, policed.** Siblings differ only in their axis values plus price, stock and barcode.
  Title, description, category and brand are identical on every member, and the platform refuses a family
  whose members disagree.
- **C1-ii — family-owned.** The question does not arise for title, description, category and brand because
  the member **has no such field**. Siblings differ in axis values, price, stock, barcode, and — depending
  on the platform — a short label and images.
- **C1-iii — free.** Siblings may differ in title, description and images as well; nothing constrains them.

Sub-questions, each answered separately: **must they share the category?** · **must they share the brand?**
· **can one product be in two families?** · **barcode identity.**

### 2 · Who uses which, who does not

**Split 3 / 5 / 2 with three named ambiguous — but the split is architectural, not substantive.** C1-i and
C1-ii are the same answer expressed in two architectures: the flat-feed platforms replicate-and-police, the
container platforms store once. **Eight of thirteen hold that siblings must not differ in title, description
or category.** Only Magento and WooCommerce permit it, and both are platforms whose container is itself an
ordinary row (Magento) or a WordPress post (WooCommerce).

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | *"Required attributes that must be identical across a family. Terms like "item type keyword," "model name," "style," and "brand" are key non-varying attributes for which all child ASINs must have the same values. Child ASINs with different non-varying attribute values cannot be grouped into a single variation family."* Measured: parent and all three children byte-identical on `title` stem, `description`, `bullet-point1`, all five `search-terms`, `item-type`, `target-audience`, `main-image-url`, `warnings`. ⚠️ **That measurement is on a family the record declares defective**: *"**Both of Amazon's flavour examples are internally defective** … The `flavor`-theme family (Clif Bar) leaves the **`flavor` column empty on all four rows** *and* **`parent-sku` empty on all three children**"* (`10976.md:412`), and *"**No clean Amazon-authored *flavour* family exists in any artifact retrieved.**"* The same paragraph says *"Amazon's four `Size`/`Color` families in `Flat.File.Home.xls` **are** clean"*. **The `[E-25]` rule alone carries the row**; the byte-identity measurement is corroboration from a defective sample | #10976 §2 `[E-25]`; the measurement `[E-12]` with `10976.md:412` | **i** |
| **Shopify** | the variant has **no description field at all**; product-only alongside it: `title`, `handle`, `category`, `vendor`, `productType`, `tags`, `media`, `seo`, `status`, `options`, `collections`. The variant keeps `title`, `media`, `selectedOptions`, `price`, `sku`, `barcode` | #11011 §2b; #11031 field survey §B | **ii** |
| **Google** | *"All variants of the same product must have the same item group title `[item_group_title]`."* and *"Make sure the item group title `[item_group_title]` is different from the title `[title]` attributes you use for the individual variants in the product group."* ❗ But: *"**Not stated anywhere retrieved**: whether `description`, `brand`, `gtin` or `google_product_category` must be identical across a group"*, and a live probe of divergent `brand` under one group produced **0 `itemLevelIssues`**. ⚠️ **That control does not discriminate**: `11013.md:925` records that **no product in the entire pass carried any `itemLevelIssues`**, so a silent diagnostic channel and "divergence is allowed" are indistinguishable. The row rests on U9's "not stated", not on the probe | #11013 §2 `[R-9]`, §4 U9 | **ambiguous** — i for title-level facts, unstated for the rest |
| **eBay** | group: *"the title and description values will become the listing title and listing description of the live, multiple-variation eBay listing"*; members: *"the product.title and product.description values … must have the same values"*. ⚠️ **Neither string is in `11045.md`** (0 hits); both are at `11031.md:1192`, whose stated route is *"Inventory guide (Wayback capture of the vendor page) + #11045 §1.4"* — `developer.ebay.com` returns 403 to every direct route. `11045.md` §1.4 itself shows the group's `title`/`description` as **0..1, optional** and states no member-match rule | #11031 §B (`:1192`, Wayback capture) + #11045 §1.4 for the group's field list | **i** (and ii simultaneously — the group owns them *and* the member's copy is policed), **on the Wayback route only** |
| **Walmart** | hard rules: *"All items in a variant group must: Share the same `variantGroupId` · Use the same `variantAttributeNames` · Provide values for the same variant attributes across all items in the group · Represent a unique combination of variant attribute values · Contain exactly one primary variant within the group"*. Content rule, under a **Best practices** heading: *"Keep product content consistent across all variants except for the attributes that vary."* ⚠️ `11046.md` **U26 / §5 #27** disputes two of those five bullets: re-fetched 2026-09-05 they *"return 0 hits on the page they are attributed to"*, the record strikes them, and *"Which side moved is not decidable"*. The five-bullet list above **is** what the page served on 2026-09-19 (`corpus/walmart/wm-multiple-variants.txt`), so the currently-served text is used — but the record disputes it. And U13's status is stronger than "best practice": *"no vendor page states a rule for any field other than `variantGroupId` and the axis names"* | `corpus/walmart/wm-multiple-variants.txt` (P0, 2026-09-19); #11046 §2b, §4 U13, §5 #27 | **i**, with the content half a best practice and two of the five "must" bullets contested |
| **Shopee** | `description` is one of the item's 32 declared `item_list` children; a model carries `model_sku`, `tier_index`, price, stock and one image. ⚠️ That 32-child list is the subject of `11047.md` **contradiction 18, "A schema that contradicts its own sample"** — `batch_add_item` declares 112 request field paths with `item_list` carrying exactly 32 children, *"neither `tier_variation` nor `model_list` among them"*, while *"Its only request sample (2,179 B) posts **both**, with `tier_index` on each model"* | #11047 §1.x, §2c `[R-15][R-16]`, §5 #18 | **ii** |
| **Tokopedia Era B** | `description` is a depth-0 product field; `skus[]` carry sales attributes, price, inventory, identifier and a SKU image. Product level also: `title`, `main_images`, `category_id`, `brand_id`, `product_attributes`, `package_dimensions`, `certifications`, `size_chart` | #11048 §1.x `[R-1]` | **ii** |
| **Square** | `CatalogItem.description_html` — *"The item's description as expressed in valid HTML elements."*; `CatalogItemVariation` has 23 property anchors and `description` → **0 hits**. The variation keeps `name`, `sku`, `upc`, `price_money`, its own `image_ids`. ⚠️ `#11031 §B` marks this row **single-route** (*"`CatalogItemVariation` reference (417,847 B; 23 property anchors, `description` → 0 hits) — single route"*) | **#11031 §B (`11031.md:1197`)**; `#11049 §1.x` for the object's own field list | **ii**, hedged: images are free-form and independent on both levels |
| **Salesforce B2C** | *"If the variant does not define an own value, the value is retrieved by fallback from variation groups (sorted by their position) or the variation master."* — `name` and `description` are inheritable **and overridable**. ⚠️ `11050.md:606` **U9**: *"**No retrieved instance data exists in this record at all**"* — no populated `VariationGroup`, no `<variation-attribute>` element | #11050 §2b `[R-4][R-5]`, §4 U9 | **ambiguous** — ii by default, iii by override |
| **Magento** | every product row has `description` and `short_description`; `ConfigurableVariant` exposes exactly `attributes` and `product`. ❗ *"Whether a child's description ever renders on a configurable page is **not stated**: a case-insensitive search of Adobe's configurable-product page (16,126 B, **updated 2026-06-15**) for `description` returns **0**"* — the date is part of the record's sentence and revision 1 dropped it | **#11031 §B (`11031.md:1199`)**; `#11082` for the schema half | **iii** |
| **WooCommerce** | variation property table: `description \| string \| Variation description.` The core template renders `<div class="woocommerce-variation-description">…</div>` and swaps it after the shopper selects attributes. Parent-only: `name`, `slug`, `type`, `categories`, `tags`, `brands`, `images`, `attributes` | **#11031 §B (`11031.md:1200`)** — two routes there (REST API docs + `templates/single-product/add-to-cart/variation.php` in the vendor repo); `#11080 §2b` for the postmeta shape | **iii** for description/sku/gtin; parent-only for name/category/images |
| **commercetools** | `ProductData.description` — *"Description of the Product."* Classic `ProductVariant` has 13 properties, **none a description**; Modular `VariantData` is `sku?, images?, attributes?, assets?`. ❗ The clause revision 1 dropped: *"The Modular `VariantProjection.description?` is 'Description of the parent Product' — a read-only beta projection, not a variant field"* | **#11031 §B (`11031.md:1201`)** — the string is **not** in `11081.md` (0 hits); `#11081 §1.x` independently enumerates the 13 variant properties | **ii** |
| **Akeneo** | default is the product model — *"the common attributes are the name, the collection, the description, the brand, etc."* — but *"if you move the Description attribute from the common attributes to the variant attributes level 1, the description previously filled in will be kept for all variant products, but you can change it"* | **#11031 §B (`11031.md:1202`)** — neither string is in `11069.md` (0 hits); its stated route is `help.akeneo.com` + `api.akeneo.com`, *"one vendor doc family"* | **ambiguous** — configurable by level |

**Fourteenth row, outside the thirteen — Meta** (new collection, `corpus/meta/`, card pointer):
*"Make sure the `item_group_id` has the same value across all sizes and colors, and that images and external
links match the color of the item."* · the **Correct** worked example, whole: *"The name of the product and
the `item_group_id` fields match (so that the name does not change when variants are selected, but images
do)."* · the **Incorrect** example is a parent row with no `color`: *"Because each line item in the field
spec needs to be its own product, this is an incorrect way of setting up products."*
(`corpus/meta/fb-variants-dev.txt`, P0, 2026-09-19). Its own 6-row CSV sample carries **byte-identical**
`title`, `description`, `rich_text_description`, `link`, `image_link`, `brand`, `google_product_category`,
`product_type` and `price`, differing only in `id`, `color` and `size`
(`corpus/meta/fb-catalog-fields.txt:587-593`). **Maps to i.** ⚠️ **Two contradictions, recorded not
resolved.** (1) *Meta vs Google*: Meta's sample gives all six rows the *same* `link`, while Google says
*"Make sure to have different landing page URLs submitted for each variant, with each URL using a different
path segment and/or query parameters, for example "/t-shirt/green" or "/t-shirt?color=green&size=small" or
"/t-shirt?preselect=8901491""* (**#11031 §C** — the string is **not** in `11013.md`). ⚠️ Google also
describes the opposite arrangement: *"**Align grouping with your landing page experience**: If your website
allows customers to select between multiple variants on a single landing page … make sure all those versions
are submitted with the same item group ID `[item_group_id]`."* (`11013.md:379`), so "Google requires" is too
strong and the tension with Meta is narrower than revision 1 framed it (`sources-new.md` O-3). (2) ⚠️ **Meta vs Meta** (added after red-team round 1, finding 28): the same six rows also carry
**identical `image_link` and `additional_image_link`** — directly against the rule on the page the brief
quotes from, *"images and external links match the color of the item"* and *"the name does not change when
variants are selected, **but images do**"*. **Meta's worked sample contradicts Meta's worked rule**, which is
the sharpest available evidence for the general point that a vendor sample is not a specification.

**Sub-tally — can one product be in two families? Near-unanimous: 12 no, 1 yes.**
Stated outright: Walmart *"An item can belong to only one variant group."* (`corpus/walmart/…`) · Amazon
*"Child products are unique, sellable products that are related in our catalog to **a single**, non-sellable
parent product"*, plus *"You must remove a child listing from its current parent-child relationship before
you relate it to a new parent"* and feed error **8032** (#10976 §1.8) · Salesforce *"While you assign a
variation group to only one base product, you assign multiple variation groups to that base product."*
(#11050 §1.2) · commercetools `Variant --1..1--> Product` (#11081 §1.7) · WooCommerce `post_parent`, *a
non-`product` parent is reset to 0* (#11080 §2b) · Akeneo `Product.parent` **0..1** (#11069) · Google,
Shopee, Tokopedia, Square, Shopify, eBay by the shape of the key.
**The one counterfactual: Magento.** `catalog_product_super_link` has both FKs on
`catalog_product_entity.entity_id` with `UNIQUE (product_id, parent_id)`, and the record's own table cell reads
`child → parent | same table | **0..N** (unique is on the *pair*)` (`11082.md:246`, §1.5). ⚠️ Revision 1
printed a paraphrase of that cell **inside quotation marks**; the cell is what the record says.

### 3 · Why each platform chose it

**Stated:**
- **Amazon** names the consequence directly — a family whose non-varying attributes disagree *"cannot be
  grouped"*. The rule exists at admission time because Amazon's family has no content row of its own to put
  the shared facts in.
- **Google** names its purpose for the group title: *"Use a relevant title that clearly describes your
  product group."* and makes it non-equal to the member title. **The reason it gives for grouping at all**
  is discovery: *"Submitting unique GTINs for each variant and adding the item group ID `[item_group_id]`
  attribute ensures that the product and its variants are shown to customers as a group rather than
  separately."* (#11013 §2 `[F-50]`).
- **Walmart** states the customer-facing reason: *"Variant groups allow sellers to display multiple versions
  of the same product on a single Walmart item page."* and *"Grouping related items into a variant group
  improves product discovery and allows customers to compare available options without navigating between
  multiple item pages."* (`corpus/walmart/wm-multiple-variants.txt`).
- **WooCommerce** states why its variation keeps a description: the storefront *"swaps the product gallery
  to that variation's images"* and the core template renders a per-variation description block — i.e. the
  shopper is expected to see different prose per selection.
- **Meta** states the display reason for name-identity in the same clause as the rule: *"so that the name
  does not change when variants are selected, but images do"*.

**Inference, labelled:**
- **The ii cluster (Shopify, Shopee, Tokopedia, Square, commercetools) did not "choose" a sibling rule at
  all.** They removed the field from the member, which makes divergence unrepresentable. **Inference:** the
  cheapest enforcement is an absent column, and every one of these five has a real container to put the
  field on instead.
- **The i cluster (Amazon, eBay, Walmart, Google, Meta) polices because it cannot store.** Four of the five
  are ingestion formats where every row must stand alone. **Inference:** replication + admission control is
  what you build when there is no container row, and the "must be identical" rules are the container,
  expressed as a validator.
- **Magento and WooCommerce permit divergence because their container is a product/post row that already had
  those columns.** Neither added a description to the child; neither removed it either. **Inference:** this
  is inherited schema, not a decision.

### 4 · Our code today

Full map in **`design-C1.md`**. The load-bearing facts at the pin:

- **Twenty relations point at `Product`** (regex over `models.ForeignKey|OneToOneField|ManyToManyField`
  targeting `Product`, migrations and tests excluded): `analytics:20,55 · basket:1164 ·
  catalogue:344,736,788,890,898 · catalogue/models_mixins:29 · forecast:26 ·
  inventory/reconciliation:147 · order:550 · price/purchase:66 · price/sell:31,187 ·
  printer/label/models/printer_label_product:81 · purchasing/models/purchasing:280 ·
  receiving/models/receiving:254 · return_to_supplier:201 · transport/models/models:198`. `InventoryRecord`
  and `InventoryFacility` reach `Product` through the mixin at `catalogue/models_mixins.py:29`, not by their
  own declaration — which is why a grep of `inventory/models.py` finds none. (The field-survey page says
  "19"; the difference is which of these you count.)
- **Barcode:** `Product.upc = models.CharField(max_length=64, validators=[validate_product_upc], unique=True)`
  (`catalogue/models.py:385-389`), non-null. **Duplicates are zero by construction.**
- **The customer URL is already member-keyed**: `shop/product/%(product_id)s/%(product_slug)s`
  (`shared/url_build/solui.py:20`), route `:productId/:slug`
  (`ts/libs/product/feature-shell/src/lib/product-feature-shell-routing.module.ts:17-21`), links built at
  `ts/libs/product/ui-link/src/lib/product-link-ui/product-link-ui.directive.ts:39`. The feed sends that same
  string (`products_api.py:218-221`).
- **The order line already snapshots the title**: `order/models.py:556`, on a `SET_NULL` product FK
  (`:550-555`; the comment is at `:548-549` — *"We don't want any hard links between orders and the products
  table so we allow this link to be NULLable."*).
- ~~**The title is indexed four times raw.**~~ ⚠️ **Corrected (red-team finding 1).** The title reaches
  the index in **nine** places, and the largest of them is a **Django template** that no `prepare_*` method
  can touch: `py/mono/templates/search/indexes/catalogue/product_lite.txt:1` —
  `{{ product.title }} {{ product.title_staff|default:"" }} {{ product.upc|default:"" }}` — which
  `{% include %}`s into **seven** index templates (`catalogue/product_text.txt:1`,
  `price_purchase/pricepurchaserecord_text.txt:2`, `price_purchase/pricepurchase_text.txt:1`,
  `inventory/inventoryfacility_text.txt:1`, `inventory/inventoryrecord_text.txt:1`,
  `forecast/forecastproduct_text.txt:1`, `price_sell/pricesell_text.txt:1`). Plus
  `solvent/search/search_indexes.py:34, 38, 54, 55` (four `model_attr="title"`) **and** `:93-96`
  (`prepare_autocomplete_staff`, not a `model_attr`, so a `model_attr` grep misses it) **and** a second
  haystack index in another app, `solvent/price/purchase/search_indexes.py:61, :75-77`. Full table in
  `design-C1.md` §5.
- **The description is indexed once**: `py/mono/templates/search/indexes/catalogue/product_text.txt:3` —
  `{{ object.description|default:""|striptags }}`. If the description moves to the family, this line must
  follow it or every member document silently loses its body text.
- ⚠️ **And nothing reindexes anything when a family row changes** (red-team finding 2 — revision 1 claimed
  the search template was *"the one nobody has named yet"*, which was wrong; **this** is).
  `solvent/catalogue/receivers.py:31-41` is a `post_save` receiver on **`Product`** →
  `update_products_indexes(products=[instance])` + `update_product_dependent_indexes(product_id=instance.id)`
  (`solvent/catalogue/index_utils.py:11-16, :19-44`), which walks the model registry for every
  `HasProductDependentSearchIndexModelMixin` subclass (`solvent/catalogue/models_mixins.py:6-31`; at the pin
  `inventory/models.py:19`, `inventory/models.py:121`, `price/purchase/models.py:36`). Its own docstring:
  *"Those documents are only rewritten when their own row is saved — and no periodic rebuild is scheduled —
  so a product edit would otherwise leave them stale indefinitely."* Move `description`, `title` and
  `main_category` onto the family and **editing the family reindexes nothing** — not the member's document,
  not the three dependent types, not the Google Merchant queue. Two neighbours are in the same position:
  `solvent/catalogue/receivers.py:44-67` (`ProductImage` post_save/post_delete, *"Only `display_order` 0 is
  published"*) has no family-image equivalent, and
  `solvent/catalogue/search_indexes_mixins.py:22-29` / `:40-41` (`prepare_category` →
  `main_category.get_ancestors_and_self()`, used by four index files) would have to resolve the category
  through the family.
- **Two fields C1 assigns a concern to but revision 1 never named** (red-team finding 40):
  `Product.slug` (`catalogue/models.py:405-408`, `AutoSlugField(populate_from="title", unique=True)`, and
  recomputed at `:488` — §7 assigns the slug to the family while both derivation points read the member's
  title) and `Product.thumbnail_url_cache` (`:434`, the denormalised primary-image URL that the
  member-first/family-fallback image rule has to keep fresh, refreshed today only through
  `catalogue/receivers.py:44-67` on `ProductImage` writes).
- **There is no brand field** anywhere in the catalogue.

**Per option, what changes:** C1-i needs cross-row validators on **every** write — both server-side paths,
`api/apiproduct/staff_serializers.py:98-128` (`create`) and `:132-143` (`update`), each inside
`transaction.atomic()`. C1-ii needs the fields moved to the group, the readers re-pointed (the list in
`design-C1.md` §7), the nine title consumers re-pointed through a single `get_display_title()` on the model
(§5 of that file), **and a new family-row reindex receiver** — which is the item revision 1 missed while
claiming to have found the one nobody had named. C1-iii needs nothing and keeps the drift.

### 5 · Our numbers

**Category.** Of the 11,411 three-word title prefixes carried by ≥2 products, **2,945 (25.8%) span more than
one `main_category`, covering 11,323 products** (`sql/fam-c1-sibling-consistency.sql`). A merge screen keyed
on name similarity will therefore offer cross-category merges about a quarter of the time. **Judgement: the
category rule earns a database constraint**, and `design-C1.md` §2 gives it as a composite FK on the pair —
the same trick lock condition 4 already buys for the dimension count.

**Brand.** Unenforceable: 36.8% of proxy families have no `manufacturer` at all, 18.9% disagree, 35.2% agree
(§A5 §5). **This confirms #10778 M9** and re-expresses it: advisory until A1/A2 give us a real brand
attribute, at which point it becomes enforced *by storage* under A5-a rather than by comparison.

**Description — the evidence-settled answer and our data disagree.** `sql/fam-c1-sibling-consistency.sql`:
**3,912 proxy families (38.8%) have a different description on every member**; 5,998 "share one string", but
**5,997 of those are families where every description is empty** — so essentially **one** family in the
catalogue has a genuinely shared, non-empty description. On the Indomie 43: **41 distinct `MD5(description)`**
(3 empty → 40 distinct bodies), and the description opens with the member's own full title — including its
gram weight — on **36 of 43 by an exact match and 38 of 43 after normalising `&nbsp;` and stripping tags**
(`sql/fam-c1-indomie-content.sql`, which now carries both predicates as columns;
⚠️ revision 1's "38" was a hand count with no query — red-team finding 11). 3 rows have no description and
**2 are genuine misses, both informative**: id **24104** uses the *abbreviated* title
(`INDOMIE PREM COLLECT JAP TORI KARA RAMEN 89 GR` in the body against
`INDOMIE PREMIUM COLLECTION JAP TORI KARA RAMEN 89 GR` in the title), and id **29219**'s body says
**`86 GR`** where its title says **`85 GR`**. The second is direct evidence that today's description is *not*
a reliable composed title — which cuts against reading the description as a title source, and for keeping
the composition explicit.

**Title.** All 43 Indomie titles distinct, all 43 slugs distinct; each title is family name + flavour + grams.
Across the proxy families, **8,935 of 10,090 (88.6%)** have a distinct title on every member. **Today's
`Product.title` is already the composed string.**

**What siblings already differ in** (`sql/fam-c1-divergence.sql`, 10,090 families): `upc` 100% and `slug`
100% (by construction) · `title` all-distinct in 88.6% · `is_active` differs in 1,677 (16.6%) ·
`is_offline_only` in 510 (5.1%) · `is_public` in 30 (0.3%) · images: 6,002 (59.5%) have at least one member
with no image, 5,299 (52.5%) have none at all.

**Two families that should be one.** 2,112 distinct normalised titles are carried by more than one product
(**4,273 products**), every one with its own `upc`; **891 of those title-collisions span more than one
category**. That is the merge screen's real input.

**One product in two families — the data signal.** `ProductCategory` M2M: 20,520 rows, 20,519 distinct
products, **exactly 1 product with more than one category** (`../../sql/results/baseline.json`, re-derived in
`sql/fam-c1-sibling-consistency.sql`). **There is no data signal for it**, and under Lock 2 a `NOT NULL` FK
makes it impossible by construction. Confirm "one family per product"; Magento is the only counterfactual in
the thirteen and it is inherited schema, not a design position.

### 5b · BARCODE IDENTITY — the Sunday measurement

`Product.upc` is `unique=True` and non-null (`catalogue/models.py:385-389`), so **duplicate barcodes are zero
by construction** and "can every member of a family carry its own barcode?" is answered **yes, already**. The
real measure is *provenance* — what the code actually identifies. `sql/fam-c1-barcode-identity.sql`,
2026-09-19:

| Kind | All | Active | **Active online** (site + feed) | Offline-only |
|---|---|---|---|---|
| GS1 checksum-valid | 45,142 | 34,350 | **21,116 (90.6%)** | 14,022 |
| server-generated `987` (no real barcode) | 60,205 | 56,835 | **2,152 (9.2%)** | 57,073 |
| 7-digit weight-embedded | 380 | 372 | 20 | 359 |
| 13-digit `2x` GS1 restricted-circulation | 71 | 66 | 9 | 59 |
| other / checksum-invalid | 363 | 329 | 2 | 361 |

⚠️ **Reconciliation with the baseline.** The baseline reports `987` = 60,238 and GS1-valid = 45,166; this
query gets 60,205 and 45,142 because it requires `LENGTH(upc)=13` for the `987` bucket and buckets the 71
`2x` codes **before** the checksum test. Both are correct about what they count; use this table's definitions
when reading this card.

**What it means, in three lines.**
1. **The 57% headline is an offline-stock artefact.** Server-generated `987` codes are 79.4% of offline-only
   rows but only **9.2% of the 23,299 active-online products**. On the surface where families matter — the
   site, the feed, the picker — **90.6% of members carry a real GS1 GTIN**.
2. **GS1's rule is satisfied where it applies.** GTIN Management Standard §2.1: *"A new jeanswear line
   includes various sizes of a particular style and colour of jeans (30x30, 30x32, 32x30, 32x32, etc.). Each
   style, colour and size variation is considered a unique product and is assigned a unique GTIN."* Our
   members each have their own code; where that code is a `987` it is an internal key, not a GTIN, and the
   GS1 rule is simply vacuous there — it is not violated.
3. **Family barcode provenance is mostly homogeneous.** Of 10,090 proxy families: **5,303 all-GS1**,
   **4,045 all-`987`**, **664 mixed**, 85 containing another kind. The 664 mixed families are the ones where
   a merge would put a real GTIN next to an internal key — worth a flag in the merge screen, not a rule.

**The Indomie family is the clean case**: all 33 active rows carry Indofood GS1 codes beginning `089686`, all
distinct, all checksum-valid (`../../sql/results/indomie.csv`). It is exactly the family the barcode rule
was written for.

**The weight-embedded 380 are the exception worth naming.** A 7-digit weight-embedded code
(`catalogue/upc/types.py:UPC_WEIGHT_EMBEDDED_LENGTH = 7`, third digit forced to `0`, the scale substitutes a
weight digit at scan time) identifies a **product class priced by weight**, not a fixed sellable unit. For
those 380 rows "each member has its own barcode" is true but means something different, and a size axis over
them is meaningless. **Judgement: exclude weight-embedded products from axis eligibility** — 20 of them are
active online, so the blast radius is tiny either way.

### 6 · Cleanest / structurally correct for us

Full sketch in **`design-C1.md`**. The rule this brief proposes, with each clause's true home:

| Clause | Home | Why there |
|---|---|---|
| a member belongs to exactly one family | **DB** — `Product.variant_group_id NOT NULL` | Lock 2 already; 12 of 13 platforms agree |
| every member has its own barcode | **DB** — `upc unique=True`, non-null | already true; GS1 §2.1 |
| siblings share the category | **DB** — composite FK on `(variant_group_id, main_category_id)` if the member keeps the mirror; **by construction** if it does not | 25.8% of name-proxy families straddle categories |
| siblings differ in their axis values, each combination unique | **DB** — lock condition 4's composite-FK mirror | already scoped |
| siblings use the same axis names | **by construction** — the dimension list hangs off the group | free |
| the family owns the description | **schema** — the member loses the column | 11 of 13 treat it as family content; **but see the migration rule below** |
| the family owns the customer-facing title; the member owns a short label | **schema** + a composed read | Google forbids the two strings being equal |
| siblings may differ in price, stock, visibility, images | **no rule** | all four are already per-member; 16.6% differ on `is_active` today |
| siblings should share the brand | **advisory only** | unenforceable on today's data (#10778 M9) |

**The description migration rule, stated so it is not lost.** On Lock 2's day one every family has one
member, so the description moves 1:1 and nothing is lost. The loss only appears at **merge** time — and that
is exactly when a human is looking at both rows. So: **the merge screen presents every losing member's
description and requires a choice; it never silently discards one.** Same rule the lock already states for
images (*"a merge must not delete the losing member's images"*).

### 7 · Recommendation

> **Judgement.** Adopt **C1-ii — family-owned content, member-owned commerce** — expressed as the table in
> §6. Siblings may differ **only** in their axis values, their price, their stock, their barcode, their
> visibility and their images (plus a short variant label). They **must** share the category, enforced in the
> database. They **should** share the brand, advisory only, until a brand attribute exists. **One product,
> one family**, by construction.

**Confidence: high** on category, one-family and barcode (near-unanimous evidence plus a DB constraint that
makes each free). **Moderate** on description-at-the-family — the platform evidence is 11 of 13, but our own
data is 3,912 families with per-member bodies, so the *decision* is right and the *migration* is a merge-time
human choice, not a script. ⚠️ **Lowered from moderate to low-moderate on composing the title** (red-team
finding 1): the recommendation is unchanged, but the reason for confidence was a two-call-site cost estimate
that was wrong by a factor of four, and the honest position is that the *direction* is well-evidenced while
the *cost* is a nine-site change across four apps touching a shared Django template. **Moderate**, newly
stated, on C1-ii as a whole shipping without a family-row reindex receiver — it cannot (finding 2).

**Title: composed, not stored.** *Judgement, taken here because the card assigns it.* Compose
`group.title + " " + member.variant_label` at read time, through **one** `get_display_title()` on the model.
Reasons: (1) Google requires two distinct strings and forbids the group title from equalling the member
title; (2) the only platforms that store the full string on every row are the four with no container, and
all four have to police the duplication; (3) our 43 Indomie titles are already the composed form.

⚠️ **The cost was understated by a factor of four and is corrected here (red-team finding 1, BLOCKING).**
~~"Cost, exactly two call sites: `order/models.py:556` … and `search/search_indexes.py:34,38,54,55`."~~
`order/models.py:556` is a **column declaration**, not code that can snapshot anything, and the search side
reaches a **Django template** no `prepare_*` method can touch. The real surface is **nine** consumers,
enumerated with `path:line` in `design-C1.md` §5:

1. `py/mono/templates/search/indexes/catalogue/product_lite.txt:1` — a template rendering the raw member
   title, `{% include %}`d by **seven** index templates;
2. `solvent/search/search_indexes.py:34, 38, 54, 55` — four `model_attr="title"`;
3. `solvent/search/search_indexes.py:93-96` — `prepare_autocomplete_staff`, which a `model_attr` grep misses;
4. `solvent/price/purchase/search_indexes.py:61, :75-77` — a **second haystack index in another app**;
5. `solvent/order/creator.py:191` — `"title": product.get_title()`, the **actual** writer of the order-line
   snapshot;
6. `solvent/order/models.py:607` — `title = self.product.title` in `OrderLine.__str__`;
7. `solvent/catalogue/models.py:405-408` and `:488` — the **slug**, derived from the title in two places,
   which §6 assigns to the family;
8. `solvent/third_party_api/biteship/biteship.py:67` — `name=product.title`, sent to a third party;
9. the composition point itself: `solvent/catalogue/models.py:575-578` `get_title()` and `:580-592`
   `get_title_for_staff()`.

Because (1) is a template, only two implementations are honest: a `get_display_title()` the template calls
and every other site re-points to, or composing at the column — which is not read-time composition at all.
**"Composing loses nothing" is withdrawn**: it costs one new model method and nine re-pointed call sites
across four apps, and it must land in the same change as the slug decision. Everything *downstream* of the
API still inherits free — the feed (`products_api.py:222`) and all 30 `product.title`/`product.slug`
occurrences in 22 `ts/` files consume one field.

**#10778 S1 (the family is never buyable): confirmed, and now free.** Under shape A it needed a rule and a
nullable `upc`; under shape B the group is a different table with no `upc`, no `PriceSell`, no
`InventoryFacility` and no basket FK, so **it is unbuyable by construction**. This is the same move as C7
(*"exclusion structural, not advisory"*). It also removes what #10778 called out as the hard
implementation item, quoted whole: *"**Barcode mechanics.** S1 says the group has no barcode; `Product.upc`
is `unique=True` and non-null (`catalogue/models.py:402`, validator `validators.py:10`). Making it nullable
is what unblocks S1 — and it is what breaks the search `guid` field (`search_indexes.py:25`, non-null on
`upc`) plus four other paths. **Size this on its own; it is not a sub-task of the exclusion surface.**"*
**Under shape B that work is unnecessary: `Product.upc` never becomes nullable, because the family is not a
`Product`.** (At this pin the two cites are `catalogue/models.py:385-389` and `search_indexes.py:30`;
`validators.py:10` still holds.)

**#10778 C2 (the family page at every variant's URL, hero by `display_order`): re-expressed.**
- *Survives, and is already built.* The customer route is keyed on the member (`:productId/:slug`), so
  rendering the family's shared content on every member's URL needs no new route and **every existing URL
  keeps working** — which also answers the field survey's open item 3.
- *The hero survives.* The card thumbnail, the search row and the feed's default all need one nominated
  member; Walmart makes it a hard rule (*"Each variant group must contain exactly one primary variant."*).
  S4's mechanism ports unchanged. ⚠️ S4's own caveat still stands: *"`display_order` is a backend convention
  only — it does not exist anywhere in `ts/` … and the admin has no reorder UI."*
- *The bare family URL is dropped.* Under shape B the group has no route and needs none — **that is the
  whole argument, and it is enough.** ⚠️ Revision 1 added *"Google requires per-variant landing pages, so no
  channel wants it"*, which is one-sided and is withdrawn (red-team finding: the "one note on a quote"
  section). Google does say *"Make sure to have different landing page URLs submitted for each variant, with
  each URL using a different path segment and/or query parameters, for example "/t-shirt/green" or
  "/t-shirt?color=green&size=small" or "/t-shirt?preselect=8901491""* (#11031 §C — ⚠️ **not** in `11013.md`;
  its route there is the 2026-09-15 field survey), **but the same record has Google describing the opposite
  pattern**: *"If your website allows customers to select between multiple variants on a single landing page
  … make sure all those versions are submitted with the same item group ID"* (`11013.md:379`). Google
  accommodates both. **Proposed as a narrowing of #10778 C2, not a contradiction.**

**What would reopen it.** (1) A staff workflow that genuinely needs two members of one family to carry
different prose — the WooCommerce case; today's 3,912 divergent-description families are a data-entry
artefact, not a requirement, but if a merchandiser asks for it the answer is a member-level override and C1
becomes iii-for-description. (2) A second sales channel that will not accept a shared category.
(3) A real brand attribute arriving, which turns the advisory brand rule into a storage rule.

**What it forces in steps 1–5.** Step 1: nothing new; the category-per-product decision is already closed.
Step 2: nothing. Step 3: D7's "every member fills every axis, unique combination" is the other half of this
rule and stays where it is. **Step 4 (D10) must additionally specify a family-row reindex receiver**
(red-team finding 2): every reindex trigger in the system is `post_save` on `Product`
(`solvent/catalogue/receivers.py:31-41`), so a family that owns `description`, `title` and `main_category`
needs its own receiver fanning out to every member and then through `update_product_dependent_indexes` to
every member's dependent documents and the Google queue — plus a family-image trigger, since
`receivers.py:44-67` fires only on `ProductImage`. **Step 4 (D10) is also where the field list lands**: the field-by-field list is now settled for
`description` (family), `title` (family + member label, composed), `slug` (family, with the member's id in
the path), `main_category` (family, with the composite-FK mirror as the open sub-choice), `images`
(member-first, family fallback — unchanged), and never price/stock/barcode/visibility. **Step 5**: the
variant label's shape is now load-bearing for the composed title, so it is no longer purely cosmetic — and
the feed key must be a group key, not a member key.

### 8 · Limits and corrections

- **Google is not assigned an option**, because its own record leaves U9 open: *"Whether non-axis attributes
  must be identical across an item group — `brand`, `gtin`, `google_product_category`, `description`. Google
  states the identity rule for `item_group_title` and the `variant_option` `name` set, and nothing else."*
  A live probe found divergent `brand` persisting with **0 `itemLevelIssues`** across 32 products at +1–2,
  +12 and +38 min. Route to settle: a Merchant-API-era statement of the issue codes (the
  `item_group_by_item_group_id_with_conflicting_attributes` row is from the **sunset** Content API).
- **Walmart's content-consistency rule is a best practice, not a rule.** Recorded as such in §2, and #11046
  §U13 says the same. Route: a `MP_ITEM` feed with divergent `productName` under one `variantGroupId`
  (credential-gated, #11068).
- **Meta contradicts Google on the per-variant landing page** (`sources-new.md` O-3). Not resolved.
- **Meta's name-identity sentence has one route.** `sources-new.md` O-1.
- **The proxy family is a proxy, and it errs in both directions.** A shared three-word title prefix inside
  one category is not a family; #11031's own C section says so of the same instrument (*"A shared title
  prefix is not a variant family, so the true share is lower; it is an upper bound"*). ⚠️ It also
  **under**-counts (red-team finding 46): a real family whose members differ inside the first three words is
  invisible to it — `LIFREE CELANA TIPIS (XXL-10)` and `LIFREE POPOK CELANA TIPIS L16` are the same product
  line and do not share a prefix. Every proxy-family percentage here is a statement about *candidate*
  families, over-counting unrelated brand-prefix neighbours and missing prefix-divergent real ones.
- **`description` divergence is measured on raw strings**, so two bodies differing only in whitespace count
  as different. Not normalised; the direction of the error inflates "all different".
- **Not measured: whether the 891 cross-category duplicate titles are true duplicates or genuine
  homonyms.** Route: a sample read of 50 pairs by a human, or a price/supplier comparison.
- **Not collected (`sources-new.md` O-2): whether Meta has a `ProductGroup` node with its own fields.**
  `corpus/meta/fb-graph-product-item.txt:962` documents the edge `/{product_group_id}/products` —
  *"When posting to this edge, a ProductItem will be created."* — so the node exists, but its reference page
  was not found (two guessed URLs → 404). This matters here because Meta is counted as a fourteenth row
  partly on the strength of having no group content row. Route: the Graph API reference page for the
  product-group node at its correct URL, or an authenticated `GET /{product_group_id}?fields=`.

**Corrections after red-team round 1:**

- **1 (BLOCKING)** — ~~"Cost, exactly two call sites"~~ → **nine**, listed in §7 and in `design-C1.md` §5
  with `path:line`. `order/models.py:556` is a column declaration, not a writer (`order/creator.py:191` is);
  `py/mono/templates/search/indexes/catalogue/product_lite.txt:1` is a **template** `{% include %}`d by
  **seven** index templates; `search_indexes.py:93-96` and `price/purchase/search_indexes.py:61, :75-77`
  were missed entirely; the slug derives from the title in two more places. *"Composing loses nothing"* is
  withdrawn and the title confidence is lowered to low-moderate.
- **2 (BLOCKING)** — the product → search-index reindex fan-out was absent from the whole brief. Added to
  §4, §7's "what it forces", `design-C1.md` §5b and `design-A5.md` §0:
  `catalogue/receivers.py:31-41` · `catalogue/index_utils.py:11-16, :19-44` ·
  `catalogue/models_mixins.py:6-31` (three subclasses) · `catalogue/receivers.py:44-67` (images) ·
  `catalogue/search_indexes_mixins.py:22-29, :40-41` (category, four index files). ~~"the search template is
  the one nobody has named yet"~~ is withdrawn — **this** is.
- **5** — eBay's two C1 quotes return **0 hits** in `11045.md`; re-cited to `#11031 §B (11031.md:1192)` with
  its stated Wayback provenance, and the row's option now says "on the Wayback route only". `11045.md` §1.4
  itself shows the group's `title`/`description` as 0..1 optional with no member-match rule.
- **11** — ~~"38 of 43"~~ (a hand count) → **36 exact / 38 normalised**, with the 3 empty rows and the **2
  genuine misses named** (id 24104 abbreviated title; id 29219 body `86 GR` vs title `85 GR`). The predicate
  is now two columns in `sql/fam-c1-indomie-content.sql`.
- **13** — Amazon's byte-identity measurement carries the record's *"Both of Amazon's flavour examples are
  internally defective"* (`10976.md:412`); the `[E-25]` rule alone carries the row.
- **17** — the Salesforce row carries `11050.md:606` **U9**, *"No retrieved instance data exists in this
  record at all"*.
- **24** — five rows quoted `#11031`'s field survey under the per-platform record's number. All re-cited to
  `#11031 §B` with the line: Square `:1197`, Magento `:1199`, WooCommerce `:1200`, commercetools `:1201`,
  Akeneo `:1202`. The commercetools row also regains the clause revision 1 dropped (the Modular
  `VariantProjection.description?` beta projection).
- **25** — the Magento counterfactual no longer presents the brief's prose as a quotation; the record's own
  table cell is quoted (`11082.md:246`), and the C1 Magento row regains *"updated 2026-06-15"*.
- **28** — added: **Meta's worked sample contradicts Meta's worked rule** — all six CSV rows carry identical
  `image_link` **and** `additional_image_link` while `color` varies, against *"images and external links
  match the color of the item"*. Re-verified by parsing `fb-catalog-fields.txt:587-593`: exactly three
  columns vary (`id`, `color`, `size`); nineteen are single-valued. ⚠️ **And the artifact is itself
  malformed** (red-team round 2, finding 8): the header declares **22** columns while every data row carries
  **24** fields, because Meta's sample repeats the `sale_price` / `sale_price_effective_date` pair.
  Positions 0–19 (`id` … `size`) align, so all three varying columns sit inside the aligned region and the
  finding holds; `status` and `inventory` at 20–21 do **not** align — they hold the second price pair, and
  the real `published` / `200` values sit in two unnamed trailing fields. A re-deriver should expect this.
  It sharpens rather than weakens the point: Meta's published sample contradicts Meta's published rule *and*
  does not parse against Meta's own header.
- **29** — the Walmart row carries `11046.md` **U26 / §5 #27** (two of the five "must" bullets return 0 hits
  on re-fetch and are struck; *"Which side moved is not decidable"*) and U13's stronger wording.
- **30** — the Shopee row carries `11047.md` **contradiction 18, "A schema that contradicts its own
  sample"**: the 32-child `item_list` the brief uses to place `description` at item level contains neither
  `tier_variation` nor `model_list`, while the only vendor sample posts both.
- **31** — the Google "0 `itemLevelIssues`" probe is marked **undiscriminating**: `11013.md:925` records that
  no product in the pass carried any. The row rests on U9's "not stated".
- **33** — `sources-new.md` gains a table mapping every OPEN row to the card §8 it lands in; **O-2** (Meta
  `ProductGroup` node) now appears in this §8 and **O-6** (GS1 provenance) in C2 §1 and §8.
- **35** — the header file table said ~~"five queries"~~; there are **nine** (eight from revision 1 plus
  `sql/fam-a5-indomie-manufacturer.sql`, added in this fix round).
- **40** — `Product.slug` (`catalogue/models.py:405-408`, recomputed at `:488`) and
  `Product.thumbnail_url_cache` (`:434`) are now named in §4, since §7 assigns the slug to the family and
  the image rule has to keep the cache fresh.
- **36** — both write paths named (`staff_serializers.py:98-128` create, `:132-143` update).
- **43** — the order-line comment is at `order/models.py:548-549`; `:550-555` is the field. Corrected below.
- **the "one note on a quote"** — the per-variant-landing-page string is cited (`#11031 §C`, not `11013.md`),
  and §6's *"Google requires per-variant landing pages, so no channel wants it"* is **withdrawn** as
  one-sided: `11013.md:379` has Google describing single-landing-page grouping too. The conclusion (do not
  build `/shop/family/:id`) now rests only on "the group has no route and needs none".

**Corrections after red-team round 2:**

- **3 (snapshot bound)** — the five C1 queries now carry the shared snapshot bound inside every
  `ROW_NUMBER()` subquery. **Every C1 figure is unchanged**, including the barcode-identity table and the
  10,090-family block: the bounded results are byte-identical to the published ones, and identical again on
  an immediate second run.
- **5** — `search_indexes_mixins.py:40-41` (was `:39-40`) in §4 and in `design-C1.md` §5b.
- **6** — `staff_serializers.py:132-143` (was `:132-144`) in §4 and in the finding-36 correction note.
- **8** — the Meta CSV sample is recorded as **malformed**: a 22-column header against 24-field rows,
  because the sample repeats the `sale_price` / `sale_price_effective_date` pair. Re-parsed and confirmed:
  positions 0–19 align, so the three varying columns (`id`, `color`, `size`) are inside the aligned region
  and finding 28 stands; `status` / `inventory` at 20–21 do not align.

---

## C2 · Is a 6-pack, or a bundle, a variant of the single — or a separate product?

### 1 · Options

- **C2-a — count is an axis.** The 6-pack is a sibling of the single.
- **C2-b — count is a separate product; form is an axis.** (The card reads Amazon this way: *"package_level
  is a mechanism apart from variation"*.)
- **C2-c — both are separate products, no family link.**

**The card's framing needs one correction before the tally is readable**, and it is a finding, not a
quibble: **(a) and (b) are not alternatives on any platform that has both.** Amazon and Walmart each name
count as a legal variant attribute **and** carry a separate pack/bundle mechanism, because the two answer
different questions — "are these two rows the same product in different amounts?" versus "is this row a
container for other rows?".

**And GS1 splits our one word "pack" into three different objects** (`corpus/gs1/GS1_GTIN_Management_Standard.pdf`,
footer *"Release 1.1, Ratified, Sep 2023 · © 2023 GS1 AISBL"*; full table in `design-C2.md` §0).
⚠️ **Provenance, stated here because this card's recommendation rests on this one artifact** (red-team
finding 16): it is **P1**, not P0 — a GS1 Member Organisation (`gs1id.org`) redistributing the AISBL
document. `www.gs1.org/docs/idkeys/GS1_GTIN_Management_Standard.pdf` returns **404**, and sixteen GS1 hosts
were tried (`corpus/gs1/attempts_task1.log`). No byte-comparison against a P0 copy was possible
(`sources-new.md` **O-6**).

| Our word | GS1 rule | GTIN level | Consumer expected to distinguish it? |
|---|---|---|---|
| a consumer multipack (6 identical sachets, scanned once) | §2.3 **Declared net content** — *"Any change (increase or decrease) to the legally-required declared net content that is printed on the pack, requires assignment of a new GTIN."*; example *"The declared count of the number of razors in a package changes from 4 to 6."* | **the retail consumer trade item / base unit level — the same level as the single** | **YES** |
| a case / carton / *dus* | §2.8 **Pack/case quantity** — *"A change to the number of trade items in a case or a change to the quantity of cases in a predefined pallet configuration, requires assignment of a new GTIN."* | **higher-level packaging only**; the table reads `GTIN change for retail consumer trade item/base unit? **N/A**` | **NO** |
| a banded pack / bundle (two *different* products) | §2.9 **Predefined assortment** — *"…a fixed composition of two or more trade items that are combined and sold together as a single physical trade item."*; *"The individual trade items included in the assortment are explicitly defined by the trading partners and carry their own, unique GTIN separate from the GTIN assigned to the assortment."* | the consumer level **and** every higher level | **YES** |

### 2 · Who uses which, who does not

**No vendor artifact in the thirteen forbids count as an axis — but the unanimity is narrower than that
sounds.** Two name it explicitly (Amazon, Walmart), **ten** permit it with no vendor statement either way,
one was not measured (eBay) — **and three restrict axis eligibility by a mechanism that is not about count**:
eBay per aspect, Walmart per product type (ten food types have no variant mechanism at all), Akeneo per
attribute type. Google models the multipack as an offer attribute **as well as** permitting count-shaped
axes, not instead.

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | *"if you set the `variation_theme` to `SIZE/COLOR/NUMBER_OF_ITEMS`, then `shirt_size`, `color`, and `number_of_items` become mandatory"*; the legacy→JSON theme map carries `count` → **`ITEM_PACKAGE_QUANTITY`**; the **`Flat.File.Health.xls` workbook's** valid-values list is `Color · Count · SizeName · SizeName-ColorName` (⚠️ a *workbook*, not "the `Health` product type" — `10976.md:566` records contradiction **19** about exactly that conflation: `Flat.File.Clothing.xls` publishes `variation-theme=flavor` on rows whose `product_type` is `HealthMisc`, which the same workbook's valid-values list does not permit). **Separately**, `ItemRelationship.type` is an enum of exactly two: `VARIATION` — *"…is a variation parent or variation child of the related items"* — and `PACKAGE_HIERARCHY` — *"…is a package container or is contained by the related items that are identified by ASIN."* | themes **#10976 §1.5** `[E-9][E-14]`; the relationship enum **§1.8** `[E-16]`; the conflation §5 #19 | **a, explicitly — and (b)'s mechanism exists beside it, not instead of it** |
| **Walmart** | *"Supported variant attributes **vary by product type and item specification version**."* and *"Common variant attributes include: Color · Size · Pattern · Character · **Count** · **Count per pack** · **Multipack quantity** · Theme"*. Spec route, at spec level: **6,957 product types each carry their own `variantAttributeNames.items.enum`**, **2,323 distinct axis names** across them, enum size min/max/mean **1 / 2,323 / 11.75**; `Toothpastes` allows 9 = `["character","character_group","count","countPerPack","flavor","form","multipackQuantity","pieceCount","size"]`, `Tires` allows 18, and — the record's own words — *"they intersect only in `count`, `countPerPack`, `multipackQuantity`"*. ⚠️ Revision 1 printed a 9-name array as "the spec's"; it is the **`Sticky Notes`** worked instance (`11046.md:210`), inside a passage retracting a "mirror" claim. ⚠️ `11046.md:2765` also records that the two Walmart artifacts **disagree about the axis lists at scale**. **Separately**, Virtual Pack: *"Use the `bundleType=VIRTUALPACK` query parameter together with the component item's `gtin`…"* | `corpus/walmart/wm-multiple-variants.txt` (P0, 2026-09-19) **+** #11046 **§1.4** (`:200-201, :217`) and **§1.9** (`:327`, `[R-17]`) | **a, explicitly — with a separate bundle mechanism** |
| **Google** | `[multipack]` is an ordinary product attribute — Integer, example `6`, cell quoted **whole**: *"**Required** (For multipack products in Australia, Brazil, Czechia, France, Germany, Italy, Japan, Netherlands, Spain, Switzerland, the UK and the US) · Required for free listings … · **Optional for all other products and target countries**"*; `[is_bundle]` (`[yes]`/`[no]`) carries the identical qualifier. The variant attributes Google names are **eight**, quoted whole: *"The most common types of product variations are supported by detailed product attributes for color `[color]`, size, `[size]`, pattern `[pattern]`, material `[material]`, age group `[age_group]`, gender `[gender]`, size type `[size_type]` and size system `[size_system]`."* — and the record ran the counter-search: *"**no artifact stating a closed set found**"*, every list introduced by *"standard attributes"*, *"such as"* or *"like"* | #11013 attributes 32 (`:691`) and 44 (`:703`), §2 `[F-11]` (`:251`, `:254`) | **expressible** — ⚠️ **re-classified from "ambiguous" after red-team round 1 (finding 22)**: a record that finds no closed set is evidence *for* count-expressibility. Google models the multipack as an *offer attribute* **as well**, which is orthogonal |
| **eBay** | axis eligibility is per aspect: *"**Not all aspects are allowed as a pivoting aspect.** … look for a value of `true` in the `aspectEnabledForVariations` field for the corresponding aspect."* Whether a count-shaped aspect is so enabled in grocery leaves was **not measured** | #11045 §3 `[R-18]` | **not collected** — `sources-new.md` O-5 |
| **Shopify** | `ProductOption.name` is **free text** — *"`ProductOption.name` is free text, so `"Flavor"` needs no taxonomy involvement at all for an unlinked option"* | #11011 §3 | **a expressible**, unnamed |
| **Shopee** | *"If you want to use customized variations, then pass `variation_id=0` and pass `variation_name`."* | #11047 §1.4 `[R-45]` | **a expressible**, unnamed |
| **Tokopedia Era B** | *"Provide either a built-in ID or a custom name; if both are provided, the ID takes priority."*; *"You can only have up to 3 types of sales attributes per product."* | #11048 §1.x `[R-42]` | **a expressible**, unnamed |
| **Square** | the axis is `item_options`, free-text option values | #11049 §1.x | **a expressible**, unnamed |
| **Salesforce B2C** | variation attributes are defined per master; no attribute-kind restriction retrieved | #11050 §1.x | **a expressible**, unnamed |
| **Magento** | the axis predicate is `is_global == SCOPE_GLOBAL` plus a select type; no restriction on what the attribute means | #11082 §1.4 | **a expressible**, unnamed |
| **WooCommerce** | the axis flag is one bool per attribute entry — `is_variation` | #11080 §1.3 | **a expressible**, unnamed |
| **commercetools** | any `AttributeDefinition` may carry `attributeConstraint: CombinationUnique` — *"Set of Attributes that have this constraint, should have different combinations in each variant."* | #11081 §1.2 | **a expressible**, unnamed |
| **Akeneo** | axes are type-restricted: *"Only the following attribute types are allowed: `simple select`, `multi select`, `reference data`, `metric`, `boolean`."* ⚠️ **The record holds this open**: `11069.md` §5 **C3** — *"Which attribute types may be an axis: **six vendor statements, three different answers**"* (the CE array names 5, the spec names 5 with different membership, the Serenity page names up to 10 and permits `Number` and `Text`); §4 **U2** is its live-enforcement gate. The downstream reading survives either way: a count fits `metric` or `simple select` on every version | #11069 §1.x `[R-84]`, §5 C3, §4 U2 | **a expressible**, type-gated |

**Tally, corrected after red-team round 1 (findings 21, 22).** **named explicitly as a count axis: 2**
(Amazon, Walmart) · **expressible, no vendor statement either way: 10** (Google, Shopify, Shopee, Tokopedia,
Square, Salesforce, Magento, WooCommerce, commercetools, Akeneo) · **not collected: 1** (eBay).

**No platform bans *count* specifically — but three restrict what may be an axis *at all*, and revision 1's
counter-search missed two of them.** ~~"Searched the thirteen records"~~ — the instrument printed six.
**Re-run over all thirteen** (`grep -in "cannot be a variant|not.*allowed as.*variation|forbidden.*axis|may
not be an axis|cannot be an axis|not.*allowed.*as.*axis|Only the following attribute types are
allowed|Not all aspects are allowed"` over `10976 11011 11013 11045 11046 11047 11048 11049 11050 11069
11080 11081 11082`) → **5 hits in 3 records**:

| Record | Restriction | Effect on count |
|---|---|---|
| **eBay** `11045.md:321, :653` | per aspect: *"**Not all aspects are allowed as a pivoting aspect.** … look for a value of `true` in the `aspectEnabledForVariations` field"* | whether a count aspect pivots is per category — **not measured** (O-5) |
| **Walmart** `11046.md:501` | per product type: *"**Counter-case 2 — ten food product types with no variant mechanism at all**: `Apples`, `Avocados`, `Bananas`, `Fresh Herbs`, `Grapes`, `Mushrooms`, `Onions`, `Packaged Salads`, `Pears`, `Watermelons`. On these, flavour cannot be an axis because **no** attribute can be."* | on those ten types, count cannot be an axis either |
| **Akeneo** `11069.md:531, :945` | per attribute type: *"Only the following attribute types are allowed: `simple select`, `multi select`, `reference data`, `metric`, `boolean`."* | a count fits `metric` or `simple select`, so unaffected |

So the honest statement is **not** *"Forbidding it: 0"* flat: **no vendor artifact in the thirteen forbids
count as an axis, and three platforms restrict axis eligibility by a mechanism that is not about count** —
eBay per aspect, Walmart per product type (ten food types have no variant mechanism at all; eight other types
constrain nothing), Akeneo per attribute type.

**A second, orthogonal tally: who carries a *separate* pack/bundle mechanism beside variation? ~~3~~ → 4.**
⚠️ **Corrected after red-team round 1 (finding 4, BLOCKING).** Revision 1 excluded Shopee on a premise that
was false in both halves: the string `component_item_or_model_image` occurs **0 times in `11047.md`** (it is
at `11031.md:1274`, inside an image-field sweep), and `11047.md` **§1.7 has a full kit-item section**.

| Platform | The mechanism | Cite |
|---|---|---|
| **Amazon** | `ItemRelationship.type = PACKAGE_HIERARCHY` — *"…is a package container or is contained by the related items that are identified by ASIN."* | #10976 §1.8 |
| **Walmart** | Virtual Pack — `bundleType=VIRTUALPACK`, `bundleComponentItemQuantity`, `bundle_component_gtin` | #11046 §1.9 |
| **Google** | `[is_bundle]` (boolean) + `[multipack]` (integer), both offer attributes | #11013 `:691`, `:703` |
| **Shopee** | `add_kit_item` (2242, 49 request field paths) / `update_kit_item` (2247, 51) / `get_kit_item_info` (2248), carrying `item_setting.model_list[] { tier_index, model_sku, original_price, component_list[] {component_item_id, component_model_id, quantity, main_component} }` and its own free-text `item_setting.tier_variation_list[]` | #11047 §1.7, §5 #21 |

❗ **And Shopee's record rules against this brief's framing**, quoted whole: *"⚠️ **Revision 1 disposed of kit
items in five words — "= composed bundle listing".** By this document's own §2 definition — a row that owns
axes and whose members carry `tier_index` and their own price and SKU — **a kit item is a variant family the
standardisation has not reached** [R-27][R-28]. Its axis shape is the legacy free-text form under a different
name."* See §6 for what this does and does not refute.

### 3 · Why

**Stated:**
- **Walmart** states the purpose of the group and therefore of every axis on it: *"Variant groups allow
  sellers to display multiple versions of the same product on a single Walmart item page. Common examples
  include products that vary by color, size, flavor, pattern, **count**, or other supported attributes while
  sharing the same core product information."* — count is on the list **because the shopper is choosing
  between them on one page**.
- **Amazon** states the two relationship types' meanings side by side: `VARIATION` is parent/child,
  `PACKAGE_HIERARCHY` is *"a package container or is contained by"*. The distinction Amazon draws is
  **containment**, not count.
- **Walmart's own data says count is its most universal axis.** Its `Toothpastes` product type allows 9
  variant attributes and `Tires` allows 18, and the record's instrument over the two lists finds that
  *"they intersect only in `count`, `countPerPack`, `multipackQuantity`"* (#11046 §1.x). The three
  count-shaped attributes are the only axes a toothpaste and a tyre have in common.
- **GS1** states the discriminator directly, and it is the only source in the whole pass that gives a
  *reason* rather than a mechanism: §2.8's guiding-principles row asks *"Is a consumer and/or trading partner
  expected to distinguish the changed or new product from previous/current products?"* and answers **NO** for
  a case-quantity change, while §2.3 answers **YES** for a declared-net-content change. **The line is whether
  the shopper is choosing.**

**Inference, labelled:**
- **Google models the multipack as an attribute because its grouping key is a display device.** `item_group_id`
  exists to render a picker; `multipack` exists to let a shopping comparison normalise price-per-unit. Those
  are different jobs, so they are different fields. **Inference.**
- **The nine "expressible but unnamed" platforms did not decide anything.** All nine let the merchant name
  the axis, so the question never reached the vendor. **Inference:** silence here is not evidence of a
  position, and it should not be read as support for (a).

### 4 · Our code today

- **There is no pack concept in the catalogue.** `grep -rn "item_group_id|itemGroupId"` over
  `py/mono/solvent` → **0 hits**; the feed sets eight attributes and none of them is `multipack`, `is_bundle`
  or `gtin` (`products_api.py:214-224, 230-232, 234-235`; instrument in `sources-new.md`).
- **The carton already has a home that is not a product row.** `ProductMeta`
  (`catalogue/models.py:895`) — `quantity_purchasing_allowed_multiples` (`:905`, *"Purchasing for this
  product is allowed in multiples of this."*) and `quantity_per_box` (`:910`, *"How many products per box
  from supplier? Used mainly in InventoryRecordMeta.inventory_replenishment_quantity_multiplier"*).
- **And staff already record the case count as a string on the single's row.** Every Indomie `title_staff`
  ends in the case quantity: `INDOMIE AYAM BAWANG 69 GR (40)` · `INDOMIE JUMBO GORENG GSSJ 129 GR (24)` ·
  `INDOMIE KERITING AYAM PANGGANG 90 GR (20) MKPN` (`../../sql/results/indomie.csv`).
- **Per option:** C2-a changes **nothing in the model** — count becomes a `ProductAttribute` on the relevant
  category and the dimension list carries it; the pack row already has its own `upc`, `PriceSell` and
  `InventoryFacility`. C2-b/C2-c change nothing either. **The entire cost of this card is in the feed and in
  the staff rule**, not in the schema.

### 5 · Our numbers

`sql/fam-c2-pack.sql` and `sql/fam-c2-pack-detail.sql`, 2026-09-19. Token definitions are the baseline's,
verbatim, so the totals reconcile.

| Token kind | Rows | Single in the same category | Active online |
|---|---|---|---|
| `ISI N` | **3,521** | **697 (19.8%)** | 2,030 |
| `N x M` **followed by a unit** (`12 X 330 GR`) | **112** | 30 | 53 |
| `N x M` with **no** unit | **2,033** | 45 | 94 |
| pack word only (`DUS`, `BOX`, `PAK`, `RENTENG`…) | **1,268** | 119 | 395 |
| **any pack token** | **6,934** (6.5% of 106,161) | 891 (12.8%) | 2,572 |

⚠️ **This corrects the baseline.** `baseline.json` reports *"titles with multiplier 'N x M' = 2,168"*. **2,055
of those carry no unit after the multiplier and are not multipacks**: `KASA HYDROPHYL PARAMITA 16X16CM` ·
`UNI PAD FOR PET 60X90 CM` · `POTENTATE HAND BOOK 110X172MM` · `SALONPAS KOYO 5X2LBR`. 643 pack-token rows
sit in category **1568 `SPREI`** (bedsheets), where `180 X 200` is a bed size. Likewise "pack word" is led by
`BOX` used as the **container form** of milk powder — `SGM EKSPLOR 1+ VANILA BOX 900 GR`.

> **The honest multipack population is `ISI N` + `N x M`-with-unit = 3,633 rows (3.4% of the catalogue), of
> which ~727 (20%) have a plausible single in the same category.**

Four in five multipacks therefore have **no single to be a sibling of**. Under Lock 2 they are families of
one regardless, so nothing breaks — but a count axis buys a picker for one pack row in five.

Sample `ISI N` titles, as printed: `ENERGEN VANILA BOX ISI 5 @ 32GR` · `FRISIAN FLAG KENTAL MANIS SACHET ISI
6 @37 GR` · `MILKITA SUSU KENTAL MANIS COKELAT ISI 6 SACHET` · `HILO SCHOOL VANILLA BAG ISI 10 @35GR`. The
shape is **count + per-item net content**, which is exactly GS1 §2.3's declared net content.

### 6 · Cleanest / structurally correct for us

Full sketch in **`design-C2.md`**. The line this brief proposes is **operational, and it matches GS1's
hierarchy split exactly**:

> **If it is scanned at the till and stocked as its own unit, it is a member of a family with its own `upc`.
> If it exists only so purchasing can order by the carton, it is `ProductMeta.quantity_per_box` and it is not
> a product at all.**

Three consequences, each traced:

1. **A consumer multipack is a sibling** (GS1 §2.3: same hierarchy level as the single, new GTIN, consumer
   expected to distinguish). Count becomes an axis. Amazon and Walmart both name it; nobody forbids it.
2. **A carton / *dus* is not a sibling** (GS1 §2.8: higher packaging level, `N/A` at the consumer level,
   consumer **not** expected to distinguish). It stays `quantity_per_box`, which it already is.
3. **A banded pack is a separate product with no family link *to its components*.** Not as a special case —
   **by C1's own rule**: a banded kecap-plus-sachet differs from the plain kecap in *two* things at once,
   because it contains a second, different product. There is no single axis value that names the difference,
   and a family whose members differ in more than their axis values is not a family. GS1 §2.9 says the same
   structurally: the assortment is its own trade item, and its components *"carry their own, unique GTIN
   separate from the GTIN assigned to the assortment."*

   ⚠️ **Re-argued after red-team round 1 (finding 4, BLOCKING), against Shopee's contrary ruling.**
   `11047.md:286` holds that *"a kit item is a variant family the standardisation has not reached"*. **That
   is a claim about a different proposition**, and the distinction is the whole of the answer:
   - Shopee's kit relates to its components through `component_list[] {component_item_id,
     component_model_id, quantity, main_component}` — a **containment** edge, exactly like Amazon's
     `PACKAGE_HIERARCHY`. Nothing in the record makes a kit a **sibling** of its components.
   - What the record calls "a variant family" is the kit's **own** `tier_variation_list[]` +
     `model_list[] {tier_index, …}` — i.e. **the bundle may itself have variants** (a shampoo+conditioner
     kit in two scents). That is a statement about the bundle's *internal* axes, not about a link outward.

   **The clause therefore survives, restated more precisely**: a banded pack has **no family link to the
   products it contains**, and **may itself be a family** if it is sold in several forms. Our case has one
   form, so it is a family of one. **What would refute it**: an artifact in which a bundle and one of its
   components appear as members of the same variant group. Searched on purpose in `11047.md` (kit sections
   §1.7, §5 #21) and `10976.md` (§1.8) — Shopee's kit uses a component list, Amazon's uses
   `PACKAGE_HIERARCHY`, both sibling values *separate from* `VARIATION`; **nothing found**.

**"Is sachet vs bottle the same idea as 1 vs 6?" — no, and the difference is exactly GS1's.** *Form* (sachet,
botol, renceng) is a property of one trade item at one hierarchy level; *count* is a declared net content at
that same level. Both can be axes, and they are **two different axes** — a 6-sachet pack versus a single
bottle differs on both at once, which is a two-axis grid cell, not one value.

**Feed consequence, the one thing that is not free.** Under C2-a the pack and the single share an
`item_group_id`, and Google then applies its variant rules to the pair — same `item_group_title`, *different*
`title`, and different landing-page URLs, all of which our member-keyed route already satisfies. But the
lock's stated exporter rule (*"forbids the group id on a product that is not a variant — so the exporter
emits members and suppresses the id for single-member families"*) means the **suppression branch is the
common path**: with 3,633 multipack rows of which ~2,900 have no single, most pack rows will emit no group
id at all.

### 7 · Recommendation

> **Judgement.** **Count is an axis (C2-a) for the consumer multipack; the carton is not a product; the
> banded pack is a separate product with no family link *to the products it contains*, and may itself be a
> family if it is sold in several forms.** State it as one rule — *a row exists in the catalogue iff it is
> scanned and stocked as its own unit; two such rows are siblings iff they differ only in axis values* —
> and let C1's rule do the rest of the work.

(⚠️ The two qualifiers on the banded-pack clause are §6's, carried into the box after red-team round 2,
finding 7 — the box previously printed the pre-narrowing wording, which is the line most likely to be
quoted into an issue.)

**Confidence: high** on the carton (GS1 explicit, and we already model it). ⚠️ **Lowered to moderate-high on
the banded pack** (red-team finding 15): revision 1 listed *"#11126's own decision"* as agreeing, and it does
not. #11126 decided *"one SKU, no assembly"* and routed family questions **away** — its Links line reads
*"variant families #10778 (**not** the home for this)"* (`11126.md:69`) — so §7 and §8 contradicted each
other. **#11126 is dropped from the confidence list.** What remains and does support the clause: GS1 §2.9,
C1's own sibling rule, and the Amazon/Walmart/Google/Shopee pattern of a containment mechanism kept separate
from variation — weighed against Shopee's `:286` ruling, addressed in §6.
**Moderate** on count-as-axis: the evidence permits it everywhere and two platforms name it, but our own data
says 80% of packs have no single, so the *value* of the axis is much smaller than the *legitimacy* of it.

**What would reopen it.** (1) A measured customer behaviour showing the single and the pack are not
substitutes (e.g. different buyers, different facilities) — then C2-c. (2) A pack whose per-unit price is
not comparable to the single's, which would make the picker misleading. (3) ATTR-DEF reopening D3, which
changes where the count is stored but not whether it may distinguish siblings.

**What it forces in steps 1–5.** Step 1: the registry must allow a count-shaped attribute on grocery
categories, and it must be axis-eligible — i.e. `is_axis_eligible` (D4) is set for it. Step 2: **D9's open
sub-question, "net content as an axis", is answered yes for count** — and the value shape must express
"Isi 6" the way A4 lands it (label or typed quantity), which is ATTR-VALUE's call, not this card's.
Step 3: **D6's cap of 3 is confirmed as necessary, not merely convenient** — grocery needs flavour, net
content and pack form, and Walmart's independently-fetched *"Up to three variant attributes can be used."*
is a second **unhedged** vendor at that number, beside Shopify. ⚠️ **Tokopedia is not a third** (red-team
finding 18): `11048.md` **U1** is open — the API doc says 3 while Tokopedia Care ID says *"Penjual bisa
mengatur maksimal **2** kategori varian (misalnya Warna dan Ukuran)."* (`11048.md:396, :504`), both
re-fetched, gated on **H1**. Revision 1 spent that 3 as corroboration in two separate recommendations.
Step 4: nothing. Step 5: the feed key work must handle the suppression branch as the common case.

**C2 ↔ A2, cited not decided.** Pack form as an axis is only expressible if a variant dimension **is** an
attribute — D3's option (a), closed 2026-08-13 on a 4–4 tie and confirmed by Lock 1. If ATTR-DEF reopens
D3 and an axis becomes its own object, this card's substance is unchanged (the count still distinguishes two
sellable rows) but the storage moves. **ATTR-DEF's A2 verdict owns that.**

### 8 · Limits and corrections

- **The card's reading of Amazon is corrected here.** *"Amazon: package_level is a mechanism apart from
  variation"* is true and incomplete: `PACKAGE_HIERARCHY` exists **and** `NUMBER_OF_ITEMS` /
  `ITEM_PACKAGE_QUANTITY` is a legal variation-theme component. They are not alternatives. The record itself makes the point:
  *"`PACKAGE_HIERARCHY` is a sibling value of the same `type` enum — pack form (`package_level`,
  `package_contains`) travels through the same relationship object as variation, not a different one."*
  (#10976, "How the pieces connect" §2). ⚠️ **I did not retrieve the `package_level` / `package_contains`
  field definitions themselves**, only the relationship enum and that sentence. Route: `getCatalogItem` with
  `includedData=relationships` on a known package-hierarchy ASIN (credential-gated, #10976 H1).
- **eBay is not assigned an option.** `sources-new.md` O-5 names the one-call route that would close it.
- ~~"Google's Indonesian requiredness … is an **inference** from a country list that omits Indonesia, not a
  statement about Indonesia."~~ ⚠️ **Withdrawn (red-team finding 9): the record states it.** Revision 1
  truncated the cell. Quoted whole, `[multipack]` at `11013.md:703` and `[is_bundle]` at `:691` both end
  *"· **Optional for all other products and target countries**"* — which **is** a statement covering
  Indonesia. `sources-new.md` **O-7 is closed**, not open.
- **The "single exists in the same category" test is a proxy** — first three words of the stripped title,
  same `main_category`. It will miss a single whose title reorders words and will falsely match unrelated
  products sharing a brand prefix. The direction of the error is not one-sided, so 20% is a rough figure, not
  a bound.
- **Not measured: whether the pack and the single are priced consistently per unit.** That is the number that
  would say whether a picker helps or misleads. Route: join `PriceSell` for the 727 matched pairs and compare
  price ÷ count. One query, not run for lack of a reliable count extraction from the title.

**Corrections after red-team round 1:**

- **4 (BLOCKING)** — ~~"Shopee's record also mentions a kit-item API in passing … nothing about its model was
  collected, so it is not counted."~~ Both halves false: `component_item_or_model_image` is at
  `11031.md:1274`, **not** in `11047.md`, and `11047.md` **§1.7** carries the full kit-item model. The
  secondary tally is raised **3 → 4**, Shopee's object is printed with its field paths, and the record's
  ruling (*"a kit item is a variant family the standardisation has not reached"*, `:286`) is quoted and
  **answered** in §6 rather than excluded: it is about the kit's *own* axes, not about a sibling link to its
  components. The "no family link" clause is **restated more precisely**, not withdrawn, and §6 names what
  would refute it.
- **9** — the Google `[multipack]`/`[is_bundle]` cells are quoted **whole**; the *"Optional for all other
  products and target countries"* clause closes O-7, and the false OPEN bullet above is struck.
- **15** — #11126 dropped from §7's confidence list (`11126.md:69`: *"variant families #10778 (**not** the
  home for this)"*); the stitched quotation replaced with the record's own two sentences; §7 and §8 no
  longer contradict each other.
- **16** — the GS1 artifact's **P1** provenance and **O-6** now appear in §1, where the recommendation rests
  on it.
- **18** — Tokopedia's 3-axis cap removed as corroboration for D6; `11048.md` **U1** named, with the
  Indonesian help text (*"maksimal 2 kategori varian"*) quoted.
- **19** — the 9-name `variantAttributeNames` enum re-labelled the **`Sticky Notes`** instance
  (`11046.md:210`); the spec-level numbers (6,957 types, 2,323 distinct axis names, mean enum 11.75) used
  instead, the corpus page's *"vary by product type and item specification version"* restored, and
  `11046.md:2765`'s artifact disagreement carried.
- **20** — Akeneo's axis type list carries §5 **C3** (*"six vendor statements, three different answers"*) and
  §4 **U2**.
- **21** — ~~"Forbidding it: 0"~~ and ~~"Searched the thirteen records"~~ (the instrument printed six) → the
  grep is **re-run over all thirteen** and reprinted; **5 hits in 3 records**, including the one revision 1
  missed: Walmart's *"ten food product types with no variant mechanism at all"* (`11046.md:501`). The claim
  is restated as "no artifact forbids **count**; three platforms restrict axis eligibility by another
  mechanism".
- **22** — Google's variant-attribute list printed at **eight**, quoted whole, with the record's own
  counter-search result (*"no artifact stating a closed set found"*); Google **re-classified from "ambiguous"
  to "expressible"**, moving the tally from 2 / 9 / 1 / 1 to **2 / 10 / 0 / 1**.
- **32** — section cites re-resolved: Amazon themes **§1.5** (not §1.8/§2) with the `Flat.File.Health.xls`
  workbook-vs-product-type conflation (`10976.md:566`, contradiction 19) carried; Walmart **§1.4** and
  **§1.9** (not §1.x/§1.8).
- **41** — `sql/fam-c2-pack.sql`'s final `ORDER BY 1,3` tied on `count = 1` across ~2,900 category rows, so
  the saved CSV's tail was not reproducible. Changed to `ORDER BY 1, 2` (the bucket string carries
  `main_category_id`), re-run, and **verified byte-identical on a second run**. No number moved.

**Corrections after red-team round 2:**

- **2 (§2 lead)** — ~~"Nobody forbids count as an axis. Two platforms name it explicitly; nine permit it
  structurally without naming it; one models the multipack as an offer attribute instead; one was not
  measured."~~ Three things below it said otherwise after round 1. The lead now prints the corrected tally
  (**2 named · 10 expressible · 1 not collected**), says Google models the multipack as an offer attribute
  **as well as** permitting count-shaped axes rather than *instead*, and states the three axis-eligibility
  restrictions up front instead of leaving "nobody forbids" to stand alone.
- **3 (snapshot bound)** — both C2 queries now carry the shared snapshot bound. **Every C2 figure is
  unchanged** — 3,521 / 112 / 2,033 / 1,268 / 6,934 and the 697 + 30 = 727 single-exists counts all
  reproduce byte-identically under the bound.
- **7** — §7's boxed judgement now carries §6's two qualifiers: no family link **to the products it
  contains**, and the pack **may itself be a family**. The box previously printed the pre-narrowing wording.
- **#11126's mechanism question is still open and this card does not close it.** ⚠️ Revision 1 put
  *"mechanism for keeping a banded pack distinguishable"* in quotation marks; that string is **stitched from
  two sentences** and is not verbatim. The record's own words, quoted whole: *"The *decision* is settled
  (one SKU, no assembly). The *mechanism* for keeping it distinguishable is not, and should be designed
  rather than assumed."* and its first open question, *"Is a marker on `Product` needed at all, or is it
  enough that a banded pack simply **is** an ordinary product and the promo form never offers it as a bundle
  candidate?"* This card only says the banded pack is not a family member of its components.

---

## C3 · Can a family have sub-families?

Shirt → colour → size, two levels; or one level only. **= D12.**

### 1 · Options

- **C3-a — one level, enforced.** A family has members; a member has no sub-members.
- **C3-b — two levels.** A family may have sub-families; members hang off the deepest.
- **C3-c — unbounded nesting.** *(Listed for completeness; no platform in the set implements it — see §2,
  where the deepest cap found anywhere is 2.)*

### 2 · Who uses which, who does not

**Near-unanimous for one level: 9 of 13.** Two nest, and both cap at exactly two. Two more are named
ambiguous because what they nest is not the family.

| Platform | The record's own words | Cite | Option |
|---|---|---|---|
| **Amazon** | *"Child products are unique, sellable products that are related in our catalog to **a single**, non-sellable parent product"*; *"You must remove a child listing from its current parent-child relationship before you relate it to a new parent"*; feed error **8032** | #10976 §1.8 `[E-20][E-14][E-21]` | **a** |
| **Shopify** | `Product → ProductVariant`, one level; *"There is no "no variant" state."* | #11011 §2c | **a** |
| **Google** | `item_group_id` is one string on the row; there is no second grouping level | #11013 §2 | **a** |
| **eBay** | one level — `InventoryItemGroup --1..N--> InventoryItem` by SKU string | #11031 P2/D12; #11045 §1.4 | **a** |
| **Walmart** | *"An item can belong to only one variant group."*; one level | `corpus/walmart/wm-multiple-variants.txt` (P0, 2026-09-19); #11031 P2/D12 | **a** |
| **Square** | one level — item → variation | #11031 P2/D12 | **a** |
| **Magento** | `catalog_product_super_link` has both FKs on `catalog_product_entity.entity_id` with `UNIQUE (product_id, parent_id)` | #11082 §1.5 | **a** (with the 0..N parent quirk, C1 §2) |
| **WooCommerce** | the child is a `product_variation` post whose `post_parent` is the container, and *a non-`product` parent is reset to 0* | #11080 §2b | **a** |
| **commercetools** | one level in both models: Classic embeds `ProductVariant`s inside `ProductData`; Modular gives `Variant` a single `product` reference upward — `Variant --1..1--> Product` | #11081 §1.6, §1.7 | **a** |
| **Akeneo** | **exactly two, and the cap is a compiled constant.** `private const MAXIMUM_LEVEL_NUMBER = 2;` (`FamilyVariantValidator.php:20`, enforced :154-197). Spec, whole: *"- Number representing the level of the attribute set.\n- It should be equal to 1 or 2.\n- If you specify the level 2, you have to specify the level 1 as well.\n"* Seven help pages: *"A number of variant levels: 1 or 2"*. `ProductModel.parent` is a self-reference (`parent_id`, CASCADE) | the caps **#11069 §1.x** (`:529`, `:531`) `[R-31][R-84]`; the self-reference **§1.6** (`11069.md:369`) and §2 step 8 (`:602`) | **b** |
| **Salesforce B2C** | a middle tier: *"A variation group is a subset of variations that are part of a base product."*; *"While you assign a variation group to only one base product, you assign multiple variation groups to that base product."*; *"A variation group can include only one value of a variation attribute."* ❗ gated: *"Reserved for Beta users. Variation groups will not be created and a warning will be logged if the Variation Groups (Beta) feature is disabled."* | #11050 §1.2 `[R-36][R-13]` | **b**, feature-gated |
| **Shopee** | nests the **axis vocabulary**, not the family: *"If there are two levels of variations under this category, `variation_group_id` must be passed."*; the tree is `variation → variation_group → variation_option`. item→model stays one level, capped at 2 axes | #11047 §1.4 `[R-45][R-9]` | **ambiguous, named** — it is not family nesting |
| **Tokopedia Era B** | documents `product_families[]` above the product — *"Applicable only for US local sellers"* | #11048 §1.10 | **ambiguous, named** — market-gated and unread |

**Tally.** **a = 9** · **b = 2** (Akeneo, Salesforce) · **c = 0** · **ambiguous, named = 2** (Shopee nests
the axis vocabulary; Tokopedia's above-product object is gated to one market).

### 3 · Why the two that nest, nest

**Akeneo states it, and the reason is content placement, not the grid.** Its worked example, whole:
*"The attributes that vary by color (variant level 1) are the composition and the pictures. Finally, the
attributes that differ by color and size (variant level 2) are the EAN, the SKU, and the weight."*
(#11031 field survey §B). The middle level exists so that *"the composition and the pictures"* have a home
that is neither the whole style nor one SKU. And the levels are attribute-disjoint by rule: *"Attributes
used as axes in one level cannot be used as axes or as attributes in the other level."* (#11069 §1.6).

**Salesforce states a merchandising reason, and names its cost.** A variation group is *"a subset of
variations"* addressable in its own right — the "all the red ones" page. Enabling it turns something else
off: *"Agentforce Commerce for B2C disables slicing (defined for variation attributes or overridden in
category assignments) when variation groups exist for a base product, but only for that product."*
(#11050 §1.x).

**Inference for the nine, labelled.** Every one of them either has no container content to place at an
intermediate level (Google, Walmart, Amazon's flat rows) or places all shared content at one level already
(Shopify, commercetools, Square, Shopee, WooCommerce, Magento). **Inference:** a second level buys nothing
unless there is content that belongs neither to the whole family nor to one member — which is exactly the
case Akeneo names and nobody else has.

### 4 · Our code today

- **The tree machinery already exists, which is why the cost is not the migration.** `Category` is an
  `MP_Node` (`catalogue/models.py:93`, django-treebeard materialised path) with `depth`, `numchild`, `path`
  and an `ancestors_are_public` mirror. A second tree would be one nullable self-FK on the new group table.
- **What a second level would cost is downstream, and every item is already on the record:**
  lock condition 4's composite-FK axis mirror would have to mirror the **deepest** level's key, with the
  middle level's axes as a second key; the Elasticsearch collapse (the grouping mechanism) would have to
  choose a level; the family-level ranking aggregates — *"the most serious open item against L2"* — would
  need a rollup per level or a choice of ranking level; and the Google feed has exactly one grouping level
  (`item_group_id`), so a nested family flattens to one id anyway and the second level is invisible to the
  channel.
- **Nothing in either stack reads a family today**, so C3 forks no existing call site — ⚠️ now
  **instrumented** rather than asserted (red-team finding 44). Backend, `grep -rn "<pattern>"
  py/mono/solvent --include=*.py`: `VariantGroup` **0** · `variant_group` **0** · `ProductGroup` **0** ·
  `product_group` **0**. Frontend, `grep -rn "<pattern>" ts/libs ts/apps --include=*.ts --include=*.html`
  with `.spec.ts`/`.stories.ts` excluded: `variantGroup` **0** · `variant_group` **0** · `productGroup`
  **0** · `product_group` **0** · `item_group` **0** · `family` **3**, and all three are CSS
  `font-family` (`libs/shared/style/util-font-fit/src/lib/font-fit.ts:18`,
  `libs/shared/feature-apps-bootstrap/src/lib/environment-indicator.util.ts:98` and `:133`). Positive
  control in the same sweep: `product.title`/`product.slug` → **30 occurrences in 22 files**. Full table in
  `design-C3.md` §4.

### 5 · Our numbers

**The grid signal — the only thing that could argue for a second level.** `sql/fam-c3-grid.sql`, 2026-09-19,
over the 10,090 proxy families, splitting each title into a net-content token and the remaining words:

| | Families | Products |
|---|---|---|
| vary on net content only | 747 | — |
| vary on the words only | 6,560 | — |
| **vary on BOTH — a grid candidate** | **1,748 (17.3%)** | **8,071** |

**Grids exist, and they are ragged.** The Indomie family is one: `INDOMIE GORENG CABE IJO 85 GR` and
`INDOMIE GORENG CABE IJO JUMBO 120 GR` are the same flavour at two sizes, while thirty-one other flavours
exist at one size each (`../../sql/results/indomie.csv`). **A ragged grid is exactly the case two axes handle
and nesting handles badly**: under nesting, 32 of the 33 flavours would each be a sub-family of one member.

**Apparel, re-running #10943's measurement.** #10943's comment of 2026-08-10 reports *"Of **1,945**
apparel-titled live products … only **240 (12.3%)** carry any size token at all — and many of those express
a *range* rather than a single size."* ⚠️ **The size-token regex was never published**, so this is a
sensitivity analysis, not a reproduction (`sql/fam-c3-apparel-sensitivity.sql`):

| | Rows |
|---|---|
| apparel-titled, all | 2,201 |
| apparel-titled, **live** (`is_active AND is_public`) | **2,062** at this snapshot; #10943 reported **1,945** on 2026-08-10 — ⚠️ **not necessarily growth** (finding 27): that query ran *"against the BigQuery prod mirror"* and this one runs against `production_append_public` with this brief's CDC dedup, so the instruments differ. #10943 also caveats its own figure — *"Treat the title-keyword match as a **floor**: apparel not matching those words is not counted."* |
| apparel-titled, **active online** | **78** |
| def1 range only (`M-XL`) | 50 |
| def2 unambiguous letters only (`XS`,`XL`,`XXL`,`2L`,`3L`…) | 262 |
| def3 letter size at the **end** of the title | 368 |
| def4 explicit marker word (`SIZE`/`UKURAN`/`UK`/`ALL SIZE`) | 23 |
| **def1 ∪ def2 ∪ def4 — the defensible floor** | **287 (13.9%)** |
| def5 permissive (any letter size anywhere, incl. bare `S`/`M`/`L`) | 688 |

**The floor reproduces #10943's order of magnitude** (13.9% vs 12.3%). Two things the keyword set does that
the original did not flag: (1) `CELANA` catches **adult and baby pants-type diapers** —
`LIFREE POPOK CELANA EXTRA SERAP XL12` · `LIFREE POPOK CELANA TIPIS L16` · `SOFTEX CELANA MENSTRUASI ISI 2`
— which are grocery, and are themselves a **size × count** grid; (2) **apparel is not an online category
today**: 78 of 2,062 live apparel-titled rows are active online (3.8%), so #10943's own stronger driver
(*"A customer buying a shirt online has to choose a size"*) is about a business we do not currently run on
this shelf.

**And the reason Akeneo nests is absent from our data.** Its level-1 content is *"the composition and the
pictures"*. Our pictures: **30,740 of 106,161** products carry any image at all, and **5,299 of 10,090 proxy
families (52.5%) have no image on any member**. There is no photographed-per-colour corpus to hang off a
middle level.

### 6 · Cleanest / structurally correct for us — fit-check on the near-unanimous option

Nine of thirteen are one level, so the design pass is a fit-check rather than a full sketch
(`design-C3.md`). It fits, and the fit is asymmetric in a way worth stating:

- **One level is expressed by the absence of a column**, not by a validator. No `parent_id` on the group
  table means nesting cannot be represented, let alone violated. This is the same argument that made shape B
  beat shape C — *"C7 'exclusion structural, not advisory' is satisfied by construction under shape B."*
- **Adding the column later is a no-op migration.** Lock 2's groups are already the level a nested model
  would call the deepest, so `parent_id` arrives NULL everywhere with nothing to backfill.
- **Removing it later is not.** It would mean collapsing hierarchies staff have authored, and re-homing every
  member.
- **Two axes cover every grid our data contains**, and D6's cap of 3 leaves headroom for flavour × net
  content × pack form — which C2 §7 shows is exactly the grocery need.

### 7 · Recommendation

> **Judgement.** **C3-a — one level, and enforce it by not building the column.** Do not add `parent_id` to
> the group table and do not write a validator forbidding nesting. Express two-dimensional families as **two
> axes on one family**, which D6 already permits.

**Confidence: high.** Nine of thirteen, the two that nest both cap at exactly two and both state a reason we
cannot evidence for ourselves, our grids are ragged (which nesting serves badly), and the decision is the
reversible one.

**What would reopen it.** (1) **An intermediate content home becomes real** — Akeneo's actual reason: a
photograph or a composition that belongs to a *colour* across sizes rather than to one SKU. Our image
coverage (29% of products) says this is not near. (2) **A merchandising need for an addressable subset** —
Salesforce's reason: a URL for "all the red ones". Today the family has no URL at all (C1 §6). (3) **The axis
cap binds** — if a family genuinely needs more than three axes, nesting is one way to split them; but
Walmart and Shopify both cap at 3 without nesting, so the likelier answer is that the family is wrong.
⚠️ **Tokopedia removed from that list** (red-team finding 18): `11048.md` **U1** is open — its API doc says
3 and its Indonesian help says *"maksimal **2** kategori varian"* (`11048.md:396`), gated on H1.

**What it forces in steps 1–5.** Step 1: nothing. Step 2: nothing. **Step 3**: D6's cap of 3 is now
load-bearing rather than convenient, because it is the whole of our answer to grids; and D7's "fill every
axis, unique combination" stays a single-level constraint, which is what lock condition 4's composite-FK
mirror already assumes. **Step 4: D12 is answered — (a), one level, enforced** (the page's own likely
default). Step 5: nothing; the naming decision (L2.3) is unaffected because there is only one container to
name.

### 8 · Limits and corrections

- **The #10943 re-run is not a reproduction.** ⚠️ **Half of its regex *was* published** (red-team finding
  26), and this brief reuses that half: the apparel-title keyword set
  `KAOS|BAJU|CELANA|KEMEJA|JAKET|SERAGAM|PAKAIAN` is printed whole in #10943's 2026-08-10 comment and is
  exactly what `fam-c3-apparel-sensitivity.sql` and `fam-c3-grid.sql` use. Only the **size-token** regex was
  never published, which is why §5 gives five definitions and the range they span (50 → 688). Route to
  close: #10943's author restating the size pattern, or a human classification of a 200-row sample.
- **The apparel keyword set is not apparel.** It catches diapers and menstrual products. A clean measurement
  needs the category tree, not title keywords — e.g. the subtree under the apparel roots. Not run here
  because TREE owns the node-level measurement (`briefs/TREE/node-attribute-need.md`), and a second
  uncoordinated node measurement would conflict with it.
- **The grid measurement is a proxy on a proxy, and it errs in *both* directions** (⚠️ red-team finding 46 —
  revision 1 named only one). Proxy families (3-word prefix + category) split by a net-content regex; a title
  that omits its size, or spells it in words, is invisible. It **over**-counts by grouping unrelated products
  that share a brand prefix (`SGM EKSPLOR 1+ …` beside `SGM 2 BOX …`) and by grouping a single with its own
  carton. It **under**-counts every real family whose members differ *inside* the first three words — which
  is exactly the apparel and net-content shapes this card measures: `INDOMIE GORENG CABE IJO 85 GR` and
  `INDOMIE GORENG CABE IJO JUMBO 120 GR` share a prefix, but `LIFREE CELANA TIPIS (XXL-10)` and
  `LIFREE POPOK CELANA TIPIS L16` do not. So **1,748 is an upper bound on *these* grids and a lower bound on
  grids overall**; revision 1 presented only the first direction. C1 §8's "upper bound" note carries the same
  correction.
- **Tokopedia's `product_families[]` was not read.** It is documented as *"Applicable only for US local
  sellers"* and no field list was retrieved. Route: the Tokopedia/TikTok Shop US local-seller product API
  reference. It is the one object in the set that might be a third nesting precedent.

**Corrections after red-team round 1:**

- **18** — Tokopedia removed from the "all cap at 3" list in §7; `11048.md` **U1** named and the Indonesian
  help text quoted. Walmart and Shopify remain, both unhedged.
- **26** — ~~"Its regex was never published"~~ → **half of it was**: the apparel-title keyword set is
  published whole in #10943 and is what this brief's SQL reuses; only the **size-token** regex is
  unpublished. §5's wording was already right; §8's was not.
- **27** — the 1,945 → 2,062 apparel delta is no longer presented as growth: the two runs used different
  instruments (#10943's *"BigQuery prod mirror"* vs this brief's `production_append_public` + CDC dedup),
  and #10943's own *"Treat the title-keyword match as a **floor**"* caveat is carried.
- **32** — Akeneo's C3 cite re-resolved to **§1.x** for the caps (`11069.md:529, :531`) and **§1.6** /
  §2 step 8 for `ProductModel.parent`; Salesforce's re-resolved to **§1.9** (`11050.md:331`), with a note
  that the record's own *"(§5 D6)"* pointer does not resolve — §5 holds C1–C14 and has no D6.
- **44** — §4's *"Nothing in either stack reads a family today"* is now instrumented in both stacks, with
  patterns, counts and a positive control, instead of asserted.
- **46** — the proxy-family instrument's bias is stated in **both** directions; 1,748 is an upper bound on
  the grids it can see and a **lower** bound on grids overall, with the worked under-count example
  (`LIFREE CELANA TIPIS (XXL-10)` vs `LIFREE POPOK CELANA TIPIS L16`).

**Corrections after red-team round 2:**

- **3 (snapshot bound) — this card is where the drift was demonstrated, and the bound resolves it.** Round 2
  re-ran `fam-c3-grid.sql` unbounded and got **1,747 / 748 / 8,069** against this card's published
  **1,748 / 747 / 8,071** — one product's title had been edited in production between the first run and the
  re-run, moving its family from "varies on both" to "varies on net content only". Both C3 queries now carry
  `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside the
  `ROW_NUMBER()` subquery, per the amended BRIEF §3.4. **Re-run under the bound the figures return to
  1,748 / 747 / 8,071**, byte-identical to what this card prints, and identical again on a second run — so
  **no figure in this card is corrected**; what changed is that they are now re-derivable by anyone at any
  later date. The unbounded originals are kept at `sql/unbounded-originals/` with a README saying not to
  re-run them. The apparel block (2,201 / 2,062 / 78 / 287 / 688) never drifted and is unchanged.
- **Salesforce's `VariationGroup` status is contradictory in its own sources and is left so**: the XSD says
  *"Reserved for Beta users. Variation groups will not be created and a warning will be logged if the
  Variation Groups (Beta) feature is disabled."* in a schema whose namespace is `2006-10-31`, while Trailhead
  ships an entire published unit on configuring variation groups *"with no beta language anywhere in its
  12,954 B of text"*. ⚠️ **Cite corrected (red-team finding 32):** this is `#11050 **§1.9**`
  (`11050.md:331`), the deprecations-and-feature-gates census — **not** "§5 D6". The record's own sentence
  ends *"Reported, not resolved (§5 D6)"*, and §5 holds C1–C14 with **no D6**; revision 1 inherited a
  dangling pointer. Counted as **b** on the strength of the published unit; the gate is recorded, not
  resolved.
