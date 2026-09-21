# redteam-round2.md — final adversarial review of ATTR-DEF (A1 · A2 · A0)

Round 2 of 2. Every round-1 finding re-checked **by doing**, not by reading the corrections list: both
pins re-opened, all four bounded SQL files re-run, the two ordering mechanisms re-traced, the `both`
instrument and both tallies re-counted, the new `matrix-A2.md` §(d) re-derived from #11031's D5 row, the
fan-out block and the 8 read sites re-opened.

**Counts: 0 BLOCKING · 4 SERIOUS · 5 MINOR.**

All three round-1 BLOCKING findings are genuinely fixed. What remains is one count error introduced by a
fix, two "fixed" entries whose substance did not land, one claim about our own code that survived both
rounds, and five cosmetic or single-location leftovers.

---

## SERIOUS

### 1 · §A0.2's new named-hedge list says "five of the ten" twice and names **six** — the same failure class as round-1 finding 6, introduced by the fix for round-1 finding 7
**What is wrong.** `ATTR-DEF.md:933` opens *"**Named ambiguous / hedged rows — five of the ten** carry a
qualification"*, then names, all in the same bolded run: **Square** · **Magento** · **Akeneo ·
WooCommerce · commercetools** · **Walmart** — **six**. `:947` closes *"**So the 10 is 5 unhedged + 5
qualified.**"* With six qualified, the unhedged count is **4**, not 5.

The corrections list at `:1221` shows the author's intent — *"five of the ten (Square, Magento, Akeneo,
WooCommerce, commercetools — **plus** Walmart's purpose-vs-visibility caveat)"* — i.e. Walmart was meant
to sit outside the five. But §2 bolds it inside the run with no separator and then asserts 5 + 5.

**Where.** `ATTR-DEF.md` §A0.2, lines 933 and 947 (and the corrections entry at :1221).
`matrix-A0.md`'s own hedge list names the same six and, correctly, **claims no number** — so the side file
is right and the brief is wrong.

**Why it matters.** This is the tally the brief calls *"the strongest signal in this card"* and takes
**high** confidence on, and the sentence exists precisely to show the reader how much of the 10 is
qualified. A published count that contradicts its own list one line later is the exact defect round-1
finding 6 flagged in `matrix-A0.md`'s V2 row; the fix for finding 7 reintroduced it in the main brief.

**Fix.** Either *"**six** of the ten carry a qualification … So the 10 is **4 unhedged + 6 qualified**"*,
or keep Walmart separate explicitly: *"five carry an evidence-quality hedge; Walmart carries a different
one — its control is a **purpose** tier, not a visibility flag — so the 10 is 4 unhedged + 5 hedged + 1
reclassified."*

---

### 2 · Round-1 finding 14 is marked "fixed … added to §4", but the `Product.attributes` M2M is nowhere in `ATTR-DEF.md`
**What is wrong.** The corrections entry (`ATTR-DEF.md:563`) reads: *"**14 — fixed.** `Product.attributes`
M2M through-model **and** `ProductClass.default()` = `objects.get()` with its two call sites … **added to
§4**."* The `ProductClass` half genuinely landed — §A1.4 now carries a *Definition endpoint queryset* row
citing `staff_views.py:67`; `models.py:88-90`. The **M2M half did not**:

- `grep -n "M2M\|ManyToMany\|through=" ATTR-DEF.md` → the only hit is the corrections line itself (:563).
  `ManyToManyField` appears **zero** times in the whole brief.
- The only mentions anywhere are the two that were already there at round 1: `design-A1.md:16` (a
  parenthetical inside the "four homes" table) and `design-A1.md:320-321` ("joined to `Product` twice").
- §A1.6 still does not price it.

**Why it matters.** My round-1 point was precisely that *neither §A1.4 nor §A1.6 prices it*.
`ProductAttributeValue` is a **declared** `through=` model (`py/mono/solvent/catalogue/models.py:419-422`,
re-opened at the pin), so option 2's "rebuild the value table with locale/scope selectors" and option 4's
`storage` discriminator both mutate a live M2M declaration on `Product` — a migration surface neither
option's cost line mentions. A false "fixed" is worse than an open finding: a reader auditing the round-1
list ticks it off.

**Fix.** Add a §A1.4 row (`models.py:419-422` — `Product.attributes = ManyToManyField(ProductAttribute,
through="ProductAttributeValue")`) and one clause in §A1.6 under options 2 and 4 saying the M2M
declaration moves with the value table. Or correct the entry to "**partially fixed**".

---

