# HV 高压板嘉立创包

## PCB 裸板上传

上传：`01_PCB_Gerber_Drill/hv_pcb_gerber_drill_jlcpcb.zip`

- 4 层 FR-4
- 嘉立创成品厚度选择 1.0 mm
- 外层/内层铜厚 1 oz
- 板框约 17.5 mm x 24.5 mm
- PTH 和 NPTH 钻孔必须同时保留

## 阻抗和高压注意事项

- Controlled impedance 选择 `No`。HV 脉冲板需要关注高压网络间距和铜皮，不需要 RF 50 ohm 阻抗。
- 不要让厂商修改 Gerber 中的高压走线、地平面、铜皮或钻孔。
- 原理图中的高压电源输出约为 +15 V。首次上电必须限流，先空载/假负载测试，禁止直接接人体。

## PCBA 资料

- `02_PCBA_BOM_CPL/BOM_JLCPCB.csv`
- `02_PCBA_BOM_CPL/CPL_JLCPCB.csv`
- `02_PCBA_BOM_CPL/COMPONENT_CHECKLIST.csv`
- `02_PCBA_BOM_CPL/wulpus_hv_mux_bom.xlsx`
- `02_PCBA_BOM_CPL/Pick_Place_original.txt`
- `02_PCBA_BOM_CPL/wulpus_hv_mux_assembly_drawing.PDF`

当前 BOM 与 `Fabrication_ready` 坐标对应 48 个器件，顶面 16 个、底面 32 个，按双面 SMT 处理。J1、J2 是 SMT 连接器，不需要收到后再补焊。

不要安装当前生产 BOM 中没有的 DNP 器件：`C9、C10、C11、C16、C20、R9`。
