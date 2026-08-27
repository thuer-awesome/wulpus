#!/usr/bin/env python3
"""Validate required boards, audit outputs, and GitHub publication constraints."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN_PARTS = (
    "tools/kicad_portable/",
    "tools/typst_portable/",
    "commercial_fpga_reference/",
    "pcb_reverse_engineering/",
    "tmp/",
)
PRIVATE_NAMES = {"BOM_12364560A_Y19.xls", "BOM_12364560A_Y20.xls"}
MAX_FILE_BYTES = 100 * 1024 * 1024


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)
    print(f"ERROR: {message}", file=sys.stderr)


def check_manifest(errors: list[str]) -> None:
    path = ROOT / "provenance" / "FILE_MANIFEST.csv"
    if not path.exists():
        fail("provenance/FILE_MANIFEST.csv is missing", errors)
        return
    with path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows:
        fail("provenance/FILE_MANIFEST.csv has no file rows", errors)
    if any(not row.get("path") or not row.get("sha256") for row in rows):
        fail("provenance/FILE_MANIFEST.csv contains an incomplete row", errors)


def check_audit(errors: list[str]) -> None:
    audit_dir = ROOT / "docs" / "manufacturing" / "missing-components"
    required = (
        "BOM_missing_parts_factory_20260823.xlsx",
        "BOM_missing_parts_factory_20260823.csv",
        "BOM_missing_parts_audit_20260823.md",
    )
    for name in required:
        if not (audit_dir / name).exists():
            fail(f"missing audit output: docs/manufacturing/missing-components/{name}", errors)
    csv_path = audit_dir / "BOM_missing_parts_factory_20260823.csv"
    if csv_path.exists():
        with csv_path.open(encoding="utf-8-sig", newline="") as stream:
            rows = [row for row in csv.DictReader(stream) if any((value or "").strip() for value in row.values())]
        if len(rows) != 25:
            fail(f"missing-component CSV has {len(rows)} data rows; expected 25", errors)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check-manifest", action="store_true", help="also run generate_manifest.py --check")
    args = parser.parse_args()
    errors: list[str] = []

    board_manifest = ROOT / "provenance" / "boards.json"
    try:
        data = json.loads(board_manifest.read_text(encoding="utf-8"))
    except Exception as exc:  # pragma: no cover - diagnostic path
        fail(f"cannot read provenance/boards.json: {exc}", errors)
        data = {"boards": []}

    boards = data.get("boards", [])
    if len(boards) != 7:
        fail(f"boards.json lists {len(boards)} boards; expected 7 (five v1 entries including silicone and two PRO)", errors)
    expected_ids = {
        "wulpus-v1-acquisition",
        "wulpus-v1-hv",
        "wulpus-v1-msp430-programmer",
        "wulpus-v1-nrf52-programmer",
        "wulpus-pro-acquisition",
        "wulpus-pro-polycmut",
    }
    actual_ids = {board.get("id") for board in boards}
    if not expected_ids.issubset(actual_ids):
        fail(f"boards.json is missing one or more core board IDs: {sorted(expected_ids - actual_ids)}", errors)
    for board in boards:
        for required in board.get("required", []):
            if not (ROOT / required).is_file():
                fail(f"{board.get('id', '<unknown>')}: missing {required}", errors)

    check_audit(errors)
    check_manifest(errors)

    source_map = ROOT / "provenance" / "SOURCE_FILE_MAP.csv"
    if not source_map.exists():
        fail("provenance/SOURCE_FILE_MAP.csv is missing", errors)
    else:
        with source_map.open(encoding="utf-8-sig", newline="") as stream:
            mapped = list(csv.DictReader(stream))
        if len(mapped) != 685:
            fail(f"source file map has {len(mapped)} rows; expected 685", errors)
        if any(row.get("status") != "MATCH" for row in mapped):
            fail("source file map contains a non-MATCH row", errors)

    file_count = 0
    total_bytes = 0
    for path in ROOT.rglob("*"):
        if (
            not path.is_file()
            or ".git" in path.parts
            or "__pycache__" in path.parts
            or path.suffix == ".pyc"
        ):
            continue
        rel = path.relative_to(ROOT).as_posix()
        if rel in {
            "provenance/FILE_MANIFEST.csv",
            "provenance/SHA256SUMS.txt",
        }:
            continue
        file_count += 1
        total_bytes += path.stat().st_size
        if any(rel.startswith(prefix) for prefix in FORBIDDEN_PARTS):
            fail(f"forbidden workspace payload is present: {rel}", errors)
        if path.name in PRIVATE_NAMES:
            fail(f"private source workbook is present: {rel}", errors)
        if path.stat().st_size > MAX_FILE_BYTES:
            fail(f"file exceeds 100 MiB GitHub limit: {rel}", errors)

    if args.check_manifest:
        import subprocess

        result = subprocess.run([sys.executable, str(ROOT / "tools/scripts/generate_manifest.py"), "--check"], cwd=ROOT)
        if result.returncode:
            fail("deterministic manifest check failed", errors)

    if errors:
        print(f"validation failed with {len(errors)} error(s)", file=sys.stderr)
        return 1
    print(f"repository OK: {len(boards)} boards, {file_count} files, {total_bytes / (1024 * 1024):.2f} MiB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
