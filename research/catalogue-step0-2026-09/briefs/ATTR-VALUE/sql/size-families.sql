-- ATTR-VALUE A4 §5 · the D9-versus-V4 measurement.
-- Builds de-facto size families from titles: strip the mass/volume quantity token, group on the
-- residue, keep groups with >=2 DISTINCT quantity labels. Then asks, per group, whether sorting
-- the labels as TEXT gives the same order as sorting them by MAGNITUDE (converted to g / ml).
-- Deliberately narrow regex: only GR|GRAM|KG (mass) and ML|LTR (volume) immediately after a
-- number. The instrument check (unit-token-instrument-check.sql) showed bare L / M / G also match
-- garment sizes and supplier codes, so bare G and bare L are excluded here.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
x AS (
  SELECT id, UPPER(title) AS u,
    REGEXP_EXTRACT(UPPER(title), r'([0-9]+(?:[.,][0-9]+)?)\s?(?:GR|GRAM|KG|ML|LTR)\b') AS mag,
    REGEXP_EXTRACT(UPPER(title), r'[0-9]+(?:[.,][0-9]+)?\s?(GR|GRAM|KG|ML|LTR)\b') AS un
  FROM p WHERE REGEXP_CONTAINS(UPPER(title), r'[0-9]+(?:[.,][0-9]+)?\s?(?:GR|GRAM|KG|ML|LTR)\b')),
y AS (
  SELECT id, u, CONCAT(mag,' ',un) AS label,
    CASE un WHEN 'KG' THEN SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64)*1000
            WHEN 'LTR' THEN SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64)*1000
            ELSE SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64) END AS base_amount,
    IF(un IN ('GR','GRAM','KG'),'mass','volume') AS dimension,
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(u, r'[0-9]+(?:[.,][0-9]+)?\s?(?:GR|GRAM|KG|ML|LTR)\b',' '), r'\s+',' ')) AS stem
  FROM x),
d AS (SELECT DISTINCT stem, label, base_amount, dimension FROM y WHERE stem != '' AND base_amount IS NOT NULL),
cnt AS (SELECT stem, COUNT(*) AS products FROM y WHERE stem != '' AND base_amount IS NOT NULL GROUP BY stem),
g AS (
  SELECT d.stem,
    COUNT(DISTINCT d.dimension) AS dimensions,
    MIN(d.dimension) AS dimension,
    COUNT(*) AS distinct_labels,
    STRING_AGG(d.label, ' | ' ORDER BY d.label) AS text_order,
    STRING_AGG(d.label, ' | ' ORDER BY d.base_amount) AS magnitude_order
  FROM d GROUP BY d.stem HAVING COUNT(*) >= 2)
SELECT g.stem, cnt.products, g.distinct_labels, g.dimensions, g.dimension,
       g.text_order, g.magnitude_order,
       g.text_order = g.magnitude_order AS text_sort_is_correct
FROM g JOIN cnt USING (stem)
ORDER BY cnt.products DESC, g.stem
