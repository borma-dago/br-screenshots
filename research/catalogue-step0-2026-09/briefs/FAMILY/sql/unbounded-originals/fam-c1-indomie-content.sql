-- fam-c1-indomie-content.sql — C1: which fields actually differ across the Indomie rows.
-- Extends sql/results/indomie.csv (which carries description LENGTH only) with the
-- description body itself (hash + head), the slug, and the image display orders, so
-- "must siblings share the description / title / images?" can be answered from data.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c1-indomie-content.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pi AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productimage`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
ind AS (SELECT * FROM p WHERE REGEXP_CONTAINS(UPPER(title), r'^INDOMIE')),
img AS (SELECT product_id, COUNT(*) AS images, STRING_AGG(CAST(display_order AS STRING), '/' ORDER BY display_order) AS orders FROM pi WHERE product_id IN (SELECT id FROM ind) GROUP BY 1)
SELECT
  ind.id,
  ind.is_active,
  ind.title,
  ind.slug,
  LENGTH(COALESCE(ind.description,'')) AS desc_len,
  TO_HEX(MD5(COALESCE(ind.description,''))) AS desc_md5,
  SUBSTR(REGEXP_REPLACE(COALESCE(ind.description,''), r'\s+', ' '), 1, 90) AS desc_head,
  -- Added after red-team round 1 (finding 11): the "does the description open with the row's own
  -- title" predicate, written out instead of hand-counted. Three variants, because the answer depends
  -- on normalisation: strict, tag-stripped, and tag-stripped + &nbsp; folded.
  STRPOS(UPPER(COALESCE(ind.description,'')), UPPER(ind.title)) > 0 AS desc_contains_title_strict,
  STRPOS(
    REGEXP_REPLACE(REGEXP_REPLACE(UPPER(REPLACE(COALESCE(ind.description,''),'&nbsp;',' ')), r'<[^>]*>', ' '), r'\s+', ' '),
    REGEXP_REPLACE(UPPER(TRIM(ind.title)), r'\s+', ' ')
  ) > 0 AS desc_contains_title_normalised,
  COALESCE(img.images,0) AS images,
  img.orders AS image_display_orders
FROM ind LEFT JOIN img ON img.product_id = ind.id
ORDER BY ind.is_active DESC, ind.title;
