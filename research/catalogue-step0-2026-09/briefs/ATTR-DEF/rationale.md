# rationale.md — every vendor-stated rationale collected for ATTR-DEF, whole

Companion to `ATTR-DEF.md` §3 of each card. **Only quoted vendor statements appear here**; every
inference is labelled as such and carries the constraint it rests on. The brief's §3 keeps the two or
three most decisive of each set inline and links here for the rest.


---

## A1


**Stated vendor rationale, quoted:**

- **Square, on why custom attributes exist beside built-in fields** (`corpus/square/raw-add-custom-attributes.txt:136-140`):
  *"…The application needs additional information for each menu item: An application-specific menu item
  name… An application-specific price. Allergen information. **Because catalog items don't have properties
  for this information**, the seller can have custom attributes added to a CatalogItem object in their
  catalog to capture the additional details."* Second route, Square's own dev blog, 2020-05-05
  (`raw-creating-custom-attributes-in-catalog.txt`): *"it's common for integrations to require use-case
  specific or custom attributes that are not covered by Catalog API's standard attributes (item name, SKU,
  price etc.)."*
- **Shopify, same question** (`corpus/shopify/sfy-docs_apps_build_custom-data.md:13`): *"**Most apps need
  to store data that Shopify's standard data model doesn't include**, such as a fabric composition on a
  product, a warranty record, or a record type that only your app uses."* — and on definitions
  (`:35`): *"**A defined metafield gets a typed editor in the admin, validation on write, and support for
  search and filtering. An undefined metafield is stored as a plain string that merchants can't search or
  validate.**"* That is the clearest published statement of *why the definition is a separate object*.
