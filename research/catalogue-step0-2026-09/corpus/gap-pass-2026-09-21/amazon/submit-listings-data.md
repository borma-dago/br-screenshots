---
updatedAt: 2026-09-09T22:39:14.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Submit Listings data

Learn how to submit and manage listing data using the Listings Items API or `JSON_LISTINGS_FEED`.

This guide explains how to submit and manage listing data using the Listings Items API. This guide covers common workflows and code samples for creating and updating listings, including product details, images, inventory, pricing, relationships, and shipping information.

## Submit images data

Images submitted with the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED` can be hosted on or distributed by an Amazon resource such as Amazon S3 or AWS CloudFront or on third-party servers that are publicly available to Amazon.

With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit image data alone or with other listings data elements.

### Create a listing with other data elements using Listings Items API

```http
PUT https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "LUGGAGE",
  "requirements": "LISTING",
  "attributes": {
    "condition_type": [
      {
        "value": "new_new",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "merchant_suggested_asin": [
      {
        "value": "BXXXXXXXXX",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "main_product_image_locator": [
      {
         "media_location": "https://example/main.jpg",
         "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    ... (more attributes, if applicable)
  }
}
```

### Update images using Listings Items API

```http
PATCH https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "PRODUCT",
  "patches": [
    {
      "op": "replace",
      "path": "/attributes/main_product_image_locator",
      "value": [
        {
          "media_location": "https://example/main.jpg",
          "marketplace_id": "ATVPDKIKX0DER"
        }
      ]
    },
    ... (more patches, if applicable)
  ]
}
```

### Create a listing with other data elements using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "UPDATE",
      "productType": "LUGGAGE",
      "requirements": "LISTING",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "main_product_image_locator": [
          {
            "media_location": "https://example/main.jpg",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Update images using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "PATCH",
      "productType": "PRODUCT",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/main_product_image_locator",
          "value": [
            {
              "media_location": "https://example/main.jpg",
              "marketplace_id": "ATVPDKIKX0DER"
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```

## Submit inventory data

With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit inventory data alone or with other listings data elements.

### Create offer-only listing with inventory data using Listings Items API

```http
PUT https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "PRODUCT",
  "requirements": "LISTING_OFFER_ONLY",
  "attributes": {
    "condition_type": [
      {
        "value": "new_new",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "merchant_suggested_asin": [
      {
        "value": "BXXXXXXXXX",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "fulfillment_availability": [
      {
         "fulfillment_channel_code": "DEFAULT",
         "quantity": 5
      }
    ],
    ... (more attributes, if applicable)
  }
}
```

### Update inventory using Listings Items API

```http
PATCH https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "PRODUCT",
  "patches": [
    {
      "op": "replace",
      "path": "/attributes/fulfillment_availability",
      "value": [
        {
          "fulfillment_channel_code": "DEFAULT",
          "quantity": 5
        }
      ]
    },
    ... (more patches, if applicable)
  ]
}
```

### Create an offer-only listing with other data elements using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "UPDATE",
      "productType": "PRODUCT",
      "requirements": "LISTING_OFFER_ONLY",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "fulfillment_availability": [
          {
            "fulfillment_channel_code": "DEFAULT",
            "quantity": 5
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Update inventory using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "PATCH",
      "productType": "PRODUCT",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/fulfillment_availability",
          "value": [
            {
              "fulfillment_channel_code": "DEFAULT",
              "quantity": 5
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```

## Submit pricing data

With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit pricing data only or with other listings data elements.

### Create an offer-only listing using Listings Items API

```http
PUT https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "PRODUCT",
  "requirements": "LISTING_OFFER_ONLY",
  "attributes": {
    "condition_type": [
      {
        "value": "new_new",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "merchant_suggested_asin": [
      {
        "value": "BXXXXXXXXX",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "purchasable_offer": [
      {
        "audience": "ALL",
        "currency": "USD",
        "our_price": [
          {
            "schedule": [
              {
                "value_with_tax": 30.00
              }
            ]
          }
        ]
      }
    ],
    ... (more attributes, if applicable)
  }
}
```

### Update the pricing using Listings Items API

```http
PATCH https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "PRODUCT",
  "patches": [
    {
      "op": "replace",
      "path": "/attributes/purchasable_offer",
      "value": [
        {
          "audience": "ALL",
          "currency": "USD",
          "our_price": [
            {
              "schedule": [
                {
                  "value_with_tax": 30.00
                }
              ]
            }
          ]
        }
      ]
    },
    ... (more patches, if applicable)
  }
}
```

### Create an offer-only listing using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "UPDATE",
      "productType": "PRODUCT",
      "requirements": "LISTING_OFFER_ONLY",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "purchasable_offer": [
          {
            "audience": "ALL",
            "currency": "USD",
            "our_price": [
              {
                "schedule": [
                  {
                    "value_with_tax": 30.00
                  }
                ]
              }
            ]
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Update the pricing using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "PATCH",
      "productType": "PRODUCT",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/purchasable_offer",
          "value": [
            {
              "audience": "ALL",
              "currency": "USD",
              "our_price": [
                {
                  "schedule": [
                    {
                      "value_with_tax": 30.00
                    }
                  ]
                }
              ]
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```

## Submit product data

With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit product data alone or with other listings data elements.

### Create a listing with other data elements using Listings Items API

```http
PUT https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "LUGGAGE",
  "requirements": "LISTING",
  "attributes": {
    "condition_type": [
      {
        "value": "new_new",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "merchant_suggested_asin": [
      {
        "value": "BXXXXXXXXX",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "item_name": [
      {
        "value": "MyBrand Carry-On Luggage",
        "language_tag": "en_US",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "brand": [
      {
        "value": "MyBrand",
        "language_tag": "en_US",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "color": [
      {
        "value": "Red",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "main_product_image_locator": [
      {
         "media_location": "https://example/main.jpg",
         "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    ... (more attributes, if applicable)
  }
}
```

### Update product data using Listings Items API

```http
PATCH https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/ABC123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "LUGGAGE",
  "patches": [
    {
      "op": "replace",
      "path": "/attributes/item_name",
      "value": [
        {
          "value": "MyBrand Carry-On Luggage",
          "language_tag": "en_US",
          "marketplace_id": "ATVPDKIKX0DER"
        }
      ]
    },
    ... (more patches, if applicable)
  ]
}
```

### Create a listing with other data elements using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "UPDATE",
      "productType": "LUGGAGE",
      "requirements": "LISTING",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "item_name": [
          {
            "value": "MyBrand Carry-On Luggage",
            "language_tag": "en_US",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "brand": [
          {
            "value": "MyBrand",
            "language_tag": "en_US",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "color": [
          {
            "value": "Red",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "main_product_image_locator": [
          {
            "media_location": "https://example/main.jpg",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Update product data using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "PATCH",
      "productType": "LUGGAGE",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/item_name",
          "value": [
            {
              "value": "MyBrand Carry-On Luggage",
              "language_tag": "en_US",
              "marketplace_id": "ATVPDKIKX0DER"
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```

## Submit relationships data

A variation family represents a collection of items for one product that is sold in multiple varieties. For example, a clothing article can come in multiple sizes and colors. Each unique size and color combination is represented by a separate listings item and grouped together by a parent listings item to provide a single detail page experience. With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit relationship data alone or with other listings data elements.

With the Listings Items API and `JSON_LISTINGS_FEED`, a parent listings item is created first and each child listings item refers to the parent listings item with the child\_parent\_sku\_relationship attribute. Each listings item in the variation family uses the parentage\_level attribute to define if it is a parent or child within the variation family and the variation\_theme attribute to define the variated attributes for the variation family.

### Create a child and add to a variation family using Listings Items API

```http
PUT https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/Child123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "LUGGAGE",
  "requirements": "LISTING",
  "attributes": {
    "condition_type": [
      {
        "value": "new_new",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "merchant_suggested_asin": [
      {
        "value": "BXXXXXXXXX",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    "child_parent_sku_relationship": [
      {
        "child_relationship_type": "variation",
        "parent_sku": "ABC123",
        "marketplace_id": "ATVPDKIKX0DER"
      }
    ],
    ... (more attributes, if applicable)
  }
}
```

### Add a child to a variation family using Listings Items API

```http
PATCH https://sellingpartnerapi-na.amazon.com/listings/2021-08-01/items/AXXXXXXXXXXXXX/Child123
  ?marketplaceIds=ATVPDKIKX0DER
  &issueLocale=en_US
```

```json
{
  "productType": "LUGGAGE",
  "patches": [
    {
      "op": "replace",
      "path": "/attributes/child_parent_sku_relationship",
      "value": [
        {
          "child_relationship_type": "variation",
          "parent_sku": "ABC123",
          "marketplace_id": "ATVPDKIKX0DER"
        }
      ]
    },
    ... (more patches, if applicable)
  ]
}
```

### Create a child and add to a variation family using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "Child123",
      "operationType": "UPDATE",
      "productType": "LUGGAGE",
      "requirements": "LISTING",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "child_parent_sku_relationship": [
          {
            "child_relationship_type": "variation",
            "parent_sku": "ABC123",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Add a child to a variation family using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "Child123",
      "operationType": "PATCH",
      "productType": "LUGGAGE",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/child_parent_sku_relationship",
          "value": [
            {
              "child_relationship_type": "variation",
              "parent_sku": "ABC123",
              "marketplace_id": "ATVPDKIKX0DER"
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```

## Submit shipping data

Shipping settings for listings items are configured on the account-level by default for sellers in Seller Central. Professional sellers can apply alternative shipping settings by defining shipping templates that are applied to each applicable listings item. The [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED` support applying shipping templates to individual listings items by specifying the merchant\_shipping\_group attribute. By providing the `sellerId` parameter with the Product Type Definitions API, you can retrieve the available shipping templates configured by the seller as an enumeration on the merchant\_shipping\_group attribute value.

With the [Listings Items API](https://developer-docs.amazon.com/sp-api/reference/listings-items-v2021-08-01) and `JSON_LISTINGS_FEED`, you can submit shipping templates data alone or with other listings data elements. For more information, refer to the <https://developer-docs.amazon.com/sp-api/docs/tutorial-retrieve-merchant-shipping-templates> tutorial.

### Create a listing with other data elements using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "UPDATE",
      "productType": "LUGGAGE",
      "requirements": "LISTING",
      "attributes": {
        "condition_type": [
          {
            "value": "new_new",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_suggested_asin": [
          {
            "value": "BXXXXXXXXX",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        "merchant_shipping_group": [
          {
            "value": "legacy-template-id",
            "marketplace_id": "ATVPDKIKX0DER"
          }
        ],
        ... (more attributes, if applicable)
      }
    },
    ... (more messages, if applicable)
  ]
}
```

### Update shipping templates data using `JSON_LISTINGS_FEED`

```json
{
  "header": {
    "sellerId": "AXXXXXXXXXXXXX",
    "version": "2.0",
    "issueLocale": "en_US"
  },
  "messages": [
    {
      "messageId": 1,
      "sku": "ABC123",
      "operationType": "PATCH",
      "productType": "PRODUCT",
      "patches": [
        {
          "op": "replace",
          "path": "/attributes/merchant_shipping_group",
          "value": [
            {
              "value": "legacy-template-id",
              "marketplace_id": "ATVPDKIKX0DER"
            }
          ]
        },
        ... (more patches, if applicable)
      ]
    },
    ... (more messages, if applicable)
  ]
}
```