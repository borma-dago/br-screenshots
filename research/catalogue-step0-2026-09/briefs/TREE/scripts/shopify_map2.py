#!/usr/bin/env python3
"""The fork — mapping feasibility, two passes.  REBUILT after red-team round 1.

What changed in round 1 (BLOCKING 3, SERIOUS 5, SERIOUS 16):
  * The gender/age qualifier is now stripped from OUR side ONLY. The previous build stripped it from the
    taxonomy's names too, which produced wrong-target matches such as `ATASAN WANITA` (women's tops)
    landing EXACT on `Pakaian Bayi & Anak > Atasan Bayi & Anak` (children's tops), because the only id-ID
    node whose stripped name is {atasan} is the children's one.
  * A stripped match is admitted only when the qualifier is RECOVERABLE on the target — the target node
    must carry `Jenis kelamin sasaran` (Target gender) or `Kelompok usia` (Age group). That is the whole
    point of the collapse: the fact moves from the tree into an attribute, so the attribute must exist.
  * The thirteen root->vertical bindings are now a PREFERENCE, not a filter: if nothing in the preferred
    verticals reaches the threshold, the whole taxonomy is searched and the row is marked scope=global.
    Pass B is therefore a superset of pass A. The previous build lost 58 correct pass-A matches this way.
  * Every mapped row carries the target's level and leafness, so "mapped to an ancestor" can be counted
    rather than hidden.
  * Ordering is deterministic: (-products, id).

Pass A  literal name identity, global pool, no stripping. The rate at which our node NAMES are literally
        the taxonomy's id-ID names.
Pass B  pass A + the two pieces of work a real adoption does first: the thirteen root->vertical bindings
        (a preference), and the qualifier collapse (recoverable only). The rate at which a mapping is
        MECHANICALLY derivable. Everything it misses is the hand-mapping bill.

Both run against dist/id-ID (only 15 of 1,686 used nodes carry `_name_en`, so the English build is not a
route). No machine translation. Corpus commit ad206247, build 2026-11-unstable. Our snapshot 2026-09-19.
"""
import csv, json, re, collections, unicodedata

BASE = "/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE"
CORP = "/home/irvan/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist"

STOP = set("""dan atau untuk di ke dari yang dengan pada the and or for of in a an &
lainnya lainya lain dll dsb serta juga adalah""".split())
QUALIFIER = set("""pria wanita anak bayi dewasa laki perempuan remaja unisex balita""".split())
# the taxonomy attributes that make a stripped qualifier recoverable on the target
RECOVERY = {"Jenis kelamin sasaran", "Kelompok usia"}
THRESHOLD = 0.60

# Hand-authored, thirteen decisions — the root-level work an adoption starts with. Judgement.
# Round 1: these are a PREFERENCE, not a filter (see docstring).
ROOT_VERTICALS = {
    "Makanan dan Minuman": ["Makanan, Minuman & Tembakau", "Rumah & Taman"],
    "Keperluan Anak dan Bayi": ["Bayi & Balita", "Kesehatan & Kecantikan", "Mainan & Permainan"],
    "Perbaikan Rumah": ["Perkakas", "Rumah & Taman", "Bisnis & Industri"],
    "Hobi, Ibadah, dan Olahraga": ["Seni & Hiburan", "Peralatan Olahraga", "Keagamaan & Seremonial",
                                    "Kendaraan & Suku Cadang", "Hewan & Perlengkapan Hewan Piaraan"],
    "Elektronik": ["Elektronik", "Rumah & Taman", "Kamera & Optik"],
    "Alat dan Buku Tulis": ["Perlengkapan Kantor", "Media", "Seni & Hiburan"],
    "Fashion": ["Busana dan Aksesori", "Bagasi & Tas"],
    "Kosmetik dan Alat Kecantikan": ["Kesehatan & Kecantikan"],
    "Mainan dan Alat Lainnya": ["Mainan & Permainan", "Perkakas", "Peralatan Olahraga"],
    "Perawatan Diri & Rumah Tangga": ["Kesehatan & Kecantikan", "Rumah & Taman", "Furnitur"],
    "UNUSED": [], "INVENTORY KANTOR": [], "BELUM DISORTIR": [],
}

