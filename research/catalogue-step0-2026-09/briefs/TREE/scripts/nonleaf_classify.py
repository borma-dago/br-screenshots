#!/usr/bin/env python3
"""B2 — classify the 292 used non-leaf nodes.

Inputs (both from BigQuery, snapshot 2026-09-19, see sql/):
  sql/results/nodes-full.csv      every category node, ancestry resolved, direct + subtree counts
  sql/results/products-titles.csv every current product with main_category_id and title

Two mechanical signals per node, then hand review on top of them (see nonleaf-classification.md):
  child_name_hit  share of the node's OWN products whose title contains a distinctive word from
                  one of its children's names -> a named child already exists for that product
  nearest_child   leave-one-out nearest-class test over title tokens: each of the node's own
                  products is scored against (a) each child's subtree title corpus and (b) the
                  node's own residual corpus. Share of products whose best class is a child.
"""
import csv, collections, math, re, json, sys

BASE = "/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
STOP = set("""DAN DLL LAIN LAINNYA LAINYA ALAT ALAT2 UNTUK DARI YANG PER PCS PCK PAK SET ISI
GR GRAM KG ML LTR LITER CM MM PACK BOX BTL BKS SACHET SCT RENCENG PRODUK ITEM BARANG NON ANEKA
JENIS TYPE TIPE UKURAN WARNA NEW OLD BIG SMALL MINI JUMBO SUPER EXTRA PLUS""".split())
TOKEN = re.compile(r"[A-Z0-9]+")

def tokens(s):
    out = []
    for t in TOKEN.findall(s.upper()):
        if len(t) < 3: continue
        if t.isdigit(): continue
        if re.fullmatch(r"\d+[A-Z]{1,3}", t): continue
        if t in STOP: continue
        out.append(t)
    return out

nodes = {r["id"]: r for r in csv.DictReader(open(f"{BASE}/sql/results/nodes-full.csv"))}
for r in nodes.values():
    r["depth"] = int(r["depth"]); r["products"] = int(r["products"])
    r["products_subtree"] = int(r["products_subtree"]); r["numchild"] = int(r["numchild"])
children = collections.defaultdict(list)
for r in nodes.values():
    if r["parent_id"]:
        children[r["parent_id"]].append(r["id"])

prod_by_cat = collections.defaultdict(list)
for r in csv.DictReader(open(f"{BASE}/sql/results/products-titles.csv")):
    prod_by_cat[r["main_category_id"]].append(r)

def subtree_ids(cid):
    out = [cid]; stack = list(children[cid])
    while stack:
        x = stack.pop(); out.append(x); stack.extend(children[x])
    return out

def subtree_titles(cid, exclude_self=False):
    ids = subtree_ids(cid)
    if exclude_self: ids = [i for i in ids if i != cid]
    return [p["title"] for i in ids for p in prod_by_cat.get(i, [])]

# document frequency over the whole catalogue, for idf
df = collections.Counter()
for ps in prod_by_cat.values():
    for p in ps:
        for t in set(tokens(p["title"])): df[t] += 1
N = sum(len(v) for v in prod_by_cat.values())
def idf(t): return math.log(N / (1 + df[t]))

used_nonleaf = [r for r in nodes.values() if r["numchild"] > 0 and r["products"] > 0]
used_nonleaf.sort(key=lambda r: -r["products"])

rows = []
for r in used_nonleaf:
    cid = r["id"]
    own = prod_by_cat.get(cid, [])
    kids = children[cid]
    parent_name_tok = set(tokens(r["name"]))
    # signal 1 — a child's NAME word appears in the product title
    kid_name_tok = {}
    for k in kids:
        kid_name_tok[k] = set(tokens(nodes[k]["name"])) - parent_name_tok - STOP
    hit = 0
    for p in own:
        tt = set(tokens(p["title"]))
        if any(kid_name_tok[k] & tt for k in kids): hit += 1
    child_name_hit = hit / len(own)

    # signal 2 — leave-one-out nearest class (children's subtree corpora vs the node's own residual)
    profiles = {}
    for k in kids:
        c = collections.Counter()
        n = 0
        for t in subtree_titles(k):
            n += 1
            for x in set(tokens(t)): c[x] += 1
        if n: profiles[("child", k)] = (c, n)
    c = collections.Counter(); n = 0
    for p in own:
        n += 1
        for x in set(tokens(p["title"])): c[x] += 1
    profiles[("self", cid)] = (c, n)
    wins = collections.Counter()
    for p in own:
        tt = set(tokens(p["title"]))
        best, bests = None, -1e9
        for key, (cc, nn) in profiles.items():
            if key[0] == "self":
                s = sum(idf(t) * (cc[t] - 1) / max(nn - 1, 1) for t in tt)   # leave-one-out
            else:
                s = sum(idf(t) * cc[t] / nn for t in tt)
            if s > bests: best, bests = key, s
        wins[best] += 1
    child_wins = sum(v for k, v in wins.items() if k[0] == "child")
    nearest_child = child_wins / len(own)
    top_child = max(((k, v) for k, v in wins.items() if k[0] == "child"), key=lambda x: x[1], default=((None, None), 0))

    name = r["name"].upper()
    catchall = bool(re.search(r"\bLAIN|LAINNYA|LAINYA|OTHER|\bDLL\b|ANEKA|SERBA|UNUSED|BELUM DISORTIR|MACAM", name))
    rows.append(dict(
        id=cid, name=r["name"], depth=r["depth"], numchild=r["numchild"],
        products=r["products"], products_subtree=r["products_subtree"],
        full_path=r["full_path_name"],
        children=" | ".join(nodes[k]["name"] for k in sorted(kids, key=lambda k: nodes[k]["path"])),
        child_name_hit=round(child_name_hit, 3),
        nearest_child=round(nearest_child, 3),
        top_child=(nodes[top_child[0][1]]["name"] if top_child[0][1] else ""),
        top_child_n=top_child[1],
        name_is_catchall=catchall,
        titles=" :: ".join(p["title"] for p in own[:12]),
    ))

with open(f"{BASE}/sql/results/nonleaf-signals.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)

tot = sum(r["products"] for r in rows)
print("used non-leaf nodes:", len(rows), "products on them:", tot)
print("catch-all by name:", sum(1 for r in rows if r["name_is_catchall"]),
      "products:", sum(r["products"] for r in rows if r["name_is_catchall"]))
print("depth-1 (root):", sum(1 for r in rows if r["depth"] == 1),
      "products:", sum(r["products"] for r in rows if r["depth"] == 1))
for lo, hi in [(0.0, .2), (.2, .5), (.5, .8), (.8, 1.01)]:
    sel = [r for r in rows if lo <= r["nearest_child"] < hi]
    print(f"nearest_child {lo}-{hi}: {len(sel)} nodes, {sum(r['products'] for r in sel)} products")
print("\ncumulative product coverage of the top-N nodes:")
c = 0
for i, r in enumerate(rows, 1):
    c += r["products"]
    if i in (10, 20, 40, 60, 80, 100, 150, 292): print(f"  top {i}: {c} ({100*c/tot:.1f}%)")
