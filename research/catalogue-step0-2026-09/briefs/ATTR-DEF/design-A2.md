# design-A2.md — the one-object and two-object axis shapes, sketched on our real models

Companion to `ATTR-DEF.md` §A2. **This is a design exercise to surface problems, not a migration plan.**
Every code cite is at the pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend
`/home/irvan/copilot/ts-layer2` @ `82187a17bd`. Every judgement is labelled.

Both sketches assume the two locks: the Category **is** the type (Lock 1 — `ProductAttribute.product_class`
becomes `ProductAttribute.category`), and every product belongs to a mandatory separate group table
(Lock 2, shape B — `Product` stays the sellable row and gains a `NOT NULL` FK). They also assume
condition 2 has run: `weight`, `length`, `width`, `height` are `NOT NULL` columns on the sellable row and
`manufacturer` is the entire attribute corpus.

---

## 0 · What we are starting from (the facts the sketches have to work with)

| Thing | Where it is today | Cite |
|---|---|---|
| Attribute definition | `ProductAttribute` — `product_class` FK (**nullable**), `name`, `code` (SlugField, **no unique constraint**), `type` (6 choices), `required` | `py/mono/solvent/catalogue/models.py:608-655` |
| Attribute value | `ProductAttributeValue` — `attribute` FK, `product` FK, `unique_together ("attribute","product")`, six typed value columns | `models.py:719-747`, `models.py:730` |
| Value read/write API | `product.attr.<code>` — a Python container that `setattr`s every value onto itself by `code` | `catalogue/product_attributes.py:5-64` |
| The only production create path | `ProductCreateSerializer.create()`, inside `transaction.atomic()` | `api/apiproduct/staff_serializers.py:98-130` (`Product(` at :116) |
| Value assignment | `_assign_attributes()` — resolves by `code`, rejects codes not on the product class | `staff_serializers.py:65-81` |
| Customer read | `ProductDetailsSerializer.attribute_values` (sorted by `attribute.code`) | `api/apiproduct/serializers.py:194-224` |
| Definition read (staff) | `ProductAttributeViewSet` — `GET .../attribute/all/`, **list only, no create/update** | `api/apiproduct/staff_views.py:57-75`, `staff_urls.py:16` |
| Search index | `ProductIndex` — **no attribute field of any kind**; faceted fields are `category` and `price` only | `solvent/search/search_indexes.py:20-75` (`category` :65, `price` :67) |
| Search document text | title + `title_staff` + `upc` + category + description. **No attribute value is indexed** | `py/mono/templates/search/indexes/catalogue/product_text.txt`, `product_lite.txt` |
| Google feed payload | `availability, condition, description, link, title, price, sale_price, image_link` — **no attribute, no `item_group_id`, no `variant_option`** | `solvent/third_party_api/google/content/products_api.py:214-235` |
| Staff value editor | Formly fields generated from the definition list, one per definition, label from the **frontend i18n bundle** | `ts/libs/product/action/ui-staff-form/.../product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)` |
| Customer spec sheet | Renders every `attribute_value` except a hard-coded deny-list `['internalname']` | `ts/libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.ts:34,47-50` |
| Frontend attribute types | `'float' \| 'text'` — **two** of the backend's six | `ts/libs/product/shared/util-core/src/lib/product-attribute.model.ts:1` |
| **Staff-form** field order | Hard-coded priority array `['internalname','length','width','height','weight']`, applied when the definition list is fetched | `product-attribute-ordering.service.ts:9-15`, applied at `product-attributes-stream.service.ts:33` |
| **Customer spec-sheet** order | The backend, alphabetically by `code` — `sorted(…, key=lambda x: x["attribute"]["code"])` | `py/mono/solvent/api/apiproduct/serializers.py:219-221` |
| **Index / feed fan-out** | `Product` `post_save` → Elasticsearch **and** Google queues. **No receiver on `ProductAttributeValue`**; `Product.save()` enqueues at `:489` *before* `attr.save()` writes at `:490` | `catalogue/receivers.py:31-41`; `catalogue/index_utils.py:11-16`; `models.py:489-490` |

