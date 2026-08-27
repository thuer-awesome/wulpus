# WULPUS v1 High-Voltage PCB

This board carries the HV2707 multiplexer, transmit/receive switch, and MOSFET
driver used by WULPUS v1.

## Files to use

- Design source: [`source/wulpus_hv_mux.PrjPcb`](source/wulpus_hv_mux.PrjPcb),
  [`source/PCB1.PcbDoc`](source/PCB1.PcbDoc), the two schematic sheets, source
  libraries, and `source/docs/` fabrication exports.
- JLCPCB package: [`manufacturing/jlcpcb`](manufacturing/jlcpcb), including
  `BOM_JLCPCB.csv`, `CPL_JLCPCB.csv`, component checklist, assembly drawing,
  schematic PDF, stackup, Gerber, and NC Drill files.
- Factory archive: [`manufacturing/fab-order/hv_pcb_fab_order.zip`](manufacturing/fab-order/hv_pcb_fab_order.zip).

The official package has 25 BOM groups and 48 placements. The current package
lists all of these as SMT. The Y19 audit identifies the seven positions to
install: `U4`, `C12`, `C14`, `C18`, `C21`, `R7`, `L2`. The official DNP positions
are `C9`, `C10`, `C11`, `C16`, `C20`, `R9`; they remain intentionally unpopulated.

Do not replace `HV2707` with the older `HV2708`. Verify the HV rail, discharge
time, creepage, and dummy-load waveform on the first article.

