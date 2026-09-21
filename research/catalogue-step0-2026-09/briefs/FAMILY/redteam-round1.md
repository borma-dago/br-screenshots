# FAMILY — red-team round 1

**Reviewer** adversarial agent, did not write the brief · **Date** 2026-09-19
**Pins re-opened** backend `/home/irvan/copilot/py-5` @ `4f99dc01c6` (confirmed `HEAD`) · frontend
`/home/irvan/copilot/ts-layer2` @ `82187a17bd` (confirmed `HEAD`, tag `ts-v2.195.1`).
**SQL** all eight files in `briefs/FAMILY/sql/` re-run against `solvent-staging` on 2026-09-19.

**Counts — 4 BLOCKING · 29 SERIOUS · 13 MINOR (46 findings, numbered 1–46).**

The numbers are the strongest part of this brief: every one of the figures the brief quotes reproduced
byte-for-byte. The weaknesses are all on the **evidence-handling** side — two manufactured quotations, one
piece of contrary evidence excluded on a false premise, a systematic pattern of citing `#11031`'s field
survey to the per-platform record, and a set of record hedges that do not travel into the tables. On the
code side the brief's claim to have found "the one nobody has named yet" is the claim that fails: the
product → search-index fan-out is absent entirely.

---

## BLOCKING

### 1 · BLOCKING — "Title: composed … Cost, exactly two call sites" is wrong; there are at least seven more, and one of them is inside the file the brief itself cites

