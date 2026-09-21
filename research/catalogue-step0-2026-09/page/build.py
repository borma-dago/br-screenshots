#!/usr/bin/env python3
"""Build the Step Zero Decisions page (v2) from the v1 page + decisions/*.json + costs.json.

v1 supplies: CSS, header, dependency figure, section heads, per-card head/options/recommendation/reopen/links,
summary section and the db-backed decision script. This script inserts, per card, the matrix-style blocks:
  Answer · Who (score) · caveats  →  sub-tallies  →  Reading  →  Platform by platform (exact shape, <details>)
  →  What each answer would cost us.
"""
import json, re, html, glob, os

S = os.path.dirname(os.path.abspath(__file__))
V1 = open(os.path.join(S, 'step-zero-decisions-v1.html'), encoding='utf-8').read()
DATA = {os.path.basename(p)[:-5]: json.load(open(p, encoding='utf-8')) for p in glob.glob(os.path.join(S, 'decisions', '*.json')) if not p.endswith(('costs.json', 'instances.json'))}
COSTS = json.load(open(os.path.join(S, 'decisions', 'costs.json'), encoding='utf-8'))
MODELS = {os.path.basename(p)[:-5]: json.load(open(p, encoding='utf-8')) for p in glob.glob(os.path.join(S, 'decisions', 'models', '*.json'))}
INSTANCES = json.load(open(os.path.join(S, 'decisions', 'instances.json'), encoding='utf-8'))
PLAT_ANCHOR = {'Amazon':'Amazon','Shopify':'Shopify','eBay':'eBay','Google':'Google Merchant Center','Walmart':'Walmart Marketplace','Shopee':'Shopee','Magento':'Magento / Adobe Commerce','WooCommerce':'WooCommerce','Salesforce B2C':'Salesforce B2C','Tokopedia':'Tokopedia / TikTok Shop','Square':'Square','commercetools':'commercetools','Akeneo':'Akeneo PIM'}
def anchor_id(name): return 'inst-' + re.sub(r'[^a-z0-9]+', '-', name.lower()).strip('-')

SCORE = {'Amazon': 100, 'Shopify': 85, 'eBay': 80, 'Google': 70, 'Walmart': 65, 'Shopee': 60, 'Magento': 60,
         'WooCommerce': 55, 'Salesforce B2C': 50, 'Tokopedia': 45, 'Square': 40, 'commercetools': 35, 'Akeneo': 30}
GAP = 'gap-pass-2026-09-21'

def score_of(name):
    base = name.split(' (')[0].replace(' Era A', '').replace(' Era B', '').strip()
    for k, v in SCORE.items():
        if base.startswith(k):
            return v
    return 0

def chip(name):
    s = score_of(name)
    label = html.escape(name)
    return f'<span class="pf"><span class="pf-n">{label}</span><span class="pf-s">{s}</span></span>'

def chips(names):
    names = sorted(names, key=lambda n: -score_of(n))
    return ' '.join(chip(n) for n in names) if names else '<span class="none">—</span>'

# ---------- split v1 into pieces ----------
head_end = V1.index('<!-- ============================ A ============================ -->')
PRELUDE = V1[:head_end]
summary_start = V1.index('<!-- ============================ SUMMARY ============================ -->')
POSTLUDE = V1[summary_start:]
BODY = V1[head_end:summary_start]

