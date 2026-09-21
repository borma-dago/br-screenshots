# Design sketch · the Step-1 fork — and in particular option (c)

*Added after red-team round 2 (SERIOUS 7): option (c) was introduced in revision 2 and recommended without a
design sketch, although BRIEF §3.5 and §4 §6 require one per option the platforms split on.*

Pins: backend `/home/irvan/copilot/py-5` @ `4f99dc01c6`, frontend `/home/irvan/copilot/ts-layer2` @
`82187a17bd`. Numbers: snapshot 2026-09-19 (SQL bounded per BRIEF §3.4).

## 0 · The three options, as objects

| | (a) Keep authoring | (b) Adopt | **(c) Keep + map** |
|---|---|---|---|
| The tree of record | ours (`catalogue_category`, 1,892 rows) | Shopify's 14,606 | ours |
| What a product points at | `main_category_id` → our node | a Shopify node id | `main_category_id` → our node |
| Where a Shopify id lives | nowhere | it *is* the category | one nullable column on `Category` |
| Who maintains the correspondence | n/a | n/a by construction | **us, forever** |

## 1 · Option (c), concretely

```python
class Category(MP_Node):
    ...
    # 0..1. Null means "not mapped yet" — which is the state of ~74% of used nodes on day one.
    shopify_taxonomy_id: str | None = models.CharField(
        max_length=64, blank=True, null=True, db_index=True
    )   # e.g. "gid://shopify/TaxonomyCategory/fb-2-14"
```

That is the whole schema change. Everything else is process:

| Surface | What (c) needs |
|---|---|
| staff editing | a field on the category form (`ts/libs/category/action/ui-form/.../category-form-ui.component.ts`, which today has six fields) and a way to search the 14,606 by name — i.e. a second picker |
| validation | none at the DB level; the id is opaque to us. A periodic job that flags ids absent from the current release is the realistic guard |
| the feed / channel that wants it | a lookup at write time; no change to `main_category` |
| **the mapping itself** | **1,686 nodes to map. 434 (25.7%) resolve mechanically today and ~a quarter to a third of those are wrong (`node-attribute-need.md` §2.1). 1,252 do not resolve at all.** |
| re-mapping on release | Shopify ships **5,754** of its own version-migration rules for `2022-02 → 2026-11` and friends — i.e. the vendor itself treats re-mapping as a standing cost. Ours is not published by anyone |
| `dist/` retirement | the artifact we measured is removed **2026-10-31**; (c) has to track release assets from the start |

## 2 · The honest comparison

**(c) does not avoid the mapping. It avoids everything else.**

| Cost | (a) | (b) | (c) |
|---|---|---|---|
| map 1,686 nodes onto Shopify | — | **yes** | **yes, identical** |
| re-home 106,161 products | — | yes | — |
| re-key the six things on `Category` (`TREE.md` fork §4), one of them on `full_code` | — | yes | — |
| rewrite every category ES document | — | yes | — |
| lose the ability to add `Batik`, `Mukena`, `Sambal`, `Kapur barus` | — | yes | — |
| author our own schema (D15/D16) | yes | — | yes |
| maintain a correspondence across vendor releases | — | — | **yes** |

So (c) is *(a) plus a mapping column plus the mapping work*. It is worth paying only if something actually
consumes the Shopify id. **Today nothing does**: the Google Merchant feed builder never touches category —
`google_product_category|product_type|googleProductCategory` returns **0 hits** across
`py/mono/solvent/third_party_api/google/`, and `_get_product_input`
(`third_party_api/google/content/products_api.py:188`) builds the payload without it.

**Judgement:** (c) is the right *shape* for a future channel obligation and the wrong thing to start now. The
recommendation is therefore **(a) today, with (c) as the named migration path** — and the trigger for (c) is
a channel that demands a standard taxonomy id, not a general wish to be aligned.

## 3 · What (c) forces in steps 1–5

- **Step 1** — an owner for the mapping, and a decision on which release channel we pin
  (`stable` vs `unstable` release assets; `dist/` is gone after 2026-10-31). Also: whether an unmapped node
  is an error state or a normal one. On day one 1,252 of 1,686 used nodes are unmapped, so it must be normal.
- **Step 1 (schema editor)** — unchanged. (c) does not touch D15/D16; we still author our own schema, which
  is why (c) does not relieve the B3/B4 decision at all.
- **Step 5** — the feed key work gains a second opaque external id to keep stable. The same immutability
  argument that applies to Google's `item_group_id` applies here: a Shopify node id must not be re-derived.
- **Not in scope of (c):** the attribute *vocabulary* proposal (fork §7, #10778 V1). That is copying MIT
  data into our own catalogue and needs no mapping column and no node correspondence — it is independent of
  (a)/(b)/(c) and can be done under any of them.
