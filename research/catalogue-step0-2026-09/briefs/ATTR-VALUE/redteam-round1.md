# ATTR-VALUE — red-team round 1

**Author:** adversarial reviewer (did not write the brief). **Date:** 2026-09-19.
**Method:** every `path:line` re-opened at the pins (backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend
`/home/irvan/copilot/ts-layer2` @ `82187a17bd` — both HEADs confirmed); all 11 SQL files re-run against
`solvent-staging` and diffed against the saved results; all three corpus-analysis scripts re-run against
`corpus/shopify-taxonomy/` and diffed against the saved `.out`; every §2 quote re-grepped (whitespace-normalised)
in the cited record with its enclosing heading resolved; 14 spot-checks in `evidence-A4-records.md`, one per
platform section; every new-source quote re-opened in the saved corpus file; the #10778 corpus at
`~/copilot/research/product-attribute-variant-2026-08/` opened directly.

**Counts: 4 BLOCKING · 13 SERIOUS · 9 MINOR.**

The measurement layer is strong: every SQL and every corpus script reproduces, and every derived figure in §5
of both cards recomputes. What does not survive is a group of **provenance** claims — a quote attributed to a
record that does not contain it, three "uncorroborated" #10778 citations that are corroborated in the corpus the
BRIEF pointed the author at, a live measurement two-thirds of which has no artifact, and a run of wrong section
cites — plus a set of **missed consumers** on the single production write path and on the reindex fan-out.

---

## BLOCKING

### 1. The §2a Google row quotes the *miner's own heading* as "the record's own words", and the only claimed disagreement with the matrix's D8 tally is built on it — BLOCKING

**What is wrong.** `ATTR-VALUE.md:202` (A4 §2a, Google row) prints as the record's own words:
*"Every value is a scalar written onto the product"* and *"the record's own heading calls it 'hybrid between
closed enums on the definition and free strings; **never an FK**'"*, cited `#11013 §1.3`.

Neither string exists anywhere in `evidence/issues/11013.md` — `scalar written onto`, `never an FK` and
`hybrid between closed enums` each return **0** over the whole file (and over the whole `evidence/` tree). Both
phrases exist in exactly one place: `briefs/ATTR-VALUE/evidence-A4-records.md:331`, which is the **miner's own
Q1 heading** for Google. I re-read `11013.md:129–167` (§1.3, `ProductAttributes` — the attribute bag) in full;
it says *"There is no per-category attribute schema"*, gives the 145/95/104 counts and a layer table, and
contains no statement about value shape at all.

**Why it matters.** Three things rest on it. (i) The brief then writes *"the matrix's own D8 tally … **matches on
twelve of thirteen; the one disagreement is Google**"* — but the matrix files Google as **Copied**
(`catalogue-decision-matrix-2026-09-16.txt:2136–2137`) and the brief files Google as **(a) copied**. They agree.
The re-check matches on thirteen of thirteen and there is no disagreement to name. (ii) Google is then listed in
§2a's **Named ambiguous** line purely on the strength of this non-existent disagreement. (iii) The BRIEF's §4
rule is that the matrix table carries *"the record's own words"*; this row carries a research agent's summary
labelled as the record's heading — the fabrication-class citation failure the MASTER flagged on #10778 and that
BRIEF §1 tells every brief to avoid.

**What would fix it.** Re-quote Google from `#11013 §1.3` (or from §1.5 `VariantOption` / §3 for the axis
question), attribute the "hybrid between closed enums / never an FK" reading to `evidence-A4-records.md:331` as
**the miner's reading**, drop Google from the named-ambiguous list or re-justify it from the record, and correct
"twelve of thirteen" to "thirteen of thirteen, no disagreement".

---

### 2. The three "uncorroborated #10778 citations" are all corroborated in the #10778 corpus the BRIEF pointed the author at — which the brief never opened — and two of them in the brief's *own* fetched corpus — BLOCKING

**What is wrong.** `ATTR-VALUE.md:491` (A4 §8) states: *"Three #10778 citations are uncorroborated by their own
platform records, and I record them rather than repair them"*, and §7 (`:244`) uses one of them to narrow V4:
*"Two of V4's own cited witnesses do not survive their platform records, which narrows its 'every surveyed
system' further."* BRIEF §1 says the #10778 corpus *"is on this machine at
`~/copilot/research/product-attribute-variant-2026-08/`, 26 files — `F2-axis-value-shape.md`, … `INDEX.md`"*
and *"Re-verify any #10778 claim you lean on."* `grep` over `ATTR-VALUE.md`, `design-A3.md`, `design-A4.md` and
`sources-and-corrections.md` for `product-attribute-variant-2026-08`, `F2-axis-value-shape`, `F1-suggestion`
returns **0** — the corpus was never opened. All three are in it:

- **V6's eBay derived-suggestions sentence.** The brief says it *"appears nowhere in the eBay record"* and
  concludes *"V6's 'derived suggestions' half is currently **unsourced**"*, then recommends *"do not build
  derived suggestions on V6's stated evidence until a route confirms it."* It is at
  `F1-suggestion-provenance.md:516–524`, quoted verbatim from eBay's own documentation:
  *"eBay determines the popularity of a name or value based on several factors, such as the number of recent
  listings and/or recently sold listings in the same category that have used the same name or value."*
  It is sourced — to eBay, just not into `#11045`.
