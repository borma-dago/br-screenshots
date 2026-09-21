---
updatedAt: 2026-09-09T22:33:42.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Catalog Items API v2022-04-01 Reference

Use Catalog Items to gain programmatic access to information contained in the Amazon catalog.

Use the Selling Partner API for Catalog Items to retrieve information about items in the Amazon catalog.

For more information, refer to the [Catalog Items API Use Case Guide](https://developer-docs.amazon.com/sp-api/docs/catalog-items-api).

### Version information

*Version* : 2022-04-01

### Contact information

*Contact* : Selling Partner API Developer Support
*Contact URL* : <https://sellercentral.amazon.com/gp/mws/contactus.html>

### License information

*License* : Apache License 2.0
*License URL* : <http://www.apache.org/licenses/LICENSE-2.0>

### URI scheme

*Host* : sellingpartnerapi-na.amazon.com
*Schemes* : HTTPS

### Consumes

* `application/json`

### Produces

* `application/json`

### Operations

[searchCatalogItems](#searchcatalogitems)<br>[getCatalogItem](#getcatalogitem)<br> <a name="paths"></a>

## Paths

<a name="searchcatalogitems"></a>

### GET /catalog/2022-04-01/items

**Operation: searchCatalogItems**

#### Description

Search for a list of Amazon catalog items and item-related information. You can search by identifier or by keywords.

**Usage Plan:**

| Rate (requests per second) | Burst |
| -------------------------- | ----- |
| 5                          | 5     |

The `x-amzn-RateLimit-Limit` response header contains the usage plan rate limits for the operation, when available. The preceding table contains the default rate and burst values for this operation. Selling partners whose business demands require higher throughput might have higher rate and burst values than those shown here. For more information, refer to [Usage Plans and Rate Limits](https://developer-docs.amazon.com/sp-api/docs/usage-plans-and-rate-limits-in-the-sp-api).

#### Parameters

| Type      | Name                                  | Description                                                                                                                                                                                                | Schema                                                         | Default     |
| --------- | ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | ----------- |
| **Query** | **identifiers**  <br>*optional*       | A comma-delimited list of product identifiers that you can use to search the Amazon catalog. **Note:** You cannot include `identifiers` and `keywords` in the same request.<br>**Max count** : 20          | < string > array(csv)                                          | -           |
| **Query** | **identifiersType**  <br>*optional*   | The type of product identifiers that you can use to search the Amazon catalog. **Note:** `identifiersType` is required when `identifiers` is in the request.                                               | enum ([IdentifiersType](#identifierstype))                     | -           |
| **Query** | **marketplaceIds**  <br>*required*    | A comma-delimited list of Amazon store identifiers. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids).<br>**Max count** : 1 | < string > array(csv)                                          | -           |
| **Query** | **includedData**  <br>*optional*      | A comma-delimited list of datasets to include in the response.                                                                                                                                             | < enum ([IncludedData](#includeddata-subgroup-2)) > array(csv) | `summaries` |
| **Query** | **locale**  <br>*optional*            | The locale for which you want to retrieve localized summaries. Defaults to the primary locale of the Amazon store.                                                                                         | string                                                         | -           |
| **Query** | **sellerId**  <br>*optional*          | A selling partner identifier, such as a seller account or vendor code. **Note:** Required when `identifiersType` is `SKU`.                                                                                 | string                                                         | -           |
| **Query** | **keywords**  <br>*optional*          | A comma-delimited list of keywords that you can use to search the Amazon catalog. **Note:** You cannot include `keywords` and `identifiers` in the same request.<br>**Max count** : 20                     | < string > array(csv)                                          | -           |
| **Query** | **brandNames**  <br>*optional*        | A comma-delimited list of brand names that you can use to limit the search in queries based on `keywords`. **Note:** Cannot be used with `identifiers`.                                                    | < string > array(csv)                                          | -           |
| **Query** | **classificationIds**  <br>*optional* | A comma-delimited list of classification identifiers that you can use to limit the search in queries based on `keywords`. **Note:** Cannot be used with `identifiers`.                                     | < string > array(csv)                                          | -           |
| **Query** | **pageSize**  <br>*optional*          | The number of results to include on each page.<br>**Maximum** : 20                                                                                                                                         | integer                                                        | `10`        |
| **Query** | **pageToken**  <br>*optional*         | A token that you can use to fetch a specific page when there are multiple pages of results.                                                                                                                | string                                                         | -           |
| **Query** | **keywordsLocale**  <br>*optional*    | The language of the keywords that are included in queries based on `keywords`. Defaults to the primary locale of the Amazon store. **Note:** Cannot be used with `identifiers`.                            | string                                                         | -           |

#### Responses

| HTTP Code | Description                                                                                                                                                                                             | Schema                                  |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **200**   | Success.  <br>**Headers** :   <br>`x-amzn-RateLimit-Limit` (string) : Your rate limit (requests per second) for this operation.  <br>`x-amzn-RequestId` (string) : Unique request reference identifier. | [ItemSearchResults](#itemsearchresults) |

For error status codes, descriptions and schemas, see [Error responses and schemas](#error-responses-and-schemas).

#### Consumes

* `application/json`

#### Produces

* `application/json`

<a name="getcatalogitem"></a>

### GET /catalog/2022-04-01/items/{asin}

**Operation: getCatalogItem**

#### Description

Retrieves details for an item in the Amazon catalog.

**Usage Plan:**

| Rate (requests per second) | Burst |
| -------------------------- | ----- |
| 5                          | 5     |

The `x-amzn-RateLimit-Limit` response header contains the usage plan rate limits for the operation, when available. The preceding table contains the default rate and burst values for this operation. Selling partners whose business demands require higher throughput might have higher rate and burst values than those shown here. For more information, refer to [Usage Plans and Rate Limits](https://developer-docs.amazon.com/sp-api/docs/usage-plans-and-rate-limits-in-the-sp-api).

#### Parameters

| Type      | Name                               | Description                                                                                                                                                                           | Schema                                                         | Default     |
| --------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | ----------- |
| **Path**  | **asin**  <br>*required*           | The Amazon Standard Identification Number (ASIN) of the item.                                                                                                                         | string                                                         | -           |
| **Query** | **marketplaceIds**  <br>*required* | A comma-delimited list of Amazon store identifiers. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | < string > array(csv)                                          | -           |
| **Query** | **includedData**  <br>*optional*   | A comma-delimited list of datasets to include in the response.                                                                                                                        | < enum ([IncludedData](#includeddata-subgroup-1)) > array(csv) | `summaries` |
| **Query** | **locale**  <br>*optional*         | The locale for which you want to retrieve localized summaries. Defaults to the primary locale of the Amazon store.                                                                    | string                                                         | -           |

#### Responses

| HTTP Code | Description                                                                                                                                                                                             | Schema        |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| **200**   | Success.  <br>**Headers** :   <br>`x-amzn-RateLimit-Limit` (string) : Your rate limit (requests per second) for this operation.  <br>`x-amzn-RequestId` (string) : Unique request reference identifier. | [Item](#item) |

For error status codes, descriptions and schemas, see [Error responses and schemas](#error-responses-and-schemas).

#### Consumes

* `application/json`

#### Produces

* `application/json`

<a name="error-responses-and-schemas"></a>

### Error Responses and Schemas

This table contains HTTP status codes and associated information for error responses.

| HTTP Code | Description                                                                                                                                                                                                                                              | Schema                  |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| **400**   | Request has missing or invalid parameters and cannot be parsed.  <br>**Headers**:  <br>`x-amzn-RateLimit-Limit` (string):Your rate limit (requests per second) for this operation.  <br>`x-amzn-RequestId` (string):Unique request reference identifier. | [ErrorList](#errorlist) |
| **403**   | Indicates that access to the resource is forbidden. Possible reasons include Access Denied, Unauthorized, Expired Token, or Invalid Signature.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                   | [ErrorList](#errorlist) |
| **404**   | The resource specified does not exist.  <br>**Headers**:  <br>`x-amzn-RateLimit-Limit` (string):Your rate limit (requests per second) for this operation.  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                          | [ErrorList](#errorlist) |
| **413**   | The request size exceeded the maximum accepted size.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                                                                                                             | [ErrorList](#errorlist) |
| **415**   | The request payload is in an unsupported format.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                                                                                                                 | [ErrorList](#errorlist) |
| **429**   | The frequency of requests was greater than allowed.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                                                                                                              | [ErrorList](#errorlist) |
| **500**   | An unexpected condition occurred that prevented the server from fulfilling the request.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                                                                          | [ErrorList](#errorlist) |
| **503**   | Temporary overloading or maintenance of the server.  <br>**Headers**:  <br>`x-amzn-RequestId` (string):Unique request reference identifier.                                                                                                              | [ErrorList](#errorlist) |

<a name="definitions"></a>

## Definitions

<a name="error"></a>

### Error

Error response returned when the request is unsuccessful.

| Name                        | Description                                                              | Schema |
| --------------------------- | ------------------------------------------------------------------------ | ------ |
| **code**  <br>*required*    | An error code that identifies the type of error that occurred.           | string |
| **message**  <br>*required* | A message that describes the error condition.                            | string |
| **details**  <br>*optional* | Additional details that can help the caller understand or fix the issue. | string |

<a name="errorlist"></a>

### ErrorList

A list of error responses returned when a request is unsuccessful.

| Name                       | Schema                    |
| -------------------------- | ------------------------- |
| **errors**  <br>*required* | < [Error](#error) > array |

<a name="item"></a>

### Item

An item in the Amazon catalog.

| Name                                | Description                                                                                                                                                                                                                                                                                                                         | Schema                                                  |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **asin**  <br>*required*            | The unique identifier of an item in the Amazon catalog.                                                                                                                                                                                                                                                                             | [ItemAsin](#itemasin)                                   |
| **attributes**  <br>*optional*      | A JSON object containing structured item attribute data that is keyed by attribute name. Catalog item attributes conform to the related Amazon product type definitions that you can get from the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/docs/product-type-definitions-api-v2020-09-01-reference). | [ItemAttributes](#itemattributes)                       |
| **classifications**  <br>*optional* | An array of classifications (browse nodes) that is associated with the item in the Amazon catalog, grouped by `marketplaceId`.                                                                                                                                                                                                      | [ItemBrowseClassifications](#itembrowseclassifications) |
| **dimensions**  <br>*optional*      | An array of dimensions that are associated with the item in the Amazon catalog, grouped by `marketplaceId`.                                                                                                                                                                                                                         | [ItemDimensions](#itemdimensions)                       |
| **identifiers**  <br>*optional*     | Identifiers associated with the item in the Amazon catalog, such as UPC and EAN identifiers.                                                                                                                                                                                                                                        | [ItemIdentifiers](#itemidentifiers)                     |
| **images**  <br>*optional*          | The images for an item in the Amazon catalog.                                                                                                                                                                                                                                                                                       | [ItemImages](#itemimages)                               |
| **productTypes**  <br>*optional*    | Product types that are associated with the Amazon catalog item.                                                                                                                                                                                                                                                                     | [ItemProductTypes](#itemproducttypes)                   |
| **relationships**  <br>*optional*   | Relationships grouped by `marketplaceId` for an Amazon catalog item (for example, variations).                                                                                                                                                                                                                                      | [ItemRelationships](#itemrelationships)                 |
| **salesRanks**  <br>*optional*      | Sales ranks of an Amazon catalog item.                                                                                                                                                                                                                                                                                              | [ItemSalesRanks](#itemsalesranks)                       |
| **summaries**  <br>*optional*       | Summaries of Amazon catalog items.                                                                                                                                                                                                                                                                                                  | [ItemSummaries](#itemsummaries)                         |
| **vendorDetails**  <br>*optional*   | The vendor details that are associated with an Amazon catalog item. Vendor details are only available to vendors.                                                                                                                                                                                                                   | [ItemVendorDetails](#itemvendordetails)                 |

<a name="itemasin"></a>

### ItemAsin

The unique identifier of an item in the Amazon catalog.

*Type* : string

<a name="itemattributes"></a>

### ItemAttributes

A JSON object containing structured item attribute data that is keyed by attribute name. Catalog item attributes conform to the related Amazon product type definitions that you can get from the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/docs/product-type-definitions-api-v2020-09-01-reference).

*Type* : object

<a name="itembrowseclassification"></a>

### ItemBrowseClassification

Classification (browse node) for an Amazon catalog item.

| Name                                 | Description                                          | Schema                                                |
| ------------------------------------ | ---------------------------------------------------- | ----------------------------------------------------- |
| **displayName**  <br>*required*      | Display name for the classification.                 | string                                                |
| **classificationId**  <br>*required* | Identifier of the classification.                    | string                                                |
| **parent**  <br>*optional*           | Parent classification of the current classification. | [ItemBrowseClassification](#itembrowseclassification) |

<a name="itemcontributor"></a>

### ItemContributor

Individual contributor to the creation of an item, such as an author or actor.

| Name                      | Description                                                                            | Schema                                      |
| ------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------- |
| **role**  <br>*required*  | Role of an individual contributor in the creation of an item, such as author or actor. | [ItemContributorRole](#itemcontributorrole) |
| **value**  <br>*required* | Name of the contributor, such as `Jane Austen`.                                        | string                                      |

<a name="itemcontributorrole"></a>

### ItemContributorRole

Role of an individual contributor in the creation of an item, such as author or actor.

| Name                            | Description                                                                    | Schema |
| ------------------------------- | ------------------------------------------------------------------------------ | ------ |
| **displayName**  <br>*optional* | Display name of the role in the requested locale, such as `Author` or `Actor`. | string |
| **value**  <br>*required*       | Role value for the Amazon catalog item, such as `author` or `actor`.           | string |

<a name="itembrowseclassifications"></a>

### ItemBrowseClassifications

An array of classifications (browse nodes) that is associated with the item in the Amazon catalog, grouped by `marketplaceId`.

*Type* : < [ItemBrowseClassificationsByMarketplace](#itembrowseclassificationsbymarketplace) > array

<a name="itembrowseclassificationsbymarketplace"></a>

### ItemBrowseClassificationsByMarketplace

Classifications (browse nodes) that are associated with the item in the Amazon catalog for the indicated `marketplaceId`.

| Name                                | Description                                                                                                                                                | Schema                                                          |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **marketplaceId**  <br>*required*   | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                                                          |
| **classifications**  <br>*optional* | Classifications (browse nodes) that are associated with the item in the Amazon catalog.                                                                    | < [ItemBrowseClassification](#itembrowseclassification) > array |

<a name="dimension"></a>

### Dimension

The value of an individual dimension for an Amazon catalog item or item package.

| Name                      | Description                                  | Schema |
| ------------------------- | -------------------------------------------- | ------ |
| **unit**  <br>*optional*  | Unit of measurement for the dimension value. | string |
| **value**  <br>*optional* | Numeric value of the dimension.              | number |

<a name="dimensions"></a>

### Dimensions

Dimensions of an Amazon catalog item or item in its packaging.

| Name                       | Description                        | Schema                  |
| -------------------------- | ---------------------------------- | ----------------------- |
| **height**  <br>*optional* | Height of an item or item package. | [Dimension](#dimension) |
| **length**  <br>*optional* | Length of an item or item package. | [Dimension](#dimension) |
| **weight**  <br>*optional* | Weight of an item or item package. | [Dimension](#dimension) |
| **width**  <br>*optional*  | Width of an item or item package.  | [Dimension](#dimension) |

<a name="itemdimensions"></a>

### ItemDimensions

An array of dimensions that are associated with the item in the Amazon catalog, grouped by `marketplaceId`.

*Type* : < [ItemDimensionsByMarketplace](#itemdimensionsbymarketplace) > array

<a name="itemdimensionsbymarketplace"></a>

### ItemDimensionsByMarketplace

Dimensions that are associated with the item in the Amazon catalog for the indicated `marketplaceId`.

| Name                              | Description                                                                                                                                                | Schema                    |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| **marketplaceId**  <br>*required* | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                    |
| **item**  <br>*optional*          | Dimensions of an Amazon catalog item.                                                                                                                      | [Dimensions](#dimensions) |
| **package**  <br>*optional*       | Dimensions of a package that contains an Amazon catalog item.                                                                                              | [Dimensions](#dimensions) |

<a name="itemidentifiers"></a>

### ItemIdentifiers

Identifiers associated with the item in the Amazon catalog, such as UPC and EAN identifiers.

*Type* : < [ItemIdentifiersByMarketplace](#itemidentifiersbymarketplace) > array

<a name="itemidentifiersbymarketplace"></a>

### ItemIdentifiersByMarketplace

Identifiers that are associated with the item in the Amazon catalog, grouped by `marketplaceId`.

| Name                              | Description                                                                                                                                                           | Schema                                      |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| **marketplaceId**  <br>*required* | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids).identifier. | string                                      |
| **identifiers**  <br>*required*   | Identifiers associated with the item in the Amazon catalog for the indicated `marketplaceId`.                                                                         | < [ItemIdentifier](#itemidentifier) > array |

<a name="itemidentifier"></a>

### ItemIdentifier

The identifier that is associated with the item in the Amazon catalog, such as a UPC or EAN identifier.

| Name                               | Description                                    | Schema |
| ---------------------------------- | ---------------------------------------------- | ------ |
| **identifierType**  <br>*required* | Type of identifier, such as UPC, EAN, or ISBN. | string |
| **identifier**  <br>*required*     | Identifier of the item.                        | string |

<a name="itemimages"></a>

### ItemImages

The images for an item in the Amazon catalog.

*Type* : < [ItemImagesByMarketplace](#itemimagesbymarketplace) > array

<a name="itemimagesbymarketplace"></a>

### ItemImagesByMarketplace

Images for an item in the Amazon catalog, grouped by `marketplaceId`.

| Name                              | Description                                                                                                                                                | Schema                            |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| **marketplaceId**  <br>*required* | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                            |
| **images**  <br>*required*        | Images for an item in the Amazon catalog, grouped by `marketplaceId`.                                                                                      | < [ItemImage](#itemimage) > array |

<a name="itemimage"></a>

### ItemImage

Image for an item in the Amazon catalog.

| Name                        | Description                                                                 | Schema                     |
| --------------------------- | --------------------------------------------------------------------------- | -------------------------- |
| **variant**  <br>*required* | Variant of the image, such as `MAIN` or `PT01`.  <br>**Example** : `"MAIN"` | enum ([Variant](#variant)) |
| **link**  <br>*required*    | URL for the image.                                                          | string                     |
| **height**  <br>*required*  | Height of the image in pixels.                                              | integer                    |
| **width**  <br>*required*   | Width of the image in pixels.                                               | integer                    |

<a name="itemproducttypes"></a>

### ItemProductTypes

Product types that are associated with the Amazon catalog item.

*Type* : < [ItemProductTypeByMarketplace](#itemproducttypebymarketplace) > array

<a name="itemproducttypebymarketplace"></a>

### ItemProductTypeByMarketplace

Product type that is associated with the Amazon catalog item, grouped by `marketplaceId`.

| Name                              | Description                                                                                                                                                | Schema |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| **marketplaceId**  <br>*optional* | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string |
| **productType**  <br>*optional*   | Name of the product type that is associated with the Amazon catalog item.  <br>**Example** : `"LUGGAGE"`                                                   | string |

<a name="itemsalesranks"></a>

### ItemSalesRanks

Sales ranks of an Amazon catalog item.

*Type* : < [ItemSalesRanksByMarketplace](#itemsalesranksbymarketplace) > array

<a name="itemsalesranksbymarketplace"></a>

### ItemSalesRanksByMarketplace

Sales ranks of an Amazon catalog item, grouped by `marketplaceId`.

| Name                                    | Description                                                                                                                                                | Schema                                                                |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| **marketplaceId**  <br>*required*       | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                                                                |
| **classificationRanks**  <br>*optional* | Sales ranks of an Amazon catalog item for a `marketplaceId`, grouped by classification.                                                                    | < [ItemClassificationSalesRank](#itemclassificationsalesrank) > array |
| **displayGroupRanks**  <br>*optional*   | Sales ranks of an Amazon catalog item for a `marketplaceId`, grouped by website display group.                                                             | < [ItemDisplayGroupSalesRank](#itemdisplaygroupsalesrank) > array     |

<a name="itemclassificationsalesrank"></a>

### ItemClassificationSalesRank

Sales rank of an Amazon catalog item.

| Name                                 | Description                                                              | Schema  |
| ------------------------------------ | ------------------------------------------------------------------------ | ------- |
| **classificationId**  <br>*required* | Identifier of the classification that is associated with the sales rank. | string  |
| **title**  <br>*required*            | Name of the sales rank.                                                  | string  |
| **link**  <br>*optional*             | Corresponding Amazon retail website URL for the sales category.          | string  |
| **rank**  <br>*required*             | Sales rank.                                                              | integer |

<a name="itemdisplaygroupsalesrank"></a>

### ItemDisplayGroupSalesRank

Sales rank of an Amazon catalog item, grouped by website display group.

| Name                                    | Description                                                              | Schema  |
| --------------------------------------- | ------------------------------------------------------------------------ | ------- |
| **websiteDisplayGroup**  <br>*required* | Name of the website display group that is associated with the sales rank | string  |
| **title**  <br>*required*               | Name of the sales rank.                                                  | string  |
| **link**  <br>*optional*                | Corresponding Amazon retail website URL for the sales rank.              | string  |
| **rank**  <br>*required*                | Sales rank.                                                              | integer |

<a name="itemsummaries"></a>

### ItemSummaries

Summaries of Amazon catalog items.

*Type* : < [ItemSummaryByMarketplace](#itemsummarybymarketplace) > array

<a name="itemsummarybymarketplace"></a>

### ItemSummaryByMarketplace

Information about an Amazon catalog item for the indicated `marketplaceId`.

| Name                                        | Description                                                                                                                                                | Schema                                                |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| **marketplaceId**  <br>*required*           | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                                                |
| **adultProduct**  <br>*optional*            | When `true`, the Amazon catalog item is intended for an adult audience or is sexual in nature.                                                             | boolean                                               |
| **autographed**  <br>*optional*             | When `true`, the Amazon catalog item is autographed.                                                                                                       | boolean                                               |
| **brand**  <br>*optional*                   | Name of the brand that is associated with the Amazon catalog item.                                                                                         | string                                                |
| **browseClassification**  <br>*optional*    | Classification (browse node) that is associated with the Amazon catalog item.                                                                              | [ItemBrowseClassification](#itembrowseclassification) |
| **color**  <br>*optional*                   | The color that is associated with the Amazon catalog item.                                                                                                 | string                                                |
| **contributors**  <br>*optional*            | Individual contributors to the creation of the item, such as the authors or actors.                                                                        | < [ItemContributor](#itemcontributor) > array         |
| **itemClassification**  <br>*optional*      | Classification type that is associated with the Amazon catalog item.                                                                                       | enum ([ItemClassification](#itemclassification))      |
| **itemName**  <br>*optional*                | The name that is associated with the Amazon catalog item.                                                                                                  | string                                                |
| **manufacturer**  <br>*optional*            | The name of the manufacturer that is associated with the Amazon catalog item.                                                                              | string                                                |
| **memorabilia**  <br>*optional*             | When true, the item is classified as memorabilia.                                                                                                          | boolean                                               |
| **modelNumber**  <br>*optional*             | The model number that is associated with the Amazon catalog item.                                                                                          | string                                                |
| **packageQuantity**  <br>*optional*         | The quantity of the Amazon catalog item within one package.                                                                                                | integer                                               |
| **partNumber**  <br>*optional*              | The part number that is associated with the Amazon catalog item.                                                                                           | string                                                |
| **releaseDate**  <br>*optional*             | The earliest date on which the Amazon catalog item can be shipped to customers.                                                                            | string (date)                                         |
| **size**  <br>*optional*                    | The name of the size of the Amazon catalog item.                                                                                                           | string                                                |
| **style**  <br>*optional*                   | The name of the style that is associated with the Amazon catalog item.                                                                                     | string                                                |
| **tradeInEligible**  <br>*optional*         | When true, the Amazon catalog item is eligible for trade-in.                                                                                               | boolean                                               |
| **websiteDisplayGroup**  <br>*optional*     | The identifier of the website display group that is associated with the Amazon catalog item.                                                               | string                                                |
| **websiteDisplayGroupName**  <br>*optional* | The display name of the website display group that is associated with the Amazon catalog item.                                                             | string                                                |

<a name="itemvariationtheme"></a>

### ItemVariationTheme

The variation theme is a list of Amazon catalog item attributes that define the variation family.

| Name                           | Description                                                                                                                                                     | Schema           |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| **attributes**  <br>*optional* | Names of the Amazon catalog item attributes that are associated with the variation theme.                                                                       | < string > array |
| **theme**  <br>*optional*      | Variation theme that indicates the combination of Amazon catalog item attributes that define the variation family.  <br>**Example** : `"COLOR_NAME/STYLE_NAME"` | string           |

<a name="itemrelationships"></a>

### ItemRelationships

Relationships grouped by `marketplaceId` for an Amazon catalog item (for example, variations).

*Type* : < [ItemRelationshipsByMarketplace](#itemrelationshipsbymarketplace) > array

<a name="itemrelationshipsbymarketplace"></a>

### ItemRelationshipsByMarketplace

Relationship details for the Amazon catalog item for the specified Amazon `marketplaceId`.

| Name                              | Description                                                                                                                                                | Schema                                          |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| **marketplaceId**  <br>*required* | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                                          |
| **relationships**  <br>*required* | Relationships for the item.                                                                                                                                | < [ItemRelationship](#itemrelationship) > array |

<a name="itemrelationship"></a>

### ItemRelationship

Relationship details for an Amazon catalog item.

| Name                               | Description                                                                                                                                      | Schema                                    |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------- |
| **childAsins**  <br>*optional*     | ASINs of the related items that are children of this item.                                                                                       | < string > array                          |
| **parentAsins**  <br>*optional*    | ASINs of the related items that are parents of this item.                                                                                        | < string > array                          |
| **variationTheme**  <br>*optional* | For `VARIATION` relationships, the variation theme indicates the combination of Amazon catalog item attributes that define the variation family. | [ItemVariationTheme](#itemvariationtheme) |
| **type**  <br>*required*           | Type of relationship.  <br>**Example** : `"VARIATION"`                                                                                           | enum ([Type](#type))                      |

<a name="itemvendordetailscategory"></a>

### ItemVendorDetailsCategory

The product category or subcategory that is associated with an Amazon catalog item.

| Name                            | Description                                                   | Schema |
| ------------------------------- | ------------------------------------------------------------- | ------ |
| **displayName**  <br>*optional* | The display name of the product category or subcategory.      | string |
| **value**  <br>*optional*       | The code that identifies the product category or subcategory. | string |

<a name="itemvendordetails"></a>

### ItemVendorDetails

The vendor details that are associated with an Amazon catalog item. Vendor details are only available to vendors.

*Type* : < [ItemVendorDetailsByMarketplace](#itemvendordetailsbymarketplace) > array

<a name="itemvendordetailsbymarketplace"></a>

### ItemVendorDetailsByMarketplace

The vendor details that are associated with an Amazon catalog item for the specified `marketplaceId`.

| Name                                       | Description                                                                                                                                                | Schema                                                  |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **marketplaceId**  <br>*required*          | Amazon store identifier. To find the ID for your Amazon store, refer to [Amazon store IDs](https://developer-docs.amazon.com/sp-api/docs/marketplace-ids). | string                                                  |
| **brandCode**  <br>*optional*              | The brand code that is associated with an Amazon catalog item.                                                                                             | string                                                  |
| **manufacturerCode**  <br>*optional*       | The manufacturer code that is associated with an Amazon catalog item.                                                                                      | string                                                  |
| **manufacturerCodeParent**  <br>*optional* | The parent vendor code of the manufacturer code.                                                                                                           | string                                                  |
| **productCategory**  <br>*optional*        | The product category that is associated with an Amazon catalog item.                                                                                       | [ItemVendorDetailsCategory](#itemvendordetailscategory) |
| **productGroup**  <br>*optional*           | The product group that is associated with an Amazon catalog item.                                                                                          | string                                                  |
| **productSubcategory**  <br>*optional*     | The product subcategory that is associated with an Amazon catalog item.                                                                                    | [ItemVendorDetailsCategory](#itemvendordetailscategory) |
| **replenishmentCategory**  <br>*optional*  | The replenishment category that is associated with an Amazon catalog item.                                                                                 | enum ([ReplenishmentCategory](#replenishmentcategory))  |

<a name="itemsearchresults"></a>

### ItemSearchResults

Items in the Amazon catalog and search-related metadata.

| Name                                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Schema                      |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| **numberOfResults**  <br>*required* | For searches that are based on `identifiers`, `numberOfResults` is the total number of Amazon catalog items found. For searches that are based on `keywords`, `numberOfResults` is the estimated total number of Amazon catalog items that are matched by the search query. Only results up to the page count limit are returned per request regardless of the number found.<br><br>**Note:** The maximum number of items (ASINs) that can be returned and paged through is 1,000. | integer                     |
| **pagination**  <br>*required*      | The `nextToken` and `previousToken` values that are required to retrieve paginated results.                                                                                                                                                                                                                                                                                                                                                                                        | [Pagination](#pagination)   |
| **refinements**  <br>*required*     | Search refinements for searches that are based on `keywords`.                                                                                                                                                                                                                                                                                                                                                                                                                      | [Refinements](#refinements) |
| **items**  <br>*required*           | A list of items from the Amazon catalog.                                                                                                                                                                                                                                                                                                                                                                                                                                           | < [Item](#item) > array     |

<a name="pagination"></a>

### Pagination

Pagination occurs when a request produces a response that exceeds the `pageSize`. This means that the response is divided into individual pages. To retrieve the next page or the previous page of results, you must pass the `nextToken` value or the `previousToken` value as the `pageToken` parameter in the next request. There is no `nextToken` in the pagination object on the last page.

| Name                              | Description                                             | Schema |
| --------------------------------- | ------------------------------------------------------- | ------ |
| **nextToken**  <br>*optional*     | A token that you can use to retrieve the next page.     | string |
| **previousToken**  <br>*optional* | A token that you can use to retrieve the previous page. | string |

<a name="refinements"></a>

### Refinements

Optional fields that you can use to refine your search results.

| Name                                | Description                                                  | Schema                                                          |
| ----------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------------- |
| **brands**  <br>*required*          | A list of brands you can use to refine your search.          | < [BrandRefinement](#brandrefinement) > array                   |
| **classifications**  <br>*required* | A list of classifications you can use to refine your search. | < [ClassificationRefinement](#classificationrefinement) > array |

<a name="brandrefinement"></a>

### BrandRefinement

A brand that you can use to refine your search.

| Name                                | Description                                                                                                    | Schema  |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| **numberOfResults**  <br>*required* | The estimated number of results that would be returned if you refine your search by the specified `brandName`. | integer |
| **brandName**  <br>*required*       | The brand name that you can use to refine your search.                                                         | string  |

<a name="classificationrefinement"></a>

### ClassificationRefinement

A classification that you can use to refine your search.

| Name                                 | Description                                                                                                           | Schema  |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------- | ------- |
| **numberOfResults**  <br>*required*  | The estimated number of results that would be returned if you refine your search by the specified `classificationId`. | integer |
| **displayName**  <br>*required*      | Display name for the classification.                                                                                  | string  |
| **classificationId**  <br>*required* | The identifier of the classification that you can use to refine your search.                                          | string  |

<a name="variant"></a>

### Variant

Variant of the image, such as `MAIN` or `PT01`.

*Type* : enum

| Value    | Description                 |
| -------- | --------------------------- |
| **MAIN** | Main image for the item     |
| **PT01** | Other image #1 for the item |
| **PT02** | Other image #2 for the item |
| **PT03** | Other image #3 for the item |
| **PT04** | Other image #4 for the item |
| **PT05** | Other image #5 for the item |
| **PT06** | Other image #6 for the item |
| **PT07** | Other image #7 for the item |
| **PT08** | Other image #8 for the item |
| **SWCH** | Swatch image for the item   |

<a name="identifierstype"></a>

### IdentifiersType

The type of product identifiers that you can use to search the Amazon catalog. **Note:** `identifiersType` is required when `identifiers` is in the request.

*Type* : enum

| Value      | Description                                                                                                           |
| ---------- | --------------------------------------------------------------------------------------------------------------------- |
| **ASIN**   | Amazon Standard Identification Number                                                                                 |
| **EAN**    | European Article Number                                                                                               |
| **GTIN**   | Global Trade Item Number                                                                                              |
| **ISBN**   | International Standard Book Number                                                                                    |
| **JAN**    | Japanese Article Number                                                                                               |
| **MINSAN** | Minsan Code                                                                                                           |
| **SKU**    | Stock Keeping Unit, a seller-specified identifier for an Amazon listing. **Note:** Must be accompanied by `sellerId`. |
| **UPC**    | Universal Product Code                                                                                                |

<a name="itemclassification"></a>

### ItemClassification

Classification type that is associated with the Amazon catalog item.

*Type* : enum

| Value                 | Description                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **BASE\_PRODUCT**     | A product that can be directly purchased. Can be a standalone ASIN or a variation child item in the Amazon catalog. |
| **OTHER**             | An item in the Amazon catalog that is not `BASE_PRODUCT`, `PRODUCT_BUNDLE`, or `VARIATION_PARENT`.                  |
| **PRODUCT\_BUNDLE**   | A parent catalog item that represents a bundle of items.                                                            |
| **VARIATION\_PARENT** | A parent catalog item that groups child items into a variation family.                                              |

<a name="type"></a>

### Type

Type of relationship.

*Type* : enum

| Value                  | Description                                                                                                                       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **VARIATION**          | The Amazon catalog item in the request is a variation parent or variation child of the related items that are identified by ASIN. |
| **PACKAGE\_HIERARCHY** | The Amazon catalog item in the request is a package container or is contained by the related items that are identified by ASIN.   |

<a name="replenishmentcategory"></a>

### ReplenishmentCategory

The replenishment category that is associated with an Amazon catalog item.

*Type* : enum

| Value                            | Description                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------- |
| **ALLOCATED**                    | The vendor allocates the inventory to Amazon and Amazon manually purchases it.  |
| **BASIC\_REPLENISHMENT**         | Inventory is manually purchased.                                                |
| **IN\_SEASON**                   | Seasonal item that is manually purchased.                                       |
| **LIMITED\_REPLENISHMENT**       | Amazon generates orders for this item automatically based on unfilled demand.   |
| **MANUFACTURER\_OUT\_OF\_STOCK** | The vendor is out of stock for an extended period of time and cannot backorder. |
| **NEW\_PRODUCT**                 | Amazon does not yet stock this item.                                            |
| **NON\_REPLENISHABLE**           | Indicates assortment parent used for detail page display, not actual items.     |
| **NON\_STOCKUPABLE**             | Drop ship inventory that Amazon does not stock in its fulfillment centers.      |
| **OBSOLETE**                     | The item is obsolete and should not be ordered.                                 |
| **PLANNED\_REPLENISHMENT**       | Active items that should be automatically ordered.                              |

<a name="includeddata"></a>

### IncludedData

*Type* : enum

<a id="includeddata-subgroup-1"></a>**For use with the operation(s): [getCatalogItem](#getcatalogitem)**

| Value               | Description                                                                                                                                                                                                                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **attributes**      | A JSON object containing structured item attribute data that is keyed by attribute name. Catalog item attributes conform to the related Amazon product type definitions that you can get from the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/docs/product-type-definitions-api-v2020-09-01-reference). |
| **classifications** | Classifications (browse nodes) for an item in the Amazon catalog.                                                                                                                                                                                                                                                                   |
| **dimensions**      | Dimensions of an item in the Amazon catalog.                                                                                                                                                                                                                                                                                        |
| **identifiers**     | Identifiers that are associated with the item in the Amazon catalog, such as UPC and EA.                                                                                                                                                                                                                                            |
| **images**          | Images for an item in the Amazon catalog.                                                                                                                                                                                                                                                                                           |
| **productTypes**    | Product types associated with the Amazon catalog item.                                                                                                                                                                                                                                                                              |
| **relationships**   | Relationship details of an Amazon catalog item (for example, variations).                                                                                                                                                                                                                                                           |
| **salesRanks**      | Sales ranks of an Amazon catalog item.                                                                                                                                                                                                                                                                                              |
| **summaries**       | Summary of an Amazon catalog item. For more information, refer to the `attributes` of an Amazon catalog item.                                                                                                                                                                                                                       |
| **vendorDetails**   | Vendor details associated with an Amazon catalog item. Vendor details are only available to vendors.                                                                                                                                                                                                                                |

<a id="includeddata-subgroup-2"></a>**For use with the operation(s): [searchCatalogItems](#searchcatalogitems)**

| Value               | Description                                                                                                                                                                                                                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **attributes**      | A JSON object containing structured item attribute data that is keyed by attribute name. Catalog item attributes conform to the related Amazon product type definitions that you can get from the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/docs/product-type-definitions-api-v2020-09-01-reference). |
| **classifications** | Classifications (browse nodes) for an item in the Amazon catalog.                                                                                                                                                                                                                                                                   |
| **dimensions**      | Dimensions of an item in the Amazon catalog.                                                                                                                                                                                                                                                                                        |
| **identifiers**     | Identifiers that are associated with the item in the Amazon catalog, such as UPC and EAN.                                                                                                                                                                                                                                           |
| **images**          | Images for an item in the Amazon catalog.                                                                                                                                                                                                                                                                                           |
| **productTypes**    | Product types associated with the Amazon catalog item.                                                                                                                                                                                                                                                                              |
| **relationships**   | Relationship details of an Amazon catalog item (for example, variations).                                                                                                                                                                                                                                                           |
| **salesRanks**      | Sales ranks of an Amazon catalog item.                                                                                                                                                                                                                                                                                              |
| **summaries**       | Summary of an Amazon catalog item. For more information, refer to the `attributes` of an Amazon catalog item.                                                                                                                                                                                                                       |
| **vendorDetails**   | Vendor details associated with an Amazon catalog item. Vendor details are only available to vendors.                                                                                                                                                                                                                                |