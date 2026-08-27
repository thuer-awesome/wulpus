# Contributing

Keep the two product lines and their revisions separate. A hardware change
must include the affected schematic, PCB source, manufacturing outputs, BOM/CPL
and a short validation note. Never silently replace a component in a factory
BOM: record the original MPN, proposed substitute, datasheet evidence, stress
checks, and first-article result.

Before opening a pull request:

1. Run `python tools/scripts/generate_manifest.py` and verify the working tree.
2. Run `python tools/scripts/validate_repository.py`.
3. Run `python tools/scripts/check_markdown_links.py`.
4. Check that no file is larger than the GitHub limit and that no private BOM,
   token, tool installer, cache, or temporary render is included.
5. For production changes, attach updated Gerber/BOM/CPL hashes and identify
   whether the change is SMT, manual solder, or a design revision.