### 3 · "The definition's `name` is dead" is false — `name` has four live Django-admin render paths
**What is wrong.** `design-A1.md` §5, defect 1 (line 323): *"**The definition's `name` is dead.** All five
definitions have `name != code` …, and no API exposes `name` (`serializers.py:164-176`). The label the
user sees comes from the frontend bundle."* The API clause is correct and verified. "Dead" is not.
Re-opened at the pin, `ProductAttribute.name` is read and rendered on four paths, none cited:

1. `ProductAttributeValue.summary()` — `return "%s: %s" % (self.attribute.name, self.value_as_text)`
   (`models.py:763-766`).
2. `Product.attribute_summary` — *"Return a string of all of a product's attributes."* — iterates
   `self.attribute_values.all()` and joins `attribute.summary()` (`models.py:520-525`); it is registered in
   `ProductAdmin.list_display` (`catalogue/admin.py:43`), so it renders on **every row** of the admin
   product list.
3. `ProductAttributeAdmin.list_display = ("name", "code", "product_class", "type")` (`admin.py:52`).
4. `ProductAttributeValue.__str__` returns `summary()` (`models.py:760-761`), so `name` renders on every
   `ProductAttributeValueAdmin` row and in every `AttributeInline` row (`admin.py:18-19`, attached to
   `ProductAdmin` at `:46`).

**Where.** `design-A1.md` §5 defect 1; it underpins §A1.7's repair list ("the display `name` actually
served by the API (it is not today)" — that phrasing is API-scoped and fine, but it rests on "dead").

**Why it matters.** It is a wrong claim about our own code that survived both rounds, and correcting it
**helps** the brief: `name` is already the label of record in the one editor that exists, so option 4's
"the definition carries `name` and `unit`; the bundle becomes an override" is a smaller change than the
brief claims, and the `UNIQUE`/immutability repairs matter more because admin already surfaces `name`.
It also matters for A0: the staff-facing label exists today and is served by Django admin, not by the
staff app.

**Fix.** Replace "dead" with "**served to no API client, and read only by Django admin**", cite
`models.py:763-766`, `models.py:520-525`, `admin.py:43,52`, and carry the correction into §A1.7's repair.

---

### 4 · Round-1 finding 22 is marked "fixed — §4's table no longer claims false exhaustiveness", but the header still says "exhaustively", now spans the frontend, and still misses two readers
**What is wrong.** Three separate problems, against an entry (`ATTR-DEF.md:576`) that claims the issue is
closed:

- **The header is unchanged.** `ATTR-DEF.md:255` still reads *"**Every reader of an attribute value in the
  backend, exhaustively:**"*. The three rows that were added (Validation, Write fan-out, Write serializer)
  are correct and verified — but the claim the finding objected to was the word, and the word is still
  there.
- **The header is now doubly wrong.** The table gained three rows that are not backend:
  *Definition permission* (which cites `ts/libs/shared/permission/util-core/src/lib/permission.model.ts:43`),
  *Frontend definition client* (`product-attributes-stream.service.ts:24,33`), and the frontend consumers.
  A table headed "in the backend" now carries frontend cites.
- **Two backend readers are still missing**, both found by re-grepping at the pin:
  `Product.attribute_summary` (`models.py:520-525`, rendered via `ProductAdmin.list_display`,
  `admin.py:43`) — the **only backend consumer of `ProductAttribute.name`**, and the subject of finding 3
  above — and the `AttributeInline` on `ProductAdmin` (`admin.py:18-19`, attached at `:46`), which is a
  live **write** surface for attribute *values* that the "Django admin" row does not name (it names only
  the three registered ModelAdmins).

**Fix.** Retitle the table *"Every reader and writer of an attribute value or definition, both stacks"*,
add the two admin rows, and downgrade the corrections entry to "partially fixed".

---

## MINOR

### 5 · Round-1 finding 17 was fixed in the corpus table only; the sentence that does the work is unchanged
`ATTR-DEF.md:1284` (corpus table) now correctly reads *"the three `.html` bodies differ (md5 …)"*. But
`ATTR-DEF.md:977`, in §A0.2's Square card-pointer bullet — the sentence that **dismisses the API-limits
404 as evidence** — still reads *"the API-limits URL returns a **generic** 404 (**md5-identical to two
other 404s**, so it proves nothing)"*. Re-measured at the pin: the three `.404.html` bodies are
`88b507dd…`/90,932 B, `419a8951…`/91,022 B, `6e3d8ee6…`/90,956 B — three different md5s; only the three
`.404.txt` extracts are identical (`f3cdc223…`, 830 B each). *Fix:* apply the same correction at :977.

