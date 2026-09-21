# design-A3 — the attribute matrix, sketched against our real models

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6` · frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.
Every `path:line` below was opened at those pins. Everything in this file is **design work, labelled as judgement**; the measured facts it rests on are in `ATTR-VALUE.md` §4 and §5.

---

## 0 · What we have, exactly

```
ProductClass (1 production row)
   └─1..N─> ProductAttribute        py/mono/solvent/catalogue/models.py:608-716
              product_class FK (blank=True, null=True)          models.py:618-624
              name CharField(128)                               models.py:625
              code SlugField(128)   ← NO unique constraint      models.py:626-638
              type  text|integer|boolean|float|date|datetime    models.py:641-653
              required BooleanField(default=False)              models.py:655
              Meta: ordering=["code"]  — and nothing else       models.py:614-616

Product ──N──> ProductAttributeValue                            models.py:719-776
                 unique_together ("attribute","product")        models.py:730
                 value_text / value_integer / value_boolean /
                 value_float / value_date / value_datetime      models.py:742-747
                 value = property(_get_value,_set_value)        models.py:749-758
                    -> getattr(self, "value_%s" % attribute.type)

Product.main_category ──> Category  (MP_Node, PROTECT)          models.py:427-431
Category: name, _name_en, _name_id, code, full_code, is_public  models.py:109-157
```

Reader of the set — **one function, two lines**:

```python
def get_all_attributes(self):
    return self.product.get_product_class().attributes.all()   # product_attributes.py:57-58
```

used by `validate_attributes()` (`product_attributes.py:36-52`, called from `Product.clean()` `models.py:484`) and by `save()` (`product_attributes.py:60-64`, called from `Product.save()` `models.py:490`).

Two further hard-coded reads of the global set:

- `ProductAttributeViewSet.get_queryset()` → `ProductClass.default().attributes.all()` (`api/apiproduct/staff_views.py:66-67`), served at `api/product/staff/attribute/all/` (`staff_urls.py:16`) behind `@cache_page(86400)` (`staff_views.py:73`).
- `_assign_attributes()` → `product.product_class.attributes.all().values_list("code", flat=True)` and rejects anything else with `f"Attribute {code} is not present in Product"` (`api/apiproduct/staff_serializers.py:70-80`).

Frontend: one un-parameterised URL (`libs/product/action/data-access/src/lib/product-attributes-stream.service.ts:24`), the form built once per edit from that list (`libs/product/action/ui-staff-form/.../product-update-staff-form-ui.component.ts:141,147-169`), attribute display name **and unit** resolved from a translation key `product.attribute.key.<code>` (`libs/product/addendum/util-i18n/src/lib/product-attribute-i18n.service.ts:20-35`) whose data ships in `ts/assets/i18n/product/{id,en}.json`, attribute order from a hard-coded array (`libs/product/action/data-access/src/lib/product-attribute-ordering.service.ts:9-15`), hidden set from a hard-coded array (`libs/product/addendum/ui-attributes/.../product-addendum-attributes-ui.component.ts:34`).

**Lock 1's own migration sentence is literally option (b).** Verbatim from the lock comment: *"**Concretely:** `ProductAttribute.product_class` becomes `ProductAttribute.category`; a product sits on a node whose schema it obeys; `ProductClass` and `Product.product_class` are dropped."* (`evidence/issues/10966.md:1105`). `product_class` is a `ForeignKey` (`models.py:618-624`), so the rename produces a single FK to `Category` — a per-category copy. A3 therefore either confirms (b) or amends that sentence to a join table. This is the first thing the sketch surfaces and it is not a detail: the migration differs, and so does everything downstream.

---

## 1 · Option (a) — one global type, categories subscribe

### Schema

```sql
ProductAttribute            -- the registry; product_class FK DROPPED, no category FK
  code      slug UNIQUE           -- new constraint (today there is none at all)
  name, type
  -- `required` LEAVES this table (see below)

CategoryProductAttribute    -- new; the membership table
  category_id   FK Category  NOT NULL
  attribute_id  FK ProductAttribute NOT NULL
  required      bool                  -- moved off ProductAttribute
  display_order smallint              -- replaces ATTRIBUTE_PRIORITY_ORDER in ts
  name_override varchar NULL          -- Shopify's `extended` (see §1.4)
  UNIQUE (category_id, attribute_id)

