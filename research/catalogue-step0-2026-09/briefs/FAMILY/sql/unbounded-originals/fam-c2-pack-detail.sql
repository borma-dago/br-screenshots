-- fam-c2-pack-detail.sql — C2 follow-up. The first pass showed 2,055 of 2,168 "N x M" titles carry
-- NO unit after the multiplier; this splits the single-exists test per token type and samples the
-- titles, to separate a genuine multipack ("ISI 12", "2 X 500 ML") from a DIMENSION ("180 X 200"
-- bedsheets), which the baseline's "titles with multiplier" count does not distinguish.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c2-pack-detail.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
t AS (SELECT id, main_category_id, is_active, is_offline_only, title, REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+',' ') AS nt FROM p),
f AS (SELECT *,
  REGEXP_CONTAINS(nt, r'\b[0-9]+\s?X\s?[0-9]+') AS has_mult,
  REGEXP_CONTAINS(nt, r'\b[0-9]+\s?X\s?[0-9]+\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC)\b') AS has_mult_unit,
  REGEXP_CONTAINS(nt, r'\bISI\s?[0-9]+') AS has_isi,
  REGEXP_CONTAINS(nt, r'\b(RENTENG|RCG|KARTON|KRT|DUS|BUNDLE|PAKET|SLOP|BAL|PAK|PACK|LUSIN|BOX)\b') AS has_packword
FROM t),
g AS (SELECT *,
  CASE WHEN has_isi THEN 'ISI N'
       WHEN has_mult_unit THEN 'N x M + unit'
       WHEN has_mult THEN 'N x M, no unit'
       WHEN has_packword THEN 'pack word only'
       ELSE 'none' END AS token_kind,
  TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(nt, r'\bISI\s?[0-9]+\b',' '), r'\b[0-9]+\s?X\s?[0-9]+(\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC))?\b',' '), r'\s+',' ')) AS base
FROM f),
h AS (SELECT *,
  ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(nt,' ')) w WITH OFFSET o WHERE o<3),' ') AS pfx3,
  ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(base,' ')) w WITH OFFSET o WHERE o<3),' ') AS base_pfx3
FROM g),
singles AS (SELECT DISTINCT main_category_id, pfx3 FROM h WHERE token_kind='none'),
packs AS (SELECT h.*, (s.pfx3 IS NOT NULL) AS single_exists FROM h LEFT JOIN singles s ON s.main_category_id=h.main_category_id AND s.pfx3=h.base_pfx3 WHERE h.token_kind<>'none')
SELECT 'A · per token kind' AS section, token_kind AS bucket,
  CONCAT(CAST(COUNT(*) AS STRING),' rows; single in same category: ',CAST(COUNTIF(single_exists) AS STRING),
         '; active online: ',CAST(COUNTIF(is_active AND NOT is_offline_only) AS STRING)) AS value
FROM packs GROUP BY 1,2
UNION ALL
SELECT 'B · sample titles', token_kind, STRING_AGG(title, ' || ' ORDER BY id LIMIT 12) FROM packs GROUP BY 1,2
ORDER BY section, bucket;
