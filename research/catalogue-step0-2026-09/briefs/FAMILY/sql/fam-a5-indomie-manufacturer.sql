-- fam-a5-indomie-manufacturer.sql — A5 §5: the distinct `manufacturer` spellings across the Indomie rows.
-- Added after red-team round 1 (finding 10): revision 1 printed SEVEN spellings from a hand count off
-- sql/results/indomie.csv; the data has NINE raw and EIGHT case-insensitively. This query is the instrument.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-a5-indomie-manufacturer.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
ind AS (SELECT id FROM p WHERE REGEXP_CONTAINS(UPPER(title), r'^INDOMIE')),
m AS (SELECT pav.product_id, pav.value_text AS v FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='manufacturer' AND pav.product_id IN (SELECT id FROM ind))
SELECT 'A · distinct spellings' AS section, v AS bucket, CAST(COUNT(*) AS STRING) AS value FROM m GROUP BY 1,2
UNION ALL
SELECT 'B · totals', k, CAST(x AS STRING) FROM (
  SELECT 'Indomie rows with a manufacturer row' k, (SELECT COUNT(*) FROM m) x UNION ALL
  SELECT 'distinct raw spellings', (SELECT COUNT(DISTINCT v) FROM m) UNION ALL
  SELECT 'distinct after UPPER()', (SELECT COUNT(DISTINCT UPPER(v)) FROM m) UNION ALL
  SELECT 'distinct after UPPER+collapse internal whitespace', (SELECT COUNT(DISTINCT REGEXP_REPLACE(UPPER(TRIM(v)), r'\s+', ' ')) FROM m)
)
ORDER BY section, bucket;
