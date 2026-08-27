# WULPUS v1 production files

The four v1 board folders under `hardware/wulpus-v1/` contain complete JLCPCB
packages and vendor-ready fabrication archives. The source snapshot is
`pulp-bio/wulpus` `main` at `48a913c9c20c5220b92e19e274565a9e9881cee6`.

For the main probe, order the Acquisition PCB and High-Voltage PCB as a pair.
The MSP430 and nRF52 programmer boards are optional adapters. P1/P2 on the
Acquisition board and J_OLMX1/S_NRDC1 on the programmer boards are manual-solder
or external parts and are intentionally excluded from SMT placement.

