# Card A4 — "What is a value, and where does its allowed list live?"
## Evidence base from the thirteen platform records, the decision matrix, and our own prior decision record

Read-only extraction. Every quote is copied verbatim from the cited file at the cited line number.
**Nothing here is a conclusion.** Where two records disagree, both sides are quoted and neither is preferred.

---

## Legend — short code → issue → file

All files are under `/home/irvan/copilot/research/catalogue-step0-2026-09/evidence/`.

| Code | Issue | File |
|---|---|---|
| `AMZ` | #10976 — Amazon | `issues/10976.md` |
| `SHOP` | #11011 — Shopify | `issues/11011.md` |
| `GOOG` | #11013 — Google Merchant Center | `issues/11013.md` |
| `EBAY` | #11045 — eBay | `issues/11045.md` |
| `WMT` | #11046 — Walmart Marketplace | `issues/11046.md` |
| `SHPE` | #11047 — Shopee | `issues/11047.md` |
| `TOKO` | #11048 — Tokopedia (TWO ERAS, never merged) | `issues/11048.md` |
| `SQ` | #11049 — Square | `issues/11049.md` |
| `SFCC` | #11050 — Salesforce Commerce Cloud B2C | `issues/11050.md` |
| `AKN` | #11069 — Akeneo PIM | `issues/11069.md` |
| `WOO` | #11080 — WooCommerce | `issues/11080.md` |
| `CT` | #11081 — commercetools Composable Commerce | `issues/11081.md` |
| `MAG` | #11082 — Magento Open Source / Adobe Commerce | `issues/11082.md` |
| `PRIOR` | #10778 — our own prior decision record (variant grouping) | `issues/10778.md` |
| `D` | #10966 — the decision record, D1–D18 | `issues/10966.md` |
| `X` | #11031 — cross-platform verification + per-decision evidence | `issues/11031.md` |
| `MATRIX` | — | `pages/catalogue-decision-matrix-2026-09-16.txt` |
| `V7` | — | `pages/catalogue-next-steps-v7.txt` |
| `SHARED` | — | `pages/shared-or-per-member-2026-09-15.txt` |

Citation form: `CODE:line`. Example — `EBAY:126` = line 126 of `issues/11045.md`.

---

## The card as posed

`V7:107`, heading `### What is a value, and where does its allowed list live?` (tier marker `A4 tier 1` at `V7:105`):

> `V7:109` — *"Is "Soto" a string typed on each product, or a row that many products point at? Is "215 g" a number with a unit, or text? Who decides the order the picker shows?"*
>
> `V7:111` — *"A value is a free string · a shared option row · or hybrid by type (select-typed → row, free text → string)."*
>
> `V7:113` — *"The list lives on the attribute (one list everywhere) · the category (per-category list) · the family (Shopify's option values belong to the product)."*
>
> `V7:115` — *"Quantities are text · a number under a unit fixed on the definition · a number plus a unit on the value (Akeneo's metric type)."*
>
> `V7:117` — *"Subsumes D8, D9. Today: 0.7% case drift, 25–32% junk in manufacturer, '0' on 11,071 rows, 28,750 titles carrying a unit token. Sunday: Shopify linked versus unlinked values; Square shared option values; Akeneo option order and metric type; GS1 and BPOM net-content rules."*

The two decisions it subsumes, as `MATRIX` heads them:

- `MATRIX:2126–2127` — `D8` / `### Is a value a shared row, or a string copied per product?` · `MATRIX:2128` gate: `gate: Amazon shared-vocabulary half`
- `MATRIX:2155–2156` — `D9` / `### Is a value a bare label, or a label plus a typed quantity and a unit?` · `MATRIX:2157` gate: `after D8`

Both are **OPEN** — `D:82` `| **D8** | Is a value a **shared row**, or a **string copied per product**? | OPEN |` · `D:83` `| **D9** | Is a value a **bare label**, or a label plus a typed quantity and a unit? | OPEN |`

---

# PART 1 — THE FOURTEEN PLATFORM ROWS

---

## 1. AMAZON — `AMZ` (#10976)

### Q1 · VALUE SHAPE → **(a) free string, copied per child, inside an array-of-objects envelope.** The shared-vocabulary half is an explicit UNKNOWN and is the matrix's declared gate on D8.

Section: `### 1.3 `Attribute`` (`AMZ:83`)

- `AMZ:89` — `| value shape | array of objects | `[{ "value": 4, "marketplace_id": "ATVPDKIKX0DER" }]` | [E-10] `→ .items[0].attributes.total_hdmi_ports` |`
- `AMZ:95` — *"**✅ `name` is stable; the label is not.** Every one of the **381** legacy `…/Flavor` XPaths maps to **exactly one** JSON pointer — `/attributes/flavor/0/value`. Searching the *other* direction (`JSON Pointer` matching `/flavou?r/i`) returns the **identical 381 rows**, `set(A) == set(B)` [E-9]. Route 2: `flavor.value_id` appears as an attribute in **all 24 marketplaces**, 13,800 rows of an independently-produced artifact [E-3]."*
- `AMZ:140` — *"**❗ The attribute may be a composite of three separately-named entries** [E-3]: `Flavor` (5,937 rows) · `flavor.value_id` (13,800 rows, all 24 marketplaces) · `Flavor Standardized Values` (5,582 rows). Whether these are three attributes or three views of one is **not established**."*

Section: `## §4 · `❓UNKNOWN` — what no public artifact answers` (`AMZ:530`)

- `AMZ:549` — `| U16 | Whether `Flavor`, `flavor.value_id` and `Flavor Standardized Values` are three attributes or three views of one | **H1** |`

Cross-platform corroboration:

- `X:1032` (section `### P4 · The value`) — *"eBay **copied** — `aspects` is `{name: [strings]}` on each SKU … Walmart **copied**, no ids anywhere in the feed"*
- `MATRIX:2135–2138` — `Copied4 | Amazon100 / eBay80 / Google70 / Walmart65 | Amazon: "must be replicated", a single route. eBay: {name: [strings]} per SKU, 0 ids over 867 MB. Every marketplace copies. |`
- `MATRIX:2128` — `gate: Amazon shared-vocabulary half`

**Maps to (a), with a flagged unknown.** Hedge quoted verbatim: `AMZ:140` *"not established"*.

**Stated vendor rationale:** no stated rationale in the record for value shape.

### Q2 · WHERE THE ALLOWED LIST LIVES → **(B) on the category / product type, per marketplace.** Soft enum in the one measured case; hard enum in the large majority.

Section: `## 3 · Attributes — the value shape` (`AMZ:13549`)

- `AMZ:13571–13584` — a complete real attribute definition [A2, `item_type_keyword`, `LUGGAGE`, US store], reproduced whole in the record, including:
  `"value": { "type": "string", "minLength": 1, "maxLength": 500, "editable": true, "hidden": false, "anyOf": [ { "type": "string" }, { "type": "string", "enum": ["luggage","travel-garment-bags","luggage-accessories","luggage-handle-wraps","luggage-tag-and-handle-wrap-sets"], "enumNames": ["Clothing, Shoes & Jewelry > Luggage & Travel Gear > Luggage", …] } ] }`
- `AMZ:13589` — *"1. **`additionalProperties: false`** on the value object — the shape is closed."*
- `AMZ:13590` — *"2. **`anyOf: [string, {string + enum + enumNames}]`** — a *soft* enum: a free string is schema-valid, and a suggested closed list sits alongside it."*
- `AMZ:13591` — *"3. `enumNames` here are **browse-path strings**, and the description says item type keywords *"are used to place new ASINs in the appropriate place(s) within the graph."*"*

Section: `### 1.2 `ProductTypeSchema`` (`AMZ:55`)

- `AMZ:60` — `| `marketplaceIds` | string[] | `["ATVPDKIKX0DER"]` — **the schema differs per marketplace** | [E-2] |`

Section: `### 1.3 `Attribute`` (`AMZ:83`)

- `AMZ:138` — *"**❓ Free text, or a closed list?** The legacy XSD says free text — `<xsd:element minOccurs="0" name="Flavor" type="String"/>`, where `String` is `xsd:normalizedString` with `maxLength 50`, **no `xsd:restriction`, no `xsd:enumeration`** [E-4]. That is **one route**, and the obvious second route cannot confirm it: [E-9] populates `XML Value` on only **3,044 of 231,514** rows … **An empty `XML Value` is a property of the workbook, not evidence about the domain.** Adjacent data, for other product types [E-3]: *"New valid values have been introduced in the list of **suggested** values"* (`SUGAR_CANDY`, `SYRUP`, `BAKING_MIX`, 21 rows) · *"A new list with valid values is being introduced for the attribute"* (`SEASONING`, 7 rows). **No such row exists for `NOODLE`.** **H1.**"*
- `AMZ:548` — `| U15 | **Is `flavor` a closed list on the JSON side?** The XSD says free text (`maxLength 50`, no `xsd:enumeration`) — one route; [E-9] cannot corroborate | **H1** — the `NOODLE` definition schema |`

Section: `### 1.5 `VariationTheme`` (`AMZ:187`)

- `AMZ:197` — *"**✅ The legal set is per product type — the whole registry for one category, measured.** `FoodAndBeverages.xsd` declares **107 product types; 105 carry a `VariationData/VariationTheme` enum**, using **44 distinct tokens** between them. Enum sizes run 3 (`Shellfish`) to 29 (`SugarCandy`) [E-4]. ⚠️ 2026-09-02: **per type in *this* category — others gate at category level:** `Sports.xsd` has **one** 199-token enum over its **123** product types, `Luggage.xsd` one of 9 over 13 [E-11]."*
- `AMZ:216` — *"**⚠️ A product type can declare an attribute without offering it as an axis.** `EdibleOilAnimal`, `Shellfish` and `CulinarySalt` each declare a product-type-level `Flavor` element while their theme enum is exactly `size_name · color_name · sizename-colorname` — no flavour token. … **Declaring the attribute and permitting the axis are two different facts.**"*
- `AMZ:240` — *"**✅ A token legal for one product type is illegal for another** [E-21]: *"You might see different valid values for same field in different categories. For Ex: A valid variation theme in Beauty is 'Size-Scent,' however, 'Size-Scent' is not a valid variation theme in the Apparel category."* Route 2 — [E-25]: *"you are required to use Amazon's standard themes available in the drop-down menu for your specific category."*"*

Section: `### Confirmed: product type determines the attribute set, and the set is closed` (`PRIOR:204`, quoting the same Amazon evidence)

- `PRIOR:206` — *"Verified against real Amazon schemas. Both carry **`"additionalProperties": false`** at the top level — a seller cannot add an attribute the type does not define. `PRODUCT` (ES) has 72 attributes, `AUTO_PART` (AU) has 101; 16 unique to one, 45 to the other. The same attribute name validates differently per type (`color` is `maxLength: 1000` in one, `50` in the other) and is even **renamed** per type ("Shirt Size" for `SHIRT`, "Bottoms Size" for `PANTS`). `GROCERY` carries **59 root-level conditional branches**."*

**Maps to (B).**

**Stated vendor rationale**, verbatim:

- `AMZ:13607` — *"If you choose to ignore this custom vocabulary and use only the standard JSON Schema Draft 2019-09 vocabularies, you may get validation errors."*
- `AMZ:233` — *"When you select a variation theme for a child listing item, you must provide the corresponding properties. For example, if you set the `variation_theme` to `SIZE/COLOR/NUMBER_OF_ITEMS`, then `shirt_size`, `color`, and `number_of_items` become mandatory. When using `parentageLevel=CHILD`, these mandatory properties appear directly in the schema as required attributes."*

### Q3 · QUANTITIES → **five different shapes in ONE schema.** No single answer, and the record says so.

Section: `## 3 · Attributes — the value shape` (`AMZ:13549`)

- `AMZ:13554–13561`, reproduced whole:
  `"total_hdmi_ports": [{ "value": 4, "marketplace_id": "ATVPDKIKX0DER" }]`
  `"item_weight": [{ "unit": "pounds", "value": 107.6, "marketplace_id": "ATVPDKIKX0DER" }]`
  `"resolution": [{ "language_tag": "en_US", "value": "4K", "marketplace_id": "ATVPDKIKX0DER" }]`
  `"item_dimensions": [{ "width": {"unit":"inches","value":72.4}, "length": {"unit":"inches","value":2.4}, "height": {"unit":"inches","value":41.4}, "marketplace_id": "…" }]`
- `AMZ:13564` — *"The qualifier set **varies per attribute**: `unit` on a weight, `language_tag` on a localisable string, neither on a count."*
- `AMZ:13565` — *"Composite attributes **nest**: `item_dimensions` holds three `{unit, value}` objects under one `marketplace_id`."*

Section: `## Comment · … Verification pass — every attribute / variant claim` (`AMZ:14004`), and the same finding in `D`

- `D:886` — *"one Amazon-published attributes object carries five structurally distinct value shapes — {value, marketplace_id}; {language_tag, value, marketplace_id}; {unit, value, marketplace_id}; {width/length/height sub-measures, no top-level value}; {cell_composition:[{value}], no top-level value} — with at least three more shapes elsewhere"*
- `PRIOR:277` (section `## Why it is out of scope`) — *"**4. The design question is genuinely unsettled, even at Amazon.** One Amazon product-type schema carries **five different shapes** for quantity: `item_package_weight` = `{value, unit:enum(7)}`, `liquid_volume` = `{value, unit:enum(20)}`, `unit_count` = `{value, type:{value, language_tag}}`, `number_of_items` = bare integer, `size` = free text `maxLength:50`. **There is no single right answer to import.**"*
- `MATRIX:2176` — `Five shapes at once1 | Amazon100 | {value, unit}, unit_count {value, type}, a bare integer and free-text size ≤ 50 characters in one schema. |`

Net content — section `### 1.4 `ProductTypeAttribute`` (`AMZ:146`):

- `AMZ:172` — the 12 required fields of `Food` and `Beverages`, whole: `item_sku` · `external_product_id` · `external_product_id_type` · `item_name` · `manufacturer` · `feed_product_type` · `item_type` · **`item_package_quantity`** · `merchant_shipping_group_name` · `main_image_url` · **`unit_count`** · **`unit_count_type`**
- `AMZ:14277` — release-note row: `US | NOODLE | Unit Count Type | A new list with valid values is being introduced for the attribute.`
- `AMZ:14127` (correction C2) — *"**`package_contains` is not settled.** Amazon's page contradicts itself: prose says `package_contains`, the JSON example two lines below uses **`package_contains_sku`**. Neither string appears in either of Amazon's own mapping workbooks, while `package_level` does. Only `package_level` is double-verified."*

**Maps to: all three of the card's options simultaneously.**

**Stated vendor rationale:** no stated rationale in the record for the shape variance.

### Q4 · ORDERING → **the enum array's own stored order. There is no position column on a value.**

Section: `## 4 · The meta-schema — what an attribute can express` (`AMZ:13593`)

- `AMZ:13603` — `| `enumNames` | Informational | *"display labels for a corresponding array of enum values… **in the same order as the values in the enum array**."* |`
- `AMZ:13605` — `| `$lifecycle` · `replaces` · `replacedBy` · `enumDeprecated` | Informational | *"details for property and constraint changes, such as replacement properties and enum value deprecations"* |`

Section: `### Addendum to the link map — S2 scrutinised` (`AMZ:13857`)

- `AMZ:13871` — *"The `attributes` list is **alphabetical, not token order** — a set, not a positional decoding."*
  (this is the *variation theme's* attribute list, not a picker's value list — recorded so it is not mistaken for one)

A whole-file search of `AMZ` for `sort order` / `display order` / `order of values` returns nothing on the subject.

**Maps to: the platform's own fixed/stored enum order.**
**Stated vendor rationale:** the `enumNames` description at `AMZ:13603` is the only statement, and it is a format rule rather than a rationale.

### Q5 · VALUE IDENTITY / RENAME → **the attribute `name` is stable; the label is not; and the published `enum` is NOT a stable code list — that framing is explicitly withdrawn.**

- `AMZ:95` — *"**✅ `name` is stable; the label is not.**"* (quoted whole above)
- `AMZ:97–104` — *"**⚠️ The display label is per-marketplace *and* per display language.** One attribute, one event, 20 rows [E-3]"* — `US · CA · AU · SG · AE · IN` = `Flavor` · `UK` = `Flavour` · `DE` = `Geschmacksrichtung` · `BR · ES · MX` = `Sabor` · `FR` = `Parfum/Saveur` · `IT` = `Sapore` · `NL` = `Smaak` · `PL · SE` = `Smak` · `TR` = `Aroma` · `JP` = `味` · `EG · SA` = `نكهة`
- `AMZ:106` — *"**✅ And the label follows the display language, not the marketplace.** `amazon.de/dp/B09XK9VBCS` renders `Flavour` / `hühn` by default and `Geschmacksrichtung` / `Hühn` under `?language=de_DE` — same URL, same DOM row `tr.po-flavor` [E-32]."*
- `AMZ:108` — *"**❗ A label collision, recorded because it defeats the obvious search.** `Aroma` is the **TR** label for *flavour* and simultaneously the **BR** label for *`Scent`* — a different attribute. In TR, `Scent` is `Koku`; in BR, flavour is `Sabor`. **Matching attributes by localised label produces false joins** [E-3]."*

Section: `## ⚠️ Corrections and refinements found by this pass` (`AMZ:14036`)

- `AMZ:14045–14047` — *"**2. `enum` is locale-dependent — it is not a stable code list.** [amzn#5239] … *"The same `getDefinitionsProductType` request returns **different `enum` values depending on the requested `locale`** — the schema is localized… SP-API publishes both fields with identical, locale-dependent display strings — so the convention's machinery (let `enum` flow to the wire, let `enumNames` flow to the UI) cannot be used."*"*
- `AMZ:14049` — *"**3. The published `enum` is not reliably the set the validator accepts.** [amzn#5238] For `COFFEE` on Amazon.de, `branded_coffee_machine_insert_type` publishes `"Nespresso Original"` in `enum`/`enumNames`, but only the undocumented `"nespresso_original"` is accepted; the published value returns `90244 / INVALID_ATTRIBUTE`."*
- `AMZ:14055` — *"**4. Consequently, my earlier framing of "`enum` holds tokens, `enumNames` holds display labels" was too clean and is withdrawn.** The observed reality is inconsistent across attributes"*
- `AMZ:14059–14061` — `| `CELLULAR_PHONE_CASE.variation_theme` | uppercase tokens — `"COLOR"`, `"COLOR_NAME"` |` · `| `COFFEE.branded_coffee_machine_insert_type` | display strings — `"Nespresso Original"` |` · `| `DRINKING_CUP.variation_theme` | *(only `enumNames` was posted; the `enum` form is not known)* |`
- `AMZ:14063` — *"There is no single `enum`/`enumNames` contract to copy. Recorded as an observation about Amazon, not a recommendation."*
- `AMZ:243` — *"**Deprecation is in-band** [E-14]: *"`enumDeprecated` indicates enumeration values that are deprecated and must be avoided… new listings must avoid using deprecated enumeration values."*"*
- `AMZ:175` — *"**❗ The join is mutable — Amazon adds and removes attributes from product types.** Of 26,135 flavour-attribute rows in the release notes, **15,299** carry the update string *"Attribute is deleted and no longer associated with the product type."*"*

**Maps to: a stable attribute `name`; NO stable value code — the enum is locale-dependent and the validator disagrees with it.**

**Stated vendor rationale**, verbatim — `AMZ:14053`, Amazon staff (`weilinggu`, CONTRIBUTOR):
> *"The mismatch you've identified — where `getDefinitionsProductType` publishes human-readable display values in `enum`/`enumNames` … while the server-side validator only accepts undocumented snake_case codes … is a valid concern that warrants internal investigation."*

---

## 2. SHOPIFY — `SHOP` (#11011)

### Q1 · VALUE SHAPE → **(c) HYBRID BY OPTION KIND.** An unlinked value is a string on the product; a linked value is a Metaobject GID shared across products. Observed live on a dev store, 2026-09-05.

Section: `### 1.3 `ProductOption` — the variant axis` (`SHOP:97`)

- `SHOP:103–107` — the 7 fields, whole:
  `name String! "Color" ← FREE TEXT, merchant-authored`
  `position Int! 2`
  `values [String!]! ["Blue","Green"]`
  `optionValues [ProductOptionValue!]! [{name:"Blue",hasVariants:true}, …]`
  `linkedMetafield LinkedMetafield {namespace:"shopify", key:"color-pattern"}`
- `SHOP:110` — `values` vs `optionValues`, quoted whole: *"Similar to values, option_values returns all the corresponding option value objects to the product option, including values not assigned to any variants."*
- `SHOP:112–119` — `ProductOptionValue`, 6 fields, whole:
  `id ID! "gid://shopify/ProductOptionValue/1054677147"`
  `name String! "Plain"`
  `hasVariants Boolean! "Whether the product option value has any linked variants."`
  `linkedMetafieldValue String "gid://shopify/Metaobject/971662499"`
  `swatch ProductOptionValueSwatch {color, image}`
  `translations(...) [Translation!]!`
- `SHOP:121` — vendor's inline query comment: *"# hasVariants indicates if the value is assigned to any variant.\n# false = unused (not used by any variant yet)\n# true = assigned to at least one variant"*

Section: `### 1.5 `SelectedOption` — the binding` (`SHOP:154`)

- `SHOP:164–168` — retrieved instances, **both published forms**:
  `"selectedOptions":[{"name":"Pattern","optionValue":{"id":"gid://shopify/ProductOptionValue/1054677147","name":"Plain"}}, {"name":"Width","optionValue":{"id":"gid://shopify/ProductOptionValue/1054677149","name":"Slim"}}]`
  `"selectedOptions":[{"name":"Title","value":"151cm"},{"name":"Color","value":"Blue"}]`
  — the id is present on one surface and absent on the other.

Section: `### E13` (`SHOP:1044`), and the same cell in `X`

- `X:1037` — *"⚠️ 2026-09-05, dev-store pass, observed: **both, by option kind.** An unlinked option value is a string on the product (`optionValues[].name` — read back on the `cp0905-fix-bulk` product as option `Size` / `ProductOptionValue/6805122056513` `{"name":"v0000"}`; the standalone case reads back as `Default Title`). A linked option value carries `linkedMetafieldValue: "gid://shopify/Metaobject/253676454209"` — a reference to a `Metaobject` row that exists independently of the product (created by `metaobjectCreate`, deleted by `metaobjectDelete`) — beside its display `name` (`"cp0905 Blue"`) and a `swatch {color, image}` resolved from that metaobject's `color` / `image` fields; **two products linked to the same metaobject `253696180545` each read back the same gid**."*
- `SHOP:1081` — live response, whole: `{"data":{"productOptionsCreate":{"product":{"id":"gid://shopify/Product/10363188838721","options":[{"id":"gid://shopify/ProductOption/12896816464193","name":"Color","position":1,"linkedMetafield":{"namespace":"shopify","key":"color-pattern"},"optionValues":[{"id":"gid://shopify/ProductOptionValue/6804826751297","name":"cp0905 Blue","linkedMetafieldValue":"gid://shopify/Metaobject/253676454209","swatch":{"color":"#2B6CB0","image":null}},{"id":"gid://shopify/ProductOptionValue/6804826784065","name":"cp0905 Image Swatch","linkedMetafieldValue":"gid://shopify/Metaobject/253676486977","swatch":{"color":null,"image":{"id":"gid://shopify/MediaImage/56765795205441",…}}}]}]}}}`

Section: `## §2c · ✅ Retrieved instance — a STANDALONE product (revision 3)` (`SHOP:439`)

- `SHOP:447/450` — `"options":[{"name":"Title","values":["Default Title"]}]` · `"selectedOptions":[{"name":"Title","value":"Default Title"}]`
- `SHOP:453` — *"❗ **There is no "no variant" state.** A standalone product still carries **one option** (`Title`) and **one variant** (`Default Title`), with a real `SelectedOption` binding them. Shopify synthesises the axis rather than allowing its absence."*

**Maps to (c).**

**Stated vendor rationale:** `SHOP:367`, quoted to the end — *"**Caution:** Avoid leaving option values unused. Always create variants for all option values you define, or remove option values that you don't need. Unused option values can cause confusion and unexpected behavior."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(C) on the PRODUCT for an unlinked option; (B) on the CATEGORY for a linked one.** Both stated and both observed live.

Section: `### The three answers, in Shopify's terms` (`SHOP:614`)

- `SHOP:620` — `| **Is the value list closed?** | On the taxonomy surface, yes — **30** values for `flavor`, published and versioned. On the `ProductOption` surface, **no** — `OptionValueCreateInput.name` is a free string. ⚠️ 2026-09-05: `INVALID_VALUE` on a non-integer / outside `choices`, controls accepted |`
- `SHOP:619` — `| **How do you make flavour the variant axis?** | Create a `ProductOption` named anything you like — **`ProductOption.name` is free text**, so `"Flavor"` needs no taxonomy involvement at all *for an unlinked option*. Optionally bind it to a metafield via `linkedMetafield`. … on the **linked** path, `CombinedListingUpdateUserErrorCode.PARENT_PRODUCT_MUST_HAVE_CATEGORY` *"The combined listing parent product must have a product category to use linked metafield options."* and `ProductOptionsCreateUserErrorCode.LINKED_METAFIELD_DEFINITION_NOT_FOUND` *"No valid metafield definition found for linked option."*; `metafield-linked.md` :30 requires *"a metafield definition … with owner type `Product` and type `list.metaobject_reference`"* |`
- `SHOP:618` — `| **What makes a product carry `flavor`?** | Its `TaxonomyCategory` declares it — `fb-1` does, `fb-2-14` does not. **Or** an unconstrained `MetafieldDefinition` applies it to everything. Two independent surfaces. |`

Section: `### 1.7 `TaxonomyCategory` — the open-source taxonomy` (`SHOP:196`)

- `SHOP:209` — `attributes TaxonomyCategoryAttributeConnection! ← the category DECLARES its attributes`
- `SHOP:240–249` — *"**❗ The GraphQL attribute is a union of three types**"*, whole: `union TaxonomyCategoryAttribute = TaxonomyAttribute | TaxonomyChoiceListAttribute | TaxonomyMeasurementAttribute`, with `| TaxonomyChoiceListAttribute | id: ID! · name: String! "For example, Color." · values: TaxonomyValueConnection! |` and `| TaxonomyValue | id: ID! · name: String! "For example, Red." |`
- `SHOP:230–236` — 14,606 categories · 93,007 category→attribute edges · 8,500 distinct attribute handles · **0 of 8,500** unresolved references · 152 categories with `attributes: []`
- `SHOP:259–262` — `distinct values` **74,820** · fewest on a base attribute **2** (`assembly_required`) · most **451** (`eu_shoe_size`) · defined but never referenced **56**
- `SHOP:562–578` — the `Flavor` attribute reproduced whole, `friendly_id: flavor`, `handle: flavor`, with its 30 values listed; *"**Exactly 30 values**, each `gid://shopify/TaxonomyValue/<int>` in the dist form"*
- `SHOP:264` — per-attribute category fan-out: `color` **10,927** · `pattern` **10,882** · `material` **4,546** · `age_group` **1,598** · `flavor` **293** · `organic_certification` 4 · `pasta_type` **3**
- `SHOP:211` — *"**⚠️ 2026-09-02 (S1-a).** Declared here, but no `Product` field carries them: **0 of `Product`'s 80 fields** match /attribute/i; the per-product carriers are `MetafieldDefinition` with constraint key `category` + `Metafield` and `ProductOption.linkedMetafield`."*

Section: `### 1.8 `MetafieldDefinition` — the *second* attribute surface` (`SHOP:268`)

- `SHOP:288–293` — **how a definition is scoped, quoted to the end of the clause**:
  *"By default, metafield definitions apply to every resource on their owner type. For example, `Product` metafield definitions apply to all products and appear on all product detail pages in the Shopify admin."*
  *"However, some metafield definitions should only apply to a subset of resources. For example, `Shoe size` is a valid metafield for `Shoes` products but wouldn't apply to `Sweaters`."*
  *"At the core of the conditional metafields system are constraint subtypes. Constraint subtypes are `key | value` pairs that identify a "subtype" of a metafield owner type."*
  *"**Currently, Shopify only supports constraint subtypes that correspond to product categories on `Product` metafield definitions.** These constraint subtypes all have a `key` equal to `category`."*
  *"If a definition is unconstrained, then the definition applies to all resources and appears on all resource pages in the Shopify admin."*
- `SHOP:296–304` — retrieved instance, published request and response: `"constraints":{"key":"category","values":["gid://shopify/TaxonomyCategory/aa-8", … 9 GIDs …]}` → response returns bare ids `{"value":"aa-8"},{"value":"aa-8-1"}…`
- `SHOP:307–313` — Shopify's own standard category-constrained definitions for `aa-6-8`, `constraintStatus: CONSTRAINED_ONLY`: `Color`/`shopify:color-pattern`, `Target gender`, `Age group`, `Jewelry material`, `Jewelry type`

Live, both directions — `SHOP:1047–1049` (full text under Item 5 below).

**Maps to (C) for an unlinked option and (B) for a linked one.**

**Stated vendor rationale:** `SHOP:290` — *"However, some metafield definitions should only apply to a subset of resources. For example, `Shoe size` is a valid metafield for `Shoes` products but wouldn't apply to `Sweaters`."*

### Q3 · QUANTITIES → **bare label; the unit lives on the variant, never on the value.** A measurement attribute type exists in the taxonomy with **zero** instances met.

- `X:1050` — *"⚠️ 2026-09-05, dev-store pass, observed: option values are labels (`name`), with an optional `linkedMetafieldValue` gid and `swatch {color: "#2B6CB0" | null, image: MediaImage | null}` on linked values; **no unit on the value.** Measured quantities live on the **variant**: `ProductVariant.inventoryItem.measurement.weight {value: 0.5, unit: "KILOGRAMS"}` (REST: `grams: 500`, `weight: 0.5`, `weight_unit: "kg"`) and `ProductVariant.unitPriceMeasurement {measuredType, quantityValue, quantityUnit, referenceValue, referenceUnit}` (all null/0 on the pass's variants). The taxonomy also declares a `TaxonomyMeasurementAttribute` member (`id, name, options`), of which the pass met **0** instances across 383 attribute nodes on 44 categories (all `TaxonomyChoiceListAttribute`)."*
- `SHOP:95` — *"**❗ There is no `weight` field on `ProductVariant`.** Instrument: a search of all **26,781 B** of the live introspection response and all **84,912 B** of `ProductVariant.md` for `weight|Weight|grams|mass|measurement` returns **no `ProductVariant` field**. Weight reaches the variant only via `inventoryItem: InventoryItem!` → `InventoryItemMeasurement { weight: Weight }` → `Weight { unit: WeightUnit!, value: Float! }`."*
- `SHOP:1069` — live: `"unitPriceMeasurement":{"measuredType":null,"quantityValue":0.0,"quantityUnit":null,"referenceValue":0,"referenceUnit":null}` and `"inventoryItem":{…,"measurement":{"weight":{"value":0.5,"unit":"KILOGRAMS"}}}`
- `SHOP:1075` — the REST counterpart, whole: `"grams":500,…,"weight":0.5,"weight_unit":"kg"`
- `SHOP:248` — `| TaxonomyMeasurementAttribute | id: ID! · name: String! · options: [Attribute!]! |`
- `SHOP:961` — *"Live: `attributes(first:250)` on the 44 categories returned by the two leaf queries yielded **383** attribute nodes, **383** of them `"__typename":"TaxonomyChoiceListAttribute"`"*
- `X:511` (claim S7-b) — *"`volume` is a shipped metafield type whose stored value is a JSON object `{"value": 20.0, "unit": "milliliters"}` … Plus: Liquid `measurement.md` shows a **three**-property shape `{"type":"volume","unit":"mL","value":"500.0"}` — string value, unit outside the Admin vocabulary."*
- `SHOP:321` — *"**Metafield data types: 48 basic + 12 reference + 53 list.** Header note, whole: *"When using the GraphQL Admin API to read and write metafields, the value is always entered and stored as a string, regardless of type."* · *"Metafields cannot be migrated to type id."*"*
- `MATRIX:367–369` — the taxonomy carries no net-content attribute: *"There is no net-content or size attribute anywhere in it | 300 of 8,240 definitions match size, volume, weight or capacity — and every one is category-specific (Bagel size, Battery size, Athletic cup size) | Our biggest axis, the 215 GR / 720 GR / 1.44 KG / 2.7 KG one, is not in the standard and would not be solved by adopting it. D9 stays ours either way."*

**Maps to: bare label, with the unit fixed elsewhere (on the variant) — never on the value.**
**Stated vendor rationale:** `SHOP:321` — *"the value is always entered and stored as a string, regardless of type."*

### Q4 · ORDERING → **options carry a `position`; option VALUES carry NO position field and are ordered by input array index.**

The fullest statement of the corrected claim is `X:492`, reproduced **whole**:

> `| **S7-c (Shopify)** `productOptionsReorder` exists — picker values are hand-ordered with a position, not derived from a stored quantity. | Substance stands; the downgrade was largely unearned. Narrow correction: option VALUES carry no `position` FIELD and are ordered by input array index, while options and variants do carry integer positions (`productVariantsBulkReorder`, never mentioned). Field absence is not model absence. Route defect: the two routes are one document. | `OptionReorderInput {id, name, values}`; `ProductVariantPositionInput.position: Int!` "The first position in the list is 1."; Shopify prose inside the verdict's own quote block: "The order of values within each option determines their new positions"; /latest/ and /2026-07/ are byte-identical 31,404 B files. | D9, D16 | detail-only |`

The truncated copies, for cross-reference:

- `SHOP:722` — *"| `S7-c` | **WRONG AS STATED** | The claim's substance stands and the verifier's downgrade was largely unearned. Confirmed: productOptionsReorder(productId: ID!, options: [OptionReorderInput!]!) exists, and ordering is never derived from a stored quantity — 0 numeric and 0 quantity/unit fields across the 15 fields of the 5 option-value types (4 numeric fields across all 11 option types, all named `position`, all at the OPTION level). The precise correction is narrower than 'WRONG': option VALUES carry no `position` FIELD and ar"* — the file's own cell truncates here (line length 548 bytes).
- `D:885` and `D:949` carry the same text, cut slightly earlier.
- `SHOP:765` — *"| **S7-c** | **NOT PRESENT** | 0 hits for `productOptionsReorder`, "hand-ordered", `productVariantsBulkReorder`; §1.3 already lists `ProductOptionValue` with 6 fields and no `position` | — | origin is #10966 D9, not this issue |"*

Supporting facts in `SHOP` itself:

- `SHOP:104` — `position Int! 2` on `ProductOption`
- `SHOP:349–351` — `├─ options[0] ProductOption "Pattern" position 1` · `├─ options[1] ProductOption "Width" position 2`
- `SHOP:379–380` — the `productSet` input carries `"position":1` / `"position":2` on the options and **no position on any value**
- `SHOP:416` — the option error enum includes `POSITION_OUT_OF_BOUNDS` and `OPTION_POSITION_MISSING` — both at the option level
- `SHOP:466` — `position` is listed among the 20 VARIANT-ONLY fields

**Maps to: insertion / input-array order for values; a stored position column for options and variants.**
**Stated vendor rationale:** `X:492` quotes Shopify's own prose — *"The order of values within each option determines their new positions"*.

### Q5 · VALUE IDENTITY / RENAME → **a `ProductOptionValue` has a GID; a linked value additionally points at a Metaobject GID. The taxonomy surface publishes no key or handle.**

- `SHOP:114–117` — `id ID! "gid://shopify/ProductOptionValue/1054677147"` · `name String! "Plain"` · `linkedMetafieldValue String "gid://shopify/Metaobject/971662499"`
- `SHOP:166–168` — the two published `selectedOptions` forms, one carrying the value id and one carrying only the string (quoted whole above)
- `SHOP:171–178` — on **input** the binding is `VariantOptionValueInput` — **all five fields nullable**: `id ID "Specifies the product option value by ID."` · `name String "Specifies the product option value by name."` · `linkedMetafieldValue String` · `optionId ID` · `optionName String`
- `SHOP:323` — *"❗ One reference type closes the loop between the two surfaces: **`product_taxonomy_value_reference`** — *"A reference to a product taxonomy value. You can add validations to limit which taxonomy values can be selected."*, sample `gid://shopify/TaxonomyValue/1`."*
- `SHOP:249` — `| TaxonomyValue | id: ID! · name: String! "For example, Red." |`
- `SHOP:251` — *"⚠️ 2026-09-05: re-introspected whole at `2025-10` and `2026-07` — **no `key`/`handle` on any member**; 383/383 attribute nodes `TaxonomyChoiceListAttribute`."*
- `SHOP:961` — *"**no `key` or `handle` field on any of the three members** (the vendor's taxonomy repo publishes a `handle` per attribute; the API does not)."*
- `SHOP:579` — *"⚠️ **The handle separator differs between routes**: `flavor__dulce_de_leche` in `data/`, `flavor__dulce-de-leche` in `dist/`."*
- `SHOP:266` — *"**Extended attributes are aliases** — no values of their own, only `values_from: <base friendly_id>`, and they **reuse the base attribute's GID**."*
- `SHOP:957` — error enum, whole, includes `CANNOT_SET_NAME_FOR_LINKED_OPTION_VALUE` — i.e. a linked value's display name is not settable by the caller.

**Maps to: YES on the option-value and metaobject surfaces (stable GID separate from `name`); AMBIGUOUS on the taxonomy surface.** Hedge quoted verbatim: `SHOP:251` — *"no `key`/`handle` on any member"*.
**Stated vendor rationale:** no stated rationale in the record for rename.

---

## 3. GOOGLE MERCHANT CENTER — `GOOG` (#11013)

### Q1 · VALUE SHAPE → **(c) hybrid between closed enums on the definition and free strings; never an FK.** Every value is a scalar written onto the product, and an axis value is written **twice**.

Section: `### 1.3 `ProductAttributes` — the attribute bag` (`GOOG` §1.3)

- `GOOG:141` — `| **typed attributes** | 145 named properties — `color`, `size`, `material`, `pattern`, `ageGroup`, `gender`, … | fixed by the schema; some are enums | [R-5] |`
- `GOOG:142` — `| **`ProductDetail`** | free-form `sectionName` + `attributeName` + `attributeValue` (140/140/1000 chars) | **open** — merchant names the key | [R-15] |`
- `GOOG:143` — `| **`CustomAttribute`** | free-form `name` + `value`, **max 2500 per product**, 10240 chars each, 102.4 kB total | **open** | [R-5] |`
- `GOOG:145` — `| ⚠️ 2026-09-02 **`VariantOption`** | `name` + `value`, 0..30 (§1.5) | **open** | [R-8][F-1] |`
- `GOOG:144` — `| ⚠️ 2026-09-02 **`CloudExportAdditionalProperties`** | `propertyName` + `textValue` / `boolValue` / `intValue` / `floatValue` / `minValue` / `maxValue` / `unitCode` — *"Extra fields to export to the Cloud Retail program."* | **open** — merchant names the key | [F-1] |`

Section: `### 1.5 `VariantOption` — the variant axis`

- `GOOG:198–199` — `name string Required, free text, max 250 chars "Memory size" · "shoe width"` / `value string Required, free text, max 250 chars "128 GB" · "narrow"`
- `GOOG:208–210` — the proto, verbatim: `// Required. The name of the variant. For example, "Color", "Memory", "Size", "Length"` / `string name = 1 [(google.api.field_behavior) = REQUIRED];` / `// Required. The value of the variant. For example, "Red", "128GB", "XL", "100cm"` / `string value = 2 [(google.api.field_behavior) = REQUIRED];`
- `GOOG:219–221` — `| Cardinality | **0..30** — *"Repeated field: Yes (up to 30)"* |` · `| Total size | max 5,000 characters |` · `| `name` domain | **open — no enumeration published in any artifact retrieved** |`
- `GOOG:225–226` — retrieved XML instances: `<g:variant_option><g:name>shoe width</g:name><g:value>narrow</g:value></g:variant_option>` · `<g:variant_option><g:name>size</g:name><g:value>8</g:value></g:variant_option>`

Section: `### Google's own worked family, reproduced whole`

- `GOOG:397` — *"❗ **The axis value is written twice** — once in the typed `[color]`/`[size]` attributes and once inside `[variant_option]`. Google documents both as required together, not as alternatives."*
- `GOOG:399` — *"⚠️ **Looser than the artifact:** nothing retrieved requires the two written values to be *equal*. Instrument: `same value|equal|must match|identical` over the extracted text of [R-8] → **0** hits; over [R-10] → 4 hits, all about `[item_group_id]`."*

Section: `## §2 · The variant mechanism, end to end`

- `GOOG:328` — `item_group_id "12345"   a shared STRING on sibling products`
- `GOOG:336` — *"**❗ There is no parent entity *in the feed or API*.** A variant family is *n* complete products sharing a string."*
- `GOOG:418` — *"❗ **A standalone and a variant differ by the presence of one string.** There is no role field, no container, and no schema difference"*

Live instance — section `### ⚠️ 2026-09-05 — instances retrieved from the live account (revision 5)`

- `GOOG:1089–1094` — `"variantOptions": [ { "name": "flavor", "value": "mango" } ]`
- `GOOG:1227` — *"a pair whose `name` is the nonsense token **`qzxjvwkmp`** … was accepted with HTTP 200 and echo == sent, persisted verbatim at +2 and +6 min … **So what is established is that the `name` sub-attribute stores arbitrary strings; the acceptance of `flavor` is not `flavor`-specific.**"*

**Maps to (c) — closed enum on the definition for 22 attributes, free string for everything else, never a shared row.**

**Stated vendor rationale:** none for value shape. `GOOG:604` / `GOOG:1348` (section `## Observations for the reader — questions, not findings`) — *"`Flavor` is documented at the `product_detail` layer and `color` at the attribute layer, and only the latter is named as a variant axis. **No artifact retrieved says why.**"*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) one global attribute bag.** The absence of any per-category schema is instrumented.

- `GOOG:131` — *"**❗ There is no per-category attribute schema.** The bag is **one global, ~~flat, strongly-typed~~ set**: **145** properties in Merchant API `products_v1`, **95** in `products_v1beta`, **104** on Content API v2.1 `Product`. The human specification documents **85** attributes"*
- `GOOG:135` — *"**Instrument for that absence:** there is no per-category schema *endpoint*, *file* or *field*. `products_v1`, 160,077 B, 51 schemas — a search for `categoryAttribute|category_attribute|attributesFor|productTypeDefinition|schemaFor` returns **0**; the discovery document exposes **no** operation that takes a category and returns a field set. … Compare: a system that *does* have one publishes a call for it."*
- `GOOG:314` (section `### 1.9 The two category axes, side by side`) — `| Value domain | closed — *"Use only a predefined Google product category."* | **none** |`
- `GOOG:791` (section `## A.11 · All 22 enumerated `ProductAttributes` properties — whole`) — *"`GET https://merchantapi.googleapis.com/$discovery/rest?version=products_v1`, re-fetched 2026-08-12, `stat -c%s` = **160,077 B**, `"revision": "20260811"`, HTTP 200 unauthenticated. `ProductAttributes` = **145** properties."*
- `GOOG:795–816` — all 22 direct enums reproduced whole (`ageGroup` 6, `amenityFeature` 35, `availability` 6, `bodyStyle` 32, `condition` 4, `emissionsStandard` 13, `energyEfficiencyClass` 11, `engine` 10, `excludedDestinations` 13, `gender` 4, `includedDestinations` 13, `maxEnergyEfficiencyClass` 11, `minEnergyEfficiencyClass` 11, `pause` 3, `pickupMethod` 5, `pickupSla` 9, `propertyType` 10, `sizeSystem` 12, `sizeTypes` 7, `specialtyHousingType` 7, `utilitiesIncluded` 6, `vehiclePriceType` 6)
- `GOOG:789` — *"**26 further enums live on referenced sub-schemas** (`Returns.windowType`, `RelatedProduct.relationshipType`, `ProductCertification.certificationName`, `CarrierShipping.carrierPrice` (62 values), and 22 others) and are **not** reproduced"*

**The variant axes themselves are NOT enumerated:**

- `GOOG:694` — `color` *"Max 100 alphanumeric chars (max 40 per color), multiple separated by `/`"*
- `GOOG:700` — `material` *"Max 200 chars"*
- `GOOG:704` — `pattern` *"Max 100 chars"*
- `GOOG:714` — `size` **Required** … *"Max 100 chars"* · `XL`
- Only `age_group` (`GOOG:690`) and `gender` (`GOOG:693`) are closed.

**The category gates requiredness, not existence — with one withdrawal:**

- `GOOG:181` — *"**❗ Category gates *requiredness*~~, never *existence*~~.** ~~Every attribute exists on every product; category only decides whether omitting it is an error.~~"*
- `GOOG:183` — *"⚠️ **2026-09-02 (G1-c) — the "never existence" half is withdrawn.** On [F-7] three rows carry an *availability*, not a requiredness, gate: `[size_type]` and `[size_system]` — each *"Optional (Available for apparel products only)"*; `[subscription_cost]` — *"Optional (available only for permitted categories)"*"*

**No closed set of axes is published:**

- `GOOG:243` (section `### 1.6 The "standard" six — and the fact that three different lists exist`) — *"**❓ But Google publishes ~~four~~ five (⚠️ 2026-09-02) different lists**, and no artifact states a closed set"*
- `GOOG:254` — *"**Counter-case search run on purpose:** … → **no artifact stating a closed set found.**"*
- `GOOG:482` — *"`variant_option.name` is free text ≤250 chars with no published enumeration, so `{name:"flavor", value:"Mi Goreng"}` is **not forbidden by any retrieved artifact** — and **not documented as supported by any either**."*

**Maps to (A).**

**Stated vendor rationale**, verbatim — `GOOG:465` (section `### Where flavour actually lives: a *suggested key name* in a free-form bag`):
> *"Note that this is not a comprehensive or exhaustive list. You are welcome to add additional properties when they are applicable to your products."*

And the suggested key list itself, `GOOG:460–462`: *"This attribute can also be used to submit salient products fact and features as key-value pairs, for example: **Shape** … **Occasion** … **Sport** … **Finish** … **Activity** … **Format** … **Theme** … **Scent**: Scents or fragrances of the product · **Flavor**: Flavors or taste of the product"*
`GOOG:467` — retrieved instance: `General:Ingredients:"Vitamin C, Vitamin D, Iron, Niacin, Citric acid, Natural fruit extract"`
`GOOG:482` / `GOOG:1223` — *"No artifact states that a `product_detail` key participates in variant grouping."*

### Q3 · QUANTITIES → **TEXT: "Value + unit" / "Number + unit" packed into one feed string.** A unit-pricing pair exists; there is **no** dedicated net-content field.

Section: `## A.2 · Price and availability (14)`

- `GOOG:661` — `| 17 | `[unit_pricing_measure]` | Optional (**except when required by local laws or regulations**) | Value + unit. Weight `oz lb mg g kg`; Volume US `floz pt qt gal`; Volume metric `ml cl l cbm`; Length `in ft yd cm m`; Area `sqft sqm`; Per unit `ct` | `1.5kg` |`
- `GOOG:662` — `| 18 | `[unit_pricing_base_measure]` | Optional (**except when required by local laws or regulations**) | Integer + unit; integers `1 10 100 2 4 8`; same unit set; plus `75cl 750ml 50kg 1000kg` | `100g` |`

Section: `## A.5 · Detailed product description (29) — contains every variant axis`

- `GOOG:707–709` — `[product_length]` / `[product_width]` / `[product_height]` — *"Number + unit"* — `20 in`
- `GOOG:711` — `[product_weight]` — *"Number + unit"* — `3.5 lb`
- `GOOG:714` — `[size]` **Required** — *"Max 100 chars"* — `XL` (a free label, not a number+unit)
- `GOOG:703` — `| 44 | `[multipack]` | **Required** (For multipack products in Australia, Brazil, Czechia, France, Germany, Italy, Japan, Netherlands, Spain, Switzerland, the UK and the US) … | Integer | `6` |`
- `GOOG:691` — `| 32 | `[is_bundle]` | **Required** (For bundles in Australia, Brazil, …) | `[yes]` / `[no]` | `yes` |`
- `GOOG:710` — `| 51 | `[product_highlight]` | Optional | Max 150 chars; *"Use between 2 and 100 product highlights."* | `Supports thousands of apps, including Netflix, YouTube, and HBO Max` |`

Section: `## A.9 · Shipping and returns (17)`

- `GOOG:757` — `| 74 | `[shipping_weight]` | Optional (**Required for carrier-calculated rates…**) · Supported 0–2000 lbs imperial, 0–1000 kgs metric | Number + unit: `lb oz g kg` | `3 kg` |`

Section: `## §1.4 · Requiredness` (Companion C)

- `GOOG:935` — *"the file's 15 `REQUIRED` lines are 14 annotations on sub-message fields (`QuestionAndAnswer`, `VariantOption`, `RelatedProduct`, `ProductDimension`, `ProductWeight`, `PickupCost`, `ProductMinimumOrderValue`)"* — the typed dimension/weight messages are named but never printed.

Apparel size typing:

- `GOOG:715` — `| 56 | `[size_type]` | Optional (**Available for apparel products only**) | `[regular]`, `[petite]`, `[maternity]`, `[big]`, `[tall]`, `[plus]` | `maternity` |`
- `GOOG:716` — `| 57 | `[size_system]` | Optional (**Available for apparel products only**) | `US UK EU DE FR JP CN IT BR MEX AU` | `US` |`
- `GOOG:812–813` — API-side: `| sizeSystem | 12 | SIZE_SYSTEM_UNSPECIFIED · AU · BR · CN · DE · EU · FR · IT · JP · MEX · UK · US |` · `| sizeTypes | 7 | SIZE_TYPE_UNSPECIFIED · REGULAR · PETITE · MATERNITY · BIG · TALL · PLUS |`
- `GOOG:161` — *"**❗ Same attributes, different types across API versions**: `size` is a scalar `string` in Merchant API but `sizes: array<string>` in Content API v2.1 — whose own description says *"Only one value is allowed."* `sizeType`, `sizeSystem`, `ageGroup` and `gender` are **enums** in Merchant API and **plain strings** in v2.1."*
- `GOOG:528` (contradiction 6) — `| **6** | **Is `size` one value or many?** | Merchant API `products_v1`: `size` scalar `string` | Content API v2.1: `sizes: array<string>`, description *"Only one value is allowed."* |`

**Dedicated net-content field: not addressed.** A whole-file search for `net content` / `netContent` / `package quantity` returns no such field; the only `quantity` hits are `sellOnGoogleQuantity` (`GOOG:592`, `GOOG:1481`).

**⚠️ Two sources disagree on whether Google has a D9 row at all:**
- `MATRIX:2178` — `No row1 | Google70 | No D9 row in the consolidated evidence. |`
- `X:805` — *"| **D9** | Covered **including Google** (Companion A row 17, `[unit_pricing_measure]`, gives value + unit with the full unit vocabulary) — even though #10966's own D9 paragraph names only three systems. |"*
Both are recorded; neither is preferred.

**Stated vendor rationale for quantities:** no stated rationale in the record.

### Q4 · ORDERING → **NOT ADDRESSED.**

A whole-file search of `GOOG` for `sort order` / `display order` / `order of value` / `alphabet` / `position` returns nothing on the subject (the only `rank` hit is `popularity_rank`, `GOOG:705`). The only order-adjacent facts are about *which submitted values survive truncation*, and they say the **head** of the list is dropped:

- `GOOG:942` (section `## §1.5 · `VariantOption` — the variant axis`, Companion C) — *"⚠️ 2026-09-05 **Over-cap behaviour** | The surplus options are dropped **from the head of the submitted list**: 31 submitted → the persisted 30 are `opt02`…`opt31`; 35 submitted → `opt06`…`opt35`."*
- `GOOG:984` (section `## §1.8 · `product_type` — the merchant's own axis`) — *"The values dropped are the **first-submitted** ones: 11 → `cp0905rev > Type 02` … `Type 11`; 20 → `Type 11` … `Type 20`. Google's cell is a submission instruction … *"Submit up to 5 times, but keep in mind that only the first value will be used to organize bidding and reporting in Google Ads Shopping campaigns."*"*

**Maps to: not addressed.**
**Stated vendor rationale:** the *"only the first value will be used to organize bidding and reporting"* clause at `GOOG:984` is the nearest vendor "why", and it is about Ads reporting, not picker order.

### Q5 · VALUE IDENTITY / RENAME → **no value id exists; the label IS the identity. Rename is not addressed.**

- `GOOG:53–55` — `offerId string Required, Immutable "SKU12345"` · `contentLanguage string Required, Immutable "en"` · `feedLabel string Required, Immutable "US"`
- `GOOG:66` — *"Identity is the triple **`contentLanguage ~ feedLabel ~ offerId`**. One feed row = one `ProductInput`."*
- `GOOG:382` (section `## §2`, sub-heading `**Case-insensitive IDs**, quoted whole`) — *"**Each distinct item group must have a unique value** for the item group ID `[item_group_id]` attribute. Don't rely on casing to make the item group ID unique. The values "abc123" and "ABC123" are interpreted as the same product. Don't reuse or recycle the same item group ID attribute for different products."*
- `GOOG:1277` (contradiction 14) — the same stored value re-formatted on Google's own second surface: *"`products.get`: … `"brand": "cp0905brandB"` — as sent | `reports_v1` `product_view` for the **same two** products: `gtin: ["08990000000051"]` — 14 digits — and `brand: "cp0905brandb"` — lower-cased"*

A whole-file search for `rename` returns **0 hits**.

**Maps to: no stable code separate from the label. Rename: not addressed.**
**Stated vendor rationale:** no stated rationale in the record.

---

## 4. eBAY — `EBAY` (#11045)

### Q1 · VALUE SHAPE → **(a) free STRING.** There is no identifier on an aspect or on an aspect value, measured on three routes with firing controls.

Section: `### 1.2 `Aspect` / `AspectConstraint` / `AspectValue` / `ValueConstraint` — the attribute model` (`EBAY:92`)

- `EBAY:96` — `Aspect { aspectConstraint, aspectValues, localizedAspectName, relevanceIndicator }   // 4`
- `EBAY:101` — `AspectValue { localizedValue, valueConstraints }                                // 2`
- `EBAY:102` — `ValueConstraint { applicableForLocalizedAspectName, applicableForLocalizedAspectValues } // 2`
- `EBAY:120` — `| `localizedValue` | string | 1..1 ⟨doc-site⟩ | `"Anachronism"` · ⚠️ live `"Pumpkin Spice"`, `"Adam Driver"` | [R-2] |`
- `EBAY:167` — *"**❗ There is no identifier on an aspect or an aspect value.** Instrument over the 5,003,334-byte unrendered Taxonomy doc page: `aspectId` → **0** · `valueId` → **0** · `aspectValueId` → **0** · `"id":` → **0**. **Control proving an id-shaped name would have matched**: on the same page `categoryId` → 16 and `errorId` → 4"*
- `EBAY:169` — *"⚠️ 2026-09-05 — **Third route, live, over 197,046 aspects and 15,111 categories**, `grep -o -F '<literal>' raw/39-decompressed.tmp.json | wc -l`: `"aspectId"` → **0** · `"valueId"` → **0** · `"aspectValueId"` → **0** · `"id":` → **0**. Controls in the same file: `"categoryId"` → **15,111** · `"localizedAspectName"` → **197,046**."*

Section: `### 1.3 `InventoryItem` / `Product` — the per-SKU record` (`EBAY:171`)

- `EBAY:181` — `| `product.aspects` | **declared `string`** | 0..1 | `{"Brand":["GoPro"],"Storage Type":["Removable"]}` | [R-3] |`
- `EBAY:191` — *"❗ **`aspects` is declared `string` and exemplified as an object of arrays** — both on `Product` and on `InventoryItemGroup`, in the contract, with no other keys. → §5 C4."*

Section: `### 1.5 `VariesBy` / `Specification` — the axis` (`EBAY:224`)

- `EBAY:228` — `Specification { name : string, values : string[] }                                     // exactly 2`
- `EBAY:236` — `| `Specification.values` | string[] | 1..N ⟨prose⟩, **Max Length: 50** | `["Green","Blue","Red","Black","White"]` | [R-3] |`

Section: `## §2c · ✅ Retrieved instance` (`EBAY:684`)

- `EBAY:721` — *"**10 values, each a bare string — no unit, no id, no quantity.** ⚠️ eBay's own caveat on this sample, verbatim: *"note that the category for this sample is a *test* category for example purposes only"*. This is the **single** aspect instance in the entire record, and it shows only `FREE_TEXT` / `SINGLE` / `true` — hence §4 U4."*
- `EBAY:714–718` — the values, whole: `Anachronism`, `Basket Ball`, `Battle Spirits`, `Bleach`, `Blood Wars`, `Cardfight Vangaurd`, `Soccer`, `Swimming`, `Tennis`, `Volley Ball`

Live retrieval (§ `### ⚠️ 2026-09-05 — Retrieved live (eBay Sandbox, `api.sandbox.ebay.com`, application token)`, `EBAY:740`)

- `EBAY:761` — `{"localizedAspectName":"Flavor","aspectConstraint":{"aspectDataType":"STRING","itemToAspectCardinality":"MULTI","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"OPTIONAL","aspectEnabledForVariations":true,"aspectApplicableTo":["PRODUCT"]},"aspectValues":[{"localizedValue":"Almond"},{"localizedValue":"Amaretto"},{"localizedValue":"Bourbon"},{"localizedValue":"Caramel"},{"localizedValue":"Chestnut"},{"localizedValue":"Chocolate"},{"localizedValue":"Cinnamon"},{"localizedValue":"Coconut"},{"localizedValue":"Hazelnut"},{"localizedValue":"Pecan"},{"localizedValue":"Pumpkin Spice"},{"localizedValue":"Vanilla"}]}`

Cross-platform: `X:1043` — *"⚠️ 2026-09-05 live (sandbox): every `aspectValues[]` entry captured is `{"localizedValue":"<string>"}` with no unit, quantity or id — including on typed aspects, e.g. `"20210101"` on a `DATE` / `YYYYMMDD` aspect. … No identifier on an aspect or a value on the live route either: `"aspectId"` / `"valueId"` / `"id":` → 0 over 867 MB, control `"categoryId"` → 15,111."*

**Maps to (a).**

**Stated vendor rationale:** none on value shape. The nearest vendor "why" is the catalog-inheritance rule — `EBAY:189`: *"**✅ The catalog product fixes values of a subset of aspects.** Verbatim, `Product.aspects`: *"If a match is found based on the ePID or GTIN value, **the product aspects that are defined for the eBay Catalog product will automatically get picked up by the newly created/updated inventory item.**"*"*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(B) on the category, with a per-aspect open/closed switch.**

Section: `## §3 · The flavour test` (`EBAY:276`)

- `EBAY:319` — *"**✅ Nothing about the product decides it. The leaf category decides it, alone**: *"Each category has a different set of aspects and different requirements for aspect values."* There is no product type, no schema selector, and no attribute registry independent of the category — the aspect list is a function of `(category_tree_id, category_id, marketplace)` and is read by exactly one call, `getItemAspectsForCategory`."*
- `EBAY:323` — *"**✅ Whether its values are open or closed is decided by a third bit on the same aspect** — `aspectMode : FREE_TEXT | SELECTION_ONLY`, *"The manner in which values of this aspect must be specified by the seller (as free text or by selecting from available options)."* Corroborated behaviourally on a separately authored artifact: *"**Most categories support free-text names and values in item specifics and in variations. However, some categories require certain item specifics (e.g., Brand), and some item specifics (e.g., Color,) may require you to select a value from a predefined set.**"*"*

Population: `EBAY:357` (§4 row U12-c) — *"197,046 aspects; **`aspectValues` 145,148**; `aspectApplicableTo` 106,766; `aspectMaxLength` 15,629; `aspectFormat` 345; `aspectAdvancedDataType` 25; `expectedRequiredByDate` 6"* — i.e. **~52,000 aspects carry no value list at all**.

`MATRIX:638` — *"Example: Athletic Shoes (15709) has 37 aspects — US Shoe Size (required, 37 values), UK Shoe Size, EU Shoe Size (60 values), Brand (3,463 values), Color, Silhouette, Style Code, California Prop 65 Warning. The record: "Nothing about the product decides it. The leaf category decides it, alone" (§3)."*

**Maps to (B).**

**Stated vendor rationale**, verbatim — `EBAY:135`:
> *"This field is always returned, even for hard-mandated/required aspects (where `aspectRequired`: `true`). The value returned for required aspects will be `RECOMMENDED`, but they are actually required and a seller will be blocked from listing or revising an item without these aspects."*

And `EBAY:161` — `AspectUsageEnum`, whole: *"RECOMMENDED This enumeration value is returned if the corresponding aspect is either required ( aspectRequired : true ) or recommended for the listing category. If a recommended aspect is not hard-mandated/required ( aspectRequired : false ), it is still highly recommended that the seller pass in the aspect name/value pair(s) if the aspect information is applicable and known…"*

### Q3 · QUANTITIES → **text by default; a typed-but-unitless `NUMBER` / `NUMERIC_RANGE` exists; NO unit on any value and NO net-content field.**

- `EBAY:114` — `| `aspectDataType` | `AspectDataTypeEnum` | 1..1 | `"STRING"` · ⚠️ live `"NUMBER"`, `"DATE"`; bulk `STRING` 196,549 / `NUMBER` 482 / `DATE` 15 / `STRING_ARRAY` **0** |`
- `EBAY:115` — `| `aspectAdvancedDataType` | `AspectAdvancedDataTypeEnum` | 0..1 | ⚠️ 2026-09-05 live: `"NUMERIC_RANGE"` on `Device Charging Range` (9355); present on **25 of 197,046** bulk aspects, all `NUMERIC_RANGE` |`
- `EBAY:117` — `| `aspectFormat` | string | 0..1 | bulk `int32` 229 / `double` 101 / `YYYYMMDD` 12 / `YYYY` 3, present on 345 of 197,046 |`
- `EBAY:147` — `| `AspectAdvancedDataTypeEnum` | 1 | `NUMERIC_RANGE`. ✅ Corroborated **without** the enum, in the contract itself: *"For example, `NUMERIC_RANGE` indicates that the aspect value must be in numeric range format.<br><br>Note: Currently only `NUMERIC_RANGE` is supported."* |`
- `EBAY:146` — `| `AspectDataTypeEnum` | 4 | `DATE` · `NUMBER` *"…is a a numeric value"* (the doubled "a a" is eBay's typo, reproduced) · `STRING` · `STRING_ARRAY` *"reserved for internal or future use"* |`
- `EBAY:773` — a live instance with an advanced type and **no** values: `{"localizedAspectName":"Device Charging Range","aspectConstraint":{"aspectDataType":"STRING","itemToAspectCardinality":"SINGLE","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"RECOMMENDED","aspectEnabledForVariations":true,"aspectApplicableTo":["PRODUCT"],"aspectAdvancedDataType":"NUMERIC_RANGE"}}`
- `EBAY:187` — *"**✅ Exactly 12 properties, re-enumerated from the contract.** **None is a unit, quantity or measure field.**"*
- `EBAY:590` — the size-family aspect-name census: `Size` 1,898 · `Size Type` 209 · `Serving Size` 110 · `Waist Size` 80 · `Chest Size` 62 · … · `US Size` 36 · `US Shoe Size` 34 · `EU Shoe Size` 34 · `UK Shoe Size` 33

**No dedicated net-content field.** A whole-file search for `unit|measure|net content|gram` returns only the `EBAY:187` negative, page chrome, and the size-name census.

**Maps to: text, with a per-aspect type hint on the constraint, no unit stored anywhere.**
**Stated vendor rationale:** the `NUMERIC_RANGE` sentence at `EBAY:147` is the only vendor statement, and it is a format rule, not a rationale. Otherwise: no stated rationale in the record.

### Q4 · ORDERING → **AMBIGUOUS.**

The only order statement in the record:

- `EBAY:238` (section `### 1.5 `VariesBy` / `Specification` — the axis`) — *"**✅ The axis is a child container, not an entity.** Verbatim, `Specification`: *"This type is used to specify product aspects for which variations within an inventory item group vary, **and the order in which they appear in the listing**."*"*

That is the seller-supplied array order of the **axes** in the listing, not the picker's order of a value list. Supporting observations:

- `EBAY:306` — *"The `aspectValues` lists (`localizedValue` sequences) for the six names are identical on the two operations: `aspectValues lists (localizedValue sequence) differing between operations for the six names: []`."*
- `EBAY:911` (C16) — *"**`getItemAspectsForCategory` and `fetchItemAspects` disagree on `aspectUsage`.** … **no other key differs** and the value lists are identical. … `aspects[]` order differs in 15 of 16 categories."*
- `EBAY:1142` (U10, closed) — *"16 categories both ways: 33 of 421 aspects differ, all on `aspectUsage`; no other key; **value lists identical**; `aspects[]` order differs in 15 of 16."*

Retrieved value sequences are **not** uniformly sorted — recorded as observation of the payloads rather than as a record statement:
`EBAY:761` `Flavor` = alphabetical · `EBAY:822` `Size` = `"2XS","XS","S","M","L"…` (size order) · `EBAY:834` `US Shoe Size` = `"2","2.5","3","3.5"…` (numeric ascending) · `EBAY:791` `Begin Date of Travel` = `"20210101","20200101","20190101"…` (**descending**).

**Maps to AMBIGUOUS.** Hedge quoted verbatim: `EBAY:238` — *"and the order in which they appear in the listing"*.
**Stated vendor rationale:** no stated rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **NO stable id at all; the label is the identity; and eBay rewrites labels server-side.**

- `EBAY:167`, `EBAY:169` — the three-route zero (quoted whole above)
- `EBAY:216` (section `### 1.4 `InventoryItemGroup` — the variant family container`) — *"**✅ Exactly 9 properties.** ✅ **`variantSKUs`'s 1..N lower bound survives the requiredness correction** … ⇒ `InventoryItemGroup --1..N--> InventoryItem`, **by SKU string, not by an eBay id**."*
- `EBAY:590` — Trading release **1455 · 2026-June-04**: *"…(warning) 21920466 : The product aspects for this category no longer support custom replaceable_value. **We updated your custom replaceable_value value to our standard replaceable_value value and saved your listing. Buyers will see the updated replaceable_value value.**"*

**Maps to: NO stable code/id separate from the label.** A rename is indistinguishable from a different value; eBay's own migration path is server-side value rewriting, not an id-preserving rename.
**Stated vendor rationale:** the 21920466 warning at `EBAY:590` states the behaviour but not a rationale.

### eBay — the requested deep dive, and TWO PREMISES IN THE BRIEF THAT THE RECORD OVERTURNS

**`aspectMode` (FREE_TEXT / SELECTION_ONLY)**

- `EBAY:109` — `| `aspectMode` | `AspectModeEnum` | 1..1 | `"FREE_TEXT"` · ⚠️ live `"SELECTION_ONLY"` on `EC Range`; bulk `FREE_TEXT` **156,337** / `SELECTION_ONLY` **40,709** |`
- `EBAY:129` — *"`aspectMode` — *"The manner in which values of this aspect must be specified by the seller (as free text or by selecting from available options)."*"*
- `EBAY:145` — `| `AspectModeEnum` | 2 | `FREE_TEXT` *"the seller can either select from a set of provided values, or manually enter a new value."* · `SELECTION_ONLY` *"the seller must select from a set of provided values."* |`
- `EBAY:157` — the archived vendor table, verbatim, with the enum: `["FREE_TEXT","SELECTION_ONLY"]`, stamped 2025-11-15 02:16:33 GMT
- Live `SELECTION_ONLY` instances — `EBAY:767`: `{"localizedAspectName":"EC Range",…,"aspectMode":"SELECTION_ONLY",…,"aspectValues":[{"localizedValue":"A - G"}]}` · `EBAY:828`: `{"localizedAspectName":"Size Type",…,"aspectMode":"SELECTION_ONLY","aspectRequired":true,…,"aspectValues":[{"localizedValue":"Regular"},{"localizedValue":"Big & Tall"}]}`
- **The canonical axis is NOT SELECTION_ONLY** — `EBAY:590`: *"Whole-tree census: aspects named exactly `Size` → `FREE_TEXT` **1,895** / `SELECTION_ONLY` **3** (the 3: `Health & Beauty(26395) > Health Care(67588) > Personal Hygiene(260745) > Protective Gloves(260747)`, `Business & Industrial(12576) > Office(25298) > Office Equipment(50203) > Electronic Dictionaries & Translators(94861)`, `… > Dictation & Stenography(62034) > Dictaphones & Voice Recorders(62042)`); `US Shoe Size` → `FREE_TEXT` 34 / `SELECTION_ONLY` 0"*
- **And a live contradiction about that** — `EBAY:913` (C17): *"**`Size` is `FREE_TEXT` in Taxonomy while Trading publishes a blocking error for non-listed `Size` values.** … (b) Trading release notes, 1477, 2026-August-24: *"(error) 21920468 : Long error: replaceable_value is not a valid value for Size. Select a value from the available options. …"* (c) The blog: *"We'll also remove the ability to input custom values on new listings"*. The sandbox tree is synthetic; the production tree was not fetched; the blog names neither Taxonomy nor `aspectMode`. **Recorded, not resolved.** → §4 U16-b."*
- `EBAY:24` — *"⚠️ **Revision 1 missed a change inside its own collection window.** Trading release **1477, 2026-08-24** — eight days before collection — added blocking error **21920468**, closing the value set on `Size`, the canonical variation axis. The row was already inside revision 1's own artifact and appears **0 times** in the 115,448-byte revision-1 record."*

**`aspectValues`** — `EBAY:96`, `EBAY:101`, `EBAY:120`, `EBAY:121`, `EBAY:357`, `EBAY:761`, `EBAY:714–718` (all quoted above). Value-to-value constraints are live — `EBAY:121`: *"⚠️ 2026-09-05 live: `{"localizedValue":"Adam Driver","valueConstraints":[{"applicableForLocalizedAspectName":"Signed","applicableForLocalizedAspectValues":["Yes"]}]}` [600 constrained values in that response]; **every one of the 81 `Size` values on T-Shirts(15687) carries a `valueConstraints` on `Size Type`**; bulk `valueConstraints` **429,323** occurrences."*

**⚠️ PREMISE 1 OVERTURNED — eBay does not carry "six orthogonal per-aspect flags"; it carries ELEVEN.**

- `EBAY:97–100` — `AspectConstraint { aspectApplicableTo, aspectDataType, aspectEnabledForVariations, aspectFormat, aspectMaxLength, aspectMode, aspectRequired, aspectUsage, expectedRequiredByDate, itemToAspectCardinality, aspectAdvancedDataType }   // 11`
- `EBAY:126` — *"**✅ `AspectConstraint` has exactly 11 properties** — confirming revision 1's anchor count on an independent, machine-readable route. **The brief's guessed list of 6 is incomplete.**"*
- `EBAY:169` — *"The 11 `AspectConstraint` keys seen live are exactly the contract's 11 (§4 U12); no twelfth key appears in any of the 16 per-category responses."*
- Distributions, all bulk over 197,046 aspects: `EBAY:110` `aspectEnabledForVariations` true **73,833** / false **123,213** · `EBAY:111` `aspectRequired` true **13,094** / false **183,952** · `EBAY:112` `aspectUsage` OPTIONAL **136,195** / RECOMMENDED **60,851** · `EBAY:113` `itemToAspectCardinality` SINGLE **168,553** / MULTI **28,493** · `EBAY:116` `aspectApplicableTo` `["PRODUCT"]` **87,560** / `["ITEM"]` **19,206** · `EBAY:118` `aspectMaxLength` on **15,629** · `EBAY:119` `expectedRequiredByDate` on **6**
- The four that carry the model, verbatim — `EBAY:128–131`: `aspectEnabledForVariations` *"A value of `true` indicates that this aspect can be used to help identify item variations."* · `aspectMode` (above) · `aspectRequired` *"A value of `true` indicates that this aspect is required when offering items in the specified category."* · `itemToAspectCardinality` *"Indicates whether this aspect can accept single or multiple values for items in the specified category. Note: Up to 30 values can be supplied for aspects that accept multiple values."*
- `EBAY:137` — *"**❗ `aspectMaxLength` is scoped**: *"The maximum length of the item/instance aspect's value… **This field is only returned for instance aspects.**"*"*
- `EBAY:133` — *"⚠️ **`aspectApplicableTo`'s quote, corrected** — revision 1 dropped three words inside quotation marks. The vendor's full sentence: *"This value indicate if the aspect identified by the `<b>aspects.localizedAspectName</b>` field is a product aspect (relevant to catalog products in the category) or an item/instance aspect, **which is an aspect** whose value will vary based on a particular instance of the product."* (The `"This value indicate"` grammar error is eBay's, reproduced.)"*
- `EBAY:150` — `| `AspectApplicableToEnum` | 2 | `ITEM` · `PRODUCT` — *"**Sellers cannot change the value of aspects that are based on a catalog product.**"* |`

> **Consequence for #10778 V2.** `PRIOR:130` states *"eBay carries six orthogonal per-aspect flags."* The eBay reference record supersedes that with **eleven**, measured on two routes plus live. V2's *substance* — that eBay ships a per-aspect, per-category free/closed switch — is confirmed at `EBAY:109`, `EBAY:129`, `EBAY:145`, `EBAY:157`.

**⚠️ PREMISE 2 OVERTURNED — "value recommendations derived from recent listings" is NOT in the eBay record at all.**

A whole-file search of `EBAY` for `recently|recent listings|last [0-9]+ days|recommendation|suggested|derive|provided values|recommended value|value recommend|from listings|seller.supplied|custom value` finds **no statement that eBay's `aspectValues` are derived from recent listings**. The only "recommendation" semantics the record carries are (i) `aspectUsage: RECOMMENDED` (a requiredness tier, `EBAY:112`, `EBAY:135`, `EBAY:161`) and (ii) a *buyer-demand* counter that is access-gated and empty:

- `EBAY:122` — `| `searchCount` | integer | 0..1 | access-gated · ⚠️ 2026-09-05 live: `relevanceIndicator` on **0 of 197,046** bulk and 0 of 421 per-category aspects. … Contract, `Aspect.properties.relevanceIndicator.description`: *"The relevance of this aspect. This field is returned if eBay has data on how many searches have been performed for listings in the category using this item aspect. Note: This container is restricted to applications that have been granted permission to access this feature. You must submit an App Check ticket to request this access. In the App Check form, add a note to the Application Title/Summary and/or Application Details fields that you want access to 'Buyer Demand Data' in the Taxonomy API."* |`

That is search-demand data about the **aspect**, not value recommendations from listings.

> **Consequence for #10778 V6.** `PRIOR:132` quotes eBay as deriving value recommendations *"based on the number of recent listings and/or recently sold listings in the same category"* and as *"converting categories **from** curated **to** derived."* **Neither clause is corroborated by the eBay reference record.** Flagged as uncorroborated, not refuted — the record's own scope note is that the Taxonomy contract is the corpus, and the quoted sentence may live in a Seller-Centre page outside it.

**Enum-completeness caveat, which bears on treating any of these as closed lists**

- `EBAY:139` — *"⚠️ **The six enum value sets are single-route and their completeness is an assertion, not a measurement.** Instrument: the Taxonomy contract carries **0 `enum` keys** and **0** occurrences of `FREE_TEXT`, `SELECTION_ONLY`, `STRING_ARRAY`, `MULTI`, `SINGLE`, `ITEM`, `PRODUCT`, `OPTIONAL`. **Control proving a contract *can* carry such a list**: the Browse contract publishes `ValueTypeEnum`'s values in prose inside the field description — *"**Valid Values:** STRING - Indicates the value returned is a string. STRING_ARRAY - Indicates the value returned is an array of strings. **Code so that your app gracefully handles any future changes to this list.**"* The route would have shown them had eBay put them there. **eBay's own closing sentence there is the warning against treating any of these as closed.**"*
- `EBAY:22` — *"❗ **Six Taxonomy enums were printed as "reproduced WHOLE" with no enumeration instrument.** … Demoted to single-route. → §1.2, §4 U11."*
- `EBAY:153` — *"⚠️ 2026-09-05 — **The same seven value sets on two new routes** … **Route B, the vendor's own type pages as archived** by `web.archive.org` … each page carries the rendered table **and** an embedded JSON object with an `"enum":[…]` array, e.g. `"enum":["FREE_TEXT","SELECTION_ONLY"],"enumDescriptions":[…],"id":"txn:AspectModeEnum"`."*

**Values-per-axis caps** — section `### 1.10 The hard caps` (`EBAY:530`)

- `EBAY:540` — `| Values per axis | **30** | *"Each variation detail may then specify **up to 30 unique values**."* Corroborated: *"Note: **Up to 30 values can be supplied for aspects that accept multiple values.**"* |`
- `EBAY:541` — `| Values per axis (consumer property) | **50** | *"Each of those details can have **up to 50 values**: 50 different colours, 50 different sizes, and so forth."* → §5 C15 |`
- `EBAY:549` — `| Aspect name / value length | **40 / 50** | ⚠️ eBay's bytes are `<strong>Max Length for Aspect Name</strong>: 40<br><br><strong>Max Length for Aspect Value</strong>: 50`…`
- `EBAY:905` (C15) — *"**Values per axis: 30 vs 50, on two different eBay properties.** … Instrument, **with the corpus stated**: `\b50\b` → **0** in the 28,992-byte extracted text of [R-8]; **8** in the raw 103,257-byte file, all eight SVG path coordinates in the eBay logo."*
- `EBAY:518` — *"C15's two published values-per-axis figures are **30** and **50** — the sample's `60` is neither"*

---

## 5. WALMART MARKETPLACE — `WMT` (#11046)

### Q1 · VALUE SHAPE → **(c) hybrid, declared PER SLOT by a four-way `description` prefix — but in every shape the value is written inline per item, with no ids anywhere.**

Section: `### 1.3 The attribute slot — how a value is governed` (`WMT:125`)

- `WMT:125` — *"Every attribute is written out in full at every product type; **nothing is referenced**. The value shape is announced by the `description` **prefix**, the vendor's own four-way vocabulary"*
- `WMT:129` — `| `"Closed List - …"` | carries an `enum` | `Toothpastes.form` (7 values) |`
- `WMT:130` — `| `"Alphanumeric, N characters - …"` | string + `minLength`/`maxLength`, no enum | `Toothpastes.flavor` (1..600) · `Toothpastes.size` (1..500) |`
- `WMT:131` — `| `"Number, Value range: A to B - …"` | `type: integer` + min/max | `Toothpastes.count` (0…99999999999999) |`
- `WMT:132` — `| `"Decimal, Value range: A to B - …"` | `type: number` + `multipleOf` **or** `type: object` `{unit, measure}` where only `measure` is the decimal | `Tires.tireWidth` |`
- `WMT:162` — *"**The 6,576 names are written out 383,947 times**: 1,767 have >1 distinct definition, 4,809 exactly one; `color` **126** distinct definitions, `size` **438**, `flavor` **50**, `condition` **68**."*

Section: `## §2 · The variant mechanism, end to end`

- `WMT:373` — *"**✅ The axis is an attribute NAME carried as a string in an array on each member — not an object, and it has no identifier.** Case-sensitive `grep -o` over all 451,013,258 B: `valueId` **0** · `attributeId` **0** · `"$ref"` **0** · `"$id"` **0** · `"definitions"` **0** · `x-walmart` **0** · `groupingAttributes` **0**. **The name string is the only handle.**"*
- `WMT:374` — *"**✅ The axis value is copied per item; there is no shared value row** — written inline on each member (`"flavor":"Peppermint"` / `"Spearmint"`, both carrying the literal `"variantGroupId":"001960968586AX6"`), and the schema **repeats definitions rather than referencing them** (383,947 slots for 6,576 names). ⚠️ **Scope correction:** that is about the **feed** schemas only. The read-side OpenAPI document *does* use references — `"$ref"` occurs **2** times, both `#/components/schemas/VariantGroupInfo`. … **The read side returns values, never ids.**"*

Section: `## §2b · Product vs variant — the field split`

- `WMT:405` — *"**❗ Nothing is inherited, because there is nothing to inherit from.** Shared values are shared by **repetition**, not reference: `variantGroupId` is a `string` copied into each item, and the two "must be the same" rules are prose obligations on the seller, not schema constructs — nothing in the 451 MB file binds one item's value to another's."*

Section: `## §2c · ✅ Retrieved instance`

- `WMT:417–419` — `"Visible": { "Toothpastes": { "productName": "Colgate Crest Toothpaste", "flavor": "Peppermint", "variantGroupId": "001960968586AX6", "isPrimaryVariant": "Yes", "variantAttributeNames": [ "flavor" ] } } },`

The flavour slot whole — section `### ✅ What determines it: the product type — and Walmart's own worked variant example is a flavour example on a non-food type`

- `WMT:472` — `{"title":"Flavor","type":"string","description":"Alphanumeric, 600 characters - The distinctive taste or flavor of the item, as provided by manufacturer.  Example: Bubblegum;Mint;Wintergreen","examples":["Bubblegum","Mint","Wintergreen"],"comments":"@group=Required for the item to be visible on Walmart website","minLength":1,"maxLength":600}`
- `WMT:474` — *"**the value list is open on this type** — free text, `minLength`/`maxLength`, **no `enum`**."*
- `WMT:510` — *"⚠️ 2026-09-05: ~~*"Whether **any** product type governs `flavor` as a `Closed List` is **not measured**…"*~~ — measured … **On none of the 6,967 product types of the recommended `MP_ITEM` build.** All **385** declarations are free text"*
- `WMT:482` — *"⚠️ 2026-09-05, measured — types declaring `flavor` ~~(*"lower bound … **≥ 50**"*)~~. The 50 distinct definitions sum to 385; **0** contain `"enum"` and **0** contain `"items"`"*

**Maps to (c) by declaration, (a) in storage — every shape is written inline, never referenced.**

**Stated vendor rationale:** the read side's own gloss — `WMT:295` (section `### 1.7 `variantGroupInfo` — the read-side per-item variant object`): *"An array of `name`/`value` pairs that represent the item's variant attributes (for example, `color: Blue` or `size: M`)"* · *"Attribute name/value pairs (for example, `color` and `size`) that define the item's variation within the group."* · *"groupingAttributes | Lists the attribute values that differentiate the variant"* — with the defect noted at `WMT:294`: *"**❗ `groupingAttributes.name`'s description is a copy-paste error** — *"Returns true if the item is a primary variant"*, the sibling `isPrimary`'s description."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(B) on the category (Walmart's "product type").** Every attribute and every allowed-value list is re-declared in full at each of 6,967 types; nothing is shared or referenced.

Section: `### 1.2 `Visible` and `<ProductType>` — the attribute-owning object` (`WMT:88`)

- `WMT:88` — *"**The attribute-owning object is the product type** (vendor spelling "product type" / "Product Type"; **PT** in the vendor's own workbook). In the payload it is the single key inside `Visible`."*
- `WMT:92–93` — `oneOf                 6,967 branches, each {"type":"object","required":["<Product Type Name>"]}` · `properties            6,967 keys, one per product type`
- `WMT:105–106` — `| attribute slots summed over all types | **383,947** |` · `| distinct attribute names | **6,576** |`
- `WMT:112` — *"**✅ Product → product type is exactly 1..1, enforced structurally** by `oneOf` plus `additionalProperties: false`."*

Per-type axis lists — section `### 1.4 The four variant fields`

- `WMT:172` — `<ProductType>.variantAttributeNames  array<per-PT enum>  0..1, minItems 1, NO maxItems`
- `WMT:191` — the slot whole: `{"$schema":"http://json-schema.org/draft-07/schema#","title":"Variant Attribute Names","type":"array","description":"Closed List - The designated attribute by which an item is varying.","comments":"@group=Recommended to create a variant experience on Walmart website","items":{"type":"string","description":"Closed List - The designated attribute by which an item is varying.","enum":[ … per-product-type list … ]},"minItems":1}`
- `WMT:200–202` — `| distinct axis names across all types | **2,323** |` · `| enum size min / max / mean | **1 / 2,323 / 11.7548** |` · `| types at enum size 1 · types whose enum equals the full union | **8** · **8** |`
- `WMT:206` — *"❗ **Eight types carry an enum set-equal to the full 2,323-name union, i.e. constrain nothing**: `Decorative Trays`, `Gut Health Tests`, `Hormone Tests`, `Infectious Disease Tests`, `Padel Balls`, `Padel Racquets`, `Sexual Health Tests`, `Splash Pads`. **`Splash Pads` has 52 attributes and 2,323 permitted axis names.**"*
- `WMT:217` — *"**Contrast between two types' axis lists**: `Toothpastes` allows 9 — `["character","character_group","count","countPerPack","flavor","form","multipackQuantity","pieceCount","size"]`; `Tires` allows 18; they intersect only in `count`, `countPerPack`, `multipackQuantity`."*
- `WMT:981` — PT `Cat Toys`, whole enum: `"variantAttributeNames":{"items":{"enum":["animalLifestage","color","count","countPerPack","flavor","multipackQuantity","pattern","pieceCount","scent","shape","sizeDescriptor","sportsLeague","sportsTeam","theme"]}}`
- `WMT:351` — enum volume across the build: *"`enum` **205,116**"*, with controls `minItems` 122,422 · `contains` 2,213 · `if` 47,337 · `then` 47,337 · `comments` 383,970 · `required` 159,560

**A caveat the record files against itself** — section `## §5 · Contradictions …`

- `WMT:565` (#3) — `| **3** | Axis names that are not attributes of their own type | *"The specified attribute must also exist in the item's `Visible` section."* / *"If a variant attribute is not present in the `Visible` section, the submission fails."* | **280 types list 18,737 such names** … `Gut Health Tests` 2,285 of them |`

**Maps to (B).**

**Stated vendor rationale — four, verbatim:**

- `WMT:113` — *"In the Visible object, the seller must define the product type being set up. Based on the product type selected, the seller will complete the relevant attributes as identified in the feed file schema provided. **Based on the chosen Product Type, attribute requirements, values, and recommendations will vary.**"*
- `WMT:114` — `Visible."definition"`: *"This section of the item setup schema contains the Product Types that can be selected for Item Setup, and all of the relevant attributes that are required to setup the item in that Product Type."*
- `WMT:218` — *"You can't create custom variant attribute names. You must select an option from the dropdown."* · *"You can't create custom variant attributes. **Choosing the correct product type is important because variant attribute names are populated based on the product type of the items in the group.**"*
- `WMT:553` (Walmart CA, §4 row U28) — *"For version 3 of the Full Item Spec, select an option from the dropdown for the Variant Attribute Names. **Each category will have different options in this dropdown. You are not allowed to select any other options for Variant Attribute Names. If your desired Variant Attribute Name is not in this list, then you should not set up this item in a variant group.**"*

### Q3 · QUANTITIES → **all three shapes coexist, and Walmart is the one platform in the set with a DEDICATED, TYPED NET-CONTENT FIELD.**

Section: `### 1.3 The attribute slot — how a value is governed` (`WMT:125`)

- `WMT:134` — heading of the block: *"**Typed quantity + unit object, whole** — *including* the `comments` key revision 1 dropped from every quote"*
- `WMT:136` — **`netContent`, whole**: `{"$schema":"http://json-schema.org/draft-07/schema#","title":"Net Content","type":"object","description":"The quantity (or quantities) of the product contained in the package along with its unit of measure typically printed on the label for the country or market where the product is sold. …","comments":"@group=Required for the item to be visible on Walmart website","properties":{"productNetContentUnit":{"title":"Unit","type":"string","description":"Closed List - The unit of weight or volume on the item packaging. …","enum":["Case","Centiliter","Centimeter","Count","Cubic Foot","Each","Fluid Ounces","Foot","Gallon","Gram","Inch","Kilogram","Liter","Meter","Milliliter","Ounce","Pallet/Unit Load","Pint","Pound","Quart","Quart Dry","Square Foot","Yard"]},"productNetContentMeasure":{"title":"Measure","type":"number","description":"Decimal, Value range: 0 to 99999999999999 …","examples":["1","12","32"],"minimum":0,"maximum":99999999999999,"multipleOf":0.001}},"required":["productNetContentUnit","productNetContentMeasure"],"additionalProperties":false}`
- `WMT:120` — and it is in `Toothpastes`' required list: `"required": ["productName","brand","condition","shortDescription","keyFeatures","mainImageUrl","isProp65WarningRequired","ageGroup","flavor","has_written_warranty","labelImage","netContent"]`
- `WMT:140–141` — **two axis-eligible `{unit, measure}` objects**: `"tireWidth": {"type":"object","properties":{"unit":{"enum":["mm","in"]},"measure":{"type":"number","minimum":0,"maximum":99999,"multipleOf":0.01}},"required":["unit","measure"],"additionalProperties":false}` and `"wheelDiameter": {…"unit":{"enum":["mm","in","cm"]},"measure":{…"maximum":9999,"multipleOf":0.01}…}`
- `WMT:143` — *"❗ **A vendor defect inside both:** the `unit` sub-property carries an `examples` array of **measures** — `"2.5","2.75",…,"710"` on `tireWidth`, `"22","23",…,"21"` on `wheelDiameter` — beside its own unit enum; they belong to the sibling `measure`. §5 #20."*
- `WMT:144` — **`size`, a quantity and a unit as free text in one string, and a permitted axis**: *"`{"title":"Size","type":"string","description":"Alphanumeric, 500 characters - Overall dimensions of an item. Used only for products that do not already have a more specific attribute, such as ring size, clothing size, and bottled pen ink. Example: 5 oz;250 g;12 fl oz; 10 oz","examples":["5 oz","250 g","12 fl oz","10 oz"],"comments":"@group=Recommended to improve search and browse on Walmart website","minLength":1,"maxLength":500}`"*

Section: `### Counts measured, with the counter-cases` → `**Counter-case 1 — a product type with 18 permitted axes and no flavour among them.**`

- `WMT:495` — `| free text | `color`, `modelNumber`, `tireSidewallStyle`, `tireSize`, and `productLine` (array of unconstrained strings) | **5** |`
- `WMT:497` — `| integer | `count`, `multipackQuantity` | **2** |`
- `WMT:498` — `| object `{unit, measure}` | `tireWidth`, `wheelDiameter` | **2** |`
- `WMT:496` — `| closed list | `constructionType` (2: Non-Radial, Radial) · `tireLoadIndex` (154) · `tireLoadRange` (15) · `tireSeason` (3) · `tireSpeedRating` (33) · `tireTerrain` (array, 7) · `tireTreadwearRating` (41) · `tireType` (array, 13) · `vehicleType` (array, **8**…) | **9** |`

Pack-related axis names — `WMT:210–211`: `variantAttributeNames.items.enum  ["assembledProductWidth","color","count","countPerPack","multipackQuantity","paperSize","pattern","shape","size"]` (9) · `swatchVariantAttribute.enum  ["assembledProductLength","assembledProductWidth","color","count","countPerPack","multipackQuantity","paperSize","pattern","shape","size"]` (10)

The separate priced pack container — section `### 1.9 `MP_VIRTUAL_PACK_BUNDLE` — the adjacent object that *is* priced`

- `WMT:320–321` — `Orderable { bundle_component_gtin        string 1..80` / `            bundleComponentItemQuantity  integer 0..9999999999`
- `WMT:327` — *"**✅ Walmart's one priced container shares no structure with variant grouping**: the whole schema contains **0** occurrences of `variantGroupId`, `variantAttributeNames`, `isPrimaryVariant` and `swatchImages`"*
- `WMT:1019` — the slot whole: `"bundle_component_gtin": {"title": "Component GTIN", "type": "string", "description": "Alphanumeric, 80 characters - GTIN of a component product in a bundle (specifically intended for Virtual Pack items).", "comments": "@group=Required to create virtual packs", "minLength": 80…}`

All numeric bounds in one row — `WMT:347`: `| `Orderable.price` · `swatchImageUrl` · `flavor` · `size` · `netContent.measure` · `tireWidth`/`wheelDiameter.measure` | 0…99999999999999 ×0.01 · 1..2500 (v4.8: 2000) · 1..600 · 1..500 · 0…99999999999999 ×0.001 · 0..99999 / 0..9999 ×0.01 | schema |`

**Maps to: number PLUS unit on the value (`netContent`, `tireWidth`, `wheelDiameter`) AND free text (`size`) AND bare integer (`count`) — simultaneously, within one product type.**

**Stated vendor rationale**, verbatim — the `netContent` description itself (`WMT:136`): *"The quantity (or quantities) of the product contained in the package along with its unit of measure typically printed on the label for the country or market where the product is sold."*

### Q4 · ORDERING → **AMBIGUOUS, and the record says so explicitly.**

- `WMT:377` — *"**A governance rule with no field anywhere**: *"How does Walmart determine the ranking of variant attributes and how they show up on the item page? **Every subcategory or item type has a ranked list of variant attributes that defines how the attributes show up on the item page. For example, clothing items will always list the item's size first followed by the color.**"* The write side has **no ordering field**; `variantMeta[]` is the only ordered structure anywhere, and **the ranked list is published nowhere (U8).**"*
- `WMT:533` (§4 U8) — `| **U8** | The relation between `variantMeta[]`'s order and the vendor's stated attribute **ranking** | The ranked list, or two calls compared against a rendered page | The list is published nowhere; the write side has no ordering field |`
- `WMT:2935` — after the last collection pass: `| **U8** | The relation between `variantMeta[]`'s order and the stated attribute ranking | The ranked list, or two calls compared against a rendered page |` — still open
- `WMT:45` (§0 H2) — *"**the attribute ranking Walmart says exists and publishes nowhere (U8)**"*
- `WMT:305` — the one ordered read-side object: *"**(b) `variants` on `GET /v3/items/walmart/search`** — the only object in any Walmart artifact carrying the axis names **once for a family** with the members beneath them: `variants{variantMeta[]{name}, variantData[]{…, variantValues[]{name,value}}}`, described *"Variant information for configurable products."* / *"Variant attribute definitions."* / *"Individual variant options."*"*
- `WMT:208` — value-list order was explicitly checked and is not the differentiator: *"**equal on 5,246 · differ as sets on 1,711 (24.6%) · mere ordering differences 0.**"*

A whole-file search for `sort order` / `display order` / `position` returns no such field.

**Maps to AMBIGUOUS.** Hedge quoted verbatim: `WMT:377` — *"the ranked list is published nowhere (U8)"*.
**Stated vendor rationale:** the FAQ answer at `WMT:377` is the only vendor "why", and it asserts the mechanism without exposing it.

### Q5 · VALUE IDENTITY / RENAME → **no value id, no attribute id, no `productTypeId` — the name string is the only handle. Rename is not addressed.**

- `WMT:373` — the measured zero (quoted whole above)
- `WMT:268` — *"❗ **Only the subcategory carries an ID** (`subCategoryId`, 24-hex-char). **No `productTypeId` exists in any artifact** — the v5 files key product types by their display-name string."*
- `WMT:187` — `variantGroupId` whole, with the vendor's instruction inside the schema: `{"title":"Variant Group ID","type":"string","description":"Alphanumeric, 300 characters - Required if item is a variant. Make up a number and/or letter code for \"Variant Group ID\" and add this to all variations of the same product. Partners must ensure uniqueness of their Variant Group IDs. Example: HANESV025","examples":["HANESV025"],"comments":"@group=Recommended to create a variant experience on Walmart website","minLength":1,"maxLength":300}`
- `WMT:531` (§4 U6) — *"Whether one `variantGroupId` may be reused across two product types, and what uniqueness is scoped to … Schema says only *"Partners must ensure uniqueness of their Variant Group IDs"*; Seller Center says new GTINs *"must be the same product type as the existing variant group"*"*; `WMT:2933` — *"**No page states a uniqueness scope**, so the row stays OPEN on that leg too"*
- A vocabulary change ships as a diff row, not a rename — `WMT:219`: *"The v4.8 release note *"Changing closed list for Variant Attribute Name to include 'tireSize' in 'Tires' category"* is confirmed in the files, which could have contradicted it: 4.3 `['color','count','size','diameter']` → 4.8 `['color','count','tireSize','diameter']`."*
- `WMT:215` — *"**22 data rows contain `variant`** — 11 `variantAttributeNames` and 11 `swatchImages_swatchVariantAttribute` rows, all `Attribute Value Change` / `Acceptable Values`, on **11 types** … Sample row: `9589.0 | Splash Pads | Attribute Value Change | variantAttributeNames | Acceptable Values | RAIDlevel,RAMSpeed,abrasive_belt_cleaner_type,…`"*
- `WMT:376` — *"**Collisions are caught after submission, not prevented**: *"Multiple items have the same values for their variant attributes. Please provide unique values or add more product variations to ensure your items are shown on site."* · *"Walmart may unpublish a variant item if duplicate variant values are found."*"*

A whole-file search for `rename` returns **0 hits**.

**Maps to: NO stable code/id separate from the label. Rename: not addressed.**
**Stated vendor rationale:** the `variantGroupId` description at `WMT:187` is the vendor's own instruction, not a rationale for the absence of ids.

---

## 6. SHOPEE — `SHPE` (#11047)

### Q1 · VALUE SHAPE → **(c) HYBRID, and the record says so in exactly those terms** — a shared row referenced by integer id, or a custom string with the id set to 0. There is a **second, structurally different** value shape for the axis.

Section: `### 1.2 `attribute` and `attribute_value`` (`SHPE:83`)

- `SHPE:127` — *"**✅ A catalogue value is a shared row referenced by integer id; a custom value is a string copied onto the product with the id set to 0**. `v2.product.search_attribute_value_list` (api 2401, 9,398 B) is keyed by `attribute_id` **alone, with no `category_id`** — value rows belong to the attribute."*
- `SHPE:128` — vendor, Guide 211 §2, verbatim: *"1) For all attribute types, you must upload a "value_id". When uploading a user-defined value, "value_id" must be 0 and "original_value_name" is required."*
- `SHPE:129` — *"2) Regardless of the data type of the value, the "original_value_name" field must be uploaded in string format."*
- `SHPE:104–110` — the shared-row schema: `attribute_value_list[]` / `value_id int "Value ID"` / `name string "Value name"` / `value_unit string "Value unit"` / `child_attribute_list object[] "Child attributes for the value of parent attribute — The structure content is the same as attribute_tree"` / `multi_lang object[] {language, value}`
- `SHPE:116` — `| `value_id` (catalogue row) | `int` / `int64` | attribute 1 : N | `678` · `3300` · `3341` · `3164` |`
- `SHPE:117` — `| `value_id` (on the item) | `int32` **required** | 1..1 per value | `0` = custom sentinel |`
- `SHPE:118` — `| `original_value_name` | `string` | 0..1, required when `value_id = 0` | `"customized name"` |`
- `SHPE:132` — *"❗ **The catalogue is recursive** — a shared value row can itself own attributes. Guide 209 §2.5, verbatim: *"In this example, "Weight Type" is the parent attribute, and "Body Weights Type" is the child attribute. To upload the child attribute, you must also upload the associated parent attribute."*"*

Retrieved instance — section `## §2c · ✅ Retrieved instance` (`SHPE:434`)

- `SHPE:474–477` — Guide 211 Example 6, verbatim: `"attribute_list": [ { "attribute_id": 100061, "attribute_value_list": [ { "value_id": 0, "original_value_name": "customized name" }, { "value_id": 678 } ] } ]`

**The axis is a SECOND, DISJOINT namespace with the same 0-sentinel trick** — section `### 1.4 `standardise_tier_variation` — the variant axis` (`SHPE:177`)

- `SHPE:197` — `| `variation_id` | ⚠️ **`int32`** in 646 & 635 · **`int64`** in 647 · bare **`int`** in 636 & 639 | required on the axis | `0` (custom) · `101054` (catalogue) |`
- `SHPE:199` — `| `variation_option_id` | ⚠️ same three spellings; **required=False in 646 and 639, required=True in 647 and 635** | 1..N per axis | `0` · `6245` · `6246` · `6255` |`
- `SHPE:201` — `| `variation_option_name` | `string` | required iff option id = 0 | `"Cream stripe"` · `"GSCM A1"` … `"GSCM A16"` |`
- `SHPE:206` — *"**✅ The axis is its own object in its own namespace, not an attribute flagged as an axis**. ⚠️ Instrument restated at full corpus scope: over **all 92 module-89+90 records (1,704,281 B), the number of records containing BOTH `attribute_id` and `variation_id` is 0** — 16 carry `attribute_id` only, 9 carry `variation_id` only, 67 carry neither."*
- `SHPE:134` — *"❗ **An attribute value is typed and carries a unit; a variation option is a bare label.** Instrument at full corpus scope: in the three-file variation corpus (86,954 B) `value_unit` → 0, `format_type` → 0, `input_validation_type` → 0, and `unit` → 0 in `get_variations`."*

**Maps to (c) — and doubly so: hybrid *within* attributes (id-or-custom-string), and a second value shape entirely for axis options.**

**Stated vendor rationale**, verbatim — `SHPE:209–210` (Announcement 873):
> *"When calling v2.product.init_tier_variation or v2.global_product.init_tier_variation to add or modify variation structures, you need to pass variation_id. If there are two levels of variations under this category, variation_group_id must be passed. **If you want to use customized variations, then pass variation_id=0 and pass variation_name.**"*
> *"Tips:" "1) If you input variation_name & variation_id, and variation_id !=0, it will not allow you to input variation_name. 2) If variation_id = 0, then you must pass the variation_name."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **SPLIT: (A) the attribute owns the value rows; (B) the category owns which attributes exist. The axis catalogue is (B).**

- `SHPE:90` — `attribute_value_list   object[]   "All available values for this attribute"`
- `SHPE:127` — value rows keyed by `attribute_id` **alone, with no `category_id`** (quoted whole above)
- `SHPE:124–125` — *"**✅ Category owns attributes, on two routes.** Guide 209 §2, verbatim: *"Each product category has different attribute data. The v2.product.get_attribute_tree API will return the attribute data for the given category_id. However, please note that **only last-level categories can retrieve attribute data.**"*"*
- `SHPE:382–383` (section `### The category gate on the axis catalogue`) — *"On Open API side, you can v2.product.get_variations or v2.global_product.get_variations to pass **category_id** to get all the standard variation."* · *"There are **two levels of standardization**: the first level is called variation_id, and the second level is called variation_group_id. The values are referred to as variation_option_id."*
- `SHPE:388` — the gate is soft and untested: *"**The defensible instrument, with a positive control**: the enumerated error lists — **72** entries in api 646 and **63** in api 647, both counts reproduced — read in full. Pattern `categor` (case-insensitive) → **0 of 72 and 0 of 135 total**. … So the vendor enumerates structural refusals in detail and enumerates **no** category-scoped one. Whether the live gateway rejects an out-of-category `variation_id` is **U-1**."*

**The open/closed switch is `input_type`, per attribute** — section `### ✅ What the structure does determine, and this is retrieved` (`SHPE:505`)

- `SHPE:509` — *"**Category also decides the governance of each attribute**, through `input_type` — Guide 209 §2.2's table, verbatim from the rendered rows"*
- `SHPE:510` — *"1 / int / SINGLE_DROP_DOWN / … Custom value is allowed: **No** / Attribute values are provided: **Yes**"*
- `SHPE:511` — *"2 / int / SINGLE_COMBO_BOX / … **Yes** / **Yes**" · "3 / int / FREE_TEXT_FILED / … **Yes** / **No**"*
- `SHPE:512` — *"4 / int / MULTI_DROP_DOWN / … **No** / **Yes**" · "5 / int / MULTI_COMBO_BOX / … **Yes** / **Yes**"*
- `SHPE:514` — *"So an attribute of `input_type` 2, 3 or 5 accepts a value Shopee never published, via `value_id = 0` + `original_value_name`. **A flavour value is therefore expressible on any category whose attribute set contains an open-typed attribute — but which categories carry one, and under what name, is not published.**"*
- `SHPE:92–93` — the enum, as the schema declares it: `input_type int SINGLE_DROP_DOWN=1 SINGLE_COMBO_BOX=2 FREE_TEXT_FILED=3 MULTI_DROP_DOWN=4 MULTI_COMBO_BOX=5`
- `SHPE:136` — *"⚠️ **The enum quotes in this document are tag-stripped renderings, not bytes.** Api 1825's `input_type` description is 195 raw bytes using `<br />` separators and `&nbsp;` padding; api 1827's is 189 raw bytes using separate `<p>` elements. The five **values** are identical in both records; the bytes are not."*
- `SHPE:555` (contradiction 2) — *"**Enum names that do not exist in the enum** | `add_item`'s `value_id` description names `TEXT_FILED`, `COMBO_BOX`, `MULTIPLE_SELECT_COMBO_BOX` | The authoritative enum is `SINGLE_DROP_DOWN=1, SINGLE_COMBO_BOX=2, FREE_TEXT_FILED=3, MULTI_DROP_DOWN=4, MULTI_COMBO_BOX=5` — three of three names wrong (`FREE_TEXT_FILED` is the vendor's own misspelling, preserved in both attribute-tree records)"*

**Maps to (A) for the value list, (B) for which attributes exist.**

**Stated vendor rationale:** Guide 209 §2 (`SHPE:125`), §2.2 (`SHPE:510–512`), §2.5 (`SHPE:132`) — all verbatim vendor text; the record carries no design note explaining *why*.

### Q3 · QUANTITIES → **a NUMBER-ish value PLUS a unit stored ON THE VALUE, governed by `format_type` on the definition, with the allowed units listed on the definition.**

- `SHPE:96` — `format_type int FORMAT_NORMAL=1 FORMAT_QUANTITATIVE_WITH_UNIT=2`
- `SHPE:098` — `attribute_unit_list string[]`
- `SHPE:107` — `value_unit string "Value unit"`
- `SHPE:119` — `| `value_unit` | `string` | 0..1, required when `format_type = 2` | `"kg"` (value `"5kg"`) |`
- `SHPE:130` — Guide 211 §2 rule 3, verbatim: *"3) When "format_type" is 2 and you upload a user-defined value, you must also upload the "value_unit" field, and the unit should be selected from the "attribute_unit_list" in the response of the v2.product.get_attribute_tree API."*
- `SHPE:134` — Guide 209 §2.4, verbatim: *"the "name" field in the "attribute_value_list" will return the value of the attribute (i.e. 5kg), while the "value_unit" field will return the unit of the attribute value (i.e. kg)."*
  — note the label is `"5kg"`: **the magnitude and unit are concatenated in the label, with the unit *also* broken out in `value_unit`.**
- `SHPE:94–95` — the typing layer: `input_validation_type int VALIDATOR_NO_VALIDATE_TYPE=0 VALIDATOR_INT_TYPE=1 VALIDATOR_STRING_TYPE=2 VALIDATOR_FLOAT_TYPE=3 VALIDATOR_DATE_TYPE=4`
- `SHPE:97` — `date_format_type int YEAR_MONTH_DATE=0 (DD/MM/YYYY)  YEAR_MONTH=1 (MM/YYYY)`
- `SHPE:147` — the item-level physical weight is a separate, unrelated field: `original_price float REQ · weight float REQ`
- `SHPE:134` — **axis options carry no unit at all** (instrument quoted above)

**No dedicated net-content field.**

**Maps to: number plus unit, unit on the VALUE (`value_unit`), the *allowed* unit list on the DEFINITION (`attribute_unit_list`), switched by `format_type` on the definition.**
**Stated vendor rationale:** Guide 209 §2.4 (`SHPE:134`) and Guide 211 §2 rule 3 (`SHPE:130`) — both verbatim.

### Q4 · ORDERING → **NOT ADDRESSED.**

A whole-file search of `SHPE` for `sort|position|display order|order of|sequence|index|drop_down|dropdown|combo_box|display` finds: every `index` hit is `tier_index` (the variant's axis coordinate); every `display` hit is `display_category_name` or browse prose. **There is no statement about sort order, position, display order, or the order of values in a picker.** The nearest thing is the UI-widget taxonomy at `SHPE:509–512`, which names the widget (`DROP_DOWN`, `COMBO_BOX`) and says nothing about ordering within it, and the paginated read at `SHPE:122`: `| paginated value read | `{attribute_id, value_name, cursor, limit}` | `limit` **1..100** |` — a cursor, no sort key.

**Maps to: not addressed. No stated rationale in the record.**

### Q5 · VALUE IDENTITY / RENAME → **`value_id` is a stable integer id separate from the label; but its SCOPE is OPEN and rename behaviour is not addressed.**

- `SHPE:105–106` — `value_id int "Value ID"` · `name string "Value name"`
- `SHPE:110` — `multi_lang object[] {language, value}` — the label is localisable per language while the id is not
- `SHPE:116` — the id instances `678` · `3300` · `3341` · `3164`
- `SHPE:534` (§4 U-7) — *"Whether attribute `value_id`s are globally unique or unique within an `attribute_id`. `search_attribute_value_list` takes `attribute_id` alone; Guide 209's examples (3300/3341 under 100643, 3164 under 100602) fit either scheme | A live `get_attribute_tree` across many categories, checking whether any `value_id` recurs under two `attribute_id`s with different names | **H1** |"*
- `SHPE:535` (§4 U-8) — *"Whether an `attribute_id` is shared across categories or re-minted per category. The vendor says only *"Each product category has different attribute data."* | **H1** |"*
- For **custom** values there is no id at all — `SHPE:117–118`, `SHPE:128`.

**Maps to: a stable id exists for catalogue values and does not for custom ones; rename is not addressed.**
**Stated vendor rationale:** no stated rationale in the record.

### Shopee — `tier_variation` and its deprecation, which #10778's V7 rebuttal leans on

- `SHPE:216` — *"**The deprecated predecessor, still in the response schema and still in the request samples:**"*
- `SHPE:218–221` — `tier_variation[]   { name : string, option_list[] { option : string, image { image_id, image_url } } }` — *"— free text, no ids."*
- `SHPE:556` (contradiction 3) — *"**Two deprecation dates for one field** | {646, 647}: **2025-09-12** | {635, 636}: **2025-09-15** — same sentence, one with `\n` where the other has a space |"*
- `SHPE:557` (contradiction 4) — *"**Five stated sunset dates for one field** | 873: *"on **May 30th** we will sunset the old field tier_variation for all APIs"* (no year) · 1179: *"descontinuados em **30/07/2025**"* · 1195: *"até **10/08/2025** … reforçamos que esse será o prazo final"* · 1224: *"estamos **novamente** estendendo o prazo para o dia **18/08/2025**"* | The changelogs: 2025-09-12 / 2025-09-15. ⚠️ **Bounded by the 5-entry cap** — earlier dates may exist and be unretrievable |"*
- `SHPE:567` (contradiction 14) — *"**Two "routes" that are one editorial stamping** | 646's and 647's newest changelog entries are **byte-identical** objects … Two stampings, not four routes |"*
- `SHPE:16` — *"⚠️ **"Precise scope of the deprecation: request-side only. The legacy shape is still returned on reads" is FALSE.** The vendor still teaches callers to **send** `tier_variation`: 14 occurrences of the JSON key inside `request_sample` blocks across the 92-record corpus — 4 in api 646, 4 in 647, 4 in 635, 2 in batch_add_item 3279. Revision 1 quoted the one clean sample (the "Payload" block) and never opened the other four in the same field."*
- `SHPE:378` — *"**What *is* true of the schema**: `init_tier_variation` request = 25 paths, `(^|\.)tier_variation$` → 0, one `standardise_tier_variation`; … And it survives on the read side: `init_tier_variation`'s **response** (26 paths) still contains `response.tier_variation`, and `get_model_list` returns **both** `response.tier_variation[]` and `response.standardise_tier_variation[]`."*
- `SHPE:530` (§4 U-3) — *"Whether legacy free-text `tier_variation` is merely undocumented or actually **rejected**. The changelog describes the documentation — *"The tier_variation structure **in the documentation** has been deprecated"* — and the vendor still ships it in 14 request samples | A credentialed `init_tier_variation` POST with the old array | **H1** |"*
- `SHPE:558` (contradiction 5) — *"**Promised mandatory, declared optional** | 873: *"standardise_tier_variation **will be set as a mandatory field**."* | `required=False` in 646, 647, 635, 636 **and 639**, while `model`/`global_model` is `required=True`. As documented, the API accepts models with no axis definition at all |"*
- `SHPE:286` — a **third** free-text axis namespace survives under another name: *"⚠️ **Revision 1 disposed of kit items in five words — "= composed bundle listing".** By this document's own §2 definition … **a kit item is a variant family the standardisation has not reached**. Its axis shape is the legacy free-text form under a different name."* (`tier_variation_list`)
- `SHPE:582` — *"| **`tier_variation`** | deprecated in the documentation | 2025-09-12 (shop) / 2025-09-15 (global) in the changelogs; 2024-05-30 → 2025-07-30 → 2025-08-10 → 2025-08-18 in the announcements | ⚠️ still in **14** vendor request samples and in every response schema |"*

> **⚠️ A CONFLATION IN #10778's V7 REBUTTAL, flagged not resolved.**
> `PRIOR:141` strikes V7 partly on the ground that *"Shopee's `value_id: 0` sidecar accompanies a `tier_variation` mechanism **deprecated 2025-09-12**"*.
> The Shopee record measures the two namespaces **disjoint** — `SHPE:206`: *"over all 92 module-89+90 records (1,704,281 B), the number of records containing BOTH `attribute_id` and `variation_id` is 0."*
> The `value_id: 0` sidecar belongs to the **attribute** namespace (`SHPE:127–129`), which is current and undeprecated. `tier_variation` belongs to the **axis** namespace. The deprecation does not touch the sidecar. The axis namespace has its own 0-sentinel (`variation_id = 0` + `variation_name`, `SHPE:209–210`), and *that* one does sit in the deprecated-and-replaced mechanism — but `standardise_tier_variation`, its replacement, carries the same sentinel (`SHPE:197–201`).

---

## 7. TOKOPEDIA — **ERA A** — `TOKO` (#11048)

> **⚠️ TWO ERAS. NEVER MERGE THEM.** `TOKO:71` (section `## §1 · Entities`), verbatim:
> *"Two surfaces that must not be merged. **ERA A** — "Tokopedia Seller API" / Tokopedia Open Platform, host `fs.tokopedia.net`, documented at `developer.tokopedia.com`, **completely terminated 2025-09-30**. **ERA B** — the documentation portal at `partner.tokopedia.com`, serving the TikTok Shop Open API with Tokopedia-specific fields."*

**Era A dates and versions as the record stamps them:** host `fs.tokopedia.net`; docs at `developer.tokopedia.com`; **terminated 2025-09-30**; Create Product **V2/V3**; `get_variant` **v1 and v2 with different shapes** (`TOKO:143`); a 2021 documentation capture and a **live production PDP capture 2026-09-01** (`TOKO:174`).

### Q1 · VALUE SHAPE → **(b) SHARED OPTION ROWS, three id spaces deep, with a value-only free-text escape.**

Section: `### 1.2 `Variant` / `VariantUnit` / `VariantUnitValue` — Era A, the global axis catalogue` (`TOKO:125`)

- `TOKO:128–129` — `GET /inventory/v2/fs/:fs_id/category/get_variant?cat_id=:cat_id` / *"This endpoint retrieves a list of variants related to a `category_id`."*
- `TOKO:131–141` — the shape, whole: `variant_details[] { variant_id int · has_unit int (0|1, defined in no table) · identifier string · name string · status int (observed 1 and 2, defined in no table) · is_primary int · units[] { variant_unit_id int · status int · unit_name string · unit_short_name string · unit_values[] { variant_unit_value_id int · status int · value string · equivalent_value_id int · english_value string · hex string · icon string } } }` · `variant_id_combinations [][]int ← undocumented, see §4/U4`
- `TOKO:143` — *"The **v1** endpoint remains documented alongside v2 with a *different* shape — `unit_id` / `name` / `short_name` / `value_id` / `hex_code`. See §5 note on D4."*
- `TOKO:147–150` — real instances: `{"variant_id":1,"has_unit":0,"identifier":"colour","name":"Warna","status":2}` · `{"variant_id":29,"has_unit":1,"identifier":"size","name":"Ukuran","status":1}` · `{"variant_unit_id":27,"status":1,"unit_name":"Default","unit_short_name":"default"}` · `{"variant_unit_value_id":445,"status":1,"value":"0","equivalent_value_id":0,"english_value":"","hex":"","icon":""}`

Section: `### 1.3 `ProductVariant` / `ProductVariantOption` — Era A, the per-product rows (live)` (`TOKO:162`)

- `TOKO:165–172` — `pdpProductVariant { productVariantID string ← per-product id, its own id space · variantID string ← points at the CATALOGUE axis · name · identifier · option[] }` · `pdpProductVariantOption { productVariantOptionID string ← per-product id · variantUnitValueID string ← points at the CATALOGUE value · value string · hex string · stock string }`
- `TOKO:174–184` — **✅ Retrieved, live, 2026-09-01**: `{"productVariantID":"31912482","variantID":"29","name":"ukuran","identifier":"size","__typename":"pdpProductVariant"}` · `{"productVariantOptionID":"108654324","variantUnitValueID":"455","value":"S","hex":"","stock":"0"}` (and `456`/`M`, `457`/`L`, `458`/`XL`) · `"children.0":{"productID":"1747343136","price":51000,…,"optionID":{"type":"json","json":[108654324]},"optionName":{"type":"json","json":["S"]},…}`

Section: `## §2 · The variant mechanism · Era A — the vendor's own call sequence` (`TOKO:899`)

- `TOKO:907` — `selection[] { id, unit_id, options[]{hex_code, unit_value_id, value} }`
- `TOKO:915` — vendor, verbatim: *"- Field `id` is `variant_id` which is retrieved from get variant by category endpoint. - Field `unit_id` is retrieved from get variant by category endpoint. - Field `hex_code` and `unit_value_id` is also retrieved from get variant by category endpoint. `unit_value_id ` fill with `value_id`'s response from `get variant by category` - **To create a custom variant simply fill `value` with desired value.**"*
- `TOKO:919` — *"**✅ The axis is referenced by catalogue id; only the VALUE has a free-text escape**. There is no documented way to name a new axis in Era A — `selection[].id` must be a `variant_id` from the category endpoint."*
- `TOKO:487` — *"**Era A — the escape hatch is on the VALUE, not the axis**. `selection[].id` must be a `variant_id` retrieved from the category endpoint; the only free text is *"To create a custom variant simply fill `value` with desired value."* So in Era A a flavour **axis** could not be introduced by a seller at all unless the category's catalogue carried one — and the two axes the vendor publishes are colour and size."*

`MATRIX:1884` — *"the global catalogue axis (Ukuran) and value (S); productVariantOptionID is a second, per-product id space"*

**Maps to (b), with a value-level free-text escape.**
**Stated vendor rationale:** `TOKO:915` is the vendor's own instruction; no design note explains it.

### Q2 · WHERE THE ALLOWED LIST LIVES → **(B) on the category**, plus an undocumented per-category axis-permission list.

- `TOKO:129` — *"This endpoint retrieves a list of variants related to a `category_id`."*
- `TOKO:141` — `variant_id_combinations [][]int ← undocumented, see §4/U4`
- `TOKO:479` — *"| The category's axis permission list, for the one category the vendor prints | `"variant_id_combinations": [[1],[29]]` for `category_id: 3412` — i.e. colour and size again. ❓ **Its semantics are documented nowhere** (§4/U4) |"*
- `MATRIX:786` — *"Example: category 3412 → two axes, Warna (colour, 12 values) and Ukuran (size, 16 values)."*

**The whole published catalogue, both arrays, reproduced whole by the record:**

- `TOKO:152` — *"⚠️ **Both catalogue arrays, printed whole this time.** Revision 1 printed 16 of the file's 28 values while presenting them as the catalogue"*
- `TOKO:154–155` — *"**`variant_id` 1 · `identifier` "colour" · `name` "Warna" · `has_unit` 0 · one unit (`variant_unit_id` 0) — 12 values, array closes cleanly:** `1` Putih/White/`#ffffff` · `2` Hitam/Black/`#000000` · `5` Biru/Blue/`#1d6cbb` · `6` Biru Muda/Light Blue/`#8ad1e8` · `9` Merah/Red/`#ff0016` · `11` Merah Muda/Pink/`#ffb0b0` · `12` Orange/Orange/`#ffa500` · `13` Kuning/Yellow/`#ffff00` · `16` Cokelat/Brown/`#8b4513` · `18` Hijau/Green/`#006400` · `19` Ungu/Purple/`#bf00ff` · `218` Abu-abu/Grey/`#5d5d5d`."*
- `TOKO:156` — *"❗ **Id 218 shows the catalogue is sparse and non-contiguous** — revision 1's 1..18 run implied it was not."*
- `TOKO:158` — *"**`variant_id` 29 · `identifier` "size" · `name` "Ukuran" · `has_unit` 1 · one unit `{"variant_unit_id":27,"unit_name":"Default","unit_short_name":"default"}` — 16 values, ids 445–460 contiguous:** `445` "0" · `446` "2" · `447` "4" · `448` "6" · `449` "8" · `450` "10" · `451` "12" · `452` "14" · `453` "16" · `454` "XS" · `455` "S" · `456` "M" · `457` "L" · `458` "XL" · `459` "XXL" · `460` "All Size"."*
- `TOKO:478` — *"| Axes in the Era-A published catalogue example | **exactly 2** … The file contains exactly two `unit_values` arrays, 28 values in total. **No flavour axis appears** |"*

**Maps to (B).**
**Stated vendor rationale:** `TOKO:129` is the only vendor sentence; no rationale in the record.

### Q3 · QUANTITIES → **BARE LABEL. `has_unit` / `units[]` names a SIZING SYSTEM, not a physical unit.**

- `TOKO:158` — the size axis has `has_unit 1` and exactly **one** unit named `"Default"` / `"default"`, holding all sixteen values
- `TOKO:160` — *"❗ **Nine of the sixteen are bare numerals inside the same named unit as the letter sizes** — which bears directly on §1.7's unit finding, and is exactly the run revision 1 dropped."*
- `TOKO:488` — *"**Counter-case inside the value layer, which is the sharpest thing this measurement did surface**: the size axis's 16 values include the bare numerals `"0" "2" "4" "6" "8" "10" "12" "14" "16"` sitting in the same named unit (`variant_unit_id` 27, `"Default"`) as `XS…XXL` and `All Size`. **The value is a bare label with no magnitude or unit field** — `amount` 0, `quantity` 0, `magnitude` 0, `uom` 0 within the 31,047 B file"*
- Era A product weight is a separate field with an enum of two: `TOKO:085` — weight `GR|KG`

**No dedicated net-content field.**

**Maps to: text / bare label.**
**Stated vendor rationale:** no stated rationale in the record.

### Q4 · ORDERING → **a stored `sort_order` EXISTS — but on the ANNOTATION (specification) groups only, not on axis values — and it is not unique in the vendor's own success sample.**

Section: `### 1.4 `Annotation` — Era A, the separate specification system` (`TOKO:188`)

- `TOKO:191–196` — `GET /v1/fs/:fs_id/product/annotation?cat_id=:cat_id` / *"This endpoint retrieve list of product annotation (product specification) based on category ID."* / `annotation[] { variant string ← the GROUP NAME. no id field exists. · sort_order int · values[] { id: int, name: string, data: string } }`
- `TOKO:198` — real instance: `{"variant":"Pola Produk","sort_order":2,"values":[{"id":84,"name":"Polkadot","data":""},{"id":92,"name":"Polos","data":""}]}`
- `TOKO:199` — *"❗ **This carries no axis role and the group has no stable id** — see contradictions 6 and 7."*
- `TOKO:528` — *"`{"variant":"Product Color","sort_order":3,"values":[{"id":65,"name":"Hitam","data":"#000000"}]}` **and**, as a separate array element, `{"variant":"Product Color","sort_order":3,"values":[{"id":64,"name":"Beige",…},{"id":68,"name":"Emas",…}]}` — same name, same `sort_order`, split across two objects in the vendor's own success sample. The group has no id field, so a consumer cannot tell whether these are o[ne group or two]"*

**For AXIS values: not addressed.** No ordering field appears on `unit_values[]` or on `pdpProductVariantOption`.

**Maps to: a stored sort column on the *specification* group; not addressed for the picker.**
**Stated vendor rationale:** no stated rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **YES — ids are stable and label-independent, demonstrated across five years.**

- `TOKO:139` — `variant_unit_value_id int` — the catalogue value's own id
- `TOKO:171` — `variantUnitValueID string ← points at the CATALOGUE value`
- `TOKO:186` — *"**✅ `variantID` 29 and `variantUnitValueID` 455 are the axis and value documented in the 2021 capture** — a doc and a running system, five years apart, that could have disagreed. The child's link is by the **per-product** option id, matching the archived doc's own `"option_ids":[41368,41370]` on children and `"option":[{"id":41368,"value":"Hijau","hex":"#006400"}]` on the axis."*
- `TOKO:155–156` — sparse, non-contiguous ids (`218` among `1..19`) — the signature of a stable id space with deletions
- `TOKO:182` — the child links by `optionID` (per-product) while carrying `optionName` (the label) alongside

**Maps to: YES — a stable code/id separate from the label, in two id spaces (catalogue and per-product).**
**Stated vendor rationale:** no stated rationale in the record.

---

## 8. TOKOPEDIA — **ERA B** — `TOKO` (#11048)

**Era B identity, dates and versions as the record stamps them:** `TOKO:71` (above) · `TOKO:226` — section heading `### 1.6 `Product` — Era B (`partner.tokopedia.com`, served title `TikTok Shop Partner Center` [R-16])` · version suffix **202309** for Create Product, Get Product, Categories, Category Rules and Get Attributes · **`edit-product-202509`** (`PUT /product/202509/…`) · suffixes across the corpus span **202309–202608** · the category tree carries `update_time` **2026-09-03** · an Indonesian-market changelog dated **27 October 2026** (`TOKO:334`).

### Q1 · VALUE SHAPE → **(c) HYBRID — built-in `id`/`value_id`, or custom `name`/`value_name`, and the custom one gets an auto-generated id after listing.**

Section: `### 1.7 `SKU` and `SalesAttributeOnSKU` — Era B, the variant row` (`TOKO:284`)

- `TOKO:287–292` — `skus[]  required=Y` / `sales_attributes[]  required=N` / `id string ← built-in attribute id, from Get Attributes` / `value_id string ← built-in value id, from Get Attributes` / `value_name string ← CUSTOM value, max 50 chars` / `name string ← CUSTOM axis name, max 20 chars`
- `TOKO:398` — *"| custom axis name ≤20 chars | *"A self-defined custom sales attribute name if the built-in attributes do not satisfy your needs. **The system will auto-generate an ID after listing.** **Note**: - Do not include sensitive characters. - Max length: 20 characters"* |"*
- `TOKO:399` — *"| custom value name ≤50 chars | *"…**Note**: - No duplicates allowed under the same attribute. - Max length: 50 characters."* |"*
- `TOKO:400` — *"| repeated characters | *"…nor can it have more than 9 consecutive repeated characters (e.g., aaaaaaaaa or 111111111)."* |"*
- `X:1032` — *"Tokopedia **both** — built-in `id`+`value_id` vs custom `name`+`value_name`; global-vs-local id scope unresolved (#11048 §1.7, §1.10)"*
- `MATRIX:1845` — the published Create Product SKU element: `{"sales_attributes":[{"id":"100089","value_id":"1729592969712207000","value_name":"Red","sku_img":{…},"name":"Color","supplementary_sku_images":[…]}], …}`
- `MATRIX:1856` — the response: `"sales_attributes":[{"id":"100000","value_id":"1729592969712207123"}]`
- `MATRIX:1874` — the record's own field map: *"B · sales_attributes[].id / value_id — the axis and its value, by built-in catalogue id; name / value_name are the free-text escape"*

**Maps to (c).**
**Stated vendor rationale:** `TOKO:398` — *"A self-defined custom sales attribute name **if the built-in attributes do not satisfy your needs**."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(B) on the category — plus a seller escape that bypasses the category entirely.**

Section: `### 1.8 `Attribute` / `AttributeValue` — Era B` (`TOKO:320`)

- `TOKO:323–326` — `GET /product/202309/categories/{category_id}/attributes    ALL 20 response_param, none omitted` / `data.attributes:[]object  "The list of standard built-in product and sales attributes that are **bound to the specified category, based on your shop's location**."`
- `TOKO:327–330` — `id:string ex 100392` · `name:string ex Occasion` · `type:string SALES_PROPERTY | PRODUCT_PROPERTY (enum whole, 2/2)` · `is_requried:bool [sic] "Applicable only if `type=PRODUCT_PROPERTY`."`
- `TOKO:339–345` — `values:[]object · values.id:string · values.name:string · values.icon_url:string` · `value_data_format:string POSITIVE_INT_OR_DECIMAL (enum whole, 1/1)` · `is_customizable:bool "Applicable only if `type=PRODUCT_PROPERTY`."` · `requirement_conditions:[]object "Applicable only if `type=PRODUCT_PROPERTY` and `is_requried=false`." { condition_type:string VALUE_ID_MATCH (enum whole, 1/1) · attribute_id:string · attribute_value_id:string }` · `is_multiple_selection:bool "Applicable only if `type=PRODUCT_PROPERTY`."`
- `TOKO:347` — `attributes[].type`, quoted whole: *"The attribute type. Possible values: - `SALES_PROPERTY`: Indicates sales attributes that define product variants. - `PRODUCT_PROPERTY`: Indicates product attributes that describe the product as a whole."*
- `TOKO:349` — *"**✅ The documented governance switch does not cover axes**. Instrument, re-run over 15,542 B: `is_customizable` **2** · `SALES_PROPERTY` **1** (the enum bullet) · `PRODUCT_PROPERTY` **7** · `is_requried` **3** · `is_required` **0**. ⚠️ The two `is_customizable` hits are the **response_param field name** and the vendor's **response_body sample** — **its desc[ription contains no occurrence of the string]**"*
- `TOKO:486` — *"**Era B — two independent surfaces, only one of them measurable.** (a) A category-bound built-in: `data.attributes` is *"bound to the specified category, based on your shop's location"* and each row carries `type: SALES_PROPERTY | PRODUCT_PROPERTY` — whether any Indonesian category declares a flavour row is **UNKNOWN, credential-blocked**. (b) ✅ **A seller-typed custom axis needs no category involvement at all**"*

**The only Era-B instance anywhere with real ids — and it is Indonesian-market:**

- `TOKO:332` — *"⚠️ **2026-09-05 — the Indonesian-market attribute notice §5/D5 recorded as *"body not opened"* has been opened, and it publishes real ids.** `Changelog / Products / For Indonesia Market: Add Mandatory Attribute "Imported Goods" to All Categories except Digital Category`, `document_id` `6a8eaefebaeab604e164ac3a`, `is_api_doc: False`, `update_time` `1787735881`, `keywords` `Coming Soon` + `Action Required`"*
- `TOKO:334` — *"Starting from 27 October 2026, partners will be required to provide mandatory product attribute "Imported Goods"(Attribute ID `102254`, values `Yes` = `1000058` / `No` = `1000059`) when listing or editing products by using API to all categories except digital category."*
- `TOKO:336` — *"The updates of the requirements apply to local to local sellers in the Indonesian market."* · *"Developers with applications that use [Create Product], [Edit Product], and [Partial Edit Product]"* · *"The updates of the requirements apply to all versions of the related APIs"* · *"Without this mandatory attribute sellers will not be able to create and update products."* · *"Use the Get Attributes to check what attributes are mandatory a[nd…]"*
- `TOKO:338` — *"**This is the only Era-B `Attribute` instance with a real attribute id and real value ids anywhere in this record, and it is Indonesian-market.** It is **one route** — a changelog article — and the mechanism it names (`Get Attributes`) is H1-gated, so **nothing is moved to VERIFIED on it**."*

**Maps to (B), with a documented bypass.**
**Stated vendor rationale:** `TOKO:326` — *"bound to the specified category, based on your shop's location"*; `TOKO:347` — the two-type gloss.

### Q3 · QUANTITIES → **the sales-attribute VALUE is a bare label; BUT a magnitude on the SKU pairs with a unit carried as a PRODUCT ATTRIBUTE — and the record retracts its own earlier denial.**

- `TOKO:305` — *"**✅ The sales-attribute VALUE is a bare label.** Its complete field set is 9 nodes including nesting, and a case-insensitive search of **every one of those 9 names AND descriptions** for `unit` returns **0**."*
- `TOKO:307` — *"⚠️ **But the flat claim "no attribute value anywhere carries a unit" is refuted by the vendor's own schema.** `skus.sku_unit_count` (string, required=N) is a **fifth** unit-named request-body field that revision 1's tree-walk missed entirely; its description alone carries 10 of the file's 59 `unit` hits"*
- `TOKO:308` — *"The total quantity/volume of the product represented by the SKU. For example, if the SKU represents 500ml of water, this value would be 500 if the unit type is defined as ml. Valid range: [0.01, 99,999.9999] **Applicable only for the EU market**."*
- `TOKO:309` — *"**Note**: - This is mainly used to calculate the unit price of the SKU… - **Unit price = Selling price/(SKU unit count/base unit count).** Therefore if you want to obtain the unit price, you would also need to define the "base unit count" and the "unit type" **product attributes**. Retrieve the relevant information for these product attributes by using the [Get Attributes API]. The unit price would then be returned in the [Get Product API]."*
- `TOKO:311` — *"Error `12052361`: *"This base unit value count is not supported. The supported base unit values can be obtained from the Get Attribute API."* Error `12052362`: *"SKU unit count is required."* Get Product returns `data.skus.price.unit_price` and `data.skus.sku_unit_count`."*
- `TOKO:312` — *"❗ So the vendor documents **a magnitude on the SKU paired with a unit carried as a PRODUCT ATTRIBUTE served by Get Attributes** — a typed quantity plus unit inside the attribute system. It is EU-scoped, so its bearing on Indonesia is **OPEN** (§4/U14), which is why it is recorded and scoped rather than erased."*
- `TOKO:314` — *"⚠️ **The corrected `unit` partition**. Whole-file `unit` = 59, and it does **not** resolve to four field paths: `request_body_param` **25** · `response_param` **1** · `error_code_list` **8** · `request_body` **5** · `sample_code` **20** (= 59). **Five** request-body field names contain `unit`: `skus.sku_unit_count`, `skus.sku_dimensions.unit`, `skus.sku_weight.unit`, `package_dimensions.unit`, `package_weight.unit`."*
- `TOKO:316` — *"The one typed-format field on attributes is a **format hint, not a unit**: `attributes[].value_data_format` — *"The supported data type and structure of the attribute value for free-form entries… Applicable only for **conditional (cascading) attributes**, not for standard attributes."* Enum whole (1 of 1): `POSITIVE_INT_OR_DECIMAL`."*
- `TOKO:302` — `sku_dimensions {length,width,height,unit — all required=Y}` · `sku_weight {value req=Y, unit req=Y}`
- `TOKO:404` — *"| weight precision | *"- GRAM: integer - KILOGRAM: up to 3 decimal places - POUND: up to 2 decimal places"* |"*
- `TOKO:401` — *"| `sku_unit_count` range | *"Valid range: [0.01, 99,999.9999] Applicable only for the EU market."* |"*
- `MATRIX:1853` — instance: `"sku_dimensions":{"length":"10","width":"10","height":"10","unit":"CENTIMETER"}, "sku_weight":{"value":"1,32","unit":"KILOGRAM"}` — with `MATRIX:1871` noting *""USD\n" and "1,32" are the vendor's own defects."*

**Maps to: the sales-attribute value is a bare label; a real unit-pricing / net-content mechanism exists (SKU magnitude + attribute-borne unit) and is EU-scoped.**
**Stated vendor rationale**, verbatim — `TOKO:309`: *"This is mainly used to calculate the unit price of the SKU… Unit price = Selling price/(SKU unit count/base unit count)."*

### Q4 · ORDERING → **NOT ADDRESSED.**

No sort-order, position or display-order field appears on `sales_attributes[]`, on `attributes[].values[]`, or anywhere in the Era-B schema as the record reproduces it. **No stated rationale in the record.**

### Q5 · VALUE IDENTITY / RENAME → **`value_id` vs `value_name`; ids exist but their SCOPE is OPEN, and the vendor's own sample contradicts itself.**

- `TOKO:290–291` — `value_id string ← built-in value id, from Get Attributes` · `value_name string ← CUSTOM value, max 50 chars`
- `TOKO:339` — `values:[]object · values.id:string · values.name:string · values.icon_url:string`
- `TOKO:393` — *"| **3 sales-attribute types per product** | *"You can only have up to 3 types of sales attributes per product."* — ✅ **survives verbatim into `edit-product-202509`**. ⚠️ **2026-09-05: re-read at `edit-product-202509` today, and the sentence is bullet 2 of a five-bullet `**Note**` block the record had only ever quoted one line of.**"*
- `TOKO:394` — *"| same-shape rule | *"Each SKU must include the same number and type of sales attributes. For example, you cannot have one SKU that has only a Color attribute, while another SKU has both Color and Size attributes."* |"*
- `TOKO:399` — *"No duplicates allowed under the same attribute."*
- `TOKO:387` — *"⚠️ **Added this pass (audit 1), and it cuts against calling the Era-B ids "a shared catalogue"**: the vendor publishes an explicit **translation table between global and local sales-attribute and value ids**. Whether the ids §1.7 calls built-in are one global catalogue or market-local identifiers requiring translation is **OPEN** (§4/U13)."*
- Contradiction C9 (as the cross-record pass reports it): the vendor's own sample uses two different ids for one Color/Red pair.

**Maps to: a stable id exists and is separate from the label; its scope is AMBIGUOUS.** Hedge quoted verbatim: `TOKO:387` — *"Whether the ids §1.7 calls built-in are one global catalogue or market-local identifiers requiring translation is **OPEN**."*
**Stated vendor rationale:** no stated rationale in the record.

### Era B — the caps that bound any value list

- `TOKO:395` — *"| **3, from the error side** | `12052525` *"The attribute max num cannot exceed 3."* — says "attribute", not "sales attribute" (§4/U2) … Its ambiguity is unchanged and U2 stays **H1**-blocked |"*
- `TOKO:396` — *"| **2 variant categories** | *"Penjual bisa mengatur maksimal 2 kategori varian (misalnya Warna dan Ukuran)."* ["Sellers can set a maximum of 2 variant categories (for example Colour and Size)."] |"*
- `TOKO:397` — *"| **30 values / 10 per level** | *"Jumlah varian yang bisa ditambahkan untuk satu produk adalah maksimal 30 varian dan maksimal 10 varian per level/kategori. Misalkan Penjual memilih varian Warna dan Ukuran, jumlah varian yang bisa ditambahkan oleh Penjual adalah maksimal 20 varian yaitu 10 varian warna dan 10 varian ukuran. Tetapi apabila hanya 1 level varian, misal Warna saja, bisa ditambahkan maksimal sampai 30 varian."* |"*
- `TOKO:414` — *"| ❓ SKUs per product | max **100** (ID and other regions), **300** (BR, EU, JP, MX, UK, US). ⚠️ **The verbatim string was not carried into this collection** — the cap is recorded from the schema reading only, and must be re-quoted before it is relied on |"*

### Era B — the flavour question, measured

- `TOKO:480` — *"| Named axes in the Era-B schema's own examples | *"(e.g. size, color, length)"* on `sales_attributes`; *"such as size, color, length"* in the overview |"*
- `TOKO:481` — *"| Named axes in the Indonesian help family | *"maksimal 2 kategori varian (misalnya Warna dan Ukuran)"* |"*
- `TOKO:482` — *"| **The one place the vendor names flavour at all** | Seller University, verbatim: *"Stock Keeping Units or SKUs refer to one product having different sizes, colours, **flavours**, etc., included in one listing. They appear as variations of the original product that customers can choose based on their preferences. For example, a t-shirt (product) with varying sizes (each different size is an SKU)."* |"*
- `TOKO:470` — *"Sellers can now group related products (sizes, colors, flavors) under one listing, rather than relying only on auto-generated combinations."* — `Nov 2025 Product Innovation`
- `TOKO:444` — *"**A second honest gap, stated because it is a defect in the instrument rather than in the world:** *no flavour-pattern search was run in any of the three collection passes.*"* → `TOKO:448` — *"⚠️ **2026-09-05 — built and run.**"* → `TOKO:462` — *"**The pattern attacked, as the absence rule requires.** Every `rasa` hit is a substring false positive: `berasal` and `frasa` (Indonesian), `retrasarse` / `retrasados` (Spanish), `atrasados` (Portuguese), all inside Terms-and-Policies text — plus, in Era A, **two occurrences inside one order example's product-title string**, `"name": "Chitato Rasa Beef BBQ 35 gr isi 20 pc"`"*

---

## 9. SQUARE — `SQ` (#11049)

### Q1 · VALUE SHAPE → **(b) A SHARED OPTION ROW — a full `CatalogObject` with its own id, referenced by id, never copied.** The cleanest (b) in the set.

Section: `### 1.4 `CatalogItemOptionValue` — the axis value` (`SQ:236`)

- `SQ:239–241` — `CatalogItemOptionValue  (type = ITEM_OPTION_VAL, PUBLIC)   — 5 properties, whole` / `item_option_id · name · description · color · ordinal`
- `SQ:245` — `| `item_option_id` | string | 1..1 | `6J4XYMEIZR5KKTE6SRF7KBLJ` |`
- `SQ:246` — `| `name` | string — **no minLength, maxLength, pattern or enum** | 0..1 | `Red` |`
- `SQ:248` — `| `color` | string, hex | 0..1 | `#ff8d4e85` (defaults `#ffffff`) |`
- `SQ:249` — `| `ordinal` | integer | 0..1 | `6` |`
- `SQ:251–256` — *"**✅ The value is a shared row referenced by ID, not a string copied per product**. The ITEM_OPTION_VAL enum element says it "represents a value associated with **one or more** item options", and `CatalogItemOptionValueForItemVariation` carries only `item_option_id` and `item_option_value_id` — IDs, not names. Second route: "Item option values are linked to an item variation by referencing the corresponding `item_option_ids` and `item_option_value_ids` in the `item_option_values` attribute of the item variation.""*
- `SQ:258–261` — *"**✅ Sharing is queryable across products, which is what makes the row global**: `CatalogQueryItemVariationsForItemOptionValues.item_option_value_ids` — "All ItemVariations that contain all of the given Item Option Values (in any order) will be returned"; `CatalogQueryItemsForItemOptions.item_option_ids` — "All Items that contain all of the given Item Options (in any order) will be returned.""*
- `SQ:651–657` — retrieved instances: `"item_option_value_data": { "item_option_id": "6J4XYMEIZR5KKTE6SRF7KBLJ", "name": "Red", "ordinal": 6 }` · `… "Blue", "ordinal": 7` · `… "Yellow", "ordinal": 8` · `… "Purple", "ordinal": 9`
- `MATRIX:1900–1905` — the variation's coordinates, whole: `"item_option_values":[{"item_option_id":"QSYVES3CG6DREP7ENYG2G63D","item_option_value_id":"FXZYYVVKDCG4JZ3YAM6I22XJ"}, …]`
- `MATRIX:1926` — the record's own field map: *"the axis coordinates as {item_option_id, item_option_value_id} pointing at shared rows, never copied strings"*
- `X:121` — *"*Shared rows (2):* Square (`CatalogItemOptionValue`, a full `CatalogObject` referenced by id), Magento…"*

**Maps to (b).**

**Stated vendor rationale — the consequence of sharing, in Square's own words:** `SQ:268–270` —
> *"Keep in mind that because \"Polo shirt\" and \"Club shirt\" are variations of \"Shirt\", they're restricted to the same option values. If the seller later receives teal polo shirts, they must add \"Teal\" to the color option set."*

And `SQ:507–509` — *"**7 — Family members share the axis, and that is binding.** "Continuing with the polo shirt example, a \"Polo shirt\" variation must have a color and size because the parent \"Shirt\" item was defined with these options. **The possible values for these variation options are taken from the \"Shirt\" item definition.**""*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) on the attribute definition — one list everywhere, globally unique by name, with NO category or product-type gate.**

Section: `### 1.3 `CatalogItemOption` — the variant axis` (`SQ:203`)

- `SQ:206–207` — `CatalogItemOption  (type = ITEM_OPTION, x-release-status PUBLIC)   — 5 properties, whole` / `name · display_name · description · show_colors · values`
- `SQ:212` — `| `name` | string, **unique across all item options** | 0..1 | `Color` |`
- `SQ:215` — `| `values` | array of `CatalogObject` (ITEM_OPTION_VAL) | ⚠️ 2026-09-05: **0..250 as enforced live**, still **no published cap** — 251 → 400 `ARRAY_LENGTH_TOO_LONG` `"Item Option has too many values (251, max 250)."` on create, batch-upsert and update, each surface with its 250 control accepted (200); `GET` read-back returns 250 |`
- `SQ:217–221` — *"**✅ The axis is its own object, not an attribute flagged as an axis**. Verbatim, the ITEM_OPTION enum element: "The `CatalogObject` instance is of the CatalogItemOption type and represents a list of options (such as a color or size of a T-shirt) that can be assigned to item variations. The item-option-specific data must be on the `item_option_data` field." Schema description: "A group of variations for a `CatalogItem`.""*
- `SQ:223–226` — *"**✅ The axis object is reused across items, not owned by one**: "After your application creates a CatalogItemOption—such as \"color\" with predefined values—that option can be applied to define the color attribute for any new catalog items. Your application can also use catalog item options created by the seller in the Square Dashboard.""*
- `SQ:228–231` — *"⚠️ **Quote restored (audit 2).** `name`, complete: "The item option's display name for the seller. Must be unique across all item options. **This is a searchable attribute for use in applicable query filters.**" Revision 1 dropped the second sentence with no ellipsis — the second instance of the truncation shape audit 1 found on `abbreviation`."*
- `SQ:233–234` — *"❗ **`CatalogItem.item_options` is typed as an array of a BETA object** (`CatalogItemOptionForItem`) while `CatalogItemOption` and `CatalogItemOptionValue` themselves are PUBLIC."*

Section: `## §3 · The flavour test` (`SQ:734`)

- `SQ:741–745` — *"**(a) As an item option (the variant axis).** Nothing gates it. Any item may carry up to 6 item options, and the axis vocabulary is entirely seller/application-defined: "These examples (color, size, and style) are just that—examples. **Your application can create any type of option with various values.**" **There is no vendor-published list of option names, no per-category option set, and no required option anywhere in the corpus.**"*
- `SQ:793–798` — *"⚠️ **What could not be measured, stated as a gap rather than filled.** … **Square publishes no attribute-per-category taxonomy to count** — there is no vendor artifact listing which attributes exist, which are required, or which apply to which category, because attributes are seller-authored and category-independent by construction. The count is therefore not "zero categories require flavour"; it is that **no such enumerable object exists in this platform's model**."*
- `SQ:783–788` — *"**Counter-case 2 — `product_type` gates built-in field blocks, but never axes or attributes**: `CatalogItemVariation.service_duration` — "If the `CatalogItem` that owns this item variation is of type `APPOINTMENTS_SERVICE`, then this is the duration of the service in milliseconds"; … `CatalogItem.food_and_beverage_details` — "The food and beverage-specific details for the `FOOD_AND_BEV` item." Nine product types exist and **none of them changes which options or attributes are available.**"*
- `SQ:790–791` — *"**Counter-case 3 — one category-typed routing behaviour exists and is not an attribute gate:** KITCHEN_CATEGORY, "used by KDS (Kitchen Display System) to route items to specific clients"."*

**There is NO free/closed switch on item options — measured against a control corpus where such a switch is known to exist:**

- `SQ:382–388` — *"⚠️ **No such switch exists for item options — evidence replaced (audit 2).** Revision 1 cited a units-and-quantities sweep, which cannot detect a governance mode. Re-run with a control corpus where the switch is known to exist: corpus A = the 4 option schemas (3,434 bytes), corpus B = the 9 `CatalogCustomAttribute*` schemas (11,117 bytes). Case-insensitive hits A/B: `enforce` 0/1, `uniqueness` 0/1, `free-form` 0/1, `constrain` 0/1, `allowed` 0/10, `"enum"` 0/3, `config` 0/13, `"required"` 0/2, "cannot be modified" 0/2, "not be modified" 0/3, `maxLength` 0/4, `minLength` 0/3, `"pattern"` 0/1, `selection` 0/24, `validat` 0/0, `immutab` 0/0. **Every governance word fires on the control and none on the option schemas.**"*

**The control — Square's *custom attribute* system DOES have the switch, on the definition** (section `### 1.7 `CatalogCustomAttributeDefinition` — the attribute-scoping object`, `SQ:344`):

- `SQ:376–380` — *"**✅ The free-text-vs-closed-list switch is exactly one field, `type`** — "The type of this custom attribute. Cannot be modified after creation. Required." Enum whole: `STRING` "A free-form string containing up to 255 characters."; `BOOLEAN` "A `true` or `false` value."; `NUMBER` "A decimal string representation of a number. Can support up to 5 digits after the decimal point."; `SELECTION` "One or more choices from `allowed_selections`.""*
- `SQ:362–364` — *"**✅ `allowed_object_types` is the one documented gate on which attributes an object may carry**: "The set of `CatalogObject` types that this custom atttribute may be applied to. Currently, only `ITEM`, `ITEM_VARIATION`, `MODIFIER`, `MODIFIER_LIST`, and `CATEGORY` are allowed. At least one type must be included." (the misspelling "atttribute" is the vendor's)."*
- `SQ:371–374` — *"**✅ There is no per-object assignment row**: "After a custom attribute definition is set to be applicable to an object, such as a [CatalogItem] or [CatalogItemVariation], that definition is available for all objects of that type." and "A seller sees placeholders for all available definitions in every supported object even if values haven't yet been assigned.""*
- `SQ:390–392` — *"❗ **Immutability, verbatim**: "You cannot edit the `source_application`, `type`, `key`, `max_allowed_selections`, or `allowed_object_types` of a custom attribute after creation." and "You cannot edit the configuration for `STRING` type attributes after creation.""*
- `SQ:399–403` — *"**✅ A custom-attribute value is inline, not a shared row** — `CatalogObject.custom_attribute_values` is `{"type": "object", "additionalProperties": {"$ref": "CatalogCustomAttributeValue"}}`, a map keyed by the definition's `key`, and the payload lands in exactly one of `string_value` / `number_value` / `boolean_value` / `selection_uid_values`. **The one exception is SELECTION**, whose `selection_uid_values` hold uids of selections living inside the definition."*
- `SQ:752` — *"Because most of the definitions can be set on items and item variations, they appear on every item and item variation in the seller's catalog."*
- `SQ:753–755` — *"The ceiling is 10 seller-visible + 10 seller-hidden ~~per account~~ ⚠️ 2026-09-05: the numbers are live-verified — the 11th of each bucket is rejected `ITEMS_CUSTOM_ATTRIBUTE_LIMIT_EXCEEDED`"*

**Maps to (A) — one global list per option definition; no category, no product type.**

**Stated vendor rationale:** `SQ:223–226` and `SQ:268–270` (both quoted above) — the vendor states both the reuse and its consequence.

### Q3 · QUANTITIES → **BARE LABEL. The typed quantity + unit lives on the VARIATION, never on a value or an attribute.**

- `SQ:263–266` — *"**✅ The value is a bare label plus presentation and ordering metadata — no quantity, no unit**. Instrument: the four option-related schemas serialised, 3,434 bytes; case-insensitive `unit` 0, `quantity` 0, `measure` 0, `amount` 0, `precision` 0, `numeric` 0, `number` 0, `decimal` 0, `currency` 0, `value_type` 0 (`type` 17, all JSON-Schema keywords)."*
- `SQ:405–408` — *"**✅ Typed but unitless**. Instrument: the 9 `CatalogCustomAttribute*` schemas, 11,117 bytes — `\bunit\b` 0, `unit_of` 0, `measurement` 0, `currency` 0, `quantity` 3 (all inside the precision prose)."*
- `SQ:410–414` — *"**✅ A typed quantity + unit lives on the variation, never on an axis value or an attribute**: `CatalogItemVariation.measurement_unit_id` → `CatalogMeasurementUnit {measurement_unit, precision}` → `MeasurementUnit`, whose 8 properties are custom_unit, area_unit, length_unit, volume_unit, weight_unit, generic_unit, time_unit, type. `CatalogStockConversion` (BETA) carries quantities as decimal strings, maxLength 16."*
- `SQ:550` — `| `item_id`, `item_option_values`, `measurement_unit_id`, `sellable`, `stockable`, `stockable_conversion`, `service_duration`, `available_for_booking`, `team_member_ids`, `vendor_information`, `inventory_alert_type`, `inventory_alert_threshold`, `ordinal` | defined on the variation only in this corpus |`
- `SQ:896–898` (§5 #8) — *"**`MeasurementUnit`'s "exactly one of" list is short by three.** Description: "Exactly one of the following fields are required: `custom_unit`, `area_unit`, `length_unit`, `volume_unit`, and `weight_unit`." The same schema also defines `generic_unit`, `time_unit` and `type` — **8** properties against a list of **5**."*

**No dedicated net-content field.**

**Maps to: bare label; unit fixed on the variation, never on the value.**
**Stated vendor rationale:** no stated rationale in the record.

### Q4 · ORDERING → **a stored `ordinal` integer ON THE VALUE.**

- `SQ:240` — `ordinal` is one of the value's 5 properties
- `SQ:249` — `| `ordinal` | integer | 0..1 | `6` |`
- `SQ:263` — the record's own characterisation: *"a bare label plus presentation and **ordering metadata**"*
- `SQ:651–657` — the four retrieved values carry `ordinal` 6, 7, 8, 9 — a stored sequence
- `SQ:1289` — a standalone value created by batch-upsert comes back with `"ordinal":2`: `{"objects":[{"type":"ITEM_OPTION_VAL","id":"EPKBMA3FEZLKJMQR3WHMIN73",…,"item_option_value_data":{"item_option_id":"ITDFNXGKLAQ2LITSSQCRLZ73","name":"cp0905-fix-r10-small-v3","ordinal":2}}], …}`
- `X:1044` — *"**Square** — values are bare labels with colour and ordinal; the unit lives on the **variation** (`measurement_unit_id`)."*

⚠️ **The record carries NO verbatim vendor description of `ordinal`.** The field is named in the schema, present in instances, and characterised by the record — its semantics are not quoted from Square. Adjacent ordering statements are about the OPTION array, not the value list:

- `SQ:481–482` — `CatalogItemOptionForItem`, whose single field is described as *"The unique id of the item option, used to form the dimensions of the item option matrix **in a specified order**."*
- `SQ:493` — `CatalogItemVariation.item_option_values[]` — *"Listed in the same order as the item options of the parent item."*

A distinct, unrelated `ordinal` also sits on category assignment — `SQ:179–180`: `| categories | array of `CatalogObjectCategory` | `[{"id": "E7CLE5RZZ744BHWVQQEAHI2C", "ordinal": 0}]` |` · `| reporting_category | … | `{"id": "U3G2UZ75UWIVG3JWQL5BCLH4", "ordinal": 0}` |`, and the server assigns those itself (`SQ:1330–1333`).

**Maps to: a stored position / sort column on the value.**
**Stated vendor rationale:** no stated rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **YES — the id is stable and rename was performed LIVE, with the id and the value count preserved.**

- `SQ:239–245` — the value is a `CatalogObject` with its own id; `item_option_id` points at its option
- `SQ:516–518` — *"**9 — Editing.** "Your application might need to modify item options to update the set of values within each option set. **There are no restrictions to updating item options.** To make an update, call [UpsertCatalogObject] and provide the complete set of new and updated values.""*
- `SQ:470–472` — *"New objects use temporary ids: "the client should set the id to a temporary identifier starting with a \"`#`\" character""*

**The live rename experiment** — section `## §C2 · §4 row 2 — the round-10 controls (R-85, R-86, R-87)` (`SQ:1272`)

- `SQ:1274` — *"One `CatalogItemOption` (`Y2E7TTG5R6PPI4XXDWHTVDGE`, created with 250 values, `raw/r10-02`, 105,321 B, 18:40:48Z) carried the whole chain."*
- `SQ:1280` — `| baseline read | `GET /v2/catalog/object/Y2E7TTG5R6PPI4XXDWHTVDGE` | `raw/r10-03` (82,962 B) | 200 | 250 values, `version 1788633649327` |`
- `SQ:1281` — `| **real-change** update — the read-back body with value #250 renamed `cp0905-fix-r10-val-250` → `cp0905-fix-r10-val-250-renamed`, still 250 | `POST /v2/catalog/object` | `raw/r10-04` (82,978 B) | **200** | 250 values, `version 1788633668745`, `updated_at 2026-09-05T18:41:08.745Z` |`
- `SQ:1282` — `| read after it | `GET` | `raw/r10-05` (82,970 B) | 200 | 250 values, **new name persisted**, `version 1788633668745` |`
- `SQ:1283` — the 251st is refused: `{"errors":[{"category":"INVALID_REQUEST_ERROR","code":"ARRAY_LENGTH_TOO_LONG","detail":"Item Option has too many values (251, max 250)."}]}`
- `SQ:1287` — a standalone `ITEM_OPTION_VAL` naming the 250-value option → **400** `INVALID_VALUE`; `SQ:1289–1290` — the identically-shaped call against a 2-value option → **200**, and the option reads back with **3** values
- `SQ:1292–1295` — the schema shape the standalone call uses: `CatalogObject.item_option_value_data` is *"Structured data for a `CatalogItemOptionValue`, set for CatalogObjects of type `ITEM_OPTION_VAL`."*, and `CatalogItemOptionValue.item_option_id` is *"Unique ID of the associated item option."*; *"the schema states no nesting requirement."*

**Maps to: YES — a stable id separate from the label, with rename demonstrated live.**
**Stated vendor rationale:** `SQ:516–518` — *"There are no restrictions to updating item options."*

---

## 10. SALESFORCE COMMERCE CLOUD B2C — `SFCC` (#11050)

### Q1 · VALUE SHAPE → **(b)/hybrid — a `ProductVariationAttribute` owns the value list, and that attribute may be CATALOG-SHARED or PRODUCT-LOCAL, as a first-class choice.**

Section: `### 1.3 `ProductVariationAttribute` — the axis is its own object` (`SFCC:123`)

- `SFCC:139–140` — `| `attributeID` / `@attribute-id` | String / `NonEmptyString.256` | **1..1 required** | `color` |` · `| `ID` / `@variation-attribute-id` | String / `NonEmptyString.256` | **1..1 required** | `color` |`
- `SFCC:142–145` — `| `@slicing-attribute` / `slicing` | `xsd:boolean` | 0..1 | `false` |` · `| `shared` | boolean | 0..1 | `true` |` · `| `variationAttributeType` | string, enum `[string, int, unknown]` | 0..1 ⚠️ single route | `string` |` · `| `values` | array of `VariationAttributeValue` | 0..N, *"can be empty"* | 5 for `color` |`
- `SFCC:160` — *"**❗ The axis exists at four scopes.** (i) **Catalog level** — the `<catalog>` sequence has 8 children and `variation-attribute` is a **sibling of `product` and `category`**: `header`, `product-attribute-definitions`, `category` (0..N), `product` (0..N), `product-option` (0..N), `variation-attribute` (0..N), `category-assignment` (0..N), `recommendation` (0..N). (ii) **Product level** — `complexType.Product.Variations.Attributes` at L530 is `<xsd:choice minOccurs="0" maxOccurs="unbounded">` of `attribute` (deprecated), `variation-attribute` (inline, local), `shared-variation-attribute` (a pure reference: `display-name` 0..N + required `attribute-id` + required `variation-attribute-id`, **no values**). (iii) **Category-assignment level** — `complexType.CategoryAssignment.VariationAssignment` … (iv) ⚠️ **A dedicated REST resource, new in revision 2**, present in `products-oas` **only**: `/organizations/{organizationId}/products/{productId}/variation-attributes`, `…/variation-attributes/{id}`, `…/variation-attributes/{attributeId}/values/{id}`."*

Section: `### 1.4` — the value type (`SFCC:162`)

- `SFCC:177` — `| `@value` / `value` | `NonEmptyString.256`, `minLength: 1` | **1..1 required** | `red`, `1 GB` |`
- `SFCC:178` — `| `<display-value>` / `name` | localized string | 0..N | `Red` |`
- `SFCC:183` — `| `position` (Data API only) | number | 0..1 | `1` |`
- `SFCC:185` — the XSD `complexType.VariationAttribute.Value` whole — two elements and two attributes, `value` `use="required"`, `display-value` `sharedType.LocalizedString` `minOccurs="0" maxOccurs="unbounded"`

Section: `## §2 · The variant mechanism, end to end` (`SFCC:376`)

- `SFCC:417` — *"**✅ Local vs shared is a first-class choice, exposed three ways.** (i) the `<xsd:choice>` above — `variation-attribute` (inline, own values) **or** `shared-variation-attribute` (a reference with **no** values) pointing at the catalog-level row; (ii) `VariationAttribute.shared : boolean` — *"Returns the value of attribute 'shared' if attribute is local or shared."*; (iii) ⚠️ replacing an unfetchable Help route, Trailhead L160: *"Select the **shared attribute** that you created and select Apply ."*"*
- `SFCC:402` — the import sequence line: `        | shared-variation-attribute     ← SHARED: attribute-id + variation-attribute-id only`

Section: `## §2c · ✅ Retrieved instance` (`SFCC:471`)

- `SFCC:503` — `    values: [{name: {default: Silver}, position: 1, value: Silver}, …]`
- `MATRIX:1815–1819` — the instance as the matrix prints it: `variationValues: {color: Silver, memorySize: 1 GB}}` · `- id: color name: Color values: [Silver, Blue, Green, Red, Fuscia]` · `- id: memorySize name: Memory Size values: [{name: 1 GB, orderable: true, value: 1 GB}, {name: 2 GB, orderable: true, value: 2 GB}]`
- `MATRIX:1821` — *"color values printed as bare labels while memorySize keeps {name, orderable, value}"*
- `MATRIX:1830` — *"variants[].variationValues — the child's axis selection, a flat {attributeId: value} map"*

⚠️ **Provenance caveat on every Salesforce instance** — `SFCC:22` / `SFCC:473`: *"**⚠️ Two artifacts labelled "REAL INSTANCE" are vendor-authored examples** — an E2E test fixture and an AI-skill reference file. **This corpus contains no retrieved instance data at all.**"* / *"**⚠️ There is no retrieved instance in this corpus. This section cannot be completed as the format asks, and that is the finding.**"*

**Maps to (b)/hybrid — the record's own word for the choice is "first-class".**

### Q2 · WHERE THE ALLOWED LIST LIVES → **on the `ProductVariationAttribute` — and the record carries the vendor SAYING that the (A) design is the superseded one.**

Section: `### 1.8 `ProductVariationModel` / `ProductAttributeModel` — computed, not persisted` (`SFCC:296`)

- `SFCC:311` — **the strongest stated vendor rationale in the entire corpus**, verbatim from the API reference: *"historical leftovers from when object attributes were used directly as the basis for variation."*
- `PRIOR:202` reproduces the same sentence independently: *"**Salesforce moved the other way for values**, and calls the old shape a mistake in its own API reference — *"historical leftovers from when object attributes were used directly as the basis for variation."*"*

Merge semantics on the value list — `SFCC:419`:
- *"**✅ Merge semantics are enumerated, and the schema explains itself.** `@merge-mode`, `type="simpleType.MergeMode"`, `default="replace"`, `use="optional"`; enum whole (4): `add` · `merge` · `remove` · `replace`. Annotation quoted to its end: *"Used to control if specified variation values will be added to variation attribute, removed from variation attribute or replace existing variation attribute value list. Attribute should only be used in import MERGE and UPDATE modes. In import REPLACE mode, using the \"merge-mode\" attribute is not sensible, because existing variation attribute values will always be removed from the variation attribute before importing the variation attribute values specified in the import file."*"*
- `SFCC:362` — *"**None of those 13 numeric bounds is on a variation-attribute container.** ⚠️ `maxOccurs="2"` on `variation-attribute-values` bounds the number of **containers** (the `merge-mode` mechanism), not values — the inner `<variation-attribute-value>` is `maxOccurs="unbounded"`."*

**The *non-variation* attribute set is a three-layer union — and Salesforce is the only platform in the set that inherits attribute definitions down a category tree:**

Section: `## §3 · The flavour test` (`SFCC:544`)

- `SFCC:554` — *"1. **The global layer.** The attribute groups of the system object type `Product` — *"the attribute groups of the system object type 'Product' (i.e. the global product attribute groups) and their bound attributes"*."*
- `SFCC:555` — *"2. **The classification-category layer.** *"the global product attribute groups / product attribute groups of the product's classification category / product attribute groups of any parent categories of the product's classification category"*. And *"If the product lacks a classification category, then only the global product attribute group is considered by the model."* Corroborated on a second host: *"The classification category defines the attributes of the product in the product catalog."*"*
- `SFCC:556` — *"3. **The browse-category layer.** ⚠️ `Category.getProductAttributeModel()` — *"the global product attribute groups / product attribute groups of the calling category / product attribute groups of any parent categories of the calling category"*. **This is the bullet revision 1 dropped, and dropping it is what created the false contradiction C8.**"*
- `SFCC:282` — *"**✅ Attribute groups attach to a *category* as well as to an object type — now three routes.** … Trailhead supplies a fetchable replacement that corroborates **both** Help-only claims in one sentence: *"You create an attribute group to help you manage product attributes. **An attribute group is a grouping of attribute assignments that's attached to a category. Attributes can belong to more than one attribute group.** The attribute assignments display on the product details page and during some product comparisons."*"*
- `MATRIX:399` — *"Salesforce B2C50 | **Yes — the only one, on a category tree.** The model is the union of global groups, the classification category's groups, and "any parent categories" of it. A sub-category group overrides the parent's by id collision. **Single route, so treat it as one vendor's word.**"*

The axis→definition constraint, three routes — `SFCC:562–564`:
- *"| Script API | *"This ID matches the value returned by ObjectAttributeDefinition.getID() for the appropriate product attribute definition."* |"*
- *"| `catalog.xsd` | `complexType.VariationAttribute/@attribute-id` is `use="required"` |"*
- *"| Trailhead L148–155 | *"Product attributes are data such as description, size, and color, within the product system object. … Create a variation attribute that uses the color attribute definition and at least one color value."* |"*

⚠️ **`ObjectAttributeValueDefinition` does not appear anywhere in this record.** A whole-file search over all 781 lines returns **zero hits**. The nearest named thing is a length cap — `SFCC:364`: `· `<value-definition><value>` `NonEmptyString.4000` ·`. **No such type is enumerated.** The record's own position is that value lists moved off the object-attribute side entirely (`SFCC:311`).

**Maps to (C)/hybrid — one value list per `ProductVariationAttribute`, which may be catalog-shared or product-local. NOT (A): the record carries the vendor calling the (A) design "historical leftovers".**

**Stated vendor rationale:** `SFCC:311` and `SFCC:419` — both verbatim vendor text.

### Q3 · QUANTITIES → **the axis value is ONE OPAQUE STRING. Units are fixed on the definition. A real net-content triple exists — on the Product, not on a value.**

- `SFCC:196` — *"**❗ A value that looks typed is one opaque string**: `- name: 1 GB, orderable: true, value: 1 GB`. **Nothing separates `1` from `GB`.**"*
- `SFCC:185` — the value type whole: two elements, two attributes, **no unit, no scale, no quantity**
- `SFCC:194` — *"⚠️ **Instrument restated with both scopes**, because revision 1's *"all 5,677 bytes"* corpus reproduced under no stated convention. Pattern, case-insensitive `unit|uom|quantity|measure|scale|currency|dimension|weight`: over the **raw 29,948 B HTML → 1 line**, and it is page chrome (`<meta name="viewport" … initial-scale=1>`, matching on `scale`); over the **de-tagged 5,296 B visible text → 0**. **Control: the same pattern over the de-tagged `ObjectAttributeDefinition` page returns 12 lines.** Confirmed against the complete printed member list, so this is not merely a regex result."*
- `SFCC:198` — *"**Where units do exist** — one level down, on the attribute definition, and on the product: `ObjectAttributeDefinition.unit : String` — *"The attribute's unit representation such as inches for length or pounds for weight."*; `complexType.AttributeDefinition` carries `<unit>` (localized) alongside `<scale>` (`xsd:int`), `<min-value>`/`<max-value>` (`xsd:double`), `<regex>`; and `complexType.Product` opens `<ean>`, `<upc>`, `<unit>`, `<unit-quantity>` (`xsd:decimal`), `<unit-measure>` (`String.60`)."*
- `SFCC:061` — the Product field list: `    ean, upc, unit, unit-quantity, unit-measure, …`
- `SFCC:076` — `| `unit` / `unitQuantity` / `unitMeasure` | `String.256` / `xsd:decimal` / `String.60` | 0..1 each | `lbs` |`
- `SFCC:364` — `· `<unit-measure>` `String.60` ·`
- `SFCC:278–280` — `| `ObjectAttributeDefinition.unit` | String | 0..1 | `kg` |` · `| `ObjectAttributeDefinition.valueTypeCode` | Number, 18 constants | 1..1 | `3` (`VALUE_TYPE_STRING`) |` · `| `<type>` on `AttributeDefinition` | `simpleType.AttributeType`, `minOccurs="1"` | **1..1 required** | `enum-of-string` |`
- `SFCC:289` — `| `VALUE_TYPE_*` | **18** | `INT=1` `NUMBER=2` `STRING=3` `TEXT=4` `HTML=5` `DATE=6` `IMAGE=7` `BOOLEAN=8` `MONEY=9` `QUANTITY=10` `DATETIME=11` `EMAIL=12` `PASSWORD=13` `SET_OF_INT=21` `SET_OF_NUMBER=22` `SET_OF_STRING=23` `ENUM_OF_INT=31` `ENUM_OF_STRING=33` |`
- `SFCC:288` — `| `simpleType.AttributeType` | **16** (identical in both XSDs) | `string` `int` `double` `text` `html` `image` `boolean` `date` `datetime` `email` `password` `set-of-string` `set-of-int` `set-of-double` `enum-of-string` `enum-of-int` |`
- `SFCC:640` (C7) — *"**The value-type enum disagrees between the Script API and the import schema.** Script API: **18** `VALUE_TYPE_*` constants including `VALUE_TYPE_MONEY = 9` and `VALUE_TYPE_QUANTITY = 10`. `catalog.xsd` and `metadata.xsd` `simpleType.AttributeType`: **16** enumeration values in both, with **no `money` and no `quantity`**; they also spell the numeric type `double`/`set-of-double` where the Script API says `NUMBER`/`SET_OF_NUMBER`."*

**Maps to: the axis value is TEXT. Units are fixed on the DEFINITION, never on the value. A dedicated net-content triple exists on the PRODUCT (`<unit>` + `<unit-quantity>` + `<unit-measure>`) and is not part of the attribute value system.**
**Stated vendor rationale:** `SFCC:198` — *"The attribute's unit representation such as inches for length or pounds for weight."* — a gloss, not a rationale.

### Q4 · ORDERING → **a stored `position` number ON THE VALUE — but on one of three surfaces only, and WHO SETS IT is AMBIGUOUS.**

- `SFCC:183` — `| `position` (Data API only) | number | 0..1 | `1` |`
- `SFCC:503` — the retrieved payload: `values: [{name: {default: Silver}, position: 1, value: Silver}, …]`
- `SFCC:571` — the flavour-test row showing the sequence: `| Color (admin) | `color` | `color` | `string` | `Silver` (pos 1) `Black` (2) `Purple` (3) … |`
- `SFCC:413` — the deprecated accessor, verbatim: *"Deprecated: Use getFilteredValues(ProductVariationAttribute) to get **the sorted and calculated collection of product variation attribute values**."*
- `SFCC:433` — `| `variationAttributes` | *"**The sorted array of variation attributes** assigned to the product. **This is applicable for product types "master", "variationGroup" and "variant" only.** It is read only."* |`
- `SFCC:434` — `| `variationAttributes` | *"**Sorted array of variation attributes information.** **Only for master, variation group, and variant types.** This array can be empty."* — **independent wording** |`
- `position` is also the **inheritance tie-breaker**, on three separate lines: `SFCC:097–098`, `SFCC:412`, `SFCC:458` — *"If the variant does not define an own value, the value is retrieved by fallback from **variation groups (sorted by their position)** or the variation master."*

**The hedge, verbatim:** `SFCC:183` — `| `position` (Data API only) |`. It is **absent** from the XSD value type (`SFCC:185–193`, exactly two elements and two attributes, none of them `position`) and **absent** from the Script API `ProductVariationAttributeValue` member list (`SFCC:165–172`). The record contains no sentence saying whether `position` is merchant-set, import-order-derived or platform-assigned.

Two unrelated `position` fields, recorded so they are not confused with it:
- `SFCC:248` — `| `<position>` | `simpleType.CategoryAssignment.Position` — enum whole, **4**: `none`, `top`, `bottom`, `auto` | 0..1 |`
- `SFCC:224` — `Category` exposes `position` among its 17 properties

**Maps to: a stored position/sort column on the value; AMBIGUOUS on who decides it.**
**Stated vendor rationale:** the fallback sentence (`SFCC:097–098` / `:412` / `:458`) states the vendor's *use* of position — resolving inherited values — but not the picker order.

### Q5 · VALUE IDENTITY / RENAME → **YES — `@value` is the required stable key and `<display-value>` the 0..N localizable label; and the record records a historical shape change from `@value-id` to `@value`.**

- `SFCC:177–178` — `@value` **1..1 required**, `NonEmptyString.256`, `minLength: 1` · `<display-value>` localized, 0..N
- `SFCC:185–193` — the XSD proves the split: `value` is `use="required"`; `display-value` is `sharedType.LocalizedString`, `minOccurs="0" maxOccurs="unbounded"`. **So one immutable key can carry many localized labels — a rename is a `display-value` edit and does not touch the key products point at.** (The record quotes the schema; it does not state this consequence in prose.)
- `SFCC:329` — *"**Shape difference, retained:** the deprecated axis-value form carries `@value-id`; the current form carries `@value`. **No date is attached to any XSD deprecation annotation.**"*
- `SFCC:319` — `| **355** | `complexType.Product.ImageGroup/@variation-value` | *"Deprecated. Please use the variation elements (complexType.Product.ImageGroup.VariationAttributeValue)."* ⚠️ **omitted by revision 1, and it is inside this record's own subject** — the live form is a two-attribute type carrying `attribute-id` **and** `value` separately |`
- `SFCC:322` — `| 653 / 662 | `…Attribute.Values` / `…Attribute.Value` | *"Deprecated please use the element variation-attribute-values (complexType.VariationAttribute.Values)…"* |`
- `SFCC:158` — *"And the Script API states the relation between them: *"The ID of the product attribute defintion related to this variation attribute. This ID matches the value returned by ObjectAttributeDefinition.getID() for the appropriate product attribute definition. **This ID is generally different than the ID returned by getID()**."* [sic, "defintion"]"*
- `SFCC:644` (C9) — *"**The axis's two IDs "generally differ", but do not in the vendor's own example.** *"This ID is generally different than the ID returned by getID() ."* In `DataProductExpandResult`: `attributeDefinitionId: color` and `id: color` — identical; likewise `memorySize`."*
- `SHARED:197` — an adjacent use of the value as an identity string: *"Salesforce is the clearest: an image group carries "an ordered list of variation attribute values… If an image group applies for all the red variants, for example, it will have one of these elements, namely \"color=red\"", groups with no tag "represent the \"fallback\" images""*

**Maps to: YES — a stable code separate from the label.** The record states no behavioural rename test.
**Stated vendor rationale:** `SFCC:158` (why two ids exist) and `SFCC:311` (why value lists moved off `ObjectAttributeDefinition`) — both verbatim vendor text.

### Salesforce — `shared-variation-attribute`, the requested item

The record never uses a CamelCase `SharedVariationAttribute`; it uses the XML element name and the boolean.

- `SFCC:160` (ii) — *"… `shared-variation-attribute` (a pure reference: `display-name` 0..N + required `attribute-id` + required `variation-attribute-id`, **no values**)."*
- `SFCC:320` — `| 533 | `complexType.Product.Variations.Attributes/attribute` | *"Deprecated please use the elements variation-attribute (complexType.VariationAttribute) or shared-variation-attribute (complexType.Product.VariationAttribute.Reference)."* |`
- `SFCC:402` — the import sequence line (quoted above)
- `SFCC:417` — the three exposures (quoted whole above)
- `SFCC:606` (§4 U9) — corpus-wide scarcity: *"The GitHub-search instrument was re-run: `org:SalesforceCommerceCloud "variation-attribute-id"` → 1 (the XSD itself) · `"shared-variation-attribute"` → 1 (same file) · `"variation-attribute-values" extension:xml` → 0"*

**Stated vendor rationale for shared vs local:** the `shared` accessor gloss (`SFCC:417`) and the `@merge-mode` annotation (`SFCC:419`) are the vendor's own words; **no design note explains *why* the choice exists.**

---

## 11. AKENEO PIM — `AKN` (#11069)

### Q1 · VALUE SHAPE → **(c)/hybrid AT THE STORAGE SEAM: the DEFINITION is a shared row with a code; the PRODUCT stores the code STRING inside JSON, with NO foreign key.**

Section: `### 1.5 `AttributeOption` and `AttributeOptionValue` — the axis value` (`AKN:313`)

- `AKN:316–323` — the mapping, whole:
  `AttributeOption   table pim_catalog_attribute_option`
  `  uniqueConstraint searchunique_idx (code, attribute_id) · id · code string(100) · sortOrder`
  `  attribute     manyToOne → AttributeInterface, inversedBy options, attribute_id nullable: false, CASCADE`
  `  optionValues  oneToMany → AttributeOptionValue, indexBy locale, orphanRemoval true`
  `AttributeOptionValue   table pim_catalog_attribute_option_value`
  `  uniqueConstraint searchunique_idx (locale_code, option_id) · id`
  `  locale string(20) nullable col locale_code · value string(255) nullable`
  `  option  manyToOne → AttributeOption, option_id nullable: false, CASCADE`
- `AKN:328` — `| `AttributeOption.code` | string(100), unique **per attribute** | 1..1, immutable | `black` |`
- `AKN:330` — `| `AttributeOptionValue.locale` / `.value` | string(20) / string(255) | 0..1 each | `fr_FR` / `Noir` |`
- `AKN:331` — `| product-side value | **string, the option code, inside `raw_values` JSON** | 0..N per attribute | `"brown"` |`
- `AKN:333–335` — *"**✅ The definition is a shared row; the product copies the code**. `OptionValue.php` carries `/** @var string Option code */ protected $data;`, and — ⚠️ printed whole, revision 1 dropped the conditional — line 45 is `return null !== $this->data ? '['.$this->data.']' : '';`"*
- `AKN:337–339` — *"**✅ Referential integrity is a validator, not a foreign key**: `if (!in_array(strtolower($value->getData()), ($existingOptionCodes[$value->getAttributeCode()] ?? []), true))` → `ATTRIBUTE_OPTION_DOES_NOT_EXIST`, attached under `getters: values:` in both `product.yml` and `productmodel.yml`."*
- `AKN:345–350` — *"**✅ Second publication system**, badge "1.7 2.x 3.x 4.0 5.0 6.0 7.0 SaaS | CE EE": "Some type of attributes offers list of choices. These available choices are attribute options." / "Only attribute of type simple select, multiselect, reference data simple select and reference data multiselect can have options." The copy/shared split is visible in one wire payload: `"color": [{"…","data": "brown"}]` — a bare code — beside `"main_color"` carrying `linked_data` with the resolved labels, "in read-only. You won't be able to patch or post it.""*
- `AKN:377` / `AKN:422` — the storage: `| `rawValues` | json, col `raw_values` | 1..1 | `{"name": [{"locale": null, "scope": null, "data": "jack"}]}` |` · `| `rawValues` | json | 1..1 | `{"sku": [{"data": "1111111195"}], …}` |`
- `AKN:883` (§4 U8) — *"**Whether `pim_catalog_product.raw_values` has any DB-level constraint tying an option code to `pim_catalog_attribute_option`** | `SHOW CREATE TABLE pim_catalog_product` on an install — generated columns, CHECK constraints, triggers | §0 H2. The application-level route is established (`AttributeOptionsExistValidator`); **the storage-level one was never inspected**."*
- `MATRIX:265` — *"Akeneo moved from rows to raw_values JSONB in 3.0"*
- `X:1035` — *"**Akeneo** — **shared definition row; the product copies the code.** … the product side stores *"a copied code string inside `raw_values` JSON"* … ❗ **Referential integrity is a validator, not a foreign key**."*

**Maps to (c) — a shared row on the definition side, a copied code string on the product side, with integrity by validator rather than FK.**

**Stated vendor rationale:** `AKN:345–347` — *"Some type of attributes offers list of choices. These available choices are attribute options."* / *"Only attribute of type simple select, multiselect, reference data simple select and reference data multiselect can have options."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) on the attribute definition. There is NO per-attribute free/closed flag — the TYPE is the switch, and on CE the type is immutable.**

Section: `### 1.4 `Attribute` — the attribute definition, and what an axis is (q9)` (`AKN:221`)

- `AKN:243` — `| `options` | oneToMany → `AttributeOption` | 0..N | 10 for `color` |`
- `AKN:251–257` — *"**✅ q9 — an axis value is governed by the attribute's `type`**. **There is no per-attribute switch between free text and a list; the switch *is* the type.** **On CE the type is immutable**, and ⚠️ **the Serenity help centre documents a shipped type-change feature** while the 7.0 help page says the attribute must be deleted — Companion A §5 **C10**. `attribute.yml` (19,880 B) declares `Immutable: properties: [code, type, scopable, localizable, metricFamily, unique, reference_data_name]`; the spec agrees machine-readably — `attribute.type = {"type": "string", "enum": [19 values], "x-immutable": true, "x-validation-rules": "The type is one of the following values"}`."*
- `AKN:259–268` — *"**✅ The CE type list is 19 constants** — ⚠️ reproduced at 19, not revision 1's 18, on both branches: `pim_catalog_boolean`, `_date`, `_file`, `_identifier`, `_image`, `_metric`, `_number`, `_multiselect`, `_simpleselect`, `_price_collection`, `_textarea`, `_text`, `pim_reference_data_multiselect`, `pim_reference_data_simpleselect`, `akeneo_reference_entity`, `akeneo_reference_entity_collection`, `pim_catalog_asset_collection`, `pim_assets_collection`, `pim_catalog_table`. The **runtime registry** is smaller — `attribute_types.yml` tags **14 aliases**"*
- `AKN:340–343` — the constraints on the option row: *"`UniqueEntity [code, attribute]`; `AttributeTypeForOption` with `['pim_catalog_simpleselect', 'pim_catalog_multiselect']`; `Immutable [code, attribute]`; `code` `NotBlank`, `Regex /^[a-zA-Z0-9_]+$/`, `Length max 100`; `attributeoptionvalue.yml` `value` `Length max 255`."*

**Which attributes a product carries is the FAMILY, not the category:**

Section: `## §3 · The flavour test` (`AKN:798`)

- `AKN:806–810` — *"**The mechanism, stated first.** Whether a product carries an attribute is determined by exactly two facts and by nothing else in this model: 1. the attribute exists as a `pim_catalog_attribute` row; and 2. the product's **Family** lists it, through `pim_catalog_family_attribute`."*
- `AKN:812–818` — *"Enforcement, measured rather than assumed: for entities that are part of a variant structure, `OnlyExpectedAttributesValidator` rejects a value outside the family, with the vendor's own message `can_have_family_variant_unexpected_attribute: 'Cannot set the property "%attribute%" to this entity as it is not in the attribute set'`. For a product with **no** family the vendor states the consequence itself — "Nevertheless, a product does not have to belong to a family. In this case, it has no default attributes." — and the CE code path early-returns, so end-to-end behaviour for a simple product is **OPEN** (§4 U3)."*
- `AKN:853–856` — *"**Category is not a determinant.** `categories.csv` has 168 rows; `Category.orm.yml` contains `attributes` **0 times**; and the whole `src/Akeneo/Category` component returns 0 for every attribute-, family- and axis-shaped pattern with the controls firing at 203 / 62 / 117 elsewhere."*
- `AKN:840` — measured on the shipped fixtures: *"| The stand-in, `color` (`pim_catalog_simpleselect`, 10 options) | listed by **3** families — `accessories`, `clothing`, `shoes`; `size` by the same three; `main_color` by `mugs`, `tshirts`; `eu_shoes_size` by `shoes` alone. Each of the 18 simple-select attributes maps to **1–3** families |"*
- `AKN:841` — *"| Products carrying a non-empty value for an attribute **not** in their family | **0 of 1,238** |"*

⚠️ **"Flavour" itself could not be measured** — `AKN:820–828`: *"Corpus: the CE demo fixture set shipped on `main` … Pattern `flavou?r`, case-insensitive → **0 hits in every file and 0 files across both fixture sets**. Positive control that the instrument would find an attribute if one existed: `^color;` in `attributes.csv` = **1**, substring `colou?r` = **5**. The mechanism was therefore measured with **`color`** as the stand-in, and the count below is not "zero categories require flavour" — it is that **no flavour attribute exists in any artifact this study could read.**"*

**Maps to (A) — one option list per attribute, globally, with the family deciding which attributes apply.**

**Stated vendor rationale:** `AKN:858` — *"A family is a set of attributes that are shared by products belonging to this family."*

### Q3 · QUANTITIES → **A NUMBER PLUS A UNIT — the `pim_catalog_metric` type — AND it is axis-eligible. This is the reference case the card names.**

Section: `### 1.9 `MeasurementFamily` and `Unit` — units` (`AKN:480`)

- `AKN:482–490` — the model, whole: `MeasurementFamily  table akeneo_measurement — columns code, labels JSON, standard_unit, units JSON` / `  MeasurementFamilyCode $code · LabelCollection $labels · UnitCode $standardUnitCode` / `  array $units                 public const MIN_UNIT_COUNT = 1;` / `Unit` / `  UnitCode $code · LabelCollection $labels · array $convertFromStandard · string $symbol` / `  Assert::allIsInstanceOf($convertFromStandard, Operation::class)` / `  Assert::notEmpty($convertFromStandard, 'Expected unit to have at least one operation')`
- `AKN:492–499` — *"**✅ One shared row per measurement family; the product copies the unit code**. Constructor assertions, all five, lines 29–33: `Assert::allIsInstanceOf($units, Unit::class); Assert::minCount($units, self::MIN_UNIT_COUNT); $this->assertStandardUnitExists(…); $this->assertStandardUnitOperationIsAMultiplyByOne(…); $this->assertNoDuplicatedUnits($units);`"*
- `AKN:501–508` — *"**✅ A metric product value is typed — `{amount, unit}` on the wire, `{amount, unit, base_data, base_unit, family}` in storage**. `AbstractMetric` holds `$data` (float), `$unit`, `$baseData`, `$baseUnit`, `$family`; `MetricValue::__toString()` is `sprintf('%.4F %s', $data, $this->data->getUnit())`. ⚠️ The standard normalizer has a **null branch revision 1 omitted**, lines 28–46: the comment `// if true, we return a string to avoid to loose precision (http://floating-point-gui.de)`, then `if (null === $amount) { return ['amount' => null, 'unit' => null]; }` before `return ['amount' => $amount, 'unit' => $metric->getUnit()];`. The storage normalizer adds `$rawMetric['base_data']`, `['base_unit']`, `['family']`."*
- `AKN:510–517` — *"**✅ Vendor prose, quoted as printed** ⚠️ (audit 3: revision 1 inserted spaces before the colons), "#Metric attribute" badge "1.7 2.x 3.x 4.0 5.0 6.0 7.0 SaaS | CE EE": *"Whenever the attribute's type is pim_catalog_metric, the data field should contain an object with following fields: amount: a string representing a number if the decimals_allowed property of the attribute is set to true, otherwise an integer, containing amount value unit: a string representing the metric unit for the specified amount symbol: a string representing the symbol of the unit (e.g. g, kW), **resolved from the measurement family definition**"*. A third page adds, badge "5.0 6.0 7.0 SaaS | CE EE": *"If you want to store your product measurement, i.e. weight, height or power inside your PIM, you will need measurement families."*"*
- `AKN:241` — **the unit default is fixed on the DEFINITION while the actual unit rides on the VALUE**: `| `metricFamily` / `defaultMetricUnit` | string(100), nullable (`metricFamily` immutable) | 0..1 each | `Length` / `INCH` |`
- `AKN:519–523` — *"❗ **Two unrelated objects are both spelled "family"** — `pim_catalog_family` / `Product.family` (the attribute set) and `pim_catalog_attribute.metric_family` / `AbstractMetric::$family` / `akeneo_measurement.code` (the unit system)."*
- `MATRIX:1990` — a retrieved instance: `"weight":[{"…","data":{"amount":"800.0000","unit":"GRAM","symbol":"g"}}]`
- `MATRIX:2008` — the matrix's field-map line: *"weight.data {amount, unit} — a metric value — typed quantity with unit, drawn from a shared unit registry"*

**And the metric type IS a legal axis:**

- `AKN:270–279` — *"**✅ What may be an axis: a static 5-element array with no family, category or tenant parameter**, line 349: `public static function getAvailableAxesAttributeTypes(): array { return [AttributeTypes::METRIC, AttributeTypes::OPTION_SIMPLE_SELECT, AttributeTypes::BOOLEAN, AttributeTypes::REFERENCE_DATA_SIMPLE_SELECT, AttributeTypes::REFERENCE_ENTITY_SIMPLE_SELECT]; }` … resolving via [R-38] to `pim_catalog_metric`, `pim_catalog_simpleselect`, `pim_catalog_boolean`, `pim_reference_data_simpleselect`, `akeneo_reference_entity`. Callers, exhaustively — 4 hits in `src/*.php`."*
- `AKN:844` — measured on the vendor's own shipped fixture data: *"| Axis attributes used across the 9 family variants | `color`, `size`, `eu_shoes_size`, `material` (all `pim_catalog_simpleselect`) and **`display_diagonal` (`pim_catalog_metric`, `metric_family` `Length`, default unit `INCH`)** |"*
- `AKN:297–299` — *"❗ **The vendor's user-facing strings name four types where the array holds five**: `:77 Variant axes "%axis%" must be a boolean, a simple select, a simple reference data or a measurement`"*
- `AKN:943–948` (C3) — *"**Which attribute types may be an axis: six vendor statements, three different answers.** … | SaaS `openapi.json` / PaaS `family_variant_write.yaml` `x-validation-rules` | "Only the following attribute types are allowed: `simple select`, `multi select`, `reference data`, `metric`, `boolean`." | 5, **including multi select, excluding reference entity** | … | help 7.0 EE Flexibility/CE, and v5, v6 | "An attribute of the family could be a variant axis only if its attribute type is structured: / Simple select / Reference entity single link (EE only) / **Measurement** / Boolean (Yes/No) …" |"*
- `X:1049` — *"**Akeneo** — **typed, on a separate attribute type — and that type is axis-eligible.** … **`pim_catalog_metric` is one of the five axis-eligible types.** An option-typed value, by contrast, is a bare code."*
- `MATRIX:2163` — *"Akeneo: pim_catalog_metric is {amount, unit} from a shared unit registry — **and it is axis-eligible.**"*

Caps — `AKN:529`: `MAXIMUM_LEVEL_NUMBER = 2` and `MAXIMUM_AXES_NUMBER = 5`; `MATRIX:2316` — *"Akeneo caps only the measurement registry (300 families, 50 units, 5 operations)."*

**No dedicated net-content field** — `netContent` does not appear; the metric type is the general mechanism.

**Maps to: a number PLUS a unit stored on the value, with the unit vocabulary in a shared registry and a default unit on the definition — the card's third option, in its reference implementation.**
**Stated vendor rationale:** `AKN:516` — *"If you want to store your product measurement, i.e. weight, height or power inside your PIM, you will need measurement families."*

### Q4 · ORDERING → **a stored `sortOrder` / `sort_order` integer ON THE OPTION ROW.**

- `AKN:317` — the DDL line itself: `uniqueConstraint searchunique_idx (code, attribute_id) · id · code string(100) · **sortOrder**`
- `AKN:696` — the vendor's own API instance, whole: `**`AttributeOption`** — vendor doc page: `{"code":"canon_brand","attribute":"camera_brand","**sort_order**":1,"labels":{"de_DE":"Canon","en_US":"Canon","fr_FR":"Canon"}}`.`
- `AKN:697–698` — the shipped fixture, header and row: `Fixture row, header `code;label-de_DE;label-en_US;label-fr_FR;attribute;**sort_order**`: `black;Black;Black;Noir;color;0`.`
- `AKN:228` — note the attribute **definition** carries its own, separate `sortOrder`: `is_required · is_unique · is_localizable · is_scopable · **sortOrder** · useableAsGridFilter`
- `AKN:688` — and its instance: `{"code":"auto_exposure","type":"pim_catalog_boolean",…,"useable_as_grid_filter":true,"**sort_order**":39}`

⚠️ **Caveat — the record carries no vendor description of what `sort_order` does.** The field is present in the DDL, in the vendor's published JSON instance and in the shipped fixture; its semantics are never quoted. The only other occurrence in the corpus is a negative-search side-hit — `X:1103`: *"`max…attributes` over `src/Akeneo/Pim/Structure` → **2 hits, both `getMaxAttributeSortOrder`**, control `\bmax` → **161**."*

⚠️ **A scoping correction on the cross-record pass.** `X`'s explicit not-found list states that *"`sort_order` for Akeneo"* was **not found** — but that search covered only `#11031`, `#10966` and the matrix. **It IS in the Akeneo platform record**, at `AKN:317`, `AKN:696` and `AKN:697–698`. #10778 V4's claim of "Akeneo `sort_order`" is therefore corroborated by the platform record, and not by the decision records.

**Maps to: a stored position / sort column on the value.**
**Stated vendor rationale:** no stated rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **YES — `code` is immutable and unique per attribute, labels are per-locale, and the axis value is IMMUTABLE ONCE SET.**

- `AKN:328` — `| `AttributeOption.code` | string(100), unique **per attribute** | 1..1, **immutable** | `black` |`
- `AKN:330` — the label side, per locale: `| `AttributeOptionValue.locale` / `.value` | string(20) / string(255) | 0..1 each | `fr_FR` / `Noir` |`
- `AKN:340–343` — `UniqueEntity [code, attribute]`; `Immutable [code, attribute]`; `code` `Regex /^[a-zA-Z0-9_]+$/`
- `AKN:698–700` — *"**`AttributeOptionValue`** — ❗ **no standalone vendor JSON exists**; the API nests the per-locale labels inside the option, so the retrieved instance is the three label columns of that row (`Black` / `Black` / `Noir`), stored as three `pim_catalog_attribute_option_value` rows."*
- `AKN:352–360` — *"❗ **Axis-value comparison stringifies**: `UniqueVariantAxisValidator` (8,253 B) builds `$combination[] = (string)$value;`, joins with `','` and compares `\mb_strtolower($ownCombination) === \mb_strtolower(…)` against siblings; `OptionValue` stringifies as `[code]`, `MetricValue` as `sprintf('%.4F %s', …)`. Messages: `:61 'Cannot set value "%values%" for the attribute axis "%attributes%" on product model "%validated_entity%", as the product model "%sibling_with_same_value%" already has this value'`; `:72 'Variant axis "%variant_axis%" cannot be modified, "%provided_value%" given'`. ❗ **Axes are immutable once set**: spec `axes.x-immutable: true` and `level.x-immutable: true`; `variantattributeset.yml` carries `ImmutableVariantAxes`; en_US `:75 'Variant axes cannot be modified for the level "%level%"'`."*
- `X:1026` — *"A product's own axis value is **immutable** once set."*
- `AKN:1006–1027` (C10) — *"**Is an attribute's `type` immutable? CE and the SaaS spec say yes; the Serenity help centre documents a shipped feature that changes it, and the 7.0 help page says you must delete the attribute.** … *"Change attribute types / Previously, to change an attribute type, you would have to go through a tedious workaround by exporting product information, families and/or family variants, deleting the attribute, recreating another attribute, and reimporting the information. / We've now introduced greater flexibility for our users by enabling direct changes to attribute types."* The same page's "Non-eligible attributes" list: *"Please note that this change of property cannot be made, if the attribute is: / Set as the main image / Set as the main label / **Set as a variant axis** / …"*"*
- `AKN:1029–1036` (C11) — *"**Attribute code length: 255 in validation, 100 in the mapping and the DDL.** … The other pairs the §1.x row lists do reproduce: … `attributeoptionvalue.yml:4-5` 255 vs `AttributeOptionValue.orm.yml:20-23` 255. Open: **U18**."*

**Maps to: YES — a stable code separate from the label. A rename is a label edit; the code products point at never moves.**
**Stated vendor rationale:** no stated rationale in the record for rename specifically; the immutability constraints are quoted from source and from the spec.

---

## 12. WOOCOMMERCE — `WOO` (#11080)

### Q1 · VALUE SHAPE → **(c) HYBRID BY LEVEL — and the axis value is ALWAYS a copied slug, even for a global attribute.**

Section: `### 1.3 `WC_Product_Attribute` — the per-product attribute entry, and the axis flag` (`WOO:225`)

- `WOO:228–235` — the PHP data array, whole: `protected $data = array( 'id' => 0, 'name' => '', 'options' => array(), 'position' => 0, 'visible' => false, 'variation' => false, );`
- `WOO:240` — `| `id` | int — **0 = product-local, >0 = global definition row** | 1..1 | `1` / `0` |`
- `WOO:241` — `| `name` | string (taxonomy name, or free label) | 1..1 | `pa_color` / `Logo` |`
- `WOO:242` — `| `options` | array (term ids/names, or free strings) | 0..N | `["Blue","Green","Red"]` |`
- `WOO:246` — `| `is_taxonomy` | derived, `0 < $this->get_id()` | 1..1 | `1` |`
- `WOO:248–251` — *"**✅ There is no axis object: an axis is an ordinary attribute carrying one boolean**. Instrument I-V: the literal `'variation' => false,` occurs **exactly once** in corpus A. Setter, verbatim: `public function set_variation( $value ) { $this->data['variation'] = wc_string_to_bool( $value ); }`; the global-vs-local switch, verbatim: `public function is_taxonomy() { return 0 < $this->get_id(); }`"*
- `WOO:253–257` — *"**✅ The whole list lives in one serialized postmeta row on the product**, written at `class-wc-product-data-store-cpt.php:1085`: `$this->update_or_delete_post_meta( $product, '_product_attributes', wp_slash( $meta_values ) );`"*

Section: `### 1.5 `wp_terms` + `wp_term_taxonomy` in a `pa_*` taxonomy — the attribute value` (`WOO:351`)

- `WOO:364–369` — `| `term_id` | bigint unsigned | 1..1 | `31` |` · `| `name` | varchar(200) | 1..1 | `Chocolate` |` · `| `slug` | varchar(200) | 1..1 | `chocolate` |` · `| `taxonomy` | varchar(32) | 1..1 | `pa_flavour` |` · `| `parent` | bigint unsigned, default 0 | 0..1 | `0` (attribute taxonomies are flat) |` · `| `count` | bigint | 1..1 | `5` |`
- `WOO:380–384` — *"**✅ The value row is shared across products**. Write, verbatim: `wp_set_object_terms( $product->get_id(), wp_list_pluck( (array) $attribute->get_terms(), 'term_id' ), $attribute->get_name() );`. Live: `pa_flavour` terms 30 `Vanilla` and 31 `Chocolate` each carry `count 5` — **five products point at the same two rows**. Vendor prose for the same fact: "so they're easy to update across the entire store"."*

Section: `### 1.6 `attribute_<key>` postmeta on a variation — the axis value, copied` (`WOO:386`)

- `WOO:390–392` — `| `meta_key` | varchar(255) — `'attribute_' . sanitize_title( $attribute_name )` | 1..1 | `attribute_pa_color` |` · `| `meta_value` | longtext — **a slug string, not a term id** | 1..1 | `red` |` · `| `''` (empty) | — | — | **means "any"** |`
- `WOO:394–398` — *"**✅ A variation stores its axis value as a copied string, always, even for a global attribute**, verbatim: `update_post_meta( $product_id, 'attribute_' . $key, wp_slash( $value ) );`. Read side: `$variation_attributes[ $name ] = $value[0];` (⚠️ :1209, revision 1 said :1210), and the empty value is documented in the source itself: `$variation_attributes[ $attribute ] = ''; // Add it - 'any' will be assumed.`"*
- `WOO:400–402` — *"⚠️ **Live instance**: rows `(27, attribute_pa_color, 'red')` and `(27, attribute_logo, 'No')` — the slug string `red`, **not term_id 20**, which the lookup table stores for the same value (§1.10). The vendor's 2019 sample carries the identical shape."*
- `WOO:541–543` — *"**✅ The lookup table re-normalizes the variation's copied slug back to a term id, for global attributes only**. Local attributes are skipped with the source's own comment: `// Custom product attribute, not suitable for attribute-based filtering.`"*
- `X:1034` — *"**WooCommerce** — **both, by level, and the axis value is always copied.** … But the *variation's* axis selection is `update_post_meta(…)` — a **slug string, not a term id**."*

**Maps to (c) — shared term row for a global attribute, free string for a local one, and a copied slug on every variation regardless.**

**Stated vendor rationale**, verbatim — `WOO:337–341`, quoted with the page's own typographic apostrophe:
> *"Attributes can be defined globally, so they’re easy to update across the entire store, and available to be used on any product, or;"*
> *"Attributes can be defined individually, at the product level, and they will only exist for that single product."*
> (⚠️ *"revision 1 printed a straight apostrophe; the exact-string search over the page text fails on `they're` — 0 hits — and succeeds on `they’re` — 1 hit."*)

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) one global attribute definition — six columns, none referencing a category or product type — and the list is OPEN: values are created on write.**

Section: `### 1.4 `{prefix}woocommerce_attribute_taxonomies` — the global attribute definition` (`WOO:281`)

- `WOO:284–293` — the DDL whole: `attribute_id bigint(20) unsigned NOT NULL auto_increment, attribute_name varchar(200) NOT NULL, attribute_label varchar(200) NULL, attribute_type varchar(20) NOT NULL, attribute_orderby varchar(20) NOT NULL, attribute_public int(1) NOT NULL DEFAULT 1, PRIMARY KEY (attribute_id), KEY attribute_name (attribute_name(20))` — `includes/class-wc-install.php:1822-1831`
- `WOO:301` — `| `attribute_type` | varchar(20) — live enum `['select']` | 1..1 | `select` |`
- `WOO:305` — *"**✅ Six columns, and none of them references a category, a product type, or any grouping object**"*
- `WOO:310–314` — *"**✅ Each definition row is registered as a WordPress taxonomy against every product**, verbatim at `class-wc-post-types.php:322`: `register_taxonomy( $name, apply_filters( "woocommerce_taxonomy_objects_{$name}", array( 'product' ) ), apply_filters( "woocommerce_taxonomy_args_{$name}", $taxonomy_data ) );` with `'hierarchical' => false` at **:270**."*
- `WOO:316–320` — *"**✅ The live install serves exactly those six fields and no more**. `OPTIONS /wp-json/wc/v3/products/attributes` returns schema title `product_attribute` with `id`, `name`, `slug`, `type` (enum `['select']`, default `select`), `order_by` (enum `['menu_order','name','name_num','id']`, default `menu_order`), `has_archives`; and `DESCRIBE wp_woocommerce_attribute_taxonomies` returns the six columns of the DDL."*
- `WOO:322–330` — *"**✅ No attribute-set, attribute-group, attribute-family or attribute-template object exists in core**. … Instrument **I-A1**: `attribute[_-]?(set|group|family|profile)s?` case-insensitive over corpus A (2,833 `*.php`, 20,564,126 bytes, GNU grep 3.12) → **1** hit, a false positive. **Positive control** `attribute[_-]?terms?` → **158**."*

Section: `## §3 · The flavour test` (`WOO:788`)

- `WOO:792–794` — *"**Answer, measured: only a per-product entry in that product's own `_product_attributes` postmeta** — either referencing a global definition (attribute 3, taxonomy `pa_flavour`, with terms) or standing alone as a product-local free-text attribute ("Flavour note"). **No product type, browse category, family, set or template participates.**"*
- `WOO:848–853` — *"⚠️ **What the count is, stated precisely.** … **WooCommerce publishes no attribute-per-category or attribute-per-type taxonomy to count**, because the definition row has no scope column (`DESCRIBE`, six columns) and every `pa_*` taxonomy is registered against `array( 'product' )` without qualification. … not an inspection of a governing taxonomy, because no such object exists (I-A1, §1.4)."*
- `WOO:839–846` — the three schema-membership tests: *"the `product_attribute` resource has **six** properties and none names a type or a category; the `product_cat` resource has **nine** and none names an attribute; … **I-A5** (`allowed_attributes|permitted_attributes|attribute_whitelist|applicable_attributes`) returns **3** PHP hits — all three in `CheckoutFields.php`, an HTML-attribute allow-list — and **0** over corpus A's 605 `.ts`, 1,079 `.tsx` and 226 `.js` files. **It has no positive control.**"*

**The list is OPEN — values are created on write:**

- `X:1122` — *"**WooCommerce** — **open at every level.** The attribute list is a serialized `_product_attributes` postmeta blob, not a schema; the value list is **open on write** — saving a product with an option name that is not yet a term creates the term, and the save path's own comment says so (`// Text based attributes - Posted values are term names.`); and a variation's axis value is not validated against the parent's list at all."*
- `X:1025` — *"**WooCommerce** — **neither.** An empty axis value on a variation is documented in the source itself to mean *any* … And a variation's value is **not validated against the parent's list**: the controller resolves the name to a term slug if a term exists and otherwise just `sanitize_title()`s it. **Live: `POST /wc/v3/products/10/variations` with `"option":"Mint"` returned 201, stored `attribute_pa_flavour = 'mint'`, and created no term — the `pa_flavour` term count stayed 3.**"*
- `MATRIX:2379` — *"WooCommerce: the value list is created on write."*

⚠️ **An experimental second surface exists and is explicitly excluded** — `WOO:343–349`: *"`src/Api` publishes a `ProductAttribute` type (951 bytes) with `name`, `slug`, `options`, `position`, `visible`, `variation`, `is_taxonomy` … It is **off by default, experimental, UI-hidden and PHP ≥ 8.1 gated** … its README says "**DO NOT** use this code in released extensions or in production environments" … **It carries no VERIFIED row in this document.**"*

**Maps to (A) for a global attribute and (C) for a product-local one — with (D) in practice, because nothing constrains the list at write time.**

**Stated vendor rationale:** `WOO:337–341` (quoted above) is the only vendor statement.

### Q3 · QUANTITIES → **BARE LABEL. Six fields, none of them a quantity, a unit or a dimension. Nothing.**

- `WOO:372–378` — *"**✅ The attribute value is a bare label — six fields, none of them a quantity, a unit or a dimension**. The `product_attribute_term` resource is `id` (integer, readonly), `name` (string), `slug` (string), `description` (string), `menu_order` (integer), `count` (integer, readonly); the product side publishes `options` as an array of string and the variation side `option` as a string. Instrument **I-A7**: `unit_of_measure|attribute_unit|term_unit|attribute_value_unit|measurement_unit` over corpus A → **2** hits, both store-level onboarding units; **positive control** `weight_unit` → **322**. **I-A7b** over the three attribute-defining files (40,222 bytes): `unit` → **0**."*
- `WOO:370` — `| REST projection | `id`, `name`, `slug`, `description`, `menu_order`, `count` | — | `{"id":31,…,"count":5}` |`
- `X:1047` — *"**WooCommerce** — **bare label.** The value resource is six fields … none a quantity, unit or dimension … The only numeric handling is a sort-time SQL rewrite, `ORDER BY t.name+0`."*
- `MATRIX:2174` — *"WooCommerce: six bare fields; numeric sort is an ORDER BY name+0 hack."*

**No dedicated net-content field.**

**Maps to: text / bare label, with no unit anywhere near a value.**
**Stated vendor rationale:** no stated rationale in the record.

### Q4 · ORDERING → **a PER-DEFINITION SORT MODE with four options, defaulting to a stored `menu_order` — and the numeric mode is MEASURED BROKEN.**

- `WOO:289` — the column: `attribute_orderby varchar(20) NOT NULL,`
- `WOO:302` — `| `attribute_orderby` | varchar(20) — enum `menu_order|name|name_num|id` | 1..1 | `menu_order` |`
- `WOO:319` — live `OPTIONS`: `order_by` (string, enum `['menu_order','name','name_num','id']`, default `menu_order`)
- `WOO:370` / `WOO:453` — the value itself carries `menu_order`: `| `menu_order` | integer | 0..1 | `0` |`
- `WOO:404–413` — *"❗ **`name_num` is a sort-time SQL rewrite**. (⚠️ Revision 1 called it "the only numeric handling anywhere"; **no instrument was run for numeric handling elsewhere in the corpus**.) `order_by` is validated against `array( 'menu_order', 'name', 'name_num', 'id' )`; `name_num` maps to orderby `name` plus a `force_numeric_name` flag, and the clause is rewritten at **:108** (revision 1 said :107), verbatim: `$clauses['orderby'] = str_replace( 'ORDER BY t.name', 'ORDER BY t.name+0', $clauses['orderby'] );` — rewriting WordPress 7.1 `class-wp-term-query.php` :924-925 `$orderby = "t.$_orderby";` and :451 `$orderby = "ORDER BY $orderby";`. ⚠️ **A parallel PHP comparator is dead code**: `_wc_get_product_terms_name_num_usort_callback` is defined at :193-201 and instrument **I-A8** finds **1** hit — its own definition — and **0** call sites."*
- `WOO:415–425` — *"⚠️ **Observed, not derived (this replaces revision 1's reasoned "behavioural consequence").** On the live install, attribute 4 `numsort` (`order_by name_num`) with terms S, M, L, XL, Red, 2, 2 kg, 8 GB, 10, 10.5, 500 g: `wc_get_product_terms( 22, 'pa_numsort' )` with `SAVEQUERIES` emitted `SELECT DISTINCT t.term_id FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt … ORDER BY t.name+0 ASC` and returned `S | M | L | XL | Red | 2 | 2 kg | 8 GB | 10 | 10.5 | 500 g`; a **second, direct query** over the same terms on the same MariaDB 11.8.9 returned `XL, Red, S, M, L, 2 kg, 2, 8 GB, 10, 10.5, 500 g` with **eight** `Warning 1292 Truncated incorrect DOUBLE value` rows. ⚠️ **That second query's SQL text is in no artifact** … **The two queries order the ties differently; whether tie order is deterministic is OPEN** (Companion A §4 U1)."*

**Stated vendor rationale**, verbatim — `WOO:427–432`, quoted as printed:
> *"“Name”, (sort alphabetically)"* / *"“Name (numeric)”, (if the values are numbers)"* / *"**If your terms are numbers – like shoe sizes for example – use this sorting order so numbers will be properly ordered.**"* / *"“Term ID” or;"* / *"“Custom ordering” where you decide by dragging and dropping the terms in the list when configuring the terms (see below)."*
> (⚠️ *"revision 1 interleaved its own paraphrase, "(for numeric values like shoe sizes)", inside the quotation marks."* The admin label is `'Name (numeric)'`.)

> This is the direct source of #10778 V4's WooCommerce clause. The record **confirms the mechanism and the breakage** but **corrects the epistemics** — see `WOO:67` under PART 2 §10c. V4's specific illustration (*"putting `1.5 L` before `600 ml` and collapsing `M` to 0"*) is **not** the measured output; the measured output is at `WOO:419–420`.

**Maps to: a stored position column (`menu_order`) as the default, with three alternative sort modes selectable per definition — the only platform in the set that offers an inferred-numeric mode at all.**

### Q5 · VALUE IDENTITY / RENAME → **for a global attribute, `term_id` + `slug` + `name` are separate; BUT the variation stores the SLUG, so the slug is load-bearing. Rename is not addressed.**

- `WOO:364–366` — `term_id` `31` · `name` `Chocolate` · `slug` `chocolate` — three distinct columns
- `WOO:391` / `WOO:400–402` — the variation stores `'red'`, **the slug**, not `term_id 20`
- `WOO:536–539` — the lookup table's composite PK is `(product_or_parent_id, term_id, product_id, taxonomy)` and `| row for a local attribute | — | **never written** |`
- `WOO:548–550` — *"Live: `DESCRIBE` matches the DDL and rows for product 11 are `(27,11,pa_color,20,1,1), (28,11,pa_color,17,1,1), (29,11,pa_color,16,1,1), (34,11,pa_color,16,1,1)` — **no row for the local `Logo` axis**."*
- `WOO:558–561` (§1.11 `_default_attributes`) — *"**✅ A separate postmeta row on the parent, not on any variation**. Live, after a PUT, the REST projection is `[{"id":1,"name":"color","option":"red"},{"id":0,"name":"Logo","option":"No"}]`; **the `_default_attributes` postmeta row itself was not read back** (Companion A §4 U16)."*

A whole-file search for `rename` returns only an unrelated category note — `WOO:469`: *"…be named “Uncategorized” and can not be deleted. However, you can rename the category."*

**Maps to: a stable `term_id` exists on the definition side, but the variation binding is by SLUG, so a slug change breaks it. Rename semantics: not addressed.**
**Stated vendor rationale:** no stated rationale in the record.

---

## 13. COMMERCETOOLS COMPOSABLE COMMERCE — `CT` (#11081)

### Q1 · VALUE SHAPE → **AMBIGUOUS — "NOT ESTABLISHED", and the record withdraws its own earlier reading as uncited.** This is the one platform the matrix files that way.

Section: `### 1.9 `Attribute` — the stored value` (`CT:445`)

- `CT:448–463` — the RAML as printed, whole:
  `Attribute                          [api-specs/api/types/product/Attribute.raml, 1,693 B], as printed:`
  `  name: (identifier): true · (elementIdentifier): true · type: string · description: | Name of the Attribute.`
  `  value: (expandable): true · #    type: AttributeValue | AttributeValue[] · type: any`
  `         #    type: string | number | datetime | date-only | time-only | boolean | AttributeLocalizedEnumValue | AttributePlainEnumValue | Reference | Money | LocalizedString | Attribute[]`
- `CT:465–467` — *"⚠️ Five commented lines, at `:15` and `:17-20`; revision 1 omitted the first without an ellipsis and revision 2 stopped at `type: any`, omitting the other four. `AttributeValue.raml` (246 B) types the union: `string | number | datetime | date-only | time-only | boolean | AttributeLocalizedEnumValue | AttributePlainEnumValue | Reference | Money | …`"*
- `CT:469–477` — *"**✅ The per-type rule for what goes in `value`, from the same file, elisions marked**: "The [AttributeType] determines the format of the Attribute `value` to be provided:\n- For [Enum Type] and [Localized Enum Type], **use the `key` of the [Plain Enum Value] or [Localized Enum Value] objects, or the complete objects as `value`.**\n … \n- For [Nested Type] Attributes, use the list of values of all Attributes of the nested Product as `value`.\n- For [Reference Type] Attributes, use the [Reference](ctp:api:type:Reference) object as `value`." — the elided bullets say the same for `AttributeLocalizableTextType` → `LocalizedString`, `AttributeMoneyType` → `Money` and `AttributeSetType` → "the entire `set` object"."*
- `CT:479–486` — **the withdrawal, verbatim**: *"⚠️ **The absence, now instrumented** (revision 2 asserted it with none): `copied|copy|shared|duplicat|denormali|snapshot|inherit` case-insensitive over C1b (51 files, 36,993 B) → **3 lines, none about how a value is stored** — the two enum-uniqueness sentences quoted in §1.4 and `AttributeSetType.raml`'s "…defines a set (without duplicate elements) with values of the given `elementType`.…"; the same pattern over `Attribute.raml` (1,693 B) and `AttributeValue.raml` (246 B) → **0**. Control: `SameForAll` over C1b → **2 files**. **Revision 1 wrote both "the literal value is copied onto every variant that carries it" and "not a foreign key", citing nothing for either.** The field is `value: any`; the instances are in §2c."*
- `CT:488–500` — *"**✅ `reference` is the one type whose value is declared to be a pointer**. `AttributeReferenceTypeId.raml` (1,902 B), whole — **17 values**: `associate-role`, `business-unit`, `cart`, `cart-discount`, `category`, `channel`, `customer`, `customer-group`, `key-value-document`, `order`, `product`, `product-type`, `review`, `shipping-method`, `state`, `variant`, `zone`. The newest is `variant`, ⚠️ dated **2026-07-14** by the release note … "variant: |\n    References a [Variant](ctp:api:type:Variant). Only available for Projects with `productCatalogModel` set to `Modular` ([BETA])."*
- `CT:502–505` — *"**✅ Second route, SDL**: `type RawProductAttribute { attributeDefinition: AttributeDefinition  name: String!  value: Json!  attributesRaw: [RawProductAttribute!]  referencedResource: ReferenceExpandable … }` (8919-8927); `type PlainEnumValue { key: String!  label: String! }` (7160-7163). Third, the Merchant Center: "**List (enum)**: allows to select from predefined values. …""*

Instances — section `## §2c · ✅ Retrieved instance` (`CT:1295`)

- `CT:1297–1300` — *"⚠️ **Provenance, corrected.** **No emitted (live) instance of any object was retrieved** (§0 H1). Revision 1 labelled two files "REAL INSTANCE … retrieved, not constructed"; they are vendor documentation examples with 1970 timestamps and placeholder ids, and the sunrise files are import payloads, not responses."*
- `CT:1311` — the **expanded** form: `| `VariantAttributes` | `VariantAttributes.json` (961 B) — productKey `outdoor-jacket`, one variant `JACKET-RED-M`; metadata once (`color` lenum, `size` enum, labels `{"en":"Color","de":"Farbe"}`), then per variant `{"name":"color","value":{"key":"red","label":{"en":"Red","de":"Rot"}}}` |`
- `CT:1312` — the **bare-key** form and the unitless number: `| `Attribute` | `{"name":"weight","value":250}` (no unit anywhere in the payload); `{"name":"color","value":"blue"}`; the expanded `{key,label}` form above; `{"name": "bar-flavor", "value": "vanilla"}` |`
- `CT:1307` — `| `AttributePlainEnumValue` | sunrise `designer` enum, **217 `{key,label}` pairs** from `{"key":"360sweater","label":"360 Sweater"}`; `commonSize` **48**, `color` (lenum) **18**, `style` 3, `madeInItaly` 2, `gender` 2 | request payload |`

Cross-record: `X:1036` — *"**commercetools** — ⚠️ **not established, and the record says so.** … but how a *stored* value relates to it is undeclared: `Attribute` is `{name, value: any}`. … The record **withdraws** Revision 1's *"the literal value is copied onto every variant"* and *"not a foreign key"* as uncited."*
`MATRIX:2147` — `Not established1 | commercetools35 | Withdrew its own "copied, no FK" reading as uncited. |`
`X:122` — *"🔄 **commercetools left this bucket** — its Revision-2 record withdraws the "copied … not a foreign key" reading as uncited, so it moves to *not established* and the bucket is 4, not 5."*

**Maps to AMBIGUOUS.** Hedge quoted verbatim: `CT:486` — *"The field is `value: any`."* and `CT:479–485` — *"3 lines, none about how a value is stored … the same pattern over `Attribute.raml` and `AttributeValue.raml` → **0**."*
**Stated vendor rationale:** no stated rationale in the record for the storage shape.

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) on the AttributeDefinition — but scoped PER ProductType, so the same attribute name may carry different lists in different types.**

Section: `### 1.4 `AttributePlainEnumValue` / `AttributeLocalizedEnumValue` — the closed-list value` (`CT:248`)

- `CT:250–253` — `AttributePlainEnumValue      { key: string, label: string }             [477 B]` / `AttributeLocalizedEnumValue  { key: string, label: LocalizedString }    [505 B]`
- `CT:255–260` — *"**✅ The allowed-value list lives on the definition, inside the ProductType document, and is scoped per ProductType**. `AttributeEnumType.values` — "Available values that can be assigned to Products."; `AttributeDefinitionDraft.raml` — "**For `enum` or `lenum` Types and sets of these AttributeTypes, the enum values can be different for each ProductType.**" The *type*, by contrast, is not: "To use the same `name` in multiple ProductTypes, each AttributeDefinition must have the same `type`; otherwise, an [AttributeDefinitionTypeConflict] error is returned.""*
- `CT:262–263` — *"**✅ Uniqueness inside the list is enforced**: "A plain enum value must be unique within the enum, else a [DuplicateEnumValues] error is returned.""*
- `CT:227–228` — the two enum-bearing types: `| `enum` | AttributeEnumType.raml, 553 B | **`values: AttributePlainEnumValue[]`** |` · `| `lenum` | AttributeLocalizedEnumType.raml, 567 B | **`values: AttributeLocalizedEnumValue[]`** |`

Section: `## §3 · The flavour test` (`CT:805`)

- `CT:809–814` — *"**The answer the artifacts give: the Product's `ProductType`, and nothing else.** `Product.productType` is 1..1, required and "Cannot be changed"; `ProductType.attributes?` is the list of `AttributeDefinition`s; and "A Product or Product Variant can only use the Attributes defined in its Product Type." Whether a given variant must carry a value is `AttributeDefinition.isRequired` — "Whether the Attribute must have a value on a [ProductVariant]"; whether the value sits on the container or the variant is `AttributeDefinition.level`. **The browse `Category` plays no part** — instrument in the body, §1.10."*
- `CT:845–857` — the one flavour attribute in the vendor's own training collections, re-serialised whole: `{"type": {"name": "enum", "values": [{"key": "chocolate", "label": "Chocolate"}, {"key": "vanilla", "label": "Vanilla"}, {"key": "strawberry", "label": "Strawberry"}]}, "name": "bar-flavor", "label": {"en": "Flavor", "de": "Flavor"}, "isRequired": true, "isSearchable": true, "attributeConstraint": "CombinationUnique"}` — *"plus `bar-size` (enum `carton` | `case` | `pallette`, `CombinationUnique`, `isRequired` true)."*
- `CT:825–834` — the token instrument: `flavou?r` → **0 files** over C1 (5,387 files, 5,327,276 B), **0** over C2, **0** over C4, **0 files** over sunrise `data/`; positive controls `\bcolou?r\b` → 17 files / 16 tokens, `color` in `products.csv` → 2,317 tokens
- `X:1124` — *"**commercetools** — **closed by the ProductType and enforced by the API**: *"A Product or Product Variant can only use the Attributes defined in its Product Type."*"*

**Maps to (A), scoped per ProductType.**

**Stated vendor rationale — the clearest "why" for per-type value lists anywhere in the corpus**, `CT:816–823`:
> *a `T-Shirt` Product Type "might include Attribute types for: - `Color`: an enum with options like Red, Green, and Blue - `Size`: an enum with options like S, M, L, and XL - `Material`: a text string - `Neckline`: an enum with options like Crew and V-Neck", while "a `Jeans` Product Type might have Attribute types for: - `Color`: an enum with a different set of options like Blue, Black, and Grey - `Length`: a number - `Fit`: … - `Washing Instructions`: a text string" — and: "**You wouldn't ask for the `Neckline` of a pair of jeans, would you? By defining appropriate Attribute types for each Product Type, you prevent irrelevant or nonsensical data from being entered, maintaining data integrity and simplifying product management.**"*

### Q3 · QUANTITIES → **TYPED by `AttributeType`, but NO PHYSICAL UNIT ANYWHERE.** Money carries a currency, not a unit.

Section: `### 1.3 `AttributeType` — the 13 subtypes` (`CT:218`)

- `CT:220–221` — `AttributeType.raml` (230 B), whole: *"Umbrella type for specific attribute types discriminated by property `name`."* — `discriminator: name`
- `CT:225–231` — the 13, with the property each adds beyond `name`: `boolean · date · time · datetime · ltext` — **none**; `text · number · money` — **none** (`AttributeNumberType.raml`, 175 B, *"Attribute type for numeric values."*); `enum` → `values`; `lenum` → `values`; `reference` → `referenceTypeId`; `set` → `elementType`; `nested` → `typeReference`
- `CT:233–235` — *"**✅ Second route: the SDL declares `interface AttributeDefinitionType { name: String! }` (11509-11511) with exactly 13 implementers** … RAML and SDL match 13-for-13."*
- `CT:241–242` — *"**❗ `money` carries a currency, not a physical unit**: `Money.raml` has exactly `centAmount: number int64` ("Amount in the smallest indivisible unit of a currency … 5 CHF is specified as `500`") and `currencyCode: CurrencyCode`."*
- `CT:243–246` — *"⚠️ **The Merchant Center publishes 7 named types plus a set switch against the RAML's 13** (§5 #5), its step printed to the end this revision including the two sentences revision 1 cut: "      If an Attribute can contain multiple values at the same time, select **Create a set with this type**.\n\n      If selected, the Attribute can only be optional for a Product.""*

Section: `## §6 · The unit instruments, re-run` (`CT:1082`)

- `CT:1091–1093` — *"⚠️ **The vendor-synonym sweep behind "no unit-bearing attribute type"** — the record carried it; no published text showed it. Body §1.3 enumerates all 13 `AttributeType` subtypes, none of which declares a unit property; these are the searches for the vendor's other words for one"*
- `CT:1097` — `| `(unitOfMeasure|unit_of_measure|measurementUnit|unitCode|\buom\b|quantityUnit|\bunitName\b)` | C1 (5,387 files, 5,327,276 B), C2 (529,322 B), C4 (178,054 B) | **0** in each |`
- `CT:1098` — `| `^[[:space:]]*(unit|units|uom|unitOfMeasure|measurementUnit|unitCode)\??:` (anchored, i.e. a declared property) | C1 (5,327,276 B) | **0** |`
- `CT:1099` — `| `measur` case-insensitive | `api/types/product-type`, `api/types/product`, `api/types/variant` (179 files, 160,659 B) | **0** |`
- `CT:1100` — `| `measur` case-insensitive — **positive control**, the same grep on a corpus where the word does occur | C2 (529,322 B) | **19 lines** |`
- `CT:1084–1089` — *"⚠️ **The SDL `unit` split.** An audit reads: "`\bunit` (case-insensitive) over C2 → 31 lines: 'Business Unit'/'business-unit' prose ×23, `unitType: BusinessUnitType!` ×5, 'unit price' tax prose ×2, `UnitPriceLevel` ×1." Case-sensitive `\bunit` does not match `UnitPriceLevel`: over C2 the case-sensitive **27** is **25 Business-Unit/`unitType` + 2 "unit price"**, against **31** case-insensitive. The total, 27, stands."*
- `CT:1312` — the instance: `{"name":"weight","value":250}` — no unit anywhere in the payload

**A real-world hybrid inside one vendor dataset** — `CT:1327–1328`: *"The columns that **vary** across those rows are `variantId`, `sku`, `prices`, **`matrixId`** …, `commonSize` (17 distinct), **`size` (17 distinct free-text values `5`, `5.5`, … `13`)**, `isOnStock` … `color` is `multicolored` on all 17"* — i.e. `commonSize` is a 48-value enum while `size` on the same family is free text.

**No dedicated net-content field.**

**Maps to: typed by attribute type; NO unit on the value and none on the definition. Physical quantity has no home in this model.**
**Stated vendor rationale:** no stated rationale in the record for the absence.

### Q4 · ORDERING → **two dedicated order-change update actions on the ProductType.** The record names the count, not the action names.

- `CT:265–270` — *"**✅ Eight ProductType update actions maintain the list** — add / remove / change-key plus two label-change and **two order-change actions**. `RemoveEnumValues`: "If the Attribute is **not** required, the Attributes of all Products using those enum keys will also be removed in an [eventually consistent] way. If the Attribute is required, the operation returns an [EnumValueIsUsed] error." Errors: `EnumKeyAlreadyExists`, `EnumKeyDoesNotExist`, `EnumValueIsUsed`, `EnumValuesMustMatch`, `DuplicateEnumValues`."*
- `CT:272–275` — *"❗ **Nothing in the 21 update-action files changes an AttributeDefinition's `type`** — instrument: `changeAttributeType|ChangeAttributeDefinitionType|elementType|newType|change.*the type` over `api/types/product-type/updates/` (21 files, 16,367 B) → **0 files**. The published route is removal + re-add, under the data-loss warning in §1.2."*

⚠️ **A targeted search of `CT` for `changePlainEnumValueOrder` / `EnumValueOrder` returns only `CT:266`'s summary phrase.** The action names themselves are **not printed** in this record. #10778 V4 names one of them — `PRIOR:128`: *"commercetools `changePlainEnumValueOrder`"* — and that name is **not corroborated by the commercetools reference record**, which establishes only that two order-change actions exist.

**Maps to: a hand-set stored order, changed through an explicit reorder action on the definition.**
**Stated vendor rationale:** no stated rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **YES — `{key, label}` is the shape at both the definition and the value level; change-key and label-change actions exist; removal is unchecked and destructive.**

- `CT:250–252` — `AttributePlainEnumValue { key: string, label: string }` · `AttributeLocalizedEnumValue { key: string, label: LocalizedString }`
- `CT:153` (§ `### 1.2 `AttributeDefinition` — the attribute slot`) — the definition carries the same split: `type (AttributeType, required) · **name (^[A-Za-z0-9_-]+$, 2..256)** · **label (LocalizedString)** · isRequired · attributeConstraint · inputTip? · inputHint (SingleLine|MultiLine) · isSearchable · level`
- `CT:149` — *"**Not a resource**: no `id`, no `version`; reached only through its ProductType."*
- `CT:265–270` — `change-key` plus two label-change actions (quoted whole above); errors `EnumKeyAlreadyExists`, `EnumKeyDoesNotExist`
- `CT:1311` — the stored value expands to the full object with its key intact: `{"name":"color","value":{"key":"red","label":{"en":"Red","de":"Rot"}}}`
- `CT:192–196` — *"❗ **Removal is unchecked and destructive**, `ProductTypeRemoveAttributeDefinitionAction.raml` (1,168 B): "The `CombinationUnique` constraint is not checked when an Attribute is removed, and uniqueness violations may occur when you remove an Attribute with a `CombinationUnique` constraint." / "Removes an AttributeDefinition and also deletes all corresponding Attributes on all [Products] with this ProductType. **Data from deleted Attributes cannot be recovered.**""*
- `CT:919` (§4 U7) — *"**Which error the API returns when a written enum `value` key is not in `values`** | A live POST with an unknown key | §0 H1. **No error type in `api/types/error/` (193 files, 156,912 B) describes that case**"*
- `CT:198–203` — a terminology **rename** the record captures: *"⚠️ **`level` is dated, and its vocabulary was renamed**: public beta **2025-06-26** — "You can now configure and use Product Attributes for Products…" and, in the same note, "Product Attributes : to refer to Attributes defined at the Product level. Variant Attributes : … **They were previously known as \"Product Attributes.\"**" → general availability **2025-12-12**. Revision 1 used both terms and stated neither the dates nor the rename."*

**Maps to: YES — a stable `key` separate from the `label`, at both levels.**
**Stated vendor rationale:** `CT:266` — the `RemoveEnumValues` sentence explains what happens to products pointing at a removed key, which is the nearest the record comes to a rationale.

---

## 14. MAGENTO OPEN SOURCE / ADOBE COMMERCE — `MAG` (#11082)

### Q1 · VALUE SHAPE → **(b) A SHARED ROW referenced by an INTEGER, with the label fanned out per store view — never per product.** The other clean (b) in the set.

Section: `### 1.7 `eav_attribute_option` / `eav_attribute_option_value` — the axis value` (`MAG:352`)

- `MAG:355–368` — the DDL verbatim:
  `eav_attribute_option   (Eav/etc/db_schema.xml, verbatim)`
  `  <column xsi:type="int"      name="option_id"    unsigned="true" nullable="false" identity="true" comment="Option ID"/>`
  `  <column xsi:type="smallint" name="attribute_id" unsigned="true" nullable="false" identity="false" default="0" comment="Attribute ID"/>`
  `  <column xsi:type="smallint" name="sort_order"   unsigned="true" nullable="false" identity="false" default="0" comment="Sort Order"/>`
  `  FK attribute_id → eav_attribute.attribute_id CASCADE`
  `eav_attribute_option_value   value_id · option_id · store_id ·`
  `  <column xsi:type="varchar" name="value" nullable="true" length="255" comment="Value"/>`
  `  FK option_id CASCADE ; FK store_id → store.store_id CASCADE ; UNIQUE (store_id, option_id)`
  `eav_attribute_option_swatch   (Swatches/etc/db_schema.xml — 2,330 B)   swatch_id · option_id · store_id ·`
  `  <column xsi:type="smallint" name="type" … comment="Swatch type: 0 - text, 1 - visual color, 2 - visual image"/>`
  `  <column xsi:type="varchar" name="value" nullable="true" length="255" comment="Swatch Value"/>`
- `MAG:374` — `| option → option_value | UNIQUE (store_id, option_id) | ⚠️ **0..N, at most one per store** | `{"label": "Small", "value": "168"}` |`
- `MAG:375` — `| `value` (the label) | varchar(255), **nullable** | 0..1 per store | `Green` |`
- `MAG:377` — `| product's reference | `catalog_product_entity_int.value` (int) | 1..1 per (entity, attribute, store) | `{"attribute_code": "color", "value": "52"}` |`
- `MAG:379–380` — *"**✅ The value is a shared row referenced by an integer, not a string copied onto each product**; the label is fanned out **per store view**, never per product."*
- `MAG:388–393` — *"⚠️ **The two artifacts that carry `value_index`, unnamed in revision 1**: `OptionSelectBuilder.php:53` selects `'value_index' => 'entity_value.value',` from the join `['entity_value' => $superAttribute->getBackendTable()]` on `'entity_value.attribute_id = super_attribute.attribute_id'` and `'entity_value.store_id = 0'`; `ConfigurableAttributeData.php:60` reads `$optionId = $attributeOption['value_index'];`. That the value is an `option_id` follows from `getBackendTypeByInput()`'s `select → int` branch."*
- `MAG:402–406` — *"**✅ A vendor-published route for the sharing, outside the repo**: "You can enter one value for the Admin, and a translation of the value for each store view. If you have only one store view, you can enter only the Admin value and it is used for the storefront as well." The emitted GraphQL sample carries **one** uid on two surfaces — under `configurable_options.values` and under a variant's `attributes` — `"Y29uZmlndXJhYmxlLzkzLzUz"`, base64 `configurable/93/53`."*
- `MAG:1413` — a live instance: `{"id": 338, "attribute_id": "141", "label": "Size", "position": 0, "values": [{"value_index": 168}, {"value_index": 169}, {"value_index": 170}], "product_id": 2078}`
- `MATRIX:1716` — the product's own reference: `{"attribute_code": "color", "value": "52"}, {"size", "91"}, {"material", "148"}, {"pattern", "196"}`
- `X:1033` — *"**Magento** — **shared row, referenced by an integer.** … ⚠️ **There is no foreign key on `value`** — each of the five value tables declares exactly 3 FKs (`attribute_id`, `entity_id`, `store_id`), none on the value; **Revision 1's "application-enforced" gloss is withdrawn because no enforcing artifact was found.**"*

**Maps to (b).**
**Stated vendor rationale:** `MAG:402–404` — *"You can enter one value for the Admin, and a translation of the value for each store view."*

### Q2 · WHERE THE ALLOWED LIST LIVES → **(A) on the attribute definition — one list per attribute, globally. The free/closed switch is the attribute's input type, and an axis MUST be closed.**

Section: `### 1.8 Axis-value governance — free text vs closed list (q9, collected here for the first time)` (`MAG:408`)

- `MAG:410–414` — the mechanism, as the record lays it out:
  `the switch:            eav_attribute.frontend_input   varchar(50)`
  `axis eligibility:      usesSource()  →  'select' | 'multiselect' | source_model != ''`
  `narrower admin gate:   frontend_input = 'select' only`
  `the list:              eav_attribute_option rows, per attribute, created in the Admin or over REST`
- `MAG:419` — `| Open Source code (di.xml + observers) | text, textarea, texteditor, date, datetime, boolean, multiselect, select, price, media_image, swatch_visual, swatch_text, weee | **13** |`
- `MAG:420` — `| Open Source GraphQL SDL (`EavGraphQl/etc/schema.graphqls:106–123`) | BOOLEAN, DATE, DATETIME, FILE, GALLERY, HIDDEN, IMAGE, MEDIA_IMAGE, MULTILINE, MULTISELECT, PRICE, SELECT, TEXT, TEXTAREA, WEIGHT, UNDEFINED | **16** |`
- `MAG:422` — `| REST option management | `POST` `/V1/products/attributes/:attributeCode/options`; `PUT`/`DELETE` `…/options/:optionId`; `GET` `…/options` | 4 routes |`
- `MAG:424–426` — *"**✅ An axis value is always a member of a closed, per-attribute list — never free text — and the switch is the attribute's input type**: an attribute with `frontend_input = 'text'` fails `usesSource()` and is rejected by both `canUseAttribute()` sites — which the `POST …/:sku/options` route reaches neither of (§2 step 5) — and the admin picker is narrower still, `select` only."*
- `MAG:447–452` — *"⚠️ **A swatch is not a fourth input type in storage**: `swatch_visual`/`swatch_text` store as `frontend_input = 'select'` plus `catalog_eav_attribute.additional_data` key `swatch_input_type` ∈ {`text`, `visual`, `dropdown`}, and `InputtypePlugin.php:27` declares `['select', 'swatch_visual', 'swatch_text']` compatible. ❗ **Three inputs mapped by `getBackendTypeByInput()` are never offered by the Admin**: `gallery`, `image` and `weight`."*
- `MAG:454–457` — *"**✅ How a list is populated, in Adobe's words**, two consecutive bullets, not one sentence: "Under Manage Options, click Add Option." … "Enter the first value that you want to appear in the list." Emitted governed list: attribute `141` `size`, `"options": [{"label": " ", "value": ""}, {"label": "Small", "value": "168"}, …]`, `"source_model": "…\Source\Table"`. ⚠️ **No artifact read offers any per-attribute switch other than `frontend_input`**; a `text` attribute cannot be promoted."*

**Which attributes a product carries is a DIFFERENT mechanism, and the browse category is in neither:**

Section: `### 3.1 The determinant, in the vendor's own terms` (`MAG:757`)

- `MAG:759–767` — *"The rule is `Catalog/Model/ResourceModel/AbstractResource.php:86–91`, verbatim and complete: `protected function _isApplicableAttribute($object, $attribute) { $applyTo = $attribute->getApplyTo() ?: []; return (count($applyTo) == 0 || in_array($object->getTypeId(), $applyTo)) && $attribute->isInSet($object->getAttributeSetId() ?? $this->getEntityType()->getDefaultAttributeSetId()); }` — two conjuncts, `apply_to` and set membership; **the browse category is in neither**."*
- `MAG:769–773` — *"**(a) The attribute set** … Adobe states it twice: "The attribute set determines the fields that are available during data entry, and the values that appear to the customer." and, of the import column `attribute_set_code`, "Assigns the product to a specific attribute set or product template, according to product type.""*
- `MAG:775–777` — *"**(b) The attribute's `apply_to` list of product types** — `catalog_eav_attribute.apply_to`, varchar(255) nullable, a comma-separated `type_id` list. Core `color` ships with `'apply_to' => implode(',', [Type::TYPE_SIMPLE, Type::TYPE_VIRTUAL])`."*
- `MAG:779–781` — *"**The browse category plays no part in any schema table** — instrument I13 with its same-corpus control is in the body §1.4 (0 hits; control 5). A category→attribute route would have to be a code path, and the only code measurement taken is the `categor` grep over the four save-path files (1 hit, a cache tag)."*
- `MAG:785–795` — the core install: *"**43 attribute definitions** installed into the default set … **✅ `flavour`/`flavor` is 0 of those 43**. **Two of the 43 are option-bearing (`select`) and user-defined**: `manufacturer` (`'apply_to' => Type::TYPE_SIMPLE`) and `color`."*
- `MAG:846–851` — *"⚠️ **No artifact published by this vendor carries a flavour attribute**, so *whether a product carries flavour* cannot be measured on this platform's published data. What **is** measurable, and is measured above, is the mechanism — attribute-set membership plus `apply_to`."*

**Maps to (A) — the option list is per attribute, global; attribute-set membership and `apply_to` govern which attributes apply, and neither is the category.**

**Stated vendor rationale — Adobe's axis requirement table, verbatim, and the fact that Adobe publishes it twice, differently:**

- `MAG:347–349` — *"❗ **Adobe's requirement table for an axis attribute, verbatim (md lines 57–61)**: `|Property|Required Setting|` · `|--- |--- |` · ``|[!UICONTROL Scope]|`Global`|`` · ``|[!UICONTROL Catalog Input Type for Store Owner]|`Dropdown`, `Visual Swatch`, or `Text Swatch`|`` · ``|[!UICONTROL Values Required]|`Yes`|``. **A second Adobe page states a *different* table** — Companion A §5 C2."*
- `MAG:907–913` (C2) — *"**Adobe's two axis-requirement tables list different requirements.** `product-create-configurable`: "Attribute requirements — Each attribute used for product variations must have these settings: `|Property|Required Setting|` · ``|Scope|`Global`|`` · ``|Catalog Input Type for Store Owner|`Dropdown`, `Visual Swatch`, or `Text Swatch`|`` · ``|Values Required|`Yes`|``" — **three** rows. `attribute-product-create`: "Attributes for configurable products — Any attribute that is used as a drop-down list of options for a configurable product must have the following properties: `| Catalog Input Type for Store Owner | Dropdown |` · `| Scope | Global |`" — **two** rows, with no *Values Required* and no swatch types."*
- `MAG:585–588` — *"**1 — Create the axis attribute, as a closed list, globally scoped.** Adobe: "If the attribute is used for a configurable product, choose Dropdown. Then, set Required to Yes."; its requirement table is `| Catalog Input Type for Store Owner | Dropdown |`, `| Scope | Global |`; and, as two consecutive bullets, "Under Manage Options, click Add Option." … "Enter the first value that you want to appear in the list.""*
- `MAG:591–592` — *"**2 — Choose the attribute set.** Adobe: "Step 2: Choose the attribute set — The attribute set determines which fields appear in the product form and which attributes are available for variations.""*
- `MAG:432–437` — *"**✅ Adobe states the axis role of three of them** — three rows of the input-types table, label cell then description cell, as printed (md 47, 54, 55): `|Dropdown|` "Displays a drop-down list of values that accepts only a single selection. **The Dropdown input type is a key component of configurable products.**"; `|[!UICONTROL Visual Swatch]|` "Displays a swatch that depicts the color, texture, or pattern of a configurable product…"; `|[!UICONTROL Text Swatch]|` "A text-based representation of a configurable product option that is frequently used for size…""*

⚠️ **But whether "Values Required = Yes" is *enforced* is OPEN** — `MAG:879` (§4 U5): *"**Whether "Values Required = Yes" is enforced on save.** Adobe documents it as mandatory; `canUseAttribute()` does not test it; the admin filter does not; instrument I7 — `grep -rE 'is_required|IsRequired'` over `app/code/Magento/ConfigurableProduct` (573 files / 2,689,654 B) — finds **10** references and **none inside either gate**."*

⚠️ **A #10778 claim this record does not reproduce.** `PRIOR:168` states *"**Magento does not auto-create option values on import — it rejects unknown ones** (`Validator.php:128-144`)."* A targeted search of `MAG` for `Validator.php` / `auto-create` / `unknown option` returns nothing on that subject. The Magento record establishes the Admin path (`MAG:585–588`) and the REST path (`MAG:422`) for creating options, and leaves import behaviour unaddressed. **Flagged as uncorroborated, not refuted.**

### Q3 · QUANTITIES → **BARE LABEL, and there is NOTHING near a value.** The strongest negative in the set.

Section: `### 1.10 Units — where they are, and where they are not` (`MAG:493`)

- `MAG:497` — `| **I4b** | all 67 `db_schema.xml`, 724,544 B | `name="[a-z_]*(unit|uom|measur|dimension)[a-z_]*"` (-i) | **0** | ⚠️ **new:** `name="[a-z_]*weight[a-z_]*"` → **12** |`
- `MAG:498` — `| **I6** | `app/code/Magento/Eav`, non-Test | `\b(unit|uom|measure|measurement|dimension)\b` (-i) | **0** | ⚠️ **new:** `\blabel\b` → **228** |`
- `MAG:499` — `| **I5** | `app/code` | `weight_unit` | **490** | — (the positive case) |`
- `MAG:501–505` — *"**✅ No unit, quantity, dimension or precision field exists anywhere on an attribute option** — every column of `eav_attribute_option` is `option_id`, `attribute_id`, `sort_order`; the whole payload is one nullable `varchar(255)`. **✅ The only unit in the platform is a store-scoped config setting for product weight**: `Directory/Helper/Data.php:66` `XML_PATH_WEIGHT_UNIT = 'general/locale/weight_unit';` and `Directory/etc/config.xml:56` `<weight_unit>lbs</weight_unit>`."*
- `X:1046` — *"**Magento** — **bare label, and no unit exists anywhere near a value.** … Instruments with controls: … → **0**, control `name="[a-z_]*weight[a-z_]*"` → 12; … → **0**, control `\blabel\b` → 228. The only unit in the platform is a store-scoped config setting for product weight, `general/locale/weight_unit`, default `lbs`."*

**No dedicated net-content field.**

**Maps to: bare label — the card's first option, with nothing typed anywhere on the value.**
**Stated vendor rationale:** no stated rationale in the record.

### Q4 · ORDERING → **a stored `sort_order` smallint ON THE OPTION ROW, plus a `position` on the axis row.**

- `MAG:358` — the column itself, verbatim from `db_schema.xml`: `<column xsi:type="smallint" name="sort_order"   unsigned="true" nullable="false" identity="false" default="0" comment="Sort Order"/>`
- `MAG:502` — restated in the units section: *"every column of `eav_attribute_option` is `option_id`, `attribute_id`, `sort_order`"*
- `MAG:286` / `MAG:299` — the axis row carries its own: `<column xsi:type="smallint" name="position"     unsigned="true" nullable="false" identity="false" default="0" comment="Position"/>` · `| `position` | smallint unsigned | 1..1 | `0` |`
- `MAG:333` — the interface: `getAttributeId` string|null, `getLabel` string|null, **`getPosition` int|null**, `getIsUseDefault` bool|null
- `MAG:343` — the SDL: `String`, **`position: Int`**, `use_default: Boolean`, `values: [ConfigurableProductOptionsValues]`, `product_id:`
- `MAG:1413` — live: `{"id": 338, "attribute_id": "141", "label": "Size", "position": 0, "values": […], "product_id": 2078}`; and the GraphQL form `{"uid": "Y29uZmlndXJhYmxlLzEwNTIvOTM=", "attribute_uid": "OTM=", "label": "Color", "position": 1, "use_default": false, "attribute_code": "color", …}`
- `MAG:131` / `MAG:134` — note a *third*, unrelated `sort_order` on `eav_attribute_set`, with its own index `EAV_ATTRIBUTE_SET_ENTITY_TYPE_ID_SORT_ORDER btree (entity_type_id, sort_order)`

`X:1033` and `X:1046` both name `eav_attribute_option` = `option_id` / `attribute_id` / `sort_order` — **the only `sort_order` column named anywhere in the decision corpus** (`#11031`, `#10966`, the matrix).
`MATRIX:1088` names Magento as the precedent for our own proposed dimension row: *"Precedent: Magento's catalog_product_super_attribute (product id, attribute id, position, per-store label)"*.

**Maps to: a stored position / sort column on the value — the card's "stored position/sort column", in its clearest implementation.**
**Stated vendor rationale:** the column's own `comment="Sort Order"` is the only text; no rationale in the record.

### Q5 · VALUE IDENTITY / RENAME → **YES, and this is the cleanest case in the corpus: the id is the reference, the label is per store view, never per product.**

- `MAG:374–376` — `option → option_value UNIQUE (store_id, option_id)`; `| `value` (the label) | varchar(255), **nullable** | 0..1 per store | `Green` |`; `| option → swatch | UNIQUE (store_id, option_id) | ⚠️ 0..N, at most one per store | `{"label": "Blue", "swatch_data": {"value": "#1857f7"}}` |`
- `MAG:379–380` — *"the label is fanned out **per store view**, never per product"*
- `MAG:382–386` — *"⚠️ **"1..N, exactly one label per store" was asserted with no artifact and is corrected to 0..N**. The schema proves only an **upper** bound, and the save path requires no row either — `Eav/Model/ResourceModel/Entity/Attribute.php:568–583` deletes every row for the option, then re-inserts only where `!empty($values[$storeId]) || isset($values[$storeId]) && $values[$storeId] == '0'`, verbatim. Same correction for the swatch overlay."*
- `MAG:395–400` — *"⚠️ **Two SDL quotes were not verbatim, and the two `value_index` fields differ in deprecation status**. Lines 43–44 read `default_label: String @doc(description: "The label of the product on the default store.")` and `store_label: String @doc(description: "The label of the product on the current store.")` — revision 1 dropped "of the product on" from both with no ellipsis. And `ConfigurableProductOptionsValues.value_index` (40) is `@deprecated(reason: "Use `uid` instead.")` while `ConfigurableAttributeOption.value_index` (21) is **not** — revision 1 hung the `option_id` claim on the deprecated one."*
- `MAG:404–406` — the uid on two surfaces: `"Y29uZmlndXJhYmxlLzkzLzUz"`, base64 `configurable/93/53`
- `X:1033` — *"It is also the cleanest RENAME evidence: the *id* is the reference, the *label* is per store view, "never per product.""*

**Maps to: YES — a stable integer id entirely separate from the label, with the label additionally localisable per store view. A rename touches no product row.**
**Stated vendor rationale:** `MAG:402–404` (quoted above).


---

# PART 2 — THE SEPARATELY-REQUESTED ITEMS

---

## P2.1 · SHOPIFY — LINKED vs UNLINKED OPTION VALUES

The full quote set is in **§2 Shopify** above (Q1, Q2, Q5). Consolidated here with the additional material that did not fit a sub-question.

**The schema seam**
- `SHOP:107` — `linkedMetafield  LinkedMetafield  {namespace:"shopify", key:"color-pattern"}` on `ProductOption`
- `SHOP:117` — `linkedMetafieldValue  String  "gid://shopify/Metaobject/971662499"` on `ProductOptionValue`
- `SHOP:175` — on input: `linkedMetafieldValue String "Metafield value associated with an option."`

**The published instance** — `SHOP:421–429`:
`// input  {"productId":"gid://shopify/Product/1072481153","options":[{"name":"Color","linkedMetafield":{"namespace":"shopify","key":"color-pattern","values":["gid://shopify/Metaobject/971662499","gid://shopify/Metaobject/971662500","gid://shopify/Metaobject/971662501"]}}]}`
`// response  "linkedMetafield":{"namespace":"shopify","key":"color-pattern"}, "optionValues":[{"name":"Red","linkedMetafieldValue":"gid://shopify/Metaobject/971662499"},{"name":"Blue","linkedMetafieldValue":"gid://shopify/Metaobject/971662500"}, …]`

**The description, whole** — `SHOP:431`: *"The identifier for the metafield linked to this option.\n\nThis API is currently in early access. See [Metafield-linked product options](https://shopify.dev/docs/api/admin/migrate/new-product-model/metafield-linked) for more details."* — *"⚠️ Revision 1 truncated this at "early access." under a "whole" claim."*

**Mutual exclusion, read off the error enum** — `SHOP:416`, all 26 codes, of which nine govern the linked path: `LINKED_METAFIELD_DEFINITION_NOT_FOUND` · `INVALID_METAFIELD_VALUE_FOR_LINKED_OPTION` · `MISSING_METAFIELD_VALUES_FOR_LINKED_OPTION` · `CANNOT_COMBINE_LINKED_METAFIELD_AND_OPTION_VALUES` · `DUPLICATE_LINKED_OPTION` · `OPTION_LINKED_METAFIELD_ALREADY_TAKEN` · `LINKED_OPTIONS_NOT_SUPPORTED_FOR_SHOP` · `LINKED_METAFIELD_VALUE_WITHOUT_LINKED_OPTION` · (and from the bulk enum, `SHOP:957`) `CANNOT_SET_NAME_FOR_LINKED_OPTION_VALUE`

**No typed edge to the taxonomy; the bridge is Admin-only** — `SHOP:433`: *"⚠️ **2026-09-02 (S4-a).** No typed edge from the option surface to any `Taxonomy*` type: 16 option-surface types / 55 field definitions in `admin_2026-07.json` (listed in the correction comment), **0** with `Taxonom` in a field type or description. `metafield-linked.md` :22 *"For standard product workflows without taxonomy, use regular options…"*; 0 hits for `category metafield` in 15,063 B. Storefront: `ProductOption` = `{id, name, optionValues, values}`, **no `LinkedMetafield` type — the bridge is Admin-only.**"*

**The requirement** — `SHOP:619`: *"`metafield-linked.md` :30 requires *"a metafield definition … with owner type `Product` and type `list.metaobject_reference`"*"*; `SHOP:1050`: *"Vendor guide "Link metafields to product options" re-fetched 2026-09-05 (15,063 B), "## Requirements", whole (3 bullets): *"Your app can make authenticated requests to the latest version of the GraphQL Admin API or higher."* · *"Your app has the `write_products` and `write_metaobjects` access scop[es]"*"*

**The live gate, both directions** — `SHOP:1046–1049`, section `### E13`:
> *"⚠️ **2026-09-05 — the linked-option path, observed live on the dev store (U6 (a)/(b)).**"*
> *"**(a) Standard, category-constrained definition `shopify.color-pattern`** (its `constraints` = `{key:"category", values: 7,750 ids}`, §1.8). `productOptionsCreate(options:[{name:"Color", linkedMetafield:{namespace:"shopify", key:"color-pattern", values:["gid://shopify/Metaobject/253696180545"]}}])`:"*
> *"- product **A**, created with no category (`"category":null`) → **refused**: `"userErrors":[{"field":["options"],"message":"At least one value for the option linked to the 'shopify.color-pattern' metafield is invalid","code":"INVALID_METAFIELD_VALUE_FOR_LINKED_OPTION"}]`, the product still carrying only `Title`/`Default Title` …; `productUpdate(category:"gid://shopify/TaxonomyCategory/aa-1-13-8")`; the same mutation → **accepted**: option `12896900120897` `"linkedMetafield":{"namespace":"shopify","key":"color-patter[n]"*
> *"- product **B**, created with `category: aa-1-13-8` at `productCreate` → **accepted**, read back; `productOptionsDelete`; `productUpdate(category:null)` → `"category":null`; the same mutation → **refused** with the identical message and code. Same result the collector saw on its first product."*
> `SHOP:1050` — *"Vendor enum page re-fetched 2026-09-05: `INVALID_METAFIELD_VALUE_FOR_LINKED_OPTION` — *"Invalid metafield value for linked option."*; the message string above is captured 4× on this store and 0× in raw/140 / raw/141 → **U8**."*
> `SHOP:1051` — *"**(b) Custom, unconstrained definition** `custom.cp0905_rev_material` (`list.metaobject_reference` → custom metaobject definition `cp0905-rev-material`; `"constraints":{"key":null,"values":{"nodes":[]}}`): the same mutation shape on a product whose `category` is `null` → **accepted**, `"category":null` in the same response; independent read-back: `"category":null`, `"linkedMetafield":{"namespace":"custom","key":"cp0905_rev_material"}`, values `"Cp0905 Rev Cotton"` / `"Cp0905 Rev Wool"` each with a `linkedMetafieldValue` gid and `"swatch":null`."*

**Two products sharing one metaobject** — `X:1037`: *"two products linked to the same metaobject `253696180545` each read back the same gid."*
**Swatches, live** — `SHOP:1081`: `"swatch":{"color":"#2B6CB0","image":null}` and `"swatch":{"color":null,"image":{"id":"gid://shopify/MediaImage/56765795205441",…}}`
**Read-back on a second product** — `SHOP:1085`: `{"data":{"product":{"id":"gid://shopify/Product/10363266007361","title":"cp0905-rev-color-a","category":{"id":"gid://shopify/TaxonomyCategory/aa-1-13-8","fullName":"Apparel & Accessories > Clothing > Clothing Tops > T-Shirts","isLeaf":true},"options":[{"id":"gid://shopify/ProductOption/12896900120897","name":"Color","position":1,"linkedMetafield":{"namespace":"shopify","key":"color-pattern"},"optionValues":[{"id":"gid://shopify/ProductOptionValue/6804936884545","name":"cp0905-rev Blue","linkedMetafieldValue":"gid://shopify/Metaobject/253696180545","swatch":{"color":"#2B6CB0","image":null}}]}]}}, …}`

**The cross-record summaries**
- `X:67` — *"| **Is a value a shared row, or copied per product?** | ⚠️ **copied** — *"most product facts must be replicated"* … | copied by default; shared only via `linkedMetafieldValue` (early access) | ⚠️ **copied**, no shared entity at all | **copied per product** → ❓ **D8 — open** |"*
- `X:78` — *"| **Shopify** | … | Own object — ProductOption / ProductOptionValue | No by default; yes on the linked-metafield path | 3 per product (`maxProductOptions`), shop-variable | Copied strings; shared only on the linked path |"*
- `X:550` — *"| **7. Is a value a shared row, or copied per product?** | **Copied** per child … | **Copied string** by default; **shared row** on the linked path (metaobject GID) †5 | **Split** — shared row for 4 selectable types, per-instance rows for 8 †6 | **Copied on every row**; no shared entity anywhere †9 |"*
- `X:613` — *"**Shopify: "a string, always, regardless of type" → copied string *by default*, optionally a shared row** via `linkedMetafieldValue` (metaobject GID); plus non-string sidecars (`swatch` = color + image)."*
- `X:706` — *"**Shopify** (copied by default; shared only via `linkedMetafieldValue` carrying a metaobject GID, early access, **linked and non-linked values cannot be mixed**)"*
- `MATRIX:2145` — *"Shopify: an unlinked value is a string on the product; a linked value is a Metaobject gid two products share, live."*
- `MATRIX:1284` — *"Shopify: none on an unlinked option; on the linked path the metafield definition's category constraints gate it (observed: refused with category: null, accepted with a category in the set)."*

⚠️ **ONE UNRESOLVED CONFLICT, both sides quoted.** `X:706` says *"linked and non-linked values cannot be mixed"*, while `PRIOR:388` (section `## Evidence`, block `<b>Membership rules vs the APIs</b>`) says *"**Per-dimension value policy (V2)** — Shopify metafield-linked options coexist with plain-text options on one product."* The error code `CANNOT_COMBINE_LINKED_METAFIELD_AND_OPTION_VALUES` (`SHOP:416`) forbids mixing **within one option**; neither source is instrumented on mixing **across options on one product**. Not resolved here.

**The audited correction on "unrelated"** — `X:472` (claim S4-a): *"The axis is its own object (ProductOption + ProductOptionValue), free text, UNRELATED to the taxonomy attribute system. | Own object and free text by default, with no typed edge to any `Taxonomy*` type. **"Unrelated" is too strong on Admin (`linkedMetafield`), but the verifier's flat "Shopify ships an explicit documented bridge" is also over-general. Accurate: decoupled by default, optionally bridgeable on Admin, no bridge on Storefront.** | admin_2026-07.json: 0 `axonom` hits across 42 option-surface field definitions; Storefront `ProductOption = {id, name, optionValues, values}`, type `LinkedMetafield` absent; metafield-linked.md 15,063 B :22/:225/:291 — namespace `custom` throughout, "For standard product workflows without taxonomy, use regular options", "category metafield" = 0 hits. | D3, D4, D5 | changes-a-decision |"*

**Open-at-namespace, closed-per-definition on the metafield surface** — `X:1125`: *"**Shopify** — … **open at the namespace/key level, closed per definition at write time.** `metafieldsSet` on a product with a `namespace/key` that has **no definition** … → `userErrors:[]`, stored and read back with `"definition":null` … Where a definition exists, its `type` and `validations` are enforced on write: a non-integer into a `number_integer` definition → `{"code":"INVALID_VALUE","message":"Value must be an integer."}`; a value outside a `choices` validation → `{"code":"INVALID_VALUE","message":"Value does not exist in provided choices: [\"alpha\", \"beta\", \"gamma\"]."}` … The option surface stays free text (`ProductOption.name`, `OptionValueCreateInput.name`)."*

---

## P2.2 · SQUARE — SHARED OPTION VALUES / ITEM OPTIONS

The full quote set is in **§9 Square** above (Q1, Q2, Q4, Q5). The additional call-sequence material:

- `SQ:468–472` — *"**1 — Create the axis objects.** "To add an item option to a catalog, create a CatalogObject instance and set its type property value as ITEM_OPTION and its item_option_data field value as a CatalogItemOption instance." Written through `UpsertCatalogObject` (`POST /v2/catalog/object`) or `BatchUpsertCatalogObjects`. New objects use temporary ids: "the client should set the id to a temporary identifier starting with a \"`#`\" character"."*
- `SQ:474–478` — *"**2 — Or reuse the seller's existing axes.** "After your application creates a CatalogItemOption—such as \"color\" with predefined values—that option can be applied to define the color attribute for any new catalog items. Your application can also use catalog item options created by the seller in the Square Dashboard." The vendor's own worked read is a `SearchCatalogObjects` call introduced as "**The following response shows that a seller has already created a standard set of colors**"."*
- `SQ:480–483` — *"**3 — Attach the axes to the family row.** `CatalogItem.item_options[]` holds `CatalogItemOptionForItem` entries, whose single field is described as "The unique id of the item option, used to form the dimensions of the item option matrix in a specified order." Vendor request sample: `"item_options": [{"item_option_id": "#item_option_size"}, {"item_option_id": "#item_option_color"}]`. Maximum 6 ⚠️ 2026-09-05: enforced live — 7 → 400 `ARRAY_LENGTH_TOO_LONG`, 6 → 200."*
- `SQ:485–489` — *"**4 — The variant grid is generated from the option values.** "Using item options, a variation is automatically generated for every combination of option values. Each variation is linked to options and values (such as Red, Small, and Polo), eliminating the need for sellers to manually format individual descriptions. These examples (color, size, and style) are just that—examples. Your application can create any type of option with various values.""*
- `SQ:491–495` — *"**5 — Each variant points at values by ID.** `CatalogItemVariation.item_option_values[]` holds `CatalogItemOptionValueForItemVariation` entries carrying only `item_option_id` + `item_option_value_id`, "Listed in the same order as the item options of the parent item." Vendor request sample: `"item_option_values": [{"item_option_id": "#item_option_size", "item_option_value_id": "#item_option_value_size_small"}, …]`."*
- `SQ:497–505` — *"**6 — The variant name becomes read-only.** "If item options are used, Square sets the variation name by combining the chosen option values into a comma-separated string…" And: "When using item options, the `CatalogItemVariation.name` includes only the option values, not the item's name (for example, \"Large, Red\" instead of \"Polo shirt: Large, Red\"). The item name should be set in the parent catalog item, such as \"Polo shirt\"." The schema agrees: "…when the parent [item] uses [item options], this attribute is auto-generated, read-only…" ⚠️ 2026-09-05: observed live — request `"name": "cp0905-rev-var"`, read-back `"name":"cp0905-rev-A-val1, cp0905-rev-B-val1, cp0905-rev-C-val1, cp0905-rev-D-val1, cp0905-rev-E-val1, cp0905-rev-F-val1"`."*
- `SQ:507–509` — **7**, the binding rule (quoted in §9 Q1 above)
- `SQ:511–514` — *"**8 — Reading back.** `CatalogQueryItemsForItemOptions` returns items by option id; `CatalogQueryItemVariationsForItemOptionValues` returns variations by value id. As of Square Version 2026-08-19, `BatchRetrieveCatalogObjects`, `SearchCatalogItems` and `SearchCatalogObjects` also expose an optional `include_options` parameter."*
- `SQ:516–518` — **9**, editing (quoted in §9 Q5 above)
- `SQ:520–523` — *"**10 — Version discipline across the whole sequence**: "Use the same API version (`Square-Version` header) for both reading and writing catalog objects… If a client reads an object at an older API version and writes it back at a newer version, fields that were introduced between those two versions will be absent from the request, and **the server will interpret that absence as an intentional clear**.""*

**Caps** — `SQ:440` / `SQ:811`: 250 values per `CatalogItemOption`, enforced live on three surfaces, no published cap; `SQ:810`: 6 item options per `CatalogItem`, two routes (live refusal at 7 on two write surfaces + `api.json`'s `"Maximum: 6 item options."`).
**Custom attributes are the contrast, not the same thing** — `SQ:399–403`, `SQ:376–380`, `SQ:390–392`, `SQ:416–419` (all quoted in §9 Q2 above).

---

## P2.3 · AKENEO — OPTION SORT ORDER AND THE `metric` TYPE

The full quote set is in **§11 Akeneo** above (Q3, Q4). Consolidated pointers:

**Sort order** — `AKN:317` (the `sortOrder` column in `pim_catalog_attribute_option`) · `AKN:696` (the vendor's published JSON instance carrying `"sort_order":1`) · `AKN:697–698` (the shipped fixture header `code;label-de_DE;label-en_US;label-fr_FR;attribute;sort_order` and its row `black;Black;Black;Noir;color;0`) · `AKN:228` and `AKN:688` (a separate `sortOrder` on the attribute definition, instance `"sort_order":39`) · `X:1103` (the only other corpus occurrence, a negative-search side-hit `getMaxAttributeSortOrder` ×2, control `\bmax` → 161). **No vendor description of the field's semantics is quoted anywhere in the record.**

**Metric type** — `AKN:480–517` (the whole section: `MeasurementFamily` / `Unit`, the five constructor assertions, `{amount, unit}` on the wire and `{amount, unit, base_data, base_unit, family}` in storage, the null branch, and the vendor prose) · `AKN:241` (`metricFamily` / `defaultMetricUnit` on the definition, `metricFamily` immutable) · `AKN:270–279` (`METRIC` first in the 5-element axis-eligible array) · `AKN:844` (`display_diagonal`, a live metric axis in the vendor's own shipped fixtures) · `AKN:352–360` (`MetricValue` stringifies as `sprintf('%.4F %s', …)` when the axis-uniqueness validator compares siblings) · `AKN:519–523` (the two objects both spelled "family") · `AKN:943–948` (C3 — six vendor statements, three different answers on axis-eligible types) · `AKN:529` (`MAXIMUM_LEVEL_NUMBER = 2`, `MAXIMUM_AXES_NUMBER = 5`) · `MATRIX:1990` (`{"amount":"800.0000","unit":"GRAM","symbol":"g"}`) · `MATRIX:2008` · `MATRIX:2163` · `X:1049`.

> **What this settles and what it does not, against #10778 V4.** `PRIOR:128` says *"**Nobody drives a picker from a stored quantity**, not even Akeneo, the one PIM whose `Measurement` type is a legal axis."* The Akeneo record **confirms the legality** (`AKN:270–279`, `AKN:844`, `AKN:943–948`) and is **silent on the picker** — no statement anywhere describes how a metric axis's values are ordered for selection. The claim's negative half is therefore **unaddressed by the platform record**, not corroborated by it.

---

## P2.4 · DEDICATED NET-CONTENT / UNIT-PRICING / PACKAGE-QUANTITY FIELDS

Every occurrence found, across all sources.

| Platform | Field | Cite |
|---|---|---|
| **Walmart** | `netContent` `{productNetContentUnit (23-value closed enum), productNetContentMeasure (number, ×0.001, 0–99999999999999)}`, both `required`, `additionalProperties:false`; **in `Toothpastes`' required list** | `WMT:136`, `WMT:120` |
| **Walmart** | `count`, `countPerPack`, `multipackQuantity`, `pieceCount` — bare integers, all four are permitted **axis names** | `WMT:131`, `WMT:210–211`, `WMT:497`, `WMT:981` |
| **Walmart** | `MP_VIRTUAL_PACK_BUNDLE` — `bundle_component_gtin` (1..80), `bundleComponentItemQuantity` (0..9999999999); shares no structure with variant grouping | `WMT:320–327`, `WMT:1019` |
| **Google** | `unit_pricing_measure` — *"Value + unit"*, full unit vocabulary, `1.5kg`; **Optional except where required by local laws** | `GOOG:661` |
| **Google** | `unit_pricing_base_measure` — *"Integer + unit"*, `100g`, plus `75cl 750ml 50kg 1000kg` | `GOOG:662` |
| **Google** | `multipack` Integer `6` · `is_bundle` `[yes]`/`[no]` | `GOOG:703`, `GOOG:691` |
| **Amazon** | `item_package_quantity`, `unit_count`, `unit_count_type` — all three in the **12 required fields** of the `Food`/`Beverages` flat file; `unit_count` shape is `{value, type:{value, language_tag}}` | `AMZ:172`, `PRIOR:277`, `AMZ:14277` |
| **Amazon** | `package_level` / `package_contains` for pack hierarchies — **single-route and internally contradicted** | `AMZ:14074`, `AMZ:14127` |
| **Tokopedia Era B** | `skus.sku_unit_count` + "base unit count" and "unit type" carried as **product attributes**; `Unit price = Selling price/(SKU unit count/base unit count)`; errors `12052361`, `12052362`; **EU-only**, Indonesian applicability OPEN (§4/U14) | `TOKO:307–312`, `TOKO:401` |
| **Shopify** | `ProductVariant.unitPriceMeasurement {measuredType, quantityValue, quantityUnit, referenceValue, referenceUnit}` + `showUnitPrice` — on the variant; all null/0 in the live pass | `SHOP:466`, `SHOP:1069`, `X:1050` |
| **Salesforce B2C** | `complexType.Product`: `<unit>` + `<unit-quantity>` (`xsd:decimal`) + `<unit-measure>` (`String.60`) — a real net-content triple, on the **Product**, not on a value | `SFCC:061`, `SFCC:076`, `SFCC:198`, `SFCC:364` |
| **Square** | `CatalogItemVariation.measurement_unit_id` → `CatalogMeasurementUnit {measurement_unit, precision}` → `MeasurementUnit` (8 properties) — on the **variation** | `SQ:410–414` |
| **Akeneo** | `pim_catalog_metric` `{amount, unit}` from a shared `MeasurementFamily`/`Unit` registry — the only *attribute-system* net-content mechanism in the set, and axis-eligible | `AKN:480–517`, `AKN:270–279` |
| **eBay** | **none** — *"**Exactly 12 properties** … **None is a unit, quantity or measure field.**"* | `EBAY:187` |
| **Shopee** | **none dedicated** — but `format_type = 2` + `value_unit` + `attribute_unit_list` is a general typed-quantity mechanism | `SHPE:096`, `SHPE:107`, `SHPE:119`, `SHPE:130` |
| **Magento** | **none** — 0 unit/quantity/dimension/precision fields across 67 `db_schema.xml` (control `weight` → 12) | `MAG:497–505` |
| **WooCommerce** | **none** — six bare fields; I-A7 → 2 store-level hits, control `weight_unit` → 322 | `WOO:372–378` |
| **commercetools** | **none** — every unit-synonym pattern returns 0 across three corpora, control 19 lines | `CT:1097–1100` |
| **Tokopedia Era A** | **none** — `amount` 0, `quantity` 0, `magnitude` 0, `uom` 0 in the catalogue file | `TOKO:488` |

**GS1 and Indonesian law — why the field cannot be scalar**
`PRIOR:279` (section `## Why it is out of scope`) — *"**5. Net content is not scalar**, which invalidates both shapes previously sketched here. GS1 types it `netContent : Measurement [0..*]` — their own example carries one item as `18 fl oz` + `532 ml` + `6 piece or count`. **Indonesian law agrees**: BPOM 31/2018 Pasal 27 mandates a *second* quantity, `bobot tuntas` (drained weight), for anything packed in liquid."*

**Whether unit pricing is even required here**
`PRIOR:273` — *"**2. The motivating consumer is weaker than assumed.** Unit pricing is **not required in Indonesia** — Permendag 35/2013 Pasal 3(1) requires price *"dilengkapi jumlah satuan atau jumlah tertentu"* (price plus the quantity it buys), not price per base quantity; Pasal 5 extends the same duty online, unchanged. Baymard: 86% of sites don't show price-per-unit (2023). It is a differentiator, not compliance."*

**Our own position** — `MATRIX:2181`: *"Units in attribute names (Tinggi (cm)); "600 ml" is title text; no unit-pricing data path. **Net content is non-scalar per GS1 and BPOM.**"*

**Adopting a standard taxonomy does not supply one** — `MATRIX:367–369`: *"There is no net-content or size attribute anywhere in it | 300 of 8,240 definitions match size, volume, weight or capacity — and **every one is category-specific** (Bagel size, Battery size, Athletic cup size) | Our biggest axis, the 215 GR / 720 GR / 1.44 KG / 2.7 KG one, is not in the standard and would not be solved by adopting it. **D9 stays ours either way.**"*

⚠️ **A conflict on whether Google's row was counted.** `MATRIX:2178` files Google as *"No row1 | Google70 | No D9 row in the consolidated evidence."* while `X:805` says *"| **D9** | Covered **including Google** (Companion A row 17, `[unit_pricing_measure]`, gives value + unit with the full unit vocabulary) — even though #10966's own D9 paragraph names only three systems. |"*. Both recorded; neither preferred.

⚠️ **Strings NOT FOUND in `#11031`, `#10966` or the matrix** (searched): `unit_pricing_base_measure` · `multipack` · `item_package_quantity` · `package_quantity`. They exist only in the platform records cited above.

---

## P2.5 · #10778 — V1, V2, V3, V4, V5, V6, C5, C8, AND THE SURVEY PASSAGE BEHIND V4

Section heading: `## Dimension vocabulary` (`PRIOR:121`).

Preamble — `PRIOR:123`:
> *"**Decision B, settled 2026-08-09** after nine research tracks plus eight independent agent passes (three unbiased panels, two blind derivations, one red team explicitly briefed that returning "looks good" was a failure). The evidence base is a local corpus, `~/copilot/research/product-attribute-variant-2026-08/`. Several rows below reverse earlier positions; the reversals are recorded in place rather than silently applied."*

Table header at `PRIOR:125`: `| # | Decision | Settled |`

### V1 — `PRIOR:127`, verbatim and whole

> `| **V1** | Dimension **names** come from a shared **staff-extendable catalogue** (Ukuran, Rasa, Warna, Kemasan). Adding one is a deliberate admin action. **Reinforced 08-09:** all seven marketplaces surveyed **close the structure and open the values**, and 8 of 20 systems govern axis *names* differently from axis *values*. Closing the name is the industry's own answer; Shopify is the lone inverse. | 07-29, reinforced 08-09 |`

### V4 — `PRIOR:128`, verbatim and whole

> `| **V4** | **An axis value is a SINGLE TEXT LABEL — `"200 ml"`, not `{200, "ml"}`.** 13 of 14 systems re-derived from source store it as a string or `{key, label}` pair. **The only argument for splitting is ordering, and it fails:** every surveyed system hand-orders picker values with a position column (Magento `sort_order`, BigCommerce `sort_order`, Shopify `productOptionsReorder`, commercetools `changePlainEnumValueOrder`, Akeneo `sort_order`, SFCC, Saleor, Spree). WooCommerce is the sole inferred-numeric sort and ships **broken** — `name_num` compiles to `ORDER BY t.name+0`, putting `1.5 L` before `600 ml` and collapsing `M` to 0. **Nobody drives a picker from a stored quantity**, not even Akeneo, the one PIM whose `Measurement` type is a legal axis. Shopify is the sharpest negative: it ships `volume = {value, unit}` and still requires a linked option to be a metaobject reference. **Splitting forfeits nothing** — unit pricing, range faceting, conversion and `500 g ≡ 0.5 kg` are unavailable from the axis value in *every* system surveyed **including the two-field ones**; those belong to #10942. Grocery confirms: Open Food Facts' typed `product_quantity` is *"computed from the `quantity` field"* — the verbatim label is the record, the typed pair a derived index. | 08-09 |`

### V5 — `PRIOR:129`, verbatim and whole

> `| **V5** | **⚠️ NEW WORK ITEM — the value ordering column is missing.** S4 puts `display_order` on the *membership*, which is correct for C2's hero pick but **cannot order a picker**: a picker orders *axis values*, in one independent list per dimension. Every surveyed system puts the order column on the **value**. This is a second order column on a second table and is currently absent from this issue's plan. | 08-09 |`

### V2 — `PRIOR:130`, verbatim and whole

> `| **V2** | **Per-dimension governance flag — SUPERSEDED IN FORM, KEPT IN SUBSTANCE.** One storage shape for every dimension (V4), with governance a **flag on the dimension**, not a distinct storage type. Six independent agents converged on this from unrelated lenses (operations, evidence quality, build cost, blind derivation, red team, grocery-operator practice). Four platforms already ship exactly this switch: **eBay `aspectMode: FREE_TEXT \| SELECTION_ONLY`** (per aspect, per category), **Shopee `input_type` 1–5**, **Lazada `input_type` 1–9**, Amazon's `anyOf[string, enum]`. eBay carries six orthogonal per-aspect flags. *(Supersedes the original V2, which framed `free` vs `curated` as two policies rather than one shape plus a flag.)* | 07-29, reframed 08-09 |`

### V3 — `PRIOR:131`, verbatim and whole

> `| **V3** | **Which setting each dimension gets is NOT decided** — deferred as a launch-time call. *(Supersedes "all dimensions ship `free` in v1".)* Evidence for whoever makes the call is in V6 and V7. | 07-29, superseded 08-09 |`

### V6 — `PRIOR:132`, verbatim and whole

> `| **V6** | **Freeform dimensions get auto-derived suggestions plus normalisation on write.** eBay derives value recommendations *"based on the number of recent listings and/or recently sold listings in the same category"* and is converting categories **from** curated **to** derived. **Normalisation is the highest-value line of code in this decision:** our own `manufacturer` field is the control condition — free text, and `ProductAttributeValue.value_text` has **no trim, no case-fold, nothing** (`models.py:742`) — producing **5,564 distinct values collapsing to 4,290, i.e. 23% pure whitespace-and-capitalisation redundancy, 19% junk, only 37% populated**. Trim + collapse + case-fold on write removes that entire class. ⚠️ *Known residual:* normalisation cannot catch `Ayam bawang` vs `Ayam Bawang` as different **words**, and auto-derived suggestions **learn the first spelling** — WooCommerce and Spree both insert typed values into the shared table on save, and in Spree the first spelling wins permanently. Jira labels are the cautionary end state: pure auto-derivation with **no rename primitive**, governance requests open 15 years. A rename/merge tool is the mitigation when it bites. **A review backlog is a query, not a mode:** "values used fewer than N times on this dimension" surfaces novel entries for cleanup without a separate storage shape. | 08-09 |`

> ⚠️ **Every one of V6's five production figures is retracted.** See §P2.6a below.
> ⚠️ **V6's eBay clause is uncorroborated by the eBay reference record.** See §4 eBay, "PREMISE 2 OVERTURNED".

### C5 — `PRIOR:133`, verbatim and whole

> `| **C5** | **One global name catalogue**, not scoped per category. Diverges from Amazon and Walmart, which bind allowed axes to product type — **and from Shopify**, the only platform surveyed with a first-class category→attribute binding. Three-for-three, not two. Acceptable for trained internal staff; retro-scoping later is migration work. | 08-05, evidence extended 08-06 |`

### C8 — `PRIOR:134`, verbatim and whole, with its two attached paragraphs

> `| **C8** | **Clothing vs grocery `Ukuran` is resolved by V2's flag.** One global `Ukuran` cannot be unbounded for grocery (`250 ml`) and closed for apparel (`S`/`M`/`L`) *as a single storage type* — but it can as a per-dimension setting, which is why the flag exists. **Do not split the dimension**; two "sizes" is itself a drift generator. If scoping is ever wanted, `main_category` is already a non-null FK (`catalogue/models.py:435`), so typeahead can be scoped with zero migration.`

> `PRIOR:136` — *"**⚠️ The apparel case is real but PENDING, not current (measured 2026-08-10).** Sized goods are carried today as **one row per style with the size range in the title** — `0002 CELANA PJG (DF) M-XL FF`, `0005 CELANA PJG SELETING M-XL FF`. Of **1,945** apparel-titled live products, only **240 (12.3%)** carry any size token, and many of those express a *range* rather than a single size. **So there are no per-size product rows today, and therefore no apparel family and no closed dimension in the catalogue as it stands.**"*

> `PRIOR:138` — *"**This is intended to change** — apparel will be entered per size, which is the universal industry practice (#10943's survey found no exceptions: Amazon each size is its own child ASIN; Magento children are ordinary simple products; Shopify and Square put price, SKU and UPC only on the variation; nobody tracks inventory at family level). **The forcing function is online ordering, not stock tracking:** a customer buying a shirt online has to choose a size, and we have to fulfil that specific size. One row per style cannot express the order. **#10943 owns that split.** Until it lands, expect every dimension to be freeform in practice — the V2 flag is kept because it is what makes V3's launch-time deferral possible, and because the closed-size case becomes real as soon as apparel is split, not because a closed dimension exists today. |"*

### V7 — proposed and struck — `PRIOR:141`, verbatim and whole

> *"**V7 was proposed and struck, 08-09** — *"list-backed dimensions carry an escape hatch, never hard rejection."* It does not survive: **a list that accepts off-list values is freeform-with-suggestions wearing extra machinery**, and it would have left V2's flag meaning almost nothing. The evidence was also weaker than first presented. Amazon is a direct counter-example — `apparel_size.size` is a 512-code enum with **no `anyOf` escape**, while `age_range_description` *in the same schema file* has one, so the escape is withheld deliberately for apparel size. Adobe Commerce requires a configurable axis to be a dropdown with no off-list entry, and eBay's closed mode is named `SELECTION_ONLY`. The supporting examples turned out to be taxonomy and marketplace contexts rather than variant axes: Open Food Facts' `fr:` prefix is a **packaging taxonomy**; Shopee's `value_id: 0` sidecar accompanies a `tier_variation` mechanism **deprecated 2025-09-12**; and Shopify's `Other` is a **curated member of the list**, not free-text capture. No system was found shipping a closed *variant axis* that also accepts off-list values. **A dimension is therefore either freeform-with-suggestions (V6) or genuinely closed** — and a dimension wanting an "other" bucket adds `Other` as an ordinary list value."*

> ⚠️ Two of V7's four supporting claims are qualified by later records: the Amazon 512-code claim is **retracted by #10778 itself** (`PRIOR:211`, below), and the Shopee clause **conflates two namespaces** (see §6 Shopee).

### The survey passage behind V4 — the corroborating sections, in order

**`### Why apparel reopened the flag — the strongest counter-evidence, recorded in full`** (`PRIOR:143`)

- `PRIOR:145` — *"A freeform-everywhere design was nearly locked on 08-09 and was **overturned by apparel**. Recorded so it is not re-litigated:"*
- `PRIOR:147` — *"**Amazon's apparel variant axis is a hard closed vocabulary.** The `SIZE` theme binds to `shirt_size`/`apparel_size` — **512 codes, no `anyOf` escape**, narrowed to as few as 20 permitted values by gender × age × class across 8 conditional branches. Amazon's own `SHIRT` worked example ships an opaque code, not a label: `"shirt_size": [{"size_class":"age","size_system":"as1","size":"1_month"}]`. An earlier pass concluded "axis name closed, axis value free" — true of the legacy XSD, **false of the current JSON model**."*
- `PRIOR:148` — *"**Adobe Commerce forces the same thing generally**, verbatim: *"Each attribute used for product variations must have these settings: Scope **Global**; Catalog Input Type **Dropdown, Visual Swatch, or Text Swatch**; Values Required **Yes**."* The same field is free as an ordinary attribute and **closed when used as an axis**."*
- `PRIOR:149` — *"**But the closure is a category rule, not an axis rule** — in 16 of 17 Amazon product types **including `GROCERY`**, `size` is a bare 50-character string. Apparel does not tighten `size`; it routes around it into a different compound attribute."*
- `PRIOR:150` — *"**The transferable rule is Adobe's, not Amazon's.** Amazon says *adopt 512 marketplace-specific codes*, which is impossible here: **Indonesia appears in no size-system enum in the industry** — not Google's 11, not Shopify's 8, not schema.org's 14, not GS1's 7. Adobe says *an axis must draw from a list*, and that list is one we author — roughly seven values."*
- `PRIOR:151` — *"**⚠️ Unresolved contradiction, reported not resolved:** Amazon's own migration workbooks route `Clothing/VariationData/Size` and flat-file `size_name1` to `/attributes/size/0/value`, the **free string**. Three current Amazon artifacts disagree: native JSON says enum, both migration maps say free string."*
- `PRIOR:152` — *"**⚠️ Provenance caveat:** no apparel product-type JSON exists anywhere on GitHub (nine searches, zero hits). Every Amazon schema finding in this corpus comes from files hosted in third-party repos with unproven provenance. Settling it needs one authenticated `getDefinitionsProductType` call, which nobody has had."*

**`### What argues the other way, also recorded`** (`PRIOR:154`)

- `PRIOR:156` — *"**The Indonesian apparel vocabulary does not close.** 45 Tokopedia products yielded **55 distinct literal size strings** — more distinct sizes than products — including `Xl` beside `XL`, `ALL SIZE` beside `all size dewasa`, `Int:M`, `LD XL (110)`, `Oversized - XL`, a stray `17` in a waist series, and one size axis filled entirely with colours. **`M fit to L` / `M fit to XL` is a generative construction** and cannot be enumerated; Indonesian sources define `all size` as having *"no fixed standard"*."*
- `PRIOR:157` — *"**Our closest analog already tried a closed list and it did not hold.** Matahari — groceries *and* clothing, Shopify-backed — runs a closed per-product picker and still emits `ALL SIZE`, `NO SIZE`, `F` and nine incompatible schemes. **A picker constrains a product, not a vocabulary.** Alfamart and Indomaret carry no size field at all."*
- `PRIOR:158` — *"**There is no standard to adopt.** ISO 8559-2 defines a size designation as a *centimetre range of a body dimension* and forbids garment dimensions; ASTM publishes measurement tables only. The sole standards-body letter vocabulary is EN 13402-3 (adults, chest only, paywalled), whose machine-readable successor **EN 13402-4 was drafted twice and never published**. `SNI 2161:2010` covers Indonesian men's T-shirts with S–XXXL but binds them to *garment* measurements."*
- `PRIOR:159` — *"**The wrong-pick hazard that motivated a freeform-for-flavour split is contradicted by measurement.** Selection errors from pick-lists run **0.01–0.5%**, ~10% of those attributable to adjacency; the one field-type-controlled study puts single-select at **1.1–6.3%** versus free text at **6.4–26.4%**, and the one randomised trial of suggestions in structured entry **improved** accuracy. What does transfer is matcher-level: prefix similarity drives **81%** of confusions, never auto-highlight row 1, require 3–4 characters, warnings do not mitigate."*
- `PRIOR:160` — *"**Governance is never chosen by semantics.** Fifteen platforms and four standards bodies checked, no instance. Amazon's `material` is a free string in `AUTO_PART` and a soft enum in `TERMINAL_BLOCK` — **the meaning does not change between categories; the governance does.**"*
- `PRIOR:161` — *"**Grocery leaves flavour free, in GS1's own words.** GDSN `variantDescription` is a *"**Free text field** used to identify the variant… such things as the particular flavor, fragrance, taste"*, and GDM 2.17 Food (187 attributes) carries **no flavour attribute at all**. Pack form *is* controlled (`packagingTypeCode`, 52 values) — but `tradeItemUnitDescriptorCode` **cannot** serve as our `Kemasan` axis: satuan/renceng/dus are pack *levels*, each requiring its own GTIN, with no consumer-facing use."*
- `PRIOR:162` — *"**What keeps a vocabulary clean is consumption, not governance.** GS1 UK / Cranfield *Data Crunch*: **80%+ inconsistency across four UK grocers**, 17% supplier–retailer dimensional match, suppliers entering dummy `1x1x1` values to satisfy validation — and **the one attribute that stayed clean was the one a daily operational process consumed**. Nothing currently consumes typed size in our market, since Indonesia has no unit-pricing requirement."*
- `PRIOR:163` — *"**Validation of the shape:** Google shipped `variant_option` in **May 2026** — `{name, value}`, both free text ≤250 characters, no enum on either side, repeated ≤30."*

**`### Corrections to earlier claims in this issue`** (`PRIOR:165`)

- `PRIOR:167` — *"**Shopee's free-text `tier_variation` was deprecated 2025-09-12** for an ID-based tree. Previous marketplace evidence for freeform axis values rests partly on a dead mechanism."*
- `PRIOR:168` — *"**Magento does not auto-create option values on import — it rejects unknown ones** (`Validator.php:128-144`)."*
- `PRIOR:169` — *"**`AttributeOption` / `AttributeOptionGroup` do not exist in this fork** — absent from models *and* every migration. Any list-backed dimension is a build. Upstream Oscar's `AttributeOptionGroup` is additionally *ownerless*, shared with the unrelated basket `Option` model."*
- `PRIOR:170` — *"**No existing soladmin picker offers inline "create new"** — the one autocomplete (`ts/libs/shared/autocomplete/`) resolves picks back to entity rows by UPC. Product attribute values today have **no suggestions and no normalisation at all**. So this decision is unconstrained by existing staff habit, and the inline-add control is genuinely new UI."*

**The three coupling patterns that underpin "the picker label and the typed quantity never touch"** — `PRIOR:263–271`

- `PRIOR:267` — `| (a) the axis **is** an attribute | Magento, Akeneo, commercetools, Walmart, schema.org `variesBy`, Lazada |`
- `PRIOR:268` — `| (b) axis is an entity **linked** to a typed attribute | Shopify alone (`linkedMetafield`) |`
- `PRIOR:269` — `| (c) axis and typed data **parallel and unlinked** | Google, Amazon, eBay, Shopee, Blibli |`
- `PRIOR:271` — *"M8/V3 is pattern (c) — settled 07-29 *before* this comparison existed, and the comparison supports it. **Under (c) the picker label and the typed quantity never touch.**"*

**Where V4/V5 land in the implementation plan** — `PRIOR:341–343` (section `### Model design`)

- `PRIOR:341` — *"5. **Axis and value storage per Decision B** — one value table, a per-dimension governance flag (V2), single text label (V4), `on_delete` semantics. ⚠️ **There are no option/value entity tables in this fork** — `AttributeOption` / `AttributeOptionGroup` are absent from models *and* every migration, so a closed dimension is a build. Upstream Oscar's `AttributeOptionGroup` is additionally *ownerless*, shared with the unrelated basket `Option` model — do not copy it as-is."*
- `PRIOR:342` — *"6. **Two ordering columns, not one** (V5). `display_order` on the *membership* orders variants and picks C2's hero. A **second order column on the value** orders the picker, which is one independent list per dimension. Every surveyed system has the latter; this issue previously had only the former. Also note S4's premise is half-true: `display_order` is a backend convention only — it does not exist anywhere in `ts/`, image "primary" is literally `setProductImage(0)` on server array order, and the admin has no reorder UI."*
- `PRIOR:343` — *"7. **Normalisation on write** (V6) — trim, collapse whitespace, case-fold for comparison. Highest value-per-line in this decision: the `manufacturer` control condition is 23% pure case-and-whitespace redundancy because `value_text` has no normalisation at all (`models.py:742`)."*
- `PRIOR:344` — *"8. **Suggestion endpoint** — auto-derived distinct values per dimension. None exists today"*

**The status framing and the blocking banner**

- `PRIOR:28` — `| **B** | **How axis values are governed** — single text label (V4), per-dimension freeform-or-closed flag (V2), suggestions + normalisation (V6) | ✅ **Locked 08-09** |`
- `PRIOR:30` — `| D | Which dimension gets which setting (V3) | Open — deliberately deferred to launch time |`
- `PRIOR:13` — *"Specifically affected: **Decision B** (V4 single text label, V2 governance flag) presupposes that a dimension is its own entity — i.e. it presupposes one answer to D3. **Decision A** (S5, the family is a `Product` row) cites `parentage_level` from the same doubtful pass — flagged for re-verification, not reopened."*
- `PRIOR:11` — *"**#10966 states those decisions (D1–D7) and owns settling them.** Everything below stays — it is the implementation record and none of it is discarded — but **no further Tier-2 decision (value storage, governance flag, ordering, inheritance) should be locked until D1–D7 land.**"*
- `PRIOR:15` — *"Corrected figures from #10966's 2026-08-11 census: **1,892** categories (not 1,634), **102,739** products, `manufacturer` **41.7%** populated (not 37%)."* — itself later superseded; see §P2.6a.

**The two corrections inside #10778 that bear on value shape** — `PRIOR:283–286`

- `PRIOR:285` — *"~~"a product with no value row simply has no value — workable"~~ — **false**. An unset attribute raises `AttributeError`, not `None` (`catalogue/product_attributes.py:27-34`, pinned by `catalogue/tests/models_test.py:236-249`), and writing `""`/`None` *deletes* the row (`catalogue/models.py:662-668`)."*
- `PRIOR:286` — *"~~"V2 already makes values rows rather than strings"~~ — **there is no such machinery**. `AttributeOption` / `AttributeOptionGroup` are absent from the models **and from every migration**, so absent from the DB schema. Upstream Oscar ships them; our fork (pinned to **django-oscar 3.0.2**) never had them."*

**The 08-10 correction that withdraws V7's Amazon evidence** — `PRIOR:211`

- *"2. ⚠️ **"Apparel binds size to a 512-code closed enum" — FALSE** (this was in the 08-09 record). Apparel size is a **conditional compound**: `size_system`, `size_class` (closed enum `Age`/`Alpha`/`Numeric`), and `size_value` validated against the chosen class. Amazon rejects a partial set."*

**The 08-10 census that reopened the whole question** — `PRIOR:192–202`

- `PRIOR:192` — *"A structural census of **25 platforms** asked one question: is the variant discriminator stored in the same system as ordinary product attributes, or in its own?"*
- `PRIOR:196` — `| **One system** — axis is a marked attribute | **12** | Amazon, Magento, WooCommerce, Shopware, Saleor, SFCC, SAP, commercetools, VTEX, Akeneo, Odoo, Lightspeed R |`
- `PRIOR:197` — `| **Two systems** — dedicated option entities | **10** | Shopify, BigCommerce, PrestaShop, Spree, Sylius, Vendure, nopCommerce, Drupal Commerce, Square, Lightspeed X |`
- `PRIOR:198` — `| Neither | 3 | Pimcore, Medusa, Wix V1 |`
- `PRIOR:200` — *"The split is not random: **catalogue-modelling systems choose one system 5 of 5** (Akeneo, commercetools, SAP, SFCC, Odoo) and **marketplaces choose one system** (Amazon, VTEX), while **storefronts choose two, 8 of 11**. The three storefront exceptions — Magento, WooCommerce, Shopware — are the three oldest and all retrofitted a marker onto a pre-existing system."*
- `PRIOR:202` — *"Two migrations, pointing opposite ways: **Akeneo moved two → one** in 2.0, deleting `variant_group` because variants were second-class (*"could not appear directly in the product grid… no bulk actions or categorization"*). **Salesforce moved the other way for values**, and calls the old shape a mistake in its own API reference — *"historical leftovers from when object attributes were used directly as the basis for variation."*"*
- `PRIOR:218` — *"**Counting new structures**, one system needs roughly **1** (ordered value rows for select-type attributes, which our typed scalars cannot express); two systems needs **3–4**."*

**The catalogue as it stands, from the same issue** — `PRIOR:453` (section `## Evidence`, block `<b>What the catalogue looks like today</b>`)

- *"The existing attribute machinery **cannot** express variant axes — a singleton product class can't say "this family varies on Ukuran and Rasa", **values are strings rather than rows, and there is no value ordering**."*
- `PRIOR:450` — *"`ProductAttribute` is defined per product class; `ProductAttributeValue` is **per product** (`unique_together`). No inheritance, no fallback, no parent lookup."*

**One correction in #10778's own "Corrections to the record" block that touches V1** — `PRIOR:470`

- *"9. **"Nobody in the industry lets axis names be free-typed per product" (V1's stated reason)** — false; Shopify's `OptionCreateInput.name` is a free-form string per product. **V1 remains our choice, but not for that reason.**"*

---

## P2.6 · AUDIT CORRECTIONS AND RETRACTIONS ON #11031 / #10966 TOUCHING VALUES, VALUE SHAPE, ORDERING OR THE MANUFACTURER FIGURES

### P2.6a · THE MANUFACTURER FIGURES — V6's five numbers are retracted, and the corrections themselves drift across three dated measurements

**The headline retraction** — `X:159`:
> *"⚠️ **Every production number originally published in this issue was wrong** — see §6 of the verification report. 🔄 *All of the replacements below were re-measured on 2026-09-03 with `remeasure.sql` against `solvent-staging.production_append_public`; where they drifted from the 2026-09-01 figure, both are shown.* Headlines: **104,733** products (104,633 on 2026-09-01) not 102,739 (the old figure is a 2026-08-10/11 snapshot); `manufacturer` **43.0%** (45,007 / 104,733) not 41.7%; the *"23% case-and-whitespace redundancy"* is **0.70%** under the method actually stated — 5,580 distinct raw values → 5,541 after trim + case-fold — and **4,299** is only reachable by additionally stripping every non-alphanumeric character, so the claim was **off by ~33× as attributed**; *"484 online-sellable products lacking a manufacturer"* is **0**, because every one of the **59,726** products with no manufacturer row is `is_offline_only`; and *"4,806 blank rows"* corresponds to **no measurable population** (0 under every reading the schema permits). The junk share is the one number that moved the other way — **24.6% at the narrowest** (`'0'` on 11,071 of 45,007 manufacturer rows), not 19%."*

**The per-number table** — `X:766–770`:
- `X:766` — `| 6 | Manufacturer coverage | 41.7% | **42.9%** |`
- `X:767` — `| 7 | Distinct raw manufacturer values | 5,564 | **5,580** |`
- `X:768` — `| 8 | Manufacturer values after "trim and case-fold" | 4,290 | **5,541**. `TRIM` alone changes **nothing** (still 5,580 — there is no leading/trailing whitespace in the column). 4,290 is only reachable, at 4,299, by **also stripping every non-alphanumeric character** (spaces, dots, commas, `&`, `PT.` punctuation) |`
- `X:769` — `| 9 | Manufacturer case/whitespace redundancy | 23% | **0.70%** under the stated method (22.96% only under aggressive punctuation-stripping). **Off by ~33× as attributed** |`
- `X:770` — `| 10 | Manufacturer junk share | ~19% | **24.4%** at the absolute narrowest (the single value `'0'`, 10,966 rows); 30.9% exact-list `{'0','-','00','000','.'}`; 31.0% no-ASCII-letter; 32.0% including `'MADE IN…'`. Even the least inclusive measure exceeds 19% — **the claim understates the problem** |`

**The same correction inside the decision record, sitting directly under D8** — `D:1044`:
> *"⚠️ *The 23% figure was wrong — re-measured 2026-09-03 with `remeasure.sql`:* **5,580** raw values → **5,541** after trim + case-fold, i.e. **0.70%**; `TRIM` alone changes nothing because the column has no leading or trailing whitespace, and ~~4,290~~ **4,299** is only reachable by additionally stripping every non-alphanumeric character *(⚠️ 2026-09-02: the body's "4,290" is itself off by nine against the measured alnum-fold figure)*. The real defect is **junk, not case drift**: ~~24.4% at the narrowest (the single value `'0'` on 10,966 rows), 30.9% … 32.0%~~ → **24.6% at the narrowest** (the single value `'0'` on **11,071** of 45,007 manufacturer rows), **31.1%** on `{'0','-','00','000','.'}` (13,984), **31.2%** on "no ASCII letter" (14,024), **32.1%** including `MADE IN…` (14,469 = 14,024 + 445, the two sets being disjoint) — ~~worse than the 19% this record claims elsewhere~~ ⚠️ **2026-09-02 (audit d5): "19%" appears nowhere else in this body** — it was #11031's figure, not this one's. ❗ This is independent of any JSON-vs-rows question."*

**The correction was itself still being echoed** — `X:902`:
> *"1. Two uncorrected echoes of the refuted *"5,564 → 4,290, 23%"* redundancy figure remained — the P4 status row (:132) and the `value_text` row (:255) — while the page's own ⚠️ block already said 0.70%."*

**The 2026-09-02 → 2026-09-03 drift** — `X:889–890`:
- `X:889` — `| Distinct raw → trim+fold → alnum-fold | 5,580 → 5,541 → 4,299 | **5,580 → 5,541 → 4,299** (identical) |`
- `X:890` — `| Value `'0'` | 10,966 (24.4%) | **11,063 (24.6%)** |`

**⚠️ A THIRD dated set, 2026-09-15, which does NOT match the 2026-09-03 set** — `MATRIX:166–178`, section `### What L2.2 is actually about — manufacturer, measured 2026-09-15`:
- `MATRIX:170` — `rows | 46,114 | Of 105,771 products, so 56% have no manufacturer at all — while the attribute is declared required.`
- `MATRIX:172` — `distinct values | 5,580 | Falls to 5,541 after trimming and case-folding: 39 values differ only by case or whitespace.`
- `MATRIX:174` — `value is literally "0" | 12,151 | 26.3% of the rows.`
- `MATRIX:176` — `value is purely numeric | 15,129 | 32.8% of the rows are not a manufacturer name at all.`
- `MATRIX:178` — `used exactly once | 2,759 | Half the vocabulary is singletons — the signature of free text with no shared row behind it.`

> **Report the date with any of these figures.** Rows: 45,007 (09-03) → 46,114 (09-15). `'0'`: 11,071 (09-03) → 12,151 (09-15). Coverage: 41.7% (V6 era) → 42.9% (09-01) → 43.0% (09-03) → "56% have none" (09-15). The distinct/folded pair (5,580 → 5,541) is the one figure stable across all three.

**Where the "37% populated" figure lives** — it appears in **none** of `#11031`, `#10966` or the matrix. Its origin is `PRIOR:132` (V6) itself: *"5,564 distinct values collapsing to 4,290, i.e. 23% pure whitespace-and-capitalisation redundancy, 19% junk, only 37% populated"*, with a corroborating instance at `PRIOR:296`: *"Field health: 37,820 of 102,478 populated (37%), **19% junk** (`0`, `-`), 5,564 raw values collapsing to 4,290 normalised."* **That whole string is what `X:766–770` refutes.**

**Our current write path, as the corrected record states it** — `X:366`:
> *"| `ProductAttributeValue.value_text` | `catalogue/models.py:744` | No trim, no case-fold, no normalisation, no validators, no `clean()` — 🔄 the write path that admits P4's junk share (**24.6–32.1%** on 2026-09-03); case drift itself is 0.70% |"*

And `X:732`:
> *"**Code (15 of 17).** `ProductClass` has only `name` and `slug`, and `default()` is a bare `ProductClass.objects.get()` (C1). … Exactly **six** TYPE_CHOICES, six validators, six `value_*` columns — **no option/multi_option type anywhere under `py/`** (C9). … **`AttributeOption` does not exist anywhere under `py/`** (C15). Nothing normalises `value_text` on the write path — and this is **stronger than claimed**: no validators, no `clean()`, no `save()` override, and `Meta` has only `unique_together ("attribute","product")`, so **no case-insensitive uniqueness either** (C12)."*

### P2.6b · CORRECTIONS TOUCHING VALUE SHAPE

**commercetools withdraws its own reading** — `X:1036` (quoted whole in §13 Q1); `X:122`:
> *"- *Copied, no shared value row (4):* Amazon, Google, eBay, Walmart. 🔄 **commercetools left this bucket** — its Revision-2 record withdraws the "copied … not a foreign key" reading as uncited (#11081 §1.9), so it moves to *not established* and the bucket is 4, not 5."*
`MATRIX:2147` — `Not established1 | commercetools35 | Withdrew its own "copied, no FK" reading as uncited. |`

**Magento's enforcement gloss withdrawn** — `X:1033`:
> *"⚠️ **There is no foreign key on `value`** — each of the five value tables declares exactly 3 FKs (`attribute_id`, `entity_id`, `store_id`), none on the value; **Revision 1's "application-enforced" gloss is withdrawn because no enforcing artifact was found** (#11082 §1.7, §1.9)."*

**D8's ORIGINAL SUPPORTING PLATFORM WAS REMOVED FROM THE SET ENTIRELY** — `D:1042`, the whole D8 paragraph:
> *"**D8 — is a value a shared row, or a string copied per product?** ~~⚠️ **Saleor is hybrid, not shared.** One `AttributeValue` row is shared for **4 of 12** input types (dropdown, multiselect, swatch, boolean); the other **8 are per-instance**, and `NUMERIC` is both axis-eligible *and* per-instance — even the shared path can mint `red-2`.~~ ⚠️ **dropped 2026-09-02 — what remains:** **D8's original support was Saleor, and Saleor was in the *hybrid* bucket, not the shared one.** With it gone the row has no shared-row instance among the original four at all. Of #11031's thirteen, **two** are unqualified shared-row systems and neither is a marketplace — **Square** (`CatalogItemOptionValue`, a full `CatalogObject` referenced by id) and **Magento** (`option_id` stored as an integer in `catalog_product_entity_int.value`, labels fanned out per store view). ~~⚠️ **This row also printed "not recorded" for Amazon and Google — and still has no answer for either**~~ ⚠️ **2026-09-02 (audit a27 — this ⚠️ contradicted the verification's own corrected table):** §4 Q7 answers both — Amazon **"Copied per child"** (single route: *"Most product facts must be replicated across all listings within the variation family"*, 1 hit across 893 pages; `inherit` 0 hits) and Google **"Copied on every row"**; the tally files both under *"copied strings"*. §7 of the verification still calls D8 the worst gap in the evidence base, and that judgement is about **route quality**, not about the answers being absent. ~~Across sixteen platforms: **2 clear shared** (Square, Magento) · **5 clear copy** · **8 hybrid**.~~ ⚠️ **recounted 2026-09-03 over thirteen** (audit e20): **2 clear shared** (Square, Magento) · **4 clear copy** (Amazon, Google, eBay, Walmart) · **6 hybrid** · **1 not established** — commercetools left the "copy" bucket because its Revision-2 record **withdraws** its own *"copied … not a foreign key"* reading as uncited. **Where a value *is* shared, ordering, rename and normalisation come free.** **We copy the string per product** *(a statement of current state, not a decision — D8 is OPEN)*."*

**The retired platform's label was itself wrong** — `X:917`:
> *"2. **Q7 Saleor "shared row for 4 *selectable* types" conflates two lists.** Shared = types **not** in `TYPES_WITH_UNIQUE_VALUES` = `{DROPDOWN, MULTISELECT, SWATCH, BOOLEAN}`. Axis-eligible = `ALLOWED_IN_VARIANT_SELECTION` = `{DROPDOWN, BOOLEAN, SWATCH, NUMERIC}`. They overlap on three. The "NUMERIC is both axis-eligible and per-instance" observation is right; the label is wrong. #10966 D8's parenthetical is the correct one."*

**"D8 has no answer at all for Amazon or Google" — restated** — `X:909`:
> *"8. **"D8 has no answer at all for Amazon or Google"** — the verification's own corrected table (§4 Q7) answers both (Amazon **copied**, Google **copied**). What is true: the two *evidence issues* do not carry the row, and the Amazon answer is single-route. Restated."*

**The D8 tally, as recounted** — `X:120–125`:
- `X:120` — *"**(e) Shares attribute values as rows vs copying strings — 2 shared · 5 copied · 8 hybrid · 1 neither (16) → 🔄 2 shared · 4 copied · 6 hybrid · 1 not established (13).**"*
- `X:121` — *"*Shared rows (2):* Square (`CatalogItemOptionValue`, a full `CatalogObject` referenced by id), Magento (`eav_attribute_option.option_id` stored as an integer in `catalog_product_entity_int.value`; labels fanned out per store view)."*
- `X:123` — *"*Hybrid — the model depends on the attribute kind, the level, or a per-attribute switch (6):* Shopify, Shopee, Tokopedia, Salesforce B2C, WooCommerce (shared `wp_terms` row for a global attribute, copied string for a local one, and the variation's axis value **always** copied), Akeneo (shared `AttributeOption` row; the product stores a copied code string in `raw_values`, integrity by validator not by FK). *(Removed from the old 8: Saleor, schema.org.)*"*
- `X:124` — *"*Not established (1):* commercetools. *(The old "neither (1)" was BigCommerce, removed.)*"*
- `X:125` — *"**What this does to D8:** the platform D8 originally rested on — Saleor, filed *hybrid* rather than shared — is out of the set entirely. Of the thirteen, **two** are unqualified shared-row systems and neither is a marketplace: Square and Magento. **Every marketplace in the set (Amazon, eBay, Walmart, Google) is a clean copy.**"*

**Amazon's five value shapes — the fact holds, the verdict did not** — `X:508`:
> *"| **A7-a** (Amazon) Five distinct value shapes in one schema | Everyone reproduced the five shapes in `listingsItems_2021-08-01.json` (md5 cba24938…) at lines 1947/1957/1969/2023/2192, with at least three more shapes elsewhere. The array-not-string point holds when scoped: 5,016 of 5,018 distinct JSON pointers in the 231,515-row mapping table index into an array. | **The "second route" is the same authored fixture republished** (`manage-product-listings-guide.md` 389–500, `catalogItems_2022-04-01.json`) — three surfaces, one authoring event. The claim is about a **schema**; every artifact is an example instance, and the verifier concedes no product-type schema is publicly retrievable. Fixture is incoherent (productType `LUGGAGE` at line 1916 carrying `total_hdmi_ports`). **"Every value is an ARRAY" asserted with no instrument, and false unqualified** (Fulfillment Inbound's flat `{name, value}`). | An authenticated `getDefinitionsProductType` schema showing the shape variance as declared types rather than as an example … Restate the array rule scoped to Listings/Catalog attributes. |"*
`D:886` — the same claim in the decision record: *"| `A7-a` | Amazon | **VERDICT NOT EARNED** | The FACT is true and everyone reproduced it: one Amazon-published attributes object carries five structurally distinct value shapes — {value, marketplace_id}; {language_tag, value, marketplace_id}; {unit, value, marketplace_id}; {width/length/height sub-measures, no top-level value}; {cell_composition:[{value}], no top-level value} — with at least three more shapes elsewhere (media_location; {name} for variation_them[e]…"*

**Amazon's soft-enum pattern withdrawn as a general rule** — `AMZ:14123–14125` (C1):
> *"**C1 — The soft-enum pattern was overstated. Withdrawn as a general rule.** It is a *minority* shape and mostly infrastructure, not content attributes: `PRODUCT`/es has **3** soft-enum sites vs **119** hard enums; `AUTO_PART`/au has **6** vs **179**, and only 3 of those are content attributes. Amazon's own page shows `merchant_shipping_group.value` as a **hard** enum with no escape, adding: *"To ensure proper mapping … pass the enum key (not the enumNames value)."* Worse, the "free string is valid" half is contradicted by Amazon's runtime — amzn#4968 is titled *"Product Type Schemas advertise anyOf: [string, enum] but backend rejects non-enum strings across multiple product types."* **The validator is stricter than the published schema.** Bears directly on **D6**."*

**Saleor's unit-on-the-attribute claim, also dropped** — `D:888`:
> *"| `SA7-b` | Saleor | **VERDICT NOT EARNED** | The substance is right and now rests on a genuinely independent third route: Attribute.unit = CharField(max_length=100, choices=MeasurementUnits.CHOICES, blank, null) at base.py:194; AttributeValue has no unit column and carries the typed columns instead (value hex, file_url, content_type, rich_text, plain_text, boolean, date_time, numeric, plus five nullable reference FKs). 34 reproduces on three routes…"*

**D9's paragraph, with its drop and its replacement** — `D:1046`:
> *"**D9 — is a value a bare label, or a label plus a typed quantity and a unit?** Amazon carries **five different shapes in one schema**. Shopify: *"the value is always entered and stored as a string, regardless of type."* ~~Saleor puts the **unit on the attribute** (a governed 34-value vocabulary) and typed columns on the **value**.~~ ⚠️ **dropped 2026-09-02 — what remains:** Amazon's five shapes and Shopify's *"always … a string"*, plus ten later records. The systems in #11031's thirteen that carry a typed quantity are **Walmart** (`{unit, measure}` objects on the value — `netContent`, `tireWidth`, `wheelDiameter`), **Shopee** (`value_unit` when `format_type = 2`, from the attribute's own `attribute_unit_list`), and **Akeneo**, which is the closest surviving analogue of the Saleor shape: a `pim_catalog_metric` value is `{amount, unit}` on the wire and `{amount, unit, base_data, base_unit, family}` in storage, drawn from shared `MeasurementFamily` / `Unit` rows — **and `pim_catalog_metric` is one of its five axis-eligible types**. Against them, **Magento** has no unit, quantity, dimension or precision field anywhere on an attribute option (instrument over all 67 `db_schema.xml`, 724,544 B → 0, control `weight` → 12) and **WooCommerce**'s value is six bare fields (control `weight_unit` → 322 against 0 in the attribute-defining files). **We currently put units in the attribute *name*.**"*

**Google's enum list under-printed, and "closed list" rejected** — `GOOG:23`, `GOOG:858–861`, `GOOG:898`:
- `GOOG:23` — *"**"Enumerated typed attributes, whole" printed 6 of 22**, and gave `availability` as 4 lowercase values when [R-5] has **6** including `LIMITED_AVAILABILITY`. → contradiction 8."*
- `GOOG:858` (G4-a, **WRONG AS STATED**) — *"…`message VariantOption { string name = 1 [REQUIRED]; string value = 2 [REQUIRED]; }` held by `repeated VariantOption variant_options = 177 [OPTIONAL]`; **axis names are unconstrained free text**…"*
- `GOOG:859` (G5-a, **WRONG AS STATED**) — *"variant_option's axis NAME is unconstrained merchant free text ("Text. Max. 250 characters."), declared usable everywhere …, with no per-category axis whitelist anywhere. **But the legacy mechanism's axis vocabulary is a closed global list of eight** (answer/6231538: color, size, pattern, material, age_group, gen[der]…"*
- `GOOG:898` — *"**REJECTED:** "closed list" — `closed|exhaustive|complete list|only the|all supported` → 0 hits on [F-11], **the sentence says *"most common types"***; **not applied:** "8 legal axes for apparel, 6 otherwise" — a count in no artifact"*
- `GOOG:861` (G7-b, **WRONG AS STATED**) — *"the 2,500 figure … governs exactly ONE bag — custom_attributes — and "two bags" is wrong. products_v1 exposes at least four merchant-supplied open name/value containers"*
- `GOOG:27` / `GOOG:236` — *"the `variant_option` name list said "whole — 12" while the same document quoted a 13th (`Length`)"* / *"⚠️ Revision 1 said "whole — 12" while **quoting `"Length"` twenty-one lines earlier in the same document**, and normalised `Color`→`color`, `Memory`→`memory`, `Size`→`size`."*
- `GOOG:943` — a published cap that live data refuted: *"| ~~Total size~~ | ~~max 5,000 characters~~ ⚠️ **2026-09-05:** … **live it was not enforced on the processed product**: Σ(len `name` + len `value`) = **5,001** over 20 options persisted whole … **Σ = 15,000** … also persisted whole. **Google publishes no definition of "total"**"*

**Walmart's two explicit RETRACTED blocks, both about value lists** — `WMT:208`, `WMT:215`:
- `WMT:208` — *"⚠️ **RETRACTED — the "mirror".** `swatchImages[].swatchVariantAttribute.enum` is **not** the same enum as `variantAttributeNames.items.enum`, compared on all 6,957 types carrying the fields: **equal on 5,246 · differ as sets on 1,711 (24.6%) · mere ordering differences 0.** … `Toothpastes` is one of the 5,246 where they coincide — **the single case revision 1 generalised from.** … **On 1,711 product types the set of names you may attach a swatch to is not the set you may vary by, in both directions.**"*
- `WMT:215` — *"⚠️ **RETRACTED — "no variant-related changes between the two v5 builds."** The vendor's diff report, parsed from its sheet XML: `Snapshot diff - 1` holds **11,027 rows = 1 header + 11,026 data rows** … and **22 data rows contain `variant`**"*
- `WMT:34` — *"**Two mechanisms on 100% of the objects studied were missing** — the per-attribute `comments` requirement tier (all 383,947 slots) and the `allOf`/`if`/`then` conditional blocks (all 6,967 types); **every "reproduced whole" quote had been dropping `comments`**. **`Tires.tireWidth`/`wheelDiameter` were filed as unit-less scalars** though both are `{unit, measure}` objects and both permitted axes."*
- `WMT:500` — *"⚠️ Two corrections in this one list. **`vehicleType` is 8 values in the recommended build**; the 17-value list revision 1 printed belongs to `0608`. And, caught by **no auditor**: revision 1's summary read *"4 free text, 10 closed list, 2 Number, 2 Decimal"* over a list it had itself printed as five free-text and nine closed. Correct: **5 + 9 + 2 + 2 = 18**."*
- `WMT:205` — *"⚠️ **The eight single-name types, corrected** — revision 1 illustrated the recommended file's minimum with the *previous* file's pair, of which the recommended file supports 25%."*

**Tokopedia — q8 "flatly wrong" and the value catalogue not truncated** — `TOKO:21`, `TOKO:22`:
- `TOKO:21` — *"⚠️ **q8 was flatly wrong.** "Units exist… never on an attribute value" is refuted by the vendor's own schema: `skus.sku_unit_count` pairs a magnitude on the SKU with **"base unit count" and "unit type" *product attributes* served by Get Attributes**. Scoped "Applicable only for the EU market" → recorded and scoped, not erased. → §1.7, §4/U14."*
- `TOKO:22` — *"⚠️ **The Era-A colour catalogue is not truncated.** It holds **12 values, closing cleanly**, including `19 Ungu/Purple/#bf00ff` and `218 Abu-abu/Grey/#5d5d5d`. The old "U12 truncation" claim is deleted. And the size axis holds **16 values, ids 445–460**, of which revision 1 printed 6 with no elision mark — nine of the sixteen are bare numerals."*
- `TOKO:24` — *"⚠️ **Six instrument counts did not reproduce**: `custom` 4→**15** …; `property`/`option` 0/0→**2/1**; `product_variant` 1→**2**; `selection` split 6/2→**4 keys / 3 prose / 1 table header** … Conclusions survive; the instruments as written did not."*
- `TOKO:512` (C11) — *"⚠️ Two corrections to earlier passes here. Revision 1 introduced two of the five as *"Format rules on free text, reproduced whole"* without saying they are error-code text and without reaching `12052935` — which is the member that bears on C3. And audit 2, correcting that, called the five *"identically-worded"* … **it is the literal 6-character escape sequence written out in the message string**, and the five are not identically worded."*
- `TOKO:387` — the global/local id-scope caveat (quoted in §8 Q5)

**Shopee — the deprecation-scope claim is FALSE, and the axis field types are declared five ways** — `SHPE:16`, `SHPE:27`, `SHPE:568–569`, `SHPE:26`, `SHPE:81`, `SHPE:214`, `SHPE:573`, `SHPE:31` (all quoted in §6 above, plus):
- `SHPE:568` — *"| ⚠️ **15** | **One structure, five declarations, three type spellings** | `int32` in 646 and 635 | `int64` in 647 · bare `int` in 636 and in 639. Required-flags diverge too: `variation_option_id` is `required=False` in 646 and 639, `required=True` in 647 and 635 |"*
- `SHPE:569` — *"| ⚠️ **16** | **`tier_index` is declared as a scalar in one record** | `int32[]` in 646 and 635; `int64[]` in 647 | **`int32`, not an array**, in 636. **A non-array `tier_index` cannot express a 2-tier coordinate** |"*
- `SHPE:214` — *"⚠️ **Quote attribution corrected, caught on this pass and by no auditor.** Revision 1 printed `get_variations`' `define` as "228 bytes, verbatim" and attributed it to api 1981 … The text revision 1 printed is 227 bytes and is byte-identical to api **1990**, a record it never cites for it."*
- `SHPE:81` — *"⚠️ **Revision 1 called this "the browse/display category" in a verified voice; that half was not retrieved and is withdrawn.**"*

**eBay — an ORDER claim fully withdrawn, and value-set closure missed inside the window** — `EBAY:244`, `EBAY:887`, `EBAY:24`, `EBAY:25`, `EBAY:22` (quoted in §4 above).

**Salesforce — a false contradiction withdrawn and a false-negative absence instrument** — `SFCC:17`, `SFCC:642`, `SFCC:18`, `SFCC:427`, `SFCC:20`, `SFCC:22`, `SFCC:24`, `SFCC:625`, `SFCC:368`, `SFCC:362`, `SFCC:194`, `SFCC:523` (quoted in §10 above, plus):
- `SFCC:642` — *"**C8 — ⚠️ WITHDRAWN.** Revision 1 asked whether the attribute set comes from *"the category the shopper browsed"* or from *"the product's classification category"*, and filed it as an unresolved disagreement between Help and the Script API. **It is not a vendor contradiction.** … **Revision 1 printed only the third bullet and then reported the gap it had created as a vendor defect.**"*
- `SFCC:427` — *"⚠️ **The gates are the correction.** Revision 1 recorded "no product-type gate on axis eligibility was found", uninstrumented; an auditor replaced that with a real regex and reported 0 hits with a firing control. **Both are wrong: the gate is present in three collected files.** The auditor's line-oriented pattern missed it for two structural reasons — the gate word `only` falls **after** the noun, in a **separate sentence**, inside a **multi-line YAML block scalar** a line-oriented grep cannot span."*
- `SFCC:625` — *"**C4 — ⚠️ CORRECTED. The `Master` description is a mangled copy, and "verbatim" was wrong.**"* · `SFCC:634` — *"In a record whose whole method rests on *verbatim* being load-bearing, that overstatement matters."*
- `SFCC:368` — *"**❌ No cap on axes per master exists in any measurable artifact.** ⚠️ Revision 1's instrument for this was `grep -ciE 'limit|maximum|at most|no more than'` over `catalog.xsd` = 0. **That count reproduces but the pattern cannot express an XSD cardinality bound** — it also scores 0 against all 13 numeric bounds that *are* present."*

**Amazon — the `enum`/`enumNames` contract framing withdrawn** — `AMZ:14045–14063` (quoted whole in §1 Q5).

### P2.6c · CORRECTIONS TOUCHING ORDERING

- **Shopify `S7-c`** — `X:492`, the full corrected statement (reproduced whole in §2 Q4). Its route defect: *"the two routes are one document."* And `X:562` (†5): *"claims S5-b, S7-b and S7-c "rest on one document read twice"; `metafield-linked.md` is served byte-identically at two URLs and was counted as two routes. The Q5 linked-path gating is "documentary only — never observed against a live store.""* (that last clause was itself superseded by the 2026-09-05 live pass, `SHOP:1046–1051`).
- **WooCommerce's `name_num` behaviour was asserted, not run** — `WOO:67`: *"**Derived behaviour was written in a factual voice.** Revision 1 stated what the `name_num` sort emits without running it, and said two constants "can differ in the same request" without tracing one. Both are replaced by executed measurements — a logged SQL query with engine warnings, and the two entry points measured separately (99 rows vs 50 rows)."* · `WOO:404`: *"⚠️ Revision 1 called it "the only numeric handling anywhere"; **no instrument was run for numeric handling elsewhere in the corpus**."* · `WOO:424`: *"**The two queries order the ties differently; whether tie order is deterministic is OPEN.**"* · `WOO:61–63`: *"**Six line citations did not land on the quoted text** — … `wc-term-functions.php` :107 → **:108**"*
- **eBay's image-axis order claim** — `EBAY:244` / `EBAY:887`: *"**C6 — ⚠️ WITHDRAWN to UNRESOLVED.** *"Only the first aspect in the array is used to determine image variation…"* is not reproducible on any route … The contradiction **and** the derived `VariesBy --0..1 effective--> Specification` edge are both withdrawn."*
- **eBay aspect-array order instability, new in Revision 3** — `EBAY:911` (C16), `EBAY:1142` (U10 closed): *"**value lists identical**; `aspects[]` order differs in 15 of 16."*
- **Walmart** — `WMT:208`: *"mere ordering differences 0"* (the two enums differ as sets, not by order).
- **Tokopedia Era A** — `TOKO:528`: same name, same `sort_order`, two objects in the vendor's own success sample, with no group id to disambiguate.
- **Salesforce** — `SFCC:523`: an auditor attack premised on element order refuted (*"18 checked, 0 out of sequence"*), with its own caveat: *"no `lxml`/`xmllint` was available, so it is a deterministic sequence-order subsequence check … **not a full schema validation**."*
- **Google** — `GOOG:1044`: *"the submitted cardinality **0..5** … the **processed** product held **0..10** … 11 → 10, 20 → 10, first-submitted values dropped. **Two numbers from two surfaces, neither withdrawn** → contradiction 11"*
- **Akeneo** — the scoping correction on `sort_order` in §P2.3 above: `X`'s not-found list covers `#11031`/`#10966`/the matrix only; the field **is** in `AKN`.

### P2.6d · THE DECISION-RECORD STATEMENT THAT RE-HOMES V2 / V4 / V5

`D:301`, inside section `# ✅ D3 — a dimension is a `ProductAttribute` playing a role` (`D:276`):
> *"⚠️ **#10778's Decision B must be re-expressed.** Its rows — V4 (a value is a single text label), V2 (a per-dimension governance flag), V5 (a value-ordering column) — all presuppose the dimension is its own object. **The substance survives; the home changes.** The label becomes an attribute value, **the governance flag becomes the attribute's input type**, **the ordering column sits on the value**. None of the reasoning behind those rows is invalidated, and re-expressing them is not a re-decision."*

`D:297`:
> *"**And a separate object buys us nothing here.** We have **no option/enum attribute type today**, so a governed value list is a build either way. The only difference is whether we build one value table or two — and two means the same fact ("Ayam Bawang") maintained in two places, which is the drift this whole design exists to remove."*

Restated twice in `#11031`:
- `X:308` — *"| #10778 | variant grouping — field names, API shape, UI, PR phasing | **Blocked.** Holds S1–S6, M2–M10, C2–C8, P1–P4, Q1–Q3, V1–V6. ⚠️ Its **Decision B must be re-expressed** under D3 — the label becomes an attribute value, the governance flag becomes the attribute's input type, the ordering column moves to the value. **Substance survives; the home changes** |"*
- `X:143` — *"| **D3** ✅ | A variant dimension is an **attribute playing a role**, not its own object | #10778's locked Decision B must be **re-expressed** — substance survives, home changes |"*

**Both D8 and D9 remain OPEN** — `D:82`, `D:83`. `X`'s own explicit not-found list ends: *"any decision that *closes* D8 or D9 (both remain OPEN in all three)."*

### P2.6e · OUR OWN PLANNED HOME FOR THE LIST, THE ORDER AND THE IDENTITY

- `MATRIX:1086` — *"An option attribute type is needed before any axis exists: today's six value columns cannot hold "Ayam Bawang" as anything but free text (D8)."*
- `MATRIX:1088` — *"**What a dimension row is.** ProductVariantDimension / ProductVariantGroupDimension is a real table but a thin one: family FK, attribute FK, **position**. It marks the role and owns nothing else — the name is the attribute's, **the allowed values are the attribute's option list**, whether the list is closed or free text is the attribute's setting (and under D1 + D2 grocery Ukuran and apparel Ukuran are two attributes owned by two categories, **so no per-family flag is needed**), each member's value is its ProductAttributeValue row, and eligibility is the attribute's is_axis_eligible. Precedent: Magento's catalog_product_super_attribute (product id, attribute id, position, per-store label); Amazon is thinner still (a theme string on the parent); **Shopify and Square made the option a full object with its own values, the D3 alternative not taken.** The row can grow a display-label override or a picker default later without breaking D3."*
- `MATRIX:1090` — *"**variant_key**: a denormalised canonical string of the member's dimension values (for example flavour=soto;size=85g), unique per family, so D7's uniqueness is a database constraint rather than a validator over many rows. **Akeneo stringifies for the same reason; Magento keys the pair.**"*
- `MATRIX:1077` — *"Attributes | ProductAttributeValue(product, attribute), one scalar per pair, types text / integer / boolean / float / date / datetime, **no option type** | both |"*
- `MATRIX:152` / `MATRIX:2153` — *"**Ordering, rename and normalisation are free under (a) and (c), and hand-built under (b).**"* / *"(a) a shared value row by FK — needs an option / enum attribute type we do not have · (b) a copied string with normalisation and a validator · (c) hybrid by attribute type — select-typed → shared row, free text → string. **Ordering, rename and normalisation come free only with (a) or (c).**"*
- `MATRIX:149` — *"An axis needs values that can be **enumerated, ordered and renamed**. We have no option or enum attribute type — the six are text, integer, boolean, float, date, datetime — so D4 · D5 · D7 and the variant key have nothing to point at until this is settled. **It is also the only part of the model with pain that is measurable today.**"*
- `MATRIX:262` — *"What is the canonical variant_key? | q2a design | … **it cannot be defined before D8 says what a value is.**"*
- `MATRIX:221–222` — *"D4 eligibility gate · D5 who picks the axes · D6 how many · D7 completeness and uniqueness — **and D8 underneath all of them, because an axis needs values that can be enumerated.** | **D8 first.** See the measurement below: our size axis already exists, written into titles, and it is not sortable as text."*
- `MATRIX:365` — the only rename/identity line in the matrix: *"Tableware and Flatware both render as Peralatan Makan. **Harmless if the id is the identifier and the name is only a label; a real problem if anyone keys on the Indonesian name.**"*
- `SHARED:241` — *"ProductAttributeValue | member | **Decided 2026-09-15: values stay on the sellable row**, so none of the 469,179 existing rows move. If the attribute decision later puts some definitions at family level, this table needs a family column then, not now. | catalogue :719 |"*
- `D:1173` (the 2026-09-16 lock, Condition 2) — *"**Take the four shipping dimensions out of the attribute system** and make them columns on the sellable row, before Lock 1 is implemented. Every product already carries all four, so the columns go in `NOT NULL` with nothing to reconcile. Shopify does the same (`inventoryItem.measurement`), and **not one of the 8,240 attributes in the published Shopify taxonomy is a generic weight or dimension.**"*

### P2.6f · THE BUSINESS CASE FOR ORDERING, IN OUR OWN DATA

`MATRIX:268–286`, section `### Our size axis already exists — it is written into the titles`:
- `MATRIX:270` — *"Measured 2026-09-15 across all 105,786 products. This is the concrete case for taking D8 and D9 before the axis decisions, rather than after."*
- `MATRIX:274` — `Titles containing a unit token — ml, gr, kg, pcs, sachet, botol, dus and the rest | 28,750 · 27.2% |`
- `MATRIX:276` — `Titles containing a multiplier, e.g. 12 x 100 | 2,206 |`
- `MATRIX:280` — *"One real family from our own catalogue, quoted as stored: **SOKLIN SOFTERGENT SAKURA STRAWBERRY 215 GR · 720 GR · 1.44 KG · 2.7 KG**"*
- `MATRIX:282` — *"Four members of one size axis, in two different units. **As bare labels they sort 1.44 KG, 2.15 GR… — wrong, and no amount of validation fixes it, because a label has no magnitude.** That is D9's question in one row, and it decides whether the size axis can be ordered on the product page at all."*
- `MATRIX:285–287` — *"Two more, showing that we need more than one axis kind at once: **REAL GOOD YOGURT DRINK {BLUEBERRY · LYCHEE} × {80 ML · 125 ML}** — flavour crossed with size; **IMPLORA DAYTODAY LITE MATTE LIP CREAM {#01 UPLIFTED · #03 PASSIONATE · #04 HUMBLE · #05 AMBITION} 4 GR** — a shade axis at one size. And a counter-example worth keeping in view: **PIXY FIXED MATTE {CUSHION · POWDER FOUNDATION}** shares a title prefix but is two different product types, not one family — whatever we build has to be able to say no to that."*

---

# THE TALLY, AS THE RECORDS THEMSELVES COUNT IT

**D8 — value shape** (`MATRIX:2132–2147`):
`A shared row 2` — Magento, Square · `Copied 4` — Amazon, eBay, Google, Walmart · `Hybrid 6` — Shopify, Shopee, WooCommerce, Salesforce B2C, Tokopedia, Akeneo · `Not established 1` — commercetools.

**D9 — quantities** (`MATRIX:2161–2178`):
`A typed quantity + unit on the value 3` — Walmart, Shopee, Akeneo · `Typed, no physical unit 2` — eBay, commercetools · `Bare, with the unit elsewhere 4` — Shopify, Salesforce B2C, Tokopedia, Square · `Bare, nothing 2` — Magento, WooCommerce · `Five shapes at once 1` — Amazon · `No row 1` — Google (contradicted by `X:805`).

**Where the allowed list lives**, assembled from the fourteen rows above:
- **(A) on the attribute definition** — Square (`SQ:212`, `SQ:223–226`), Magento (`MAG:410–414`), WooCommerce global attributes (`WOO:305`), Akeneo (`AKN:251–257`), commercetools *per ProductType* (`CT:255–260`), Google one global bag (`GOOG:131`), Shopee value rows keyed by attribute (`SHPE:127`)
- **(B) on the category / product type** — eBay (`EBAY:319`), Walmart (`WMT:88`, `WMT:191`), Amazon (`AMZ:197`, `AMZ:240`), Shopee for *which attributes* (`SHPE:125`), Tokopedia Era A (`TOKO:129`) and Era B (`TOKO:326`), Shopify on the linked path (`SHOP:288–293`, `SHOP:1047–1049`)
- **(C) on the product / family** — Shopify unlinked options (`SHOP:619–620`), WooCommerce product-local attributes (`WOO:240`), Salesforce local `variation-attribute` (`SFCC:160`, `SFCC:417`)
- **(D) no allowed list at all** — Shopify unlinked (`SHOP:620`), WooCommerce (created on write, `X:1122`), Square item options (`SQ:382–388`), Walmart free-text `flavor` (`WMT:474`, `WMT:510`), Google `variant_option` (`GOOG:219–221`)

---

# THREE PREMISES IN THE BRIEF THAT THE RECORDS OVERTURN

1. **eBay does not carry "six orthogonal per-aspect flags" — it carries ELEVEN.** `EBAY:126` — *"**✅ `AspectConstraint` has exactly 11 properties** … **The brief's guessed list of 6 is incomplete.**"* All eleven at `EBAY:97–100`; confirmed live at `EBAY:169`. #10778 V2's clause (`PRIOR:130`) is superseded on the count; its substance — a per-aspect, per-category free/closed switch — holds (`EBAY:109`, `:129`, `:145`, `:157`).

2. **eBay's "value recommendations derived from recent listings" is not in the eBay record at all.** No statement anywhere in `EBAY` says `aspectValues` are derived from listings. The only demand-derived datum is `relevanceIndicator`/`searchCount` — access-gated and **0 of 197,046** live (`EBAY:122`) — and it counts *searches for the aspect*, not value usage. #10778 V6's quoted sentence (`PRIOR:132`) is **uncorroborated by the reference record**, not refuted: the record's corpus is the Taxonomy contract, and the sentence may live outside it.

3. **#10778's Shopee rebuttal of V7 conflates two namespaces.** `PRIOR:141` strikes V7 partly because *"Shopee's `value_id: 0` sidecar accompanies a `tier_variation` mechanism deprecated 2025-09-12"*. `SHPE:206` measures the two namespaces disjoint — *"the number of records containing BOTH `attribute_id` and `variation_id` is 0"*. The sidecar belongs to the attribute namespace (`SHPE:127–129`), which is current; `tier_variation` belongs to the axis namespace, whose replacement `standardise_tier_variation` carries the same 0-sentinel (`SHPE:197–201`).

**And two #10778 claims with no corroboration in their own platform records:**
- *"Magento does not auto-create option values on import — it rejects unknown ones (`Validator.php:128-144`)"* (`PRIOR:168`) — not reproduced anywhere in `MAG`.
- *"commercetools `changePlainEnumValueOrder`"* (`PRIOR:128`) — `CT:266` establishes that **two order-change actions exist** but never prints their names.

---

# WHAT NO RECORD SETTLES

- **Who orders a picker's values** on Shopify (array index — but no statement says who sets it), eBay, Shopee, Tokopedia (either era), Google, or Amazon beyond "the enum array's order".
- **Whether a Shopee catalogue `value_id` is globally or per-attribute unique** — `SHPE:534` (U-7), H1-blocked.
- **Whether Salesforce's `position` is merchant-set or platform-assigned** — `SFCC:183`, present on one of three surfaces, described by none.
- **Whether Walmart's stated per-subcategory attribute ranking exists as data** — `WMT:377`, `WMT:533` (U8): *"the ranked list is published nowhere."*
- **Whether Akeneo's `raw_values` has any DB-level constraint tying a code to an option row** — `AKN:883` (U8).
- **What commercetools returns when a written enum key is not in `values`** — `CT:919` (U7): *"No error type in `api/types/error/` (193 files, 156,912 B) describes that case."*
- **Whether Amazon's `Flavor`, `flavor.value_id` and `Flavor Standardized Values` are three attributes or three views of one** — `AMZ:549` (U16). This is the matrix's declared gate on D8 (`MATRIX:2128`).
- **Whether `flavor` is a closed list on Amazon's JSON side** — `AMZ:548` (U15).
- **Whether WooCommerce's `name_num` tie order is deterministic** — `WOO:424`.
- **Whether Google's D9 row was counted at all** — `MATRIX:2178` vs `X:805`.

---

# PROVENANCE OF THIS DOCUMENT

Three parallel read-only miners produced the eBay / Shopee / Tokopedia / Salesforce, the Google / Walmart, and the matrix / #11031 / #10966 extractions; Amazon, Shopify, Square, Akeneo, commercetools, Magento, WooCommerce and #10778 were mined directly. Returned line numbers were spot-checked against the files (`GOOG:131`, `:141`, `:198`, `:199`, `:661`, `:662`; `WMT:125`, `:136`, `:373`, `:377`) and all matched exactly. One miner's Tokopedia section was truncated in transit; `TOKO` §1.2, §1.3, §1.4, §1.7, §1.8, §1.11 and §3 were re-mined directly, and every Tokopedia quote above comes from that direct pass.

**Nothing in this document is a conclusion.** Where two records disagree — Google's D9 coverage, Shopify's "linked and non-linked cannot be mixed", the three dated manufacturer measurements, eBay's `Size` governance, Salesforce's two axis ids — both sides are quoted and neither is preferred.