ProductAttributeValue       -- UNCHANGED
```

### What changes, per call site

| Call site | Change |
|---|---|
| `product_attributes.py:57-58` | `ProductAttribute.objects.filter(categoryproductattribute__category=self.product.main_category)` — plus ancestors iff B4 says inherit. `Category` is an `MP_Node` so `get_ancestors_and_self()` is one query (`search_indexes_mixins.py:29` already does this). |
| `product_attributes.py:40` `if attribute.required` | reads the **membership** row, not the attribute. Needs the queryset to carry it (`.annotate` or iterate the through-model). |
| `staff_serializers.py:70-72` | same swap; `product.main_category` replaces `product.product_class`. |
| `staff_views.py:66-67` + `:73` | endpoint becomes `…/attribute/?category=<id>`; the 24-hour `cache_page` must key on the category or go. A global cache on a per-category answer is a correctness bug, not a perf question. |
| `serializers.py:164-191` | unchanged — it serialises the value's own `attribute.code`, which still exists. |
| `search_indexes.py` + the index templates | **nothing exists to change**: `ProductIndex` (`search/search_indexes.py:20-75`) declares no attribute field, and the document text is title + title_staff + upc + category names/code + description (`templates/search/indexes/catalogue/{product_text,product_lite,category_lite}.txt`). Any facet is new work under every option. |
| `third_party_api/google/content/products_api.py:214-224` | **nothing to change**: the feed sends availability, condition, description, link, title, price, sale_price, image_link and `offer_id` only. No attribute reaches Google today. |
| `basket/models.py:1265-1274`, `third_party_api/biteship/biteship.py:60-62,90` | read `product.attr.{weight,length,width,height}` by name. Condition 2 turns those into columns first, so they leave the attribute system before this decision lands. After condition 2 **`manufacturer` is the whole corpus** and no code reads it by name. |
| `admin.py:27-29` + `:32-34` `ProductAttributeInline` on `ProductClassAdmin` | **the schema editor that already exists.** Under (a) it must become an inline on the new `CategoryProductAttribute` through-model; under (b) it re-parents to `Category`; under (c) it gains a second level (attribute, then its options for this node). Missed by the first revision of this sketch (red-team round 1, finding 11). |
| `admin.py:18-19` `AttributeInline` on `ProductAdmin:46` · `admin.py:56-57,68` `ProductAttributeValueAdmin` | the per-product **value** editors. Unchanged by A3 itself, but both write `ProductAttributeValue` **without firing any reindex** — there is no `post_save` on that model (finding 14). |
| `models.py:489` vs `:490` — `receivers.py:31-41` → `index_utils.py:11-16` | `super().save()` at `:489` enqueues the Haystack **and** Google Merchant documents; `self.attr.save()` writes the values at `:490`, after. Any attribute facet this card unlocks is therefore built one write stale until the ordering is fixed or a `ProductAttributeValue` signal is added. Common to (a), (b) and (c). |
| ts `product-attributes-stream.service.ts:24` | `relativeUrl$` becomes a function of the selected category → the staff form must rebuild its attribute fields when `main_category` changes (today `main_category` is an ordinary formly field, `product-update-staff-form-ui.component.ts:117-124`, and the attribute fields are built once at init, `:141`). This is the single largest frontend change in the card, and it is the same under (a), (b) and (c). |

### The category move

`Category.move()` is a live staff path (`api/apicategory/staff_serializers.py:116`). Under (a) a **product** move (changing `Product.main_category`) is the interesting one:

- The value row survives — it points at the attribute, not at the membership. **"values survive a category move" is true.**
- But if the new category does not subscribe to that attribute, the row becomes an **orphan that still renders**: `validate_attributes()` iterates the *category's* set so it never sees it; `ProductAttributesContainer.save()` (`product_attributes.py:60-64`) likewise never writes it; and `ProductDetailsSerializer.attribute_values` (`serializers.py:207`) serialises `product.attribute_values.all()` — every row, subscribed or not, and the customer endpoint prefetches it unfiltered (`api/apiproduct/views.py:52,58-63`, `ProductFullViewSet`). So the product page shows a field its category does not have, forever, and no code path can clear it.
- **Fix at root, not a patch:** the move needs the same guard lock condition 5 already asks for (a check + a decision: block, drop, or keep-and-flag), and the read serializer should filter by the category's set rather than dumping all rows. Both are small; neither exists.

### Problems (a) causes

1. **A name-unique registry is a new constraint on data that has never had one.** `ProductAttribute.code` has no `unique=True` and no `unique_together` anywhere in the migrations (checked: `catalogue/migrations/*` contains exactly two `unique_together`, `("product","category")` and `("attribute","product")`). Adding `UNIQUE(code)` is free today at 5 rows and gets harder every year.
2. **`required` has to move.** It is on the attribute now (`models.py:655`) and all five production rows have it set. Once one type is shared by many categories, a single global `required` is meaningless — it is already meaningless: `manufacturer` is `required=True` and 59,662 products have no row. Moving it to the membership is the honest fix, and it is D17's question arriving early.
3. **The registry does not stay small.** Measured on the industry's own reference registry: 64.5% of Shopify's 8,195 attached attributes are used by **exactly one** category (`corpus-analysis/shopify_attr_reuse.out` §2). (a) buys sharing where sharing exists; it does not prevent 5,282 single-use types.
4. **The frontend translation bundle is the real bottleneck, not the table.** Every attribute needs `product.attribute.key.<code>.{name,unit}` in `ts/assets/i18n/product/{id,en}.json`, so **adding an attribute is a frontend release**. Today that file holds six codes — one of which, `internalname`, does not exist in the database any more (5 rows: manufacturer, weight, length, width, height). The registry and its display metadata have **already drifted** at n=5.
   *Fix at root:* `Category` already stores `_name_en` / `_name_id` columns (`models.py:110-121`) and serialises them (`api/apicategory/serializers.py:8-19`). The same pattern on `ProductAttribute` removes the bundle from the critical path. That is the in-repo analog, and it should be taken under any option.

---

## 2 · Option (b) — each category owns its own copy (Lock 1 as written)

### Schema

```sql
ProductAttribute
  category_id FK Category NOT NULL      -- the rename Lock 1 names
  code, name, type, required
  UNIQUE (category_id, code)            -- new
```

### Migration size, measured

Today 5 attributes × 1 class. Under (b) the same five facts on every category that holds products = **1,686 used nodes × 5 = 8,430 rows**, or 1,892 × 5 = 9,460 if every node gets a schema. **After lock condition 2** (four dimensions to columns) it is `manufacturer` alone: **1,686–1,892 rows**, one per node. That is the honest post-condition-2 number and it is small.

### What breaks that (a) does not

1. **A product's category move silently invalidates every one of its values.** `ProductAttributeValue.attribute_id` points at a *category-scoped* row. Move the product and each value now references an attribute belonging to the old category. `unique_together("attribute","product")` does not catch it; `validate_attributes()` does not catch it (it iterates the new category's set); nothing does. The value is not lost, it is **mis-attributed** — worse than losing it, because it still renders. Correct handling is a re-point on move: for each value, find the same `code` under the new category and swap the FK, else drop. That is a data migration executed on every staff move.
2. **One Elasticsearch field, several types.** Nothing under (b) stops `flavor` being `text` on one node and `integer` on another. A facet has to be indexed by `code` to be cross-category at all, and Elasticsearch needs one mapping per field name, so the first such divergence breaks the index. Under (a) `UNIQUE(code)` makes that unrepresentable. (Today there is no attribute field in `ProductIndex` at all, so this is a future defect, not a present one — but it is a defect that only (b) can create.)
3. **The curation bill is per node.** 639 nodes cover 90% of products; 607 used nodes hold fewer than ten products each. Authoring a private `Rasa` on each is the "639-node authoring project" the page names, and there is no list to curate once.
4. **No cross-category filter, by construction.** Two `Rasa` rows are two ids; a customer filtering "Rasa = Soto" across Mi Instan and Bumbu gets nothing unless the filter is written against `code`, which re-invents (a)'s global name space without its constraint.

### What (b) is genuinely better at

- It is the **smallest migration from today** and it needs no new table.
- It expresses "this node's schema" with no join, so the staff editor is a plain list under a node — the simplest editor of the three.
- It is what eBay does at 197,046 leaf-scoped aspect rows and it demonstrably scales (#11045 §1.1, §3); the price eBay pays is exactly item 4 — it has no cross-category aspect identity at all (`aspectId`/`valueId`/`"id":` → 0 over 867 MB).

---

## 3 · Option (c) — shared type, per-category value list

### Schema (three new tables, not one)

```sql
ProductAttribute                 -- global, as (a)
CategoryProductAttribute         -- membership, as (a)
ProductAttributeOption           -- the value rows
  attribute_id FK, code, label_en, label_id, display_order
  UNIQUE (attribute_id, code)
CategoryProductAttributeOption   -- which of the options this category offers
  category_attribute_id FK, option_id FK
  UNIQUE (category_attribute_id, option_id)
```

### Problems

1. **It only pays if two categories genuinely need different subsets of one list.** The card's own example — "noodle flavours and snack flavours are different lists" — is answered by the industry's reference taxonomy with option (a) *and a second type*: Shopify ships `flavor` (30 values, 293 categories), `pet_food_flavor` (43 values, 54 categories), `baby_food_flavor` (41, 4), `e_liquid_flavor` (22, 10) and five more — **nine separate global definitions, each with its own list, zero per-category subsetting** (`corpus-analysis/shopify_attr_reuse.out` §3). The category→attribute edge in that corpus carries exactly five keys — `description, extended, handle, id, name` — and **no value list** (ibid. §5).
2. **The fourth table is a second place a value can be wrong.** A product can hold a value whose option is no longer offered by its category. That is the (a) orphan problem plus a join.
3. **The staff editor becomes two-level:** pick the attribute for this node, then tick which of its options this node offers. There is no `ProductAttribute` UI at all today (lock condition 1), so this is the most expensive editor of the three to build first.

### Where (c) is actually the right shape

Only one platform in the thirteen states it verbatim, and it states it for a **per-type** definition, not a shared one — commercetools: *"For `enum` or `lenum` Types and sets of these AttributeTypes, the enum values can be different for each ProductType"*, alongside *"To use the same `name` in multiple ProductTypes, each AttributeDefinition must have the same `type`"* (#11081 §1.4). That is name+type shared, values per type — (c) on the values, (b) on the object.

---

## 4 · Option (a′) — (a) plus a per-membership display name (Shopify's `extended`)

Measured in the corpus: **106** base attributes carry `extended_attributes`, declaring **316** extended names, appearing on **2,891** of 93,007 category edges, and every extended edge **reuses the base attribute's GID** and therefore its single value list (`corpus-analysis/shopify_attr_reuse.out` §4; e.g. `Upholstery color`, `Body color`, `Handle color`, `Frame color` all carry `gid://shopify/TaxonomyAttribute/1`).

In our model this is one nullable column on the membership row — `name_override` above. It buys the whole of the card's motivating case ("Rasa" on food, a different label elsewhere) for the price of one column, while keeping one id, one value list and one filter. **Judgement: this is the cheapest resolution of the tension between (a)'s sharing and (b)'s local naming, and it has a working precedent at 14,606-category scale.**

Caveat, stated: the extended name is a *label*, not a separate list. It does not solve "noodle flavours ≠ snack flavours"; only a second type or (c) does.

---

## 5 · The staff editor, under each option

No `ProductAttribute` UI exists (lock condition 1: build it first). What each option implies:

| | (a) global + membership | (b) per-category copy | (c) + per-category list |
|---|---|---|---|
| Registry screen | one list of N types, name-unique | none — types live inside nodes | one list of N types |
| Node screen | tick which types this node has, set required/order/label-override | author name+code+type+required per node | tick types, then tick options per type |
| Product form | fetch types for the product's category; rebuild on category change | same | same |
| Django admin inline today | becomes an inline on the membership model | re-parents to `Category` | two levels |
| Rename a type | one row | N rows, one per node that copied it | one row |
| "Which nodes use Rasa?" | one query on the membership table | a `LIKE` over codes | one query |

Under all three, the product form must become category-aware (`product-attributes-stream.service.ts:24` + `product-update-staff-form-ui.component.ts:141`). That cost is **common** and should not be attributed to any one option.

---

## 6 · Fit-check (what a red team should attack)

- The membership table is a plain Django M2M-through; nothing in `ProductAttributeValue` changes under (a), so the 471,143 existing value rows migrate by not moving. Under (b) they all keep working too — until the first product category move.
- The one production create path is `ProductCreateSerializer.create()` inside `transaction.atomic()` (`staff_serializers.py:98-128`); `_assign_attributes` runs inside it (`:124`). Swapping the set-reader is one line inside an already-atomic block.
- `ProductClass.default()` is `ProductClass.objects.get()` (`models.py:88-90`) with two non-test call sites (`staff_views.py:67`, `staff_serializers.py:118`) and it raises the moment a second row exists. Every option deletes it. That is the same three-line change #10942 measured in 2026-08 and it is still three lines.
