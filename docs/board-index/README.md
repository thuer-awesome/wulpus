# Board index

Use this page to choose the correct design family before ordering parts. The
v1 system needs four boards; the PRO acquisition board combines the v1
acquisition and high-voltage functions and therefore uses a different BOM.

| ID | Product | Purpose | Source | Production package | SMT / manual notes |
|---|---|---|---|---|---|
| `wulpus-v1-acquisition` | WULPUS v1 | MSP430FR5043 acquisition + nRF52832 BLE | [`hardware/wulpus-v1/acquisition-pcb/source`](../../hardware/wulpus-v1/acquisition-pcb/source) | [`hardware/wulpus-v1/acquisition-pcb/manufacturing`](../../hardware/wulpus-v1/acquisition-pcb/manufacturing) | 61 BOM groups, 121 placements; P1/P2 are post-SMT through-hole headers |
| `wulpus-v1-hv` | WULPUS v1 | HV2707 multiplexer and TX/RX switch | [`hardware/wulpus-v1/hv-pcb/source`](../../hardware/wulpus-v1/hv-pcb/source) | [`hardware/wulpus-v1/hv-pcb/manufacturing`](../../hardware/wulpus-v1/hv-pcb/manufacturing) | 25 BOM groups, 48 placements; all listed placements are SMT |
| `wulpus-v1-msp430-programmer` | WULPUS v1 | MSP430 programming adapter | [`hardware/wulpus-v1/msp430-programmer/source`](../../hardware/wulpus-v1/msp430-programmer/source) | [`hardware/wulpus-v1/msp430-programmer/manufacturing`](../../hardware/wulpus-v1/msp430-programmer/manufacturing) | 2 BOM groups / 2 placements; J_OLMX1 manual solder |
| `wulpus-v1-nrf52-programmer` | WULPUS v1 | nRF52 programming adapter | [`hardware/wulpus-v1/nrf52-programmer/source`](../../hardware/wulpus-v1/nrf52-programmer/source) | [`hardware/wulpus-v1/nrf52-programmer/manufacturing`](../../hardware/wulpus-v1/nrf52-programmer/manufacturing) | 2 BOM groups / 2 placements; S_NRDC1 manual solder |
| `wulpus-v1-silicone` | WULPUS v1 | Soft package molds | [`hardware/wulpus-v1/silicone-package/source`](../../hardware/wulpus-v1/silicone-package/source) | n/a | Choose FDM or resin STL according to the mold process |
| `wulpus-pro-acquisition` | WULPUS PRO | Integrated acquisition/HV development board | [`hardware/wulpus-pro/acquisition-dev-board/source`](../../hardware/wulpus-pro/acquisition-dev-board/source) | [`hardware/wulpus-pro/acquisition-dev-board/manufacturing`](../../hardware/wulpus-pro/acquisition-dev-board/manufacturing) | 65 BOM groups / 164 designators; 157 SMT placements; X1/X3/X4/X5/X6/X7/X8 are PTH/manual |
| `wulpus-pro-polycmut` | WULPUS PRO | Optional polyCMUT adapter | [`hardware/wulpus-pro/polycmut-adapter/source`](../../hardware/wulpus-pro/polycmut-adapter/source) | [`hardware/wulpus-pro/polycmut-adapter/manufacturing`](../../hardware/wulpus-pro/polycmut-adapter/manufacturing) | 4 BOM groups / 12 designators; 10 SMT placements; J5/P1 are external/manual |

## Revision and source rule

The v1 source snapshot is `pulp-bio/wulpus` `main` at commit
`48a913c9c20c5220b92e19e274565a9e9881cee6` (tag `v1.2.3`). The PRO snapshot is
`pulp-bio/wulpus-pro` `dev` at commit
`d49cf62a53e260d7670d7375b2f6ca3aad627ea7`. Do not mix a board's source,
schematic PDF, BOM, CPL, or Gerber files across revisions.

