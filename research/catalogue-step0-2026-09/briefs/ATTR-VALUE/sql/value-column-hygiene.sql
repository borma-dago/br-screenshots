-- ATTR-VALUE A4 §5 · the six typed columns in practice: is exactly one populated per row, and does
-- the populated one match the attribute's declared type? A seventh (option) column inherits
-- whatever discipline these six already have.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
j AS (SELECT pa.code, pa.type,
        (CASE WHEN pav.value_text IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN pav.value_integer IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN pav.value_boolean IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN pav.value_float IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN pav.value_date IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN pav.value_datetime IS NOT NULL THEN 1 ELSE 0 END) AS populated,
        CASE pa.type WHEN 'text' THEN pav.value_text IS NOT NULL
                     WHEN 'float' THEN pav.value_float IS NOT NULL
                     WHEN 'integer' THEN pav.value_integer IS NOT NULL
                     WHEN 'boolean' THEN pav.value_boolean IS NOT NULL
                     ELSE NULL END AS declared_column_populated
      FROM pav JOIN pa ON pa.id = pav.attribute_id)
SELECT code, type, COUNT(*) AS n_rows,
       COUNTIF(populated = 0) AS zero_columns_populated,
       COUNTIF(populated = 1) AS one_column_populated,
       COUNTIF(populated > 1) AS more_than_one_populated,
       COUNTIF(NOT declared_column_populated) AS wrong_column_for_type
FROM j GROUP BY code, type ORDER BY n_rows DESC
