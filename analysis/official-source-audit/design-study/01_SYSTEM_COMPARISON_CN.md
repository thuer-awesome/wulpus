# 三套系统：共同点与差异

## 一句话定位

- **WULPUS**：完整、低功耗、8 通道时分 A-mode 基线。
- **WULPUS Pro**：在同一 MCU/ADC 基线上扩展到 16 通道、30 V、VGA/TGC、包络和 CMUT 偏置。
- **96ARC / PowerDaughter**：96 阵元、16 TX/8 RX、50 MS/s AFE/ADC 和 FPGA 数据降维的阵列成像系统。

## 共同系统架构

三套系统都遵循同一物理闭环：

```text
HV 短脉冲 -> 通道选择 -> 换能器 -> 回波
-> T/R 保护 -> 可变增益/滤波 -> ADC
-> 硬实时控制 -> 缓冲/降维 -> 主机
```

共同原则：发射前 blank；pulser 关断并进入高阻后才收；孔径切换 break-before-make；ADC、TGC、HV 和 MUX 由同一个硬实时状态机统一调度；主机不能直接 bit-bang 发射。

## 不能再写成“都是时分单链路”

WULPUS 和 Pro 是单接收链逐通道采集。商用板不是同一规模：

- [确认] U12/U13 提供 96 个阵元信号。
- [确认] 两颗 HV7350 提供 16 个 ±50 V 发射/接收总线。
- [确认] 三颗 `SY2320` 各覆盖 32 个阵元区域。
- [确认] 四颗 MD0101 保护 16 个回波总线。
- [确认] MT8816 把 16 路选择到 8 路 AD9273 输入。
- [确认] AD9273 同时提供 8 路 12-bit 50 MS/s AFE/ADC。
- [强推断] FPGA 完成捕获、延时/求和或等价降维、包络/IQ 和帧化中的至少一部分。

## 模块级对照

| 模块 | WULPUS | WULPUS Pro | 96ARC / PowerDaughter |
|---|---|---|---|
| 物理阵元 | 8 | 16 | 96 |
| 发射电压 | 约 15 V | 30 V 单极性 | +50/-50 V rail，2 x HV7350 |
| 阵元选择 | HV2707，8 TX + 8 RX 成对 | HV2707，16 路共用 TX_RX | 3 x SY2320，高压层级复用 |
| T/R 保护 | 单接收路径保护 | 增强保护/滤波 | 4 x MD0101，16 路 |
| 接收选择 | 1 路 | 1 路 | MT8816 16x8 |
| AFE | OPA836 + MCU PGA | OPA836 + AD8338，可选 LTC5507 | AD9273 八通道 LNA/VGA/AAF/ADC |
| ADC | 8 MS/s，12 bit，1 路 | 8 MS/s，12 bit，1 路 | 50 MS/s，12 bit，8 路 |
| 实时核心 | MSP430FR5043 | MSP430FR5043 | Cyclone 10 LP 10CL040 |
| 主机 | nRF52832 + nRF52840 dongle | nRF52 DK 或 ESP32-C6 | CC3200 + Wi-Fi |
| 外部存储 | MCU/主机内部 | MCU/主机内部 | EPCS16 FPGA 配置；W25Q80 CC3200 Flash；FM24CL16 FRAM |
| 数据目标 | A-mode RF | A-mode RF/envelope | B-mode 与潜在 Doppler 图像链 |

## 高压复用拓扑

### WULPUS

HV2707 为每个物理通道提供 TX 和 RX 两只开关。被选通通道连接 pulser 与接收链，其余通道保持断开。结构直观，适合逐通道 A-mode。

### WULPUS Pro

16 个通道各用一只高压选择开关连接到公共 `TX_RX` 节点。发射、保护、AD8338 和可选 envelope 围绕公共节点工作。地址和使能真值表与 WULPUS 不同，不能直接复用控制位图。

### 96ARC / PowerDaughter

```text
PowerDaughter: battery -> LT8471 -> +50/-50
96ARC: ±50 -> 2 x HV7350 -> 16 TX/RX buses
-> 3 x SY2320 -> 96 probe elements

echo: 96 -> SY2320 -> 16 buses -> 4 x MD0101
-> MT8816 16x8 -> AD9273 8ch -> FPGA
```

三颗 SY2320 的精确地址真值表仍未知，但 PCB 网络已经证明其把 U12 的 64 路和 U13 的 32 路连接到 16 路收发总线。

## 接收链和 TGC

### WULPUS

OPA836 先放大，MSP430 内部 PGA 和 ADC 完成采样。可编程增益能力有限，适合较浅 A-mode。

### WULPUS Pro

OPA836 后增加 AD8338 VGA/TGC；可切换低通和 LTC5507 envelope。适合学习模拟 TGC、滤波和 envelope/raw RF 分支。

### 96ARC / PowerDaughter

AD9273 集成 8 路 LNA、VGA、AAF、12-bit ADC。AD5601 DAC 由 FPGA 控制，输出经 R40 到 AD9273 `TGC` 节点，证明商用系统使用公共深度增益曲线。50 MS/s 与 8 路并行捕获支持真正的阵列成像。

## 控制面和数据面

WULPUS/Pro：MSP430 是实时面，nRF52/ESP32-C6 是连接面。

商用板：FPGA 是实时面，CC3200 是无线/主机面。`8 x 12 x 50 MS/s = 4.8 Gbit/s`，CC3200 无法直接搬运原始 ADC；主板也没有外部 DDR，所以 FPGA 必须流式降维。

## 电源架构

| 系统 | 电源重点 |
|---|---|
| WULPUS | 低功耗，约 15 V HV，BLE 峰值与模拟隔离 |
| WULPUS Pro | 30 V TX、±30 V CMUT bias、更多模拟 rail 和上电顺序 |
| PowerDaughter | LTC4001 单节锂电管理、BQ51013 无线充电、AD8418 电流检测、LT8471 双路高压、+50/-50 板间供电 |

## 哪些思想可以复用

- 统一硬实时状态机和发射/接收互锁。
- 主机只提交配置，不直接产生发射脉冲。
- 每个 rail、HV 节点、保护后节点、TGC 和 clock 都留测试点。
- 每帧带配置、时间戳、CRC、丢帧和饱和计数。
- raw RF、envelope 和 IQ 是不同数据产品，不能混写。

## 哪些参数不能直接复制

- 阵元数量、pitch、探头电容和最大电压。
- HV2707 与 SY2320/MT8816 的控制真值表。
- WULPUS/Pro 的 8 MS/s ADC 规格不能支撑 7.5 MHz 宽带阵列 RF。
- BLE/SPI 带宽不能承担阵列原始数据。
- 商用板 ±50 V 不能在没有探头额定值和水听器测试时直接用于人体。

## 结论

学习顺序仍然是 WULPUS -> Pro -> 商用 FPGA，但目的不同：WULPUS 建立闭环，Pro 学 TGC/滤波/CMUT，商用板学 96 阵元、并行采集、FPGA 降维和便携电源。颈动脉 B-mode/Doppler 必须走第三条 FPGA 阵列路线。
