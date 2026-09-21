# design-A5 — where an attribute's level lives, sketched against our real models

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`; frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.
Every line number below was re-taken at those pins. ⚠️ They differ from the 2026-09-15 field-survey
page, which cites `upc :390 · title :398 · description :418 · main_category :434`; at this pin they are
`:385 · :392 · :410 · :427`. Cite this file's numbers, not the page's.

## 0 · The surface that has to change, whichever option wins

```
ProductAttribute          catalogue/models.py:608      code, name, type, required, product_class(FK :618)
ProductAttributeValue     catalogue/models.py:719      attribute(FK :732) · product(FK :736, NOT NULL)
                          Meta.unique_together = ("attribute", "product")            :730
ProductAttributesContainer catalogue/product_attributes.py
  get_values()            :54-55   self.product.attribute_values.all()
  get_all_attributes()    :57-58   self.product.get_product_class().attributes.all()
  validate_attributes()   :36-52   raises if a REQUIRED attribute has no value on THIS product
  save()                  :60-64   attribute.save_value(self.product, value)
ProductAttribute.save_value  catalogue/models.py:672-681   signature is (product, value)
Product.clean()           catalogue/models.py:468-484     calls self.attr.validate_attributes() at :484
Product.save()            catalogue/models.py:486-497     calls self.attr.save() at :490
```

Readers of values, complete at the pin (`grep -rn "\.attr\.|attribute_values|attribute_summary"`, tests excluded):

| Reader | path:line | Reads |
|---|---|---|
| basket weight/dimensions | `basket/models.py:1265,1272-1274` | `product.attr.weight/length/width/height` |
| biteship shipping quote | `third_party_api/biteship/biteship.py:60-62,90` | same four |
| staff create/update | `api/apiproduct/staff_serializers.py:63,66-81,99,124,133-138` | `attribute_values` round-trip |
| customer detail payload | `api/apiproduct/serializers.py:200,207,219-221` | `attribute_values`, sorted by code |
| detail queryset prefetch | `api/apiproduct/views.py:60` | `attribute_values` |
| django admin column | `catalogue/admin.py:43` → `models.py:521-525` | `attribute_summary` |
| frontend spec table | `ts/libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.html:6-20` + `.ts:34,42-56` | flat `productAddendum.attribute_values`, hides `internalname` |
| frontend staff form | `ts/libs/product/action/ui-staff-form/.../product-update-staff-form-ui.component.ts:186,215,235` | reads and re-posts `attribute_values` |
| TS model | `ts/libs/product/shared/util-core/src/lib/product.model.ts:49,73` | `attribute_values: readonly ProductAttributeValue[]` |

**Not readers of an attribute *value* — but not "free" either:**
- Search **indexes no attribute value**: `py/mono/templates/search/indexes/catalogue/product_text.txt` is
  three lines (the product-lite partial, the category-lite partial, `object.description`) and
  `solvent/search/search_indexes.py:24-75` declares no attribute field. ⚠️ **But the reindex *trigger* is not
  free** (red-team finding 2): `solvent/catalogue/receivers.py:31-41` fires on `post_save` of **`Product`**
  only, and `solvent/catalogue/index_utils.py:19-44` fans out from a `product_id` to every
  `HasProductDependentSearchIndexModelMixin` subclass (`solvent/catalogue/models_mixins.py:6-31`; subclasses
  at the pin: `inventory/models.py:19`, `inventory/models.py:121`, `price/purchase/models.py:36`). Under
  A5-a a **family-level value edit fires no receiver at all**. That does not corrupt the search document
  today — no attribute value is indexed — but it does mean a family-level value is invisible to any future
  index field, and it is the same missing trigger C1 needs for `description` (see `design-C1.md` §5b). One
  receiver serves both.
- The Google feed. `third_party_api/google/content/products_api.py:214-224` builds `ProductAttributes` from
  exactly eight values — `availability, condition, description, link, title, price`, plus `sale_price` at
  `:230-232` and `image_link` at `:234-235` — and reads no attribute value at all.
- Order lines, price, inventory, purchasing, receiving, transport, returns, labels, forecast: none reads
  `attr` or `attribute_values`.

**Post-condition-2 this shrinks to almost nothing.** Lock condition 2 moves `weight`, `length`, `width`,
`height` to `NOT NULL` columns, which removes the basket and biteship readers and 424,644 of the 471,143
`ProductAttributeValue` rows. What remains is `manufacturer`: **1 definition, 46,499 rows**
(`sql/results/baseline.json`, 2026-09-19). So A5 is, on today's corpus, a decision about one attribute —
and it is exactly the attribute most likely to be family-level.

---

## Option A5-a · the level is pinned on the definition

> ⚠️ `VariantGroup` / `catalogue_variantgroup` is a **placeholder name**. Table naming is L2.3 and is
> open (step 5 of the page: *"keep `Product` as the sellable row and name the container"*). Nothing in these
> sketches depends on the name.


Precedent shape: `AttributeDefinition.level ∈ {Product, Variant}` (commercetools), `aspectApplicableTo ∈
{PRODUCT, ITEM}` (eBay), `allowed_object_types` (Square), `MetafieldDefinition.ownerType` (Shopify).

### Schema

```sql
ALTER TABLE catalogue_productattribute ADD COLUMN level varchar(8) NOT NULL DEFAULT 'member';
-- level ∈ {'family','member'}; after Lock 1 this row is (category, code, type, required, level)
ALTER TABLE catalogue_productattributevalue ALTER COLUMN product_id DROP NOT NULL;
ALTER TABLE catalogue_productattributevalue ADD COLUMN variant_group_id bigint NULL
      REFERENCES catalogue_variantgroup(id) ON DELETE CASCADE;
