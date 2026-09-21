---
updatedAt: 2026-09-09T22:40:57.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Retrieve a Product Type Definition

Learn how to return Amazon Product Type Definitions and related schemas from the Product Type Definitions API for a given selling partner, Amazon product type, and Amazon store.

Learn how to return Amazon Product Type Definitions and related schemas from the Product Type Definitions API for a given selling partner, Amazon product type, and Amazon store.

## Prerequisites

To complete this tutorial, you need:

* Authorization from the Selling Partner for whom you are making calls. Refer to [Authorizing Selling Partner API applications](https://developer-docs.amazon.com/sp-api/docs/authorizing-selling-partner-api-applications) for more information.
* Approval for the [Product Listing role](https://developer-docs.amazon.com/sp-api/docs/roles-in-the-selling-partner-api#product-listing) in your developer profile.
* The Product Listing role selected in the App registration page for your application.

## Step 1. Retrieve the Product Type Definition

Call the [`getDefinitionsProductType`](https://developer-docs.amazon.com/sp-api/reference/getdefinitionsproducttype) operation to retrieve an Amazon Product Type Definition from the [Product Type Definitions API](https://developer-docs.amazon.com/sp-api/docs/product-type-definitions-api).

## Step 2. Retrieve the schema documents

In the previous step, the retrieved Amazon Product Type Definition includes details about the Amazon product type and links to retrieve the <<glossary:meta schema>> and product type schema documents. The links provided are valid for seven days.

Schema documents can be retrieved programmatically with a standard HTTP client or manually with a web browser.

> 📘 Note
>
> Include the optional `sellerId` parameter to retrieve the seller-specific attributes, including B2B audience values. The API returns B2B attributes only when the seller is enrolled in the Amazon Business program. If the `sellerId` is not provided, the API returns a generic schema without the seller-specific configurations.

> ❗️ Meta schema names cannot be resolved using the web
>
> The Amazon Product Type Definition JSON schema document references the meta schema by name. Some JSON schema libraries attempt to resolve meta schema names online via the web, which the [Amazon Product Type Definition Meta-Schema (v1)](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema) does not support. These libraries should be configured to use a downloaded copy of the meta schema instead. Refer to the accompanying [Amazon Product Type Definition Meta-Schema (v1)](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema) documentation for more details.

## `parentageLevel` parameter

You can use the optional `parentageLevel` query parameter to retrieve a JSON Schema applicable to a specific listing type. When you provide this parameter, the schema includes only the attributes and requirements relevant to the specified parentage level.

| Value    | Description                                                                                                                                                             |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CHILD`  | Schema for **variation child listings**. Includes attributes applicable to listings with a parent-child variation relationship. The `parent_sku` attribute is required. |
| `PARENT` | Schema for **variation parent listings**. Includes attributes applicable to variation group containers.                                                                 |
| `NONE`   | Schema for **standalone listings** with no variation relationships. Variation-related attributes are excluded.                                                          |

When `parentageLevel` is omitted, the full schema with all conditional logic is returned.

### Retrieve a schema for a child listing example

```
GET /definitions/2020-09-01/productTypes/SHIRT ?marketplaceIds=ATVPDKIKX0DER &requirements=LISTING &requirementsEnforced=ENFORCED &locale=en_US &parentageLevel=CHILD
```

### Retrieve a schema for a parent listing example

```
GET /definitions/2020-09-01/productTypes/SHIRT ?marketplaceIds=ATVPDKIKX0DER &requirements=LISTING &parentageLevel=PARENT
```

### Retrieve a schema for a standalone listing example

```
GET /definitions/2020-09-01/productTypes/LUGGAGE ?marketplaceIds=ATVPDKIKX0DER &requirements=LISTING &parentageLevel=NONE
```

When you create listings that are not part of a variation family, include `parentageLevel=NONE` when calling `getDefinitionsProductType` to retrieve a schema applicable to standalone listings. Variation-related attributes are excluded from the returned schema.

For more information about configuring variation families, refer to [Configure related listings items](https://developer-docs.amazon.com/sp-api/docs/building-listings-management-workflows-guide#configure-related-listingsitems-variations-package-hierarchies).