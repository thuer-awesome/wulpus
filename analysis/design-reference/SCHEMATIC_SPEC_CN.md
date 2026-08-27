# 完整原理图绘制规格

建议分成 6 张原理图页。网络名、默认值和 DNP 状态不要在首次绘制时自行简化；它们承担上电默认安全状态、量产替代或调试隔离功能。

## 第 1 页：USB-C、ESD 与 BQ24074 PowerPath

### J1 USB-C（GCT USB4105-GF-A）

- A4、A9、B4、B9 全部接 `USB5_RAW`；A1、A12、B1、B12 接 `DGND`。外壳焊盘经 R48=0 Ω 接 DGND（默认装配）；另预留 R49=1 MΩ 与 C34=1 nF 并联到 DGND，默认 DNP，用于外壳接地策略实验，不能三者同时装配。
- A6 与 B6 并接为 `USB_DP_CONN`；A7 与 B7 并接为 `USB_DM_CONN`。A8、B8（SBU）NC。
- A5/CC1 经 R1=5.1 kΩ 1% 到 DGND；B5/CC2 经 R2=5.1 kΩ 1% 到 DGND。两个电阻必须独立，不能共用一只。
- `USB5_RAW` 经 F1=MF-NSMF110（23°C 时 Ihold 1.1 A）到 `USB5_IN`。若将输入模式改成 1 A 且环境温度较高，F1 同时改为 MF-NSMF150；PTC 是故障保护，实际取电电流仍由 BQ24074 限制。
- C1=4.7 µF/10 V/X7R 从 `USB5_IN` 到 DGND，靠近 BQ24074 IN；USB 硬启动总输入电容保持不超过 10 µF。

### U1 USBLC6-2SC6（SOT-23-6）

- pin1 `USB_DM_CONN`，pin6 `USB_DM_ESD`；pin3 `USB_DP_CONN`，pin4 `USB_DP_ESD`。
- pin5 接 `USB5_IN`，pin2 经最短、最宽路径和至少 2 个地过孔接 DGND；C2=100 nF 从 pin5 到 pin2。
- U1 必须在 J1 后第一站；连接器到 U1 不打过孔、不留支路。ESD 以后再分到 ESP32。

### U2 BQ24074RGTR（RGT VQFN-16，3 mm × 3 mm，EP）

| 引脚 | 网络/连接 | 外围与说明 |
|---|---|---|
| 1 TS | `BAT_NTC` | J2 pin2；R3=10 kΩ 到 DGND 仅作无 NTC 电池调试，默认 DNP |
| 2,3 BAT | `BAT+` | J2 pin1；C3=10 µF/10 V/X7R 到 DGND |
| 4 CE | `CHG_CE` | GPIO11；R4=100 kΩ 到 DGND，低电平默认允许充电 |
| 5 EN2 | `BQ_EN2` | R5=100 kΩ 到 DGND，默认 USB500 模式 |
| 6 EN1 | `BQ_EN1` | R6=100 kΩ 到 SYS，默认 USB500 模式 |
| 7 PGOOD | `PGOOD` | R7=10 kΩ 上拉 3V3，GPIO13；开漏，低表示输入有效 |
| 8 VSS | `DGND` | 不以 EP 代替此引脚的地连接 |
| 9 CHG | `CHG_STAT` | R8=10 kΩ 上拉 3V3，GPIO12；开漏 |
| 10,11 OUT | `SYS` | C4=22 µF/10 V/X7R 到 DGND；USB 在时典型 4.4 V，电池模式约 BAT-100 mV max |
| 12 ILIM | `BQ_ILIM` | R9=1.55 kΩ 1% 到 DGND，仅在 EN2=1/EN1=0 时约 1 A |
| 13 IN | `USB5_IN` | 紧邻 C1；输入正常工作范围 4.35~10.2 V |
| 14 TMR | `BQ_TMR` | R10=46.4 kΩ 1% 到 DGND，典型约 6.19 h，是 6.25 h 目标的最近标准值 |
| 15 ITERM | `BQ_ITERM` | R11=2.94 kΩ 1% 到 DGND；非 USB100 模式约 30 mA 终止 |
| 16 ISET | `BQ_ISET` | R12=2.94 kΩ 1% 到 DGND；ICHG≈890/R(kΩ)=303 mA |
| EP | `DGND` | 实心铜连接并布 4~9 个 0.20~0.30 mm 成品孔热过孔 |

