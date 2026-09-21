#!/usr/bin/env python3
"""For a sample of pass-B UNMAPPED nodes, list the five nearest taxonomy candidates
(loose scoring: token Jaccard on the node name, plus a bonus for containment) so the
'does a home exist at all?' question can be answered by hand rather than by the matcher."""
import csv, json, re, collections, unicodedata, random, sys
BASE="/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
CORP="/home/irvan/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist"
STOP=set("dan atau untuk di ke dari yang dengan pada the and or for of in a an & lainnya lainya lain dll".split())
QUAL=set("pria wanita anak bayi dewasa laki perempuan remaja unisex balita".split())
def norm(s):
    s=unicodedata.normalize("NFKD",s).casefold(); s=re.sub(r"[^a-z0-9]+"," ",s)
    t=[x for x in s.split() if x and x not in STOP]
    t2=[x for x in t if x not in QUAL]
    return frozenset(t2 or t)
d=json.load(open(f"{CORP}/id-ID/categories.json")); sh=[c for v in d["verticals"] for c in v["categories"]]
for c in sh: c["_t"]=norm(c["name"]); c["_ft"]=norm(c["full_name"])
rows=[r for r in csv.DictReader(open(f"{BASE}/data/shopify-mapping.csv")) if r["passB_verdict"]=="UNMAPPED"]
rows.sort(key=lambda r:-int(r["products"]))
sample=rows[:30]
random.seed(11); sample+=random.sample(rows[30:],20)
for r in sample:
    t=norm(r["name"])
    sc=[]
    for c in sh:
        j=len(t&c["_t"])/len(t|c["_t"]) if (t|c["_t"]) else 0
        j2=len(t&c["_ft"])/len(t) if t else 0
        sc.append((max(j,0.7*j2),c))
    sc.sort(key=lambda x:-x[0])
    print(f"[{r['id']}] n={r['products']:>5} {r['our_path'][-68:]}")
    for s,c in sc[:5]:
        print(f"      {s:.2f}  {c['full_name'][:100]} [{len(c['attributes'])}a]")
