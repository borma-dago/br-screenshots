-- manufacturer-as-brand.sql — ATTR-DEF · A1 (sub-question: is brand an attribute or an entity?)
-- Treats the one surviving post-condition-2 attribute, `manufacturer`, as the brand candidate:
-- how many distinct values, how they spread across the category tree, how many products each
-- carries, and how many are junk. A value that spans many categories behaves like an entity;
-- a value used once behaves like a typo.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE,
-- bounded to the shared snapshot instant so the figures are reproducible as production writes land:
-- source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')  (the column is INT64 epoch ms).
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
manu AS (
  SELECT pav.product_id, pav.value_text AS v, UPPER(TRIM(pav.value_text)) AS vn,
         p.main_category_id, p.is_public, p.is_active, p.is_offline_only, p.title
  FROM pav JOIN pa ON pa.id = pav.attribute_id JOIN p ON p.id = pav.product_id
  WHERE pa.code = 'manufacturer'),
real_values AS (SELECT * FROM manu WHERE REGEXP_CONTAINS(v, r'[A-Za-z]')),
per_value AS (
  SELECT vn, COUNT(*) AS products, COUNT(DISTINCT main_category_id) AS categories
  FROM real_values GROUP BY vn)
SELECT 'distinct_values_normalised_upper_trim' AS measure, CAST(COUNT(DISTINCT vn) AS STRING) AS value FROM manu UNION ALL
SELECT 'distinct_values_with_an_ascii_letter', CAST(COUNT(DISTINCT vn) AS STRING) FROM real_values UNION ALL
SELECT 'letter_bearing_rows', CAST(COUNT(*) AS STRING) FROM real_values UNION ALL
SELECT 'values_used_on_1_product', CAST(COUNTIF(products=1) AS STRING) FROM per_value UNION ALL
SELECT 'values_used_on_ge10_products', CAST(COUNTIF(products>=10) AS STRING) FROM per_value UNION ALL
SELECT 'values_used_on_ge100_products', CAST(COUNTIF(products>=100) AS STRING) FROM per_value UNION ALL
SELECT 'values_spanning_1_category', CAST(COUNTIF(categories=1) AS STRING) FROM per_value UNION ALL
SELECT 'values_spanning_ge2_categories', CAST(COUNTIF(categories>=2) AS STRING) FROM per_value UNION ALL
SELECT 'values_spanning_ge10_categories', CAST(COUNTIF(categories>=10) AS STRING) FROM per_value UNION ALL
SELECT 'max_categories_for_one_value', CAST(MAX(categories) AS STRING) FROM per_value UNION ALL
SELECT 'rows_starting_with_PT', CAST(COUNTIF(REGEXP_CONTAINS(vn, r'^PT[\. ]')) AS STRING) FROM real_values UNION ALL
SELECT 'distinct_values_starting_with_PT', CAST(COUNT(DISTINCT IF(REGEXP_CONTAINS(vn, r'^PT[\. ]'), vn, NULL)) AS STRING) FROM real_values UNION ALL
SELECT 'rows_where_title_starts_with_value', CAST(COUNTIF(STARTS_WITH(UPPER(title), vn)) AS STRING) FROM real_values UNION ALL
SELECT 'rows_where_title_contains_value', CAST(COUNTIF(STRPOS(UPPER(title), vn) > 0) AS STRING) FROM real_values UNION ALL
SELECT 'junk_rows_on_public_active_online_products', CAST(COUNT(*) AS STRING) FROM manu WHERE NOT REGEXP_CONTAINS(v, r'[A-Za-z]') AND is_public AND is_active AND NOT is_offline_only UNION ALL
SELECT 'junk_rows_on_public_products_any', CAST(COUNT(*) AS STRING) FROM manu WHERE NOT REGEXP_CONTAINS(v, r'[A-Za-z]') AND is_public UNION ALL
SELECT 'value_0_on_public_products', CAST(COUNT(*) AS STRING) FROM manu WHERE v='0' AND is_public
ORDER BY 1;