# extra CSS for the new blocks, injected before </style>
EXTRA_CSS = '''
/* v2 — matrix-style blocks */
.blk{padding:14px 20px;border-top:1px solid var(--line);display:grid;gap:8px}
.blk h4{margin:0;font-size:.74rem;letter-spacing:.07em;text-transform:uppercase;color:var(--ink-3);font-weight:600}
.blk p{font-size:.92rem}
.ans{width:100%;border-collapse:collapse;font-size:.9rem}
.ans th{text-align:left;font-size:.72rem;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);padding:6px 8px;border-bottom:1px solid var(--line)}
.ans td{padding:9px 8px;border-bottom:1px solid var(--line);vertical-align:top}
.ans td.a{font-weight:600;width:24%}
.ans td.a .n{display:inline-block;margin-left:6px;font-variant-numeric:tabular-nums;font-weight:600;font-size:.78rem;padding:1px 7px;border-radius:999px;background:var(--surface-2);color:var(--ink-2)}
.ans td.a.rec{color:var(--accent-ink)}
.ans td.w{width:30%}
.ans td.c{color:var(--ink-2);font-size:.86rem}
.ans td.c ul{margin:0;padding-left:16px;display:grid;gap:3px}
.pf{display:inline-flex;align-items:stretch;margin:2px 4px 2px 0;border:1px solid var(--line-strong);border-radius:6px;overflow:hidden;font-size:.8rem;line-height:1.35;vertical-align:middle}
.pf-n{padding:2px 7px;background:var(--surface)}
.pf-s{padding:2px 6px;background:var(--surface-2);color:var(--ink-2);font-variant-numeric:tabular-nums;font-weight:600;border-left:1px solid var(--line)}
.none{color:var(--ink-3)}
.sub{display:grid;gap:8px}
.sub table{border-collapse:collapse;font-size:.84rem;width:100%}
.sub th{text-align:left;padding:4px 8px;font-weight:600;color:var(--ink-2);background:var(--surface-2);font-size:.8rem}
.sub td{padding:4px 8px;border-bottom:1px solid var(--line);vertical-align:top}
.sub td:first-child{width:34%;color:var(--ink-2)}
.reading{background:var(--surface-2);border-radius:8px;padding:10px 12px;font-size:.9rem;color:var(--ink-2)}
details.shape{border:1px solid var(--line);border-radius:8px;background:var(--surface)}
details.shape summary{cursor:pointer;padding:10px 14px;font-weight:600;font-size:.9rem;color:var(--accent-ink);list-style:none;display:flex;gap:10px;align-items:center}
details.shape summary::-webkit-details-marker{display:none}
details.shape summary::before{content:"▸";font-size:.9rem;color:var(--ink-3);transition:transform .15s}
details.shape[open] summary::before{transform:rotate(90deg)}
details.shape summary .hint{font-weight:400;color:var(--ink-3);font-size:.82rem}
.shape-wrap{overflow-x:auto;border-top:1px solid var(--line)}
.shape-t{width:100%;border-collapse:collapse;font-size:.86rem;min-width:760px}
.shape-t th{text-align:left;font-size:.72rem;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);padding:8px 10px;border-bottom:1px solid var(--line);background:var(--surface-2);position:sticky;top:0}
.shape-t td{padding:10px;border-bottom:1px solid var(--line);vertical-align:top}
.shape-t td.s{font-variant-numeric:tabular-nums;font-weight:600;color:var(--ink-2);width:44px}
.shape-t td.p{font-weight:600;white-space:nowrap;width:120px}
.shape-t td.p .h{display:block;font-weight:400;font-size:.78rem;color:var(--ink-3);white-space:normal;margin-top:3px;max-width:160px}
.shape-t td.o{width:110px}
.shape-t td.o .tag{font-size:.74rem;font-weight:700;letter-spacing:.04em;padding:2px 7px;border-radius:5px;background:var(--surface-2);color:var(--ink-2);white-space:nowrap}
.shape-t td.o .tag.rec{background:var(--accent-soft);color:var(--accent-ink)}
.shape-t td.x{line-height:1.5}
.shape-t td.x code{font-size:.82em}
.shape-t td.ci{font-size:.76rem;color:var(--ink-3);width:150px;font-family:"IBM Plex Mono",monospace}
.shape-t tr.gap td{background:color-mix(in srgb,var(--ok-soft) 45%,var(--surface))}
.gapmark{display:inline-block;font-size:.68rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;padding:1px 6px;border-radius:4px;background:var(--ok-soft);color:var(--ok);margin-left:6px;vertical-align:middle}
.costs{width:100%;border-collapse:collapse;font-size:.86rem}
.costs th{text-align:left;font-size:.72rem;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);padding:6px 8px;border-bottom:1px solid var(--line)}
.costs td{padding:8px;border-bottom:1px solid var(--line);vertical-align:top;line-height:1.5}
.costs td:first-child{font-weight:600;width:22%}
.costs td:nth-child(2){width:26%}
.costs td:last-child{color:var(--ink-2);font-size:.82rem;width:16%}
.tablewrap-x{overflow-x:auto}
.model{display:grid;grid-template-columns:max-content 1fr;gap:4px 12px;font-size:.84rem}
.model .k{font-size:.7rem;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);font-weight:600;padding-top:3px;white-space:nowrap}
.model .v{line-height:1.5}
.model .v pre{margin:4px 0 2px;padding:8px 10px;background:var(--code-bg);border-radius:6px;font-size:.78rem;line-height:1.4;overflow-x:auto;white-space:pre}
.model .v code{font-size:.9em}
details.raw{margin-top:6px}
details.raw summary{cursor:pointer;font-size:.76rem;color:var(--ink-3);list-style:none}
details.raw summary::before{content:"▸ ";color:var(--ink-3)}
details.raw[open] summary::before{content:"▾ "}
details.raw .prose{font-size:.82rem;color:var(--ink-2);padding:6px 0 0;line-height:1.5}
.shape-t td.x{min-width:420px}
.pbl{display:grid;gap:10px;padding:12px 14px;border-top:1px solid var(--line)}
.pb{border:1px solid var(--line);border-radius:8px;padding:10px 14px 12px;background:var(--surface)}
.pb.gap{border-color:color-mix(in srgb,var(--ok) 50%,var(--line));background:color-mix(in srgb,var(--ok-soft) 30%,var(--surface))}
.pbh{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:8px;padding-bottom:8px;border-bottom:1px dashed var(--line)}
.pbh .s{font-variant-numeric:tabular-nums;font-weight:700;color:var(--ink-3);font-size:.85rem;min-width:28px}
.pbh .p{font-weight:700;font-size:1rem}
.pbh .tag{font-size:.74rem;font-weight:700;letter-spacing:.04em;padding:2px 7px;border-radius:5px;background:var(--surface-2);color:var(--ink-2)}
.pbh .tag.rec{background:var(--accent-soft);color:var(--accent-ink)}
.pbh .hint{font-size:.8rem;color:var(--ink-3)}
.pbh .ci{margin-left:auto;font-size:.74rem;color:var(--ink-3);font-family:"IBM Plex Mono",monospace}
.pbh .ci a{font-family:"IBM Plex Sans",system-ui,sans-serif}
.model{grid-template-columns:190px minmax(0,1fr);min-width:0}
.model .k{white-space:normal;line-height:1.3}
.model .v{min-width:0;overflow-wrap:anywhere}
.pb,.pbl,details.shape,.blk{min-width:0}
.pbh{min-width:0}
.pbh .ci{max-width:100%;overflow-wrap:anywhere}
.exlegend{font-size:.76rem;color:var(--ink-3);padding:6px 14px 10px}
.inst-grid{display:grid;gap:14px}
.inst{background:var(--surface);border:1px solid var(--line);border-radius:12px;box-shadow:var(--shadow);overflow:hidden}
.inst .ih{padding:14px 20px 8px;display:flex;gap:12px;align-items:baseline;flex-wrap:wrap}
.inst .ih .sc{font-variant-numeric:tabular-nums;font-weight:700;color:var(--ink-3);font-size:.9rem}
.inst .ih h3{font-size:1.15rem}
.inst .ih .sub{color:var(--ink-2);font-size:.88rem;flex-basis:100%}
.inst .route{padding:0 20px 8px;font-size:.82rem;color:var(--ink-3)}
.inst pre{margin:0;padding:12px 20px;background:var(--code-bg);font-size:.78rem;line-height:1.45;overflow-x:auto;white-space:pre;border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.inst .cut{padding:10px 20px;font-size:.82rem;color:var(--ink-2)}
.inst .fm{display:grid;grid-template-columns:max-content 1fr;gap:4px 14px;padding:4px 20px 16px;font-size:.84rem}
.inst .fm .k{font-family:"IBM Plex Mono",monospace;font-size:.78rem;color:var(--accent-ink);padding-top:2px}
.inst .fm .d{color:var(--ink-2)}
@media (max-width:760px){ .model{grid-template-columns:1fr} .inst .fm{grid-template-columns:1fr} }
@media (max-width:760px){ .ans td.a,.ans td.w{width:auto} .ans{display:block} .ans thead{display:none} .ans tr{display:grid;gap:4px;padding:8px 0;border-bottom:1px solid var(--line)} .ans td{border:0;padding:2px 0} }
'''
PRELUDE = PRELUDE.replace('</style>', EXTRA_CSS + '</style>', 1)