def norm(s, strip_qualifier=False):
    s = unicodedata.normalize("NFKD", s).casefold()
    s = re.sub(r"[^a-z0-9]+", " ", s)
    toks = [t for t in s.split() if t and t not in STOP]
    if strip_qualifier:
        stripped = [t for t in toks if t not in QUALIFIER]
        if stripped:
            toks = stripped
    return frozenset(toks)

def load(loc):
    d = json.load(open(f"{CORP}/{loc}/categories.json"))
    return [(v["name"], c) for v in d["verticals"] for c in v["categories"]]

sh_pairs = load("id-ID")
sh_en = {c["id"]: c for _, c in load("en")}
for vert, c in sh_pairs:
    c["_vert"] = vert
    c["_tok"] = norm(c["name"])                      # NEVER stripped — round-1 fix
    c["_anc"] = norm(c["full_name"])
    c["_attrs"] = [a["name"] for a in c["attributes"]]
    c["_recovers"] = bool(RECOVERY & set(c["_attrs"]))
    c["_isleaf"] = not c["children"]
sh = [c for _, c in sh_pairs]

ours = [r for r in csv.DictReader(open(f"{BASE}/sql/results/nodes-full.csv")) if int(r["products"]) > 0]
for r in ours:
    r["_root"] = (r["ancestor_names"] or r["name"]).split(" > ")[0]
    r["_raw"] = norm(r["name"])
    r["_strip"] = norm(r["name"], True)
    r["_hasqual"] = r["_raw"] != r["_strip"]
    r["_anc"] = norm((r["ancestor_names"] or "") + " " + r["name"])
ours.sort(key=lambda r: (-int(r["products"]), int(r["id"])))

def resolve(cands, r):
    """Round-2 fix (red-team round 2, SERIOUS 9). Revision 2 tie-broke on ancestor-token overlap and
    silently recorded the winner as EXACT: 30 of 351 exact-tier rows had more than one identically
    normalised candidate, and the tie could turn on one generic shared word. `CELANA PENDEK PRIA` was
    resolved to LOUNGEWEAR shorts because our parent is `BAWAHAN PRIA` and the taxonomy path contains
    `Bawahan Loungewear` — one shared token, "bawahan".

    Now: more than one candidate sharing the winning normalised name is AMBIGUOUS, full stop. The
    best-ranked candidate is still reported so the row can be inspected, but it is not counted as mapped.
    Returns (node, unique?, n_candidates)."""
    if len(cands) == 1:
        return cands[0], True, 1
    s = sorted(cands, key=lambda c: (-len(c["_anc"] & r["_anc"]), c["level"]))
    return s[0], False, len(cands)

def search(r, pool, allow_strip):
    """Returns (verdict, node, score, tier) or None if nothing reaches the threshold."""
    # T1 exact on raw tokens
    c1 = [c for c in pool if c["_tok"] == r["_raw"]]
    if c1:
        n, uniq, k = resolve(c1, r)
        return ("EXACT" if uniq else "AMBIGUOUS"), n, 1.0, "exact-raw", k
    # T2 exact on stripped tokens, only if our name carried a qualifier AND the target recovers it
    if allow_strip and r["_hasqual"]:
        c2 = [c for c in pool if c["_tok"] == r["_strip"] and c["_recovers"]]
        if c2:
            n, uniq, k = resolve(c2, r)
            return ("EXACT" if uniq else "AMBIGUOUS"), n, 1.0, "exact-stripped", k
    # T3/T4 fuzzy
    best, bestj, bestt = [], 0.0, ""
    for c in pool:
        for tok, tier, ok in ((r["_raw"], "fuzzy-raw", True),
                              (r["_strip"], "fuzzy-stripped", allow_strip and r["_hasqual"] and c["_recovers"])):
            if not ok or not (tok & c["_tok"]):
                continue
            j = len(tok & c["_tok"]) / len(tok | c["_tok"])
            if j > bestj:
                best, bestj, bestt = [c], j, tier
            elif j == bestj and c not in best:
                best.append(c)
    if best and bestj >= THRESHOLD:
        n, uniq, k = resolve(best, r)
        return ("FUZZY" if uniq else "AMBIGUOUS"), n, bestj, bestt, k
    return ("UNMAPPED", (best[0] if best else None), bestj, "", len(best))

