# The Step-1 fork · every number in the card, verified against the corpus on disk

**Corpus:** `~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy`, a sparse clone of
`https://github.com/Shopify/product-taxonomy` at commit
**`ad206247ecc45a95fe4b01bce2ad2f0e7bec3c66`** (2026-08-27, *"Merge pull request #999 from
Shopify/bump-gem-to-1.2.0"*), sparse paths `dist/en` and `dist/id-ID`. The build string inside both
`categories.json` files is **`2026-11-unstable`** — note it is *not* `2026-08`; the README badge at the same
commit says `Version-2026--08`. Sizes: `dist/en` 232 MB, `dist/id-ID` 203 MB; `en/taxonomy.json` is
95,139,186 B.

**Instrument:** `scripts/shopify_corpus.py` → `data/shopify-corpus-stats.json` (re-runnable).
**Mapping:** `scripts/shopify_map2.py` → `data/shopify-mapping.csv`; probe `scripts/unmapped_probe.py` →
`data/unmapped-probe.txt`.

## 1 · The card's claims, one row each

| Card says | Measured | Verdict |
|---|---|---|
| MIT-licensed | LICENSE not in the sparse checkout; the repo's README (fetched 2026-09-19, `corpus/why-2026-09/shopify-readme-*.md`) has a `## 📜 License` section | **not re-verified from the corpus** — the licence file was not in the two sparse paths. Route to settle: `git sparse-checkout add LICENSE` or fetch `raw.githubusercontent.com/.../LICENSE` |
| 14,606 categories | **14,606** in `en`, **14,606** in `id-ID`, over **26** verticals | ✅ |
| 8,240 attribute definitions | **8,240** in `en`, **8,240** in `id-ID` | ✅ |
| with closed value lists | **0** definitions have an empty `values[]`; 74,820 values in total; **median 7** values per definition, max 451 | ✅ (and the value lists are genuinely closed — there is no free-text definition) |
| only 1.0% of nodes have none | **152 of 14,606 = 1.04%** carry zero attributes | ✅ |
| median 6 | attributes per category: **median 6**, mean 6.37, max 28; **93,007** category→attribute edges | ✅ (93,007 also matches the A3 card's "93,007 category edges") |
| materialised per node with no inheritance | the literal string `inherit` occurs **0** times in `en/taxonomy.json` (95,139,186 B), **0** in `en/categories.json`, **0** in `en/attributes.json`. **4,569 of 14,580** parent→child pairs have at least one parent attribute absent from the child; 10,011 pairs are a superset; 10,159 parent-attribute occurrences are dropped by a child | ✅ on the mechanism. ⚠️ **the count differs from the record**: #11188 (2026-09-15) and #11031 say **4,668 of 14,580**. The pair denominator reproduces exactly (14,606 − 26 roots = 14,580); the numerator does not. Both were measured on a "2026-08"-labelled artifact. Recorded as a correction, not resolved |
| id-ID is a published locale | categories, attribute names **and** values are all translated. Worked example verified whole: `Food, Beverages & Tobacco > Food Items > Dairy Products > Yogurt` = `Makanan, Minuman & Tembakau > Item Makanan > Produk Susu > Yoghurt`, carrying `Informasi alergen` (16 values) · `Varian beta-kasein` (4) · `Preferensi diet` (28) · `Kandungan lemak` (8) · **`Rasa` (30)** · `Persyaratan penyimpanan` (6) · `Bahan dasar yogurt` (15) | ✅ — all seven, and the counts the card quotes for Rasa/Kandungan lemak |
| no net-content or size attribute | there **is** a base definition named exactly `Size` (`gid://shopify/TaxonomyAttribute/2778`, 80 values, carried by **464** categories) — but its values are garment sizes (`Triple extra small (XXXS)` … `Six extra large (6XL)`, `000`, `00`). Across all 8,240 definitions, only **15** have any value matching `^\d+(\.\d+)?\s?(g\|kg\|ml\|l\|oz\|lb\|mg\|cl)\b`, and none of them is a net-content measure (`Compatible wax container size`, `Compatible can size`, `Spoke gauge`, `CO2 cylinder compatibility`, …) | ✅ on the substance — **no net-content attribute exists**. ⚠️ the card's framing "no size attribute" is too strong: a closed garment-size list exists |
| 300 of 8,240 match size/volume/weight, all category-specific | measured: **262** of 8,240 base definition **names** contain `size\|volume\|weight` (case-insensitive); 272 if the 314 extended (category-specific renames) are added to the population; **254** distinct edge names as actually used on categories. Of the 262, **85** are used by more than one category and **18** by none | ⚠️ **300 not reproduced** at this commit with this pattern. Reported as measured, with the pattern stated |
| the id-ID build has 18 duplicate full_name paths | **18** duplicate `full_name` values in `id-ID` (36 rows), **0** in `en`. Listing: `data/shopify-duplicate-fullnames-id-ID.json`. Also: 298 duplicate leaf **names** in `id-ID` vs 205 in `en` | ✅ |
| re-homing 106,161 products | 106,161 is our count, not the taxonomy's; re-homing is per **category** — see §3 | see §3 |

## 2 · Three facts the card does not carry, found while verifying it

### 2.1 `dist/` is deprecated and is removed on 2026-10-31

The repository README, fetched 2026-09-19 at both `main` and the pinned commit (byte-identical, md5
`5d197d41f6fc02b731ca95cfa93c9730`, saved at `corpus/why-2026-09/shopify-readme-*.md`), states verbatim:

> "[!IMPORTANT]
> The committed [`dist/`](./dist/) directory is deprecated and will be removed on **October 31, 2026**.
> Migrate to the release-asset URLs above before then."

Our entire corpus is `dist/`. Every measurement above remains true of the artifact measured; the artifact
itself has six weeks to live in that location. The successor is gzip release assets
(`https://github.com/Shopify/product-taxonomy/releases/latest/download/categories.en.json.gz`), with a
`stable` and an `unstable` channel. **This is a currency fact, not a blocker — but any adoption plan that
says "pin `dist/`" is already wrong.**

### 2.2 The taxonomy is a translated global taxonomy, not an Indonesian one

Word-boundary leaf-name probe over both 14,606-node builds. **Absent (0 hits in either locale):**
`Batik` · `Mukena` · `Sajadah` / `Prayer rug` / `Prayer mat` · `Kebaya` · `Kopiah` · `Peci` · `Sarong` ·
`Sambal` · `Terasi` / `Shrimp paste` · `Mi Instan` / `Instant noodle` · `Kapur barus` / `Mothball`.
**Present:** `Abaya dan Jilbab`, `Baju Melayu`, `Kaftan` (under `Pakaian Tradisional & Seremonial`, 17 nodes
total, every one listed in `TREE.md`), `Sampo`, `Lipstik`, `Keripik`, `Kerupuk Beras`, `Kecap`,
`Santan & Minuman Kelapa`, `Penanak Nasi` (the id-ID name for a rice cooker).

*(Synced to `TREE.md` after red-team round 2, SERIOUS 11: this list still carried the en spellings `Santan`
and `Rice Cooker` inside an id-ID list — no id-ID node is named `Santan` (there are `Santan & Minuman
Kelapa` and `Santan & Krim Kelapa`) and none contains "Rice Cooker" at all — and the Absent list read
`Sarong` **(en)** while omitting `Peci`. Both are absent at word boundary in both builds.)*

Against that, the same branch that has no instant-noodle node has `Snack Foods` with 44 nodes including
`Pork Rinds` (id `Kerupuk Kulit Babi`), `Korean Tteok & Tteokbokki Rice Cakes` and `Namkeen & Sev Mixes`.

**`Food, Beverages & Tobacco > Food Items > Pasta & Noodles` (id `Pasta & Mi`) is a single node with 5
attributes and no children.** Our `MIE, BIHUN, KWETIAU INSTAN` branch (node 99) is **7 nodes and 439
products** in subtree; the mie-only sub-branch the absence bites — node 99 itself (16) + `MIE INSTAN BUNGKUS`
(318) + `MIE INSTAN DALAM KEMASAN CUP` (60) — is **3 nodes and 394 products**, including node **612**
(`MIE INSTAN BUNGKUS`, 318 products) — the node the 43 Indomie rows live in, and the
example that started this whole workstream. Adoption puts Indomie in the same node as spaghetti, and gives
it no net-content attribute to distinguish 85 g from a 5-pack.

### 2.3 Two of the taxonomy's own artifacts disagree about `level`

Recorded on #11011 as its contradiction 8: the release asset gives `fb-1` → `"level": 1` with a histogram
starting at level 0; the live API gives `fb` → level 1, `fb-1` → level 2. Our corpus is the file, so our
level histogram is 0-based (26 roots at level 0). Anything keying on `level` gets a different tree depending
on the route.

## 3 · Mapping feasibility — how much of our tree maps

Full method and both passes: `node-attribute-need.md` §3. Headline:

**Rebuilt after red-team round 1** — the qualifier is now stripped from **our side only** and must be
recoverable as `Jenis kelamin sasaran` / `Kelompok usia` on the target; the thirteen root→vertical bindings
are a **preference with a global fallback**, not a filter; the 90% cut is deterministic. Full method and the
revision-1→2 delta table: `node-attribute-need.md` (revision banner, §2.1, §3).

| | nodes mapped | products covered | miss |
|---|---|---|---|
| Pass A — literal name identity | 362 of 1,686 (21.5%) | 23,748 (22.4%) | **1,324 nodes (78.5%)** |
| Pass B — + 13 root→vertical preferences + the recoverable gender/age collapse | **434 (25.7%)** | **34,671 (32.7%)** | **1,252 nodes (74.3%)**, 71,490 products (67.3%) |

Of the 639 nodes covering 90% of products, pass B maps **200** (161 EXACT + 39 FUZZY), leaves 28 ambiguous
and 411 unmapped. *(Rebuilt again after red-team round 2, SERIOUS 9 — the resolver now returns `AMBIGUOUS`
whenever more than one candidate shares the winning normalised name; 485 → 434 mapped.)*

**And the mapping over-maps.** Hand adjudication of 37 mapped rows (`data/mapping-adjudication.csv`):
**6 of a random 21 point at the wrong kind of product (28.6%, Wilson 95% CI 14–50%)** and 5 land on a
genuine ancestor; the top-by-products stratum is better at 2 of 16 (12.5%). Examples: `KAUS PRIA` → men's
**undershirts**; `KAUS WANITA` → women's **undershirts**; `PERAWATAN MOBIL` → a **service** node;
`KIPAS ANGIN` → fan **remote controls**; `MAKANAN BEKU` → frozen **fish food**. So 25.7% is the *automation*
rate, not an accuracy rate — the share of nodes a machine can place **and** place correctly is nearer
**one in five**.

**The miss rate is a mapping-automation rate, not a coverage rate.** A hand probe of 50 unmapped nodes finds
three causes, and only the third is a real hole:

1. **loanword spelling** — `SHAMPOO`/`Sampo` (719 products), `LIPSTICK`/`Lipstik` (482),
   `BLOUSE WANITA`/`Blus` (913), `COOKIES & BISKUIT`/`Biskuit` (827);
2. **a qualifier we make a node and the taxonomy makes an attribute** — **302 of our 1,686 used nodes
   (17.9%), holding 42,621 products (40.1%), carry a gender/age qualifier in the node name; 168 of them
   collapse onto a name shared with another node**. `SANDAL WANITA` + `SANDAL PRIA` → one `Sandal` with
   `Jenis kelamin sasaran`;
3. **a genuine hole** — §2.2.

**So the mapping bill, honestly stated:** roughly one in four of our used nodes maps mechanically, and about
a quarter to a third of those are wrong, so under one in four is both placed and placed right; a further large fraction
map after a spelling/synonym pass and a decision to collapse gender-and-age nodes into attributes (which is
itself a tree restructuring, not a rename); and a residue — at minimum the Indonesian kinds in §2.2, ~2,800
products by node name — has no home in the published taxonomy, and adding nodes locally forks it.
**The card's "machine work once a mapping exists" is right; the mapping does not exist and is the work.**

## 4 · What the fork settles for B1–B4

| Card | Under "keep authoring our own tree" | Under "adopt the taxonomy" |
|---|---|---|
| **B1** nodes have types | open; lock condition 5 asks for the per-node switch | **settled as (b)**: one kind. `TaxonomyCategory` carries `isLeaf Boolean!` as a derived field (#11011 §1.7) and nothing else distinguishes node kinds |
| **B2** products on a non-leaf | open; our 292 need the classification either way | **settled as "any node"** — verified live on #11011: a product created on `aa-1-13` with `isLeaf:false` returned `userErrors:[]`. But the 3,402 products under `UNUSED` / `BELUM DISORTIR` / `INVENTORY KANTOR` still have no taxonomy home |
| **B3** depth / what earns a node | ours to decide; measured 68 attribute-need sets over 1,686 nodes | **settled by the vendor**: 14,606 nodes, max level 7, food branch 764 nodes, median 6 attributes. We stop deciding — and stop being able to add `Batik` |
| **B4** what flows down | needs (b) inherit-with-override. Like-for-like precedent — platforms whose **internal** category nodes own a per-node schema, so inheriting is a real choice — is **Shopify vs Salesforce, 1 of 2**; 2 of 3 admitting Akeneo's Family tree. Derivation: `TREE.md` B4 §2 | **settled as (a)**: materialised per node, `inherit` = 0 occurrences, 4,569 pairs where a child drops a parent attribute. Inheritance becomes unnecessary because we are not the authors |

**The consequences for the value model (fork↔A4) and for shared types (fork↔A3) are stated by ATTR-VALUE,
under its own headings. TREE states only the facts above.** The two facts they need: every one of the 8,240
definitions carries a **closed** value list (0 with an empty `values[]`, median 7 values), and **no
net-content attribute exists** (15 definitions of 8,240 have any numeric+unit value, none of them a net
content).

## 5 · The bill each side pays

| | Keep authoring | Adopt |
|---|---|---|
| **Tree** | 1,892 nodes stay; 609 under-10-product nodes and 206 unused nodes are ours to prune | re-home 1,686 used nodes onto a foreign tree; ~76% need hand mapping; the Indonesian residue needs nodes the standard does not have |
| **Schema** | a **range**: 68 distinct sets measured floor · 316 inferred over the mapped share (220 conservative) · 1,686 under D15=(a). Needs B4=(b), whose like-for-like precedent is **1 of 2** (`TREE.md` B4 §2) | zero authoring — 93,007 edges arrive materialised |
| **Population** | 8 attribute kinds our titles already carry | **776 distinct attribute names** over the 434 nodes that map (**558** on the conservative cut); **477** over the 200 inside the 639 (**330** conservative). About a quarter to a third of the mapped rows are the wrong target (`node-attribute-need.md` §2.1). Nothing in our data fills most of them |
| **Net content / size** | ours to design (A4) | **not solved** — and now has to be a metafield outside the taxonomy, i.e. the same design, plus a taxonomy |
| **Governance** | we own every change; no external clock | Shopify's release cadence; `dist/` retired 2026-10-31; two artifacts already disagree on `level`; 18 duplicate id-ID paths |
| **Business logic on the tree** | age-walling, replenishment, `full_code`, `is_public`/`ancestors_are_public`, ES ancestor ids all keep working on the same ids | every one of those is keyed on **our** `Category.id`; adoption means either keeping our tree as a shell that maps to theirs, or re-keying all five |


---

## 8 · Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **BLOCKING 3 / SERIOUS 5 / SERIOUS 16** | §3 rebuilt on the corrected mapping. Pass A 380→**420**, pass B 395→**485** mapped; miss 76.6%→**71.2%**; the 90% cut is deterministic and both scripts now print **223 / 491**. An **over-mapping rate** is published for the first time (~25% of a random 20 mapped rows point at the wrong kind). §5's population row restated with both ceilings (810 / 574). |
| **SERIOUS 7** | §5's governance row and §6's "decisive fact 2" in `TREE.md` overstated "a standard taxonomy is one we cannot extend". Restated as what is actually established: **adding nodes locally forks it** — the published set has no `Batik`, and a local addition is not in the standard, so upstream updates and any interoperability the standard buys are lost. The stronger prohibition claim is withdrawn; the repo's contribution guide was **not** collected (it is outside the sparse checkout). |
| **SERIOUS 9** | The "business logic on the tree" row in §5 was five items; it is **six**, and the sixth (`CategoryIndex`) is keyed on `full_code`, not `id`. |
| **MINOR 19** | `MIE, BIHUN, KWETIAU INSTAN` restated as 7 nodes / 439 products in subtree, with the 3-node / 394-product mie-only sub-branch named. |
| **MINOR 23** | `Santan` and `Rice Cooker` were en spellings in an id-ID list; corrected to `Santan & Minuman Kelapa` and `Penanak Nasi`. |
| **MINOR 27** | §4 and §5 said B4 "needs (b) … on one precedent of thirteen", contradicting `TREE.md`. Both now carry the derived denominator (**1 of 2** like-for-like) and point at `TREE.md` B4 §2. |


---

## 9 · Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 9** | §3 rebuilt on the fixed resolver: pass A 420 → **362**, pass B 485 → **434** mapped (28.8% → **25.7%**), miss 71.2% → **74.3%**, the 639 cut 223 → **200**. Over-mapping restated at **6 of a random 21 = 28.6%** (CI 14–50%), with the top-by-products stratum (12.5%) and the product-weighted figures beside it. §5's population row restated (776 / 558 / 477 / 330). |
| **SERIOUS 11** | §2.2's "Present" list still carried the en spellings `Santan` and `Rice Cooker` inside an id-ID list, and the "Absent" list read `Sarong` (en) while omitting `Peci` — although this file's own round-1 corrections table said both were fixed. Synced to `TREE.md`; both probes re-verified at word boundary in both builds. |
| **SERIOUS 8 (carried)** | The 14,528 + 5,754 published rules take a **Shopify** category as input; they cover the hop after ours and relieve none of the our→Shopify bill. Stated in `TREE.md` fork §6 and §7. |
| **Snapshot bound** | All three `sql/*.sql` dedup subqueries bounded at 2026-09-19 10:27 UTC per BRIEF §3.4; re-run **byte-identical**, no figure changed. |