J2 为 JST PH 3Pin：pin1 BAT+、pin2 BAT_NTC、pin3 DGND。只接带保护的 1S 电池包，NTC 为电池包内 10 kΩ、另一端接电池负极。

300 mA 充电电流还必须小于电池包厂家允许的充电电流；小容量电池需要按 `RISET=890/ICHG(A)` 增大 R12，不能只因为充电芯片支持 300 mA 就默认电池也支持。

默认输入模式由 R6 上拉 EN1、R5 下拉 EN2 得到 500 mA。预留 R13=`BQ_EN1` 到 DGND、R14=SYS 到 `BQ_EN2`，两者 DNP。仅当电源适配器和线缆明确可提供至少 1 A 时，DNP R5/R6、装 R13/R14，并保留 R9=1.55 kΩ；普通 USB 口不能这样改。

## 第 2 页：3.3 V 与 ESP32-S3

### U3 TPS63070RNMT（RNM VQFN-HR-15，2.5 mm × 3.0 mm）

| 引脚 | 连接 |
|---|---|
| 1 PS/SYNC | R15=10 kΩ 到 DGND，默认强制 PWM；JP1 可改接 3V3 进入省电模式 |
| 2 PG | `3V3_PG`，R16=10 kΩ 上拉 3V3，测试点 TP5 |
| 3 VAUX | C5=100 nF 到 DGND，不能带外部负载 |
| 4 GND | DGND |
| 5 FB | R17=470 kΩ 从 3V3 到 FB，R18=150 kΩ 从 FB 到 DGND，VOUT≈3.31 V |
| 6 FB2 | NC |
| 7,8 VOUT | 3V3 |
| 9 L2 | L1 第二端 |
| 10 PGND | DGND，直接回到输入/输出电容地端 |
| 11 L1 | L1 第一端 |
| 12,13 VIN | SYS |
| 14 EN | `3V3_EN`；R19=100 kΩ 到 DGND；SYS 经 SW1 滑动开关和 R20=10 kΩ 到 EN |
| 15 VSEL | DGND |

L1=XFL4020-152MEC，1.5 µH。输入端 C6/C7=2×10 µF 0805 加 C8=10 µF 0603；输出 C9/C10=2×22 µF 0805 加 C11=10 µF 0603。必须查所选电容的 DC Bias 曲线，使总有效输出电容在 3.3 V 时不低于 15 µF。

### U4 ESP32-S3-WROOM-1-N8

- pin2 接 3V3；pin1、pin40、EP pin41 全接 DGND。模块旁 C12=22 µF、C13=100 nF。
- pin3 EN：R21=10 kΩ 上拉 3V3，C14=1 µF 到 DGND，SW2 RESET 按键到 DGND。
- pin27 GPIO0：R22=10 kΩ 上拉 3V3，SW3 BOOT 按键到 DGND。
- pin13 GPIO19/USB_D- 经 R23=22 Ω 接 `USB_DM_ESD`；pin14 GPIO20/USB_D+ 经 R24=22 Ω 接 `USB_DP_ESD`。R23/R24 紧靠模块。
- pin36 GPIO44/U0RXD、pin37 GPIO43/U0TXD 引到 J5；其余控制引脚按 `GPIO_MUX_MAP.csv`。
- GPIO0、GPIO3、GPIO45、GPIO46 是启动配置相关引脚，不用于电源使能；GPIO4~14 上电可能短暂输出低电平，因此本设计所有危险使能均为“高有效 + 硬件下拉”。
- 模块 PCB 天线端置于板边，最好伸出基板；天线区域上下两层均无铜、走线、过孔和器件，且离外壳、电池、连接器、线束等至少 15 mm。

## 第 3 页：受控 5 V 与 15.05 V

### U5 TPS61222DCKR（SC-70-6，固定 5 V）

- pin1 VIN 接 SYS，C15=10 µF/10 V 到 AGND_HV。
- L2=4.7 µH（LPS4018-472MRC）从 SYS 接 pin5 L。
- pin2 FB 与 pin4 VOUT 均接 `5V_RAW`；C16=10 µF/10 V 从 `5V_RAW` 到 AGND_HV。
- pin3 GND 接 AGND_HV；pin6 EN 接 GPIO5/`BOOST5_EN`，R25=100 kΩ 到 AGND_HV。
- TPS61222 关闭时输出会经内部通路跟随输入，不能承担 HV2707 的电源隔离，所以必须保留 U6。

