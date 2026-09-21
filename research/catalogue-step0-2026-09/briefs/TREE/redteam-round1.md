# TREE — red-team round 1

Adversarial re-verification by an agent that did not write the brief. Everything below was re-run, re-opened
or re-read; nothing is quoted from the brief's own summary of itself.

**What was re-executed:** `bq` re-run of `sql/nodes-full.sql` (byte-identical to the saved result); every
number in B1–B4 §5 re-derived from `sql/results/nodes-full.csv`; `scripts/shopify_corpus.py`,
`scripts/shopify_map2.py`, `scripts/node_attribute_need.py` re-run against
`corpus/shopify-taxonomy` @ `ad206247` with outputs diffed against `data/`; independent probes of the
taxonomy corpus; ~60 `path:line` cites re-opened at `py-5@4f99dc01c6` and `ts-layer2@82187a17bd`;
independent `Grep` sweeps for Category / `main_category` / `numchild` / `depth` / `full_code` /
age-walling / replenishment / category picker on both stacks; quoted fragments grepped in
`evidence/issues/*.md`; saved artifacts in `corpus/why-2026-09/` opened; a random 20 of the 252
rule-assigned non-leaf nodes re-read by hand.

**Counts: 3 BLOCKING · 14 SERIOUS · 14 MINOR.**

---

## BLOCKING

### 1. B3 §2's tally contradicts itself one sentence later, and both halves cannot be true — BLOCKING

**What is wrong.** `TREE.md` B3 §2, "Tally":

> Node carries a schema: **7** — and **all seven are in the centrally-authored group**. Of the six
> merchant-authored, exactly one (Salesforce) puts a schema on the category tree at all.

