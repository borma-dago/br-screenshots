#!/usr/bin/env python3
"""Third pass: value ORDER in the published dist (en vs id-ID) and duplicate attribute NAMES."""
import json, os, collections, unicodedata
BASE=os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist")
def load(loc,n):
    with open(os.path.join(BASE,loc,n)) as f: return json.load(f)
en=load("en","attributes.json")["attributes"]
idn=load("id-ID","attributes.json")["attributes"]

def order_shape(attrs,label):
    alpha=alpha_no_other=id_asc=0
    other_last=other_any=0
    for a in attrs:
        names=[v["name"] for v in a["values"]]
        ids=[int(v["id"].rsplit("/",1)[1]) for v in a["values"]]
        if names==sorted(names): alpha+=1
        no=[n for n in names if n not in ("Other","Lainnya")]
        if no==sorted(no): alpha_no_other+=1
        if ids==sorted(ids): id_asc+=1
        if any(n in ("Other","Lainnya") for n in names):
            other_any+=1
            if names[-1] in ("Other","Lainnya"): other_last+=1
    print(f"[{label}] n={len(attrs)} · array order alphabetical: {alpha} · alphabetical ignoring Other/Lainnya: {alpha_no_other} · ascending by value id: {id_asc} · 'Other'/'Lainnya' present {other_any}, of which last {other_last}")
order_shape(en,"en")
order_shape(idn,"id-ID")

# same attribute id: does the value ARRAY ORDER differ between locales?
byid_en={a["id"]:[v["id"] for v in a["values"]] for a in en}
diff=same=0
for a in idn:
    o=byid_en.get(a["id"])
    if o is None: continue
    cur=[v["id"] for v in a["values"]]
    if cur==o: same+=1
    else: diff+=1
print(f"attributes whose value ARRAY ORDER is identical en vs id-ID: {same} · different: {diff}")
print("-> the published order is a function of the LOCALE's labels, not a stored per-value position" if diff>same else "-> order is stable across locales")

# duplicate attribute names in the global registry
names=collections.Counter(a["name"] for a in en)
dups={k:v for k,v in names.items() if v>1}
print(f"\ndistinct attribute NAMES among {len(en)} definitions: {len(names)} · names defined more than once: {len(dups)} {dict(list(dups.items())[:10])}")
# value-id stability across locales
val_en=set(v["id"] for a in en for v in a["values"]); val_id=set(v["id"] for a in idn for v in a["values"])
print(f"value ids: en {len(val_en)} · id-ID {len(val_id)} · identical set: {val_en==val_id}")
# edge concentration
cats=[c for v in load("en","categories.json")["verticals"] for c in v["categories"]]
byattr=collections.Counter(a["id"] for c in cats for a in c["attributes"])
tot=sum(byattr.values()); run=0
for i,(k,n) in enumerate(byattr.most_common(),1):
    run+=n
    if i in (3,10,25,50,100,250,500,1000):
        print(f"  top {i:4d} attributes cover {run:6d}/{tot} edges ({run/tot*100:.1f}%)")
