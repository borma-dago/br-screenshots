# B2 · All 292 used non-leaf nodes, classified

**Question from the card:** *"which of our 292 used non-leaf nodes are real types (a product genuinely
belongs at 'Snack') and which are catch-alls (Mainan dan Alat Lainnya: 1,048 products at depth 1)"*.

**Snapshot 2026-09-19.** SQL: `sql/nonleaf-used.sql`, `sql/nodes-full.sql`, `sql/products-titles.sql`.
Signals: `scripts/nonleaf_classify.py` → `sql/results/nonleaf-signals.csv`.
Classes: `scripts/nonleaf_classes.py` → **`data/nonleaf-classification.csv` (all 292 rows, with the
children list and a 12-title sample per node)**. Hand-review listing: `data/nonleaf-review.txt`.

**Answer in one line: about one fifth (21.9% of the hand-read products) of the products parked on a
non-leaf node are there legitimately. The rest is under-filing, catch-alls, and three roots that are not
product types at all.**

---

## 1 · Classes

| Class | Meaning |
|---|---|
| `residual-type` | the node names a real kind; its children are *partial* refinements, so a product of that kind with no fitting child genuinely stops here — this is the card's "a product genuinely belongs at Snack" |
| `under-filed` | a child that fits the parked products already exists; the assignment is a data-entry residue |
| `mixed` | the parked products span several of the children's kinds, or kinds belonging to a different branch entirely |
| `declared-catch-all` | the node's own **name** declares a residual bucket (LAIN / LAINNYA / OTHER / ANEKA / …) |
| `root-parking` | a depth-1 root holding products directly |
| `not-a-type` | the node or an ancestor is an operational / merchandising container, not a kind of product |

## 2 · Method, and its accuracy

Two mechanical signals per node:

- **`child_name_hit`** — the share of the node's own products whose title contains a distinctive word from
  one of its **children's names** (words shared with the parent's name and a stop list are removed). High
  means a named child already exists for those products.
- **`nearest_child`** — a leave-one-out nearest-class test over idf-weighted title tokens: each of the node's
  own products is scored against every child's subtree title corpus and against the node's own residual
  corpus. The reported figure is the share whose best class is a child.

Then: **the top 40 nodes by product count — 13,555 of the 19,522 products, 69.4% — were read one by one**
against their children and a 12-title sample, and carry `basis=hand`. **Red-team round 1 re-read a random **20** of the
rule-assigned tail and tabulated the **8** it judged misclassified; those 8 verdicts are adopted here
verbatim and carry `basis=hand-redteam`. The 8 are therefore an ERROR-ENRICHED SUBSAMPLE, not a random 8**
*(described correctly after red-team round 2, SERIOUS 6)* (`scripts/nonleaf_classes.py`, dict `REDTEAM_HAND`, each with its reason). The
remaining 244 nodes (5,804 products, 29.7%) are assigned by rule and carry `basis=rule`.

**Rule accuracy: 20 of the 48 hand-read nodes, 42%.**

**Confusion matrix on the 40 top-by-products hand-read nodes** (rows = rule, columns = reading):

| rule \ hand | under-filed | residual-type | mixed | catch-all | root-parking | not-a-type | total |
|---|---|---|---|---|---|---|---|
| under-filed | 8 | 1 | 1 | 0 | 0 | 0 | 10 |
| residual-type | 0 | **3** | 0 | 0 | 0 | 0 | 3 |
| mixed | 13 | 5 | **3** | 0 | 0 | 0 | 21 |
| declared-catch-all | 0 | 0 | 0 | **2** | 0 | 0 | 2 |
| root-parking | 0 | 0 | 0 | 0 | **2** | 0 | 2 |
| not-a-type | 0 | 0 | 0 | 0 | 0 | **2** | 2 |
| **total** | 21 | 9 | 4 | 2 | 2 | 2 | 40 |

**The direction of the rule's error is NOT established, and revision 1's claim that it was is withdrawn.**
On this stratum the rule over-produces `mixed` (21 calls, only 3 correct; 13 are really `under-filed` and 5
`residual-type`). On the tail, the red team's readings show the opposite lean. **"The rule agreed on 0 of 8" is a restatement
of how the 8 were chosen, not a measurement** — they are the disagreeing rows of a random-20 re-read whose
own agreement rate was reported as **~40–55%, consistent with the top-40 stratum's 50%**. What the 8 do
establish is the *shape* of the tail's errors: five of the eight are `residual-type` nodes the rule called
`under-filed` or `mixed`:

