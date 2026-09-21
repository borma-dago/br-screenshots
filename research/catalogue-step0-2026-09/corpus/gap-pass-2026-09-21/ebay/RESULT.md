# eBay sandbox — does a count-shaped aspect pivot in grocery leaves? · gap pass 2026-09-21

**Route.** Commerce Taxonomy API v1, sandbox (`api.sandbox.ebay.com`), application (client-credentials)
token minted per #11068 §2.5, tree `0` version `134` (`default-tree.json`, 2026-09-21).
`get_category_subtree?category_id=14308` (Food & Beverages: 122 leaves, `subtree-14308-food.json`, 36,782 B),
then `get_item_aspects_for_category?category_id=<leaf>` on 12 grocery leaves (`aspects-<id>.json`,
122–127 KB each, HTTP 200). Tier: P0 (vendor API, live), one route; the sandbox tree is the record's own
caveat (#11045 §1.2: production tree not fetched).

**Answer: YES — on 12 of 12 grocery leaves sampled, `Number in Pack` is `aspectEnabledForVariations: true`.**
`Unit Quantity` is `false` on 12 of 12 (and `aspectApplicableTo: ["ITEM"]`). `Number of Servings` is
`true` on 6 of 12. `Packaging` is `true` on Chips and Cookies & Biscuits, `false` on Instant Coffee.

| leaf | name | aspects | variation-enabled | Number in Pack | Unit Quantity | Flavor |
|---|---|---|---|---|---|---|
| 257998 | Prepared Food & Ready Meals > Noodles | 24 | 9 | **true** | false | true (5 values: Beef, Chicken, Chili, Curry, Seafood) |
| 257993 | Pantry > Pasta, Grains & Cereals > Pasta & Noodles | 24 | 6 | **true** | false | *no Flavor aspect on this leaf* |
| 179179 | Snacks > Chips | 26 | 14 | **true** | false | true |
| 179188 | Non-Alcoholic Drinks > Soft Drinks | 25 | 11 | **true** | false | true |
| 185038 | Coffee > Instant Coffee | 26 | 11 | **true** | false | true |
| 20473 | Sweets & Chocolate > Cookies & Biscuits | 27 | 14 | **true** | false | true |
| 258021 | Sweets & Chocolate > Chocolate Blocks | 27 | 9 | **true** | false | true |
| 257964 | Condiments & Sauces > Cooking Sauces | 24 | 7 | **true** | false | true |
| 48318 | Non-Alcoholic Drinks > Water | 25 | 9 | **true** | false | true |
| 38181 | Non-Alcoholic Drinks > Tea & Infusions | 24 | 13 | **true** | false | true |
| 179176 | Juices, Milkshakes & Smoothies | 25 | 9 | **true** | false | true |
| 258012 | Snacks > Nuts, Seeds & Mixes | 25 | 10 | **true** | false | true |

**Verbatim constraint records, leaf 257998 (Noodles):**

```
Number in Pack   {"aspectDataType":"STRING","itemToAspectCardinality":"SINGLE","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"OPTIONAL","aspectEnabledForVariations":true}   aspectValues: []
Unit Quantity    {"aspectDataType":"STRING","itemToAspectCardinality":"SINGLE","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"OPTIONAL","aspectEnabledForVariations":false,"aspectApplicableTo":["ITEM"]}   aspectValues: []
Item Weight      {"aspectDataType":"STRING","itemToAspectCardinality":"SINGLE","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"OPTIONAL","aspectEnabledForVariations":true}   aspectValues: 9 ["100 g","1 kg","250 g","2 kg","300 g","30 g","500 g","540 g","5 g"]
Flavor           {"aspectDataType":"STRING","itemToAspectCardinality":"MULTI","aspectMode":"FREE_TEXT","aspectRequired":false,"aspectUsage":"OPTIONAL","aspectEnabledForVariations":true,"aspectApplicableTo":["PRODUCT"]}   aspectValues: 5 ["Beef","Chicken","Chili","Curry","Seafood"]
```

**What it settles.** FAMILY C2's "not collected" row for eBay (sources-new.md O-5) closes: eBay lets a
grocery seller pivot a listing on `Number in Pack` — count as an axis — while `Unit Quantity` (the per-unit
size fact) is item-level and not pivotable. Both are `FREE_TEXT` `STRING` with no suggested values; the
count is a bare label. `Item Weight` pivots too, with suggested values that are label+unit strings
(`"250 g"`), never a typed quantity — consistent with the A4 D9 row for eBay ("typed on the constraint, no
physical unit; every value is a string").

**What it does not settle.** Whether the production tree carries the same flags (sandbox only, as before);
whether eBay *policies* a pack listing's price-per-unit; the `aspectUsage`-vs-`aspectRequired` contradiction
is untouched (all sampled aspects `OPTIONAL`).

Files: `default-tree.json`, `subtree-14308-food.json`, `aspects-{257998,257993,179179,179188,185038,20473,258021,257964,48318,38181,179176,258012}.json`. No credential is stored in this directory.