# ---------- per-card rendering ----------
def rec_keys(card):
    """Options marked recommended in the v1 options list → which option keys are 'rec' in the data.
    We mark by explicit list per card (kept small and reviewable)."""
    return {
        'A1': {'O1'}, 'A2': {'P1'}, 'A0': {'V1'}, 'A3': {'a', 'a′'}, 'A4': {'c'}, 'A5': {'a'},
        'C1': {'ii'}, 'C2': {'a', 'c'}, 'C3': {'a'}, 'B1': {'c'}, 'B2': {'c'}, 'B3': {'b'}, 'B4': {'d', 'b'}, 'FORK': {'a'},
    }.get(card, set())

def answer_block(cid, d):
    opts = d['options']; rows = d['rows']; recs = rec_keys(cid)
    order = list(opts.keys())
    groups = {k: [] for k in order}
    for r in rows:
        groups.setdefault(r['o'], []).append(r)
    trs = []
    for k in order:
        rs = sorted(groups.get(k, []), key=lambda r: -r['s'])
        if not rs and k in ('AMB', 'NE', 'NC', 'NT', 'NA', 'BOTH', 'NONE'):
            continue
        who = chips([r['p'] for r in rs])
        cav = ''.join(f'<li><b>{html.escape(r["p"])}</b> — {html.escape(r["h"])}</li>' for r in rs if r.get('h'))
        cav = f'<ul>{cav}</ul>' if cav else '<span class="none">no hedge on the record</span>'
        cls = 'a rec' if k in recs else 'a'
        trs.append(f'<tr><td class="{cls}">{opts[k]}<span class="n">{len(rs)}</span></td><td class="w">{who}</td><td class="c">{cav}</td></tr>')
    return f'<div class="blk"><h4>Who gives which answer · tried-and-tested score beside each name</h4><table class="ans"><thead><tr><th>Answer</th><th>Who</th><th>The caveats that sit inside the group</th></tr></thead><tbody>{"".join(trs)}</tbody></table></div>'

