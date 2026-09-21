# design-C2 — count-as-axis vs separate product, on our real rows and the real feed

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`; frontend `/home/irvan/copilot/ts-layer2` @ `82187a17bd`.

## 0 · The question is three questions, and GS1 already separates them

The GTIN Management Standard, footer *"Release 1.1, Ratified, Sep 2023 · © 2023 GS1 AISBL"*
(`corpus/gs1/GS1_GTIN_Management_Standard.pdf`, 381,277 B; text extract `…​.txt`, 51,967 B) gives three
different rules to three things our single word "pack" covers. ⚠️ **Provenance: P1, not P0** — the copy is
`gs1id.org`'s redistribution of the AISBL document; `www.gs1.org/docs/idkeys/GS1_GTIN_Management_Standard.pdf`
returns 404 and sixteen GS1 hosts were tried (`corpus/gs1/attempts_task1.log`). No byte-comparison against a
P0 copy was possible (`sources-new.md` O-6). All three quoted to the end of the clause:

| Thing | GS1 rule | What GS1 says | Level of the new GTIN | Consumer expected to distinguish it? |
|---|---|---|---|---|
| a consumer multipack — 6 identical sachets in one bag, bought and scanned once | **§2.3 Declared net content** | *"Any change (increase or decrease) to the legally-required declared net content that is printed on the pack, requires assignment of a new GTIN."* Examples include *"The declared count of the number of razors in a package changes from 4 to 6."* and *"a 4 pack (count) of lip balm is increased and is declared as a 6 pack (count) bonus pack."* | **the retail consumer trade item / base unit level** — the *same* level as the single | **YES** — §2.3's guiding-principles row reads `Declared net content · YES · YES · YES` |
| a case / carton / *dus* — the shipping unit | **§2.8 Pack/case quantity** | *"A change to the number of trade items in a case or a change to the quantity of cases in a predefined pallet configuration, requires assignment of a new GTIN."* Example: *"A case configuration changes from containing 8 trade items to containing 12 trade items, the case needs to be uniquely identified."* | **higher level packaging only** — the table reads `GTIN change for retail consumer trade item/base unit? **N/A**` | **NO** — *"Is a consumer and/or trading partner expected to distinguish the changed or new product from previous/current products?"* → **NO** |
| a banded pack / bundle — two *different* products taped together | **§2.9 Predefined assortment** | *"A predefined assortment is a type of physical trade item assortment/bundle that comprises a fixed composition of two or more trade items that are combined and sold together as a single physical trade item."* · *"The individual trade items included in the assortment are explicitly defined by the trading partners and carry their own, unique GTIN separate from the GTIN assigned to the assortment."* | the retail consumer trade item level **and** every higher level | **YES** |

And the per-variant rule that C1 leans on comes from the same file, §2.1: *"A new jeanswear line includes
various sizes of a particular style and colour of jeans (30x30, 30x32, 32x30, 32x32, etc.). Each style,
colour and size variation is considered a unique product and is assigned a unique GTIN."*

**Read together:** a consumer 6-pack is a sibling-shaped thing (same hierarchy level as the single, differing
in one declared fact); a carton is *not* (different hierarchy level, and the consumer is explicitly not
expected to distinguish it); a banded pack is a third thing (its own trade item, whose components keep their
own GTINs).

## 1 · The three design options, against our models

### C2-a · count is an axis — the 6-pack is a sibling of the single

**Schema:** nothing new. `count`/`isi` becomes a `ProductAttribute` on the relevant `Category` after Lock 1,
flagged axis-eligible (D4), and the family's dimension list carries it. The pack row keeps its own `upc`,
its own `PriceSell`, its own `InventoryFacility` — all of which it already has.

**What it buys:** the customer sees "Isi 1 · Isi 6" on one page instead of two search results.

**What it costs, measured.** `sql/fam-c2-pack.sql` + `sql/fam-c2-pack-detail.sql`, 2026-09-19:

| Token kind (baseline's regexes, verbatim) | Rows | With a plausible single in the same category | Active online |
|---|---|---|---|
| `ISI N` | 3,521 | **697 (19.8%)** | 2,030 |
| `N x M` **followed by a unit** (`12 X 330 GR`) | 112 | 30 | 53 |
| `N x M` with **no** unit | 2,033 | 45 | 94 |
| pack word only (`DUS`, `BOX`, `PAK`, `RENTENG`…) | 1,268 | 119 | 395 |
| **any pack token** | **6,934** | 891 (12.8%) | 2,572 |

**⚠️ A correction to the baseline.** `sql/results/baseline.json` reports *"titles with multiplier 'N x M' =
2,168"*. Of those, **2,055 carry no unit after the multiplier**, and the sampled titles show what they are:
`KASA HYDROPHYL PARAMITA 16X16CM` · `UNI PAD FOR PET 60X90 CM` · `POTENTATE HAND BOOK 110X172MM` ·
`SALONPAS KOYO 5X2LBR` — **dimensions and sheet counts, not multipacks**; 643 of the pack-token rows sit in
category 1568 `SPREI` (bedsheets), where `180 X 200` is a bed size. Likewise the 1,583 "pack word" rows are
led by `BOX` used as the *container form* of milk powder — `SGM EKSPLOR 1+ VANILA BOX 900 GR`. The honest
multipack population is **`ISI N` + `N x M`-with-unit = 3,633 rows (3.4% of 106,161)**, of which **727 (20%)**
have a plausible single in the same category.

**So C2-a's real cost is the 80%.** Making count an axis creates ~2,900 families whose count axis has exactly
one value — a picker with one option, on rows that are in no sense a variant of anything we stock. Under Lock 2
those are families of one anyway, so nothing breaks; but the axis buys nothing for four rows in five.

### C2-b · count is a separate product; form is an axis

This is the card's reading of Amazon. **It is not what Amazon does.** Amazon has *both* mechanisms and they
are not alternatives:

- `ItemRelationship.type` is an enum of exactly **two** values (#10976 §1.8, from the Catalog Items and
  Listings Items schemas): `VARIATION` — *"The Amazon catalog item in the request is a variation parent or
  variation child of the related items that are identified by ASIN."* — and `PACKAGE_HIERARCHY` — *"The Amazon
  catalog item in the request is a package container or is contained by the related items that are identified
  by ASIN."*
- **And** count is a legal variation theme component. `variation_theme = SIZE/COLOR/NUMBER_OF_ITEMS` is
  Amazon's own worked example (#10976 §2, `[E-14]`): *"if you set the `variation_theme` to
  `SIZE/COLOR/NUMBER_OF_ITEMS`, then `shirt_size`, `color`, and `number_of_items` become mandatory."* The
  legacy→JSON theme map carries `count` → `ITEM_PACKAGE_QUANTITY` (#10976 §2, `[E-9]`), and the `Health`
  product type's theme list is `Color · Count · SizeName · SizeName-ColorName`.

Walmart is the same: **count is on the axis list**, and the bundle is a different mechanism.
`corpus/walmart/wm-multiple-variants.txt` (developer.walmart.com, fetched 2026-09-19), *"Supported variant
attributes"*: *"Supported variant attributes **vary by product type and item specification version**."*, then
the "Common variant attributes include" list whole: `Color · Size · Pattern · Character · Count · Count per
pack · Multipack quantity · Theme`. Second, independent route: the `MP_ITEM` spec, instrumented over the
451,013,258-byte file (#11046 §1.4) — **6,957 product types each carrying their own
`variantAttributeNames.items.enum`, 2,323 distinct axis names across them, enum size min/max/mean
1 / 2,323 / 11.75**; `Toothpastes` allows 9
(`["character","character_group","count","countPerPack","flavor","form","multipackQuantity","pieceCount","size"]`),
`Tires` allows 18, and *"they intersect only in `count`, `countPerPack`, `multipackQuantity`"*.
⚠️ Revision 1 of this file printed the 9-name array
`["assembledProductWidth","color","count","countPerPack","multipackQuantity","paperSize","pattern","shape","size"]`
as "the spec's"; it is the **`Sticky Notes`** worked instance (`11046.md:210`) — red-team finding 19.
⚠️ `11046.md:501` also records ten food product types (`Apples`, `Avocados`, `Bananas`, `Fresh Herbs`,
`Grapes`, `Mushrooms`, `Onions`, `Packaged Salads`, `Pears`, `Watermelons`) with **no variant mechanism at
all** — on those, count cannot be an axis because nothing can.
Separately, Walmart's **Virtual Pack** is not variant grouping at all: *"Use the `bundleType=VIRTUALPACK`
query parameter together with the component item's `gtin` to retrieve virtual pack information."* (#11046),
and the one priced container schema *"contains **0** occurrences of `variantGroupId`, `variantAttributeNames`,
`isPrimaryVariant` and `swatchImages`"*.

Google is the third data point and it goes the other way: `[multipack]` is an **ordinary product attribute**,
not a variant attribute — *"Integer"*, example `6`, *"Required (For multipack products in Australia, Brazil,
Czechia, France, Germany, Italy, Japan, Netherlands, Spain, Switzerland, the UK and the US)"* — and
`[is_bundle]` is a boolean with the same country list (#11013, attributes 44 and 32). **Indonesia is in
neither list**, so both are optional for our feed.

### The fourth pack/bundle mechanism revision 1 excluded — Shopee's kit item

⚠️ Added after red-team round 1 (finding 4). `11047.md` **§1.7** carries a full kit-item model:
`add_kit_item` (2242, 34,798 B, 49 request field paths) · `update_kit_item` (2247, 36,225 B, 51) ·
`get_kit_item_info` (2248), with
`item_setting.model_list[] { tier_index, model_sku, original_price, component_list[] {component_item_id,
component_model_id, quantity, main_component} }` and its own free-text
`item_setting.tier_variation_list[] { name, option_list[] { option, image{image_id} } }`. Instrument in the
record: `standardise` · `variation_id` · `get_variations` → **0 · 0 · 0** across all three kit records, and
`"tier_variation_list":` appears 5× in 2242 and 5× in 2247 and **nowhere else** in the 92-record corpus
(§5 #21).

**The record's ruling, whole**: *"⚠️ **Revision 1 disposed of kit items in five words — "= composed bundle
listing".** By this document's own §2 definition — a row that owns axes and whose members carry `tier_index`
and their own price and SKU — **a kit item is a variant family the standardisation has not reached**
[R-27][R-28]. Its axis shape is the legacy free-text form under a different name."*

**What it does and does not say.** It says the kit **has its own axes** — the bundle may be sold in several
forms. It does **not** say the kit is a sibling of its components: those hang off `component_list[]`, a
containment edge, exactly like Amazon's `PACKAGE_HIERARCHY`. So the design line in §3 below stands, restated:
*no family link to the components; the bundle may itself be a family.*

### C2-c · both are separate products, no family link

**Schema:** nothing. Under Lock 2 they are simply two families of one.

**What it costs:** the customer who searches "Indomie Goreng" gets the single and the 6-pack as two results
with no relationship. That is today, and it is the drift problem Lock 2 exists to fix — but only where the
two really are the same thing to the shopper.

## 2 · The line that actually separates them, in our own model

We already have a place for the case that is *not* a catalogue row:

```
ProductMeta                      catalogue/models.py:895
  quantity_purchasing_allowed_multiples :905   "Purchasing for this product is allowed in multiples of this."
  quantity_per_box                      :910   "How many products per box from supplier?"