A, B = {}, {}
for r in ours:
    A[r["id"]] = search(r, sh, allow_strip=False) + ("global",)
    allowed = ROOT_VERTICALS.get(r["_root"])
    got = None
    scope = "global"
    if allowed:
        pool = [c for c in sh if c["_vert"] in allowed]
        if pool:
            got = search(r, pool, allow_strip=True)
            if got[0] == "UNMAPPED":
                got = None
            else:
                scope = "vertical"
    if got is None:
        if allowed == []:                       # the three non-product roots bind to nothing
            got = ("UNMAPPED", None, 0.0, "", 0)
        else:
            got = search(r, sh, allow_strip=True)
    B[r["id"]] = got + (scope,)

rows = []
for r in ours:
    va, ma, sa, ta, ka, _ = A[r["id"]]
    vb, mb, sb, tb, kb, scope = B[r["id"]]
    ok_b = vb in ("EXACT", "FUZZY")
    attrs = mb["_attrs"] if (mb and ok_b) else []
    rows.append(dict(
        id=r["id"], name=r["name"], depth=r["depth"], products=r["products"], our_path=r["full_path_name"],
        has_qualifier=r["_hasqual"],
        passA_verdict=va, passA_score=round(sa, 3), passA_n_candidates=ka,
        passA_shopify=(ma["full_name"] if ma and va != "UNMAPPED" else ""),
        passB_verdict=vb, passB_score=round(sb, 3), passB_tier=tb, passB_scope=scope,
        passB_n_candidates=kb,
        passB_shopify_id=(mb["id"].rsplit("/", 1)[-1] if mb and ok_b else ""),
        passB_shopify=(mb["full_name"] if mb and ok_b else ""),
        passB_shopify_en=(sh_en[mb["id"]]["full_name"] if mb and ok_b else ""),
        passB_level=(mb["level"] if mb and ok_b else ""),
        passB_is_leaf=(mb["_isleaf"] if mb and ok_b else ""),
        passB_ancestor_level_match=((mb["level"] <= 2 or not mb["_isleaf"]) if mb and ok_b else ""),
        passB_n_attrs=(len(attrs) if ok_b else ""),
        passB_attrs=" | ".join(attrs),
        passB_nearest_miss=(mb["full_name"] if mb and vb == "UNMAPPED" else ""),
    ))