**Where** `FAMILY.md` C1 §7 ("Title: composed, not stored") and `design-C1.md` §5 ("Title: compose, and the
only two places that must change").

**What is wrong.** The brief names `order/models.py:556` and `search/search_indexes.py:34,38,54,55`, then
says *"Everything else — the feed …, the frontend … — reads whatever string it is given."* Re-taken at the
pin, composing `Product.title` at read time also forks:

| Missed consumer | `path:line` at the pin | Why it forks |
|---|---|---|
| **the search document body** | `py/mono/templates/search/indexes/catalogue/product_lite.txt:1` — `{{ product.title }} {{ product.title_staff\|default:"" }} {{ product.upc\|default:"" }}` | This partial is `{% include %}`d by `product_text.txt:1` — **the line directly above the `:3` the brief does cite**. It renders the *raw* member title into the full-text `text` field. A `prepare_title` method does not reach a template. |
| **the same partial, three more times** | `forecast/forecastproduct_text.txt:1` · `price_purchase/pricepurchase_text.txt:1` · `inventory/inventoryfacility_text.txt:1` | One shared partial puts the product title into **four** Elasticsearch document types, not one. |
| **a fifth title read in the file the brief did open** | `solvent/search/search_indexes.py:93-96` — `prepare_autocomplete_staff` returns `f"{obj.upc} {obj.title_staff} {obj.title}"` | Not a `model_attr="title"`, so the brief's "indexed four times raw" grep missed it. |
| **a second haystack index entirely** | `solvent/price/purchase/search_indexes.py:61, 75-77` — `prepare_product_title_staff` → `(product.title_staff or product.title or "").lower()` | A whole index the brief never mentions; it is the staff sort key for the price-purchase table. |
| **the actual writer of the order snapshot** | `solvent/order/creator.py:191` — `"title": product.get_title()` | `order/models.py:556` is the **column declaration** (`title: str = models.CharField(max_length=255)`); it is not code that can be changed to snapshot a composed string. `order/models.py:607` (`title = self.product.title`) is a third order-side read. |
| **the slug, which is derived from the title** | `catalogue/models.py:405-408` — `slug = AutoSlugField(populate_from="title", unique=True)`; and `catalogue/models.py:488` — `self.slug = slugify(self.get_title())` in `Product.save()` | C1 §7 assigns `slug` to the family in the same breath, and never names either place the slug is computed from the title. |
| **the natural composition point** | `catalogue/models.py:575-578` `get_title()` · `:580-592` `get_title_for_staff()` / `title_for_staff` | Unnamed, though it is where the composition would have to live. |
| **the shipping quote** | `solvent/third_party_api/biteship/biteship.py:67` — `name=product.title` | Sent to a third party. |

**Why it matters.** The cost figure is load-bearing. C1 §7 rates the title decision *"Moderate"* confidence
and argues *"composing loses nothing"* on the strength of the change being two prepare-methods and one
snapshot. It is not: it includes a Django template shared by four index types and a second haystack index in
another app. A two-call-site estimate would put this in the wrong PR size band.

**Fix.** Replace the "exactly two call sites" table with the nine above, and state explicitly that
`product_lite.txt` is a **template**, so a composed title needs either a `get_display_title()` on the model
that the template calls, or the composition done at the column.

---

### 2 · BLOCKING — the product → search-index reindex fan-out is missing from the brief entirely, which is the one thing C1-ii cannot ship without

**Where** `FAMILY.md` A5 §4 (*"Inherits free under every option — search …"*), C1 §4 (*"**the search template
is the one nobody has named yet**"*), `design-A5.md` §0 ("Not readers — these inherit free"), `design-C1.md` §7.

**What is wrong.** Three files at the pin, none of them cited anywhere in the brief or its side files:

- `solvent/catalogue/receivers.py:31-41` — `@receiver(post_save, sender=Product)` →
  `update_products_indexes(products=[instance])` **and** `update_product_dependent_indexes(product_id=instance.id)`.
- `solvent/catalogue/index_utils.py:19-44` — walks Django's model registry for every
  `HasProductDependentSearchIndexModelMixin` subclass and re-enqueues its rows. Its own docstring:
  *"Those documents are only rewritten when their own row is saved — and no periodic rebuild is scheduled —
  so a product edit would otherwise leave them stale indefinitely."*
- `solvent/catalogue/models_mixins.py:6-31` — the mixin. Subclasses at the pin: `inventory/models.py:19`
  and `:121` (two models) and `price/purchase/models.py:36`.

**Why it matters.** C1's recommendation moves `description`, the customer-facing `title` and `main_category`
off `Product` onto the family row. Every reindex trigger in the system is keyed on `post_save` of **`Product`**.
Editing the family would therefore reindex **nothing** — not the member's own `ProductIndex` document, not
the three dependent document types, not the Google queue (`index_utils.py:14-16`). A new signal receiver on
the family row, fanning out to every member and then to every member's dependents, is required work that the
brief does not name, cost or flag — while claiming in C1 §4 to have found the consumer *"nobody has named
yet."*

Two further readers in the same neighbourhood are also absent: `catalogue/search_indexes_mixins.py:22-29`
(`AbstractCategorySearchIndexMixin.prepare_category` → `main_category.get_ancestors_and_self()`, used by
four index files) would have to resolve the category through the family; and
`catalogue/receivers.py:44-67` (`ProductImage` post_save/post_delete, *"Only `display_order` 0 is published"*)
is the mechanism the "images member-first, family fallback" decision rests on, with no equivalent trigger for
a family-owned image.

**Fix.** Add a §4 sub-section for the indexing surface with these three files, and add to C1 §7's "what it
forces in steps 1–5" that Step 4 must specify a family-row reindex receiver.

---

### 3 · BLOCKING — the Google row in A5 §2 is a manufactured quotation that deletes the hedge *and* deletes the field C1 §2 then relies on

**Where** `FAMILY.md` A5 §2, Google row, cited `#11031 field survey §A`.

**The brief prints** (in italics, as a quotation):
> *"Google … reads 'member' everywhere because it has **no family object at all** — only a shared
> `item_group_id` repeated on every row"*

**The record says** (`evidence/issues/11031.md:1263`, verbatim):
> "**Google** and **Walmart** read "member" everywhere because neither has a family object **on the write
> side**. Google's only group-level values are `item_group_id` **and `item_group_title`**, repeated on every row."

Two edits: *"on the write side"* → *"at all"* (a scope hedge removed), and **`item_group_title` deleted from
the list of group-level values.**

**Why it matters.** Twice over.
1. A5 §2's headline reading — *"The four (c)s are exactly the four platforms with **no family content row**
   … (c) is what you do when you have nowhere else to put it"* — depends on Google having nothing at group
   level. The record says it has two things at group level.
2. **The brief contradicts itself.** C1 §2's Google row leans on exactly the deleted field:
   *"All variants of the same product must have the same item group title `[item_group_title]`."* A5 says
   Google has no group-level value; C1 quotes Google's group-level value. The record names both and the
   brief deletes one in the section where it is inconvenient.

**Fix.** Restore the record's sentence verbatim with the `on the write side` scope and `item_group_title`
intact, and re-state A5 §2's "no family content row" reading as "no family **content** row on the write side,
though Google does carry a group-level *title*" — which weakens but does not destroy the (c) reading.

---

### 4 · BLOCKING — C2 excludes Shopee's bundle object on a false premise; the record it cites has a whole section on it and rules the opposite way

**Where** `FAMILY.md` C2 §2, the second (orthogonal) tally.

**The brief says:**
> "(Shopee's record also mentions a "kit-item" API in passing — `component_item_or_model_image` — but
> **nothing about its model was collected**, so it is not counted.)"

**Both halves are false at the pin:**
- The string `component_item_or_model_image` occurs **zero times in `11047.md`**. It is at
  **`11031.md:1274`**, inside an image-field sweep — not in Shopee's own record at all.
- `11047.md` has a full kit-item section (§1.7: request field paths, `component_list[] {component_item_id,
  component_model_id, quantity, main_component}`, contradiction 21), and at **`11047.md:286`** rules:
  *"⚠️ Revision 1 disposed of kit items in five words — "= composed bundle listing". By this document's own
  §2 definition — a row that owns axes and whose members carry `tier_index` and their own price and SKU —
  **a kit item is a variant family the standardisation has not reached** [R-27][R-28]."*

**Why it matters.** This is contrary evidence excluded on a stated-but-false premise, and it cuts directly at
C2's conclusion. C2 §6/§7 hold that a bundle is *"a separate product with no family link"*; Shopee's own
record classifies its bundle object **as a variant family**. The brief's own secondary tally ("who carries a
separate pack/bundle mechanism beside variation? 3 named") should be 4 — and the fourth one is the
counter-example.

**Fix.** Replace the parenthesis with `#11047 §1.7` + the `:286` ruling, raise the secondary tally to 4, and
either rebut `:286` on the record or lower C2 §7's confidence on the banded-pack clause.

---

## SERIOUS

### 5 · SERIOUS — eBay's two C1 quotes are not in the record the brief cites

**Where** `FAMILY.md` C1 §2, eBay row, cited `#11045 §1.4`.
Both strings — *"the title and description values will become the listing title and listing description of
the live, multiple-variation eBay listing"* and *"the product.title and product.description values … must
have the same values"* — return **0 hits in `11045.md`**. The first is at `11031.md:1192`, which sources it
to a **Wayback capture of the vendor page**. `11045.md` §1.4 itself shows the group's `title`/`description`
as **0..1, optional**, and states no member-match rule anywhere. **Fix:** re-cite to `#11031 §…` with the
Wayback provenance, or drop the "i (and ii simultaneously)" assignment, which `#11045 §1.4` as cited does not
support.

### 6 · SERIOUS — A5's eBay row states the record is silent where the record is explicit

**Where** `FAMILY.md` A5 §2, eBay row: *"the two do not sum to 197,046 — the field is not returned on every
aspect, **and the record does not state the remainder**."*
`11045.md:116` reads: *"present on **106,766 of 197,046** (`["PRODUCT"]` 87,560 · `["ITEM"]` 19,206; array
length 1 in every instance…)"*. 87,560 + 19,206 = **106,766 exactly**. There is no unexplained remainder.
**Why it matters:** the sentence is used to build eBay's "ambiguous, not counted" status, and it overstates
the ambiguity by attributing a gap to the record that the record closes. The genuine reason to leave eBay
ambiguous (`aspectApplicableTo` is about eBay's catalogue product vs a seller instance, not group vs item) is
in the next paragraph and stands on its own. **Fix:** delete the clause. Also carry `11045.md`'s **U12-c**,
which records that those bulk counts are *"one artifact read once"*.

### 7 · SERIOUS — the A5 tally's "plurality (6 of 13)" does not survive the brief's own discounting logic

**Where** `FAMILY.md` A5 §2 tally and §7 confidence.
A5-a is defined as *"pinned **on the definition** … fixed on the definition row."* Of the six counted:
Shopify (`MetafieldDefinition.ownerType`), Square (`allowed_object_types`), commercetools
(`AttributeDefinition.level`) and Tokopedia Era B (`attributes[].type`) genuinely carry a level flag **on a
definition**. **Shopee** does not — it has one item-level `attribute_list` slot and the model has no
attribute slot, so the level is fixed by the API's shape. **WooCommerce** does not — placement is by post
type (`_product_attributes` on the parent, `attribute_<key>` on the variation); no level lives on any
attribute definition.
**Why it matters:** the brief discounts the four (c)s with exactly this move — *"(c) is what you do when you
have nowhere else to put it."* Applied consistently, Shopee and WooCommerce are the same kind of case, and
the tally is **4 / 1 / 6 / 1**, not 6 / 1 / 4 / 1 — (a) and (c) level-pegged. §7's *"The option has the
plurality (6 of 13)"* is then no longer a reason.
**Fix:** either split the tally into "level on a definition (4)" vs "level fixed by structure (2)", or drop
plurality from the confidence rationale and lean on the argument that does survive — the commercetools shape
match and the zero day-one cost.

### 8 · SERIOUS — A5 §1 and A5 §2 disagree on how many platforms implement (d), and the brief never reconciles them

**Where** `FAMILY.md` A5 §1 (*"it has to be on the list because **three of the thirteen records implement it**
(Salesforce's documented chain, WooCommerce's `'parent'` sentinel, Shopee's weight/dimension fallback)"*) vs
A5 §2 tally (*"**d = 1** (Salesforce)"*).
The cells do say "+ a **d** mechanism", but the tally line is flat and the BRIEF's rule is that a hedge
travels into the tally. **Fix:** print the tally as "d as the primary model = 1; d as a mechanism beside a =
3" and name the three.

### 9 · SERIOUS — Google's `[multipack]` / `[is_bundle]` Indonesian optionality is **stated** in the record, not an inference; the brief truncated the quote and then filed a false OPEN item

**Where** `FAMILY.md` C2 §2 Google row, C2 §8, and `sources-new.md` O-7.
The brief quotes: *"Required (For multipack products in Australia, Brazil, Czechia, France, Germany, Italy,
Japan, Netherlands, Spain, Switzerland, the UK and the US)"* and stops. `11013.md:703` continues:
*"· Required for free listings … · **Optional for all other products and target countries**"*. `:691` says
the same for `[is_bundle]`.
C2 §8 then records: *"Google's Indonesian requiredness … is an **inference** from a country list that omits
Indonesia, **not a statement about Indonesia**."* The record **is** a statement about all other target
countries, Indonesia included. **Why it matters:** an OPEN slot is spent on a question the evidence answers,
and the brief understates what it knows. **Fix:** quote the cell whole, close O-7, delete the C2 §8 bullet.

### 10 · SERIOUS — the Indomie manufacturer spelling count does not reproduce: seven listed, nine in the data

**Where** `FAMILY.md` A5 §5, *"the 43 Indomie rows carry **one** manufacturer under **seven** spellings"*,
cited `../../sql/results/indomie.csv`.
Parsing the `attrs` column of that exact file gives **nine** distinct raw values. The brief's list omits
`PT. INDOFOOD CBP SUKSES MAKMUR Tbk` and `PT. INDOFOOD CBP SUKSES MAKMUR Tbk.` — both **case-drift**
variants. Case-insensitively it is eight, still not seven.
**Why it matters:** the two omitted values are precisely the case-drift the baseline's own
`distinct raw 5,580 / distinct trim+lower 5,541` split exists to measure. The worked example undercounts the
drift it is there to demonstrate. (The direction favours the brief's conclusion, so the argument survives —
but the number is wrong and there is no query behind it.) **Fix:** print nine, mark which two are case-only,
and add the one-line SQL that produced the set.

### 11 · SERIOUS — "38 of 43 open with the member's own full title" does not reproduce and has no query

**Where** `FAMILY.md` C1 §5, cited `sql/fam-c1-indomie-content.sql`.
That query returns `desc_head` only; the "38" is a hand count. Re-derived from the saved CSV: **36** rows
whose `desc_head` contains the row's own title exactly; 3 rows have an empty description; the remaining 4 are
near-misses (`&nbsp;` for a space, an abbreviated title `INDOMIE PREM COLLECT …`, a split `<strong>` tag, and
id 29219 whose title says `85 GR` while its description says **`86 GR`**). No rule yields 38 — the strict
count is 36 and the generous one is 40. **Fix:** state 36 with the four near-misses named, or add the
predicate to the SQL. The 29219 gram mismatch is worth keeping: it is direct evidence that the description is
*not* a reliable composed title.

### 12 · SERIOUS — "The read forks in exactly one place" is contradicted by the brief's own side file

**Where** `FAMILY.md` A5 §4 vs `design-A5.md` §0.
`design-A5.md` §0 correctly lists `catalogue/admin.py:43` → `models.py:521-525` as a reader. `FAMILY.md` §4
then asserts *"**The read forks in exactly one place**: `ProductDetailsSerializer.attribute_values`."*
At the pin, `Product.attribute_summary` (`catalogue/models.py:521-525`) reads
`self.attribute_values.all()` and is the Django-admin `list_display` column
(`catalogue/admin.py:37-46`). Under A5-a it would **silently drop every family-level value** from the admin
list. **Fix:** say "two", and add `attribute_summary` to the A5-a row of the §4 option table.

### 13 · SERIOUS — Amazon's byte-identity measurement in C1 comes from a family the record declares defective

**Where** `FAMILY.md` C1 §2, Amazon row: *"Measured: parent and all three children byte-identical on `title`
stem, `description`, `bullet-point1`, all five `search-terms`, `item-type`, `target-audience`,
`main-image-url`, `warnings`"* `[E-12]`.
`10976.md:412`: *"⚠️ **Both of Amazon's flavour examples are internally defective**, recorded as-is rather
than cleaned up: 1. The `flavor`-theme family (Clif Bar) leaves the **`flavor` column empty on all four rows**
*and* **`parent-sku` empty on all three children**."* **Fix:** carry the warning, or move the measurement to
`Flat.File.Home.xls`, which the same paragraph calls clean (*"Amazon's four `Size`/`Color` families … **are**
clean"*). The `[E-25]` quote alone still supports **i**.

### 14 · SERIOUS — "Amazon's 7 own worked families" omits the record's retraction of their independence

**Where** `FAMILY.md` A5 §2, Amazon row.
`10976.md:418`: *"⚠️ **The seven flat-file `Example` sheets are one artifact, not seven.** Beauty,
FoodAndBeverages, Gourmet, Health, Jewelry, PetSupplies are **cell-identical** (SHA1 of all cell values
`c55c37cfc4ba`); Clothing differs only by 5 absent `other-image-url` columns. Only `Flat.File.Home.xls` …
is a genui[ne]…"* The brief quotes `:391`'s "all 7" without `:418`'s correction. **Fix:** add the sentence;
it is one clause and it is the difference between seven independent observations and two.

### 15 · SERIOUS — C2 §7 cites #11126 as agreeing with "no family link"; #11126 explicitly routes variant families away

**Where** `FAMILY.md` C2 §7: *"**Confidence: high** … on the banded pack (GS1 §2.9, **#11126's own decision**,
and C1's rule all agree)."*
`11126.md:69`: *"Case catalogue C11 · C12 on #10724 · whole-deal returns #10946 · variant families #10778
(**not** the home for this)."* #11126 decided **one SKU, no assembly** (`:15`); it decided nothing about
family membership and said so. The brief's own C2 §8 concedes it (*"#11126's 'mechanism for keeping a banded
pack distinguishable' is still open and this card does not close it"*) — §7 and §8 disagree.
Separately, the phrase C2 §8 puts in quote marks (*"mechanism for keeping a banded pack distinguishable"*) is
stitched from two sentences, not verbatim. **Fix:** drop #11126 from §7's confidence list; keep GS1 §2.9 and
C1's rule, which do support it.

### 16 · SERIOUS — the GS1 document's P1 provenance never reaches the brief, though C2's recommendation rests on it

**Where** `FAMILY.md` C2 §1 cites *"`corpus/gs1/GS1_GTIN_Management_Standard.pdf`, Release 1.1, Ratified Sep
2023"* with no provenance mark; C2 §8 does not carry it.
`sources-new.md` correctly files it as **P1** — *"a GS1 Member Organisation redistributing the AISBL
document"* — and **O-6** records that no P0 copy was reachable (`www.gs1.org/docs/idkeys/…` → 404). C2's
entire three-way pack split, and therefore its recommendation, is built on this one artifact.
(Its content verified clean — see below — so this is a provenance-disclosure failure, not a content failure.)
**Fix:** one line in C2 §8 carrying O-6.

### 17 · SERIOUS — the two rows the brief calls "canonical" both carry a "no live instance" hedge the table drops

**Where** `FAMILY.md` A5 §2: commercetools *"**a** — the canonical instance"*; C1 §2 Salesforce.
`11081.md:913` **U1**: *"**No live response for any object.** Every instance in §2c is a vendor documentation
example."* `11050.md:606` **U9**: *"**No retrieved instance data exists in this record at all**"* — no
populated `VariationGroup`, no `<variation-attribute>` element. **Why it matters:** commercetools is the
shape the A5 recommendation is modelled on; "canonical instance" reads as an observed system. **Fix:** say
"the canonical *documented* shape" and carry U1 / U9.

### 18 · SERIOUS — Tokopedia's 3-axis cap is an unresolved contradiction in its record, and the brief spends it twice

**Where** `FAMILY.md` C2 §7 (*"Shopify and Tokopedia are the other two the page already cites"*) and C3 §7
(*"Walmart, Shopify and Tokopedia all cap at 3"*).
`11048.md` **U1** is open: the API doc says 3, Tokopedia Care ID says *"maksimal 2 kategori varian"*
(`11048.md:1470`), both re-fetched, gate **H1**. The brief uses the 3 as corroboration for D6's cap in two
separate recommendations. **Fix:** cite Walmart and Shopify (both unhedged) and name Tokopedia's U1.

### 19 · SERIOUS — the Walmart "spec route" enum of 9 is one product type's list, printed as the spec's

**Where** `FAMILY.md` C2 §2, Walmart row: *"Spec route: `variantAttributeNames.items.enum` =
[9 names]"*.
`11046.md:210` prints that array as the **`Sticky Notes`** instance, inside a passage retracting a "mirror"
claim. The record's spec-level facts are 6,957 types each with its own enum, **2,323 distinct axis names**,
mean enum size **11.75**. The brief's unqualified rendering reads as global.
The same row elides *"Supported variant attributes **vary by product type and item specification version**"*
from the corpus page, and omits `11046.md:2765` (the two artifacts' axis sets disagree on **2,154** types).
**Fix:** label the 9 as `Sticky Notes`, and cite the 2,323 / 11.75 spec-level numbers instead.

### 20 · SERIOUS — Akeneo's axis type-restriction is quoted as settled; its own record files it as a live contradiction

**Where** `FAMILY.md` C2 §2, Akeneo row: *"axes are type-restricted: "Only the following attribute types are
allowed: `simple select`, `multi select`, `reference data`, `metric`, `boolean`.""*
`11069.md` §5 **C3** tabulates **six vendor statements with three different answers**; the Serenity list
permits **`Number`** and **`Text`** as well. The brief picks the `openapi.json` answer without saying the
record holds it open. The downstream inference (*"A count fits `metric` or `simple select`"*) survives either
way. **Fix:** add "(the record records six statements and three answers — §5 C3)".

### 21 · SERIOUS — "Forbidding it: 0" rests on six records, and the one platform that does restrict axes was not in the grep

**Where** `FAMILY.md` C2 §2 (*"**Forbidding it: 0.** The deliberate counter-search … is recorded in
`sources-new.md`"*) and `sources-new.md` "Counter-evidence searched for on purpose".
`sources-new.md` claims *"Searched the thirteen records"* and then prints the instrument:
`11013.md, 11045.md, 11046.md, 11047.md, 11048.md, 10976.md` — **six**. `11069.md` is not among them, and
Akeneo is the one platform in the set that restricts what may be an axis (finding 20). **Fix:** re-run the
grep over all thirteen and reprint the instrument, or restate the claim as "over six records".

### 22 · SERIOUS — Google's variant-attribute list is truncated in the direction that supports the brief's verdict

**Where** `FAMILY.md` C2 §2, Google row: *"The variant attributes Google names are `color`, `pattern`,
`material`, `age_group`, `gender`, `size`."*
`11013.md:251` gives an **eight**-item list, and `:254` records a deliberate counter-search result:
*"no artifact stating a closed set found."* A record that says there is no closed set is evidence *for*
count-expressibility, not for "ambiguous". **Fix:** print eight and add the "no closed set" finding; Google's
row then supports "expressible" rather than "ambiguous".

### 23 · SERIOUS — Shopee's A5 quotation is `#11031`'s paraphrase, cited to `#11047`, at a wrong section, with the vendor's conditional stripped

**Where** `FAMILY.md` A5 §2, Shopee row: *"`weight`, `dimension`, days-to-ship fall back to the item"*, cited
`#11047 §1.9, §2b`.
The string is **not in `11047.md`**; it is at `11031.md:1074`. `#11047 §1.9` is "The hard caps", not this
material. The record's own words are `11047.md:420` (*"`weight`, `dimension`, `pre_order` — **inherited, see
below**"*) and `:423` (*"**Shared fields are inherited, not independently valued by default**"*, from
`add_model` / `init_tier_variation`), with the vendor text at `:427-429` — *"If don't set the weight of this
model, will use the weight of item by default"* — plus the conditional the brief drops: *"If set the
dimension of this model, them must set the weight of this model"* (the fallback is not unconditional).
**Fix:** re-cite to `#11047 §1.5/§2b` and quote `:423`.

### 24 · SERIOUS — the same mis-citation pattern runs through C1 §2: five rows quote `#11031`'s field survey under the per-platform record's number

**Where** `FAMILY.md` C1 §2.
commercetools (*"Description of the Product."* — **0 hits in `11081.md`**, cited `#11081 §1.x` **alone**),
Akeneo (both quotes, 0 hits in `11069.md`), Square, WooCommerce and Magento's *"16,126 B"* all live in
`11031.md` (rows :1197 – :1202). Some rows do also cite `#11031`; the commercetools row does not, so its
quote is uncheckable at the cite given. `11031.md:1201` also carries a clause the brief drops:
*"The Modular `VariantProjection.description?` is 'Description of the parent Product' — a read-only beta
projection."* **Fix:** cite `#11031 §B` alongside the platform record wherever the string came from the survey.

### 25 · SERIOUS — Magento's C1 cell and the two-families sub-tally present the brief's own prose inside quotation marks

**Where** `FAMILY.md` C1 §2 Magento row and the sub-tally's Magento counterfactual.
The sub-tally prints *"the record records child → parent as **0..N** precisely because the unique constraint
is on the pair, not on the child"* as a quotation with a cite; `11082.md:246` reads
`child → parent | same table | **0..N** (unique is on the *pair*)` — a table cell, not that sentence. The C1
Magento cell likewise reshapes `11031.md:1199` and drops *"updated 2026-06-15"*. **Fix:** un-italicise, or
quote the table cell.

### 26 · SERIOUS — C3 §8 says #10943's regex "was never published"; half of it was, and the brief reuses that half

**Where** `FAMILY.md` C3 §8 (*"Its regex was never published"*) vs C3 §5 (*"The **size-token** regex was
never published"* — correct).
`#10943`'s 2026-08-10 comment publishes the **apparel-title** regex whole
(`KAOS|BAJU|CELANA|KEMEJA|JAKET|SERAGAM|PAKAIAN`), which is exactly the keyword set
`fam-c3-apparel-sensitivity.sql` and `fam-c3-grid.sql` reuse. Only the size-token regex is unpublished.
**Fix:** restore the qualifier in §8.

### 27 · SERIOUS — the 1,945 → 2,062 apparel delta is presented as growth; a source change is not excluded

**Where** `FAMILY.md` C3 §5, *"**2,062** (was 1,945 on 2026-08-10)"*.
`#10943` states its query ran *"against the BigQuery prod mirror"* and carries a caveat the brief never
repeats: *"Treat the title-keyword match as a **floor**: apparel not matching those words is not counted."*
The brief's re-run is its own `sql/` query against `production_append_public`. The delta may be population
growth, a different dedup, or a different source. **Fix:** say "2,062 at this snapshot against 1,945 reported
on 2026-08-10; the two were not run on the same instrument, so the delta is not necessarily growth."

### 28 · SERIOUS — Meta's own internal contradiction is unrecorded, while the weaker external one is

**Where** `FAMILY.md` C1 §2 Meta row and §8.
The brief records the Meta-vs-Google `link` contradiction (O-3). Verified at the corpus: the same 6-row CSV
also gives **identical `image_link` and `additional_image_link` on all six rows**
(`corpus/meta/fb-catalog-fields.txt:588-593`) — directly against Meta's own rule on the page the brief quotes
from: *"images and external links match the color of the item"* and *"the name does not change when variants
are selected, **but images do**"*. Meta's worked sample contradicts Meta's worked rule. **Fix:** add it to
C1 §8 beside O-3; it strengthens the brief's point that vendor samples are not specifications.

### 29 · SERIOUS — C1's headline hard rules for Walmart are contested inside `#11046`, with no signal to the reader

**Where** `FAMILY.md` C1 §2, Walmart row (the five-bullet "must" list).
The list is verbatim at `11046.md:1052` and at the corpus page ✓. But `11046.md:370/551/589` (**U26 / §5 #27**)
records that **two of those clauses return 0 hits** on the page §2 attributes them to, strikes them, and says
*"which side moved is not decidable"*; and U13's real status is stronger than the brief's "best practice" —
*"no vendor page states a rule for any field other than `variantGroupId` and the axis names."*
**Fix:** one clause noting U26; the brief's version matches the currently-served page, which is the right
call, but the reader should know the record disputes it.

### 30 · SERIOUS — Shopee's "32 declared `item_list` children" is the list its own record flags as self-contradicting

**Where** `FAMILY.md` C1 §2, Shopee row.
`11047.md:571` is **contradiction 18, "A schema that contradicts its own sample"**: that 32-child list
contains neither `tier_variation` nor `model_list`, while the only vendor sample posts both. The brief uses
the list to establish that `description` is item-level. **Fix:** carry contradiction 18.

### 31 · SERIOUS — Google's "0 `itemLevelIssues`" probe is not a discriminating control

**Where** `FAMILY.md` C1 §2 Google row and §8 (*"a live probe of divergent `brand` under one group produced
**0 `itemLevelIssues`**"*).
`11013.md:925` records that **no product in the entire pass carried any `itemLevelIssues`**. A control that
never fires cannot distinguish "divergent brand is allowed" from "the diagnostic channel was silent." The
brief presents it as weak positive evidence. **Fix:** say the control was undiscriminating; the U9 "not
stated" finding carries the row on its own.

### 32 · SERIOUS — four dangling or wrong section cites

**Where** throughout.
- `#11050 §5 D6` (`FAMILY.md` C3 §8) — §5 of `11050.md` holds C1–C14; there is no D6. The record itself
  mis-points at `:331`; the brief inherited it.
- Amazon C2: cited `§1.8, §2`; `variation_theme`, the `count` → `ITEM_PACKAGE_QUANTITY` map and the `Health`
  themes are in **§1.5**. `Health` is a **workbook** (`Flat.File.Health.xls`), not "the `Health` product
  type" — and `10976.md:566` records a contradiction about exactly that conflation.
- Walmart C2: cited `§1.x, §1.8`; the Toothpastes/Tires intersect is **§1.4** (`11046.md:217`) and VIRTUALPACK
  is **§1.9** (`11046.md:327`, `[R-17]`).
- Akeneo C3: cited `§1.2, §1.6`; `MAXIMUM_LEVEL_NUMBER` and the axis-type quote are in **§1.x** — only
  `ProductModel.parent` CASCADE is §1.6.
**Fix:** re-resolve each; they are all checkable in one pass.

### 33 · SERIOUS — `sources-new.md` O-2 and O-6 never surface in `FAMILY.md` §8

**Where** `sources-new.md` OPEN table vs `FAMILY.md` §8 sections.
Of the seven OPEN items, O-1, O-3, O-4 (C1 §8) and O-5, O-7 (C2 §8) travel. **O-2** (does Meta have a
`ProductGroup` node with its own fields — two 404s) and **O-6** (GS1 provenance, finding 16) appear nowhere in
the brief. The output contract puts "not collected + route" in §8. **Fix:** add both; O-2 belongs in C1 §8
because Meta is counted as a fourteenth row on the strength of having no group content row.

---

## MINOR

34. **MINOR — a backend path that does not resolve at the stated root.** `FAMILY.md` A5 §4 and C1 §4 cite
    `templates/search/indexes/catalogue/product_text.txt`. Every other backend cite in the brief is relative
    to `py/mono/solvent/`; this file is at `py/mono/templates/…`. Fix: write the full relative path.

35. **MINOR — the file table says "five queries"; there are eight.** `FAMILY.md` header table, `sql/*.sql`
    row. Eight `.sql` files exist and all eight ran. Fix: change to eight.

36. **MINOR — "one production create path" undercounts the write surface C1-i must cover.** `FAMILY.md` C1
    §4 names `api/apiproduct/staff_serializers.py:98-130` (which is `create()`, actually `:98-128`). C1-i's
    cross-row validators fire on **every** write; `ProductUpdateSerializer.update()` at `:131-145` is the
    other path. `design-A5.md` §0 does list `:133-138`. Fix: name both in `FAMILY.md`.

37. **MINOR — A5 §6's hazard wording is stronger than A5 §7's cost claim, and §7 is the accurate one.** §6:
    *"`validate_attributes()` must learn the level **in the same commit that adds it**, or every save breaks."*
    Re-checked at `product_attributes.py:36-52` + `models.py:484`: with `level` defaulting to `'member'`,
    `get_all_attributes()` still returns every attribute and every value is still on the member, so nothing
    breaks until the **first definition is moved**. The day-one-no-op claim in §7 **holds**. Fix: reword §6
    to "in the same commit that moves the first definition".

38. **MINOR — A5-a's day-one cost is "zero" in Python but not quite zero in Postgres.**
    `design-A5.md`'s migration adds `CHECK (num_nonnulls(product_id, variant_group_id) = 1)` to a
    471,143-row table. Added plain, that takes `ACCESS EXCLUSIVE` plus a validating scan. Small at this row
    count, but it should say `NOT VALID` + `VALIDATE CONSTRAINT`. Fix: one clause in the SQL sketch.

39. **MINOR — A5-a moves required-ness without saying where it lands.** `FAMILY.md` §6 compresses the fix to
    *"one condition in one loop"*; `design-A5.md` §0 has the other half (*"skip family-level definitions, **and
    validate them on the group instead**"*). There is no family model and nothing calls a family `clean()`, so
    that validator is new work. Fix: carry the second clause into `FAMILY.md` §6.

40. **MINOR — `Product.slug` and `thumbnail_url_cache` are unnamed though C1 assigns both concerns.**
    `catalogue/models.py:405-408` (`AutoSlugField(populate_from="title", unique=True)`) and `:434`
    (`thumbnail_url_cache`, a denormalised primary-image URL on `Product`). C1 §7 assigns `slug` to the
    family and keeps images "member-first, family fallback"; both fields are downstream of those decisions.

41. **MINOR — `fam-c2-pack.sql`'s result does not reproduce row-for-row.** Its final `ORDER BY 1,3` ties on
    `count = 1` across ~2,900 category rows, so the saved CSV's "top categories" tail comes back in a
    different order. Every *number* is identical. Fix: add `main_category_id` to the ORDER BY so the saved
    result is reproducible.

42. **MINOR — `design-A5.md` §0 cites `.ts:32` for `hiddenAttributes`.** At the pin it is
    `product-addendum-attributes-ui.component.ts:34`; `:32` is a docblock comment line.

43. **MINOR — the order-line comment is attributed one line group too low.** `FAMILY.md` C1 §4 puts
    *"We don't want any hard links between orders and the products table"* at `order/models.py:550-555`; the
    comment is at `:548-549` and `:550-555` is the field.

44. **MINOR — C3 §4 cites no frontend at all**, though the contract asks §4 for both stacks. The claim
    (*"Nothing in either stack reads a family today"*) is true, but it is asserted rather than instrumented.

45. **MINOR — the frontend §4 is thin relative to the backend.** A5 §4 and C1 §4 name three `ts/` files. At
    the pin there are ~28 `product.title` / `product.slug` consumers across `libs/`, including three ESC/POS
    label formatters (`order/util-printer-label-esc-pos-formatter/…:274`,
    `order/return/util-printer-label-esc-pos-formatter/…:60`,
    `printer/label/product/util-zebra-formatter/…:73`) and the analytics formatter
    (`analytics/util-core/…/analytics-formatter.service.ts:43`). The brief's *"reads whatever string it is
    given"* verdict is **correct** for all of them — they consume one API field — but the §4 sweep should say
    so with a count rather than one example.

46. **MINOR — the proxy-family instrument's bias is named but not quantified in the direction that matters.**
    C1 §8 says it is *"a proxy and a generous one … an upper bound"* ✓, correctly echoing `#11031`'s own
    caveat. What it does not say: a three-word prefix inside one `main_category` **under**-counts as well as
    over-counts. It over-counts by grouping unrelated products that share a brand prefix
    (`SGM EKSPLOR 1+ …` vs `SGM 2 BOX …`) and by grouping a single with its own carton. It **under**-counts
    every real family whose members differ inside the first three words — which is exactly the apparel and
    net-content shapes C3 measures (`INDOMIE GORENG CABE IJO 85 GR` and `INDOMIE GORENG CABE IJO JUMBO 120 GR`
    share a prefix, but `LIFREE CELANA TIPIS (XXL-10)` and `LIFREE POPOK CELANA TIPIS L16` do not). So the
    1,748 grid candidates in C3 §5 are an upper bound on *these* grids and a **lower** bound on grids overall,
    and the brief presents only the first direction. Fix: one sentence in C3 §8.

---

## Verified clean — what I re-ran and confirmed

**Both pins.** `py-5` `HEAD = 4f99dc01c6baf181ffc54c460e936384d12968f7` ✓ · `ts-layer2`
`HEAD = 82187a17bdd5cfbe8f77a52d14fa3f7109fc5c2f`, tag `ts-v2.195.1` ✓.

**All eight SQL files re-run** (`bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv
--max_rows=5000 < file.sql`, 2026-09-19). Seven returned output **byte-identical** to the saved CSV; the
eighth (`fam-c2-pack`) differs only in the tie-ordering of its category tail (finding 41) — every number is
identical.

**Every figure the task listed reproduced:**
10,090 proxy families ✓ · 3,912 all-different descriptions ✓ · 5,998 share one string, of which 5,997 are
all-empty → exactly **one** genuinely shared non-empty description ✓ · 2,945 of 11,411 prefixes = 25.81%
straddling, covering 11,323 products ✓ · 2,112 duplicate normalised titles / 4,273 products / 891
cross-category ✓ · active-online `987` = **2,152** of 23,299 (9.24%) and GS1-valid 21,116 (90.63%) ✓ ·
family barcode mix **5,303 / 4,045 / 664** (+85 other) ✓ · `N x M` with no unit = **2,055** of 2,168 ✓ ·
`ISI N` 3,521 + `N x M`+unit 112 = **3,633** multipacks, 697 + 30 = **727** with a plausible single ✓ ·
grid candidates **1,748** families / **8,071** products ✓ · apparel live **2,062**, defensible floor
**287** (13.92%) ✓ · every derived percentage in the brief recomputes to the stated figure ✓ ·
41 distinct Indomie description MD5s of 43 rows, 3 empty → 40 distinct bodies ✓ · all **33** active Indomie
rows carry distinct `089686…` codes ✓.

**Backend `path:line` re-opened at the pin and confirmed exactly as the brief states them:**
`catalogue/models.py` `:385-389` `upc` (unique, non-null) · `:392` title · `:410` description · `:427`
main_category — i.e. the brief's own correction of the 2026-09-15 page's `:390/:398/:418/:434` is right on
all four · `:468-484` `Product.clean()` with the `validate_attributes()` call at `:484` · `:672` `save_value`
signature `(product, value)` · `:719` `ProductAttributeValue` · `:730` `unique_together` · `:736` the NOT NULL
`product` FK · `:866` `PRODUCT_CODE_PREFIX = "987"` · `:895` `ProductMeta`, `:905`
`quantity_purchasing_allowed_multiples`, `:910` `quantity_per_box` ·
`product_attributes.py:36-52 / :54-55 / :60-64` · `api/apiproduct/serializers.py:200, 207, 219-221` ·
`api/apiproduct/views.py:60` · `search/search_indexes.py:30` (`guid`) and `:34, 38, 54, 55` (four
`model_attr="title"`) · `templates/search/indexes/catalogue/product_text.txt` is three lines with
`object.description` on line 3 · `third_party_api/google/content/products_api.py:214-224, 218-221, 222,
230-232, 234-235` — exactly eight attributes, no attribute value · `shared/url_build/solui.py:20` ·
`order/models.py:550-556` · `catalogue/upc/types.py:3` `UPC_WEIGHT_EMBEDDED_LENGTH = 7` ·
`catalogue/validators.py:10` · `api/apiproduct/staff_serializers.py:98…124` inside `transaction.atomic()`.

**The 20-relation count is right.** I re-derived it with an independent multi-line-aware parser: exactly
twenty `ForeignKey`/`OneToOneField`/`ManyToManyField` declarations target `Product` outside migrations and
tests, and all twenty line numbers in the brief's list are correct, including the mixin at
`catalogue/models_mixins.py:29` that the field survey's "19" misses.

**Frontend `path:line` re-opened and confirmed:** `product-update-staff-form-ui.component.ts:186` and `:235`
(and `:215`) · `product-addendum-attributes-ui.component.html:6-20` + `.ts:42-56` ·
`product-feature-shell-routing.module.ts:17-21` (`:productId/:slug`) · `product-link-ui.directive.ts:39` ·
`product.model.ts:49, 73` · `product-detail-ui.component.html:60`.

**Corpus quotes — every one I could check is present verbatim in the saved artifact.**
GS1 `GS1_GTIN_Management_Standard.txt`: §2.1 jeanswear example ✓ · §2.3 rule + the razors-4-to-6 example ✓ ·
§2.8 rule ✓ · §2.9 definition and the components'-own-GTIN sentence ✓ · the guiding-principles question ✓ ·
and the three table rows the brief's C2 §1 depends on, all confirmed: `Declared net content · YES · YES`,
`Pack/case quantity · N/A · YES` with guiding principles `NO YES YES`, `Predefined assortment · YES · YES` ·
footer `Release 1.1, Ratified, Sep 2023` ✓. The §2.3 hierarchy sentence *"The GTIN change occurs at the
retail consumer trade item or base unit level"* confirms the brief's "same level as the single" ✓.
Walmart `wm-multiple-variants.txt`: the five-bullet must-list ✓ · *"An item can belong to only one variant
group."* ✓ · *"Keep product content consistent…"* confirmed to sit under a **Best practices** heading ✓ ·
*"Variant groups allow sellers to display multiple versions…"* ✓ · the discovery sentence ✓ ·
*"Each variant group must contain exactly one primary variant."* ✓ · *"Up to three variant attributes can be
used."* ✓ · the `Color · Size · Pattern · Character · Count · Count per pack · Multipack quantity · Theme`
list under a real **Supported variant attributes** heading ✓.
Meta `fb-variants-dev.txt`: all three quoted strings ✓. `fb-catalog-fields.txt:587-593`: the CSV sample
**parses as the brief describes it** — 6 rows differing only in `id`, `color` (blue×3, black×3) and `size`
(small/medium/large), with `title`, `description`, `rich_text_description`, `link`, `image_link`, `brand`,
`google_product_category`, `product_type` and `price` all single-valued ✓.
Walmart `Toothpastes` 9 / `Tires` 18 / *"they intersect only in `count`, `countPerPack`, `multipackQuantity`"*
✓ verbatim at `11046.md:217`; `variantAttributeNames.items.enum` ✓ verbatim at `:210` (but see finding 19).

**Record quotes confirmed verbatim** (spot-checked by me, plus a full sweep by two independent passes):
Amazon `[E-25]` *"Child ASINs with different non-varying attribute values cannot be grouped…"* ✓ and
`:391`'s *"zero fields populated on the parent row and on no child row"* ✓ · Shopify
`MetafieldDefinition.ownerType` description and the 25/26/26/28 enum counts ✓ · Square `allowed_object_types`
including the vendor's `atttribute` typo ✓ · Tokopedia Era B `attributes[].type` whole ✓ · Magento
*"There is **no inheritance mechanism in the schema**"* ✓ at `11082.md:681` and `SCOPE_STORE = 0 /
SCOPE_GLOBAL = 1` ✓ · commercetools `enum: [Product, Variant]`, the `attributeConstraint must be None` gate,
and the Merchant-Center immutability line ✓ · Salesforce's fallback sentence ✓ at `11050.md:412` ·
WooCommerce `$value = 'parent';` ✓ · Akeneo `clothing_color_size` JSON ✓, `MAXIMUM_LEVEL_NUMBER = 2` at
`FamilyVariantValidator.php:20` enforced `:154-197` ✓, the seven help pages ✓ · Amazon feed error **8032** ✓ ·
Magento `UNIQUE (product_id, parent_id)` ✓ · Google's `[R-9]` item-group-title pair ✓ · the Google
per-variant-landing-page quote ✓ (present at `11031.md:1296`; see the note below).

**Tokopedia era discipline: clean.** A5 uses only `11048.md:347` (Era B) and C1 only `11031.md:1196`
("Tokopedia Era B"). No Era A material appears in any FAMILY table, and A5 §8 states the exclusion. No merge.

**Tallies re-derived from the brief's own tables and all reconcile arithmetically:**
A5 6 / 1 / 4 / 1 + 1 ambiguous = 13 ✓ (but see finding 7) · C1 3 / 5 / 2 + 3 ambiguous = 13 ✓ and the
"8 of 13 hold siblings must not differ" = 3 + 5 ✓ · C1's one-product-two-families 12 / 1 ✓ with Magento the
sole counterfactual ✓ · C2 2 / 9 / 1 / 1, forbidding 0 = 13 ✓ · C3 9 / 2 / 0 / 2 = 13 ✓.

**Both card corrections check out.** Shopify is **not** an example of A5-b: `MetafieldDefinition.ownerType`
is a single non-null enum value, so each definition is pinned to one owner type — the card's *"Shopify
metafields exist on both Product and ProductVariant"* is true of the surface only, and the brief's correction
is right. C2's *"(a) and (b) are not alternatives"* is right: Amazon's `ItemRelationship.type` carries
`VARIATION` and `PACKAGE_HIERARCHY` as sibling values of one enum, and Walmart names `count` as an axis while
also shipping Virtual Pack.

**Structure and couplings.** All four cards carry all eight contract sections (C1 adds a §5b). The coupling
citations are present and none re-decides the other brief's question: A2 → ATTR-DEF (A5 §1, C2 §7 with the
D3 dependency spelled out), A0 → ATTR-DEF and A4 → ATTR-VALUE (A5 §7, both explicitly "cited not decided"),
A4 again in C2 §7 for the value shape of "Isi 6". Every recommendation carries a labelled judgement, a
confidence, reopen triggers, and a "what it forces in steps 1–5" paragraph. The four #10778 items the task
named are each addressed explicitly and none is silently contradicted: **S1** confirmed (and correctly shown
to be free under shape B, retiring #10778's nullable-`upc` work item), **C2** re-expressed with the
narrowing named as a narrowing, **M4** re-expressed with the same-product / two-different-products line drawn,
**M9** confirmed with our own numbers. The two locks, the five conditions, the 2026-09-15 tentatives and the
2026-09-18 closed "one category per product" are all respected; A5 §5 gives both as-measured and
post-condition-2 figures as condition 2 requires.

**One note on a quote I initially could not source.** `FAMILY.md:359` attributes *"different landing page
URLs submitted for each variant"* to Google with **no cite**, and it is not in `11013.md`. It **is** genuine —
`11031.md:1296` and the 2026-09-15 field survey both carry it whole. `design-C1.md:177` cites it correctly.
Fix is a cite on `FAMILY.md:359`. But the reading built on it should be softened: `11013.md:379` has Google
describing the opposite pattern — *"If your website allows customers to select between multiple variants on a
single landing page … make sure all those versions are submitted with the same item group ID"* — so C1 §6's
flat *"Google requires per-variant landing pages, so no channel wants it"*, used to **drop** the bare-family-URL
half of #10778 C2, is one-sided. The conclusion (don't build `/shop/family/:id`) survives on the cheaper
argument the brief already gives: under shape B the group has no route and needs none.
