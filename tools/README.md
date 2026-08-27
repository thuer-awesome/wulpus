# Tools

The repository tooling is intentionally small and cross-platform:

- [`scripts/generate_manifest.py`](scripts/generate_manifest.py) generates and
  checks deterministic SHA256 manifests.
- [`scripts/validate_repository.py`](scripts/validate_repository.py) checks
  board payloads, audit row counts, exclusions, and GitHub file limits.
- [`scripts/check_markdown_links.py`](scripts/check_markdown_links.py) checks
  integration-authored relative links.
- [`scripts/verify_source_blobs.py`](scripts/verify_source_blobs.py) compares
  all 685 mapped files with the pinned upstream Git snapshots.

Do not place vendor installers, portable CAD tools, caches, or temporary
renders in this directory; those payloads are excluded by policy.
