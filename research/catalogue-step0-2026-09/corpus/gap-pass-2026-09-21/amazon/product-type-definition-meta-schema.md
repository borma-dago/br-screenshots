---
updatedAt: 2026-09-09T22:40:47.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Amazon Product Type Definitions Meta-Schema (v1)

The meta-schema that describes the properties and requirements for an Amazon Product Type.

The **Amazon Product Type Definition Meta-Schema** is an extension of the [JSON Schema Draft 2019-09](https://json-schema.org/draft/2019-09/json-schema-core.html), which describes the properties and requirements for an Amazon <<glossary:Product Type>>.

Instances of the Amazon Product Type Definition <<glossary:Meta Schema>> can utilize any of the keywords and vocabularies supported by <<glossary:JSON Schema>> Draft 2019-09. Refer to the [JSON Schema Specification](https://json-schema.org/specification.html) for more details.

**Schema URI**: `https://schemas.amazon.com/selling-partners/definitions/product-types/meta-schema/v1`

**Vocabulary URI**: `https://schemas.amazon.com/selling-partners/definitions/product-types/vocabulary/v1`

> 📘 Note
>
> The schema and vocabulary URIs are identifiers; they are **not** network addressable.

In addition to standard [JSON Schema Draft 2019-09](https://json-schema.org/draft/2019-09/json-schema-core.html) vocabularies, instances of the Amazon Product Type Definition Meta-Schema utilize keywords that are defined by a custom vocabulary in the meta-schema. This documentation outlines the custom vocabulary for `https://schemas.amazon.com/selling-partners/definitions/product-types/vocabulary/v1`.

If you choose to ignore this custom vocabulary and use only the standard [JSON Schema Draft 2019-09](https://json-schema.org/draft/2019-09/json-schema-core.html) vocabularies, you may get validation errors.

## Vocabulary

### `editable`

* **Type**: `Boolean`
* **Purpose**: Informational
* **Description**: Indicates whether or not a property value can be modified for an existing item. Properties that can't be modified may still be required for a valid submission.

### `enumNames`

* **Type**: `array`
* **Purpose**: Informational
* **Description**: Contains an array of display labels for a corresponding array of `enum` values. The display labels in the `enumNames` array are in the same order as the values in the `enum` array.

### `hidden`

* **Type**: `Boolean`
* **Purpose**: Informational
* **Description**: Determines if a property should be hidden in Amazon user interfaces. Hiding or displaying these properties is at the discretion of the application consuming the Amazon Product Type Definition Meta-Schema.

### `maxUniqueItems`

* **Type**: `integer`
* **Purpose**: Validation
* **Description**: Defines the maximum number of unique items in an array. Use in conjunction with `selectors`.

### `minUniqueItems`

* **Type**: `integer`
* **Purpose**: Validation
* **Description**: Defines the minimum number of unique items in an array. Use in conjunction with `selectors`.

### `maxUtf8ByteLength`

* **Type**: `integer`
* **Purpose**: Validation
* **Description**: Defines the maximum length of a `string`, measured in UTF-8 bytes.

### `minUtf8ByteLength`

* **Type**: `integer`
* **Purpose**: Validation
* **Description**: Defines the minimum length of a `string`, measured in UTF-8 bytes.

### `selectors`

* **Type**: `array`
* **Purpose**: Validation
* **Description**: Contains an array of property names that define the combination of properties that make an object unique. By default, the JSON Schema determines the uniqueness of objects in an array, based an all the properties of the object. When `selectors` are defined, only the specified properties are used to determine uniqueness.

### `$lifecycle`

* **Type**: `object`
* **Purpose**: Informational
* **Description**: Provides details for property and constraint changes, such as replacement properties and `enum` value deprecations.

### `replacedBy`

* **Type**: `array`
* **Purpose**: Informational
* **Description**: Contains an array of Relative JSON Pointers according to the [2019-09 JSON schema specification](https://json-schema.org/specification).

### `replaces`

* **Type**: `array`
* **Purpose**: Informational
* **Description**: Contains an array of Relative JSON Pointers according to the [2019-09 JSON schema specification](https://json-schema.org/specification).

### `enumDeprecated`

* **Type**: `array`
* **Purpose**: Informational
* **Description**: Contains an array of deprecated `enum` values. Instances of deprecated `enum` values must be replaced with valid values before the deprecated values are removed.

## Example validator implementations

[JSON Schema](https://json-schema.org) is a vocabulary that allows you to annotate and validate JSON documents. There are multiple paid and open-source applications and libraries that support JSON Schema, refer to [JSON Schema Tooling](https://json-schema.org/tools?query=\&sortBy=name\&sortOrder=ascending\&groupBy=toolingTypes\&licenses=\&languages=\&drafts=\&toolingTypes=) for a list of known implementations.

The following reference validator implementations provide examples of how you can validate a custom vocabulary for instances of Amazon Product Type Definition Meta-Schema using language-specific open-source libraries. Amazon does not provide technical support for third-party JSON Schema libraries and these are provided as examples only.

| Language   | Library                                                                                     | Example                                                                                                                             |
| :--------- | :------------------------------------------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------------- |
| .NET       | [Newtonsoft Json.NET Schema](https://www.newtonsoft.com/jsonschema)                         | [validator implementation](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema-v1-example-c)          |
| Java       | [networknt/json-schema-validator](https://github.com/networknt/json-schema-validator)       | [validator implementation](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema-v1-example-java)       |
| JavaScript | [hyperjump-io/json-schema-validator](https://github.com/hyperjump-io/json-schema-validator) | [validator implementation](https://developer-docs.amazon.com/sp-api/docs/product-type-definition-meta-schema-v1-example-javascript) |