#!/usr/bin/env python3
"""B2 — assign a class to each of the 292 used non-leaf nodes.

Classes
  not-a-type        the node or an ancestor is an operational / merchandising container,
                    not a kind of product (roots UNUSED, BELUM DISORTIR, INVENTORY KANTOR,
                    and the AREA DISPLAY / OBRAL tiers under them)
  declared-catch-all the node's own NAME declares a residual bucket (LAIN/LAINNYA/OTHER/ANEKA/...)
  root-parking      a depth-1 root holding products directly, not otherwise classified
  under-filed       a child that fits the parked products already exists
  residual-type     the node names a real kind; its children are partial refinements, so a
                    product of that kind with no fitting child genuinely stops at this node
  mixed             the parked products span several children's kinds, or kinds that belong
                    to a different branch entirely

basis=hand   the top 40 nodes by product count (69.4% of the 19,522) were read one by one
             against their children and a 12-title sample; the verdict below is that reading.
basis=rule   the remaining 252 were assigned mechanically from the two signals in
             scripts/nonleaf_classify.py. Rule order is the class order above; then
             under-filed if child_name_hit >= 0.30 or nearest_child >= 0.70;
             residual-type if nearest_child < 0.35 and child_name_hit < 0.10; else mixed.
The rule is a weaker instrument than the reading: on the 40 hand-read nodes it agrees with
the hand verdict on the share printed at the end, which is the honest accuracy estimate.
"""
import csv, collections

BASE = "/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
HAND = {
 "955":"under-filed", "10":"declared-catch-all", "450":"under-filed", "72":"mixed",
 "53":"residual-type", "49":"residual-type", "58":"under-filed", "398":"under-filed",
 "59":"under-filed", "60":"under-filed", "48":"mixed", "57":"residual-type",
 "42":"under-filed", "1541":"under-filed", "1796":"not-a-type", "404":"residual-type",
 "391":"under-filed", "40":"under-filed", "51":"residual-type", "7":"root-parking",
 "256":"under-filed", "29":"residual-type", "111":"under-filed", "14":"under-filed",
 "41":"under-filed", "1410":"residual-type", "449":"mixed", "44":"residual-type",
 "2":"root-parking", "1546":"declared-catch-all", "428":"under-filed", "1795":"not-a-type",
 "93":"under-filed", "448":"under-filed", "107":"under-filed", "26":"mixed",
 "151":"residual-type", "1649":"under-filed", "78":"under-filed", "390":"under-filed",
}
# Added after red-team round 1 (SERIOUS 6): eight nodes from the rule-assigned tail that the red-team
# agent re-read by hand and adjudicated. Adopted as readings, not disputed. They show the rule errs in
# BOTH directions, which is why the tail's class distribution is reported as unresolved.
REDTEAM_HAND = {
 "52":   ("residual-type", "children are kids'/men's/women's; every parked title is JAM TANGAN WANITA PRIA COUPLE — unisex, fits no child"),
 "213":  ("residual-type", "children are sewing/pin/knitting needles; parked are JARUM KARUNG (sack) and JARUM LAYAR (sail)"),
 "935":  ("residual-type", "children are pants-style and tape-style; parked is LIFREE PAD REFILL — a pad, neither"),
 "945":  ("residual-type", "children are pouch/spray/sachet; parked is RAPIKA BIANG KOTAK — a box"),
 "1677": ("residual-type", "children are plastic/stainless; parked are KAYU JATI, MAHONI, SONO — wood, a third material"),
 "235":  ("mixed",         "only child is BOLA TENNIS; parked is BET TENIS MEJA — a table-tennis bat, a different sport"),
 "125":  ("under-filed",   "one child has the SAME NAME as the parent; all 61 feeding sets belong in it"),
 "110":  ("under-filed",   "two of the four children are IKAN SEGAR LAINNYA / SEAFOOD SEGAR LAINNYA, so everything fits a child"),
}
NOT_A_TYPE_ROOTS = {"UNUSED", "BELUM DISORTIR", "INVENTORY KANTOR"}

nodes = {r["id"]: r for r in csv.DictReader(open(f"{BASE}/sql/results/nodes-full.csv"))}
sig = list(csv.DictReader(open(f"{BASE}/sql/results/nonleaf-signals.csv")))

def rule(r):
    root = (nodes[r["id"]]["ancestor_names"] or nodes[r["id"]]["name"]).split(" > ")[0]
    if root in NOT_A_TYPE_ROOTS: return "not-a-type"
    if r["name_is_catchall"] == "True": return "declared-catch-all"
    if r["depth"] == "1": return "root-parking"
    hit, near = float(r["child_name_hit"]), float(r["nearest_child"])
    if hit >= 0.30 or near >= 0.70: return "under-filed"
    if near < 0.35 and hit < 0.10: return "residual-type"
    return "mixed"

