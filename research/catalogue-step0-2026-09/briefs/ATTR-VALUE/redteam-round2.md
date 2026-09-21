# ATTR-VALUE — red-team round 2 (final)

**Author:** adversarial reviewer (did not write the brief; wrote `redteam-round1.md`). **Date:** 2026-09-19.
**Method:** fixes verified by re-doing, not by reading the corrections lists. All ten bounded SQL files re-run
against `solvent-staging` and diffed against the saved results; all four corpus scripts re-run and diffed,
including the new `indomie_vs_shopify_flavor.py`; the unbounded `size-families` run separately to test the
drift claim; the new `live_taxonomy_attributes_3categories.json` parsed; every corrected `path:line` re-opened
at the pins; every corrected record cite re-taken with its enclosing heading resolved; both tallies re-derived
by hand; both design files re-read.

**Counts: 0 BLOCKING · 5 SERIOUS · 4 MINOR.**

Every round-1 finding is genuinely fixed at root — including all four BLOCKING ones, which are fixed with the
evidence they were missing rather than by softening the claim. What remains is a set of **residues of the
fixes**: three places where a correction was applied in one location and not in its twin, one locator that
repeats the exact error round 1 raised, and one tally that no longer sums. Nothing here changes either
recommendation.

---

## SERIOUS

### 1. A3 §7's confidence clause is contradicted by its own corrected paragraph, and neither confidence was revisited — SERIOUS

**What is wrong.** `ATTR-VALUE.md:152` still reads: *"Confidence: **high** on (a) over (b) — **TREE's measurement
(below) removed the only reopen trigger I had for it**."* Twelve lines below, the R1-15 fix retracts exactly
that: weight 1 (`:154`) now says *"**I now hold the inferred route as pending, not as support**"*, and reopen
trigger (iv) (`:164`) is *"**downgraded to pending** … the inferred route cannot currently discharge this
trigger."* So the single stated reason for "high" has been withdrawn in the same section while the level is
unchanged, and §8 repeats the withdrawal a third time.

The same applies, more weakly, to A4: `:473` still reads *"Confidence: **high** on (c)+(A)"* after §7 reason 1
grew from *"a two-line change"* to *"one table, one column, one enum entry, one validator method, one
type-alias member, one API field and one formly type, plus `_option_as_text`"*. Neither per-card "Corrections
after red-team round 1" list records a confidence review at all.

**Why it matters.** BRIEF §4 makes confidence one of the five required elements of §7. A confidence whose
justification the same section retracts is not a judgement a reader can weigh — and the retraction is the
*only* thing either card says about why (a) beats (b) with high confidence. (A4's "high" is defensible on the
brief's own argument that the larger bill is still additive and reversible; A3's is not, as written.)

**Fix.** Either restate A3's confidence with a reason that survives — the measured route alone (`net_content`
617 nodes, `colour` 494, `flavour` 199) is a perfectly good one — or lower it and say so. Add one line to each
corrections list recording whether the confidence was reviewed and why it did or did not move.

---

### 2. The R1-15 fix reached weight 1, trigger (iv) and §8, but not reopen trigger (i) or §5 — SERIOUS

**What is wrong.** Reopen trigger **(i)** (`ATTR-VALUE.md:164`) still declares itself discharged on the route the
brief now holds pending: *"— **closed in the opposite direction**: **both** of TREE's routes return a heavily
reused head (`net_content` 617 nodes, `colour` 494; **`Warna` 235 of 395 mapped**), so (b) cannot win on
overlap"*. `Warna` 235 of 395 is the inferred route, and trigger (iv) — the next clause but one in the same
sentence — says that route *"cannot currently discharge this trigger"*.

And A3 §5's TREE row (`:132`) still reports the inferred figures as a plain measurement with **no** pending
flag: *"Inferred route (Shopify's taxonomy mapped onto our nodes): 715 distinct names over the 395 nodes it
reaches (23.4%), 290 distinct sets, median 8 per node"*. §5 is the section the BRIEF designates for numbers; a
reader who takes figures from it gets no warning that §7 and §8 have withdrawn them.

**Why it matters.** R1-15 was about not resting on TREE's inferred route while its over-mapping rate is
unstated. One of the three reopen triggers and the numbers table still do, so the correction reads as applied
when it is applied in two of four places.