**The fact that dominates both sketches.** There is no option/enum attribute type, no shared value row and
no value-ordering column anywhere in our system (`ProductAttribute.TYPE_CHOICES` at `models.py:641-648`
is text/integer/boolean/float/date/datetime; `ProductAttributeValue` at `models.py:742-747` is six scalar
columns and nothing else). **Both shapes therefore have to build a governed, ordered value list from
zero.** The choice is not "build one or build two", it is *where the one we build lives* — and whether a
second value store appears beside it.

**And the axis values themselves do not exist today.** For the 43 Indomie rows (`sql/results/indomie.csv`,
snapshot 2026-09-19) the flavour is a substring of `title` and of nothing else; every one of those rows
carries exactly the five attribute values `height, length, manufacturer, weight, width`. So under either
shape the axis value is **new authored data for every member**. Nothing inherits for free. That is a
cost both shapes pay equally, and it means the migration cannot be a back-fill from an existing column.

---

## 1 · Shape 1 — one object with a role flag (D3 as closed)

### 1.1 Tables

```
ProductAttribute            (exists)      + is_axis_eligible : bool  NOT NULL default false
                                          + category FK (Lock 1, replaces product_class)
ProductVariantGroup         (Lock 2)      the family row
ProductVariantGroupDimension (new)        group FK, attribute FK, position
                                          UNIQUE (group, attribute); UNIQUE (group, position)
ProductAttributeValue       (exists)      unchanged — the member's axis value is an ordinary row
Product                     (Lock 2)      + group FK NOT NULL
                                          + variant_key (derived, see 1.5)
```

Two new tables where Lock 2 already gives us one, one new boolean, one new thin join row. Nothing about
value storage changes: `ProductAttributeValue` carries the axis value in the same six columns it carries
everything else, under the same `unique_together ("attribute","product")` (`models.py:730`).

The dimension row is the matrix's own sketch — *"ProductVariantDimension / ProductVariantGroupDimension
is a real table but a thin one: family FK, attribute FK, position"* (Catalogue Decision Matrix,
2026-09-16, "Design exercise" §, line 1088) — and its precedent is Magento's
`catalog_product_super_attribute (product_super_attribute_id, product_id, attribute_id, position,
UNIQUE (product_id, attribute_id))` (`~/copilot/research/product-attribute-variant-2026-08/H1-variant-axis-object-vs-attribute.md`
§2.2, re-verified below in §4).

### 1.2 The write path

`ProductCreateSerializer.create()` (`staff_serializers.py:98-130`) already does, in one
`transaction.atomic()` block: build `Product(**validated_data, product_class=ProductClass.default())`,
`product.save()`, `_assign_attributes(product, attribute_values)`, `clean_and_save(product)`.

- The **axis value needs zero new write code**: it arrives in the same `attribute_values` list, is
  resolved by `code` against the product's class/category, and lands in a `ProductAttributeValue` row.
  `_assign_attributes` (`staff_serializers.py:65-81`) already rejects a code the class does not declare.
- What is new: the `group` FK on create (Lock 2's work, not A2's), and the group's dimension rows, which
  need one nested serializer on the group, not on the product.
- **Forced fork: `Product.save()` calls `self.attr.save()` unconditionally** (`models.py:486-491` →
  `product_attributes.py:60-64`), and `attr.save()` iterates *every* definition of the class. Adding a
  sixth definition (`rasa`) therefore touches every product save in the system, not only variant ones.
  That is true today for the five and is not made worse by shape 1 — but it means an axis attribute is
  loaded and re-saved on every ordinary product edit.

### 1.3 The staff editor

The value editor already exists and is generic: `getProductAttributeFields$` builds one field per definition
from `GET api/product/staff/attribute/all/`, typed by
`PRODUCT_ATTRIBUTE_TYPE_TO_FORM_FIELD[productAttribute.type]`
(`product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)`). An axis attribute renders in that form the day it
exists — **one editor, no new screen for values**.

