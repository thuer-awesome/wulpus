# Provenance

This directory records how the archive was assembled and how it can be
reproduced:

- [`SOURCE_REPOSITORIES.md`](SOURCE_REPOSITORIES.md): upstream URLs, commits,
  branches, and file counts.
- [`SOURCE_FILE_MAP.csv`](SOURCE_FILE_MAP.csv): 685 row-level source-to-
  integration comparisons.
- [`FILE_MANIFEST.csv`](FILE_MANIFEST.csv) and [`SHA256SUMS.txt`](SHA256SUMS.txt):
  deterministic hashes for the published payload.
- [`boards.json`](boards.json): required files for each of the seven board or
  package entries.
- [`EXCLUDED_ARTIFACTS.md`](EXCLUDED_ARTIFACTS.md): intentionally omitted
  installers, caches, private workbooks, and temporary files.
- [`PUBLISHING.md`](PUBLISHING.md): GitHub/LFS release checklist.

Run the scripts under [`tools/scripts/`](../tools/scripts/) before publishing a
new revision.
