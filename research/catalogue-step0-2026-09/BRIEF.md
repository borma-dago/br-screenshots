# BRIEF — Step-0 catalogue concept questions · research pack · 2026-09-19

You are one of four research agents. Read this file completely before anything else. Everything you produce goes under **your own directory only**: `~/copilot/research/catalogue-step0-2026-09/briefs/<YOUR-ID>/`. You do not run `git` commands, you do not edit any file in either repository, you do not write to `/tmp`, and you do not post anything anywhere. Both repositories are read-only reference material.

## 0. The goal, in the owner's words (Irvan, 2026-09-19)

> goal: for each decision i know who uses it, who doesnt, what options are available, which one is cleanest / structurally correct. Even better if you can say why say amazon opt for option XXX. but yes "who uses" is extremely important -- if all platform uses only one option, that is a very strong evidence. when an option has multiple different use cases across platforms that needs to be elaborated further, eg you can try desigining to try and figure out what problems will it cause etc.

And: "dont half ass anything, just do it properly, if you try to half ass to save $$$ etc itll just end up more $$$ due to multiple times we have to come back to this issue." Depth is set by what the evidence needs, never by the question's tier.

**Therefore every question's section delivers, in this order:**

1. **The options available** — as the card lists them; extend only with a stated reason.
2. **Who uses which, and who does not** — a thirteen-row matrix, one platform per row: the record's own words, the section cite, the option it maps to. Then the tally per option with a *named* ambiguous list (a record's hedge travels into the tally; it is never silently assigned). **Unanimity is the strongest signal**: if every platform that has the concept picks one option, say so first and the design pass in §5 shrinks to a fit-check. A split is the signal to elaborate.
3. **Why each platform chose it** — the platform's *own stated* rationale where a primary artifact states one (a developer guide, a changelog, a design note), quoted and cited; where none is stated, the constraint that explains it (marketplace vs merchant tool, flat feed vs stored catalogue, single- vs multi-tenant, what the platform sells), **labelled "inference"**. Never a guess presented as the vendor's reason.
4. **Which is cleanest / structurally correct for us** — for every option the platforms split on, a design sketch against our real models to surface the problems it causes; for a unanimous option, one fit-check that it works in our code.
5. **Recommendation, labelled as judgement**, with confidence, what would reopen it, and what it forces in steps 1–5 of the Next Steps page.

## 1. What is locked, what is tentative, what is standing

### The two locks (2026-09-16, #10966 lock comment — `evidence/issues/10966.md`, last comment)

- **Lock 1 — the Category *is* the product type.** One object. The existing `Category` tree owns the attribute definitions and the axis eligibility. No separate `ProductType`; `ProductClass` retires. `ProductAttribute.product_class` becomes `ProductAttribute.category`. Confirms D1 · D2 · D3.
- **Lock 2 — every product belongs to a product variant group.** Mandatory, including families of one. The group is a **separate table**; the sellable row (`Product`) keeps price, stock, barcode and visibility and gains a `NOT NULL` FK to the group. Shape B. Re-closes D13 (which had been shape A, a parent `Product` row — superseded). Table naming (L2.3) open.

**The five conditions the locks were taken on (binding on every brief):**
1. Build the category attribute schema editor first — there is no UI for `ProductAttribute` at all today.
2. **Take the four shipping dimensions (weight, length, width, height) out of the attribute system and make them `NOT NULL` columns on the sellable row, before Lock 1.** After this, `manufacturer` is the entire existing attribute corpus. State your numbers as-measured *and* post-condition-2 wherever the four dimensions matter.
3. Ship Lock 2 before Lock 1 (Lock 1 is a day-one no-op with one `ProductClass`).
4. Lock 2 ships with: a dimension-count mirror on the member via composite FK; family-level aggregates for ranking; a dual-write migration (not a Python property); explicit writable serializer fields; a stable opaque feed key; a decision on the Elasticsearch collapse hit count.
5. Lock 1 needs a per-node "accepts products" switch, a guard on the category move, and an owner for the catch-all nodes.

**Reopen triggers:** families of one prove expensive in measured latency → shape C competitive again; staff cannot keep a ~639-node schema coherent or catch-alls cannot be cleaned → flat separate type list (~40–120) becomes better; the axis key cannot be made genuinely derived → B loses its distinguishing constraints.