Two things it cannot do today, and both are A2 costs under shape 1:

1. `PRODUCT_ATTRIBUTE_TYPE_TO_FORM_FIELD` maps `float→number` and `text→input`
   (`product-attribute.model.ts:3-9`). A picker needs a **select**, so a new attribute type and a new
   form-field mapping are required. That is the A4 dependency stated as code.
2. The field's **label and unit come from the frontend i18n bundle**, keyed by `code`
   (`product-attribute-i18n.service.ts:20-35`, bundle `ts/assets/i18n/product/{en,id}.json` → six
   hard-coded keys). A staff-authored attribute has no key, so it renders with a missing translation.
   Under Lock 1 (639 nodes authoring their own schemas) that bundle cannot be the naming mechanism.
   **This is a problem shape 1 inherits and shape 2 escapes only for axis names** — see §2.3.

The **definition** editor does not exist on either shape: `ProductAttributeViewSet` is list-only
(`staff_views.py:57-75`) and the only write surface is Django admin (`catalogue/admin.py:51-54,67`).
That is lock condition 1, and it is the same build under both shapes.

### 1.4 Search

`ProductIndex` indexes no attribute at all and facets only `category` and `price`
(`search_indexes.py:65,67`). Under shape 1 a filter on flavour is: one new index field fed from
`obj.attribute_values`, plus one facet. There is exactly **one** value store to read, so there is exactly
**one** filter path, and a non-axis attribute (`manufacturer`) and an axis attribute (`rasa`) are
filtered by the same code.

Lock 2's collapse key is the group FK, independent of A2.

### 1.5 The invariants, and which survive as database constraints

| Invariant | Shape 1 | Enforceable in Postgres? |
|---|---|---|
| A member has at most one value per attribute | `unique_together ("attribute","product")` | **Yes, today** (`models.py:730`) |
| An attribute is a dimension of a group at most once | `UNIQUE (group, attribute)` on the dimension row | **Yes** |
| Every member fills every dimension | "for each dimension row, a PAV row exists for (member, attribute)" | **No** — spans two tables and a variable row count; validator only |
| Siblings' dimension-value combinations are unique | the combination is N `ProductAttributeValue` rows | **No, not directly** — needs a derived, materialised `variant_key` on the member plus `UNIQUE (group, variant_key)` |

The `variant_key` is the price of shape 1, and the lock's own reopen trigger names it: *"the axis key
cannot be made genuinely derived → B loses its distinguishing constraints"* (BRIEF.md §1). Deriving it
means recomputing a concatenation of the member's dimension values on every `ProductAttributeValue`
write — and `ProductAttributeValue` is written from `attribute.save_value()` (`models.py:672-682`), which
is reached from `attr.save()` on **every** `Product.save()`, so the hook point exists but fires very
often.

*Judgement:* this is a real cost and it is the strongest structural argument the two-object side has.
It is not fatal — `unique_together` on a materialised key is an ordinary pattern — but it converts a
would-be database invariant into a derived column plus a trigger-shaped discipline.

### 1.6 The feed

`_get_product_input` (`products_api.py:188-241`) builds a `ProductAttributes(...)` with eight fields and
**reads no `ProductAttributeValue` at all**. Under shape 1, `variant_option` is built by walking the
group's dimension rows and reading the member's `attribute_values` — one join, one loop, in the same
method. `item_group_id` is Lock 2's field. The matrix already records that *"The Merchant feed keys on
product.id, not upc, so item_group_id is a one-field addition in every shape"* (matrix, "What the
exercise adds", line ~1228).

### 1.7 The customer page

`ProductDetailsSerializer` already emits every `attribute_value` (`serializers.py:200,207`) and the spec
sheet already renders all of them minus a deny-list of one (`product-addendum-attributes-ui.component.ts:34`).
So under shape 1 the axis value **appears on the spec sheet for free, whether or not we want it there** —
which is precisely the A0 question, and under shape 1 it must be answered with a flag, because there is
no structural difference between an axis value and any other value. Under shape 2 the separation is
structural and the spec sheet shows nothing new by default.


