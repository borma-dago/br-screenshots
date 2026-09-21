-- fam-c1-divergence.sql — C1: what do would-be siblings ALREADY differ in, on the fields the card
-- asks about? Two parts: (A) per-field divergence inside proxy families; (B) the 2,112 duplicate
-- normalised titles — same category or not, and what distinguishes the rows.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c1-divergence.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
v AS (SELECT id, main_category_id, upc, title, slug, is_active, is_public, is_offline_only,
        REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+',' ') AS nt,
        ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+',' '),' ')) w WITH OFFSET o WHERE o<3),' ') AS pfx3
      FROM p),
fam AS (SELECT main_category_id, pfx3, COUNT(*) n,
          COUNT(DISTINCT is_offline_only) AS d_offline,
          COUNT(DISTINCT is_public) AS d_public,
          COUNT(DISTINCT is_active) AS d_active,
          COUNT(DISTINCT title) AS d_title,
          COUNT(DISTINCT slug) AS d_slug,
          COUNT(DISTINCT upc) AS d_upc
        FROM v GROUP BY 1,2 HAVING COUNT(*)>=2),
dup AS (SELECT nt, COUNT(*) n, COUNT(DISTINCT main_category_id) cats, COUNT(DISTINCT upc) upcs FROM v GROUP BY 1 HAVING COUNT(*)>1)
SELECT 'A · divergence inside a proxy family' AS section, k AS bucket, CAST(x AS STRING) AS value FROM (
  SELECT 'proxy families' k, (SELECT COUNT(*) FROM fam) x UNION ALL
  SELECT 'members differ on is_offline_only', (SELECT COUNTIF(d_offline>1) FROM fam) UNION ALL
  SELECT 'members differ on is_public', (SELECT COUNTIF(d_public>1) FROM fam) UNION ALL
  SELECT 'members differ on is_active', (SELECT COUNTIF(d_active>1) FROM fam) UNION ALL
  SELECT 'every member has a distinct title', (SELECT COUNTIF(d_title=n) FROM fam) UNION ALL
  SELECT 'every member has a distinct slug', (SELECT COUNTIF(d_slug=n) FROM fam) UNION ALL
  SELECT 'every member has a distinct upc', (SELECT COUNTIF(d_upc=n) FROM fam)
)
UNION ALL
SELECT 'B · duplicate normalised titles', k, CAST(x AS STRING) FROM (
  SELECT 'distinct titles carried by >1 product' k, (SELECT COUNT(*) FROM dup) x UNION ALL
  SELECT 'products involved', (SELECT SUM(n) FROM dup) UNION ALL
  SELECT 'duplicate titles whose rows sit in ONE category', (SELECT COUNTIF(cats=1) FROM dup) UNION ALL
  SELECT 'duplicate titles whose rows span >1 category', (SELECT COUNTIF(cats>1) FROM dup) UNION ALL
  SELECT 'duplicate titles where every row has its own upc', (SELECT COUNTIF(upcs=n) FROM dup)
)
ORDER BY section, bucket;
