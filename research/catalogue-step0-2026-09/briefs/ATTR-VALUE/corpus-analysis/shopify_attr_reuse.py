#!/usr/bin/env python3
"""ATTR-VALUE A3/A4 measurements over the Shopify Standard Product Taxonomy corpus.

Corpus (fetched by the coordinator, not re-fetched):
  ~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist/{en,id-ID}
  sparse clone of Shopify/product-taxonomy at commit ad206247 (2026-08-27);
  the data files self-report  version = "2026-11-unstable".
Every number printed here is computed from those files only.
"""
import json, collections, os, sys, re

BASE = os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist")
OUT  = os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/briefs/ATTR-VALUE/corpus-analysis")

def load(locale, name):
    p = os.path.join(BASE, locale, name)
    with open(p) as fh:
        return json.load(fh), os.path.getsize(p)

cats_doc, cats_bytes = load("en", "categories.json")
attrs_doc, attrs_bytes = load("en", "attributes.json")
vals_doc, vals_bytes = load("en", "attribute_values.json")

print(f"# corpus files: categories.json {cats_bytes} B · attributes.json {attrs_bytes} B · attribute_values.json {vals_bytes} B")
print(f"# self-reported version: categories={cats_doc['version']} attributes={attrs_doc['version']} values={vals_doc['version']}")

cats = [c for v in cats_doc["verticals"] for c in v["categories"]]
attrs = attrs_doc["attributes"]
vals = vals_doc["values"]

print("\n## 1 · totals")
print(f"verticals                 {len(cats_doc['verticals'])}")
print(f"categories                {len(cats)}")
print(f"attribute definitions     {len(attrs)}")
print(f"attribute values          {len(vals)}")

edges = []            # (category_id, attribute_id, extended, name_on_edge)
for c in cats:
    for a in c["attributes"]:
        edges.append((c["id"], a["id"], a.get("extended"), a["name"], a["handle"]))
print(f"category->attribute edges {len(edges)}")
ext_edges = [e for e in edges if e[2]]
print(f"  edges with extended=true  {len(ext_edges)}")
print(f"  edges with extended=false {len(edges)-len(ext_edges)}")

print("\n## 2 · is the definition ONE object shared by many categories, or a per-category copy?")
by_attr = collections.Counter(e[1] for e in edges)
print(f"distinct attribute ids appearing on at least one category edge  {len(by_attr)}")
print(f"attribute definitions never attached to a category              {len(attrs)-len(by_attr)}")
print(f"mean categories per attached attribute                          {len(edges)/len(by_attr):.2f}")
hist = collections.Counter(by_attr.values())
print("categories-per-attribute histogram (bucketed):")
buckets = [(1,1),(2,2),(3,5),(6,10),(11,25),(26,50),(51,100),(101,500),(501,2000),(2001,99999)]
for lo,hi in buckets:
    n = sum(v for k,v in hist.items() if lo<=k<=hi)
    tot = sum(k*v for k,v in hist.items() if lo<=k<=hi)
    label = f"{lo}" if lo==hi else f"{lo}-{hi}" if hi<99999 else f"{lo}+"
    print(f"  used by {label:>9} categories : {n:5d} attributes  ({tot:7d} edges)")
print(f"attributes used by exactly 1 category : {hist.get(1,0)} ({hist.get(1,0)/len(by_attr)*100:.1f}% of attached)")
print(f"attributes used by >1 category        : {len(by_attr)-hist.get(1,0)} ({(len(by_attr)-hist.get(1,0))/len(by_attr)*100:.1f}%)")

id2name = {a["id"]: a["name"] for a in attrs}
print("\ntop 25 most-reused attribute definitions (categories subscribing):")
for aid, n in by_attr.most_common(25):
    print(f"  {n:6d}  {id2name.get(aid,'?'):45s} {aid}")

print("\n## 3 · the card's example: Flavor")
flavor = [a for a in attrs if re.fullmatch(r"(?i)flavou?r", a["name"])]
for a in flavor:
    n = by_attr.get(a["id"], 0)
    print(f"  '{a['name']}'  {a['id']}  handle={a['handle']}  values={len(a['values'])}  categories subscribing={n}")
    print(f"    description: {a['description']}")
    print(f"    extended_attributes: {[e['name'] for e in a['extended_attributes']]}")
