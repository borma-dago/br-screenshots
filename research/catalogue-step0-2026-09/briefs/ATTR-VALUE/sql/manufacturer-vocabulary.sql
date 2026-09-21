-- ATTR-VALUE A4 §5 · the shape of the one real attribute vocabulary we have (manufacturer).
-- Asks: if a value were a shared option row instead of a free string, how many rows, how much
-- collapse, and what does the tail look like?
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
manu AS (SELECT pav.product_id, pav.value_text AS v FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='manufacturer'),
-- normalisation ladder, each step strictly stronger than the last
norm AS (
  SELECT v,
    TRIM(v) AS n1_trim,
    LOWER(TRIM(v)) AS n2_lower,
    REGEXP_REPLACE(LOWER(TRIM(v)), r'\s+', ' ') AS n3_ws,
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(TRIM(v)), r'[^a-z0-9 ]', ' '), r'\s+', ' ')) AS n4_punct
  FROM manu),
cnt AS (SELECT v, COUNT(*) k FROM manu GROUP BY v)
SELECT 'rows_total' AS measure, CAST(COUNT(*) AS STRING) AS value FROM manu UNION ALL
SELECT 'distinct_raw', CAST(COUNT(DISTINCT v) AS STRING) FROM manu UNION ALL
SELECT 'distinct_trim', CAST(COUNT(DISTINCT n1_trim) AS STRING) FROM norm UNION ALL
SELECT 'distinct_trim_lower', CAST(COUNT(DISTINCT n2_lower) AS STRING) FROM norm UNION ALL
SELECT 'distinct_trim_lower_ws', CAST(COUNT(DISTINCT n3_ws) AS STRING) FROM norm UNION ALL
SELECT 'distinct_alnum_only', CAST(COUNT(DISTINCT n4_punct) AS STRING) FROM norm UNION ALL
SELECT 'values_used_once', CAST(COUNTIF(k=1) AS STRING) FROM cnt UNION ALL
SELECT 'values_used_2_to_5', CAST(COUNTIF(k BETWEEN 2 AND 5) AS STRING) FROM cnt UNION ALL
SELECT 'values_used_6_to_20', CAST(COUNTIF(k BETWEEN 6 AND 20) AS STRING) FROM cnt UNION ALL
SELECT 'values_used_21_to_100', CAST(COUNTIF(k BETWEEN 21 AND 100) AS STRING) FROM cnt UNION ALL
SELECT 'values_used_over_100', CAST(COUNTIF(k>100) AS STRING) FROM cnt UNION ALL
SELECT 'rows_covered_by_values_used_once', CAST(SUM(IF(k=1,k,0)) AS STRING) FROM cnt UNION ALL
SELECT 'rows_covered_by_top_100_values', CAST((SELECT SUM(k) FROM (SELECT k FROM cnt ORDER BY k DESC LIMIT 100)) AS STRING) UNION ALL
SELECT 'rows_covered_by_top_500_values', CAST((SELECT SUM(k) FROM (SELECT k FROM cnt ORDER BY k DESC LIMIT 500)) AS STRING) UNION ALL
SELECT 'value_len_max', CAST(MAX(LENGTH(v)) AS STRING) FROM manu UNION ALL
SELECT 'value_len_p50', CAST(CAST(APPROX_QUANTILES(LENGTH(v),100)[OFFSET(50)] AS INT64) AS STRING) FROM manu UNION ALL
SELECT 'value_len_p99', CAST(CAST(APPROX_QUANTILES(LENGTH(v),100)[OFFSET(99)] AS INT64) AS STRING) FROM manu UNION ALL
SELECT 'values_with_leading_or_trailing_space', CAST(COUNTIF(v != TRIM(v)) AS STRING) FROM manu UNION ALL
SELECT 'values_with_double_space', CAST(COUNTIF(REGEXP_CONTAINS(v, r'  ')) AS STRING) FROM manu UNION ALL
SELECT 'distinct_that_are_case_variants', CAST((SELECT COUNT(*) FROM (SELECT n2_lower FROM norm GROUP BY n2_lower HAVING COUNT(DISTINCT v)>1)) AS STRING) UNION ALL
SELECT 'distinct_no_ascii_letter', CAST((SELECT COUNT(DISTINCT v) FROM manu WHERE NOT REGEXP_CONTAINS(v, r'[A-Za-z]')) AS STRING) UNION ALL
SELECT 'distinct_after_dropping_no_letter', CAST((SELECT COUNT(DISTINCT LOWER(TRIM(v))) FROM manu WHERE REGEXP_CONTAINS(v, r'[A-Za-z]')) AS STRING) UNION ALL
SELECT 'rows_after_dropping_no_letter', CAST((SELECT COUNT(*) FROM manu WHERE REGEXP_CONTAINS(v, r'[A-Za-z]')) AS STRING)
ORDER BY measure