- **Walmart, on why the type owns the attribute set** (#11046 §1.2): *"Based on the product type selected,
  the seller will complete the relevant attributes as identified in the feed file schema provided. Based on
  the chosen Product Type, attribute requirements, values, and recommendations will vary."*
- **commercetools, on why types constrain attributes** (#11081 §3): *"**You wouldn't ask for the
  `Neckline` of a pair of jeans, would you?** By defining appropriate Attribute types for each Product
  Type, you prevent irrelevant or nonsensical data from being entered, maintaining data integrity and
  simplifying product management."*
- **Adobe, on what the attribute set is for** (#11082 §1.2): *"**The attribute set determines the fields
  that are available during data entry, and the values that appear to the customer.**"*
- **Akeneo, on what attributes are for** (#11069 §1.1): *"**The family helps managing the product's
  completeness** as you can say at the family level, which family attributes are required for the
  completeness calculation."* — Akeneo's headline purpose is completeness, not display.
- **Magento, on why everything is an attribute** — `Magento_Eav/README.md`, **the whole file**
  (`corpus/magento/magento2/app/code/Magento/Eav/README.md`, 128 B): *"EAV stands for
  Entity-Attribute-Value. **This module makes entities configurable/extendable by admin user.**"* And
  Adobe states the price of that choice
  (`corpus/magento/adobe-catalog-management.txt`, fetched live 2026-09-19): *"Configuring many product
  attributes increases the product template size for each product (EAV structure) and the amount of data
  that must be retrieved."* → *"Increase in SQL queries traffic related to EAV data retrieval… Significant
  increase in the size of Adobe Commerce indexes and the full-text search index… Reaching hard MySQL limits
  when building a FLAT index for oversized product templates… Increased response time for most storefront
  scenarios related to catalog browsing, search (quick and advanced), and layered navigation."*
  **That is the vendor of the purest option-2 catalogue publishing option 2's running cost.**
- **Tokopedia, on the attribute/axis split** (#11048 Companion C §2): *"**Attributes are supplementary
  content of product information.** Attributes are associated with categories… **Product attributes** are
  general attributes such as manufacturer, country of origin, materials used) **Sales attributes** are
  attributes that are specific to the variant (aka SKU) of a product such as size, color, length."*

**Inference, labelled — why the three option-2 platforms are option 2.** Akeneo is a **PIM**: its product
has no storefront, no checkout and no shipping engine, so no code path needs a typed column and every fact
can be a value in a bag. Magento is a **2008-era EAV monolith** whose static columns are the ones the ORM
needs to find a row at all; its 22-column `catalog_eav_attribute` overlay exists precisely to give the bag
back the per-use flags a column would have had for free. Amazon's write path is a **submission against a
per-product-type JSON Schema**, so "everything is a property" is a statement about the wire format, and its
read model keeps scalars anyway. **None of the three is a merchant storefront with one tenant, one
category tree and a shipping integration — which is what we are.** No vendor states this.

**Inference, labelled — why Square caps at ten.** Square's built-in set is large (27 item properties + 23
variation properties) and its custom attributes are an **app-integration** device rather than a
merchandising one: the blog's own framing is *"tokens unique to an external application"*. A cap is cheap
when the extension is not the product model.


---

## A2


- **Salesforce is the only platform that documents a migration between the two, and it ran 1 → 2**
  (#11050 §1.8, the vendor's own note): *"The latter are historical leftovers from when object attributes
  were used directly as the basis for variation, and **the value lists were stored directly on the
  ObjectAttributeDefinition**. Every ProductVariationAttribute corresponds with exactly one
  ObjectAttributeDefinition, but **values are now stored on the ProductVariationAttribute and not the
  ObjectAttributeDefinition**."* **Read it precisely: the *definition* stayed shared and 1:1; only the
  *value list* moved off it.** That is an argument about where an axis's allowed values live — A4's and
  A3's question — not about whether an axis is an attribute.
- **Shopify built a bridge back from 2 to 1 and marks it unfinished**: `linkedMetafield` —
  *"This API is currently in early access."* — and the 2025-01-01 changelog says why it was widened:
  *"Up until now, merchants had the ability to link their options to category metafields, allowing them to
  use these option values across similar products. **This release expands that functionality to include any
  metaobject reference list.**"* (`corpus/shopify/sfy-changelog-feed.xml`). Shopify's own guide states the
  motive: *"Instead of simple text values like "Red" or "Large", your options reference metaobjects that
  contain structured data, **enabling features like improved search and marketplace integration**."*
- **eBay states why not every attribute may be an axis** (#11045 §2): *"**Not all aspects are allowed as a
  pivoting aspect.** … To see which aspects are allowed as pivoting aspects, you can use the
  `getItemAspectsForCategory` method and look for a value of `true` in the `aspectEnabledForVariations`
  field."* — i.e. the eligibility flag exists because the axis-worthy subset is smaller than the attribute
  set. That is option 1's own justification, from a platform filed ambiguous.
- **Akeneo makes the two roles structurally inseparable** (#11069 §1.3): `setAttributes()` re-adds every
  axis to the same set's `attributes`, so an axis is *always* also an attribute.
- **Inference, labelled:** the four clean option-2 platforms (Shopify, Shopee, Square, Salesforce) are all
  **merchant/seller tools with a buyer-facing picker as a first-class UI**, and all four needed an ordered,
  swatchable, shareable value row (`ProductOptionValue.swatch`, `CatalogItemOptionValue.color`/`ordinal`,
  `variation_option_id` + `image_id`). The five option-1 platforms either have no picker to render
  (Akeneo), render it from a flat feed (Amazon, Walmart), or build it from an EAV option row that already
  has `sort_order` and a per-store label (Magento, WooCommerce). **The split is not about axes. It is about
  whether the platform's ordinary attribute values were already rows with a position.** No vendor states
  this.


---

## A0


- **Square, on why hidden attributes exist at all** — the clearest statement in the set, and it is a
  *developer* rationale, not a merchandising one (`corpus/square/raw-creating-custom-attributes-in-catalog.txt`,
  Square dev blog 2020-05-05): *"**Since there are strong use cases for supporting custom attributes that
  are not visible to the seller (e.g. tokens unique to an external application)**, Catalog Custom
  Attributes also supports invisible attribute definitions. This allows developers to store seller-invisible
  values within Square Catalog."*
- **Square, on what the two axes control** (`raw-add-custom-attributes.txt:245-260`): *"The `app_visibility`
  field controls whether the custom attribute and its definition are readable or writable by other
  applications"* · *"The `seller_visibility` field controls whether the custom attribute definition and
  value appear in the UI of Square products, such as the Square Point of Sale application or the Square
  Dashboard"*. Enum descriptions, whole, from the spec: `SELLER_VISIBILITY_HIDDEN` — *"Sellers cannot read
  this custom attribute in Square client applications or Square APIs."*; `SELLER_VISIBILITY_READ_WRITE_VALUES`
  — *"Sellers can read and write this custom attribute value in catalog objects, but cannot edit the custom
  attribute definition."*; `APP_VISIBILITY_HIDDEN` / `_READ_ONLY` / `_READ_WRITE_VALUES` likewise.
- **Shopify, on why the access model was simplified** — changelog 2024-12-10, whole in
  `corpus/shopify/sfy-changelog-feed.xml`: *"we're simplifying how metafield and metaobject permissions
  work. **This makes the system easier to work with and will further improve API response times.**"* — and
  the migration it forced: `PRIVATE → MERCHANT_READ`, `PUBLIC_READ → MERCHANT_READ`,
  `PUBLIC_READ_WRITE → MERCHANT_READ_WRITE`, with `LEGACY_LIQUID_ONLY` removed. **A vendor that shipped a
  five-valued visibility enum reduced it to two writable values within three years.**
- **Shopify, on what the filter capability is for** (`sfy-use-metafield-capabilities.md`): the
  `adminFilterable` capability is documented as eligibility-then-enable, with an eligibility table naming
  Products, Companies, Company Locations, Metaobjects and Orders — *"\*Does not support numeric and date
  searches at this time."*
- **Walmart states the purposes directly**, as a tier on every slot: *"Required to sell on Walmart
  website"* · *"Required for the item to be visible on Walmart website"* · *"Recommended to improve search
  and browse on Walmart website"* · *"Recommended to create a variant experience on Walmart website"*
  (#11046 §1.3). **That is the card's own list of uses, published by a platform as a per-attribute field.**
- **eBay, on why a per-aspect usage tier exists at all** (#11045 §1.1): *"Each category has a different set
  of aspects and different requirements for aspect values. Sellers are required or encouraged to provide
  one or more acceptable values for each aspect when offering an item in that category on eBay."*
- **eBay, on what attributes are FOR — the filter use, stated by the vendor to sellers** and fetched live
  2026-09-19 from `www.ebay.com/sellercenter/listings/item-specifics`
  (`corpus/ebay/sellercenter-item-specifics.txt:79,137`): *"Together with product identifiers, item
  specifics are the most important way to help buyers find what they're looking for. **Buyers use item
  specifics to filter their search results, and your item will only appear in those filtered search results
  if you've added the matching item specific.** The more item specifics you complete, the better eBay can
  match your item to what a buyer is looking for."* · *"As you list, you'll see guidance on what item
  specifics your buyers are searching for, based on the number of searches over the past 30 days.
  Completing these item specifics will help increase your listing's visibility, **especially when buyers
  use the left-hand navigation filters.**"* **Second, independent route that could have disagreed** — the
  buyer-side Browse API exposes the same aspects as refinements: `AspectDistribution` —
  *"The type that define the fields for the aspect information."*; `AspectValueDistribution.matchCount` —
  *"The number of items with this aspect."*; and the search parameter `aspect_filter` —
  *"This field lets you filter by item aspects."* (`corpus/ebay/openapi-buy_browse_v1_oas3.json`, v1.20.4).
  **This closes #11045's open item that search refinement was "not answered".**
- **Adobe, on what each flag is for — the vendor's own list of uses, fetched live 2026-09-19**
  (`corpus/magento/adobe-attribute-product-create.txt`, "Step 4: Describe the storefront properties"):
  *"If the attribute is to be available for search, set **Use in Search** to `Yes`."* · *"To control where
  the item appears in search results, set the **Search Weight** value: 1 (lowest weight) to 10 (highest
  weight)."* · *"To include the attribute in Product Compare, set **Comparable on Storefront** to `Yes`."*
  · *"To use the attribute as a filter in layered navigation, set **Use in Layered Navigation** to
  `Yes`."* · *"To use the attribute in layered navigation on search results pages, set **Use in Search
  Results Layered Navigation** to `Yes`."* · *"For **Position**, enter a number to indicate the relative
  position of the attribute in the layered navigation block."* · *"To use the attribute in price rules, set
  **Use for Promo Rule Conditions** to `Yes`."* · *"To include the attribute on the product page, set
  **Visible on Catalog Pages on Storefront** to `Yes`."* · *"To include the attribute in product listings,
  set **Used in Product Listing** to `Yes`."* · *"To use the attribute as a sort parameter for product
  listings, set **Used for Sorting in Product Listing** to `Yes`."* **That is the A0 card's own list of
  uses — spec sheet, listing, filters, search, sorting, internal rules — published as one flag per use on
  the definition.**
- **Inference, labelled:** the platforms with the richest per-attribute flag sets (Magento 24, eBay 11,
  Shopify 8-ish) are the ones whose **storefront or search is rendered by the platform itself**. A platform
  that renders the page must be told, per attribute, whether to print it, facet it, and sort by it. A
  platform that only accepts a feed (Google, Walmart) states a *purpose* instead and keeps the rendering
  decision to itself. **We render our own storefront**, so we are in the first group. No vendor states this.

---

## Added 2026-09-19 — the brand-and-rationale collection

### The brand-entity promotion trigger, from three vendors

**Akeneo**, `corpus/akeneo/brand-help-104-serenity-what-is-a-reference-entity.txt:96-97`
(help.akeneo.com, no publication date on page):
> "Some information are shared between different products (such as care instructions, or colors or even brands). This data can be complex to manage because it has its own attributes (e.g. a label, a logo, a description or photos). Those information may have dedicated pages on one's e-commerce website (e.g. a webpage describing a brand) or their information may be used to enrich product pages (e.g. the logo of a brand)."
> "For example, you can create a reference entity to manage your brands, designers, manufacturers, product collections or ranges, artists, cities, countries, colors, sizes, materials, care instructions, technologies, ingredients..."
> "Let's take an example with a reference entity called Brand and a list of brands (Kartell, Alessi, Fatboy, Fermob...). A brand is described by the following information: a code / a label / an image / a description / a photo / a country"
> "For the Brand reference entity, a record contains all the information regarding a brand like Kartell or Fermob. A record may be related to one or several products."

**Akeneo**, `corpus/akeneo/brand-reference-entities.txt:290` (api.akeneo.com/concepts/reference-entities.html):
> "Available in the PIM versions: 3.x 4.0 5.0 6.0 7.0 SaaS | Available in the PIM editions: EE  Reference entities are objects that are related to products but have their own attributes and lifecycle. A reference entity can be for example the brands, the ranges, the manufacturers, the colors, the materials or the care instructions... And so many other entities."

**WooCommerce**, `corpus/woocommerce/doc-woocommerce-brands.txt` (woocommerce.com/document/woocommerce-brands/):
> "Product brands give you a dedicated way to organize products by manufacturer, label, or maker. Each brand can have its own name, description, image, and archive page."

**WooCommerce**, `corpus/woocommerce/dev-blog-introducing-brands.txt`, post date **2024-10-01T17:37:56Z**:
> "The popular Brands functionality, previously available only as a premium plugin, will now be integrated into WooCommerce core. This change allows us to provide an essential ecommerce feature out-of-the-box and opens up new possibilities for developers and store owners alike. Starting with WooCommerce 9.4, to be released October 21, 2024, all functionality previously offered by the WooCommerce Brands plugin will now be part of WooCommerce core, and available to use for free."
> "Brands are implemented as a custom taxonomy, similar to product categories. This allows for seamless integration with existing WooCommerce hooks and filters. Developers can extend and customize Brand functionality using familiar WordPress taxonomy functions and WooCommerce product data management APIs."
> "Although we are adding this feature WooCommerce 9.4, it will be initially disabled for all users."

**WooCommerce**, `corpus/woocommerce/dev-blog-enabling-brands.txt`, post date **2025-01-17T08:37:49Z**:
> "In October 2024, we announced the introduction of the Brands plugin migrating into WooCommerce Core as a beta feature that required manual enabling. Since then, we've listened to your feedback, and refined the feature. We are now excited to share that starting with WooCommerce 9.6, scheduled for Monday, January 20th, Brands will move out of beta and be automatically enabled for everyone."
> "Automatically enabled: Brands is now fully integrated into WooCommerce core and turned on by default for all users."

**commercetools**, `corpus/commercetools/docs-lm_product-modeling_product-types.txt:69`:
> "If the same information is used in a large number of Products or Product Variants, it is more efficient to design it as a Custom Object and reference it using an Attribute."
> "Don't overcomplicate your Product Types with too many Attributes. You can add Attributes at any time, but removing Attributes that are already in use can be difficult."
> "Product Types are generally restrictive: if you need flexibility, consider using a Category."
> "Many Projects only have one generic Product Type, but Product Types can be as broad or granular as needed. Pushing all information into one Product Type can lead to a complicated data model with high payloads and poor performance."

### Adobe states option 4 — a definition for every fact, a flag for which behave as built-ins

`corpus/magento-rationale/eav-attributes.txt:79` (developer.adobe.com/commerce/php/development/components/attributes; source markdown `AdobeDocs/commerce-php` last committed **2026-03-17T00:20:31Z**):
> "A module has a set of built-in attributes that are always available. The `Catalog` module has several attributes that are defined as EAV attributes, but are treated as built-in attributes. These attributes include:"

all 14 entries: `attribute_set_id`, `created_at`, `group_price`, `media_gallery`, `name`, `price`, `sku`, `status`, `store_id`, `tier_price`, `type_id`, `updated_at`, `visibility`, `weight`.

> "In this case, when `getCustomAttributes()` is called, the system returns only custom attributes that are not in this list."
> "Custom and Entity-Attribute-Value (EAV) attributes—Custom attributes are those added on behalf of a merchant. For example, a merchant might need to add attributes to describe products, such as shape or volume. A merchant can add these attributes in the Admin panel."
> "Extension attributes. Extension attributes are new in Adobe Commerce and Magento Open Source. They are used to extend functionality and often use more complex data types than custom attributes. These attributes do not appear in the Admin."

### Shopify, on what a definition buys and when to use a new record type instead

`corpus/shopify-rationale/apps_build_custom-data.txt` (shopify.dev/docs/apps/build/custom-data; page carries no date):
> "Custom data stores that information in Shopify, so you don't need to run your own database. The data behaves like the rest of the store's data: you can query it through the GraphQL Admin API, render it in themes, read it from Shopify Functions and extensions, and let merchants edit it in the admin."

its metafields-vs-metaobjects table, all four rows, quoted whole:

| | Metafields | Metaobjects |
|---|---|---|
| What it is | An extra field on an existing resource | A new record type that you define |
| Use it when | The data describes a product, order, customer, or other Shopify object | The data doesn't belong to an existing Shopify object |
| Examples | Care instructions on a product, a loyalty tier on a customer, a routing rule on an order | A size chart, a store location, an ingredient, a product review |

`corpus/shopify-rationale/apps_build_custom-data_metafields.txt`:
> "Shopify includes built-in data models like products, customers, and orders. Metafields extend these models by letting you add custom data to any Shopify resource."
> "Shopify provides pre-built \"standard\" definitions for common use cases like ISBN numbers, product ingredients, and care instructions. Using standard definitions helps ensure interoperability across the Shopify ecosystem and saves you from defining schemas for well-known data types."

`corpus/shopify-rationale/standard-definitions.txt` (16 standard definitions listed; `grep -ci brand` over its 7,945 B → **0**):
> "Standard metafield definitions are metafield definitions that we've created for some common use cases. If you need to store data for one of these use cases, then we recommend using the standard metafield definitions, because they're interoperable across the entire Shopify platform and connect more seamlessly to themes. Standards ensure interoperability across the Shopify ecosystem."

### Square, on what custom attributes are for

`corpus/square-rationale/devtools_customattributes_overview.txt` (banner: "Beta release"; its cURL sample carries `Square-Version: 2026-09-16`) — this is the **non-catalogue** custom-attribute family, recorded for completeness beside the Catalog one quoted in ATTR-DEF §A1.3:
> "Custom attributes are a lightweight way to extend the Square data model and add new properties to some objects, thereby making them more specific to the business problem you're solving. You can use custom attributes in a number of scenarios, such as when a seller has certain attributes they want to capture that aren't native to the Square data model."
> "Custom attributes are intended to store additional information about a resource or associations with an entity in another system."

### Amazon, on what a product-type definition is

`corpus/amazon/docs-product-type-definitions-api.txt` (developer-docs.amazon.com; footer renders a relative date only):
> "You use the Product Type Definitions API to search and retrieve attribute and data requirements for product types in the Amazon catalog. Amazon Product Type Definitions describe the attribute and data requirements for items in the Amazon catalog using JSON schemas."
> "Unless you specify a previous productTypeVersion, the Amazon Product Type Definitions always describe the latest up-to-date Amazon catalog requirements."
> "Most Amazon catalog requirements use standard JSON Schema 2019-09 vocabulary. The Amazon Product Type Definition Meta-Schema also uses custom vocabulary to fully describe Amazon catalog requirements. Custom vocabulary data validation is recommended but not required."
> "Validating data with custom data prevents most listings-related issues from occurring before submitting to Amazon. However, it is up to you to implement such validation."

### Akeneo, on what an attribute is — and the vendor's own count disagreeing with itself

`corpus/akeneo/brand-help-30-serenity-what-is-an-attribute.txt`:
> "An attribute is a product's characteristic. A product usually has several attributes: an identification number, a name, a description, a price, and a color... Depending on your Akeneo Edition version (Community or Enterprise), you can choose from 17 attribute types."
> "In Akeneo, attributes are gathered into families, so all products belonging to the same family share the same attributes."

`corpus/akeneo/brand-catalog-structure.txt`:
> "An attribute is a characteristic of a product. Each product is composed of a variety of attributes."
> "Depending on your Akeneo Edition version, you can have up to 13 attribute types: text and text area, simple or multiselect, boolean (yes/no), date, image, price, number, metric, assets (digital resources like a video, picture, PDF file...)."

⚠️ **Prose says 13, the help centre says 17, and the same page's own table prints 19 rows.** All three recorded as printed.

### Google, on the generic escape hatch

`corpus/google/merchantapi-products_v1-discovery.json` (revision 20260910), `ProductInput.customAttributes`:
> "Optional. A list of custom (merchant-provided) attributes. It can also be used for submitting any attribute of the data specification in its generic form (for example, `{ \"name\": \"size type\", \"value\": \"regular\" }`). This is useful for submitting attributes not explicitly exposed by the API. Maximum allowed number of characters for each custom attribute is 10240 (represents sum of characters for name and value). Maximum 2500 custom attributes can be set per product, with total size of 102.4kB. Underscores in custom attribute names are replaced by spaces upon insertion."

and `brand` itself, with its conditions quoted whole (`corpus/google/brand-attribute-6324351.txt`, "When to use"):
> " Required for each product with a clearly associated brand or manufacturer."
> " Required for each product where the manufacturer is also the merchant (for example, homemade and custom-made products)."
> " Optional for any product that doesn't have a clearly associated brand (for example, movies, books, music, and posters)."
> "Only provide a brand if you're sure it's correct. When in doubt don't provide a brand (for example, don't guess or make up a value)."

Format row, whole: Type `String (Unicode characters. Recommended: ASCII only)` · Limits `1–70 characters` · Repeated field `No` · Schema.org property `Product.brand, Type: Brand`.
