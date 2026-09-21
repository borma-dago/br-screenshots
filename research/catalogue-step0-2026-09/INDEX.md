# INDEX — the thirteen Step-0 questions, answered with data · 2026-09-19

**Status:** final, 2026-09-19 (late evening WIB). All four briefs went through two adversarial rounds each and a final fix pass; every finding was fixed at the root or disputed with a cite, and every struck claim remains visible beside its correction. Round-2 counts: FAMILY 0/3/5 · TREE 1/10/9 · ATTR-DEF 0/4/5 · ATTR-VALUE 0/5/4 (blocking/serious/minor), all applied. Every SQL file in the pack is pinned to the shared snapshot and reproduces byte-identically.

**What this is.** For each card on *Catalogue Next Steps* Step 0 (2026-09-18): the options, who uses which and who does not (13 platforms), why, which is cleanest for us, and a judgement-labelled recommendation with confidence and reopen trigger — produced by four Opus research agents, each brief red-teamed by an independent Opus reviewer (round 1: 46 / 31 / 26 / 28 findings; every finding fixed at the root or disputed with a cite; nothing silently deleted). Every number carries a SQL file pinned to the snapshot **2026-09-19 10:27 UTC** (`sql/baseline.sql`, `BRIEF.md` §3.4); every code cite is `path:line` at solvent-master `4f99dc01c6` / ts-master `82187a17bd`. Nothing here is decided; the recommendations are the agents' judgements for Irvan to accept, change, or reject.

**Briefs:** `briefs/ATTR-DEF/ATTR-DEF.md` (A1 A2 A0) · `briefs/ATTR-VALUE/ATTR-VALUE.md` (A3 A4) · `briefs/TREE/TREE.md` (B1–B4, the fork) · `briefs/FAMILY/FAMILY.md` (A5 C1 C2 C3). Each carries its matrices, design sketches, SQL, corpus notes and red-team files beside it.

---

## 1 · The verdicts, in Step-0 order

Legend: **unanimous / near-unanimous** = the platform evidence points one way; **split** = the design pass decided it. Confidence is the brief's own.

### A · What is an attribute?

