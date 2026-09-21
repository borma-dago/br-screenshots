-- title-facts-vs-attributes.sql — ATTR-DEF · A1
-- Which product facts exist only inside the title today, and whether the one quantity we do model
-- (`weight`, a shipping dimension) is the same fact as the net content printed in the title.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE,
-- bounded to the shared snapshot instant so the figures are reproducible as production writes land:
-- source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')  (the column is INT64 epoch ms).
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
w AS (SELECT pav.product_id, pav.value_float AS weight_gram FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='weight'),
t AS (
  SELECT p.id, p.title, p.is_active, p.is_offline_only, w.weight_gram,
         REGEXP_CONTAINS(UPPER(p.title), r'[0-9]+\s?(GR|GRAM|G|KG|ML|L|LTR|LITER|CC)\b') AS has_unit_token,
         SAFE_CAST(REGEXP_EXTRACT(UPPER(p.title), r'([0-9]+)\s?GR?\b') AS FLOAT64) AS title_gram,
         SAFE_CAST(REGEXP_EXTRACT(UPPER(p.title), r'([0-9]+)\s?KG\b') AS FLOAT64) AS title_kg,
         REGEXP_CONTAINS(UPPER(p.title), r'\b[0-9]+\s?X\s?[0-9]+\b') AS has_multiplier,
         REGEXP_CONTAINS(UPPER(p.title), r'\bISI\s?[0-9]+') AS has_isi,
         REGEXP_CONTAINS(UPPER(p.title), r'\b(PCS|PACK|PAK|RENCENG|DUS|KARTON|BOX|LUSIN)\b') AS has_pack_word
  FROM p LEFT JOIN w ON w.product_id = p.id)
SELECT 'products_total' AS measure, CAST(COUNT(*) AS STRING) AS value FROM t UNION ALL
SELECT 'title_has_unit_token', CAST(COUNTIF(has_unit_token) AS STRING) FROM t UNION ALL
SELECT 'title_has_unit_token_active_online', CAST(COUNTIF(has_unit_token AND is_active AND NOT is_offline_only) AS STRING) FROM t UNION ALL
SELECT 'title_has_multiplier_NxM', CAST(COUNTIF(has_multiplier) AS STRING) FROM t UNION ALL
SELECT 'title_has_ISI_N', CAST(COUNTIF(has_isi) AS STRING) FROM t UNION ALL
SELECT 'title_has_pack_word', CAST(COUNTIF(has_pack_word) AS STRING) FROM t UNION ALL
SELECT 'title_gram_parsed', CAST(COUNTIF(title_gram IS NOT NULL) AS STRING) FROM t UNION ALL
SELECT 'title_gram_parsed_and_weight_attr_is_zero', CAST(COUNTIF(title_gram IS NOT NULL AND weight_gram = 0) AS STRING) FROM t UNION ALL
SELECT 'title_gram_parsed_and_weight_attr_nonzero', CAST(COUNTIF(title_gram IS NOT NULL AND weight_gram > 0) AS STRING) FROM t UNION ALL
SELECT 'title_gram_equals_weight_attr', CAST(COUNTIF(title_gram IS NOT NULL AND weight_gram > 0 AND ABS(title_gram - weight_gram) < 0.5) AS STRING) FROM t UNION ALL
SELECT 'title_gram_differs_from_weight_attr', CAST(COUNTIF(title_gram IS NOT NULL AND weight_gram > 0 AND ABS(title_gram - weight_gram) >= 0.5) AS STRING) FROM t UNION ALL
SELECT 'weight_attr_zero_products', CAST(COUNTIF(weight_gram = 0) AS STRING) FROM t UNION ALL
SELECT 'weight_attr_nonzero_products', CAST(COUNTIF(weight_gram > 0) AS STRING) FROM t
ORDER BY 1;
