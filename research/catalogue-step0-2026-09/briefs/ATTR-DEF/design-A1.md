# design-A1.md — the column-versus-attribute rule, sketched on our real models

Companion to `ATTR-DEF.md` §A1. **A design exercise to surface problems, not a migration plan.** Code cites
at the pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend `/home/irvan/copilot/ts-layer2` @
`82187a17bd`. Numbers from `sql/` in this directory, snapshot 2026-09-19. Every judgement is labelled.

---

## 0 · We already have four homes for a product fact, not two

The card frames A1 as "column or attribute". Our code has **four** places a product fact can live, and the
fourth is the one doing most of the work today.

| Home | What is in it | Cite |
|---|---|---|
| **1. A column on the sellable row** | `upc`, `title`, `title_staff`, `notes_staff`, `slug`, `description`, `is_public`, `is_offline_only`, `is_active`, `thumbnail_url_cache`, plus five FKs (`product_class`, `main_category`, `price_sell_online`, `inventory_facility_online`, and the M2M to attributes) | `py/mono/solvent/catalogue/models.py:351-456` |
| **2. A column on a mandatory 1:1 side table** | `ProductMeta.quantity_purchasing_allowed_multiples`, `ProductMeta.quantity_per_box` — *"For storing rarely accessed metadata for products."* Auto-created on every product by a `post_save` receiver | `models.py:895-910`; `catalogue/receivers.py:28` |
| **3. A `ProductAttributeValue` row** | `manufacturer`, `weight`, `length`, `width`, `height` — the whole corpus, five definitions | `models.py:608-747`; `sql/results/attribute-definitions.csv` |
| **4. Inside the `title` string** | net content (26,317 titles carry a unit token), pack count (`ISI N` on 3,519; `N x M` on 1,691), flavour (every Indomie flavour), brand-as-the-shopper-knows-it | `sql/results/title-facts-vs-attributes.csv`; `sql/results/indomie.csv` |

A fifth, half-home, matters for A1 because it holds part of the **definition**: the attribute's display
name and its **unit** live in the frontend i18n bundle, keyed by `code`
(`ts/assets/i18n/product/{en,id}.json` → `attribute.key.<code>.{name,unit}`, six hard-coded keys;
`ts/libs/product/addendum/util-i18n/src/lib/product-attribute-i18n.service.ts:20-35`). The database's own
`ProductAttribute.name` is **never sent to any API client** — `ProductAttributeSerializer` exposes
`["code"]` and `ProductAttributeFullSerializer` `["code","type","required"]`
(`py/mono/solvent/api/apiproduct/serializers.py:164-176`) — though it **is** rendered by Django admin on
four paths (§5 defect 1), which is where the staff-facing label of record actually lives today.

*Judgement:* any A1 rule that speaks only of "column or attribute" will silently leave homes 2, 4 and the
i18n half-home unruled, and those are where the drift is.

---

## 1 · Option 1 — "universal and read by code → column; category-specific and staff-authored → attribute"

### 1.1 What the rule selects, tested against our code

The rule's left half is decidable by Grep. Every product fact that backend code reads today:

| Fact | Read by | Cite | Rule says |
|---|---|---|---|
| `weight` | shipping quote, basket line weight | `third_party_api/biteship/biteship.py:90`; `basket/models.py:1265` | column |
| `length` / `width` / `height` | shipping quote, basket volume | `biteship.py:60-62`; `basket/models.py:1272-1274` | column |
| `main_category` | age wall, replenishment filter, search index, feed link | `models.py:571-573`; `inventory/replenishment/inventory_replenishment_service.py:31-36`; `search/search_indexes.py:65` | column (it is one) |
| `title`, `upc`, `description` | feed, search, label printing | `third_party_api/google/content/products_api.py:214-222`; `search/search_indexes.py:29-37` | column (they are) |
| `is_active`, `is_offline_only`, `is_public` | feed eligibility, browsable | `models.py:501-515`; `catalogue/managers.py:11-26` | column (they are) |
| `quantity_per_box`, `quantity_purchasing_allowed_multiples` | replenishment, purchasing | `inventory_replenishment_service.py:114`; `purchasing/purchasing_quantity_service.py:39,158`; `transport/models/models.py:222` | column (they are — on `ProductMeta`) |
| **`manufacturer`** | **nothing** — `grep -rn "manufacturer" --include=*.py py/mono/solvent/` returns **0 hits outside migrations** | — | attribute |

