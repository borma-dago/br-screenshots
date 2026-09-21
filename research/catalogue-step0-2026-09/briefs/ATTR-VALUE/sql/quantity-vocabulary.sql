-- ATTR-VALUE A4 §5 · the size-label vocabulary, and the coverage of the narrow (mass|volume) regex.
-- Asks: how many products would carry a typed net-content value, and how big is the LABEL list
-- that V4's "hand-ordered position column" would have to curate?
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
x AS (SELECT id, UPPER(title) u,
        REGEXP_EXTRACT(UPPER(title), r'([0-9]+(?:[.,][0-9]+)?)\s?(?:GR|GRAM|KG|ML|LTR)\b') mag,
        REGEXP_EXTRACT(UPPER(title), r'[0-9]+(?:[.,][0-9]+)?\s?(GR|GRAM|KG|ML|LTR)\b') un
      FROM p),
y AS (SELECT *, CONCAT(mag,' ',un) label,
        CASE un WHEN 'KG' THEN SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64)*1000
                WHEN 'LTR' THEN SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64)*1000
                ELSE SAFE_CAST(REPLACE(mag,',','.') AS FLOAT64) END base_amount
      FROM x WHERE un IS NOT NULL)
SELECT 'products_total' m, CAST(COUNT(*) AS STRING) v FROM p UNION ALL
SELECT 'products_with_mass_or_volume_token', CAST(COUNT(*) AS STRING) FROM y UNION ALL
SELECT 'distinct_labels_all', CAST(COUNT(DISTINCT label) AS STRING) FROM y UNION ALL
SELECT 'distinct_magnitudes_all', CAST(COUNT(DISTINCT mag) AS STRING) FROM y UNION ALL
SELECT 'distinct_units_all', CAST(COUNT(DISTINCT un) AS STRING) FROM y UNION ALL
SELECT 'labels_used_once', CAST((SELECT COUNTIF(k=1) FROM (SELECT label, COUNT(*) k FROM y GROUP BY label)) AS STRING) UNION ALL
SELECT 'labels_covering_90pct_of_products', CAST((SELECT MIN(rk) FROM (SELECT ROW_NUMBER() OVER (ORDER BY k DESC) rk, SUM(k) OVER (ORDER BY k DESC ROWS UNBOUNDED PRECEDING) cum FROM (SELECT label, COUNT(*) k FROM y GROUP BY label)) WHERE cum >= 0.9*(SELECT COUNT(*) FROM y)) AS STRING) UNION ALL
SELECT 'magnitude_not_parseable', CAST(COUNTIF(base_amount IS NULL) AS STRING) FROM y UNION ALL
SELECT 'products_with_2plus_tokens_in_title', CAST(COUNTIF(ARRAY_LENGTH(REGEXP_EXTRACT_ALL(u, r'[0-9]+(?:[.,][0-9]+)?\s?(?:GR|GRAM|KG|ML|LTR)\b'))>1) AS STRING) FROM y UNION ALL
SELECT 'unit_spellings_for_gram', CAST(COUNT(DISTINCT un) AS STRING) FROM y WHERE un IN ('GR','GRAM','KG') UNION ALL
SELECT 'unit_spellings_for_litre', CAST(COUNT(DISTINCT un) AS STRING) FROM y WHERE un IN ('ML','LTR')
ORDER BY m