**⚠️ Both shapes pay the same propagation cost, and the first draft priced neither.** Nothing an axis value
touches reaches Elasticsearch or Google today, because:
- the index/feed push is enqueued by **`Product`'s** `post_save` only — `product_post_save_update_indexes`
  (`catalogue/receivers.py:31-41`) → `update_products_indexes` (`catalogue/index_utils.py:11-16`), which
  fans out to `SearchIndexQueue` **and** `GoogleProductIndexQueue`;
- **there is no `post_save`/`post_delete` receiver on `ProductAttributeValue` anywhere**, so an
  attribute-value-only write is invisible to both;
- and `Product.save()` enqueues **before** it writes: `super().save()` at `models.py:489` fires the
  receiver, `self.attr.save()` at `models.py:490` writes the values.

Instrument: `grep -rn "attribute\|attr\." index_utils.py models_mixins.py` → **0 hits**. So the first
filterable or feed-visible axis value costs **a new receiver on the value model plus a re-ordering of
`Product.save()`**, under shape 1 and shape 2 alike. It is not a differentiator between the shapes; it is
a floor under both, and it belongs in whichever step ships the first attribute-reading consumer.

### 1.8 Problems shape 1 causes — the list

1. **No home for value order.** A `ProductAttributeValue` is `(attribute, product, value_*)`. There is no
   row for "Ayam Bawang" as a *thing*, so `position` has nowhere to live. #10778 V5 records the same gap
   (*"the value-ordering column is missing (new work)"*). Shape 1 only works once A4 gives values rows;
   **stated as a dependency, not decided here** (owner: ATTR-VALUE).
2. **The axis value is visible everywhere an ordinary value is**, so "don't show the axis twice" becomes
   a flag rather than a structural fact (§1.7, A0).
3. **`variant_key` replaces a database constraint with a derived column** (§1.5).
4. **Every axis attribute is loaded and re-saved on every product save** (§1.2).
4b. **Nothing propagates**: a value written without a `Product.save()` never reaches the index or the feed,
    and even with one the enqueue happens first (see the box above). Shared with shape 2.
5. **Attribute naming is still in the frontend i18n bundle** (§1.3).
6. `ProductAttribute.code` has **no unique constraint** (`models.py:614-616` Meta carries only
   `app_label` and `ordering`), and `product_class` is **nullable** (`models.py:617-623`). Two definitions
   may share a code; `ProductAttributesContainer.initiate_attributes` would silently keep the last
   (`product_attributes.py:21-25`). Under Lock 1, where 639 nodes author their own, this becomes a live
   hazard, and it is a hazard for *axes* specifically because an axis code collision changes what a
   picker is.

---

## 2 · Shape 2 — two objects (options for variation, attributes for everything else)

### 2.1 Tables

```
ProductVariantGroup       (Lock 2)   the family row
ProductVariantOption      (new)      group FK, name (or attribute FK), position
                                     UNIQUE (group, name); UNIQUE (group, position)
ProductVariantOptionValue (new)      option FK, label, position
                                     UNIQUE (option, label); UNIQUE (option, position)
ProductSelectedOption     (new)      product FK, option_value FK
                                     UNIQUE (product, option)  ← needs option denormalised onto the row
ProductAttribute          (exists)   unchanged
ProductAttributeValue     (exists)   unchanged
Product                   (Lock 2)   + group FK NOT NULL  (+ variant_key, same as shape 1)
```

Three new tables against shape 1's one, and **a second value store**. This is Shopify's
`ProductOption` / `ProductOptionValue` / `SelectedOption` triple
(H1 §1, re-verified below) and Square's `CatalogItemOption` / `CatalogItemOptionValue` /
`CatalogItemVariation.item_option_values`.

### 2.2 What it buys

