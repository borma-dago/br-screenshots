# ATTR-DEF — what an attribute is · research brief · 2026-09-19

**Cards:** **A1** what is an attribute, and which facts are attributes at all (incl. is brand an entity?) ·
**A2** is a variant dimension an attribute or its own object (= **D3**; confirm or reopen on the record) ·
**A0** what are attributes for, and are some of them hidden. Answered in that order — A2 depends on A1.

**Pins (read-only).** Backend `/home/irvan/copilot/py-5` @ solvent-master `4f99dc01c6` (verified at the
pin). Frontend `/home/irvan/copilot/ts-layer2` @ ts-master `82187a17bd` (verified at the pin). Data:
BigQuery `solvent-staging.production_append_public`, CDC-deduped, snapshot **2026-09-19**.

**Files beside this one**

| File | What |
|---|---|
| `rationale.md` | every vendor-stated rationale collected, whole; each card's §3 keeps the decisive ones inline |
| `matrix-A1.md` | the thirteen-row evidence table for A1, every cell the record's own words + cite |
| `matrix-A2.md` | the same for A2, with the declaration / value-storage split and both tallies |
| `matrix-A0.md` | the same for A0, with the V1/V2/V3 tallies and the A0↔A5 coupling |
| `design-A1.md` | the column-vs-attribute rule designed against our real models; brand's three homes |
| `design-A2.md` | both axis shapes designed against our real models: tables, write path, editor, search, feed, invariants |
| `sql/*.sql`, `sql/results/*.csv` | every number in §5, each with its query |
| `corpus/square/`, `corpus/shopify/` (+ others, see §8) | vendor artifacts fetched for the card pointers |

---

## A1 · What is an attribute, and which facts are attributes at all?

### 1 · Options

As the card lists them:

1. **Universal and read by code → column; category-specific and staff-authored → attribute.** (Lock
   condition 2 already moves the four shipping dimensions to columns on this logic.)
2. **Everything is an attribute, even the title** (the card cites Amazon).
3. **Only a small fixed set of custom fields beside the columns** (the card cites Square: 10 visible + 10
   hidden).

**Extended, with the reason stated** (BRIEF.md §3 permits extension only with a stated reason): a fourth
option exists, it is implemented by a platform in the sample, and it dissolves the tension between options
1 and 2 —

4. **Every fact has a definition; the definition says where the value is stored.** Magento's
   `eav_attribute` carries a row for `sku`, `has_options`, `created_at` and `updated_at` exactly as it does
   for `manufacturer`; what differs is `backend_type`. `'type' => 'static'`
   (`corpus/magento/magento2/app/code/Magento/Catalog/Setup/CategorySetup.php:410-421`) plus
   `public function isStatic() { return $this->getBackendType() == self::TYPE_STATIC || $this->getBackendType() == ''; }`
   (`Eav/Model/Entity/Attribute/AbstractAttribute.php:794-801`) means *"the value is a column of the main
   table"*. **So Magento does not have a column-versus-attribute binary at all: it has one metadata
   registry and two storage strategies.** The reason to put this on the table is stated in §6 and §7 — it
   is the only option that removes option 1's one real defect.

Sub-question: **is brand an attribute, or an entity with its own table?**
Second question on the card: **is a definition (name, type, allowed values, owner) a separate thing from a
value (one product's answer)?**

Respects: Lock 1 (`ProductAttribute.product_class` → `.category`), condition 1 (the schema editor is
built first), and **condition 2** — with a disposition this card must state rather than assume.
~~Condition 2 as written: the four dimensions become `NOT NULL` columns, after which `manufacturer` is the
entire corpus.~~ **This brief's recommendation (option 4, §7) RE-EXPRESSES condition 2**: the four
dimensions' *values* leave `ProductAttributeValue` for `NOT NULL` columns exactly as the condition requires,
and their *definitions* stay as `ProductAttribute` rows carrying `storage='column'`. After it,
**`manufacturer` is the entire attribute *value* corpus and one of five surviving definitions.** The
substance of the condition — no dimension value in the EAV table, a `NOT NULL` column the shipping code
reads directly — is untouched; what changes is that the metadata is not deleted with the data. Labelled as
a re-expression, not a silent contradiction, per BRIEF.md §1. Touches D9, D18.

### 2 · Who uses which, who does not

**Split, not unanimous: 9 · 3 · 1.** Full table with quotes and cites: `matrix-A1.md`.

| Option | Count | Platforms |
|---|---|---|
| **1** — fixed core of built-in fields **+** an extensible attribute system | **9** | Shopify · Google · eBay · Walmart · Shopee · Tokopedia (**both eras agree**) · Salesforce B2C · WooCommerce · commercetools |
| **2** — everything is an attribute | **3** | Amazon · Akeneo · Magento |
| **3** — capped custom fields beside a large core | **1** | Square |

**Named ambiguous rows** (the record's hedge travels into the tally): **Amazon** — option 2 on the *write*
path, but `sku` is *"a URL path parameter, never a schema attribute"*, `getListingsItem` returns attributes
*"not part of the Product Type schema"*, and the read model projects `brand`/`itemName`/`manufacturer` as
plain scalars; read that way Amazon is option 1. **commercetools** — option 1, but the closest of the nine
to option 2: weight is an ordinary attribute and no barcode/GTIN field exists anywhere. **Square** — option
3 on a cap whose **scope the vendor's own page contradicts itself on** (see §3). **WooCommerce** — option
1, but where `_weight`/dimensions live is **not answered in the record** (0 hits). **Google** — option 1,
but it has *"no per-category attribute schema"* at all, so option 1's second clause has no analogue there.

**Two propositions that are far stronger than the option tally:**

- **13 of 13 — nobody puts everything in the bag.** Every platform, including all three option-2 ones,
  keeps identity + structure outside the extensible system: Amazon's `sku`; Akeneo's
  `uuid`/`id`/`identifier`/`enabled`/timestamps/edges as mapped columns; Magento's 8 static columns on
  `catalog_product_entity` (*"foreign keys: none"*).
- **Definition and value are separate objects: 8 yes · 3 partial · 2 no.** The two "no"s are **Google**
  (145 named properties *are* the schema) and **Walmart** (*"the schema **repeats definitions rather than
  referencing them**"* — 383,947 slots for 6,576 names, `$ref` **0 over the 451,013,258-byte feed
  schema**). ⚠️ **Walmart's own scope correction, carried rather than dropped** (#11046 §2, the next
  sentence): *"⚠️ **Scope correction:** that is about the **feed** schemas only. The read-side OpenAPI
  document **does** use references — `"$ref"` occurs **2** times, both
  `#/components/schemas/VariantGroupInfo`; **"no shared definition anywhere in the published schemas" would
  be too broad.** The read side returns values, never ids."* Walmart is therefore "no" **on the write
  path**, which is the path that defines products. *Inference, labelled:* those two are
  exactly the two **flat feeds**; a feed row has nowhere to put a reusable definition. Neither vendor says
  so.

**Brand — 5 attribute · 3 built-in scalar · 2 platform-owned entity reference · 3 not established.**
Attribute: Amazon, Walmart, Akeneo (`camera_brand` → `AttributeOption` `canon_brand`), commercetools,
Magento (`manufacturer` — re-fetched at source 2026-09-19: `'input' => 'select'`, `'user_defined' => true`,
`'filterable' => true`, `'comparable' => true`, `'apply_to' => Type::TYPE_SIMPLE`,
`corpus/magento/magento2/app/code/Magento/Catalog/Setup/CategorySetup.php:537-551`). Scalar: Shopify
(`vendor: String!`, free text, *"No enum, no validations"*; and **no brand entity exists** — an instrument
over 3,289 distinct field names in the live `2026-07` introspection returns `brand` only on
`CheckoutBrandingColorGlobal`, `CustomerCreditCard` and `VaultCreditCard`), Google (`brand`, max 70 chars),
eBay — **both at once, with automatic sync**: `Product.brand` is a built-in field *and* `Brand` is a
category aspect, and the contract says they merge: *"If a brand was passed in as an item specific
name-value pair through the **aspects** array in a **createOrReplaceInventoryItem** call, this value is
also picked up by the **brand** field."* (`corpus/ebay/openapi-sell_inventory_v1_oas3.json`,
`components.schemas.Product.properties.brand.description`). Entity reference: Shopee
(`brand_id : int32` required), Tokopedia **Era B** (`brand_id`; error *"Reason: [Brand does not exist]"*).
Not established in the records: Square, Salesforce (zero occurrences of the string) and WooCommerce —
**three**, before the correction below moves WooCommerce off this list.

⚠️ **A correction to the reading the records support, found by the 2026-09-19 external pass — do not
repeat the claim that no platform models brand as an entity.** Four platforms do, in **two kinds**:

- **Shopee's is a platform-owned registry**, and it is a full API surface:
  `v2.product.get_brand_list` returns `brand_list[{original_brand_name, brand_id int64,
  display_brand_name}]` with `has_next_page` pagination, and `v2.product.register_brand` exists for
  sellers to add one (`corpus/shopee/get_brand_list.txt:640-724`, `register_brand.txt`). Same for
  Tokopedia Era B's `brand_id`.
- **Two are merchant-owned entities, and both vendors state the same trigger.**
  - **WooCommerce** — `product_brand` is a registered WordPress **taxonomy**, `'hierarchical' => true`,
    `'label' => 'Brands'`, `'show_in_rest' => true`, `@since 9.4.0`
    (`corpus/woocommerce/class-wc-brands.php:275-331`), listed as *"Add - Introduced Product Brands.
    [#50165]"* under `= 9.4.0 2024-11-11 =`. It was shipped **disabled** and turned on later:
    *"Although we are adding this feature WooCommerce 9.4, it will be initially disabled for all users."*
    (dev blog 2024-10-01) → *"starting with WooCommerce 9.6, scheduled for Monday, January 20th, Brands
    will move out of beta and be automatically enabled for everyone."* (dev blog 2025-01-17) → the source
    now reads *"As of WooCommerce 9.6, Brands is enabled for all users."* (`Internal-Brands.php`).
    The reason it is an entity: *"Product brands give you a dedicated way to organize products by
    manufacturer, label, or maker. **Each brand can have its own name, description, image, and archive
    page.**"* (`corpus/woocommerce/doc-woocommerce-brands.txt:42`) — and its Store API resource carries exactly that (`image`, `description`, `permalink`,
    `review_count`, `count`). Mechanism, in the vendor's words: *"Brands are implemented as a custom
    taxonomy, **similar to product categories**."* (`corpus/woocommerce/dev-blog-introducing-brands.txt:14`)
  - **Akeneo** — brand is the vendor's **canonical example of a Reference Entity** (EE only):
    *"Reference entities are objects that are related to products but have their own attributes and
    lifecycle. **A reference entity can be for example the brands**, the ranges, the manufacturers, the
    colors, the materials or the care instructions…"* (`corpus/akeneo/brand-reference-entities.txt:290`).
    Its help centre states the promotion trigger outright
    (`corpus/akeneo/brand-help-104-serenity-what-is-a-reference-entity.txt:96-97`): *"Some information are
    shared between different products (such as care instructions, or colors or even brands). **This data
    can be complex to manage because it has its own attributes (e.g. a label, a logo, a description or
    photos). Those information may have dedicated pages on one's e-commerce website (e.g. a webpage
    describing a brand) or their information may be used to enrich product pages (e.g. the logo of a
    brand).**"*
    ⚠️ **And Akeneo ships both states at once**: its own demo catalogue models brand as an ordinary
    `pim_catalog_simpleselect` attribute with `AttributeOption` rows —
    `brand;Brand;Brand;Marque;…;pim_catalog_simpleselect;0;0` and option `akeneo;;Akeneo;;brand;1`
    (`corpus/akeneo/pim-community-dev/…/icecat_demo_dev/attributes.csv:75`, `attribute_options.csv:114`).
    **One vendor demonstrating both ends of the path.**

**So the corrected tally is 4 attribute · 3 built-in scalar · 2 platform-owned registry · 2 merchant-owned
entity · 2 not established** (Akeneo moves from "attribute" to "both", and is counted on the entity side
with the demo-data counter-fact stated). ⚠️ **Shopify has a type literally called `Brand` — it is not
this.** `Shop.brand` is *"The store's branding configuration… such as logos, colors, and slogan"*; a
Storefront introspection of all **426** types returns 4 containing `brand` (`Brand`, `BrandColorGroup`,
`BrandColors`, `CardBrand`) and **0** containing `vendor`, and `Product.vendor` has no edge to it
(`corpus/shopify-vendor-field/mockshop-brand-type.json`, `mockshop-introspect-types.json`).
See §7 for what all this does to the recommendation.

**Card pointer executed** — *"where each of the thirteen draws the column-versus-attribute line"*: the
thirteen rows are in `matrix-A1.md`. *"Shopify keeps weight on the variant, outside the attribute system"*:
**confirmed with a correction, on two routes.** In Admin GraphQL `2026-07` there is **no `weight` field on
`ProductVariant`** — the path is `ProductVariant.inventoryItem.measurement.weight { value unit }`; on REST
the same variant carries `"grams":500,"weight":0.5,"weight_unit":"kg"` directly. Re-verified at origin
2026-09-19: `ProductVariant` has 52 fields in `2026-07` and 41 in `2025-10`, and in **neither** version is
any field named `weight`/`weightUnit`, deprecated or otherwise
(`corpus/shopify/sfy-extract-ProductVariant.txt`, `sfy-ProductVariant-2025-10.json`). **And the deliberate
counter-case search found the opposite too:** Shopify ships a metafield *type* called `weight` and its own
guide stores a product weight in it —
`{ namespace: "specs"  key: "weight"  value: "{\"value\": 2.5, \"unit\": \"KILOGRAMS\"}"  type: "weight" }`
(`corpus/shopify/sfy-docs_apps_build_custom-data_metafields_manage-metafields.md:132-134`). Both are true
in one API version. **So the pointer's premise holds for the built-in field and does not exclude the
attribute route.**

