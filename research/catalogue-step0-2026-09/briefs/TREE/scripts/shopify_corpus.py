#!/usr/bin/env python3
"""Verify every Shopify Standard Product Taxonomy number the fork card asserts.
Corpus: ~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy at commit ad206247
(dist/en and dist/id-ID, build version string printed below). Read-only."""
import json, re, statistics, collections, sys

ROOT = "/home/irvan/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist"

def load_categories(locale):
    d = json.load(open(f"{ROOT}/{locale}/categories.json"))
    cats = []
    for v in d["verticals"]:
        cats.extend(v["categories"])
    return d["version"], d["verticals"], cats

def main():
    out = {}
    ver_en, verticals_en, cats_en = load_categories("en")
    ver_id, verticals_id, cats_id = load_categories("id-ID")
    out["build_version_en"] = ver_en
    out["build_version_id"] = ver_id
    out["verticals_en"] = len(verticals_en)
    out["categories_en"] = len(cats_en)
    out["categories_id"] = len(cats_id)

    attrs = json.load(open(f"{ROOT}/en/attributes.json"))["attributes"]
    attrs_id = json.load(open(f"{ROOT}/id-ID/attributes.json"))["attributes"]
    out["attribute_definitions_en"] = len(attrs)
    out["attribute_definitions_id"] = len(attrs_id)
    nvals = [len(a["values"]) for a in attrs]
    out["attribute_defs_with_zero_values"] = sum(1 for n in nvals if n == 0)
    out["attribute_values_total_en"] = sum(nvals)
    out["attribute_values_per_def_median"] = statistics.median(nvals)
    out["attribute_values_per_def_max"] = max(nvals)
    # extended (child) attributes: an attribute that specialises a base one
    out["attribute_defs_with_extended"] = sum(1 for a in attrs if a.get("extended_attributes"))

    # per-category attribute counts
    per_cat = [len(c["attributes"]) for c in cats_en]
    out["cats_with_zero_attributes"] = sum(1 for n in per_cat if n == 0)
    out["cats_with_zero_attributes_pct"] = round(100.0 * out["cats_with_zero_attributes"] / len(per_cat), 2)
    out["attributes_per_category_median"] = statistics.median(per_cat)
    out["attributes_per_category_mean"] = round(statistics.mean(per_cat), 2)
    out["attributes_per_category_max"] = max(per_cat)
    out["category_attribute_edges"] = sum(per_cat)

    # depth
    lv = collections.Counter(c["level"] for c in cats_en)
    out["level_histogram"] = dict(sorted(lv.items()))
    out["max_level"] = max(lv)
    leaves = [c for c in cats_en if not c["children"]]
    out["leaf_categories_en"] = len(leaves)
    out["internal_categories_en"] = len(cats_en) - len(leaves)
    out["leaf_level_histogram"] = dict(sorted(collections.Counter(c["level"] for c in leaves).items()))

    # inheritance test: parent -> child pairs where a parent attribute is absent from the child
    byid = {c["id"]: c for c in cats_en}
    pairs = 0; broken = 0; missing_total = 0
    child_superset = 0
    for c in cats_en:
        p = c.get("parent_id")
        if not p or p not in byid:
            continue
        pairs += 1
        pa = {a["id"] for a in byid[p]["attributes"]}
        ca = {a["id"] for a in c["attributes"]}
        miss = pa - ca
        if miss:
            broken += 1
            missing_total += len(miss)
        if pa <= ca:
            child_superset += 1
    out["parent_child_pairs"] = pairs
    out["pairs_with_parent_attr_absent_from_child"] = broken
    out["pairs_child_superset_of_parent"] = child_superset
    out["total_parent_attrs_absent_in_child"] = missing_total

    # the literal string "inherit" anywhere in the published taxonomy
    for f in ["taxonomy.json", "categories.json", "attributes.json"]:
        blob = open(f"{ROOT}/en/{f}", encoding="utf-8").read()
        out[f"inherit_occurrences_en_{f}"] = len(re.findall(r"inherit", blob, re.I))
        del blob

    # size / volume / weight / net content definitions
    pat = re.compile(r"\b(size|volume|weight|capacity|net content|net weight|quantity)\b", re.I)
    sized = [a for a in attrs if pat.search(a["name"])]
    out["defs_name_matches_size_volume_weight_capacity_qty"] = len(sized)
    pat2 = re.compile(r"(size|volume|weight)", re.I)
    sized2 = [a for a in attrs if pat2.search(a["name"])]
    out["defs_name_matches_size_volume_weight_substring"] = len(sized2)
    out["defs_size_generic_exact_name"] = [a["name"] for a in attrs if a["name"].strip().lower() in
                                           ("size", "volume", "weight", "net content", "net weight", "capacity")]
    json.dump(sorted(a["name"] for a in sized2), open("/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE/data/shopify-size-like-attribute-names.json", "w"), indent=0, ensure_ascii=False)

    # how many categories carry each size-like attribute (category-specific test)
    use = collections.Counter()
    for c in cats_en:
        for a in c["attributes"]:
            use[a["name"]] += 1
    out["size_like_defs_used_by_more_than_one_category"] = sum(1 for a in sized2 if use[a["name"]] > 1)
    out["size_like_defs_unused_by_any_category"] = sum(1 for a in sized2 if use[a["name"]] == 0)
    out["most_reused_attributes_top20"] = use.most_common(20)
    out["flavor_category_count"] = use.get("Flavor", 0)
    out["distinct_attribute_names_used_on_a_category"] = len(use)
    json.dump(use.most_common(), open("/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE/data/shopify-attribute-reuse-en.json", "w"), indent=0, ensure_ascii=False)

    # duplicate full_name paths
    for loc, cats in (("en", cats_en), ("id-ID", cats_id)):
        cnt = collections.Counter(c["full_name"] for c in cats)
        dups = {k: v for k, v in cnt.items() if v > 1}
        out[f"duplicate_full_name_paths_{loc}"] = len(dups)
        out[f"duplicate_full_name_rows_{loc}"] = sum(dups.values())
        if dups:
            json.dump(dups, open(f"/home/irvan/copilot/research/catalogue-step0-2026-09/briefs/TREE/data/shopify-duplicate-fullnames-{loc}.json", "w"), indent=1, ensure_ascii=False)
        dupname = collections.Counter(c["name"] for c in cats)
        out[f"duplicate_leaf_names_{loc}"] = sum(1 for k, v in dupname.items() if v > 1)

    # food branch
    food = [c for c in cats_en if c["full_name"].startswith("Food, Beverages & Tobacco")]
    out["food_branch_categories_en"] = len(food)
    food_leaves = [c for c in food if not c["children"]]
    out["food_branch_leaves_en"] = len(food_leaves)
    out["food_branch_max_level"] = max(c["level"] for c in food)
    out["food_branch_level_histogram"] = dict(sorted(collections.Counter(c["level"] for c in food).items()))
    fa = [len(c["attributes"]) for c in food]
    out["food_branch_attrs_per_node_median"] = statistics.median(fa)
    out["food_branch_attrs_per_node_mean"] = round(statistics.mean(fa), 2)
    out["food_branch_attrs_per_node_max"] = max(fa)
    out["food_branch_nodes_with_zero_attrs"] = sum(1 for n in fa if n == 0)
    fl = [len(c["attributes"]) for c in food_leaves]
    out["food_branch_leaf_attrs_median"] = statistics.median(fl)
    out["food_branch_leaf_attrs_mean"] = round(statistics.mean(fl), 2)
    fuse = collections.Counter()
    for c in food:
        for a in c["attributes"]:
            fuse[a["name"]] += 1
    out["food_branch_distinct_attribute_names"] = len(fuse)
    out["food_branch_attr_top25"] = fuse.most_common(25)
    # distinct attribute SETS across the food branch
    sets = collections.Counter(frozenset(a["id"] for a in c["attributes"]) for c in food)
    out["food_branch_distinct_attribute_sets"] = len(sets)
    setsl = collections.Counter(frozenset(a["id"] for a in c["attributes"]) for c in food_leaves)
    out["food_branch_leaf_distinct_attribute_sets"] = len(setsl)
    out["food_branch_leaf_count_for_sets"] = len(food_leaves)

    # whole taxonomy: distinct attribute sets vs node count
    allsets = collections.Counter(frozenset(a["id"] for a in c["attributes"]) for c in cats_en)
    out["taxonomy_distinct_attribute_sets"] = len(allsets)
    out["taxonomy_nodes_sharing_a_set_with_another"] = sum(v for v in allsets.values() if v > 1)
    leafsets = collections.Counter(frozenset(a["id"] for a in leaves[0:0]) for c in [])  # placeholder
    lsets = collections.Counter(frozenset(a["id"] for a in c["attributes"]) for c in leaves)
    out["taxonomy_leaf_distinct_attribute_sets"] = len(lsets)

    json.dump(out, sys.stdout, indent=1, ensure_ascii=False, default=str)
    print()

main()
