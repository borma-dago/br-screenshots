-- ATTR-VALUE §5/§8 · re-take of the three families the decision matrix quotes as stored, at the
-- 2026-09-19 snapshot rather than the matrix's 2026-09-15 one.
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
-- Snapshot-bounded per BRIEF §3.4: every dedup subquery is cut at source_timestamp <= 2026-09-19 10:27:00+00
-- (INT64 epoch millis), so the result is reproducible as production keeps writing.
WITH p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE')
SELECT 'SOKLIN SAKURA' AS family, id, upc, title, is_active FROM p WHERE UPPER(title) LIKE 'SOKLIN SOFTERGENT SAKURA%'
UNION ALL SELECT 'REAL GOOD YOGURT', id, upc, title, is_active FROM p WHERE UPPER(title) LIKE '%REAL GOOD%YOGURT%'
UNION ALL SELECT 'IMPLORA LIP CREAM', id, upc, title, is_active FROM p WHERE UPPER(title) LIKE '%IMPLORA%LIP CREAM%'
UNION ALL SELECT 'PIXY FIXED MATTE', id, upc, title, is_active FROM p WHERE UPPER(title) LIKE 'PIXY FIXED MATTE%'
ORDER BY family, title