### 3 · Why

**Full set of quoted vendor rationale for this card: `rationale.md` §A1.** The three that decide it:

- **Shopify, on why the definition is a separate object — the clearest published statement in the set**
  (`corpus/shopify/sfy-docs_apps_build_custom-data.md:35`): *"**A defined metafield gets a typed editor in
  the admin, validation on write, and support for search and filtering. An undefined metafield is stored as
  a plain string that merchants can't search or validate.**"* And on why the extension exists at all
  (`:13`): *"**Most apps need to store data that Shopify's standard data model doesn't include**, such as a
  fabric composition on a product, a warranty record, or a record type that only your app uses."*
- **Square, same question, with the reason spelled out**
  (`corpus/square/raw-add-custom-attributes.txt:136-140`): *"…The application needs additional information
  for each menu item: An application-specific menu item name… Allergen information. **Because catalog items
  don't have properties for this information**, the seller can have custom attributes added to a
  CatalogItem object in their catalog to capture the additional details."*
- **Adobe states option 4 in its own words, and this is the strongest support the extension has.**
  `corpus/magento-rationale/eav-attributes.txt:79` (developer.adobe.com/commerce/php, source markdown last
  committed 2026-03-17): *"A module has a set of built-in attributes that are always available. The
  `Catalog` module has several attributes that are **defined as EAV attributes, but are treated as built-in
  attributes**. These attributes include:"* — followed by all 14: `attribute_set_id`, `created_at`,
  `group_price`, `media_gallery`, `name`, `price`, `sku`, `status`, `store_id`, `tier_price`, `type_id`,
  `updated_at`, `visibility`, `weight`. *"In this case, when `getCustomAttributes()` is called, the system
  returns only custom attributes that are not in this list."* **A definition for every fact; a list that
  says which ones behave as built-ins.**
- **commercetools states the brand-entity trigger as an efficiency rule**
  (`corpus/commercetools/docs-lm_product-modeling_product-types.txt:69`): *"**If the same information is
  used in a large number of Products or Product Variants, it is more efficient to design it as a Custom
  Object and reference it using an Attribute.**"* — and, on restraint: *"Don't overcomplicate your Product
  Types with too many Attributes. You can add Attributes at any time, but removing Attributes that are
  already in use can be difficult."*
- **Magento, on why everything is an attribute — and what it costs.** `Magento_Eav/README.md`, **the whole
  file** (`corpus/magento/magento2/app/code/Magento/Eav/README.md`, 128 B): *"EAV stands for
  Entity-Attribute-Value. **This module makes entities configurable/extendable by admin user.**"* Against
  that, Adobe's own operations guidance
  (`corpus/magento/adobe-catalog-management.txt`, fetched live 2026-09-19): *"Configuring many product
  attributes increases the product template size for each product (EAV structure) and the amount of data
  that must be retrieved."* → *"Increase in SQL queries traffic related to EAV data retrieval… Significant
  increase in the size of Adobe Commerce indexes and the full-text search index… Reaching hard MySQL limits
  when building a FLAT index for oversized product templates… Increased response time for most storefront
  scenarios related to catalog browsing, search (quick and advanced), and layered navigation."*
  **The vendor of the purest option-2 catalogue publishes option 2's running cost.**

Also quoted in `rationale.md` §A1: Walmart on why the type owns the attribute set; commercetools
(*"You wouldn't ask for the `Neckline` of a pair of jeans, would you?"*); Adobe on the attribute set
(*"determines the fields that are available during data entry, and the values that appear to the
customer"*); Akeneo on completeness; Tokopedia's own product-vs-sales attribute definition.

**Inference, labelled — why the three option-2 platforms are option 2.** Akeneo is a **PIM**: its product
has no storefront, no checkout and no shipping engine, so no code path needs a typed column. Magento is a
**2008-era EAV monolith** whose static columns are the ones the ORM needs to find a row at all, and whose
24-column `catalog_eav_attribute` overlay exists precisely to give the bag back the per-use flags a column
would have had for free. Amazon's write path is a **submission against a per-product-type JSON Schema**, so
"everything is a property" is a statement about the wire format, and its read model keeps scalars anyway.
**None of the three is a merchant storefront with one tenant, one category tree and a shipping integration
— which is what we are.** No vendor states this.

**Inference, labelled — why Square caps at ten.** Square's built-in set is large (27 item properties + 23
variation properties) and its custom attributes are an **app-integration** device rather than a
merchandising one — the blog's own framing is *"tokens unique to an external application"*. A cap is cheap
when the extension is not the product model.

### 4 · Our code today

Every consumer found by Grep at the pins. Full table in `design-A1.md` §0–§1.

**The attribute system.** `ProductAttribute` — `product_class` FK (**nullable**), `name`, `code`
(SlugField, **no unique constraint** — `Meta` carries only `app_label` and `ordering`), `type` (6 choices),
`required` — `py/mono/solvent/catalogue/models.py:608-655`. `ProductAttributeValue` — `attribute` FK,
`product` FK, `unique_together ("attribute","product")`, six typed value columns — `models.py:719-747`.
Read/write through `product.attr.<code>`, a container that `setattr`s every value onto itself by `code` —
`catalogue/product_attributes.py:5-64`.

**Every reader and writer of an attribute value or definition, both stacks** (not claimed exhaustive —
round-1 finding 22 and round-2 finding 4 each found more):

| Consumer | Reads | Cite |
|---|---|---|
| Shipping quote | `attr.length`, `attr.width`, `attr.height`, `attr.weight` | `solvent/third_party_api/biteship/biteship.py:60,61,62,90` |
| Basket line weight / volume | `attr.weight`, `attr.length`, `attr.width`, `attr.height` | `solvent/basket/models.py:1265,1272,1273,1274` |
| Customer + staff product API | the whole `attribute_values` list, sorted by `attribute.code` | `solvent/api/apiproduct/serializers.py:194-224`; prefetch at `views.py:60-61` |
| Staff write path (the **only** production create path) | `_assign_attributes()` resolves by `code` against the class's codes, inside `transaction.atomic()` | `solvent/api/apiproduct/staff_serializers.py:65-81, 96-130` (`Product(` at `:116`) |
| Definition read (staff app) | `GET api/product/staff/attribute/all/`, **list only — no create/update/delete** | `staff_views.py:57-75`; `staff_urls.py:16`; `py/mono/solvent/api/shared/views/api_mixins.py:11-22` |
| Django admin — definitions | `ProductAttribute`, `ProductAttributeValue`, `ProductClass` registered; `prepopulated_fields = {"code": ("name",)}`; `ProductAttributeAdmin.list_display = ("name", "code", "product_class", "type")` | `catalogue/admin.py:27-34, 51-57, 65-68`; `:52`, `:53` |
| Django admin — **values, write surface** | `AttributeInline(admin.TabularInline){ model = ProductAttributeValue }`, attached to `ProductAdmin` | `admin.py:18-19`, attached at `:46` |
| **`Product.attribute_summary`** | *"Return a string of all of a product's attributes."* — joins `attribute.summary()` over `attribute_values.all()`; registered in `ProductAdmin.list_display`, so it renders on **every row of the admin product list** | `models.py:520-525`; `admin.py:43` |
| **`ProductAttributeValue.summary()` / `__str__`** | `"%s: %s" % (self.attribute.name, self.value_as_text)` — **the only backend consumer of `ProductAttribute.name`** | `models.py:760-766` |
| **`Product.attributes` M2M** | `ManyToManyField("catalogue.ProductAttribute", through="ProductAttributeValue")` — a **declared through-model**, so any change to the value table's shape mutates a live M2M declaration | `models.py:419-422` |
| **Validation** | `Product.clean()` → `attr.validate_attributes()`, which iterates `product_class.attributes.all()` and enforces `required` | `models.py:484` → `product_attributes.py:36-52` |
| **Write fan-out** | `Product.save()` → `attr.save()`, which iterates *every* definition of the class and calls `attribute.save_value()` | `models.py:490` → `product_attributes.py:60-64` → `models.py:672-682` |
| **Write serializer** | `ProductAttributeValueStaffSerializer.value` is a plain `CharField(allow_null=True, allow_blank=True)` — **one field type for all six attribute types** | `staff_serializers.py:36-38` |
| **Definition endpoint queryset** | `ProductClass.default().attributes.all()` — and `default()` is `ProductClass.objects.get()`, which **raises the moment a second row exists** | `staff_views.py:67`; `models.py:88-90` |
| **Definition permission** | `permissions_required = ["catalogue.view_productattribute"]`, mirrored in the frontend permission union | `staff_views.py:64`; `ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43` |
| **Frontend definition client** | `ProductAttributesStreamService` → `GET api/product/staff/attribute/all/`, sorted by the priority array | `ts/libs/product/action/data-access/src/lib/product-attributes-stream.service.ts:24,33`; consumed at `product-new.component.ts:35`, `product-update.component.ts:47` |
| Search index | **nothing** — `ProductIndex` carries no attribute field; faceted fields are `category` (`:65`) and `price` (`:67`) only; `product_class` is commented out (`:62`) | `solvent/search/search_indexes.py:20-75` |
| Search document text | title + `title_staff` + `upc` + category + description — **no attribute value** | `py/mono/templates/search/indexes/catalogue/product_lite.txt`, `product_text.txt` |
| Google Merchant feed | **nothing** — `ProductAttributes(...)` is built from `availability, condition, description, link, title, price` (+`sale_price`, `image_link`) | `solvent/third_party_api/google/content/products_api.py:214-241` |

**`manufacturer` has zero backend readers.** `grep -rn "manufacturer" --include=*.py py/mono/solvent/`
returns **0 hits, full stop** (re-run at the pin; there are no migration hits either — see §8 finding 15).
It does have exactly one *frontend* reader: the hard-coded i18n label/unit pair
`attribute.key.manufacturer.{name,unit}` in `ts/assets/i18n/product/{en,id}.json`.

**The reindex and feed fan-out, and the ordering trap inside it — missed by the first draft and
load-bearing for A0 and A2.** `Product` has a `post_save` receiver,
`product_post_save_update_indexes` (`catalogue/receivers.py:31-41`), which calls
`update_products_indexes([instance])` and `update_product_dependent_indexes(instance.id)`;
`update_products_indexes` enqueues **both** the Elasticsearch document *and* the Google Merchant push —
`SearchIndexQueue().enqueue_updates(products)` and
`google_product_index_queue.GoogleProductIndexQueue().enqueue_updates(...)`
(`catalogue/index_utils.py:11-16`). Two facts follow, and both cost money later:

1. **There is no `post_save` or `post_delete` receiver on `ProductAttributeValue` anywhere.** An
   attribute-value-only write never reindexes and never re-pushes to Google.
2. **`Product.save()` enqueues before it writes the values.** `super().save(*args, **kwargs)` at
   `models.py:489` is what fires the receiver; `self.attr.save()` runs at `models.py:490`, *after* it. So
   even on a full product save, the document that gets queued is built from the pre-write state as far as
   attribute values are concerned.

Instrument: `grep -rn "attribute\|attr\." index_utils.py models_mixins.py` → **0 hits**. **The first
attribute value that any index or feed consumer needs will require a new receiver on
`ProductAttributeValue` *and* a re-ordering of `Product.save()` — under both A2 shapes, and under every A1
option.**

**The third home.** `ProductMeta` — *"For storing rarely accessed metadata for products."* — is a mandatory
1:1 side table auto-created by a `post_save` receiver (`models.py:895-910`; `catalogue/receivers.py:28`)
and it holds the **purchasing and replenishment rules**: `quantity_purchasing_allowed_multiples` and
`quantity_per_box`, read at `inventory_replenishment_service.py:114`,
`purchasing/purchasing_quantity_service.py:39,158`, `transport/models/models.py:222`. **So the "internal
rules" use on the A0 card is already served — by columns, not attributes.**

**Frontend (`ts-layer2` @ `82187a17bd`).** `ProductAttributeType = 'float' | 'text'` — **two of the
backend's six** (`ts/libs/product/shared/util-core/src/lib/product-attribute.model.ts:1`). The staff form
generates one Formly field per definition, typed by `PRODUCT_ATTRIBUTE_TYPE_TO_FORM_FIELD`
(`ts/libs/product/action/ui-staff-form/.../product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)`). **The label
and the unit come from a frontend i18n bundle keyed by `code`** —
`product.attribute.key.<code>.{name,unit}`, six hard-coded keys in
`ts/assets/i18n/product/{en,id}.json` (`ts/libs/product/addendum/util-i18n/.../product-attribute-i18n.service.ts:20-35`)
— and the DB's own `ProductAttribute.name` is **never sent to any API client**
(`serializers.py:164-176`). ⚠️ It is **not** unread, though: `name` renders on four Django-admin paths —
`ProductAttributeValue.summary()` (`models.py:763-766`), `Product.attribute_summary` on every row of the
admin product list (`models.py:520-525`; `admin.py:43`), `ProductAttributeAdmin.list_display`
(`admin.py:52`), and `ProductAttributeValue.__str__` in every inline row (`models.py:760-761`;
`admin.py:18-19,46`). **The staff-facing label of record exists today; it is served by Django admin, not
by the staff app.** The customer spec sheet renders every value except a hard-coded deny-list
(`ts/libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.ts:34,47-50`).

⚠️ **There are TWO attribute orderings in this system, on two surfaces, by two mechanisms — an earlier
draft of this brief conflated them, and the A0 recommendation was priced on the conflation.** Corrected:

| Surface | What orders it | Cite |
|---|---|---|
| **Customer spec sheet** | the **backend**, alphabetically by `code`: `response["attribute_values"] = sorted(response["attribute_values"], key=lambda x: x["attribute"]["code"])` | `py/mono/solvent/api/apiproduct/serializers.py:219-221` |
| **Staff form fields** | the **frontend**, by a hard-coded priority array `['internalname','length','width','height','weight']`, applied when the *definition list* is fetched | `product-attribute-ordering.service.ts:9-15`, applied at `product-attributes-stream.service.ts:33` |

