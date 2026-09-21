-- attribute-definitions.sql — ATTR-DEF · A1
-- Every ProductAttribute definition row, whole, with its ProductClass, its value count,
-- and whether `name` differs from `code` (the API never sends `name`; the frontend
-- renders the label from an i18n bundle keyed by `code`).
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE,
-- bounded to the shared snapshot instant so the figures are reproducible as production writes land:
-- source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')  (the column is INT64 epoch ms).
WITH
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pcl AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productclass` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE')
SELECT
  pa.id, pa.code, pa.name, pa.name = pa.code AS name_equals_code, pa.type, pa.required,
  pa.product_class_id, pcl.name AS product_class_name,
  COUNT(pav.id) AS value_rows,
  COUNTIF(pav.value_text IS NOT NULL) AS rows_value_text,
  COUNTIF(pav.value_float IS NOT NULL) AS rows_value_float,
  COUNTIF(pav.value_integer IS NOT NULL) AS rows_value_integer,
  COUNTIF(pav.value_boolean IS NOT NULL) AS rows_value_boolean,
  COUNTIF(pav.value_date IS NOT NULL) AS rows_value_date,
  COUNTIF(pav.value_datetime IS NOT NULL) AS rows_value_datetime
FROM pa
LEFT JOIN pcl ON pcl.id = pa.product_class_id
LEFT JOIN pav ON pav.attribute_id = pa.id
GROUP BY 1,2,3,4,5,6,7,8
ORDER BY pa.id;
