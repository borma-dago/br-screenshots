# TikTok Shop (Tokopedia Era B) — structured API spec via `api_meta` · gap pass 2026-09-21

**Route.** #11068 §3.2 + the 2026-09-21 correction (#11336): `partner.tiktokshop.com/api/v1/document/tree?workspace_id=3`
(958 nodes, `tree-ws3.json`) and the undocumented `document/api_meta?src_document_id=<id>` endpoint, which serves the
**structured** spec (params, types, required flags, enums, samples) with no credential. `document/detail` returned
`98001001 internal error` for all five ids today (`detail-*.json`, 56 B) — the structured route is what worked.
Tier-1 vendor text, one route. Files: `api_meta-{get-attributes,create-product,get-category-rules,get-brands,get-global-attributes}.json`.

## Get Attributes — `GET /product/202309/categories/{category_id}/attributes` (`api_meta-get-attributes.json`, 15,598 B)

Response `data.attributes[]`, vendor descriptions verbatim:
- `id : string` — *"The ID of the built-in attribute."*
- `name : string`
- `type : string` — *"The attribute type. Possible values: - SALES_PROPERTY: Indicates sales attributes that define product variants. - PRODUCT_PROPERTY: Indicates product attributes that describe the product as a whole."*
- `is_requried : bool` — *"A flag to indicate if the product attribute is always required when creating or editing a product. - true: The attribute is always required. - false: The attribute is not required, or required only if certain conditions are met. Refer to `requirement_conditions` for the specific requirements. Applicable only if `type=PRODUCT_PROPERTY`."*
- `values : []object {id, name, icon_url}` — *"A list of selectable values for the attribute."*
- `value_data_format : string` — *"The supported data type and structure of the attribute value for free-form entries, such as strings, integers, or positive decimals. Applicable only for **conditional (cascading) attributes**, not for standard attributes. Possible values: - POSITIVE_INT_OR_DECIMAL: Positive integers or decimal numbers."*
- `is_customizable : bool` — *"A flag to indicate if the product attribute value can be customized by sellers when creating or editing a product. Applicable only if `type=PRODUCT_PROPERTY`."*
- `requirement_conditions : []object {condition_type, attribute_id, attribute_value_id}` — *"A list of conditions that determine if the product attribute is required based on the seller's inputs for other attributes. If any of the conditions is met, the attribute is required; otherwise, it is optional. For example … the "Battery type" attribute is required if the seller selects the value "Batteries" for the attribute "Contains Batteries or Cells?"."* `condition_type` — *"Possible values: - VALUE_ID_MATCH: The condition is true when the seller selects a value whose ID matches the one specified in this condition."*
- `is_multiple_selection : bool` — *"Applicable only if `type=PRODUCT_PROPERTY`."*

**What it adds.** (1) Confirms #11048 §1.8 verbatim from the structured spec. (2) **Conditional requiredness is a
first-class field on the definition** — `requirement_conditions[] {condition_type: VALUE_ID_MATCH, attribute_id,
attribute_value_id}` — the one shipped instance of D17 option (d) "conditional" in the thirteen. (3) `value_data_format`
is the typed-quantity gate and it is scoped to cascading attributes only; the standard value is an id/name row.
(4) The only value type vocabulary is `POSITIVE_INT_OR_DECIMAL`; no unit field anywhere on the attribute.

## Create Product — `POST /product/202309/products` (`api_meta-create-product.json`, 139,730 B; `request_body_param`)

Required flags from the structured sheet (`req=Y/N`), field types verbatim:
- Product level: `title : string Y` · `description : string Y` · `category_id : string Y` · `main_images[] Y` · `skus[] Y` · `brand_id : string N` · `category_version : string N` · `package_dimensions {length, width, height, unit — all string, Y within} N` · `package_weight {value, unit — string} N` · `product_attributes[] {id : string Y, values[] Y {id : string N, name : string N}} N` · `certifications[]` · `size_chart` · `is_not_for_sale : bool` · `listing_platforms : []string` · `manufacturer_ids : []string` · `responsible_person_ids : []string` · `search_terms`, `key_product_features : []string` · `minimum_order_quantity : int` · `idempotency_key : string` · `locale`, `auto_translate_enabled`.
- SKU level (`skus[]`): `sales_attributes[] {id : string, value_id : string, value_name : string, name : string, sku_img {uri}, supplementary_sku_images[]} N` · `inventory[] {warehouse_id Y, quantity, backorder_quantity, handling_time} Y` · `price {amount, currency Y, sale_price, starting_bid_price} Y` · `seller_sku : string` · `identifier_code {code, type}` · `extra_identifier_codes : []string` · **`combined_skus[] {product_id Y, sku_id Y, sku_count : int Y}`** · `sku_unit_count : string` · `sku_dimensions {length, width, height, unit}` · `sku_weight {value, unit}` · `list_price`, `external_list_prices[]`, `fees[]`, `pre_sale`.

**What it adds.** (1) **Both levels carry physical dimensions**: `package_dimensions`/`package_weight` on the product
and `sku_dimensions`/`sku_weight` on the SKU — an A5 "both levels" instance for one kind of fact. (2) A value is
written as `{id, name}` for product attributes and `{id, value_id, value_name, name}` for sales attributes — id-bearing
row OR a name, the hybrid shape (A4 (c)) stated in the schema. (3) **`combined_skus[]` is a separate bundle
mechanism on the SKU** (`product_id`, `sku_id`, `sku_count`) beside the sales-attribute axis — Tokopedia Era B
joins the "separate pack/bundle mechanism beside variation" list (C2), making it 5 of 13. (4) All money and
quantity fields are **strings** (`amount : string`, `sku_unit_count : string`), never numbers.

Not settled: everything shop-gated (a live `access_token` + `shop_cipher` is still absent — #11336 re-proved the app keys
valid by error-code differential only).
