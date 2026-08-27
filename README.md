# WULPUS hardware and embedded archive

This repository is a traceable, GitHub-ready consolidation of the public WULPUS hardware, firmware, host software, manufacturing outputs, and the 2026-08-23 missing-component audit. It keeps the two product lines separate:

- **WULPUS v1**: the four-board system used for the original wearable probe (Acquisition, High-Voltage MUX, MSP430 programmer, and nRF52 programmer), plus the silicone package.
- **WULPUS PRO**: the later acquisition development board and the optional polyCMUT adapter. The PRO board integrates the acquisition and high-voltage functions and must not be ordered as the v1 four-board set.

The official source snapshots are preserved byte-for-byte in the board `source/` and firmware/software directories. Manufacturer-ready Gerber, NC Drill, BOM, CPL, assembly drawings, stackups, checklists, and order archives are kept beside each board under `manufacturing/`.

## Board index

| Product line | Board | Design source | Manufacturer package | Notes |
|---|---|---|---|---|
| WULPUS v1 | Acquisition PCB | [`hardware/wulpus-v1/acquisition-pcb/source`](hardware/wulpus-v1/acquisition-pcb/source) | [`hardware/wulpus-v1/acquisition-pcb/manufacturing`](hardware/wulpus-v1/acquisition-pcb/manufacturing) | 8-channel acquisition, MSP430FR5043 + nRF52832 |
| WULPUS v1 | High-Voltage PCB | [`hardware/wulpus-v1/hv-pcb/source`](hardware/wulpus-v1/hv-pcb/source) | [`hardware/wulpus-v1/hv-pcb/manufacturing`](hardware/wulpus-v1/hv-pcb/manufacturing) | HV2707 MUX and TX/RX switch |
| WULPUS v1 | MSP430 programmer | [`hardware/wulpus-v1/msp430-programmer/source`](hardware/wulpus-v1/msp430-programmer/source) | [`hardware/wulpus-v1/msp430-programmer/manufacturing`](hardware/wulpus-v1/msp430-programmer/manufacturing) | J_OLMX1 is manual solder |
| WULPUS v1 | nRF52 programmer | [`hardware/wulpus-v1/nrf52-programmer/source`](hardware/wulpus-v1/nrf52-programmer/source) | [`hardware/wulpus-v1/nrf52-programmer/manufacturing`](hardware/wulpus-v1/nrf52-programmer/manufacturing) | S_NRDC1 is manual solder |
| WULPUS v1 | Silicone package | [`hardware/wulpus-v1/silicone-package/source`](hardware/wulpus-v1/silicone-package/source) | n/a | FDM and resin mold STL files |
| WULPUS PRO | Acquisition development board | [`hardware/wulpus-pro/acquisition-dev-board/source`](hardware/wulpus-pro/acquisition-dev-board/source) | [`hardware/wulpus-pro/acquisition-dev-board/manufacturing`](hardware/wulpus-pro/acquisition-dev-board/manufacturing) | Read the PRO errata before assembly |
| WULPUS PRO | polyCMUT adapter | [`hardware/wulpus-pro/polycmut-adapter/source`](hardware/wulpus-pro/polycmut-adapter/source) | [`hardware/wulpus-pro/polycmut-adapter/manufacturing`](hardware/wulpus-pro/polycmut-adapter/manufacturing) | Optional adapter; J5/P1 are manual/external |

The board-specific READMEs are the authoritative quick-start for file selection and manual-solder exclusions. The complete board list is also available in [`docs/board-index/README.md`](docs/board-index/README.md).

## Repository layout

```text
hardware/       Altium source and per-board production files
firmware/       Official MSP430, nRF52, and ESP32-C6 source trees
software/       Official Python host applications and notebooks
docs/           Manuals, assembly notes, errata, and manufacturing guidance
analysis/       Selected, non-runtime design and reverse-engineering reports
reference/      Source-repository maps and datasheet indexes (not vendor PDF copies)
provenance/     Source commits, hashes, manifests, and exclusion decisions
projects/       Separate 9959 Control Integrated Board handover
tools/scripts/  Cross-platform manifest and repository validation scripts
```

## Manufacturing workflow