out, agree, n_hand = [], 0, 0
for r in sig:
    rl = rule(r)
    if r["id"] in HAND:
        cls, basis = HAND[r["id"]], "hand"; n_hand += 1; agree += (cls == rl)
    elif r["id"] in REDTEAM_HAND:
        cls, basis = REDTEAM_HAND[r["id"]][0], "hand-redteam"
    else:
        cls, basis = rl, "rule"
    out.append(dict(id=r["id"], klass=cls, basis=basis, rule_says=rl,
                    products=int(r["products"]), depth=r["depth"], numchild=r["numchild"],
                    child_name_hit=r["child_name_hit"], nearest_child=r["nearest_child"],
                    full_path=r["full_path"], children=r["children"], titles=r["titles"]))
out.sort(key=lambda r: -r["products"])
with open(f"{BASE}/data/nonleaf-classification.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)

tot = sum(r["products"] for r in out)
print(f"{len(out)} used non-leaf nodes, {tot} products")
c = collections.Counter(r["klass"] for r in out); p = collections.Counter()
for r in out: p[r["klass"]] += r["products"]
for k, v in c.most_common():
    print(f"  {k:<19} {v:>4} nodes ({100*v/len(out):5.1f}%)  {p[k]:>6} products ({100*p[k]/tot:5.1f}%)")
rt = [r for r in out if r["basis"] == "hand-redteam"]
rt_agree = sum(1 for r in rt if r["klass"] == r["rule_says"])
print(f"\nred-team hand-read tail nodes: {len(rt)} ({sum(r['products'] for r in rt)} products); "
      f"rule agreed on {rt_agree} of {len(rt)}")
print("  their direction of error, on the tail:")
for r in rt:
    if r["klass"] != r["rule_says"]:
        print(f"    [{r['id']}] rule {r['rule_says']:<15} -> hand {r['klass']:<15} n={r['products']}")
hp = sum(r['products'] for r in out if r['basis'] == 'hand')
up = sum(r['products'] for r in out if r['basis'].startswith('hand'))
un = sum(1 for r in out if r['basis'].startswith('hand'))
uagree = sum(1 for r in out if r['basis'].startswith('hand') and r['klass'] == r['rule_says'])
print(f"\nhand-read, top-by-products stratum: {n_hand} nodes ({hp} products, {100*hp/tot:.1f}%); "
      f"rule agrees on {agree} of {n_hand} ({100*agree/n_hand:.0f}%)")
print(f"hand-read UNION (top-by-products + the adopted tail rows): {un} nodes ({up} products, "
      f"{100*up/tot:.1f}%); rule agrees on {uagree} of {un} ({100*uagree/un:.0f}%)")
print("  NOTE: the union pools a top-by-products stratum with an ERROR-ENRICHED subsample "
      "(the rows a random-20 tail re-read judged misclassified), so the union's agreement rate is a "
      "lower bound, not an estimate of the rule's accuracy on the tail. See nonleaf-classification.md §2.")
print(f"rule-assigned nodes remaining: {len(out)-un}")
# red-team SERIOUS 6: print the confusion matrix, not a prose summary of it
print("\nCONFUSION MATRIX on the 40 hand-read nodes — rows = rule_says, columns = hand verdict")
ks = ["under-filed", "residual-type", "mixed", "declared-catch-all", "root-parking", "not-a-type"]
m = collections.Counter((r["rule_says"], r["klass"]) for r in out if r["basis"] == "hand")
hdr = "rule / hand"
print(f"{hdr:<20}" + "".join(f"{k[:11]:>13}" for k in ks) + f"{'TOTAL':>8}")
for rk in ks:
    row = [m[(rk, hk)] for hk in ks]
    if sum(row) or rk in {r["rule_says"] for r in out if r["basis"] == "hand"}:
        print(f"{rk:<20}" + "".join(f"{v:>13}" for v in row) + f"{sum(row):>8}")
print(f'{"TOTAL":<20}' + "".join(f"{sum(m[(rk,hk)] for rk in ks):>13}" for hk in ks) +
      f"{sum(m.values()):>8}")
print("\nwhere the rule and the reading disagree, by direction:")
for (rk, hk), v in sorted(m.items(), key=lambda x: -x[1]):
    if rk != hk: print(f"   rule {rk:<19} -> hand {hk:<19} {v}")
print("\nthe residual-type nodes (the ones where a non-leaf assignment is genuinely right):")
for r in out:
    if r["klass"] == "residual-type" and r["products"] >= 60:
        print(f"   {r['products']:>5}  {r['full_path'][-78:]}")