# every attribute whose name contains flavor
flav_like = [a for a in attrs if "flavor" in a["name"].lower() or "flavour" in a["name"].lower()]
print(f"  attribute definitions whose NAME contains 'flavo(u)r': {len(flav_like)}")
for a in sorted(flav_like, key=lambda a: -by_attr.get(a["id"],0)):
    print(f"    {by_attr.get(a['id'],0):5d} cats · {len(a['values']):4d} values · {a['name']}")

if flavor:
    fid = flavor[0]["id"]
    subs = [c for c in cats if any(x["id"]==fid for x in c["attributes"])]
    with open(os.path.join(OUT,"shopify-flavor-categories.txt"),"w") as fh:
        fh.write(f"# categories subscribing to {fid} ('{flavor[0]['name']}') — {len(subs)} of {len(cats)}\n")
        for c in sorted(subs, key=lambda c: c["full_name"]):
            ed = [x for x in c["attributes"] if x["id"]==fid][0]
            fh.write(f"{c['id']}\textended={ed['extended']}\tname_on_edge={ed['name']}\t{c['full_name']}\n")
    print(f"  wrote shopify-flavor-categories.txt ({len(subs)} rows)")
    # top-level verticals covered
    tops = collections.Counter(c["full_name"].split(" > ")[0] for c in subs)
    print("  verticals containing a Flavor subscription:")
    for k,v in tops.most_common():
        print(f"    {v:5d}  {k}")
    # how the edge names it
    edge_names = collections.Counter(x["name"] for c in subs for x in c["attributes"] if x["id"]==fid)
    print(f"  distinct names carried on the Flavor edges: {dict(edge_names)}")

print("\n## 4 · extended attributes — a category-specific NAME over a shared value list")
ext_defs = [a for a in attrs if a.get("extended_attributes")]
print(f"base attributes carrying extended_attributes : {len(ext_defs)}")
print(f"total extended names declared                : {sum(len(a['extended_attributes']) for a in ext_defs)}")
ext_names_on_edges = collections.Counter()
for cid, aid, extended, name, handle in edges:
    if extended:
        ext_names_on_edges[(aid, name, handle)] += 1
print(f"distinct (base attribute id, extended name) pairs seen on edges: {len(ext_names_on_edges)}")
print("sample of 15 extended edges (base id · extended name · #categories):")
for (aid,name,handle),n in ext_names_on_edges.most_common(15):
    print(f"  {n:5d}  {name:38s} handle={handle:38s} base={id2name.get(aid,'?')} ({aid})")

print("\n## 5 · where does the value list live?")
val_ids = set()
dupe_ids = 0
attr_of_value = {}
for a in attrs:
    for v in a["values"]:
        if v["id"] in val_ids:
            dupe_ids += 1
        val_ids.add(v["id"])
        attr_of_value.setdefault(v["id"], []).append(a["id"])
print(f"value ids reachable from attributes.json : {len(val_ids)}")
print(f"value ids appearing under >1 attribute   : {sum(1 for k,v in attr_of_value.items() if len(v)>1)}")
print(f"  (a TaxonomyValue therefore belongs to exactly 1 attribute)" if all(len(v)==1 for v in attr_of_value.values()) else "  (SHARED VALUES EXIST)")
name_counts = collections.Counter(v["name"] for v in vals)
recur = {k:v for k,v in name_counts.items() if v>1}
print(f"distinct value NAMES                     : {len(name_counts)}")
print(f"value names that recur under >1 attribute: {len(recur)}  (covering {sum(recur.values())} value rows)")
print("top 15 recurring value names:")
for k,v in collections.Counter(recur).most_common(15):
    print(f"  {v:5d}  {k!r}")
# handle convention
bad = [v for v in vals[:2000] if "__" not in v["handle"]]
print(f"values (first 2000) whose handle lacks the '<attribute>__<value>' convention: {len(bad)}")
novals = [a for a in attrs if not a["values"]]
print(f"attribute definitions with an EMPTY value list: {len(novals)}")
for a in novals[:20]:
    print(f"    {a['name']} ({a['id']})")
