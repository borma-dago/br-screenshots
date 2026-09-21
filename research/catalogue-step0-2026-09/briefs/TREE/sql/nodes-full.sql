-- Snapshot bound (BRIEF §3.4): every dedup subquery is cut at the shared baseline snapshot
-- 2026-09-19 10:27 UTC, so re-runs reproduce regardless of later CDC rows.
-- nodes-full.sql — every category node with its materialised-path ancestry resolved to names,
-- its parent, leaf flag, direct product count and subtree product count.
-- Treebeard MP_Node: path is fixed-width base36 steps of 4 chars (steplen=4), so an ancestor's
-- path is a 4*k-char prefix of the node's path and depth = LENGTH(path)/4.
-- Feeds: B1, B2, B3, the non-leaf classification, and the Shopify mapping feasibility measurement.
WITH
p AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_product` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00') ) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
c AS (SELECT * EXCEPT(rn) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY datastream_metadata.source_timestamp DESC, datastream_metadata.change_sequence_number DESC) rn FROM `solvent-staging.production_append_public.catalogue_category` WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00') ) WHERE rn=1 AND datastream_metadata.change_type != 'DELETE'),
direct AS (SELECT main_category_id AS cid, COUNT(*) n, COUNTIF(is_active) n_active FROM p WHERE main_category_id IS NOT NULL GROUP BY 1),
-- subtree count: a product counts for node X if X.path is a prefix of the product's category path
prodcat AS (SELECT p.id AS pid, c.path AS cpath FROM p JOIN c ON c.id = p.main_category_id),
subtree AS (SELECT c.id AS cid, COUNT(pc.pid) AS n_subtree FROM c LEFT JOIN prodcat pc ON STARTS_WITH(pc.cpath, c.path) GROUP BY 1),
anc AS (
  SELECT c.id AS cid, STRING_AGG(a.name, ' > ' ORDER BY a.depth) AS ancestor_names,
         STRING_AGG(IFNULL(a._name_en, ''), ' > ' ORDER BY a.depth) AS ancestor_names_en
  FROM c JOIN c a ON STARTS_WITH(c.path, a.path) AND a.depth < c.depth GROUP BY 1),
par AS (SELECT c.id AS cid, a.id AS parent_id, a.name AS parent_name FROM c JOIN c a ON a.path = SUBSTR(c.path, 1, (c.depth-1)*4) AND a.depth = c.depth-1)
SELECT c.id, c.name, c._name_en AS name_en, c.depth, c.numchild, (c.numchild = 0) AS is_leaf,
       c.full_code, c.code, c.is_public, c.ancestors_are_public, c.path,
       par.parent_id, par.parent_name,
       anc.ancestor_names,
       CONCAT(IFNULL(CONCAT(anc.ancestor_names, ' > '), ''), c.name) AS full_path_name,
       IFNULL(direct.n, 0) AS products, IFNULL(direct.n_active, 0) AS products_active,
       subtree.n_subtree AS products_subtree
FROM c
LEFT JOIN direct ON direct.cid = c.id
LEFT JOIN subtree ON subtree.cid = c.id
LEFT JOIN anc ON anc.cid = c.id
LEFT JOIN par ON par.cid = c.id
ORDER BY c.path;
