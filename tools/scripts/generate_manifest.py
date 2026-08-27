#!/usr/bin/env python3
"""Generate or verify deterministic SHA256 manifests for this repository."""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "provenance" / "FILE_MANIFEST.csv"
SUMS = ROOT / "provenance" / "SHA256SUMS.txt"
EXCLUDED = {MANIFEST.relative_to(ROOT).as_posix(), SUMS.relative_to(ROOT).as_posix()}


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def rows() -> list[tuple[str, int, str]]:
    result: list[tuple[str, int, str]] = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if "__pycache__" in path.parts or path.suffix == ".pyc":
            continue
        rel = path.relative_to(ROOT).as_posix()
        if rel in EXCLUDED or rel.startswith(".git/"):
            continue
        result.append((rel, path.stat().st_size, digest(path)))
    return sorted(result, key=lambda item: item[0])


def csv_bytes(items: list[tuple[str, int, str]]) -> str:
    stream = io.StringIO()
    writer = csv.writer(stream, lineterminator="\n")
    writer.writerow(["path", "bytes", "sha256"])
    writer.writerows(items)
    return stream.getvalue()


def sums_text(items: list[tuple[str, int, str]]) -> str:
    return "".join(f"{sha}  {path}\n" for path, _size, sha in items)


def check_file(path: Path, expected: str) -> bool:
    if not path.exists():
        print(f"missing manifest: {path}", file=sys.stderr)
        return False
    actual = path.read_text(encoding="utf-8")
    if actual != expected:
        print(f"manifest differs: {path}", file=sys.stderr)
        return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail when committed manifests are stale")
    args = parser.parse_args()
    items = rows()
    expected_csv = csv_bytes(items)
    expected_sums = sums_text(items)
    if args.check:
        ok = check_file(MANIFEST, expected_csv) and check_file(SUMS, expected_sums)
        if ok:
            print(f"manifest OK: {len(items)} files")
            return 0
        return 1
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(expected_csv, encoding="utf-8", newline="")
    SUMS.write_text(expected_sums, encoding="utf-8", newline="")
    print(f"wrote {len(items)} file hashes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