```

The field survey labels `ProductMeta` "member, ours" with exactly this reasoning: *"`quantity_purchasing_
allowed_multiples` and `quantity_per_box` describe a pack: a carton holds 24 singles or 12 large bottles,
never '24 of the family'."*

So the line is operational, not taxonomic, and it matches GS1's hierarchy-level split:

> **If it is scanned at the till and stocked as its own unit, it is a member with its own `upc`. If it exists
> only so purchasing can order by the carton, it is `ProductMeta.quantity_per_box` and it is not a product.**

Our own titles already carry the carton count as staff metadata rather than as a product: every Indomie
`title_staff` ends in `(40)` or `(24)` or `(20)` — `INDOMIE AYAM BAWANG 69 GR (40)` — which is the case
quantity, recorded in a string, on the single's row (`sql/results/indomie.csv`).

## 3 · #11126's banded pack under this line

#11126 ruled: *"the actual case for this one will be registered as a **single SKU**, cause the banded products
will have their own barcode to be scanned at the cashier till … **There's no assembling component. The banded
is already banded on arrival.**"* GS1 §2.9 says the same thing structurally — the assortment is its own trade
item, and *"The individual trade items included in the assortment are explicitly defined by the trading
partners and carry their own, unique GTIN separate from the GTIN assigned to the assortment."*

**It is a separate product with no family link to its components**, and the reason is C1's rule, not a
special case (⚠️ #11126 itself decides nothing about family membership — its Links line reads *"variant
families #10778 (**not** the home for this)"*, `11126.md:69`): a banded
pack of kecap + a free sachet differs from the plain kecap in *two* things at once (it contains a second,
different product), so there is no single axis value that names the difference. A family whose members differ
in more than their axis values is not a family.

**This re-expresses #10778 M4 rather than confirming it.** M4 says *"A same-product banded or promo pack is an
ordinary dimension value — Bango Ukuran `135 ml · 275 ml · 500 ml · 2×500 ml (BOGO)`. Which axis it lands on is
staff judgment."* That holds for `2×500 ml` — two of the **same** product, i.e. a consumer multipack under GS1
§2.3, count-as-axis. It does **not** hold for #11126's Bango-plus-sachet, which is §2.9's predefined
assortment. M4's own example is the same-product case; #11126's is not. Both statements are right about
different objects, and nothing on the record currently says so.

## 4 · What the feed does today, and what each option does to it

`third_party_api/google/content/products_api.py` at the pin emits exactly eight attributes per row:

```
:214-224  ProductAttributes(availability, condition, description=strip_tags(product.description),
                            link=solui_url_build(PRODUCT_DETAIL, {product_id, product_slug}),
                            title=product.title.title(), price=…)
