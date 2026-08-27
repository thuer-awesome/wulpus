# WULPUS Pro 嘉立创下单总说明

## 先确认板数

WULPUS Pro 仓库只有两块需要制造的 PCB，不是旧版 WULPUS 的四块：

1. 01_wulpus_pro_acquisition_dev_board
   - 采集、MSP430、模拟前端和高压复用/驱动功能集成在同一块 6 层开发板。
2. 02_polycmut_adapter
   - 可选 polyCMUT 转接板，2 层。

旧版的 MSP430 和 nRF52 编程转接板没有 Pro 新版工程，不能从旧包复制后当成 Pro 生产文件。尤其主板 PJ1 已被官方 ERRATA 确认相对旧版对称镜像。

## 文件怎么上传

PCB 裸板订单只上传每块板的 01_PCB_Gerber_Drill/*_gerber_drill_jlcpcb.zip。该 ZIP 已扁平化，只含 Gerber 和 NC Drill。

需要嘉立创贴片时，再上传同一板目录内：

- 02_PCBA_BOM_CPL/BOM_JLCPCB.csv
- 02_PCBA_BOM_CPL/CPL_JLCPCB.csv

不要把 BOM、CPL、PDF、stackup、DRR/LDP、Gerber 报告和工程文件混进 PCB Gerber ZIP。嘉立创打不开“原来太多”的原因通常就是上传包混入了非生产层文件。

## 两板参数摘要

| 板 | 层数/厚度 | 铜厚 | 阻抗 | 贴片/手焊 |
|---|---|---|---|---|
| Pro 采集开发板 | 6 层 / 订单标称 1.0 mm（源层叠图约 0.95 mm） | 官方层叠约外 1 oz、内 1 oz | Yes，S50 单端 50 ohm +/-10%，JLC061011_2116A | 157 个双面 SMT；7 个 2.54 mm PTH 排针手焊 |
| polyCMUT 转接板 | 2 层 / 建议 1.6 mm | 外层 1 oz | No；仓库没有官方生产阻抗层叠 | 10 个双面 SMT；J5 手焊；P1 外接 |

## 主板阻抗下单

1. 选择 6 layers、标称 1.0 mm、Controlled Impedance = Yes。官方装配图层叠合计约 0.95 mm。
2. 阻抗类型选 Single-ended 50 ohm，Tolerance 10%。不要选 90/100 ohm 差分。
3. 指定/备注 JLC061011_2116A，并把 03_Reference 下的官方 stackup 文件交给工程。
4. 外层设计线宽 0.208 mm，内层 L3/L4 设计线宽 0.152 mm。不要在下单页面或 AD 中只改线宽而不重做全套 Gerber。
5. 若网页没有完全相同层叠，不要猜一个“最接近”的直接投产，转工程订单确认。

## 自动匹配规则

- BOM 优先使用官方 Manufacturer Part Number 1，空白时才使用 Name。
- COMPONENT_CHECKLIST.csv 同时保存 Source_Name、Source_MPN1、最终 Preferred_MPN、封装、坐标、面别和装配方式。
- 嘉立创自动匹配只是候选结果。IC、晶振、连接器、高压芯片、U.FL 和极性器件必须逐项人工确认。
- 坐标文件保留官方原点，出现负坐标是正常的。若系统拒绝，必须让 CAM 对 Gerber 和 CPL 统一换原点，不能单独平移 CPL。

## 装配和 DNP

- 主板 P&P 中额外的 29 个非 BOM 对象是测试点、安装孔、Logo 和焊桥，不贴装；完整列表在 PLACEMENT_EXCLUSIONS.csv。
- 转接板 TP1-TP4 是测试焊盘，不贴装。
- 主板 X1/X3/X4/X5-X8 是 PTH，收板后手焊。
- 转接板 J5 是 PTH 手焊，P1 是外部 transducer/interposer。
- 这里的“不安装”是根据同一官方 variant BOM 与 P&P 做集合核对得出，不包含凭经验猜测的 DNP。

## 生产前必须读

- 主板 03_Reference/ERRATA.MD
- 主板 03_Reference/ERRATA_ACTIONS_CN.md
- 转接板 README_POLYCMUT_ADAPTER_CN.md 中的 12 个阻焊桥 DRC 违规

高压相关设计第一次上电必须用限流电源、断电放电和假负载。该开源硬件不能未经安全验证直接用于人体。
