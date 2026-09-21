-- ATTR-VALUE A4 §5 · instrument check on unit-tokens-by-unit.sql: what do the L / M / BOTOL
-- buckets actually match? Prints 15 real titles per suspect unit so the reader can see the
-- false positives rather than trust the tally.
WITH p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
h AS (SELECT id, UPPER(title) u, REGEXP_EXTRACT(UPPER(title), r'\b[0-9]+(?:[.,][0-9]+)?\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|SACHET|SCT|BOTOL|BTL|DUS|BOX|PAK|PACK|CM|MM|M|OZ|LBR|LEMBAR)\b') unit_token FROM p)
SELECT unit_token, STRING_AGG(u, ' || ' ORDER BY u LIMIT 15) AS sample_titles
FROM h WHERE unit_token IN ('L','M','BOTOL','G','PC','BOX','MG') GROUP BY unit_token ORDER BY unit_token
