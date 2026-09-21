# matrix-A2.md — is a variant dimension an attribute playing a role, or its own object?

Full evidence table for `ATTR-DEF.md` §A2 step 2, re-derived from the thirteen records rather than
inherited from #11031's tally. **Options:** **P1** one object with a role flag (the axis is an ordinary
attribute, marked) · **P2** two objects (a dedicated option/axis object beside the attribute system).

**The question splits in two, and the two halves answer differently.** A platform can declare its axes one
way and store the axis *value* another. Both sub-tallies are given, because the second is the one that
prices our design.

- **(a) Declaration** — what marks an attribute as an axis: a flag/name-list on an ordinary attribute, or a
  dedicated object?
- **(b) Value storage** — where a member's axis value lives: in the same store as its ordinary attribute
  values, or in a separate one?

---

## 1 · Amazon — **P1 / same store**

> "- **The discriminator is an ordinary attribute.** `color`, `shirt_size`, `number_of_items` are plain schema properties, no different from `item_weight`. No separate axis entity exists anywhere in the schemas.
> - **The product type does NOT carry a list of eligible discriminator attributes.** It carries a list of eligible **themes**. The attribute set is reached only through a theme."
— #10976, comment "✅ `variation_theme` — settled"

The whole variant mechanism is three ordinary attributes: `parentage_level`,
`child_parent_sku_relationship`, `variation_theme` — the `variations` property group, whole:
`"variations": { "title": "Variations", "description": "Variations that product uses", "propertyNames":
["parentage_level","child_parent_sku_relationship","variation_theme"] }` (#10976 §1.2).

Amazon's own field descriptions: `ItemVariationTheme` — *"The variation theme is **a list of Amazon catalog
item attributes** that define the variation family."*; `.attributes` — *"**Names of the Amazon catalog item
attributes** that are associated with the variation theme."* — and *"`attributes` is `array of string` in
both — names, not `$ref`s."* (#10976 "Addendum to §6").

**Value storage:** the child's axis value sits in the same `attributes` map as everything else —
`"parentage_level":[{"value":"child"}] … "color":[{"value":"Red"}]` (#10976 SUPERSEDED comment §6).

**Hedges:** the theme token is not the attribute name — *"Note `SIZE` resolves to **`shirt_size`**, not
`size`."* (#10976 §1.5) — so three strings exist per axis: the storefront key, the listing attribute and a
locale-varying display label (#10976 Companion A §5C). The per-type theme enum is **unobserved on the live
model**: *"⚠️ 2026-09-02: this is the **legacy-XSD** shape; the JSON enum is unobserved —
`ItemVariationTheme.theme` is a bare string with **no `enum` key**."* (#10976 §1.5).

---

## 2 · Shopify — **P2 / separate store**, with an opt-in bridge back

`ProductOption` (7 fields, its own `id`, `name` free text, `position`, `values`, `optionValues`,
`linkedMetafield`), `ProductOptionValue` (6 fields, its own `id`, `hasVariants`, `linkedMetafieldValue`,
`swatch`), `SelectedOption` (`name`, `value`, `optionValue: ProductOptionValue!`) (#11011 §1.3, §1.5).

*"✅ **`ProductVariantSetInput.optionValues` is the ONLY non-null field across the entire product-create
input surface.**"* (#11011 §2).

**The bridge, and its hedge, whole:**
> "`LinkedMetafield` description, whole: *"The identifier for the metafield linked to this option.\n\nThis API is currently in early access. See [Metafield-linked product options] for more details."* ⚠️ Revision 1 truncated this at "early access." under a "whole" claim."
— #11011 §2

The linked path's **Requirements**, whole (3 bullets): *"Your app can make authenticated requests to the
latest version of the GraphQL Admin API or higher."* · *"Your app has the `write_products` and
`write_metaobjects` access scopes."* · *"A metafield definition exists with owner type `Product` and type
`list.metaobject_reference` (for example, `custom.color-pattern`)."* (#11011 §2, Rev-5 E13).

Live behaviour of the bridge: linking `shopify.color-pattern` was **refused** with
`INVALID_METAFIELD_VALUE_FOR_LINKED_OPTION` *"At least one value for the option linked to the
'shopify.color-pattern' metafield is invalid"* while `Product.category` was `null`, and **accepted** once
the category was set — while a *custom* unconstrained definition was accepted with `category:null`
(#11011 §2, Rev-5 E13).

*"- The one axis that actually generates variants — `ProductOption` — is **free text**, bound to neither
surface unless you opt in via `linkedMetafield`. The 14,606-category taxonomy does not constrain it."*
(#11011, Observations for the reader).

---

## 3 · Google Merchant Center — **both, required together / written twice**

> "❗ **The axis value is written twice** — once in the typed `[color]`/`[size]` attributes and once inside `[variant_option]`. Google documents both as required together, not as alternatives."
— #11013 §2

Google's own sentence, re-verified and placed: *"**Use all standard variants**: Specify the standard color
`[color]`, pattern `[pattern]`, material `[material]`, age group `[age_group]`, gender `[gender]` and size
`[size]` attributes in addition to variant option `[variant_option]` even when these are part of the set of
variant-identifying properties."* — *"sits at line 87, under `## Minimum requirements` … before `## Best
practices` — disapproval-backed."* (#11013 §2).

**The hedge that must not be smoothed:** *"⚠️ **Looser than the artifact:** nothing retrieved requires the
two written values to be *equal*. Instrument: `same value|equal|must match|identical` over the extracted
text of [R-8] [F-16] → **0** hits"* (#11013 §2).

`VariantOption` is **nested inside** `message ProductAttributes` (*"its fully-qualified name is
**`ProductAttributes.VariantOption`**"*, #11013 §1.5) — i.e. the "separate object" is a repeated field of
the attribute message, not a resource. `name` and `value` are both free text, max 250 chars, and the `name`
is not validated against any set: the nonsense token `qzxjvwkmp` persisted (#11013 Companion C §3).

**Google publishes five different lists of which attributes are axes** (six / four incl. `condition` /
three "like" / eight) and *"no artifact states a closed set"* (#11013 §1.6, §5 contradiction 5).

---

## 4 · eBay — **ambiguous on declaration / same store on value**

Declaration is a **child container with no identity**:
> "✅ **The axis is a child container, not an entity.** Verbatim, `Specification`: *"This type is used to specify product aspects for which variations within an inventory item group vary, and the order in which they appear in the listing."* **A `Specification` has no id and no URI**; it is reachable only through its group."
— #11045 §1.5

But **eligibility is a boolean on an ordinary aspect of the category**: `aspectEnabledForVariations`,
present on **197,046 of 197,046** aspects, `true` **73,833** / `false` **123,213** (#11045 §1.2), with the
vendor's own statement: *"**Not all aspects are allowed as a pivoting aspect.** … **To see which aspects
are allowed as pivoting aspects, you can use the `getItemAspectsForCategory` method and look for a value of
`true` in the `aspectEnabledForVariations` field**"* (#11045 §2).

**Value storage is unambiguous — the same store as any other aspect**, written on each member:
*"Note: **Each member of the inventory item group should have these same aspect names specified through the
`product.aspects` container** when the inventory item is created"* and *"**Aspect names and values are case
sensitive (make sure the names and values use the same case).**"* (#11045 §2). On Trading the axis set is
*"typed as the *same generic container* as ordinary Item Specifics — `ns:NameValueListArrayType`"*
(#11045 §1.9).

**Filed ambiguous on (a)** because eBay satisfies both descriptions at once, which is also #11031's reading
(*"eBay and Walmart satisfy both descriptions and neither cleanly"*).

---

## 5 · Walmart — **P1 by name / same store** *(a departure from #11031, stated)*

> "✅ **The axis is an attribute NAME carried as a string in an array on each member — not an object, and it has no identifier.** Case-sensitive `grep -o` over all 451,013,258 B: `valueId` **0** · `attributeId` **0** · `"$ref"` **0** · `"$id"` **0** · `"definitions"` **0** · `x-walmart` **0** · `groupingAttributes` **0**. The name string is the only handle."
— #11046 §2

The four fields travel together on **6,957 of 6,967** product types: `variantGroupId` (string 1..300),
`variantAttributeNames` (array of a per-type enum, `minItems 1`, **no `maxItems`**), `isPrimaryVariant`
(`["No","Yes"]`), `swatchImages[].swatchVariantAttribute` (#11046 §1.4).

**Value storage:** the axis value is an ordinary attribute value inside the same
`Visible.<ProductType>` node — *"✅ **The axis value is copied per item; there is no shared value row** —
written inline on each member (`"flavor":"Peppermint"` / `"Spearmint"`, both carrying the literal
`"variantGroupId":"001960968586AX6"`)"* (#11046 §2).

**Why #11031 files Walmart "cannot be assigned", and the counter-fact carried whole:** *"**280 types list
18,737 such names**"* that are not their own type's attributes — against the vendor's own rule *"The
specified attribute must also exist in the item's `Visible` section."* · *"If a variant attribute is not
present in the `Visible` section, the submission fails."* (#11046 §5 #3). And the swatch enum differs from
the axis enum as a **set** on **1,711 of 6,957 types (24.6%), in both directions** (#11046 §1.4,
RETRACTED "mirror").

**This brief files Walmart P1** — no axis entity, no ids, the value in the same block — **and states the
divergence.** Moving it back to "cannot be assigned" restores #11031's 4–4.

---

## 6 · Shopee — **P2 / separate store**, two disjoint namespaces

> "✅ **The axis is its own object in its own namespace, not an attribute flagged as an axis.** ⚠️ Instrument restated at full corpus scope: over **all 92 module-89+90 records (1,704,281 B), the number of records containing BOTH `attribute_id` and `variation_id` is 0** — 16 carry `attribute_id` only, 9 carry `variation_id` only, 67 carry neither."
— #11047 §1.4

And from the attribute side, with its control:
> "✅ **No attribute carries an "is this an axis" flag** — instrument **with a control**. Corpus `get_attribute_tree` (19,393 B): `is_axis` → 0, `is_variation` → 0, `"axis"` → 0, `variation` → 0. ⚠️ Control revision 1 never ran: the same record **does** carry boolean flag fields — `mandatory` → 3, `is_oem` → 1, `support_search_value` → 2 — so an axis flag would have been visible in exactly this shape had one existed."
— #11047 §1.2

The axis catalogue is a separate three-level tree, `get_variations(category_id)` →
`standardise_variation_list[] { variation_id, variation_name, variation_group_list[] { variation_group_id,
…, variation_option_list[] { variation_option_id, variation_option_name } } }` (#11047 §1.4).

**Governance is a sentinel on both sides, not an enum:** *"**If you want to use customized variations, then
pass variation_id=0 and pass variation_name.**"* (#11047 §1.4, Announcement 873), mirroring the attribute
side's *"When uploading a user-defined value, "value_id" must be 0 and "original_value_name" is required."*
(#11047 §1.2).

**Typing is asymmetric, and this is the cost:** *"❗ **An attribute value is typed and carries a unit; a
variation option is a bare label.** Instrument at full corpus scope: in the three-file variation corpus
(86,954 B) `value_unit` → 0, `format_type` → 0, `input_validation_type` → 0"* (#11047 §1.2). So Shopee's
two objects have **two different value models**, and the axis one is the weaker.

---

## 7 · Tokopedia — **era-split, in opposite directions**

**Era A — P2 / separate store.** A separate global axis catalogue addressed by id:
`GET /inventory/v2/fs/:fs_id/category/get_variant?cat_id=` → `variant_details[] { variant_id, has_unit,
identifier, name, status, is_primary, units[] { variant_unit_id, unit_values[] { variant_unit_value_id,
value, hex, icon } } }`, plus `variant_id_combinations` (#11048 §1.2). The product-attribute system is a
*different* endpoint, the **Annotation** (*"product specification"*), whose group is a bare name string
with **no id** (#11048 §1.4). *"✅ **The axis is referenced by catalogue id; only the VALUE has a free-text
escape**. There is no documented way to name a new axis in Era A"* (#11048 Companion C §2).

**Era B — P1 / one definition catalogue, role flag.** One call serves both roles:
> "  data.attributes:[]object  "The list of standard built-in product and sales attributes that are bound to the specified category, based on your shop's location.""
> "    type:string        SALES_PROPERTY | PRODUCT_PROPERTY          (enum whole, 2/2)"
— #11048 §1.8

quoted whole:
> "`attributes[].type`: *"The attribute type. Possible values: - `SALES_PROPERTY`: Indicates sales attributes that define product variants. - `PRODUCT_PROPERTY`: Indicates product attributes that describe the product as a whole."*"
— #11048 §1.8

**This is the clearest "one object with a role flag" instance in the thirteen.** The flag also scopes four
sibling fields: `is_requried`, `is_customizable`, `requirement_conditions` and `is_multiple_selection` are
each *"Applicable only if `type=PRODUCT_PROPERTY`."* (#11048 §1.8).

**But the two roles are consumed on different objects**: `product_attributes` at Product depth 0, and
`skus[].sales_attributes` on the SKU (#11048 §1.6, §1.7). And the role flag is **asymmetric**: a custom
*axis* name is allowed (`sales_attributes[].name`, ≤20 chars, *"The system will auto-generate an ID after
listing"*) while a custom *product attribute* is refused — `12052247` *"Do not support custom product
attribute."* (#11048 §3, §5 C3).

⚠️ **A global↔local translation table exists** — `sales_attribute_mappings {global_attribute_id,
global_value_id, local_attribute_id, local_value_id}` — and *"it cuts against calling the Era-B ids "a
shared catalogue"… is **OPEN**"* (#11048 §1.10, U13).

---

## 8 · Square — **P2 / separate store**, and the two systems never meet

`CatalogItemOption` (5 properties: `name`, `display_name`, `description`, `show_colors`, `values`) and
`CatalogItemOptionValue` (5: `item_option_id`, `name`, `description`, `color`, `ordinal`) are both
first-class `CatalogObject` types with their own ids (#11049 §1.3, §1.4).

> "✅ **The axis is its own object, not an attribute flagged as an axis**. Verbatim, the ITEM_OPTION enum element: *"The `CatalogObject` instance is of the [CatalogItemOption] type and represents a list of options (such as a color or size of a T-shirt) that can be assigned to item variations."*"
— #11049 §1.3

*"✅ **The value is a shared row referenced by ID, not a string copied per product**"* — the variation
carries only `{item_option_id, item_option_value_id}` (#11049 §1.4, §2 step 5). And it is shared **across
items**: *"After your application creates a CatalogItemOption—such as "color" with predefined values—that
option can be applied to define the color attribute for any new catalog items."* (#11049 §1.3).

**Whether a custom attribute could ever be an axis is not stated anywhere in the record**; what is measured
is that the governance vocabulary fires only on the custom-attribute schemas and never on the option
schemas — `enforce` 0/1, `allowed` 0/10, `"enum"` 0/3, `config` 0/13, `selection` 0/24, `maxLength` 0/4
(#11049 §1.7). Two mechanisms, neither gated by what the product is (#11049 §3).

---

## 9 · Salesforce B2C Commerce — **P2 / separate store — and the vendor says it migrated here from P1**

> "**❗ The single most important deprecation for anyone modelling SFCC axes**: *"NOTE: Several methods in this class have a version taking a ProductVariationAttribute parameter, and another deprecated version accepting a ObjectAttributeDefinition parameter instead. The former should be strictly favored. **The latter are historical leftovers from when object attributes were used directly as the basis for variation, and the value lists were stored directly on the ObjectAttributeDefinition.** Every ProductVariationAttribute corresponds with exactly one ObjectAttributeDefinition, but values are now stored on the ProductVariationAttribute and not the ObjectAttributeDefinition."* Any account in which axis values live on the object attribute definition describes the superseded design."
— #11050 §1.8

`ProductVariationAttribute` has **3 properties and 3 methods** — `attributeID`, `displayName`, `ID`
(#11050 §1.3). The value side carries a first-class shared/local switch: `VariationAttribute.shared :
boolean`, `shared-variation-attribute` reference vs a local inline copy (#11031 P4 D8).

**This is the only record in the thirteen that states a migration between the two options, and it runs
P1 → P2.**

---

## 10 · Akeneo PIM — **P1 / same store**

> "⚠️ **There is no `Axis` entity, table or column — restated with an instrument and a control.** `Attribute.orm.yml` (5,123 B) and `Model/Attribute.php`, case-insensitive `axis|axes` → **0 hits each**; `find src -iname '*axis*'` non-test → **21 paths on main**, all validators, queries or exceptions over the join table — **none an entity or a mapping**. Positive control: `axis|axes` in `src/Akeneo/Pim/Structure` → **117 hits**."
— #11069 §1.4

> "✅ **Both collections point at the identical interface** — `axes` and `attributes` are each `targetEntity: …Model\AttributeInterface`. **"Is an axis" means "a row exists in `pim_catalog_variant_attribute_set_has_axes` pairing this `variant_attribute_set_id` with this `axes_id`".**"
— #11069 §1.3

Eligibility is a **static 5-element array with no family, category or tenant parameter** —
`pim_catalog_metric`, `pim_catalog_simpleselect`, `pim_catalog_boolean`,
`pim_reference_data_simpleselect`, `akeneo_reference_entity` — intersected with the family's own attributes
(`FamilyAttributeUsedAsAxisValidator`: *"Checks that all attributes used as axis are also attributes of the
family."*), plus three flag gates rejecting localizable / scopable / locale-specific (`AXES_WRONG_TYPE`) and
unique (`AXES_ATTRIBUTE_TYPE_UNIQUE`) attributes (#11069 §1.4).

**Value storage:** in `raw_values`, like every other value. **Cost, measured:** *"❗ **Axis-value comparison
stringifies**: `UniqueVariantAxisValidator` builds `$combination[] = (string)$value;`, joins with `','` and
compares `mb_strtolower` against siblings; `OptionValue` stringifies as `[code]`, `MetricValue` as
`sprintf('%.4F %s', …)`."* — and axes are **immutable once set** (#11069 §1.5).

**Every axis is force-added to the same set's `attributes`** — `setAttributes()` re-adds each axis
(#11069 §1.3): the two roles are structurally inseparable.

---

## 11 · WooCommerce — **P1 / same definition, different value key**

> "✅ **There is no axis object: an axis is an ordinary attribute carrying one boolean.** Instrument I-V: the literal `'variation' => false,` occurs **exactly once** in corpus A."
— #11080 §1.3

`WC_Product_Attribute.$data = ['id'=>0,'name'=>'','options'=>[],'position'=>0,'visible'=>false,
'variation'=>false]` (#11080 §1.3). And the flag is **per (product, attribute), not per definition**: the
same global definition (attribute 3, `pa_flavour`) is `variation:false` on product 22 —
`s:12:"is_variation";i:0` — and `variation:true` on product 10 (#11080 §1.3). **That is shape 1's
per-family dimension row, implemented as a boolean inside a serialised blob.**

**The cost, in the record's own words:**
> "8. **One global attribute value has three simultaneous representations.** The parent points at it by `term_id`; the variation stores its **slug string**; the lookup table stores the `term_id` again. All three are live rows for product 11 / variation 27."
— #11080 §5 #8

And the filter path excludes local attributes with the source's own comment:
`// Custom product attribute, not suitable for attribute-based filtering.` (#11080 §1.10).

No validation of a variation's value against the parent's list: `POST …/variations` with `"option":"Mint"`
returned **201**, stored `attribute_pa_flavour = 'mint'`, and created no term (#11080 §2 step 6).

---

## 12 · commercetools — **neither**

> "**5 — ⚠️ No retrieved artifact declares a selection axis or a generated grid**: `\b(axis|axes|variationTheme)\b` case-insensitive → **0** over C1 (5,387 files, 5,327,276 B), **0** over C2, **0** over C4, and **0** over the Modular tutorial, `variants.md` and `variant-attributes.md`; the unanchored `axis|axes` a naive search would use returns 59 tokens, every one of them the `axes` inside `taxes`."
— #11081 §2

The nearest construct is a property of the **ordinary attribute definition**: `attributeConstraint ∈
{None, Unique, CombinationUnique, SameForAll}`, with *"CombinationUnique: Set of Attributes that have this
constraint, should have different combinations in each variant."* and the vendor's guidance *"Use this
constraint for variant dimensions such as color and size."* (#11081 §1.2, §2).

**Hedges:** the constraint is scoped four different ways across commercetools' own pages (#11081 §5 #2);
*"The `CombinationUnique` constraint is not checked when an Attribute is removed"* (#11081 §1.2); the
vendor's own reference dataset sets `color`/`size` to `"attributeConstraint": "None"` with **0**
`CombinationUnique` across all 21 definitions (#11081 §5 #12); and *"Whether **any** object stores which
attributes are a family's selection axes"* is **U12, unresolved** (#11081 §4).

*Judgement, labelled:* commercetools is "neither" as filed, but the mechanism it does have is a flag on an
ordinary attribute definition, i.e. it leans P1. It is counted "neither" because no axis exists to place.

---

## 13 · Magento / Adobe Commerce — **P1 / same store**, via a per-parent join row

> "✅ **An ordinary EAV attribute becomes an axis by one row, scoped to one parent product**; the same `eav_attribute` may be an axis on unlimited parents, `UNIQUE (product_id, attribute_id)` capping it at one row *per parent*."
— #11082 §1.6

```
catalog_product_super_attribute
  product_super_attribute_id int identity PK · product_id int · attribute_id smallint · position smallint
  FK product_id → catalog_product_entity.entity_id CASCADE ; attribute_id: NO foreign key
  UNIQUE (product_id, attribute_id)
catalog_product_super_attribute_label
  value_id · product_super_attribute_id · store_id · use_default · value varchar(255)
  UNIQUE (product_super_attribute_id, store_id)
```
(#11082 §1.6)

Eligibility, verbatim and complete:
```php
public function canUseAttribute(\Magento\Catalog\Model\ResourceModel\Eav\Attribute $attribute)
{
    return $attribute->getIsGlobal() == …ScopedAttributeInterface::SCOPE_GLOBAL &&
        $attribute->getIsVisible() &&
        $attribute->usesSource() &&
        $attribute->getIsUserDefined();
}
```
*"✅ **The eligibility predicate has four conditions and consults neither the set, nor the category, nor
`apply_to`**"* — instrument `getSetAttributes|attribute_set` over 62,051 B of `Configurable.php` → **0**
(#11082 §1.6).

**The per-family facts live on the join row, not on the attribute** — `position`, `label`, and a per-store
label override (`catalog_product_super_attribute_label`) — which is exactly the "dimension row" shape
(`~/copilot/research/product-attribute-variant-2026-08/H1-variant-axis-object-vs-attribute.md` §2.3,
re-verified 2026-09-19 against #11082 §1.6).

**Value storage:** the child's axis value is an ordinary EAV value — an `option_id` integer in
`catalog_product_entity_int.value` — and *"**The value is a shared row referenced by an integer, not a
string copied onto each product**"* with one uid appearing on two surfaces of one response
(`"Y29uZmlndXJhYmxlLzkzLzUz"` = `configurable/93/53`) (#11082 §1.7).

⚠️ **The headline word "Both" that #11031 attributes to this record is not in it.** Instrument with its
scope, re-run 2026-09-19 over all 1,430 lines of `evidence/issues/11082.md`: case-sensitive `\bBoth\b` →
**3** (lines 688, 765, 943 — an instrument note on the `scanned` row, a `beforeSave()` caller note, and
*"Both classes are registered as p…"*); case-insensitive `\bboth\b` → **33** over the whole record and
**14** over the body alone (to the first `## Comment`). ~~19 times~~ reproduced under no scoping and is
withdrawn. **None of the three is a headline for the axis question**, so the correction to #11031 stands. #11031's note (*"Magento's record headline word is 'Both'; it
is counted as marked because its own body establishes no axis entity"*) therefore rests on a word the
Revision-2 record does not carry. **Filed P1 on the record's own §1.6 headline.**

**Two enforcement paths disagree:** the REST route `POST /V1/configurable-products/:sku/options` runs
neither `canUseAttribute()` site, *"Whether any axis-eligibility gate runs on `POST …/:sku/options` is
open"* (#11082 §2 step 5, U15); and the Admin picker admits a different population from the API
(#11082 §5 C6).

---

## Tallies

### (a) Declaration — is the axis marked on an ordinary attribute, or its own object?

| Option | Count | Platforms |
|---|---|---|
| **P1** one object with a role flag / name list | **5** | Amazon · Walmart · Akeneo · WooCommerce · Magento |
| **P2** a dedicated axis object | **4** | Shopify · Shopee · Square · Salesforce B2C |
| **both, required together** | 1 | Google |
| **neither** | 1 | commercetools |
| **ambiguous** | 1 | eBay |
| **era-split, opposite directions** | 1 | Tokopedia (Era A = P2 · Era B = P1) |

**Named ambiguous / hedged rows:**
- **eBay** — a `Specification` child container with no id (P2-shaped) sitting on top of
  `aspectEnabledForVariations`, a boolean on an ordinary category aspect (P1-shaped). Both at once.
- **Walmart** — filed P1 here; #11031 files it "cannot be assigned" because **280 of 6,967 types name axes
  that are not their own attributes** and the swatch enum differs from the axis enum on **1,711 types**.
  Moving it back restores #11031's 4–4.
- **Google** — requires both mechanisms and writes the value twice; equality between the two is **not
  stated by any artifact**.
- **commercetools** — no axis exists to classify; its nearest mechanism is a flag on an ordinary attribute
  definition, so it leans P1 without being it.
- **Tokopedia** — the two eras answer in opposite directions and are not merged. Era B is the live one.
- **Magento** — #11031's "Both" headline is not present in the Revision-2 record (verified 2026-09-19).

**So the declaration tally is 5–4 with five rows that could move it either way — the tie #11031 found is
intact in substance.** No plurality can be claimed, and there is **no industry rule to adopt**.

### (b) Value storage — is the axis value in the same store as ordinary attribute values?

| Answer | Count | Platforms |
|---|---|---|
| **Same store** | **6** | Amazon · eBay · Walmart · Akeneo · WooCommerce (same definition; the variation's copy is a different meta key) · Magento |
| **Separate store** | **4** | Shopify · Shopee · Square · Salesforce B2C |
| **Both — written twice** | 1 | Google |
| **N/A — no axis** | 1 | commercetools |
| **Era-split** | 1 | Tokopedia (A separate · B one definition catalogue, two value fields) |

*Judgement, labelled:* on the half of the question that actually prices our build — where a member's
flavour value lives — the evidence leans **same store, 6 to 4**, and the one platform that duplicates
(Google) documents the duplication as a requirement rather than a design. That is still a split, not a
unanimity.

### (c) What each side pays, from the records' own words

| Cost | Evidence on the P1 side | Evidence on the P2 side |
|---|---|---|
| **Duplicated values** | Amazon: *"Most product facts must be **replicated** across all listings within the variation family."* — with the quantifier hedge *"the quantifier is "Most""* (#10976 §2). Walmart: *"The axis value is copied per item; there is no shared value row"* (#11046 §2). eBay: each member repeats the aspect (#11045 §2b) | Shopify: a `ProductOption` is reached only through its product (`productOptionsCreate(productId: ID!, …)`, `Product.options`), so its values are per product, not shared (#11011 §1.3; the #10778 corpus file `H1-variant-axis-object-vs-attribute.md` §1 ran the counter-search for a shop-level option registry and recorded **"Not found."** — re-verified 2026-09-19 against #11011 and **confirmed**). Square is the counter-case: the option value **is** shared across items (#11049 §1.4). WooCommerce: *"One global attribute value has three simultaneous representations."* (#11080 §5 #8) |
| **Two editors** | Akeneo: one editor — an axis is force-added to the same attribute set (#11069 §1.3). Magento: but Adobe adds a set gate and an auto-fix modal, *"The attribute-set gate is documented as a constraint and implemented as an auto-fix."* (#11082 §5 C7) | Square: two mechanisms, and *"neither is keyed to what the product is"* (#11049 §3). Shopee: two disjoint API namespaces, 0 of 92 records carry both ids (#11047 §1.4) |
| **Two filter paths** | Magento: one value store (`catalog_product_entity_int.value = option_id`) serves both (#11082 §1.7) | Square: `CatalogQueryItemsForItemOptions` and `CatalogQueryItemVariationsForItemOptionValues` are separate query classes from the custom-attribute search path (#11049 §1.4, §2 step 8) |
| **Weaker typing on one side** | — | Shopee: *"An attribute value is typed and carries a unit; a variation option is a bare label."* (#11047 §1.2) |
| **A bridge back** | — | Shopify shipped `linkedMetafield`, *"This API is currently in early access."* (#11011 §2). Salesforce migrated **away** from P1 and says so (#11050 §1.8) |

### (d) D5 — does the family choose its dimensions, or does the type impose them?

Derived here because `ATTR-DEF.md` §A2.7 needs it and an earlier draft asserted an unsourced *"6 of the 7"*
that appears nowhere in the evidence. Source: #11031's per-decision comment, **P3 · D5**, which covers
**10 of the 13** — Amazon, Shopify and Google have no row there.

| Answer | Count | Platforms, with the record's own mechanism |
|---|---|---|
| **The family chooses, from the gated set** | **8** | eBay (`variesBy.specifications[]`, §1.5) · Walmart (`variantAttributeNames` per item, §1.4) · Shopee (`standardise_tier_variation` per item, §1.4) · Tokopedia (`sales_attributes` per SKU, §1.7) · Square (`item_options[]` on the item, §2 step 3) · Salesforce (the master's `variationAttributes`, §2b) · Magento (*"a `catalog_product_super_attribute` row is scoped to **one parent product**"*, §1.6) · WooCommerce (*"demonstrated live: the same global definition … is `variation:false` on product 22 … and `variation:true` on product 10"*, §1.3) |
| **The structure imposes** | **1** | Akeneo — axes on `FamilyVariant`/`VariantAttributeSet`, `x-immutable: true` |
| **Neither** | **1** | commercetools — *"nothing anywhere declares an axis, so there is nothing for either party to choose"* |
| **Not covered by the row** | 3 | Amazon · Shopify · Google |

⚠️ **Akeneo's own hedge, carried whole** (#11031 P3 D5): *"⚠️ **Classification note — this is a judgement,
and the record does not make it.** A `FamilyVariant` is itself a merchant-authored per-family structure
row, and *"You can create one or more family variants in each family"*, so on a narrower reading the family
still chooses — once, at family-variant creation — and then freezes it. Filed as "the structure imposes"
because the axes live on a **type-level** row that many product models share, not on the container
instance."* On the narrower reading the tally is **9 · 0 · 1**.