-- NOT VALID first: a plain ADD CONSTRAINT ... CHECK takes ACCESS EXCLUSIVE and validates all
-- 471,143 rows under the lock. Small at this row count, but there is no reason to pay it.
ALTER TABLE catalogue_productattributevalue ADD CONSTRAINT pav_exactly_one_owner
      CHECK (num_nonnulls(product_id, variant_group_id) = 1) NOT VALID;
ALTER TABLE catalogue_productattributevalue VALIDATE CONSTRAINT pav_exactly_one_owner;
-- unique_together("attribute","product") becomes two partial uniques
CREATE UNIQUE INDEX pav_uniq_member ON catalogue_productattributevalue (attribute_id, product_id)
       WHERE product_id IS NOT NULL;
CREATE UNIQUE INDEX pav_uniq_family ON catalogue_productattributevalue (attribute_id, variant_group_id)
       WHERE variant_group_id IS NOT NULL;
```

This is option 1 of the field survey's "four things worth deciding deliberately" (#2: *"add a nullable
`variant_group` beside it with a check that exactly one is set, or give the family its own value table"*).

### What breaks, concretely

1. **`validate_attributes()` fails every member the moment the *first definition is moved*.** It loops
   `get_all_attributes()` — every attribute of the class/category — and raises
   `"%(attr)s attribute cannot be blank"` when a **required** one has no value **on this product**
   (`product_attributes.py:37-44`). `manufacturer` is `required=True` today
   (`baseline.json: manufacturer:text:req`). Move it to `level='family'` without touching the container and
   `Product.clean()` raises on all 106,161 rows. ⚠️ **Precise scope (red-team finding 37):** adding the
   `level` column alone breaks nothing — with the default `'member'`, `get_all_attributes()` still returns
   every attribute and every value is still on the member. The break is at the first move, not at the
   migration.
   The fix has **two** halves, and revision 1 compressed it to one: (a) skip family-level definitions in the
   member's loop; **and (b) validate them on the group instead** — and **there is no family model, nothing
   calls a family `clean()`, and no family write path exists**, so (b) is new work, not a condition. Size it
   as a small new validator plus its call site in whatever creates a family, not as one line.
2. **`save_value(product, value)` has a product-only signature** (`models.py:672`). A family writer is a
   second method, or the signature becomes `(owner, value)`. Small, but it is the one place the "exactly
   one owner" check can be violated in Python before the DB sees it.
3. **The staff form round-trips the merged list.** `product-update-staff-form-ui.component.ts:186` reduces
   `productAddendum.attribute_values` into form controls and `:235` posts them back as
   `attribute_values` on the **member's** update endpoint. If the read merges family values in and the write
   does not split them out, a staff edit silently writes a family value onto the member — and the new
   partial unique index will not stop it, because the member row is a legal row. **This is the one real
   frontend fork**, and it is a write-path correctness bug, not a display problem.
4. **The read path forks once, in one place.** `ProductDetailsSerializer.attribute_values`
   (`api/apiproduct/serializers.py:207`) must become a method field that unions the member's rows with the
   group's. `views.py:60`'s `prefetch_related("attribute_values")` gains a second prefetch. Everything
   downstream — including the whole frontend spec table — **inherits free**, because the card's own rule
   ("if an attribute is on the product, its variants do not store it") makes the union **disjoint**: there
   is never a precedence decision, so the merged list is just a longer list of the same shape.

### What `SameForAll` costs

commercetools enforces it as an error type, not a structure: `DuplicateAttributeValuesError.raml` —
*"The set of attributes must be unique across all variants."* — and the sibling `DuplicateAttributeValueError`
— *"Attribute can't have the same value in a different variant."* (#11081 §1.2). Under A5-a we never need
either, because *"the attribute is on the family"* **is** `SameForAll` by construction: one row, nothing to
compare. commercetools says the same thing structurally, in its one gate: *"If the Attribute is defined at
Product level, then `attributeConstraint` must be `None`."* (`AttributeDefinitionDraft.raml:36-41`, #11081 §1.2).

Under A5-b or A5-c, `SameForAll` is a cross-row validator: on every member write, read the other members'
value for that attribute and compare. There is exactly one production create path
(`api/apiproduct/staff_serializers.py:98-130`, inside `transaction.atomic()`), so it has a home — but
`Product.clean()` sees one row and would have to grow a group-wide read, and a family of 33 (Indomie) makes
that 33 rows read on every save of any member.

### What it costs to ship

**Nothing, on day one.** `level` defaults to `'member'`, `variant_group_id` stays NULL on all 471,143 rows,
and the tentative decision *"ProductAttributeValue: member — no migration of existing rows"* holds
unchanged. The column is inert until a definition is moved, and moving one is then a data migration of
that attribute's rows only (`manufacturer`: 46,499 rows, and only where the family has ≥2 members).

### The immutability question nobody has asked yet

commercetools makes the level **immutable after save**: *"The **Attribute level** option cannot be changed
after saving the Attribute."* (#11081 §2b, Merchant Center). It also makes `attributeConstraint` one-way:
*"For now only following changes are supported: `SameForAll` to `None` and `Unique` to `None`."*
(`ProductTypeChangeAttributeConstraintAction.raml`, #11081 §1.2). If we allow the level to be edited, the
editor has to move rows — member→family means picking one of N values, family→member means copying one
value onto N rows. That is a schema-evolution item; the page already parks schema evolution in step 5 as
*"a consideration with no core decision behind it"*, and this is a concrete instance of it.

---

## Option A5-b · either side, chosen per family

Precedent: Akeneo `FamilyVariant.variant_attribute_sets[].{level, axes, attributes}` (#11069 §2c, vendor
instance: `{"code":"clothing_color_size", "variant_attribute_sets":[{"level":1,"axes":["color"],
"attributes":["variation_name","variation_image","composition","color","material"]},{"level":2,
"axes":["size"],"attributes":["sku","weight","size","ean"]}]}`).

### Schema

```sql
CREATE TABLE catalogue_variantgroupattributelevel (
  id bigserial PRIMARY KEY,
  variant_group_id bigint NOT NULL REFERENCES catalogue_variantgroup(id) ON DELETE CASCADE,
  attribute_id     bigint NOT NULL REFERENCES catalogue_productattribute(id) ON DELETE CASCADE,
  level varchar(8) NOT NULL,                       -- 'family' | 'member'
  UNIQUE (variant_group_id, attribute_id)
);
```
plus the same nullable-owner change to `ProductAttributeValue` as A5-a.

### The problems it causes

1. **106,161 distributions on day one.** Lock 2 gives every product a group, including families of one. A
   per-family distribution is a row set per group. Either every group gets a full distribution (106,161 ×
   |attributes|) or there is a default — and the default *is* A5-a wearing a different name.
2. **Akeneo's own object is not the family.** The distribution lives on `FamilyVariant`, which is shared by
   many product models (#11069: *"You can create one or more family variants in each family."*), not on one
   product model. Our analogue of `FamilyVariant` is the **Category** after Lock 1, not the group. So the
   faithful port of Akeneo is `level` on the `(category, attribute)` row — which is A5-a with the level
   living on the row Lock 1 already creates. **A5-b as the card words it has no platform precedent at the
   family level.**
3. **No static answer to "where do I read `manufacturer`?"** Every read becomes two steps: look up this
   group's level for this attribute, then read the right table. `attribute_summary` (`models.py:521`), the
   detail serializer and the staff form all become level-aware.
4. **Merge and split have to re-home values.** Merging two families whose distributions disagree means
   choosing a distribution and then moving rows. Splitting a family whose `manufacturer` is at family level
   means copying one value onto every member of both halves. Under A5-a a merge never moves a value.

---

## Option A5-c · always on the variant; the family carries nothing

Precedent: Google (no family object — *"only `item_group_id` and `item_group_title`, repeated on every
row"*, #11031 field survey §A), Walmart (*"shared by repetition, not reference"*, #11046 §2b), Magento
(*"There is no inheritance mechanism in the schema"*, #11082 §2b).

### Schema

None. This is today.

### The problems it causes

1. **The drift is already measured, and it is ours.** Across 10,090 proxy families (≥2 products sharing a
   three-word title prefix inside one `main_category`), **1,908 (18.9%) disagree on `manufacturer`**
   (`sql/results/fam-c1-sibling-consistency.csv`, 2026-09-19). The 43 Indomie rows are the worked example:
   one manufacturer, seven spellings — `PT. INDOFOOD CBP SUKSES MAKMUR TBK`, `PT INDOFOOD CBP SUKSES MAKMUR
   TBK`, `PT. INDOFOOD CBP SUKSES MAKMUR`, `PT. INDOFOOD CBP SUKSES MAKMKUR TBK`, `PT. INDOFFOD CBP SUKSES
   MAKMUR TBK`, `PT. INDOFOOD CBP MAKMUR TBK.`, `PT. INDOFOOD CBP  SUKSES MAKMUR TBK`
   (`sql/results/indomie.csv`, all 43 rows).
2. **The three precedents replicate because they have no container.** Google, Walmart and Magento-as-a-type-
   model each lack the thing Lock 2 has already decided to build. Replicating *under* a container is the one
   combination none of the thirteen runs: you pay for the group row and keep the drift.
3. **It makes A5's own rule unstatable.** The card's rule — *"if an attribute is on the product, its
   variants do not store it"* — has no referent under A5-c, because nothing is ever on the product.

---

## What each option does to the tentative decision ("values stay on the member")

| Option | Day-one effect on the 471,143 existing rows | Effect on the tentative decision |
|---|---|---|
| **A5-a** | none — `level` defaults to `'member'`, `variant_group_id` NULL everywhere | **holds unchanged**; the column is inert until a definition moves |
| **A5-b** | none, but 106,161 distributions must be created or defaulted | holds only while the default says "member" |
| **A5-c** | none | is the decision; nothing further to take |

## Where A5 must cite, not decide

- **A0 owns visibility per channel** (ATTR-DEF). A5 adds a second axis to the same definition row —
  `level` beside whatever A0 lands — and the two are independent: a family-level attribute can be hidden and
  a member-level one shown. Nothing in A5 constrains A0's answer, and A0's per-channel visibility does not
  change where the value is stored.
- **A4 owns the value shape** (ATTR-VALUE). If a value becomes a shared option row (A4's option a), the
  family-level value is a second FK from the same row set and the `CHECK` above is unchanged. If it stays a
  string, likewise. **A5 is orthogonal to A4**: the level says which column carries the owner, not what the
  value is.
