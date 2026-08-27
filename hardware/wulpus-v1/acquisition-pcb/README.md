# WULPUS v1 Acquisition PCB

This folder contains the official Altium source and the production-ready JLCPCB
package for the v1 acquisition board.

## Files to use

- Design source: [`source/wulpus_acq_pcb.PrjPcb`](source/wulpus_acq_pcb.PrjPcb),
  [`source/PCB1.PcbDoc`](source/PCB1.PcbDoc), the `.SchDoc` sheets, libraries,
  and the source `docs/` fabrication exports.
- JLCPCB package: [`manufacturing/jlcpcb`](manufacturing/jlcpcb). Upload the
  flat Gerber archive in `01_PCB_Gerber_Drill/` and use the matching BOM/CPL in
  `02_PCBA_BOM_CPL/`.
- Factory archive: [`manufacturing/fab-order/acquisition_pcb_fab_order.zip`](manufacturing/fab-order/acquisition_pcb_fab_order.zip).

The official package contains 61 BOM groups and 121 designators (60 SMT groups,
119 SMT placements). P1 and P2 are 1x3 through-hole headers intentionally
excluded from SMT and must be hand-soldered after PCBA.

## Y20 missing-component check

The 2026-08-23 audit identifies these 18 actual SMT positions for Y20:
`J3`, `J4`, `L3`, `C1`, `C4`, `C8`, `C9`, `C50`, `C39`, `R2`, `R19`, `R20`,
`R14`, `R26`, `R28`, `R30`, `E1`, `U6`. The official DNP positions remain
`R3`, `R21`, `R32`, `R33`, `C5`, `C46`. Do not treat the DNP list as missing
parts and do not move P1/P2 into the SMT BOM.

Use the consolidated manufacturer sheet at
[`docs/manufacturing/missing-components/BOM_missing_parts_factory_20260823.xlsx`](../../../docs/manufacturing/missing-components/BOM_missing_parts_factory_20260823.xlsx)
and its CSV companion. Substitutions marked B/C in the audit require an
engineering sign-off and first-article test.

