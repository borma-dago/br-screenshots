# matrix-A1.md — where each of the thirteen draws the column-versus-attribute line

Full evidence table for `ATTR-DEF.md` §A1 step 2. Every cell is the record's own words with a section cite.
**Options:** **O1** a substantial fixed core of built-in fields **plus** an extensible attribute system ·
**O2** everything is an attribute (only identity/structure stays outside) · **O3** a large built-in core
plus a **capped** small set of custom fields.

Tokopedia's two eras are given separately and never merged.

---

## 1 · Amazon — **O2** (write path), with a named hedge

> `"product_identity": { "title": "Product Identity", "description": "Information to uniquely identify your product (e.g., UPC, EAN, GTIN, Product Type, Brand)", "propertyNames": [ "item_name", "brand", "external_product_id", "gtin_exemption_reason", "merchant_suggested_asin", "product_type", "product_category", "product_subcategory", "item_type_keyword" ] }`
— #10976, `definitionsProductTypes_2020-09-01.json` comment (= [E-1])

The seven property groups are `offer` · `images` · `shipping` · `variations` · `safety_and_compliance` ·
`product_identity` · `product_details` (#10976 §1.2). So price (`list_price` inside `offer.propertyNames`),
images (`main_product_image_locator` inside `images.propertyNames`), weight
(`"Information to determine shipping and storage of your product (e.g., package dimensions, weight,
volume)"`) and the title are all **properties of the product-type definition**. `item_name`,
`brand` and `product_description` sit in the schema's root `required` array for `PET_FOOD` (#10976 Tier-3
§2.1).

