-- baseline.sql — shared snapshot for every Step-0 brief. Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=prettyjson < baseline.sql
-- Source: solvent-staging.production_append_public (append-only CDC). Dedup: latest row per id, excluding DELETE.
CREATE TEMP FUNCTION gs1_ok(u STRING) RETURNS BOOL AS ((
  SELECT CASE
    WHEN u IS NULL OR NOT REGEXP_CONTAINS(u, r'^[0-9]+$') OR LENGTH(u) NOT IN (8,12,13) THEN FALSE
    ELSE (SELECT MOD(10 - MOD(SUM(COALESCE(SAFE_CAST(SUBSTR(u,pos,1) AS INT64),0) * IF(MOD(LENGTH(u)-pos,2)=1,3,1)),10),10)
                 = SAFE_CAST(SUBSTR(u,LENGTH(u),1) AS INT64)
          FROM UNNEST(GENERATE_ARRAY(1, LENGTH(u)-1)) AS pos)
  END));
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
c AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_category`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pa AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattribute`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pav AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productattributevalue`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pc AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productcategory`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pi AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productimage`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pcl AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_productclass`) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
pcat AS (SELECT p.*, c.depth AS cat_depth, c.numchild AS cat_numchild, c.name AS cat_name FROM p LEFT JOIN c ON c.id = p.main_category_id),
nodes AS (SELECT c.id, c.name, c.depth, c.numchild, COUNT(p.id) AS n FROM c LEFT JOIN p ON p.main_category_id = c.id GROUP BY 1,2,3,4),
used AS (SELECT *, SUM(n) OVER (ORDER BY n DESC, id ROWS UNBOUNDED PRECEDING) AS cum, ROW_NUMBER() OVER (ORDER BY n DESC, id) AS rk FROM nodes WHERE n > 0),
manu AS (SELECT pav.product_id, pav.value_text AS v FROM pav JOIN pa ON pa.id = pav.attribute_id WHERE pa.code = 'manufacturer'),
manu_counts AS (SELECT v, COUNT(*) AS k FROM manu GROUP BY v),
m AS (
  SELECT 'snapshot_utc' AS measure, FORMAT_TIMESTAMP('%Y-%m-%d %H:%M', CURRENT_TIMESTAMP()) AS value UNION ALL
  SELECT 'products_total', CAST(COUNT(*) AS STRING) FROM p UNION ALL
  SELECT 'products_active', CAST(COUNTIF(is_active) AS STRING) FROM p UNION ALL
  SELECT 'products_public', CAST(COUNTIF(is_public) AS STRING) FROM p UNION ALL
  SELECT 'products_offline_only', CAST(COUNTIF(is_offline_only) AS STRING) FROM p UNION ALL
  SELECT 'products_active_online', CAST(COUNTIF(is_active AND NOT is_offline_only) AS STRING) FROM p UNION ALL
  SELECT 'productclass_rows', CAST(COUNT(*) AS STRING) FROM pcl UNION ALL
  SELECT 'productattribute_rows', CAST(COUNT(*) AS STRING) FROM pa UNION ALL
  SELECT 'productattribute_list', STRING_AGG(CONCAT(code,':',type,':',IF(required,'req','opt')), ' | ' ORDER BY id) FROM pa UNION ALL
  SELECT 'pav_rows_total', CAST(COUNT(*) AS STRING) FROM pav UNION ALL
  SELECT CONCAT('pav_rows_', pa.code), CAST(COUNT(*) AS STRING) FROM pav JOIN pa ON pa.id=pav.attribute_id GROUP BY pa.code UNION ALL
  SELECT 'categories_total', CAST(COUNT(*) AS STRING) FROM c UNION ALL
  SELECT 'categories_leaf', CAST(COUNTIF(numchild=0) AS STRING) FROM c UNION ALL
  SELECT 'categories_nonleaf', CAST(COUNTIF(numchild>0) AS STRING) FROM c UNION ALL
  SELECT 'categories_root', CAST(COUNTIF(depth=1) AS STRING) FROM c UNION ALL
  SELECT 'categories_max_depth', CAST(MAX(depth) AS STRING) FROM c UNION ALL
  SELECT 'categories_used_as_main', CAST(COUNT(DISTINCT main_category_id) AS STRING) FROM p UNION ALL
  SELECT 'products_on_nonleaf', CAST(COUNTIF(cat_numchild>0) AS STRING) FROM pcat UNION ALL
  SELECT 'products_on_root', CAST(COUNTIF(cat_depth=1) AS STRING) FROM pcat UNION ALL
  SELECT 'used_nonleaf_nodes', CAST(COUNTIF(numchild>0) AS STRING) FROM nodes WHERE n>0 UNION ALL
  SELECT 'used_leaf_nodes', CAST(COUNTIF(numchild=0) AS STRING) FROM nodes WHERE n>0 UNION ALL
  SELECT 'used_nodes_lt10_products', CAST(COUNTIF(n<10) AS STRING) FROM nodes WHERE n>0 UNION ALL
  SELECT 'nodes_to_cover_50pct', CAST(MIN(rk) AS STRING) FROM used WHERE cum >= 0.5*(SELECT COUNT(*) FROM p) UNION ALL
  SELECT 'nodes_to_cover_80pct', CAST(MIN(rk) AS STRING) FROM used WHERE cum >= 0.8*(SELECT COUNT(*) FROM p) UNION ALL
  SELECT 'nodes_to_cover_90pct', CAST(MIN(rk) AS STRING) FROM used WHERE cum >= 0.9*(SELECT COUNT(*) FROM p) UNION ALL
  SELECT 'catchall_nodes_LAINNYA', CAST(COUNT(*) AS STRING) FROM nodes WHERE n>0 AND REGEXP_CONTAINS(UPPER(name), r'LAINNYA|LAIN-LAIN|OTHER') UNION ALL
  SELECT 'catchall_products_LAINNYA', CAST(SUM(n) AS STRING) FROM nodes WHERE n>0 AND REGEXP_CONTAINS(UPPER(name), r'LAINNYA|LAIN-LAIN|OTHER') UNION ALL
  SELECT 'manufacturer_rows', CAST(COUNT(*) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_distinct_raw', CAST(COUNT(DISTINCT v) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_distinct_trim_lower', CAST(COUNT(DISTINCT LOWER(TRIM(v))) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_value_is_0', CAST(COUNTIF(v='0') AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_junk_set', CAST(COUNTIF(v IN ('0','-','00','000','.')) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_numeric_only', CAST(COUNTIF(REGEXP_CONTAINS(v, r'^[0-9]+$')) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_no_ascii_letter', CAST(COUNTIF(NOT REGEXP_CONTAINS(v, r'[A-Za-z]')) AS STRING) FROM manu UNION ALL
  SELECT 'manufacturer_values_used_once', CAST(COUNTIF(k=1) AS STRING) FROM manu_counts UNION ALL
  SELECT 'products_without_manufacturer_row', CAST(COUNT(*) AS STRING) FROM p WHERE id NOT IN (SELECT product_id FROM manu) UNION ALL
  SELECT 'active_online_without_manufacturer_row', CAST(COUNT(*) AS STRING) FROM p WHERE is_active AND NOT is_offline_only AND id NOT IN (SELECT product_id FROM manu) UNION ALL
  SELECT 'active_online_manufacturer_no_letter', CAST(COUNT(*) AS STRING) FROM p JOIN manu ON manu.product_id=p.id WHERE p.is_active AND NOT p.is_offline_only AND NOT REGEXP_CONTAINS(manu.v, r'[A-Za-z]') UNION ALL
  SELECT 'productcategory_m2m_rows', CAST(COUNT(*) AS STRING) FROM pc UNION ALL
  SELECT 'productcategory_m2m_distinct_products', CAST(COUNT(DISTINCT product_id) AS STRING) FROM pc UNION ALL
  SELECT 'productcategory_m2m_products_gt1', CAST(COUNT(*) AS STRING) FROM (SELECT product_id FROM pc GROUP BY 1 HAVING COUNT(*)>1) UNION ALL
  SELECT 'image_rows', CAST(COUNT(*) AS STRING) FROM pi UNION ALL
  SELECT 'products_with_image', CAST(COUNT(DISTINCT product_id) AS STRING) FROM pi UNION ALL
  SELECT 'indomie_rows_all', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'^INDOMIE')) AS STRING) FROM p UNION ALL
  SELECT 'indomie_rows_active', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'^INDOMIE') AND is_active) AS STRING) FROM p UNION ALL
  SELECT 'titles_with_unit_token', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'\b[0-9]+([.,][0-9]+)?\s?(ML|LTR|L|GR|GRAM|G|KG|MG|PCS|PC|SACHET|SCT|BOTOL|BTL|DUS|BOX|PAK|PACK|CM|MM|M|OZ|LBR|LEMBAR)\b')) AS STRING) FROM p UNION ALL
  SELECT 'titles_with_multiplier', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'\b[0-9]+\s?X\s?[0-9]+')) AS STRING) FROM p UNION ALL
  SELECT 'titles_with_isi_N', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'\bISI\s?[0-9]+')) AS STRING) FROM p UNION ALL
  SELECT 'titles_with_pack_word', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'\b(RENTENG|RCG|KARTON|KRT|DUS|BUNDLE|PAKET|SLOP|BAL|PAK|PACK|LUSIN|BOX)\b')) AS STRING) FROM p UNION ALL
  SELECT 'upc_len_13', CAST(COUNTIF(LENGTH(upc)=13) AS STRING) FROM p UNION ALL
  SELECT 'upc_len_12', CAST(COUNTIF(LENGTH(upc)=12) AS STRING) FROM p UNION ALL
  SELECT 'upc_len_8', CAST(COUNTIF(LENGTH(upc)=8) AS STRING) FROM p UNION ALL
  SELECT 'upc_len_7_weight_embedded', CAST(COUNTIF(LENGTH(upc)=7) AS STRING) FROM p UNION ALL
  SELECT 'upc_len_other', CAST(COUNTIF(LENGTH(upc) NOT IN (7,8,12,13)) AS STRING) FROM p UNION ALL
  SELECT 'upc_prefix_984_deprecated_custom', CAST(COUNTIF(STARTS_WITH(upc,'984')) AS STRING) FROM p UNION ALL
  SELECT 'upc_prefix_987_server_generated', CAST(COUNTIF(STARTS_WITH(upc,'987')) AS STRING) FROM p UNION ALL
  SELECT 'upc_gs1_checksum_valid_not_984_987', CAST(COUNTIF(gs1_ok(upc) AND NOT STARTS_WITH(upc,'984') AND NOT STARTS_WITH(upc,'987')) AS STRING) FROM p UNION ALL
  SELECT 'upc_checksum_invalid_len_8_12_13', CAST(COUNTIF(LENGTH(upc) IN (8,12,13) AND NOT gs1_ok(upc)) AS STRING) FROM p UNION ALL
  SELECT 'upc_prefix_2xx_2x_restricted_gs1', CAST(COUNTIF(LENGTH(upc)=13 AND REGEXP_CONTAINS(upc, r'^2[0-9]')) AS STRING) FROM p UNION ALL
  SELECT 'indomie_active_gs1', CAST(COUNTIF(REGEXP_CONTAINS(UPPER(title), r'^INDOMIE') AND is_active AND gs1_ok(upc) AND NOT STARTS_WITH(upc,'984') AND NOT STARTS_WITH(upc,'987')) AS STRING) FROM p
)
SELECT measure, value FROM m ORDER BY measure;
