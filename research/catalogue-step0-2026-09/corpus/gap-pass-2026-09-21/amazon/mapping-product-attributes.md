---
updatedAt: 2026-09-09T22:39:27.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Mapping product attributes to the Listings Items API and JSON-based feeds

Map product attributes from category XSDs and flat file feed types to the Listings Items API and JSON-based feeds.

> ❗ Important
>
> Starting **July 31, 2025**, the Feeds API no longer supports legacy XML and flat file listing feeds, including pricing, inventory, relationships, and images. Developers will receive fatal `processingStatus` in the `getFeed` API response for these feeds. For more information, refer to the [deprecation announcement](https://developer-docs.amazon.com/sp-api/changelog/deprecation-of-feeds-api-support-for-xml-and-flat-file-listings-feeds).

## Product attributes mappings from category XSDs (XML) and flat file feed types

Data elements in the <<glossary:Listings Item>>s API and `JSON_LISTINGS_FEED` are structured and, in some cases, named differently from how those data elements are structured and named in XML and flat file feed types. The updated data elements are a more direct representation of the data modeling of Amazon’s catalog, expanding support for features not previously available with legacy feed types and enabling consistency with the latest requirements of the Amazon catalog.

The mapping of data elements for inventory, pricing, images, shipping, and variation relationships are outlined in this guide in the following sections. However, for product data (for example: item names, bullet points, and other relevant attributes), there are thousands of mappings from legacy XML and flat file feed types. To aid in migration of product attributes, the following files provide mappings from the product data elements from legacy XML and flat file feed types to the corresponding data elements in the Listings Items API and `JSON_LISTINGS_FEED`.

* [Product XML (Category XSD) Mappings](https://m.media-amazon.com/images/G/01/VSSC/XPath-To-JSON-mappings.xlsx)
* [Product Flat File Mappings](https://m.media-amazon.com/images/G/01/VSSC/FlatFile-To-JSON-Mapping.xlsx)

> 🚧 Updates for Legacy Flat Feed Users
>
> The following changes apply to legacy flat feed users:
>
> * `merchant_shipping_group_name`(`merchant_shipping_group`) attribute requires the enumeration key instead of name in the `JSON path/attributes/merchant_shipping_group/0/value` - **also applies to legacy XML feed users**.
> * Unit of measure requires full names instead of abbreviations (use "pounds" instead of "lb" for weight).
> * Variation theme format changes from **CamelCase** in flat files (`SizeName`) to **Underscore** format in the JSON schema (`Size_Name`).
>
> These format and naming changes can cause enum values and attribute names to differ between flat file and `JSON_LISTINGS_FEED`, requiring updates to your data mappings during migration.

The mappings in these files are limited to product-related attributes (that is, they do not include inventory or pricing) and do not include the product type or Amazon store-specific relevancy of each. The [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/reference/product-type-definitions-v2020-09-01) provides JSON Schemas that represent the applicable attributes and constraints per product type and Amazon store. Using the mapping files in conjunction with the JSON Schemas lets you update your data mappings, identify which mappings are relevant for each product type and Amazon store, identify data elements no longer relevant, and identify new relevant data elements.

## Inventory Feed mappings

The following table provides a mapping of XML element by XPath to JSON element by JSON Pointer for inventory data.

| XML Element                                             | JSON Element                                                        | Description                                                                                                                                                                                                                                   |
| :------------------------------------------------------ | :------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/AmazonEnvelope/Message/Inventory/FulfillmentCenterID` | `/attributes/fulfillment_availability/0/fulfillment_channel_code`   | Represents the name of the fulfillment channel. Examples: `DEFAULT` (MFN), `AMAZON_NA` (FBA), `AMAZON_EU` (FBA), and `AMAZON_JP` (FBA).                                                                                                       |
| `/AmazonEnvelope/Message/Inventory/Available`           | `/attributes/fulfillment_availability/0/is_inventory_available`     | Indicates MFN inventory is always available instead of providing a quantity value.                                                                                                                                                            |
| `/AmazonEnvelope/Message/Inventory/Quantity`            | `/attributes/fulfillment_availability/0/quantity`                   | Indicates MFN quantity available for fulfillment.                                                                                                                                                                                             |
| `/AmazonEnvelope/Message/Inventory/RestockDate`         | `/attributes/fulfillment_availability/0/restock_date`               | Indicates the date MFN quantity is available for fulfillment.                                                                                                                                                                                 |
| `/AmazonEnvelope/Message/Inventory/FulfillmentLatency`  | `/attributes/fulfillment_availability/0/lead_time_to_ship_max_days` | Indicates the handling time for MFN fulfillment.                                                                                                                                                                                              |
| `/AmazonEnvelope/Message/Inventory/SwitchFulfillmentTo` | -                                                                   | Indicates the provided fulfillment type (MFN or AFN) should replace the existing fulfillment type. This feature is replaced by explicitly adding and deleting fulfillment channels. More details outlined in the SwitchFulfillmentTo section. |

## Pricing Feed mappings

The following table provides a mapping of XML element by XPath to JSON element by JSON Pointer for pricing data. Data elements no longer relevant have been excluded.

> 📘 Note
>
> For more details on how to granularly update and delete individual `purchasable_offer` sub-attributes using the Listings Items API, refer to [Manage purchasable offer](https://developer-docs.amazon.com/sp-api/docs/manage-purchasable-offer).

| XML Element                                                       | JSON Element                                                                                                               | Description                                        |
| :---------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------- |
| `/AmazonEnvelope/Message/Price/StandardPrice`                     | `/attributes/purchasable_offer/0/our_price/0/schedule/0/value_with_tax` `/attributes/purchasable_offer/0/audience` = "ALL" | Standard price, when no discounted price scheduled |
| `/AmazonEnvelope/Message/Price/Sale/StartDate`                    | `/attributes/purchasable_offer/0/discounted_price/0/schedule/0/start_at`                                                   | Discounted price schedule start date               |
| `/AmazonEnvelope/Message/Price/Sale/EndDate`                      | `/attributes/purchasable_offer/0/discounted_price/0/schedule/0/end_at`                                                     | Discounted price schedule end date                 |
| `/AmazonEnvelope/Message/Price/Sale/SalePrice`                    | `/attributes/purchasable_offer/0/discounted_price/0/schedule/0/value_with_tax`                                             | Discounted price.                                  |
| `/AmazonEnvelope/Message/Price/MinimumSellerAllowedPrice`         | `/attributes/purchasable_offer/0/minimum_seller_allowed_price/0/schedule/0/value_with_tax`                                 | Minimum price for automated pricing                |
| `/AmazonEnvelope/Message/Price/MaximumSellerAllowedPrice`         | `/attributes/purchasable_offer/0/maximum_seller_allowed_price/0/schedule/0/value_with_tax`                                 | Maximum price for automated pricing                |
| `/AmazonEnvelope/Message/Price/MAP`                               | `/attributes/purchasable_offer/0/map_price/0/schedule/0/value_with_tax`                                                    | MAP price                                          |
| `/AmazonEnvelope/Message/Price/MSRPWithTax`                       | `/attributes/purchasable_offer/0/list_price/0/schedule/0/value_with_tax`                                                   | MSRP price                                         |
| `/AmazonEnvelope/Message/Price/BusinessPrice`                     | `/attributes/purchasable_offer/0/our_price/0/schedule/0/value_with_tax` `/attributes/purchasable_offer/0/audience` = "B2B" | B2B price                                          |
| `/AmazonEnvelope/Message/Price/QuantityPriceType`                 | `/attributes/purchasable_offer/0/quantity_discount_plan/0/schedule/0/discount_type`                                        | Quantity Discount Type                             |
| `/AmazonEnvelope/Message/Price/QuantityPrice/QuantityPrice1`      | `/attributes/purchasable_offer/0/quantity_discount_plan/0/schedule/0/levels/0/value`                                       | Quantity Discount                                  |
| `/AmazonEnvelope/Message/Price/QuantityPrice/QuantityLowerBound1` | `/attributes/purchasable_offer/0/quantity_discount_plan/0/schedule/0/levels/0/lower_bound`                                 | Quantity Discount price                            |

## Image type mappings

The following table provides a mapping of image types used in XML image feeds to the applicable JSON element by JSON pointer.

| Image Type       | JSON Element                                                 | Description                                         |
| :--------------- | :----------------------------------------------------------- | :-------------------------------------------------- |
| `Main`           | `/attributes/main_product_image_locator/0/media_location`    | Main product image.                                 |
| `Swatch`         | `/attributes/swatch_product_image_locator/0/media_location`  | Swatch image representing the color of an item.     |
| `BKLB`           | -                                                            | No longer used.                                     |
| `PT1`            | `/attributes/other_product_image_locator_1/0/media_location` | Other product image                                 |
| `PT2`            | `/attributes/other_product_image_locator_2/0/media_location` | Other product image                                 |
| `PT3`            | `/attributes/other_product_image_locator_3/0/media_location` | Other product image                                 |
| `PT4`            | `/attributes/other_product_image_locator_4/0/media_location` | Other product image                                 |
| `PT5`            | `/attributes/other_product_image_locator_5/0/media_location` | Other product image                                 |
| `PT6`            | `/attributes/other_product_image_locator_6/0/media_location` | Other product image                                 |
| `PT7`            | `/attributes/other_product_image_locator_7/0/media_location` | Other product image                                 |
| `PT8`            | `/attributes/other_product_image_locator_8/0/media_location` | Other product image                                 |
| `Search`         | -                                                            | No longer used (main product image used for search) |
| `PM01`           | -                                                            | No longer used                                      |
| `MainOfferImage` | `/attributes/main_offer_image_locator/0/media_location`      | Main offer image (for items in non-new condition)   |
| `OfferImage1`    | `/attributes/other_offer_image_locator_1/0/media_location`   | Other offer image (for items in non-new condition)  |
| `OfferImage2`    | `/attributes/other_offer_image_locator_2/0/media_location`   | Other offer image (for items in non-new condition)  |
| `OfferImage3`    | `/attributes/other_offer_image_locator_3/0/media_location`   | Other offer image (for items in non-new condition)  |
| `OfferImage4`    | `/attributes/other_offer_image_locator_4/0/media_location`   | Other offer image (for items in non-new condition)  |
| `OfferImage5`    | `/attributes/other_offer_image_locator_5/0/media_location`   | Other offer image (for items in non-new condition)  |
| `PFEE`           | -                                                            | No longer used                                      |
| `PFUK`           | `/attributes/image_locator_pfuk/0/media_location`            | Product fiche image (UK)                            |
| `PFDE`           | `/attributes/image_locator_pfde/0/media_location`            | Product fiche image (DE)                            |
| `PFFR`           | `/attributes/image_locator_pffr/0/media_location`            | Product fiche image (FR)                            |
| `PFIT`           | `/attributes/image_locator_pfit/0/media_location`            | Product fiche image (IT)                            |
| `PFES`           | `/attributes/image_locator_pfes/0/media_location`            | Product fiche image (ES)                            |
| `EEGL`           | `/attributes/image_locator_eegl/0/media_location`            | Energy efficiency image                             |
| `PT98`           | -                                                            | No longer used                                      |
| `PT99`           | -                                                            | No longer used                                      |
| `ELFL`           | `/attributes/image_locator_elfl/0/media_location`            | Lighting facts image                                |