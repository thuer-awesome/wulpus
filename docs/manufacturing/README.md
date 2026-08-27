# Manufacturing index

Each board keeps its source and its factory payload together:

```text
hardware/<product>/<board>/source/                         Altium source and source-side exports
hardware/<product>/<board>/manufacturing/jlcpcb/            unpacked JLCPCB upload package
hardware/<product>/<board>/manufacturing/fab-order/        complete vendor ZIP
```

Use the unpacked package to inspect and audit files; use the matching ZIP only
after confirming its SHA256 in `provenance/FILE_MANIFEST.csv`. The `README_*.md`
and `FILE_LIST.txt` in every JLCPCB package are part of the release and should
be sent to the manufacturer with the BOM/CPL.

The smaller combined JLCPCB archives are retained under
`docs/manufacturing/wulpus-v1/archives/` and
`docs/manufacturing/wulpus-pro/archives/` for compatibility with tooling that
expects the original package layout. The large full-repository snapshot ZIPs
are intentionally excluded as redundant.

## Required factory checks

- Confirm board name, revision, layer count, thickness, copper, and impedance
  against the board README and stackup.
- Confirm the Gerber ZIP, NC Drill, BOM, CPL, and assembly drawing all refer to
  the same board and variant.
- Treat `COMPONENT_CHECKLIST.csv` as the assembly sign-off list. Items marked
  manual/external are not missing SMT parts.
- For Y19/Y20, use the audit in
  [`missing-components`](missing-components) and do not change an MPN solely
  because a live LCSC stock value changed.