### Tentative (2026-09-15, "Shared Or Per Member" — `evidence/pages/shared-or-per-member-2026-09-15.txt`)
images member-first with family fallback · price/stock/`upc` on the member · visibility (`is_public`, `is_active`) on the member · `ProductAttributeValue` on the member (no migration of existing rows) · category on the family · brand deferred to the attribute decision · attributes on both levels, **mechanism deferred** (that is card A5). Title: open ("composed or stored?"). Description: evidence-settled at family by the field survey (FAM confirms or overrules).

### Closed on 2026-09-18 by Irvan
**One category per product** (as Amazon has one product type). First half of D14. Not to be reopened.

### #10778 standing decisions (`evidence/issues/10778.md`) — confirm, re-express, or propose superseding; never silently contradict
Decision B (settled 2026-08-09 after nine tracks + eight passes; its corpus is on this machine at `~/copilot/research/product-attribute-variant-2026-08/`, 26 files — `F2-axis-value-shape.md`, `H1-variant-axis-object-vs-attribute.md`, `T1`, `T2`, `T6`, `E2-redteam-proposal.md`, `INDEX.md`):
- **V1** axis *names* come from a shared staff-extendable catalogue (closed names, open values).
- **V2** one storage shape for every dimension + a per-dimension governance flag (eBay `aspectMode`, Shopee `input_type`).
- **V3** which setting each dimension gets: deferred.
- **V4** an axis value is a **single text label** (`"200 ml"`, not `{200,"ml"}`), hand-ordered by a position column; "nobody drives a picker from a stored quantity".
- **V5** the value-ordering column is missing (new work).
- **V6** freeform values get derived suggestions + normalisation on write.
- **C5** one global name catalogue, not scoped per category.
- **C8** one `Ukuran` governed by the flag; never split into two size dimensions.
- **C2** the family has a page, rendered at every variant's own URL with that variant as the hero; a bare family URL picks a hero via `display_order`.
- **M4** a same-product banded or promo pack is an ordinary dimension value; which axis is staff judgment.
- **S1** the family is never buyable (locked 08-10; stands under shape B).
- **Decision A = S5 + C7 is superseded by Lock 2** (S5 "a variant group is a kind of product" is shape A). C7 "exclusion structural, not advisory" is satisfied by construction under shape B.
- **The re-expression of Decision B under D3 is already on the record** (#11031 child-issue map): *the label becomes an attribute value, the governance flag becomes the attribute's input type, the ordering column moves to the value.* Start from that mapping.
- The MASTER (#11031) notes #10778's evidence pass was found unsound in parts (two claims retracted, fabrication-class citations). Re-verify any #10778 claim you lean on.

### Errata — statements in the sources that are wrong or superseded
- Shape-A statements still present: #11031's ledger and status diagram ("D13 ✅ a parent `Product` row"), the matrix text ("our closed pieces are Amazon's and Magento's structure: a parent row in the same table"), #10778 S5. All superseded by Lock 2.
- #10778 V6's manufacturer figures ("5,564 → 4,290, 23% redundancy, 19% junk, 37% populated") were retracted by the #11031 audit. Use the baseline below.
- The matrix's D9 framing ("as bare labels SOKLIN 215 GR · 2.7 KG sort wrong — a label has no magnitude") contradicts #10778 V4 ("every surveyed system hand-orders picker values with a position column"). Neither source names the conflict. **ATTR-VALUE (A4) must name and resolve it.**
- Product totals differ by date across the record (104,733 on 2026-09-03; 105,771 on 2026-09-15; 105,786 matrix; 105,885 lock comment). All valid at their date. Use the baseline (106,161 on 2026-09-19) and cite older figures only with their date.
- The lock's working documents (`~/copilot/research/catalogue-decision-2026-09/`) are NOT on this machine. Their conclusions are in #11230, the lock comment and the pages. Flag any claim you could not re-open at source.
- Records cite backend commit `a91a48e152`; the code has moved (e.g. #11169 made `Product.main_category` PROTECT). Re-take every cite at the pins below.

### Rejected by Irvan on 2026-09-18 — do not re-propose as questions
who fills the data (AI-assisted, moot) · external channels · schema evolution as a decision (a consideration only) · title authored vs generated (AI-assisted, in design) · search rows per family vs member (decided, #10778 Q1) · non-product sellables · tree-restructuring ownership.

## 2. The thirteen questions and who owns which

The list is **Step 0 of "Catalogue Next Steps" v7** (2026-09-18) — `evidence/pages/catalogue-next-steps-v7.txt`. Read your cards there verbatim: each carries the question, one example line, the options, what it touches, and a research pointer ("Sunday: …"). **Execute the pointer.**

| Brief | Cards | Page tier |
|---|---|---|
| **ATTR-DEF** | A1 what is an attribute, which facts are attributes at all · A2 is a variant dimension an attribute or its own object (= D3; confirm or reopen on the record) · A0 what are attributes for, and are some hidden | 1 |
| **ATTR-VALUE** | A3 is "Rasa" one shared type or per-category (the category × attribute matrix) · A4 what is a value and where does its allowed list live (subsumes D8, D9) | 1 |
| **TREE** | B1 do nodes have types · B2 can a product sit on a non-leaf node · B3 how deep should leaves go (= D16) · B4 what flows down, per kind of fact (= D15) · **the Step-1 fork**: keep authoring our own tree vs adopt the Shopify Standard Product Taxonomy; record "one category per product" as closed | 1 |
| **FAMILY** | A5 does an attribute belong to the product (family row), the variant (member), or both (subsumes D11, touches D10) · C1 what may siblings differ in, what must they share (incl. **barcode identity**) · C2 is a 6-pack / bundle a variant of the single or a separate product · C3 can a family have sub-families (= D12) | 2 · 2 · 2 · 3 |

Page tier orders the synthesis; it does **not** thin your research.

**D-decisions in scope because a card subsumes them:** D3 (A2) · D8, D9 (A4) · D11 + the "touches" of D10 (A5) · D12 (C3) · D15 (B4) · D16 (B3). **Out of scope (steps 1–5 of the page):** D4–D7 axis mechanics, D10 beyond what A5 touches, D14 second half, D17, D18, naming L2.3, feed key, collapse totals, the variant label, the four decision-free code items. End each question with one paragraph on what your answer forces there, and stop.

### Couplings — one owner each; the other brief cites, never re-decides
| Coupling | Owner | What the owner produces |
|---|---|---|
| A1↔A2 an axis is an attribute only if A1's rule admits it | ATTR-DEF | A1 first, then A2 |
| A2↔A4 an option row exists only if a value can be a row | ATTR-VALUE decides the value shape; ATTR-DEF states A2's dependence on it | — |
| A0↔A4 filters want shared value rows | ATTR-VALUE | the value-shape consequence; ATTR-DEF states the use |
| A3↔B4 a subscribed shared type is what "flows down" would carry | TREE (B4) for the tree side; ATTR-VALUE (A3) for the type side | each cites the other's section by heading |
| **A3↔B3 one measurement**: "the distinct attribute names our 639 main nodes would need" / "how many of our leaves share an identical attribute need" | **TREE** computes it once → `briefs/TREE/node-attribute-need.md` (+ SQL) | ATTR-VALUE cites that file |
| A4↔A5 a family-level value needs a home | FAMILY (A5) for the level; ATTR-VALUE (A4) for the value | — |
| A0↔A5 visibility per channel vs per level | ATTR-DEF (A0) | FAMILY cites |
| C2↔A2 pack form as an axis | FAMILY (C2) | cites ATTR-DEF's A2 verdict |
| fork↔A3, fork↔A4 the taxonomy's closed value lists and missing net-content attribute | **TREE** states the taxonomy facts (from the corpus below) | ATTR-VALUE draws the value-model consequence |

## 3. Method

### 3.1 Who uses it — the thirteen platforms
Amazon (#10976) · Shopify (#11011) · Google Merchant Center (#11013) · eBay (#11045) · Walmart (#11046) · Shopee (#11047) · Tokopedia (#11048, two eras — never merge them) · Square (#11049) · Salesforce B2C (#11050) · Akeneo PIM (#11069) · WooCommerce (#11080) · commercetools (#11081) · Magento (#11082). Records are in `evidence/issues/<n>.md` (body + companion comments). They are large; navigate with the **per-decision evidence comments on #11031** (`evidence/issues/11031.md`, comments headed "Per-decision evidence, ten records" parts 1–2, and the three 2026-09-15 passes) and grep the record for the section cited. Cite as `#<n> §<section>`.

"Tried and tested" weighting (the matrix's proposed judgement, use it as a reading aid, not as a vote): Amazon 100 · Shopify 85 · eBay 80 · Google 70 · Walmart 65 · Shopee 60 · Magento 60 · WooCommerce 55 · Salesforce 50 · Tokopedia 45 · Square 40 · commercetools 35 · Akeneo 30.

### 3.2 New-source pass — allowed for exactly the card pointers, and for "why"
Several pointers name sources the records never collected (Meta's variant-consistency rules; GS1 and BPOM net-content rules; Square's custom-attribute caps; Shopify metafield storefront visibility; Akeneo option order and metric type; eBay `aspectUsage`; Shopify's food-branch depth per node; Walmart count/multipack fields). Vendor rationale for "why" is also new collection. **Load the `external-research` skill before collecting** and hold to it: primary artifact plus a second independent route; identifiers verbatim; a fact is verified or explicitly "not collected + the route that would settle it"; no verdicts inside the data. Everything fetched lands in `~/copilot/research/catalogue-step0-2026-09/corpus/<platform-or-source>/` — never in a scratchpad or `/tmp`. List what you fetched in your §7. **Credential-gated items (#11068) are not re-attempted.**

### 3.3 Our code — two pins, read-only
- Backend: `/home/irvan/copilot/py-5` at solvent-master `4f99dc01c6`. Catalogue: `py/mono/solvent/catalogue/{models.py,product_attributes.py,validators.py,managers.py}`, `py/mono/solvent/catalogue/upc/`, `py/mono/solvent/api/apiproduct/`, `py/mono/solvent/api/apicategory/`, `py/mono/solvent/search/`, the Merchant feed, basket and biteship readers of `product.attr.*`.
- Frontend: `/home/irvan/copilot/ts-layer2` at ts-master `82187a17bd` (a detached read-only worktree; the `ts/` inside py-5 is stale — never cite it).
- Every consumer is found by search (Grep), never from memory, and cited `path:line` at the pin. Say which call sites change per option and which inherit for free.

### 3.4 Our numbers — BigQuery
Project `solvent-staging`, dataset `production_append_public` (append-only CDC). **Every query is pinned to the shared snapshot** — `source_timestamp` is INT64 epoch milliseconds, and the mirror is append-only, so bounding it reproduces the state at that instant no matter what production writes later. Current state as of the snapshot = latest row per `id` at or before the bound, excluding DELETE:
```sql
SELECT * EXCEPT(rn) FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn
  FROM `solvent-staging.production_append_public.<table>`
  WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')   -- the shared snapshot bound
) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'
```
An unbounded query drifts (a red-team re-run of one brief's query moved 1,748 → 1,747 within hours). Verified 2026-09-19 22:30 WIB: the bounded `baseline.sql`, `nodes.sql` and `indomie.sql` reproduce the 10:27 UTC results exactly (64 measures, 0 differences; both listings byte-identical). The unbounded originals are kept in `sql/unbounded-originals/`.
Run: `bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < your.sql`. Save every query as `briefs/<ID>/sql/<name>.sql` and its result beside it; every number in your brief carries the file name and the snapshot date. Shared baseline (`sql/baseline.sql`, results in `sql/results/baseline.json`, **snapshot 2026-09-19 10:27 UTC**):

| Measure | Value |
|---|---|
| products_total / active / public / offline_only / active_online | 106,161 / 91,952 / 106,102 / 71,874 / 23,299 |
| productclass_rows / productattribute_rows | 1 / 5 (`manufacturer` text req · `weight` `length` `width` `height` float req) |
| pav_rows_total; per attribute | 471,143; four dimensions 106,161 each; manufacturer 46,499 |
| manufacturer rows / distinct raw / distinct trim+lower | 46,499 / 5,580 / 5,541 |
| manufacturer value `'0'` / junk set {0,-,00,000,.} / numeric-only / no ASCII letter / used once | 12,512 / 15,475 / 12,792 / 15,516 / 2,788 |
| products without manufacturer row; active-online without row; active-online with no-letter value | 59,662; 0; 2,843 |
| categories total / leaf / non-leaf / roots / max depth / used as main_category | 1,892 / 1,553 / 339 / 13 / 8 / 1,686 |
| products on non-leaf / on root; used non-leaf nodes / used leaf nodes; used nodes <10 products | 19,522 / 1,724; 292 / 1,394; 609 |
| nodes to cover 50% / 80% / 90% of products | 114 / 398 / 639 |
| catch-all nodes (name matches LAINNYA / LAIN-LAIN / OTHER) / their products | 42 / 3,566 |
| ProductCategory M2M rows / distinct products / products with >1 | 20,520 / 20,519 / 1 |
| image rows / products with ≥1 image | 63,363 / 30,740 |
| Indomie rows all / active; active with GS1 code | 43 / 33; 33 (listing: `sql/results/indomie.csv`, all in category 612) |
| titles with unit token / multiplier "N x M" / "ISI N" / pack word | 30,417 / 2,168 / 3,519 / 1,583 |
| upc length 13 / 12 / 8 / 7 (weight-embedded) / other | 103,981 / 1,532 / 16 / 380 / 252 |
| **upc prefix `987` server-generated (no real barcode) / `984` deprecated custom / GS1 checksum-valid (not 984/987) / checksum-invalid at 8/12/13 / 13-digit starting `2x` (GS1 restricted-circulation)** | **60,238 / 0 / 45,166 / 258 / 71** |

`sql/results/nodes.csv` = every category with products (main_category), depth, numchild, cumulative share. `sql/results/indomie.csv` = the 43 Indomie rows with upc, flags, category, description length, image count, attribute values.

### 3.5 Which is cleanest — the design pass
For each option the platforms split on: the tables/columns/constraints it needs against our real models; the write path (there is exactly one production create path, `api/apiproduct/staff_serializers.py`, inside `transaction.atomic()`); the staff editor it implies (no `ProductAttribute` UI exists today); search (Elasticsearch 7 via haystack; the index re-hydrates from Postgres; collapse on a family key is the grouping mechanism); the Google Merchant feed; the customer page; the migration shape; which invariants become database constraints vs validators; forced forks and call sites counted. Write the sketch in a side file (`briefs/<ID>/design-<card>.md`) and summarise its problems in the brief. For a unanimous option, one fit-check.

### 3.6 Corpus already fetched (single owner: coordinator)
`corpus/shopify-taxonomy/` — a sparse clone of `Shopify/product-taxonomy` at commit `ad206247` (2026-08-27), `dist/en` and `dist/id-ID`: `categories.txt/.json`, `attributes.txt/.json`, `attribute_values.txt/.json`, `taxonomy.json`. TREE reads it for B3 and the fork; ATTR-VALUE reads it for A3 ("how many categories reuse Flavor") and the fork↔A4 consequence. **Do not re-fetch it.**

## 4. Output contract

`briefs/<ID>/<ID>.md` — one section per card, in this fixed shape, plus a short header naming the cards, the date, the pins, and the files beside it.

```
## <Card id> · <question as the card states it>
### 1 · Options
### 2 · Who uses which, who does not  (13-row table: platform · record's words · cite · option; then tally with named ambiguous list; unanimity or split stated first)
### 3 · Why  (per platform: stated rationale quoted+cited, or "inference:" + the constraint)
### 4 · Our code today  (consumers by search, path:line at the pin; per option what changes / inherits free; both stacks)
### 5 · Our numbers  (the card's measurements; sql file + date; as-measured and post-condition-2 where relevant)
### 6 · Cleanest / structurally correct for us  (per split option: the problems it causes, from design-<card>.md; unanimous: fit-check)
### 7 · Recommendation  (judgement · confidence · what would reopen · what it forces in steps 1–5)
### 8 · Limits and corrections  (not collected + route; new sources fetched; red-team findings and resolution, appended later)
```

Keep the brief itself readable (~8–10K characters per card); put full quotes, design sketches, SQL and long tables in side files and link them. **Nothing of substance is dropped for length.** Label every judgement as judgement. Quote records verbatim with cites; never paraphrase a hedge away. When you lean on a #10778 item, say whether you confirm it, re-express it, or propose to supersede it.

A red-team agent that did not write your brief will: re-open every `path:line` at the pins, re-run every SQL, re-derive every tally from the records, check every "why" is a cited statement or a labelled inference, check every card pointer was executed, search for consumers you missed, and attack your recommendation. Write so that survives.

## 5. Evidence pack index
- `evidence/issues/10966.md` decision record (last comment = the lock; the "Open decisions D4–D18" comment = current state of each open decision with audit corrections) · `11031.md` MASTER + per-decision evidence + 2026-09-15 passes · `11230.md` stress test + system design comment · `11188.md` tree management + inheritance correction · `10778.md` implementation issue, Decisions A/B · `10942.md` (closed, scoping only) · `11068.md` credential checklist · `11126.md` banded pack = own SKU · `10943.md` apparel per-size · `10824.md` (closed, archive) · the thirteen records.
- `evidence/pages/catalogue-next-steps-v7.{txt,html}` **the question list** · `catalogue-decision-matrix-2026-09-16.{txt,html}` per-decision platform cells (pre-lock text; see errata) · `shared-or-per-member-2026-09-15.{txt,html}` field-level survey and tentative decisions.
- Also readable with the Artifact tool if needed: "Does Every Product Need A Group?" (`https://claude.ai/code/artifact/37ecee56-1e94-40f4-8570-7860df88b614`) and "Stress-Testing The Two Locks" (`https://claude.ai/code/artifact/257452dd-f763-4d17-95fe-9dc0e1218079`).
- `PLAN.md` — the approved plan, for context.
