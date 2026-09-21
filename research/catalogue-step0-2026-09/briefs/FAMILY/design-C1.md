# design-C1 — the sibling rule, as constraints vs validators, against our real models

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`; frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.

## 0 · Shape B, as Lock 2 leaves it

> ⚠️ `VariantGroup` / `catalogue_variantgroup` is a **placeholder name**. Table naming is L2.3 and is
> open (step 5 of the page: *"keep `Product` as the sellable row and name the container"*). Nothing in these
> sketches depends on the name.


```
VariantGroup (new)   id · main_category(FK) · title · slug · description · [dimension list] · [aggregates]
Product              catalogue/models.py:351   + variant_group_id  NOT NULL FK
  is_public   :375   is_offline_only :381   upc :385 (unique=True, non-null)
  title :392   title_staff :394   notes_staff :400   slug :405 (AutoSlugField, unique=True)
  description :410   product_class :414   main_category :427   thumbnail_url_cache :434
  price_sell_online :437   inventory_facility_online :445
  get_absolute_url() :465-466 → soladmin `product/list?upc=%(upc)s`   (shared/url_build/soladmin.py:14)
Customer URL         shared/url_build/solui.py:20  `shop/product/%(product_id)s/%(product_slug)s`
Frontend route       ts/libs/product/feature-shell/src/lib/product-feature-shell-routing.module.ts:17-21
                     path `:productId/:slug`, component ProductDetailPageComponent
```

Twenty relations point at `Product` at this pin (enumerated by regex over `models.ForeignKey|OneToOneField|
ManyToManyField` targeting `Product`, migrations and tests excluded):
`analytics:20,55 · basket:1164 · catalogue:344,736,788,890,898 · catalogue/models_mixins:29 ·
forecast:26 · inventory/reconciliation:147 · order:550 · price/purchase:66 · price/sell:31,187 ·
printer/label/models/printer_label_product:81 · purchasing/models/purchasing:280 ·
receiving/models/receiving:254 · return_to_supplier:201 · transport/models/models:198`.
`inventory/models.py` `InventoryRecord` and `InventoryFacility` reach `Product` through
`HasProductDependentSearchIndexModelMixin` (`catalogue/models_mixins.py:29`), not by their own declaration —
which is why a plain grep of `inventory/models.py` finds none. (The field-survey page says "19"; the
difference is which of these you count.)

⚠️ **Three of these have moved since the 2026-09-15 field-survey page**, which cites `transport :192`,
`printer/label :81`… — at this pin `transport/models/models.py` is **:198** (the page's :192 no longer
lands on the FK), `price/sell` is **:31, :187** (the page says `:31, :182`), and the rest agree. Re-take
every cite at the pin, per the brief's errata.

## 1 · Candidate invariants, and where each can live

| # | Candidate rule | Cheapest true home | Cost |
|---|---|---|---|
| 1 | every member is in exactly one family | **DB**: `Product.variant_group_id NOT NULL` | free — Lock 2 already |
| 2 | every member has its own barcode | **DB**: `upc unique=True`, non-null (`models.py:385-389`) | free — already true |
| 3 | siblings share the category | **DB** if the member keeps no `main_category`; **composite FK** if it keeps a mirror | see §2 |
| 4 | siblings differ in their axis values, and each combination is unique | **DB**: lock condition 4's composite-FK dimension mirror + UNIQUE | already scoped |
| 5 | siblings use the same axis *names* | **by construction**: the dimension list hangs off the group | free |
| 6 | siblings share the description | **validator, or nothing** | see §3 |
| 7 | siblings share the brand | **nothing** — unenforceable on today's data | see §4 |
| 8 | siblings do not repeat the full title | **validator** + a composed read | see §5 |
| 9 | siblings may differ in price, stock, visibility | **no rule** — all three already per-member | free |

## 2 · Category: the one rule worth a database constraint

The tentative decision puts `main_category` on the family. If the member keeps nothing, the rule is true by
construction and there is nothing to enforce. If the member keeps the "validated duplicate" the field survey
leaves open (its item 1, so that age-walling `models.py:571-573`, replenishment, the search index and the
feed keep reading the column they read today), the duplicate must not drift:

```sql
ALTER TABLE catalogue_variantgroup ADD CONSTRAINT vg_id_cat_uniq UNIQUE (id, main_category_id);
ALTER TABLE catalogue_product ADD CONSTRAINT product_cat_matches_group
  FOREIGN KEY (variant_group_id, main_category_id)
  REFERENCES catalogue_variantgroup (id, main_category_id);
