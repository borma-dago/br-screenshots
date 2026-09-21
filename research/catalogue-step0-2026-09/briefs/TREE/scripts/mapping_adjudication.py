#!/usr/bin/env python3
"""BLOCKING 3 (ii) — the OVER-mapping rate, by hand adjudication of a sample of pass-B mapped nodes.

Sample fixed before adjudication: the 20 largest mapped nodes by product count (a products-weighted
stratum) + 20 drawn at random from the rest (random.seed(7) over the remaining mapped rows, the same
draw the listing in data/mapping-adjudication.md was produced from). Verdicts:
  correct   the target is the right equivalent kind
  ancestor  the target is a genuine ancestor of the right node — a correct but coarser home, so the
            attribute set it contributes is the ancestor's, not the node's
  wrong     a different kind of product
Each verdict carries the reason. Nothing here is mechanical; it is a reading, and it is published so it
can be disagreed with row by row.
"""
import csv, collections, json

BASE = "/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
VERDICT = {
 # id: (verdict, reason)
 "1162": ("wrong",   "KAUS PRIA (men's T-shirts) -> 'Pakaian Dalam Pria > Kaus Dalam Pria' = men's UNDERSHIRTS; the right node is 'Atasan Pakaian > Kaus Oblong'"),
 "1224": ("correct", "CELANA DALAM WANITA -> Lingeri > Celana Dalam Wanita"),
 "955":  ("ancestor","PERALATAN RUMAH TANGGA (depth-4) -> 'Rumah & Taman > Peralatan Rumah Tangga', a level-1 vertical child"),
 "440":  ("correct", "SANDAL WANITA -> Sepatu > Sandal; gender recoverable on the target"),
 "1223": ("correct", "BRA WANITA -> Lingeri > Bra"),
 "1163": ("correct", "KEMEJA PRIA -> Atasan Pakaian > Kemeja"),
 "1176": ("correct", "CELANA PANJANG PRIA -> Celana > Celana Panjang"),
 "1211": ("correct", "CELANA PANJANG WANITA -> Celana > Celana Panjang (same target as 1176; the collapse is the point)"),
 "432":  ("correct", "SANDAL PRIA -> Sepatu > Sandal"),
 "1271": ("wrong",   "TAS RANSEL PRIA (men's backpack) -> 'Tas Tangan > Tas Ransel Tangan' = a HANDBAG-style backpack; the right branch is 'Bagasi & Tas > Ransel'"),
 "53":   ("correct", "KACAMATA -> Perawatan Penglihatan > Kacamata"),
 "1180": ("correct", "CELANA DALAM PRIA -> Pakaian Dalam Pria > Celana Dalam"),
 "1144": ("correct", "SET PAKAIAN ANAK LAKI-LAKI -> Pakaian > Set Pakaian; age recoverable"),
 "58":   ("ancestor","SEPATU PRIA -> 'Busana dan Aksesori > Sepatu', the whole footwear branch (level 1, non-leaf)"),
 "67":   ("correct", "BONEKA -> Mainan > Boneka, Set Mainan & Figur Mainan > Boneka"),
 "1282": ("correct", "TAS RANSEL WANITA -> Tas Tangan > Tas Ransel Tangan; for a women's handbag-backpack this is the right node"),
 "1151": ("correct", "SET PAKAIAN ANAK PEREMPUAN -> Pakaian > Set Pakaian"),
 "59":   ("ancestor","SEPATU WANITA -> 'Busana dan Aksesori > Sepatu' (level 1, non-leaf)"),
 "57":   ("correct", "SEPATU ANAK & BAYI -> Sepatu > Sepatu Bayi & Anak"),
 "549":  ("correct", "PERMEN -> Permen & Cokelat > Permen"),
 "1094": ("correct", "KABEL AUDIO -> Kabel > Kabel Audio & Video"),
 "1264": ("correct", "DOMPET PRIA -> Dompet & Klip Uang > Dompet"),
 "721":  ("correct", "JAMUR -> Buah & Sayur > Sayur Segar & Beku > Jamur"),
 "1284": ("correct", "TAS TANGAN WANITA -> Tas Tangan, Dompet & Kotak > Tas Tangan"),
 "1149": ("wrong",   "PAKAIAN MUSLIM ANAK PEREMPUAN -> 'Pakaian Dalam Anak Perempuan' = girls' UNDERWEAR"),
 "307":  ("correct", "PENSIL -> Pena & Pensil > Pensil"),
 "138":  ("correct", "PERAWATAN MULUT & GIGI -> Perawatan Tubuh > Perawatan Mulut"),
 "630":  ("correct", "MINYAK WIJEN -> Minyak Goreng > Minyak Wijen"),
 "1007": ("correct", "BENANG JAHIT -> Benang & Floss > Benang Jahit"),
 "1179": ("wrong",   "CELANA BOXER (men's) -> 'Pakaian Dalam Balita > Celana Dalam Boxer' = TODDLER boxers"),
 "97":   ("wrong",   "MAKANAN BEKU (frozen food) -> 'Perlengkapan Ikan & Akuatik > Makanan Ikan > Makanan Beku' = frozen FISH FOOD"),
 "1813": ("correct", "JAS HUJAN -> Pakaian Luar > Mantel & Jaket > Jas Hujan"),
 "658":  ("correct", "TEPUNG ROTI -> Bahan Memasak & Baking > Tepung Roti"),
 "1160": ("ancestor","TOPI BAYI -> 'Aksesori Pakaian > Topi', the generic hats node (level 2, non-leaf)"),
 "7":    ("wrong",   "our ROOT 'Alat dan Buku Tulis' -> 'Perlengkapan Kantor Umum > Produk Kertas > Alat Tulis', a paper-products leaf"),
 "287":  ("wrong",   "KIPAS ANGIN (electric fans) -> 'Aksesori Kipas > Remote Kipas Angin' = fan REMOTE CONTROLS"),
 "574":  ("correct", "GULA PASIR -> Gula & Pemanis > Gula Pasir"),
 "552":  ("correct", "PERMEN KARET -> Permen > Permen Karet"),
 "1519": ("correct", "MASKER ANTI DEBU -> Masker Pelindung > Masker Debu"),
 "174":  ("correct", "CAT -> Bahan Pengecatan Habis Pakai > Cat"),
 # --- round-2 top-up (red-team round 2, SERIOUS 9): the resolver fix dropped 7 of the original 40 rows
 # out of the mapped set, so the random stratum was topped up by 4 further rows drawn at random from the
 # CURRENT mapped set (random.seed(23) over the mapped rows outside the top 20 and outside the original
 # sample) and adjudicated the same way.
 "205":  ("wrong",   "PERAWATAN MOBIL (car-care PRODUCTS: compounds, polishes, coolant) -> 'Layanan > Layanan Otomotif > Perbaikan & Perawatan Mobil' = a SERVICE node. Wrong across the goods/services boundary"),
 "390":  ("ancestor","PAKAIAN ANAK PEREMPUAN -> 'Busana dan Aksesori > Pakaian', the whole clothing branch (level 1, non-leaf)"),
 "1186": ("wrong",   "KAUS WANITA (women's T-shirts) -> 'Lingeri > Kaus Dalam Wanita' = women's UNDERSHIRTS; same failure mode as KAUS PRIA"),
 "683":  ("correct", "PISANG -> Buah & Sayur > Buah Segar & Beku > Pisang"),
}
STRATUM_TOP20 = ["1162","1224","955","440","1223","1163","1176","1211","432","1271",
                 "53","1180","1144","58","67","1282","1151","59","57","549"]
