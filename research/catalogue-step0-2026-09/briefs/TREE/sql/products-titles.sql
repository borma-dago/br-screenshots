-- Snapshot bound (BRIEF §3.4): every dedup subquery is cut at the shared baseline snapshot
-- 2026-09-19 10:27 UTC, so re-runs reproduce regardless of later CDC rows.
-- products-titles.sql — every current product with its main_category, title and flags.
-- Downloaded once; drives (a) the non-leaf classification (B2) by comparing a node's own titles
-- against its children's, and (b) the title-token attribute evidence in node-attribute-need.md (B3).
WITH p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00') ) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE')
SELECT id, main_category_id, is_active, is_public, is_offline_only, REPLACE(REPLACE(title, '\n', ' '), '\r', ' ') AS title
FROM p ORDER BY main_category_id, id;