```

That is the same composite-FK trick lock condition 4 already buys for the dimension count, so it costs one
more redundant unique index and no new machinery.

**Why it is needed and not theoretical.** Grouping by name alone crosses categories at scale: of the 11,411
three-word title prefixes carried by ≥2 products, **2,945 (25.8%) span more than one `main_category`,
covering 11,323 products** (`sql/fam-c1-sibling-consistency.sql`, 2026-09-19). A merge screen that offers
"products with a similar name" will therefore offer cross-category merges roughly a quarter of the time.
Walmart states the member's side of this as a hard rule — *"An item can belong to only one variant group."*
(`corpus/walmart/wm-multiple-variants.txt`, fetched 2026-09-19) — but states nothing about the category;
Salesforce does: the classification category *"cannot be overridden"* on a variant (#11050, via the
2026-09-15 field survey).

## 3 · Description: the platform answer and our data disagree, and the disagreement is resolvable

**The platform answer is family**, and it is the strongest row in the whole field survey: 5 platforms give
the member no description field at all (Shopify, Shopee, Tokopedia Era B, Square, commercetools), 2 inherit
it (Salesforce, Akeneo), 4 repeat it per row and police it identical (Amazon, eBay, Walmart, Google), 2 give
the member a real independent one (Magento, WooCommerce). eBay is the sharpest: members' *"product.title and
product.description values … must have the same values"* (#11045 §1.4).

**Our data says the opposite about today's rows.** Across the 10,090 proxy families
(`sql/fam-c1-sibling-consistency.sql`):

- **3,912 (38.8%)** have a *different* description on every member;
- **5,998 (59.4%)** "share one description string" — but **5,997** of those are families where every member's
  description is empty. Net: essentially **one** proxy family in the catalogue has a genuinely shared,
  non-empty description.
- On the Indomie 43: **41 distinct `MD5(description)`**, 3 of them empty, so **40 distinct non-empty bodies**;
  and **38 of 43 descriptions open with the member's own full title including its gram weight** —
  `<p><strong>INDOMIE AYAM BAWANG 69 GR</strong></p>…` (`sql/results/fam-c1-indomie-content.csv`).

So "description at the family" is not a field move, it is a **content rewrite**: the first line of 38 bodies
is member-specific by construction.

**The resolution costs nothing if it is sequenced right.** On Lock 2's day one every family has one member,
so the description moves 1:1 and loses nothing. The loss only ever appears at **merge** time — and that is
exactly the moment a human is looking at both rows. So the rule is:

> The family owns the description. The merge screen presents every losing member's description and requires a
> choice; it never silently discards one. This is the same rule the lock already states for images
> (*"a merge must not delete the losing member's images"*).

~~The search consequence is one line.~~ ⚠️ **Corrected (findings 1, 2).** The search consequence is three
things, not one: (a) `py/mono/templates/search/indexes/catalogue/product_text.txt:3` indexes
`{{ object.description|default:""|striptags }}`, which becomes `object.variant_group.description` and must be
`select_related`; (b) the **seven** templates that include `product_lite.txt` also render the member's raw
title (§5); and (c) **nothing reindexes anything when the family row changes** — every trigger is
`post_save` on `Product` (§5b). Without (c) the first two are moot: the documents would be correct only until
the next member save.

## 4 · Brand: state it as advisory, because it cannot be enforced

There is no brand field. `manufacturer` is not one: #10778's corrections measured its top values as corporate
entities — `PT. UNILEVER INDONESIA TBK` covering Bango, Royco, Wall's and Lifebuoy simultaneously — and struck
the GS1 company prefix for the same reason (*"30% of prefixes span more than one brand"*). Our own numbers
close it: of the 10,090 proxy families, **3,717 (36.8%) have no member with a `manufacturer` row at all**,
**1,908 (18.9%) have members that disagree**, and only **3,550 (35.2%)** have one value shared by every member
(`sql/fam-c1-sibling-consistency.sql`). A "siblings must share the brand" constraint would reject or
block-save more than half the catalogue.

This **confirms #10778 M9** (*"No cross-brand or cross-line grouping. ⚠️ Advisory only — nothing in the system
enforces it."*) and re-expresses it: it stays advisory until A1/A2 give us a real brand attribute, at which
point it becomes a candidate for a family-level definition under A5-a — and then it is enforced by *storage*
(one value on the family) rather than by comparison.

## 5 · Title: compose — and the real call-site count is nine, not two

⚠️ **Corrected after red-team round 1 (finding 1).** Revision 1 of this file said *"Two call sites are
load-bearing"* and named `order/models.py:556` and `search_indexes.py:34,38,54,55`. That was wrong in both
directions: `order/models.py:556` is a **column declaration**, not code that can snapshot anything, and the
search side reaches a Django **template** that no `prepare_*` method can touch. Re-swept at the pin
(`grep -rn "\.title\b|get_title|populate_from" py/mono --include=*.py --include=*.txt`, tests excluded):

**Google forces two distinct strings.** *"All variants of the same product must have the same item group title
`[item_group_title]`."* and *"Make sure the item group title `[item_group_title]` is different from the title
`[title]` attributes you use for the individual variants in the product group."* (#11013 §2, from
`support.google.com/merchants/answer/17085146`). So even the flattest platform in the set wants a family
string and a member string that are not equal.

**Our data says today's title is the composed string already.** All 43 Indomie titles are distinct, all 43
slugs are distinct, and each title is `INDOMIE <flavour> <grams> GR` — family name plus two axis values.
Across the proxy families, **8,935 of 10,090 (88.6%)** have a distinct title on every member.

### The nine places a composed title forks

| # | Consumer | `path:line` at the pin | Why it forks |
|---|---|---|---|
| 1 | **the search document body — a Django template** | `py/mono/templates/search/indexes/catalogue/product_lite.txt:1` — `{{ product.title }} {{ product.title_staff\|default:"" }} {{ product.upc\|default:"" }}` | `{% include %}`d by `product_text.txt:1`, the line directly above the `:3` this file used to cite. **A `prepare_*` method cannot reach a template.** |
| 2 | **the same partial, six more index types** | `product_text.txt:1` · `price_purchase/pricepurchaserecord_text.txt:2` · `price_purchase/pricepurchase_text.txt:1` · `inventory/inventoryfacility_text.txt:1` · `inventory/inventoryrecord_text.txt:1` · `forecast/forecastproduct_text.txt:1` · `price_sell/pricesell_text.txt:1` | **Seven** templates include the one partial — measured at the pin, `grep -rn "product_lite" py/mono/templates`. One edit reaches all seven; one *missed* edit breaks all seven. |
| 3 | `ProductIndex` title fields | `solvent/search/search_indexes.py:34, 38, 54, 55` — four `model_attr="title"` | `prepare_*` methods |
| 4 | **a fifth title read in the same file** | `solvent/search/search_indexes.py:93-96` — `prepare_autocomplete_staff` returns `f"{obj.upc} {obj.title_staff} {obj.title}"` | not a `model_attr`, so a `model_attr="title"` grep misses it |
| 5 | **a second haystack index, in another app** | `solvent/price/purchase/search_indexes.py:61` (`product_title_staff = KeywordField()`) and `:75-77` — `prepare_product_title_staff` → `(product.title_staff or product.title or "").lower()` | the staff sort key of the price-purchase table |
| 6 | **the actual writer of the order snapshot** | `solvent/order/creator.py:191` — `"title": product.get_title()` | this, not `order/models.py:556`, is what must snapshot the composed string |
| 7 | a third order-side read | `solvent/order/models.py:607` — `title = self.product.title` inside `OrderLine.__str__` | reads the live product, not the snapshot |
| 8 | **the slug, which is derived from the title** | `solvent/catalogue/models.py:405-408` — `slug = AutoSlugField(populate_from="title", unique=True)`; and `:488` — `self.slug = slugify(self.get_title())` in `Product.save()` | §7 assigns the slug to the family; both derivation points read the member's title |
| 9 | the shipping quote | `solvent/third_party_api/biteship/biteship.py:67` — `name=product.title` | sent to a third party |

**The natural composition point, unnamed in revision 1:** `solvent/catalogue/models.py:575-578` `get_title()`
(*"Return a product's title or it's parent's title if it has no title."* — the docstring already anticipates
a parent) and `:580-592` `get_title_for_staff()` / `title_for_staff`.

**Because item 1 is a template, there are only two honest implementations:**
- **(a) a `get_display_title()` on the model** that the template calls (`{{ product.get_display_title }}`) and
  that every `prepare_*` and `creator.py:191` also calls — one method, nine call sites re-pointed; or
- **(b) compose at the column** — keep a denormalised composed string on the member, written on save, which
  is *not* composing at read time and reintroduces the drift pair composition was meant to remove.

Everything else still inherits free: the feed sends `title=product.title.title()`
(`third_party_api/google/content/products_api.py:222`) and the frontend renders
`{{ product.title | titlecase }}`
(`ts/libs/product/detail/ui-core/src/lib/product-detail-ui/product-detail-ui.component.html:60`) — both read
whatever string the API gives them.

**Frontend sweep, instrumented (finding 45).** `grep -rn "product\.title|product\.slug" ts/libs ts/apps
--include=*.ts --include=*.html`, `.spec.ts` and `.stories.ts` excluded → **30 occurrences in 22 files**,
including three ESC/POS label formatters
(`libs/order/util-printer-label-esc-pos-formatter/…` · `libs/order/return/util-printer-label-esc-pos-formatter/…` ·
`libs/printer/label/product/util-zebra-formatter/…`), the HTML label template service and
`libs/analytics/util-core/src/lib/analytics-formatter.service.ts`. **Every one consumes a single API field**,
so all 22 inherit a composed title for free — but the count belongs in the record, not one example.

## 5b · The indexing surface — the fan-out this file missed entirely

⚠️ **Added after red-team round 1 (finding 2).** Three files at the pin, cited nowhere in revision 1, and
they are what C1-ii cannot ship without:

```
solvent/catalogue/receivers.py:31-41   @receiver(post_save, sender=Product, dispatch_uid="product_post_save_update_indexes")
                                       → update_products_indexes(products=[instance])
                                       → update_product_dependent_indexes(product_id=instance.id)