- **`position` has a home from day one** on `ProductVariantOptionValue` — the thing shape 1 has to wait
  for A4 to build. #10778 V4/V5's "single text label, hand-ordered by a position column" lands here
  without touching the attribute system.
- **A closed value list is structural**: a member's value is an FK to a row of the option's list, so
  "Soto" cannot be typed twice in two casings. In shape 1 the same guarantee requires A4 to introduce
  option rows for attributes generally.
- **The uniqueness invariant is one table closer**: `UNIQUE (product, option)` is a real constraint, and
  the combination still needs a derived key, but it is derived from FKs rather than from free text.
- **The spec sheet does not change**: axis values are not `ProductAttributeValue` rows, so nothing new
  appears on the product page unless we add it.

### 2.3 What it costs, measured against our code

- **Two write paths.** `_assign_attributes` (`staff_serializers.py:65-81`) writes attribute values.
  Selected options need a second, parallel resolver in the same `transaction.atomic()` block
  (`staff_serializers.py:120-130`). Today that block has one attribute call; it grows a second of a
  different shape.
- **Two editors.** The Formly form generates its fields from the definition list
  (`product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)`). Options are not in that list, so the staff form
  needs a second, differently-shaped section — a select over the group's option values, fed by a
  different endpoint. Two models in `ts/libs/product/shared/util-core` where there is one today
  (`product-attribute.model.ts`).
- **Two filter paths.** A filter on flavour reads option values; a filter on manufacturer reads attribute
  values. `ProductIndex` would carry two families of field, and the API's filter surface would carry two
  query shapes. Today it carries zero of either (`search_indexes.py:59-69`), so this is two builds rather
  than one.
- **Two feed sources.** `variant_option` comes from selected options; any future `product_detail` /
  `brand` / `material` line comes from attribute values. One method, two readers
  (`products_api.py:214`).
- **The duplication the record names.** If flavour must *also* appear on the spec sheet or in a
  cross-category filter, it has to exist in both stores — the same fact in two places, which the D3
  record calls out in its own words: *"two means the same fact (\"Ayam Bawang\") maintained in two
  places, which is the drift this whole design exists to remove"* (#10966, D3 → "Why the marked-attribute
  side won"). **Whether that duplication is actually forced depends on A0**: if the axis is never wanted
  in a cross-category filter and never on the spec sheet, it is not forced.
- **Lock 1 gets thinner.** Under Lock 1 the Category owns the attribute definitions and the *axis
  eligibility*. With options as their own objects, the group's option names are free text unless a second
  category→option-name registry is built — i.e. Lock 1's "the category owns axis eligibility" needs a
  second mechanism, or the option must carry an `attribute` FK, at which point shape 2 has re-absorbed
  shape 1's join row and kept its extra value table. *Judgement: this is the sharpest structural
  objection to shape 2 under our locks, and it is a consequence of Lock 1, not of D3.*

### 2.4 Problems shape 2 causes — the list

1. Two value stores, two editors, two filter paths, two feed readers (§2.3).
2. The same fact in two places whenever an axis is also a displayed or filtered fact (§2.3).
3. Lock 1's axis-eligibility has no natural home unless the option points back at an attribute (§2.3).
4. The attribute system is left exactly as broken as it is today — free text, no order, no closed list,
   `manufacturer` still 15,516 rows with no ASCII letter (`sql/results/manufacturer-as-brand.csv`, 2026-09-19; the narrower junk set {0,-,00,000,.} is 15,475, `sql/results/baseline.json`) — because
   all the new machinery went to the option side. *Judgement:* on our numbers the attribute system is
   where the measurable pain is, and shape 2 spends the budget elsewhere.
5. The migration is larger: three tables and three serializers against one table and one boolean.
6. **Nothing propagates either** — the receiver and save-ordering fix in the box above are owed under this
   shape too, and under it they are owed on *two* value models rather than one.

---

## 3 · A third shape the card does not list — and why it is worth naming

