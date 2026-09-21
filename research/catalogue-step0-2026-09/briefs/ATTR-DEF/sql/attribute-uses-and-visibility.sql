-- attribute-uses-and-visibility.sql — ATTR-DEF · A0
-- What the five uses on the card can actually read today, as-measured and post-condition-2
-- (the four shipping dimensions leave the attribute system and become NOT NULL columns,
-- after which `manufacturer` is the entire attribute corpus).
-- The customer spec sheet renders every attribute_value except a hard-coded deny-list of one
-- code, `internalname` (ts-layer2 product-addendum-attributes-ui.component.ts:34) — a code that
-- has no ProductAttribute row any more, so the deny-list currently hides nothing.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE,
-- bounded to the shared snapshot instant so the figures are reproducible as production writes land:
-- source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')  (the column is INT64 epoch ms).
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
v AS (SELECT pav.product_id, pa.code, pav.value_text, pav.value_float, p.is_public, p.is_active, p.is_offline_only
      FROM pav JOIN pa ON pa.id = pav.attribute_id JOIN p ON p.id = pav.product_id),
online AS (SELECT * FROM p WHERE is_active AND NOT is_offline_only),
lines_per_product AS (SELECT product_id, COUNT(*) AS n FROM v GROUP BY 1)
SELECT 'spec_sheet_lines_today_all_products' AS measure, CAST(COUNT(*) AS STRING) AS value FROM v UNION ALL
SELECT 'spec_sheet_lines_today_public_products', CAST(COUNTIF(is_public) AS STRING) FROM v UNION ALL
SELECT 'spec_sheet_lines_hidden_by_the_deny_list', CAST(COUNTIF(code='internalname') AS STRING) FROM v UNION ALL
SELECT 'products_with_5_attribute_rows', CAST(COUNTIF(n=5) AS STRING) FROM lines_per_product UNION ALL
SELECT 'products_with_4_attribute_rows', CAST(COUNTIF(n=4) AS STRING) FROM lines_per_product UNION ALL
SELECT 'products_with_other_row_counts', CAST(COUNTIF(n NOT IN (4,5)) AS STRING) FROM lines_per_product UNION ALL
SELECT 'post_condition2_spec_sheet_lines_all', CAST(COUNTIF(code='manufacturer') AS STRING) FROM v UNION ALL
SELECT 'post_condition2_spec_sheet_lines_public', CAST(COUNTIF(code='manufacturer' AND is_public) AS STRING) FROM v UNION ALL
SELECT 'post_condition2_products_with_empty_spec_sheet', CAST(COUNT(*) AS STRING) FROM p WHERE id NOT IN (SELECT product_id FROM v WHERE code='manufacturer') UNION ALL
SELECT 'post_condition2_online_products_with_empty_spec_sheet', CAST(COUNT(*) AS STRING) FROM online WHERE id NOT IN (SELECT product_id FROM v WHERE code='manufacturer') UNION ALL
SELECT 'post_condition2_online_products_with_junk_only_spec_sheet', CAST(COUNT(*) AS STRING) FROM v WHERE code='manufacturer' AND NOT REGEXP_CONTAINS(value_text, r'[A-Za-z]') AND is_active AND NOT is_offline_only UNION ALL
SELECT 'dimension_rows_that_become_columns', CAST(COUNTIF(code IN ('weight','length','width','height')) AS STRING) FROM v UNION ALL
SELECT 'dimension_rows_with_value_zero', CAST(COUNTIF(code IN ('weight','length','width','height') AND value_float = 0) AS STRING) FROM v UNION ALL
SELECT 'products_with_any_zero_dimension', CAST(COUNT(DISTINCT IF(code IN ('weight','length','width','height') AND value_float = 0, product_id, NULL)) AS STRING) FROM v UNION ALL
SELECT 'products_with_all_four_dimensions_zero', CAST(COUNT(*) AS STRING) FROM (SELECT product_id FROM v WHERE code IN ('weight','length','width','height') GROUP BY 1 HAVING COUNTIF(value_float=0)=4)
ORDER BY 1;
