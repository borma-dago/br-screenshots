#!/usr/bin/env python3
"""Second pass: the actual value lists behind the card's Rasa example, en and id-ID."""
import json, os, collections, re
BASE=os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist")
def load(loc,n):
    with open(os.path.join(BASE,loc,n)) as f: return json.load(f)
en=load("en","attributes.json")["attributes"]
by_handle={a["handle"]:a for a in en}
print("## Flavor (gid 1458) — the ONE list, all 30 values, en")
f=by_handle["flavor"]
for v in f["values"]: print(f"  {v['id']}  {v['name']}")
print("\n## Pet food flavor — all 43 values (a SECOND definition, its own list)")
for v in by_handle["pet-food-flavor"]["values"]: print(f"  {v['name']}")
print("\n## Baby food flavor — all 41 values")
for v in by_handle["baby-food-flavor"]["values"]: print(f"  {v['name']}")
print("\n## Food product form values")
for h in ["food-product-form","package-type","product-form"]:
    if h in by_handle:
        a=by_handle[h]; print(f"  {a['name']} ({a['id']}) {len(a['values'])} values: {[v['name'] for v in a['values']]}")

print("\n## id-ID: same ids, translated names?")
idn=load("id-ID","attributes.json")["attributes"]
by_id_idn={a["id"]:a for a in idn}
fi=by_id_idn.get(f["id"])
print(f"  id-ID attributes: {len(idn)} · same id present: {fi is not None}")
if fi:
    print(f"  name en='{f['name']}'  id-ID='{fi['name']}'  handle en='{f['handle']}' id-ID='{fi['handle']}'")
    print(f"  value count en={len(f['values'])} id-ID={len(fi['values'])}")
    envals={v['id']:v['name'] for v in f['values']}
    for v in fi['values'][:40]:
        print(f"    {v['id']}  en={envals.get(v['id'],'?'):22s} id-ID={v['name']}")
idcats=load("id-ID","categories.json")
print(f"  id-ID categories: {sum(len(v['categories']) for v in idcats['verticals'])}")

print("\n## does the taxonomy have ANY non-enumerated attribute? (free text / number / measurement)")
print(f"  attributes with 0 values: {sum(1 for a in en if not a['values'])}")
print(f"  keys on an attribute object: {sorted(en[0].keys())}")
print(f"  keys on a value object: {sorted(en[0]['values'][0].keys())}")
print("  -> no 'type', no 'unit', no 'input_type', no 'position' key anywhere on attribute or value" if not ({'type','unit','input_type','position','sort_order'} & set(en[0].keys()) | ({'position','sort_order','unit'} & set(en[0]['values'][0].keys()))) else "  -> a typing/ordering key EXISTS")

print("\n## value ORDER: is the published list alphabetical, id-ordered, or curated?")
for h in ["flavor","size","color","food-product-form"]:
    a=by_handle.get(h)
    if not a: continue
    names=[v["name"] for v in a["values"]]
    ids=[int(v["id"].rsplit("/",1)[1]) for v in a["values"]]
    print(f"  {a['name']:20s} alphabetical={names==sorted(names)}  id-ascending={ids==sorted(ids)}  last={names[-1]!r}")
n_other_last=sum(1 for a in en if a["values"] and a["values"][-1]["name"]=="Other")
n_other=sum(1 for a in en if any(v["name"]=="Other" for v in a["values"]))
alpha_excl_other=sum(1 for a in en if [v["name"] for v in a["values"] if v["name"]!="Other"]==sorted([v["name"] for v in a["values"] if v["name"]!="Other"]))
print(f"  attributes whose LAST value is 'Other': {n_other_last} of {n_other} attributes containing an 'Other' value ({len(en)} total)")
print(f"  attributes alphabetical once 'Other' is removed: {alpha_excl_other} of {len(en)}")
