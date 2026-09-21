# design-A4 — the value, its list, its unit and its order, sketched against our real models

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6` · frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.
Everything here is **design work, labelled as judgement**; the measured facts are in `ATTR-VALUE.md` §4–§5, `sql/` and `corpus-analysis/`.

---

## 0 · What a value is today, exactly

```
ProductAttributeValue                                     models.py:719-776
  attribute FK, product FK, unique_together(attribute,product)   :730-740
  value_text TEXT | value_integer | value_boolean | value_float
  | value_date | value_datetime                                   :742-747
  def _get_value(self):  return getattr(self, "value_%s" % self.attribute.type)   :749-751
  def _set_value(self, v): setattr(self, "value_%s" % self.attribute.type, v)     :753-756
  value = property(_get_value, _set_value)                                        :758
  value_as_text -> getattr(self, "_%s_as_text" % type, self.value)                :768-776
```

Three properties of that design decide most of this card:

1. **It dispatches on `attribute.type` — in three places, and only two of them tolerate a new member.** `value_<type>` is computed from a string, so `_get_value`/`_set_value` (`models.py:749-756`) need no edit, and `value_as_text` (`:775-776`) has a default. But `ProductAttribute.validate_value` (`models.py:684-686`) is `getattr(self, "_validate_%s" % self.type)` **with no default**, so a seventh `TYPE_CHOICES` entry without a matching `_validate_option` raises `AttributeError` inside `Product.clean()` on the one production write path. `ProductAttributeType` is also a closed `Literal` (`catalogue/types.py:3-5`) and `ProductAttribute.clean()` (`models.py:660-662`) branches on `self.type`. ~~a *two-line* change~~ (red-team round 1, finding 4). The model's read path was built for a hybrid; its write path needs one method.
2. **There is no option table.** #10778 §"Red team" records this verbatim: *"`AttributeOption` / `AttributeOptionGroup` are absent from the models and from every migration, so absent from the DB schema. Upstream Oscar ships them; our fork (pinned to django-oscar 3.0.2) never had them."* (`10778.md:286`, repeated at `:341`). Re-verified at the pin: `grep -rn "AttributeOption" py/mono` → no hits outside that record.
3. **The wire is already all strings, in both directions.** Read: `value = serializers.CharField(source="value_as_text")` (`api/apiproduct/serializers.py:189-191`). Write: `value = serializers.CharField(allow_null=True, allow_blank=True)` (`api/apiproduct/staff_serializers.py:38`), set with `setattr(product.attr, code, value)` (`:81`). Frontend model: `ProductAttributeValueBase { attribute: {code}; value: string }` (`libs/product/shared/util-core/src/lib/product-attribute.model.ts:19-22`).
   *Side effect worth knowing:* for a `float` attribute the string reaches `value_float` and Django coerces it at save, but `_save_value`'s `if value != value_obj.value` (`models.py:664-670`) compares the incoming `"69"` against the loaded `69.0`, which is never equal. So on **every staff product update** (`staff_serializers.py:81` sets the string, `product_attributes.py:60-64` then hands it to `save_value`) every float attribute value row is rewritten even when unchanged. A save that does *not* go through the staff serializer compares float to float and correctly writes nothing. A typed value on the wire would end the asymmetry.

And the **unit already exists — in the frontend translation bundle**:

```jsonc
// ts/assets/i18n/product/id.json  (en.json identical shape)
"attribute": { "key": {
   "height":       { "name": "Tinggi",     "unit": "cm" },
   "weight":       { "name": "Berat",      "unit": "g"  },
   "length":       { "name": "Panjang",    "unit": "cm" },
   "width":        { "name": "Lebar",      "unit": "cm" },
   "manufacturer": { "name": "Manufaktur", "unit": "-"  },
   "internalname": { "name": "Nama Internal", "unit": "-" }   // no such attribute in the DB
}}
```

read by `ProductAttributeI18nService.productAttributePartialTranslate$` (`libs/product/addendum/util-i18n/src/lib/product-attribute-i18n.service.ts:20-35`, `'-'` → `''`) and rendered as `` `${value} ${unit}` `` (`:46-51`), and used again for the staff form label `` `${name} (${unit})` `` (`product-update-staff-form-ui.component.ts:160-165`).

**So option (b) of the quantity question — "a number under a unit fixed on the definition" — is what we ship today.** The only defect is that the definition lives in a JSON asset in another repository's build, not in a column. Nothing in D9 needs inventing; it needs moving.

---

## 1 · Value shape

### (a) free string — the status quo

`value_text`, no trim, no case-fold, no validator (`models.py:742`; `_validate_text` only asserts `isinstance(value, str)`, `models.py:690-692`).

Measured consequence on the one real vocabulary we have (`sql/manufacturer-*.sql`, snapshot 2026-09-19):

- 46,499 rows, 5,580 distinct raw, **0** with leading/trailing whitespace.
- Case-folding collapses 39 spellings into 38 keys — the whole of the "0.7% drift".
- Stripping punctuation as well collapses to **4,421** — 1,159 more.
- The head of that residue: **16 spellings of `PT UNILEVER INDONESIA TBK`** over 1,108 rows; 10 of `PT MANDOM INDONESIA TBK`; 8 of `PT KINO INDONESIA TBK`; 7 of `PT PROCTER & GAMBLE OPERATIONS INDONESIA` (`sql/results/manufacturer-duplication-classes.csv`).

**Judgement:** normalisation-on-write (#10778 V6) fixes the 38 case groups and none of the 16 Unilevers. The duplication that actually exists is punctuation and abbreviation, and no write-time transform catches it without becoming a fuzzy matcher. A shared row plus a merge tool does.

### (b) shared option row

```sql
ProductAttributeOption
  id, attribute_id FK NOT NULL, code slug,
  label_en varchar, label_id varchar,        -- the Category pattern, models.py:110-121
  display_order smallint NULL,
  amount double NULL, unit varchar NULL,     -- see §3
  UNIQUE (attribute_id, code)