1. Select exactly one product line and one board from the index. Do not combine v1 and PRO BOMs.
2. Read the board README, its `manufacturing/jlcpcb/README_*.md`, and any linked errata.
3. Upload the board's flat Gerber ZIP from `01_PCB_Gerber_Drill/` to the PCB fabricator. For PCBA, use the matching `BOM_JLCPCB.csv`, `CPL_JLCPCB.csv`, `COMPONENT_CHECKLIST.csv`, assembly drawing, and stackup.
4. Keep all components marked manual/external in the checklist out of SMT placement and solder them in the stated post-assembly step.
5. Compare the factory output against the source schematic, PCB, and placement file before releasing a batch. Build one to three engineering samples first.

The v1 missing-component audit is in [`docs/manufacturing/missing-components`](docs/manufacturing/missing-components). It identifies 25 actual SMT positions requiring attention: seven on Y19/HV and eighteen on Y20/Acquisition. The audit also records the current DNP positions, LCSC checks, source hashes, and the rule that no unapproved substitute may be loaded into the factory BOM.

### Missing-component decision summary

| Board | Actual positions to install | Current official DNP positions | Action |
|---|---:|---|---|
| Y19 / HV | 7: `U4`, `C12`, `C14`, `C18`, `C21`, `R7`, `L2` | `C9`, `C10`, `C11`, `C16`, `C20`, `R9` | Install official MPNs; verify HV safety and AOI |
| Y20 / Acquisition | 18: `J3`, `J4`, `L3`, `C1`, `C4`, `C8`, `C9`, `C50`, `C39`, `R2`, `R19`, `R20`, `R14`, `R26`, `R28`, `R30`, `E1`, `U6` | `R3`, `R21`, `R32`, `R33`, `C5`, `C46` | Install official MPNs; `P1/P2` remain post-SMT hand solder |

Only the exact Samtec connector `LSHM-120-02.5-L-DV-A-N-K-TR` (LCSC `C6287797`) was directly available in the 2026-08-23 check. All other LCSC values are dynamic or require engineering approval. The audit's B/C decisions are not blanket substitutions. Re-check stock, lot, datasheet revision, footprint, electrical stress, and first-article test immediately before ordering.

## Firmware and host software

The v1 firmware and GUI are under [`firmware/wulpus-v1`](firmware/wulpus-v1) and
[`software/wulpus`](software/wulpus). The official v1 debug entry is
[`software/wulpus/GUI_ENTRY.md`](software/wulpus/GUI_ENTRY.md), which points to
the upstream notebook and the `wulpus/` GUI package. PRO firmware and GUI are
under [`firmware/wulpus-pro`](firmware/wulpus-pro) and
[`software/wulpus-pro`](software/wulpus-pro); its three official debug
workflows are indexed in [`software/wulpus-pro/GUI_ENTRY.md`](software/wulpus-pro/GUI_ENTRY.md).
Toolchains and vendor SDK installers are intentionally not bundled; follow
each directory's official setup notes.

## Safety

The boards include high-voltage ultrasound transmit circuitry and stored energy. Use a current-limited supply, a dummy load, and a discharge procedure for the first power-up. Verify 3V3, 5V, 15V/HV rails and connector orientation before connecting a transducer. Disconnect power and confirm capacitors are discharged before probing. No design in this archive has been certified for human use.

## Provenance and licensing

The exact upstream repositories, branches, commits, file counts, and local source paths are recorded in [`provenance/SOURCE_REPOSITORIES.md`](provenance/SOURCE_REPOSITORIES.md). SHA256 and a deterministic file manifest are generated in [`provenance/`](provenance/). The two private user BOM workbooks are not copied into this public-ready tree; their paths and SHA256 values are recorded in [`docs/manufacturing/missing-components/USER_BOM_PROVENANCE.md`](docs/manufacturing/missing-components/USER_BOM_PROVENANCE.md).

Licenses are component-specific. See [`LICENSES/README.md`](LICENSES/README.md), the upstream `hw/LICENSE` and `sw/LICENSE` copies, and the third-party notices shipped with the firmware. Vendor datasheet PDFs are not redistributed here; their names, source links, and hashes are listed in [`reference/datasheets`](reference/datasheets).

## GitHub publication status

This directory is a self-contained local Git repository candidate. It deliberately has no guessed remote URL: pushing to either upstream project would mix an integration archive into an official product repository. Configure a new destination repository supplied by the owner, review the generated manifest, then push the committed branch. No claim of a remote upload is made until `git push` returns a verifiable result.
