# Google Merchant Center — U9 "must non-axis attributes match across an item group?" · gap pass 2026-09-21

**Doc route (run).** `support.google.com/merchants/answer/6324507` (item_group_id), fetched 2026-09-21, 1,664,823 B
HTML → `item_group_id.txt`. Vendor text, whole, on what must match: *"Use the same value for the item group ID
[item_group_id] attribute for all variants of the same product."* · *"Make sure the item group title [item_group_title]
is the same for all variants with the same item group ID."* · *"Don’t submit variants without variant attributes."*
No sentence on `description`, `brand`, `gtin` or `google_product_category` having to match — **#11013 §4 U9 "not
stated anywhere retrieved" stands on a second read of the primary page.** The page also carries both halves of the
landing-page tension on one page: *"Align grouping with your landing page experience: If your website allows customers
to select between multiple variants on a single landing page … make sure all those versions are submitted with the
same item group ID"* (requirements) and *"Make sure to have different landing page URLs submitted for each variant …
"/t-shirt/green" or "/t-shirt?color=green&size=small""* (best practices) — so the Meta-vs-Google contradiction FAMILY C1
records is a requirements-vs-best-practices split inside Google's own page, not a flat contradiction.

**Live route (NOT run).** Two grouped variants with divergent `brand`/`description` on the staging research data
source `10721231878` would, as before, insert with HTTP 200 and `itemLevelIssues: 0` — non-discriminating until
**H3** (enable a program/destination on the research source so Merchant Center emits `itemLevelIssues`) is decided by
the maintainer (#11068 §7, #11013 H3). Re-running the insert half without H3 repeats 11013.md:925 and settles
nothing; deliberately skipped. Route once H3 is granted: #11068 §2.3 (impersonation token), insert two products with
one `item_group_id`, `brand` A vs B, wait for processing, `GET …/products/<id>` and read `itemLevelIssues`.