`ProductAttributeOrderingService` is referenced in exactly **three** places in the whole frontend — its own
file, the barrel export, and `product-attributes-stream.service.ts` — verified
`grep -rn "ProductAttributeOrderingService\|sortProductAttributes" --include=*.ts ts/` at the pin. **The
spec-sheet component never injects it.** So the array orders the staff form, and a backend `sorted()`
orders the customer page.

**The frontend's only definition consumer** is `ProductAttributesStreamService` —
`relativeUrl$ = of('api/product/staff/attribute/all/')` (`product-attributes-stream.service.ts:24`),
decorated with the ordering service at `:33`, consumed by `product-new.component.ts:35` and
`product-update.component.ts:47`. It is the client that proves the definition list already reaches the
staff app.

**Per option, what changes and what inherits free** — `design-A1.md` §6. Headline: option 1 changes
~~6 backend call sites~~ **8 backend read sites, in 3 methods across 2 files** — `biteship.py:60,61,62,90`
(`_parse_product`) and `basket/models.py:1265,1272,1273,1274` (`line_weight_gram`, `line_dimension_cm`);
re-measured at the pin, and a 9th `attr.weight` occurrence is a docstring at `product_attributes.py:10`.
It also removes four generated fields from the staff form; option 2 changes **~20 call sites for `title` alone** and requires rebuilding
`ProductAttributeValue` with locale/scope selectors; option 3 is option 1 plus an unenforced counter.

### 5 · Our numbers

`sql/attribute-definitions.sql` · `sql/manufacturer-as-brand.sql` · `sql/attribute-uses-and-visibility.sql`
· `sql/title-facts-vs-attributes.sql`, all snapshot **2026-09-19 10:27 UTC**.

**Every dedup subquery is bounded to that instant** — `WHERE datastream_metadata.source_timestamp <=
UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside the `ROW_NUMBER` subquery, per BRIEF.md §3.4
(the column is `INT64` epoch milliseconds, verified against
`INFORMATION_SCHEMA.COLUMNS`: `STRUCT<uuid STRING, source_timestamp INT64, change_sequence_number STRING,
change_type STRING, sort_keys ARRAY<STRING>>`, so a bare `TIMESTAMP` literal will not compile). Without
the bound an unbounded CDC dedup drifts as production writes land and the same file returns different
numbers on a later run. **All four were re-run with the bound and every result is byte-identical to the
unbounded run**, so no figure below changed — the bound makes them reproducible, it did not correct them.

**The whole definition corpus, five rows** (`sql/results/attribute-definitions.csv`):

| id | code | name | type | required | value rows |
|---|---|---|---|---|---|
| 2 | `manufacturer` | `Manufacturer` | text | true | 46,499 |
| 3 | `weight` | `Berat (gram)` | float | true | 106,161 |
| 4 | `length` | `Panjang (cm)` | float | true | 106,161 |
| 5 | `width` | `Lebar (cm)` | float | true | 106,161 |
| 6 | `height` | `Tinggi (cm)` | float | true | 106,161 |

`name != code` on all five, the unit is baked into three of the names as free text, and **id 1 is absent**
— the retired `internalname`, migrated to the `title_staff` column (`models.py:394-399`), which is our one
worked example of a promotion from attribute to column.

- **`required` is not enforced over the backlog**: all five are `required=True`, yet **59,662** products
  have no `manufacturer` row.
- **68.5% of the dimension rows are a placeholder**: 290,774 of 424,644 dimension rows are `0`;
  **72,635 products have all four dimensions zero**; 72,644 have `weight = 0`.
- **`weight` is doubly loaded**: of the 12,676 products whose title carries a gram number *and* whose
  `weight > 0`, **10,036 agree exactly** — staff have been recording **net content** in the shipping-weight
  attribute. 2,640 disagree.
- **Facts trapped in the title** (my own regexes, stated in the `.sql`; they differ from `baseline.sql`'s —
  see §8): unit token **26,317** (15,011 active-online) · `N x M` **1,691** · `ISI N` **3,519** · pack word
  **2,000**.
- **Brand, tested against `manufacturer`**: 30,983 letter-bearing rows over **5,510** distinct values;
  **2,867 of 5,510 (52.0%)** distinct values begin `PT.`/`PT `, and **21,577 of 30,983 rows (69.6%)** do;
  only **1,002 rows (3.2%)** have a title that *starts with* the value and 1,923 (6.2%) contain it;
  **2,736 values (49.7%)** are used once; 32 values are used on ≥100 products; 1,542 values span ≥2 main
  categories, one spans **82**. **`manufacturer` is the legal manufacturer, not the brand.**
- **Post-condition-2**: the attribute **value** corpus is `manufacturer` alone — 46,499 values, 59,662
  products with none, 15,516 rows with no ASCII letter on public products, **`'0'` on 12,512 public
  products**. (Under the recommended re-expression of condition 2, §1 and §7, the **definition** corpus
  stays at five: `manufacturer` with `storage='value_row'` and the four dimensions with
  `storage='column'`.)

### 6 · Cleanest / structurally correct for us

Full sketches in `design-A1.md`. The problems each option causes, in short:

**Option 1** — *our code already implements it.* Every fact code reads is a column except the four
dimensions; the only fact code does not read is the only attribute that survives condition 2. Problems:
(a) the rule is **unstable in one direction** — the day a rule reads `rasa`, "code-read" says promote it,
i.e. a migration per new consumer; (b) it gives **no rule for the `ProductMeta` home** (`quantity_per_box`
is universal and code-read and is a column on a side table for a performance reason); (c) its answer for
our biggest data gap (net content, 26,317 titles) is "author a new attribute", which is correct and
unscheduled.

**Option 2** — coherent, and wrong at our size: **`ProductAttributeValue` has no locale and no scope
column**, and a title is per-locale for us. Amazon carries `"selectors": ["marketplace_id","language_tag"]`
on `item_name`; Akeneo carries `{"locale","scope","data"}` on every value. Option 2 is not "move a column
into the existing table", it is "rebuild the value table, then rewrite ~20 core call sites". And the two
platforms it cites keep scalar copies anyway.

**Option 3** — a cap is a governance knob, not an answer. It binds nothing today (1 definition after
condition 2) and contradicts Lock 1 tomorrow (639 nodes authoring their own schemas), unless it is
re-expressed as a **per-category** cap, which is a step-1 decision.

**Option 4 (the extension) — the definition registry covers both storages.** On our models: give
`ProductAttribute` a `storage` discriminator (`value_row` | `column`) and, for `column`, the name of the
`Product`/`ProductMeta` field it describes. Nothing about `ProductAttributeValue` changes. What it buys,
measured against the defects found in §4 and §6:
- **Option 1's instability disappears.** Promoting `rasa` from a value row to a column becomes a change of
  `storage` plus a data move — the staff form, the spec sheet, the feed and the API keep reading one list.
  ⚠️ **It does not by itself fix propagation:** nothing reaches Elasticsearch or Google until
  `ProductAttributeValue` gets a `post_save` receiver and `Product.save()` stops enqueueing at
  `models.py:489` before writing at `models.py:490` (§4).
  Today the same promotion is what happened to `internalname` → `title_staff`, and it left **four dead
  references in three places**, because there was no registry to update: the staff-form ordering array
  (`product-attribute-ordering.service.ts:9-15`), the spec-sheet deny-list
  (`product-addendum-attributes-ui.component.ts:34`), and — uncounted in the first draft — the label/unit
  pair `attribute.key.internalname.{name,unit}` in **both** `ts/assets/i18n/product/en.json` and
  `id.json` (verified: the six keys are `height, internalname, length, manufacturer, weight, width`).
- **Condition 2 stops losing information.** After the four dimensions become columns they would still have
  a definition — name, unit, `display_order`, `is_customer_visible` — instead of vanishing from the one
  place that describes a product's facts.
- **A0's flags become uniform.** `is_customer_visible` on `weight` (a column) and on `manufacturer` (a
  value row) are the same field, so the spec sheet renders from one query.
- **The label change is smaller than it looks.** `ProductAttribute.name` is already the staff-facing label
  of record — Django admin renders it on four paths (§4) — so moving `name`/`unit` onto the definition as
  the served source is a promotion of an existing field, not a new concept.
- ⚠️ **What it touches that options 1 and 3 do not:** `ProductAttributeValue` is a **declared `through=`
  model** of `Product.attributes` (`models.py:419-422`), so option 4's `storage` discriminator — and, much
  more so, option 2's rebuild of the value table — mutate a live `ManyToManyField` declaration on
  `Product`. Option 4 adds columns to the *definition* side and leaves the through-model's shape alone,
  which is why its migration surface stays small; option 2's does not.
- **Cost:** one column on `ProductAttribute`, plus a resolver in the serializer that reads a column when
  `storage = 'column'`. It does **not** require rebuilding `ProductAttributeValue` (option 2's blocker) and
  it does **not** move any existing data.
- **Risk, stated:** a registry that describes columns can drift from the columns it describes. Magento's
  own answer is a `backend_model` per static attribute; ours would be a test that every `storage='column'`
  row names a real field. *Judgement: that is a cheap test and a real risk.*

**Brand** — three homes sketched in `design-A1.md` §4. A free-text column reproduces `manufacturer`'s junk
profile exactly (no normalisation exists anywhere: `value_text` has no `clean()`, no validators, no
case-insensitive uniqueness). A separate `Brand` table is the only design where "SOKLIN" is one row rather
than 82 category-scoped spellings — and it costs a curation project plus a second editor, with **no
precedent in the thirteen** for a merchant-owned brand entity.

### 7 · Recommendation

**Judgement.** Take **option 1**, restated so that it is decidable rather than vibes-based:

> **A fact is a column when a code path reads it or a database constraint must hold over it. A fact is an
> attribute when only humans read it and whether it applies depends on the category. A fact that is
> universal, code-read *and* rarely read goes on the 1:1 side table (`ProductMeta`), which is a column
> home, not a third kind of thing.**

**And take option 4 with it — the one §1 adds to the card's three, with its reason stated: keep one
definition registry over both storages.** The rule above then decides *storage*, not *existence*: every
product fact gets a `ProductAttribute` row describing it (name, unit, order, visibility), and a `storage`
discriminator says whether its value lives in `ProductAttributeValue` or in a column. **This is the single
change that turns option 1 from a rule that needs a migration per new consumer into a rule that needs a
flag flip**, and it is Magento's shipped design (`backend_type = 'static'`), not an invention. *Judgement,
medium-high confidence; it is one column plus a serializer resolver, and it is the only way condition 2
stops deleting four definitions' worth of metadata.*

**And keep definition and value as two objects** — 8 of 13 clearly do, the 2 that do not are flat feeds,
and Shopify states the payoff in one sentence (*"A defined metafield gets a typed editor in the admin,
validation on write, and support for search and filtering. An undefined metafield is stored as a plain
string that merchants can't search or validate."*). Our split is right and **under-specified**; the schema
editor (condition 1) should ship with four repairs — three at `models.py:608-623` and one at
`serializers.py:164-176`: a `UNIQUE` on the
attribute's code within its owner; `category` non-null once Lock 1 lands; the display `name` actually
served by the API (today it reaches only Django admin — §4); and a typed `unit` on the definition, so the
unit stops living in a free-text `name` string *and* in a frontend i18n bundle. **Note the direction this
took after round 2:** because `name` is already the label of record in the one editor that exists, serving
it over the API is a smaller change than an earlier draft implied — and the `UNIQUE`/immutability repairs
matter *more*, because a code rename in admin (`prepopulated_fields = {"code": ("name",)}`, `admin.py:53`)
breaks the i18n lookup and every `attr.<code>` reader while the admin label keeps looking correct.

**Brand: an attribute whose values are rows — with a named promotion trigger — and in no case
`manufacturer`.** The 46,499 `manufacturer` values cannot be renamed into a brand field: 69.6% are `PT …`
companies and only 3.2% match the brand token in the title. That half is settled by our own data and is
high confidence.

On the entity half, **the recommendation is the same but the reasoning had to change after the external
pass**, and the change is on the record rather than smoothed away. What I first wrote — *"no platform in
the thirteen has one"* — is **false**: two platforms model brand as a merchant-owned entity (§2). What
survives, and is much stronger for having been tested:

- **Three vendors independently state the same promotion trigger, and it is the one I had guessed.**
  **Akeneo**, naming brand as the canonical reference entity: *"**This data can be complex to manage
  because it has its own attributes (e.g. a label, a logo, a description or photos). Those information may
  have dedicated pages on one's e-commerce website (e.g. a webpage describing a brand)**…"*
  **WooCommerce**, on why brand is a taxonomy: *"**Each brand can have its own name, description, image,
  and archive page.**"* **commercetools**, as an efficiency rule: *"If the same information is used in a
  large number of Products or Product Variants, it is more efficient to design it as a Custom Object and
  reference it using an Attribute."* **The trigger is "brand has acquired facts and a page of its own",
  from three vendors, in three different words.**
- **Akeneo ships both ends of the path**, which is the single most useful fact for us: brand is a
  `pim_catalog_simpleselect` attribute with option rows in its own demo catalogue, **and** the canonical
  reference entity in its EE documentation. The same vendor does not treat these as rival designs; it
  treats them as different stages.
- **Magento, which has no brand page, never promoted it**: brand stays the `manufacturer` attribute,
  `'input' => 'select'`, `'user_defined' => true`, `'filterable' => true` (`CategorySetup.php:537-551`).
  **The platforms differ by whether brand has its own page, not by taste.**
- **We have no brand page, no brand logo and no brand navigation, and none is on the Step-0 or Step-1
  list.** So the trigger is not met. *Judgement.*
- **And the promotion is far cheaper for them than for us.** In WooCommerce an attribute value is *already*
  a `wp_terms` row and in Akeneo an `AttributeOption` row, so promotion is a change of label and UI.
  **Our attribute values are not rows at all** — that is A4's open question. Building a `Brand` table
  before A4 answers would create our first shared value table as a one-off, for the attribute whose data
  is worst.

So: **brand becomes an attribute with option rows now, and is promoted to its own table the day it needs a
page, a logo or navigation of its own** — the path WooCommerce took in 2024-11 (plugin attribute → core
taxonomy, shipped disabled, enabled 2025-01) and the path Akeneo documents from one end to the other.

**Confidence.** High on option 1 (our code already implements it; 9 of 13 are in the same family; the 3
that are not are a PIM, an EAV monolith and a feed schema). High on definition-vs-value. **Medium-high** on
option 4 — it is a proposal, backed by two platforms that keep definitions for column-stored facts, and it
costs one column. **Medium** on brand: the `manufacturer ≠ brand` half is high confidence (our own data),
the entity half is medium-high because the external pass **refuted** the absence argument I first wrote and
replaced it with a better one: three vendors state the same promotion trigger, and one of them (Akeneo)
ships both ends of the path (§7). The judgement we retain is whether brand has a page of its own — and it
does not.

**What would reopen it.** (i) Two or more staff-authored attributes acquiring code readers within a year —
then the promotion migrations cost more than option 2's read indirection would have. (ii) Lock 1 producing
per-category attribute counts large enough that a governance cap is needed — then option 3 returns as a
*per-category* cap. (iii) A decision to sell in a second language or a second market, which makes
`ProductAttributeValue`'s missing locale/scope columns urgent regardless of A1.

**What it forces in steps 1–5.** **Condition 2 is confirmed as the right first move and is re-expressed,
not merely accepted** (§1): the four *values* move to `NOT NULL` columns; the four *definitions* stay with
`storage='column'`. ~~It is the *only* correction option 1 needs~~ — that was wrong on this brief's own
recommendation, since option 4 is a second correction and it lands on condition 2 itself. Ship it knowing
68.4% of products will carry `0` in the new `NOT NULL` columns, so a zero must not be read as a fact. **D18** (is the attribute set a closed contract, enforced
where?) inherits a clear lean: of the thirteen, the ones that close it do so **above the database** —
commercetools by the API, Salesforce by the registry, Akeneo by a validator with a stated hole, Magento by
the type model with `catalog_product_entity` declaring **zero foreign keys** — and we already close it
above the database at `staff_serializers.py:74-81`. **D9** (quantities: text vs number+unit) is **not
decided here** — it is ATTR-VALUE's, and this brief hands it one fact: our unit is currently modelled in
two non-typed places at once, and 10,036 products have net content hiding in the shipping-weight column.

### 8 · Limits and corrections

**Corrections after red-team round 1** (findings numbered as in `redteam-round1.md`; nothing deleted,
everything struck-and-replaced at the root):

- **3 (BLOCKING) — fixed.** Condition 2's disposition is now stated as a **re-expression**, in §1, §5 and
  §7: the four *values* leave the value table, the four *definitions* stay with `storage='column'`. §1 and
  §5 now say "the entire attribute **value** corpus"; §7 drops *"the only correction option 1 needs"*.
- **5 — fixed.** Walmart's own ⚠️ Scope correction (`$ref` 2 on the read-side OpenAPI; *"would be too
  broad"*) is now quoted in §2 and in `matrix-A1.md`, and Walmart is filed "no" **on the write path**.
- **8 — fixed.** The index/feed fan-out is now in §4 as its own block: `receivers.py:31-41` →
  `index_utils.py:11-16` (Elasticsearch **and** Google), **no receiver on `ProductAttributeValue`**, and
  `Product.save()` enqueues at `models.py:489` before writing at `:490`.
- **9 — fixed.** `catalogue.view_productattribute` on both stacks added to §4's table and to §A0.4/§A0.7.
- **10 — fixed.** `ProductAttributesStreamService` (`:24`, `:33`) and its two consumers added to §4.
- **11 — fixed.** ~~6 backend call sites~~ → **8 read sites in 3 methods across 2 files**, re-measured;
  the docstring at `product_attributes.py:10` is named and excluded.
- **13 — fixed.** `api_mixins.py:11-22` → `py/mono/solvent/api/shared/views/api_mixins.py:11-22` (the
  sibling file in `apiproduct/` is a different class).
- **14 — fixed.** `Product.attributes` M2M through-model and `ProductClass.default()` = `objects.get()`
  with its two call sites (`staff_views.py:67`, `staff_serializers.py:118`) added to §4.
- **15 — fixed.** The stated route was a dead end: **0** migrations mention `manufacturer`. Replaced with
  the production audit trail / the introducing issue.
- **17 — fixed.** The Square 404 instrument now says the three `.html` bodies **differ** and the three
  tag-stripped `.txt` extracts are identical.
- **19 — fixed.** The `internalname` promotion left **four** dead references in **three** places, not two
  in two: the i18n label/unit pair in both bundles was uncounted. §6 corrected.
- **20 — fixed.** §2 now says "four platforms, in **two kinds**", and the pre-revision "not established"
  list names all three (Square, Salesforce, WooCommerce).
- **21 — fixed.** Magento's flag count is now stated with its scope at every point of use (22 columns in
  `Catalog`, **24** merged with `CatalogSearch`'s `search_weight` and `Swatches`' `additional_data`), and
  §2 no longer calls all 24 "flags".
- **22 — fixed.** §4's table no longer claims false exhaustiveness: `validate_attributes()`, `attr.save()`
  and `ProductAttributeValueStaffSerializer` (one `CharField` for all six types) are now rows in it.
- **23 — fixed.** `search_indexes.py:92-95`→`93-96`; `products_api.py:190-241`→`188-241`; `isStatic()`
  harmonised to `:794-801`; `class-wc-brands.php` harmonised to `:275-331`.
- **24 — fixed.** *"0 hits outside migrations"* → **"0 hits, full stop"**, with the one frontend reader
  (the i18n key) named beside it.
- **25 — fixed.** The corpus table now lists `doc-woocommerce-brands.txt`, `Internal-Brands.php`,
  `store-api-product-brands.md` and `ProductBrandSchema.php`, and both WooCommerce quotes carry file:line.
- **28 — fixed.** "four repairs, all at `models.py:608-623`" → three there, one at `serializers.py:164-176`.


- **A claim in this brief was refuted by its own external pass, and the refutation is kept visible.**
  §2 and §7 first said no platform in the thirteen models brand as a merchant-owned entity. **Two do** —
  WooCommerce in core since 9.4.0 (2024-11-11, enabled 9.6) and Akeneo as its canonical EE Reference
  Entity. The corrected tally and the revised recommendation are in §2 and §7; `matrix-A1.md` keeps the
  pre-revision list beside the correction so the change can be audited.
- **Single-route, and it matters: `brand` as a property of an Amazon product-type JSON schema.** Only the
  `product_identity` **property-name list** was ever obtained; the schema body sits behind
  `SchemaLink.link.resource`, which the vendor's own example prints as the placeholder
  `"https://schema-url"`, and `schemas.amazon.com` has **no DNS A record** from this machine. Four
  developer-docs pages were fetched (two returned SOFT_404) and the repo's `schemas/` directory holds only
  `data-kiosk`, `feeds`, `notifications`, `reports`. **Route: a `getDefinitionsProductType` call with LWA
  credentials, then following `schema.link.resource`.** So "Amazon's title and brand are attributes" rests
  on the property-group list, not on a retrieved schema — consistent with #10976's own P2/P3 warning.
- **Instrumented absences worth keeping** (each names artifact, size and pattern): **0** SP-API paths
  containing `brand` across 67 model JSONs / 8,329,281 B (3 schema *names*: `BrandRefinement` ×2,
  `BrandSegmentDetails`); **0** Merchant API resources containing `brand` across 15 discovery documents /
  1,045,733 B (1 schema, `BestSellersBrandView` in `reports_v1`), and `manufacturer`/`vendor`/`marque`
  **0** each; **0** `brand` hits in commercetools' 3,103,801-byte OpenAPI and 538,456-byte GraphQL SDL, and
  none of its 50 top-level resources is a brand.
- **Not collected:** whether `manufacturer` was *ever* intended as brand (no issue in the evidence pack
  states it). ~~Route: `git log -S "manufacturer"` on the migration that created attribute id 2.~~ **That
  route does not exist**: `grep -rln "manufacturer" py/mono/solvent/catalogue/migrations/` → **0 files**,
  and the only migration touching `ProductAttribute` at all is `0011_add_title_staff_field.py`. The five
  definitions are **production data**, not migration data. **Real route:** the production audit trail for
  `catalogue_productattribute` id 2, or the issue/PR that introduced it.
- **CDC snapshot bound applied (systemic fix from the FAMILY red-team, BRIEF.md §3.4).** All four SQL
  files now carry `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19
  10:27:00+00')` inside every `ROW_NUMBER` dedup subquery — 3 per file, 12 in total. Re-run 2026-09-19:
  **every result byte-identical to the pre-bound run**, so no number in this brief changed. The saved
  `results/*.csv` are the bounded re-runs. The column is `INT64` epoch milliseconds; a bare `TIMESTAMP`
  literal fails to compile, which is why `UNIX_MILLIS()` is required.
