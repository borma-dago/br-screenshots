# FAMILY — red-team round 2 (final)

**Reviewer** adversarial agent, did not write the brief · **Date** 2026-09-19 · **Round 2 of 2**
**Pins re-opened** backend `/home/irvan/copilot/py-5` @ `4f99dc01c6` · frontend
`/home/irvan/copilot/ts-layer2` @ `82187a17bd` — both confirmed `HEAD`.
**SQL** all **nine** files re-run against `solvent-staging`, including the new
`fam-a5-indomie-manufacturer.sql` and the two changed files.

**Counts — 0 BLOCKING · 3 SERIOUS · 5 MINOR.**

All four round-1 BLOCKING findings are fixed at the root, verified by re-opening the code and the records
rather than by reading the corrections list. Two of the fixes went further than the finding asked
(`product_lite.txt` is included by **seven** index templates, not the four I found; the C3 "nothing reads a
family" claim is now instrumented in both stacks with a positive control). Every one of the 46 round-1
findings is referenced somewhere in the pack, and every struck claim is shown in strikethrough beside its
correction.

What remains is small and of one kind: **two section-lead sentences still print the tally the section then
withdraws**, and the SQL is not pinned to a timestamp, which I can now demonstrate matters because one
figure has already moved.

---

## SERIOUS

### 1 · SERIOUS — A5 §2's lead sentence still prints the withdrawn tally and the withdrawn plurality claim

**What is wrong.** `FAMILY.md:74`, the first line of A5 §2, still reads:

> **Split, not unanimous — 6 / 1 / 4 / 1, one named ambiguous.** The plurality pins the level on the definition.

Both halves are retracted in the same section. The corrected tally at `:115-122` is **a1 4 / a2 2 / b 1 /
c 4 / d 1 / ambiguous 1**, and `:109-113` says in terms: *"⚠️ **This costs A5-a its plurality, and the brief
accepts that.** … the declared-level count is **4**, level-pegged with (c)'s 4. §7's confidence rationale is
rewritten accordingly and no longer rests on plurality."* §7 at `:326` strikes *"the plurality (6 of 13)"*
outright.

**Where.** `FAMILY.md:74` (A5 §2, lead).

**Why it matters.** BRIEF §4 fixes this sentence's job: *"then the tally per option with a named ambiguous
list … unanimity or split stated first."* It is the line a reader of the synthesis takes as the answer, and
it is the one line in A5 §2 that was not updated. A reader who stops at the bold lead gets exactly the two
statements the section spends thirteen lines withdrawing. It also re-creates the §1-vs-§2 inconsistency that
round-1 finding 8 fixed, in the opposite direction.

**Fix.** Replace with the corrected split, e.g.: *"Split, not unanimous — the level is **declared** on a
definition in 4, **fixed by structure** in 2, per-family in 1, absent in 4, a read-time fallback in 1, with
eBay named ambiguous. No option has a plurality once 'pinned' is split by mechanism."*

### 2 · SERIOUS — C2 §2's lead sentence still prints the pre-correction split and still gives Google the withdrawn classification

**What is wrong.** `FAMILY.md:939`, the first line of C2 §2, still reads:

> **Nobody forbids count as an axis.** Two platforms name it explicitly; **nine** permit it structurally
> without naming it; **one models the multipack as an offer attribute instead**; one was not measured.

Three things below it now say otherwise:
- the corrected tally at `:970-972` is **named 2 · expressible 10 · not collected 1** (findings 21, 22);
- the Google row at `:944` is *"**expressible** — ⚠️ **re-classified from 'ambiguous' after red-team round 1
  (finding 22)**"*, and explicitly says the offer-attribute modelling is *"orthogonal"* — i.e. **as well**,
  not *instead*;
- `:975-977` replaces the flat *"Forbidding it: 0"* with *"no vendor artifact in the thirteen forbids count
  as an axis, **and three platforms restrict axis eligibility** by a mechanism that is not about count"* —
  including Walmart's ten food product types where *"**no** attribute can be"* an axis (`11046.md:501`,
  re-verified).

**Where.** `FAMILY.md:939` (C2 §2, lead).

**Why it matters.** Same as finding 1 — this is the contract's "split stated first" line. It also
mis-states the corrected Google reading in the direction that weakens C2's own case: a record that ran a
counter-search and found *"no artifact stating a closed set found"* (`11013.md:254`, re-verified) is
evidence **for** count-expressibility, which is why the row moved.