### 6 · Round-1 finding 21 was fixed in `ATTR-DEF.md` only; `rationale.md` still says "Magento 22"
`ATTR-DEF.md` is now consistent — §A0.2's table says *"Magento (**24 columns** on the merged
`catalog_eav_attribute`, ~18 of them behaviour flags)"* and §A0.3's inference says *"Magento **24**"*. But
`rationale.md:175` carries **the same inference sentence** and still reads *"the platforms with the richest
per-attribute flag sets (**Magento 22**, eBay 11, Shopify ~8)"*. The corrections entry claims the count is
"stated with its scope **at every point of use**". *Fix:* harmonise `rationale.md:175` to 24.

### 7 · `matrix-A2.md`'s Tallies run (a) · (b) · **(d)** · (c)
The new D5 derivation was inserted at line 414, **before** §(c) at line 434. `ATTR-DEF.md` §A2.2 points
readers at *"`matrix-A2.md` §(c)"* for the card pointer, which now sits last. *Fix:* move §(d) after §(c),
or renumber.

### 8 · The length note is stale
`ATTR-DEF.md:1313` still says *"this one runs ~23K per card"*. The file was 85,156 B at round 1 and is
**109,762 B** now — the round-1 fixes added 24,606 B. Net of the header, the corpus table and the three
corrections blocks, the cards run roughly **33K each**. The note's argument (nothing of substance dropped
for length) is unaffected; the number is. *Fix:* restate the figure.

### 9 · Two new frontend cites point at the symbol line rather than the call
`ATTR-DEF.md:271` and `:336` cite the `ProductAttributesStreamService` consumers as
`product-new.component.ts:36` and `product-update.component.ts:48`. Those are the lines carrying the
injected **symbol**; the `inject(` calls are at `:35` and `:47` respectively (the round-1 note gave the
latter). Harmless — a reader lands one line into the right statement.

---

## Verified fixed — by round-1 finding number

Each confirmed by re-opening the code, re-running the query, or re-counting the record; not by reading the
corrections list.

