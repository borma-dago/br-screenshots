---
updatedAt: 2026-09-09T22:41:03.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Product Type Definitions API

Learn how to programmatically access product type attribute and data requirements in the Amazon catalog.

You use the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/reference/product-type-definitions-v2020-09-01) to search and retrieve attribute and data requirements for product types in the Amazon catalog. Amazon Product Type Definitions describe the attribute and data requirements for items in the Amazon catalog using <<glossary:JSON schema>>s.

Refer to the [Product Type Definitions API v2020-09-01 Reference](https://developer-docs.amazon.com/sp-api/reference/product-type-definitions-v2020-09-01) for details about API operations and associated data types and schemas.

| Current version                                                                                                                                                                                                                                                                                                                                                                                                                            | Legacy versions | Availability        | Sandbox |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- | :------------------ | :------ |
| v2020-09-01 ([Reference](https://developer-docs.amazon.com/sp-api/reference/product-type-definitions-v2020-09-01 "Access the complete API reference documentation for the Product Type Definitions API.") \| [Model](https://github.com/amzn/selling-partner-api-models/blob/main/models/product-type-definitions-api-model/definitionsProductTypes_2020-09-01.json "Access the JSON schema model for the Product Type Definitions API.")) | None            | Sellers and Vendors | Static  |

<details aria-label="Dropdown menu for Product Type Definitions API release notes"> 
  <summary>Release notes</summary>

\- [May 27, 2026](https://developer-docs.amazon.com/sp-api/docs/sp-api-release-notes#may-27-2026)

* [December 13, 2023](https://developer-docs.amazon.com/sp-api/docs/sp-api-release-notes#december-13-2023)
* [November 8, 2023](https://developer-docs.amazon.com/sp-api/docs/sp-api-release-notes#november-8-2023)
* [April 19, 2023](https://developer-docs.amazon.com/sp-api/docs/sp-api-release-notes#april-19-2023)

</details>

To learn more about the terms that are used on this page, refer to [Terminology](https://developer-docs.amazon.com/sp-api/docs/terminology).

## Use cases

The following use case examples are available for the Product Type Definitions API:

* [Search available Product Type Definitions](https://developer-docs.amazon.com/sp-api/docs/search-available-product-type-definitions): Search and identify Amazon product types available in the Product Type Definitions API for a given Amazon store and type of selling partner account.
* [Get Product Type Definition recommendations](https://developer-docs.amazon.com/sp-api/docs/get-product-type-definition-recommendations): Get Amazon product type recommendations from the Product Type Definitions API for a given Amazon store, type of selling partner account, and item name.
* [Get recommended browse nodes or item type keywords](https://developer-docs.amazon.com/sp-api/docs/get-recommended-browse-nodes-or-item-type-keywords): Retrieve Amazon recommended browse nodes and item type keywords values using the Product Type Definitions API for a given Amazon store and product type.
* [Retrieve a Product Type Definition](https://developer-docs.amazon.com/sp-api/docs/retrieve-a-product-type-definition): Return Amazon Product Type Definitions and related schemas from the Product Type Definitions API for a given selling partner, Amazon product type, and Amazon store.

> ⭐ Tip
>
> Unless you specify a previous `productTypeVersion`, the Amazon Product Type Definitions always describe the latest up-to-date Amazon catalog requirements.

> ⭐ Tip
>
> To retrieve schemas for variation family listings, use the `parentageLevel` query parameter with `getDefinitionsProductType` to specify your listing type (`CHILD`, `PARENT`, or `NONE`). For more information, refer to [Retrieve a Product Type Definition](https://developer-docs.amazon.com/sp-api/docs/retrieve-a-product-type-definition).

## Roles for the Product Type Definitions API v2020-09-01

<details>
<summary><span class="notranslate">getDefinitionsProductType</span></summary>

| Attribute                          | Value                                                                                                                                                                                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Regions                            |  NA, EU, FE                                                                                                                                                                                                                                                        |
| Required roles (need at least one) |  [Inventory and Order Tracking](https://developer-docs.amazon.com/sp-api/docs/roles-in-the-selling-partner-api#inventory-and-order-tracking)<br> [Product Listing](https://developer-docs.amazon.com/sp-api/docs/roles-in-the-selling-partner-api#product-listing) |

</details>

<details>
<summary><span class="notranslate">searchDefinitionsProductTypes</span></summary>

| Attribute                          | Value                                                                                                                                                                                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Regions                            |  NA, EU, FE                                                                                                                                                                                                                                                        |
| Required roles (need at least one) |  [Inventory and Order Tracking](https://developer-docs.amazon.com/sp-api/docs/roles-in-the-selling-partner-api#inventory-and-order-tracking)<br> [Product Listing](https://developer-docs.amazon.com/sp-api/docs/roles-in-the-selling-partner-api#product-listing) |

</details>

## JSON schema support

Amazon Product Type Definition JSON schemas extend [JSON Schema 2019-09](https://json-schema.org/draft/2019-09/release-notes.html). If future versions of JSON Schema are adopted by the Product Type Definitions API, they will be accompanied by a new Product Type Definitions API version release and [Amazon Product Type Definition Meta-Schema](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema).

Most Amazon catalog requirements use standard [JSON Schema 2019-09](https://json-schema.org/draft/2019-09/release-notes.html) vocabulary. The Amazon Product Type Definition Meta-Schema also uses custom vocabulary to fully describe Amazon catalog requirements. Custom vocabulary data validation is recommended but not required.

Validating data with custom data prevents most listings-related issues from occurring before submitting to Amazon. However, it is up to you to implement such validation.

The amount of custom code required depends on your application. Refer to the following JSON schema validation use cases for examples of when custom code is needed:

* **Open-source library *with* validation of custom vocabulary**
  * Retrieve schemas from the Product Type Definitions API
  * Implement validation of custom vocabulary
  * Integrate with the open-source library

* **Open-source library *without* validation of custom vocabulary**
  * Retrieve schemas from the Product Type Definitions API
  * Integrate with the open-source library

For more information, refer to the [Amazon Product Type Definition Meta-Schema (v1)](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema) documentation, which includes example integrations with open-source libraries to validate data with a custom vocabulary in .NET (C#), Java, and JavaScript (Node.js).

## Open-source libraries

There are dozens of open-source libraries and implementations available to validate data, render user interfaces, and generate code. For a complete list, refer to [JSON Schema Tooling](https://json-schema.org/tools?query=\&sortBy=name\&sortOrder=ascending\&groupBy=toolingTypes\&licenses=\&languages=\&drafts=\&toolingTypes=).

Amazon does not directly support or endorse any specific open-source or commercial libraries and implementations. Examples provided in this documentation are for reference only.