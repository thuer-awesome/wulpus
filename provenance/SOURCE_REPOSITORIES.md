# Source repositories

The integration tree was assembled from clean shallow clones and local
reproduction packages. The upstream files under `source/`, `firmware/`, and
`software/` were copied without content edits.

| Product line | Upstream | Branch/tag | Snapshot commit | Commit date | Tracked files |
|---|---|---|---|---|---:|
| WULPUS v1 | https://github.com/pulp-bio/wulpus | `main` / `v1.2.3` | `48a913c9c20c5220b92e19e274565a9e9881cee6` | 2026-06-21 | 336 |
| WULPUS PRO | https://github.com/pulp-bio/wulpus-pro | `dev` | `d49cf62a53e260d7670d7375b2f6ca3aad627ea7` | 2025-11-08 | 349 |

Local source roots used during assembly:

- `E:\HJM暑假交付\电子框图\wulpus\wulpus\source_current`
- `E:\HJM暑假交付\电子框图\wulpus\wulpus_pro\source_pro`
- `E:\HJM暑假交付\电子框图\wulpus\wulpus\wulpus_reproduction_package`
- `E:\HJM暑假交付\电子框图\wulpus\wulpus_pro\wulpus_pro_reproduction_package`

The reproduction package metadata contains historical path text referring to
`E:\电子框图\...`; that stale text does not change the snapshot hash or the
actual source used here. No submodules or Git LFS objects were present in either
upstream snapshot.

`SOURCE_FILE_MAP.csv` contains 685 row-level SHA256 comparisons (336 v1 files
and 349 PRO files). Every mapped upstream file is marked `MATCH`; this is the
check that the reclassification did not alter the official source bytes. For a
normal text path, both hashes are computed from the canonical LF Git blobs. For
an integration path stored in Git LFS, both hashes are computed from the
hydrated payload bytes; this preserves upstream checkout bytes for Altium
files whose source worktree used CRLF. Re-run the assembly-time audit with:

```powershell
python tools/scripts/verify_source_blobs.py `
  --v1-root E:\HJM暑假交付\电子框图\wulpus\wulpus\source_current `
  --pro-root E:\HJM暑假交付\电子框图\wulpus\wulpus_pro\source_pro
```

Package-only extras that are useful for reproduction (combined JLCPCB archives,
the cleaned v1 Conda file, and original package metadata) are retained under
`docs/manufacturing/` and `docs/provenance/`; generated Python caches and full
snapshot ZIPs are excluded as documented separately.
