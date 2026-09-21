# redteam-round1.md — adversarial review of ATTR-DEF (A1 · A2 · A0)

Reviewer did not write the brief. Everything below was re-derived by doing: both pins re-opened
(`/home/irvan/copilot/py-5` @ `4f99dc01c6`, `/home/irvan/copilot/ts-layer2` @ `82187a17bd` — both
**verified at the stated commits**), all four SQL files re-run against `solvent-staging`, every
matrix tally re-derived from the records, every new-source quote re-opened in the saved corpus.

**Counts: 3 BLOCKING · 12 SERIOUS · 13 MINOR.**

---

## BLOCKING

### 1 · The hard-coded TS ordering array does **not** order the customer spec sheet — and a recommendation rests on it
**What is wrong.** `ProductAttributeOrderingService` is referenced in exactly **one** place in the whole
frontend: `ts/libs/product/action/data-access/src/lib/product-attributes-stream.service.ts:33`, inside
`ProductAttributesStreamService.fetchFromApiService$`, which decorates the **staff definition list**
fetched from `relativeUrl$ = of('api/product/staff/attribute/all/')` (`:24`). The customer spec-sheet
component (`ts/libs/product/addendum/ui-attributes/src/lib/product-addendum-attributes-ui/product-addendum-attributes-ui.component.ts`)
never injects it; it iterates `productAddendum.attribute_values` in the order the API returns them,
and that order is set on the **backend** by `sorted(response["attribute_values"], key=lambda x: x["attribute"]["code"])`
at `py/mono/solvent/api/apiproduct/serializers.py:219-221`. Verified by
`grep -rn "ProductAttributeOrderingService\|sortProductAttributes" --include=*.ts ts/` → only the service
itself, its barrel export, and `product-attributes-stream.service.ts`.