- **V4's commercetools `changePlainEnumValueOrder`.** The brief says *"appears **0 times** in #11081 … The
  mechanism plausibly exists; the citation is uncorroborated, and I record it as such rather than repairing
  it."* It is at `F2-axis-value-shape.md:319–328` with the upstream URL and the full RAML
  (`discriminatorValue: changePlainEnumValueOrder`, *"Updates the order of enum `values` in an
  AttributeEnumType AttributeDefinition"*) — **and the brief's own corpus already holds the primary artifact**:
  `corpus/commercetools/repo/api-specs/api/types/product-type/updates/ProductTypeChangePlainEnumValueOrderAction.raml`,
  plus `corpus/commercetools/docs-api_projects_productTypes.txt` and `pt.html`. One grep of the author's own
  collection repairs it.
- **#10778's Magento `Validator.php:128-144` claim** (recorded in §8 as a fourth, "outside my cards"). It is at
  `F1-suggestion-provenance.md:252`: *"I re-fetched the file myself.
  `app/code/Magento/CatalogImportExport/Model/Import/Product/Validator.php:128-144`"*, and summarised at
  `INDEX.md:65`.

**Why it matters.** This is a load-bearing move twice over. It downgrades a #10778 *decision* (V6's derived
suggestions → "do not build") on a false premise, and it narrows V4's survey evidence — the very item the errata
told A4 to resolve — by half, when the surviving half (Shopify's `productOptionsReorder` ordering options not
values) is the only one that stands. Declaring an item "uncorroborated" while holding its primary artifact on
disk is the strongest single defect in the brief.

**What would fix it.** Open `product-attribute-variant-2026-08/`; re-express the finding as *"not carried into
the platform record, corroborated in #10778's own corpus at `<file>:<line>`"*; withdraw "unsourced" and the
"do not build derived suggestions" recommendation; restore `changePlainEnumValueOrder` as a surviving V4
witness and re-run the "two witnesses do not survive" sentence with one.

---

### 3. A3 §5's "confirmed live on a second route" names three categories; only one has a saved artifact — BLOCKING

**What is wrong.** `ATTR-VALUE.md:120` (A3 §5) states as a measured row: *"three unrelated categories queried
against the live Admin GraphQL API at `2026-07` all return the same attribute object: `aa-1-13-8` (T-Shirts),
`ap-2-3-6-1` (Dog Pens) and `hg-5-2` (Fireplace Grates) each carry `gid://shopify/TaxonomyAttribute/1`
'Color'"*, sourced to `corpus/shopify-values/`, collected 2026-09-19.

The saved artifact `corpus/shopify-values/live_taxonomy_attributes.json` (2,146 B) contains **one** category:
`ap-2-3-6-1` Dog Pens. `aa-1-13-8` and `hg-5-2` return **0 hits** across `corpus/shopify-values/` and
`corpus/shopify/`. `hg-5-2` returns 0 across the whole `evidence/` tree; `aa-1-13-8` appears in `11011.md:435`
and `:619` only as the category at which a **metafield link** was accepted — a different observation.

**Why it matters.** The claim's whole force is *"The two routes could have disagreed — the API could have minted
a distinct id per category — and they do not"*, which requires more than one category. With one category the
live route shows nothing about sharing. Under BRIEF §3.2 a fact is verified or explicitly "not collected + the
route"; this is a measurement of three presented as complete on an artifact of one.

**What would fix it.** Re-run the query for `aa-1-13-8` and `hg-5-2` and save the responses, or restate the row
as one category and drop "three unrelated categories … could have disagreed".

---

### 4. "The model already implements hybrid-by-type; what is missing is the option table" is wrong — a seventh `TYPE_CHOICES` entry crashes the single production write path — BLOCKING

**What is wrong.** `ATTR-VALUE.md:59` (A4 §4): *"**Consequence: a seventh column plus a seventh `TYPE_CHOICES`
entry (`:641-648`) needs no edit to `_get_value` at all.** The model already implements hybrid-by-type; what is
missing is the option table."* `design-A4.md:23` bills it as *"a **two-line** change in `_get_value`/`_set_value`
plus a migration"*, and `design-A4.md:186` as *"one column, one `TYPE_CHOICES` entry, one new table, one API
field, one formly type"*. It is reason **1** of the A4 recommendation (`:213`).

There are **three** `getattr`-by-type dispatches at the pin, not one, and only one has a default:

- `ProductAttributeValue._get_value` — `getattr(self, "value_%s" % self.attribute.type)`
  (`py/mono/solvent/catalogue/models.py:749-751`). No default, but a new `value_option` column satisfies it.
- `ProductAttributeValue.value_as_text` — `getattr(self, "_%s_as_text" % …, self.value)`
  (`models.py:775-776`). **Has** a default; this is the one the brief relies on. Correct.
- `ProductAttribute.validate_value` — `validator = getattr(self, "_validate_%s" % self.type)`
  (`models.py:684-686`). **No default.** The six `_validate_*` methods are `models.py:690-716`. Adding
  `option` to `TYPE_CHOICES` without adding `_validate_option` raises `AttributeError` the first time
  `Product.clean()` → `attr.validate_attributes()` → `attribute.validate_value(value)`
  (`product_attributes.py:36-52`, called at `models.py:484`) sees an option-typed attribute — i.e. inside the
  one production create/update path.

Two further edits are unbilled: `ProductAttributeType` is a closed `Literal` in
`py/mono/solvent/catalogue/types.py:3-5` (`"text","integer","boolean","float","date","datetime"`), and
`ProductAttribute.clean()` (`models.py:658-660`) branches on `self.type`.

**Why it matters.** The recommendation's headline cost ("costs no change to `_get_value`", "two-line change") is
what makes (c) look free against (a). The real bill includes a validator the absence of which is a hard crash on
the only write path, plus a type-alias edit. A reader taking the design sketch's bill would ship that crash.