:230-232  sale_price, when a promo line is active
:234-235  image_link, when the product has a display_order=0 image
:237-242  ProductInput(content_language="id", feed_label="ID", offer_id=str(product.id), …)
```

**`grep -rn "item_group_id|itemGroupId" py/mono/solvent` → 0 hits.** There is no grouping in the feed at all
today, and no `gtin`, no `brand`, no `multipack`, no `is_bundle`.

| Option | Feed consequence |
|---|---|
| **C2-a** count is an axis | the pack and the single share an `item_group_id`. Google then applies its variant rules to the pair: same `item_group_title`, *different* `title`, and **different landing-page URLs** (#11031 §C) — all of which our member-keyed route already satisfies (`solui.py:20`). Emitting `[multipack]` becomes correct-but-optional (Indonesia is not in Google's required-country list). |
| **C2-b / C2-c** separate products | no `item_group_id` between them. Google's own guidance pushes the other way for identical-GTIN cases — *"This issue (Duplicate value: GTIN) also occurs when you submit the same GTIN value for products that should be grouped together using the item group ID"* (#11013 §2, `[F-50]`) — but our pack and single always have **different** GTINs, so the diagnostic never fires. No feed change either way. |

Note the one thing that is **not** free under C2-a: the feed currently suppresses nothing, and the lock's
stated rule is that the exporter *"forbids the group id on a product that is not a variant — so the exporter
emits members and suppresses the id for single-member families."* With 3,633 multipack rows of which ~2,900
have no single, that suppression branch is the common path, not the rare one.

## 5 · C2 ↔ A2: what this depends on

Pack form as an axis is only expressible if a variant dimension **is** an attribute (A2 = option a, the
"one object with a role flag" shape that D3 closed on 2026-08-13). If ATTR-DEF reopens D3 and an axis becomes
its own object, "count" becomes an axis-object name rather than an attribute, and C2-a is unaffected in
substance — the count still distinguishes two sellable rows — but the storage moves. **This card decides
whether count *may* be an axis, not what an axis is.** ATTR-DEF's A2 verdict owns the latter.
