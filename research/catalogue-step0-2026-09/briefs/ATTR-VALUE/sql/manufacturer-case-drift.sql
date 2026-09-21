-- ATTR-VALUE A4 §5 · the 38 lowercase keys that carry more than one spelling — the whole of the
-- "0.7% case drift" the record cites, listed so the reader can judge what normalisation buys.
WITH
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
manu AS (SELECT pav.value_text AS v FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='manufacturer')
SELECT LOWER(TRIM(v)) AS folded, COUNT(DISTINCT v) AS spellings, COUNT(*) AS rows_affected,
       STRING_AGG(DISTINCT v, ' // ' ORDER BY v) AS the_spellings
FROM manu GROUP BY folded HAVING COUNT(DISTINCT v) > 1 ORDER BY rows_affected DESC, folded
