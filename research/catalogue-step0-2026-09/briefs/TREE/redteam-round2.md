# TREE — red-team round 2 (final)

Re-verification of revision 2 by the same adversarial agent. Fixes were checked **by re-execution**, never
by reading the corrections tables; the corrections tables were then checked against what is actually in the
files.

**What was re-executed:** `scripts/shopify_map2.py`, `scripts/node_attribute_need.py` and
`scripts/nonleaf_classes.py` re-run and their outputs diffed byte-for-byte against `data/`; the B4
internal-node figures and the `all_mappings.json` rule counts computed independently from the corpus; the
B3 §2 and fork §2 tallies re-derived row by row from the tables; 10 of the 40 rows in
`data/mapping-adjudication.csv` re-read against the corpus; the tie-break re-implemented to count silent
ties; the five added consumers, the corrected `apisearch/serializers.py:10` cite and every new `path:line`
re-opened at the pins; `corpus/why-2026-09/` re-listed and the new seller artifacts re-grepped.

**Counts: 1 BLOCKING · 10 SERIOUS · 9 MINOR.**

The headline: **revision 2 is a real improvement — BLOCKING 1, 2 and 3 are genuinely resolved and every
rebuilt number reproduces exactly.** What remains is almost entirely *unapplied* edits: four passages that a
corrections table says were changed and were not, and one new option that was added without being priced.

---

## BLOCKING

### 1. B3 §7 was never edited. Three corrections rows claim it was. — BLOCKING

**What is wrong.** `TREE.md` B3 §7 (lines 707–723) is verbatim revision 1. Three separate rows of B3's own
"Corrections after red-team round 1" table assert changes to it that are not in the file:

| Corrections table says | What §7 actually still says |
|---|---|
| **MINOR 18** — *"~~87% of them are one branch~~ → **95%** (13,148 of 13,847). The correction strengthens the claim."* | line 714: *"328 deep nodes hold 13,847 products and **87%** of them are one branch"* |
| **BLOCKING 3 (carried)** — *"**715 → 810** names"* | line 723: *"the measured floor is irrelevant and **the inferred ceiling (715 names) is the real bill**"* |
| **SERIOUS 17** — *"The bill is now stated as a **range in the reasoning itself**, not only in the reopen clause … its advantage over (a) is restated as **'tens to low hundreds of sets versus 1,686 nodes'**"* | the Reasoning paragraph is unchanged: *"(b) is the only option whose authoring bill is bounded by the number of distinct sets (**68 measured, 47 inside the 639**)"*. `grep -n "tens to low hundreds"` over `TREE.md` → **0 hits**; the phrase exists only at `design-B3.md:86` |

I re-derived 13,148 / 13,847 = **95.0%** of products and 311 / 328 = **94.8%** of nodes from
`sql/results/nodes-full.csv`; B3 §5's own table already carries 13,148 of 13,847, so §7 contradicts §5 four
paragraphs apart. And 715 is the superseded ceiling — `scripts/node_attribute_need.py` re-run prints
**810**, and `node-attribute-need.md`'s revision-2 box heads its delta table with `715 → 810`.

**Where.** `TREE.md:707-723` (B3 §7, all three sub-paragraphs); the claimed-but-absent edits at
`TREE.md:754` (MINOR 18), `:751` (BLOCKING 3 carried) and `:750` (SERIOUS 17).

**Why it matters.** §7 is the paragraph a decision-maker reads; the corrections table is the audit trail
that a second reviewer reads instead of re-checking. Here the audit trail is wrong in the *"already fixed"*
direction on three separate rows, which is worse than leaving the errors unflagged — it retires them.
`design-B3.md` received the SERIOUS 17 edit, so this reads like one lost write to `TREE.md`.

