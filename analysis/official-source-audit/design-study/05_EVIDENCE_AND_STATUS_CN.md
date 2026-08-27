# 证据、转换状态与限制

## 1. 官方 WULPUS/WULPUS Pro 快照

- WULPUS 源码：`wulpus/source_current`
- WULPUS 复刻包：`wulpus/wulpus_reproduction_package`
- WULPUS Pro 源码：`wulpus_pro/source_pro`
- WULPUS Pro 复刻包：`wulpus_pro/wulpus_pro_reproduction_package`

WULPUS/Pro 的器件、固件帧、SPI、GPIO、HV2707 和勘误结论均应回到这些本地官方快照核查。

## 2. 商用 FPGA 原始证据

用户提供四项原始材料，已经复制但未移动桌面原件：

```text
commercial_fpga_reference/source_original/
|- 96ARC_V7
|- PowerDaughter_v30
|- memory_dumps/Y905#-U14-W25Q80D-SOP8-ZLG.bin
|- memory_dumps/Y905#-U21-FM24CL16B-SOP8-ZLG.bin
`- MANIFEST_SHA256.csv
```

归档统计：77 个源文件，共 283,433,952 byte。逐文件 SHA-256、长度和 UTC 时间戳在 manifest 中。

## 3. 交付内容

### 96ARC_V7

- Altium binary `.pcb` 4,523,520 byte。
- Altium binary `.sch` 3,103,232 byte。
- `PCB_Project.pdf` 3 页。
- 6 层 Gerber：GTL、G1、G2、G3、G4、GBL。
- BOM、Pick Place、板层照片和实物照片。
- BOM 规格：FR4、6 层、TG150、1.2 mm、外层 1 oz、内层 0.5 oz、沉金。

### PowerDaughter_v30

- Altium binary `.pcb` 1,473,536 byte。
- Altium binary `.sch` 729,088 byte。
- `PCB_Project.pdf` 3 页。
- 4 层 Gerber：GTL、G1、G2、GBL。
- BOM、Pick Place、板层照片、拆解照片。
- BOM 规格：FR4、4 层、TG150、1.6 mm、外层 1 oz、内层 0.5 oz、无铅喷锡。

## 4. CAD 格式识别与转换

`.pcb/.sch` 首字节为：

```text
D0 CF 11 E0 A1 B1 1A E1
```

这是 OLE Compound File Binary Format，与 Altium/Protel binary 工程一致；`PrjPcb` 是 UTF-8 文本项目文件。

KiCad 10.0.5 CLI 已成功执行：

```powershell
kicad-cli pcb import --format altium --output <board.kicad_pcb> <source.pcb>
```

结果：

| 板 | footprint | track | via | zone |
|---|---:|---:|---:|---:|
| 96ARC | 334 | 4484 | 949 | 117 |
| PowerDaughter | 203 | 1250 | 286 | 104 |

KiCad CLI 支持 Altium PCB import，但不支持 Altium schematic CLI import。原理图当前通过交付 PDF 文本、BOM、PCB 网络和照片交叉分析。

导入副本的板厚 1.8336/1.1224 mm 是 Altium stackup 解析误差；生产参数必须使用原始 BOM/Altium/Gerber。

## 5. 已确认的商用架构

- 96 阵元：U12 64 路 + U13 32 路。
- 16 TX：2 x HV7350K6-G，使用 +50/-50 rail。
- 阵元选择：3 x 64-pin `SY2320` marking，每颗覆盖 32 阵元区域。
- 16 路接收保护：4 x MD0101K6-G。
- 16x8 接收选择：MT8816AF1。
- 8 路 AFE/ADC：AD9273BBCZ-50，12-bit 50 MS/s。
- FPGA：Cyclone 10 LP 10CL040YF484C8G。
- TGC：AD5601 输出经 R40 到 AD9273 TGC 节点。
- 子板：CC3200、LTC4001、BQ51013B、LT8471、AD8418、W25Q80、FM24CL16。

## 6. 强推断

原始 8 路 ADC 流为 4.8 Gbit/s；板间只有少量数字信号，CC3200 无法持续接收，主板没有外部 DDR。因此 FPGA 必须流式执行捕获与显著降维。具体是完整动态波束形成、固定延时求和、包络、抽取还是其他专有算法，仍需 EPCS16 位流和实测确认。

## 7. 存储镜像边界

### W25Q80D

- 原始 SHA-256：`989441F5C42FEB2397F1A6AAFF163FFBB9955CA9A55C73CBAC7EC0F5EA574ADF`
- 前 1 MiB SHA-256：`8C11C60C6A7C86ABE0B310D417B99BF657C05531FFFA54EEDE3458E214D76169`
- 文件系统含 `/sys/mcuimg.bin` 和 CC3200 SimpleLink 配置。
- 末尾 1024 byte SFDP + 2 byte 0x00 是编程器附加信息。
- 它属于 PowerDaughter U14，不属于 96ARC FPGA。

### FM24CL16B

- SHA-256：`4DDBE9B386AA709E9E626020F383A4D95B9E3F1427C69FA722BA8227B89CC2C3`
- 2 KiB，只有 23 byte 非零。
- `0x100` 为 `WLPCDJB038`。

### 缺失项

96ARC U14 `EPCS16SI8N` 没有 dump。没有它就不能确认 FPGA 状态机、delay LUT、TGC schedule、主机协议和 B-mode/Doppler 算法。

## 8. 尚待验证

- SY2320 的原厂型号、耐压、R_on、通道真值表和 settle time。
- 96 阵元探头型号、pitch、中心频率、带宽、pin map 和最大电压。
- FPGA 到 CC3200 的协议、输出数据类型和吞吐。
- 是否板上完成动态 beamforming、envelope、scan conversion 或 Doppler。
- +50/-50 实际工作电压、pulse amplitude、cycles 和 PRF。
- 声学输出、MI/TI、热和人体接触安全。

## 9. 转换文件的责任边界

- `source_original`：只读证据，不修改。
- `analysis/pcb/*.kicad_pcb`：分析副本，可搜索网络和引脚，不用于直接生产。
- Gerber/BOM/Pick Place：用于交付复核，但逆向资料仍需人工检查坐标、层叠和 DNP。
- PDF 报告：工程学习与原型路线，不是临床医疗器械验证。