def subtally_block(d):
    subs = d.get('subtallies') or []
    if not subs:
        return ''
    out = []
    for st in subs:
        trs = ''.join(f'<tr><td>{html.escape(a)}</td><td>{chips(b) if b and score_of(b[0]) else (", ".join(html.escape(x) for x in b) if b else "<span class=none>—</span>")}</td></tr>' for a, b in st['cells'])
        out.append(f'<table><thead><tr><th colspan="2">{html.escape(st["name"])}</th></tr></thead><tbody>{trs}</tbody></table>')
    return f'<div class="blk sub"><h4>Sub-tallies</h4>{"".join(out)}</div>'

def reading_block(d):
    parts = []
    for k in ('unanimous', 'framing', 'hedges', 'brand', 'coupling', 'meta'):
        if d.get(k):
            parts.append(f'<p><b>{k.capitalize() if k not in ("unanimous",) else "Unanimous"}:</b> {html.escape(d[k])}</p>' if k != 'framing' else f'<p>{html.escape(d[k])}</p>')
    if not parts:
        return ''
    return f'<div class="blk"><h4>Reading</h4><div class="reading">{"".join(parts)}</div></div>'

def shape_block(cid, d):
    opts = d['options']; recs = rec_keys(cid)
    rows = sorted(d['rows'], key=lambda r: -r['s'])
    keys = (MODELS.get(cid) or {}).get('keys', [])
    blocks = []
    for r in rows:
        gap = GAP in (r.get('cite') or '')
        tag = f'<span class="tag{" rec" if r["o"] in recs else ""}">{html.escape(r["o"])}</span>'
        hint = f'<span class="hint">{html.escape(r["h"])}</span>' if r.get('h') else ''
        mark = '<span class="gapmark">gap pass 21 Sep</span>' if gap else ''
        model = (MODELS.get(cid) or {}).get('rows', {}).get(r['p'])
        if model:
            kv = ''.join(f'<div class="k">{html.escape(k)}</div><div class="v">{model.get(k)}</div>' for k in keys if model.get(k))
            body = f'<div class="model">{kv}</div><details class="raw"><summary>the record\'s words, unstructured</summary><div class="prose">{r["shape"]}</div></details>'
        else:
            body = f'<div class="prose">{r["shape"]}</div>'
        inst_link = f'<a href="#{anchor_id(PLAT_ANCHOR.get(r["p"], r["p"]))}">real instance ↓</a>'
        blocks.append(f'<div class="pb{" gap" if gap else ""}"><div class="pbh"><span class="s">{r["s"]}</span><span class="p">{html.escape(r["p"])}</span>{tag}{mark}{hint}<span class="ci">{html.escape(r.get("cite",""))} · {inst_link}</span></div>{body}</div>')
    legend = ' · '.join(f'<b>{html.escape(k)}</b> {html.escape(v)}' for k, v in opts.items())
    return (f'<div class="blk"><details class="shape"><summary>Platform by platform — the exact shape <span class="hint">13 platforms · sorted by tried-and-tested score · structured from the record; the record\'s own prose folded under each</span></summary>'
            f'<div class="pbl">{"".join(blocks)}</div>'
            f'<p class="exlegend">Examples: <b>●</b> verbatim from the record or a vendor sample · <b>◇</b> illustrative — built only from the documented field names and types, not a retrieved object. Answer keys: {legend}</p></details></div>')