**Fix.** Mark the §5 row "inferred route — pending TREE's over-mapping rate (finding R1-15)", and restate
trigger (i) on the measured route alone (it closes on that route by itself: eight kinds over 1,686 nodes with
`net_content` on 617 is already the opposite of "near-zero overlap").

---

### 3. The Google row's new locators repeat the R1-5 error — wrong line range and wrong section — SERIOUS

**What is wrong.** The R1-1 fix is real: every word the Google row now quotes is genuinely in `11013.md`, and I
re-opened all of it. The locators are not.

- The brief cites *"#11013 §1.3 (the layer table at `11013.md:145–151`)"*. The layer table is at
  **`11013.md:139–145`** — `139` header, `141` typed attributes, `142` `ProductDetail`, `143` `CustomAttribute`,
  `144` `CloudExportAdditionalProperties`, `145` `VariantOption`. The cited range starts at the table's **last**
  row and then runs into `:147` (the G7-b note) and `:149–151`, which are the **enum** table. Three of the four
  rows the brief quotes — *"free-form `sectionName` + `attributeName` + `attributeValue` (140/140/1000 chars)"*
  (:142), *"free-form `name` + `value`, max 2500 per product"* (:143) and *"fixed by the schema; some are
  enums"* (:141) — fall outside the range given for them.
- The brief cites *"§1.5 via `11013.md:482`"*. `:482` is correct for *"`variant_option.name` is free text ≤250
  chars with no published enumeration"*, but it sits under `### ❓ Can flavour be a variant axis? Not
  established either way.` (`:480`) inside **§3 · The flavour test** (`:435`). §1.5 is at `:192`.

**Why it matters.** This is the same class of defect as R1-5, introduced by the fix for R1-1, and it falsifies
the brief's own §8 assurance that after round 1 *"the check was re-run across all §2 rows of both cards and
**every enclosing heading re-resolved**"* — the one row rewritten in this round is the one whose heading was
not re-resolved.

**Fix.** Cite `#11013 §1.3` (`11013.md:139–145`) for the layer table and `#11013 §3` (`:482`) for the
`variant_option.name` sentence.

---

### 4. A4 §2a's held-out tally does not sum — SERIOUS

**What is wrong.** `ATTR-VALUE.md:239`: *"Holding out the three named-ambiguous rows (commercetools, Salesforce,
Amazon), **the unambiguous eleven** read: shared row **2** · copied **3** · hybrid **6 (7 split)**."*

Re-derived by hand from the table above it: holding out commercetools, Salesforce and Amazon leaves
**10 platforms / 11 rows**. Shared row = Magento, Square = 2 ✓. Copied = eBay, Google, Walmart = 3 ✓. Hybrid =
Shopify, Shopee, WooCommerce, Tokopedia, Akeneo = **5 platforms**, i.e. **6 rows** with Tokopedia split. So
"6 (7 split)" is impossible on either reading: 2 + 3 + 7 = **12**, not the eleven the sentence names, and 6 is
already the split count. (The full-tally sentence immediately before it is right: 2 + 4 + 6 + 1 = 13 platforms,
2 + 4 + 7 + 1 = 14 rows.)

**Why it matters.** This is the sentence the R1-10 fix added, in the who-uses matrix the BRIEF makes the
centrepiece; a reader checking the arithmetic of the "both readings" tally gets 12 against a stated 11.

**Fix.** "hybrid **5 (6 split)**" — and the conclusion is unchanged: hybrid is still modal on either reading.

---

### 5. The V4 bullet still carries the label the fix reversed — SERIOUS

**What is wrong.** `ATTR-VALUE.md:493` still heads the bullet *"V4's evidence that 'every surveyed system
hand-orders picker values with a position column' — **RE-EXPRESSED, and narrowed**."* Its own body, after the
R1-2 fix, now ends: *"commercetools therefore joins Square, Akeneo, Magento and WooCommerce as a system that
hand-orders a shared value list, which **strengthens V4's evidence rather than narrowing it**."* The narrowing
rested on two witnesses failing; one has been restored, so what remains is a re-expression of what Shopify's
`productOptionsReorder` orders, not a narrowing of the survey.

**Why it matters.** The V4-vs-matrix resolution is the deliverable the BRIEF's errata specifically assigns to
A4, and its bullet headings are what a reader skims for the disposition. "Narrowed" is now the opposite of the
bullet's conclusion. (The withdrawal itself is clean — `grep` for "do not build derived" returns **0** hits, and
V6 is restored whole.)