**Hedges that travel into the tally:**
- `sku` is outside: *"| `sku` | string PK | **a URL path parameter, never a schema attribute** |"* (#10976 §1.7).
- The schema is not universal: *"⚠️ 2026-09-02: **not universal** — `getListingsItem` returns attributes "not part of the Product Type schema""* (#10976 §1.1).
- The read side keeps scalars beside the bag: `ItemSummaryByMarketplace.brand` — *"Name of the brand that is associated with the Amazon catalog item."*, `.itemName`, `.manufacturer`, `.color`, `.size`, `.style`; plus first-class `identifiers`, `images`, `dimensions`, `classifications`, `relationships`, `salesRanks` blocks on `Item` (#10976 §1.6).
- The attribute bag is declared open: `"ItemAttributes": { … "additionalProperties": true, "type": "object" }` (#10976 §1.6); and root closedness was never verified — *"no root `additionalProperties: false` was ever retrieved ([E-18]: `true` ×3, `false` ×0)"* (#10976 §2c).
- Third-party-sourced schema dumps are **P2/P3**: *"Nothing here may be restated as "Amazon's schema says X"."* (#10976 Tier-3 supplement, tier warning) — the property-group quote above is from Amazon's own sandbox response, not from those dumps.

**Definition vs value:** modelled as `Attribute` (name PK) + a `ProductTypeAttribute` join carrying
`marketplaceId`, `parentageLevel` and requiredness — *"❗ Requiredness is a property of this join, not of
the Attribute."* (#10976 §1.4). But the typing half is open: *"| `type` / `constraints` / `enum` | — |
❓**UNKNOWN** on the JSON side"* (#10976 §1.3). **Population: 2,336 distinct JSON attribute names**
(#10976 §1.3); **213 product types → 208 distinct attributes, 1,154 pairs; 107 of 208 used by exactly one
type** (#11031 verification comment §2).

**Brand:** an attribute (`product_identity` property), **and** a read-side scalar, **and** a search
refinement type (`BrandRefinement { numberOfResults, brandName }`, #10976 §1.6). No brand-registry entity
appears anywhere in the record. Amazon's family rule: *"Terms like "item type keyword," "model name,"
"style," and "brand" are key non-varying attributes for which all child ASINs must have the same values."*
(#10976 §2).

**Cap:** none published. Per-attribute caps only (`maxUniqueItems`, `maxUtf8ByteLength`).

---

## 2 · Shopify — **O1**

`Product` has **83 fields**, `ProductVariant` **52** (#11011 §1.1, §1.2). Built-in and outside the metafield
system: `title`, `handle`, `descriptionHtml`, `productType`, `vendor`, `tags`, `category`, `options`,
`price`, `compareAtPrice`, `sku`, `barcode`, `inventoryItem`.

**The weight pointer, answered:**
> "**❗ There is no `weight` field on `ProductVariant`.** Instrument: a search of all **26,781 B** of the live introspection response and all **84,912 B** of `ProductVariant.md` for `weight|Weight|grams|mass|measurement` returns **no `ProductVariant` field**. Weight reaches the variant only via `inventoryItem: InventoryItem!` → `InventoryItemMeasurement { weight: Weight }` → `Weight { unit: WeightUnit!, value: Float! }`"
— #11011 §1.2

Live: `"inventoryItem":{…,"measurement":{"weight":{"value":0.5,"unit":"KILOGRAMS"}}}`, and the REST view of
the same variant carries `"grams":500,"weight":0.5,"weight_unit":"kg"` directly (#11011 §2c′). **So weight
is a built-in field on both surfaces and is not a metafield — the card's premise holds, with the
correction that on GraphQL it hangs off `InventoryItem`, not `ProductVariant`.** Length/width/height are
**not answered in the record**.

**The extension:** `MetafieldDefinition`, 17 fields, *"the second attribute surface"* (#11011 §1.8), owner
types include both `PRODUCT` and `PRODUCTVARIANT` (26 values, #11011 §1.8). A **value may be written with
no definition at all** — `metafieldsSet` with an undefined namespace/key returns `"userErrors":[]` and the
metafield carries `"definition":null` (#11011 §1.8). **48 basic + 12 reference + 53 list data types**, and
*"the value is always entered and stored as a string, regardless of type"* (#11011 §1.8).

**The second definition surface:** the taxonomy — 14,606 categories, **93,007 category→attribute edges**,
**8,240 base attributes + 316 extended**, 74,820 distinct values; `color` on 10,927 categories, `flavor` on
**293** (#11011 §1.7). But *"**0 of `Product`'s 80 fields** … match /attribute/i"* — the taxonomy declares,
the metafield definition carries (#11011 §1.7).

**Brand:** `vendor: String!` — *"The name of the product's vendor."*, free text, **no enum, no
validations** (#11011 §1.6). The string `brand` occurs **zero times** in the record; whether `vendor` is
the brand is **not answered in the record**.

**Cap:** a metafields-per-product cap is **not answered in the record**.

---

## 3 · Google Merchant Center — **O1**, with no definition object at all

> "**❗ There is no per-category attribute schema.** The bag is **one global, ~~flat, strongly-typed~~ set**: **145** properties in Merchant API `products_v1`, **95** in `products_v1beta`, **104** on Content API v2.1 `Product`. The human specification documents **85** attributes"
— #11013 §1.3

Every named fact is one of the 145 flat properties: `title`, `description`, `price`, `gtins`, `brand`,
`imageLink`, `productWeight`, `productLength/Height/Width`, `shippingWeight`, `googleProductCategory`,
`productTypes`, `color`, `size`, `material`, `pattern`, `itemGroupId`, `variantOptions`, `productDetails`
(#11013 Companion D). **Four open merchant-named bags** sit beside them: `customAttributes`
(*"Maximum 2500 custom attributes can be set per product, with total size of 102.4kB."*, and `CustomAttribute`
is recursive), `productDetails` (*"Yes, up to 100."*), `cloudExportAdditionalProperties`
(*"Extra fields to export to the Cloud Retail program."*) and `variantOptions` (#11013 §1.3).

`product_detail` is the generic spec-sheet bag — Google's own suggested keys include *"**Scent**: Scents or
fragrances of the product · **Flavor**: Flavors or taste of the product"* and
*"Note that this is not a comprehensive or exhaustive list."* (#11013 §3).

**Definition object: none.** The 145 property names *are* the schema; the open bags are `{name, value}`
with no definition. Category gates **requiredness**, not existence — and the record struck its own stronger
claim: *"**❗ Category gates *requiredness*~~, never *existence*~~.** ~~Every attribute exists on every
product…~~"* (#11013 §1.4), because `subscription_cost` is *"Use for approved product categories only."*

**Brand:** a flat field, `Max 70 chars`, *"**Required** (For all new products, except movies, books, and
musical recording brands) · Optional for all other products"* (#11013 Companion A row 26). No brand
resource found; the instrument was run for `group|cluster|variant`, not for brand (#11013 §4 U16).

---

## 4 · eBay — **O1**

Built-in on the Inventory API's `Product`: `brand`, `ean`, `epid`, `isbn`, `mpn`, `upc` —
*"| **Variant only** (`Product`) | `brand` · `ean` · `epid` · `isbn` · `mpn` · `upc` — **every product
identifier is variant-level** |"* — plus `title`, `description`, `imageUrls`, `subtitle`, `videoIds`, and
`aspects` (#11045 §2b). Price/quantity live on the `Offer`, never on the group (#11045 §2b).

**The extension:** the aspect, owned by the leaf category. *"Each category has a different set of aspects
and different requirements for aspect values."* (#11045 §1.1). **197,046 aspects over 15,111 sandbox
leaves** (#11045 §1.1 X1, §1.2). The aspect has **no id**: an item's values are `aspects` = `{name:
[strings]}`; on Trading the same data is `NameValueListArrayType`.

**Definition vs value:** `AspectConstraint` has **exactly 11 properties** (#11045 §1.2) and is the
definition — but it is identified only by `localizedAspectName` within a category, so it is a *per-category
definition without an identity*. Value caps: name 40 chars, value 50 chars; 30 values per multi-value
aspect (#11045 §1.10).

**Brand:** **both** — a built-in `Product.brand` field *and* an aspect name. And the catalog overrides
it: *"If a match is found based on the ePID or GTIN value, **the product aspects that are defined for the
eBay Catalog product will automatically get picked up**"* and *"**Sellers cannot change the value of
aspects that are based on a catalog product.**"* (#11045 §1.3, §1.2).

**Cap on aspects per item:** not published — *"❗ **The Inventory API path publishes no numeric variation or
axis cap.**"* (#11045 §1.10).

---

## 5 · Walmart — **O1**, and the cleanest published instance of the line

Two fixed blocks, `Orderable` and `Visible`, and nothing else:
> `MPItem  1..N  minItems 1; items required ["Visible","Orderable"], additionalProperties false`
> `Orderable  23 properties  required ["sku","productIdentifiers","price","ShippingWeight","country_of_origin_substantial_transformation"]`
— #11046 §1.1

`Orderable`'s 23, whole: `sku`, `productIdentifiers`, `price`, `ShippingWeight`,
`country_of_origin_substantial_transformation`, `inventory`, `stateRestrictions`, `electronicsIndicator`,
`chemicalAerosolPesticide`, `batteryTechnologyType`, `fulfillmentLagTime`, `shipsInOriginalPackaging`,
`MustShipAlone`, `IsPreorder`, `releaseDate`, `startDate`, `endDate`, `externalProductIdentifier`,
`ProductIdUpdate`, `SkuUpdate`, `msrp`, `automate_pricing`, `product_package_dimensions_and_weight`
(#11046 Companion C · Edit 4 §1.1).

**`Visible` is the per-product-type attribute set**, and it is where the *merchandising* facts live —
`productName`, `brand`, `shortDescription`, `mainImageUrl`, `netContent`, `flavor` are all product-type
attribute slots, and for `Toothpastes` they are in that type's `required` array (#11046 §1.2).

**Counts:** 6,967 product types · **383,947 attribute slots** · **6,576 distinct names** · 28…183
attributes per type (#11046 §1.2).

**Definition object: none on the write path.** *"Every attribute is written out in full at every product
type; **nothing is referenced**."* — `"$ref"` **0**, `"$id"` **0**, `"definitions"` **0**, `valueId` **0**,
`attributeId` **0** over 451,013,258 B (#11046 §1.3, §2). ⚠️ **With the record's own scope correction:**
*"that is about the **feed** schemas only. The read-side OpenAPI document **does** use references —
`"$ref"` occurs **2** times… **"no shared definition anywhere in the published schemas" would be too
broad.** The read side returns values, never ids."* And the same name gets different definitions per type: `color` **126**
distinct definitions, `size` **438**, `flavor` **50** (#11046 §1.3).

**The governance vocabulary is a description prefix:** `"Closed List - …"` (has an `enum`) ·
`"Alphanumeric, N characters - …"` · `"Number, Value range: A to B - …"` · `"Decimal, Value range: A to B -
…"` (#11046 §1.3).

**Brand:** a product-type attribute slot, required for `Toothpastes`. (The deprecated 4.x generation put
`brand` and `productName` in the offer block instead — #11046 §1.1.)

**Cap:** none — `maxItems`/`maxContains`/`maxProperties` = **0** by parsed key scan, with controls firing
(#11046 §1.x).

---

## 6 · Shopee — **O1**

The item's own fixed fields (#11047 §1.3): `item_name` REQ, `description` REQ, `original_price` REQ,
`weight` REQ, `item_sku`, `item_status`, `has_model`, `condition`, `gtin_code`,
`brand {brand_id int32 REQ, original_brand_name string REQ}`, `image`,
`dimension {package_height, package_length, package_width}`, `pre_order`, `logistic_info` REQ, `wholesale`,
`tax_info | size_chart_info | certification_info | purchase_limit_info | complaint_policy`, `seller_stock`,
`price_info`. Plus `attribute_list` — the category-scoped extension.

**Definition object: yes, with shared value rows.** `get_attribute_tree(category_id)` returns
`attribute_id`, `name`, `mandatory`, `attribute_value_list[{value_id, name, value_unit,
child_attribute_list}]`, and `attribute_info{input_type (5 values), input_validation_type (5),
format_type (2), date_format_type, attribute_unit_list, max_value_count, is_oem, support_search_value}`
(#11047 §1.2). *"only last-level categories can retrieve attribute data."* (#11047 §1.2).

**A typed attribute value carries a unit; the axis label does not:** *"the "name" field in the
"attribute_value_list" will return the value of the attribute (i.e. 5kg), while the "value_unit" field will
return the unit"* — and in the variation corpus `value_unit` → 0, `format_type` → 0 (#11047 §1.2).

**Brand:** a **reference to a platform-owned brand entity** — `brand_id : int32` required. A
`get_brand_list`-style endpoint is **not answered in the record**.

**Cap:** *"❓ **no documented cap**"* on attributes per item (#11047 §1.9).

---

## 7 · Tokopedia — **two eras, never merged**

**Era A (terminated 2025-09-30) — O1.** Fixed product columns: `name` ≤70, `category_id`, `price`,
`price_currency`, `status`, `stock`, `min_order`, `weight`, `weight_unit`, `condition`, `sku` ≤50,
`description` ≤2000, `dimension`, `annotations []string`, `etalase`, `variant` (#11048 §1.1). The
extension is the **Annotation** — *"This endpoint retrieve list of product annotation (product
specification) based on category ID."* — whose group is a bare `variant` **string name with no id**, with
`sort_order` and `values[{id, name, data}]` (#11048 §1.4). **No brand field and no GTIN field appear in the
Era-A create body at all.**

**Era B — O1.** 34 depth-0 Product fields including `title`, `description`, `category_id`, `brand_id`,
`main_images`, `package_dimensions`, `package_weight`, `product_attributes`, `certifications`,
`size_chart`, `search_terms`, `key_product_features` (#11048 §1.6). **The Product carries no price, no
inventory and no product identifier** — those are SKU-level (`skus.price`, `skus.inventory`,
`skus.identifier_code` with the `GTIN|EAN|UPC|ISBN|JAN` enum) (#11048 §1.6, §1.11).

**Definition object: yes.** `GET /product/202309/categories/{category_id}/attributes` returns `id`, `name`,
`type`, `is_requried` [sic], `values[{id, name, icon_url}]`, `value_data_format`, `is_customizable`,
`requirement_conditions`, `is_multiple_selection` — *"The list of standard built-in product and sales
attributes that are bound to the specified category, **based on your shop's location**."* (#11048 §1.8).

**Vendor's own definition of what an attribute is for:**
> *"**Attribute**: Attributes are supplementary content of product information. Attributes are associated with categories. For a particular category, some attributes are required while others are optional. Attributes can be further divided into product attributes and sales attributes.*
> *\* **Product attributes** are general attributes such as manufacturer, country of origin, materials used)*
> *\* **Sales attributes** are attributes that are specific to the variant (aka SKU) of a product such as size, color, length."*
— #11048 Companion C §2

**Brand:** Era B, a **reference to a platform-owned Brand entity** — `brand_id` at depth 0, and the vendor's
own sample warning `"The [brand_id]:123 field is incorrect and has been automatically cleared by the
system. Reason: [Brand does not exist]."` (#11048 Companion C §2c). No Brand instance was retrieved (U11).

**Cap:** an attribute-count cap is not established; the one error-side number is ambiguous —
`12052525` *"The attribute max num cannot exceed 3."* — *"says "attribute", not "sales attribute""*
(#11048 §1.11, U2).

---

## 8 · Square — **O3**, the card's own example, with the cap's scope unresolved

`CatalogItem` — **27 defined properties, enumerated whole**: `abbreviation`, `buyer_facing_name`,
`categories`, `category_id`(DEPRECATED), `channels`, `description`(DEPRECATED), `description_html`,
`description_plaintext`, `ecom_image_uris`(DEPRECATED), `ecom_seo_data`, `ecom_uri`(DEPRECATED),
`food_and_beverage_details`, `image_ids`, `is_alcoholic`, `is_archived`, `is_taxable`, `item_options`,
`kitchen_name`, `label_color`, `modifier_list_info`, `name`, `product_type`, `reporting_category`,
`skip_modifier_screen`, `sort_name`, `tax_ids`, `variations` (#11049 §1.2).
Price, SKU and UPC are on the **variation**: `price_money`, `sku` (*"This is a searchable attribute…"*),
`upc` (*"…where this attribute shows in the GTIN field."*), `measurement_unit_id` (#11049 §1.5, §2b).

**The extension, and its cap:**
> "| **10 + 10 custom attributes ~~per account~~** ⚠️ 2026-09-05: scope unresolved — the live error names `app_id` | *"Each Square account can have up to 10 seller-visible and 10 seller-hidden custom attributes."* ⚠️ live — 10 `SELLER_VISIBILITY_READ_WRITE_VALUES` definitions → 10× HTTP 200, the 11th → HTTP 400 `ITEMS_CUSTOM_ATTRIBUTE_LIMIT_EXCEEDED` … `"…Maximum number of read/write custom attribute definitions for app_id … exceeded limit of 10"`; 10 `SELLER_VISIBILITY_HIDDEN` → 10× 200, the 11th → 400 … |"
— #11049 §1.x

**The hedge, verbatim:** *"One vendor page … states in its Limitations list `"Each Square account can have
up to 10 seller-visible and 10 seller-hidden custom attributes."` and in its body `"An application can
create up to 10 seller-visible custom attribute definitions…"`. The live rejection reads `"…for app_id
…"`. **Three statements, two scopes. Not resolved.**"* (#11049 §5 #10).

**Definition vs value:** `CatalogCustomAttributeDefinition` (12 properties, `required ["type","name",
"allowed_object_types"]`, `key` immutable, `type` ∈ STRING|BOOLEAN|NUMBER|SELECTION) vs
`CatalogObject.custom_attribute_values`, a map keyed by the definition's `key` landing in
`string_value`/`number_value`/`boolean_value`/`selection_uid_values` (#11049 §1.7, §1.8). *"✅ **A
custom-attribute value is inline, not a shared row**"* (#11049 §1.8) — note the contrast with option
*values* (§ matrix-A2).

**Weight/dimensions:** not a product field; the variation points at a `CatalogMeasurementUnit`
(`weight_unit: METRIC_KILOGRAM`, …) (#11049 §1.8, Companion C §C11).

**Brand:** not answered; the only occurrence is a custom-attribute key example, `"cocoa_brand"`
(#11049 §1.8). `CatalogObjectType` has 19 values and none is a brand (#11049 §1.1).

---

## 9 · Salesforce B2C Commerce — **O1**

One `Product` row for every role (#11050 §1.1). `catalog.xsd`'s `complexType.Product` opens with `ean`,
`upc`, `unit`, `unit-quantity` (`xsd:decimal`), `unit-measure` (`String.60`), then
`classification-category`, `variations`, `images`, `product-set-products`, `bundled-products`,
`custom-attributes` (#11050 §1.1, §1.4). *"Products are identified by a unique product ID, sometimes called
the SKU."* (#11050 §1.1).

**Definition object: yes, three-level.** `ObjectTypeDefinition` → `ObjectAttributeGroup` →
`ObjectAttributeDefinition`, with `unit : String` — *"The attribute's unit representation such as inches
for length or pounds for weight."* — and `valueTypeCode` (18 constants) against the XSD's
`simpleType.AttributeType` (16 values). **The two disagree**: the Script API has `VALUE_TYPE_MONEY` and
`VALUE_TYPE_QUANTITY`; the XSDs have neither (#11050 §1.7, §5 C7).

**The system/custom switch** is `@system : xsd:boolean default="false"` on the attribute *reference*
(#11050 §1.7); the REST projection prefixes custom attributes `c_` (#11050 §1.5). **Which named facts are
system vs custom is not answered in the record.**

**Brand:** **zero occurrences** of the string in the whole record.

---

## 10 · Akeneo PIM — **O2**, the purest case

Non-attribute fields on `pim_catalog_product`, whole: `uuid`, `id`, `identifier`, `enabled` (`is_enabled`),
`rawValues` (`raw_values`), `created`, `updated`, `rawQuantifiedAssociations`, plus the edges `family`,
`parent`, `familyVariant`, `groups`, `categories`, `associations`, `uniqueData` (#11069 §1.7). **Everything
describing the product's content is an attribute**, and the 19 CE attribute types include
`pim_catalog_identifier`, `pim_catalog_price_collection`, `pim_catalog_image`, `pim_catalog_metric`
(#11069 §1.4).

- Title → an attribute, nominated by the family: `attributeAsLabel` = `name` (#11069 §1.1, §2c).
- Price → `pim_catalog_price_collection`; measured live on vendor fixtures (`price-EUR` non-empty on 187 of
  1,239 products) (#11069 §2b q10).
- Images → `pim_catalog_image`, three in the fixtures; the family nominates `attributeAsImage` = `picture`.
- SKU → `pim_catalog_identifier`, and *also* a mapped `identifier` column — the record carries both.
- Weight → `pim_catalog_metric`, typed: `"weight":[{…,"data":{"amount":"800.0000","unit":"GRAM","symbol":"g"}}]` (#11069 §2c).
- Barcode → **no such concept**: whole-word `barcode|gtin` over 6,741 files / 17,564,983 B → **0 files**,
  positive control `price` → 89 files (#11069 §1.x, §2b).

**Definition object:** `pim_catalog_attribute` with ~30 columns, including `is_required`, `is_unique`,
`is_localizable`, `is_scopable`, `sortOrder`, `useableAsGridFilter`, `metricFamily`, `defaultMetricUnit`,
`group` FK; **type is immutable** (#11069 §1.4). Values live in `raw_values` JSON as
`{"locale": …, "scope": …, "data": …}`; option values are shared `AttributeOption` rows while the product
**copies the code string**, with *"Referential integrity is a validator, not a foreign key"* (#11069 §1.5).

**What decides which attributes a product carries: the Family, never the category.** *"A product can belong
to only one family."* · *"a product does not have to belong to a family. In this case, it has no default
attributes."* (#11069 §1.1). Category → attribute: **0 hits over 344 files / 729,922 B** with controls at
203 / 62 / 117 (#11069 §1.8).

**Brand: Akeneo ships BOTH designs, and this is the most useful brand row in the matrix.**
- *As an attribute*, in Akeneo's own demo catalogue: `brand;Brand;Brand;Marque;…;marketing;0;…;pim_catalog_simpleselect;0;0`
  with option `akeneo;;Akeneo;;brand;1`
  (`corpus/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev/attributes.csv:75`,
  `attribute_options.csv:114`), and `camera_brand` likewise with `canon_brand`/`nikon_brand` options — the
  vendor's published JSON is `{"code":"canon_brand","attribute":"camera_brand","sort_order":1,"labels":{…}}`
  (#11069 §2c).
- *As an entity*, in the EE documentation, where **brand is the first example given**:
  *"Reference entities are objects that are related to products but have their own attributes and
  lifecycle. **A reference entity can be for example the brands**, the ranges, the manufacturers, the
  colors, the materials or the care instructions… And so many other entities."* —
  *"Available in the PIM versions: 3.x 4.0 5.0 6.0 7.0 SaaS | Available in the PIM editions: **EE**"*
  (`corpus/akeneo/brand-reference-entities.txt:290`). A published instance:
  `{ "code" : "brand", "labels" : { "en_US" : "Brand", "fr_FR" : "Marque" }, "image" : "0/2/d/6/54d81…_ref_img.png" }`.
- **The trigger, in the vendor's own words** (`corpus/akeneo/brand-help-104-serenity-what-is-a-reference-entity.txt:96-97`):
  *"Some information are shared between different products (such as care instructions, or colors or even
  brands). **This data can be complex to manage because it has its own attributes (e.g. a label, a logo, a
  description or photos). Those information may have dedicated pages on one's e-commerce website (e.g. a
  webpage describing a brand)** or their information may be used to enrich product pages (e.g. the logo of
  a brand)."* And: *"For the Brand reference entity, a record contains all the information regarding a
  brand like Kartell or Fermob. A record may be related to one or several products."*
- ⚠️ Reference entities are **EE-only** and their implementation is **not in `pim-community-dev`**;
  `akeneo_reference_entity` and `akeneo_reference_entity_collection` are declared as attribute types in CE
  (`AttributeTypes.php`) with nothing behind them. **No Record instance was retrieved** — route: an EE
  `GET /api/rest/v1/reference-entities/brand/records`.
- Instrument: `grep -ci brand` over `Product.orm.yml` (3,328 B) → **0**; over all 8 `.orm.yml` files under
  `src/Akeneo/Pim/**/config/doctrine/` → **0 files**. Brand is nowhere in the product mapping.

---

## 11 · WooCommerce — **O1**

> "WooCommerce stores none of these objects in a table of its own. **Products, variations, categories, product types and attribute values are all WordPress core rows** — `wp_posts`, `wp_terms`, `wp_term_taxonomy`, `wp_term_relationships`, `wp_postmeta` — and WooCommerce adds exactly two tables that touch them: `{prefix}woocommerce_attribute_taxonomies` (the global attribute registry) and `{prefix}wc_product_attributes_lookup` (a filter index)"
— #11080 §1

`post_title` is the title; `post_excerpt` the short description; `_sku` / `_global_unique_id` (GTIN) /
`_price` are postmeta (#11080 §1.1, §2b). **`_weight`, `_length`, `_width`, `_height` occur 0 times in the
record** — WooCommerce's shipping-dimension home is **not answered**.

**Three distinct attribute objects:** (1) the per-product entry `WC_Product_Attribute` —
`{id, name, options, position, visible, variation}` serialised into one `_product_attributes` postmeta row;
(2) the **global definition** `woocommerce_attribute_taxonomies` — six columns `attribute_id`,
`attribute_name`, `attribute_label`, `attribute_type`, `attribute_orderby`, `attribute_public`, and
*"**none of them references a category, a product type, or any grouping object**"*; (3) the **value** — a
WordPress term, *"a bare label — six fields, none of them a quantity, a unit or a dimension"*, shared
across products (#11080 §1.3, §1.4, §1.5).

*"A product-local attribute has no definition row at all: it is an entry in the product's own blob with
`id` 0"*, and the switch is `public function is_taxonomy() { return 0 < $this->get_id(); }`
(#11080 §2 step 1, §1.3).

**No attribute-set object exists**: instrument `attribute[_-]?(set|group|family|profile)s?` over 2,833 PHP
files / 20,564,126 B → **1** hit, a false positive; control `attribute[_-]?terms?` → **158** (#11080 §1.4).

**Brand:** **not answered in #11080** — its only token is a display widget file name
(`class-wc-widget-brand-nav.php:99`). ⚠️ **Closed by the 2026-09-19 external pass, and it is the one
merchant-owned brand entity in the thirteen.** `product_brand` is a registered WordPress taxonomy in
WooCommerce **core**: `register_taxonomy( 'product_brand', array( 'product' ), … 'hierarchical' => true,
'label' => __( 'Brands', 'woocommerce' ), … )`, carrying `@since 9.4.0`
(`corpus/woocommerce/class-wc-brands.php:275-331`), listed as *"Add - Introduced Product Brands.
[#50165]"* under `= 9.4.0 2024-11-11 =` (`corpus/woocommerce/readme-9.4.0.txt:244`). The vendor's framing
(`dev-blog-introducing-brands.txt`): *"The popular Brands functionality, previously available only as a
premium plugin, will now be integrated into WooCommerce core… The new Brands feature lets you create and
manage brands for stores and assign them to products, **similar to Categories**. With brand short-codes,
widgets, and blocks, you can create dedicated brand pages, display brand details on product pages, and help
shoppers navigate stores using brand-specific navigation menus."* ⚠️ The blog says *"to be released
October 21, 2024"*; the changelog dates 9.4.0 to **2024-11-11**. Both carried, unreconciled.
**Note the structural point:** in WooCommerce an attribute value is *already* a `wp_terms` row, so
promoting brand from a `pa_*` attribute to its own taxonomy is a change of label and UI, not of storage.

**Cap:** *"⚠️ **No cap on the number of attributes, or on the number of attributes flagged as axes, was
found by any instrument**"* (#11080 §1.x).

---

## 12 · commercetools — **O1**, with the thinnest core of the nine

`ProductData` has 13 properties: `name`, `categories`, `categoryOrderHints?`, `description?`, `slug`,
`metaTitle?`, `metaDescription?`, `metaKeywords?`, `masterVariant`, `variants`, `searchKeywords`,
`attributes`, `defaultVariant?`. `ProductVariant` has 13: `id`, `sku?`, `key?`, `prices?`, `attributes?`,
`price?`, `images?`, `assets?`, `availability?`, `isMatchingVariant?`, `scopedPrice?`,
`scopedPriceDiscounted?`, `recurrencePrices?` (#11081 §1.5, §1.6).

**Weight is an ordinary attribute** — `{"name":"weight","value":250}` *(no unit anywhere in the payload)*
(#11081 §2c). **No barcode/GTIN field exists** on `Product`, `ProductVariant` or `Variant`: anchored search
over 5,327,276 B → 1 hit, unrelated (#11081 §2b). Units: four instruments, all 0, control 19 lines
(#11081 §6).

**Definition object:** `AttributeDefinition` — `type`, `name` (`^[A-Za-z0-9_-]+$`, 2..256), `label`,
`isRequired`, `attributeConstraint`, `inputTip?`, `inputHint`, `isSearchable`, `level` — and it is
*"**Not a resource**: no `id`, no `version`; reached only through its ProductType"* (#11081 §1.2). The
**value** is `Attribute {name, value: any}` and the record **withdraws** its own statement about how the
value is stored (#11081 §1.9). Closed lists live on the definition and are per-ProductType; *"To use the
same `name` in multiple ProductTypes, each AttributeDefinition must have the same `type`"* (#11081 §1.4).

**Brand:** appears only as vendor-authored **attribute names** (`brand`, `tablet-brand`) in sample product
types (#11081 §3). No brand resource.

**Cap:** *"No cap on `AttributeDefinition`s per ProductType"* — `maxItems` → 0 over 51 files; adjacent
published numbers: **50 Product Attributes + 50 Variant Attributes indexable per product**, 10,922
characters per searchable field, 1,000 Product Types, 100 Attribute Groups (#11081 §1.x).

---

## 13 · Magento / Adobe Commerce — **O2**

`catalog_product_entity` declares **8 columns**: `entity_id`, `attribute_set_id`, `type_id`, `sku`,
`has_options`, `required_options`, `created_at`, `updated_at` — *"foreign keys: none"* (#11082 §1.5).

Everything else is an `eav_attribute` row. The core install creates **43 attribute definitions** in the
default set, whole: `name`, `sku`, `description`, `short_description`, `price`, `special_price`,
`special_from_date`, `special_to_date`, `cost`, `weight`, `manufacturer`, `meta_title`, `meta_keyword`,
`meta_description`, `image`, `small_image`, `thumbnail`, `media_gallery`, `old_id`, `tier_price`, `color`,
`news_from_date`, `news_to_date`, `gallery`, `status`, `minimal_price`, `visibility`, `custom_design`,
`custom_design_from`, `custom_design_to`, `custom_layout_update`, `page_layout`, `category_ids`,
`options_container`, `required_options`, `has_options`, `image_label`, `small_image_label`,
`thumbnail_label`, `created_at`, `updated_at`, `country_of_manufacture`, `quantity_and_stock_status`
(#11082 §3.2).

⚠️ The record lists `sku` **both** as a static column and among the installed attribute definitions and
never reconciles the two (#11082 §1.5 vs §3.2). **Re-read at source 2026-09-19, the two are reconciled and
the reconciliation is the most interesting fact in this row:** `sku` is installed as
`'sku' => ['type' => 'static', 'label' => 'SKU', 'input' => 'text', 'backend' => Sku::class,
'unique' => true, …]`
(`corpus/magento/magento2/app/code/Magento/Catalog/Setup/CategorySetup.php:410-421`), and
`'type' => 'static'` maps to `backend_type='static'`, which the vendor defines as:
```php
    /**
     * Check if attribute is static
     */
    public function isStatic()
    {
        return $this->getBackendType() == self::TYPE_STATIC || $this->getBackendType() == '';
    }
```
(`Eav/Model/Entity/Attribute/AbstractAttribute.php:794-801`, `public const TYPE_STATIC = 'static';` at
`:30`). The same is true of `has_options`, `required_options`, `created_at` and `updated_at`
(`CategorySetup.php:809-865`). **So Magento has a definition row for every product fact, and
`backend_type` says whether the value lives in an EAV table or in a column of `catalog_product_entity`.
It does not have a column-versus-attribute binary; it has one registry and two storage strategies.** That
is `ATTR-DEF.md` §A1's extended option 4.

**Definition object:** `eav_attribute` (17 columns incl. `frontend_input`, `backend_type`, `source_model`,
`is_user_defined`, `is_required`, `is_unique`, `default_value`, `UNIQUE (entity_type_id, attribute_code)`)
plus the catalog overlay `catalog_eav_attribute` (22 columns, see matrix-A0). **Value:** five typed tables,
`UNIQUE (entity_id, attribute_id, store_id)` — note the **store_id in the key**. *"✅ **The value is a
shared row referenced by an integer, not a string copied onto each product**; the label is fanned out **per
store view**, never per product."* (#11082 §1.7, §1.9).

`frontend_input` is the one free-text-vs-closed-list switch (#11082 §1.1).

**Brand:** the installed `manufacturer` attribute — `'input' => 'select'`, `'user_defined' => true`,
`'apply_to' => Type::TYPE_SIMPLE` (#11082 §3.2). The string `brand` occurs once, in marketing prose.

**Barcode:** *"⚠️ **No vendor term.** `\b(barcode|gtin|upc|ean13|ean)\b` (-i) over `app/code` php/xml/graphqls
excluding Test → **0**."* (#11082 §2b).

**Cap:** *"**No cap in any artifact read.**"*, six instruments → 0 (#11082 §1.x).

---

## Tally

| Option | Count | Platforms |
|---|---|---|
| **O1** fixed core + extensible attribute system | **9** | Shopify · Google · eBay · Walmart · Shopee · Tokopedia (**both eras agree**) · Salesforce B2C · WooCommerce · commercetools |
| **O2** everything is an attribute | **3** | Amazon · Akeneo · Magento |
| **O3** capped custom fields beside a large core | **1** | Square |

**Named ambiguous / hedged rows** (the record's hedge travels into the tally):
- **Amazon** — filed O2 on the *write* path. Its `sku` is outside the schema entirely, its read model
  projects `brand`/`itemName`/`manufacturer`/`color`/`size`/`style` as plain scalars and carries
  first-class `identifiers`/`images`/`dimensions` blocks, and *"not universal — `getListingsItem` returns
  attributes "not part of the Product Type schema""*. Reading Amazon's *read* model instead moves it to O1.
- **commercetools** — filed O1, but it is the closest of the nine to O2: weight is an ordinary attribute
  and no barcode/GTIN field exists anywhere in the model.
- **Square** — filed O3 on a cap whose **scope is unresolved by the vendor's own artifacts** (account vs
  application vs `app_id`). If the cap is per-application, every seller can hold many more than 20 and
  Square is an O1.
- **WooCommerce** — filed O1, but where its shipping dimensions live is **not answered in the record**
  (`_weight` 0 hits), so one arm of its line is unmeasured.
- **Google** — filed O1, but its core is not selected by "code-read vs staff-authored": there is **no
  per-category attribute schema at all**, so the second half of option 1's rule has no analogue. Its
  extension is four open name/value bags.

**A narrower proposition that IS unanimous — 13 of 13.** *Every* platform keeps a fixed core of
**identity plus structure** outside the extensible system, including the three O2 platforms: Amazon's `sku`
is a path parameter; Akeneo's `uuid`/`id`/`identifier`/`enabled`/timestamps/edges are mapped columns;
Magento's `entity_id`/`sku`/`type_id`/`attribute_set_id`/timestamps are static columns. **Nobody puts
everything in the bag.**

⚠️ **With one refinement that matters (Magento, verified at source above):** keeping a fact's *value* out
of the bag is not the same as keeping its *definition* out. Magento keeps `sku`, `created_at` and
`updated_at` as columns **and** gives each of them an `eav_attribute` row. Akeneo's counterpart is the
opposite: its `identifier` is *both* a mapped column and a `pim_catalog_identifier` attribute, and the
record carries both without collapsing them (#11069 §1.7, §5 C9). **So of the three O2 platforms, two keep
a definition for their column-stored facts.** That is the evidence behind `ATTR-DEF.md` §A1's option 4.

**A second near-unanimity — definition and value are separate objects: 8 yes · 3 partial · 2 no.**
- *Yes (8):* Shopify (`MetafieldDefinition`), Shopee (`attribute_tree` + `value_id`), Tokopedia (both eras
  have id-bearing catalogues), Square (`CatalogCustomAttributeDefinition`), Salesforce
  (`ObjectAttributeDefinition`), Akeneo (`pim_catalog_attribute`), commercetools (`AttributeDefinition`,
  though *"not a resource"*), Magento (`eav_attribute` + `catalog_eav_attribute`).
- *Partial (3):* Amazon (modelled as `Attribute` + a join, but *"❓UNKNOWN on the JSON side"* for
  type/constraints), eBay (`AspectConstraint` is a full definition but has **no id** and is per-category),
  WooCommerce (global attributes have a registry row; **local attributes have no definition row at all**).
- *No (2):* **Google** (145 named properties *are* the schema; the open bags are bare name/value) and
  **Walmart** (definitions repeated inline — 383,947 slots for 6,576 names, `$ref` **0 over the
  451,013,258-byte feed schema**). ⚠️ **Walmart's own scope correction, carried** (#11046 §2): *"⚠️
  **Scope correction:** that is about the **feed** schemas only. The read-side OpenAPI document **does**
  use references — `"$ref"` occurs **2** times, both `#/components/schemas/VariantGroupInfo`; **"no shared
  definition anywhere in the published schemas" would be too broad.** The read side returns values, never
  ids."* Filed "no" on the **write path**, which is where products are defined.
- **Inference (labelled):** the two "no"s are exactly the two systems whose interface is a **flat feed**
  rather than a stored catalogue. A feed row has nowhere to put a reusable definition, so the schema is the
  definition and the schema is re-stated per type. Neither vendor states this.

**Brand sub-question — 4 attribute · 3 built-in scalar · 2 platform-owned registry · 2 merchant-owned
entity · 2 not established.** *(Revised 2026-09-19 after the external pass: WooCommerce moves from "not
established" to "merchant-owned entity", and Akeneo moves from "attribute" to the entity side while
shipping both. The list immediately below is the pre-revision reading, kept so the change is visible, with
the correction restated under it.)*
- *Ordinary attribute (5):* Amazon (a `product_identity` property), Walmart (a product-type slot), Akeneo
  (`camera_brand` with `AttributeOption` values), commercetools (an attribute name), Magento
  (`manufacturer`, a `select` attribute with option rows).
- *Built-in scalar (3):* Shopify (`vendor: String!`, free text), Google (`brand`, Max 70 chars), eBay
  (`Product.brand`, **and** a `Brand` aspect).
- *Reference to a platform-owned brand entity (2):* Shopee (`brand_id : int32` required), Tokopedia **Era B**
  (`brand_id` at depth 0; `"Reason: [Brand does not exist]"`). *Era A carries no brand field at all.*
- *Not established (3):* Square, Salesforce B2C (zero occurrences), WooCommerce.
⚠️ **CORRECTION, 2026-09-19.** The sentence this list originally carried — *"No record in the thirteen
shows brand as a merchant-owned first-class resource"* — **is refuted.** It was true of the thirteen
*records* and false of the platforms. **WooCommerce ships `product_brand` as a hierarchical merchant-owned
taxonomy in core since 9.4.0 (2024-11-11)**, with brand pages, brand blocks and brand navigation; see the
WooCommerce row above for the registration call and the vendor's own description. The revised reading:

- *Platform-owned registry (2):* **Shopee** — `GET /api/v2/product/get_brand_list` (*"Get the brand data of
  a leaf category."*), keyed by `category_id`, paginated (`page_size` max 100), returning
  `brand_list[{original_brand_name, brand_id, display_brand_name}]` plus `is_mandatory` and `input_type`;
  and `POST /api/v2/product/register_brand` (*"Use this call to register a brand."*) taking
  `original_brand_name`, `category_list` (max 50 L1/L2 categories), `product_image.image_id_list`,
  `app_logo_image_id`, `brand_website`, `brand_description`, `brand_region`, licences and a registration
  website. Published instance: `{"brand_id": 2500139861, "original_brand_name": "nike",
  "display_brand_name": "nike"}`. ⚠️ Two contradictions inside Shopee's own pages, carried unresolved:
  `brand_id` is `int64` in the get_brand_list response table (and the example exceeds int32) but `int32` in
  the add_item request and get_item_base_info response tables; and `input_type` is *"Input type:
  DROP_DOWN"* in the table while the example emits `"input_type":"TEXT_FILED"` [sic].
  And **Tokopedia Era B** (`brand_id`, *"Reason: [Brand does not exist]"*). Both are **marketplace**
  registries the seller points at.
- *Merchant-owned entity (2):* **WooCommerce** (core taxonomy) and **Akeneo** (EE Reference Entity, with
  brand as the vendor's own first example — see the Akeneo row).
- ⚠️ **Shopify has a type called `Brand` and it is not this**: `Shop.brand` is *"The store's branding
  configuration… such as logos, colors, and slogan"* with fields `colors`, `coverImage`, `logo`,
  `shortDescription`, `slogan`, `squareLogo`. A Storefront introspection of all **426** types returns 4
  containing `brand` and **0** containing `vendor`; `Product.vendor` is `String!` with no edge to it
  (`corpus/shopify-vendor-field/mockshop-brand-type.json`, `mockshop-introspect-types.json`,
  `mockshop-product-type.json`). Live instance: `"vendor":"Mock.shop"` on three products.
- **Inference (labelled):** a marketplace needs brand normalised for search, filtering and counterfeit
  control and therefore mints brand ids centrally; a merchant tool promotes brand to an entity when brand
  acquires **its own attributes and its own page** — which is the reason Akeneo, WooCommerce and
  commercetools each give in different words, and which Magento (no brand page) has never needed, leaving
  brand as the `manufacturer` attribute.
