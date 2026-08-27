# 固件、FPGA 与硬件接口地图

## 1. 三套系统的控制分层

```text
WULPUS/Pro:
host UI -> nRF52 or ESP32-C6 -> SPI/config -> MSP430 hard realtime
-> HV2707/pulser/PGA/ADC -> frame -> host

96ARC/PowerDaughter:
host/Wi-Fi -> CC3200 -> board connector -> Cyclone 10 LP hard realtime
-> HV7350/SY2320/MD0101/MT8816/AD9273
-> beamformed/envelope/IQ/frame -> CC3200/host
```

ESP32/CC3200 都不是 50 MS/s 多通道采集核心。它们负责配置、状态、网络、升级和 UI；发射脉冲、ADC 对齐、孔径和 PRF 必须由 FPGA/MSP430 硬实时产生。

## 2. WULPUS/Pro MSP430 配置与帧

公共规则：主机先发送配置，MSP430 按固定状态机采集，再返回固定长度帧。具体字段以源码为准。

Pro 已确认差异：

- 帧长 804 byte：4-byte header + 400 x 16-bit sample。
- 配置包 byte 19 插入 `enEnvDetector`，后续字段相对 WULPUS 后移。
- nRF52 `us_spi.c` 设置 2 MHz；ESP32-C6 路径设置 8 MHz。
- 不能把 README 的 8 MHz 当成所有主机固件的共同事实。

## 3. WULPUS 硬件职责

| 模块 | 职责 |
|---|---|
| MSP430FR5043 | pulser/MUX 时序、PGA/ADC、帧缓冲、配置解析 |
| nRF52832 | 板载 BLE、与 MSP 通信、状态/数据搬运 |
| nRF52840 dongle | USB 与 BLE 桥接 |
| HV2707 | 8 通道 TX/RX 成对高压开关 |

## 4. WULPUS Pro 硬件职责

| 模块 | 职责 |
|---|---|
| MSP430FR5043 | 同上，外加 Pro GPIO、滤波、envelope 和 TGC 控制 |
| AD8338 | 模拟 VGA/TGC |
| LTC5507 | 可选 envelope detector |
| nRF52 DK | 2 MHz SPI + BLE |
| ESP32-C6 | 8 MHz SPI + Wi-Fi/TCP |
| HV2707 | 16 路连接公共 TX_RX 节点 |

## 5. 商用 96ARC 主板职责

| 位号 | 器件 | 职责 | 证据 |
|---|---|---|---|
| U6 | 10CL040YF484C8G | FPGA 捕获、时序、降维 | BOM + PCB |
| U2 | AD9273BBCZ-50 | 8ch LNA/VGA/AAF/12-bit ADC | BOM + PCB |
| U8/U10 | HV7350K6-G | 16ch ±50 V pulser | BOM + PCB |
| U4/U5/U7 | marking `AP9URD.1 / SY2320` | 96 阵元高压选择 | PCB 网络 + 照片；精确型号待确认 |
| U9/U18/U21/U23 | MD0101K6-G | 16 路接收高压保护 | BOM + PCB |
| U11 | MT8816AF1 | 16x8 接收 crosspoint | BOM + PCB |
| U3 | AD5601 | FPGA 控制的 TGC DAC | PCB：输出经 R40 到 AD9273 TGC |
| U14 | EPCS16SI8N | FPGA 配置存储 | BOM；当前无 dump |
| OSC1 | 50 MHz oscillator | FPGA/采集基准时钟 | BOM + PCB |

## 6. PowerDaughter 职责

| 位号 | 器件 | 职责 |
|---|---|---|
| U12 | CC3200R1M2RGC | Wi-Fi + Cortex-M4 主机/连接控制 |
| U14 | W25Q80D | CC3200 1 MiB serial Flash |
| U21 | FM24CL16B | 2 KiB FRAM 配置/设备标识 |
| U15 | LT8471 | 双路高压转换，输出 +50/-50 |
| U1 | LTC4001 | 单节锂电充电/电源管理 |
| U17 | BQ51013B | 无线电源接收 |
| U4 | AD8418 | 电流检测 |
| U9 | LTC2951 | 开关机 pushbutton controller |
| U23 | CN1185 | 监控/复位/电源状态 |
| J1_WL | 40-pin board-to-board | ±50、VCC、GND、数字控制/数据 |

## 7. 商用板间接口

`J1_WL` 与 `J2_FPGA` 同 pin 的已确认映射：

| pin | PowerDaughter | 96ARC |
|---:|---|---|
| 1-4 | +50 | +50 -> HV7350 |
| 5-8 | GND | GND |
| 9-12 | VCC | 主板低压输入 `J2_FPGA-9` |
| 13-14 | GND | GND |
| 15-18 | -50 | -50 -> HV7350 |
| 19-22 | GND | GND |
| 23-40 | 控制/数据与插入地 | FPGA/逻辑/按钮/LCD 控制 |

数字信号中可见 `DOUT`、`CS`、`ENV`、`CLK/HV` 等标签，但在没有 CC3200 固件解析和 FPGA 位流前，不给出虚构协议。

## 8. 存储镜像

### PowerDaughter U14 W25Q80D

- 原始文件：1,049,602 byte，SHA-256 `989441f5...574adf`。
- 前 1 MiB 是 CC3200 SimpleLink 文件系统，canonical SHA-256 `8c11c60c...d76169`。
- 可见 `/sys/mcuimg.bin`、`/sys/servicepack.ucf`、Wi-Fi 和网络配置文件。
- 末尾多出的 1024 byte 以 `SFDP` 开头，后跟 2 byte `00`，是编程器附加信息。
- 它不是 FPGA bitstream。

### PowerDaughter U21 FM24CL16B

- 2,048 byte，SHA-256 `4ddbe9b3...cc2c3`。
- 仅 23 byte 非零。
- `0x100` 处为 `WLPCDJB038`；其余为 `5A A5` 标志和少量配置字节。

### 96ARC U14 EPCS16

当前没有 dump。这是恢复 FPGA 时序、beamforming、TGC 表和 host protocol 的关键缺口。下一步应在断电、隔离并确认接口电压后，用合适编程器只读备份，并先做两次一致性读取和 SHA-256。

## 9. 拟建系统的寄存器/协议分层

建议 host 只写 frame-level 配置：

```text
probe_id
mode: B / color / PW / raw
tx_aperture, rx_aperture
focus_depth, steering_angle
frequency, cycles, hv_level
sample_rate, depth, PRF
TGC_curve_id
ROI and Doppler gate
```

FPGA 内部负责：电源/时钟状态、HV interlock、MUX 真值表、blank/fire/ringdown/receive、ADC valid、TGC LUT、beamforming/IQ/envelope、CRC、饱和/丢帧/温度错误计数。

## 10. 不能省略的调试接口

- FPGA JTAG 和配置只读备份。
- ADC test pattern、frame alignment、LVDS bit-slip 计数。
- pulser gate、HV enable、blank、ADC valid、line/frame trigger 测试点。
- 每条 rail、电流、温度和 HV 放电状态。
- raw RF 小窗口旁路，用于验证 beamformer/IQ 之前的数据。
- host 日志包含配置版本、bitstream hash、probe ID、校准版本和错误计数。
