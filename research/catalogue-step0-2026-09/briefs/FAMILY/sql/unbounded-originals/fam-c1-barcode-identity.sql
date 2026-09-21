-- fam-c1-barcode-identity.sql — C1 "barcode identity": what Product.upc actually identifies.
-- Product.upc is unique=True and non-null (catalogue/models.py:390), so duplicate barcodes are
-- zero BY CONSTRUCTION. The real measure is provenance: how many rows carry a real GS1 GTIN and
-- how many carry a code we minted ourselves (ProductCodeGenerator.PRODUCT_CODE_PREFIX = "987",
-- catalogue/models.py:866). Split by the surfaces that care, and inside proxy families.
-- Proxy family = >=2 products sharing the first THREE title words within one main_category
-- (the same proxy #11031's "familyproxy.sql" used; it is an upper bound, not a family count).
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c1-barcode-identity.sql
CREATE TEMP FUNCTION gs1_ok(u STRING) RETURNS BOOL AS ((
  SELECT CASE
    WHEN u IS NULL OR NOT REGEXP_CONTAINS(u, r'^[0-9]+$') OR LENGTH(u) NOT IN (8,12,13) THEN FALSE
    ELSE (SELECT MOD(10 - MOD(SUM(COALESCE(SAFE_CAST(SUBSTR(u,pos,1) AS INT64),0) * IF(MOD(LENGTH(u)-pos,2)=1,3,1)),10),10)
                 = SAFE_CAST(SUBSTR(u,LENGTH(u),1) AS INT64)
          FROM UNNEST(GENERATE_ARRAY(1, LENGTH(u)-1)) AS pos)
  END));
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
k AS (
  SELECT id, upc, title, main_category_id, is_active, is_public, is_offline_only,
    CASE
      WHEN STARTS_WITH(upc,'987') AND LENGTH(upc)=13 THEN 'server_987'
      WHEN LENGTH(upc)=7 THEN 'weight_embedded_7'
      WHEN LENGTH(upc)=13 AND STARTS_WITH(upc,'2') THEN 'gs1_restricted_2x'
      WHEN gs1_ok(upc) THEN 'gs1_valid'
      ELSE 'other_invalid'
    END AS upc_kind,
    ARRAY_TO_STRING(ARRAY(SELECT w FROM UNNEST(SPLIT(REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+', ' '), ' ')) w WITH OFFSET o WHERE o < 3), ' ') AS pfx3
  FROM p
),
fam AS (SELECT main_category_id, pfx3, COUNT(*) n FROM k GROUP BY 1,2 HAVING COUNT(*) >= 2),
kf AS (SELECT k.*, fam.n AS fam_size FROM k JOIN fam USING (main_category_id, pfx3)),
famkind AS (
  SELECT main_category_id, pfx3, fam_size,
    COUNTIF(upc_kind='server_987') AS n987,
    COUNTIF(upc_kind='gs1_valid') AS ngs1,
    COUNTIF(upc_kind NOT IN ('server_987','gs1_valid')) AS nother
  FROM kf GROUP BY 1,2,3
)
SELECT 'upc_kind · all products' AS measure, upc_kind AS bucket, CAST(COUNT(*) AS STRING) AS value FROM k GROUP BY 1,2
UNION ALL SELECT 'upc_kind · active', upc_kind, CAST(COUNTIF(is_active) AS STRING) FROM k GROUP BY 1,2
UNION ALL SELECT 'upc_kind · active online (feed+site)', upc_kind, CAST(COUNTIF(is_active AND NOT is_offline_only) AS STRING) FROM k GROUP BY 1,2
UNION ALL SELECT 'upc_kind · offline only', upc_kind, CAST(COUNTIF(is_offline_only) AS STRING) FROM k GROUP BY 1,2
UNION ALL SELECT 'proxy families (>=2, 3-word prefix + category)', 'families', CAST(COUNT(*) AS STRING) FROM famkind
UNION ALL SELECT 'proxy families (>=2, 3-word prefix + category)', 'products in them', CAST(SUM(fam_size) AS STRING) FROM famkind
UNION ALL SELECT 'proxy family barcode mix', 'all members GS1-valid', CAST(COUNTIF(ngs1 = fam_size) AS STRING) FROM famkind
UNION ALL SELECT 'proxy family barcode mix', 'all members server 987', CAST(COUNTIF(n987 = fam_size) AS STRING) FROM famkind
UNION ALL SELECT 'proxy family barcode mix', 'mixed GS1 + 987', CAST(COUNTIF(n987 > 0 AND ngs1 > 0) AS STRING) FROM famkind
UNION ALL SELECT 'proxy family barcode mix', 'contains other kind', CAST(COUNTIF(nother > 0) AS STRING) FROM famkind
ORDER BY measure, bucket;