vcount = collections.Counter(len(a["values"]) for a in attrs)
sizes = sorted(len(a["values"]) for a in attrs)
print(f"values per attribute: min {sizes[0]} · median {sizes[len(sizes)//2]} · mean {sum(sizes)/len(sizes):.1f} · max {sizes[-1]}")
print("\ndoes any CATEGORY carry its own value list?  keys present on a category->attribute edge:")
keyset = collections.Counter(tuple(sorted(a.keys())) for c in cats for a in c["attributes"])
for k,v in keyset.most_common():
    print(f"  {v:7d}  {k}")

print("\n## 6 · per-category attribute counts")
counts = [len(c["attributes"]) for c in cats]
counts_sorted = sorted(counts)
print(f"categories with 0 attributes : {sum(1 for x in counts if x==0)} ({sum(1 for x in counts if x==0)/len(counts)*100:.1f}%)")
print(f"attributes per category: min {counts_sorted[0]} · median {counts_sorted[len(counts_sorted)//2]} · mean {sum(counts)/len(counts):.2f} · max {counts_sorted[-1]}")

print("\n## 7 · net content / size / weight / volume attributes")
pat = re.compile(r"(?i)\b(size|volume|weight|capacity|net content|net weight|quantity|dimension|length|width|height|depth|diameter)\b")
hits = [a for a in attrs if pat.search(a["name"])]
print(f"attribute definitions whose NAME matches size|volume|weight|capacity|net content|quantity|dimension|length|width|height|depth|diameter : {len(hits)}")
single = [a for a in hits if by_attr.get(a["id"],0)<=1]
print(f"  of those, subscribed by <=1 category : {len(single)}")
print(f"  of those, subscribed by >1 category  : {len(hits)-len(single)}")
exact_net = [a for a in attrs if "net content" in a["name"].lower() or "net weight" in a["name"].lower()]
print(f"attribute definitions named exactly containing 'net content'/'net weight': {len(exact_net)} {[a['name'] for a in exact_net]}")
print("the 15 most-reused size/weight/volume attributes:")
for a in sorted(hits, key=lambda a: -by_attr.get(a["id"],0))[:15]:
    print(f"  {by_attr.get(a['id'],0):5d} cats · {len(a['values']):4d} values · {a['name']}")
print("sample values of the most-reused 'size'-named attribute, to show they are labels not numbers:")
size_attrs = sorted([a for a in attrs if re.fullmatch(r"(?i)size", a["name"])], key=lambda a: -by_attr.get(a["id"],0))
for a in size_attrs[:3]:
    print(f"  {a['name']} ({a['id']}) cats={by_attr.get(a['id'],0)} values={len(a['values'])}: {[v['name'] for v in a['values']][:25]}")
# any attribute whose values look numeric+unit
unitpat = re.compile(r"^\s*\d+([.,]\d+)?\s*(g|kg|ml|l|oz|lb|fl oz|mg|cm|mm|m|in|ft)\b", re.I)
unitty = []
for a in attrs:
    if not a["values"]: continue
    n = sum(1 for v in a["values"] if unitpat.match(v["name"]))
    if n and n/len(a["values"])>0.5:
        unitty.append((a["name"], n, len(a["values"]), by_attr.get(a["id"],0)))
print(f"attributes where >50% of values are a literal 'number + unit' label: {len(unitty)}")
for t in sorted(unitty, key=lambda t:-t[3])[:20]:
    print(f"  {t[3]:5d} cats · {t[1]}/{t[2]} numeric-unit values · {t[0]}")

print("\n## 8 · food branch, the card's Rasa example (en + id-ID)")
food = [c for c in cats if c["full_name"].startswith("Food, Beverages & Tobacco")]
print(f"categories under 'Food, Beverages & Tobacco': {len(food)}")
fc = collections.Counter()
for c in food:
    for a in c["attributes"]:
        fc[a["name"]] += 1
print("top 20 attribute names in the food vertical:")
for k,v in fc.most_common(20):
    print(f"  {v:5d}  {k}")