**What would fix it.** Add `_validate_option` and the `types.py` `Literal` entry to §4's per-option table and to
`design-A4.md` §1(c)/§6; restate as "two of the three type dispatches inherit free; `validate_value` does not".

---

## SERIOUS

### 5. Four section cites in A4 §2a point at the wrong section of the record, and one section does not exist — SERIOUS

Re-opened at the pin, with the enclosing heading resolved for each quote:

| Row | Brief's cite | Where the quote actually is |
|---|---|---|
| **Magento** | `#11082 §1.5` | `11082.md:379`, **§1.7** `eav_attribute_option` / `eav_attribute_option_value`. §1.5 is `catalog_product_entity` |
| **WooCommerce** | `#11080 §1.4, §3` | *"bare label"* at `11080.md:372`, **§1.5** `wp_terms`; *"copied string, always"* at `:394`, **§1.6** |
| **Walmart** | `#11046 §3, §3.1` | *"copied per item"* at `11046.md:374`, **§2**; *"shared by repetition"* at `:405`, **§2b**. **`#11046` has no §3.1** — §3's children are unnumbered |
| **Tokopedia Era A** | `#11048 §1.2` | field list at `:139-140` is §1.2 ✓, but *"To create a custom variant simply fill `value`"* is at `:487`, **§3** |

**Why it matters.** BRIEF §4 requires "the record's own words, **the section cite**", and BRIEF §3.1 tells
readers to navigate by grepping the cited section. Four of thirteen A4 rows send the reader to the wrong place,
one to a section that is not there. A3's cites, by contrast, resolve correctly on every row I checked (13/13).

**Fix.** Re-take the four cites at the pin.

---

### 6. §6.4 attributes a *Next Steps page* sentence to the decision matrix, with a line number that belongs to the other file — SERIOUS

`ATTR-VALUE.md:417` (§6.4): *"The matrix says the same from the other end: 'Ordering, rename and a stable variant
key come only with (a) or (c)' (its D8 options line, `catalogue-decision-matrix-2026-09-16.txt:269`)."*

`come only with` returns **0** in `catalogue-decision-matrix-2026-09-16.txt` and `.html`. The sentence is at
`evidence/pages/catalogue-next-steps-v7.txt:269` — the card page, i.e. the same document the brief is answering,
not independent corroboration. The matrix's own D8 options line
(`catalogue-decision-matrix-2026-09-16.txt:2153`) reads differently: *"Ordering, rename and **normalisation** come
**free** only with (a) or (c)"* — no "stable variant key".

**Why it matters.** §6.4 is where the brief argues that the DB-enforceable variant key exists only under (b)/(c).
Presenting the card's own words as an independent second source overstates the support, and the matrix's actual
sentence does not mention the variant key.

**Fix.** Cite `catalogue-next-steps-v7.txt:269`, note it is the card restating itself, and quote the matrix's
`:2153` wording separately.

---

### 7. §2c merges Tokopedia's two eras, which the BRIEF forbids and A4 §2's own header promises not to do — SERIOUS

A4 §2 opens *"Fourteen rows (Tokopedia's two eras never merged)"*. §2c's D9 table is the matrix's 13-platform
table reproduced whole, with a single undifferentiated **`Tokopedia45`** cell in "Bare, with the unit elsewhere"
(`catalogue-decision-matrix-2026-09-16.txt:2168-2171`). The brief's own **Correction 2** is specifically about
Era B (`skus.sku_unit_count`, Get Attributes, the Era-B unit-pricing formula) yet the tally row stays merged and
the merge is never flagged.

**Why it matters.** BRIEF §3.1: *"Tokopedia (#11048, **two eras — never merge them**)"*. D9 is the one
sub-question where the two eras plainly differ (Era A's `VariantUnitValue` carries no unit; Era B's
`sku_unit_count` is a magnitude paired with a unit-bearing product attribute). Merging them hides the finding
the brief's own correction makes.

**Fix.** Split the Tokopedia D9 cell into Era A and Era B, or state explicitly that §2c reproduces the matrix's
merged row and that Correction 2 applies only to Era B.

---

### 8. §2c's post-correction tally does not add up — SERIOUS

`ATTR-VALUE.md:250`: *"Tally after both corrections: a typed quantity carries its unit on the value in **3 of
14** · the unit sits elsewhere or nowhere in **8** · one platform ships five shapes at once · one is
text-with-a-unit-pricing-pair."* 3 + 8 + 1 + 1 = **13**, and the table it derives from has 13 platforms
(Tokopedia counted once — see finding 7). Either the denominator is 13, or a fourteenth row is missing.

**Fix.** State 13 with Tokopedia merged, or split Tokopedia and re-derive to 14.

---

### 9. A3's tally counts two hedged rows as clean, and §8 then claims the opposite — SERIOUS

A3 §2 tallies **(a) = 6**, including:

- **Amazon**, whose own row carries *"⚠️ the legacy XSD surface behaves like (b): … 'Divergence is REAL and ~20×
  more pervasive than reported: … **101–124** measured on the verifier's own corpus (**149–157** on the complete
  set)'"* (verified at `10966.md`, the audit a3/b8 entry).
- **Tokopedia Era B**, whose own row carries *"⚠️ record's own hedge: 'It is **one route** — a changelog article
  … so **nothing is moved to VERIFIED on it**'"* (verified at `11048.md`, §1.8).

A3 §8 then says *"**Amazon is genuinely mixed across its two generations and I did not force it into one cell**"*
— but the tally does force it, and §7 weight 2 uses the resulting margin: *"**6–3** among the platforms that have
the concept"*.

