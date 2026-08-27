# Hardware

Hardware is organized by product line and board. Each board keeps the
official Altium source under `source/` and the manufacturer-ready exports,
checklists, and order archives under `manufacturing/`.

## Product lines

- [WULPUS v1](wulpus-v1): Acquisition PCB, High-Voltage MUX PCB, MSP430
  programmer, nRF52 programmer, and silicone package.
- [WULPUS PRO](wulpus-pro): Acquisition development board and optional
  polyCMUT adapter. Read the PRO errata before assembly.

Use one product-line directory per build. Do not combine v1 and PRO BOM/CPL
files. The board-specific README is the release checklist for that board.