def costs_block(cid):
    rows = COSTS.get(cid)
    if not rows:
        return ''
    trs = ''.join(f'<tr><td>{o}</td><td>{g}</td><td>{c}</td><td>{s}</td></tr>' for o, g, c, s in rows)
    return f'<div class="blk"><h4>What each answer would cost us — inference from our own code and data; the last column is evidence</h4><div class="tablewrap-x"><table class="costs"><thead><tr><th>Option</th><th>What we gain</th><th>What it costs</th><th>Who ships this shape</th></tr></thead><tbody>{trs}</tbody></table></div></div>'

# ---------- rewrite each card ----------
card_re = re.compile(r'(<article class="card [^"]*" data-id="([^"]+)">)(.*?)(</article>)', re.S)

def rewrite(m):
    open_tag, cid, inner, close = m.group(1), m.group(2), m.group(3), m.group(4)
    if cid not in DATA:
        return m.group(0)  # lock-amendment cards: unchanged
    d = DATA[cid]
    # v1 inner: card-head, grid (4 cells), foot, decide
    grid_m = re.search(r'<div class="grid">(.*?)</div>\s*<div class="foot">', inner, re.S)
    cells = re.findall(r'<div class="cell(?: wide)?">(.*?)</div>\s*(?=<div class="cell|$)', grid_m.group(1) + '\n', re.S)
    # cells: [options, who, recommendation, reopen]
    options_cell = cells[0]; rec_cell = cells[2]; reopen_cell = cells[3]
    head = inner[:inner.index('<div class="grid">')]
    foot_and_decide = inner[inner.index('<div class="foot">'):]
    new_inner = (head
                 + f'<div class="grid"><div class="cell wide">{options_cell}</div></div>'
                 + answer_block(cid, d)
                 + subtally_block(d)
                 + reading_block(d)
                 + shape_block(cid, d)
                 + costs_block(cid)
                 + f'<div class="grid"><div class="cell">{rec_cell}</div><div class="cell">{reopen_cell}</div></div>'
                 + foot_and_decide)
    return open_tag + new_inner + close

BODY2 = card_re.sub(rewrite, BODY)

# header tweak: date + note on the gap pass
PRELUDE = PRELUDE.replace('research of 2026-09-19 · page of 2026-09-21', 'research of 2026-09-19 · gap pass 2026-09-21 · page v2 of 2026-09-21')
PRELUDE = PRELUDE.replace('<p class="lede">Thirteen concept questions',
    '<p class="lede">Modelled on the Catalogue Decision Matrix: for every decision, the answer, who gives it (tried-and-tested score beside each name — Amazon 100 … Akeneo 30, the matrix\'s own scale), the caveats inside each group, then platform by platform the exact shape in the record\'s own words — objects, fields, value types, caps — and what each answer would cost us. Thirteen concept questions')

def instances_section():
    blocks = []
    for name, d in sorted(INSTANCES.items(), key=lambda kv: -kv[1]['score']):
        fm = ''.join(f'<span class="k">{html.escape(k)}</span><span class="d">{html.escape(v)}</span>' for k, v in d['fieldmap'])
        blocks.append(f'<article class="inst" id="{anchor_id(name)}"><div class="ih"><span class="sc">{d["score"]}</span><h3>{html.escape(name)}</h3><span class="sub">{html.escape(d["subtitle"])}</span></div>'
                      f'<p class="route">{html.escape(d["route"])}</p><pre>{html.escape(d["instance"])}</pre><p class="cut">{html.escape(d["cut"])}</p><div class="fm">{fm}</div></article>')
    return ('<section class="group" id="grp-i"><div class="group-head"><h2>One real instance per platform</h2>'
            '<p>Verbatim from the thirteen records as the Catalogue Decision Matrix printed them (extracted 2026-09-09, sorted by the tried-and-tested score): an object the platform itself emitted or published — a live capture where one exists, otherwise the vendor\'s own sample. Nothing constructed; elisions marked; what is missing stated. The field map says what each key is in that platform\'s model. Every platform row above links here.</p></div>'
            f'<div class="inst-grid">{"".join(blocks)}</div></section>')

PRELUDE = PRELUDE.replace('<a href="#grp-l">Lock wording</a>', '<a href="#grp-l">Lock wording</a><a href="#grp-i">Instances</a>')
OUT = PRELUDE + BODY2 + instances_section() + POSTLUDE
open(os.path.join(S, 'step-zero-decisions-v2.html'), 'w', encoding='utf-8').write(OUT)
print('wrote', len(OUT), 'bytes;', len(DATA), 'cards with data;', sum(len(d['rows']) for d in DATA.values()), 'platform rows')