**Why it matters.** BRIEF §4 is explicit: *"a record's hedge travels into the tally; it is never silently
assigned"*. A3 applies that rule correctly to Shopee and Tokopedia Era A (held out, named) and not to Amazon and
Tokopedia Era B. Held out consistently, (a) = 4 and (b) = 3, and "6–3" becomes 4–3 with four named ambiguous —
still a lead for (a), but not the margin §7 leans on.

**Fix.** Either move Amazon and Tokopedia Era B into the named-ambiguous list and restate the margin, or state in
§2 why a hedge on the *legacy generation* / a *single route* does not disturb the assignment, and reconcile §8.

---

### 10. A4 §2a names four platforms ambiguous and then assigns every one of them to a bucket — SERIOUS

`ATTR-VALUE.md:217`: *"**Named ambiguous:** commercetools … · Salesforce (storage shape never stated) · Google …
· Amazon (U16 … 'not established')."* The tally immediately above puts Amazon and Google inside **copied 4** and
Salesforce inside **hybrid 6/7**; only commercetools is held out (as "not established 1"). So three of the four
named-ambiguous rows are assigned anyway, the opposite of A3's discipline (finding 9, inverted).

**Why it matters.** The two cards apply the BRIEF's hedge rule in opposite directions, so neither tally can be
read as the BRIEF intends. A4's "modal answer, 6–7 of 14, is hybrid" would become "6–7 of 11 unambiguous rows".

**Fix.** Pick one discipline for both cards; show the tally with and without the named-ambiguous rows.

---

### 11. Missed consumers — the Django admin attribute editors that already exist — SERIOUS

A4 §4 (`:74`): *"**The only editor that exists today is Django admin** — `ProductAttributeAdmin` with
`prepopulated_fields = {"code": ("name",)}` (`solvent/catalogue/admin.py:51-53,67`)"*, and A3 §6 repeats lock
condition 1's *"no `ProductAttribute` UI exists today"*. `admin.py:51-53,67` is correct, but three further admin
surfaces exist at the pin and none is named anywhere in `ATTR-VALUE.md`, `design-A3.md` or `design-A4.md`
(`grep` for `AttributeInline`, `ProductAttributeInline`, `ProductAttributeValueAdmin` → 0 hits in all four files):

- `ProductAttributeInline` (`py/mono/solvent/catalogue/admin.py:27-29`) mounted on `ProductClassAdmin`
  (`:32-34`) — this **is** an attribute-schema editor today, and it is exactly the surface A3's (a)/(b)/(c)
  split changes (under (a) it must become a membership editor; under (b) it re-parents to `Category`).
- `AttributeInline` (`admin.py:18-19`, `model = ProductAttributeValue`) mounted on `ProductAdmin`
  (`admin.py:46`) — the per-product attribute-**value** editor. Under an option row it needs a select and a
  queryset filtered by attribute.
- `ProductAttributeValueAdmin` (`admin.py:56-57`, registered `admin.py:68`), `list_display` includes `value`,
  which routes through `_get_value`.

**Why it matters.** BRIEF §3.3 requires "which call sites change per option and which inherit for free", and
BRIEF §3.5 requires "the staff editor it implies". Three editor call sites are missing from both design sketches,
and the flat statement "no attribute UI exists" is not true of the schema side.

**Fix.** Add the three to §4's consumer list and to the per-option tables in both design files.

---

### 12. Missed consumers — `initiate_attributes()` and `get_values()` on the single production write path — SERIOUS

`grep` for `initiate_attributes` and `get_values` over `ATTR-VALUE.md`, `design-A3.md`, `design-A4.md`,
`sources-and-corrections.md` → **0 hits**. At the pin:

- `ProductAttributeContainer.initiate_attributes()` — `py/mono/solvent/catalogue/product_attributes.py:21`,
  called at `py/mono/solvent/api/apiproduct/staff_serializers.py:68`, i.e. the first statement of
  `_assign_attributes()` on the one production create/update path the BRIEF names, immediately before the
  `attribute_codes` read at `:70-72` and the `setattr` loop at `:81`.
- `ProductAttributeContainer.get_values()` — `product_attributes.py:54-55`
  (`return self.product.attribute_values.all()`).

**Why it matters.** `initiate_attributes()` is where the container is seeded from the stored rows. Under value
shape (b)/(c) it is one of the places that must learn the difference between a label and an option id — the
brief's §4 claims the write path is only `staff_serializers.py:38` + `:81`, and it is not.

**Fix.** Add both to §4 and to `design-A4.md` §1(c) "what changes".

---

### 13. Missed consumer — `Product.attribute_summary` — SERIOUS

`Product.attribute_summary` (`py/mono/solvent/catalogue/models.py:520-525`) reads `self.attribute_values.all()`
and calls `ProductAttributeValue.summary()` (`models.py:763-766`), which renders `value_as_text`. It is in
`ProductAdmin.list_display` (`admin.py:43`) and is exercised by
`catalogue/tests/product_models_test.py:125`. Not named in the brief or either design file.

**Why it matters.** It is a real read of a value through the `_%s_as_text` hook the recommendation depends on;
it inherits free **only if** `_option_as_text` is written (see finding 4). It belongs in the "inherits free"
column with that condition attached.

---

### 14. The reindex fan-out is never examined, and it carries a live ordering hazard that a value-shape change walks into — SERIOUS

`grep` for `receivers`, `index_utils`, `models_mixins`, `reindex`, `haystack` over `ATTR-VALUE.md`,
`design-A3.md`, `design-A4.md` → **0 hits**. §4 disposes of the whole path with *"nothing exists either way"*.
At the pin:

