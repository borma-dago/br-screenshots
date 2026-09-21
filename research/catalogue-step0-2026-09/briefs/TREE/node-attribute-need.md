# The attribute need per category node — the A3↔B3 shared measurement

> ## ⚠ REVISION 3 — 2026-09-19, after red-team round 2. **ATTR-VALUE: the inferred numbers changed again. Re-read §2.**
>
> | | rev 1 | rev 2 | **rev 3** |
> |---|---|---|---|
> | pass-B mapped nodes | 395 (23.4%) | 485 (28.8%) | **434 (25.7%)** |
> | pass-B mapped products | 32,962 (31.0%) | 40,540 (38.2%) | **34,671 (32.7%)** |
> | pass-B miss rate (nodes) | 76.6% | 71.2% | **74.3%** |
> | inferred attribute **names**, all mapped | 715 | 810 | **776** |
> | inferred attribute **sets**, all mapped | 290 | 347 | **316** |
> | names over the 639 nodes covering 90% | 436 / 185 nodes | 491 / 223 | **477 / 200** |
> | conservative (equivalent-level) cut | — | 574 / 233 / 309 | **558 / 220 / 284**; 90%-cut **330 / 115** |
> | over-mapping, random stratum | not stated | 5/20 = 25% | **6/21 = 28.6%** (Wilson 95% CI **14–50%**) |
>
> **What changed in round 2.** The resolver was silently breaking ties: **30 of 351 exact-tier rows had more
> than one identically-normalised taxonomy candidate** and were recorded as `EXACT`, score 1.0, with no
> ambiguity marker — the tie could turn on a single generic shared word. It now returns **`AMBIGUOUS`
> whenever more than one candidate shares the winning normalised name**, and every row carries
> `passB_n_candidates`. Pass-B `AMBIGUOUS` rises 17 → **68**; mapped falls 485 → **434**. The demonstrated
> case, `CELANA PENDEK PRIA` → *loungewear* shorts (five taxonomy nodes are named exactly `Celana Pendek`
> and all five carry `Jenis kelamin sasaran`, so recoverability could not discriminate), is now
> `AMBIGUOUS`; so is `CELANA BOXER`. `ATASAN WANITA` remains `UNMAPPED`, as round 1 required.
>
> **The over-mapping rate went slightly UP, not down.** The fix removed 7 of the 40 adjudicated rows from
> the mapped set (6 of them rows the reading had called *correct*, 1 *wrong*), so the random stratum was
> **topped up with 4 fresh random draws** and re-adjudicated; two of those four are wrong
> (`PERAWATAN MOBIL` — car-care **products** onto a **service** node; `KAUS WANITA` → women's
> **undershirts**). Six of round 1's seven named wrong matches are single-candidate and therefore
> untouched by the round-2 rule. **The honest reading is that ~1 in 4 of the mapped rows still points at
> the wrong kind of product, and the resolver fix bought precision on ambiguity, not on accuracy.**
>
> **Snapshot bound.** Every dedup subquery in `sql/*.sql` now carries
> `WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside the
> `ROW_NUMBER` subquery (BRIEF §3.4). All three queries were re-run under the bound and reproduce
> **byte-identical**; no figure in this file changed as a result.
>
> **The MEASURED half has never changed**: 68 sets over 1,686 used nodes, 61 over 1,394 used leaves, 47 over
> the 639, 8 kinds. Re-run byte-identical in both rounds.

**Owner:** TREE. **Cited by:** ATTR-VALUE (A3), and by TREE's own B3 and the fork.
**Snapshot:** production data 2026-09-19 (BigQuery `solvent-staging.production_append_public`, CDC-deduplicated
per BRIEF §3.4); Shopify Standard Product Taxonomy corpus at commit `ad206247ecc45a95fe4b01bce2ad2f0e7bec3c66`
(2026-08-27), build string `2026-11-unstable`, `dist/id-ID` and `dist/en`.

**Question, as the card states it:** *"how many of our leaves share an identical attribute need"*, and
*"the distinct attribute names our 639 main nodes would need"*.

**Answer in one line (measured, from our own titles): 68 distinct attribute-need sets across our 1,686 used
nodes, drawn from 8 distinct kinds; 98.8% of nodes share their set with at least one other node; the 639
nodes that cover 90% of products need 47 distinct sets.** The inferred route (a vendor taxonomy's
materialised sets) answers the same question with **776 distinct attribute names over the 434 nodes it can
reach at all** — and reaches only 25.7% of our nodes, with roughly a quarter of those reaches landing on the
wrong target (§2.1).

---

## 0 · What is measured and what is inferred

The two routes are reported separately and are never blended. They answer the same question from opposite
ends and they disagree by an order of magnitude; that disagreement is the finding.

| | MEASURED | INFERRED |
|---|---|---|
| Source | our own 106,161 product titles | Shopify's taxonomy, mapped onto our nodes |
| What it shows | what the catalogue **already distinguishes** — the facts staff felt they had to type into a title because there was nowhere else to put them | what a centrally-authored taxonomy **says a node of this kind should carry** |
| Blind to | any fact staff never wrote into a title (allergens, halal, storage temperature, country of origin, certifications) | anything our tree names that the taxonomy does not (see §3 miss rate) |
| Direction of error | **under**-states the need | **over**-states the need relative to what we can populate |

Neither is "the" answer. A schema built only on the measured route would omit facts we have never captured
and that a customer may still want to filter on; a schema built only on the inferred route hands staff
hundreds of attribute names nothing in our data can fill. **Judgement (mine):** the measured route bounds
what is *authorable today*; the inferred route bounds what is *authorable at all*. B3's recommendation uses
the measured route as the floor and names the inferred route as the ceiling.

Scripts and inputs: `scripts/node_attribute_need.py`, `scripts/shopify_map2.py`,
`sql/nodes-full.sql`, `sql/products-titles.sql`. Per-node output: `data/node-attribute-need.csv`.

---

## 1 · MEASURED — the attribute need our own titles already show

### Method

For every one of the 1,686 used nodes, the node's products' titles are scanned for evidence of eight
attribute **kinds**. Before scanning, every word the node's own name or ancestry already says is masked out —
so a node called `SUSU BUBUK` is not scored as needing *flavour* because every title contains SUSU, and
`KERIPIK KENTANG PUTIH` is not scored as needing *colour* because of PUTIH. A kind counts as **needed** by a
node when **≥ 20%** of that node's titles carry the evidence.

Detectors, verbatim from `scripts/node_attribute_need.py` (each is a property of the regex as much as of the
data — see §4):

| Kind | Detector |
|---|---|
| `net_content` | `\b\d+([.,]\d+)?\s?(GR\|GRAM\|G\|KG\|ML\|MLT\|L\|LTR\|LITER\|CC\|MG\|OZ)\b` |
| `pack_count` | `\bISI\s?\d+` · `\b\d+\s?[xX]\s?\d+\b` · `@\s?\d+` · `\b\d+\s?(PCS\|PC\|PAK\|PACK\|LBR\|LEMBAR\|SET\|RENCENG\|LUSIN\|SACHET\|SCT\|BKS)\b` |
| `colour` | 33-term lexicon (HITAM, PUTIH, MERAH, …, BLACK, WHITE, RED, …) |
| `flavour` | 40-term lexicon (RASA, AYAM, SOTO, COKLAT, STROBERI, …) |
| `material` | 24-term lexicon (PLASTIK, STAINLESS, KERAMIK, MELAMIN, KAYU, KACA, …) |
| `garment_size` | `XS\|XXL\|XXXL\|…` · `ALL SIZE` · `\b\d{2}-\d{2}\b` · `\b[2-6]L\b` · `UK. <size>` |
| `scent` | 15-term lexicon (LAVENDER, SAKURA, AROMA, PARFUM, WANGI, …) |
| `model_code` | `\b[A-Z]{1,5}\d{2,6}[A-Z]?\b` · `\b[A-Z]{2,5}-\d{1,5}[A-Z]?\b` · `\b\d{3,6}[A-Z]{1,4}\b` |

### Results

**Kind → how many used nodes need it at the 20% threshold** (of 1,686):

| Kind | Nodes | Share |
|---|---|---|
| `net_content` | 617 | 36.6% |
| `colour` | 494 | 29.3% |
| `model_code` | 454 | 26.9% |
| `pack_count` | 202 | 12.0% |
| `flavour` | 199 | 11.8% |
| `scent` | 93 | 5.5% |
| `material` | 88 | 5.2% |
| `garment_size` | 49 | 2.9% |
| *(no kind at threshold)* | 369 | 21.9% |

**How many nodes share an identical need:**

| Population | Nodes | Distinct need-sets | Nodes sharing their set with ≥1 other |
|---|---|---|---|
| all used nodes | 1,686 | **68** | 1,665 (**98.8%**) |
| used **leaves** only | 1,394 | **61** | 1,376 (**98.7%**) |
| the 639 nodes covering 90% of products | 639 | **47** | — |

**The twelve most common sets** (the whole head; the tail is in `data/node-attribute-need.csv`):

| Nodes | Set |
|---|---|
| 369 | *(none at threshold)* |
| 219 | `model_code` |
| 188 | `net_content` |
| 153 | `colour` |
| 77 | `flavour · net_content` |
| 71 | `colour · net_content` |
| 70 | `colour · model_code` |
| 64 | `pack_count` |
| 54 | `model_code · net_content` |
| 38 | `material` |
| 38 | `colour · flavour · net_content` |
| 32 | `net_content · scent` |

**Reading (judgement):** a schema authored to what our own catalogue already distinguishes is not 1,892
schemas and is not 639 schemas. It is on the order of **60–70 distinct schemas** over eight attribute names —
and the 639 nodes carrying 90% of the catalogue span **47** of them. The scale of the L1 authoring bill is
therefore set by how many *distinct sets* have to be authored, not by how many nodes exist, and only if
something makes the set reusable across nodes. That is exactly what D15 (= B4) decides.

**One of the eight is not an attribute.** `model_code` (454 nodes) detects a supplier/model code embedded in
the title (`KA-297`, `C2503`, `LB-1405`). It is evidence that half our tree carries an identifier staff have
nowhere else to put — a column question (A1), not a per-category attribute. It is left in the table because
removing it would be a classification judgement made inside a measurement.

---

## 2 · INFERRED — what a materialised vendor taxonomy says a node of this kind carries

Method in full: `scripts/shopify_map2.py` (rebuilt in revision 2), summarised in §3. For every used node the
pass-B mapping resolves, the mapped taxonomy node's materialised attribute list is taken as that node's need.

| Measure | Value |
|---|---|
| our used nodes with an inferred set | **434 of 1,686 (25.7%)** — the other 1,252 are a hole, not a zero |
| distinct inferred attribute **sets** among those 434 | **316** |
| of those 434, nodes sharing a set with another | 186 (42.9%) |
| distinct inferred attribute **names** across those 434 | **776** |
| median attributes per mapped node | **8** |
| of the 639 nodes covering 90%: nodes with an inferred set | **200** |
| distinct attribute names those 200 carry | **477** |

**Restricted to targets that are not obviously an ancestor** (dropping every mapped row whose target is at
level ≤ 2 or is a non-leaf taxonomy node — 150 of the 434, 34.6%, holding 16,458 products):

| Measure | Value |
|---|---|
| nodes | **284** |
| distinct sets | **220** |
| distinct names | **558** |
| inside the 639 covering 90% | **115 nodes / 330 names** |

Full name list for the 90% cut: `data/shopify-attrs-for-our-90pct.json` (477 entries) and
`data/shopify-attrs-for-our-90pct-equivalent-level.json` (330 entries).

**Top inferred names by node count** (id-ID spelling, as published, over all 434 mapped): the head is
`Warna` · `Pola` · `Jenis kelamin sasaran` · `Kelompok usia` · `Bahan` · `Preferensi diet` ·
`Informasi alergen` · `Persyaratan penyimpanan` · `Kain` · `Petunjuk perawatan`. The exact counts for the
current build are printed by `scripts/node_attribute_need.py` and saved in
`data/run-logs/node_attribute_need.out.txt` and `data/node-attribute-need-summary.json`; the reuse table
over the whole taxonomy is `data/shopify-attribute-reuse-en.json`.

### 2.1 · The over-mapping rate — how many of the 434 are the wrong target

**Added in revision 2 (red-team BLOCKING 3).** Under-mapping (§3) was measured in revision 1; over-mapping
was not measured at all. It is now, by hand, on a sample fixed before adjudication: the **20 largest mapped
nodes by product count** plus **20 drawn at random from the rest** (`random.seed(7)`). Verdicts, reasons and
every row: `scripts/mapping_adjudication.py` → `data/mapping-adjudication.csv`.

| Stratum | n | correct | mapped to a genuine **ancestor** | **wrong** kind | wrong rate |
|---|---|---|---|---|---|
| top by products | 16 | 11 | 3 | 2 | 12.5% |
| **random (the unbiased stratum)** | 21 | 13 | 2 | **6** | **28.6%** |
| combined | 37 | 24 | 5 | 8 | 21.6% |

**Wilson 95% CI on the random stratum: 14%–50%.** The honest statement is *roughly a quarter to a third of
mapped rows point at the wrong kind of product, and the sample is too small to narrow it further.*

**Product-weighted, over the products these 37 rows cover** (14,290 products): wrong **21.5%**, ancestor
**16.7%**. This is **not** a population estimate — the top-by-products stratum dominates it by construction
— it is the error share of the products the sample happens to cover, and it is given because a node-share
rate alone hides whether the errors are on big nodes or small ones. Here they are on both.

**Sample provenance, stated because it is no longer a single clean draw.** The original sample was 20
largest-by-products + 20 random (`random.seed(7)`). The round-2 resolver fix moved **7** of those 40 rows
out of the mapped set (6 previously judged *correct*, 1 *wrong*), leaving 16 + 17. The random stratum was
then **topped up with 4 fresh draws from the current mapped set** (`random.seed(23)`, excluding the top 20
and everything already sampled) and adjudicated the same way — of which 2 are wrong, 1 ancestor, 1 correct.
So the random stratum is 17 survivors + 4 top-ups = 21.

Wrong matches found, verbatim from the adjudication:

- `KAUS PRIA` (men's T-shirts, 1,467 products) → `Pakaian Dalam Pria > Kaus Dalam Pria` — men's **undershirts**
- `TAS RANSEL PRIA` (661) → `Tas Tangan > Tas Ransel Tangan` — a **handbag**-style backpack, wrong branch
- `PAKAIAN MUSLIM ANAK PEREMPUAN` (232) → `Pakaian Dalam Anak Perempuan` — girls' **underwear**
- `Alat dan Buku Tulis` (our root, 241) → `Produk Kertas > Alat Tulis` — a paper-products leaf
- `KIPAS ANGIN` (electric fans, 158) → `Aksesori Kipas > Remote Kipas Angin` — fan **remote controls**
- `CELANA BOXER` (men's, 36) → `Pakaian Dalam Balita > Celana Dalam Boxer` — **toddler** boxers
- `MAKANAN BEKU` (frozen food, 11) → `Perlengkapan Ikan & Akuatik > Makanan Ikan > Makanan Beku` — frozen **fish food**

**The mechanical "ancestor" flag over-counts.** `target level ≤ 2 or non-leaf` fires on 150 of 434 (34.6%)
but on only 5 of the 37 adjudicated rows does the reading agree it is really an ancestor match — the flag
also fires on correct equivalent matches whose target simply happens to be non-leaf (`Lingeri > Celana Dalam
Wanita`, `Sepatu > Sandal`, `Pakaian > Set Pakaian`). Both figures are published; neither is a substitute for
the reading.

**Consequence for use as a ceiling (judgement).** 776 names over 434 nodes is the *shape* of the ceiling, not
a validated set: about a quarter to a third of the rows behind it are the wrong node's attribute list. The
equivalent-level-only figure (**558 names over 284 nodes**) is the more conservative of the two and is still
not error-free. **ATTR-VALUE should treat both as order-of-magnitude bounds — "hundreds of attribute names,
not eight" — and not as a list to adopt.**

**The contrast, stated plainly:** 434 of our nodes, mapped, would carry **776 distinct attribute names and
316 distinct sets** (558 / 220 on the conservative cut). The same 1,686 nodes, measured against what our own
titles distinguish, need **8 names and 68 sets**. A vendor taxonomy does not reduce the schema-authoring
problem; it replaces authoring with *populating*, and the population bill is hundreds of names wide.

---

## 3 · The mapping the inferred route rests on, and its miss rate

Two passes, both against `dist/id-ID` (only **15 of 1,686** used nodes carry `_name_en`, so the English build
is not a usable route). No machine translation is used: a miss here is an honest miss.

- **Pass A — literal name identity.** Normalise both sides (casefold, punctuation → space, drop Indonesian
  function words), compare token sets. `EXACT` = identical set, one winner. `FUZZY` = best Jaccard ≥ 0.60.
  `AMBIGUOUS` = a tie survives the ancestor tie-break. `UNMAPPED` = nothing ≥ 0.60. No stripping, global pool.
- **Pass B — pass A plus the two pieces of work a real adoption does first.**
  1. **Thirteen hand-authored root → vertical bindings** (listed in the script; our three non-product roots
     bind to nothing). **Revision 2: these are a *preference*, not a filter** — if nothing in the preferred
     verticals reaches the threshold, the whole taxonomy is searched and the row is marked `scope=global`.
     Among the 485 mapped rows, 426 resolved inside the preferred verticals and **59 needed the global
     fallback**; the global-fallback rows are where several of the wrong matches in §2.1 come from
     (`MAKANAN BEKU` → pet fish food is one).
  2. **The gender/age qualifier collapse.** The tokens `pria · wanita · anak · bayi · dewasa · laki ·
     perempuan · remaja · unisex · balita` are stripped from **our** node name only — **never from the
     taxonomy's** (this was the revision-1 defect) — and a stripped match is admitted only when the
     qualifier is **recoverable** on the target, i.e. the target node carries `Jenis kelamin sasaran`
     (Target gender) or `Kelompok usia` (Age group). 106 of our 302 qualifier-bearing nodes map through a
     stripped tier.

Tier counts across all 1,686 rows: `exact-raw` 269 · `fuzzy-raw` 127 · `exact-stripped` 85 ·
`fuzzy-stripped` 21 · no tier (unmapped) 1,184. (Tiers also appear on `AMBIGUOUS` rows, so they sum above
the mapped count.)

| Verdict | Pass A nodes | Pass A products | Pass B nodes | Pass B products |
|---|---|---|---|---|
| EXACT | 242 (14.4%) | 14,209 (13.4%) | **321 (19.0%)** | **27,034 (25.5%)** |
| FUZZY | 120 (7.1%) | 9,539 (9.0%) | 113 (6.7%) | 7,637 (7.2%) |
| AMBIGUOUS | 77 (4.6%) | 7,713 (7.3%) | **68 (4.0%)** | 7,347 (6.9%) |
| UNMAPPED | 1,247 (74.0%) | 74,700 (70.4%) | 1,184 (70.2%) | 64,143 (60.4%) |
| **mapped** | **362 (21.5%)** | **23,748 (22.4%)** | **434 (25.7%)** | **34,671 (32.7%)** |
| **MISS RATE** | **1,324 (78.5%)** | **82,413 (77.6%)** | **1,252 (74.3%)** | **71,490 (67.3%)** |

All **68** pass-B `AMBIGUOUS` rows have more than one identically-normalised candidate — that is the
round-2 rule, and `passB_n_candidates` records how many.

> Pass A's own figures moved across all three revisions (380 → 420 → 362 mapped) even though its
> `UNMAPPED` set is **identical every time** (1,247). Only the tie-break changed: revision 2 loosened it,
> revision 3 tightened it to "more than one identically-normalised candidate ⇒ AMBIGUOUS". **The set of
> nodes that reach the threshold at all has never moved**; what moved is how much of that set we are
> willing to call resolved.

**Pass B is a superset of pass A over the ten product roots — and only over those** *(claim scoped after
red-team round 2, SERIOUS 5: revision 2 stated the invariant unscoped while the instrument printed it
violated)*. The script now asserts it in that form and prints **0** lost over the ten product roots. Two
nodes (89 products) that pass A maps are `UNMAPPED` in pass B — `UNUSED > AREA DISPLAY > CARDINAL >
CARDINAL NORMAL > JEANS` (56) and `UNUSED > UNUSED 2 > PENGGARIS` (33) — both under the `UNUSED` root, which
binds to no vertical **by construction** (`shopify_map2.py`, `if allowed == []`), because it is a
display-area tier and not a product type. Pass A maps them only because it does not know that. This is the
refusal working, not a regression.

Per-node results, including every ambiguous and unmapped node with its nearest candidate, plus each mapped
row's tier, scope, target level and leafness: `data/shopify-mapping.csv`.

**The miss rate is not "the taxonomy has no home for these products."** A hand probe of 50 unmapped nodes
(30 largest + 20 random, `scripts/unmapped_probe.py`, output `data/unmapped-probe.txt`) shows three distinct
causes, and only the third is a real hole:

1. **Loanword spelling.** `SHAMPOO` (719 products) vs the taxonomy's `Sampo`; `LIPSTICK` (482) vs `Lipstik`;
   `BLOUSE WANITA` (913) vs `Blus`; `COOKIES & BISKUIT` (827) vs `Biskuit`. Verified present by leaf-name
   probe: `Kesehatan & Kecantikan > Perawatan Tubuh > Perawatan Rambut > Sampo & Kondisioner > Sampo`;
   `… > Riasan Bibir > Lipstik`.
2. **A qualifier we put in the node name and the taxonomy puts in an attribute.** **Measured: 302 of our
   1,686 used nodes (17.9%), holding 42,621 products (40.1%), carry a gender/age qualifier in the node name;
   168 of them collapse onto a name shared with at least one other node.** 106 of the 302 reach a
   recoverable-stripped tier; the rest still miss — and some of the 106 land on `AMBIGUOUS` under the
   round-2 rule, because the collapse frequently produces several identically-named candidates
   (`Celana Pendek` has five). **This is a tree restructuring, not a
   rename.**
3. **A genuine hole** — §4 below.

## 4 · Limits, and what each number is a property of

- **The measured route is a property of eight regexes.** Each will have false positives and negatives. The
  masking rule (§1) removes the largest class of false positives but also removes true evidence when the node
  name happens to contain the word. A stricter instrument would hand-label a sample per kind; not done.
- **`net_content` at 36.6% of nodes is consistent with the catalogue-wide baseline** (30,417 of 106,161
  titles carry a unit token, 28.7%; `sql/results/baseline.json`, 2026-09-19) but is not the same measurement —
  the baseline counts titles, this counts nodes above a threshold.
- **The 20% threshold is a choice.** Raising it shrinks every count; lowering it grows the number of distinct
  sets. The per-node shares are in `data/node-attribute-need.csv` so any threshold can be re-derived without
  re-running the scan.
- **The inferred route's 776 names is a property of the 434 nodes that mapped**, which are biased toward
  nodes whose Indonesian name happens to match a translated global taxonomy — and **about a quarter to a
  third of those rows point at the wrong kind of product** (§2.1). It is not an estimate of what all 1,686
  would carry, and it is not a validated list. The conservative cut is 558 names over 284 nodes.
- **Six of round 1's seven named wrong matches survive the round-2 resolver fix**, because each has exactly
  one candidate: `KAUS PRIA` → men's undershirts, `TAS RANSEL PRIA` → a handbag-style backpack,
  `PAKAIAN MUSLIM ANAK PEREMPUAN` → girls' underwear, our root `Alat dan Buku Tulis` → a paper-products
  leaf, `KIPAS ANGIN` → fan remote controls, `MAKANAN BEKU` → frozen fish food. **Ambiguity detection does
  not detect wrongness**; only reading does.
- **The taxonomy's own gaps, verified by leaf-name probe over both locale builds (each 14,606 categories):**
  `Batik` **0**, `Mukena` **0**, `Sajadah` / `Prayer rug` / `Prayer mat` **0**, `Kebaya` **0**, `Kopiah` **0**,
  `Sarong` **0** (en), `Sambal` **0**, `Terasi` / `Shrimp paste` **0**, `Mi Instan` / `Instant noodle` **0**,
  `Kapur barus` / `Mothball` **0**. Against that: `Pasta & Noodles` (id `Pasta & Mi`) exists as **one node with
  five attributes and no children**, and `Snack Foods` carries 44 nodes including `Pork Rinds`
  (`Kerupuk Kulit Babi`). Those absences cover our `MIE, BIHUN, KWETIAU INSTAN` branch (node 99: **7 nodes,
  439 products in the subtree**; the mie-only sub-branch that the "instant noodle" absence bites is 3 nodes /
  394 products, including the 43 Indomie rows in node 612 — corrected after red-team round 1, MINOR 19), `BATIK PRIA` + `BATIK WANITA` (470), the Muslim-wear cluster
  (`MUKENA WANITA` 146, `SAJADAH` 58, `PECI` 201, `SARUNG` 172, `KERUDUNG WANITA` 314, `JILBAB WANITA` 57,
  `GAUN MUSLIM WANITA` 270, and the child nodes under `PAKAIAN MUSLIM ANAK …` 293 + 232), and
  `KAMPER / KAPUR BARUS` (140).
- **Currency.** The corpus is the committed `dist/` directory. Shopify's own README, fetched
  2026-09-19 at both `main` and the pinned commit (identical, md5 `5d197d41f6fc02b731ca95cfa93c9730`,
  `corpus/why-2026-09/shopify-readme-*.md`), states: *"The committed [`dist/`](./dist/) directory is
  deprecated and will be removed on **October 31, 2026**. Migrate to the release-asset URLs above before
  then."* Everything measured here remains true of the artifact measured; the artifact is being retired.
- **Not collected:** whether any of our unmapped nodes has a home under a taxonomy name no probe of mine
  guessed. The route that would settle it is a per-node hand mapping of all 1,252 — which is the adoption
  bill itself, and is the measurement the fork asks the human to price.

### Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 5** | ~~"they are now a **preference** with a global fallback, **so pass B is a superset of pass A**"~~ **Struck as unscoped.** The script's own assertion printed a non-zero violation. The claim is now scoped — *superset over the ten product roots* — the assertion is computed that way and prints **0**, and the two nodes lost under the non-product roots are named as excluded by construction. |
| **SERIOUS 9** | The resolver silently broke ties: **30 of 351 exact-tier rows** had >1 identically-normalised candidate and were recorded `EXACT`. Now **`AMBIGUOUS` whenever >1 candidate shares the winning normalised name**, with `passB_n_candidates` on every row. Mapped 485 → **434**; `AMBIGUOUS` 17 → **68**. `CELANA PENDEK PRIA` and `CELANA BOXER` are now `AMBIGUOUS`; `ATASAN WANITA` stays `UNMAPPED`. All inferred figures rebuilt (§2). **Six of round 1's seven named wrong matches are single-candidate and survive** — stated in §4. |
| **SERIOUS 9 (sample)** | The fix dropped 7 adjudicated rows out of the mapped set, so the random stratum was **topped up with 4 fresh random draws** and re-adjudicated. Random stratum wrong-rate **25% → 28.6%** (n=21, CI 14–50%); combined 17.5% → 21.6%. Provenance stated in §2.1. |
| **MINOR 17** | A **product-weighted** error rate is now published beside the node-share rates (21.5% wrong / 16.7% ancestor over the 14,290 products the sample covers), with an explicit note that it is not a population estimate. |
| **MINOR 16** | ~~"destroyed **58 correct** pass-A matches"~~ **Struck.** Round 1 itself noted several of the 58 were wrong anyway (`KAUS PRIA` is still adjudicated *wrong* here). Restated as "58 pass-A matches, some of them themselves wrong". |
| **Snapshot bound** | All three `sql/*.sql` dedup subqueries now carry the BRIEF §3.4 bound at 2026-09-19 10:27 UTC. Re-run: **all three reproduce byte-identical**; no figure changed. |

### Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **BLOCKING 3** | The gender/age qualifier was stripped from **both** sides; now **our side only**, and a stripped match must be **recoverable** on the target (`Jenis kelamin sasaran` / `Kelompok usia`). An **over-mapping rate is now published** (§2.1): 5 of a random 20 mapped rows point at the wrong kind, Wilson 95% CI 11–47%; 4 of 40 map to a genuine ancestor. The "mapped to an ancestor" population is reported both mechanically (176 of 485) and by hand (4 of 40), with the note that the mechanical flag over-counts. The ceiling is recomputed and published twice: **810 names / 347 sets** over all 485, and **574 names / 233 sets** over the 309 whose target is not obviously an ancestor. |
| **SERIOUS 5** | The thirteen root→vertical bindings were a hard filter that destroyed 58 pass-A matches (5,289 products). They are now a **preference with a global fallback**, so pass B is a superset of pass A. The one remaining exception — 3 nodes / 132 products under the `UNUSED` root — is deliberate and named in §3. |
| **SERIOUS 16** | The "639 nodes covering 90%" cut is now deterministic (`-products`, then `id`). Both scripts now print the same 223 / 491, and `data/shopify-attrs-for-our-90pct.json` contains exactly 491 entries. Revision 1's 185/436 and 186/439 were two admissible cuts of a tied boundary. |
| **MINOR 19** | `MIE, BIHUN, KWETIAU INSTAN` restated: node 99 is **7 nodes / 439 products** in subtree; 394 is the mie-only sub-branch. |
| **MINOR 23** | `Santan` and `Rice Cooker` were listed among "present" id-ID leaf names. No id-ID node is named `Santan` (there are `Santan & Minuman Kelapa` and `Santan & Krim Kelapa`) and none contains "Rice Cooker" (the id-ID name is `Penanak Nasi`). The list mixed en and id spellings; corrected. The **absence** probes — the load-bearing half — all verify at word boundary in both builds. |