| Card | Who uses which | Recommendation (judgement) | Confidence |
|---|---|---|---|
| **A0** what are attributes for; hidden? | **10 of 13** put visibility on the *definition* (5 with a named qualification); 1 of 13 per channel | Visibility on the definition as **purpose flags** — `is_customer_visible`, `is_filterable`, `display_order` — not one boolean. Uses ranked: spec sheet (live and broken today) › internal rules (read columns; keep it so) › variant picker › Google feed (sends nothing today) › search filters (need A4's rows). No per-category visibility (that is A3's membership), no per-channel visibility now. Make `code` `UNIQUE` and immutable once values exist. | high on "on the definition"; medium on the flag set |
| **A1** what is an attribute; which facts are attributes | **9 of 13** draw the same line (universal + code-read → column; category-specific + human-read → attribute); the 3 that do not are a PIM, an EAV monolith and a feed. 8 of 13 keep definition and value as two objects | Option 1, made decidable: *a fact is a column when a code path reads it or a DB constraint must hold over it; an attribute when only humans read it and applicability depends on the category.* Plus **option 4** (Magento's `backend_type='static'`): one definition registry over both storages with a `storage` discriminator — so lock condition 2 moves four *values* to columns while the four *definitions* stay. **Brand:** an attribute with option rows now, promoted to its own table only when it needs a page/logo/navigation (the trigger three vendors state); never derived from `manufacturer` (69.6% are `PT …` companies, 3.2% match the title brand). | high on option 1; medium-high on option 4; medium on brand |
| **A2** axis = attribute or own object (= D3) | **Tie on declaration** (4 marked-attribute / 4 own-object / 1 neither / 4 unassignable — re-derived, holds); **6–4 lean on value storage** to the same store | **D3 CONFIRMED, not reopened**, on the storage argument: an axis is a category-owned `ProductAttribute` marked eligible + a thin per-family dimension row (`group`, `attribute`, `position`); a member's axis value is its ordinary `ProductAttributeValue`. One write path, one editor, one filter path instead of two. **Conditional on A4 giving values rows** — if A4 had answered "free strings", A2 must reopen. | medium-high |
| **A3** "Rasa" shared or per-category (the attribute matrix) | **4–3 among the unambiguous** for a shared global type that categories subscribe to (6–3 counting hedged rows); the 3 per-category platforms are all marketplaces that do not own their sellers' data model | **(a′)** one global attribute registry + a `CategoryProductAttribute` **membership row** carrying `required` / `display_order` / optional `name_override`; a second *type* (not a subsetted list) when two categories need different vocabularies. Our own reuse is head-heavy (`net_content` on 617 nodes, `colour` 494, `flavour` 199 of 1,686), the shape (a) is built for. Makes `UNIQUE(code)` expressible; a category move orphans (fixable) rather than mis-attributes. | medium-high on (a) over (b) — written into the file after round 2 (the measured reuse route alone carries it; TREE's inferred route is discharged as support, see §2); medium on `name_override` |
| **A4** what is a value; where its list lives (= D8, D9) | **13 of 13** store the value the same way at the platform's own level (no disagreement with the matrix's D8 tally); ordering: 5 systems hand-order a shared list, 3 generate order from the label, **0 generate it from a stored quantity** | **(c) hybrid by type** (select-typed → shared option row; free text → string), **list on the attribute**, quantities as **label + magnitude derived on write** into a canonical base unit. Honest bill: one table, one column, one enum entry, one validator, one type-alias member, one API field, one form type. Normalisation alone reaches 1.6% of the manufacturer mess; the junk is 31 distinct letterless values over 15,516 rows, which rows delete in 31 operations. | medium-high on (c)+(A) — lowered from high once the honest seven-item bill replaced "two lines"; medium-high on derived magnitude; high that string-plus-normalisation alone is insufficient |
| **A5** attribute on product, variant, or both (= D11) | **Split with no plurality once "pinned" is split by mechanism**: 4 declared on the definition · 2 fixed by structure · 1 per family · 4 absent (the four with no family content row) · 1 read-time fallback · eBay ambiguous | **A5-a — level pinned on the definition**: `ProductAttribute.level` (family \| member, default member) + a nullable `variant_group_id` beside `ProductAttributeValue.product` with `CHECK (num_nonnulls(...) = 1)` and two partial uniques. No `SameForAll` (family level *is* it); fallback kept for images only. Day-one no-op: `level` defaults member, all 471,143 rows untouched, the 2026-09-15 tentative decision survives. Card correction: Shopify is *not* a per-family example (`MetafieldDefinition.ownerType` is one value). | moderate-high |

**The V4-vs-matrix conflict, resolved (A4):** both are true — V4 ("a single text label, hand-ordered; nobody drives a picker from a stored quantity") describes *how a picker can be ordered*, the matrix ("a label has no magnitude") describes *what a label does by itself*. Neither priced the alternative: hand-ordering costs 886 labels (399 inside real size families) plus renumbering on insert; a derived magnitude costs 0 and is correct on the 782 of 1,993 size families that text order gets wrong. V4's core claim (the label is the record) is confirmed; its "ordering fails as an argument" is re-expressed as "ordering costs"; its "splitting forfeits nothing, those belong to #10942" is superseded because #10942 is closed and never carried those capabilities — **the typed-quantity capability has no owning issue today.**

### B · What is a category node?