**Fix.** Apply the three edits to `TREE.md` B3 §7: 87% → 95%; 715 → 810 (and name the conservative 574
beside it); and put the bill range — 68 floor · 347 inferred over the 485 mapped (233 conservative) · 1,686
under (a) — in the Reasoning paragraph, with the "tens to low hundreds vs 1,686" restatement that
`design-B3.md:86` already carries.

---

## SERIOUS

### 2. B3 §2's opening sentence still asserts exactly what BLOCKING 1 struck — SERIOUS

`TREE.md:515-516`, the lede above the table: *"**Every platform that materialises an attribute schema per
node is in the first group.**"* The derived tally 20 lines below (`:536-546`) says the opposite and says it
correctly: centrally-authored **7**, of which **6** carry a schema (Google does not); merchant-authored
**6**, of which **1** does (Salesforce); *"the schema-carrying set is not the centrally-authored set."* I
re-derived this from the table's own column and it is right. The lede is the round-1 error in a different
sentence. **Fix:** replace with *"Six of the seven centrally-authored platforms materialise a schema per
node; so does one of the six merchant-authored ones."*

### 3. B2 §8's limits bullet still carries the withdrawn one-directional claim and two stale counts — SERIOUS

`TREE.md:477-479`: *"**The 252 rule-assigned non-leaf nodes are weak.** 50% agreement with the hand reading,
**biased toward `mixed`**."* Fifteen lines below, B2's corrections table (SERIOUS 6) says *"The claim that
the rule's error is one-directional is **withdrawn**"*, and `nonleaf-classification.md` §2 says *"The
direction of the rule's error is NOT established, and revision 1's claim that it was is withdrawn."* The
counts are also superseded: the CSV has **244** rule rows, and agreement is **20 of 48 = 42%**. So the one
place in `TREE.md` that states the limit states the retracted version of it, unstruck. **Fix:** restate as
*"the 244 rule-assigned nodes (29.7% of the products) are an estimate; agreement with the reading is 20 of
48 and the direction of error is unresolved."*

### 4. B4 §7 states two different confidences for the same judgement — SERIOUS

`TREE.md:995-996` (the judgement line): *"Confidence **high** that D15 must be per-kind; **medium** that
definitions should be (b)."* `TREE.md:1018-1019`, same section: *"Confidence on (b) for definitions
therefore moves **medium → medium-high**."* The revision-2 header (`:33-34`) and B4's corrections table both
record the move up. The judgement line was not updated. A reader who stops at the judgement line — which is
what the line exists for — gets the superseded figure. **Fix:** make the judgement line read *medium-high*.

### 5. "Pass B is a superset of pass A" is false, and the script's own assertion says so — SERIOUS

`node-attribute-need.md`, revision-2 box, defect (2): *"they are now a **preference** with a global
fallback, **so pass B is a superset of pass A**."* Re-running `scripts/shopify_map2.py` prints, and the
saved `data/run-logs/shopify_map2.out.txt` carries verbatim:

```
pass-A matches lost by pass B (must be 0 now): 3, products 132
```

