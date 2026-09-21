-- ATTR-VALUE A4 §5 · what normalisation can and cannot fix. Groups the manufacturer values by a
-- strong key (lowercase, punctuation stripped, whitespace collapsed) and shows the spellings that
-- collapse. Case-folding alone reaches 38 groups; this key reaches the punctuation/abbreviation
-- class that only a shared row or a merge tool can fix.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
manu AS (SELECT pav.value_text AS v FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='manufacturer'),
k AS (SELECT v, TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(TRIM(v)), r'[^a-z0-9 ]', ' '), r'\s+',' ')) AS key FROM manu)
SELECT key, COUNT(DISTINCT v) AS spellings, COUNT(*) AS rows_affected,
       STRING_AGG(DISTINCT v, ' // ' ORDER BY v) AS the_spellings
FROM k GROUP BY key HAVING COUNT(DISTINCT v) > 1 ORDER BY rows_affected DESC, key LIMIT 25
