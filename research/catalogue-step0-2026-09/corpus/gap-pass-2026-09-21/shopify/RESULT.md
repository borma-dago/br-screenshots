# Shopify — the taxonomy attribute shape, live from the Admin API · gap pass 2026-09-21

**Route.** #11068 §2.2: Admin GraphQL on the empty dev store, served version header `x-shopify-api-version: 2026-07`
(`last-headers.txt`). Read-only queries: `taxonomy.categories(search:…)` with `attributes { __typename … }` and
`__type` introspection. Tier P0 (vendor API, live), one route. Files: `introspect-taxonomy-types.json`,
`taxonomy-{pasta-noodles,chocolate,snack-foods,soda,coffee,condiments}.json` (16 categories: 11 food, 5 kitchen/pet
noise from the search).

**Types, introspected (2026-07):**
- `TaxonomyCategory { id: ID!, name, fullName, level: Int, isRoot/isLeaf/isArchived: Boolean, parentId, ancestorIds, childrenIds, attributes: TaxonomyCategoryAttributeConnection }` — 11 fields, matches #11011 §1.7.
- `TaxonomyChoiceListAttribute { id: ID!, name: String!, values: TaxonomyValueConnection }` · `TaxonomyValue { id: ID!, name: String! }`.
- `TaxonomyMeasurementAttribute { id: ID!, name: String!, options: [Attribute!]! }` · `Attribute { key: String!, value: String }` — the measurement attribute's options are bare key/value strings.

**What was measured.** 16 categories → **99 choice-list attributes, 0 measurement attributes** (food nodes: Pasta &
Noodles, Chocolate, Chocolate Gift Boxes, Snack Foods, Snack Cakes, Soda, Coffee, Coffee Cakes, Condiments & Sauces).
Every food attribute is a **closed choice list of `{id, name}` rows**; no free-text, no number, no unit anywhere.

| attribute id | name | values | on which of the 9 food nodes |
|---|---|---|---|
| 1451 | Allergen information | 16 | all 9 |
| 1452 | Dietary preferences | 28 | all 9 |
| 2364 | Country | 60 | 8 |
| 7962 | Storage requirements | 6 | 7 |
| **1458** | **Flavor** | **30 — the same 30 ids and names on every node that carries it** (Almond, Apple, Banana, Blueberry, Caramel, Cherry, Chocolate, Cinnamon, …) | Chocolate, Chocolate Gift Boxes, Snack Foods, Snack Cakes, Soda, Coffee, Coffee Cakes (7) — **not** on Pasta & Noodles or Condiments |
| 1978 | Food product form | 11 (Dried, Fresh, Frozen, Granules, Ground, Powder, Preserved, …) | Pasta & Noodles, Snack Foods |
| 1456 | Package type | 27 (Bag, Bottle, Box, Can, Canister, Case, Dispenser, Flip-top, …) | Soda |
| 1498 | Pasta type | 37 | Pasta & Noodles |
| 3412 | Chocolate type | 4 | Chocolate ×2 |
| 1480 | Soda variety | 8 | Soda |
| 1477 / 1977 / 3415 / 7698 / 7699 / 7700 | Coffee roast / product form / Caffeine content / bean species / beverage variety / processing method | 6 / 3 / 4 / 6 / 11 / 8 | Coffee |
| 1485 | Heat level | 6 | Condiments & Sauces |
| 3098 | Dietary supplements | 28 | Soda, Coffee |

**What it settles.**
- **A3:** the global type is real and live — `Flavor` is one gid (`…/1458`) with one 30-value list wherever it is subscribed; there is no per-category value list (option (c)) anywhere in this sample. Pasta & Noodles carries no Flavor at all (Shopify's per-category *membership* is the mechanism, not visibility — matches A0 V2).
- **A4:** a taxonomy value is a **row with an id** (`TaxonomyValue {id, name}`), never a string; **0 measurement attributes** on any food node sampled, and the measurement type's `options` are bare `{key, value: String}` — so even the typed shape carries no unit field. Consistent with TREE's "no net-content attribute" and A4's "measurement type exists, 0 instances met".
- **C2:** `Package type` (1456: Bag, Bottle, Box, Can, …) exists as a choice list on Soda — pack *form* is a taxonomy attribute; pack *count* is not (no count/pack-quantity attribute on any sampled node).
- **B3:** attributes per food node here: 5–11 (Coffee 11, Pasta 6, Chocolate 6, Snack Foods 5) — in line with the corpus median of 6.

**Not settled.** Whether any node in the whole taxonomy carries a `TaxonomyMeasurementAttribute` (this sample: 0 of 16; corpus pass: 0 of 383); the Plus-only limits; the linked-metafield write path was not exercised again (Rev-5 E13 stands as the one observation).
