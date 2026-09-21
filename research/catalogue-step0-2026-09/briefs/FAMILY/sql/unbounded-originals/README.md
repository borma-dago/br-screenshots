# FAMILY — unbounded SQL originals

These are the nine queries **as first run** on 2026-09-19, before BRIEF.md §3.4 was amended to pin every
dedup subquery to the shared snapshot instant.

They are kept for provenance only. **Do not re-run them for any figure in the brief**: they take the latest
row per `id` with no upper time bound, so they read production *now* rather than the snapshot, and they
drift. Red-team round 2 demonstrated the drift on `fam-c3-grid.sql`, which moved
1,748 → 1,747 / 747 → 748 / 8,071 → 8,069 within hours of first publication.

The bounded versions in `../` carry
`WHERE datastream_metadata.source_timestamp <= UNIX_MILLIS(TIMESTAMP '2026-09-19 10:27:00+00')` inside every
`ROW_NUMBER()` subquery (17 subqueries across the nine files). Verified 2026-09-19: all nine bounded results
are **byte-identical to the published results** — including `fam-c3-grid`, which the bound restores to
1,748 / 747 / 8,071 — and byte-identical again on an immediate second run. So the bound changed no published
figure; it only made every figure re-derivable.