### U6 TPS22919DCKR（SC-70-6）

- pin1 IN 接 `5V_RAW`；pin6 VOUT 为 `VDD5_SW`；pin2 GND 接 AGND_HV。
- pin3 ON 接 GPIO17/`MUX_PWR_EN`，R26=100 kΩ 到 AGND_HV；pin4 NC。
- pin5 QOD 直接接 pin6，使关闭时通过内部典型 24 Ω 放电；C17=1 µF/10 V 从 VDD5_SW 到 AGND_HV，靠近 HV2707。

### U7 LT1945IMS#PBF（MSOP-10，仅使用正升压通道 2）

| 引脚 | 连接 |
|---|---|
| 1 NFB1 | NC；禁用通道 1 的反馈输入 |
| 2 SHDN1 | AGND_HV，永久关闭通道 1 |
| 3 GND | AGND_HV |
| 4 SHDN2 | GPIO4/`HV_EN`；R27=100 kΩ 到 AGND_HV |
| 5 FB2 | R28=2.00 MΩ 从 `V15_RAW` 到 FB2，R29=178 kΩ 从 FB2 到 AGND_HV |
| 6 SW2 | `SW15_NODE` |
| 7,9 PGND | AGND_HV，两个都必须连接 |
| 8 VIN | SYS；C18=4.7 µF/10 V 直接到 AGND_HV |
| 10 SW1 | NC；铜皮不延伸 |

- L3=LPS4018-103MRC，10 µH，从 SYS 到 `SW15_NODE`；D1=ZHCS400，阳极 `SW15_NODE`、阴极 `V15_RAW`。
- C19=1 µF/50 V/X7R 从 `V15_RAW` 到 AGND_HV；C20=4.7 pF/C0G 并联在 R28 两端。反馈值给出 1.23×(1+2.00 M/178 k)=15.05 V。
- FB 取样点在 C19 正端，远离 SW15_NODE。`V15_RAW` 经 FB1=BLM18PG300SH1D 到 `V15`；C21=2.2 µF/50 V/X7R 和 C22=100 nF/50 V 从 V15 到 AGND_HV。
- R30=1 MΩ 从 V15 到 AGND_HV 作为泄放。TP8=`SW15_NODE` 只留微型测试环并明确“普通示波器地夹禁止”；TP9=`V15`。
- LT1945 的内部开关限流典型 350 mA、SW 绝对最大 36 V；10 µH 电感选择 Isat 1.1 A、DCR≤0.20 Ω，给电流过冲留余量。

## 第 4 页：MCP1416 发射驱动与 HV2707 收发开关

### U8/U9 MCP1416T-E/OT（SOT-23-5，非反相）

- 两颗 pin1 NC、pin2 V15、pin4 AGND_HV。每颗 pin2-pin4 直接放 C23/C25=1 µF/25 V 低 ESR 与 C24/C26=100 nF/25 V；优先按手册使用 1 µF 薄膜，空间不足的测试版可先用高品质 X7R 并实测振铃。
- U8 pin3 经 R31=33 Ω 接 `TX_PULSE`，并由 R32=100 kΩ 下拉；pin5 经 R33=4.7 Ω（调试范围 0~10 Ω）到 `TX_BUS_A`。
- U9 pin3 经 R34=33 Ω 接 `TX_PULSE`，并由 R35=100 kΩ 下拉；pin5 经 R36=4.7 Ω到 `TX_BUS_B`。
- 各 TX_BUS 到 AGND_HV 预留串联 RC 吸收支路 R37+C27、R38+C28，默认 DNP。器件值必须根据换能器、线缆和实测波形调谐，不能照抄一个“通用 snubber”。

### U10 HV2707T-C/R8X（LQFP-48 7 mm × 7 mm，0.5 mm pitch）

- pin13 GND、pin24 RGND 接 AGND_HV；pin17 DGND 接 DGND。pin16 VSS 浮空，不能接地；pin14、35、36 及 pin1/2 NC。
- pin18 VLL 接 3V3，C29=1 µF、C30=100 nF 到 DGND；pin15 VDD 接 VDD5_SW，C31=1 µF、C32=100 nF 到 AGND_HV。
- pin19 DIN=GPIO8，R39=100 kΩ 下拉；pin20 CLK=GPIO9，R40=100 kΩ 下拉；pin21 LE=GPIO10，R41=10 kΩ 上拉 3V3；pin22 CLR=GPIO7，R42=10 kΩ 上拉 3V3；pin23 DOUT 可经 R43=33 Ω 回 GPIO21，默认 DNP。
- 开关的 A 端接公共 RX/TX 总线，B 端接通道。逐引脚映射见 `GPIO_MUX_MAP.csv`；原理图必须为每个 CH1~CH8 画出成对的 RX/TX 开关，不能只画一只开关后把驱动器永久并在通道上。