- **1 (BLOCKING) — FIXED.** Re-traced both mechanisms at the pin.
  `grep -rn "ProductAttributeOrderingService\|sortProductAttributes" --include=*.ts ts/` → three files
  (`data-access/src/index.ts:3`, `product-attributes-stream.service.ts:9,21,33`, the service's own file);
  the spec-sheet component injects neither. §A1.4 now carries a two-row table separating **customer spec
  sheet → backend `sorted(…, key=attribute.code)` (`serializers.py:219-221`)** from **staff form →
  `product-attribute-ordering.service.ts:9-15` applied at `product-attributes-stream.service.ts:33`**, and
  states "the spec-sheet component never injects it". §A0.6 now reads "one frontend array **and** one
  backend `sorted()` **and** the i18n key-set"; §A0.7 sells `display_order` on replacing **both** orderings
  on **both** stacks. Both mechanisms are priced as two.
- **2 (BLOCKING) — FIXED.** §A2.7 now files **V1 re-expressed** (not confirmed) and
  **C5 ~~confirmed for names~~ → AT RISK under Lock 1, REFERRED TO A3**, with the contradiction named in
  full and the struck text left visible. "A2 claims neither a confirmation nor a supersession of C5 —
  ATTR-VALUE owns A3." No contradiction remains in the paragraph.
- **3 (BLOCKING) — FIXED, consistently in all three places.** §A1.1 (`:57-65`) struck *"~~Condition 2 as
  written…~~"* and states *"**RE-EXPRESSES condition 2**"* with exactly what moves and what stays.
  §A1.5 (`:390-394`) now says *"the attribute **value** corpus is `manufacturer` alone"* with a
  parenthetical that the **definition** corpus stays at five. §A1.7 (`:532-535`) says "confirmed … **and is
  re-expressed, not merely accepted**" and strikes *"~~the only correction option 1 needs~~"*.
- **4 — FIXED.** Re-counted `evidence/issues/11082.md` myself: case-sensitive `\bBoth\b` → **3**
  (lines **688, 765, 943** — the brief names exactly those), case-insensitive whole file → **33**, body
  only (to the first `## Comment`) → **14**. The brief now publishes 3 / 33 / 14 with scopes and withdraws
  19. I re-read all three occurrences: none is a headline, so the correction to #11031 stands.
- **5 — FIXED.** Walmart's ⚠️ Scope correction (*"that is about the **feed** schemas only… `$ref` occurs
  **2** times… 'no shared definition anywhere in the published schemas' would be too broad"*) is now quoted
  in §A1.2 (`:96-98`) and twice in `matrix-A1.md` (`:163`, `:538-539`), and Walmart is filed "no" **on the
  write path**.
- **6 — FIXED.** `matrix-A0.md:515-520`: row 2 is now **5**, "**8 + 5 = 13**" is stated, and the
  non-sequitur note is replaced by an explicit acknowledgement that 4 was an arithmetic error with no
  platform moving rows.
- **7 — list added** (see new finding 1 for its count).
- **8 — FIXED, and the new block is accurate.** Re-opened every cite: `receivers.py:31-41`
  (`product_post_save_update_indexes`) → `index_utils.py:11-16` (`SearchIndexQueue` **and**
  `GoogleProductIndexQueue`); **no `post_save`/`post_delete` receiver on `ProductAttributeValue` anywhere**;
  `super().save()` at `models.py:489` fires the receiver, `self.attr.save()` runs at `:490`;
  `grep -rn "attribute\|attr\." index_utils.py models_mixins.py` → **0 hits**. The cost (a new receiver +
  a save-ordering change) is now priced in §A1.4, §A0.7, §A2.4 and `design-A2.md`, and "zero new write
  code" is scoped to the authoring path and called **a floor under both shapes, not a differentiator**.
- **9 — FIXED.** §A1.4 carries a *Definition permission* row —
  `permissions_required = ["catalogue.view_productattribute"]` (`staff_views.py:64`) mirrored at
  `permission.model.ts:43` — both re-opened and exact; §A0.7 adds the
  `add_`/`change_`/`delete_productattribute` strings condition 1 must create on both stacks.
- **10 — FIXED.** §A1.4 has a *Frontend definition client* row for `ProductAttributesStreamService`
  (`:24`, `:33`) with its two consumers; §A1.4 also states it is "the client that proves the definition
  list already reaches the staff app".
- **11 — FIXED.** Re-measured: **8** production read lines — `biteship.py:60,61,62,90` (`_parse_product`)
  and `basket/models.py:1265,1272,1273,1274` (`line_weight_gram`, `line_dimension_cm`) — in 3 methods
  across 2 files, with the 9th occurrence correctly identified as a docstring at
  `product_attributes.py:10`. §A1.4 strikes "~~6 backend call sites~~" and `design-A1.md` §1.3 and §6's
  table both now read **8**.
- **12 — FIXED, and the new derivation re-checks exactly.** `matrix-A2.md` §(d) rebuilt from #11031's
  P3 · D5 row (`11031.md:999` + its five bullets). I re-derived it independently: the six 2026-09-01
  platforms *"all let the **family choose from the gated set**"* (eBay §1.5 · Walmart §1.4 · Shopee §1.4 ·
  Tokopedia §1.7 · Square §2 step 3 · Salesforce §2b) **+ Magento** (*"the family chooses: a
  `catalog_product_super_attribute` row is scoped to **one parent product**"*) **+ WooCommerce**
  (*"the family chooses, and it is demonstrated live"*) = **8**; **Akeneo** = "the structure imposes" = 1;
  **commercetools** = "neither" = 1; Amazon, Shopify, Google absent from the row = 3. **8 + 1 + 1 + 3 = 13.**
  Akeneo's own ⚠️ *"Classification note — this is a judgement, and the record does not make it"* is carried
  **whole**, with the narrower-reading alternative **9 · 0 · 1** stated. §A2.7 strikes the unsourced
  *"~~6 of the 7~~"* and cites the derivation.
- **13 — FIXED.** `py/mono/solvent/api/shared/views/api_mixins.py:11-22` (full path) in both §A1.4 and
  §A0.4; re-opened — it is `ListAllApiMixin.all`, and the sibling `apiproduct/api_mixins.py:11-22` is
  indeed a different class.
- **14 — PARTIALLY fixed** (see new finding 2). The `ProductClass.default()` half is in §A1.4 and
  re-verified: `models.py:88-90` is `ProductClass.objects.get()`, called at `staff_views.py:67` and
  `staff_serializers.py:118`.
- **15 — FIXED.** Re-ran it: `grep -rln "manufacturer" py/mono/solvent/catalogue/migrations/` → **0 files**;
  only `0011_add_title_staff_field.py` touches `ProductAttribute` rows. §A1.8 now says the definitions are
  **production data, not migration data**, and gives the production audit trail / the introducing issue as
  the real route.
- **16 — FIXED.** `ts/apps/solui/src/app/app-routing.module.ts:23` — path corrected, line re-opened and
  correct.
- **17 — PARTIALLY fixed** (see new finding 5).
- **18 — FIXED.** `getFormlyFieldConfigs` no longer appears in any brief file (only in `redteam-round1.md`
  and the corrections entry); `design-A2.md` §1.3 now names `getProductAttributeFields$`, which exists at
  `product-update-staff-form-ui.component.ts:147`.
- **19 — FIXED.** Now "**four** dead references in **three** places" — re-verified: `internalname` is in
  `product-attribute-ordering.service.ts:9-15`, `product-addendum-attributes-ui.component.ts:34`, and
  `attribute.key.internalname.{name,unit}` in **both** `ts/assets/i18n/product/en.json` and `id.json`.
- **20 — FIXED.** §A1.2 now reads *"Four platforms do, in **two kinds**"* (`:122`) and the pre-revision
  "not established" list names all three — Square, Salesforce **and WooCommerce** (`:118`).
- **21 — PARTIALLY fixed** (see new finding 6). `ATTR-DEF.md` is internally consistent at 24.
- **22 — PARTIALLY fixed** (see new finding 4). The three new rows are correct and were re-opened:
  `models.py:484` → `product_attributes.py:36-52`; `models.py:490` → `product_attributes.py:60-64` →
  `models.py:672-682`; `staff_serializers.py:36-38` (one `CharField(allow_null=True, allow_blank=True)`
  for all six types).
- **23 — FIXED, all five.** `search_indexes.py:93-96` (`design-A1.md:132`) · `products_api.py:188-241`
  (`design-A2.md:149`) · `isStatic()` harmonised to `:794-801` in `ATTR-DEF.md:47` **and**
  `matrix-A1.md:464` · `class-wc-brands.php:275-331` harmonised in `ATTR-DEF.md:132`, `matrix-A1.md:388`
  **and** `design-A1.md:287`. All re-opened at source and correct.
- **24 — FIXED.** *"**0 hits, full stop**"* with "there are no migration hits either" and the one frontend
  reader (`attribute.key.manufacturer.{name,unit}`) named beside it. Re-ran the grep: 0 hits.
- **25 — FIXED.** The corpus table (`:1291`) now lists `Internal-Brands.php`, `ProductBrandSchema.php`,
  `store-api-product-brands.md` and `doc-woocommerce-brands.txt` with their quotes, and the §A1.2 quotes
  now carry file:line (`doc-woocommerce-brands.txt:42` — re-opened, verbatim).
- **26 — FIXED.** The Amazon quote is restored to the end of its clause in both `ATTR-DEF.md:700` and
  `matrix-A2.md:438`: *"…across all listings **within the variation family**."* Matches `10976.md:14359`.
- **27 — FIXED.** "**five** rows that could move it" in both `ATTR-DEF.md:659` and `matrix-A2.md:396`.
- **28 — FIXED.** `ATTR-DEF.md:473`: "four repairs — **three** at `models.py:608-623` and **one** at
  `serializers.py:164-176`".

### SQL — all four re-run under the new snapshot bound

Each file now carries `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19
10:27:00+00')` **inside every `ROW_NUMBER` dedup subquery** — 3 per file, **12 in total** — which is the
correct placement (it filters rows *before* the window, so the dedup picks the latest row as of the bound).
Re-run 2026-09-19 with `bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv`:

| File | vs saved `results/*.csv` | vs the round-1 unbounded run |
|---|---|---|
| `attribute-definitions.sql` | **identical** | identical |
| `attribute-uses-and-visibility.sql` | **identical** | identical |
| `manufacturer-as-brand.sql` | **identical** | identical |
| `title-facts-vs-attributes.sql` | **identical** | identical |

So the bound is correctly applied **and** changes nothing — which is what §A1.8's note claims, and it now
reproduces independently. Every number in §A1.5 and §A0.5 still re-derives.

### Struck claims

Spot-checked across all three cards: every correction leaves its superseded text visible with `~~…~~`
rather than deleting it — §A1.1's condition-2 wording, §A1.4's "~~6 backend call sites~~", §A1.7's
"~~the only correction option 1 needs~~", §A2.7's "~~C5 confirmed for names~~" and "~~6 of the 7~~",
§A2.8's "~~19 times~~", §A0's ordering correction. The three per-card "Corrections after red-team round 1"
blocks sit inside §8, which is where BRIEF.md §4's shape puts red-team findings and their resolution.
The eight-section shape, the thirteen-row matrices, the card pointers and the A0↔A5 statement are
unchanged from round 1 and still hold.
