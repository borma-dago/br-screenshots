-- fam-c3-apparel-sensitivity.sql — C3: #10943 reported "240 of 1,945 live apparel products carry a
-- size token" (comment 2026-08-10) WITHOUT publishing its regex, so the re-run is a sensitivity
-- analysis over four token definitions rather than a single number. Also samples the titles.
-- Run: bq --project_id=solvent-staging query --use_legacy_sql=false --format=csv --max_rows=5000 < fam-c3-apparel-sensitivity.sql
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
a AS (
  SELECT id, title, is_active, is_public, is_offline_only, REGEXP_REPLACE(UPPER(TRIM(title)), r'\s+',' ') AS nt
  FROM p WHERE REGEXP_CONTAINS(UPPER(title), r'\b(KAOS|BAJU|CELANA|KEMEJA|JAKET|SERAGAM|PAKAIAN)\b')
),
live AS (SELECT * FROM a WHERE is_active AND is_public),
d AS (
  SELECT *,
    REGEXP_CONTAINS(nt, r'\b(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\s?-\s?(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b') AS def_range,
    REGEXP_CONTAINS(nt, r'\b(XS|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b') AS def_unambiguous,
    REGEXP_CONTAINS(nt, r'(\b(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b\s*$)') AS def_trailing_letter,
    REGEXP_CONTAINS(nt, r'\b(SIZE|UKURAN|UK)\b') OR REGEXP_CONTAINS(nt, r'\bALL ?SIZE\b') AS def_marker_word,
    REGEXP_CONTAINS(nt, r'(\b(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b(\s?-\s?(XS|S|M|L|XL|XXL|XXXL|2XL|3XL|4XL|2L|3L|4L)\b)?|\bALL ?SIZE\b)') AS def_permissive
  FROM live
)
SELECT 'A · population' AS section, k AS bucket, CAST(v AS STRING) AS value FROM (
  SELECT 'apparel-titled, all rows' k, (SELECT COUNT(*) FROM a) v UNION ALL
  SELECT 'apparel-titled, live (is_active AND is_public)', (SELECT COUNT(*) FROM live) UNION ALL
  SELECT 'apparel-titled, active online (feed/site)', (SELECT COUNTIF(is_active AND NOT is_offline_only) FROM a)
)
UNION ALL
SELECT 'B · size token, by definition', k, CAST(v AS STRING) FROM (
  SELECT 'def1 range only (M-XL)' k, COUNTIF(def_range) v FROM d UNION ALL
  SELECT 'def2 unambiguous letters only (XS/XL/XXL/2L/3L...)', COUNTIF(def_unambiguous) FROM d UNION ALL
  SELECT 'def3 letter size at END of title', COUNTIF(def_trailing_letter) FROM d UNION ALL
  SELECT 'def4 explicit marker word (SIZE/UKURAN/UK/ALL SIZE)', COUNTIF(def_marker_word) FROM d UNION ALL
  SELECT 'def5 permissive (any letter size anywhere, incl. bare S/M/L)', COUNTIF(def_permissive) FROM d UNION ALL
  SELECT 'def2 OR def1 OR def4 (defensible floor)', COUNTIF(def_range OR def_unambiguous OR def_marker_word) FROM d
)
UNION ALL
SELECT 'C · samples', 'def2 unambiguous', STRING_AGG(title,' || ' ORDER BY id LIMIT 10) FROM d WHERE def_unambiguous
UNION ALL
SELECT 'C · samples', 'no size token at all (def5 false)', STRING_AGG(title,' || ' ORDER BY id LIMIT 10) FROM d WHERE NOT def_permissive
ORDER BY section, bucket;
