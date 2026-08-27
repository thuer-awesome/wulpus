# MSP430 JTAG 编程转接板嘉立创包

## PCB 裸板上传

上传：`01_PCB_Gerber_Drill/msp430_programmer_pcb_gerber_drill_jlcpcb.zip`

- 2 层 FR-4
- 嘉立创成品厚度选择 0.4 mm
- 1 oz 铜厚
- 板框约 26.67 mm x 14.732 mm
- Controlled impedance 选择 `No`
- 有 20 个 0.9 mm PTH 通孔，主要给 2x10 排针使用

## 元件和手焊

本板只有两个连接器：

- `CONN_JW1`：Molex `5051100892`，SMT 连接器
- `J_OLMX1`：Samtec `SAMTEC-TST-110-01-X-DJ`，2x10 通孔排针，必须手焊

最简单的下单方式是只做裸板，收到后按 `assembly_drawing.pdf` 的方向把两个连接器手焊。它是被动转接板，不需要烧录固件。

如果一定要嘉立创贴片，`02_Manual_Solder/BOM_JLCPCB.csv` 和 `CPL_JLCPCB.csv` 只包含 SMT 的 `CONN_JW1`；通孔 `J_OLMX1` 已排除，仍需收到后手焊。完整两个元件的参数见 `COMPONENT_CHECKLIST.csv` 和原始 BOM。
