-- Snapshot bound (BRIEF §3.4): every dedup subquery is cut at the shared baseline snapshot
-- 2026-09-19 10:27 UTC, so re-runs reproduce regardless of later CDC rows.
-- nonleaf-used.sql — every category that has children AND holds products directly (main_category).
-- For B2: classify each as a real type (a product genuinely belongs at this level) or a catch-all.
-- Carries the node's children names and a sample of the titles parked on it.
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00') ) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
c AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_category` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00') ) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
anc AS (SELECT c.id AS cid, STRING_AGG(a.name, ' > ' ORDER BY a.depth) AS ancestor_names FROM c JOIN c a ON STARTS_WITH(c.path, a.path) AND a.depth < c.depth GROUP BY 1),
kids AS (SELECT a.id AS cid, COUNT(*) AS n_children, STRING_AGG(k.name, ' | ' ORDER BY k.path LIMIT 12) AS children_sample
         FROM c a JOIN c k ON k.path = CONCAT(a.path, SUBSTR(k.path, a.depth*4+1, 4)) AND k.depth = a.depth+1 GROUP BY 1),
titles AS (SELECT main_category_id AS cid, COUNT(*) n, COUNTIF(is_active) n_active,
                  STRING_AGG(title, ' :: ' ORDER BY id LIMIT 14) AS title_sample
           FROM p WHERE main_category_id IS NOT NULL GROUP BY 1),
subtree AS (SELECT c.id AS cid, COUNT(p.id) AS n_subtree FROM c LEFT JOIN (SELECT p.id, c2.path FROM p JOIN c c2 ON c2.id=p.main_category_id) p ON STARTS_WITH(p.path, c.path) GROUP BY 1)
SELECT c.id, c.name, c._name_en AS name_en, c.depth, c.numchild, c.full_code,
       IFNULL(anc.ancestor_names,'') AS ancestor_names,
       titles.n AS products, titles.n_active AS products_active, subtree.n_subtree AS products_subtree,
       kids.children_sample, titles.title_sample
FROM c
JOIN titles ON titles.cid = c.id
LEFT JOIN anc ON anc.cid = c.id
LEFT JOIN kids ON kids.cid = c.id
LEFT JOIN subtree ON subtree.cid = c.id
WHERE c.numchild > 0
ORDER BY titles.n DESC, c.id;