- **Instrument note:** my title regexes in `sql/title-facts-vs-attributes.sql` differ from
  `baseline.sql`'s and return different counts (unit token 26,317 vs the baseline's 30,417; `N x M` 1,691
  vs 2,168; pack word 2,000 vs 1,583). Both are stated in their `.sql` files; neither is wrong, they match
  different patterns. Use one or the other, never both.
- **New sources fetched for this card** (external-research standard, corpus left in place, listed in full
  at the end of this brief): Square's Connect OpenAPI spec (`corpus/square/square-api.json`, 3,273,134 B)
  + 13 rendered doc pages; Shopify's live Admin GraphQL `2026-07` introspection
  (`corpus/shopify/sfy-admin-2026-07-introspection.json`, 6,600,955 B), `2025-10` `ProductVariant`, the
  changelog feed (1,729,431 B, 784 items) and 30 doc pages; eBay's three OpenAPI contracts (Commerce
  Taxonomy v1.1.1, Sell Inventory 1.18.4, Buy Browse v1.20.4 — 1,265,461 B together), 11 type pages and the
  `eBay/taxonomy-sdk` repo; a sparse clone of `magento/magento2` @ `874f1f5c` (2026-09-17, 56 MB) plus
  three live Adobe Experience League pages.
- **A block that was routed around, recorded:** `developer.ebay.com` returns **HTTP 403** to this client on
  every path — six named attempts including a real browser. The eBay artifacts above are **Wayback `id_`
  raw captures of the vendor origin** (P1, each with its origin URL and capture timestamp) plus the
  vendor's own GitHub repo (P0). `www.ebay.com/b/…` also 403s and `…/help/…item-specifics` redirects to a
  captcha, so **eBay's buyer-side filter UI was not observed directly**; the filter claim rests on the
  Seller Center page (live, 200) and the Browse API contract instead.
- **Carried hedge:** the Amazon per-product-type JSON schema dumps in #10976 are **P2/P3** and the record
  forbids restating them as Amazon's own — *"Nothing here may be restated as "Amazon's schema says X"."*
  The Amazon quotes used above are from Amazon's own sandbox response and from its API model files.

---


**Corrections after red-team round 2:**

- **2 — fixed properly** (round 1 marked it fixed; the M2M half had not landed). §4 now carries a
  `Product.attributes` row — `ManyToManyField("catalogue.ProductAttribute", through="ProductAttributeValue")`
  (`models.py:419-422`) — and §6's option-4 bullet states what it means: option 2's rebuild of the value
  table mutates a live `ManyToManyField` declaration on `Product`, while option 4 adds columns to the
  *definition* side and leaves the through-model's shape alone. `design-A1.md` §6's "New tables" row says
  the same.
- **3 — fixed, and it moved a claim in our favour.** ~~"The definition's `name` is dead"~~ was **false**.
  `name` renders on four live Django-admin paths, all re-opened at the pin:
  `ProductAttributeValue.summary()` (`models.py:763-766`), `Product.attribute_summary` on **every row of
  the admin product list** (`models.py:520-525`; `admin.py:43`), `ProductAttributeAdmin.list_display`
  (`admin.py:52`), and `ProductAttributeValue.__str__` in every inline row (`models.py:760-761`;
  `admin.py:18-19,46`). Restated as **"served to no API client, and read only by Django admin"** in §4 here
  and in `design-A1.md` §0 and §5. Two downstream effects, both carried: option 4's label change is
  **smaller** than claimed (the label of record already exists), and the `UNIQUE`/immutability repairs
  matter **more** (an admin code rename breaks the i18n lookup and every `attr.<code>` reader while the
  admin label still looks right). §7's repair list restated.
- **4 — fixed properly.** §4's table heading dropped *"exhaustively"* and *"in the backend"* — it now reads
  *"Every reader and writer of an attribute value or definition, both stacks (not claimed exhaustive)"* —
  and gained the two missing rows: `Product.attribute_summary` (the only backend consumer of
  `ProductAttribute.name`) and the `AttributeInline` write surface on `ProductAdmin`.
- **5 — fixed at the sentence that does the work.** §A0.2's Square bullet no longer says the API-limits 404
  is *"md5-identical to two other 404s"*; it now says the tag-stripped bodies are identical
  (`f3cdc223…`, 830 B each) while the raw `.html` bodies differ.
- **6 — fixed.** `rationale.md`'s copy of the labelled inference now reads "Magento **24**".
- **8 — fixed.** The length note now says ~**33K per card**, not ~23K.
- **9 — fixed.** The `ProductAttributesStreamService` consumer cites now point at the `inject(` calls,
  `product-new.component.ts:35` and `product-update.component.ts:47`.

## A2 · Is a variant dimension an attribute, or its own object?

### 1 · Options