**Fix.** Replace with: *"No vendor artifact in the thirteen forbids count as an axis. Two name it
explicitly, ten permit it with no vendor statement either way, one was not measured — and three restrict
axis eligibility by a mechanism that is not about count (eBay per aspect, Walmart per product type, Akeneo
per attribute type)."*

### 3 · SERIOUS (new) — the SQL is not pinned to a timestamp, and one published figure has already drifted

**What is wrong.** `fam-c3-grid.sql` no longer reproduces its saved result. Re-run twice, minutes apart,
both runs agree with each other and disagree with the file:

| Bucket | Saved (`sql/results/fam-c3-grid.csv`, and quoted in C3 §5) | Re-run ×2, 2026-09-19 |
|---|---|---|
| vary on BOTH — a grid candidate | **1,748** | **1,747** |
| vary on net content only | **747** | **748** |
| products inside grid candidates | **8,071** | **8,069** |

`proxy families` is unchanged at 10,090 and the apparel block is unchanged, so no row was added or removed —
one product's title was edited in production between the saved run and now, moving its family from
"varies on both" to "varies on net content only". The other eight queries still reproduce byte-identical, so
this is not a query defect; it is the corpus moving underneath a query that has no time bound.

**Where.** `briefs/FAMILY/sql/fam-c3-grid.sql` (and, structurally, all nine); the figures are quoted in
`FAMILY.md` C3 §5 (*"**1,748 (17.3%)**"*, *"**8,071**"*) and `design-C3.md` §2.

**Why it matters.** Not for the conclusion — one family in 10,090 is 0.01%, C3-a is unaffected, and 17.3%
rounds the same either way. It matters because the brief's header asserts a **snapshot** (*"snapshot
2026-09-19"*) and the red-team contract is "re-run every SQL". The dedup pattern in BRIEF §3.4 takes the
latest row per `id` with **no upper time bound**, so every re-run reads *now*, not the snapshot. Within four
hours a published figure has already moved; a reader re-running these next week will get different numbers
in more places and will not be able to tell drift from error. The same pattern is shared by the three
sibling briefs.

**Fix.** Add one predicate to the dedup CTE —
`AND datastream_metadata.source_timestamp <= TIMESTAMP '2026-09-19 10:27:00 UTC'` (the baseline's own
snapshot instant) — and re-save the results, or state in the header that the figures are as-of first-run and
will drift on re-execution. The first is better: it makes the whole pack reproducible by anyone, at any
later date, which is what the "every number carries the file name and the snapshot date" rule is for.
Meanwhile, update C3 §5 to 1,747 / 748 / 8,069 or annotate the three figures as first-run values.

---

## MINOR

### 4 · MINOR — A5 §7's "what it forces in steps 1–5" does not carry the family-row reindex receiver, though A5's own option table lists it

`FAMILY.md` A5 §4's option table (`:216`) gives A5-a *"**a family-row reindex receiver** shared with C1"* as
required work. A5 §7's "What it forces in steps 1–5" (`:344-355`) covers steps 1–5 without mentioning it.
C1 §7 does carry it, correctly and in full — *"**Step 4 (D10) must additionally specify a family-row reindex
receiver** … plus a family-image trigger"* (`:809-816`). A5 §4 justifies the asymmetry (*"Harmless today,
because no attribute value is indexed — but it is the *same* missing trigger C1 needs"*), so the substance
is right and nothing is lost if both cards land together. But the §7 paragraph is the handoff to steps 1–5,
and a reader taking A5 alone would not see a work item A5's own table declares.
**Fix:** one clause in A5 §7's Step 4 — "and the receiver C1 §7 specifies is shared, not duplicated."

### 5 · MINOR — `search_indexes_mixins.py:39-40` is off by one

`FAMILY.md` C1 §4 and `design-C1.md` §5b cite
`solvent/catalogue/search_indexes_mixins.py:22-29` (correct — `category` at `:22`, `prepare_category` at
`:27-29`) and `:39-40` for the product-FK variant. At the pin `:39` is a blank line; the method is
`:40` (`def _get_main_category`) and `:41` (`return cast(Category, obj.product.main_category)`).
**Fix:** `:40-41`.

### 6 · MINOR — `staff_serializers.py:132-144` overshoots by one line

`FAMILY.md` A5 §4, C1 §4 and the correction note for finding 36 cite `:132-144` for
`ProductUpdateSerializer.update`. At the pin the method is `:132-143` (`:143` is
`return self.clean_and_save(instance)`; `:144` is blank). The companion cite `:98-128` for `create` is
exact. **Fix:** `:132-143`.

