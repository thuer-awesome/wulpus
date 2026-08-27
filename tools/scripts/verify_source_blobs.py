#!/usr/bin/env python3
"""Compare mapped integration files with canonical upstream Git blobs.

This is an assembly-time audit. It accepts the two local upstream clone roots;
the published repository does not require those private clone paths. Text
files are read from Git blobs (therefore LF-normalized), while files tracked by
Git LFS are read from a hydrated object and checked against the pointer OID.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MAP_PATH = ROOT / "provenance" / "SOURCE_FILE_MAP.csv"
LFS_POINTER_PREFIX = b"version https://git-lfs.github.com/spec/v1\n"


class VerificationError(RuntimeError):
    """Raised when a required source or LFS object cannot be read."""


def git_blob(repo: Path, revision: str, source_path: str) -> bytes:
    """Read one canonical Git blob without applying checkout filters."""

    try:
        return subprocess.check_output(
            ["git", "-C", str(repo), "cat-file", "blob", f"{revision}:{source_path}"],
            stderr=subprocess.PIPE,
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        detail = ""
        if isinstance(exc, subprocess.CalledProcessError):
            detail = exc.stderr.decode("utf-8", errors="replace").strip()
        raise VerificationError(
            f"cannot read Git blob {repo}:{revision}:{source_path}: {detail or exc}"
        ) from exc


def lfs_pointer_oid(data: bytes) -> str | None:
    """Return the SHA256 OID from a Git LFS pointer, if ``data`` is one."""

    if not data.startswith(LFS_POINTER_PREFIX):
        return None
    for line in data.splitlines()[1:]:
        if line.startswith(b"oid sha256:"):
            oid = line[len(b"oid sha256:") :].strip().decode("ascii", errors="ignore")
            if len(oid) == 64 and all(char in "0123456789abcdef" for char in oid):
                return oid
    return None


def git_dir() -> Path:
    try:
        raw = subprocess.check_output(
            ["git", "rev-parse", "--git-dir"], cwd=ROOT, stderr=subprocess.PIPE
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        raise VerificationError("cannot resolve the integration repository Git directory") from exc
    value = Path(os.fsdecode(raw.strip()))
    return value if value.is_absolute() else (ROOT / value).resolve()


def lfs_storage_roots() -> list[Path]:
    roots = [git_dir() / "lfs"]
    try:
        raw = subprocess.run(
            ["git", "config", "--path", "--get", "lfs.storage"],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        ).stdout.strip()
    except FileNotFoundError:
        raw = b""
    if raw:
        configured = Path(os.fsdecode(raw))
        if not configured.is_absolute():
            configured = (ROOT / configured).resolve()
        if configured not in roots:
            roots.append(configured)
    return roots


def hydrated_lfs_bytes(path: Path, oid: str) -> bytes:
    """Read a hydrated LFS object from local storage or the worktree."""

    for storage in lfs_storage_roots():
        candidate = storage / "objects" / oid[:2] / oid[2:4] / oid
        try:
            data = candidate.read_bytes()
        except FileNotFoundError:
            continue
        if hashlib.sha256(data).hexdigest() != oid:
            raise VerificationError(f"LFS object hash mismatch: {candidate}")
        return data

    if path.is_file():
        data = path.read_bytes()
        if lfs_pointer_oid(data) is None and hashlib.sha256(data).hexdigest() == oid:
            return data
    raise VerificationError(
        f"LFS object for {path.relative_to(ROOT).as_posix()} is not hydrated; "
        "run `git lfs pull`/`git lfs checkout` before verification"
    )


def integrated_bytes(integrated_path: str) -> tuple[bytes, bool]:
    """Read the committed integration representation and report LFS status."""

    path = ROOT / Path(integrated_path)
    try:
        data = git_blob(ROOT, "HEAD", integrated_path)
    except VerificationError:
        if not path.is_file():
            raise
        # This fallback supports an assembly audit before the first commit.
        return path.read_bytes(), False
    oid = lfs_pointer_oid(data)
    return (hydrated_lfs_bytes(path, oid), True) if oid is not None else (data, False)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def write_map(rows: list[dict[str, str]]) -> None:
    MAP_PATH.parent.mkdir(parents=True, exist_ok=True)
    with MAP_PATH.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(
            stream,
            fieldnames=[
                "source_repo",
                "source_path",
                "integrated_path",
                "source_sha256",
                "integrated_sha256",
                "status",
            ],
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--v1-root", type=Path, required=True)
    parser.add_argument("--pro-root", type=Path, required=True)
    parser.add_argument(
        "--rewrite-map",
        action="store_true",
        help="rewrite SOURCE_FILE_MAP.csv with canonical SHA256 values",
    )
    args = parser.parse_args()
    roots = {
        "pulp-bio/wulpus@48a913c9": args.v1_root,
        "pulp-bio/wulpus-pro@d49cf62a": args.pro_root,
    }
    try:
        rows = list(csv.DictReader(MAP_PATH.open(encoding="utf-8-sig", newline="")))
    except (FileNotFoundError, OSError) as exc:
        print(f"ERROR: cannot read {MAP_PATH}: {exc}", file=sys.stderr)
        return 1

    errors: list[str] = []
    updated: list[dict[str, str]] = []
    for row in rows:
        source_repo = row.get("source_repo", "")
        source_path = row.get("source_path", "")
        integrated_path = row.get("integrated_path", "")
        try:
            source_root = roots[source_repo]
            integrated_data, is_lfs = integrated_bytes(integrated_path)
            if is_lfs:
                # LFS preserves the source checkout bytes. This matters for
                # upstream text-classified design files that were checked out
                # with CRLF before being copied into the integration tree.
                source_file = source_root / Path(source_path)
                source_data = source_file.read_bytes() if source_file.is_file() else git_blob(source_root, "HEAD", source_path)
            else:
                # Non-LFS text is represented by canonical Git blobs on both
                # sides, independent of the local checkout line ending.
                source_data = git_blob(source_root, "HEAD", source_path)
            source_sha = digest(source_data)
            integrated_sha = digest(integrated_data)
        except (KeyError, VerificationError) as exc:
            errors.append(f"{source_repo}:{source_path}: {exc}")
            source_sha = row.get("source_sha256", "")
            integrated_sha = row.get("integrated_sha256", "")
        status = "MATCH" if source_sha == integrated_sha else "MISMATCH"
        if status != "MATCH":
            errors.append(
                f"{source_path} -> {integrated_path}: source {source_sha} != integrated {integrated_sha}"
            )
        if row.get("source_sha256", "").upper() != source_sha or row.get("integrated_sha256", "").upper() != integrated_sha:
            errors.append(f"stale recorded hash: {source_path} -> {integrated_path}")
        updated.append(
            {
                "source_repo": source_repo,
                "source_path": source_path,
                "integrated_path": integrated_path,
                "source_sha256": source_sha,
                "integrated_sha256": integrated_sha,
                "status": status,
            }
        )

    if args.rewrite_map:
        write_map(updated)
        print(f"rewrote {MAP_PATH} with {len(updated)} canonical rows")
    if errors:
        print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
        return 1
    print(f"upstream Git blob comparison OK: {len(rows)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