- `Product.save()` calls `super().save()` at `models.py:489`, which fires `post_save` →
  `catalogue/receivers.py:31-41` → `update_products_indexes()` **and** `update_product_dependent_indexes()`;
  `catalogue/index_utils.py:11-16` shows `update_products_indexes` enqueues **both** the Haystack index and the
  **Google Merchant** queue (`google_product_index_queue.GoogleProductIndexQueue().enqueue_updates`).
- `self.attr.save()` — which writes the attribute values — runs at `models.py:490`, i.e. **after** the index
  document has already been enqueued.
- There is **no** `post_save`/`post_delete` receiver on `ProductAttributeValue` anywhere
  (`grep -rn "ProductAttributeValue" py/mono --include=*.py` shows only admin, models, migrations and
  serializers).

**Why it matters.** The brief's §7 says step 2/3 make attribute facets and feed fields reachable, and A3 §6 says
*"Any attribute facet is new work under **every** option"*. The moment any attribute value is indexed or fed,
(i) every document is built one write stale because of the `489`/`490` ordering, and (ii) a value edited through
the admin inline (finding 11) never reindexes at all. That is a named, dated cost that belongs in both design
sketches — the parent BRIEF §3.5 asks for exactly this path.

**Fix.** Add the fan-out to §4 with the `models.py:489`/`:490` ordering and the missing PAV signal, and price it
in `design-A4.md` §6 under "what step 2 forces".

---

### 15. A3 §7's weight 1 and reopen-trigger (iv) lean on TREE's *inferred* route, which TREE's own red team found over-maps with no stated error rate — SERIOUS

`ATTR-VALUE.md:153` (weight 1) and `:162` (reopen (iv)) both rest partly on TREE's inferred route (*"715 names
over the 395 mapped nodes … `Warna` on 235, `Pola` on 231, `Preferensi diet` on 102"* — all confirmed present in
`briefs/TREE/node-attribute-need.md` §2). §8 says the brief *"inherit[s] its stated limits"* and names only the
98.8% dimensionality caveat.

`briefs/TREE/redteam-round1.md` **BLOCKING 3** finds that pass B strips gender/age qualifiers from **both** sides,
producing wrong matches at scale (`ATASAN WANITA`, 523 products, maps EXACT to *children's* tops;
`CELANA PENDEK PRIA` → loungewear; 85 of 395 map to a level ≤ 2 node and 103 to a non-leaf; 47 taxonomy nodes
receive more than one of our nodes), and states: *"without an over-mapping rate its inferred half is not a sound
basis"* for ATTR-VALUE. That limit is **not** among TREE's stated limits, so "I inherit its stated limits" does
not cover it.

**Why it matters.** Confidence on (a) over (b) is stated as **high** partly because *"TREE's measurement (below)
removed the only reopen trigger I had for it"*, and reopen (iv) is dismissed with *"Nothing in the inferred route
suggests that"*. One of the two routes behind that is currently unsound. The measured route (`net_content` 617,
`colour` 494, `flavour` 199 — all confirmed at `node-attribute-need.md:72-76`, and TREE's red team reports the
measured script re-runs byte-identical) still supports the recommendation; the confidence statement does not.

**Fix.** Restate weight 1 on the measured route alone, mark the inferred figures as pending TREE's over-mapping
rate, and downgrade the reopen-(iv) dismissal to "pending".

---

### 16. §8 claims "every §2 quote was additionally verified by me against the record itself"; it was not — SERIOUS

`ATTR-VALUE.md:491`: *"**and every §2 quote was additionally verified by me against the record itself** (exact-string
`grep -rl` on the load-bearing strings …)"*, then names **six** strings. I re-ran all six — Walmart's
*"copied per item; there is no shared value row"* (`11046.md:374`), Magento's *"shared row referenced by an
integer"* (`:379`), WooCommerce's *"copied string, always"* (`11080.md:394`), Akeneo's *"the product copies the
code string"* (`11069.md`), Shopee's *"value rows belong to the attribute"* (`11047.md:127`) and Google's *"not a
comprehensive or exhaustive list"* (`11013.md`) — **all six are exact**. But six is not "every", and the one §2a
quote that fails (finding 1) is not among them.

**Fix.** Restate as "six load-bearing strings spot-checked", and run the check over all 28 §2 quotes.

---

### 17. Square's A3 quote is cited to §1.7/§3 of the record but lives in its Retrievals appendix; the verbatim sentence is in the corpus — SERIOUS

