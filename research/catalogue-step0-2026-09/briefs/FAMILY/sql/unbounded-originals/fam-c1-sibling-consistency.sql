-- fam-c1-sibling-consistency.sql — C1: what must siblings share?
-- Tests, on the proxy families, the three "must share" candidates the card names:
--   category  — would a family straddle two categories if we grouped by name alone?
--   brand     — measured through `manufacturer`, the only brand-ish attribute we have (NOT a brand:
--               #10778 measured its top values are corporate entities covering many brands).
--   two families — is there any data signal that one product belongs in two groups?
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c1-sibling-consistency.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pc AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productcategory`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pi AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productimage`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
manu AS (SELECT pav.product_id, TRIM(UPPER(pav.value_text)) AS m FROM pav JOIN pa ON pa.id=pav.attribute_id WHERE pa.code='manufacturer'),
imgs AS (SELECT product_id, COUNT(*) AS n_img FROM pi GROUP BY 1),
t AS (
  SELECT p.id, p.main_category_id, p.title, p.description, p.is_active, p.is_offline_only,
    REGEXP_REPLACE(UPPER(TRIM(p.title)), r'\s+',' ') AS nt,
    manu.m AS manufacturer, COALESCE(imgs.n_img,0) AS n_img
  FROM p LEFT JOIN manu ON manu.product_id=p.id LEFT JOIN imgs ON imgs.product_id=p.id
),
v AS (SELECT *, ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(nt,' ')) w WITH OFFSET o WHERE o<3),' ') AS pfx3 FROM t),
fam AS (
  SELECT main_category_id, pfx3, COUNT(*) AS n,
    COUNT(DISTINCT manufacturer) AS distinct_manu,
    COUNTIF(manufacturer IS NULL) AS n_no_manu,
    COUNT(DISTINCT IFNULL(description,'')) AS distinct_desc,
    COUNTIF(IFNULL(description,'')='') AS n_empty_desc,
    COUNTIF(n_img=0) AS n_no_img,
    COUNT(DISTINCT n_img) AS distinct_img_counts
  FROM v GROUP BY 1,2 HAVING COUNT(*)>=2
),
crosscat AS (SELECT pfx3, COUNT(DISTINCT main_category_id) AS cats, COUNT(*) AS n FROM v GROUP BY 1 HAVING COUNT(*)>=2)
SELECT 'A · category · would a name-only family straddle categories?' AS section, k AS bucket, CAST(v AS STRING) AS value FROM (
  SELECT 'distinct 3-word prefixes with >=2 products' k, (SELECT COUNT(*) FROM crosscat) v UNION ALL
  SELECT 'of those, spanning >1 main_category', (SELECT COUNTIF(cats>1) FROM crosscat) UNION ALL
  SELECT 'products inside prefixes that span >1 category', (SELECT SUM(IF(cats>1,n,0)) FROM crosscat)
)
UNION ALL
SELECT 'B · brand proxy (manufacturer) inside a proxy family', k, CAST(v AS STRING) FROM (
  SELECT 'proxy families' k, (SELECT COUNT(*) FROM fam) v UNION ALL
  SELECT 'all members share one manufacturer value', (SELECT COUNTIF(distinct_manu=1 AND n_no_manu=0) FROM fam) UNION ALL
  SELECT 'members disagree on manufacturer', (SELECT COUNTIF(distinct_manu>1) FROM fam) UNION ALL
  SELECT 'at least one member has no manufacturer row', (SELECT COUNTIF(n_no_manu>0) FROM fam) UNION ALL
  SELECT 'no member has a manufacturer row', (SELECT COUNTIF(n_no_manu=n) FROM fam)
)
UNION ALL
SELECT 'C · description / images inside a proxy family', k, CAST(v AS STRING) FROM (
  SELECT 'every member has a DIFFERENT description' k, (SELECT COUNTIF(distinct_desc=n) FROM fam) v UNION ALL
  SELECT 'all members share one description string', (SELECT COUNTIF(distinct_desc=1) FROM fam) UNION ALL
  SELECT 'at least one member has an empty description', (SELECT COUNTIF(n_empty_desc>0) FROM fam) UNION ALL
  SELECT 'every member has an empty description', (SELECT COUNTIF(n_empty_desc=n) FROM fam) UNION ALL
  SELECT 'at least one member has no image', (SELECT COUNTIF(n_no_img>0) FROM fam) UNION ALL
  SELECT 'no member has an image', (SELECT COUNTIF(n_no_img=n) FROM fam)
)
UNION ALL
SELECT 'D · one product in two families — data signal', k, CAST(v AS STRING) FROM (
  SELECT 'ProductCategory M2M rows' k, (SELECT COUNT(*) FROM pc) v UNION ALL
  SELECT 'products with >1 ProductCategory row', (SELECT COUNT(*) FROM (SELECT product_id FROM pc GROUP BY 1 HAVING COUNT(DISTINCT category_id)>1)) UNION ALL
  SELECT 'exact duplicate normalised titles across the catalogue', (SELECT COUNT(*) FROM (SELECT nt FROM v GROUP BY 1 HAVING COUNT(*)>1)) UNION ALL
  SELECT 'products carrying a duplicated normalised title', (SELECT SUM(k2) FROM (SELECT COUNT(*) AS k2 FROM v GROUP BY nt HAVING COUNT(*)>1))
)
ORDER BY section, bucket;