**Fix.** Retitle the bullet "RE-EXPRESSED, and on one witness only", or "RE-EXPRESSED; its evidence base is
unchanged in size".

---

## MINOR

### 6. R1-24 was applied to one of the two copies of the WooCommerce quote — MINOR

`ATTR-VALUE.md:78` (A3 §3) now reads *"so they**’**re easy to update across the entire store"* with the line
cites `11080.md:338`, `:629` and a note that the typographic apostrophe is what defeats a plain `grep -F` ✓.
`ATTR-VALUE.md:289` (A4 §3) prints the same vendor sentence with a **straight** apostrophe and a bare
`(#11080 §1.4)`. Same record, same quote, one corrected. Apply the same fix to `:289`.

### 7. A3 §2's headline still leads with the un-held-out margin — MINOR

`:47` opens *"**Split, not unanimous: 6 (a) · 3 (b) · 0 pure (c) · 3 (d) · 2 ambiguous.**"* The honest reading
the R1-9 fix added — 4–3 with four named ambiguous, which the brief itself calls *"the honest margin"* — arrives
twenty lines later, and §7 weight 2 leads with 4–3. BRIEF §4 asks for the split to be stated first. Put both in
the headline, as §7 weight 2 already does.

### 8. `evidence-A4-records.md` is 2,225 lines, not the 2,224 the brief states twice — MINOR

