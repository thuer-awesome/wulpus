# WULPUS PRO acquisition development board

This is the PRO integrated acquisition/HV development board. It is a separate
product line from the v1 Acquisition + HV pair.

- Design source: [`source/wulpus_pro_acq_pcb.PrjPcb`](source/wulpus_pro_acq_pcb.PrjPcb)
- JLCPCB package: [`manufacturing/jlcpcb`](manufacturing/jlcpcb)
- Factory archive: [`manufacturing/fab-order/wulpus_pro_acquisition_dev_board_fab_order.zip`](manufacturing/fab-order/wulpus_pro_acquisition_dev_board_fab_order.zip)
- Errata: [`docs/ERRATA.MD`](source/docs/ERRATA.MD) and
  [`docs/errata/wulpus-pro-acquisition-ERRATA_ACTIONS_CN.md`](../../../docs/errata/wulpus-pro-acquisition-ERRATA_ACTIONS_CN.md)

The main board has 65 BOM groups and 164 designators, with 157 SMT placements.
X1/X3/X4/X5/X6/X7/X8 are PTH/manual connections. The official manufacturing
variant is `pzt_hia_no_bias`, with the JLC061011_2116A six-layer, 1.0 mm stackup.

Read both errata files before ordering. In particular, verify the U16 input
capacitance, the R23/RGND bias decision, PJ1 mirrored programming pinout, and
J1/J2 connector stacking height. Build engineering samples before a batch.