| Card | Who uses which | Recommendation (judgement) | Confidence |
|---|---|---|---|
| **B1** node types? | **8 of 13** one kind; Square alone has node types (a till/kitchen artefact its vendor warns about); **no platform has a per-node switch** — Akeneo's `only_leaves` is **per-tree** (a correction to the card and to lock condition 5) | **(c)** one kind with a per-node `accepts_products` switch, recorded as a **cleanup instrument, not a model of the world** — a zero-row migration and the only option that lets the 19,522 non-leaf products be cleaned incrementally. "One precedent of thirteen at tree scope; none at node scope." | medium |
| **B2** products on non-leaf nodes? | **8 permit** (incl. both central authors, Amazon and Shopify) · **3 forbid** (eBay, Shopee, Tokopedia B — Walmart miscounted on the card: its feed has no category field) · every leaf-only platform authors its tree centrally with a per-leaf policy table | **The switch, defaulted `True` — explicitly NOT leaf-only.** Our 292 used non-leaf nodes, hand-read (48 nodes = 70% of the products): under-filed 52% · **real residual types 21.9%** · mixed 10% · catch-all 9% · not-a-type 4% · root-parking 3%. Leaf-only would re-home 19,522 rows of which ~22% cannot be re-homed without inventing nodes. | high on "not leaf-only"; medium on the switch |
| **B3** how deep; what earns a node (= D16) | Granularity for the same domain spans **107 : 764 : 5,595 : 14,606**; 7 platforms carry a per-node schema, 6 central + **Salesforce, the one merchant-authored precedent**; every published deep taxonomy is at least as deep as ours (Shopify 8 levels = our max 8) | **D16 = (b)** — a schema on a *subset* of nodes, the rest inheriting; subset = where the measured attribute need differs from the parent's; **no depth cap**; a separate ≥10-product pruning rule (609 nodes / 2,545 products). Authoring bill is bounded by *distinct sets* (68 measured; 220–316 inferred over the mapped quarter, rev 3) not by 1,686 nodes. **B3 and B4 are one decision.** | medium-high on (b); low on the threshold |
| **B4** what flows down, per kind of fact (= D15) | Like-for-like denominator (internal nodes own a schema, so inheriting is a real choice): **1 of 2** — Salesforce inherits, Shopify does not (and authors 14,606 nodes centrally); eBay inherits the fact it attaches tree-wide (features) and not the leaf-only one (aspects) — direct evidence for *per kind* | **D15 is not one switch — (d) per kind of fact.** Definitions: **(b) inherit, add-and-override, never remove**. Requiredness inherits with the definition, a child may tighten. Allowed values inherit, a child may narrow (A4 owns the model). Age-walling **must** flow by ancestry (today's exact-id list is a live bug). Replenishment and `is_public` already flow. `accepts_products` must **not** flow. Our own code already carries six kinds of category-derived fact resolved by four mechanisms. | high that it is per-kind; medium-high on (b) for definitions (raised from medium once the like-for-like precedent was derived) |
| **The fork** own tree vs Shopify taxonomy | **0 of 13 adopt another organisation's taxonomy as their tree**; the two that touch a second taxonomy ship a mapping (Shopify → Google: 14,528 rules) or run a dual tree (Tokopedia B) | **Keep authoring our own tree — (a) now; (c) "hold a mapping" deferred as a named migration path, not recommended.** The taxonomy has **no node for instant noodles** (Indomie joins spaghetti), none for Batik / Mukena / Sajadah / Sambal / Terasi (~2,800 products), and **no net-content attribute**; only **25.7% of our used nodes (32.7% of products) map mechanically and 28.6% of those map wrong** (Wilson CI 14–50%; the figures moved ~20% on each of three re-measurements, which is itself the finding); 302 nodes (40% of products) carry a gender/age level the taxonomy models as an attribute. Option (c) was priced honestly in the final pass: it pays the identical our→Shopify mapping bill, the 14,528 + 5,754 published rules take a *Shopify* category as input and relieve none of it, and nothing consumes a Shopify id today (the Google feed builder never touches category). Take the 8,240-name attribute vocabulary with closed `id-ID` value lists as seed for the registry (V1). | medium-high on (a); (c) deferred |
| **Closed** one category per product | — | Already true in code on both stacks (the M2M has no production reader). **Live consequence for D14's second half:** 3,402 rows (3,209 active) sit under roots that are not product types — `UNUSED` (shop-in-shop display areas), `BELUM DISORTIR`, `INVENTORY KANTOR` — and need a non-type home *before* Lock 1 makes them types. | — |

### C · What makes products a family?

| Card | Who uses which | Recommendation (judgement) | Confidence |
|---|---|---|---|
| **C1** what siblings differ in / share | **8 of 13** say siblings must not differ in title, description or category (3 police it on flat rows, 5 own it on the family); **12 of 13** forbid one product in two families | **C1-ii — family-owned content, member-owned commerce.** Siblings differ only in axis values, price, stock, barcode, visibility, images (+ a short label); **must** share the category, enforced in the DB by a composite FK on `(variant_group_id, main_category_id)`; **should** share the brand (advisory until a brand attribute exists); one product, one family, by construction. **Description = family confirmed as the home, overruled as a silent migration**: 3,912 of 10,090 proxy families have a different description on every member; the merge screen must present each losing description. **Title: composed** (`group.title + label` via one `get_display_title()`), at an honest cost of **nine** consumers across four apps including a shared search template. **#10778 S1 confirmed and now free** (the group is a different table: no `upc`, no price, no basket FK — the "make `upc` nullable" work is unnecessary). **#10778 C2 re-expressed**: the hero survives (Walmart requires exactly one primary); the bare family URL is dropped (the route is member-keyed; every existing URL keeps working). | high on category / one-family / barcode; moderate on description; low-moderate on the *cost* of composing the title |
| **Barcode identity** (the kept "Sunday measurement") | GS1 §2.1: *each style, colour and size variation … assigned a unique GTIN* | `upc` is unique by constraint, so "duplicates" is zero by construction. Provenance is the real measure: **57% of all products carry a server-generated `987` code, but that is an offline-stock artefact — on the active-online surface where families matter, 90.6% carry a real GS1 GTIN** (2,152 of 23,299 minted). Across 10,090 proxy families: 5,303 all-GS1, 4,045 all-minted, **664 mixed → flag at merge**. Exclude the 380 weight-embedded rows from axis eligibility (their code identifies a weight-priced class). All 33 active Indomie rows carry Indofood GS1 codes. | high |
| **C2** 6-pack / bundle: variant or separate product? | **No vendor artifact forbids count as an axis** — 2 name it (Amazon `NUMBER_OF_ITEMS`; Walmart `Count`/`Multipack quantity`), 10 can express it, 1 not collected; three restrict axis eligibility by another mechanism. Card correction: (a) and (b) are not alternatives — Amazon has both `VARIATION` and `PACKAGE_HIERARCHY` | GS1 splits our one word into three: **consumer multipack** (§2.3, same level as the single, new GTIN) → **count is an axis**; **carton** (§2.8) → **not a product** (already `ProductMeta.quantity_per_box`); **banded pack of different products** (§2.9) → **a separate product with no family link to its components** (it may itself be a family). One rule: *a row exists iff it is scanned and stocked as its own unit; two rows are siblings iff they differ only in axis values.* "Sachet vs bottle" is a different axis from "1 vs 6". **#10778 M4 re-expressed**: true for `2×500 ml`, not for #11126's Bango-plus-sachet. **Baseline correction:** of 2,168 "N x M" titles, 2,055 are dimensions (bedsheets, gauze); the honest multipack population is 3,633 (3.4%), and only ~727 have a plausible single in the same category. | high on carton and banded pack; moderate on count-as-axis (legitimate everywhere, but 80% of packs have no single) |
| **C3** sub-families? (= D12) | **9 of 13 one level**; the 2 that nest cap at exactly two (Akeneo — reason: content placement per colour; Salesforce `VariationGroup`, Beta) | **C3-a — one level, enforced by not building the column.** No `parent_id`, no validator. Two-dimensional families are two axes on one family (D6 permits). Our grids are ragged (Indomie: one flavour at two sizes, 31 at one) and 71% of products have no image, so Akeneo's reason does not apply. **D12 = (a).** | high |

---

## 2 · Cross-brief consistency — checked by the coordinator

| Coupling | Result |
|---|---|
| A1↔A2 | Consistent: A2 derives from A1's rule; D3 confirmed conditional on A4. |
| A2↔A4 | **Satisfied**: A4 gives select-typed values rows, which is A2's condition. |
| A0↔A4 | Consistent: A0 ranks filters last pending rows; A4 supplies them. |
| A3↔B4 | Consistent: A3's membership row is what B4 inherits ("does a membership row apply to descendants" — one boolean); both put requiredness on the (node, attribute) row. |
| A3↔B3 (one measurement) | TREE computed `node-attribute-need.md` (now rev 3: 434 mapped, 28.6% over-mapping, inferred ceiling 776 names / 316 sets, conservative 558 / 284). ATTR-VALUE leans on the **measured** route only (8 kinds over 1,686 nodes; `net_content` 617, `colour` 494, `flavour` 199) and, after reading rev 3, **discharges the inferred route as support** — the rate went up on re-measurement, the figures moved every round, and even a perfect mapping would measure the taxonomy's concentration (`Warna` on ~80% of its 14,606 nodes) rather than our reuse. Retained only as an order-of-magnitude ceiling for the adoption bill. Consistent. |
| A4↔A5 | Consistent: option rows are an FK from the same value row set whichever level owns the value. |
| A0↔A5 | Consistent and precedent-backed: level and visibility are independent fields of the same definition (commercetools, Shopify); "family-level = visible" has no precedent. |
| C2↔A2 | Consistent: count as an axis requires D3 (a), which A2 confirms. |
| fork↔A3, fork↔A4 | Consistent: TREE keeps the tree and proposes the taxonomy vocabulary as seed; ATTR-VALUE's global registry is where that seed lands; A4's closed lists match the taxonomy's shape, and its net-content gap is why A4 needs derived magnitude. |
| **#10778 C5** (one global name catalogue, not per category) | Three readings converge: TREE *confirms* for names / re-expresses value lists; ATTR-DEF marks it *at risk under Lock 1* and refers it to A3; ATTR-VALUE *confirms and re-expresses* — the binding and the global catalogue are the same design. **Synthesis: C5 stands as re-expressed by A3(a′): a global `ProductAttribute` registry (`UNIQUE(code)`) plus a per-category membership table.** ATTR-DEF's worry (nothing in its field list creates a global object) is answered by that membership table. |

**Three amendments the locks' own wording needs, surfaced by the briefs (for Irvan, not decided here):**
1. **Lock 1's "concretely" sentence** — `ProductAttribute.product_class` → `ProductAttribute.category` is a FK; under A3(a′) it must be a **join table** (`CategoryProductAttribute`), or every shared attribute is copied per category. (ATTR-VALUE A3 §7.)
2. **Lock condition 2** — "take the four shipping dimensions out of the attribute system" is re-expressed by A1 option 4: the four *values* move to `NOT NULL` columns; the four *definitions* stay in the registry with `storage='column'` so their metadata (name, unit, order, visibility) is not deleted. Ship knowing 68.4% of products carry `0` in those columns. (ATTR-DEF A1 §7.)
3. **Lock condition 5** — "a per-node 'accepts products' switch (Akeneo's model)": Akeneo's `only_leaves` is **per-tree**; a per-node switch has no precedent in the thirteen. TREE still recommends it, as a cleanup instrument. (TREE B1 §7.)

---

## 3 · What the answers force in steps 1–5 of the Next Steps page

| Step | Decision | Forced by the Step-0 answers |
|---|---|---|
| 1 | D15 | (d) per kind of fact; definitions (b) inherit + add-and-override, never remove — B4 |
| 1 | D16 | (b) schema on a subset, rest inherit; no depth cap — B3 |
| 1 | D17 | requiredness lives on the **membership row**, per (node, attribute) and **per level** — A3, A5, B4 |
| 1 | D18 | closed **above** the DB for free-text attributes (as today, `staff_serializers.py:74-81`); the FK *is* the enforcement for option-typed ones — A1, A4 |
| 1 | schema editor (condition 1) | definite field list: `code` (unique, immutable), `name`, `type`, `required`, `is_axis_eligible`, `is_customer_visible`, `is_filterable`, `display_order`, `unit`, `level`, `storage` (+`source_field`); must show inherited vs own rows and where a set is authored; permissions `add_/change_/delete_productattribute` on both stacks — A0, A1, A5, B3, B4 |
| 2 | D8 | (c) hybrid by type; **rows, not JSONB** (the FK from value to option exists only with rows) — A4 |
| 2 | D9 | label + derived magnitude in a canonical base unit; **net content as an axis: yes** — A4, C2 |
| 3 | D4 | `is_axis_eligible` on the **membership** row (eBay: 62% of aspects are not axis-eligible) — A2, A3 |
| 3 | D5 | the family chooses from the gated set (8 family-chooses / 1 type-imposes / 1 neither over 10 of 13) — A2 |
| 3 | D6 | cap of 3 is **necessary** (flavour, net content, pack form); Shopify and Walmart at 3; Tokopedia is 2-or-3, open — C2, C3 |
| 3 | D7 | implementable **in the DB** once values are rows (lock condition 4's composite-FK mirror becomes a real constraint) — A4 |
| 4 | D10 | field list settled: description, title, slug, `main_category` → family (composite-FK mirror as the open sub-choice); images member-first; never price/stock/barcode/visibility. **Plus a required work item nobody had named: a family-row reindex receiver and a family-image trigger** (every reindex today is `post_save` on `Product`) — C1, A5 |
| 4 | D11 | partition by level, each fact stored once — A5 |
| 4 | D12 | (a) one level, enforced by not building the column — C3 |
| 5 | D14 second half | **not hypothetical**: 3,402 rows under non-type roots need a home before Lock 1 — TREE |
| 5 | variant label | load-bearing for the composed title; composable from option labels — C1, A4 |
| 5 | feed key | must be a **group** key; suppression on singletons is the common case (80% of packs have no single) — C1, C2 |

**Decision-free defects surfaced (independent of every decision above):** the save-ordering bug — `Product.save()` enqueues the search index and the Google push at `models.py:489` *before* attribute values are written at `:490`, and there is no signal on `ProductAttributeValue` (ATTR-DEF, ATTR-VALUE) · age-walling matches an exact id list, not ancestry (TREE; already on the v7 page) · the attribute `unit` lives in a free-text `name` *and* a frontend i18n bundle, with three dead `internalname` keys (ATTR-DEF, ATTR-VALUE) · `ProductAttribute.code` has no `UNIQUE` and is auto-generated from a free-text name (A0) · the customer spec sheet is ordered alphabetically by code on the backend while the staff form uses a hard-coded TS array (A0) · `manufacturer` is declared required yet 59,662 products have no row and 2,843 active-online rows carry a letterless value (baseline).

---

## 4 · Standing decisions — every #10778 item, with its verdict

| Item | Verdict | Where |
|---|---|---|
| V1 axis names from a shared staff-extendable catalogue | **confirmed**; TREE proposes seeding it from the Shopify vocabulary; ATTR-DEF re-expresses "shared" as reusable across categories via A3's mechanism | A3, fork, A2 |
| V2 one storage shape + governance flag | **confirmed**; A4's (c) is its implementation ("the flag becomes the attribute's input type"); its "six eBay flags" count superseded (eBay has 11) | A4, A2 |
| V3 which setting per dimension: deferred | **confirmed**; (c) keeps it deferrable | A4 |
| V4 single text label, hand-ordered | **confirmed in substance** (the label is the record), **re-expressed** on ordering (it costs; a derived magnitude is cheaper and correct), **superseded** on "splitting forfeits nothing / belongs to #10942" (no owner exists) | A4 |
| V5 ordering column missing | **confirmed** as a gap; re-expressed: derived magnitude for magnitude-bearing lists, hand-set `display_order` only for lists without one | A4 |
| V6 normalisation + derived suggestions | **confirmed whole** (an earlier "unsourced" verdict was withdrawn after the #10778 corpus was opened); its manufacturer figures superseded by the baseline | A4 |
| C5 one global name catalogue, not per category | **confirmed as re-expressed by A3(a′)** — global registry + membership table + `UNIQUE(code)` | A3, B4, A2 |
| C8 one `Ukuran`, never split | **confirmed and strengthened** under (c)+(iv) | A4 |
| C2 family page at every variant's URL, hero via `display_order` | **re-expressed**: hero survives; bare family URL dropped | C1 |
| M4 a promo/banded pack is an ordinary dimension value | **re-expressed**: true for a same-product multipack, not for a two-product banded pack | C2 |
| M9 no cross-brand grouping, advisory | **confirmed**, with our numbers for why it cannot be enforced | C1 |
| S1 family never buyable | **confirmed**, and free under shape B | C1 |
| Decision A = S5 + C7 | **superseded by Lock 2** (S5 shape A); C7 satisfied by construction | BRIEF |

---

## 5 · Coverage — nothing dropped

| Source item | Landed in |
|---|---|
| Step-0 cards A0 A1 A2 A3 A4 A5 B1 B2 B3 B4 C1 C2 C3 | §1 above, one row each, each with all eight sections in its brief |
| The closed card (one category per product) | TREE, recorded not reopened |
| The Step-1 fork | TREE, full eight-section shape |
| Each card's research pointer | executed or recorded as "not collected + route" in the brief's §8 (see §6) |
| The 2026-09-18 clean-up line: barcode identity | C1 §5b |
| Tentative decisions 2026-09-15 | A5 (values on member: confirmed day-one), C1 (description: confirmed home / overruled silent migration; title: composed), images unchanged |
| The lock's five conditions | condition 1 field list (A0/A1/A5/B3/B4); condition 2 re-expressed (A1); condition 4's mirror becomes a real constraint (A4); condition 5's attribution corrected (B1) |
| #10778 items | §4 above |
| Errata (V4-vs-matrix) | resolved in A4 |

---

## 6 · What could not be collected, and the route that would settle it

- **Akeneo `only_leaves` per-tree** and **Salesforce's ancestor walk** (the only B4=(b) precedent) — single-route; their corpora are on the laptop. Route: Akeneo's category-tree docs; Salesforce B2C catalog/attribute-group docs. (TREE)
- **Shopify taxonomy `docs/`** — whether local extension is sanctioned. Route: `git sparse-checkout add docs` on the existing clone. (TREE)
- **The 244 rule-assigned non-leaf nodes** — direction of error unresolved. Route: read them as the 48 were. (TREE)
- **Meta's variant-consistency rule** (one route) and Meta's `ProductGroup` node fields; **Meta vs Google contradict on per-variant landing pages** (recorded). (FAMILY)
- **Walmart: may non-axis content diverge** — behind `MP_ITEM` credentials (#11068). **eBay: does a count aspect pivot** — one sandbox `getItemAspectsForCategory` call would settle it, the cheapest open item. **Amazon `package_level` field definitions** — `getCatalogItem?includedData=relationships`, credential-gated. (FAMILY)
- **Amazon "title and brand are attributes"** — single-route; the schema body sits behind `SchemaLink.link.resource` and `schemas.amazon.com` has no DNS record from here. Route: `getDefinitionsProductType` with LWA credentials. (ATTR-DEF)
- **A derived parse on staff-authored size labels** — tested on 886 title-derived labels only; a sample of 200 staff-entered values (`1 LUSIN`, `1/2 KG`) would settle it. (ATTR-VALUE)
- **Price-per-unit consistency across the ~727 pack/single pairs** — one join on `PriceSell`; not run. (FAMILY)