**Where.** `ATTR-DEF.md` §A1.4 ("the customer spec sheet renders every value except a hard-coded deny-list
…; the display order is a hard-coded array `['internalname','length','width','height','weight']`") ·
§A0.4 ("Display order is a second hard-coded array containing the same dead code") · §A0.6 ("It replaces
**two hard-coded frontend arrays** with data — the deny-list and the ordering list") · §A0.7
("`display_order` (**the picker and the spec sheet**, replacing the hard-coded TS array)") ·
`design-A1.md` §0/§3b.2/§6 · `design-A2.md` §0.

**Why it matters.** The claim is placed so that a reader takes the TS array to be the spec sheet's order,
and the A0 recommendation for `display_order` is sold on deleting it. For the spec sheet the thing a
`display_order` column replaces is a **backend alphabetical sort**, not a frontend array; the array
governs the **staff form's** field order and would survive unless the same column is threaded through
`ProductAttributesStreamService`. That is two surfaces, two mechanisms, and two changes — the brief
prices one.

**Fix.** Separate the two: spec-sheet order = `serializers.py:219-221` (alphabetical by `code`); staff-form
order = `product-attribute-ordering.service.ts:9-15` applied at `product-attributes-stream.service.ts:33`.
Restate §A0.6/§A0.7 as "replaces one frontend array **and** one backend `sorted()`", and add
`ProductAttributesStreamService` to §A1.4's consumer inventory.

---

### 2 · C5 is declared "confirmed" in a sentence that contradicts the brief's own re-expression of V1 two sentences earlier
**What is wrong.** `ATTR-DEF.md` §A2.7, "#10778 items — confirm / re-express / supersede", says:

> **V1** (axis names from a shared staff-extendable catalogue) — **confirmed**, and under Lock 1 the
> catalogue is the **category-owned** `ProductAttribute` set. … **C5** (one global name catalogue,
> **not per category**) — **confirmed for names**; flagged as at risk for values …

Those two dispositions cannot both hold. If Lock 1 makes the name catalogue the category-owned
`ProductAttribute` set (`ProductAttribute.product_class` → `.category`), the name catalogue **is**
per-category, which is precisely what C5 denies. Nothing in the brief's own recommended design creates a
global name registry above the per-category definitions: the field list it hands condition 1 in §A0.7 is
`code, name, type, required, is_axis_eligible, is_customer_visible, is_filterable, display_order, unit`
— no cross-category name catalogue.

**Where.** `ATTR-DEF.md` §A2.7, the "#10778 items" paragraph.

**Why it matters.** BRIEF.md §1 requires standing #10778 items to be confirmed, re-expressed, or proposed
superseded, and **never silently contradicted**. C5 is marked "confirmed" while the brief's own Lock-1
reading supersedes it. It is also poaching: whether one `Rasa` is shared across categories is **A3**, owned
by ATTR-VALUE, and the brief hands A3 a "confirmed" it did not earn.

**Fix.** Replace "C5 — confirmed for names" with either (a) **at risk under Lock 1, referred to A3** — the
honest reading given V1's re-expression — or (b) an explicit proposal that a global *name* registry sits
above per-category definitions, costed on our models. Say which, on the record.

---

### 3 · The recommended option 4 materially alters binding lock condition 2 while the brief declares condition 2 "confirmed … the only correction option 1 needs", and §2/§5 keep the unaltered reading
**What is wrong.** BRIEF.md §1 condition 2 (binding): take the four shipping dimensions **out of the
attribute system**, after which "`manufacturer` is the entire existing attribute corpus". The brief's
headline recommendation (option 4, §A1.7) keeps a `ProductAttribute` definition row for each of the four
with `storage='column'` — explicitly: *"After the four dimensions become columns they would still have a
definition — name, unit, `display_order`, `is_customer_visible` — instead of vanishing"* (§A1.6), and
`design-A1.md` §3b.2's last row states the delta outright. But:

- §A1.1 says option 1 "**Respects** … condition 2 (the four dimensions become `NOT NULL` columns, **after
  which `manufacturer` is the entire corpus**)" — the unaltered reading;
- §A1.5 says "**Post-condition-2**: the corpus is `manufacturer` alone";
- §A1.7 says "**Condition 2 is confirmed** as the right first move and is the ***only*** correction option 1
  needs".

Under option 4, `manufacturer` is the entire **value** corpus but not the entire **definition** corpus
(five definitions survive), so §A1.1 and §A1.5 are false of the brief's own recommendation.

**Where.** `ATTR-DEF.md` §A1.1 · §A1.5 (post-condition-2 bullet) · §A1.6 (option-4 bullet) · §A1.7
("what it forces in steps 1–5") · `design-A1.md:207`.

**Why it matters.** A binding condition is being re-expressed without the label, in the one card whose job
is to rule on what an attribute *is*. Whoever ships condition 2 from §A1.5 will delete four definitions
that §A1.7 depends on surviving.

**Fix.** State the disposition explicitly: "**condition 2 is re-expressed** — the four *values* leave the
attribute value table; the four *definitions* stay, with `storage='column'`." Then correct §A1.1 and §A1.5
to say "the entire attribute **value** corpus", and drop "the *only* correction option 1 needs".

---

## SERIOUS

### 4 · "`both` occurs 19 times" in #11082 does not reproduce under any scoping
**Where.** `ATTR-DEF.md` §A2.2 ("that word is not in the Revision-2 record (re-checked 2026-09-19:
`both` occurs 19 times, none as a headline)"), repeated in §A2.8 and `matrix-A2.md` §13.
**Measured 2026-09-19 on `evidence/issues/11082.md` (1,430 lines; the whole file is Revision 2, per its
line 14):** `grep -oi '\bboth\b'` → **33**; body only (lines 1–739, before the first `## Comment`) → **14**;
case-sensitive `\bBoth\b` → **3** (lines 688, 765, 943). No scoping yields 19.
**Why it matters.** This instrument is the sole evidence for a published **correction to #11031** — a
master-issue claim the brief overturns and repeats in its Limits section. The *substantive* half survives
(I re-read all three capital-`Both` occurrences; none is a headline for the axis question), but the number
that certifies it is wrong.
**Fix.** Re-run and restate with the scope named: "3 case-sensitive `Both`, 33 case-insensitive `both`
over the whole record / 14 over the body; none is a headline."

### 5 · Walmart's `$ref` 0 is quoted without the record's own ⚠️ Scope correction — a smoothed hedge
**Where.** `ATTR-DEF.md` §A1.2, the definition-vs-value tally: *"**Walmart** (`"the schema **repeats
definitions rather than referencing them**"` — 383,947 slots for 6,576 names, `$ref` **0**)"*; repeated in
`matrix-A1.md`, "No (2)" bullet.
**What the record actually says** (#11046 §2, one sentence later, same line): *"⚠️ **Scope correction:**
that is about the **feed** schemas only. The read-side OpenAPI document ***does*** use references —
`"$ref"` occurs **2** times, both `#/components/schemas/VariantGroupInfo`; **"no shared definition
anywhere in the published schemas" would be too broad.** The read side returns values, never ids."*
**Why it matters.** BRIEF.md §4: "never paraphrase a hedge away." The unqualified `$ref` 0 is one of the
two legs of the "definition and value are separate objects: 8 · 3 · **2 no**" tally and of the labelled
flat-feed inference. §A2.2 uses the same instrument **correctly scoped** ("over 451 MB"), which shows the
scope was known and dropped in §A1.
**Fix.** Carry the scope correction in §A1.2 and `matrix-A1.md`, or move Walmart to *partial*.

### 6 · matrix-A0's V2 tally does not sum to 13, and the ⚠️ note offered does not fix it
**Where.** `matrix-A0.md`, "Is visibility scoped per category? (V2)".
Row 1 = **8** (eBay · Walmart · Shopee · Tokopedia · Amazon · Salesforce · Google · Shopify) — correct.
Row 2 is published as **4** but names **five**: Square · Akeneo · commercetools · WooCommerce · Magento.
8 + 4 = 12. The ⚠️ counting note says "the second row names five platforms; **Google sits in the first
row** on requiredness only" — a non-sequitur: Google is already counted in row 1, so it cannot absorb the
missing unit.
**Why it matters.** A0's most load-bearing prose claim ("**Option 2 is a mirage**… A category-like object
decides attributes in **8 of 13**") sits on this table, and a tally that does not reach 13 is exactly the
failure the named-ambiguous rule exists to prevent.
**Fix.** Publish row 2 as **5** and delete the note, or state which platform is genuinely unassignable and
name it.

### 7 · A0 §2 has no named ambiguous list for its 10/13 — the four material hedges live only in the side file
**Where.** `ATTR-DEF.md` §A0.2. BRIEF.md §3 step 2 and §4's shape both require "the tally per option with
a **named** ambiguous list". §A1.2 and §A2.2 each carry one inline; §A0.2 does not.
**What is hidden.** `matrix-A0.md`'s own hedge list is substantial and none of it reaches the brief:
**Square** — the two visibility enums are cited "by arity only", never enumerated, and a plausible third
`app_visibility` value is rejected live as `INVALID_ENUM_VALUE`; **Magento** — 22 flags exist as columns,
**18 have no meaning stated in the record**, and *"no instance of `catalog_eav_attribute` was ever
retrieved"*; **Akeneo / WooCommerce / commercetools** — the records quote **no vendor definition** of
`useable_as_grid_filter`, `is_visible` or `inputHint`; **Walmart** — `@group=` is a *purpose* tier, not a
visibility flag, and per-attribute viewing/editing restrictions exist only as workbook column headers with
no values.
**Why it matters.** The brief calls 10/13 "the strongest signal in this card" and takes **high** confidence
on it. Five of the ten are hedged in ways a reader of the brief alone cannot see.
**Fix.** Lift the named hedge list into §A0.2, as A1 and A2 do.

### 8 · Missed consumer: the reindex fan-out has **zero** attribute awareness, and `Product.save()` indexes before it writes values
**What I found (not in the brief or any side file).**
- `py/mono/solvent/catalogue/receivers.py:31-41` — `product_post_save_update_indexes` calls
  `update_products_indexes([instance])` and `update_product_dependent_indexes(instance.id)`.
- `py/mono/solvent/catalogue/index_utils.py:11-16` — `update_products_indexes` enqueues **both** the
  Elasticsearch document *and* the Google Merchant push (`GoogleProductIndexQueue`).
- **There is no `post_save`/`post_delete` receiver on `ProductAttributeValue` anywhere** — an
  attribute-value-only write never reindexes and never re-pushes to Google.
- `py/mono/solvent/catalogue/models.py:486-490`: `super().save()` (which fires the post_save →
  enqueue) runs **before** `self.attr.save()` writes the values.
- `grep -rn "attribute\|attr\." index_utils.py models_mixins.py` → **0 hits**.
**Where the brief needed it.** §A0.4 ("Google feed — sends zero attributes"), §A0.7 (feed ranked 4th,
"costs one method"; filters 5th), §A2.4 ("Under shape 1 the axis value costs **zero new write code**"),
`design-A2.md` §1.4/§1.6.
**Why it matters.** The first attribute value that reaches the index or the feed requires a new receiver
on `ProductAttributeValue` **and** a re-ordering of `Product.save()` — under *both* A2 shapes. The brief
prices neither, and "zero new write code" is only true while nothing downstream reads the value.
**Fix.** Add the fan-out to §A1.4's inventory and price the receiver + save-ordering change in §A0.7 and
`design-A2.md`.

### 9 · Missed consumer: the staff attribute endpoint's permission strings, on both stacks
**What I found.** Backend: `py/mono/solvent/api/apiproduct/staff_views.py:57-64` —
`ProductAttributeViewSet(ListAllApiMixin, DjangoModelPermissionApiMixin, SolventAPIViewSet)` with
`permissions_required = ["catalogue.view_productattribute"]` (`:64`) and
`get_queryset → ProductClass.default().attributes.all()` (`:66-67`). Frontend:
`ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43` — `'catalogue.view_productattribute'`.
**Where.** Neither string appears in `ATTR-DEF.md`, `matrix-A0.md`, `design-A1.md` or `design-A2.md`
(grepped).
**Why it matters.** A0's second question is literally *"are some attributes customer-facing while others
are staff-only?"* Our **existing** staff-vs-customer mechanism for attribute *definitions* is a Django
model permission mirrored in a frontend permission union — and the brief's §A0.7 recommends a new
`is_customer_visible` flag without recording what already gates the definition surface, or that a schema
editor (condition 1) will need `add_/change_/delete_productattribute` strings on both stacks.
**Fix.** Add the two cites to §A0.4 and name the permission strings condition 1 must add.

### 10 · Missed consumer: `ProductAttributesStreamService` — the frontend's only definition consumer
**What I found.** `ts/libs/product/action/data-access/src/lib/product-attributes-stream.service.ts:24`
(`relativeUrl$ = of('api/product/staff/attribute/all/')`) and `:33` (applies
`sortProductAttributes`). Consumed by `product-new.component.ts:35,47,53` and
`product-update.component.ts:47,58,72-73`.
**Where.** Absent from every file in the brief. §A1.4 cites the backend half (`staff_views.py:57-75`) but
not its only client, and §A0.6's claim that "the API already serves the definition list to the staff app,
so flags reach the frontend through an existing endpoint" is asserted without the client cite that proves
it.
**Fix.** Cite it in §A1.4; it is also the file finding 1's correction turns on.

### 11 · "6 backend call sites" does not reproduce — the count is 8
**Where.** `ATTR-DEF.md` §A1.4 ("option 1 changes **6 backend call sites** (the four dimensions'
readers)") · `design-A1.md` §1.3 ("rewrites six call sites") · `design-A1.md` §6 table ("Backend call
sites changed | 6").
**Measured.** `grep -rn "attr\.\(weight\|length\|width\|height\)" --include=*.py py/mono/` excluding
tests/migrations → **8 production lines**: `biteship.py:60,61,62,90` and `basket/models.py:1265,1272,1273,1274`
— in **3 methods** (`_parse_product`, `line_weight_gram`, `line_dimension_cm`) across **2 files**, plus a
docstring at `product_attributes.py:10` and 3 integration-test assertions. No reading gives 6.
**Why it matters.** It is the headline of the 6-vs-~20 cost comparison that carries option 1. The
conclusion survives; the number does not.
**Fix.** State "8 read sites in 3 methods across 2 files" and say which unit is being counted.

### 12 · "6 of the 7 platforms with a family-level choice" is unsourced
**Where.** `ATTR-DEF.md` §A2.7, "What it forces in steps 1–5": *"**D5** (family chooses vs type imposes) →
the family chooses … which is what **6 of the 7** platforms with a family-level choice do."*
**What I found.** The phrase and the tally appear **nowhere else** — not in `matrix-A2.md`, not in
`design-A2.md`, not anywhere in `evidence/` (grepped for both "6 of the 7" and "family-level choice").
The decision matrix's nearest table ("2c · Does the type constrain what a family may vary on?") is
6 Yes / 2 Mixed / 3 No / 2 N-A — a different question with a different shape.
**Why it matters.** It is the only evidence given for a forcing claim on an open decision (D5).
**Fix.** Derive it in `matrix-A2.md` with the 7 platforms named and the 1 dissenter named, or delete the
number and state D5 as a judgement from our code alone.

### 13 · `api_mixins.py:11-22` resolves to the wrong file
**Where.** `ATTR-DEF.md` §A1.4 (consumer table) and §A0.4.
**What is wrong.** Three files named `api_mixins.py` exist. The one **in the same directory as the cited
`staff_views.py`** — `py/mono/solvent/api/apiproduct/api_mixins.py:11-22` — is
`FacilityIdAndPlatformSerializerContextMixinBase.get_facility_id_and_platform_serializer_context`,
nothing to do with `all`. The intended file is
`py/mono/solvent/api/shared/views/api_mixins.py:11-22` (`ListAllApiMixin.all`), which does verify.
**Why it matters.** BRIEF.md §3.3: "cited `path:line` at the pin". A bare basename that resolves to a
sibling file of a different class is a cite that fails on first check.
**Fix.** Use the full path.

### 14 · Missed facts: `Product.attributes` M2M and the `ProductClass` singleton
**What I found.**
- `py/mono/solvent/catalogue/models.py:419-422` — `Product.attributes = ManyToManyField("catalogue.ProductAttribute", through="ProductAttributeValue")`.
  `ProductAttributeValue` is a **declared through-model**, so option 2's "rebuild the value table with
  locale/scope selectors" and option 4's `storage` discriminator both touch a live M2M declaration.
  `design-A1.md` §5 mentions "joined to `Product` twice" in passing; neither §A1.4 nor §A1.6 prices it.
- `models.py:88-90` — `ProductClass.default()` is `ProductClass.objects.get()`, i.e. it **raises** the
  moment a second row exists; called at `staff_serializers.py:118` and `staff_views.py:67`
  (`ProductClass.default().attributes.all()` — the definition endpoint's entire queryset).
**Why it matters.** Lock 1 retires `ProductClass`. The brief cites `productclass_rows = 1` as a fact but
never records that the number is enforced in code by a `.get()` on two hot paths, one of which is the
staff definition list that condition 1's editor extends.
**Fix.** Add both to §A1.4 and note the two `.default()` call sites Lock 1 must rewrite.

### 15 · §8's stated route for the `manufacturer` provenance gap cannot be run as described
**Where.** `ATTR-DEF.md` §A1.8: *"**Not collected:** whether `manufacturer` was ever intended as brand…
Route: `git log -S "manufacturer"` on **the migration that created attribute id 2**."*
**What I found.** `grep -rln "manufacturer" py/mono/solvent/catalogue/migrations/` → **0 files**. The only
migration that touches `ProductAttribute` rows at all is `0011_add_title_staff_field.py`. There is no
migration that created attribute id 2 — `manufacturer` was created as production data — so the route is
not executable, and the grep that shows this is one the brief already ran ("0 hits outside migrations").
**Why it matters.** BRIEF.md §3.2 requires a gap to be "explicitly 'not collected' + **the route that
would settle it**". This route is a dead end, and the brief could have said so in the same breath.
**Fix.** Replace with: "no migration created it; the definition is production data — route is the
production audit trail / the issue that introduced it."

---

## MINOR

16. **Wrong path prefix.** `ATTR-DEF.md` §A0.4 cites `apps/solui/src/app/app-routing.module.ts:23`; the
    file is `ts/apps/solui/src/app/app-routing.module.ts` (line 23 is correct — the
    `import('@ts/shop/feature-shell')`). Every other frontend cite in the brief carries the `ts/` prefix.

17. **Square 404 "bodies … all md5-identical" does not reproduce on the bodies.** The three
    `corpus/square/*.404.html` files have **three different** md5s and sizes
    (`88b507dd…`/90,932 B, `419a8951…`/91,022 B, `6e3d8ee6…`/90,956 B). Only the tag-stripped
    `.404.txt` extracts are identical (`f3cdc223…`, 830 B each). The substantive point (a Square 404 is
    generic and proves nothing) holds on the text; the instrument as worded does not.
    *Where:* §A0.2 and the corpus table.

18. **`getFormlyFieldConfigs` is not a symbol in `ts-layer2`** (`grep -rn` → 0 hits). `design-A2.md` §1.3
    names it; the method is `getProductAttributeFields$`, which the brief cites correctly elsewhere.

19. **The `internalname` promotion left a *third* dead pair of entries, uncounted.**
    `attribute.key.internalname.{name,unit}` exist in **both** `ts/assets/i18n/product/en.json` and
    `id.json` (verified: the six keys are `height, internalname, length, manufacturer, weight, width`).
    §A1.6 says the promotion "left **two** dead entries in **two** hard-coded frontend arrays". The
    undercount weakens the brief's own strongest argument for option 4.

20. **Brand sub-tally naming is short by one.** §A1.2's pre-revision line reads "…· **3 not established**"
    but names only Square and Salesforce. `matrix-A1.md` correctly names three (+ WooCommerce).
    Relatedly, §A1.2's "⚠️ … **Two do**, in two different ways" is followed by **four** platforms
    (Shopee, Tokopedia B, WooCommerce, Akeneo) in two *kinds*; §A1.7 then says "two platforms model brand
    as a merchant-owned entity", which is the correct statement. Reword §A1.2 to "two *kinds*".

21. **Magento flag count is 22 in two places and 24 in two others.** `ATTR-DEF.md` §A1.2/§A0.2 and
    `rationale.md:175` say "22 flags"; §A0.3's labelled inference and `matrix-A0.md` §13 say 24.
    (Both are right for their scope — 22 in `Catalog`, 24 merged — but the brief never distinguishes
    them at the point of use.) Also, of the 22, `attribute_id` is a PK, `apply_to` and
    `frontend_input_renderer` are varchars and `position` is an int, so "22 flags" over-counts flags.
    *Verified at source:* `Catalog/etc/db_schema.xml:1050-1106` declares exactly 22 columns;
    `CatalogSearch` adds `search_weight float NOT NULL default 1`, `Swatches` adds `additional_data text`.

22. **§A1.4's "exhaustively" is not exhaustive.** The table headed *"Every reader of an attribute value in
    the backend, exhaustively"* omits `Product.clean()` → `attr.validate_attributes()`
    (`models.py:484` → `product_attributes.py:36-52`) and `Product.save()` → `attr.save()`
    (`models.py:490` → `product_attributes.py:60-64`), and the write-side serializer
    `ProductAttributeValueStaffSerializer` (`staff_serializers.py:36-38`, whose `value` is a plain
    `CharField(allow_null=True, allow_blank=True)` for *every* attribute type). `design-A1.md` §1.2 and §5
    do cover `validate_attributes()`; the table that claims exhaustiveness does not.

23. **Cite drift (all small, all confirmed otherwise).** `search_indexes.py:92-95` → actual **93-96**;
    `products_api.py:190-241` → `_get_product_input` starts at **188**; `models.py:394-399` for the
    internalname comment → the comment is at **393**; `isStatic()` cited `:798-801` in `ATTR-DEF.md` and
    `:794-801` in `matrix-A1.md`; `class-wc-brands.php:275-331` in `ATTR-DEF.md` vs `:267-292` in
    `matrix-A1.md`. None changes a claim.

24. **"0 hits outside migrations" implies migration hits; there are none.** §A1.4:
    `grep -rn "manufacturer" --include=*.py py/mono/solvent/` returns **0 hits, full stop** (re-run).
    Also, `manufacturer` *does* have a frontend reader — the hard-coded i18n key
    `attribute.key.manufacturer.{name,unit}` — which the brief records elsewhere but not beside the
    "zero code readers" headline.

25. **The corpus inventory omits files the brief cites.** `corpus/woocommerce/doc-woocommerce-brands.txt`
    (source of the load-bearing *"Each brand can have its own name, description, image, and archive page"*),
    `Internal-Brands.php`, `store-api-product-brands.md` and `ProductBrandSchema.php` are cited or quoted
    but absent from the "Corpus fetched for this brief" table. Two WooCommerce quotes in §A1.2 carry **no
    file cite at all** (both verified present: `doc-woocommerce-brands.txt:42`,
    `dev-blog-introducing-brands.txt:14`).

26. **An unmarked truncation.** §A2.2 quotes Amazon as *"Most product facts must be **replicated** across
    all listings"*; the record reads *"…across all listings **within the variation family**"*
    (#10976 §2 / `10976.md:14359`). No ellipsis. The quantifier hedge ("Most") **is** carried in
    `matrix-A2.md` §(c), and #10976's own audit row `A3-f` warns specifically about mis-extending this
    sentence — worth marking the cut.

27. **"5 · 4, with four rows that could move it" then names five.** §A2.2 and `matrix-A2.md`'s tally note
    say "four rows"; the named list is eBay, Walmart, Google, commercetools, **Magento** — five — plus the
    era-split Tokopedia. Both tallies do sum to 13 correctly.

28. **"four repairs, all at `models.py:608-623`"** (§A1.7) — the third repair ("the display `name` actually
    served by the API") lives in `serializers.py:164-176`, not in that range.

---

## Verified clean — re-run and confirmed

**Pins.** `py-5` at `4f99dc01c6baf181…` (2026-09-18) and `ts-layer2` at `82187a17bdd5cfbe…` (2026-09-18) —
both exactly as stated.

**SQL — all four re-run 2026-09-19 (`bq --project_id=solvent-staging … --format=csv`); output
byte-identical to every saved CSV.**
`attribute-definitions.sql` · `attribute-uses-and-visibility.sql` · `manufacturer-as-brand.sql` ·
`title-facts-vs-attributes.sql`. Every figure quoted in §A1.5 and §A0.5 re-derives, including all the
percentages: 290,774/424,644 = 68.5%; 2,867/5,510 = 52.0%; 21,577/30,983 = 69.6%; 1,002 = 3.2%;
1,923 = 6.2%; 2,736 = 49.7%; 15,516/46,499 = 33.4%; 59,662/106,161 = 56.2%; 2,843/23,299 = 12.2%;
72,635/106,161 = 68.4%. Every number in the brief carries a SQL file and the 2026-09-19 date.

**Backend cites re-opened at the pin and confirmed exact.** `models.py:608-655` (incl. `Meta` =
`app_label`+`ordering` only, `product_class` nullable, `TYPE_CHOICES` 641-648, `required` :655) ·
`models.py:719-747` + `:730` `unique_together` + six scalar columns 742-747 · `product_attributes.py:5-64`
(whole file is 64 lines) · `biteship.py:60,61,62,90` · `basket/models.py:1265,1272,1273,1274` ·
`serializers.py:164-176` (**`name` is genuinely never serialised** — `["code"]` and
`["code","type","required"]`) · `serializers.py:194-224`, `:200,207`, `:219-221` · `views.py:60-61` ·
`staff_serializers.py:65-81`, `Product(` at `:116`, `transaction.atomic()` `:121` · `staff_views.py:57-75`
· `staff_urls.py:16` · `admin.py:27-34, 51-57, 65-68`, `:53` `prepopulated_fields` ·
`search_indexes.py:20-75` (`category` faceted `:65`, `price` `:67`, `product_class` commented `:62`) ·
`models.py:895-910` (ProductMeta) · `receivers.py:28` · `models.py:394-399` (title_staff), `:486-491`,
`:501-515`, `:571-573` · `managers.py:11-26` · `inventory_replenishment_service.py:31-36,114` ·
`purchasing_quantity_service.py:39,158` · `transport/models/models.py:222` ·
`products_api.py:214-241` (exactly 8 feed fields, **no** attribute value, **no** `item_group_id`) ·
`templates/search/indexes/catalogue/product_{lite,text}.txt` (title + title_staff + upc + category +
description). **Independently confirmed the two absences the brief asserts:**
`grep -rn "attr\|attribute" py/mono/templates/search/indexes/` → 0 hits across all 49 templates;
`grep -rn "attribute_values\|attr\." --include=search_indexes.py py/mono/` → 0 hits.
`grep -rn "manufacturer" --include=*.py py/mono/solvent/` → 0 hits.

**Frontend cites re-opened at the pin and confirmed exact.** `product-attribute.model.ts:1`
(`'float' | 'text'`) · `product-update-staff-form-ui.component.ts:147-169` (`getProductAttributeFields$`),
`:63`, `:196-200` · `product-attribute-i18n.service.ts:20-35`, `:25` ·
`ts/assets/i18n/product/{en,id}.json` → **exactly six** `attribute.key.*` entries ·
`product-addendum-attributes-ui.component.ts:34,47-50` (`hiddenAttributes = ['internalname']`) ·
`product-attribute-ordering.service.ts:9-15` (the array is exactly as quoted) ·
`shop-feature-shell-routing.module.ts:75` · `product-detail-ui.component.html:17,34` ·
`SolventAPIViewSet` **is** a `GenericViewSet` · frontend files matching `facet` → **0**.

**Corpus quotes — every one I opened is verbatim and at the cited line.**
*Shopify:* `sfy-docs_apps_build_custom-data.md:13` and **`:35`** exact; the `type: "weight"` metafield
example; the Liquid sentence; both changelog quotes; introspection **6,600,955 B** exact, `LEGACY_LIQUID`
→ **0**, `LEGACY_LIQUID_ONLY` present in the changelog; `ProductVariant` **52** fields in `2026-07` and
**41** in `2025-10` with **no** weight-named field in either; **3,289** distinct field names;
`MetafieldAccess{admin,customerAccount,storefront}`, `MetafieldStorefrontAccess` = 2,
`MetafieldAdminAccess` = 5 output / 2 input, `MetafieldCapabilities` = 5, `MetafieldOwnerType` = 26;
mock.shop Storefront = **426** types, 4 containing `brand`, **0** containing `vendor`.
*Square:* `raw-add-custom-attributes.txt:147, 150, 243, 250, 256` all exact; the 2020-05-05 dev-blog
rationale exact; `square-api.json` = **3,273,134 B**.
*Magento:* clone at `874f1f5cdf3bc…`, commit date **2026-09-17** — exactly as stated;
`CategorySetup.php:410-421` (`sku`, `'type' => 'static'`) and `:537-551` (`manufacturer`, `'input' =>
'select'`, `'user_defined' => true`, `'filterable' => true`, `'comparable' => true`, `apply_to`) exact;
`AbstractAttribute::isStatic()` at `:798-801`, `TYPE_STATIC` at `:30`;
`catalog_eav_attribute` = 22 columns at `db_schema.xml:1050-1106`, `is_global`/`is_visible` default `1`
and every other flag `0`; `+search_weight` `+additional_data` = **24**; `FilterableOptions.php` returns
exactly the three values quoted; `Magento_Eav/README.md` is **128 B** and the quote is the whole file;
`eav-attributes.txt:79` plus **all 14** listed attributes and the `getCustomAttributes()` sentence at `:96`.
*eBay:* the three OpenAPI contracts at **88,972 / 793,331 / 383,158 B** and versions
**v1.1.1 / 1.18.4 / v1.20.4** — all exact; the `Product.brand` merge sentence; the
`aspectEnabledForVariations` description; `sellercenter-item-specifics.txt:79,137` exact.
*commercetools:* `oas/api/openapi.yaml` **3,103,801 B**, `graphql/schema.sdl` **538,456 B**, `\bbrand\b`
→ **0** in both; `docs-lm_product-modeling_product-types.txt:69` (both quotes) exact.
*Akeneo:* `brand-reference-entities.txt:290` and `brand-help-104…:96-97` exact; and **both demo-fixture
lines land on the cited rows** — `icecat_demo_dev/attributes.csv:75` =
`brand;Brand;Brand;Marque;…;pim_catalog_simpleselect;0;0` and `attribute_options.csv:114` =
`akeneo;;Akeneo;;brand;1`.
*WooCommerce:* `class-wc-brands.php:275-331` — `register_taxonomy('product_brand', array('product'), …
'hierarchical' => true, 'label' => 'Brands', 'show_in_rest' => true)` with `@since 9.4.0` at `:281`; all
five rationale quotes present (`doc-woocommerce-brands.txt:42`, `dev-blog-introducing-brands.txt:14,18`,
`dev-blog-enabling-brands`, `Internal-Brands.php:39`).
*Amazon:* `spapi-models` @ `3659f96`, **67 JSONs / 8,329,281 B** — exact.
*Google:* **15** discovery documents / **1,045,733 B** — exact.

**Records.** #11031's D3 tally (**4 marked / 4 object / 1 neither / 4 unassignable**) reproduces at
`11031.md:135` and `10966.md:291`. The matrix page's D3 cells reproduce at
`catalogue-decision-matrix-2026-09-16.txt:1233-1256`. #10966's D3 section (`:276-297`) and the
"Ayam Bawang… the drift this whole design exists to remove" quote used in `design-A2.md` §2.3 is **verbatim
at `:297`**, under the heading `:293` the brief names. `H1-variant-axis-object-vs-attribute.md` §1's
shop-level-registry counter-search (*"**Not found.**"*, `:140`) and §2.3's "what lives where" both
reproduce. Spot-checked and confirmed verbatim in `matrix-A2.md`: Amazon, Walmart (`copied per item`,
`451,013,258 B` instrument), eBay (`pivoting aspect`, 197,046 / 73,833 / 123,213), Shopee (0 of 92),
WooCommerce (three representations), Salesforce (the whole deprecation note). In `matrix-A0.md`: Amazon
`hidden`, Walmart's five `@group=` counts incl. 27,828 = 6,957 × 4, Salesforce's attribute-group sentence,
Akeneo's `pim_catalog_attribute_requirement`, WooCommerce's `attribute_public`, Shopify's conditional-
metafield block and the 7,750 category ids, eBay's `aspectUsage` 136,195 / 60,851 and the 33-of-421
disagreement.

**Tallies that re-derive and sum to 13.** A1: 9 · 3 · 1. A1 definition-vs-value: 8 · 3 · 2. A1 brand,
pre-revision (5·3·2·3) and post-revision (4·3·2·2·2). A2 declaration: 5 · 4 · 1 · 1 · 1 · 1. A2 value
storage: 6 · 4 · 1 · 1 · 1. A0 V1: 10 · 3. A0 V3: 1 · 4 · 3 · 5. (Only A0 V2 fails — finding 6.)

**Method compliance that holds.**
- **Tokopedia is never merged** — two eras given separately in all three matrices (A1: both O1, stated
  separately; A2: era-split, opposite directions; A0: neither era carries a flag).
- **Walmart's reassignment is compliant with the #11031 rule.** It is argued from the record's own §2
  headline (*"not an object, and it has no identifier"*), Walmart is **named** in the ambiguous list, the
  counter-fact (280 types / 1,711 swatch divergences) is quoted whole, and "moving it back restores
  #11031's 4–4" is stated **twice** (§A2.2 and §A2.8). No platform is silently assigned a side.
- **All eight BRIEF.md §4 sections are present on all three cards** (1 Options · 2 Who uses · 3 Why ·
  4 Our code · 5 Our numbers · 6 Cleanest · 7 Recommendation · 8 Limits), and each card ends with "what it
  forces in steps 1–5".
- **Every card pointer was executed.** A1 ("where each of the thirteen draws the line" → 13 rows;
  "Shopify keeps weight on the variant" → confirmed with a correction on two routes, plus a deliberate
  counter-case). A2 ("what each side pays — duplicated values, two editors, two filter paths" →
  `matrix-A2.md` §(c) and `design-A2.md` §5, from the records' own words). A0 (all four: Square 10+10;
  Shopify metafield storefront visibility; eBay `aspectUsage`; Magento's three flags — the last
  **closed at source** where the record left it open). No silent gaps found.
- **A2 answers A1 first and derives from it** (§A2 opens on A1's rule; §A1↔§A2 coupling stated), and
  **D3 is stated CONFIRMED on the record with its reason** — "not reopened, but on a different argument
  from the one it was closed on": the declaration tie survives, the 6–4 value-storage lean is the half
  that prices our build. Its A4 dependency and the conditional reopen are stated explicitly.
- **V1 and V2 both have explicit dispositions** (V1 confirmed; V2 re-expressed per #11031). V4/V5 and C8
  are also dispositioned. (C5 is the failure — finding 2.)
- **The A0↔A5 answer is stated in a form FAMILY can cite**: *"the level a fact lives at is A5's question,
  the channels it is shown on is A0's, and a design that makes visibility depend on level has no precedent
  in the thirteen"* — with two platform cites carrying both fields as independent fields of one definition
  row (commercetools `AttributeDefinition.level` + `isSearchable`; Shopify `MetafieldDefinition.ownerType`
  + `access`/`capabilities`), and a named absence. Both cites verify in the records.
- **design-A1.md and design-A2.md genuinely test the options on our models** rather than asserting:
  write path, staff editor, search, feed, migration shape, and which invariants survive as Postgres
  constraints are each worked with real cites. `design-A1.md` §0's "four homes, not two" and §5's four
  named defects in the definition/value split, and `design-A2.md` §1.5's constraint table and §3's
  shape-1b note, are the strongest parts of the brief.
- **Judgements are labelled throughout**, and the brief keeps its own refuted claim visible in §A1.7/§A1.8
  rather than smoothing it — which is how the WooCommerce/Akeneo brand-entity correction was found.
