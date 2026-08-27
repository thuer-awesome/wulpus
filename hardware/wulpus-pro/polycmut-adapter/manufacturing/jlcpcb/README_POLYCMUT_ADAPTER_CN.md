# WULPUS Pro polyCMUT 转接板 - 嘉立创下单说明

## 直接使用的文件

- PCB 裸板上传：01_PCB_Gerber_Drill/polycmut_adapter_gerber_drill_jlcpcb.zip
- 嘉立创贴片 BOM：02_PCBA_BOM_CPL/BOM_JLCPCB.csv
- 嘉立创贴片坐标：02_PCBA_BOM_CPL/CPL_JLCPCB.csv
- 全器件逐位号核对：02_PCBA_BOM_CPL/COMPONENT_CHECKLIST.csv
- 官方原理图：03_Reference/wulpus_polycmut_adapter_schematics.pdf
- 官方 DRC 报告：03_Reference/Design Rule Check - PCB1.drc

仓库没有这块转接板的官方 assembly drawing，也没有官方生产 stackup。不要把本说明中的实用下单默认值误称为官方层叠。

## 嘉立创 PCB 参数

| 参数 | 建议设置 |
|---|---|
| 板层 | 2 层 |
| 外形 | 40.00 x 38.00 mm，以 Gerber 自动识别为准 |
| 板厚 | 1.6 mm；仓库无官方厚度约束，这是普通刚性转接板的实用默认值 |
| 铜厚 | 外层 1 oz |
| 阻抗 | No；源工程有通用 50 ohm 规则字段，但没有制造层叠或受控阻抗 profile，不能据此声称阻抗板 |
| 表面处理 | 推荐 ENIG 沉金，便于细间距连接器和接触焊盘；属于工艺建议 |
| 阻焊/字符 | 建议绿色/白色 |
| 盲埋孔/HDI | No |
| 金手指/半孔/边镀 | No |
| 钻孔 | PCB1.TXT 同时含 PTH 和 NPTH |

1.6 mm 对纯转接功能通常没有电气影响，但必须同时确认外壳、FlexyPin、J3/J4 配合高度和 polyCMUT/interposer 的机械间距。

## PCBA 分类

- 嘉立创 SMT：R1-R8 顶面 0 ohm 0402；J3/J4 底面 91910-21169LF，共 10 个贴装位号。
- 手焊：J5 为 901-144-8RFX 通孔同轴连接器。
- 外接：P1 为 polyCMUT/interposer，不是普通贴片料。
- TP1-TP4 是测试焊盘，不是元件，已从 BOM/CPL 排除。
- 坐标由官方 mil 乘 0.0254 转成 mm，保留相同原点和负坐标。

## DRC 风险

官方 DRC 报告保留 12 个 Minimum Solder Mask Sliver 违规：

- J3/J4 附近 4 处，最小约 0.009 mm。
- R1-R8 各 1 处，共 8 处，约 0.05 mm。
- 另有 10 个已 waived 的 Logo/dead-copper 提示。

嘉立创 CAM 可能合并或删除这些极窄阻焊桥。提交后必须查看 DFM 结果，重点确认 J3/J4 和 R1-R8 焊盘没有被错误盖油；不得为了消除提示而未经审查重导 Gerber。

## 元件核对

- J3/J4 必须核对底面、Pin 1 和连接器朝向。
- R1-R8 的 Source MPN1 是 CR0402-J/-000GLF，Name 是 RC0402JR-070RL；下单包优先使用官方 MPN1，并同时保留两者供核对。
- J5 和 P1 不在嘉立创 SMT BOM/CPL 中。