## 第 5 页：MD0101、换能器与接收输出

### U11 MD0101K6-G（DFN-18 5 mm × 5 mm，中心散热焊盘）

- `RX_BUS` 经 C33=10 nF/100 V/C0G 或高品质薄膜，再经 R44=0 Ω 到 pin2 TX1。C33 两端并联 R45=0 Ω，默认 DNP，用于低频换能器旁路验证。
- pin17 RX1 为 `RX_OUT`；pin16 RGND1 经 R46=0 Ω 接 AGND_HV；中心焊盘接 AGND_HV。
- pin1/3/5/7/9/18 NC；未用通道 pin4/6/8、pin10~15 全部 NC，不连接或铺铜。
- `RX_OUT` 到 AGND_HV 预留 R47=100 Ω，默认 DNP。是否终端匹配由换能器、线缆和外部 AFE 输入阻抗共同决定。
- J3 为边缘 SMA：中心 `RX_OUT`、外壳 AGND_HV；J4 为 1×3 调试头：pin1 RX_OUT、pin2 AGND_HV、pin3 3V3（只给低功耗外部 AFE，标注最大 100 mA）。

### J6 8 通道换能器接口

使用 2×8、2.54 mm 直插针座，奇数脚为 CH1~CH8，偶数脚均为 AGND_HV：1/2=CH1/GND，3/4=CH2/GND，…，15/16=CH8/GND。对 MHz 回波或超过约 10 cm 的线缆，改用逐通道同轴接口，不能用无地回线的排线。

### J5 控制扩展接口

使用 2×6：1=3V3，2=DGND，3=UART_TX，4=UART_RX，5=I2C_SDA，6=I2C_SCL，7=TRIG_IN，8=SYNC_OUT，9=CHG_STAT，10=PGOOD，11=DGND，12=SYS。J5 的 SYS 仅作测量/小负载输出，丝印标注不超过 100 mA。

## 第 6 页：地连接、测试点与上电时序

- 建立 `DGND` 与 `AGND_HV` 两个网络，只通过 NT1 单点 net-tie 相连。NT1 放在 SYS 电源从数字/充电区进入驱动区的位置；它们是同一电位的受控回流分区，不是隔离电源。
- TP1 USB5_IN、TP2 BAT+、TP3 SYS、TP4 3V3、TP5 3V3_PG、TP6 5V_RAW、TP7 VDD5_SW、TP8 SW15_NODE、TP9 V15、TP10 TX_BUS_A、TP11 TX_BUS_B、TP12 RX_BUS、TP13 RX_OUT、TP14 DGND、TP15 AGND_HV。
- 首次上电固定顺序：3V3 稳定且 MUX_CLR=HIGH；BOOST5_EN=HIGH；确认 5V_RAW 后等待至少 1 ms；MUX_PWR_EN=HIGH 后等待至少 5 ms；确认 VDD5_SW 后再允许 HV_EN=HIGH。关机顺序相反，先 HV_EN=LOW 和所有 TX/RX OFF，再关 VDD5_SW/5V。
- HV2707 要求 VLL 先于 VDD；上/下电期间模拟端必须位于 0~VDD 或浮空。本设计因此不允许 15 V 驱动先于复用器电源启动。
- 单次收发顺序：全部 RX OFF → 等 5 µs → 选中 TX ON → 等 5 µs → 发 burst → TX_PULSE 回 LOW → TX OFF → 等换能器 ring-down → 再等 5 µs → 选中 RX ON → 等 5 µs → 触发外部采集。任何时刻同一通道的 TX/RX 位不得同时为 1。
- HV2707 最坏开关时间为 5 µs，因此只在 burst 之间切换通道，不能把它当成逐载波周期换向器。默认固件只允许一个 TX 位为 1；首板从总 TX 占空比≤1% 起步，并根据 `Pburst≈CLOAD×V15²×f`、V15 瞬态和器件温升设置最终 burst/PRF 上限。