solvent/catalogue/index_utils.py:11-16 update_products_indexes → SearchIndexQueue + GoogleProductIndexQueue
solvent/catalogue/index_utils.py:19-44 update_product_dependent_indexes — walks Django's model registry for
                                       every HasProductDependentSearchIndexModelMixin subclass and re-enqueues
                                       its rows. Docstring: "Those documents are only rewritten when their own
                                       row is saved — and no periodic rebuild is scheduled — so a product edit
                                       would otherwise leave them stale indefinitely."
solvent/catalogue/models_mixins.py:6-31  the mixin. Subclasses at the pin: inventory/models.py:19
                                       (InventoryRecord), inventory/models.py:121 (InventoryFacility),
                                       price/purchase/models.py:36 (PricePurchase) — three models.
solvent/catalogue/receivers.py:44-67   ProductImage post_save/post_delete → update_products_indexes,
                                       guarded by "Only display_order 0 is published".
solvent/catalogue/search_indexes_mixins.py:22-29  AbstractCategorySearchIndexMixin.prepare_category →
                                       main_category.get_ancestors_and_self(); :40-41 the product-FK variant
                                       resolves obj.product.main_category. Used by search/search_indexes.py:21,
                                       inventory/search_indexes.py:12 and :28, price/purchase/search_indexes.py:52.