### 7 · MINOR — C2 §7's boxed judgement still says "no family link" unqualified, after §6 narrowed it

The §6 re-argument added for round-1 finding 4 is careful and correct: it distinguishes containment from
siblinghood, and lands on *"a banded pack has **no family link to the products it contains**, and **may
itself be a family** if it is sold in several forms"* (`:1104-1106`). The boxed judgement at `:1127-1130`
still reads *"the banded pack is a separate product with **no family link**"* — the pre-narrowing wording,
and the line most likely to be quoted into an issue. **Fix:** carry §6's two qualifiers into the box.

### 8 · MINOR — the Meta CSV sample is malformed, and the new field-by-field parse is right only because the variance sits before the break

Round-1 finding 28's fix states *"exactly three columns vary (`id`, `color`, `size`); nineteen are
single-valued"*. Re-derived with a CSV parser: **correct** — `id`, `color`, `size` vary; the other 19 header
columns are single-valued. But the artifact is internally malformed: the header carries **22** columns while
every data row carries **24** fields, because Meta's own sample repeats the
`sale_price` / `sale_price_effective_date` pair. Positions 0–19 (`id` … `size`) align; `status` and
`inventory` at 20–21 do not — they hold the second price pair, and the real `published` / `200` values sit
in the two unnamed trailing fields. The three varying columns all fall inside the aligned region, so the
claim survives intact. **Fix:** one clause noting the sample is 24 fields against a 22-column header, so a
re-deriver is not surprised — it also strengthens the brief's own point that vendor samples are not
specifications.

---

## Verified fixed — by round-1 finding number

Each was checked by re-opening the cited file at the pin, re-running the query, or grepping the record —
not by reading the corrections list.

**BLOCKING, all four fixed:**

- **1** — the nine title consumers are enumerated in `FAMILY.md` C1 §7 and `design-C1.md` §5, and the fix
  **exceeds** the finding: `grep -rn "product_lite.txt" templates/` returns **seven** includes, not the four
  I reported, and all seven line numbers are exact — `catalogue/product_text.txt:1`,
  `price_purchase/pricepurchaserecord_text.txt:**2**`, `price_purchase/pricepurchase_text.txt:1`,
  `inventory/inventoryfacility_text.txt:1`, `inventory/inventoryrecord_text.txt:1`,
  `forecast/forecastproduct_text.txt:1`, `price_sell/pricesell_text.txt:1`. `order/models.py:556` is
  correctly demoted to a column declaration with `order/creator.py:191` named as the writer;
  `search_indexes.py:93-96`, `price/purchase/search_indexes.py:61, :75-77`, `models.py:405-408` + `:488`
  (slug), `biteship.py:67` and `get_title()`/`get_title_for_staff()` all re-opened and correct.
  *"Composing loses nothing"* is struck; title confidence lowered to low-moderate.
- **2** — the reindex chain is added to `FAMILY.md` A5 §4 and C1 §4, `design-A5.md` §0 and a new
  `design-C1.md` §5b. Re-verified at the pin: `catalogue/receivers.py:31-41` (the `post_save` on `Product`),
  `catalogue/index_utils.py:11-16` and `:19-44` with its docstring quoted verbatim,
  `catalogue/models_mixins.py:6-31`, and exactly three subclasses — `inventory/models.py:19`,
  `inventory/models.py:121`, `price/purchase/models.py:36`. The four `AbstractCategorySearchIndexMixin`
  users are right too: `search/search_indexes.py:21`, `inventory/search_indexes.py:12` and `:28`,
  `price/purchase/search_indexes.py:52`. `receivers.py:44-67` (images) carried. The work item reaches
  C1 §7's "forces in steps 1–5" with the family-image trigger beside it.
- **3** — `11031.md:1263` re-read: the A5 Google row now quotes it **verbatim**, with the *"on the write
  side"* scope and `item_group_title` both restored, and the "no family content row" reading is narrowed
  with the unqualified version explicitly withdrawn. The A5-vs-C1 self-contradiction is gone.
- **4** — the Shopee exclusion is replaced by a real rebuttal. Re-verified: `11047.md:271-281` carries
  `add_kit_item` (2242, 49 request field paths), `update_kit_item` (2247, 51), and
  `component_list[] {component_item_id, component_model_id, quantity, main_component}`; `11047.md:286`'s
  ruling is quoted whole in C2 §2 and answered in §6 on the containment-vs-siblinghood distinction, with
  a stated refutation test and a recorded negative search. The secondary tally is 3 → **4**.