`wc -l` = **2,225** (byte count 340,343 ✓, md5 `5a5bf571dc6a3ca13f6c55d979c7a885`). The figure appears at `:533`
and in the §8 provenance bullet. Carried since the first revision; I missed it in round 1. (The file's mtime is
unchanged from before round 1, so it was not edited this round — correctly, since no round-1 finding required
editing it; the coordinator's summary saying it was updated does not match the file.)

### 9. My own round-1 count line was wrong, and the ledger inherited it — MINOR (mine, recorded so the ledger is right)

`redteam-round1.md:12` says *"4 BLOCKING · 13 SERIOUS · 9 MINOR"* = 26. The file actually carries **28** numbered
findings: 1–4 BLOCKING, 5–17 SERIOUS (13), **18–28 MINOR (11)**, with 28 split into 28a/28b. The "all 26" in the
hand-off is my arithmetic, not the author's. **I re-checked the union of the two per-card correction lists and
all 28 are addressed** — A3's list carries R1-3, 9, 11, 14, 15, 17, 18, 19, 24, 25, 27, 28a, 28b; A4's carries
R1-1, 2, 4, 5, 6, 7, 8, 10, 12, 13, 14, 16, 20, 21, 22, 23, 26. Nothing was skipped.

---

## Verified fixed, by round-1 finding number

**R1-1 (BLOCKING) — fixed at root.** The Google row is re-quoted from the record. I confirmed the four open
layers and the typed layer are verbatim at `11013.md:141–143`, `:145`, and the axis sentence at `:482`; the
miner's phrases (`scalar written onto`, `never an FK`, `hybrid between closed enums`) are gone from the row.
The tally now reads *"thirteen of thirteen; there is no disagreement"* and the struck claim is visible beside
it; Google is removed from the named-ambiguous list. (Locators only — finding 3 above.)

**R1-2 (BLOCKING) — fixed, and over-fixed in the right direction.** I re-opened all three:
`F1-suggestion-provenance.md:516–524` carries eBay's own *"eBay determines the popularity of a name or value
based on several factors, such as the number of recent listings and/or recently sold listings in the same
category…"*; `F2-axis-value-shape.md:319–328` carries the `changePlainEnumValueOrder` RAML with its upstream
URL, and `corpus/commercetools/repo/api-specs/api/types/product-type/updates/ProductTypeChangePlainEnumValueOrderAction.raml`
is in the brief's own corpus; `F1-suggestion-provenance.md:250–268` re-fetches Magento's
`Validator.php:128-144`. The withdrawn recommendation is gone (`grep "do not build derived"` → **0**), V6 is
restored whole, and commercetools is restored as a V4 witness that *strengthens* V4. The §8 bullet now names
the corpus and says plainly *"I did not open it; that is the single worst defect in the first revision"*.

**R1-3 (BLOCKING) — fixed at root with new collection.** `corpus/shopify-values/live_taxonomy_attributes_3categories.json`
(3,492 B) parsed: `aa-1-13-8` T-Shirts **15** attributes, `hg-5-2` Fireplace & Wood Stove Grates **6**,
`ap-2-3-6-1` Dog Pens **4** — and `gid://shopify/TaxonomyAttribute/1` present on **all three**, exactly as §5
now states. The claim finally has the evidence it always asserted.

**R1-4 (BLOCKING) — fixed and re-costed.** §4 now enumerates all three `getattr`-by-type dispatches and I
re-opened each at the pin: `_get_value` `models.py:749-751`, `value_as_text` `:775-776` (with default),
`validate_value` `:684-686` (**no** default, six `_validate_*` at `:690-716`). `types.py:3-5` is the closed
`Literal` ✓ and `ProductAttribute.clean()` is at `:660-662` ✓ (both cites exact). §7 reason 1, the per-option
table and `design-A4.md` §0/§1/§6 all carry the seven-item bill; `design-A4.md:76-77` names
`_validate_option` and the `Literal` member in the schema sketch.

**R1-5 (SERIOUS) — fixed.** Re-taken at the pin with headings resolved: Magento **§1.7** (`11082.md:379`) ✓,
WooCommerce **§1.5** (`11080.md:372`) and **§1.6** (`:394`) ✓, Walmart **§2** (`11046.md:374`) and **§2b**
(`:405`) ✓, Tokopedia Era A §1.2 (`11048.md:139-140`) and **§3** (`:487`) ✓. I confirm `#11046` has no §3.1 —
its only §3 heading is `## §3 · The flavour test` at `:464`.

**R1-6 (SERIOUS) — fixed.** §6.4 now attributes the sentence to `catalogue-next-steps-v7.txt:269`, calls it the
card restating itself rather than corroboration, and quotes the matrix's actual `:2153` line — which I
re-opened and which indeed says *"normalisation come free"* and never mentions the variant key.

**R1-7 (SERIOUS) — fixed.** §2c Correction 3 splits the eras from #11048: Era A bare-nothing, Era B typed
quantity + unit with the unit-price formula, and Correction 2 is explicitly scoped to Era B. The matrix's
merged cell is flagged in the table itself.

**R1-8 (SERIOUS) — fixed.** Re-derived: 4 + 2 + 3 + 3 + 1 + 1 = **14** ✓, and the "two largest groups at 4 and
6" checks out (3 + 3 = 6). The 3·8·1·1 version is struck in place.

**R1-9 (SERIOUS) — fixed.** §2 gives the tally both ways and both sum to 14: 6+3+0+3+2 and 4+3+0+3+4. Weight 2
is restated to *"4–3 among the unambiguous platforms (6–3 counting the two hedged rows)"*, and §8's *"I did not
force it into one cell"* is struck as untrue of the first revision. (Headline ordering — finding 7 above.)

**R1-10 (SERIOUS) — fixed.** Named-ambiguous is now three (commercetools, Salesforce, Amazon), Google removed
with the reason, and the tally is given both ways. (Arithmetic of the held-out line — finding 4 above.)

**R1-11 (SERIOUS) — fixed.** All four admin surfaces are in §4 and re-opened by me: `ProductAttributeAdmin`
`admin.py:51-53`/`:67`, `ProductAttributeInline` `:27-29` on `ProductClassAdmin` `:32-34`, `AttributeInline`
`:18-19` on `ProductAdmin` `:46`, `ProductAttributeValueAdmin` `:56-57`/`:68`. The brief now says outright that
*"no `ProductAttribute` UI exists"* is true of the staff app and **false of Django admin**, and
`design-A3.md:84` makes the schema inline the most affected surface in that card.

**R1-12 (SERIOUS) — fixed.** `initiate_attributes()` re-opened at `product_attributes.py:21-25` — exactly
`values = self.get_values().select_related("attribute")` then `setattr(self, v.attribute.code, v.value)` — and
`get_values()` at `:54-55`; both cited, with `staff_serializers.py:68` as the first statement of
`_assign_attributes`. §4's heading now reads *"The write path is four call sites, not two"*.

**R1-13 (SERIOUS) — fixed.** `Product.attribute_summary` `models.py:520-525` → `summary()` `:763-766` →
`value_as_text`, in `ProductAdmin.list_display` (`admin.py:43`) and asserted at `product_models_test.py:125`,
with the "inherits free **only** once `_option_as_text` exists" condition attached.

**R1-14 (SERIOUS) — fixed in both cards.** The fan-out is in A3 §4, A4 §4, `design-A3.md:86` and
`design-A4.md:201`, with the `models.py:489` vs `:490` ordering, `receivers.py:31-41` →
`index_utils.py:11-16` enqueuing **both** Haystack and Google Merchant, and the absent `ProductAttributeValue`
signal — all of which I re-opened and confirm.

**R1-15 (SERIOUS) — partly fixed.** Weight 1 rests on the measured route alone, the `~4.4` figure is withdrawn,
trigger (iv) is downgraded to pending, and §8 says the over-mapping limit is not among TREE's stated limits.
(Trigger (i) and §5 — finding 2 above.)

**R1-16 (SERIOUS) — fixed.** *"every §2 quote"* is struck; the bullet now says six load-bearing strings were
spot-checked and names the row that failed.

**R1-17 (SERIOUS) — fixed.** Square's vendor sentence is cited to `corpus/square/add-custom-attributes.html:57`
and to `#11049` §Retrievals `[R-11]` (`11049.md:1082`), with the note that the second quote is correctly §3
(`:750`) — both of which I re-opened.

**R1-18 (MINOR) — fixed.** §4 now names the package path `catalogue/search_indexes_mixins.py:22` with
`prepare_category` at `:27-29`, and states the field is declared **twice** (the `ProductIndex` re-declaration at
`search/search_indexes.py:65`).

**R1-19 (MINOR) — fixed.** "~4.4 nodes per name" struck in place with the median-as-mean reason.

**R1-20 (MINOR) — fixed.** `corpus-analysis/indomie_vs_shopify_flavor.py` written; I ran it and it reproduces
`indomie_vs_shopify_flavor.out` **byte-identically** (43 phrases, 73 tokens, 0 hits against the 30-value list).

**R1-21 (MINOR) — fixed.** §6.2 now states the limit: `Title`/`Default Title` is Shopify's synthetic default, so
the measurement shows the default row is per-product, not that two merchant-authored values get distinct ids.

**R1-22 (MINOR) — fixed.** `size-families.sql` uses `MIN(d.dimension)`; `manufacturer-case-drift.sql:9` gained
`ORDER BY rows_affected DESC, folded`. Consecutive re-runs are byte-identical.

**R1-23 (MINOR) — fixed.** `results/manufacturer-top-and-tail.csv` now matches its query name.

**R1-25 (MINOR) — fixed.** §5 now says the corpus row *"matches both figures the card gives"* with the card's
line cite, and that the category count is the author's.

**R1-26 (MINOR) — fixed.** §6.3 prints both locales, `en` 7,715 and `id-ID` 7,544 of 8,240 — which is what my
re-run of `shopify_order_and_names.py` returns.

**R1-27 (MINOR) — fixed.** §4 separates the global read (`staff_views.py:66-67`) from the read through the
product's FK (`staff_serializers.py:70-72`), and says why the distinction is the one §4 is drawing.

**R1-28a/b (MINOR) — fixed.** Shopee's U-8 is cited to §4 (`11047.md:535`) ✓ — I re-resolved the heading — and
§7 names TREE's B4 heading *"What flows down from parent to child, per kind of fact"* for the A3↔B4 coupling.

**Systemic (snapshot binding) — applied, and the claim is true.** All ten queries carry
`WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside every
dedup subquery. **All ten re-run byte-identical to their saved results.** I tested the drift claim directly by
stripping the bound from `size-families.sql` and re-running: **unbounded now returns 1,994 families / 4,595
products**, bounded returns **1,993 / 4,593** — exactly as the note in A4's corrections list states. Derived
figures from the bounded result recompute to the last digit: **1,993 / 4,593 / 1,211 (60.8%) correct /
782 (39.2%) wrong / 78 mixed-dimension / 399 distinct labels**, histogram 1582-301-74-21-9-4-2; and
`manufacturer-vocabulary` (46,499 / 5,580 / 5,580 / 5,541 / 5,489 / 4,421; 31 letterless values over 15,516
rows), `quantity-vocabulary` (23,986 / 886 / 573 / 214 / 275 / 0 unparseable), `value-column-hygiene`
(471,143 rows, 0 zero / 0 multi / 0 wrong-column) and the by-unit breakout summing to **30,417** all stand.
The other three corpus scripts (`shopify_attr_reuse`, `shopify_flavor_values`, `shopify_order_and_names`) also
re-run byte-identical, regenerated `shopify-flavor-categories.txt` included.