STRATUM_TOPUP = ["205", "390", "1186", "683"]

rows = {r["id"]: r for r in csv.DictReader(open(f"{BASE}/data/shopify-mapping.csv"))}
mapped = [r for r in rows.values() if r["passB_verdict"] in ("EXACT", "FUZZY")]
# Round-2 (SERIOUS 9): the resolver now returns AMBIGUOUS whenever >1 candidate shares the winning
# normalised name, so some adjudicated rows are no longer "mapped". They are reported and EXCLUDED
# from the rate, because a row that is no longer claimed cannot be a claim that is wrong.
dropped = [cid for cid in VERDICT if rows[cid]["passB_verdict"] not in ("EXACT", "FUZZY")]
out = []
for cid, (v, why) in VERDICT.items():
    if cid in dropped:
        continue
    r = rows[cid]
    out.append(dict(id=cid, stratum=("top20" if cid in STRATUM_TOP20 else "random"),
                    products=r["products"], verdict=v, tier=r["passB_tier"], scope=r["passB_scope"],
                    target_level=r["passB_level"], target_is_leaf=r["passB_is_leaf"],
                    flagged_ancestor_level=r["passB_ancestor_level_match"],
                    ours=r["our_path"], theirs=r["passB_shopify"], reason=why))
out.sort(key=lambda r: (r["stratum"], -int(r["products"])))
with open(f"{BASE}/data/mapping-adjudication.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)

print(f"pass-B mapped nodes: {len(mapped)}")
print(f"adjudicated rows no longer mapped after the round-2 resolver fix: {len(dropped)} "
      f"{[ (cid, VERDICT[cid][0], rows[cid]['passB_verdict']) for cid in dropped ]}")
print(f"surviving adjudicated rows: {len(out)}")
for st in ("top20", "random", "ALL"):
    sel = [r for r in out if st == "ALL" or r["stratum"] == st]
    if not sel: continue
    c = collections.Counter(r["verdict"] for r in sel)
    print(f"  {st:<9} n={len(sel):<3} correct={c['correct']:<3} ancestor={c['ancestor']:<3} wrong={c['wrong']:<3}"
          f"  wrong-rate={100*c['wrong']/len(sel):5.1f}%  not-equivalent={(100*(c['wrong']+c['ancestor'])/len(sel)):5.1f}%")
# Wilson 95% interval for the unbiased stratum
import math
c = collections.Counter(r["verdict"] for r in out if r["stratum"] == "random")
n = sum(1 for r in out if r["stratum"] == "random"); k = c["wrong"]; p = k/n; z = 1.96
den = 1 + z*z/n; c1 = (p + z*z/(2*n))/den
half = z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))/den
print(f"\nrandom stratum wrong-rate {k}/{n} = {100*p:.0f}%; Wilson 95% CI [{100*(c1-half):.0f}%, {100*(c1+half):.0f}%]")
# product-weighted error over the adjudicated rows (red-team round 2, MINOR 17)
tp = sum(int(r["products"]) for r in out)
wp = sum(int(r["products"]) for r in out if r["verdict"] == "wrong")
ap = sum(int(r["products"]) for r in out if r["verdict"] == "ancestor")
print(f"product-weighted over the {len(out)} adjudicated rows: wrong {wp}/{tp} = {100*wp/tp:.1f}%, "
      f"ancestor {ap}/{tp} = {100*ap/tp:.1f}%  (the top-20 stratum dominates this, so it is NOT a "
      f"population estimate — it is the error share of the products this sample covers)")
print("  -> the honest statement over all mapped rows: roughly a quarter, and certainly not negligible")
# mechanical flag vs the hand verdict
mech = sum(1 for r in out if r["flagged_ancestor_level"] == "True")
hand = sum(1 for r in out if r["verdict"] == "ancestor")
print(f"\nmechanical flag `target level<=2 or non-leaf` fires on {mech} of the {len(out)}; hand says 'ancestor' on {hand}."
      f"  The flag OVER-counts: it fires on correct equivalent matches whose target is simply non-leaf.")
# scope among mapped
print(f"\nscope among the {len(mapped)} mapped rows: " +
      ", ".join(f"{k}={v}" for k, v in collections.Counter(r["passB_scope"] for r in mapped).most_common()))