`ATTR-VALUE.md:59` (A3, Square row) quotes *"After a custom attribute definition is set to be applicable to an
object… **that definition is available for all objects of that type.**"* cited `#11049 §1.7, §3`. At the pin the
fragment appears at `11049.md:1082`, inside **`### Retrievals`** as the summary of `[R-11]`; §1.7
(`CatalogCustomAttributeDefinition`, `:344`) does not carry the sentence. The full sentence *is* saved, verbatim,
at `corpus/square/add-custom-attributes.html:57`. (The row's second quote, *"a 'flavour' definition allowed on
ITEM appears on every item…"*, is correctly in §3 at `:750`.)

**Fix.** Cite `corpus/square/add-custom-attributes.html` for the vendor sentence and `#11049` Retrievals `[R-11]`
for the record's carriage of it.

---

## MINOR

### 18. `search_indexes_mixins.py:22,27-29` is ambiguous, and it is not the only `category` declaration — MINOR

A3 §4 (`:102`): *"`ProductIndex` (`search/search_indexes.py:20-75`) … the only category field is
`category = MultiValueField` holding ancestor ids (`search_indexes_mixins.py:22,27-29`)"*. Two files carry that
basename. The correct one is `py/mono/solvent/**catalogue**/search_indexes_mixins.py:22` (field) and `:27-29`
(`prepare_category` → `[c.id for c in main_category.get_ancestors_and_self()]`) ✓; but the cite follows
`search/search_indexes.py` and `py/mono/solvent/**search**/search_indexes_mixins.py:22,27-29` is a docstring of
`FacilitiesSearchIndexMixin`. Separately, `ProductIndex` **re-declares** its own
`category = indexes.MultiValueField(null=True, faceted=True)` at `search/search_indexes.py:65`, overriding the
mixin's — so "the only category field" is two declarations, and only the subclass's is faceted.

### 19. "~4.4 nodes per name on average" is derived from a median — MINOR

`ATTR-VALUE.md:153`. TREE publishes *median* attributes per mapped node = 8 (`node-attribute-need.md` §2); the
mean is not published. 395 × 8 ÷ 715 = 4.4 treats a median as a mean. Label it as an estimate or ask TREE for the
edge count.

### 20. `indomie_vs_shopify_flavor.out` has no script beside it — MINOR

`corpus-analysis/` holds `.py` + `.out` for three measurements; the fourth, `indomie_vs_shopify_flavor.out`
(the "43 flavour phrases, **0 of 73 word tokens** appear in Shopify's 30-value list" figure used in A3 §5 and in
A4 §6.5 consequence 3), has an output with no instrument. I could read the output but not re-run it. Add
`indomie_vs_shopify_flavor.py`.

### 21. The 600-product Shopify measurement is entirely the auto-generated default option — MINOR

`corpus/shopify-values/live_option_value_ids_600products.tsv` reproduces exactly (600 product ids, 600
`ProductOption` ids, 600 `ProductOptionValue` ids, 1 option name, 1 value name). But the single option name is
`Title` and the single value name is `Default Title` — Shopify's synthetic default for a product with no real
options. It shows the *default* value row is minted per product; it does not show that two products carrying a
merchant-authored `Red` get distinct ids. The brief prints the names but does not state the limit.

### 22. `sql/size-families.sql` is non-deterministic in one column — MINOR

Re-run against the same snapshot, 43 of 1,993 rows differ — all in `dimension`, which is `ANY_VALUE(d.dimension)`
over the 78 mass+volume families. Every load-bearing column (`products`, `distinct_labels`, `dimensions`,
`text_order`, `magnitude_order`, `text_sort_is_correct`) is byte-identical, and all derived figures recompute
exactly (1,993 / 4,593 / 1,211 (60.8%) / 782 (39.2%) / 78 / 399 / 1582-301-74-21-9-4-2). Use
`MIN(d.dimension)` so the file is reproducible.

### 23. Result file name does not match its query — MINOR

`sql/manufacturer-top-and-tail.sql` → `sql/results/manufacturer-top.csv`. The brief's file table names the `.sql`;
a reader looking for `manufacturer-top-and-tail.csv` finds nothing. (Content reproduces identically.)

### 24. WooCommerce's "why" quote silently normalises the record's apostrophe — MINOR

A3 §3 (`:79`) prints *"so they're easy to update…"*; `11080.md:338` and `:629` read *"so they**’**re easy to
update…"*. Harmless, but it defeats exact-string verification — it is why a plain `grep -F` on that quote returns
0 and was the only §3 quote I could not match on the first pass.

### 25. "confirms the card's figures exactly" overstates what the card gives — MINOR

A3 §5 (`:119`) prints `14,606 / 8,240 / 93,007` as *"confirms the card's figures exactly"*. The card
(`catalogue-next-steps-v7.txt:97`) gives *"8,240 definitions, 93,007 category edges"* and no category count.

### 26. The locale claim in §6.3 is supported by the `en` figure only — MINOR

§6.3's Shopify row says the published order is *"the **locale's** label, alphabetically"* and prints
*"alphabetical ex-`Other` in **7,715 of 8,240**"*. That is the `en` figure; `shopify_order_and_names.out` gives
`id-ID` as **7,544**. Both reproduce; print both, since the claim is about locale-dependence.

### 27. `staff_serializers.py:70-80` is not a "hard-coded read of the global set" — MINOR

A3 §4 (`:98`) lists it beside `ProductClass.default().attributes.all()`. At the pin it is
`product.product_class.attributes.all()` (`staff_serializers.py:70-72`) — a read through the product's own FK,
identical to the global set only while `productclass_rows = 1`. Under A3 option (b) the two diverge, which is
exactly the distinction §4 is drawing.

### 28. Two small cite slips — MINOR

(a) A3's Shopee row cites `#11047 §1.2` for the **U-8** open item; U-8 is in `#11047 §4` (`11047.md:535`).
(b) The A3↔B4 coupling requires *"each cites the other's section by heading"*; §7 says *"B4's question becomes…"*
but names no TREE heading. (A3↔B3 **is** cited correctly — `briefs/TREE/node-attribute-need.md` §1–§2, in §5, §7
and §8 — and A4 correctly defers the level to FAMILY's A5 and the taxonomy facts to TREE.)

---

## Verified clean — what I re-ran and confirmed

**Pins.** `py-5` HEAD = `4f99dc01c6baf181ffc54c460e936384d12968f7` on `solvent-master`; `ts-layer2` worktree HEAD
= `82187a17bdd5cfbe8f77a52d14fa3f7109fc5c2f`. Both as the brief states.

**SQL — all 11 files re-run (`bq --project_id=solvent-staging … --format=csv --max_rows=5000`), all diffed
against the saved results, all identical** except the one non-deterministic column in finding 22:
`manufacturer-vocabulary`, `manufacturer-top-and-tail`, `manufacturer-case-drift`,
`manufacturer-duplication-classes`, `value-column-hygiene`, `quantity-vocabulary`, `unit-tokens-by-unit`,
`unit-token-instrument-check`, `matrix-examples-recheck`, `size-families`. Every figure in §5 of both cards
recomputes: 46,499 rows / 5,580 distinct / 5,580 after TRIM (0 leading-or-trailing spaces) / 5,541 TRIM+LOWER
(38 case groups over 39 spellings) / 5,489 +whitespace (= **1.6%**, and the 0.7% case-only drift) / 4,421
+punctuation; 2,788 / 1,793 / 735 / 229 / 35 (sums to 5,580); top-100 26,317 (57%), top-500 34,666 (75%);
p50 16 / p99 44 / max 66; **31** letterless values over **15,516** rows (33%); Unilever **16 spellings /
1,108 rows**, Mandom 10/396, Kino 8/317, P&G 7/252, Nestlé 5/231; 471,143 value rows with **0** having zero,
more-than-one or wrong-column population; 23,986 (22.6%) mass/volume titles, **886** labels, 573 magnitudes,
5 unit spellings, 214 labels for 90%, 275 used once, 86 double-token titles, **0** unparseable; the by-unit
breakout summing to exactly **30,417**; size families **1,993 / 4,593 products / 1,211 (60.8%) correct /
782 (39.2%) wrong / 78 mixed / 399 labels** and the 2-to-8 label histogram; and the four matrix families
re-taken (SOKLIN six rows incl. `REFILL 700ML` and `SACHET 41GR`, four distinct 13-digit GS1 barcodes
`8998866612180/…173/…166/8998866622493`; REAL GOOD three flavours × two sizes with all three 80 ML inactive;
IMPLORA six shades with `02 CHERISH 4GR` drifted; PIXY two kinds sharing three shade labels).

**Corpus scripts — all three re-run against `corpus/shopify-taxonomy/`, outputs byte-identical**
(`shopify_attr_reuse.py`, `shopify_flavor_values.py`, `shopify_order_and_names.py`), including the regenerated
`shopify-flavor-categories.txt`. Confirmed: 14,606 / 8,240 / 74,820 / **93,007**; 8,195 attached, 45 never;
**5,282 (64.5%)** single-category, 2,913 (35.5%); Color 11,730 · Pattern 11,686 · Material 4,546; top-3 30.1%,
top-100 64.4%; `Flavor` = `gid://shopify/TaxonomyAttribute/1458`, **293 categories, 30 values, one name on all
293**, verticals 169/111/13; nine flavour-named definitions with the stated counts; extended **106 base / 316
names / 2,891 edges**; 0 of 74,820 values shared across attributes; 0 attributes with an empty list (min 2,
median 7, max 451); 329 size-ish names of which 219 on ≤1 category; `id-ID` = same gid, name **"Rasa"**, same 30
ids, `Other` → `Lainnya`; `Other` last in 8,237 of 8,237; en alphabetical-ex-Other 7,715 of 8,240; array order
differing en vs id-ID for **6,968**. I independently recomputed **8,500 distinct attribute handles on edges**
(the reconciliation row) — it was the one number in §5 with no instrument beside it, and it is right.

**Records.** All 32 A3 quotes and all 23 A4 §2a quotes located in the cited record (whitespace-normalised, after
line wrapping), except the Google §2a pair (finding 1). Section headings resolved for 13/13 A3 rows — all correct.
Line cites re-opened and exact: `10966.md:1105`, `10778.md:128/286/341`, `11031.md:492/769/1032/1036`,
`11045.md:122/126`, `11046.md:162/374/405`, `11047.md:127/206`, `11069.md:73/333/337`, `11080.md:305/338/372/394`,
`11081.md:149/258/266`, `11082.md:101/379/831`, `11011.md:234/264/266/292/655`.
Matrix cites re-opened and exact: `:244` (family-column fork), `:282` (the D9 "a label has no magnitude"
paragraph, `2.15 GR` typo and all), `:368` (300 of 8,240), and the whole D8/D9 answer tables at `:2130-2190` —
the §2c reproduction is verbatim, caveat text included, and the "not established 1 (commercetools)" cell really
is the matrix's own.

**`evidence-A4-records.md`.** 2,225 lines / 340,343 B; structure is exactly as §8 describes (legend, the card,
PART 1 with all **fourteen** rows including both Tokopedia eras, PART 2 with P2.1–P2.6, the tally, the three
overturned premises, what no record settles, provenance). I drew one random cited quote per platform section
(14 sections, seeded) and checked each against the record at the cited line: **14 of 14 exact**, including the
three rows the miner flags as subagent-mined. Two initially failed only because the quote elides with "…"; both
resolve on inspection (`GOOG:254`, `X:1034`).

**New sources.** Re-opened and confirmed verbatim in the saved corpus: Shopify's metaobject rationale and the
`black` → `graphite` rename sentence (`corpus/shopify/sfy-metafield-linked.md`,
`corpus/shopify-values/metafield_linked.md`, `help_category_metafields.archived.html`); *"The order of values
within each option determines their new positions"* (`sfy-ref-objects_Product.md`); the Shopify ETL sort logic —
`sorted_values` / `manually_sorted?` / `Value.sort_by_localized_name` at `taxonomy_attribute.rb:140-152` and
`taxonomy_value.rb:42`, with `sorting: custom` = **7 lines** in `product-taxonomy-attributes.yml`
(**4,769,315 B**, as stated); the introspection at **6,600,955 B**; the 600-product TSV recomputed (600/600/600,
1 option name, 1 value name); Square's `ordinal` description and `api.json` at **3,273,134 B**; the Square item
-options guide sentences; Akeneo's `raw_Attribute.orm.yml` (`decimalsAllowed`, `negativeAllowed`, `metricFamily`,
`defaultMetricUnit` inside `:59-84`) and `Normalizer/Standard/Product/MetricNormalizer.php` returning
`['amount' => …, 'unit' => …]` at `:24-46`; Akeneo's help-centre both-mechanisms sentence; GS1
`gs1Voc` UN/ECE Rec 20 wording, the GTIN Management Standard R1.1 net-content rule at `:615` with the
"Local, national or regional regulations…" qualifier at `:645`, and the General Specifications' weaker
*"will usually lead to a change in the Global Trade Item Number (GTIN)"* inside **§4.2.2.2** (`:16705`, `:16719`);
**Permendag 31/2011 Pasal 7(3) verbatim** (`corpus/bpom/BN_698_2011_Permendag31_BDKT.txt:196-198`) and PerBPOM
31/2018 Pasal 26's `berat`/`volume` split and `bobot tuntas`. Both Akeneo's and commercetools' vendor sentences
are also in their records (`11069.md`, `11081.md:258` §1.4) — the A3 rows are correctly cited on those.

**Code (backend, at `4f99dc01c6`).** Confirmed exactly as cited: `product_attributes.py:36-52` / `:57-58` /
`:60-64`; `models.py:88-90`, `:484`, `:490`, `:618-624`, `:626-638` (no `unique=True` on `code`), `:641-648`,
`:655`, `:672-682`, `:719-776` (`:730` `unique_together("attribute","product")`, `:742-747` six typed columns,
`:749-751`, `:753-756`, `:758`, `:768-776` with the `_%s_as_text` default at `:775-776`), `:110-121`;
the only two `unique_together` in `catalogue/migrations/*` are `("product","category")` and
`("attribute","product")` (both `0002_initial.py:30,34`); `ProductClass.default()` has exactly **two** non-test
call sites (`staff_views.py:67`, `staff_serializers.py:118`); `staff_views.py:66-67` + `:73`
`@method_decorator(cache_page(86400))` + `staff_urls.py:16`; `serializers.py:189-191` and `:207`;
`views.py:52,58-68`; `staff_serializers.py:38`, `:70-72`, `:81`; `admin.py:51-53,67`;
`search/search_indexes.py:20-75` declares **no** attribute field and the three
`templates/search/indexes/catalogue/*.txt` carry title / title_staff / upc / category names+code / description
only; `third_party_api/google/content/products_api.py:214-242` carries availability, condition, description,
link, title, price, sale_price, image_link, offer_id and **no** attribute value;
`grep -rn "AttributeOption" py/mono` → **0**. The "`manufacturer` is `required=True` and 59,662 products have no
row" arithmetic checks against the baseline (106,161 − 46,499).

**Code (frontend, at `82187a17bd`).** Confirmed exactly as cited: `product-attribute.model.ts:1-8` and `:19-22`
(`ProductAttributeType = 'float' | 'text'`, the two-entry form-field map, `value: string`);
`product-attribute-i18n.service.ts:20-35` and the `` `${value} ${unit}` `` render at `:46-51`;
`product-attribute-ordering.service.ts:9-15` (`ATTRIBUTE_PRIORITY_ORDER`, `internalname` at `:10`);
`product-addendum-attributes-ui.component.ts:34` (`hiddenAttributes = ['internalname']`);
`product-attributes-stream.service.ts:24`; `product-update-staff-form-ui.component.ts:141`, `:147-169`,
`:160-165`. `ts/assets/i18n/product/{en,id}.json` hold `attribute.key.<code>.{name,unit}` for exactly
`height/internalname/length/manufacturer/weight/width` — **the `internalname` drift at n = 5 is real**, in both
locales, and the key exists in no database row.

**Coupling and coverage.** Both cards carry all eight BRIEF §4 sections. A3 cites TREE's
`node-attribute-need.md` for the shared A3↔B3 measurement rather than re-deriving it (§5, §7, §8), and every
TREE figure it quotes (617 / 494 / 199 / 36.6% / 68 / 98.8% / 47 / 715 / 395 / 23.4% / 290 / median 8 /
`Warna` 235 / `Pola` 231 / `Preferensi diet` 102) is present in TREE's file as written. A4 defers the level to
FAMILY's A5 (§6.2) and the taxonomy facts to TREE (§6.5) without re-deciding either.

**Card pointers.** All executed or explicitly routed. A3: "how many Shopify categories reuse Flavor" → 293,
measured (§5); "the distinct attribute names our 639 main nodes would need" → cited to TREE, not re-derived;
"distinct names among eBay's aspects" → **explicitly not answerable from the record**, with the route stated
(§8) — and I confirm the record holds only (leaf × aspect) occurrence counts, never a distinct-name census.
A4: all four pointers collected at source and quoted (§2a, §3, §6.1, §6.3). No silent gaps.

**The V4-vs-matrix conflict.** Named and resolved with evidence (§7 "The conflict the errata names, resolved"),
both sources quoted at their lines, the matrix's `2.15 GR` typo caught and corrected against production data,
and V4 split into a confirmed core (the label is the record) and two re-expressed supporting claims. Explicit
dispositions exist for **V1, V2, V3, V4, V5, V6, C5, C8 and V7** — confirmed / re-expressed / superseded, each
with a reason. That is the fullest part of the brief, and it is sound except where finding 2 removes one of its
two V4 witnesses and one of its two V6 legs.