**SERIOUS and MINOR:**

- **5** — eBay's two C1 quotes re-cited to `#11031 §B (11031.md:1192)`; `:1192` re-read and its route is
  indeed *"Inventory guide (Wayback capture of the vendor page) + #11045 §1.4"*. The row's option now says
  *"on the Wayback route only"* and notes `11045.md` §1.4 shows group `title`/`description` as 0..1 optional.
- **6** — the false clause is gone; the row quotes `11045.md:116` whole (*"present on 106,766 of
  197,046"*) and adds **U12-c** (*"one artifact read once"*).
- **7** — tally split into **a1 declared (4)** / **a2 structural (2)** with the reasoning printed; §7's
  confidence rationale rewritten onto shape-match + zero-day-one-cost. *(Lead sentence not updated — round-2
  finding 1.)*
- **8** — the tally now prints *"d as the primary model = 1"* and *"d as a mechanism beside another = 3"*,
  naming all three; §1 and §2 reconciled explicitly.
- **9** — the Google cell is quoted **whole** including *"Optional for all other products and target
  countries"*; `11013.md:691` and `:703` re-read and both carry it. **O-7 is closed** in `sources-new.md`
  with the reason stated.
- **10** — new instrument `sql/fam-a5-indomie-manufacturer.sql`, re-run **byte-identical**: **9** raw
  spellings, **8** after `UPPER()`, **7** after also collapsing whitespace. All nine printed with counts
  (31/3/2/2/1/1/1/1/1 = 43 ✓) and the two case-only variants marked. The note that revision 1's "seven" was
  the whitespace-collapsed figure is correct.
- **11** — `fam-c1-indomie-content.sql` now carries `desc_contains_title_strict` and
  `desc_contains_title_normalised` as columns. Re-run byte-identical: **36** strict, **38** normalised —
  exactly the two counts I derived independently in round 1. The 3 empty rows and the 2 genuine misses
  (id 24104 abbreviated title; id 29219 body `86 GR` vs title `85 GR`) are named.
- **12** — *"The read forks in **two** places"*; `Product.attribute_summary`
  (`catalogue/models.py:521-525`) and `catalogue/admin.py:37-46` re-opened and correct.
- **13** — the Amazon C1 row carries `10976.md:412` (*"Both of Amazon's flavour examples are internally
  defective"*), and states that `[E-25]` alone carries the row.
- **14** — the A5 Amazon row carries `10976.md:418` (*"The seven flat-file `Example` sheets are one
  artifact, not seven"*) — re-read, verbatim — and reduces it to two observations.
- **15** — #11126 is **dropped** from C2 §7's confidence list with `11126.md:69` quoted; confidence lowered
  to moderate-high; §7 and §8 no longer contradict.
- **16 / 33** — `sources-new.md` gains an OPEN-item routing table. **O-6** (GS1 **P1**, no P0 copy
  reachable) now reaches C2 §1 and §8; **O-2** now reaches C1 §8.
- **17** — commercetools and Akeneo re-labelled *"the canonical **documented** shape"*, each carrying its
  record's hedge (`11081.md:913` U1, `11050.md:606` U9).
- **18** — Tokopedia removed from the 3-axis-cap corroboration in **both** C2 §7 and C3 §7, with U1 named
  and the Indonesian text quoted. Cites re-resolved to `11048.md:396` and `:504` — both re-read and correct
  (better than the `:1470` I gave).
- **19** — the 9-name array is labelled the **`Sticky Notes`** instance (`11046.md:210`), replaced at spec
  level by **6,957 types / 2,323 distinct axis names / min-max-mean 1 / 2,323 / 11.75** — re-verified at
  `11046.md:201` — and `11046.md:2765`'s at-scale disagreement is carried, as is the elided *"vary by
  product type and item specification version"*.
- **20** — the Akeneo axis-type quote carries `11069.md` §5 **C3** (*"six vendor statements, three different
  answers"*, re-read at `:939`) and §4 U2.
- **21** — the counter-search is re-run over all thirteen records with the pattern printed: **5 hits in 3
  records**. Walmart's counter-case re-verified at `11046.md:501` (*"ten food product types with no variant
  mechanism at all … **no** attribute can be"*), Akeneo's at `:531`/`:945`, eBay's at `:321`/`:653`.
  *"Forbidding it: 0"* is struck and replaced with the accurate statement.
- **22** — Google re-classified to **expressible**; the eight-item variant list is quoted whole and
  `11013.md:254`'s *"no artifact stating a closed set found"* is carried.
- **23** — the Shopee A5 quote is replaced with `11047.md:423` verbatim plus the vendor text at `:427-429`
  **including** the dropped conditional, re-cited to `#11047 §1.5`.
- **24 / 25** — all five C1 rows re-cited to `#11031 §B` with line numbers (`:1197`, `:1199`, `:1200`,
  `:1201`, `:1202`); commercetools regains the beta-projection clause, Magento regains *"updated
  2026-06-15"* and now quotes the record's table cell (`11082.md:246`) instead of the brief's prose.
- **26 / 27** — C3 §8 now says half of #10943's regex **was** published; the 1,945 → 2,062 delta is no
  longer presented as growth, with the two instruments named and #10943's own "floor" caveat carried.
- **28** — Meta's internal contradiction added. Independently re-parsed: three columns vary, nineteen do
  not. *(See round-2 finding 8 for the artifact's own malformation.)*
- **29 / 30 / 31** — Walmart's **U26 / §5 #27** and U13, Shopee's **contradiction 18**, and Google's
  undiscriminating `itemLevelIssues` control (`11013.md:925`) are all carried in their rows.
- **32** — every dangling cite re-resolved: Amazon themes → `#10976 §1.5` with the `Flat.File.Health.xls`
  workbook-vs-product-type conflation and **contradiction 19** (re-verified at `10976.md:566`); Walmart →
  `§1.4` (`:200-201`, `:217`) and `§1.9` (`:327`); Akeneo → `§1.x`; Salesforce → `§1.9` (`11050.md:331`)
  **with the record's own dangling "(§5 D6)" pointer disclosed** rather than silently inherited.
- **34 / 35** — the template path is `py/mono/templates/…`; the file table says **nine** queries, which is
  the true count.
- **36** — both server-side write paths named. *(Range off by one — round-2 finding 6.)*
- **37 / 38 / 39** — §6 reworded to *"in the same commit that **moves the first definition**"*, with the
  day-one-no-op claim retained as the accurate one; `design-A5.md`'s migration now adds the `CHECK` as
  `NOT VALID` followed by `VALIDATE CONSTRAINT`, with the reason in a comment; the family-side validator is
  named as new work because no family model or family write path exists.
- **40** — `Product.slug` (`catalogue/models.py:405-408`, `:488`) and `thumbnail_url_cache` (`:434`) added
  to C1 §4.
- **41** — `fam-c2-pack.sql`'s tie-ordering is fixed; the query now reproduces **byte-identical** (it did
  not in round 1).
- **42 / 43** — `hiddenAttributes` at `:34`; the order-line comment attributed to `:548-549`.
- **44** — C3 §4's claim is now instrumented in both stacks, and I reproduced every count exactly:
  backend `VariantGroup`/`variant_group`/`ProductGroup`/`product_group` → **0 / 0 / 0 / 0**; frontend the
  same four plus `item_group` → **0**; `family` → **3**, all three CSS `font-family`, at precisely the three
  cited lines; positive control `product.title`/`product.slug` → **30 occurrences in 22 files**.
- **45** — the frontend sweep is instrumented; I re-ran it and got exactly 30 occurrences across 22 files.
- **46** — the proxy instrument's bias is now stated in both directions, with the worked under-count example.

**Also re-verified unchanged and still correct:** both repo pins; the eight round-1 queries other than
`fam-c3-grid` reproduce byte-identical, including every figure the round-1 brief quoted (10,090 families ·
3,912 / 5,998 / 5,997 · 2,945 of 11,411 · 2,112 / 4,273 / 891 · 2,152 of 23,299 and 21,116 · 5,303 / 4,045 /
664 · 2,055 · 3,521 + 112 = 3,633 and 697 + 30 = 727 · 2,062 / 287); all four cards still carry all eight
contract sections; the C1 tally (3 / 5 / 2 + 3 ambiguous) and the C3 tally (9 / 2 / 0 / 2) are unchanged and
still match their tables; the A5/C1 lead sentence for C1 is still accurate; the couplings to ATTR-DEF (A2,
A0) and ATTR-VALUE (A4) are present and still cite rather than re-decide; the two locks, the five
conditions, the 2026-09-15 tentatives, the 2026-09-18 closed "one category per product" and the four #10778
standing items (S1, C2, M4, M9) are all respected, with every re-expression labelled as one.