ProductAttributeValue
  + value_option_id FK ProductAttributeOption NULL   -- the 7th typed column
ProductAttribute.TYPE_CHOICES += ("option", _("Option"))
ProductAttribute._validate_option(value)    -- REQUIRED: validate_value (models.py:684-686) has no default
catalogue/types.py:3-5  ProductAttributeType Literal += "option"
```

`_get_value`/`_set_value` need no edit at all — `value_option` is found by the existing `"value_%s" % type` lookup. **`validate_value` does need one**: `getattr(self, "_validate_%s" % self.type)` (`models.py:684-686`) has no default, so `_validate_option` must exist before the first option-typed attribute reaches `Product.clean()`. A `_option_as_text` property (the hook `value_as_text` already looks for, `models.py:775-776`) renders the localised label, so **the read API and both frontend renderers keep working unchanged**.

The write path does change: `ProductAttributeValueStaffSerializer.value` is a `CharField` (`staff_serializers.py:38`). Two choices, and they are not equivalent:
- resolve **label → option** server-side: no API change, but a rename silently re-points or fails;
- send the **option id**: honest, and forces `ProductAttributeValue.value: string` (`product-attribute.model.ts:21`) to become a union, plus a new formly field type in `PRODUCT_ATTRIBUTE_TYPE_TO_FORM_FIELD` (`product-attribute.model.ts:3-8`, which today maps only `float→number` and `text→input`).

**Judgement: send the id.** The whole point of a row is a stable identity; resolving by label re-introduces the string as the key.

### (c) hybrid by type — `option` → row, `text` → string

This is (b) *without removing anything*. `manufacturer` can stay `text` on day one and become `option` later by a data migration that mints one option per distinct value. Nothing else in the code branches on the choice, because everything already goes through `attribute.type`.

**Judgement: (c) is not a compromise here, it is the shape the existing model was written for.** ~~The matrix's own option line agrees on the consequence~~ — **corrected (red-team round 1, finding 6; residue fixed in round 2):** that sentence is the **card's**, at `evidence/pages/catalogue-next-steps-v7.txt:269`, so it restates the question rather than corroborating the answer. The matrix's actual D8 options line says *"Ordering, rename and **normalisation** come **free** only with (a) or (c)"* (`catalogue-decision-matrix-2026-09-16.txt:2153`) and never mentions the variant key.

---

## 2 · Where the allowed list lives

### (A) on the attribute — one list everywhere

`ProductAttributeOption.attribute_id`. One `Rasa`, one list, one filter, one curation surface.

This is what the industry's largest published shared registry does, measured: a `TaxonomyValue` belongs to **exactly one** attribute — 0 of 74,820 value ids appear under two attributes — and the category→attribute edge carries no value list at all (`corpus-analysis/shopify_attr_reuse.out` §5). It is also what Akeneo (`AttributeOption.attribute` manyToOne, exactly 1) and Magento (one `flavor` row, options merged into one list — the vendor-emitted `customAttributeMetadata` response returns the **union** of two fixtures' size lists, #11082 §3.2) do.

Problem it causes: **one list has to hold every category's values.** Our own case: Shopify's global `Flavor` list has 30 values (Almond … Vanilla, Other) and **zero** of them appear in the 43 Indomie titles (Soto, Ayam Bawang, Kari Ayam, Empal Gentong, Seblak Hot Jeletot…) — measured, token-level intersection = 0 (`corpus-analysis/indomie_vs_shopify_flavor.out`). A single `Rasa` list for us would therefore hold both savoury noodle names and sweet biscuit names. Shopify's own answer to that is a second attribute (`pet_food_flavor`, `baby_food_flavor`), not a per-category subset.

### (B) on the category — per-category list

The fourth table from `design-A3.md` §3. Same objections; see there.

### (C) on the family — Shopify's product-level option values

Under Lock 2 every product has a group row, including families of one. A family-scoped value list means one option row set per family. At 106,161 products, most of them families of one, the option table is **larger than the value table** and no two families share a value, so there is no filter, no rename and no ordering to inherit. There is exactly one thing it buys: a family can offer a value nobody else uses without touching a global list.

**Judgement: reject (C) as the home of the *list*.** It is right as the home of a *selection* — "which of the attribute's options this family's members use" — which is D5's question (the family picks from the eligible set; eleven of thirteen platforms), not A4's.

### A4 ↔ A5 (FAMILY owns the level; I own the shape)

Whatever level a value sits at, **the shape must be identical on both levels or we buy two editors, two serializers and two filter paths.** Concretely, if A5 puts non-axis values on the family row, the family's value table gets the same six-plus-one typed columns and the same `attribute_id` FK, and the option list stays on the attribute. The matrix already names the schema fork this creates: *"`ProductAttributeValue` has one product column. Either a nullable family column beside it with a check that exactly one is set, or a second table"* (`catalogue-decision-matrix-2026-09-16.txt:246`). Either is compatible with an option row; neither is compatible with a family-scoped option list, because a member-level value and a family-level value would then point into different vocabularies.

---

## 3 · Quantities

### (i) text

What titles do today: 23,986 products (22.6%) carry a mass or volume token in the title (`sql/quantity-vocabulary.sql`). 886 distinct labels; 214 cover 90% of them; 275 used once; 5 unit spellings (`GR`, `GRAM`, `KG`, `ML`, `LTR`) for 2 dimensions.

### (ii) a number under a unit fixed on the definition — **what we already ship**

`value_float` + a unit on the definition. Move the unit from `ts/assets/i18n/product/*.json` to a `unit` column on `ProductAttribute` and the shape is complete and in one place.

Where it fails: when one attribute carries values in more than one unit. That is exactly our case — `SOKLIN SOFTERGENT SAKURA STRAWBERRY` holds `215 GR · 720 GR · 1.44 KG · 2.7 KG` (verified in production, `sql/results/size-families.csv`). A single fixed unit forces the entry to be `1440` grams while the label must print `1.44 KG`.

### (iii) a number **plus a unit on the value** — Akeneo's metric

`value_amount double` + `value_unit varchar` (or the two columns on the option row, §1(b)). Handles mixed units directly.

### (iv) the shape I actually recommend — **label is the record, magnitude is derived**

```
ProductAttributeOption
  label_en / label_id     "1.44 KG"          <- staff type this; it is the truth
  amount double NULL      1440.0             <- derived on write
  unit_canonical char(3)  'g'                <- derived on write
  display_order NULL                         <- only for lists with no magnitude
```

- **Correct 100% of the time on our data:** all 886 labels parse; `magnitude_not_parseable = 0` (`sql/quantity-vocabulary.sql`).
- **Zero curation.** Every new label sorts itself.
- **It is the pattern #10778 V4 itself cites**, read the other way round: *"Open Food Facts' typed `product_quantity` is 'computed from the `quantity` field' — the verbatim label is the record, the typed pair a derived index"* (`10778.md:128`). V4 quotes that to argue the label suffices for a picker; the same sentence says the derived index exists and is computed, not typed.
- It leaves V4's substance intact — the axis value **is** a single text label — while removing V5's hand-set position column from the critical path.

Residual, stated: **78 of 1,993 size families mix mass and volume** (`sql/results/size-families.csv`). A single linear order over a mixed list is arbitrary in any design — with a derived magnitude it is arbitrary-but-stable (`g` and `ml` interleave by number), with a hand-set position it is whatever staff typed. Neither is right; the number of affected families is 78.

---

## 4 · Who orders the picker, under each shape

| shape | what orders the list | curation bill, measured |
|---|---|---|
| free string | nothing — there is no list; order is query order | n/a |
| option row + `display_order` | staff, per value | **886** labels catalogue-wide, **399** inside real size families; every new label needs a position, and inserting `250 GR` between `245 GR` and `281 GR` means renumbering or sparse positions |
| option row + derived magnitude | the data | **0** |
| the published Shopify taxonomy | the **locale's label**, alphabetically, with `Other` pinned last | measured in **both locales**, since the claim is about locale-dependence (R1-26 residue, fixed in round 2): alphabetical once `Other`/`Lainnya` is removed in **7,715 of 8,240** in `en` and **7,544 of 8,240** in `id-ID`; `Other`/`Lainnya` is last in **8,237 of 8,237** attributes that contain it; and the value array order differs between `en` and `id-ID` for **6,968 of 8,240** attributes, while the value **ids are identical** (74,820 in both). `corpus-analysis/shopify_order_and_names.out` |

The last row matters for the #10778 V4 ↔ matrix-D9 conflict and is treated in `ATTR-VALUE.md` §7, which supersedes this paragraph's first draft. Precisely: Shopify's **shared taxonomy** value list is generated from the localized label (only 7 of 8,240 attributes carry `sorting: custom`), while its **per-product** option values are hand-ordered by array order through `productOptionsReorder` — `ProductOptionValue` has no `position` field, but as #11031 puts it, *"Field absence is not model absence."* The two are different objects at different levels, and #11031's re-expression moves the ordering column to the **shared** one.

Without a magnitude, text order is wrong for **782 of 1,993** de-facto size families (39.2%), covering the matrix's own quoted example. With one, it is right for all 1,993.

---

## 5 · The variant key as a database constraint

Lock condition 4 asks for "a dimension-count mirror on the member via composite FK"; D7's default is *"(a) both at write, in the DB"*; the matrix says the canonical variant key *"cannot be defined before D8 says what a value is"* (`catalogue-decision-matrix-2026-09-16.txt:262`).

- **With free strings:** the key is a tuple of `value_text`. A unique index is possible (`UNIQUE(group_id, value_text_1, value_text_2, value_text_3)` or a normalised projection) but it is only as stable as the text. `Ayam bawang` and `Ayam Bawang` are two different members of the same family, and the DB cannot tell.
- **With option rows:** the key is a tuple of integer FKs. `UNIQUE (group_id, option_a_id, option_b_id, option_c_id)` is an ordinary composite unique index, and a rename of the label cannot break it. The composite-FK mirror becomes checkable rather than advisory.

**Judgement: D7's "enforced in the DB" is reachable only under value shape (b) or (c).** That is the sharpest downstream consequence of this card, and it is a constraint-level fact, not a preference.

---

## 6 · Migration shape, per option

| | work | reversible? |
|---|---|---|
| string + normalisation (V6) | one `save()` hook + a backfill `UPDATE` over 46,499 rows | the original spellings are gone; not reversible |
| add `option` type (c), leave `manufacturer` as `text` | one column, one `TYPE_CHOICES` entry, **one `_validate_option` method**, **one `types.py` `Literal` member**, one new table, one API field, one formly type, plus `_option_as_text` so `attribute_summary` and the two admin surfaces keep rendering | fully reversible — nothing existing changes |
| convert `manufacturer` to `option` | mint ~4,421–5,541 options from distinct values, repoint 46,499 rows, then merge by hand | reversible while `value_text` is kept alongside |

**Judgement:** the second row is the one to ship first. It is additive, it unblocks the axis work (D4–D7), and it does not require anyone to decide what `manufacturer`'s vocabulary should be. The third row can then be done attribute by attribute, with the 16 Unilevers merged by a human once.

### What step 2 forces that this sketch first missed (red-team round 1, findings 11–14)

| Surface | Why it is in this bill |
|---|---|
| `product_attributes.py:21-25` `initiate_attributes()`, called first in `_assign_attributes()` (`staff_serializers.py:68`) | it seeds the container from stored rows via `get_values()` (`:54-55`) and `setattr(self, v.attribute.code, v.value)` — every value goes through `_get_value`. Under (b)/(c) this is where a label and an option id must stop being the same thing. |
| `models.py:520-525` `Product.attribute_summary` → `ProductAttributeValue.summary()` (`:763-766`) → `value_as_text` | in `ProductAdmin.list_display` (`admin.py:43`), asserted at `catalogue/tests/product_models_test.py:125`. Inherits free **only** once `_option_as_text` exists. |
| `admin.py:18-19` `AttributeInline` on `ProductAdmin` (`:46`) · `admin.py:56-57,68` `ProductAttributeValueAdmin` | the two value editors. Under an option row each needs a select widget and a queryset filtered by attribute; `ProductAttributeValueAdmin.list_display` renders `value` through `_get_value`. |
| `admin.py:27-29` `ProductAttributeInline` on `ProductClassAdmin` (`:32-34`) | the schema editor that already exists; it must offer the new `option` type and a way to reach the option list. |
| `models.py:489` vs `:490`, `receivers.py:31-41`, `index_utils.py:11-16` | **the ordering hazard.** `super().save()` at `:489` enqueues the Haystack *and* Google Merchant documents; the attribute values are written at `:490`. There is no `post_save` on `ProductAttributeValue` at all. The first time a value reaches a facet or a feed field, every document is one write stale and admin-inline edits never reindex. Fix by adding a `ProductAttributeValue` signal, or by moving `self.attr.save()` above `super().save()` — which it cannot be, because the values need the product's pk (`staff_serializers.py:122-123` says so). **So the signal is the fix, and it belongs in step 2, not step 3.** |

The one production create path is `ProductCreateSerializer.create()` inside `transaction.atomic()` (`staff_serializers.py:98-128`), and `_assign_attributes` runs inside it (`:124`) — so an option lookup joins an already-atomic block.
