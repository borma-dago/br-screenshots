#!/usr/bin/env python3
"""B3 / A3<->B3 shared measurement — the attribute need per used node.

TWO independent routes, reported separately and never blended:

MEASURED  (our own data, no external input). For every used node, scan its products' titles
          for evidence of eight attribute KINDS. A kind counts as needed by the node when at
          least THRESHOLD of the node's titles carry the evidence. Titles are what staff
          actually typed, so this measures what the catalogue already distinguishes, not what
          a schema ought to contain. Detectors are regex/lexicon and are listed in the output.

INFERRED  (Shopify Standard Product Taxonomy, corpus ad206247, id-ID). For every used node
          the pass-B mapping resolves (scripts/shopify_map2.py), take the mapped taxonomy
          node's materialised attribute set as that node's attribute need. Unmapped nodes
          contribute nothing — they are reported as a hole, not as zero.

Outputs: data/node-attribute-need.csv (per node, both routes) and the counts quoted in
node-attribute-need.md. Snapshot 2026-09-19.
"""
import csv, re, json, collections, unicodedata

BASE = "/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
THRESHOLD = 0.20

COLOUR = r"(HITAM|PUTIH|MERAH|BIRU|HIJAU|KUNING|COKLAT|COKELAT|ABU|PINK|UNGU|ORANGE|ORANYE|NAVY|MAROON|CREAM|KREM|GOLD|SILVER|BLACK|WHITE|RED|BLUE|GREEN|GREY|GRAY|TOSCA|BEIGE|MOCCA|KHAKI|LILAC|PEACH)"
FLAVOUR = r"(RASA|FLAVOU?R|AYAM|SOTO|SAPI|COKLAT|COKELAT|STROBERI|STRAWBERRY|VANILA|VANILLA|JERUK|MELON|ANGGUR|KEJU|PEDAS|ORIGINAL|BARBEQUE|BBQ|JAGUNG|BAWANG|KARI|KALDU|MINT|LEMON|APEL|APPLE|MANGGA|DURIAN|PANDAN|KOPI|TEH|SUSU|MADU|CAPPUCCINO|MOCHA|TIRAMISU|MATCHA|LYCHEE|BLACKCURRANT|JASMINE)"
MATERIAL = r"(PLASTIK|STAINLESS|KERAMIK|MELAMIN|MELAMINE|KAYU|KACA|ENAMEL|PORSELEN|KERTAS|ALUMU?NIUM|BESI|KARET|SILIKON|SILICONE|KATUN|COTTON|KAIN|JEANS|DENIM|KULIT|RAJUT|SPANDEX|POLYESTER|ANYAMAN)"
GARMENT = r"(\b(XS|XXL|XXXL|XXXS|XXS)\b|\bALL ?SIZE\b|\b\d{2}-\d{2}\b|\b[2-6]L\b|\bSIZE [A-Z0-9]+\b|\bUK\.? ?[SMLX]+\b)"
SCENT = r"(LAVENDER|SAKURA|OCEAN|FRESH|FLORAL|AROMA|PARFUM|PERFUME|WANGI|CITRUS|GARDENIA|ROSE|MAWAR|MELATI)"

DETECTORS = {
    "net_content":  re.compile(r"\b\d+([.,]\d+)?\s?(GR|GRAM|G|KG|ML|MLT|L|LTR|LITER|CC|MG|OZ)\b", re.I),
    "pack_count":   re.compile(r"(\bISI\s?\d+|\b\d+\s?[xX]\s?\d+\b|@\s?\d+|\b\d+\s?(PCS|PC|PAK|PACK|LBR|LEMBAR|SET|RENCENG|LUSIN|SACHET|SCT|BKS)\b)", re.I),
    "colour":       re.compile(COLOUR, re.I),
    "flavour":      re.compile(FLAVOUR, re.I),
    "material":     re.compile(MATERIAL, re.I),
    "garment_size": re.compile(GARMENT, re.I),
    "scent":        re.compile(SCENT, re.I),
    "model_code":   re.compile(r"\b[A-Z]{1,5}\d{2,6}[A-Z]?\b|\b[A-Z]{2,5}-\d{1,5}[A-Z]?\b|\b\d{3,6}[A-Z]{1,4}\b"),
}

nodes = {r["id"]: r for r in csv.DictReader(open(f"{BASE}/sql/results/nodes-full.csv"))}
prod = collections.defaultdict(list)
for r in csv.DictReader(open(f"{BASE}/sql/results/products-titles.csv")):
    prod[r["main_category_id"]].append(r["title"])

mapping = {r["id"]: r for r in csv.DictReader(open(f"{BASE}/data/shopify-mapping.csv"))}

rows = []
for cid, titles in prod.items():
    if cid not in nodes:
        continue
    n = len(titles)
    # Mask every word that the node's own name or ancestry already says, so a node called
    # SUSU BUBUK is not scored as needing "flavour" because every title says SUSU, and
    # KERIPIK KENTANG PUTIH is not scored as needing "colour" because of PUTIH.
    own = set(w for w in re.findall(r"[A-Z]+", (nodes[cid]["full_path_name"] or "").upper()) if len(w) > 2)
    ownpat = re.compile(r"\b(" + "|".join(sorted(map(re.escape, own), key=len, reverse=True)) + r")\b") if own else None
    masked = [(ownpat.sub(" ", t.upper()) if ownpat else t.upper()) for t in titles]
    shares = {k: sum(1 for t in masked if d.search(t)) / n for k, d in DETECTORS.items()}
    need = frozenset(k for k, v in shares.items() if v >= THRESHOLD)
    m = mapping.get(cid, {})
    inferred = m.get("passB_attrs", "")
    rows.append(dict(
        id=cid, name=nodes[cid]["name"], depth=nodes[cid]["depth"],
        is_leaf=nodes[cid]["is_leaf"], products=n,
        full_path=nodes[cid]["full_path_name"],
        measured_need="|".join(sorted(need)),
        measured_n=len(need),
        **{f"share_{k}": round(v, 3) for k, v in shares.items()},
        inferred_verdict=m.get("passB_verdict", ""),
        inferred_node=m.get("passB_shopify", ""),
        inferred_n=(len(inferred.split(" | ")) if inferred else 0),
        inferred_attrs=inferred,
        inferred_flagged_ancestor=m.get("passB_ancestor_level_match", ""),
        inferred_tier=m.get("passB_tier", ""),
    ))