The two sentences are mutually exclusive. Reading the table's own "Node carries a schema?" column: the
yes-rows are Amazon, Shopify, eBay, Walmart, Shopee, Tokopedia Era A, Tokopedia Era B, **Salesforce** — 8
rows / 7 platforms. Google is in the centrally-authored group and carries **no** schema ("no — *every line
is `id - path`*"). So the seven schema-carrying platforms are six central ones **plus Salesforce**, which is
merchant-authored. "All seven are in the centrally-authored group" is false on the brief's own rows.

**Where.** `TREE.md:471-477` (B3 §2, tally paragraph).

**Why it matters.** This is a tally in a who-uses matrix, which the owner names as the single most important
output ("if all platform uses only one option, that is a very strong evidence"). It is also the premise of
B3 §3's closing bullet — *"the merchant-tool six … none of them is evidence for how deep our tree should
go — the six that most resemble our situation have nothing to say about it"* — which is wrong precisely for
the one merchant-authored platform that does put a schema on a category tree **and** inherits down it
(Salesforce), i.e. the platform whose situation is closest to ours and the only precedent for B4=(b).

**Fix.** Restate as: *centrally-authored: 7, of which 6 carry a per-node schema (Google does not);
merchant-authored: 6, of which 1 (Salesforce) carries one. Node carries a schema: 7 = 6 central + Salesforce.*
Then re-write the §3 "merchant-tool six" bullet, which currently deletes the one relevant precedent.

---

### 2. The "1 of 5" denominator is asserted, not derived, and the brief's own rows contradict it — BLOCKING

**What is wrong.** `TREE.md` B4 §2 closes:

> Only Shopify, eBay, Shopee, Tokopedia and Salesforce have a category **tree** that owns attributes, and of
> those five, **one inherits**. That is the honest denominator: **1 of 5, not 1 of 13.**

Two things break it, both from the brief's own table three paragraphs above:

- **eBay's category tree does inherit, explicitly.** The brief's eBay row reads *"Category **features**: yes,
  explicitly"* and assigns eBay **(d)**; §3 quotes eBay's `GetCategoryFeatures` Overview at length as *"the
  fullest statement anywhere in the thirteen"* — *"Each child category in the tree inherits its settings from
  its parent category."* Counting eBay in the denominator as a non-inheritor while simultaneously presenting
  it as the strongest inheritance evidence is incoherent.
- **Three of the five have no parent set to inherit *from*.** By the brief's own rows, eBay aspects are
  *"leaf-only and self-contained"*, Shopee is per leaf, and Tokopedia Era B is *"Bound to one leaf category…
  Non-leaf nodes cannot be queried for attributes at all"* (`evidence/issues/11031.md:1349`, re-read). A
  platform that only ever attaches a schema to leaves has not *chosen* not to inherit; inheritance is not
  expressible there. The like-for-like comparison — platforms whose **internal** category nodes own a
  per-node schema — is Shopify vs Salesforce: **1 of 2**.

**Where.** `TREE.md:686-689` (B4 §2 closing), re-used at `TREE.md:846-849` (B4 §7, "On the precedent count")
and `TREE.md:966` (fork §4, B4 row).

**Why it matters.** It is load-bearing twice over. B4 §7 builds *"The precedent argument against (b) is
really an argument for the fork, which is why B4 and the fork must be decided together"* directly on it, and
the fork §4/§5 tables price "keep authoring" against it. Both corrections move the precedent **in favour**
of (b) — so the brief is, ironically, understating its own recommendation while labelling the figure
"honest".

**Fix.** Replace the single number with the derivation and the alternatives it excludes: 1 of 13 (all
platforms) · 1 of 5 (any category tree that owns attributes anywhere) · **1 of 2** (internal nodes own a
schema: Shopify, Salesforce) · 2 of 6 if Akeneo's Family tree is admitted as a schema-owning tree. Say which
denominator the recommendation uses and why, and reconcile it with eBay's (d).

---

### 3. `node-attribute-need.md` — the designated shared measurement — over-maps, and the over-mapping rate is never stated — BLOCKING

**What is wrong.** Pass B strips the gender/age qualifier tokens from **both** sides, not just ours. The
brief describes it only as stripping *"the gender/age qualifier tokens our node names carry"*
(`node-attribute-need.md` §3, and the docstring of `scripts/shopify_map2.py`); the code applies `norm(…,
strip_qualifier=True)` to every taxonomy node as well (`shopify_map2.py`, `c["_tokB"] = norm(c["name"],
True)`). Consequences I measured from `data/shopify-mapping.csv`:

- **`Fashion > FASHION WANITA > ATASAN WANITA` (523 products) maps `EXACT`, score 1.0, to
  `Busana dan Aksesori > Pakaian > Pakaian Bayi & Anak > Atasan Bayi & Anak`** — women's tops onto **baby &
  children's** tops. The only id-ID node whose stripped name is `{atasan}` is the children's one; the correct
  home, `Busana dan Aksesori > Pakaian > Atasan Pakaian`, normalises to `{atasan, pakaian}` and can never
  match. Five of our nodes collapse onto `Atasan Bayi & Anak` (ids 1139, 1145, **398**, 1153, **392**), two
  of which are adult nodes.
- **`CELANA PENDEK PRIA` (368) → `Pakaian Tidur & Pakaian Santai > Loungewear > …`** — men's shorts onto
  loungewear.
- **85 of the 395 "mapped" nodes map to a taxonomy node at level ≤ 2 and 103 to a non-leaf taxonomy node** —
  e.g. `MAINAN ANAK LAKI-LAKI` (1,319), `MAINAN ANAK PEREMPUAN` (496) and `MAINAN BAYI & BALITA` (95) all
  land on the bare vertical child `Mainan & Permainan > Mainan`. That is mapping to an ancestor, not to an
  equivalent, and it imports that ancestor's generic attribute set as the node's "need".
- **47 taxonomy nodes receive more than one of our nodes (112 of our nodes collapse).**

`node-attribute-need.md` §4 states only that the 715 names are *"a property of the 395 nodes that mapped,
which are biased toward nodes whose Indonesian name happens to match a translated global taxonomy"*. It
names no wrong-match class and gives **no over-mapping rate at all** — only the under-mapping rate (76.6%).

**Where.** `node-attribute-need.md` §2 (the 715 / 290 / 436 / median-8 table), §3 (pass-B description), §4
(limits); `scripts/shopify_map2.py`; `TREE.md` B3 §5 and fork §5 (the "population bill is 715 names wide"
row).

**Why it matters.** BRIEF §2 designates this file as the **single shared measurement** that ATTR-VALUE must
cite for A3 — it is consumed by another brief as a given. The inferred half is the only ceiling TREE offers
against the measured floor of 8 kinds, and B3 §7's reopen trigger is stated in terms of it. A ceiling built
partly from the wrong nodes' attribute lists is not usable as a bound in either direction, and ATTR-VALUE
has no way to know that from the file as written.

**Fix.** (i) Correct §3 and the script docstring to say the stripping is two-sided. (ii) Hand-check a sample
of the 395 mapped nodes (the task's ten is enough to establish the class) and publish an **over-mapping
rate** beside the 76.6% miss rate. (iii) Report separately the 85 level-≤2 / 103 non-leaf targets as
"mapped to an ancestor", and recompute 715 / 290 / 436 excluding them, or state both figures. (iv) Either
restrict candidate matching so a qualifier stripped from our side cannot also be stripped from theirs, or
require the stripped tokens to be recoverable as `Jenis kelamin sasaran` / `Kelompok usia` values on the
target node.

---

## SERIOUS

### 4. B4 §2's 14-row table is attributed wholesale to a 13-row source that lacks one of the rows — SERIOUS

`TREE.md:688` footnotes the whole table: *"All rows: #11031, comment of 2026-09-15T08:28:21Z, §B, which
cites the per-platform records."* I counted the rows in that table (`evidence/issues/11031.md:1338-1352`):
**13 rows — Amazon, Shopify, eBay, Google, Walmart, Shopee, Magento, WooCommerce, Salesforce B2C, Tokopedia
Era B, Square, commercetools, Akeneo.** There is **no Tokopedia Era A row**. The brief's Era A row (*"axes
come from `get_variant?cat_id=`; no inheritance mechanism named"*, override column `—`, option **(a)**) is
the brief's own construction from #11048, and it is counted in the tally *"(a) … **11 of 14 rows**"*.
The substance is not in dispute; the attribution is false, and a red-team check of "does the cite contain
this" fails on it. **Fix:** cite the Era A row to #11048 §1.5/§2 and re-word the footnote to "all rows except
Tokopedia Era A".

### 5. Pass B is not a superset of Pass A — the 13 hand-authored vertical bindings destroy correct matches — SERIOUS

`node-attribute-need.md` §3 and `fork-shopify-taxonomy.md` §3 present pass B as *"pass A **plus** the two
pieces of work a real adoption does first"*, implying monotone improvement. It is not: re-running
`shopify_map2.py`, **58 nodes holding 5,289 products that pass A maps are `UNMAPPED` in pass B**, because
`ROOT_VERTICALS` confines candidates to a hand-chosen whitelist per root. The clearest case is
**node 53 `Fashion > KACAMATA` (642 products)**, which pass A maps `EXACT` to
`Kesehatan & Kecantikan > Perawatan Tubuh > Perawatan Penglihatan > Kacamata` — a correct home, verified by
my own probe — and which pass B cannot reach because `Fashion` is bound only to `Busana dan Aksesori` and
`Bagasi & Tas`. The whitelist is explicitly *"Judgement"* in the script and is never surfaced in the brief as
a source of error in the *under*-mapping direction. **Why it matters:** 23.4% / 76.6% is quoted six times
across `TREE.md`, `fork-shopify-taxonomy.md` and `node-attribute-need.md` as *the* automation rate that the
fork recommendation rests on. **Fix:** report `max(A, B)` as the automation rate, or publish the 58-node
regression list and say the whitelist is a judgement that costs 5,289 products of coverage.

### 6. The stated direction of the rule-assigned tail's bias is wrong, and it points away from B2's reopen trigger — SERIOUS

`nonleaf-classification.md` §2: *"Its error is one-directional: 18 of the 20 disagreements are the rule
saying `mixed` where the reading says `under-filed` (13) or `residual-type` (5). So the rule over-produces
`mixed` … the rule-assigned tail's `mixed` count (69 nodes, 2,470 products) should be read as mostly
under-filed."*

I re-read a random 20 of the 252 `basis=rule` rows (seed fixed, none in the hand-read top 40). My agreement
rate is ~40–55%, consistent with the stated 50% — but the **dominant error is the opposite one**: the rule
assigns `under-filed` or `mixed` where the node is the brief's own `residual-type` shape (children are a
facet; the parked stock is the facet's residue). Examples, with the node's own titles:

| id | node | rule says | the titles say |
|---|---|---|---|
| 52 | `Fashion > JAM TANGAN` (68) | `under-filed` | children are kids'/men's/women's; every parked title is `JAM TANGAN WANITA PRIA COUPLE` — unisex, fits no child. This is `KACAMATA`'s exact shape, which the hand-read calls `residual-type` |
| 213 | `MENJAHIT > JARUM` (2) | `under-filed` | children are sewing / pin / knitting needles; parked are `JARUM KARUNG` (sack) and `JARUM LAYAR` (sail) |
| 935 | `POPOK (DIAPERS) DEWASA` (1) | `under-filed` | children are pants-style and tape-style; parked is `LIFREE PAD REFILL` — a pad, neither |
| 945 | `PELICIN PAKAIAN` (1) | `under-filed` | children are pouch / spray / sachet; parked is `RAPIKA BIANG **KOTAK**` — a box |
| 235 | `PERALATAN & PERLENGKAPAN TENNIS` (1) | `under-filed` | only child is `BOLA TENNIS`; parked is `BET TENIS MEJA` — a table-tennis bat |
| 1677 | `… > GARPU` (8) | `mixed` | children are plastic / stainless; parked are `KAYU JATI`, `MAHONI`, `SONO` — wood, a third material |
| 125 | `PERALATAN MAKAN ANAK & BAYI` (61) | `residual-type` | one child has the **same name** as the parent; all 61 belong in it — `under-filed` |
| 110 | `IKAN & SEAFOOD SEGAR` (21) | `mixed` | two of the four children are `IKAN SEGAR LAINNYA` / `SEAFOOD SEGAR LAINNYA`, so everything fits a child — `under-filed` |

**Why it matters.** B2 §7's reopen trigger is *"if the 292 classification is re-done and finds the
residual-type share far below 20% … leaf-only becomes a one-off cleanup rather than a permanent tax."* The
brief's stated correction — read the tail's `mixed` as under-filed — would push residual-type **down**
toward that trigger. My re-read pushes it **up**. The brief's own headline (21.5% hand-read) is safe; the
bias statement attached to it is not. **Fix:** re-derive the disagreement direction from
`data/nonleaf-classification.csv` (`klass` vs `rule_says` on the 40 hand rows) and print the confusion
matrix rather than a prose summary of it; then re-state the tail correction in the direction the matrix
shows.

### 7. "A *standard* taxonomy is one we cannot extend" is a decisive fact that §7 records as not collected — SERIOUS

`TREE.md` fork §6, decisive fact 2: *"a *standard* taxonomy is one we cannot extend. Local additions fork
it, and a forked standard is our own tree with someone else's ids."* Stated as fact, unhedged, as one of
four decisive facts. `TREE.md` fork §7 then says: *"**Not collected:** the taxonomy repo's `docs/` and
contribution guide (outside the sparse checkout), **which is where a statement about extending the taxonomy
locally would live**."* The brief also establishes elsewhere that the corpus is MIT-licensed data it
proposes to *copy* per node (fork §6, "What we should take from it anyway"). Nothing prevents extending a
local copy; what is lost is upstream interoperability and the ability to take updates cleanly — which is the
honest and materially weaker claim. **Fix:** re-word to the second clause only ("a forked standard is our own
tree with someone else's ids"), label the extension claim `inference`, or collect the contribution guide
(one `git sparse-checkout add docs` on the existing clone).

### 8. B1 narrows the card's option (c), then builds "zero precedent / we would be first" on the narrowing — SERIOUS

The card (`evidence/pages/catalogue-next-steps-v7.txt:145`) defines (c) as *"One kind with a per-node switch,
so the rule can tighten later without a migration (Akeneo; lock condition 5)."* `TREE.md` B1 §2 re-defines it
as *"a per-node switch **governing whether a node may own a schema or hold products**"*, tallies **(c) = 0**
against that, and makes *"**no platform in the thirteen has a per-node switch at all.** … We would be first"*
the section's headline correction — propagated to B1 §7, B1 §8, and the fork §4 table ("with **zero
precedent** in the thirteen"). Under the card's own wording the named instance is Akeneo, and the brief's own
row confirms the mechanism exists and differs only in **scope** (per-tree, not per-node). The honest finding
is "one of thirteen, at tree scope, not node scope", which is a much weaker correction than "zero". **Fix:**
tally against the card's wording, report the scope difference as the correction (which it is), and drop "we
would be first" or restrict it to "per-*node*".

### 9. Missed consumers on both stacks, although §4 claims completeness ("established by search, not by reading") — SERIOUS

Found by independent `Grep` at the pins, absent from every section and side file:

| Missed consumer | What it is | Why it matters |
|---|---|---|
| `py/mono/solvent/catalogue/search_indexes.py:8-22` | `CategoryIndex`, with **`guid = KeywordField(model_attr="full_code")`** and `autocomplete_en`/`autocomplete_id` | Categories carry their **own** Elasticsearch document, keyed on `full_code`. This is a sixth item for the fork §5 row "all five pieces of business logic on the tree are keyed on our `Category.id`" — and the only one keyed on `full_code`, so adoption or any re-code changes every category document id |
| `py/mono/solvent/api/apiproduct/serializers.py:127, 137, 201, 208` (`main_category = CategorySerializer()`) and `:76` (`"age_walled"`) | the product **read** serializers | B1/B2 §4 list only `staff_serializers.py`. Any field added to `api/apicategory/serializers.py:9-19` under (a) or (c) surfaces here too; the age-wall flag is exposed to the customer API here, not only via search |
| `py/mono/solvent/catalogue/managers.py:28-31` — `CategoryQuerySet.browsable()` | `filter(is_public=True, ancestors_are_public=True)` | the actual reader of the inherited visibility flags the brief calls "inherits free"; never cited, though BRIEF §3.3 names `managers.py` |
| `ts/libs/category/action/ui-form/.../category-form-ui.component.ts:96-97` | the category **parent** picker, also formly `type: 'category-id'` | B1 §4 says under (a) "the tree node and the picker must stop offering folders" — but this picker needs the **inverse** filter (offer folders, refuse types). It is a second, oppositely-constrained consumer of the one picker component |
| `ts/libs/product/filter/util-core/src/lib/product-filter.util.ts:36` | a ninth `category-id` registration | not in design-B3 §1's list of eight |

**Fix:** add all five; move the `CategoryIndex` finding into the fork §5 "business logic on the tree" row
(making it six, one of them keyed on `full_code` rather than `id`).

### 10. "No breadcrumbs" is a word-search artefact; an ancestors endpoint, an ancestors service and a parent-link UI all exist — SERIOUS

`TREE.md` B3 §4 and `design-B3.md` §1 assert *"There are **no breadcrumbs** (`breadcrumb` → zero hits across
`ts/libs`, `ts/apps`)"* and use it to grade the card's "browse need" criterion. The grep is correct — and
misleading. At the pins:

- `py/mono/solvent/api/apicategory/views.py:46-55` — a cached `ancestors` action returning
  `category.get_ancestors_and_self()`.
- `ts/libs/category/list/data-access/src/lib/category-tree.service.ts:16` —
  `categoryAncestorsUrl = 'api/category/%d/ancestors/'`.
- `ts/libs/category/detail/feature-parent-link/.../category-parent-link.component.ts` +
  `ts/libs/category/detail/ui-parent-link/.../category-parent-link-ui.component.ts`, rendered unconditionally
  on every category detail page (`category-detail-ui.component.html:1`).
- `ts/libs/category/tree/feature-core/.../category-tree-select.component.ts:50-73` — the picker **pre-expands
  the tree along the ancestor chain** to the current selection, so "the only way down is one level at a time"
  is not true for the picker with an initial value.

The parent-link renders only `ancestors[length-2]` — one level up — so "no multi-level breadcrumb trail" is
true in effect. But the ancestry read path exists, is wired end to end, and is a consumer the brief should
have found. **Why it matters:** B3 §6 grades "a browse need" as *"the UI it serves is a one-level-at-a-time
drill-down with no breadcrumbs, so each level costs the customer a tap"* — a claim about the cost of depth
that the existing pre-expansion partly refutes. **Fix:** replace the zero-hit grep with the four cites above
and re-state the criterion as "one-level-up link, no full trail".

### 11. The card's "what sellers do about it" evidence has no saved artifact anywhere — SERIOUS

`TREE.md` B2 §3 quotes an eBay Community thread verbatim (*"I have tried consumer electronics > others and
computers & networking > other and both throw the same … error."*, *"Do a search for your item, and you'll see
what category other sellers have used."*, *"I will just quit using eBay."*) and a 3Dsellers help page. The
Appendix lists both and marks the B1 pointer ✅. **Neither is on disk.** `corpus/why-2026-09/` holds exactly
six files (the two eBay pages, two 403 bodies, two README copies); `grep -rl "I have tried consumer
electronics" corpus/` and `grep -rl "3[Dd]sellers" corpus/` both return nothing. BRIEF §3.2 requires
*"Everything fetched lands in `~/copilot/research/catalogue-step0-2026-09/corpus/<platform-or-source>/`"*.
As it stands the quotes cannot be re-opened, and this is the seller-behaviour evidence that B2 §6 turns into
*"That is the eBay seller behaviour collected in §3, reproduced in our own tree by design"*. **Fix:** save
both pages under `corpus/why-2026-09/` with URL + fetch date + byte count, or mark the claim "not collected +
route" and drop the ✅.

### 12. Three "Why" bullets present an unlabelled causal inference as a stated vendor reason — SERIOUS

BRIEF §4 is explicit: *"Never a guess presented as the vendor's reason."*

- **B3 §3, Amazon** — headed *"**stated**, and it is a governance reason"*, ends *"**107 is small because
  Amazon, not the seller, pays for every one.**"* I re-opened `evidence/issues/10976.md:53`: the record states
  non-creatability (12 patterns / 877 files / 16,441,164 B → 0 hits each) and the correction route ("submit a
  request to update it using the Category update tool"). Those are stated **facts about creatability**. The
  causal claim about *why the count is 107* is the brief's inference and is unlabelled.
- **B1 §3, Square** — headed *"**stated**"*, and *"**This is the only vendor rationale in the row**"*. The
  quote (`evidence/issues/11049.md`, verified) warns that the Dashboard auto-creates `MENU_CATEGORY` rows and
  tells integrators to filter for `REGULAR_CATEGORY`. It is a warning about a **consequence**; it states no
  reason for the type discriminator existing. The following sentence — *"Square's node kinds exist because two
  surfaces (till and kitchen display) write into one tree"* — is inference.
- **B2 §3 / B3 §3, Google** — headed *"**stated**"*. The quote establishes automatic assignment; *"A leaf rule
  on a field the platform fills for you would be incoherent"* and *"Depth is cheap because no one authors a
  schema per node"* are inferences.

**Fix:** split each bullet into "stated:" (the quote, which stands) and "inference:" (the causal sentence),
exactly as the brief already does correctly for Shopify, Akeneo, Magento and Salesforce.

### 13. The fork card has no who-uses matrix and no "Why" section — SERIOUS

BRIEF §2 lists *"**the Step-1 fork**: keep authoring our own tree vs adopt the Shopify Standard Product
Taxonomy"* as one of TREE's cards, and §4 fixes the eight-section shape for "one section per card". The fork
section (`TREE.md:883-1035`) has seven headings and **no §2 platform matrix, no §3 Why, and no §4 Our code
today** (the code content is one cell in the §5 bill table). The owner's stated first priority is *"who uses
… 'who uses' is extremely important"*, and the fork is answerable that way from records already read: which
of the thirteen author their own classification, which adopt an external standard, which publish a *mapping*
to one rather than adopting it (the brief itself found
`dist/en/integrations/google/shopify_2026-08_to_google_2021-09-21.json`), and which let the merchant author.
**Fix:** add the 13-row matrix and a Why section; the material for it is already in the B3 §2 table's
"Authored by" column.

### 14. #10778 is never mentioned anywhere in TREE, although two recommendations sit on its territory — SERIOUS

`grep -ri "10778" briefs/TREE/` returns **zero** hits in `TREE.md` and every side file. BRIEF §1 requires
#10778's standing decisions be *"confirm[ed], re-express[ed], or propose[d] superseding; never silently
contradict[ed]"*, and §4 repeats it. Two places lean on #10778 territory:

- fork §6, *"What we should take from it anyway … the attribute **vocabulary**. 715 names with closed,
  translated id-ID value lists … That is the same mechanism A3 is deciding — a shared attribute catalogue —
  seeded rather than invented."* That is #10778 **V1** (axis names from a shared staff-extendable catalogue)
  and **C5** (one global name catalogue, not scoped per category), proposed to be seeded from a vendor corpus,
  with no disposition.
- B4 §7, *"**allowed values** | inherits; a child may narrow"* — per-node narrowing of a value list is
  adjacent to **C5**'s "not scoped per category" and needs at least a "re-express" note.

The brief also does not carry BRIEF §1's warning that *"#10778's evidence pass was found unsound in parts …
Re-verify any #10778 claim you lean on."* **Fix:** add a short "#10778 disposition" paragraph naming V1, C5
and (if relied on) V4, each marked confirm / re-express / supersede.

### 15. `api/apisearch/filters.py:26-29` does not say what B2 §4 says it says, and the "five serializers" do not exist — SERIOUS

`TREE.md` B2 §4: *"so do the eight admin category filters (`api/apisearch/filters.py:26-29` and the five
serializers listed in `design-B3.md` §1)"*. Re-opened at the pin: `filters.py:26-29` is
`_handle_equality_filters(self, queryset, validated_data) → queryset.filter(**validated_data)` — a generic
helper with no category in it. The category query field is `py/mono/solvent/api/apisearch/serializers.py:10`
(`category = PositiveInteger32Field()`). And `design-B3.md` §1 lists **eight admin tables**, not five
serializers. (The eight-table count itself is correct — I count exactly 8 non-spec `type: 'category-id'`
filter registrations, including the two distinct price-purchase tables at
`ts/libs/purchasing/price-purchase/…:113` and `ts/libs/price/purchase/…:85`.) **Fix:** cite
`apisearch/serializers.py:10` plus the eight frontend registrations by path, and correct the cross-reference.

### 16. "436 names over the 185 mapped nodes" and "186 (158 EXACT + 28 FUZZY)" describe the same stated population with different numbers, and the brief's own data file says 439 — SERIOUS

Both figures reproduce — but from **different scripts that build different "639 nodes covering 90%" sets**,
because the set is tie-unstable at the 90% boundary and the two scripts sort with different tie-breaks:

- `scripts/shopify_map2.py` prints *"the 639 nodes covering 90% of products, pass B: UNMAPPED=424,
  EXACT=158, AMBIGUOUS=29, FUZZY=28 … distinct Shopify attribute names the mapped ones carry: **439**"*, and
  writes `data/shopify-attrs-for-our-90pct.json` with **439** entries (I diffed it — the saved file is 439).
- `scripts/node_attribute_need.py` prints *"of the 639 nodes covering 90%: **185** have an inferred set,
  carrying **436** distinct attribute names."*

`TREE.md` fork §3 quotes 186; `node-attribute-need.md` §2, `TREE.md` B3 §5, `TREE.md` fork §5 and
`fork-shopify-taxonomy.md` §5 all quote 185/436 — while the artifact those four cite for the full list
(`data/shopify-attrs-for-our-90pct.json`) contains 439. A reader opening the cited file to check the number
finds a different one. **Fix:** make the 90% cut deterministic (sort by products **then id**), regenerate
both, and state one number; or say explicitly that 185/436 and 186/439 are two admissible cuts of a tied
boundary.

### 17. B3's recommendation reasons from the measured floor (68) while its own inferred route says 290, and only §7's reopen note discounts it — SERIOUS

B3 §7: *"(b) is the only option whose authoring bill is bounded by the number of *distinct sets* (68
measured, 47 inside the 639) rather than by the number of nodes."* But `node-attribute-need.md` §2 measures
the inferred route at **290 distinct sets over just the 395 nodes it reaches** — 0.73 sets per node, against
the measured route's 0.04 — and §0 states the measured route *"**under**-states the need"* while the inferred
one over-states it. If the real schema lands anywhere between, (b)'s bill is in the hundreds of sets, not 68,
and the "68 vs 1,686" argument for (b) over (a) weakens sharply. §7's "what would reopen it" does name this,
but the recommendation's *reasoning* uses 68 as if it were the bill. **Why it matters:** the whole
B3-recommends-(b), and B3-and-B4-are-one-decision, chain hangs on the 68-vs-1,686 gap. **Fix:** state the bill
as a range (68 floor · 290 inferred over the mapped quarter · 1,686 under (a)) in the reasoning, not only in
the reopen clause, and say which end the recommendation assumes.

---

## MINOR

18. **`TREE.md` B3 §7: "328 deep nodes hold 13,847 products and **87%** of them are one branch."** The
brief's own §5 line gives 13,148 of 13,847 → **95.0%** of products, and 311 of 328 → **94.8%** of nodes.
87% reproduces on neither reading. It understates the brief's case. Fix: 95%.

19. **"Our `MIE, BIHUN, KWETIAU INSTAN` branch is three nodes and 394 products"** (`TREE.md` fork §2(ii),
`fork-shopify-taxonomy.md` §2.2, `node-attribute-need.md` §4). From `nodes-full.csv`: node 99 has **six**
children and a subtree of **439** products across **7** nodes. 394 = node 99 (16) + `MIE INSTAN BUNGKUS`
(318) + `MIE INSTAN DALAM KEMASAN CUP` (60) — the *mie-only* sub-branch, excluding `BIHUN INSTAN BUNGKUS`
(24), `KWETIAU INSTAN BUNGKUS` (3), `PASTA INSTAN BUNGKUS` (18), `MIESOA INSTAN BUNGKUS` (0). Fix: name the
sub-branch, or use 7 nodes / 439.

20. **`corpus/why-2026-09/ebay-edp-metadata.html` is 200,027 B on disk; the brief reports "HTTP 200,
**38,126 B**"** (B2 §3 and the Appendix). The other three byte counts match exactly (63,985 / 1,832 / 1,832),
so the verification trail is otherwise sound. All four quoted sentences from that page verify in the saved
file. Fix: restate the size.

21. **`TREE.md` B4 §5: "5,580 distinct raw values, **of which** 15,475 are junk."** 15,475 is the baseline's
`manufacturer_junk_set` **row** count (I re-read `sql/results/baseline.json`), not a count of distinct
values, and it exceeds 5,580 — the sentence is arithmetically impossible as written. Fix: "46,499 rows, of
which 15,475 carry a junk value; 5,580 distinct raw values."

22. **"3,402 **live** products"** (B1 §7, B2 §5, `nonleaf-classification.md` §5, the closed-card section).
3,402 is the current-row count; **3,209** are `is_active`. Fix: say "current rows" or give both.

23. **`Santan` and `Rice Cooker` listed among "Present" id-ID leaf names** (`TREE.md` fork §2(ii),
`fork-shopify-taxonomy.md` §2.2). No id-ID node is named `Santan` (there are `Santan & Minuman Kelapa` and
`Santan & Krim Kelapa`), and **no id-ID node contains "Rice Cooker" at all** — the id-ID name is `Penanak
Nasi`. The list mixes en and id names. The **absence** probes, which are the load-bearing half, all verify:
`Batik`, `Mukena`, `Sajadah`, `Kebaya`, `Kopiah`, `Peci`, `Sarong`, `Sambal`, `Terasi`, `Kapur barus` =
0 word-boundary hits in both builds.

24. **The legacy Vue widget's `is_leaf` branch is dead.** B1 §4 calls
`js/solvent_js/src/js/solvent/CategorySelectWidget.vue:71-72` *"the one surviving consumer"* of `is_leaf`.
Correct as code — but `grep -rn "is_leaf" py/mono --include=*.py` returns **zero hits**, so the API never
emits the field and `!result.is_leaf` is always true. The brief's point ("leafness is not stored and barely
read") is strengthened, not weakened; it should say so.

25. **`design-B4.md` §0 is headed "The **four** kinds of fact"** and `TREE.md`'s lede says *"four different
ways for four different kinds of fact"*, but the table lists **six** kinds (definitions, requiredness,
age-walling, replenishment, visibility, search browse). Fix the count, or say "six kinds, four mechanisms".

26. **B4 §7: "`accepts_products` must NOT flow down — a folder's children are exactly the nodes that do
accept products."** False in general on an 8-deep tree with 339 internal nodes: a folder's children are
frequently folders. The conclusion (don't inherit) stands; the justification does not. Fix: "a folder's
descendants include the nodes that do accept products, so inheriting `false` would disable them."

27. **`fork-shopify-taxonomy.md` §4 and §5 still say B4 "needs (b) … on **one precedent of thirteen**"**,
contradicting `TREE.md` B4 §7's *"the honest denominator is 1 of 5, not 1 of 13"* and `TREE.md` fork §4's own
"1 of 5". Fix the side file (and see BLOCKING 2 for what the number should be).

28. **`TREE.md` B3 §7 compares "Shopify 7, Google 7, eBay ~6, Tokopedia v2 7" against our depth** without
saying Shopify's `level` is **0-based** (the histogram is 26 nodes at level 0). Shopify's max level 7 = 8
levels = exactly our max depth 8, so "deeper than our median" is true but "deeper" invites a wrong reading.
`design-B3.md` §2 does label it "(0-based)"; `TREE.md` does not, and that is where the comparison is made.

29. **B1 §2's commercetools cell reuses a B2 measurement as B1 evidence.** *"`leaf` occurs **0** times in
5,366,096 B of spec"* is, in `evidence/issues/11031.md:1351`, the answer to *"Product on a non-leaf node?"* —
a leaf-**permission** measurement, not a node-**kinds** one. It happens to support (b) either way, but the
same string doing double duty in two different matrices should be flagged, and the genuine B1 evidence (*"the
`Category` tree owns no attribute definitions"*) is already in the same cell.

30. **`TREE.md` B4 §7 cites Amazon as "(#10976 §)"** — an empty section marker. The sentence *"Requiredness is
a property of this join, not of the Attribute"* is at `evidence/issues/10976.md:158`. Fix the cite.

31. **Catch-all counts mix denominators.** The BRIEF baseline's "42 nodes / 3,566 products" counts **used**
nodes (`baseline.sql:49-50`, `WHERE n>0`). The brief's wider pattern gives *"48 / 3,591, of which **34** are
leaves"* (B2 §3, §5, §6; `nonleaf-classification.md` §6) — but 48 and 34 count **all** nodes, including four
unused ones; the used-only figures are 44 nodes and 32 leaves (products are 3,591 either way). Presented
side by side with the baseline's 42 as though comparable. Fix: state both on the same basis.

---

## Verified clean

Re-run or re-opened independently, and confirmed:

**BigQuery.** `sql/nodes-full.sql` re-run against `solvent-staging` — output **byte-identical** to
`sql/results/nodes-full.csv` after sort. Every figure derived from it reproduces exactly: 1,892 nodes ·
1,553 leaves · 339 internal · 13 roots · max depth 8 · 1,686 used · 292 used internal · 1,394 used leaves ·
206 unused (159 leaves) · children per internal node median 4 / mean 5.54 / max 90 · nodes by depth
13·74·453·822·190·120·128·92 · products by depth 1,724·11,172·24,257·49,478·5,683·6,361·3,737·3,749 ·
50/80/90/95/99% at 114/398/639/869/1,278 · 609 used nodes <10 products holding 2,545 (2.4%) · 216 <3 holding
315 · 328 used nodes at depth ≥6 holding 13,847, 13,148 in `Perawatan Diri & Rumah Tangga` · 727 used nodes
at depth 4 · 19,522 on non-leaf (18.39%) · 1,724 on a root · 1,077 left after a ≥10 merge · 15 of 1,686 with
`_name_en`. `sql/results/products-titles.csv` = 106,161 rows, matching the baseline.

**Age-walling, sized.** All eight ids resolve as stated — 17 `ROKOK & LAINNYA` (d2, 5 children, 0 direct, 92
subtree) · 115 (0) · 117 (92) · 145 `KESEHATAN SEKSUAL` (d3, 4 children, 0 direct, 36 subtree) · 931 (0) ·
932 (5) · 933 (27) · 934 (4). **Total 128.** Union of the 8 subtrees = **11 nodes, 128 products** — so "an
ancestry rule would newly wall 0 products today" is exact, and the §8 self-correction about it is honest.

**The three non-type roots.** `UNUSED` subtree 1,923 (`ARTEMEDIA` 830, `CARDINAL OBRAL` 353, `CARDINAL
NORMAL` 166, `OLYMPIC` 264, `FOOD COURT` 81) · `BELUM DISORTIR` 1,401 (child `BARANG OBRAL` 1,382) ·
`INVENTORY KANTOR` 78 · total **3,402** (3.2%).

**Named tree pathologies.** `Alat dan Buku Tulis > BUKU TULIS` id 41, 219 products, child id 321 of the same
name ✓ · `SAYURAN SEGAR` id 111, **90** children, 222 parked ✓ · `Fashion > KACAMATA` 642, 3 children ✓ ·
`PAKAIAN DALAM WANITA` 299, 4 children ✓ · `MENJAHIT` 225, **15** children ✓ · node **612** `MIE INSTAN
BUNGKUS` 318 ✓.

**Shopify corpus** (`ad206247ecc45a95fe4b01bce2ad2f0e7bec3c66`, verified by `git log`, sparse `dist/en` +
`dist/id-ID`). `scripts/shopify_corpus.py` re-run — output **byte-identical** to
`data/shopify-corpus-stats.json`. Confirmed: build string `2026-11-unstable` in both locales · 14,606
categories in both · 26 verticals · 8,240 definitions in both · 0 with an empty `values[]` · 74,820 values,
median 7, max 451 · 152 nodes (1.04%) with no attributes · attributes per category median 6 / mean 6.37 /
max 28 · **93,007** category→attribute edges · `inherit` = 0 in `taxonomy.json` (95,139,186 B — file size
confirmed by `ls`), `categories.json`, `attributes.json` · **4,569 of 14,580** parent→child pairs drop at
least one parent attribute (10,011 supersets, 10,159 dropped occurrences) — and the record's 4,668
(`evidence/issues/11031.md:1341`) is correctly flagged as not reproducing · **262** base names matching
`size|volume|weight`, 272 with the 316 extended renames, 254 distinct edge names, 85 used by >1 category, 18
by none — and the card's 300 correctly flagged as not reproducing · `Size` = `TaxonomyAttribute/2778`, 80
garment values (`XXXS`…`6XL`, `000`, `00`), carried by **464** categories · only **15** of 8,240 definitions
have any numeric+unit value and **none is a net content** (`Compatible can size`, `Spoke gauge`, `CO2
cylinder compatibility`, …) · **18** duplicate `full_name` paths in id-ID (36 rows), 0 in en; 298 vs 205
duplicate leaf names · food branch **764** nodes, 656 leaves, max level 6, median 5 attributes (mean 5.51,
max 13, 1 with none), 483 distinct names, **320** leaf attribute sets · `Snack Foods` = 44 descendants ·
`Pakaian Tradisional & Seremonial` = 17 descendants · `Pasta & Noodles` (`fb-2-14`) = **one node, 5
attributes, no children** · the id-ID Yoghurt example carries exactly the seven named attributes with the
counts quoted (`Informasi alergen` 16 · `Varian beta-kasein` 4 · `Preferensi diet` 28 · `Kandungan lemak` 8 ·
`Rasa` 30 · `Persyaratan penyimpanan` 6 · `Bahan dasar yogurt` 15).

**Taxonomy absence probes** (word-boundary, both 14,606-node builds): `Batik` 0 · `Mukena` 0 · `Sajadah` 0 ·
`Kebaya` 0 · `Kopiah` 0 · `Peci` 0 · `Sarong` 0 · `Sambal` 0 · `Terasi` 0 · `Kapur barus` 0 · `Mi Instan` /
`Instant noodle` 0. The load-bearing fork claim holds.

**Mapping scripts.** `scripts/shopify_map2.py` re-run — `data/shopify-mapping.csv` **byte-identical**.
Pass A 253/127/59/1,247 (380 mapped = 22.5%, 25,012 products = 23.6%); pass B 308/87/59/1,232 (**395 =
23.4%**, **32,962 = 31.0%**, miss 1,291 = 76.6% / 73,199 = 69.0%). Gender/age qualifier nodes: **302
(17.9%), 42,621 products (40.1%), 168 collapsing onto a shared name.** All reproduce.

**`scripts/node_attribute_need.py`** re-run — `data/node-attribute-need.csv` and
`data/node-attribute-need-summary.json` **byte-identical**. Measured route: **68** distinct need-sets over
1,686 used nodes, **1,665 (98.8%)** sharing · **61** over 1,394 used leaves, **1,376 (98.7%)** sharing ·
**47** across the 639 · the twelve most common sets reproduce row for row · kind counts `net_content` 617 /
`colour` 494 / `model_code` 454 / `pack_count` 202 / `flavour` 199 / `scent` 93 / `material` 88 /
`garment_size` 49 / none 369 · 8 kinds. Inferred route: 395 mapped, **290** sets, **166 (42.0%)** sharing,
**715** distinct names, median **8**, and the top-20 name list reproduces exactly.

**Non-leaf classification.** `data/nonleaf-classification.csv` = 292 rows, 40 `hand` / 252 `rule`. Both
class tables reproduce exactly: hand 21/9/4/2/2/2 nodes and 7,086/2,919/1,403/1,217/519/411 products
(13,555 = 69.4% of 19,522; residual-type 21.53%); rule 95/69/69/10/7/2 nodes and 5,967 products.

**Code cites re-opened at the pins (all correct unless listed above).** `catalogue/models.py:93` `class
Category(MP_Node)` with the "merely navigational" docstring at `:94-96`, `Meta` at `:100-102`, no `clean()`
and no `Meta.constraints` in `:93-330` · `:136` `full_code` · `:149-157` `is_public` + `ancestors_are_public`
· `:251-253` `SearchIndexQueue().enqueue_update(self)` · `:271-285` `set_ancestors_are_public()` with
`path__rstartswith` / `depth__lt` at `:277-278` · `:287-301` `_ancestors_and_self` `@cached_property` ·
`:322-330` `has_children` / `is_has_children` / `get_num_children` · `:333-348` `ProductCategory` ·
`:419` + `:890` the only two `ManyToManyField`s · `:427-431` `main_category` FK `PROTECT`, no `validators=`,
no `limit_choices_to` · `:468-484` `Product.clean()` with the docstring table at `:471-479`, category absent
· `:570-573` `age_walled` verbatim · `:618-624` `ProductAttribute.product_class` · `:655`
`ProductAttribute.required` · `:88-90` `ProductClass.default()` = `objects.get()` with no filter ·
`settings/base.py:928-937` the 8 ids verbatim · `shared/test_utils/django/settings.py:173-174` empty ·
`inventory_replenishment_service.py:31-36` · `catalogue/search_indexes_mixins.py:22, 27-29` ·
`search/search_indexes.py:45, :64-65 (faceted=True), :134-135` · `catalogue/receivers.py:18-20` ·
`search/receivers.py:26-30` (the asymmetry comment) · `catalogue/validators.py` 47 lines, one function at
`:10` · `catalogue/utils.py:1-2` · `catalogue/admin.py:46, :60-62` · `apicategory/staff_views.py:32`,
`:37-44` (Create + Update only, no Destroy) · `apicategory/views.py:85` · `apicategory/serializers.py:9-19`
(nine fields) · `apicategory/staff_serializers.py:69-81`, `:104-148`, `:116` `category.move`, `:117-120`
`InvalidMoveToDescendant`, `:131-146` `full_code` cascade · `apiproduct/staff_serializers.py:55` (plain
`main_category` in `Meta.fields`), `:84`, `:116-119`, `:131` · `apiproduct/staff_views.py:66-67` ·
`apisearch/serializers.py:17` · the age-wall integration test at `:23` and `:39` ·
`third_party_api/google/content/products_api.py:188` and
`google_product_category|product_type|googleProductCategory` = **0 hits** across
`solvent/third_party_api/google/` · `catalogue/migrations/0001_initial.py:34` `numchild`, and `numchild` =
**0 hits** anywhere else in `py/mono` · `validate_main_category` = **0 hits** in `py/mono`.

**Frontend cites at `82187a17bd`.** `category.model.ts:3-17` = exactly the nine fields listed ·
`category-tree-node.component.html:1-4` renders `Pilih` unconditionally · `category-id-form-field.component.ts`
is the one picker component · `category-list-staff.component.ts:27` flat paging ·
`category-list-children-staff.component.ts:28-32` · `category-search-staff.service.ts:18-42` with the
first-page-only docstring · `category-tree-children.component.ts:28-29` (the URL itself is at
`category-tree.service.ts:15`) · `product.model.ts:52, 76, 90` scalar `main_category` ·
`product-update-staff-form-ui.component.ts:118-122` · `product-filter.model.ts:5` ·
`revision-with-previous-paging.service.ts:62` · `CategorySelectWidget.vue:71-72` · `is_leaf`/`isLeaf`,
`breadcrumb` and `facet` all **0 hits** across `ts/libs` and `ts/apps` (see SERIOUS 10 for what that grep
hides) · exactly **8** non-spec `type: 'category-id'` filter-table registrations, matching design-B3 §1's
list including the two distinct price-purchase tables.

**Record quotes.** Verified verbatim in `evidence/issues/`: Amazon's flat `ProductTypeList`, 107 `xsd:choice`
refs, the 1,640 floor, "❗ Not creatable" with 12 patterns / 877 files / 16,441,164 B, `NewProductTypes`,
"Category update tool", 26,135 / **15,299** deletion rows, and "Requiredness is a property of this join"
(`10976.md:158`) · Shopify's `isLeaf Boolean!` (`11011.md`), the `aa-1-13` live write, "Owner subtype does
not match…" · Google's "every line is `id - path`", "continuously evolving product taxonomy", "14 are
parents" · eBay's `62009` "must be a leaf category" and the whole `GetCategoryFeatures` inheritance
paragraph + "inheritance override model" / "Store the data locally" (`11031.md:1356-1358`) · Walmart's 6,967
/ 451,013,258 B / "no category field in the feed at all" · Shopee's "has_children =false means the last
level category" and "Please note that only the category_id with has_children =false can be used to create or
update products" (`11047.md:76`, exact) · Tokopedia Era B's "It must be a leaf category that corresponds to
the category tree type specified in the `category_version` property" (`11048.md:949`) and `Qualification
Center` · Square's `CatalogCategoryType` / `MENU_CATEGORY` · Salesforce's "three roles on one `Category`
type", "the sub-category group overrides the parent group", and the §C retraction of the earlier "cannot be
overridden" cite (`11031.md:1362-1364`) · Akeneo's `Category.orm.yml` = 0, "automatically inherit every
attribute from the parent level", and the no-removal / completeness restriction · WooCommerce's 9-property
`product_cat` term · Magento's own `attribute_set_id`. The B4 §2 table matches `11031.md:1338-1352` row for
row apart from the Tokopedia Era A row (SERIOUS 4). Akeneo's `only_leaves` being **per-tree** is indeed in
two records — `11031.md:1352` and `11188.md:170` ("leaf-only is a **per-tree setting** rather than a law") —
and the brief's "single-route, could not re-open" caveat is honest.

**New collection.** `corpus/why-2026-09/` opened: `ebay-edp-metadata.html` contains *"Every eBay listing
must be listed in an eBay leaf category."* and *"Some metadata endpoints only accept leaf categories."*
(both twice), plus `getItemAspectsForCategory`, `fetchItemAspects`, `getCategorySuggestions`,
`ProductIdentifierUnavailableText` · `ebay-2824ab.html` row parsed to exactly
`['87', 'Invalid Category. The category selected is not a leaf category.', 'Listing will fail.']` ·
the two 403 bodies are 1,832 B eBay error pages as described · both Shopify READMEs are byte-identical,
md5 **`5d197d41f6fc02b731ca95cfa93c9730`** as claimed, and line 63 carries the `dist/` deprecation notice
verbatim with **October 31, 2026**.

**Structure.** B1, B2, B3 and B4 each carry all eight BRIEF §4 sections. Every recommendation is explicitly
labelled a judgement with a confidence, a "what would reopen it" and a "what it forces in steps 1–5".
`node-attribute-need.md` does separate MEASURED from INFERRED, name the blind spot of each, give the
direction of error, publish the miss rate and the detectors, and attack itself in §4 — so it is usable by
ATTR-VALUE **once BLOCKING 3 is fixed**; without an over-mapping rate its inferred half is not a sound
ceiling. Card pointers B1 (eBay 62009 + seller behaviour), B2 (all 292 classified), B3 (Shopify food branch
from the corpus; Amazon 107 vs Google 5,595; leaves sharing an attribute need), B4 (eBay inheritance; the
#11188 survey; our own age-wall and replenishment code) and both fork pointers were all executed; the only
silent gap is the unsaved seller-behaviour artifacts (SERIOUS 11) and the missing fork matrix (SERIOUS 13).