**Shape 1b — one object, role flag, *and* the option rows live on the attribute.** i.e. A4 gives
`ProductAttribute` a value list (`ProductAttributeOption(attribute FK, label, position)`), an axis is an
attribute with `is_axis_eligible`, the group's dimension row points at the attribute, and the member's
value is a `ProductAttributeValue` whose `value_text` (or a new `value_option` FK) resolves to an option
row. This is **Magento's actual shape**: `eav_attribute_option.option_id` is the shared value row, and
`catalog_product_super_attribute` is the per-parent join that promotes an ordinary attribute to an axis
(#11031 tally (e); H1 §2.2-2.3).

It is worth naming because it is what shape 1 *becomes* once A4 answers, and because it obtains every
benefit listed under §2.2 without a second value store. **It is not a new option for A2** — it is shape 1
plus an A4 answer — but a reader comparing §1.8 with §2.2 will otherwise conclude that ordering and
closed lists are reasons to prefer two objects, when they are reasons to prefer *rows for values*.

---

## 4 · Re-verification of the two prior-work claims this sketch leans on

The brief requires prior work to be re-verified rather than inherited.

- **Magento's join row.** `H1-variant-axis-object-vs-attribute.md` §2.2 reproduces
  `catalog_product_super_attribute` with `UNIQUE (product_id, attribute_id)` and
  `catalog_product_super_attribute_label` per `store_id`, from
  `app/code/Magento/ConfigurableProduct/etc/db_schema.xml` (route A: vendor source; route B: Adobe
  merchant docs). #11031's per-decision comment independently states the same object with the same
  uniqueness rule and adds that the eligibility predicate `canUseAttribute()` *"consults **neither** the
  attribute set, nor the category, nor `apply_to`"* (#11082 §1.6). Two records, two routes, no conflict.
  **Confirmed** — see ATTR-DEF.md §A2.2 for the corpus re-fetch.
- **Shopify's option triple and the `linkedMetafield` bridge.** H1 §1 reproduces
  `ProductOption`/`ProductOptionValue`/`SelectedOption` with field-level quotes and a live storefront
  JSON as the second route. #10966's D3 "Why" paragraph leans on the same bridge and flags it: *"Shopify
  shipped `linkedMetafield`, an opt-in pointer from an option to a metafield, and marks it \"currently in
  early access\"."* **Confirmed, with the hedge carried**: the bridge is real and it is the reason the
  1-vs-2 question is not a clean binary even on the platform that most clearly picked 2.

---

## 5 · What each side pays — the card's own research pointer, answered

| Cost the card names | Shape 1 (one object) | Shape 2 (two objects) |
|---|---|---|
| **Duplicated values** | None structurally. One value store; a fact is stored once | Forced **only if** the axis is also displayed or filtered outside the picker (A0 decides). If it is, the same label lives in `ProductVariantOptionValue` and in `ProductAttributeValue` |
| **Two editors** | One — the existing generated Formly form covers axis and non-axis values alike (`product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)`). Plus one new group-level dimension editor, which shape 2 also needs | Two — the generated attribute form **plus** a separate option/selected-option section, on a different endpoint and a different model |
| **Two filter paths** | One index field family, one facet family, one API filter shape | Two of each, in `search_indexes.py` and in the search API |
| Value ordering | **Missing until A4 answers** — nowhere to put `position` | Free — `position` on the option value row |
| Closed value list | Missing until A4 answers | Free — the selected value is an FK |
| Sibling-uniqueness as a DB constraint | Derived `variant_key` over free text | Derived `variant_key` over FKs (`UNIQUE (product, option)` is real) |
| Tables added beyond Lock 2 | **1** (+1 boolean, +1 derived column) | **3** (+1 derived column) |
| Index/feed propagation | a new `post_save` receiver on `ProductAttributeValue` + re-order `Product.save()` (`models.py:489-490`) | **the same**, plus the equivalent on the selected-option model — **not a differentiator, a floor under both** |
| Lock 1's "category owns axis eligibility" | Satisfied by construction — eligibility is a flag on a category-owned definition | Needs a second registry, or an `attribute` FK on the option (which re-absorbs shape 1) |