rows.sort(key=lambda r: (-r["products"], int(r["id"])))   # deterministic 90% cut (red-team 16)
with open(f"{BASE}/data/node-attribute-need.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)

tot = len(rows); totp = sum(r["products"] for r in rows)
print(f"used nodes {tot}, products {totp}, threshold {THRESHOLD}")

print("\n=== MEASURED (title evidence) ===")
c = collections.Counter(r["measured_need"] for r in rows)
print(f"distinct measured attribute-need SETS across {tot} used nodes: {len(c)}")
print(f"nodes sharing their set with at least one other node: {sum(v for v in c.values() if v > 1)} "
      f"({100*sum(v for v in c.values() if v>1)/tot:.1f}%)")
print("the 12 most common sets:")
for s, k in c.most_common(12):
    print(f"   {k:>5} nodes  {{{s or '(none)'}}}")
kind = collections.Counter()
for r in rows:
    for k in r["measured_need"].split("|"):
        if k: kind[k] += 1
print("\nkind -> how many used nodes need it (>= threshold):")
for k, v in kind.most_common():
    print(f"   {k:<13} {v:>5} nodes ({100*v/tot:.1f}%)")
print(f"\nnodes needing NO kind at threshold: {c.get('',0)}")
print(f"distinct measured kinds in total: {len(kind)}")

# leaves only
leaves = [r for r in rows if r["is_leaf"] == "true"]
cl = collections.Counter(r["measured_need"] for r in leaves)
print(f"\nused LEAVES {len(leaves)}: distinct measured sets {len(cl)}; "
      f"leaves sharing a set with another leaf {sum(v for v in cl.values() if v>1)} "
      f"({100*sum(v for v in cl.values() if v>1)/len(leaves):.1f}%)")

# the 90% set
cum = 0; top = []
for r in rows:
    cum += r["products"]; top.append(r)
    if cum >= 0.9 * totp: break
ct = collections.Counter(r["measured_need"] for r in top)
kt = collections.Counter()
for r in top:
    for k in r["measured_need"].split("|"):
        if k: kt[k] += 1
print(f"\nthe {len(top)} nodes covering 90% of products: distinct measured sets {len(ct)}; "
      f"distinct measured kinds {len(kt)}")

print("\n=== INFERRED (Shopify pass-B mapping) ===")
mapped = [r for r in rows if r["inferred_verdict"] in ("EXACT", "FUZZY")]
print(f"nodes with an inferred set: {len(mapped)} of {tot} ({100*len(mapped)/tot:.1f}%); "
      f"the other {tot-len(mapped)} are a hole, not a zero")
ci = collections.Counter(r["inferred_attrs"] for r in mapped)
print(f"distinct inferred attribute SETS among them: {len(ci)}; "
      f"nodes sharing a set with another: {sum(v for v in ci.values() if v>1)} "
      f"({100*sum(v for v in ci.values() if v>1)/len(mapped):.1f}%)")
allnames = collections.Counter()
for r in mapped:
    for a in r["inferred_attrs"].split(" | "):
        if a: allnames[a] += 1
eq = [r for r in mapped if r["inferred_flagged_ancestor"] != "True"]
ceq = collections.Counter(r["inferred_attrs"] for r in eq)
neq = collections.Counter()
for r in eq:
    for a in r["inferred_attrs"].split(" | "):
        if a: neq[a] += 1
print(f"  of the mapped, NOT flagged 'target level<=2 or non-leaf': {len(eq)} nodes, "
      f"{len(ceq)} distinct sets, {len(neq)} distinct names")
print(f"distinct inferred attribute NAMES across the mapped nodes: {len(allnames)}")
print(f"median attributes per mapped node: "
      f"{sorted(r['inferred_n'] for r in mapped)[len(mapped)//2]}")
print("top 20 inferred names by node count:")
for a, v in allnames.most_common(20):
    print(f"   {v:>4}  {a}")
mapped90 = [r for r in top if r["inferred_verdict"] in ("EXACT", "FUZZY")]
n90 = set()
for r in mapped90:
    n90 |= set(x for x in r["inferred_attrs"].split(" | ") if x)
eq90 = [r for r in mapped90 if r["inferred_flagged_ancestor"] != "True"]
n90eq = set()
for r in eq90:
    n90eq |= set(x for x in r["inferred_attrs"].split(" | ") if x)
print(f"\nof the {len(top)} nodes covering 90%: {len(mapped90)} have an inferred set, "
      f"carrying {len(n90)} distinct attribute names; "
      f"not-flagged-ancestor subset: {len(eq90)} nodes / {len(n90eq)} names")
json.dump({"measured_kind_counts": kind, "inferred_name_counts": allnames.most_common()},
          open(f"{BASE}/data/node-attribute-need-summary.json", "w"), indent=1, ensure_ascii=False)
