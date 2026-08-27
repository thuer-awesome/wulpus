# WULPUS 嘉立创分板下单包

本目录已经把四块 PCB 拆成四个独立订单包。嘉立创 PCB 裸板上传时，只上传每个板目录下的 `01_PCB_Gerber_Drill/*_gerber_drill_jlcpcb.zip`；BOM、坐标和装配图用于 PCBA 订单或人工核对，不要和 Gerber 混成一个总 zip 上传。

本目录的上一级同时提供 `jlcpcb_order_packages.zip`，解压后仍保留下面四个独立板目录；你也可以直接在当前目录逐板打开。

## 四个订单包

| 目录 | 嘉立创 PCB 上传 | PCBA/核对资料 | 成品层数/厚度 | 阻抗 |
|---|---|---|---|---|
| `01_acquisition_pcb` | `acquisition_pcb_gerber_drill_jlcpcb.zip` | BOM、CPL、装配图、元件核对表 | 4 层 / 1.0 mm | 单端 50 ohm |
| `02_hv_pcb` | `hv_pcb_gerber_drill_jlcpcb.zip` | BOM、CPL、装配图、元件核对表 | 4 层 / 1.0 mm | 不控制阻抗 |
| `03_msp430_programmer_pcb` | `msp430_programmer_pcb_gerber_drill_jlcpcb.zip` | BOM、装配图、手焊说明 | 2 层 / 0.4 mm | 不控制阻抗 |
| `04_nrf52_programmer_pcb` | `nrf52_programmer_pcb_gerber_drill_jlcpcb.zip` | BOM、装配图、手焊说明 | 2 层 / 0.4 mm | 不控制阻抗 |

## 嘉立创通用选项

- FR-4，普通 Tg，外层和内层 1 oz。
- 表面处理推荐沉金 ENIG；阻焊绿色、字符白色。
- 普通通孔板，不选 HDI、盲埋孔、盘中孔、树脂塞孔、金手指、边缘电镀和半孔。
- 钻孔以 zip 内的 NC Drill 为准。主板有 PTH 和 NPTH 两类钻孔，不能只保留其中一种。
- 采集板选择 `Controlled Impedance = Yes`、`Single-ended = 50 ohm`。不要选择 90/100 ohm 差分阻抗。
- HV 板和两块编程转接板选择 `Controlled Impedance = No`。
- 嘉立创若要求改变采集板 RF 线宽，先让工程师确认实际层叠和 50 ohm 计算，不要直接确认改版。

## PCBA 上传顺序

1. 先上传同一板目录的 Gerber/钻孔 zip，检查层数、板框和预览。
2. 如果要嘉立创贴片，再上传 `BOM_JLCPCB.csv` 和 `CPL_JLCPCB.csv`；这两个文件只列 SMT，不含后续手焊的通孔件。
3. 用 `COMPONENT_CHECKLIST.csv` 逐个核对完整型号、封装、数量、贴装面和手焊分类；原始 `.xlsx` BOM 保留全部元件。
4. 用 `assembly_drawing.pdf` 检查极性、连接器方向和底面器件。
5. 嘉立创元件绑定时优先按完整制造商料号匹配。MCU、HV MUX、天线、晶振、连接器禁止未经确认替代。

## 贴片和手焊

- 采集板：嘉立创 BOM/CPL 含 119 个双面 SMT；`P1/P2` 是通孔排针，已从嘉立创 BOM/CPL 排除，收到 PCBA 后手焊。
- HV 板：BOM 中 48 个器件按坐标文件双面 SMT；连接器 J1/J2 为 SMT。钻孔中的机械/安装孔不是电子元件。
- MSP430 编程转接板：`CONN_JW1` 是 SMT 连接器，嘉立创 BOM/CPL 只含它；`J_OLMX1` 是 2x10 通孔排针，已从嘉立创 BOM/CPL 排除。最简单做法仍是只下裸板，收到后两个连接器都手焊。
- nRF52 编程转接板：`CONN_SWDN1` 是 SMT 连接器，嘉立创 BOM/CPL 只含它；`S_NRDC1` 是 2x10 通孔排针，已从嘉立创 BOM/CPL 排除。最简单做法仍是只下裸板，收到后两个连接器都手焊。
- 两块编程转接板没有 MCU，也不需要烧录固件；nRF52840 USB Dongle 是另外购买的商业 USB Dongle。

## 版本绑定

生产文件以每个订单包内的 Gerber、NC Drill、BOM、CPL 和装配图为准，并使用同一包内资料。完整 Altium 工程只作参考，不需要转换成嘉立创EDA。当前主板生产层叠表为约 0.949 mm/1.0 mm；不要用旧的 `WOLFMAN.stackup` 重新导出生产文件。

## 首次下单建议

先各做 3 张采集板和 HV 裸板，主板 PCBA 各试做 1 套；两块编程转接板各做 2 张裸板并手焊连接器。主板首次上电使用限流电源和假负载，检查短路、供电电流和焊接质量后再烧录固件。