| id | node | rule said | reading | why |
|---|---|---|---|---|
| 52 | `Fashion > JAM TANGAN` (68) | under-filed | **residual-type** | children are kids'/men's/women's; every parked title is `JAM TANGAN WANITA PRIA COUPLE` — unisex, fits no child. `KACAMATA`'s exact shape |
| 213 | `MENJAHIT > JARUM` (2) | under-filed | **residual-type** | children are sewing/pin/knitting needles; parked are `JARUM KARUNG` (sack) and `JARUM LAYAR` (sail) |
| 935 | `POPOK (DIAPERS) DEWASA` (1) | under-filed | **residual-type** | children are pants-style and tape-style; parked is `LIFREE PAD REFILL` — a pad, neither |
| 945 | `PELICIN PAKAIAN` (1) | under-filed | **residual-type** | children are pouch/spray/sachet; parked is `RAPIKA BIANG KOTAK` — a box |
| 1677 | `… > PERALATAN MAKAN > GARPU` (8) | mixed | **residual-type** | children are plastic/stainless; parked are `KAYU JATI`, `MAHONI`, `SONO` — wood, a third material |
| 235 | `PERALATAN & PERLENGKAPAN TENNIS` (1) | under-filed | **mixed** | only child is `BOLA TENNIS`; parked is `BET TENIS MEJA` — a table-tennis bat |
| 125 | `PERALATAN MAKAN ANAK & BAYI` (61) | residual-type | **under-filed** | one child has the **same name** as the parent; all 61 feeding sets belong in it |
| 110 | `IKAN & SEAFOOD SEGAR` (21) | mixed | **under-filed** | two of the four children are `… LAINNYA` catch-alls, so everything fits a child |

**So the rule errs in both directions**, and the 244 rule-assigned nodes (29.7% of the products) are an
estimate whose class distribution is unresolved.

**What each number is a sample of, stated because the two strata are not interchangeable:**

