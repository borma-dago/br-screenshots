-- fam-c3-grid.sql — C3: can a family have sub-families?
-- (1) Re-runs #10943's apparel measurement (comment 2026-08-10: 240 of 1,945 live apparel-titled
--     products carry a size token) at the 2026-09-19 snapshot, with the regexes written out.
-- (2) Measures the GRID signal that would be the only reason to want two levels: proxy families
--     whose members vary on TWO things at once (a net-content token AND the remaining words).
--     A grid is served either by one family with two axes (D6 caps at 3) or by nesting; this
--     counts how many grids exist at all.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c3-grid.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
t AS (SELECT id, main_category_id, is_active, is_public, is_offline_only, title, REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+',' ') AS nt FROM p),
ap AS (
  SELECT *,
    REGEXP_CONTAINS(nt, r'\b(KAOS|BAJU|CELANA|KEMEJA|JAKET|SERAGAM|PAKAIAN)\b') AS is_apparel,
    -- letter sizes, single or as a range ("M-XL"), plus ALL SIZE
    REGEXP_CONTAINS(nt, r'(\b(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b(\s?-\s?(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b)?|\bALL ?SIZE\b)') AS has_size_token,
    REGEXP_CONTAINS(nt, r'\b(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\s?-\s?(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b') AS has_size_range
  FROM t
),
-- net content token ("85 GR", "500 ML") as the would-be size axis
u AS (
  SELECT *,
    REGEXP_EXTRACT(nt, r'\b([0-9]+(?:[.,][0-9]+)?\s?(?:ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|CM|MM|LBR|LEMBAR))\b') AS unit_token,
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(nt, r'\b[0-9]+([.,][0-9]+)?\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|CM|MM|LBR|LEMBAR)\b',' '), r'\s+',' ')) AS rest
  FROM ap
),
v AS (SELECT *, ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(nt,' ')) w WITH OFFSET o WHERE o<3),' ') AS pfx3 FROM u),
fam AS (
  SELECT main_category_id, pfx3, COUNT(*) AS n,
    COUNT(DISTINCT unit_token) AS distinct_units,
    COUNT(DISTINCT rest) AS distinct_rest
  FROM v GROUP BY 1,2 HAVING COUNT(*) >= 2
)
SELECT 'A · apparel (#10943 re-run, 2026-09-19)' AS section, k AS bucket, CAST(v AS STRING) AS value FROM (
  SELECT 'apparel-titled, live (is_active AND is_public)' k, COUNTIF(is_apparel AND is_active AND is_public) v FROM ap UNION ALL
  SELECT 'of those, carrying a size token', COUNTIF(is_apparel AND is_active AND is_public AND has_size_token) FROM ap UNION ALL
  SELECT 'of those, the token is a RANGE (M-XL)', COUNTIF(is_apparel AND is_active AND is_public AND has_size_range) FROM ap UNION ALL
  SELECT 'apparel-titled, all rows', COUNTIF(is_apparel) FROM ap UNION ALL
  SELECT 'apparel-titled, active online', COUNTIF(is_apparel AND is_active AND NOT is_offline_only) FROM ap
)
UNION ALL
SELECT 'B · grid signal in proxy families (>=2 members)', k, CAST(v AS STRING) FROM (
  SELECT 'proxy families' k, COUNT(*) v FROM fam UNION ALL
  SELECT 'vary on net content only (units>1, rest=1)', COUNTIF(distinct_units>1 AND distinct_rest=1) FROM fam UNION ALL
  SELECT 'vary on the words only (units<=1, rest>1)', COUNTIF(distinct_units<=1 AND distinct_rest>1) FROM fam UNION ALL
  SELECT 'vary on BOTH (grid candidate)', COUNTIF(distinct_units>1 AND distinct_rest>1) FROM fam UNION ALL
  SELECT 'products inside grid candidates', SUM(IF(distinct_units>1 AND distinct_rest>1, n, 0)) FROM fam
)
ORDER BY section, bucket;
