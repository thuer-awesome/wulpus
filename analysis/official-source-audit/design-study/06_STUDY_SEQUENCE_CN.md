# 建议学习与实验顺序

## 阶段 0：冻结目标和安全边界

产物：探头规格卡、成像深度/频率/帧率、B-mode/Doppler 需求、数据率预算、风险表。

通过门：拿到逐阵元探头数据表；明确首版仅为研究级仿体系统；HV 有独立硬件关断；扫描时充电器断开。

## 阶段 1：WULPUS 建立完整闭环

阅读顺序：

1. Acquisition 与 HV 两块板原理图。
2. MSP430 pulser/MUX/PGA/ADC 状态机。
3. nRF52832 与 dongle 数据路径。
4. 官方 BOM、装配图和 DNP。

实测：低电压假负载、单元 PZT pulse-echo、8 MS/s 帧、BLE 丢帧和上电顺序。

通过门：在不改硬件的前提下解释每个时序边沿、每个配置字段和每帧数据。

## 阶段 2：WULPUS Pro 学模拟增强

重点：16 路 HV2707 拓扑、30 V TX、AD8338 TGC、LTC5507 envelope、可切换低通、CMUT bias。

必须复核：

- U16 输入至少 1 uF。
- PJ1 镜像。
- R23/RGND 泄放。
- J1/J2 堆叠高度。
- C12 实板 220 pF。
- AD8338 OFFSN。
- VLL-before-VDD。
- 禁止 TX/RX 同时态。
- nRF52 2 MHz 与 ESP32-C6 8 MHz 分开测试。

通过门：raw RF、envelope、滤波和 TGC 曲线都能独立切换并记录。

## 阶段 3：拆解商用 FPGA 板

已完成：

- 原始交付只读归档和 SHA-256。
- Altium PCB -> KiCad CLI 导入。
- 96 阵元、16 TX、16 protected bus、16x8 crosspoint、8ch AD9273 网络分析。
- 板间 +50/-50/VCC/GND 映射。
- W25Q80/FRAM 镜像初步分析。

下一步：

1. 只读备份 96ARC EPCS16，两次读取比对 hash。
2. 示波器确认 HV7350 pulse、SY2320 address/enable、blank、AD9273 clock、FPGA frame trigger。
3. 逻辑分析 FPGA-CC3200 connector，识别 CLK/CS/DOUT/ENV 等协议。
4. 用组织仿体确认输出是 RF、line envelope 还是完整 frame。
5. 查明 SY2320 数据手册或建立黑盒真值表。

通过门：能画出实际 firing 到 host packet 的完整时序，不依赖猜测。

## 阶段 4：单通道原型 P1

模块：可调 10-50 V HV、单通道 pulser、T/R protector、LNA/VGA/TGC、40-50 MS/s ADC。

测试顺序：电阻/电容假负载 -> 单元 PZT 水槽 -> 组织仿体。

通过门：无 AFE 过压；近场恢复稳定；增益/带宽/噪声可测；HV 可由硬件独立关断。

## 阶段 5：8 路 FPGA 采集 P2

先用 ADC test pattern，不接 HV。实现 LVDS frame alignment、bit-slip、FIFO、timestamp、CRC 和 USB 3/GigE 原始窗口。

通过门：连续 30 分钟无不可观测错帧；每个错误都有计数器；clock spur 和 channel skew 达标。

## 阶段 6：16 TX / 8 RX 子孔径 P3

使用 32 阵元子阵列，不直接上 96/128 元。实现孔径真值表、break-before-make、16 路保护、8 路 AFE、TGC LUT 和固定焦点 beamforming。

通过门：组织仿体上线靶位置、轴/横向分辨率、旁瓣、串扰和恢复达到目标。

## 阶段 7：96/128 阵元 B-mode P4

实现 probe ID、逐通道 offset/gain/delay、坏阵元 mask、动态 receive delay、apodization、sum、IQ/envelope、log compression 和 scan conversion。

通过门：0-60 mm 深度、20-40 fps、动态范围和可重复性在组织仿体中达标。

## 阶段 8：Doppler P5

保留相干 RF/IQ，加入 PRF scheduler、ROI ensemble 8-16、wall filter、Kasai、PW gate、128-256 点 FFT 和 angle correction。

通过门：流体仿体速度误差、alias、variance、clutter rejection 和角度依赖可解释。

## 阶段 9：电池一体化 P6

采用 2S BMS/USB-C PD 或经过验证的 1S 方案。分离 HV、AFE、FPGA、host rails；加入 fuel gauge、电流、温度、充电互锁、eFuse 和放电。

通过门：2 小时运行、热稳态、Wi-Fi/USB burst、EMI、跌落和电池保护合格。

## 阶段 10：预符合性 P7

建立 ISO 14971 风险文件、IEC 60601-1/2-37 电气/声学验证、IEC 62304 软件追踪、IEC 62366-1 可用性和网络安全记录。

停止条件：未完成水听器声输出、漏电/隔离和审批流程时，不进行人体试用。

## 每个模块的记录模板

```text
module/revision:
schematic/PCB/bitstream/firmware hash:
test date/operator/instrument calibration:
probe/dummy load:
power rails and temperature:
HV amplitude/cycles/PRF:
blank/ringdown/receive window:
AFE gain/TGC/filter/sample rate:
raw RF file + metadata:
pass/fail criteria:
known issues and next action:
```
