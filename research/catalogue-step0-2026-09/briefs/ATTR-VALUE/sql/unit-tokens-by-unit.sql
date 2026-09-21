-- ATTR-VALUE A4 §5 · the net-content vocabulary hiding in titles, broken out BY UNIT.
-- Asks D9: if a quantity became a typed value, which units would it need, how many distinct
-- (magnitude, unit) pairs exist, and how many distinct raw spellings does one unit have?
-- The unit-token regex is the baseline's (sql/baseline.sql:69), extended to capture the token.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
t AS (SELECT id, UPPER(title) AS u FROM p),
hit AS (
  SELECT id, u,
    REGEXP_EXTRACT(u, r'\b([0-9]+(?:[.,][0-9]+)?)\s?(?:ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|SACHET|SCT|BOTOL|BTL|DUS|BOX|PAK|PACK|CM|MM|M|OZ|LBR|LEMBAR)\b') AS magnitude,
    REGEXP_EXTRACT(u, r'\b[0-9]+(?:[.,][0-9]+)?\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|SACHET|SCT|BOTOL|BTL|DUS|BOX|PAK|PACK|CM|MM|M|OZ|LBR|LEMBAR)\b') AS unit_token
  FROM t
  WHERE REGEXP_CONTAINS(u, r'\b[0-9]+(?:[.,][0-9]+)?\s?(?:ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|SACHET|SCT|BOTOL|BTL|DUS|BOX|PAK|PACK|CM|MM|M|OZ|LBR|LEMBAR)\b'))
SELECT unit_token,
       COUNT(*) AS products,
       COUNT(DISTINCT magnitude) AS distinct_magnitudes,
       COUNT(DISTINCT CONCAT(magnitude,' ',unit_token)) AS distinct_pairs,
       STRING_AGG(DISTINCT magnitude ORDER BY magnitude LIMIT 12) AS sample_magnitudes
FROM hit GROUP BY unit_token ORDER BY products DESC
