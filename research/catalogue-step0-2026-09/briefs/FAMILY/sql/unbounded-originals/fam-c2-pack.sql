-- fam-c2-pack.sql — C2: is a 6-pack a variant of the single, or a separate product?
-- Counts our own multipack titles and asks the question the card asks: do BOTH the single and
-- the pack exist as rows, and do they share a category?
-- Token definitions are the baseline's, verbatim (sql/baseline.sql:70-72), so the totals reconcile.
-- "single exists" test: strip the pack token from the title, then look for another product in the
-- SAME main_category whose first three title words match the stripped title's first three words
-- and which carries no pack token itself. Proxy, deliberately generous — an upper bound.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c2-pack.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
c AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_category`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
t AS (
  SELECT id, main_category_id, is_active, is_offline_only, upc, title,
    REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+', ' ') AS nt
  FROM p
),
f AS (
  SELECT *,
    REGEXP_CONTAINS(nt, r'\b[0-9]+\s?X\s?[0-9]+') AS has_mult,
    REGEXP_CONTAINS(nt, r'\bISI\s?[0-9]+') AS has_isi,
    REGEXP_CONTAINS(nt, r'\b(RENTENG|RCG|KARTON|KRT|DUS|BUNDLE|PAKET|SLOP|BAL|PAK|PACK|LUSIN|BOX)\b') AS has_packword
  FROM t
),
g AS (
  SELECT *, (has_mult OR has_isi OR has_packword) AS is_pack,
    -- the base title with the pack token removed
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(nt,
      r'\bISI\s?[0-9]+\b', ' '),
      r'\b[0-9]+\s?X\s?[0-9]+(\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC))?\b', ' '),
      r'\s+', ' ')) AS base
  FROM f
),
h AS (
  SELECT *,
    ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(nt,' ')) w WITH OFFSET o WHERE o<3), ' ') AS pfx3,
    ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(base,' ')) w WITH OFFSET o WHERE o<3), ' ') AS base_pfx3
  FROM g
),
singles AS (SELECT DISTINCT main_category_id, pfx3 FROM h WHERE NOT is_pack),
packs AS (
  SELECT h.*, (s.pfx3 IS NOT NULL) AS single_same_category_exists
  FROM h LEFT JOIN singles s ON s.main_category_id = h.main_category_id AND s.pfx3 = h.base_pfx3
  WHERE h.is_pack
)
SELECT 'pack titles · totals' AS measure, k AS bucket, CAST(v AS STRING) AS value FROM (
  SELECT 'any pack token' k, COUNTIF(is_pack) v FROM h UNION ALL
  SELECT 'multiplier N x M', COUNTIF(has_mult) FROM h UNION ALL
  SELECT 'ISI N', COUNTIF(has_isi) FROM h UNION ALL
  SELECT 'pack word', COUNTIF(has_packword) FROM h UNION ALL
  SELECT 'any pack token · active', COUNTIF(is_pack AND is_active) FROM h UNION ALL
  SELECT 'any pack token · active online', COUNTIF(is_pack AND is_active AND NOT is_offline_only) FROM h
)
UNION ALL
SELECT 'pack rows · does the single exist in the same category?', IF(single_same_category_exists,'yes','no'), CAST(COUNT(*) AS STRING) FROM packs GROUP BY 1,2
UNION ALL
SELECT 'pack rows · unit that follows the multiplier', COALESCE(REGEXP_EXTRACT(nt, r'\b[0-9]+\s?X\s?[0-9]+\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC)\b'),'(no unit)'), CAST(COUNT(*) AS STRING)
  FROM h WHERE has_mult GROUP BY 1,2
UNION ALL
SELECT 'pack rows · top categories', CONCAT(CAST(h.main_category_id AS STRING),' ',c.name), CAST(COUNT(*) AS STRING)
  FROM h JOIN c ON c.id=h.main_category_id WHERE h.is_pack GROUP BY 1,2
-- Added after red-team round 1 (finding 41): the previous `ORDER BY 1,3` tied on count=1 across ~2,900
-- category rows, so the saved CSV's tail came back in a different order on every run. Ordering on the
-- bucket string (which carries main_category_id) makes the saved result byte-reproducible. No number moves.
ORDER BY 1, 2
;
