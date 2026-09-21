# FAMILY — new-source pass: what was fetched, where it is, and what is still OPEN

Collected under `.claude/skills/external-research/SKILL.md`, 2026-09-19. Corpus root:
`~/copilot/research/catalogue-step0-2026-09/corpus/`. **Left in place, not deleted** — GS1 and Meta are
shared with other briefs. Total added by this brief: ~180 KB of text plus the Walmart rendered page.

The card pointers this pass executes: *"Google and Meta 'consistent content across variants' rules (Meta is
NOT among the thirteen records — new collection …, corpus/meta/)"* (C1) · *"Walmart count and multipack
fields; GS1's GTIN-per-pack rule (new collection …, corpus/gs1/)"* (C2).

## Sample, fixed before collecting

| Source | Why in scope | Surface in scope | Deliberately out of scope |
|---|---|---|---|
| **Meta Commerce / Catalog** | the card names it; it is not one of the thirteen records | the variant-grouping mechanism and any stated cross-variant consistency rule | Meta's ads targeting, Shops checkout, Instagram tagging |
| **GS1 GTIN Management Standard** | the card names "GS1's GTIN-per-pack rule" | the ten GTIN Management Rules, §2.1–§2.10 | GS1 General Specifications barcode symbology (already in `corpus/gs1/` from another brief; not read by me) |
| **Walmart Marketplace developer docs** | the card names "Walmart count and multipack fields" | the variant-group guide and its supported-attribute list | the 451 MB `MP_ITEM` spec (not on this machine; the #11046 record's instrument over it is the second route) |

## Artifacts

| File | Source URL | Prov. | Route | Bytes | Retrieved |
|---|---|---|---|---|---|
| `corpus/gs1/GS1_GTIN_Management_Standard.pdf` + `.txt` | `gs1id.org/docs/idkeys/GS1_GTIN_Management_Standard.pdf` | **P1** — a GS1 Member Organisation redistributing the AISBL document; the file's own footer reads `Release 1.1, Ratified, Sep 2023 · © 2023 GS1 AISBL` | plain `curl` (fetched into the shared corpus by the coordinator/ATTR-VALUE pass; `attempts_task1.log` records 16 hosts tried, `www.gs1.org/docs/idkeys/…` → 404) | 381,277 / 51,967 | in corpus at 2026-09-19 17:40 local |
| `corpus/meta/fb-variants-dev.txt` | `developers.facebook.com/docs/commerce-platform/catalog/variants/` | P0 | `fetch-page.cjs --text --settle 6000` (plain `curl` → **HTTP 400**, 856 B, recorded in `corpus/meta/attempts_family.log`) | 4,229 | 2026-09-19T10:41:43Z |
| `corpus/meta/fb-catalog-fields.txt` | `developers.facebook.com/docs/commerce-platform/catalog/fields/` | P0 | same | 36,189 | 2026-09-19T10:42:20Z |
| `corpus/meta/fb-help-120325381656392.txt` | `facebook.com/business/help/120325381656392` (Product data specifications for catalogues in Commerce Manager) | P0 | same | 22,561 | 2026-09-19T10:42:31Z |
| `corpus/meta/fb-graph-product-item.txt` | `developers.facebook.com/docs/marketing-api/reference/product-item/` | P0 | same | 44,502 | 2026-09-19T10:42:xx Z |
| `corpus/walmart/wm-multiple-variants.txt` | `developer.walmart.com/us-marketplace/docs/setting-up-multiple-variants-of-an-item` | P0 | `fetch-page.cjs --text --settle 9000`; the URL was **found**, not guessed — `href="/us-marketplace/docs/setting-up-multiple-variants-of-an-item"` extracted from the rendered `wm-items.html` (381,077 B), after `developer.walmart.com/doc/us/us-mp/us-mp-setting-up-multiple-variants-of-an-item/` returned the nav-only SPA shell | 21,282 | 2026-09-19T10:4x Z |
| `corpus/walmart/wm-items.html`, `wm-items.txt` | `developer.walmart.com/doc/us/mp/us-mp-items/` | P0 | as above | 381,077 / 16,313 | same |

Failed and recorded, not inferred through: `www.gs1.org/standards/gtin-management-standard` → **404**
(74,849 B of generic error page — a soft-404-shaped response with a real 404 status);
`facebook.com/business/help/2144286692311411` → 200 but it is the **country/language feed** page, not variants;
`developers.facebook.com/docs/marketing-api/reference/product-group/` and `…/product-group` → **404** both.

## VERIFIED — two independent routes each

| Fact | Route 1 | Route 2 | Quote (to the end of the clause) |
|---|---|---|---|
| **GS1: a size/colour variation is its own GTIN** | GTIN Management Standard §2.1, `corpus/gs1/…​.txt` | the identical rule restated on the member-org page the 2026-09-15 field survey quotes (*"every variation of your product (e.g. each size, each colour) requires its unique GS1 GTIN"*) — different document family, same proposition | *"A new jeanswear line includes various sizes of a particular style and colour of jeans (30x30, 30x32, 32x30, 32x32, etc.). Each style, colour and size variation is considered a unique product and is assigned a unique GTIN."* |
| **GS1: a count change is a net-content change at the retail consumer trade item level** | §2.3, rule sentence + the examples list whole | §2.3's own "Hierarchy level of GTIN change" table: `Declared net content · GTIN change for retail consumer trade item/base unit? YES · New GTIN for higher level packaging? YES` — a separate table in the same standard that could have said `N/A`, as §2.8's does | *"Any change (increase or decrease) to the legally-required declared net content that is printed on the pack, requires assignment of a new GTIN."* · *"The declared count of the number of razors in a package changes from 4 to 6."* |
| **GS1: a case-quantity change is a higher-packaging-level GTIN only** | §2.8 rule sentence + example | §2.8's hierarchy table, which reads `Pack/case quantity · GTIN change for retail consumer trade item/base unit? **N/A** · New GTIN for higher level packaging? YES`, and its guiding-principles row `Pack/case quantity · NO · YES · YES` | *"A change to the number of trade items in a case or a change to the quantity of cases in a predefined pallet configuration, requires assignment of a new GTIN."* |
| **GS1: an assortment's components keep their own GTINs** | §2.9 "Additional information" | §2.9's hierarchy table `Predefined assortment · YES · YES` | *"The individual trade items included in the assortment are explicitly defined by the trading partners and carry their own, unique GTIN separate from the GTIN assigned to the assortment."* |
| **Walmart: count / countPerPack / multipackQuantity are permitted variant attributes** | `wm-multiple-variants.txt`, "Supported variant attributes" list whole: `Color · Size · Pattern · Character · Count · Count per pack · Multipack quantity · Theme` | the machine-readable `MP_ITEM` spec's `variantAttributeNames.items.enum` as instrumented in #11046 §1.x — `["assembledProductWidth","color","count","countPerPack","multipackQuantity","paperSize","pattern","shape","size"]` — a different artifact that could have omitted them | as printed |
| **Walmart: an item belongs to one variant group** | `wm-multiple-variants.txt`, "How variant groups work" | #11046 §2b's independent reading of the write side (a group exists only as a repeated string; an item carries one `variantGroupId`, `0..1`) | *"An item can belong to only one variant group."* |
| **Walmart: at most three variant attributes** | `wm-multiple-variants.txt` — *"Up to three variant attributes can be used."* and, under Best practices, *"Use no more than three variant attributes."* | #11046 §1.x's independent count from the spec | as printed |
| **Meta: the variant group is a repeated string key on the item, with no group content row** | `fb-variants-dev.txt` — *"Product variants are created by adding multiple products grouped by the same `item_group_id` field. This field typically corresponds to the parent SKU, although you can use any other ID to group variants together."* | `fb-graph-product-item.txt` — the Graph API `ProductItem` carries `retailer_product_group_id : string` and `additional_variant_attributes : JSON object {string : string}` — *"Additional attributes to distinguish the product in its variant group (ex: {\"Scent\" : \"Fruity\", \"Style\" : \"Classic\"})"* | as printed |
| **Meta: a non-variant "parent" row in the feed is an error** | `fb-variants-dev.txt`, the "Incorrect" worked example whole — a `CoolShirt123` row with an empty `Color` — *"Incorrect — “CoolShirt123” is sent as a parent SKU and the color field is not populated. Because each line item in the field spec needs to be its own product, this is an incorrect way of setting up products."* | `fb-help-120325381656392.txt` — *"Each group ID must be unique and must not be the same as any individual content IDs (id) in your catalogue."* — the same prohibition from the other side | as printed |
| **Meta: every variant field must be populated on every member** | `fb-variants-dev.txt` — *"All variants for a given product `item_group_id` must have populated every variant field (for example, size, color, gender, and pattern). For custom variants, you can use the `additional_variant_attribute` field."* | `fb-catalog-fields.txt`'s own 6-row CSV example, in which every row carries both `color` and `size` | as printed |

## VERIFIED — negative result, with the instrument

**Our Google Merchant feed sends no grouping at all.** `grep -rn "item_group_id\|itemGroupId" /home/irvan/copilot/py-5/py/mono/solvent --include=*.py` → **0 hits** at `4f99dc01c6`. Control:
`grep -rn "offer_id" …` → 1 hit, `third_party_api/google/content/products_api.py:240`. The eight attributes the
exporter does set are enumerated at `products_api.py:214-224, 230-232, 234-235`. Synonyms searched over the whole
`third_party_api/google/` tree (`--include=*.py`): `gtin` → 0, `brand` → 0, `multipack` → 0,
`is_bundle` → 0, `item_group_id` → 0.

## Where each OPEN row travels into `FAMILY.md` §8

⚠️ Added after red-team round 1 (finding 33). Revision 1 let **O-2** and **O-6** stop here; the output
contract puts "not collected + route" in each card's §8.

| Row | Lands in |
|---|---|
| O-1 Meta name-identity, single route | C1 §8 |
| **O-2** Meta `ProductGroup` node fields | **C1 §8** (added — Meta is counted as a fourteenth row partly on having no group content row) |
| O-3 Meta vs Google on the per-variant `link` | C1 §2 and §8 |
| O-4 Walmart non-axis divergence | C1 §8 |
| O-5 eBay count-as-pivoting-aspect | C2 §2 and §8 |
| **O-6** GS1 P1 provenance, no P0 copy reachable | **C2 §1 and §8** (added — C2's recommendation rests on this one artifact) |
| ~~O-7~~ | **closed** (finding 9) — see the row above |

## OPEN — named, with the route that would settle each

| # | Question | Why it is open | Route that would settle it |
|---|---|---|---|
| **O-1** | Does Meta state a cross-variant **content-identity** rule (title/description must match), or only the worked example? | The sentence *"The name of the product and the `item_group_id` fields match (so that the name does not change when variants are selected, but images do)"* appears on **one** page (`fb-variants-dev.txt`). The Business Help Centre page I retrieved is the field spec, which does not restate it. Two guessed help-centre article ids → 404. | the Commerce Manager help article "How to manage variants in your catalogue in Commerce Manager" (title read from the nav list at `corpus/meta/fb-help-120325381656392.txt:460`; URL not resolved — the page links it by JS, and two guessed ids returned 404), **or** a Commerce Manager catalogue upload with divergent titles under one `item_group_id`, read back for a rejection. Credential-gated. |
| **O-2** | Does Meta have a `ProductGroup` node with its own fields? | `fb-graph-product-item.txt:962` documents the edge `/{product_group_id}/products` — *"When posting to this edge, a ProductItem will be created."* — so the node exists, but its own reference page was not found (two 404s). | the Graph API reference page for the product-group node at its correct URL, or an authenticated `GET /{product_group_id}?fields=` |
| **O-3** | Whether Meta's identical `link` across variants is actually accepted | `fb-catalog-fields.txt`'s own CSV sample gives all six variant rows the **same** `link` and the **same** `image_link`, which contradicts Google's explicit per-variant landing-page requirement (#11031 §C). Both are vendor-published; neither is wrong about itself. **Recorded as a contradiction, not resolved.** | a Commerce Manager upload with a shared link, read back for a diagnostic |
| **O-4** | Whether Walmart permits **non-axis** attributes to diverge across a group | the page states the content rule only under **Best practices** — *"Keep product content consistent across all variants except for the attributes that vary."* — while the five **must** rules cover only the group id, the attribute names, the value completeness, combination uniqueness and the single primary. #11046 §U13 records the same gap. | a `MP_ITEM` feed with divergent `productName` under one `variantGroupId`, read back through the feed's item-level errors. Credential-gated (#11068). |
| **O-5** | Whether eBay permits a **count** aspect as a pivoting aspect | eBay gates axes per aspect: *"To see which aspects are allowed as pivoting aspects, you can use the `getItemAspectsForCategory` method and look for a value of `true` in the `aspectEnabledForVariations` field"* (#11045 §3). Which grocery categories set it `true` for a count-shaped aspect was **not measured**. | one `getItemAspectsForCategory` on an Indonesian grocery leaf with the sandbox application token that #11045 already holds, grepping `aspectEnabledForVariations` against count-shaped `localizedAspectName`s |
| **O-6** | Whether GS1 Indonesia's copy is byte-identical to the AISBL original | the file is **P1** — a member organisation's redistribution. Its footer, release, ratification date and © line are the AISBL's, and no clause was compared against a P0 copy because `www.gs1.org/docs/idkeys/…` returns 404. | `ref.gs1.org` or the GS1 Global Office document library, if either publishes the PDF at a stable path |
| ~~**O-7**~~ **CLOSED** | ~~Google's `[multipack]` / `[is_bundle]` requiredness for **Indonesia**~~ | ⚠️ **Closed after red-team round 1 (finding 9): the record states it and revision 1 truncated the quote.** `11013.md:703` (`[multipack]`) and `:691` (`[is_bundle]`) both end *"· Required for free listings … · **Optional for all other products and target countries**"*. That covers Indonesia explicitly; it was never an inference | — |

## Counter-evidence searched for on purpose, and what it returned

- **A platform that forbids count as a variant axis.** ⚠️ **Re-run after red-team round 1 (finding 21).**
  Revision 1 said *"Searched the thirteen records"* and then printed an instrument over **six**
  (`11013 11045 11046 11047 11048 10976`), which omitted `11069.md` — the one platform that restricts axis
  eligibility by attribute type. Re-run over **all thirteen**:

  ```
  grep -in "cannot be a variant|not.*allowed as.*variation|forbidden.*axis|may not be an axis|\
  cannot be an axis|not.*allowed.*as.*axis|Only the following attribute types are allowed|\
  Not all aspects are allowed" \
    10976.md 11011.md 11013.md 11045.md 11046.md 11047.md 11048.md 11049.md \
    11050.md 11069.md 11080.md 11081.md 11082.md
  ```
  → **5 hits in 3 records**; per-file counts `10976 0 · 11011 0 · 11013 0 · 11045 2 · 11046 1 · 11047 0 ·
  11048 0 · 11049 0 · 11050 0 · 11069 2 · 11080 0 · 11081 0 · 11082 0`.

  | Record | What it restricts | Bears on count? |
  |---|---|---|
  | eBay `11045.md:321, :653` | per aspect — *"**Not all aspects are allowed as a pivoting aspect.**"* | only via the per-category flag; unmeasured (O-5) |
  | **Walmart `11046.md:501`** | per product type — *"**Counter-case 2 — ten food product types with no variant mechanism at all**: `Apples`, `Avocados`, `Bananas`, `Fresh Herbs`, `Grapes`, `Mushrooms`, `Onions`, `Packaged Salads`, `Pears`, `Watermelons`. On these, flavour cannot be an axis because **no** attribute can be."* | **yes** — on those ten types count cannot be an axis either. **Missed by revision 1's six-file grep** |
  | Akeneo `11069.md:531, :945` | per attribute type — *"Only the following attribute types are allowed: `simple select`, `multi select`, `reference data`, `metric`, `boolean`."* (its own §5 C3 holds this open: six statements, three answers) | no — a count fits `metric` or `simple select` |

  Also found outside the pattern and carried in C2 §2: Amazon's per-product-type theme enums (#10976 §1.5 —
  *"A valid variation theme in Beauty is 'Size-Scent,' however, 'Size-Scent' is not a valid variation theme
  in the Apparel category."*). **No artifact in the thirteen forbids *count* specifically; three platforms
  restrict axis eligibility by a mechanism that is not about count.**
- **A platform that nests families three or more deep.** `MAXIMUM_LEVEL_NUMBER = 2` is the deepest found
  (Akeneo, #11069 §1.6). Nothing deeper appeared in any record.
- **A platform whose member may differ from its siblings in category.** Salesforce states the opposite (the
  classification category *"cannot be overridden"*); no record states a permission. **Nothing found.**
