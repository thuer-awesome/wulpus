# Y19/Y20 missing-component release

This release is the manufacturer-facing output of the 2026-08-23 cross-check
between the user BOM workbooks, official BOM/CPL, fabrication-ready coordinates,
PCB pads, and schematics.

## Files

- [`BOM_missing_parts_factory_20260823.xlsx`](BOM_missing_parts_factory_20260823.xlsx):
  formatted factory list with source and verification columns.
- [`BOM_missing_parts_factory_20260823.csv`](BOM_missing_parts_factory_20260823.csv):
  plain-text import for a purchasing or SMT system.
- [`BOM_missing_parts_audit_20260823.md`](BOM_missing_parts_audit_20260823.md):
  evidence, DNP exclusions, LCSC checks, and decision rules.
- PNG files in this folder are human-readable render previews of the workbook
  and audit summaries; the CSV/XLSX/Markdown files remain authoritative.

## Scope and count

- Y19 / HV: 7 actual SMT positions (`U4`, `C12`, `C14`, `C18`, `C21`, `R7`,
  `L2`). Current official DNP: `C9`, `C10`, `C11`, `C16`, `C20`, `R9`.
- Y20 / Acquisition: 18 actual SMT positions (`J3`, `J4`, `L3`, `C1`, `C4`,
  `C8`, `C9`, `C50`, `C39`, `R2`, `R19`, `R20`, `R14`, `R26`, `R28`, `R30`,
  `E1`, `U6`). Current official DNP: `R3`, `R21`, `R32`, `R33`, `C5`, `C46`.
- Total: 25 positions and 25 pieces, 13 unique MPNs. Decision levels are A=2,
  B=19, C=4.

`P1/P2` on Y20 are 1x3 through-hole headers explicitly excluded from the SMT
BOM/CPL and must be hand-soldered. `R2` is required in the current design even
though an older changelog called it DNM. `HV2707` is the current part; do not
restore `HV2708`.

## Procurement rule

The only exact MPN with stock in the 2026-08-23 LCSC check was
`LSHM-120-02.5-L-DV-A-N-K-TR` (LCSC `C6287797`, stock 101). Stock is dynamic.
All B/C candidates require engineering approval, datasheet/DC-bias and stress
checks, footprint/height review, and a first-article test. C-level parts must
not be substituted without a signed design change.

