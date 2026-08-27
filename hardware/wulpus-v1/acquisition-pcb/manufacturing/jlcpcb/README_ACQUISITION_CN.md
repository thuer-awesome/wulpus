# Acquisition 采集板嘉立创包

## PCB 裸板上传

上传：`01_PCB_Gerber_Drill/acquisition_pcb_gerber_drill_jlcpcb.zip`

- 4 层 FR-4
- 嘉立创成品厚度选择 1.0 mm
- 外层/内层铜厚 1 oz
- 板框约 45.9 mm x 24.5 mm
- 采集板有 PTH 和 NPTH 两个钻孔文件，必须同时保留

## 阻抗

选择单端 50 ohm 阻抗控制，针对 nRF52832 的 RF 天线馈线。使用本目录 `03_Reference/wulpus_acq_pcb_stackup.xls` 给嘉立创工程师核对实际层叠。不要把它设置成 USB 90 ohm 或 100 ohm 差分阻抗。

## PCBA 资料

- `02_PCBA_BOM_CPL/BOM_JLCPCB.csv`
- `02_PCBA_BOM_CPL/CPL_JLCPCB.csv`
- `02_PCBA_BOM_CPL/COMPONENT_CHECKLIST.csv`
- `02_PCBA_BOM_CPL/wulpus_acq_pcb_bom.xlsx`
- `02_PCBA_BOM_CPL/Pick_Place_original.txt`
- `02_PCBA_BOM_CPL/wulpus_acq_pcb_assembly_drawing.PDF`

官方 `Fabrication_ready` 坐标与完整 BOM 对应 121 个器件，顶面 64 个、底面 57 个。其中 `P1/P2` 为通孔件，已从可上传的 `BOM_JLCPCB.csv/CPL_JLCPCB.csv` 排除；嘉立创贴片文件实际包含 119 个双面 SMT 器件。

## 收到后的手焊

`P1、P2` 为 1x3 通孔排针，建议主板 SMT 完成后按装配图手焊。它们的完整料号仍保留在原始 BOM 和 `COMPONENT_CHECKLIST.csv` 中。其余电子元件按坐标文件贴片；USB、Samtec、Hirose、Molex 等连接器不要擅自换封装。

不要安装当前生产 BOM 中没有的 DNP 器件：`R3、R21、R32、R33、C5、C46`。`R2` 属于当前版本，应该安装。