with open(f"{BASE}/data/shopify-mapping.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)

tot = len(rows); totp = sum(int(r["products"]) for r in rows)
print(f"our used nodes {tot}, products {totp}\n")
for p in ("passA", "passB"):
    t = collections.Counter(r[p + "_verdict"] for r in rows); pr = collections.Counter()
    for r in rows: pr[r[p + "_verdict"]] += int(r["products"])
    print(f"--- {p} ---")
    for k in ("EXACT", "FUZZY", "AMBIGUOUS", "UNMAPPED"):
        print(f"   {k:<10} {t[k]:>5} ({100*t[k]/tot:5.1f}%)  products {pr[k]:>7} ({100*pr[k]/totp:5.1f}%)")
    m = t["EXACT"] + t["FUZZY"]; mp = pr["EXACT"] + pr["FUZZY"]
    print(f"   mapped     {m:>5} ({100*m/tot:5.1f}%)  products {mp:>7} ({100*mp/totp:5.1f}%)")
    print(f"   MISS       {tot-m:>5} ({100*(tot-m)/tot:5.1f}%)  products {totp-mp:>7} ({100*(totp-mp)/totp:5.1f}%)")

# Is B a superset of A? Scoped claim (red-team round 2, SERIOUS 5): the three non-product roots are
# excluded from pass B BY CONSTRUCTION, so the invariant can only hold over the ten product roots.
NONPRODUCT = ("UNUSED", "BELUM DISORTIR", "INVENTORY KANTOR")
reg = [r for r in rows if r["passA_verdict"] in ("EXACT", "FUZZY") and r["passB_verdict"] not in ("EXACT", "FUZZY")]
reg_prod = [r for r in reg if not r["our_path"].startswith(NONPRODUCT)]
print(f"\npass-A matches lost by pass B, over the TEN PRODUCT ROOTS (must be 0): {len(reg_prod)}")
print(f"  lost under the three non-product roots, by construction: {len(reg)-len(reg_prod)}"
      f", products {sum(int(r['products']) for r in reg) - sum(int(r['products']) for r in reg_prod)}"
      f"  [{', '.join(r['id'] for r in reg if r not in reg_prod)}]")
amb = [r for r in rows if r["passB_verdict"] == "AMBIGUOUS"]
print(f"pass-B AMBIGUOUS rows: {len(amb)}, of which {sum(1 for r in amb if int(r['passB_n_candidates'])>1)} "
      f"have >1 identically-normalised candidate (the round-2 rule)")
print("pass-B scope: " + ", ".join(f"{k}={v}" for k, v in collections.Counter(r["passB_scope"] for r in rows).most_common()))
print("pass-B tier:  " + ", ".join(f"{k or '(none)'}={v}" for k, v in collections.Counter(r["passB_tier"] for r in rows).most_common()))

mapped = [r for r in rows if r["passB_verdict"] in ("EXACT", "FUZZY")]
anc = [r for r in mapped if r["passB_ancestor_level_match"] is True]
print(f"\nmapped {len(mapped)}; of them target level<=2 or non-leaf ('mapped to an ancestor'): "
      f"{len(anc)} ({100*len(anc)/len(mapped):.1f}%), products {sum(int(r['products']) for r in anc)}")
coll = collections.Counter(r["passB_shopify_id"] for r in mapped)
multi = {k: v for k, v in coll.items() if v > 1}
print(f"taxonomy nodes receiving >1 of our nodes: {len(multi)}; our nodes collapsing: {sum(multi.values())}")

def stats(sel, label):
    ci = collections.Counter(r["passB_attrs"] for r in sel)
    names = collections.Counter()
    for r in sel:
        for a in r["passB_attrs"].split(" | "):
            if a: names[a] += 1
    med = sorted(int(r["passB_n_attrs"]) for r in sel)[len(sel)//2] if sel else 0
    print(f"  {label}: {len(sel)} nodes, {len(ci)} distinct sets, {len(names)} distinct names, median {med} attrs")
    return names
print("\ninferred attribute need:")
n_all = stats(mapped, "all mapped")
n_eq = stats([r for r in mapped if r["passB_ancestor_level_match"] is not True], "equivalent-level only")

cum = 0; top = []
for r in rows:
    cum += int(r["products"]); top.append(r)
    if cum >= 0.9 * totp: break
print(f"\nthe {len(top)} nodes covering 90% (deterministic cut, -products then id): " +
      ", ".join(f"{k}={v}" for k, v in collections.Counter(r["passB_verdict"] for r in top).most_common()))
t_m = [r for r in top if r["passB_verdict"] in ("EXACT", "FUZZY")]
n90 = set(); n90eq = set()
for r in t_m:
    s = set(x for x in r["passB_attrs"].split(" | ") if x)
    n90 |= s
    if r["passB_ancestor_level_match"] is not True: n90eq |= s
print(f"  mapped {len(t_m)}; distinct attribute names {len(n90)}; "
      f"equivalent-level only {len([r for r in t_m if r['passB_ancestor_level_match'] is not True])} nodes / {len(n90eq)} names")
json.dump(sorted(n90), open(f"{BASE}/data/shopify-attrs-for-our-90pct.json", "w"), indent=0, ensure_ascii=False)
json.dump(sorted(n90eq), open(f"{BASE}/data/shopify-attrs-for-our-90pct-equivalent-level.json", "w"), indent=0, ensure_ascii=False)
q = [r for r in rows if r["has_qualifier"]]
print(f"\nour used nodes whose NAME carries a gender/age qualifier: {len(q)} ({100*len(q)/tot:.1f}%), "
      f"{sum(int(r['products']) for r in q)} products ({100*sum(int(r['products']) for r in q)/totp:.1f}%)")
print(f"  of them mapped by the stripped tiers: "
      f"{sum(1 for r in q if r['passB_tier'] in ('exact-stripped','fuzzy-stripped'))}")
