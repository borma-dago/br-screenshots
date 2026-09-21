#!/usr/bin/env python3
"""Do our 43 Indomie flavour phrases appear in Shopify's ONE global `Flavor` value list?

Instrument for the A3 §5 / A4 §6.5 figure "0 of 73 word tokens".
Inputs, both read-only and both already on disk:
  corpus/shopify-taxonomy/dist/en/attributes.json   (the taxonomy's 8,240 definitions)
  sql/results/indomie.csv                           (the shared baseline's 43 Indomie rows, 2026-09-19)
Written after red-team round 1 finding 20 pointed out the .out had no script beside it;
re-running it reproduces indomie_vs_shopify_flavor.out byte-for-byte.
"""
import json, os, re, csv

BASE = os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/corpus/shopify-taxonomy/dist/en/attributes.json")
ROWS = os.path.expanduser("~/copilot/research/catalogue-step0-2026-09/sql/results/indomie.csv")

attrs = json.load(open(BASE))["attributes"]
flavor = [a for a in attrs if a["handle"] == "flavor"][0]
shopify_values = {v["name"].lower() for v in flavor["values"]}

rows = list(csv.DictReader(open(ROWS)))
print(f"Shopify global 'Flavor' list: {len(shopify_values)} values")
print(f"Indomie rows in sql/results/indomie.csv: {len(rows)}")

# the distinguishing phrase = the title minus "INDOMIE" and minus the quantity token
phrases = []
for r in rows:
    t = r["title"].upper()
    t = re.sub(r'\b[0-9]+(?:[.,][0-9]+)?\s?(GR|GRAM|KG|ML|LTR)\b', '', t)
    t = t.replace("INDOMIE", "").strip()
    phrases.append(re.sub(r'\s+', ' ', t))

print(f"distinct distinguishing phrases: {len(set(phrases))}")
tokens = set()
for p in phrases:
    tokens.update(w.lower() for w in re.findall(r"[A-Z'-]+", p))
hit = sorted(tokens & shopify_values)
print(f"distinct word tokens across those phrases: {len(tokens)}")
print(f"tokens that appear verbatim in Shopify's global Flavor value list: {len(hit)} -> {hit}")
print("\nthe 43 phrases:")
for p in sorted(set(phrases)):
    print("  " + p)