1. **One object with a role flag** (the card cites WooCommerce `is_variation`, eBay, Magento). A group's
   axes are some of its category's attributes; a member's axis value is its ordinary attribute value.
   *Nothing new to store.*
2. **Two objects**: options for variation, attributes for everything else (the card cites Shopify, Square,
   Shopee). The group declares its axes; a member stores a "selected option" separately.

**This is D3, closed 2026-08-13 as (1) on a 4–4 tie and confirmed by Lock 1.** The card requires this brief
to **confirm or reopen it, and say which on the record.** Touches D3, D4, D5, D7, D8.

### 2 · Who uses which, who does not

**The question splits in two and the halves answer differently.** Full table: `matrix-A2.md`.

**(a) Declaration — 5 · 4, with five rows that could move it.**

| Option | Count | Platforms |
|---|---|---|
| **1** one object + role flag / name list | **5** | Amazon · Walmart · Akeneo · WooCommerce · Magento |
| **2** a dedicated axis object | **4** | Shopify · Shopee · Square · Salesforce B2C |
| both, required together | 1 | Google |
| neither | 1 | commercetools |
| ambiguous | 1 | eBay |
| era-split, opposite directions | 1 | Tokopedia (A = 2 · B = 1) |

*Named ambiguous:* **eBay** — a `Specification` child container with **no id** sitting on top of
`aspectEnabledForVariations`, a boolean on an ordinary category aspect, present on **197,046 of 197,046**
aspects. **Walmart** — filed option 1 here (*"The axis is an attribute NAME carried as a string… **not an
object, and it has no identifier**"*, `valueId` 0 / `attributeId` 0 / `$ref` 0 over 451 MB); **#11031 files
it "cannot be assigned"** because 280 of 6,967 types name axes that are not their own attributes and the
swatch enum differs from the axis enum on 1,711 types. **Moving Walmart back restores #11031's 4–4.**
**Google** — requires both and writes the value twice; equality between the two is *"not stated"*.
**commercetools** — no axis exists; its nearest mechanism (`attributeConstraint`) is a flag on an ordinary
attribute definition. **Magento** — #11031 attributes the headline word *"Both"* to the record; **no such headline is in the
Revision-2 record.** Instrument, re-run 2026-09-19 with the scope named (the earlier "19 times" reproduced
under no scoping and is withdrawn): over all 1,430 lines of `evidence/issues/11082.md`, case-insensitive
`\bboth\b` → **33**; body only, to the first `## Comment` → **14**; case-sensitive `\bBoth\b` → **3**,
at lines 688, 765 and 943. **None is a headline for the axis question**, so the substantive correction to
#11031 stands; the number that certified it did not.

**So the declaration tie #11031 found is intact in substance. No plurality can be claimed; there is no
industry rule to adopt.**

**(b) Value storage — where a member's flavour value lives — leans same-store, 6 · 4.**

| Answer | Count | Platforms |
|---|---|---|
| same store as ordinary attribute values | **6** | Amazon · eBay · Walmart · Akeneo · WooCommerce · Magento |
| separate store | **4** | Shopify · Shopee · Square · Salesforce B2C |
| both — written twice | 1 | Google |
| N/A | 1 | commercetools |
| era-split | 1 | Tokopedia |

**Card pointer executed** — *"what each side pays: duplicated values, two editors, two filter paths"*:
`matrix-A2.md` §(c), with the records' own words. Headlines: duplication is paid by the **option-1**
platforms at *family* level (Amazon *"Most product facts must be **replicated** across all listings within the variation family."*;
Walmart *"The axis value is copied per item; there is no shared value row"*) and by **option 2** at
*representation* level (WooCommerce: *"One global attribute value has three simultaneous
representations."*). Two editors and two filter paths are paid only by option 2: Shopee's two namespaces
share **0 of 92 API records**; Square's option queries are separate classes from the custom-attribute
search path. And **Shopee shows the sharpest cost of two objects**: *"An attribute value is typed and
carries a unit; a variation option is a bare label."*

### 3 · Why

**Full set: `rationale.md` §A2.** The three that decide it:

- **Salesforce is the only platform that documents a migration between the two, and it ran 1 → 2**
  (#11050 §1.8, the vendor's own note): *"The latter are historical leftovers from when object attributes
  were used directly as the basis for variation, and **the value lists were stored directly on the
  ObjectAttributeDefinition**. Every ProductVariationAttribute corresponds with exactly one
  ObjectAttributeDefinition, but **values are now stored on the ProductVariationAttribute and not the
  ObjectAttributeDefinition**."* **Read it precisely: the *definition* stayed shared and 1:1; only the
  *value list* moved off it.** That is an argument about where an axis's allowed values live — A4's and
  A3's question — not about whether an axis is an attribute.
- **Shopify built a bridge back from 2 to 1 and marks it unfinished**: `linkedMetafield` — *"This API is
  currently in early access."* — widened on 2025-01-01 (`corpus/shopify/sfy-changelog-feed.xml`): *"Up
  until now, merchants had the ability to link their options to category metafields… **This release expands
  that functionality to include any metaobject reference list.**"*, with the stated motive *"Instead of
  simple text values like "Red" or "Large", your options reference metaobjects that contain structured
  data, **enabling features like improved search and marketplace integration**."*
- **eBay states why not every attribute may be an axis** (#11045 §2): *"**Not all aspects are allowed as a
  pivoting aspect.** … To see which aspects are allowed as pivoting aspects, you can use the
  `getItemAspectsForCategory` method and look for a value of `true` in the `aspectEnabledForVariations`
  field."* — option 1's own justification, from a platform filed ambiguous. eBay's contract description of
  that flag, re-read at origin: *"A value of `true` indicates that this aspect can be used to help identify
  item variations."* (`corpus/ebay/openapi-commerce_taxonomy_v1_oas3.json`, v1.1.1).

**Inference, labelled.** The four clean option-2 platforms (Shopify, Shopee, Square, Salesforce) are all
**merchant/seller tools with a buyer-facing picker as a first-class UI**, and all four needed an ordered,
swatchable, shareable value row (`ProductOptionValue.swatch`, `CatalogItemOptionValue.color`/`ordinal`,
`variation_option_id` + `image_id`). The five option-1 platforms either have no picker to render (Akeneo),
render it from a flat feed (Amazon, Walmart), or build it from an EAV option row that already has
`sort_order` and a per-store label (Magento, WooCommerce). **The split is not about axes. It is about
whether the platform's ordinary attribute values were already rows with a position.** No vendor states
this.

### 4 · Our code today

Both shapes sketched in `design-A2.md` §1–§2, against the tables, the write path, the editor, search and
the feed. The facts that dominate:

- **No option/enum attribute type exists.** `ProductAttribute.TYPE_CHOICES` is
  text/integer/boolean/float/date/datetime (`models.py:641-648`) and `ProductAttributeValue` is six scalar
  columns (`models.py:742-747`). **There is no shared value row and no position column anywhere.** So both
  shapes must build a governed, ordered value list from zero; the choice is only *where it lives*.
- **The axis values do not exist in our data at all.** Across the 43 Indomie rows
  (`sql/results/indomie.csv`) the flavour is a substring of `title` and of nothing else; every row carries
  exactly the five values `height, length, manufacturer, weight, width`. **Nothing inherits for free under
  either shape.**
- **Under shape 1 the axis value costs zero new write code *on the authoring path*, and the same new work
  as shape 2 on the fan-out path.** Authoring: `_assign_attributes()` already resolves any declared code
  (`staff_serializers.py:65-81`), the staff form already generates a field per definition
  (`product-update-staff-form-ui.component.ts:147-169`, `getProductAttributeFields$`), and
  `ProductDetailsSerializer` already emits every value (`serializers.py:200,207`); under shape 2 each of
  those needs a second, differently-shaped path. **Fan-out, new to this revision:** there is **no
  `post_save` receiver on `ProductAttributeValue`** anywhere, and `Product.save()` enqueues the index and
  Google pushes at `models.py:489` (`super().save()` → `receivers.py:31-41` → `index_utils.py:11-16`)
  **before** `attr.save()` writes the values at `models.py:490`. So the moment an axis value must reach
  Elasticsearch or the feed, **both shapes** need a new receiver **and** a save-ordering change. Shape 1's
  advantage is on authoring, not on propagation.
- **Under shape 1 the sibling-uniqueness invariant stops being a database constraint.** The combination
  spans N `ProductAttributeValue` rows, so it needs a materialised `variant_key` on the member plus
  `UNIQUE (group, variant_key)` — and the lock's own reopen trigger names exactly this (*"the axis key
  cannot be made genuinely derived → B loses its distinguishing constraints"*). Under shape 2 it is one
  step closer: `UNIQUE (product, option)` is real, and the combination key is derived from FKs.
- **Tables beyond Lock 2:** shape 1 = **1** (the dimension row) + 1 boolean + 1 derived column. Shape 2 =
  **3** + 1 derived column.
- **Under Lock 1, shape 2 has no home for "the category owns axis eligibility"** unless the option carries
  an `attribute` FK — at which point it has re-absorbed shape 1 and kept its extra value table.

### 5 · Our numbers

- Variant families today: **zero**. `productclass_rows = 1`; there is no group table; the 43 Indomie rows
  are 43 independent products (`sql/results/indomie.csv`, `baseline.json`).
- Attribute value rows that would be reachable as axis values under shape 1 today: **0** — flavour is not
  stored anywhere (see §4).
- Rows shape 1 adds for a 33-member family: 1 dimension row + 33 `ProductAttributeValue` rows. Shape 2
  adds: 1 option row + N option-value rows + 33 selected-option rows, **plus** 33 more
  `ProductAttributeValue` rows if the flavour must also appear on the spec sheet or in a filter.
- Junk that would flow straight into a picker if values stay free text: the only precedent we have is
  `manufacturer` — 5,510 distinct values of which **2,736 are used once** and 15,516 rows carry no ASCII
  letter (`sql/results/manufacturer-as-brand.csv`).

### 6 · Cleanest / structurally correct for us

`design-A2.md` §5 prices both sides against our code. The decisive asymmetries:

1. **Shape 2's advertised benefits — value ordering and a closed list — are not benefits of *two objects*.
   They are benefits of *rows for values*.** Magento gets both inside one object
   (`eav_attribute_option.sort_order` + a per-parent join row). `design-A2.md` §3 names this explicitly as
   shape **1b**, which is what shape 1 becomes once A4 answers. A reader comparing the two lists without
   that note will conclude two objects are needed for a picker; they are not.
2. **Shape 2 spends the budget away from where our pain is measurable.** After condition 2 the attribute
   system is one definition, 46,499 values, 33% of them junk. Shape 2 leaves all of that untouched.
3. **Shape 1's real cost is the derived `variant_key`**, and it is a genuine cost: a database invariant
   becomes a derived column recomputed on a hook that fires on every `Product.save()`
   (`models.py:486-491` → `product_attributes.py:60-64`).
4. **Shape 1 makes "don't show the axis twice" a flag rather than a structural fact** — the axis value will
   appear on the spec sheet for free, because there is no structural difference from any other value. That
   is A0's question, and it is a cost shape 1 hands to A0.

### 7 · Recommendation

**On the record: D3 is CONFIRMED, not reopened — but on a different argument from the one it was closed
on.** D3 was closed on a 4–4 declaration tie plus a bridging argument. That tie survives re-derivation
(§2a). What this brief adds is that the tie is on the **wrong half of the question**: on **value storage**
the evidence leans 6–4 to the same store, and value storage is the half that prices our build.

**Judgement.** One object with a role flag, expressed as: **an axis is a category-owned `ProductAttribute`
marked eligible, plus a thin per-family dimension row (`group`, `attribute`, `position`); a member's axis
value is its ordinary `ProductAttributeValue`.**

**Confidence: medium-high.** The platform evidence is a genuine tie on declaration and a lean on storage;
what carries the recommendation is our own code (one write path, one editor, one filter path to build
instead of two) and Lock 1 (which gives axis eligibility a home only under one object).

**A2's dependence on A4, stated explicitly (ATTR-VALUE owns the decision).** Shape 1 works **only if a
value can be a row**. If A4 decides values stay free strings, shape 1 has nowhere to put `position`
(#10778 V5 already records the ordering column as missing), and a picker would need a new table anyway — at
which point shape 2's cost gap narrows sharply. **If A4 answers "free string, no rows", A2 should be
re-opened.**

**The one piece of counter-evidence that must not be smoothed away**: Salesforce migrated 1 → 2 and says
why — value lists on a shared definition. **If** A3 answers C5's way (one global `Rasa` subscribed by many
categories) our `Rasa` would be one definition shared by noodles and snacks, and its value list would be
global unless A3 or A4 scopes it. **That is the same failure mode Salesforce fixed by splitting the object.** It can be
answered inside shape 1 by scoping the value list per category — but it has to be answered, and it is A3's
and A4's to answer.

**#10778 items — confirm / re-express / supersede.** **V1** (axis names from a shared staff-extendable
catalogue) — **re-expressed**: the catalogue survives as a catalogue of *definitions*, but under Lock 1 it
is the **category-owned** `ProductAttribute` set, so "shared" now means "reusable across categories by
whatever mechanism A3 chooses", not "global by construction". **V2** (one storage shape + a per-dimension
governance flag) — **re-expressed** exactly as #11031 already proposes: the flag becomes the attribute's
input type. **V4/V5** (a single text label, hand-ordered by a position column) — **confirmed in substance,
home moved to the value**, and note that V5's missing column is now A2's hard dependency on A4, not a
detail. **C8** (one `Ukuran`, never split) — untouched here. **Decision B's re-expression under D3 stands.**

**C5 — ~~confirmed for names~~ → AT RISK under Lock 1, and REFERRED TO A3 (ATTR-VALUE), which owns it.**
C5 says the name catalogue is **one global catalogue, not scoped per category**. This brief's own reading
of Lock 1 makes `ProductAttribute.product_class` become `ProductAttribute.category`, i.e. **the name
catalogue becomes per-category by construction** — which is what C5 denies. The two cannot both hold, and
an earlier draft of this paragraph asserted both; that is corrected here rather than left standing.
Nothing in this brief's recommended design creates a global name registry above the per-category
definitions: the field list it hands condition 1 in §A0.7 is `code, name, type, required,
is_axis_eligible, is_customer_visible, is_filterable, display_order, unit` — no cross-category name
object. **A2 therefore does not confirm C5 and does not supersede it either**: whether one `Rasa`
definition is shared by every category that wants it, or each category owns a copy, **is A3**, and
ATTR-VALUE owns A3. A2's only claim on it is a dependency, stated in the paragraph above: if A3 leaves one
global `Rasa` whose value list is also global, the Salesforce failure mode applies. *Judgement: C5 as
written is not survivable under Lock 1 without a second object above the category-owned definitions;
whether to build one is A3's call, not this card's.*

**What it forces in steps 1–5.** **D4** (does the type gate which attributes may be axes?) → yes, as an
`is_axis_eligible` boolean on the category-owned definition; eBay is the worked precedent
(`aspectEnabledForVariations` on 197,046 of 197,046 aspects, 73,833 true / 123,213 false), and its ratio is
the answer to "is a second flag worth it": **62% of aspects are not axis-eligible**. **D5** (family chooses
vs type imposes) → the family chooses, from the gated set, via the dimension row. ~~which is what 6 of the
7 platforms with a family-level choice do~~ — that tally was unsourced and appears nowhere in the evidence.
**Re-derived from #11031's D5 row, which covers 10 of the 13** (`matrix-A2.md` §(d)): **8 family-chooses**
(eBay, Walmart, Shopee, Tokopedia, Square, Salesforce, Magento, WooCommerce) · **1 type-imposes** (Akeneo,
and the record attaches its own ⚠️ *"Classification note — this is a judgement, and the record does not
make it"*, adding that on a narrower reading the family still chooses) · **1 neither** (commercetools).
Amazon, Shopify and Google are not covered by that row. **D6** (axis cap) → a validator, not a schema shape. **D7**
(fill + uniqueness) → a validator plus the derived `variant_key`; neither is expressible as a plain
constraint over EAV rows. **D8** (shared value row vs copied string) → **not decided here**; it is A4's,
and A2's recommendation is conditional on it.

### 8 · Limits and corrections

**Corrections after red-team round 1:**

- **2 (BLOCKING) — fixed.** ~~C5 confirmed for names~~ → **C5 is AT RISK under Lock 1 and is REFERRED TO
  A3**, because this brief's own Lock-1 reading makes the name catalogue per-category, which is what C5
  denies. V1 is now filed **re-expressed** rather than confirmed, for the same reason. A2 claims neither a
  confirmation nor a supersession of C5 — ATTR-VALUE owns A3.
- **4 — fixed.** The #11082 `both` instrument is restated with its scope: case-sensitive `\bBoth\b` →
  **3** (lines 688, 765, 943), case-insensitive **33** whole / **14** body. ~~19~~ reproduced under no
  scoping and is withdrawn. The substantive correction to #11031 is unaffected — none of the three is a
  headline.
- **8 — fixed.** *"zero new write code"* is now scoped to the **authoring path**, and the propagation cost
  (a `post_save` receiver on `ProductAttributeValue` + re-ordering `Product.save()`) is priced in §4 and in
  `design-A2.md` §1.8/§2.4/§5 as **a floor under both shapes, not a differentiator**.
- **12 — fixed.** ~~"6 of the 7 platforms with a family-level choice"~~ was unsourced and appears nowhere
  in the evidence. Replaced by a derivation in `matrix-A2.md` §(d) from #11031's D5 row, which covers 10 of
  13: **8 family-chooses · 1 type-imposes (Akeneo, with the record's own ⚠️ classification note) · 1
  neither**; Amazon, Shopify and Google are not covered.
- **26 — fixed.** The Amazon quote is restored to the end of its clause: *"…across all listings **within
  the variation family**."*
- **27 — fixed.** "four rows that could move it" → **five** (eBay, Walmart, Google, commercetools,
  Magento), in both §2 and `matrix-A2.md`. Both tallies already summed to 13.


- **A departure from #11031 is on the record**: Walmart moved from "cannot be assigned" to option 1, with
  the counter-fact (280 types / 1,711 swatch divergences) quoted whole. A reader who prefers #11031's
  classification gets 4–4; nothing else in this section changes.
- **A correction to #11031**: its Magento row says *"the record's headline word is **"Both"**"*. No such
  headline is in #11082 Revision 2. Instrument with its scope: case-sensitive `\bBoth\b` → **3**
  (lines 688, 765, 943), none a headline; case-insensitive over the whole record → **33**, body only →
  **14**. ~~19 times~~ was wrong under every scoping and is withdrawn. The classification #11031 reaches is
  unaffected; its stated reason is.
- **Not collected**: whether any of the four option-2 platforms publishes a rationale for choosing two
  objects at the outset (as opposed to Shopify's bridge and Salesforce's migration). Route: Shopify
  engineering blog and the pre-2024 changelog; the 784-item feed was searched and returned nothing
  (`corpus/shopify/sfy-changelog-feed.xml`).

---


**Corrections after red-team round 2:**

- **7 — fixed.** `matrix-A2.md`'s tallies ran (a) · (b) · **(d)** · (c) because the new D5 derivation was
  inserted before §(c). §(d) now sits after §(c), so §A2.2's pointer at *"`matrix-A2.md` §(c)"* lands where
  a reader expects. No content changed.

## A0 · What are attributes for, and are some of them hidden?

### 1 · Options

1. **Visibility is a property of the attribute definition** — shown or hidden everywhere it appears.
2. **Per category membership** — Rasa shown for food, hidden for cleaning products.
3. **Per channel** — shown online, hidden at the till, sent to Google.

And the card's first question: **which uses do we want, in what order?** — the variant picker, search
filters, a spec sheet, Google feed fields, internal rules (age wall, replenishment, purchasing). Touches
A2, A4, D17. **This brief also owns the A0↔A5 coupling** (visibility per channel vs per level).

### 2 · Who uses which, who does not

Full table: `matrix-A0.md`.

**Option 1 is the near-unanimous answer: 10 of 13 put at least one visibility / filterability / purpose
control on the definition.**

**Named ambiguous / hedged rows — six of the ten carry a qualification, and the brief must show it**
(fuller in `matrix-A0.md`): **Square** — #11049 cites the two visibility enums **by arity only**
(`enum (2)` / `enum (3)`), never enumerating or glossing them, and a plausible third `app_visibility`
value is **rejected live** as `INVALID_ENUM_VALUE` against a declared 3-value enum, unreconciled *(the
external pass closed the enumeration half — both enums are whole in §3 — the live rejection stands)*.
**Magento** — #11082 states a meaning for **only four of the flags** and **no instance of
`catalog_eav_attribute` was ever retrieved**, only a storefront projection with different field names
*(closed at source in §2, with two gaps left: 8 of the 24 columns are named by no Adobe page, and
`is_used_for_price_rules` is written by no `PropertyMapper`)*. **Akeneo · WooCommerce · commercetools** —
the flags exist (`useable_as_grid_filter`, `is_visible`, `inputHint`) and **the records quote no vendor
definition of any of the three**; WooCommerce's `attribute_public` additionally contradicts itself across
routes (DDL default `1`, REST `has_archives` default `false`, all four live rows `0`). **Walmart** — its
`@group=` tier is a **purpose** tier, not a visibility flag, and per-attribute viewing/editing restrictions
exist only as **workbook column headers with no values** (`Restrict Viewing by`, `Restrict Editing For`).
**So the 10 is 4 unhedged (Amazon, Shopify, eBay, Shopee) + 5 carrying an evidence-quality hedge (Square,
Magento, Akeneo, WooCommerce, commercetools) + 1 reclassified (Walmart, whose control is a *purpose* tier
rather than a visibility flag) = 10.** ~~5 unhedged + 5 qualified~~ was an arithmetic error that
contradicted its own list one line later — the same failure class as round-1 finding 6, and corrected the
same way. The direction is unaffected; the strength is.

| Answer | Count | Platforms |
|---|---|---|
| **yes** | **10** | Amazon (`hidden`, `editable`) · Shopify (`access`, `capabilities`, `pinnedPosition`) · eBay (11 per-aspect flags) · Walmart (a `@group=` purpose tier on **100% of 383,947 slots**) · Shopee (`support_search_value`, `mandatory`) · Square (`seller_visibility`, `app_visibility`) · Akeneo (`useable_as_grid_filter`, `scopable`) · WooCommerce (`is_visible`, `attribute_public`) · commercetools (`isSearchable`) · Magento (24 columns on the merged `catalog_eav_attribute`, ~18 of them behaviour flags) |
| **no / not established** | **3** | Google (destination controls are per *product*) · Tokopedia (neither era) · Salesforce B2C (visibility comes from attaching a *group* to a category, not from a flag) |

**Option 2 is a mirage, and this is the most useful finding in the card.** A category-like object decides
attributes in 8 of 13 — but in every one of them it decides **membership** (which attributes a product
carries), never **visibility** (whether a carried attribute is shown). Even Shopify's conditional
definitions, the closest case, resolve to *"appear on all product detail pages in the Shopify admin"* —
membership in the editor. **The card's option 2 is A3's question, not A0's.**

**Option 3 is real but almost always means something else: 1 of 13 does per-channel *visibility*.**
Only Shopify — `MetafieldDefinition.access` = `{admin, storefront, customerAccount}`, enums reproduced
whole in §3. Four more do per-channel **values or requiredness**: Akeneo
(`pim_catalog_attribute_requirement` unique on `(channel_id, family_id, attribute_id)`), Magento
(`SCOPE_STORE=0 / SCOPE_GLOBAL=1 / SCOPE_WEBSITE=2`, values keyed by `store_id`), Amazon (a
`marketplace_id` selector on every value), Walmart (a different `@group=` vocabulary per feed type). Three
more do it at the **product** level only (Google `excludedDestinations`, Tokopedia `listing_platforms`,
Square's *"The Square Point of Sale application doesn't show custom attributes for any object type."*).

**Card pointers, all four executed.**
- **Square's 10 visible + 10 hidden** — **found, and it is single-route with an internal contradiction.**
  The Limitations list says *"**Each Square account** can have up to 10 seller-visible and 10 seller-hidden
  custom attributes."* (`corpus/square/raw-add-custom-attributes.txt:150`); the same page's body says
  *"**An application** can create up to 10 seller-visible custom attribute definitions…"* (`:243`).
  Two scopes, one page, unreconciled. The figure appears in **no** other Square artifact: 0 hits across
  `square-api.json` (3,273,134 B) for any custom-attribute definition cap, 0 in the dev blog, 0 in the
  Catalog overview, 0 in the devtools Custom Attributes overview; the API-limits URL returns a **generic**
  404 — its tag-stripped body is byte-identical to two other Square 404s (`f3cdc223…`, 830 B each) while
  the three raw `.html` bodies differ, so a Square 404 proves nothing either way.
- **Shopify metafield storefront visibility** — collected whole from the live `2026-07` schema:
  `MetafieldAccess {admin, customerAccount, storefront}`; `MetafieldStorefrontAccess` = **2 values**,
  `PUBLIC_READ` *"Read-only access."* / `NONE` *"No access."*; `MetafieldAdminAccess` = 5 output values
  (`PRIVATE`, `PUBLIC_READ`, `PUBLIC_READ_WRITE`, `MERCHANT_READ`, `MERCHANT_READ_WRITE`) but the **input**
  enum accepts only 2; `MetafieldCapabilities` = **5** (`adminFilterable`, `analyticsQueryable`,
  `cartToOrderCopyable`, `smartCollectionCondition`, `uniqueValues`). And the rule that matters most:
  *"`storefront` controls permissions for the Storefront API… **This setting doesn't affect Liquid
  templates - metafields are always accessible in Liquid regardless of this setting.**"* Limits: 256
  definitions per resource type per app **and** per merchant, 50 pinned, 128 smart-collection, 50 admin
  filter, 5 order admin filter.
- **eBay `aspectUsage`** — collected from the record and reproduced in `matrix-A0.md` §4 with the
  distribution (`OPTIONAL` 136,195 / `RECOMMENDED` 60,851 over 197,046) and **two contradictions eBay owns**:
  *"The value returned for required aspects will be `RECOMMENDED`, but they are actually required"*, and
  the two Taxonomy operations returning different `aspectUsage` for **33 of 421** aspects on the same day.
- **Magento's `is_visible_on_front` / `is_filterable` / `used_in_product_listing`** — #11082 carries all 22
  column names but **states a meaning for only four of them**. **That gap is now closed at source.** The
  merged `catalog_eav_attribute` has **24** columns (22 in `Catalog`, plus `search_weight float NOT NULL
  default 1` from `CatalogSearch` and `additional_data text` from `Swatches`), re-read from
  `magento/magento2` @ `874f1f5c` (2026-09-17) at
  `corpus/magento/magento2/app/code/Magento/Catalog/etc/db_schema.xml:1050-1106`. Defaults matter:
  **`is_global` and `is_visible` default to `1`; every other flag defaults to `0`.** And **`is_filterable`
  is not a boolean** — `LayeredNavigation/Model/Attribute/Source/FilterableOptions.php` returns three
  options whole: `0 → "No"`, `1 → "Filterable (with results)"`, `2 → "Filterable (no results)"`. Adobe's
  Admin labels map to the columns via the UI component XML (`Catalog/view/adminhtml/ui_component/
  product_attribute_add_form.xml:621-721` etc.), which is how the storefront projection's differently-named
  fields reconcile. **Two of the 24 are filter flags, two are search flags, three are grid flags, one is a
  promo-rule flag** — see §3 for Adobe's own list of what they are for.

### 3 · Why

**Full set of quoted vendor rationale for this card: `rationale.md` §A0.** The four that decide it:

- **Square, on why *hidden* attributes exist at all** — and note it is a *developer* rationale, not a
  merchandising one (`corpus/square/raw-creating-custom-attributes-in-catalog.txt`, Square dev blog
  2020-05-05): *"**Since there are strong use cases for supporting custom attributes that are not visible
  to the seller (e.g. tokens unique to an external application)**, Catalog Custom Attributes also supports
  invisible attribute definitions."* Its two axes, in Square's words
  (`raw-add-custom-attributes.txt:245-260`): *"The `app_visibility` field controls whether the custom
  attribute and its definition are readable or writable by other applications"* · *"The
  `seller_visibility` field controls whether the custom attribute definition and value appear in the UI of
  Square products, such as the Square Point of Sale application or the Square Dashboard"*.
- **Adobe publishes the A0 card's own list of uses as one flag per use** — fetched live 2026-09-19
  (`corpus/magento/adobe-attribute-product-create.txt`, "Step 4: Describe the storefront properties"):
  *"If the attribute is to be available for search, set **Use in Search** to `Yes`."* · *"To control where
  the item appears in search results, set the **Search Weight** value: 1 (lowest weight) to 10 (highest
  weight)."* · *"To include the attribute in Product Compare, set **Comparable on Storefront** to `Yes`."*
  · *"To use the attribute as a filter in layered navigation, set **Use in Layered Navigation** to
  `Yes`."* · *"To use the attribute in layered navigation on search results pages, set **Use in Search
  Results Layered Navigation** to `Yes`."* · *"For **Position**, enter a number to indicate the relative
  position of the attribute in the layered navigation block."* · *"To use the attribute in price rules,
  set **Use for Promo Rule Conditions** to `Yes`."* · *"To include the attribute on the product page, set
  **Visible on Catalog Pages on Storefront** to `Yes`."* · *"To include the attribute in product listings,
  set **Used in Product Listing** to `Yes`."* · *"To use the attribute as a sort parameter for product
  listings, set **Used for Sorting in Product Listing** to `Yes`."* **Spec sheet, listing, filters,
  search, sorting, internal rules — one flag each, on the definition.**
- **eBay states the filter use to sellers**, live 2026-09-19
  (`corpus/ebay/sellercenter-item-specifics.txt:79,137`): *"**Buyers use item specifics to filter their
  search results, and your item will only appear in those filtered search results if you've added the
  matching item specific.**"* · *"…especially when buyers use the **left-hand navigation filters**."*
  **Second, independent route that could have disagreed** — the buyer-side Browse API exposes the same
  aspects as refinements (`AspectDistribution`, `AspectValueDistribution.matchCount`, and the
  `aspect_filter` search parameter — *"This field lets you filter by item aspects."*,
  `corpus/ebay/openapi-buy_browse_v1_oas3.json` v1.20.4). **This closes #11045's open item that search
  refinement was "not answered".**
- **Shopify, on why it *shrank* its visibility model** — changelog 2024-12-10
  (`corpus/shopify/sfy-changelog-feed.xml`): *"we're simplifying how metafield and metaobject permissions
  work. **This makes the system easier to work with and will further improve API response times.**"* —
  migrating `PRIVATE → MERCHANT_READ`, `PUBLIC_READ → MERCHANT_READ`,
  `PUBLIC_READ_WRITE → MERCHANT_READ_WRITE` and removing `LEGACY_LIQUID_ONLY`. **A vendor that shipped a
  five-valued visibility enum reduced it to two writable values within three years.**

**Inference, labelled.** The platforms with the richest per-attribute flag sets (Magento 24, eBay 11,
Shopify ~8) are the ones whose **storefront or search is rendered by the platform itself**: a platform that
renders the page must be told, per attribute, whether to print it, facet it and sort by it. A platform that
only accepts a feed (Google, Walmart) states a *purpose* instead and keeps the rendering decision to
itself. **We render our own storefront**, so we are in the first group. No vendor states this.

### 4 · Our code today

**The uses, ranked by what exists today, not by what we want:**

| Use | State at the pin | Cite |
|---|---|---|
| **Spec sheet (customer PDP)** | **live** — renders every `attribute_value` minus a hard-coded deny-list of one code. Route chain, so this is not in doubt: `ts/apps/solui/src/app/app-routing.module.ts:23` → `@ts/shop/feature-shell` → `shop-feature-shell-routing.module.ts:75` → `@ts/product/feature-shell` → `ProductDetailPageComponent` → `product-detail-ui.component.html:17,34` → `<ts-product-addendum-attributes>` | `ts/libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.ts:34,47-50` |
| **Internal rules** | **live, and they read columns** — age wall reads `main_category_id` (`models.py:571-573`); replenishment reads the category tree (`inventory_replenishment_service.py:31-36`) and `ProductMeta.quantity_per_box` (`:114`); purchasing reads `ProductMeta.quantity_purchasing_allowed_multiples` (`purchasing_quantity_service.py:39,158`); shipping reads the four dimension attributes (`biteship.py:60-62,90`; `basket/models.py:1265-1274`) | — |
| **Variant picker** | **does not exist** — no variant model, no picker component | — |
| **Google feed** | **sends zero attributes** — 8 fields, none of them an attribute value, no `item_group_id`, no `variant_option` | `products_api.py:214-241` |
| **Search filters** | **do not exist** — `ProductIndex` indexes no attribute; facets are `category` and `price`; the frontend has **0** files matching `facet` | `search/search_indexes.py:59-69` |

**Where visibility lives today: a hard-coded array in the frontend.**
`hiddenAttributes = ['internalname']` (`product-addendum-attributes-ui.component.ts:34`) — and
**`internalname` no longer exists as a `ProductAttribute`** (`sql/results/attribute-definitions.csv` shows
ids 2–6 only). **Our one visibility mechanism currently hides nothing.** Display order is a second
hard-coded array containing the same dead code
(`product-attribute-ordering.service.ts:9-15`).

**The stable-code requirement the card names is already load-bearing and already unprotected.**
`ProductAttribute.code` is simultaneously (i) the Python attribute name in `attr.<code>`
(`product_attributes.py:21-25`), (ii) the i18n key `product.attribute.key.<code>`
(`product-attribute-i18n.service.ts:25`), and (iii) the Formly field name `_attribute_<code>`
(`product-update-staff-form-ui.component.ts:63,186-201`). It has **no unique constraint**
(`models.py:613-616`) and Django admin offers it with `prepopulated_fields = {"code": ("name",)}`
(`admin.py:53`). **Renaming a code in admin silently breaks the label lookup and every `attr.<code>`
reader.**

**What already gates the definition surface, staff-vs-customer, on both stacks:** the viewset declares
`permissions_required = ["catalogue.view_productattribute"]` (`staff_views.py:64`) and the frontend carries
the same string in its permission union
(`ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43`). **Our existing staff-only mechanism
for attribute *definitions* is a Django model permission mirrored in TypeScript** — the honest starting
point for A0's "are some staff-only?", and the thing a schema editor must extend.

**No definition editor exists in the staff app** — `ProductAttributeViewSet` is a `GenericViewSet` with
only a cached `all` GET action (`staff_views.py:57-75`, `py/mono/solvent/api/shared/views/api_mixins.py:11-22`). The only write surface is
Django admin. *(Correction to lock condition 1's wording: a UI does exist — Django admin
`catalogue/admin.py:51-54,67` — it is simply not the staff app.)*

### 5 · Our numbers

`sql/attribute-uses-and-visibility.sql`, snapshot 2026-09-19.

| Measure | As-measured | Post-condition-2 |
|---|---|---|
| spec-sheet lines rendered, all products | **471,143** | **46,499** |
| …on public products | 470,848 | 46,440 |
| …hidden by the deny-list | **0** | 0 |
| products with an empty spec sheet | 0 | **59,662** |
| active-online products with an empty spec sheet | 0 | **0** |
| active-online products whose only line is junk | — | **2,843** |
| dimension lines that leave the spec sheet | 424,644 (of which **290,774 are `0`**) | — |
| products showing `Manufacturer: 0` on a public page | **12,512** | 12,512 |

**Read that table once more.** Today the customer spec sheet is 90% shipping dimensions and most of those
print zero. After condition 2 it becomes a single "Manufacturer" line, absent on 56% of products and junk
on 12% of the online catalogue. **The spec-sheet use is not a future feature to design; it is a live
surface that is currently wrong, and condition 2 changes what is wrong about it rather than fixing it.**

### 6 · Cleanest / structurally correct for us

Option 1 is near-unanimous (10/13), so the design pass is a **fit-check**, per BRIEF.md §3.5.

- **It fits our definition object with no new table.** `ProductAttribute` already carries `type` and
  `required`; adding boolean flags beside them is a migration of columns, not of shape. The API already
  serves the definition list to the staff app (`staff_views.py:57-75`), so flags reach the frontend through
  an existing endpoint.
- **It replaces one frontend array, one backend `sorted()` and one i18n key-set with data** — and all
  three are *already wrong*, each still naming `internalname`, a definition that no longer exists.
  `is_customer_visible` replaces the spec-sheet deny-list
  (`product-addendum-attributes-ui.component.ts:34`). `display_order` replaces **two** things, not one:
  the staff-form priority array (`product-attribute-ordering.service.ts:9-15`, applied at
  `product-attributes-stream.service.ts:33`) **and** the backend alphabetical sort that orders the customer
  spec sheet (`serializers.py:219-221`). `name`/`unit` on the definition replace the six hard-coded i18n
  keys. **That is three changes on two stacks, not one** — the first draft priced one.
- **It does not fit the feed or filters yet**, because those consumers do not exist: the feed reads no
  attribute and the index carries none. Flags for them are declarations of intent, not wiring — **and the
  wiring is more than a flag**: neither surface can see an attribute value at all until
  `ProductAttributeValue` gets a `post_save` receiver and `Product.save()` stops enqueueing
  (`models.py:489`) before it writes (`models.py:490`). See §4.
- **The one thing option 1 cannot do on its own** is stop the spec sheet from rendering junk: a flag says
  "show this attribute", not "this value is meaningful". That is A4's (value governance) and a data
  clean-up, not A0's.
- **Option 3 (per channel) does not fit yet and should not be built.** We have three channels in the code
  (`is_offline_only` splits till from online; the feed is the third), but they are **product-level** gates
  today (`models.py:501-515`, `managers.py:19-26`) — exactly where Google, Tokopedia and Square put theirs.
  Adding per-channel *attribute* visibility would be the only instance in the thirteen outside Shopify.

### 7 · Recommendation

**Judgement — the uses, ranked.**
1. **Spec sheet** — the only use with data and a live surface, and it is currently broken.
2. **Internal rules** — already the heaviest consumer, and they read **columns**; keep it that way (A1's
   rule) rather than teaching rules to read the attribute bag.
3. **Variant picker** — required by Lock 2, and it is the use that forces A4 to give values an order.
4. **Google feed** — greenfield; sends nothing today. ~~so anything added is pure gain and costs one
   method~~ **Re-priced: one method *plus* the fan-out fix.** `products_api.py:188-241` is one method, but
   the push is enqueued by `Product`'s `post_save` (`receivers.py:31-41` → `index_utils.py:11-16`), there
   is **no receiver on `ProductAttributeValue`**, and `Product.save()` enqueues at `models.py:489` *before*
   `attr.save()` writes at `:490`. Sending any attribute to Google costs the method **and** a new receiver
   **and** a save-ordering change — the same three for search filters.
5. **Search filters** — last, because they cannot be built before A4 gives values rows, and the index
   carries no attribute field at all today.

**Judgement — visibility is a property of the definition (option 1), expressed as purpose flags, not one
boolean.** Minimum set, matching what our consumers actually need and what 10 of 13 platforms carry:
`is_customer_visible` (the spec sheet), `is_filterable` (reserved for A4's filters), and `display_order`
— which replaces **both** orderings: the staff-form priority array
(`product-attribute-ordering.service.ts:9-15` applied at `product-attributes-stream.service.ts:33`) and the
backend alphabetical `sorted(…, key=attribute.code)` that orders the customer spec sheet
(`serializers.py:219-221`); it also gives the picker an order it has no source for today. **Do not build per-category
visibility** — on the evidence it is membership, which is A3's. **Do not build per-channel visibility now**
— 1 of 13 has it, our channels are product-level gates, and Shopify's own history is a five-valued enum
reduced to two writable values in three years.

**Also recommended, because the card names it and our code fails it:** give `code` a `UNIQUE` constraint
and make it non-editable once values exist. It is the stable key three subsystems depend on and it is
currently auto-generated from a free-text `name` in Django admin.

**Confidence: high** on "on the definition" (10 of 13 — with the hedges on five of those ten named in §2 —
plus three hard-coded orderings/deny-lists across both stacks that a flag and an integer delete). **Medium** on the exact flag set — it is a judgement about our five consumers, not a reading of
the platforms.

**What would reopen it.** (i) A till/POS product page that must show a different attribute set from the web
— then per-channel becomes real and Shopify's `access` triple is the cheapest precedent, not a per-channel
table. (ii) A decision to send `product_detail` rows to Google — then the feed needs a per-attribute
"export" flag, and Walmart's per-feed-type vocabulary is the precedent for keeping that separate from
customer visibility.

**The A0↔A5 coupling (owned here; FAMILY cites this).** Two platforms carry both a **level** field and a
**visibility/searchability** field, and they carry them as **independent fields of the same definition
row**: commercetools (`AttributeDefinition.level : Product|Variant`, *"immutable in the UI"*, beside
`isSearchable`) and Shopify (`MetafieldDefinition.ownerType`, 26 values including both `PRODUCT` and
`PRODUCTVARIANT`, beside `access` and `capabilities`). **No record in the thirteen derives one from the
other.** So: the level a fact lives at is A5's question, the channels it is shown on is A0's, and a design
that makes visibility depend on level — "family-level attributes are shown, member-level ones are not" —
has **no precedent in the thirteen**.

**What it forces in steps 1–5.** **Condition 1 (the schema editor) gains a definite field list**: code
(immutable, unique), name, type, required, `is_axis_eligible` (from A2), `is_customer_visible`,
`is_filterable`, `display_order`, `unit` — plus `storage` and `source_field` if option 4 is taken
(§A1.7). It also gains a definite **permission** list: today only `catalogue.view_productattribute` exists,
on both stacks (`staff_views.py:64`; `ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43`),
so the editor must add `add_`/`change_`/`delete_productattribute` to the Django model permissions **and**
to the frontend permission union. **D17** (where requiredness lives, and is it one-valued?)
inherits two facts from this card: `required` is a boolean on the definition in the three platforms that
state it plainly (commercetools `isRequired`, Shopee `mandatory`, Salesforce `mandatory-flag`), and
**Akeneo is the counter-case that matters for us** — it keys requiredness on `(channel, family,
attribute)`, which is the shape we would need the day the feed and the web disagree. **D9/D8** are
ATTR-VALUE's and are not touched here beyond stating the use (filters want shared value rows).

### 8 · Limits and corrections

**Corrections after red-team round 1:**

- **1 (BLOCKING) — fixed.** The hard-coded TS ordering array **does not order the customer spec sheet**.
  Re-priced against the two real mechanisms: the **staff form** is ordered by
  `product-attribute-ordering.service.ts:9-15` applied at `product-attributes-stream.service.ts:33`; the
  **customer spec sheet** is ordered on the backend by `sorted(…, key=attribute.code)` at
  `serializers.py:219-221`. §A1.4 now carries both as a table, §6 says "one frontend array **and** one
  backend `sorted()` **and** the i18n key-set", and §7's `display_order` is sold on replacing **two**
  orderings on **two stacks**, not one array.
- **6 — fixed.** `matrix-A0.md`'s V2 tally published row 2 as **4** while naming **five** platforms, and
  the counting note that tried to absorb it was a non-sequitur. Row 2 is now **5**; 8 + 5 = 13; the note is
  replaced by an explicit statement that the earlier number was an arithmetic error.
- **7 — fixed, then corrected again in round 2.** §2 now carries the **named ambiguous list** inline, as
  A1 and A2 do. ⚠️ This entry originally said *"five of the ten … plus Walmart"*, which is **six**, and the
  §2 text it describes asserted "5 + 5"; **round-2 finding 1 corrected both** — see the round-2 list below.
  The list itself (Square, Magento, Akeneo, WooCommerce, commercetools, Walmart) was right throughout.
- **8 — fixed.** The feed is no longer priced at "one method": `products_api.py:188-241` **plus** a new
  receiver on `ProductAttributeValue` **plus** the `Product.save()` re-ordering. Same three for filters.
  §6's "flags are declarations of intent, not wiring" now names the wiring.
- **9 — fixed.** §4 records what already gates the definition surface —
  `permissions_required = ["catalogue.view_productattribute"]` (`staff_views.py:64`) mirrored at
  `ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43` — and §7 adds the
  `add_`/`change_`/`delete_productattribute` strings condition 1 must create on both stacks.
- **16 — fixed.** `apps/solui/…` → `ts/apps/solui/src/app/app-routing.module.ts:23`.
- **18 — fixed.** `getFormlyFieldConfigs` (not a symbol in `ts-layer2`) → `getProductAttributeFields$`.


- **Square's cap is OPEN, not verified.** Single route, plus an internal contradiction about its scope
  (account vs application), plus a live rejection quoted in #11049 naming `app_id` — three statements, two
  scopes. Route that would settle it: an 11th seller-visible `CUSTOM_ATTRIBUTE_DEFINITION` against a Square
  sandbox, which needs a token we do not have. **#11068 credential-gated items were not re-attempted.**
- **CLOSED since #11082 was written:** the flag meanings and a real instance. Adobe's storefront-properties
  page supplies the meanings (quoted in §3) and
  `corpus/magento/magento2/dev/tests/integration/testsuite/Magento/Catalog/_files/dropdown_attribute.php`
  supplies a vendor-published instance carrying 12 of the flags at once. **Two items remain open**: 8 of
  the 24 columns are named by no Adobe page (`is_required_in_admin_store`, the three `*_in_grid`,
  `additional_data`, `frontend_input_renderer`, `is_visible`, `is_used_for_price_rules`), and
  `is_used_for_price_rules` is written by **no** `PropertyMapper` at all — it exists in the schema and
  nothing populates it. Route that would settle it: a post-install database dump.
- **A contradiction inside Magento's own artifacts, recorded unresolved:** `price` is declared
  `SCOPE_WEBSITE` at `CategorySetup.php:456` and set to `SCOPE_GLOBAL` by the data patch
  `Catalog/Setup/Patch/Data/ChangePriceAttributeDefaultScope.php:59-73`. Not picked.
- **Shopify's numeric metafield limits (256 / 50 / 128 / 5) are single-route** — one doc page. The live
  schema publishes only the error codes (`LIMIT_EXCEEDED`, `PINNED_LIMIT_REACHED`,
  `RESOURCE_TYPE_LIMIT_EXCEEDED_BY_APP`, …), not the numbers.
- **`LEGACY_LIQUID` as named in the card pointer does not exist** in Admin API `2026-07` (0 hits in
  6,600,955 B). Shopify's changelog names the removed value `LEGACY_LIQUID_ONLY` and dates its removal to
  the 2025-01 version.
- **Not collected:** what WooCommerce's `is_visible` actually does, and what an attribute archive is —
  #11080 carries both fields and states no meaning for either. Route: the WooCommerce template that renders
  the Additional Information table.
- **Route-independence caveats carried from the collections.** **Square**: the OpenAPI spec and its
  rendered reference page are **not independent** — the page renders the spec word for word; Square facts
  rest on spec + hand-written guide prose + vendor sample payloads. **Shopify**: the live introspection and
  the `.md` reference are one origin; the independent routes are the hand-written guides, the changelog
  feed and an archived `help.shopify.com` capture. **eBay**: the OpenAPI contract and the rendered type
  pages match character-for-character after tag-stripping, so they are one origin too — `AspectConstraint`
  is the one object that escapes it, via the hand-written POJO in `eBay/taxonomy-sdk`. **Magento**: the
  declarative schema and the `PropertyMapper` PHP *are* independent and **did** diverge
  (`is_used_for_price_rules` is in the schema and in no mapper), and Adobe's docs team is a third.
- **Completeness caveat:** eBay's OpenAPI declares `aspectDataType`, `aspectUsage`, `aspectMode` and
  `aspectApplicableTo` as bare `string` with **no `enum` array**, so the value sets above come from the
  rendered enum pages. Only `ItemToAspectCardinalityEnum` is closed on two routes (the SDK's Java enum).
  Treat the others as observed sets, not proven-closed ones — which is eBay's own advice elsewhere:
  *"Code so that your app gracefully handles any future changes to this list."*

---


**Corrections after red-team round 2:**

- **1 — fixed.** §2's named-hedge list said *"five of the ten"* twice while naming **six**, then asserted
  *"5 unhedged + 5 qualified"* — the same arithmetic failure as round-1 finding 6, reintroduced by the fix
  for round-1 finding 7. Restated as **4 unhedged (Amazon, Shopify, eBay, Shopee) + 5 carrying an
  evidence-quality hedge (Square, Magento, Akeneo, WooCommerce, commercetools) + 1 reclassified (Walmart,
  a *purpose* tier rather than a visibility flag) = 10**, struck text left visible. `matrix-A0.md` was
  already correct — it names the six and claims no number.
- **5 — fixed** (listed under A1): the Square 404 sentence sits in this card's §2 card-pointer bullet.

## Corpus fetched for this brief

Collected 2026-09-19 to the external-research standard, left in place under
`~/copilot/research/catalogue-step0-2026-09/corpus/`. `corpus/shopify-taxonomy/` (the coordinator's) was
not read or modified by this brief.

| Directory | Headline artifacts | Size |
|---|---|---|
| `corpus/square/` | `square-api.json` (Connect OpenAPI, 3,273,134 B) + 13 rendered doc pages + the 2020-05-05 dev blog + three **generic 404** captures kept as block evidence — the three `.html` bodies differ (md5
`88b507dd…`/90,932 B, `419a8951…`/91,022 B, `6e3d8ee6…`/90,956 B) while the three tag-stripped `.404.txt`
extracts are byte-identical (`f3cdc223…`, 830 B each), which is what shows a Square 404 is generic and
proves nothing | ~12 MB |
| `corpus/shopify/` | live Admin GraphQL `2026-07` introspection (6,600,955 B), `2025-10` `ProductVariant`, `sfy-changelog-feed.xml` (1,729,431 B, 784 items, 2024-09-20 → 2026-09-18), 30 doc/reference pages, an archived `help.shopify.com` capture (the live page 403s behind Cloudflare in curl **and** in a real browser) | ~11 MB |
| `corpus/ebay/` | three OpenAPI contracts — Commerce Taxonomy v1.1.1 (88,972 B), Sell Inventory 1.18.4 (793,331 B), Buy Browse v1.20.4 (383,158 B) — 11 type pages, two vendor sample responses, the Seller Center item-specifics page (live, 200), and the `eBay/taxonomy-sdk` repo @ `7d6bc84` | ~9 MB |
| `corpus/magento/` | sparse clone of `magento/magento2` @ `874f1f5cdf3bc52b61c3d66becf159cc16345d7a`, branch `2.4-develop`, commit date 2026-09-17, modules `Catalog`/`Eav`/`CatalogSearch`/`ConfigurableProduct`/`Swatches`/`LayeredNavigation` + the Catalog integration fixtures; plus three live Adobe Experience League pages | 56 MB |
| `corpus/woocommerce/` | `class-wc-brands.php` (the `product_brand` taxonomy registration), `class-wc-post-types.php`, `Internal-Brands.php` (*"As of WooCommerce 9.6, Brands is enabled for all users."*), `class-wc-rest-product-brands-controller.php`, `ProductBrandSchema.php`, `store-api-product-brands.md` (the published brand instance), `doc-woocommerce-brands.txt` (the *"Each brand can have its own name, description, image, and archive page"* quote), `readme-9.4.0.txt`, and the two dev-blog posts (2024-10-01, 2025-01-17) | 6.9 MB |
| `corpus/shopee/` | `get_brand_list`, `register_brand`, `add_item`, `get_item_base_info` reference pages | 132 KB |
| `corpus/akeneo/` | `brand-reference-entities`, `brand-catalog-structure`, `brand-products-concept`, the two Serenity help articles, and a `pim-community-dev` clone @ `77d98c30` (2026-08-28) whose `icecat_demo_dev` fixtures carry `brand` as a `pim_catalog_simpleselect` attribute | 270 MB |
| `corpus/commercetools/` | a `commercetools-api-reference` clone @ `76af649b` (2026-09-18) — `oas/api/openapi.yaml` 3,103,801 B, `graphql/schema.sdl` 538,456 B, `api-specs/` 5,405 files — plus 10 rendered docs pages | 114 MB |
| `corpus/amazon/`, `corpus/google/` | the SP-API models clone @ `3659f968` (67 JSONs, 8,329,281 B) + 8 developer-docs pages; the 15 Merchant API discovery documents (1,045,733 B), `products_common.proto`, and the `brand` spec page fetched with a real browser | 13 MB / 1.4 MB |
| `corpus/shopify-vendor-field/`, `corpus/{shopify,square,magento}-rationale/` | `Product.vendor` from the Admin doc page **and** a live `mock.shop` Storefront introspection + query; the vendor rationale pages quoted in `rationale.md` | ~130 KB |
| `corpus/gs1/` | `GS1_GTIN_Management_Standard.pdf` (381,277 B) + `GS1_General_Specifications.pdf` (12,175,796 B), both served unauthenticated by `ref.gs1.org` after `www.gs1.org` returned 403. **Collected for FAMILY's C1/C2, not used by this brief** — §2.1's new-product rule and its seven worked scenarios (including the flavour and the size-per-jeans cases) are at lines 520-521 of the text extract | 21 MB |

⚠️ `corpus/walmart/`, `corpus/bpom/`, `corpus/meta/`, `corpus/shopify-values/`, `corpus/why-2026-09/` and
the coordinator's `corpus/shopify-taxonomy/` were written during this run by **other briefs' collections**
and are not cited here. Within the directories this brief does cite, a few files predate its collections
(noted per directory by the collectors); nothing above rests on a file this brief did not fetch itself.

**Blocks recorded rather than inferred through.** `developer.ebay.com` returns **HTTP 403** to this client
on every path (six named attempts, including a real browser), so every eBay doc artifact above is a
**Wayback `id_` raw capture of the vendor origin** with its origin URL and capture timestamp recorded, plus
the vendor's own GitHub repo. `www.ebay.com/b/…` also 403s and `…/help/…item-specifics` redirects to a
captcha, so **eBay's buyer-side filter UI was never observed directly** — the filter finding rests on the
Seller Center page (live, 200) and the Browse API contract instead. `help.shopify.com` 403s behind
Cloudflare; the category-metafields quote is from a 2026-02-28 archive capture. **No credential-gated item
(#11068) was re-attempted.**

**A note on this brief's length.** BRIEF.md §4 asks for ~8–10K characters per card; this one runs roughly **33K
per card** (85,156 B at round 1, ~110,000 B after two red-team fix rounds added the corrections blocks). Everything that could move has moved — the full vendor-rationale sets to `rationale.md`, the
thirteen-row evidence to the three `matrix-*.md`, the design work to the two `design-*.md`, the queries and
results to `sql/`. What remains inline is the tally, the code inventory, the numbers and the judgement, and
the instruction that outranks the length target is *"Nothing of substance is dropped for length"* and
*"dont half ass anything"*. Flagged rather than trimmed silently.

