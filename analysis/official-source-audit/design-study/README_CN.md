# WULPUS 三系统学习入口

本目录比较三套真实超声系统：

1. `WULPUS v1.2.2`：8 通道时分、约 15 V、单路 8 MS/s 12-bit 采集、MSP430FR5043 + nRF52/BLE。
2. `WULPUS Pro v0.1.0`：16 通道时分、30 V、AD8338 VGA/TGC、可选包络和 CMUT 偏置，主机可用 nRF52 DK 或 ESP32-C6。
3. `96ARC_V7 + PowerDaughter_v30`：96 阵元、16 路 ±50 V 发射/接收总线、8 路 AD9273 50 MS/s AFE/ADC、Cyclone 10 LP FPGA 和 CC3200 无线主控。

此前的 `pcb_reverse_engineering/design_reference` 只是内部生成的 ESP32-S3 两层实验规格，不是商用逆向系统。它不再作为第三样例，仅可作为“低速主控/电源概念草案”参考。

## 建议阅读顺序

1. `01_SYSTEM_COMPARISON_CN.md`：先理解共同流水线和并行度差异。
2. `02_SIGNAL_CHAIN_AND_TIMING_CN.md`：理解 HV、保护、TGC、深度、PRF 和 Doppler。
3. `03_FIRMWARE_HARDWARE_MAP_CN.md`：把 MCU/FPGA/主机职责和存储镜像对应起来。
4. `04_COMPONENT_CROSS_REFERENCE.csv`：查器件与功能映射。
5. `05_EVIDENCE_AND_STATUS_CN.md`：区分已确认、强推断和待验证。
6. `06_STUDY_SEQUENCE_CN.md`：按通过门搭建原型。

完整中文 PDF：

`pcb_reverse_engineering/output/pdf/Portable_Ultrasound_Three_System_Study_CN.pdf`

## 证据标签

- **[确认]**：官方源码、交付 BOM、PCB 网络、Gerber、照片或存储镜像直接支持。
- **[强推断]**：多个独立证据一致，但缺少位流、协议或专有器件数据手册。
- **[待验证]**：需要示波器、逻辑分析仪、探头数据表、FPGA 镜像或水听器。

## 工作区地图

```text
wulpus/
|- wulpus/source_current
|- wulpus/wulpus_reproduction_package
|- wulpus_pro/source_pro
|- wulpus_pro/wulpus_pro_reproduction_package
|- pcb_reverse_engineering/commercial_fpga_reference
|  |- source_original                 商用交付只读副本与 SHA-256
|  |- analysis/pcb                    KiCad PCB 副本、IPC-D-356、统计
|  |- analysis/schematic              交付 PDF 渲染
|  |- analysis/photos                 实物/铜层图片
|  |- analysis/specs                  超声规格计算器
|  `- study                           商用板专项笔记
|- pcb_reverse_engineering/report     Typst 源文件
`- pcb_reverse_engineering/output/pdf 最终 PDF
```

## 三套系统的共同骨架

```text
电池/USB
-> 低压与 HV 电源
-> pulser
-> 通道/孔径选择
-> 探头
-> T/R 保护
-> LNA/VGA/TGC/AAF
-> ADC
-> 硬实时状态机
-> 降维/帧化
-> USB/Ethernet/Wi-Fi/BLE 主机
```

共同的是物理流水线，不是并行度。WULPUS/Pro 是单接收链时分系统；96ARC 是 96 阵元经层级复用进入 16 路发射和 8 路并行 AFE/ADC 的 FPGA 成像系统。

## 最重要的结论

- 颈动脉 B 模式需要 96/128 阵元 5-10 MHz 线阵，单元探头只能做 A-mode/机械扫描。
- 商用板的 `±50 V` rail 不等于探头必须使用 100 Vpp，最终电压由探头额定值和水听器声输出决定。
- `8 x 12 x 50 MS/s = 4.8 Gbit/s`，FPGA 必须在板上降维；CC3200/ESP32 只能做 supervisor 和连接。
- `W25Q80D U14` 是 PowerDaughter 的 CC3200 Flash；96ARC 的 FPGA 配置器件是另一颗 `EPCS16 U14`，当前没有位流镜像。
- Doppler 必须保留相干 RF/IQ；包络数据不能恢复血流相位。
- 任何人体接触之前，必须完成 HV 防护、校准水听器声输出、组织/流体仿体和法规风险流程。

## 使用边界

这些文件用于研究、学习和原型设计，不是医疗器械制造或临床诊断依据。高压板、阵列探头和患者侧接口必须由具备相应资质的工程团队复核。
