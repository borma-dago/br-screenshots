# RESUME — the Step-0 catalogue decisions, from any session or account · written 2026-09-21

Everything needed to continue is on GitHub; nothing depends on the Claude account that built it.

## 1 · The decision page (the artifact), as a file

| What | Where |
|---|---|
| The page, complete, self-contained HTML (602 KB) | [`page/step-zero-decisions-v2.html`](https://github.com/borma-dago/br-screenshots/blob/main/research/catalogue-step0-2026-09/page/step-zero-decisions-v2.html) · raw: `https://raw.githubusercontent.com/borma-dago/br-screenshots/main/research/catalogue-step0-2026-09/page/step-zero-decisions-v2.html` |
| View it in a browser without republishing | https://htmlpreview.github.io/?https://raw.githubusercontent.com/borma-dago/br-screenshots/main/research/catalogue-step0-2026-09/page/step-zero-decisions-v2.html (a public proxy that renders raw GitHub HTML; the decision controls show “not saved in this view” — expected, there is no artifact runtime there) |
| The live artifact (private to the account that published it) | https://claude.ai/artifact/Gqer3FKNeLhFPnTnjHj68r — v3, 2026-09-21 |

**To re-create the artifact from another Claude account:** download `page/step-zero-decisions-v2.html`, publish it with the Artifact tool (title “Step Zero Decisions”, capabilities `{db: {}, user: {}}`). It is a fresh artifact with an empty decision store — decisions recorded in the original are **not** carried over (see §3).

**To rebuild the page from its data:** `page/build.py` reads `page/step-zero-decisions-v1.html` (the fixed parts: CSS, header, figure, per-card options/recommendation/reopen/links, decision script) + `page/decisions/<id>.json` (13 platform rows per question) + `page/decisions/models/<id>.json` (the structured key/value models + examples) + `page/decisions/costs.json` + `page/decisions/instances.json` → writes `step-zero-decisions-v2.html`. Python 3, no dependencies.

## 2 · Where the decisions stand

The seventeen cards: A1 A2 A4 A3 A0 A5 · B4 B3 B1 B2 + the fork · C1 C2 C3 · L-1 L-2 L-3 (lock-wording amendments). **As of 2026-09-21 none has been decided** — Irvan has not yet recorded Accept / Change / Reject / Later on any card. The recommendations (the agents' judgements) are in `INDEX.md` §1 and on the page.

## 3 · Recording decisions so they survive account changes

The page stores each choice in the artifact's own database (collection `decisions`, one document per card id: `{choice, note, title, updatedAt}`). That store belongs to the artifact, i.e. to the account that published it. **Rule: whenever decisions are recorded, export them to #11342 as a comment** (a table of card · choice · note · when) — then the issue, not the artifact, is the record, and #10966 gets the final outcome. From the publishing session: `ArtifactData` action `list`, collection `decisions`. From any other session: read the table on #11342.

## 4 · What is open, with the route (so nothing loops)

- Merchant Center U9 live probe — needs **H3** (enable a program on research data source `10721231878` so `itemLevelIssues` are emitted); route in `corpus/gap-pass-2026-09-21/merchant-center/RESULT.md`.
- Walmart non-axis divergence (`MP_ITEM` creds) · Amazon live per-type enum (blocked) · Shopee value behaviour (blocked) · Akeneo `only_leaves` per-tree + Salesforce ancestor walk (corpora on the laptop) · Shopify taxonomy `docs/` (sparse-checkout) · whether any Shopify node carries a measurement attribute.
- The three lock-amendment cards and the “what it forces” cells are v1 prose (no platform matrix applies).

## 5 · Read in this order

1. #11342 body (= `INDEX.md`) — the verdicts and the amendments.
2. `PROGRESS-2026-09-21.md` — what was done and not done on 2026-09-21.
3. The page (§1) — per question: answer · who (score) · caveats · sub-tallies · reading · platform-by-platform models · costs · recommendation.
4. `briefs/<X>/<X>.md` — the full argument behind any cell; `corpus/gap-pass-2026-09-21/*/RESULT.md` — the 2026-09-21 additions.
5. #11068's operator's manual — before any new collection pass (credentials, free routes).
