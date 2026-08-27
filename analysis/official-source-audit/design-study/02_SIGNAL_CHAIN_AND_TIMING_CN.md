# 信号链、时序与规格计算

## 1. 一次采集的统一状态机

```text
SAFE
-> SELECT aperture (all-off then new address)
-> configure AFE/TGC/filter
-> BLANK receiver
-> FIRE 1-3 cycles
-> pulser high-Z
-> RINGDOWN holdoff
-> RECEIVE + TGC ramp + ADC valid
-> beamform/IQ/envelope/frame
-> SAFE or next line
```

硬件不变量：HV enable 与 fire 分开；最大脉宽和最大 burst 数由 FPGA 硬限制；孔径变化只在非发射窗口；watchdog、过流、时钟失锁和非法地址都直接回 SAFE。

## 2. 三套发射链

### WULPUS

约 15 V pulser -> HV2707 TX 开关 -> 8 个物理通道之一。发射后关闭 TX，等待恢复，再打开对应 RX。

### WULPUS Pro

30 V pulser -> 公共 `TX_RX` -> HV2707 16 路选择。CMUT 使用时还要处理 -30 V 到 +30 V 偏置以及 VLL-before-VDD。

### 96ARC / PowerDaughter

```text
battery/charger
-> LT8471 dual HV converter
-> +50 V and -50 V
-> 2 x HV7350 (16 pulser channels)
-> 3 x SY2320 aperture network
-> 96-element probe
```

商用板的 ±50 V 是 rail 能力，不是默认探头驱动值。原型应在假负载上从 10-20 V 起调，最终幅度由探头额定值、目标 SNR 和水听器声输出决定。

## 3. 商用接收链

```text
96 elements
-> SY2320 selected TX/RX buses (16)
-> MD0101 protection (16)
-> MT8816 16x8 crosspoint
-> AD9273 8ch LNA/VGA/AAF/12-bit ADC at up to 50 MS/s
-> Cyclone 10 LP FPGA
```

保护和恢复要同时覆盖三种瞬态：HV7350 边沿、探头自身振铃、MUX 电荷注入。仅在 ADC 饱和消失后开始计样会损失近场；正确方法是同时优化 pulser 波形、保护器件、blank 窗口和 AFE 恢复。

## 4. 深度、采样和 PRF

声速取 `c = 1540 m/s`：

```text
round_trip_time = 2 * depth / c
PRF_max ~= c / (2 * depth)
samples_per_channel = ceil(sample_rate * round_trip_time)
```

| 深度 | 往返时间 | 理论最大 PRF | 50 MS/s 样本/通道 |
|---:|---:|---:|---:|
| 20 mm | 26.0 us | 38.5 kHz | 1299 |
| 40 mm | 51.9 us | 19.25 kHz | 2598 |
| 60 mm | 77.9 us | 12.83 kHz | 3897 |
| 100 mm | 129.9 us | 7.70 kHz | 6494 |

实际 PRF 必须小于理论值，因为还要留 blank、处理、行切换和安全余量。

## 5. 颈动脉探头规格

- 类型：96 或 128 阵元 PZT 线阵。
- 中心频率：B-mode 约 7.5 MHz；Doppler 可用约 5 MHz。
- 带宽：60%-80%。
- pitch：0.15-0.25 mm；96 x 0.20 mm 为 19.2 mm 孔径。
- 深度：0-60 mm；color ROI 优先限制在 40 mm 内。
- ADC：40-50 MS/s，12 bit，MVP 8 RX，推荐 16 RX。

7.5 MHz 波长约 0.205 mm。严格无栅瓣转向条件近似：

```text
pitch <= wavelength / (1 + sin(max_steering_angle))
```

±15 degree 时约 0.163 mm。若采购 0.20 mm pitch，应限制转向角，并依赖阵元方向性、孔径和 apodization 管理栅瓣。

## 6. TGC 如何计算

软组织一阶衰减取 `0.5 dB/(cm*MHz)`：

```text
two_way_loss_db ~= 2 * attenuation * frequency_MHz * depth_cm
TGC_slope_db_per_us ~= attenuation * frequency_MHz * 0.154
```

| 模式 | 深度 | 两程组织衰减 | 一阶 TGC 斜率 |
|---|---:|---:|---:|
| 7.5 MHz B-mode | 60 mm | 45 dB | 0.578 dB/us |
| 5 MHz Doppler | 40 mm | 20 dB | 0.385 dB/us |

商用 96ARC 用 AD5601 DAC 驱动 AD9273 的公共 TGC 节点。第一条曲线应是分段线性：blank 后保持低增益 2-5 us，再按深度增加；最后用组织仿体校正几何扩散、探头灵敏度和通道差异。

## 7. B-mode 数据量

```text
raw_rate = channels * bits * sample_rate
8 * 12 * 50 MS/s = 4.8 Gbit/s
```

60 mm、8 RX、50 MS/s：每个 firing 3897 sample/ch。若按 16-bit 容器保存，128 line 原始帧约 7.61 MiB；20 fps 为 152 MiB/s。Wi-Fi 不适合持续搬原始 RF，需 USB 3/GigE，或先在 FPGA 里 beamform/envelope/decimate。

## 8. Doppler 计算

```text
doppler_shift = 2 * f0 * velocity * cos(angle) / c
Nyquist requires PRF > 2 * abs(doppler_shift)
```

7.5 MHz、1.5 m/s、60 degree 时约 7.31 kHz，要求 PRF > 14.61 kHz，与 60 mm 深度上限 12.83 kHz 冲突。

改用 5 MHz、40 mm ROI：频移约 4.87 kHz，Nyquist PRF 9.74 kHz，深度允许 PRF 最高 19.25 kHz，存在可工作窗口。

Color flow 需要每条 ROI line 重复 8-16 pulse、IQ、wall filter 和 Kasai autocorrelation。PW Doppler 需要同一 beam/采样门的相干 IQ、128-256 点窗函数 FFT 和角度校正。envelope 数据无法恢复 Doppler 相位。

## 9. WULPUS/Pro 固件时序要点

- WULPUS 与 Pro 的 MSP430 固件仍是学习硬实时状态机的最佳入口。
- Pro 的 804-byte 帧是 4-byte 头 + 400 x 16-bit 样本。
- Pro 配置包在 byte 19 插入 `enEnvDetector`，之后字段整体后移。
- nRF52 路径实际 2 MHz SPI；ESP32-C6 路径 8 MHz。
- VLL-before-VDD；禁止不安全的 TX/RX 同时态。

## 10. 可复算工具

运行：

```powershell
python commercial_fpga_reference/analysis/specs/ultrasound_spec_calculator.py
```

参数包括频率、深度、带宽、阵元数、pitch、转向角、流速、Doppler 角度、ADC 采样率、有效位数、存储容器位数、接收通道和帧率。
