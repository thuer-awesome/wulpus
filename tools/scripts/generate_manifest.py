#!/usr/bin/env python3
"""Generate or verify deterministic SHA256 manifests for this repository."""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import os
import subprocess
import sys
from functools import lru_cache
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "provenance" / "FILE_MANIFEST.csv"
SUMS = ROOT / "provenance" / "SHA256SUMS.txt"
EXCLUDED = {MANIFEST.relative_to(ROOT).as_posix(), SUMS.relative_to(ROOT).as_posix()}
LFS_POINTER_PREFIX = b"version https://git-lfs.github.com/spec/v1\n"


class ManifestError(RuntimeError):
    """Raised when a tracked file cannot be read deterministically."""


def _decode_git_path(raw_path: bytes) -> str:
    """Decode a NUL-delimited Git path without Git's quote-path rewriting."""

    return raw_path.decode("utf-8", errors="surrogateescape")


def _index_entries() -> dict[str, str]:
    """Return stage-zero (or lowest-stage) index paths and their blob IDs."""

    try:
        raw = subprocess.check_output(
            ["git", "ls-files", "--stage", "-z"], cwd=ROOT, stderr=subprocess.PIPE
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        raise ManifestError("cannot read the Git index; run this script inside a Git repository") from exc

    entries: dict[str, tuple[int, str]] = {}
    for record in raw.split(b"\0"):
        if not record:
            continue
        metadata, separator, raw_path = record.partition(b"\t")
        fields = metadata.split()
        if separator != b"\t" or len(fields) != 3:
            raise ManifestError(f"unexpected `git ls-files --stage` record: {record!r}")
        _mode, object_id, raw_stage = fields
        try:
            stage = int(raw_stage)
        except ValueError as exc:
            raise ManifestError(f"invalid index stage for {_decode_git_path(raw_path)}") from exc
        path = _decode_git_path(raw_path)
        object_text = object_id.decode("ascii")
        previous = entries.get(path)
        if previous is None or stage < previous[0]:
            entries[path] = (stage, object_text)
    return {path: object_id for path, (_stage, object_id) in entries.items()}


def _batch_blob_data(object_ids: list[str]) -> dict[str, bytes]:
    """Read index blobs in one Git process to avoid one subprocess per file."""

    if not object_ids:
        return {}
    try:
        process = subprocess.Popen(
            ["git", "cat-file", "--batch"],
            cwd=ROOT,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except FileNotFoundError as exc:
        raise ManifestError("Git executable is not available") from exc
    request = b"".join(object_id.encode("ascii") + b"\n" for object_id in object_ids)
    stdout, stderr = process.communicate(request)
    if process.returncode:
        detail = stderr.decode("utf-8", errors="replace").strip()
        raise ManifestError(f"git cat-file --batch failed: {detail or process.returncode}")

    result: dict[str, bytes] = {}
    cursor = 0
    for object_id in object_ids:
        line_end = stdout.find(b"\n", cursor)
        if line_end < 0:
            raise ManifestError(f"truncated Git batch response for {object_id}")
        header = stdout[cursor:line_end].split()
        cursor = line_end + 1
        if len(header) != 3 or header[0].decode("ascii", errors="replace") != object_id:
            raise ManifestError(f"invalid Git batch response for {object_id}: {header!r}")
        object_type = header[1].decode("ascii", errors="replace")
        if object_type == "missing":
            raise ManifestError(f"Git index object is missing: {object_id}")
        try:
            size = int(header[2])
        except ValueError as exc:
            raise ManifestError(f"invalid Git batch size for {object_id}") from exc
        data = stdout[cursor : cursor + size]
        if len(data) != size or cursor + size >= len(stdout) or stdout[cursor + size : cursor + size + 1] != b"\n":
            raise ManifestError(f"truncated Git batch object for {object_id}")
        cursor += size + 1
        result[object_id] = data
    return result


def _lfs_pointer_oid(data: bytes) -> str | None:
    """Return the SHA256 OID from a Git LFS pointer, if ``data`` is one."""

    if not data.startswith(LFS_POINTER_PREFIX):
        return None
    for line in data.splitlines()[1:]:
        if line.startswith(b"oid sha256:"):
            oid = line[len(b"oid sha256:") :].strip().decode("ascii", errors="ignore")
            if len(oid) == 64 and all(character in "0123456789abcdef" for character in oid):
                return oid
    return None


@lru_cache(maxsize=1)
def _git_dir() -> Path:
    """Resolve the repository's common Git directory (including worktrees)."""

    try:
        raw = subprocess.check_output(
            ["git", "rev-parse", "--git-dir"], cwd=ROOT, stderr=subprocess.PIPE
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        raise ManifestError("cannot resolve the Git directory") from exc
    value = Path(os.fsdecode(raw.strip()))
    return value if value.is_absolute() else (ROOT / value).resolve()


def _lfs_storage_roots() -> list[Path]:
    """Return standard and configured Git LFS storage locations."""

    roots = [_git_dir() / "lfs"]
    try:
        configured = subprocess.run(
            ["git", "config", "--path", "--get", "lfs.storage"],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        ).stdout.strip()
    except FileNotFoundError:
        configured = b""
    if configured:
        configured_path = Path(os.fsdecode(configured))
        if not configured_path.is_absolute():
            configured_path = (ROOT / configured_path).resolve()
        if configured_path not in roots:
            roots.append(configured_path)
    return roots


def _read_local_lfs_object(pointer_oid: str) -> bytes | None:
    """Read a hydrated LFS object directly, avoiding a filter subprocess per file."""

    for storage in _lfs_storage_roots():
        candidate = storage / "objects" / pointer_oid[:2] / pointer_oid[2:4] / pointer_oid
        try:
            data = candidate.read_bytes()
        except FileNotFoundError:
            continue
        if hashlib.sha256(data).hexdigest() != pointer_oid:
            raise ManifestError(f"LFS object hash mismatch: {candidate}")
        return data
    return None


def _hydrated_lfs_bytes(path: Path, pointer_oid: str) -> bytes:
    """Return hydrated LFS bytes after validating the pointer OID."""

    rel = path.relative_to(ROOT).as_posix()
    local_data = _read_local_lfs_object(pointer_oid)
    if local_data is not None:
        return local_data

    # A hydrated worktree copy can be used as a fallback when the LFS object
    # directory is external (for example, a shared cache) but the bytes still
    # prove the exact OID recorded by the index pointer.
    if path.is_file():
        worktree_data = path.read_bytes()
        if _lfs_pointer_oid(worktree_data) is None and hashlib.sha256(worktree_data).hexdigest() == pointer_oid:
            return worktree_data

    raise ManifestError(
        f"LFS object for {rel} is not hydrated; run `git lfs pull`/`git lfs checkout` before generating the manifest"
    )


def _index_text_attributes() -> dict[str, bool]:
    """Return Git's text/binary classification for every indexed path."""

    try:
        raw = subprocess.check_output(
            ["git", "ls-files", "--eol", "-z"], cwd=ROOT, stderr=subprocess.PIPE
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        raise ManifestError("cannot read Git end-of-line attributes") from exc

    result: dict[str, bool] = {}
    for record in raw.split(b"\0"):
        if not record:
            continue
        header, separator, raw_path = record.rpartition(b"\t")
        if separator != b"\t":
            raise ManifestError(f"unexpected `git ls-files --eol` record: {record!r}")
        tokens = header.split()
        # `attr/text=auto` and `attr/text` are text; `attr/-text` is binary.
        is_text = any(token.startswith(b"attr/text") for token in tokens)
        result[_decode_git_path(raw_path)] = is_text
    return result


def _normalize_text(data: bytes) -> bytes:
    """Match Git's LF checkout convention for files marked as text."""

    return data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")


def _tracked_bytes() -> dict[str, bytes]:
    """Read tracked files with stable text and hydrated LFS representations."""

    entries = _index_entries()
    blobs = _batch_blob_data(sorted(set(entries.values())))
    text_attributes = _index_text_attributes()
    result: dict[str, bytes] = {}
    for rel, object_id in entries.items():
        data = blobs[object_id]
        pointer_oid = _lfs_pointer_oid(data)
        if pointer_oid is not None:
            data = _hydrated_lfs_bytes(ROOT / Path(rel), pointer_oid)
        else:
            worktree = ROOT / Path(rel)
            if worktree.is_file():
                data = worktree.read_bytes()
                if text_attributes.get(rel, False):
                    data = _normalize_text(data)
        result[rel] = data
    return result


def _is_ignored(rel: str) -> bool:
    """Return whether Git ignores an untracked path in this repository."""

    try:
        result = subprocess.run(
            ["git", "check-ignore", "-q", "--", rel],
            cwd=ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except FileNotFoundError as exc:
        raise ManifestError("Git executable is not available") from exc
    return result.returncode == 0


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def rows() -> list[tuple[str, int, str]]:
    tracked = _tracked_bytes()
    result: list[tuple[str, int, str]] = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if "__pycache__" in path.parts or path.suffix == ".pyc":
            continue
        rel = path.relative_to(ROOT).as_posix()
        if rel in EXCLUDED or rel.startswith(".git/"):
            continue
        # The published tree contains tracked files and any new, non-ignored
        # files awaiting `git add`; local logs/caches must not affect hashes.
        if rel not in tracked and _is_ignored(rel):
            continue
        data = tracked.get(rel)
        if data is None:
            data = path.read_bytes()
        result.append((rel, len(data), hashlib.sha256(data).hexdigest()))
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
    try:
        items = rows()
    except ManifestError as exc:
        print(f"manifest error: {exc}", file=sys.stderr)
        return 2
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