**The rule reproduces lock condition 2 exactly, and it reproduces the rest of our schema exactly.** Every
fact code reads is already a column except the four dimensions, which condition 2 moves; the only fact code
does not read is the only one the rule leaves as an attribute. *Judgement: this is the strongest evidence
for option 1 on the table — our own code already implements it, and condition 2 is the one correction it
needs.*

### 1.2 What it does to the five existing attributes

| Definition (`sql/results/attribute-definitions.csv`) | Rows | Post-condition-2 |
|---|---|---|
| `weight` — `Berat (gram)`, float, required | 106,161 | → `NOT NULL` column |
| `length` — `Panjang (cm)`, float, required | 106,161 | → `NOT NULL` column |
| `width` — `Lebar (cm)`, float, required | 106,161 | → `NOT NULL` column |
| `height` — `Tinggi (cm)`, float, required | 106,161 | → `NOT NULL` column |
| `manufacturer` — `Manufacturer`, text, required | 46,499 | **stays an attribute — and is the entire corpus** |

Three things the numbers say about that migration, none of which is an argument against it:

1. **68.5% of the dimension rows are a placeholder.** 290,774 of 424,644 dimension rows are `0`; 72,635
   products have all four at zero; 72,644 have `weight = 0`
   (`sql/results/attribute-uses-and-visibility.csv`, `title-facts-vs-attributes.csv`). A `NOT NULL` column
   defaulting to `0` carries the same non-fact into a stronger-looking place. `required=True` on the
   definition is already not an enforcement: it is only checked in `validate_attributes()` on the
   clean/save path (`catalogue/product_attributes.py:36-52`, reached from `Product.clean()` at
   `models.py:484`), so it constrains new writes, not the 59,662 products with no `manufacturer` row.
2. **`weight` is doubly loaded.** For 10,036 of the 12,676 products where the title carries a gram number
   *and* `weight > 0`, the two agree exactly (`title-facts-vs-attributes.csv`) — i.e. staff have been using
   the shipping-weight attribute to record **net content**. 2,640 disagree. After condition 2 the column is
   "shipping weight", and the net-content fact it was carrying for 10,036 products has nowhere to go except
   back into the title. *Judgement: this is a real gap condition 2 opens, and it belongs to A4/TREE (a
   net-content attribute), not to a re-litigation of condition 2.*
3. **After condition 2 the attribute system holds exactly one definition**, used by 43.8% of products, junk
   on 33.4% of those (15,516 of 46,499 rows have no ASCII letter; the narrower junk set {0,-,00,000,.} is 15,475). So option 1's "attribute" side is, today,
   a one-row table holding a field nothing reads.

### 1.3 What it costs in code

Nothing new. `ProductAttribute` / `ProductAttributeValue` stay as they are; condition 2 adds four columns
and rewrites **8 read sites in 3 methods across 2 files** — `biteship.py:60,61,62,90` (`_parse_product`)
and `basket/models.py:1265,1272,1273,1274` (`line_weight_gram`, `line_dimension_cm`); ~~six call sites~~
was a miscount, re-measured at the pin (a 9th `attr.weight` is a docstring at
`product_attributes.py:10`). Plus the staff
serializer's `attribute_values` list loses four entries and the staff form four generated fields.

### 1.4 The problems it causes

