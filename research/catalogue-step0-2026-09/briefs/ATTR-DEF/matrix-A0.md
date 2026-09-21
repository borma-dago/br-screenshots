# matrix-A0.md — what attributes are for, and where visibility lives

Full evidence table for `ATTR-DEF.md` §A0 step 2. **Options as the card states them:**
**V1** visibility is a property of the attribute **definition** (shown or hidden everywhere it appears) ·
**V2** per **category membership** (Rasa shown for food, hidden for cleaning products) ·
**V3** per **channel** (online / till / Google).

The card also asks *which uses we want and in what order*: the variant picker, search filters, a spec
sheet, Google feed fields, internal rules. Each platform row therefore records **what the platform says
attributes are FOR**, alongside its visibility mechanism.

---

## 1 · Amazon — V1 flag, V2 by product type, per-marketplace selectors

**V1, the flag, verbatim:**
> "| `hidden` | Informational | *"whether a property should be hidden in Amazon user interfaces."* |"
> "| `editable` | Informational | *"whether or not a property value can be modified for an existing item. Properties that can't be modified may still be required for a valid submission."* |"
— #10976, SUPERSEDED comment §4 (the product-type-definition meta-schema, [A7])

Observed values: `"editable": true, "hidden": false` on `item_name`, on `variation_theme.name`, on
`parentage_level.value`; and **`"editable": false, "hidden": true`** on `child_relationship_type` in
`TERMINAL_BLOCK` and on `marketplace_id` (#10976 Tier-3 §2.3, §2.5). The record's own tier warning applies
to those four instances (P2/P3 sources).

**The purposes are declared by property group**: `product_details` — *"Information and characteristics to
describe the product to support search, browse and detail page content (e.g., bullets, product features,
model, style name)"*; `safety_and_compliance` — *"Information to indicate product compliance, hazardous
materials, and legal and safety warnings…"* (#10976 Tier-3 §2.8).

**Filters:** the browse-tree guides publish a **Refinements** sheet whose columns are attribute names —
globally **2,600,729 rows, 1,407 distinct attributes**; US-only 130,826 rows / 1,035 distinct
(#10976 Companion C §1.6, §1.8). The search API exposes exactly two refinement axes, `brands` and
`classifications` (#10976 §1.6).

**Release-note rationale strings classify purpose at scale:** *"A new optional attribute is introduced to
improve the product detail page."* occurs **267,595** times across the corpus (#10976 Companion C §2.5).

**Per-channel:** not a channel flag — a **per-marketplace selector on every value**
(`"selectors": ["marketplace_id","language_tag"]`), and status is per-marketplace too (#10976 §1.3, §2c).

---

## 2 · Shopify — **the richest instance: V1 + V2 + V3 all on the definition**

**V3 — per-channel visibility, on the definition:** `MetafieldDefinition.access : MetafieldAccess!` with
`{admin, storefront, customerAccount}`. Live values observed:
`"access":{"admin":"PUBLIC_READ_WRITE","storefront":"PUBLIC_READ","customerAccount":"NONE"}` on the
standard `shopify.color-pattern` definition, and `"storefront":"NONE"` on a custom one
(#11011 §1.8 Rev-5 E8, §2c′). `StandardMetafieldDefinitionTemplate.visibleToStorefrontApi: Boolean!` is a
second, template-level expression of the same idea; *"All 28 constrained templates are …
`visibleToStorefrontApi: true`"* (#11011 §1.8).

**V1 — filterability, on the definition:** `capabilities : MetafieldCapabilities!` with
`smartCollectionCondition`, `adminFilterable` and `uniqueValues`; live:
`"capabilities":{"smartCollectionCondition":{"eligible":true,"enabled":false},"adminFilterable":{"eligible":true,"enabled":false,"status":"NOT_FILTERABLE"},"uniqueValues":{"eligible":false,"enabled":false}}`
(#11011 §2c′). Plus `pinnedPosition : Int` (an ordering/prominence field; **no description is quoted
anywhere in the record**) and the deprecation `useAsCollectionCondition` → *"Use `smartCollectionCondition`
instead."* (#11011 §1.8).

**V2 — per-category applicability, on the definition, quoted to the end of the clause:**
> *"By default, metafield definitions apply to every resource on their owner type. For example, `Product` metafield definitions apply to all products and appear on all product detail pages in the Shopify admin."*
> *"However, some metafield definitions should only apply to a subset of resources. For example, `Shoe size` is a valid metafield for `Shoes` products but wouldn't apply to `Sweaters`."*
> *"At the core of the conditional metafields system are constraint subtypes. Constraint subtypes are `key | value` pairs that identify a "subtype" of a metafield owner type."*
> *"**Currently, Shopify only supports constraint subtypes that correspond to product categories on `Product` metafield definitions.** These constraint subtypes all have a `key` equal to `category`."*
> *"If a definition is unconstrained, then the definition applies to all resources and appears on all resource pages in the Shopify admin."*
— #11011 §1.8

Scale of one constraint: `constraints{key:"category"}` on `shopify.color-pattern` paged to **7,750 category
ids** (#11011 §1.8).

**Filters, in the platform's own terms:** `CollectionRuleColumn` — all 15 —
`IS_PRICE_REDUCED · PRODUCT_CATEGORY_ID · PRODUCT_CATEGORY_ID_WITH_DESCENDANTS ·
PRODUCT_METAFIELD_DEFINITION · PRODUCT_TAXONOMY_NODE_ID · TAG · TITLE · TYPE ·
VARIANT_COMPARE_AT_PRICE · VARIANT_INVENTORY · VARIANT_METAFIELD_DEFINITION · VARIANT_PRICE ·
VARIANT_TITLE · VARIANT_WEIGHT · VENDOR` (#11011 §1.9) — i.e. **a metafield definition is itself a
first-class filter column, at both levels.**

---

## 3 · Google Merchant Center — **no per-attribute visibility flag; V3 lives on the product**

**The absence:** no field equivalent to Amazon's `hidden` appears anywhere in the record.

**V3, at product level, not attribute level:** `excludedDestinations` (13 enum values whole:
`DESTINATION_ENUM_UNSPECIFIED · SHOPPING_ADS · DISPLAY_ADS · LOCAL_INVENTORY_ADS · FREE_LISTINGS ·
FREE_LOCAL_LISTINGS · YOUTUBE_SHOPPING · YOUTUBE_SHOPPING_CHECKOUT · YOUTUBE_AFFILIATE ·
FREE_VEHICLE_LISTINGS · VEHICLE_ADS · CLOUD_RETAIL · LOCAL_CLOUD_RETAIL`), `includedDestinations`,
`shopping_ads_excluded_country`, `pause` (3 enum values) — and the spec's list of 7 disagrees with the
API's 13 (#11013 Companion A §A.8, §A.11, contradiction 8).

**Per-surface availability of an attribute, by publication rather than by flag:** `[lifestyle_image_link]`
— *"**Only available for browsy surfaces**"*; `[short_title]` — *"**Only available for Demand Gen Ads,
including YouTube, Gmail, Maps, Discover app, Google Display Network, and Google Video Partners.**"*
(#11013 Companion A §A.6).

**V2, as requiredness not visibility, with the record's own strike:**
> "**❗ Category gates *requiredness*~~, never *existence*~~.** ~~Every attribute exists on every product; category only decides whether omitting it is an error.~~"
— #11013 §1.4 — struck because `[subscription_cost]` is *"Use for approved product categories only. Use of the subscription cost attribute for other categories of products will result in disapprovals."*

**The three requirement markers, quoted whole** — the closest thing Google has to a purpose tier:
> "**Required**: Submit this attribute. If you don't, your product won't be able to serve in ads and free listings. **It depends**: You may or may not need to submit this attribute depending on the product or the countries in which your products show. **Optional**: You can submit this attribute if you want to help boost your product's performance."
— #11013 §1.4

**`custom_label_0-4`:** *"Use only 1,000 unique values for each custom label across your Merchant Center
account."* — and **whether custom labels are merchant-internal or shown to buyers is not answered in the
record**; the analogous "bidding and reporting only" statement is made for `product_type`, not for custom
labels (#11013 Companion A §A.6, §1.8).

**Landing-page match is a stated purpose:** *"Make sure that the product details displayed on your landing
page match the variant-identifying values you provide for the variant like title `[title]`, variant option
`[variant_option]`, color `[color]`, price `[price]`, availability `[availability]`, and image link
`[image_link]`."* (#11013 §1.6).

---

## 4 · eBay — **V1, eleven flags per aspect, scoped V2 by construction** *(the card's `aspectUsage` pointer)*

`AspectConstraint` has **exactly 11 properties** (#11045 §1.2). The four the record quotes verbatim:
- `aspectEnabledForVariations` — *"A value of `true` indicates that this aspect can be used to help identify item variations."*
- `aspectMode` — *"The manner in which values of this aspect must be specified by the seller (as free text or by selecting from available options)."*
- `aspectRequired` — *"A value of `true` indicates that this aspect is required when offering items in the specified category."*
- `itemToAspectCardinality` — *"Indicates whether this aspect can accept single or multiple values for items in the specified category. Note: Up to 30 values can be supplied for aspects that accept multiple values."*

**`aspectUsage` — the pointer, with its live distribution and its contradiction:**
> "| `aspectUsage` | `AspectUsageEnum` | 1..1 | `"RECOMMENDED"` · ⚠️ live `"OPTIONAL"` on `Flavor`; bulk `OPTIONAL` 136,195 / `RECOMMENDED` 60,851; **the two operations disagree on this field** |"
— #11045 §1.2

> "❗ **`aspectUsage` contradicts `aspectRequired` by design, and eBay says so**: *"This field is always returned, even for hard-mandated/required aspects (where `aspectRequired`: `true`). The value returned for required aspects will be `RECOMMENDED`, but they are actually required and a seller will be blocked from listing or revising an item without these aspects."*"
— #11045 §1.2

**And the two Taxonomy operations disagree on it** — same tree, same version, same day: **33 of 421
aspects** carry `OPTIONAL` from `getItemAspectsForCategory` and `RECOMMENDED` from `fetchItemAspects`, *"no
other key differs"*, plus 18 more aspects over 289 further leaves (#11045 §5 C16, §4 U10-b).

**The other seven flags:** `aspectApplicableTo` (`ITEM` 19,206 / `PRODUCT` 87,560 — *"Sellers cannot change
the value of aspects that are based on a catalog product."*), `aspectDataType` (`STRING` 196,549 / `NUMBER`
482 / `DATE` 15 / `STRING_ARRAY` **0**), `aspectAdvancedDataType` (`NUMERIC_RANGE`, 25 of 197,046),
`aspectFormat` (`int32` 229 / `double` 101 / `YYYYMMDD` 12 / `YYYY` 3), `aspectMaxLength` (15,629 of
197,046, *"This field is only returned for instance aspects."*), `expectedRequiredByDate` (**6** of
197,046), `valueConstraints` (429,323 occurrences — conditional value logic between aspects)
(#11045 §1.2).

**Attributes used only by internal code, named by the vendor:**
- `STRING_ARRAY` — *"This enumeration value is reserved for internal or future use."* (#11045 §1.2)
- `relevanceIndicator` / `searchCount` — *"The relevance of this aspect. This field is returned if eBay has
  data on how many searches have been performed for listings in the category using this item aspect. Note:
  This container is restricted to applications that have been granted permission to access this feature…
  that you want access to 'Buyer Demand Data' in the Taxonomy API."* — and it is **0 of 197,046** in the
  corpus (#11045 §1.2).

**Buyer-facing filters: the record leaves it partially answered — and the 2026-09-19 collection closes
it.** #11045 establishes that aspects are Item Specifics on the listing (*"if the listing request includes
Item Specifics … that are associated with the `SecondaryCategory`, eBay drops those values"*, §1.1) and
that the axis order is display order (§1.5), but records **search refinement as not answered**: the Browse
API's `SearchPagedCollection.refinement` key was **absent** from the live response and the record never
quotes what it contains (§1.8, §4 U12-b).

**✅ Closed on two independent routes, 2026-09-19.** Route 1, eBay Seller Center, fetched live
(`corpus/ebay/sellercenter-item-specifics.txt:79,137`): *"**Buyers use item specifics to filter their
search results, and your item will only appear in those filtered search results if you've added the
matching item specific.**"* and *"…especially when buyers use the **left-hand navigation filters**."*
Route 2, the Buy Browse API contract itself (`corpus/ebay/openapi-buy_browse_v1_oas3.json`, v1.20.4) —
which could have disagreed, had aspects been seller-side metadata only: `Refinement.aspectDistributions`
— *"An array of containers for the all the aspect refinements."*; `AspectDistribution.localizedAspectName`
— *"The name of an aspect, such as Brand, Color, etc."*; `AspectValueDistribution.matchCount` — *"The
number of items with this aspect."*; and the query parameter `aspect_filter` — *"This field lets you filter
by item aspects."*, with eBay's own example
`…/item_summary/search?q=shirt&category_ids=15724&aspect_filter=categoryId:15724,Color:{Red}`.

**V2:** *"✅ **Nothing about the product decides it. The leaf category decides it, alone**: "Each category
has a different set of aspects and different requirements for aspect values.""* (#11045 §3).

---

## 5 · Walmart — **a per-slot PURPOSE tier on 100% of slots, and a different vocabulary per channel**

> "**⚠️ The requirement tier — a mechanism on 100% of the slots.** All **383,947** slots carry a `comments` string; **0** do not; **81** distinct values."
— #11046 §1.3

The five largest, verbatim (exact-value / substring counts):
| `comments` value | count |
|---|---|
| `@group=Recommended to improve search and browse on Walmart website` | 258,217 / 262,417 |
| `@group=Required for the item to be visible on Walmart website` | 58,595 / 72,769 |
| `@group=Recommended to create a variant experience on Walmart website` | **27,828** |
| `@group=Required to sell on Walmart website` | 13,781 / 13,917 |
| `@group=Condition Details` | 6,996 |

**This is the clearest statement in the thirteen of what an attribute is FOR**: sell · be visible · improve
search and browse · create a variant experience. And *"✅ **All four variant fields carry
`@group=Recommended to create a variant experience on Walmart website` on all 6,957 types that have them**
— 6,957 × 4 = **27,828**, the whole of that tier"* (#11046 §1.3).

**V3 — a different vocabulary per feed type**, which is a channel in all but name:
> "❗ **The maintenance feed uses a different tier vocabulary entirely** over its 345,763 slots / 78 values: `@group=Product Content to improve search & browse on Walmart website` 238,474 · `@group=Basic Item Info` 34,166 · `@group=Site Experience` 27,832 · `@group=Compliance & Regulatory` 17,414 · `@group=Images` 9,367. **This is the only systematic difference between the two feed types**"
— #11046 §1.3

plus a fourth vocabulary on `MP_ITEM_MATCH` (#11046 Companion C Edit 6), and a `businessUnit` enum
`["SAMSCLUB","WALMART_CA","WALMART_US","ASDA_GM"]` on the feed header (#11046 §1.1).

**⚠️ Per-attribute viewing/editing restrictions exist as workbook COLUMN HEADERS with no values reported**:
`Restrict Viewing by` · `Restrict Editing For` · `Requirement Level (MP)` · `Requirement Level (WFS)`
(#11046 §4 U12). `searchable`, `facet`, `attributeGroup`, `filterable`, `refinement` each occur **0** times
in the record.

**A display ranking that is published nowhere:**
> "*"How does Walmart determine the ranking of variant attributes and how they show up on the item page? Every subcategory or item type has a ranked list of variant attributes that defines how the attributes show up on the item page. For example, clothing items will always list the item's size first followed by the color."* The write side has **no ordering field** … and the ranked list is published nowhere (U8)."
— #11046 §2

**Internal/rule attributes** sit in the fixed `Orderable` block:
`country_of_origin_substantial_transformation`, `stateRestrictions`, `electronicsIndicator`,
`chemicalAerosolPesticide`, `batteryTechnologyType`, `MustShipAlone`, `automate_pricing`; plus
`isProp65WarningRequired` and `labelImage` as product-type slots whose conditional blocks fire on 628 types
(#11046 Companion C, §1.2, §1.x).

---

## 6 · Shopee — V1 flags on the definition, V2 by construction

`attribute_info` carries `input_type` (5 values), `input_validation_type` (5), `format_type` (2),
`date_format_type`, `attribute_unit_list`, `max_value_count`, `is_oem`, **`support_search_value`**; plus
`mandatory` on the attribute (#11047 §1.2). **`support_search_value` is the only filterability-shaped flag,
and the record quotes no description for it.**

**V2 by construction:** *"Each product category has different attribute data. The
`v2.product.get_attribute_tree` API will return the attribute data for the given `category_id`. However,
please note that **only last-level categories can retrieve attribute data.**"* (#11047 §1.2).

**Compliance-as-attribute, dated:** a 2026-01-23 announcement adds a blocking validation keyed to
`attribute_id` **101351** checked against government open data; three later announcements change which
category attributes are mandatory; two are titled *"Ativação do Atributo de Anvisa como obrigatório"*
[*Activation of the Anvisa Attribute as mandatory*] (#11047 deprecations). But tax, size chart,
certification, purchase limit and complaint policy are **fixed item fields, not attributes** (#11047 §1.3).

**No buyer-visibility flag is reported.**

---

## 7 · Tokopedia — **no visibility flag in either era**

**Era A:** the only per-attribute fields are `sort_order` on the Annotation group (a display-order field)
and `has_unit` / `status` / `is_primary` on the axis catalogue — and the record flags two of those as
*"defined in no table"* (#11048 §1.2, §1.4). `is_variant` **0** hits, `is_mandatory` **0** hits.

**Era B:** `id`, `name`, `type` (the role flag), `is_requried` [sic], `values[{id,name,icon_url}]`,
`value_data_format`, `is_customizable`, `requirement_conditions`, `is_multiple_selection`.
**No filterability, searchability, facet or buyer-visibility flag is reported on any Era-B attribute**
(#11048 §1.8).

**V2 + V3 in one sentence:** *"The list of standard built-in product and sales attributes that are bound to
the specified category, **based on your shop's location**."* (#11048 §1.8) — and `listing_platforms`
(`TOKOPEDIA | TIKTOK_SHOP`) is a per-product channel field (#11048 §1.6), with the category tree itself
filterable by `listing_platform` (#11048 §1.9).

**Product-level visibility, not attribute-level:** `is_not_for_sale` — *"…not for sale and only available
through Gift with Purchase (GWP) promotions. Such products won't appear in searches or recommendations"*
(#11048 §1.6).

**Internal-rule attributes, worked:** the EU unit-price rule pairs a magnitude on the SKU
(`sku_unit_count`) with the **unit carried as a product attribute served by Get Attributes** —
*"you would also need to define the "base unit count" and the "unit type" **product attributes**"*
(#11048 §1.7). And an Indonesian compliance attribute is named with real ids: *"partners will be required
to provide mandatory product attribute "Imported Goods" (Attribute ID `102254`, values `Yes` = `1000058` /
`No` = `1000059`)"* — one route only, so nothing is moved to VERIFIED on it (#11048 §1.8).

---

## 8 · Square — **V1 explicitly: two visibility enums on the definition** *(the card's pointer)*

> "| `seller_visibility` / `app_visibility` | enum (2) / enum (3) | 0..1 | `SELLER_VISIBILITY_READ_WRITE_VALUES` |"
— #11049 §1.7

⚠️ **The record never enumerates either enum whole and never quotes a per-value meaning** — the values that
appear do so as observed data: `SELLER_VISIBILITY_READ_WRITE_VALUES`, `SELLER_VISIBILITY_HIDDEN`,
`APP_VISIBILITY_READ_WRITE_VALUES`, and `APP_VISIBILITY_READ_ONLY_VALUES` which is **rejected live** as
`INVALID_ENUM_VALUE` while the field is declared a 3-value enum — a tension the record does not reconcile
(#11049 §1.7, §4 row 4). The bare forms `VISIBILITY_HIDDEN` / `VISIBILITY_READ_ONLY` /
`VISIBILITY_READ_WRITE_VALUES` occur **zero times**.

**The cap is expressed in visibility terms** — *"Each Square account can have up to 10 seller-visible and
10 seller-hidden custom attributes."*, live-verified at 10+10 (#11049 §1.x); scope unresolved (§5 #10).

**A second visibility lever, per object type, quoted whole:**
> "`ITEM` - Attributes are visible in the Square Dashboard and the API. / `ITEM_VARIATION` - Attributes are visible in the Square Dashboard and the API. / `MODIFIER` (2023-04-19 or later) - Attributes are visible only with the API. / `MODIFIER_LIST` (2024-04-17 or later) - Attributes are visible only with the API. / `CATEGORY` (2024-04-17 or later) - Attributes are visible only with the API."
— #11049 §1.7

**A per-channel fact stated in prose, not as a flag:** *"The Square Point of Sale application doesn't show
custom attributes for any object type."* (#11049 §1.7) — i.e. Square's till simply never shows them.

**V2: no.** *"✅ **Not one of the 11 properties scopes attributes**"* on `CatalogCategory`, and
*"a "flavour" definition allowed on ITEM appears on every item in the seller's catalogue"* — the vendor's
own words: *"Because most of the definitions can be set on items and item variations, they appear on every
item and item variation in the seller's catalog."* (#11049 §1.6, §3).

**Filterability:** no per-custom-attribute flag; searchability appears only on built-in fields
(`CatalogItemOption.name` — *"**This is a searchable attribute for use in applicable query filters.**"*;
`sku`; `abbreviation`) (#11049 §1.3, §1.5, §1.2).

---

## 9 · Salesforce B2C Commerce — **V2 is the design: attribute groups attach to categories, with a
precedence rule**

> "**✅ Attribute groups attach to a *category* as well as to an object type** … *"You create an attribute group to help you manage product attributes. **An attribute group is a grouping of attribute assignments that's attached to a category. Attributes can belong to more than one attribute group.** The attribute assignments display on the product details page and during some product comparisons."*"
— #11050 §1.7

**Three layers, quoted whole:**
> "1. **The global layer.** … *"the attribute groups of the system object type 'Product' (i.e. the global product attribute groups) and their bound attributes"*
> 2. **The classification-category layer.** *"the global product attribute groups / product attribute groups of the product's classification category / product attribute groups of any parent categories of the product's classification category"*. And *"If the product lacks a classification category, then only the global product attribute group is considered by the model."* Corroborated: *"The classification category defines the attributes of the product in the product catalog."*
> 3. **The browse-category layer.** `Category.getProductAttributeModel()` — *"the global product attribute groups / product attribute groups of the calling category / product attribute groups of any parent categories of the calling category"*."
— #11050 §3

**And an override precedence, still single-route:** *"If this model is associated with specific categories
…, then a category product attribute group might have the same ID as a global product attribute group. In
this case, the category group overrides the global one. / If a category and one of its ancestor categories
both define a product attribute group with the same ID, the sub-category group overrides the parent
group."* (#11050 §1.8, U1).

**The entry point is named:** *"On the product detail page, call `Product.getAttributeModel()` to get the
attribute model for the product."* (#11050 §1.8).

**V1:** the `@system : xsd:boolean` flag on the attribute reference (#11050 §1.7). No shown/hidden flag is
reported. **V3:** the nearest is the classification-vs-primary category split — *"The classification
category defines the attributes of the product in the product catalog, while the primary category defines
the breadcrumbs on the product details page."* (#11050 §1.5c).

⚠️ **Currency warning carried:** *"OCAPI is marked deprecated as of April 2026."*, and *"**The entire
`help.salesforce.com` corpus is unreproducible** … **Treat every Help-only claim here as
reported-not-verified**"* (#11050 §1.9, §4 U11).

---

## 10 · Akeneo PIM — **V3 is first-class, as requiredness; V1 carries the filter flag**

**Per-channel is a table:** `pim_catalog_attribute_requirement` carries `required` under
`uniqueConstraint (channel_id, family_id, attribute_id)` with all three joinColumns `nullable: false` —
*"emitted on the wire only inside a family, keyed by channel"* (#11069 §1.1). On the wire:
`"attribute_requirements":{"ecommerce":[…6…],"mobile":[…6…],"print":[…6…]}` (#11069 §2c).
**So Akeneo models "this attribute is required on the web but not at the till" exactly.**

**`scopable` is the per-channel flag on the definition** — and the record is careful: it carries the flag
(`is_scopable` in the mapping, `scopable` in the API, immutable) and **never prints a vendor definition of
it as "per channel"**; what it does print is that a scopable attribute **cannot be an axis**, on four
routes (`AXES_WRONG_TYPE`; *"Variant axes "%axis%" cannot be localizable, not scopable and not locale
specific"*; the spec rule; the help centre) (#11069 §1.4, §1.x, §5 C3). Every value carries
`{"locale": …, "scope": …, "data": …}` (#11069 §1.6).

**V1 — filterability:** `useableAsGridFilter` in the mapping / `useable_as_grid_filter` on the wire,
observed `true` on `auto_exposure` and on `color`. ⚠️ **The record carries no vendor sentence defining what
it does.** Plus `sort_order`, `group` (→ `AttributeGroup`), `unique`, `localizable`, `is_locale_specific`
(#11069 §1.4, §2c).

**V2 — measured absent, with controls:** Category → attribute returns **0** for every attribute-, family-
and axis-shaped pattern over 344 files / 729,922 B, with controls firing at 203 / 62 / 117
(#11069 §1.8). ❗ But a **separate** system attaches attributes to the category *record*:
`pim_catalog_category_attribute` with `is_required`/`is_scopable`/`is_localizable` — *"a different
hierarchy from `Akeneo\Pim\Structure\Component\Model\Attribute`"* (#11069 §1.8).

**Purpose, in the vendor's words:** *"The family helps managing the product's completeness as you can say
at the family level, which family attributes are required for the completeness calculation."*
(#11069 §1.1) — i.e. Akeneo's headline purpose for attributes is **completeness**, not display.

**No `visible`/`visibility` flag exists as an attribute flag anywhere in the record.**

---

## 11 · WooCommerce — **V1 per (product, attribute), and filterability is decided by global-vs-local**

`WC_Product_Attribute` carries `'visible' => false` → serialised as `is_visible` 1/0 in the product's
`_product_attributes` blob (#11080 §1.3). ⚠️ **The record carries the field and states no meaning for it**,
and never mentions an "Additional Information" table (0 hits).

On the **definition**: `attribute_public int(1) DEFAULT 1`, surfaced through REST as `has_archives`
(boolean, default false) — and the two disagree: *"**`attribute_public` defaults to 1 in the DDL and lands
as 0 through REST.**… Live: **all four** rows read back carry `attribute_public = 0`"*. **What an archive
*does* is not answered in the record** (#11080 §1.4, §5 #7).

**Filterability is structural, not a flag:**
> "✅ **The lookup table re-normalizes the variation's copied slug back to a term id, for global attributes only**. Local attributes are skipped with the source's own comment: `// Custom product attribute, not suitable for attribute-based filtering.`"
— #11080 §1.10

and it is gated by an option — *"it is consulted only when `'yes' === get_option(
'woocommerce_attribute_lookup_enabled' )`"*, whose value *"was not captured in any retrieval"*
(#11080 §1.10). The word *"layered"* occurs **0** times.

**Ordering is a purpose:** `attribute_orderby` — enum `menu_order|name|name_num|id`; and *"For variable
products, the sorting order of the attributes affects the sorting order of the dropdown selector(s) on the
product page."* (#11080 §1.4, §1.7).

**V2 — measured absent, with staged instruments and controls:** lines containing `product_cat` → **500**;
of those also matching `attribute_taxonom` → **0**; control `product_tag` → **12**; `is_variation` → 81,
with `product_cat|category` → **0**, control `is_visible` → 1 (#11080 §1.7).

**V3 — not answered in the record.**

---

## 12 · commercetools — V1, one flag, plus a deprecation caveat on the whole level mechanism

`AttributeDefinition` carries `isSearchable`, `inputHint` (`SingleLine|MultiLine`), `inputTip?`, `label`,
`isRequired`, `attributeConstraint`, `level` (#11081 §1.2). ⚠️ **The record states no meaning for
`inputHint` or `inputTip`.**

**The `isSearchable` caveat, whole:** *"⚠️ **Every `level: Product` caveat names a deprecated API.**
`AttributeLevelEnum` whole: `enum: [Product, Variant]`, "Product: Attribute is defined at Product level
(**not supported** by [Product Projection Search])… Variant: Attributes are defined at the Product Variant
level." … **Product Projection Search is deprecated**… The same caveat sits on `ProductData.attributes` and
on `AttributeDefinitionDraft.isSearchable`"* (#11081 §1.2). And type-level exclusions: `nested`/`set` —
*"It does not support `isSearchable` and is not supported in queries."* (#11081 §1.3).

**Which attributes are shown vs internal: not answered in the record.** The nearest is a **per-request**
choice: *"Variant-level Attribute names to include in the response. Must be provided at least once… Only
variant-level Attributes are returned. Product-level Attributes are silently omitted."*, on a read model
*"Designed for building attribute selectors on product detail pages (PDPs)."* (#11081 §1.8).

**V2 — measured absent:** `api/types/category/` is 29 files / 20,117 B with no `attributes`,
`attributeDefinitions` or `productType` property; *"**None of the ten reads a Category to gate a
constraint**"* (#11081 §1.10). ⚠️ The adjacent unmeasured mechanism is `Category.custom?: CustomFields`
(#11081 §1.10).

**V3 — not answered in the record.**

**A UI immutability rule worth carrying for A5:** *"which slot a definition uses is
`AttributeDefinition.level`, immutable in the UI ("The **Attribute level** option cannot be changed after
saving the Attribute.")"* (#11081 §2b).

---

## 13 · Magento / Adobe Commerce — **V1 at maximum resolution: one flag per use; V3 as value scope**

`catalog_eav_attribute` — **22 columns, whole**: `attribute_id` (PK, FK to `eav_attribute`), `is_global`,
`is_visible`, `is_searchable`, `is_filterable`, `is_comparable`, `is_visible_on_front`,
`is_html_allowed_on_front`, `is_used_for_price_rules`, `is_filterable_in_search`,
`used_in_product_listing`, `used_for_sort_by`, `apply_to`, `is_visible_in_advanced_search`, `position`,
`is_wysiwyg_enabled`, `is_used_for_promo_rules`, `is_required_in_admin_store`, `is_used_in_grid`,
`is_visible_in_grid`, `is_filterable_in_grid`, `frontend_input_renderer` — **plus two module extensions**,
`additional_data` (Swatches) and `search_weight` `float NOT NULL default 1` (CatalogSearch)
(#11082 §1.3).

**⚠️ The record states a meaning for only four of the 22** (`is_global`, `apply_to`, partially
`additional_data`, and `is_visible` by its use in `canUseAttribute()`); **for 18 of them, including
`is_visible_on_front`, `is_filterable`, `used_in_product_listing`, `used_for_sort_by` and
`is_used_for_promo_rules`, no meaning is stated in the record** (#11082 §1.3).

**✅ That gap is closed at source, 2026-09-19**, from `magento/magento2` @ `874f1f5c` (2026-09-17) and
Adobe's live storefront-properties page. Three additions the record does not carry:
1. **The merged table has 24 columns**, not 22: `search_weight float NOT NULL default 1`
   (`CatalogSearch/etc/db_schema.xml:11-12`) and `additional_data text`
   (`Swatches/etc/db_schema.xml:11`) are added to the same `<table>` block by other modules.
2. **Defaults**: `is_global` and `is_visible` default to **`1`**; every other flag defaults to `0`
   (`Catalog/etc/db_schema.xml:1050-1106`).
3. **`is_filterable` is a three-valued enum, not a boolean** —
   `LayeredNavigation/Model/Attribute/Source/FilterableOptions.php`, whole:
   `['value' => 0, 'label' => __('No')]`, `['value' => 1, 'label' => __('Filterable (with results)')]`,
   `['value' => 2, 'label' => __('Filterable (no results)')]`. Its sibling `is_filterable_in_search` uses
   plain `Yesno`. Both fields carry the Admin notice, verbatim: *"Can be used only with catalog input type
   Yes/No (Boolean), Dropdown, Multiple Select and Price."*

Adobe's per-flag meanings are quoted in `ATTR-DEF.md` §A0.3. **Two gaps remain**: 8 of the 24 columns are
named by no Adobe page, and **`is_used_for_price_rules` is written by no `PropertyMapper`** — an
instrumented search of the 36 MB `app/` tree returns 4 files, two of them `@method` docblocks.

**⚠️ No instance of `catalog_eav_attribute` was ever retrieved** — only a storefront projection whose field
names *differ* from the column names (`use_in_product_listing`, `use_in_layered_navigation:
"FILTERABLE_WITH_RESULTS"` vs the columns `used_in_product_listing`, `is_filterable`), and *"the record does
not map them"* (#11082 §2c).

**V3 — per-store-view scope, whole:** `ScopedAttributeInterface` (268 B) —
`const SCOPE_STORE = 0;  const SCOPE_GLOBAL = 1;  const SCOPE_WEBSITE = 2;` (#11082 §1.3). Values are
scoped structurally: `UNIQUE (entity_id, attribute_id, store_id)` on every value table, and option labels
are `UNIQUE (store_id, option_id)` (#11082 §1.9, §1.7). *"You can enter one value for the Admin, and a
translation of the value for each store view."* (#11082 §1.7).

**Internal-rule attributes exist as flags:** `is_used_for_promo_rules` and `is_used_for_price_rules` are
columns (#11082 §1.3). And a documentation-history fact: a 2025-09-10 commit **removed** the row
``|[!UICONTROL Use for Promo Rule Conditions]|`Yes`|`` from the axis-requirement table it had added on
2025-03-21 (#11082 Deprecations D7).

**V2 — measured absent, with a same-corpus control:** over the **352** `<table>` blocks of 67
`db_schema.xml` files, tables declaring a category column **and** any attribute column → **0**; control
(both `category_id` and `product_id`) → **5**. *"Revision 1's "the browse category never gates axes" is
withdrawn."* (#11082 §1.4). What gates data entry is the **attribute set**: *"The attribute set determines
the fields that are available during data entry, and the values that appear to the customer."*
(#11082 §1.2).

---

## Tallies

### Is there a per-attribute visibility / filterability / purpose control on the DEFINITION? (V1)

| Answer | Count | Platforms |
|---|---|---|
| **Yes** | **10** | Amazon (`hidden`, `editable`) · Shopify (`access`, `capabilities`, `pinnedPosition`) · eBay (11 per-aspect flags) · Walmart (the `@group=` purpose tier on 100% of slots) · Shopee (`support_search_value`, `mandatory`) · Square (`seller_visibility`, `app_visibility`) · Akeneo (`useable_as_grid_filter`, `scopable`) · WooCommerce (`is_visible`, `attribute_public`) · commercetools (`isSearchable`) · Magento (**24** columns on the merged `catalog_eav_attribute`, ~18 of them behaviour flags) |
| **No / not established** | **3** | **Google** (no per-attribute flag; destination controls are per *product*) · **Tokopedia** (neither era carries one) · **Salesforce B2C** (visibility is achieved by attaching an attribute *group* to a category, not by a flag) |

**10 of 13 put at least one such control on the definition.** That is the strongest signal in this card.

**Named hedges that travel into the tally:**
- **Square** — the two enums are cited by **arity only**; the record never enumerates them or quotes a
  per-value meaning, and a plausible third `app_visibility` value is rejected live as `INVALID_ENUM_VALUE`.
- **Magento** — the flags exist as columns (22 declared in `Catalog`, **24** merged with `CatalogSearch`'s
  `search_weight` and `Swatches`' `additional_data`); **18 have no meaning stated in the record** and **no instance of
  the table was ever retrieved**.
- **Akeneo**, **WooCommerce**, **commercetools** — the flags exist; the records quote **no vendor
  definition** of `useable_as_grid_filter`, `is_visible` or `inputHint`.
- **Walmart** — the `@group=` tier is a *purpose* tier, not a visibility flag; per-attribute
  viewing/editing restrictions exist only as **workbook column headers with no values reported**.

### Is visibility scoped per category? (V2)

| Answer | Count | Platforms |
|---|---|---|
| **Category decides which attributes EXIST** (membership) | **8** | eBay · Walmart (per product type) · Shopee · Tokopedia (both eras) · Amazon (per product type) · Salesforce · Google (requiredness only) · Shopify (opt-in `constraints`) |
| **Category decides nothing about attributes** | **5** | Square · Akeneo (the **family** decides) · commercetools (the **ProductType** decides) · WooCommerce · Magento (the **attribute set** decides) |

**8 + 5 = 13.** ⚠️ The published count of **4** on row 2 was an arithmetic error and the counting note that
tried to absorb it — *"Google sits in the first row on requiredness only"* — was a non-sequitur, since
Google is already counted in row 1. Corrected 2026-09-19; no platform moves rows, only the number.
**The important finding is not the count but the kind:** in every platform where a category-like object is involved, it decides **membership** (which
attributes a product has), not **visibility** (whether a carried attribute is shown). The single exception
that frames it as applicability rather than membership is Shopify's conditional metafields —
*"some metafield definitions should only apply to a subset of resources"* — and even there the effect is
"appears on the product page in the admin", i.e. membership in the editor.

**Consequence for A0, labelled as judgement:** the card's option "per category membership (Rasa shown for
food, hidden for cleaning products)" is, on the evidence, **not a visibility mechanism anywhere** — it is
A3's membership question. A0 should not spend a flag on it.

### Is visibility scoped per channel? (V3)

| Answer | Count | Platforms |
|---|---|---|
| **Per-channel *visibility of the definition*** | **1** | **Shopify** — `access {admin, storefront, customerAccount}` |
| **Per-channel *values or requiredness*** | **4** | Akeneo (`AttributeRequirement` keyed `(channel_id, family_id, attribute_id)`; `scopable`) · Magento (`SCOPE_STORE/WEBSITE/GLOBAL`, values keyed by `store_id`) · Amazon (per-`marketplace_id` selector on every value) · Walmart (a different `@group=` vocabulary per feed type) |
| **Per-channel at the *product* level only** | **3** | Google (`excludedDestinations`, `pause`) · Tokopedia (`listing_platforms`) · Square (per object type + *"The Square Point of Sale application doesn't show custom attributes for any object type."*) |
| **Not answered** | **5** | eBay · Shopee · Salesforce B2C · WooCommerce · commercetools |

**Judgement, labelled:** per-channel is real but almost never means "hide this attribute on this channel".
It means "this attribute has a different **value** or a different **requiredness** per channel". Only
Shopify expresses per-channel *visibility* on the definition, and it does so with a three-valued access
triple rather than a boolean.

### The A0↔A5 coupling — visibility per channel vs per level (owned here; FAMILY cites this)

Two platforms carry both a level field and a visibility/searchability field **on the same definition
object, as independent fields**:
- **commercetools**: `AttributeDefinition.level : AttributeLevelEnum` (`Product|Variant`, *"immutable in
  the UI"*) sits beside `isSearchable` (#11081 §1.2, §2b).
- **Shopify**: `MetafieldDefinition.ownerType : MetafieldOwnerType!` (26 values, including both `PRODUCT`
  and `PRODUCTVARIANT`) sits beside `access` and `capabilities` (#11011 §1.8).

**Neither derives one from the other, and no record in the thirteen ties them.** So: *the level a fact
lives at (A5) and the channels it is shown on (A0) are orthogonal properties of one definition row.* A
design that makes visibility depend on level — e.g. "family-level attributes are shown, member-level ones
are not" — has **no precedent in the thirteen**.
