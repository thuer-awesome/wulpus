# nRF52 SWD 编程转接板嘉立创包

## PCB 裸板上传

上传：`01_PCB_Gerber_Drill/nrf52_programmer_pcb_gerber_drill_jlcpcb.zip`

- 2 层 FR-4
- 嘉立创成品厚度选择 0.4 mm
- 1 oz 铜厚
- 板框约 27.051 mm x 13.970 mm
- Controlled impedance 选择 `No`
- 有 20 个 0.9 mm PTH 通孔，主要给 2x10 排针使用

## 元件和手焊

本板只有两个连接器：

- `CONN_SWDN1`：Molex `5051100692`，SMT 连接器
- `S_NRDC1`：Samtec `SAMTEC-TST-110-01-X-DJ`，2x10 通孔排针，必须手焊

最简单的下单方式是只做裸板，收到后按 `assembly_drawing.pdf` 的方向把两个连接器手焊。它是被动转接板，不是 nRF52840 USB Dongle，也不需要烧录固件。

如果一定要嘉立创贴片，`02_Manual_Solder/BOM_JLCPCB.csv` 和 `CPL_JLCPCB.csv` 只包含 SMT 的 `CONN_SWDN1`；通孔 `S_NRDC1` 已排除，仍需收到后手焊。完整两个元件的参数见 `COMPONENT_CHECKLIST.csv` 和原始 BOM。

注意：官方原始层叠文件名仍为 `wulpus_msp430_programmer_pcb_stackup.xls`，内容实际是本 nRF52 转接板的 2 层 0.411 mm 层叠。嘉立创裸板上传只需要本目录的 Gerber/钻孔 zip。
