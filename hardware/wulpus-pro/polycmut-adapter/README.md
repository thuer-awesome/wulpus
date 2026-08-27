# WULPUS PRO polyCMUT adapter

This optional adapter provides the polyCMUT/interposer interface. It is not a
replacement for the PRO acquisition board.

- Design source: [`source/wulpus_testbench_polycmut_flexypin.PrjPcb`](source/wulpus_testbench_polycmut_flexypin.PrjPcb)
- JLCPCB package: [`manufacturing/jlcpcb`](manufacturing/jlcpcb)
- Factory archive: [`manufacturing/fab-order/polycmut_adapter_fab_order.zip`](manufacturing/fab-order/polycmut_adapter_fab_order.zip)

The package has four BOM groups and twelve designators, with ten SMT placements.
J5 and P1 are external/manual connections; keep them out of SMT placement and
check the flexy-pin/interposer mechanical stack before assembly. The official
package does not provide a production stackup; confirm the fabricator's layer
and thickness proposal before release.