```

**Why it is load-bearing.** Every reindex trigger in the system is keyed on `post_save` of **`Product`**.
C1-ii moves `description`, the customer-facing `title` and `main_category` onto the family row. **Editing the
family would then reindex nothing** — not the member's own `ProductIndex` document, not the three dependent
document types, not the Google Merchant queue. A new `post_save` receiver on the family row, fanning out to
every member and then through `update_product_dependent_indexes` to every member's dependents, is **required
new work**. So is a family-image trigger, because `receivers.py:44-67` only fires on `ProductImage` rows and
the "member-first, family fallback" rule gives a family image no trigger at all.

**And `prepare_category` has to resolve through the family.** With `main_category` on the group,
`search_indexes_mixins.py:22-29` and `:40-41` both read a column that no longer exists on `Product`; four
index files depend on them.

## 6 · Member URL and the hero — does #10778 C2 survive Lock 2?

C2 says: *"The family has a page, and it is rendered at every variant's own URL with that variant as the hero.
… A bare family URL, if hit, picks a hero via `display_order` (S4)."*

**It survives, and Lock 2 makes it cheaper, not dearer.** The customer route is already keyed on the member:
`shop/product/:productId/:slug` (`product-feature-shell-routing.module.ts:17-21`), built from `product.id` and
`product.slug` at `shared/url_build/solui.py:20` and on the frontend at
`ts/libs/product/ui-link/src/lib/product-link-ui/product-link-ui.directive.ts:39`
(`['/shop/product', product.id, product.slug]`). Under shape B nothing about that route changes — the member
keeps its id and its slug — so **every existing URL keeps working and the feed's `link` keeps resolving**
(`products_api.py:218-221`). That is the third of the field survey's four open items, answered by the route
that already exists.

Two amendments to C2 under shape B:
- **"A bare family URL" has no route today and needs none.** Under shape A the family was a `Product` row and
  therefore had a URL; under shape B it is a different table with no route, so the `display_order` hero pick
  is only needed if we choose to add `/shop/family/:id`. **Judgement:** don't add it. Google requires
  per-variant landing pages in one place — *"Make sure to have different landing page URLs submitted for each
  variant, with each URL using a different path segment and/or query parameters"* (#11031 field survey §C) —
  ⚠️ **but not everywhere**: *"If your website allows customers to select between multiple variants on a
  single landing page … make sure all those versions are submitted with the same item group ID"*
  (`11013.md:379`). Google accommodates both shapes, so the bare family URL is dropped on the cheaper
  argument — the group has no route and needs none — not on a Google requirement.
- **"Which member is primary" is still needed**, for the card thumbnail, the search result row and the feed's
  default — Walmart makes it a hard rule (*"Each variant group must contain exactly one primary variant"*,
  `corpus/walmart/wm-multiple-variants.txt`). S4's mechanism (`display_order` on the membership, primary
  derived as `== 0`, following `ProductImage`'s convention at `catalogue/models.py:802-812`) ports unchanged
  to shape B, where the membership is the member row itself.

⚠️ #10778's own note on S4 stands and matters for the editor: *"`display_order` is a backend convention only
— it does not exist anywhere in `ts/`, image 'primary' is literally `setProductImage(0)` on server array
order, and the admin has no reorder UI."*

## 7 · What merge and split must enforce

| Operation | DB does it | A validator must do it | A human must decide |
|---|---|---|---|
| **Merge** two families | re-point `variant_group_id` (one UPDATE); the composite FK refuses a cross-category merge | axis combinations must stay unique after the merge; every member must fill every axis of the surviving family | which description survives; which title becomes the family title; which member is primary; which images move |
| **Split** a family | re-point `variant_group_id`; create the new group | the losing side must still satisfy "every member fills every axis"; a family that drops to one member must keep its axes or lose them | whether the family-level description/images are copied to both halves or kept by one |
| **Move** a member between families | composite FK refuses if the categories differ | the uniqueness of the destination's combinations | — |
| **Any family-row edit** (title, description, category, images) | nothing — there is no trigger | **a new `post_save` receiver on the family**, fanning out to every member and then through `update_product_dependent_indexes` to every member's dependent documents and the Google queue (§5b) | — |

**The one thing no constraint can catch**: two families that *should* be one. 2,112 distinct normalised titles
are carried by more than one product (4,273 products), every one of them with its own `upc`; **891 of those
title-collisions span more than one category** (`sql/fam-c1-divergence.sql`). Those are the merge screen's
real input, and a quarter of them are cross-category — which the composite FK will refuse, correctly, until
someone fixes the category.

## 8 · Fields that already diverge between would-be siblings, measured

`sql/fam-c1-divergence.sql`, 10,090 proxy families, 2026-09-19:

| Field | Families where members differ | Reading |
|---|---|---|
| `upc` | 10,090 (100%) | by construction — `unique=True` |
| `slug` | 10,090 (100%) | by construction — `unique=True` |
| `title` | 8,935 (88.6%) all-distinct | today's title is already the composed string |
| `is_active` | 1,677 (16.6%) | supports visibility on the member |
| `is_offline_only` | 510 (5.1%) | supports `is_offline_only` on the member (the field survey labels this one "ours", unevidenced) |
| `is_public` | 30 (0.3%) | supports it, weakly |
| `description` | 3,912 (38.8%) all-distinct | against "description at the family" as a *migration*; see §3 |
| `manufacturer` | 1,908 (18.9%) disagree, 3,717 (36.8%) absent | against any enforced brand rule |
| images | 6,002 (59.5%) have ≥1 member with no image; 5,299 (52.5%) have none at all | the member-first/family-fallback rule fires constantly |
