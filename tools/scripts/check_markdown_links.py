#!/usr/bin/env python3
"""Check relative links in integration-authored Markdown files."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[2]
LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
SKIP_PREFIXES = (
    "analysis/",
    "docs/manuals/",
    "docs/provenance/",
    "firmware/",
    "reference/source-repository-maps/",
    "software/",
)


def imported_markdown(rel: str) -> bool:
    if rel.startswith(SKIP_PREFIXES):
        return True
    return "/source/" in rel or "/manufacturing/jlcpcb/" in rel


def main() -> int:
    errors: list[str] = []
    checked = 0
    for markdown in ROOT.rglob("*.md"):
        rel = markdown.relative_to(ROOT).as_posix()
        if ".git/" in rel or imported_markdown(rel):
            continue
        checked += 1
        text = markdown.read_text(encoding="utf-8", errors="replace")
        for raw in LINK_RE.findall(text):
            target = raw.strip().split(maxsplit=1)[0].strip("<>")
            if not target or target.startswith(("#", "http://", "https://", "mailto:")):
                continue
            path_text = unquote(target.split("#", 1)[0])
            resolved = (markdown.parent / path_text).resolve()
            try:
                resolved.relative_to(ROOT)
            except ValueError:
                errors.append(f"{rel}: link escapes repository: {target}")
                continue
            if not resolved.exists():
                errors.append(f"{rel}: missing relative target: {target}")
    if errors:
        print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
        return 1
    print(f"Markdown links OK: {checked} integration-authored files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