The three are ids **1804**, **1799** (`UNUSED > AREA DISPLAY > CARDINAL > CARDINAL NORMAL > …`) and **1839**
(`UNUSED > UNUSED 2 > PENGGARIS`), all EXACT in pass A. They are lost deliberately —
`shopify_map2.py:143-145`, `if allowed == []: got = ("UNMAPPED", None, 0.0, "")` for the three non-product
roots. The exclusion is defensible and consistent with the brief's own position that those roots are not
product types. What is not defensible is a stated invariant that the instrument reports violated, an
assertion line left printing a non-zero value with no comment, and a superset claim in the box ATTR-VALUE is
told to re-read. **Fix:** either scope the claim (*"a superset over the ten product roots; the three
non-product roots are excluded by construction"*) or change the assertion to exclude them so it prints 0.

### 6. The eight adopted tail nodes are described as "a random 8"; they are the disagreeing subset of a random 20 — SERIOUS

`nonleaf-classification.md:40`, `:61`, `:193`: *"Red-team round 1 re-read **a random 8** of the
rule-assigned tail"*, *"the red team's **random 8** shows the opposite lean — **the rule agreed on 0 of
8**"*. That is not what round 1 did. `redteam-round1.md` finding 6 states: *"I re-read a **random 20** of
the 252 `basis=rule` rows"*, *"My agreement rate is ~40–55%, **consistent with the stated 50%**"*, and then
tabulates only the eight it judged misclassified. The eight are an **error-enriched subsample**; "the rule
agreed on 0 of 8" is a restatement of the selection rule, not a measurement of the tail.

Pooling them into the hand-read population propagates into three published figures, all of them quoted in
`TREE.md`: hand-read population 40 → **48** nodes / 13,555 → **13,718** products (B1 §5, B2 §5);
residual-type **21.5% → 21.9%** (B1 §5, B2 §5, B2 §6, B2 §7); rule agreement 50% (of 40) → **42% (of 48)**
(B2 §5). I re-derived all of them from `data/nonleaf-classification.csv` and they are arithmetically
correct — 40 `hand` + 8 `hand-redteam` = 48, 13,555 + 163 = 13,718, 2,919 + 80 = 2,999 = 21.86% — but they
are statistics over a union of a top-by-products stratum and a stratum selected for being wrong.

B2 §7 then uses the pooled move as evidence: *"Red-team round 1 moved this figure **up**, not down — 21.5%
→ 21.9% — by re-reading 8 tail nodes, 5 of which the rule had wrongly called `under-filed`."* It moved up
*because* the eight were chosen for being wrong. **Fix:** describe the provenance accurately ("the eight
rows a random-20 tail re-read judged misclassified"), keep the two strata separate — top-40 agreement 20/40
= 50%; tail agreement from the random 20 ≈ 50%, not 0/8 — and state the selection when the 48-node class
table is used. The recommendation does not turn on it; the arithmetic being clean is not the same as the
sample being one.

### 7. The new fork option (c) is priced at "one nullable column" and is never charged the mapping it requires — SERIOUS

`TREE.md` fork §4: *"**Under (c)** exactly one new nullable column (`shopify_taxonomy_id`) and a feed-time
lookup."* §6's (c) column: Tree *"unchanged"*, Schema authoring *"unchanged"*, Our code *"one nullable
column"*. But (c) — *"keep our tree and hold a mapping to a standard"* — requires a mapping **from our 1,686
used nodes to Shopify's**, which is precisely the bill the same section uses as decisive fact 4 **against**
adoption: 71.2% of nodes do not map mechanically, ~25% of the automated ones are the wrong target, and the
largest single component (302 nodes, 40.1% of products) *"is not a rename but a decision to turn gender and
age from tree levels into attributes."* A column is the schema cost; the mapping is the work, and (c) pays
it in full.

Two further gaps for an option that is being **recommended** (§7: *"the card's (a) plus (c), not (b)"*):
§7's *"What it forces in steps 1–5"* covers "if we keep authoring" and "if we adopt" and says nothing about
(c); and there is **no design sketch for (c)** — no `design-fork.md`, and `design-B1..B4` do not cover it —
although BRIEF §3.5 and §4 §6 require one per option the platforms split on.

**Fix:** give (c) its own row in the bill with the same mapping numbers used against (b), add its step-1
consequence (who authors the mapping, against which release channel, and what happens when `dist/` is
retired on 2026-10-31), and sketch it.

### 8. The 14,528 + 5,754 published rules are cited as if they reduced *our* mapping cost — SERIOUS

`TREE.md` fork §6, (c) governance row: *"the mapping is refreshed on their cadence, **which is what their
14,528 + 5,754 published mapping rules exist for**."* §7's reopen clause: *"the answer is (c), and **the
taxonomy already ships the mapping** (`dist/en/integrations/google/shopify_2026-08_to_google_2021-09-21.json`,
14,528 rules)."*

I measured `dist/en/integrations/all_mappings.json` directly. The rule sets are:

| input taxonomy | output taxonomy | rules |
|---|---|---|
| `shopify/2026-11-unstable` | `google/2021-09-21` | **14,528** |
| `shopify/2022-02` | `shopify/2026-11-unstable` | 5,595 |
| `shopify/2025-12` | `shopify/2026-11-unstable` | 108 |
| `shopify/2024-10` | `shopify/2026-11-unstable` | 50 |
| `shopify/2025-09` | `shopify/2026-11-unstable` | 1 |

Every rule takes a **Shopify** category as input. None maps our nodes to anything. They are usable only on
the second hop, downstream of the our→Shopify mapping that §5 says does not exist. The counts themselves
are correct and correctly stated in §2; the inference drawn from them in §6 and §7 is not. **Fix:** say the
shipped mapping is Shopify→Google (and Shopify→Shopify for version migration), and that it covers the hop
after ours, not ours.

### 9. The revised resolver turns disclosed ambiguity into confident EXACT matches, and one of round 1's two named wrong matches survives through it — SERIOUS

Pass B's `AMBIGUOUS` count falls **59 → 17** while `EXACT` rises **308 → 351**. Re-implementing the
tie-break against the script's own candidate pools, **30 of the 351 exact-tier rows (8.5%, 5,185 products)
had more than one identically-normalised taxonomy candidate** and were resolved silently and recorded as
`EXACT`, score 1.0, with no ambiguity marker. The resolver is
`sorted(cands, key=(-len(c["_anc"] & r["_anc"]), c["level"]))` with "unique" tested only against the
runner-up (`shopify_map2.py:95-97`), so it can turn on a generic structural word.

Demonstrated, and it is one of the two wrong matches round 1 named by name:

- **node 1177 `Fashion > FASHION PRIA > BAWAHAN PRIA > CELANA PENDEK PRIA` (368 products)** → mapped
  `EXACT`, tier `exact-stripped`, to
  `Busana dan Aksesori > Pakaian > Pakaian Tidur & Pakaian Santai > Loungewear > Bawahan Loungewear >
  Celana Pendek` — **loungewear** shorts.
- The taxonomy has **five** nodes named exactly `Celana Pendek`, and I confirmed **all five carry
  `Jenis kelamin sasaran`**, so the new recoverability rule does not discriminate between them. The obvious
  home is `Busana dan Aksesori > Pakaian > Celana Pendek > Celana Pendek` (level 3, leaf).
- Loungewear wins because our parent is literally named `BAWAHAN PRIA` and the taxonomy path contains
  `Bawahan Loungewear` — one shared generic token, "bawahan".
- The wrong target is level 5 **and a leaf**, so the mechanical ancestor flag does not fire and the row
  **survives into the conservative 309-node / 574-name cut**, contributing a loungewear attribute set.

Round 1 named two wrong matches. `ATASAN WANITA` is genuinely fixed (I confirmed node 398 is now
`UNMAPPED`, and the taxonomy side is never stripped — `shopify_map2.py:75`, *"NEVER stripped — round-1
fix"*). `CELANA PENDEK PRIA` was not re-checked. **Fix:** return `AMBIGUOUS` whenever more than one
candidate shares the winning token set (or record `n_candidates` per row so the adjudication can stratify on
it), and re-check both round-1 cases explicitly.

### 10. SERIOUS 12 was applied to three of the four bullets it named; B3 §3's Google bullet is untouched — SERIOUS

Round-1 SERIOUS 12 listed four instances: B1 Square, B2 Google, B3 Amazon and **B3 Google**. B1 Square,
B2 Google and B3 Amazon are now properly split into **Stated** / **Inference** with a note. `TREE.md:573-576`
is not: it still reads *"**Google — stated.** The taxonomy is an ad-targeting classification the platform
fills in for you: [quote]. **Depth is cheap because no one authors a schema per node.**"* The quote
establishes automatic assignment; the closing sentence is an unlabelled causal inference in a bullet headed
"stated". **Fix:** split it the way B2 §3's Google bullet already is.

### 11. `fork-shopify-taxonomy.md` §2.2 still contains the MINOR 23 error its own corrections table says was fixed — SERIOUS

`fork-shopify-taxonomy.md:55-56`, the "Present" list, still ends *"`Kecap`, **`Santan`**, **`Rice
Cooker`**"* — the en spellings inside an id-ID list. Its corrections table at `:154` says *"corrected to
`Santan & Minuman Kelapa` and `Penanak Nasi`"*; `TREE.md:1200-1205` **is** corrected. I re-probed: no id-ID
node is named `Santan` (there are `Santan & Minuman Kelapa`, `Santan & Krim Kelapa`) and **no id-ID node
contains "Rice Cooker" at all**. The same paragraph's "Absent" list is also out of sync with `TREE.md`'s —
it reads `Sarong` **(en)** and omits `Peci`, where `TREE.md` now lists both unqualified. (Both are in fact
absent at word boundary in both builds; I re-verified.) **Fix:** sync the side file to `TREE.md`.

---

## MINOR

12. **`TREE.md` B2 §3 still reports the eBay edp guide as "HTTP 200, 38,126 B"** (`:302`) — the exact figure
MINOR 20 corrected. The Appendix (`:1382`) and `corpus/why-2026-09/PROVENANCE.md` both carry the right
**200,027 B** with the explanation (curl's compressed-transfer figure). So the wrong number survives only at
the place a reader checking the eBay evidence opens first, with no correction beside it.

13. **Appendix item 7 still says "the **1,291** unmapped nodes"** (`TREE.md:1434`). The rebuilt figure is
**1,201**.

14. **`scripts/nonleaf_classes.py`'s printed summary is still the 40-row version.** The saved
`data/run-logs/nonleaf_classes.out.txt` — the provenance a reader is pointed to — says *"hand-read nodes:
**40** (13555 products, **69.4%**)"* and *"rule agrees with the hand verdict on **20 of 40 (50%)**"*, and
prints a 40-row confusion matrix, against the brief's 48 / 13,718 / 70.3% / 42%. The brief's figures are the
correct ones (I re-derived every one from the CSV, which does carry `basis` = `hand` 40 / `hand-redteam` 8 /
`rule` 244); it is the instrument's own headline that was not updated. `nonleaf-classification.md` §2 is
careful and labels its matrix *"on the 40 top-by-products hand-read nodes"* — the run-log is not.

15. **B2 §3 and §6 still quote the catch-all count as "48 … 34 of them leaves" without the basis** MINOR 31
added in §5. On the baseline's used-nodes basis it is **44 nodes, 32 leaves**; 3,591 products either way.
§5 now gives both bases; §3 and §6 give only the all-nodes one, next to the baseline's used-only 42.

16. **"destroyed **58 correct** pass-A matches"** (`node-attribute-need.md` revision-2 box, defect 2).
Round 1 said 58 pass-A matches were lost and explicitly noted several were wrong anyway — `KAUS PRIA` →
`Kaus Dalam Pria`, `MAKANAN KECIL` → pet treats. `KAUS PRIA` is still adjudicated **wrong** in revision 2's
own `data/mapping-adjudication.csv`. "58 correct" is not supportable; "58 pass-A matches, some of them
themselves wrong" is.

17. **The over-mapping headline uses the worse of two strata, and `TREE.md` never gives the other two.**
`node-attribute-need.md` §2.1 publishes all three honestly — top-20 by products **10.0%**, random-20
**25.0%**, combined **17.5%** — and I reproduced them from the adjudication file. `TREE.md` B3 §5 and fork
§5 quote only *"roughly a quarter … 5 of a random 20"*. The random stratum is the right unbiased choice for
a node-share estimate, but the top-20 stratum covers the rows carrying the most products and is three times
better, and no product-weighted error rate is given anywhere.

18. **The fork §2 matrix's mapping column is mostly unpopulated, and option (c)'s precedent rests on two
cells.** Of the 14 rows, the *"publishes/consumes a mapping"* column reads **"not collected" on 5** (Amazon,
eBay, Walmart, Shopee, and n/a for Tokopedia A) and "no"/"n/a" on 7; only **2** are positive, one of which
(Tokopedia Era B) is a dual tree the seller reconciles, not a stored mapping. §1 introduces (c) as *"the way
**every platform that touches a second taxonomy** actually does it"* — true, with n = 2. §8's limits note
covers the *adoption* column's silence but not the mapping column's five "not collected"s. **Fix:** say n =
2 where the claim is made, or collect the five.

19. **The Appendix's fork-matrix row says it was "✅ added in round 1"** (`TREE.md:1406`). It was added in
the round-1 *fix* round, i.e. revision 2; round 1 is the report that asked for it.

20. **Row-count wording.** Fork §2's table has **14** rows (Tokopedia split into two eras, as BRIEF §3.1
requires) while §2's prose and the corrections table call it a *"13-row matrix"*. B4 §2 handles the same
split correctly by saying *"11 of 14 rows"*. Harmonise, or say "thirteen platforms, fourteen rows".

---

## Verified fixed, by round-1 finding number

**BLOCKING 1 — fixed.** B3 §2 now derives the tally row by row. I re-derived it from the table: centrally
authored 7 (Amazon, Shopify, Google, eBay, Walmart, Shopee, Tokopedia), of which 6 carry a per-node schema —
Google does not; merchant-authored 6, of which 1 does — Salesforce; total 7 = 6 + Salesforce. §3's
"merchant-tool six" bullet is rewritten and now names Salesforce as *the* relevant precedent. (Lede sentence
still stale → finding 2.)

**BLOCKING 2 — fixed.** The denominator is now derived, not asserted, with an explicit expressibility filter
and four denominators published side by side. I verified the two new corpus measurements independently:
**2,606 of 2,664 internal nodes (97.8%) carry ≥1 attribute, median 5**, and **14,254 of 14,580 parent→child
pairs (97.8%) have a parent with something inheritable** — both exact. eBay's reconciliation matches the
record verbatim (`evidence/issues/11031.md:1345`: *"Aspects: no, leaf-only and self-contained. Category
features: yes, explicitly"*). The 1-of-2 reading follows from the brief's own rows.

**BLOCKING 3 — fixed in substance.** The taxonomy side is no longer stripped (`shopify_map2.py:75`), a
stripped match must be recoverable on the target, and `ATASAN WANITA` (node 398) is now `UNMAPPED` rather
than matched to `Atasan Bayi & Anak`. An over-mapping rate is published for the first time, with a
40-row hand adjudication, a conservative equivalent-level cut, an explicit note that the mechanical ancestor
flag over-counts (176 of 485 vs 4 of 40 by hand), and direct guidance to ATTR-VALUE to treat both ceilings
as order-of-magnitude bounds. (Residual tie-break defect → finding 9.)

**SERIOUS 4 — fixed.** The B4 §2 footnote now reads *"all rows **except Tokopedia Era A**"*, cites
`evidence/issues/11031.md:1338-1352` as 13 rows, and attributes the Era A row to #11048 §1.5/§2.

**SERIOUS 5 — fixed 58 → 3.** The vertical bindings are a preference with a global fallback; pass A's
`KACAMATA` match (node 53, 642 products) is recovered and now maps `scope=global` to
`Kesehatan & Kecantikan > … > Kacamata`. (Superset claim overstated → finding 5.)

**SERIOUS 6 — fixed in substance.** The one-directional claim is explicitly withdrawn, the confusion matrix
is printed rather than summarised and is correctly labelled as covering the 40-row stratum, and the tail's
eight readings are published with their reasons. (Sample description → finding 6.)

**SERIOUS 7 — fixed.** *"a standard taxonomy is one we cannot extend"* is struck and replaced with the
forks-the-published-set claim, which the evidence supports; the uncollected contribution guide is named as
the route in both §3 and §8.

**SERIOUS 8 — fixed.** B1 §2 now tallies against the card's own wording (Akeneo = 1 of 13, at tree scope)
*and* against the narrower reading (0), states that the narrower reading is the brief's own definition, and
§7's headline is restated as *"one precedent of thirteen at tree scope; none at node scope"*.

**SERIOUS 9 — fixed, all five re-opened at the pins.** `catalogue/search_indexes.py:8-22` (`CategoryIndex`,
`guid = KeywordField(model_attr="full_code")`) ✓ · `api/apiproduct/serializers.py:127, 137, 201, 208`
(`main_category = CategorySerializer()` on both read serializers) and `:76` `"age_walled"` ✓ ·
`catalogue/managers.py:28-31` `browsable()`, consumed at `api/apicategory/views.py:60` and `:73` ✓ ·
`ts/.../category-form-ui.component.ts:96-97` (the parent picker, inverse requirement) ✓ ·
`ts/.../product-filter.util.ts:36` ✓. The fork §4 "keyed on our Category" list is now six, with
`full_code` correctly singled out; `catalogue/models.py:136-141` confirms `unique=True`.

**SERIOUS 10 — fixed.** The four ancestry cites all verify: `api/apicategory/views.py:46-55`,
`category-tree.service.ts:16`, `category-parent-link-ui.component.ts:26-27` (`ancestors[length-2]`) mounted
at `category-detail-ui.component.html:1`, and `category-tree-select.component.ts:50-73`. The criterion is
restated as "one-hop parent link, no full trail", which is what the code does.

**SERIOUS 11 — fixed.** `corpus/why-2026-09/seller-69be0f.html` (909,400 B) and `seller-3b9900.html`
(112,194 B) are on disk with a `PROVENANCE.md` table. I re-grepped the saved bytes: *"I have tried consumer
electronics…"* 12 occurrences, *"Do a search for your item…"* 4, *"FB Marketplace"* 1; and on the 3Dsellers
page *"define the category specifically"* and *"Kitchen Units"* both present.

**SERIOUS 12 — fixed 3 of 4** (B1 Square, B2 Google, B3 Amazon). B3 Google → finding 10.

**SERIOUS 13 — fixed.** The fork now has all eight sections, a 13-platform / 14-row matrix with a cite on
every row, a "Why" section and an "Our code today" section. The **0-of-13** claim is cited per row and is
honestly hedged in both §2 and §8 (*"the six merchant-tool platforms are silent, not opposed … we are their
customer"*). I independently confirmed the Shopify mapping counts behind the matrix's Shopify row
(14,528 + 5,595 + 108 + 50 + 1) and that both
`shopify_2026-08_to_google_2021-09-21.json` and `shopify_2026-11_to_google_2021-09-21.json` exist.

**SERIOUS 14 — fixed.** A "#10778 disposition" section now precedes the Appendix: V1 **confirm** (fork's
vocabulary proposal framed as seeding V1's initial contents), C5 **confirm for names / re-express for value
lists** with A4 named as owner, V4 **not relied on**, and the #11031 audit warning **honoured** — I
confirmed no #10778 figure is quoted anywhere in the brief.

**SERIOUS 15 — fixed.** `api/apisearch/serializers.py:10` (`category = PositiveInteger32Field()`) is now the
cite; `filters.py:26-29` is correctly described as the generic `_handle_equality_filters` helper that
contains no category; the phantom "five serializers" is gone. The registration decomposition is correct — I
recounted 12 non-spec `type: 'category-id'` registrations = 8 filter tables/modals + 1 filter util + 2 write
fields + 1 storybook file.

**SERIOUS 16 — fixed.** The 90% cut is deterministic (`-products`, then `id`). Both scripts now print
**223 / 491**, and `data/shopify-attrs-for-our-90pct.json` holds exactly **491** entries;
`…-equivalent-level.json` holds exactly **340**.

**SERIOUS 17 — fixed in `design-B3.md:86` only** → finding 1.

**MINOR 18 — not applied** → finding 1. **MINOR 19 — fixed** (7 nodes / 439 products in subtree; 394 named
as the mie-only sub-branch). **MINOR 20 — fixed in the Appendix and PROVENANCE, not in B2 §3** → finding 12.
**MINOR 21 — fixed** (46,499 rows, 15,475 junk rows, 12,512 literal `'0'`; separately 5,580 distinct raw
values). **MINOR 22 — fixed** (3,402 current rows, 3,209 `is_active`). **MINOR 23 — fixed in `TREE.md`, not
in the side file** → finding 11. **MINOR 24 — fixed** (the dead Vue branch is now said to strengthen the
point). **MINOR 25 — fixed** (`design-B4.md` §0 heading and the brief's lede both now read "six kinds, four
mechanisms"). **MINOR 26 — fixed** (restated in terms of descendants). **MINOR 27 — fixed**
(`fork-shopify-taxonomy.md` §4/§5 now carry the derived 1 of 2). **MINOR 28 — fixed** (0-based level stated
at the comparison). **MINOR 29 — fixed** (the commercetools cell flags the B2/B1 double duty and leads with
the genuine B1 evidence). **MINOR 30 — fixed** (`evidence/issues/10976.md:158`). **MINOR 31 — fixed in B2 §5;
§3 and §6 unqualified** → finding 15.

### Re-runs that reproduced exactly

- `scripts/shopify_map2.py` → `data/shopify-mapping.csv` **byte-identical**. Pass A **420 (24.9%) / 29,478
  (27.8%)**; pass B **485 (28.8%) / 40,540 (38.2%)**, miss **1,201 (71.2%) / 65,621 (61.8%)**; the 639 cut
  **223 = 175 EXACT + 48 FUZZY**, 5 ambiguous, 411 unmapped, **491** names; equivalent-level **309 / 233 /
  574** and **129 / 340**; gender/age nodes **302 (17.9%) / 42,621 (40.1%)**, 106 mapped through the
  stripped tiers.
- `scripts/node_attribute_need.py` → `data/node-attribute-need.csv` and the summary JSON **byte-identical**;
  measured half unchanged (**68 / 61 / 47** sets, 8 kinds, 98.8% / 98.7% sharing); inferred **810 / 347 /
  485**, **574 / 233 / 309**, **491 over 223**, **340 over 129**, median 8.
- `scripts/nonleaf_classes.py` → `data/nonleaf-classification.csv` **byte-identical**; 292 rows, basis
  `hand` 40 / `hand-redteam` 8 / `rule` 244; hand union 48 nodes / 13,718 products / 70.3%; class products
  7,168 · 2,999 (21.9%) · 1,404 · 1,217 · 519 · 411; agreement 20 of 48.
- Corpus, computed independently: internal nodes **2,664**, of which **2,606 (97.8%)** carry ≥1 attribute,
  median 5; pairs **14,580**, of which **14,254 (97.8%)** have an inheritable parent; `all_mappings.json`
  rule counts 14,528 / 5,595 / 108 / 50 / 1.
- Adjudication: `data/mapping-adjudication.csv` has 40 rows, 29 correct / 7 wrong / 4 ancestor; strata
  10.0% / 25.0% / 17.5%. I re-read 10 rows against the corpus and agree with 9 (630, 1162, 721, 658, 59,
  1264, 53, 1151, 307); the tenth (1284 `TAS TANGAN WANITA` → `Tas Tangan`, marked *correct* though the
  mechanical flag fires) is a judgement the file itself discusses and I would not overturn.