- **The rule is unstable in one direction.** "Read by code" is a property of *today's* code. The day a promo
  rule reads `rasa`, or the feed sends `brand`, a staff-authored attribute becomes code-read and the rule
  says "promote it to a column" — i.e. a migration per new consumer. Magento's answer to the same problem
  is to make *everything* an attribute and let code read attributes (`name`, `price`, `weight` are all
  `eav_attribute` rows — #11082 §3.2); Shopify's is to keep a fixed built-in set and never promote
  (#11011 §1.1-1.2). Ours would be neither.
- **It gives no rule for home 2.** `quantity_per_box` is universal and code-read, so the rule says "column"
  — and it *is* a column, on `ProductMeta`, for a stated performance reason (*"For storing rarely accessed
  metadata for products."* `models.py:896`). The rule cannot tell you which of the two column homes to use.
- **It gives no rule for home 4.** Net content is universal and *not* read by code (it is in the title), so
  the rule says "attribute" — which is right, and which means the rule's output for our biggest data gap is
  "author a new attribute for 26,317 products", i.e. the rule is satisfied by the status quo plus work
  nobody has scheduled.

---

## 2 · Option 2 — "everything is an attribute, even the title"

### 2.1 The shape on our models

`Product` keeps `id`, `upc` (identity), `slug`, the two online FKs and the three booleans; `title`,
`description`, `title_staff`, `notes_staff` and the four dimensions all become `ProductAttribute` rows with
values in `ProductAttributeValue`. `ProductAttribute` grows what a definition needs to carry a title:
per-locale values (we have `en`/`id`), max length, and a `unit` (today in the i18n bundle).

### 2.2 What breaks, counted

| Consumer | Today | Under option 2 |
|---|---|---|
| `Product.title` as a DB column | `models.py:392`, `max_length=255` | gone — `slug` is `AutoSlugField(populate_from="title")` (`models.py:405-408`) and `Product.save()` slugifies `get_title()` (`models.py:487-489`); both need a value that is now in another table |
| `Product.clean()` | `if not self.title: raise ValidationError` (`models.py:481-482`) | a cross-table check |
| Search index | `title = CharFieldExact(model_attr="title")`, `title_compound`, `autocomplete_en/id`, `autocomplete_staff` (`search/search_indexes.py:34-56`) | five index fields lose their `model_attr`; each needs a `prepare_*` that walks `attribute_values` |
| Search document template | `{{ product.title }} {{ product.title_staff }} {{ product.upc }}` (`py/mono/templates/search/indexes/catalogue/product_lite.txt`) | template must walk a value bag |
| Feed | `title=product.title.title()` (`products_api.py:222`) | same |
| Staff form | `title` is a hand-written Formly field with its own label and placeholder (`product-update-staff-form-ui.component.ts:77-87`) | becomes one of the generated fields, losing the placeholder and the required flag unless the definition carries them |
| Spec sheet | renders every attribute value minus a deny-list of one (`product-addendum-attributes-ui.component.ts:34,47-50`) | the title now renders inside the spec sheet unless excluded |
| `title_staff` readers | `get_title_for_staff()` (`models.py:580-592`), `prepare_autocomplete_staff` (`search_indexes.py:93-96`), printer labels | each becomes a bag read |

Roughly **20 call sites** for `title` alone, against **6** for the four dimensions under option 1.

### 2.3 The structural objections

- **Our value table cannot hold a title.** `ProductAttributeValue` has `unique_together ("attribute","product")`
  (`models.py:730`) and six scalar columns with **no locale and no scope** (`models.py:742-747`). A
  title is per-locale for us (the frontend ships `en` and `id` bundles). Amazon's equivalent carries
  `"selectors": ["marketplace_id","language_tag"]` on `item_name` (#10976 Tier-3 §2.1) and Akeneo's carries
  `{"locale": …, "scope": …, "data": …}` per value (#11069 §1.6). Option 2 is not "move a column into the
  existing table" — it is "rebuild the value table with selectors first".
- **We would be adopting the shape whose own owners keep a scalar copy.** Amazon has `item_name` and
  `brand` inside the product-type schema *and* `ItemSummaryByMarketplace.itemName` / `.brand` as plain
  strings on the read side (#10976 §1.6). Akeneo, the purest case, still keeps `identifier`, `enabled`,
  timestamps and every structural edge as mapped columns (#11069 §1.7). Nobody stores *everything* in the bag.
- **It costs exactly what option 1's instability costs, inverted.** Option 2 never needs a promotion
  migration, and pays for it on every read of every core field, forever.

*Judgement: option 2 is coherent and is what a PIM would do, and it is wrong for us at this size — it
rebuilds the value table and rewrites ~20 core call sites to solve a problem (promotion churn) we have had
zero instances of.*

---

## 3 · Option 3 — "a small fixed set of custom fields beside the columns" (Square)

### 3.1 The shape

Cap the attribute system: N definitions, globally, full stop. Square's published cap is *"Each Square
account can have up to 10 seller-visible and 10 seller-hidden custom attributes."*, live-verified at 10+10
with `ITEMS_CUSTOM_ATTRIBUTE_LIMIT_EXCEEDED` on the 11th (#11049 §1.x) — though the record leaves the cap's
**scope** unresolved (account vs application vs `app_id`, #11049 §5 #10).

### 3.2 Fit against our numbers

- Today: 5 definitions. Post-condition-2: **1**. A cap of 10 or 20 is not binding on anything we have.
- Under Lock 1 it is binding on everything we want: the Category owns the definitions and there are 639
  nodes covering 90% of products. A global cap of 20 and a 639-node schema are contradictory unless the cap
  is *per category*, which is a different design (and is what Walmart does with per-type schemas: 6,967
  types, 2,323 distinct attribute names — #11046).
- Square itself pairs the cap with a *separate* axis object (`CatalogItemOption`, #11049 §1.3) and with 27
  built-in fields on the item (#11049 §1.2), i.e. the cap is small because the built-in set is large.

*Judgement: a cap is a governance knob, not an answer to A1. It becomes interesting only after Lock 1 as a
**per-category** cap ("a node may declare at most N attributes"), which is a step-1 decision, not this one.*

---

## 3b · Option 4 — one definition registry, two storages (added 2026-09-19 from the Magento source pass)

### 3b.1 The shape on our models

```
ProductAttribute   (exists)  + storage : enum('value_row','column')  NOT NULL default 'value_row'
                             + source_field : CharField  null  — e.g. 'weight', 'productmeta.quantity_per_box'
                             + unit : CharField  null          — today only in name-text and the TS bundle
                             + display_order : Int
                             + is_customer_visible : bool
ProductAttributeValue (exists) unchanged — it simply holds nothing for storage='column' rows
Product            (exists)  + weight/length/width/height columns (condition 2)
```

Precedent, verified at source 2026-09-19: Magento installs `sku`, `has_options`, `required_options`,
`created_at` and `updated_at` as `eav_attribute` rows with `'type' => 'static'`
(`CategorySetup.php:410-421, 809-865`), and `AbstractAttribute::isStatic()` (`:794-801`) is the switch that
sends reads to a column of `catalog_product_entity` instead of to an EAV value table.

### 3b.2 What it changes in our code

| Consumer | Today | Under option 4 |
|---|---|---|
| `ProductDetailsSerializer.attribute_values` (`serializers.py:200,207`) | reads `product.attribute_values.all()` | reads the definition list; for `storage='column'` resolves `getattr(product, source_field)` |
| Staff form field generation (`product-update-staff-form-ui.component.ts:147-169 (`getProductAttributeFields$`)`) | one field per definition, all of them value rows | unchanged — a column-backed definition generates the same field |
| Staff write path (`staff_serializers.py:65-81`) | `setattr(product.attr, code, value)` | branches once on `storage` |
| Spec-sheet deny-list (`product-addendum-attributes-ui.component.ts:34`) | hard-coded `['internalname']`, and `internalname` no longer exists | deleted — replaced by `is_customer_visible` on the definition |
| Staff-form ordering array (`product-attribute-ordering.service.ts:9-15`, applied at `product-attributes-stream.service.ts:33`) | hard-coded, contains the same dead code | deleted — replaced by `display_order` |
| Spec-sheet ordering (`serializers.py:219-221`) | backend `sorted(…, key=attribute.code)`, alphabetical | also replaced by `display_order` — **a second change on a second stack, unpriced in the first draft** |
| i18n key-set (`ts/assets/i18n/product/{en,id}.json`) | six hard-coded keys, one the dead `internalname` | `name`/`unit` move to the definition; the bundle becomes an override |
| i18n label/unit bundle (`ts/assets/i18n/product/{en,id}.json`) | six hard-coded keys; a staff-authored attribute has no key | the definition carries `name` and `unit`; the bundle becomes an override, not the source |
| Condition 2 | the four dimensions' definitions are **deleted** with their names and units | the four definitions survive with `storage='column'` |

### 3b.3 The problems it causes

1. **Drift between the registry and the columns it names.** A `storage='column'` row whose `source_field`
   no longer exists is a runtime `AttributeError` in the serializer. Mitigation: a test that resolves every
   such row at import. *Judgement: cheap, and the risk is real.*
2. **Two write semantics behind one editor.** A column write is a plain field assignment; a value-row write
   goes through `attribute.save_value()` (`models.py:672-682`). The branch lives in one place
   (`_assign_attributes`), which is better than the alternative of teaching every consumer both, but it is
   still a branch on the single production create path.
3. **It tempts the registry to describe things it should not** — `price_sell_online`, `is_public`. The
   guard is the A1 rule itself: a definition exists for a fact staff *author*, not for every column.
4. **It is not in the card's option list**, so it is a proposal, not a reading of the record — although
   two of the thirteen (Magento, Akeneo) already keep definitions for column-stored facts.

---

## 4 · The sub-question — is brand an attribute, or an entity with its own table?

### 4.1 What we actually have is not brand

`manufacturer` is the only candidate, and the data says it is the **legal manufacturer**, not the consumer
brand (`sql/manufacturer-as-brand.sql`, 2026-09-19):

| Measure | Value |
|---|---|
| rows with any ASCII letter / distinct such values | 30,983 / 5,510 |
| distinct values beginning `PT.` or `PT ` | **2,867 of 5,510 (52.0%)** |
| rows beginning `PT.` or `PT ` | **21,577 of 30,983 (69.6%)** |
| rows whose `title` **starts with** the value | **1,002 (3.2%)** |
| rows whose `title` **contains** the value | 1,923 (6.2%) |
| values used on exactly one product | 2,736 (49.7% of distinct) |
| values used on ≥100 products | 32 |
| values spanning ≥2 main categories / ≥10 / max | 1,542 / 116 / **82** |
| junk rows (no ASCII letter) on public products | 15,516; `'0'` alone on **12,512** |

So: two thirds of the populated rows are `PT …` company names, only 3% match the brand token in the title,
and half the distinct values are used once. **A brand entity built by promoting these values would be 5,510
rows of which ~2,700 are singletons and ~2,867 are companies rather than brands.**

### 4.2 The three designs

**(a) Brand as a column on the sellable row** (`Product.brand = CharField`). Cheapest; matches Shopify
(`Product.vendor: String!`, *"The name of the product's vendor."*, free text, no enum, no validations —
#11011 §1.6) and Google (`brand`, one of 145 flat properties, `Max 70 chars` — #11013 Companion A row 26).
Problems for us: free text on 106,161 rows reproduces exactly the junk profile `manufacturer` already has
(no normalisation exists anywhere — `ProductAttributeValue.value_text` has no `clean()`, no validators, no
case-insensitive uniqueness, `models.py:742`), and a brand filter would face 5,510 spellings.

**(b) Brand as an ordinary attribute.** Zero new tables; inherits the editor, the API shape and the spec
sheet for free. Problems: it inherits the *whole* attribute system's weaknesses — free text, no shared value
row, no ordering, and (under Lock 1) it must be declared on every category that wants it, which A3 owns.
Precedent is the majority: Amazon (`brand` is a `product_identity` property in the product-type schema —
#10976), Akeneo (`camera_brand`, a select attribute whose values are `AttributeOption` rows — #11069 §2c),
commercetools (`brand` appears only as a vendor-authored attribute name — #11081 §3), eBay (`brand` is a
built-in `Product` field *and* an aspect name — #11045 §2b).

**(c) Brand as an entity with its own table** (`Brand(id, name, slug, …)`, `Product.brand_id` FK). Problems
and benefits, on our numbers: it is the only design where "SOKLIN" is one row rather than 82 category-scoped
spellings; it is the only design that can carry a logo, a supplier link or a brand page; and it is the only
one that makes a brand filter a join rather than a string match. It costs a curation project — 5,510 raw
values to 32 values-with-≥100-products plus a long tail — and a second staff editor.

⚠️ **Precedent, corrected 2026-09-19.** An earlier draft of this file said no platform in the thirteen
models brand as a first-class resource. That is **false**. Four do, in two kinds:
- **Platform-owned registries — Shopee and Tokopedia Era B.** Shopee's is a full surface:
  `get_brand_list(category_id, offset, page_size≤100, status, language)` →
  `brand_list[{original_brand_name, brand_id, display_brand_name}]` + `is_mandatory` + `input_type`, and
  `register_brand(original_brand_name, category_list≤50, product_image.image_id_list, app_logo_image_id,
  brand_website, brand_description, brand_region, licenses, brand_registration_website)`
  (`corpus/shopee/get_brand_list.txt`, `register_brand.txt`). Published instance
  `{"brand_id": 2500139861, "original_brand_name": "nike", "display_brand_name": "nike"}`.
- **Merchant-owned entities — WooCommerce and Akeneo.** WooCommerce:
  `register_taxonomy( 'product_brand', array( 'product' ), … 'hierarchical' => true, 'label' => 'Brands',
  'show_in_rest' => true )`, `@since 9.4.0` (`corpus/woocommerce/class-wc-brands.php:275-331`), shipped
  disabled on 2024-11-11 and enabled for everyone in 9.6 (2025-01-20). Akeneo: brand is the vendor's own
  **first example** of a Reference Entity (EE) — *"A reference entity can be for example the brands, the
  ranges, the manufacturers…"* — with the published instance
  `{ "code": "brand", "labels": {"en_US": "Brand", "fr_FR": "Marque"}, "image": "0/2/d/6/54d81…_ref_img.png" }`.

**The trigger is stated by three vendors, in three different words, and it is the same trigger:**
Akeneo — *"This data… has its own attributes (e.g. a label, a logo, a description or photos). Those
information may have dedicated pages on one's e-commerce website (e.g. a webpage describing a brand)"*;
WooCommerce — *"Each brand can have its own name, description, image, and archive page."*; commercetools —
*"If the same information is used in a large number of Products or Product Variants, it is more efficient
to design it as a Custom Object and reference it using an Attribute."*

*Judgement (medium-high confidence, after the external pass):* brand is **an attribute whose values are
rows** for us **now**, and becomes design (c) the day brand needs a page, a logo or navigation of its own.
Three facts sharpen the timing:
1. **Akeneo ships both ends of the path** — brand as a `pim_catalog_simpleselect` attribute in its demo
   catalogue *and* as the canonical reference entity in EE. The vendor does not treat them as rivals.
2. **Magento, which has no brand page, never promoted it**: brand is still the `manufacturer` attribute
   (`'input' => 'select'`, `'user_defined' => true`, `'filterable' => true`, `CategorySetup.php:537-551`).
3. **Promotion is nearly free for them and not for us.** WooCommerce's attribute values are already
   `wp_terms` rows and Akeneo's are already `AttributeOption` rows; **ours are not rows at all** until A4
   says so, so building `Brand` first would make our first shared-value table a one-off, for the attribute
   whose data is worst.
**And `manufacturer` is not brand**: whatever A1 decides, the 46,499 `manufacturer` values cannot be
renamed into a brand field — 69.6% of them are `PT …` companies and only 3.2% match the title's brand
token.

---

## 5 · Is a definition a separate thing from a value? — our own answer, and where it is broken

We already have both objects: `ProductAttribute` (the definition) and `ProductAttributeValue` (the value),
joined to `Product` twice — once through the through-model and once through the M2M
(`models.py:419-423` and `models.py:719-747`). Four defects in that split, all live at the pin:

1. **The definition's `name` is ~~dead~~ served to no API client, and read only by Django admin.** All
   five definitions have `name != code` (`Berat (gram)`, `Panjang (cm)`, …) and **no API exposes `name`** —
   `ProductAttributeSerializer` is `["code"]` and `ProductAttributeFullSerializer` is
   `["code","type","required"]` (`serializers.py:164-176`), so the label the *staff app* and the *customer
   page* show comes from the frontend i18n bundle. But `name` is **not** unread: it renders on four live
   Django-admin paths, none of which the first two drafts cited —
   (i) `ProductAttributeValue.summary()` → `"%s: %s" % (self.attribute.name, self.value_as_text)`
   (`models.py:763-766`); (ii) `Product.attribute_summary`, which joins those summaries
   (`models.py:520-525`) and is registered in `ProductAdmin.list_display` (`admin.py:43`), so it renders on
   **every row of the admin product list**; (iii) `ProductAttributeAdmin.list_display = ("name", "code",
   "product_class", "type")` (`admin.py:52`); (iv) `ProductAttributeValue.__str__` returns `summary()`
   (`models.py:760-761`), so `name` renders on every `ProductAttributeValueAdmin` row and in every
   `AttributeInline` row (`admin.py:18-19`, attached to `ProductAdmin` at `:46`).
   **Two consequences, and both cut in favour of option 4.** The staff-facing label of record already
   exists and is already `ProductAttribute.name` — it is simply served by Django admin rather than by the
   staff app, so option 4's *"the definition carries `name` and `unit`; the bundle becomes an override"* is
   a **smaller** change than an earlier draft implied. And because admin already surfaces `name` on four
   paths, the `UNIQUE`-on-code and immutability repairs matter **more**, not less: a code rename in admin
   (`prepopulated_fields = {"code": ("name",)}`, `admin.py:53`) silently breaks the i18n lookup and every
   `attr.<code>` reader while the admin label keeps looking right.
   ⚠️ **The unit is still modelled nowhere typed** — it is inside the free-text `name` string *and* in
   `attribute.key.<code>.unit` in the frontend bundle. That half of the defect stands. **The unit is
   modelled twice and typed nowhere** — inside the DB `name` string, and again as
   `attribute.key.<code>.unit` in `ts/assets/i18n/product/{en,id}.json`.
2. **`code` has no unique constraint.** `ProductAttribute.Meta` carries only `app_label` and `ordering`
   (`models.py:613-616`). Two definitions may share a code;
   `ProductAttributesContainer.initiate_attributes()` `setattr`s by `code`
   (`product_attributes.py:21-25`), so the last one read wins, silently.
3. **`product_class` is nullable** (`models.py:617-623`), so a definition can be detached from every class
   while its values keep existing and keep rendering — `validate_attributes()` reads
   `product_class.attributes.all()` (`product_attributes.py:57-58`) but the serializer reads
   `product.attribute_values.all()` (`serializers.py:200,207`). Detaching a definition hides it from
   validation and from the staff form while leaving it on the customer page.
4. **`required` is a write-path rule only.** All five definitions are `required=True`, yet 59,662 products
   have no `manufacturer` row (`sql/results/attribute-uses-and-visibility.csv`). Nothing reconciles the
   backlog.

*Judgement:* the definition/value split is right and is what every platform does; ours is under-specified
rather than wrongly shaped. A1's answer should say the split stands **and** name these four as the repairs
that come with the schema editor (lock condition 1).

---

## 6 · Fit-check summary — what each option would force

| | Option 1 (code-read → column) | Option 2 (everything an attribute) | Option 3 (capped custom fields) | **Option 4 (one registry, two storages)** |
|---|---|---|---|---|
| New tables | 0 | 0, but `ProductAttributeValue` is rebuilt with locale/scope selectors — **and it is a declared `through=` model (`models.py:419-422`), so the `Product.attributes` M2M declaration is rebuilt with it** | 0 | 0, **but the `storage` discriminator sits on the definition side of that same M2M** |
| Columns added | 4 (condition 2) | 0 | 4 (condition 2) | 4 (condition 2) + 5 on `ProductAttribute` |
| Backend read sites changed | **8** (3 methods, 2 files) | ~20 for `title` alone, plus every other core field | **8** | **8** + one serializer resolver + one write branch |
| Frontend changed | 4 generated fields disappear; the **staff-form** ordering array loses 4 of its 5 entries (`product-attribute-ordering.service.ts:9-15`) | title/description leave their hand-written Formly fields; spec sheet must exclude core fields | same as 1 | one frontend array **+ one backend `sorted()`** + the i18n key-set replaced by data |
| What it leaves unruled | homes 2 and 4; promotion churn | nothing, at the price of rebuilding the value table | the same as 1, plus a cap that binds nothing today and contradicts Lock 1 tomorrow | registry-vs-column drift (one test) |
| Our code today | **already implements it** | contradicts it in 20 places | already implements it plus an unenforced cap | **option 1 plus one column** |