| Stratum | n | what it is | rule agreement |
|---|---|---|---|
| top-by-products | 40 | the 40 largest used non-leaf nodes — a census of the head, unbiased *within* it | **20 of 40 = 50%** |
| adopted tail rows | 8 | the disagreeing rows of a random-20 tail re-read — **selected for being wrong** | 0 of 8, by construction |
| **union** | 48 | the two pooled | 20 of 48 = **42%, a lower bound** |
| the random-20 re-read itself | 20 | the only unbiased tail sample there is | ~40–55% (round 1's own figure) |

The class shares below are computed over the union, so the residual-type share carries the selection: the
8 added rows contribute 5 residual-type out of 8. **The head's own share — 9 residual-type of 40 nodes,
2,919 of 13,555 products = 21.5% — is the figure that does not depend on the selection**, and it is within
0.4 points of the pooled 21.9%. That agreement is the reason the recommendation does not turn on this.

## 3 · Results

### Hand-read population — 48 nodes, 13,718 products (70.3%). This is the measurement.

| Class | Nodes | Products | Share of the hand-read products |
|---|---|---|---|
| `under-filed` | 23 | 7,168 | **52.3%** |
| `residual-type` | 14 | 2,999 | **21.9%** |
| `mixed` | 5 | 1,404 | 10.2% |
| `declared-catch-all` | 2 | 1,217 | 8.9% |
| `not-a-type` | 2 | 519 | 3.8% |
| `root-parking` | 2 | 411 | 3.0% |

Split by who read it: `basis=hand` 40 nodes / 13,555 products (under-filed 21 · residual-type 9 · mixed 4 ·
catch-all 2 · not-a-type 2 · root-parking 2) and `basis=hand-redteam` 8 nodes / 163 products
(residual-type 5 · under-filed 2 · mixed 1).

### Rule-assigned tail — 244 nodes, 5,804 products (29.7%). Estimate; direction of error unresolved.

| Class | Nodes | Products |
|---|---|---|
| `under-filed` | 90 | 1,206 |
| `residual-type` | 68 | 1,411 |
| `mixed` | 67 | 2,441 |
| `declared-catch-all` | 10 | 549 |
| `root-parking` | 7 | 168 |
| `not-a-type` | 2 | 29 |

### All 292 together (for completeness; carries the tail's error)

`under-filed` 113 nodes / 8,374 products (42.9%) · `residual-type` 82 / 4,410 (22.6%) ·
`mixed` 72 / 3,845 (19.7%) · `declared-catch-all` 12 / 1,766 (9.0%) · `root-parking` 9 / 579 (3.0%) ·
`not-a-type` 4 / 548 (2.8%).

---

## 4 · `residual-type` — the nodes where a non-leaf assignment is genuinely right

These are the cases B2 must not break. Every one has the same shape: **the children partition the parent on a
dimension that does not apply to every product of the parent's kind.**

| Products | Node | Why the children do not exhaust it |
|---|---|---|
| 642 | `Fashion > KACAMATA` | children are `KACAMATA ANAK` · `KACAMATA BACA` · `KACAMATA HITAM`. An ordinary adult non-reading, non-sun pair of glasses has no child |
| 596 | `Fashion > FASHION ANAK & BAYI` | children are boys' / girls' / baby clothing. Unisex children's clothing has no child |
| 379 | `Fashion > SEPATU ANAK & BAYI` | children are boys' / girls'. Unisex baby shoes have no child |
| 299 | `Fashion > FASHION WANITA > PAKAIAN DALAM WANITA` | children are `BRA` · `CELANA DALAM` · `KORSET` · `SET BRA`. The parked stock is `MINISET` (bralette), which is none of them |
| 252 | `Fashion > FASHION WANITA` | nine children by garment type; the parked stock is `SETELAN` / one-sets, which has no child |
| 225 | `Hobi, Ibadah, dan Olahraga > MENJAHIT` | fifteen children (`BENANG`, `JARUM`, `PITA`, …); the parked stock is `KANCING` (buttons) and hooks, which has no child |
| 218 | `… > DETERJEN PAKAIAN > DETERJEN CAIR` | children are liquid detergent *for baby / for batik / for adults*. A general liquid detergent has no child |
| 173 | `Alat dan Buku Tulis > KERTAS` | nine paper-type children; the parked stock is loose-leaf refill, which has no child |
| 135 | `… > PENGHARUM RUANGAN` | children are electric / hanging / spray. Clip-on pocket fresheners fit none cleanly |
| 68 | `Fashion > JAM TANGAN` *(red-team read)* | children are kids' / men's / women's. Unisex couple watches have no child |
| 8 | `… > PERALATAN MAKAN > GARPU` *(red-team read)* | children are plastic / stainless. Wooden forks are a third material |

**Structural reading (judgement):** in every one of these, the parent is a type and the children are
**facets** — gender, age, target fabric, form. Under a leaf-only rule each would need a new
`… LAINNYA` leaf, which is how eBay sellers behave in practice (§5 of `TREE.md`). Under an attribute model
each facet is an attribute of the parent type and the children should not exist as nodes at all. This is the
same finding as the 302 gender/age-qualified nodes in `node-attribute-need.md` §3, seen from the other side.

## 5 · `not-a-type` — three roots that are not product types

Beyond the 4 non-leaf nodes classified `not-a-type`, three whole **roots** are operational or merchandising
containers. Measured from `sql/results/nodes-full.csv`:

| Root | Subtree products | What it is |
|---|---|---|
| `UNUSED` (id 3) | **1,923** | depth-2 child `AREA DISPLAY`, then brand display areas: `ARTEMEDIA` 830 · `CARDINAL` (with `CARDINAL OBRAL` 353 and `CARDINAL NORMAL` 166, each subdivided into `JEANS` / `COTTON` / `FORMAL` / `KEMEJA` …) · `OLYMPIC` 264 · `FOOD COURT` 81 · `GAME MASTER` 7 |
| `BELUM DISORTIR` (id 1787) | **1,401** | Indonesian for *not yet sorted*; its one child `BARANG OBRAL` (*clearance goods*) holds 1,382 |
| `INVENTORY KANTOR` (id 1785) | **78** | office inventory — a leaf root, not merchandise |

**3,402 current product rows (3.2% of the catalogue; 3,209 of them `is_active`) sit under a root that is
not a kind of product.** Two of the three
are *merchandising* (a shop-in-shop display area, a clearance tier) and one is a *workflow state*
(unsorted). Under Lock 1 — the category **is** the product type — each of these becomes a product type with
an attribute schema, which it cannot meaningfully have. This is D14's second half arriving early, and it is
not confined to "Promo Ramadan": it is 3.2% of the live catalogue today.

## 6 · Catch-alls, counted two ways

- The BRIEF baseline (`sql/results/baseline.json`, 2026-09-19) counts nodes whose name matches
  `LAINNYA` / `LAIN-LAIN` / `OTHER`: **42 nodes, 3,566 products**.
- A slightly wider pattern — `\bLAIN(NYA|YA)?\b` / `LAIN-LAIN` / `OTHER`, which also catches `LAIN LAIN` and
  `ALAT LAINNYA` — gives **48 nodes / 3,591 products over ALL nodes, of which 34 are leaves**. On the
  baseline's own basis (**used** nodes only, `WHERE n>0`) the same pattern gives **44 nodes, 32 of them
  leaves**, and the same 3,591 products. The 42 / 3,566 baseline figure is used-nodes-only, so 44 / 32 is
  the comparable pair (corrected after red-team round 1, MINOR 31).
- Of the 292 used **non-leaf** nodes, 12 are catch-alls by name, holding **1,766 products**.

The largest is the root `Mainan dan Alat Lainnya` — *Toys and Other Tools* — id 10, depth 1, 8 children,
**1,048 products parked on the root itself** and 4,528 in the subtree. Its own products are puzzles, blocks,
die-cast cars and dolls; its children include `MAINAN ANAK LAKI-LAKI` and `MAINAN ANAK PEREMPUAN`. It is
simultaneously a root, a catch-all by name, and under-filed.

## 7 · The pathologies worth naming

- **A node with a child of the same name.** `Alat dan Buku Tulis > BUKU TULIS` (219 products on the parent)
  has a child also called `BUKU TULIS`. Every parked title begins `BUKU TULIS …`.
- **A 90-child node.** `Makanan dan Minuman > FRESH > SAYURAN SEGAR` has 90 children, one per vegetable, and
  still parks 222 products on the parent — `child_name_hit` **0.676**, i.e. two thirds of those titles
  already name one of the 90 children. `BUAH` is the same shape: 30 children, 136 parked, hit **0.706**.
- **A branch filed sideways.** `Mainan dan Alat Lainnya > MAINAN OLAHRAGA DAN AKTIVITAS` (683 products) has
  children `KARPET PUZZLE` · `MANDI BOLA` · `PEROSOTAN` · `SEPEDA ANAK`, but its own products are modelling
  clay, building blocks, marbles and toy guns — none of which is a sports or activity toy.
- **A branch filed across roots.** `Fashion > AKSESORIS FASHION DEWASA` (385) parks cosmetic sponges,
  powder puffs and eyeliner stencils, which belong under `Kosmetik dan Alat Kecantikan`.


---

## 8 · Corrections after red-team round 1

| Finding | What changed |
|---|---|
| **SERIOUS 6** | The claim that the rule's error is one-directional (`mixed` → `under-filed`) is **withdrawn**. The confusion matrix is now printed rather than summarised (§2), and the red team's re-read of a random 8 tail nodes — where the rule agreed **0 of 8** and five were `residual-type` called `under-filed`/`mixed` — is adopted verbatim as `basis=hand-redteam`. The rule errs in **both** directions and the tail's distribution is now stated as unresolved. Rule accuracy over all hand-read nodes falls from 50% (of 40) to **42% (of 48)**. The headline moves from 21.5% to **21.9%** residual-type, i.e. the direction of the correction is *away* from B2's reopen trigger, not toward it. |
| **MINOR 22** | "3,402 live products" restated as **3,402 current rows, 3,209 of them `is_active`**. |
| **MINOR 31** | The catch-all counts mixed denominators. Both bases are now given: all nodes 48 / 34 leaves; **used** nodes 44 / 32 leaves — the latter comparable with the baseline's 42. Products are 3,591 either way. |


---

## 9 · Corrections after red-team round 2

| Finding | What changed |
|---|---|
| **SERIOUS 6** | ~~"Red-team round 1 re-read **a random 8** of the rule-assigned tail"~~ · ~~"the red team's **random 8** shows the opposite lean — the rule agreed on 0 of 8"~~ **Struck.** Round 1 re-read a **random 20** and tabulated only the **8** it judged misclassified, so the 8 are an **error-enriched subsample** and "0 of 8" restates the selection rule. §2 now says so, adds a table of what each stratum is a sample of, and states the head's own unselected share (**9 of 40 nodes, 2,919 of 13,555 products = 21.5%**) beside the pooled 21.9%. The 0.4-point gap is why the recommendation does not turn on it. Rule agreement is now quoted as **20 of 40 (50%) on the unbiased head** and **20 of 48 (42%) on the pooled union, a lower bound**. |
| **MINOR 14** | `scripts/nonleaf_classes.py`'s printed headline was still the 40-row version, so the saved run-log disagreed with the brief. It now prints both strata, the union, and an explicit note that the union's agreement rate is a lower bound. `data/run-logs/nonleaf_classes.out.txt` refreshed. |
| **Snapshot bound** | `sql/nodes-full.sql`, `sql/nonleaf-used.sql` and `sql/products-titles.sql` now carry the BRIEF §3.4 bound (`source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')`) inside each `ROW_NUMBER` subquery. All three re-run **byte-identical**; every figure in this file is unchanged. |
