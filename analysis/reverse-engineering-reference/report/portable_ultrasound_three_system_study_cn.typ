#let navy = rgb("#163247")
#let teal = rgb("#087f79")
#let red = rgb("#bc463d")
#let amber = rgb("#c78b24")
#let green = rgb("#4b7654")
#let violet = rgb("#66558d")
#let ink = rgb("#20282e")
#let muted = rgb("#5e6a72")
#let paper = rgb("#f6f8f7")
#let border = rgb("#d4dde0")
#let pale-blue = rgb("#edf4f7")
#let pale-teal = rgb("#e9f4f2")
#let pale-red = rgb("#faefed")
#let pale-amber = rgb("#fbf4e5")
#let pale-green = rgb("#edf4ee")
#let pale-violet = rgb("#f1eef7")

#set document(
  title: "便携式超声成像系统：三案拆解、颈动脉指标反推与一体化设计",
  author: "Codex engineering study based on WULPUS sources and commercial reverse-engineering evidence",
  date: datetime(year: 2026, month: 8, day: 9),
)

#set page(
  paper: "a4",
  margin: (x: 16mm, top: 15mm, bottom: 17mm),
  fill: white,
  numbering: "1",
  number-align: center + bottom,
  header: context {
    if counter(page).get().first() > 1 {
      align(right, text(size: 7.2pt, fill: muted)[便携式超声成像系统一体化设计])
      v(3pt)
      line(length: 100%, stroke: 0.5pt + border)
    }
  },
)

#set text(
  font: ("Noto Sans SC", "Microsoft YaHei", "Arial"),
  size: 9pt,
  fill: ink,
  lang: "zh",
)
#set par(justify: true, leading: 0.67em)
#set list(indent: 1.05em, body-indent: 0.55em, spacing: 0.25em)
#set enum(indent: 1.05em, body-indent: 0.55em, spacing: 0.25em)
#set table(stroke: 0.5pt + border, inset: 4.2pt)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(width: 100%, fill: navy, radius: 4pt, inset: (x: 10pt, y: 7pt))[
    #text(font: "Noto Serif SC", size: 16pt, weight: "bold", fill: white)[#it.body]
  ]
  v(7pt)
}

#show heading.where(level: 2): it => {
  v(7pt)
  block(width: 100%, inset: (bottom: 3pt), stroke: (bottom: 1.2pt + teal))[
    #text(size: 12.3pt, weight: "bold", fill: navy)[#it.body]
  ]
  v(4pt)
}

#show heading.where(level: 3): it => {
  v(5pt)
  text(size: 10.3pt, weight: "bold", fill: teal)[#it.body]
  v(2pt)
}

#let panel(title, body, accent: teal, fill-color: pale-teal) = block(
  width: 100%,
  breakable: true,
  fill: fill-color,
  stroke: 0.7pt + accent,
  radius: 4pt,
  inset: 8pt,
)[
  #text(weight: "bold", size: 10.1pt, fill: accent)[#title]
  #v(3pt)
  #body
]

#let badge(label, color: teal) = box(
  fill: color,
  radius: 3pt,
  inset: (x: 5pt, y: 2pt),
)[#text(size: 7pt, weight: "bold", fill: white)[#label]]

#let th(body, color: navy) = table.cell(fill: color, inset: 4.5pt)[
  #text(fill: white, weight: "bold", size: 7.7pt)[#body]
]

#let flow-box(title, sub, color: teal, height: 22mm) = block(
  width: 100%,
  height: height,
  fill: color,
  radius: 4pt,
  inset: 5pt,
)[
  #align(center + horizon)[
    #text(fill: white, weight: "bold", size: 8.3pt)[#title]
    #v(2pt)
    #text(fill: white, size: 6.4pt)[#sub]
  ]
]

#let arrow() = align(center + horizon, text(size: 15pt, weight: "bold", fill: muted)[->])

#let module-card(id, title, goal, parts, gate, color: teal) = block(
  width: 100%,
  breakable: false,
  fill: white,
  stroke: 0.7pt + border,
  radius: 4pt,
  inset: 7pt,
)[
  #grid(
    columns: (auto, 1fr),
    gutter: 7pt,
    align: horizon,
    badge(id, color: color),
    text(weight: "bold", size: 10.3pt, fill: navy)[#title],
  )
  #v(3pt)
  #text(weight: "bold", fill: color)[目标] #goal
  #v(2pt)
  #text(weight: "bold", fill: color)[实现] #parts
  #v(2pt)
  #text(weight: "bold", fill: color)[通过门] #gate
]

#let gantt-cell(active: false, color: teal, label: none) = table.cell(
  fill: if active { color } else { white },
  inset: 2.5pt,
)[
  #align(center)[
    #if label != none { text(size: 6.2pt, weight: "bold", fill: if active { white } else { muted })[#label] }
  ]
]

// Cover
#set page(margin: (x: 0mm, top: 0mm, bottom: 0mm), numbering: none, header: none)
#block(width: 100%, height: 297mm, fill: paper)[
  #image("../commercial_fpga_reference/analysis/photos/96ARC_V7_top_component.jpg", width: 100%, height: 100mm, fit: "cover")
  #block(width: 100%, height: 5mm, fill: teal)
  #pad(x: 19mm, top: 15mm)[
    #badge([工程学习与原型路线], color: red)
    #v(8pt)
    #text(font: "Noto Serif SC", size: 26pt, weight: "bold", fill: navy)[
      便携式超声成像系统
      #linebreak()
      三案拆解与一体化设计
    ]
    #v(7pt)
    #text(size: 11.5pt, fill: muted)[
      WULPUS · WULPUS Pro · 96ARC / PowerDaughter 商用 FPGA 反向工程
    ]
    #v(13pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 7pt,
      panel([WULPUS], [8 通道时分、8 MS/s、低功耗 A-mode 完整基线], accent: navy, fill-color: pale-blue),
      panel([WULPUS Pro], [16 通道时分、30 V、AD8338 TGC、CMUT 偏置], accent: teal, fill-color: pale-teal),
      panel([商用 FPGA], [96 阵元、16 路发射、8 路 50 MS/s AFE/ADC、±50 V], accent: amber, fill-color: pale-amber),
    )
    #v(11pt)
    #panel([目标用例], [以颈动脉 B 模式、彩色血流和频谱多普勒为指标反推探头、HV、采集、FPGA、TGC、数据链和电池规格。], accent: green, fill-color: pale-green)
    #v(11pt)
    #line(length: 100%, stroke: 0.7pt + border)
    #v(7pt)
    #grid(
      columns: (1fr, auto),
      [#text(size: 8.2pt, fill: muted)[证据：官方仓库、交付 BOM、Altium 原理图/PCB、Gerber、实物层图、存储镜像]],
      [#text(size: 8.2pt, weight: "bold", fill: navy)[2026-08-09]],
    )
  ]
]
#pagebreak()

#set page(
  margin: (x: 16mm, top: 15mm, bottom: 17mm),
  numbering: "1",
  number-align: center + bottom,
  header: context {
    if counter(page).get().first() > 1 {
      align(right, text(size: 7.2pt, fill: muted)[便携式超声成像系统一体化设计])
      v(3pt)
      line(length: 100%, stroke: 0.5pt + border)
    }
  },
)

= 先给结论：整机由五部分闭环

#panel([结论 1 · 探头决定成像上限], [
  做颈动脉不能从单元探头或 WULPUS 的逐通道 A-mode 直接跳到二维图像。首个成像探头应是 *96 或 128 阵元线阵 PZT*，中心频率 5-10 MHz，建议 B 模式以 7.5 MHz 为中心、带宽 60%-80%；血流模式可降低到约 5 MHz 以扩大无混叠速度范围。0.15-0.25 mm 阵元间距、19-26 mm 有效孔径是可实施起点。采购时必须拿到逐阵元引脚、阻抗/电容、带宽、最大驱动、电缆和声透镜资料。
], accent: navy, fill-color: pale-blue)

#v(5pt)
#panel([结论 2 · HV 不是独立模块，它与探头和接收共用声学节点], [
  商用板的证据链是：`PowerDaughter LT8471 -> +50/-50 V -> 2 x HV7350 -> 16 路发射/接收总线 -> 3 x SY2320 -> 96 个阵元`。回波从同一阵元返回，再经 `SY2320 -> 4 x MD0101 -> MT8816 16x8 -> AD9273`。因此 HV、MUX、T/R 保护和 AFE 的时序必须由同一 FPGA 状态机控制，不能由无线 MCU 分散 bit-bang。
], accent: red, fill-color: pale-red)

#v(5pt)
#panel([结论 3 · 采集必须在 FPGA 内先降数据率], [
  `8 路 x 12 bit x 50 MS/s = 4.8 Gbit/s` 原始吞吐。板间连接和 CC3200 不可能持续搬走这一级数据，且主板没有外部 DDR。因此商用 FPGA 至少要完成 LVDS 捕获、通道选择、延时/求和或等价降维、包络/IQ、抽取和帧化。拟建系统应把 FPGA 定义为硬实时主控，把 USB/以太网/Wi-Fi 主机定义为配置、显示和存储端。
], accent: teal, fill-color: pale-teal)

#v(5pt)
#panel([结论 4 · 电池首先是噪声、隔离和热问题], [
  商用子板包含单节锂电管理、无线充电、功率监测和双路高压变换。新系统的原型阶段应规定“扫描时电池供电、充电器断开、HV 硬件互锁”；若目标总功耗 8-12 W，1S 5 Ah 仅约 1.2-1.7 h，2S 5 Ah 可做到约 2.5-3 h，但需要 2S BMS、USB-C PD 充电和更严格的绝缘/爬电设计。
], accent: green, fill-color: pale-green)

#v(5pt)
#panel([结论 5 · 正确路线是单通道验证后逐级扩展], [
  先用假负载和单元 PZT 完成低压脉冲、T/R 恢复、AFE/TGC 和 ADC；再做 8 路 FPGA 采集；然后做 16 TX / 8 RX 与 32 阵元子孔径；最后才接 96/128 阵元线阵、B 模式、IQ、多普勒和电池。每一阶段都必须有可量化的通过门，而不是一次性合板后同时调 HV、模拟、FPGA、无线和算法。
], accent: amber, fill-color: pale-amber)

= 三个学习样例分别教什么

== 样例一：WULPUS，学低功耗闭环

#grid(
  columns: (1.2fr, 1fr),
  gutter: 8pt,
  [
    - 8 个物理通道，HV2707 每通道 TX/RX 成对开关。
    - 约 15 V 单极性激励，OPA836 + MSP430 内部 PGA。
    - 8 MS/s、12 bit；MSP430FR5043 完成硬实时采集。
    - nRF52832 + BLE，nRF52840 USB dongle 搬运数据。
    - 适合 A-mode、穿戴式测距和系统时序入门。
  ],
  panel([保留的工程思想], [实时采集与无线搬运分离；HV 上电顺序；先 blank 再 fire；配置包与帧格式固定；测试点覆盖每条电源和收发节点。], accent: navy, fill-color: pale-blue),
)

== 样例二：WULPUS Pro，学模拟前端增强

#grid(
  columns: (1.2fr, 1fr),
  gutter: 8pt,
  [
    - 16 通道时分；30 V 单极性发射；-30 V 到 +30 V CMUT 偏置。
    - OPA836 + AD8338 VGA/TGC；可选 LTC5507 包络和可切换低通。
    - ADC 仍为 8 MS/s、12 bit，实时核心仍是 MSP430FR5043。
    - 804-byte 帧：4-byte 头 + 400 个 16-bit 样本。
    - nRF52 路径实际 2 MHz SPI；ESP32-C6 路径使用 8 MHz。
  ],
  panel([必须保留的勘误], [U16 输入电容至少 1 uF；PJ1 镜像；HV2707 R23/RGND 泄放；J1/J2 堆叠高度；C12 实板 220 pF；AD8338 OFFSN；VLL 先于 VDD；禁止 TX/RX 同时态。], accent: teal, fill-color: pale-teal),
)

== 样例三：96ARC / PowerDaughter，学并行成像

#grid(
  columns: (1.15fr, 1fr),
  gutter: 8pt,
  [
    - 96 个阵元连接：U12 提供 64 路，U13 提供 32 路。
    - 2 x HV7350：16 路 ±50 V 双极性超声脉冲器。
    - 3 x 64-pin `SY2320`：高压阵元选择网络，精确真值表待数据手册/位流确认。
    - 4 x MD0101：16 路高压接收保护。
    - MT8816：16x8 模拟交叉开关；AD9273：8 路 12-bit 50 MS/s AFE/ADC。
    - Cyclone 10 LP 10CL040：确定性采集与数据降维；CC3200：无线/主机控制。
  ],
  panel([最关键的边界], [用户提供的 `W25Q80D U14` 是 PowerDaughter 的 CC3200 串行 Flash，不是 FPGA 配置；96ARC 的 FPGA 配置器件是另一颗 U14 `EPCS16SI8N`，当前没有其存储镜像。], accent: red, fill-color: pale-red),
)

#v(5pt)
#grid(
  columns: (2fr, 1fr),
  gutter: 6pt,
  image("../commercial_fpga_reference/analysis/photos/96ARC_V7_top_component.jpg", width: 100%, height: 50mm, fit: "contain"),
  image("../commercial_fpga_reference/analysis/photos/PowerDaughter_v30_top_component.jpg", width: 100%, height: 50mm, fit: "contain"),
)
#align(center)[#text(size: 7pt, fill: muted)[交付实物层图：96ARC 主板（左）与 PowerDaughter 电源/无线子板（右）]]

= 共同超声流水线与架构分叉

== 所有系统共享的物理闭环

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([发射能量], [HV 供电 · pulser], color: red),
  arrow(),
  flow-box([声学接口], [MUX · 阵元 · 匹配层], color: amber),
  arrow(),
  flow-box([接收保护], [T/R · clamp · blank], color: green),
  arrow(),
  flow-box([模拟采集], [LNA · TGC · AAF · ADC], color: teal),
  arrow(),
  flow-box([数字成像], [timing · beamform · host], color: navy),
)

#v(7pt)
#panel([共同控制原则], [
  任何系统都必须先锁定阵元/孔径，再预置增益与滤波，然后进入硬件 blank，最后发射。发射结束后 pulser 进入高阻，等待探头振铃和保护器件恢复，再释放 AFE、启动 ADC 和 TGC。孔径切换只能发生在非发射窗口，且要 break-before-make。
], accent: teal, fill-color: pale-teal)

== 两条产品路线不能混为一条

#table(
  columns: (27mm, 1fr, 1fr),
  align: (left, left, left),
  th([维度]), th([路线 A：WULPUS 型 A-mode]), th([路线 B：FPGA 阵列成像], color: amber),
  [探头], [单元或少量逐通道探头], [96/128 阵元线阵],
  [实时性], [单 ADC、顺序采样、MCU 可承担], [8-32 路并行 ADC、FPGA 必需],
  [数据], [每次几百个样本，BLE 可搬运], [数 Gbit/s 原始流，必须板上降维],
  [图像], [A-mode、厚度/距离趋势], [B-mode、color flow、PW Doppler],
  [首要风险], [功耗、时序、无线稳定性], [HV 串扰、同步、波束形成、热与吞吐],
  [适合目标], [穿戴、单点监测、学习], [颈动脉和便携二维成像],
)

== 三案结构对照

#table(
  columns: (24mm, 1fr, 1fr, 1.15fr),
  align: (left, left, left, left),
  th([模块]), th([WULPUS]), th([WULPUS Pro], color: teal), th([96ARC / PowerDaughter], color: amber),
  [阵元/孔径], [8 路时分], [16 路时分], [96 阵元；16 TX 总线；8 RX ADC],
  [发射], [约 15 V], [30 V 单极性], [2 x HV7350，±50 V rail],
  [选择网络], [HV2707，8 TX + 8 RX], [HV2707，16 路共用 TX_RX], [3 x SY2320 + MT8816],
  [保护], [离散/T-R 路径], [改进收发保护], [4 x MD0101，16 路],
  [AFE], [OPA836 + MCU PGA], [OPA836 + AD8338 + 可选 envelope], [AD9273 八通道 LNA/VGA/AAF/ADC],
  [采样], [8 MS/s，12 bit，1 路], [8 MS/s，12 bit，1 路], [50 MS/s，12 bit，8 路],
  [实时核心], [MSP430FR5043], [MSP430FR5043], [Cyclone 10 LP FPGA],
  [连接], [nRF52832 + BLE dongle], [nRF52 DK 或 ESP32-C6], [CC3200 + Wi-Fi，板间数字接口],
  [用途], [低功耗 A-mode], [增强 A-mode/CMUT 研究], [阵列 B-mode 的商用级骨架],
)

= 商用 FPGA 系统：证据化拆解

== 发送、接收和连接的完整路径

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([电池/充电], [LTC4001 · BQ51013], color: green),
  arrow(),
  flow-box([±50 V], [LT8471 · 双变压器], color: red),
  arrow(),
  flow-box([16 TX], [2 x HV7350], color: red),
  arrow(),
  flow-box([96 阵元], [3 x SY2320 · U12/U13], color: amber),
)
#v(5pt)
#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([同节点回波], [96 -> 16 选择], color: amber),
  arrow(),
  flow-box([16 路保护], [4 x MD0101], color: green),
  arrow(),
  flow-box([16 -> 8], [MT8816 crosspoint], color: violet),
  arrow(),
  flow-box([8 路 RF], [AD9273 -> FPGA], color: teal),
)

== 哪些是确认，哪些仍是推断

#table(
  columns: (24mm, 1fr, 25mm),
  align: (left, left, center),
  th([证据等级]), th([结论]), th([状态]),
  [交付/BOM], [96ARC 为 6 层、标称 1.2 mm；PowerDaughter 为 4 层、标称 1.6 mm。], [已确认],
  [PCB 网络], [U12/U13 共 96 路阵元信号；J2/J1_WL 同 pin 传送 +50、-50、VCC、GND 和数字信号。], [已确认],
  [器件与网络], [16 个 HV7350 输出经 SY2320 到阵元；16 路经 MD0101 后进入 MT8816，再到 8 路 AD9273。], [已确认],
  [吞吐推理], [4.8 Gbit/s 原始流无法进入 CC3200；FPGA 必须先降维。], [强推断],
  [算法边界], [具体是动态接收波束形成、固定延时求和、包络还是其他专有流程。], [待位流/实测],
  [SY2320], [三颗器件各覆盖 32 个阵元；精确地址编码、耐压、导通电阻和开关时序。], [待数据手册],
)

== 板间连接器的可验证部分

#table(
  columns: (22mm, 33mm, 1fr),
  align: (center, center, left),
  th([引脚]), th([PowerDaughter]), th([96ARC]),
  [1-4], [+50 V], [+50 V -> HV7350 正高压],
  [5-8], [GND], [HV 回流/地],
  [9-12], [VCC], [主板低压输入 `J2_FPGA-9`],
  [13-14], [GND], [地],
  [15-18], [-50 V], [-50 V -> HV7350 负高压],
  [19-22], [GND], [地],
  [23-40], [控制/数据，信号间插 GND], [FPGA、逻辑门、按钮/LCD 控制],
)

#panel([版图提示], [
  原始 BOM 才是板厚依据。KiCad 导入副本显示的 1.8336 mm / 1.1224 mm 是 Altium stackup 解析误差，不能拿去生产。主板最小线宽/间距约 0.10/0.076 mm、最小钻孔约 0.20 mm，已经进入高密度 BGA 制造范围；复制时必须让 PCB 厂确认叠层、微小孔、BGA 阻焊桥和阻抗，而不是使用默认两层/四层参数。
], accent: amber, fill-color: pale-amber)

== 两份存储镜像的真正含义

- `Y905#-U14-W25Q80D-SOP8-ZLG.bin`：1,049,602 byte。前 1 MiB 是 CC3200 SimpleLink 串行 Flash，含 `/sys/mcuimg.bin`、service pack 和 Wi-Fi 配置；后 1024 byte 以 `SFDP` 开头，是编程器附加的器件参数表，最后还有 2 个 `00`。前 1 MiB 的 SHA-256 为 `8c11c60c...d76169`。
- `Y905#-U21-FM24CL16B-SOP8-ZLG.bin`：2,048 byte，仅 23 byte 非零，偏移 `0x100` 存在设备标识 `WLPCDJB038`，其余是 `5A A5` 标志和少量配置字节。
- 当前没有 96ARC 的 EPCS16 镜像，所以不能复原 FPGA 状态机、波束形成系数或主机协议。

= 颈动脉目标反推规格

== 首版成像目标

#table(
  columns: (30mm, 1fr, 1fr),
  align: (left, left, left),
  th([指标]), th([B 模式目标]), th([血流/Doppler 目标], color: red),
  [组织深度], [0-60 mm；主 ROI 15-45 mm], [color ROI 建议 <= 40 mm],
  [频率], [中心 7.5 MHz；5-10 MHz 可切换], [约 5 MHz 更利于高速血流无混叠],
  [阵列], [96/128 元线阵，0.15-0.25 mm pitch], [同一线阵，保持相位一致],
  [采样], [>= 30 MS/s；推荐 40-50 MS/s、12 bit], [RF/IQ 路径必须保留，不能只存 envelope],
  [接收通道], [MVP 8 路；推荐 16 路；32 路更稳健], [至少 16 路更利于 SNR、孔径和帧率],
  [帧率], [20-40 fps 目标], [color 10-20 fps；PW spectrum 50-100 Hz 更新],
  [流速], [不适用], [0.1-1.5 m/s；角度校正 <= 60 degree],
)

== 从物理量到电子指标

#grid(
  columns: (1fr, 1fr),
  gutter: 7pt,
  panel([波长与分辨率], [
    $lambda = c / f_0$
    #linebreak()
    7.5 MHz 时 $lambda = 0.205$ mm。70% 带宽下理论轴向分辨率 $c/(2 "BW") approx 0.147$ mm；工程目标应留出换能器振铃和滤波余量，按 0.2-0.4 mm 验收。
  ], accent: navy, fill-color: pale-blue),
  panel([深度与 PRF], [
    $t_(2w) = 2d/c$，$"PRF"_(max) approx c/(2d)$
    #linebreak()
    60 mm 深度往返 77.9 us，理论 PRF 上限 12.83 kHz；实际还要扣除 blank、处理和安全余量。
  ], accent: teal, fill-color: pale-teal),
)
#v(6pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 7pt,
  panel([Doppler 频移], [
    $f_D = 2 f_0 v cos(theta) / c$
    #linebreak()
    7.5 MHz、1.5 m/s、60 degree 时约 7.31 kHz，Nyquist 要求 PRF > 14.61 kHz，与 60 mm 深度冲突。降到 5 MHz、ROI 40 mm 后，频移约 4.87 kHz，PRF 9.74-19.25 kHz 可工作。
  ], accent: red, fill-color: pale-red),
  panel([阵元间距], [
    转向角 $theta_(max)$ 下严格无栅瓣条件约为 $p <= lambda/(1+sin theta_(max))$。7.5 MHz、±15 degree 时约 0.163 mm。若使用 0.20 mm pitch，应限制大角度转向，并用阵元方向性、孔径和 apodization 管理栅瓣。
  ], accent: amber, fill-color: pale-amber),
)

== 数据率决定 FPGA 和接口

#table(
  columns: (1fr, 29mm, 33mm, 1fr),
  align: (left, right, right, left),
  th([数据级]), th([典型规模]), th([连续/帧吞吐]), th([处理位置]),
  [ADC 原始流], [8 x 12 x 50 MS/s], [4.8 Gbit/s], [FPGA 内部，禁止直接进 Wi-Fi],
  [60 mm 一次 firing], [3897 sample/ch], [约 62 kB / 8ch / 16bit], [FPGA FIFO/line buffer],
  [128 line 原始帧], [8ch x 3897 x 128], [约 7.6 MiB/帧（16bit 对齐）], [USB 3 / GigE 才适合持续保存],
  [beamformed envelope], [1ch x 1024-2048 x 128], [0.25-0.5 MiB/帧], [可送主机/Wi-Fi],
  [IQ/color], [ROI + ensemble 8-16], [依 ROI、PRF 和抽取率], [FPGA/SoC 先做 DDC 与 wall filter],
)

#panel([计算器], [
  工作区已提供 `commercial_fpga_reference/analysis/specs/ultrasound_spec_calculator.py`。修改频率、深度、带宽、pitch、转向角、流速、ADC 和通道数即可复算，而不是手工改报告中的固定数字。
], accent: green, fill-color: pale-green)

= 探头、HV 与采集怎么连接

== 推荐探头规格卡

#table(
  columns: (31mm, 1fr, 1fr),
  align: (left, left, left),
  th([项目]), th([推荐起点]), th([采购必须确认]),
  [类型], [线阵 PZT，96 或 128 元], [不是机械扫描单元探头；不是只给整探头阻抗],
  [频带], [5-10 MHz，中心约 7.5 MHz], [-6 dB 带宽、中心频率离散和相位一致性],
  [几何], [pitch 0.15-0.25 mm，孔径 19-26 mm], [kerf、element width/height、elevation focus],
  [电气], [逐元电容/阻抗，单独回线或受控共地], [最大脉冲电压、推荐匹配、连接器 pin map],
  [声学], [短脉冲、低振铃、匹配层 + backing], [灵敏度、脉冲回波、声透镜和温升],
  [线缆], [短柔性线缆，地/屏蔽邻近信号], [每通道串扰、弯折寿命、屏蔽终接],
)

== HV 到探头，再回到 AFE

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([±HV rail], [10 V 起调 -> ±50 V 上限], color: red),
  arrow(),
  flow-box([pulser], [1-3 cycle · 16 TX], color: red),
  arrow(),
  flow-box([HV MUX], [break-before-make], color: amber),
  arrow(),
  flow-box([线阵探头], [96/128 element], color: navy),
)
#v(5pt)
#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([回波], [uV-mV · 同一阵元], color: navy),
  arrow(),
  flow-box([T/R 保护], [MD0101/limiter · blank], color: green),
  arrow(),
  flow-box([选择 + AFE], [16x8 · LNA/VGA/AAF], color: teal),
  arrow(),
  flow-box([ADC/FPGA], [50 MS/s · LVDS], color: violet),
)

#panel([电压不能凭 PCB 数字决定], [
  `±50 V` 仅证明商用电路的 rail 能力，不等于探头应使用 100 Vpp，也不等于声输出安全。首台样机必须在电阻/电容假负载上从 10-20 V 开始，验证脉冲、过冲和恢复后再接探头；最终要用校准水听器测负峰值声压、MI、TI 和脉冲强度。未完成声输出测量前，不用于人体。
], accent: red, fill-color: pale-red)

== 发射/接收状态机

#table(
  columns: (21mm, 24mm, 1fr, 1fr),
  align: (center, center, left, left),
  th([状态]), th([建议初值]), th([硬件动作]), th([失败保护]),
  [SAFE], [持续], [HV disabled；pulser 输出高阻；AFE 最小增益], [任何 watchdog/过流/欠压都回到 SAFE],
  [SELECT], [> mux settle], [先全断，再写入 TX/RX 孔径], [地址不合法则拒绝 fire],
  [BLANK], [0.5-2 us 起调], [T/R clamp；ADC 数据标 invalid；冻结 TGC], [blank 未确认则禁止 HV],
  [FIRE], [1-3 cycle], [FPGA 硬件定时驱动 HV7350], [最大 pulse width/次数硬限幅],
  [RINGDOWN], [0.5-3 us 起调], [pulser high-Z；维持保护；禁止 MUX 切换], [过压比较器保持 AFE mute],
  [RECEIVE], [到深度窗口结束], [释放保护；ADC valid；按深度运行 TGC], [ADC 饱和计数超限则降 HV/增 blank],
  [FRAME], [行/帧边界], [beamform/IQ/envelope/打包], [CRC、序号、丢帧计数],
)

== 过压、振铃和数字噪声怎么压住

- *器件层*：HV rated pulser/MUX；MD0101 或等价主动保护；AFE 输入前低电容 limiter、串阻和可测 clamp；ADC 过量程计数。
- *时序层*：硬件 blank 覆盖整个发射与振铃；pulser high-Z 后再打开 RX；任何孔径地址变化都先全断；HV enable 与 fire 分离。
- *电源层*：HV converter 的开关频率与采集窗口协调；AFE 用独立低噪声 LDO/LC；±HV 有放电和电压监测；无线突发不能共享 AFE rail。
- *版图层*：TX、MUX、阵元连接器靠近；保护器件紧贴进入 AFE 的边界；LVDS/clock 远离 HV 磁件；完整参考地平面和可控回流，不随意切割模拟地。
- *机械层*：探头屏蔽在单点/受控位置终接；电池和天线远离 AFE；外壳内设置 HV 隔离区和不可触及结构。

= 可编程增益：TGC 是成像核心，不是音量旋钮

== 商用板如何实现

96ARC 的 `AD9273` 集成 8 路 LNA、VGA、抗混叠滤波和 12-bit ADC。PCB 网络显示 `AD5601` DAC 由 FPGA 三线控制，其输出经 R40 到 AD9273 的 `TGC` 节点；因此它是 *8 路共享、随深度连续变化的模拟增益控制*。固定 LNA 增益、滤波带宽和工作模式由 AFE 串行寄存器配置，动态 TGC 由 DAC 曲线承担。

== 如何算第一条 TGC 曲线

#grid(
  columns: (1fr, 1fr),
  gutter: 7pt,
  panel([一阶补偿], [
    软组织衰减近似 $alpha = 0.5$ dB/(cm·MHz)。两程补偿：
    #linebreak()
    $G_("TGC")(z) approx 2 alpha f_0 z$
    #linebreak()
    7.5 MHz、60 mm 深度约 45 dB；5 MHz、40 mm 约 20 dB。
  ], accent: teal, fill-color: pale-teal),
  panel([随时间的斜率], [
    因 $z = c t / 2$，一阶斜率为 $Delta G / Delta t approx alpha f_0 c$。
    #linebreak()
    7.5 MHz 约 0.58 dB/us；5 MHz 约 0.385 dB/us。它只补偿组织衰减，几何扩散和探头响应要靠标定修正。
  ], accent: navy, fill-color: pale-blue),
)

== 实际可编程策略

1. 近场 blank 后 2-5 us 保持低增益，避免残余振铃打满 VGA/ADC。
2. 用 8-16 个深度控制点定义分段线性 TGC；FPGA 在每个 firing 开始时触发 DMA/查表更新 DAC。
3. 每条曲线都记录 `HV、LNA gain、VGA/TGC、AAF bandwidth、采样率、温度、探头 ID`。
4. 先用标准线靶/组织仿体调到各深度背景幅度接近，再用强反射体检查 12-bit ADC 仍保留 3-6 dB 峰值余量。
5. 统计每深度 bin 的饱和率和噪声 RMS；饱和率过高先降 TGC/HV，噪声抬升则检查保护恢复、电源和通道串扰。

#panel([为 Doppler 保留相位], [
  envelope detector 适合显示幅度，但会丢失正负频移和相位。B 模式可输出 envelope；color/PW Doppler 必须从同一稳定采样时钟下的 RF 或复数 IQ 分支计算。两条路径可以共享 AFE 和 ADC，不能只保存包络后再“恢复”多普勒。
], accent: red, fill-color: pale-red)

= FPGA 与成像算法

== 推荐硬实时流水线

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([LVDS capture], [8/16ch · frame align], color: violet),
  arrow(),
  flow-box([calibration], [offset · gain · bad channel], color: green),
  arrow(),
  flow-box([delay/apodize], [fractional delay · LUT], color: amber),
  arrow(),
  flow-box([sum], [dynamic receive aperture], color: teal),
)
#v(5pt)
#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 4pt,
  flow-box([RF branch], [debug · raw capture], color: navy),
  arrow(),
  flow-box([B-mode], [demod · envelope · log], color: teal),
  arrow(),
  flow-box([Doppler], [IQ · wall filter · estimator], color: red),
  arrow(),
  flow-box([packetizer], [CRC · timestamp · USB/GbE], color: green),
)

== B 模式最小算法集

- 发射聚焦或有限角度 plane-wave；首版优先固定焦点/固定孔径，降低验证复杂度。
- 每通道 offset/gain/delay 标定，失效阵元掩码。
- 动态接收延时、apodization、求和；50 MS/s 下 20 ns 采样间隔仍需要分数延时插值以减少量化旁瓣。
- 正交解调或 Hilbert 近似、低通与抽取；包络检测；40-60 dB log compression；scan conversion。
- 帧元数据必须携带孔径、焦点、HV、TGC、温度、PRF 和探头 ID。

== Color 与 PW Doppler 最小算法集

#table(
  columns: (29mm, 1fr, 1fr),
  align: (left, left, left),
  th([模块]), th([Color flow]), th([PW spectrum], color: red),
  [采集], [ROI 内每条 line 重复 8-16 pulse], [同一 beam/采样门连续重复],
  [信号], [beamformed complex IQ], [采样门 complex IQ],
  [杂波], [高通 wall filter，抑制血管壁/探头运动], [更高阶/自适应 wall filter],
  [估计], [Kasai autocorrelation：速度 + power + variance], [128-256 点窗函数 FFT / overlap],
  [PRF], [按深度与流速 4-15 kHz], [5-20 kHz，受采样门深度限制],
  [显示], [color map 叠加 B-mode], [速度谱、包络、角度校正],
)

#panel([颈动脉 Doppler 的设计冲突], [
  深成像要求低 PRF，高速血流要求高 PRF；高频提高分辨率，也提高 Doppler shift 并更容易 alias。解决方式是缩小 color ROI、降低 Doppler 发射频率、将取样门放在较浅深度、控制 insonation angle、采用 baseline shift/高 PRF 模式，并明确显示 alias，而不是修改公式隐藏冲突。
], accent: red, fill-color: pale-red)

= 电池、电源、时钟与热

== 推荐电源树

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 5pt,
  flow-box([USB-C PD/充电], [认证适配器 · charge interlock], color: green),
  arrow(),
  flow-box([2S 电池 + BMS], [fuel gauge · fuse · current sense], color: navy),
  arrow(),
  flow-box([系统母线], [soft start · eFuse · load switch], color: teal),
)
#v(5pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 5pt,
  flow-box([±HV], [可编程 10-50 V · discharge], color: red),
  flow-box([AFE rail], [低噪声 LDO · LC], color: teal),
  flow-box([FPGA rail], [core · I/O · sequence], color: violet),
  flow-box([host rail], [USB/GbE/Wi-Fi load switch], color: green),
)

== 功耗预算先按 12 W 设计

#table(
  columns: (1fr, 27mm, 1fr),
  align: (left, right, left),
  th([模块]), th([初始预算]), th([验证方式]),
  [AFE/ADC 8-16ch], [1.5-3.0 W], [静态/50 MS/s/不同 gain 分档测量],
  [FPGA + clock + memory], [2.5-4.0 W], [真实 bitstream toggle rate + 热像],
  [HV converter + pulser], [0.5-2.0 W avg], [不同 PRF、脉宽、负载下输入功率],
  [USB/GbE/Wi-Fi 主机], [1.0-2.5 W], [峰值与平均分开记录],
  [损耗与余量], [1.5-2.5 W], [DC/DC 效率、线缆、LDO 压差],
  [总计], [8-14 W], [以 12 W 做电池和散热首轮预算],
)

2S 5 Ah 标称约 37 Wh。按 80% 可用能量和 12 W 平均功耗，运行时间约 `37 x 0.8 / 12 = 2.47 h`。这是电量估算，不含电池低温、老化、峰值降额和外壳温升限制。

== 时钟和噪声要求

- ADC 采样时钟必须由低抖动源直接送 AFE/FPGA；CC3200/Wi-Fi 不参与采样定时。
- B-mode 可容忍少量帧间抖动；Doppler 需要 firing 到 firing 的相位一致，PRF 定时也必须由 FPGA 计数器产生。
- HV DC/DC 可在 RECEIVE 窗口降频/保持或采用同步调度，但必须验证 rail droop；不能在未测量情况下直接关闭控制环。
- FPGA 核心、LVDS I/O、AFE 模拟和无线峰值电流分别用近端 decoupling 与阻抗测试验证。

= 一体化项目：十二个可独立验收的模块

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  module-card([M1], [探头与连接], [固定 96/128 阵元 pin map、屏蔽和标定], [探头适配板、ID EEPROM、温度传感器], [逐通道开短路、串扰和 pulse-echo 合格], color: navy),
  module-card([M2], [HV 电源], [产生可控 ±10 至 ±50 V], [boost/inverting、监测、放电、eFuse], [假负载下过冲、纹波、过流和关断合格], color: red),
  module-card([M3], [多通道 pulser], [1-3 cycle 可编程脉冲], [8/16ch pulser、硬件 pulse-width 限制], [幅度/边沿/通道偏差和温升合格], color: red),
  module-card([M4], [孔径选择与 T/R], [96/128 元连接到 16/32 总线并保护 AFE], [HV MUX、MD0101/limiter、blank], [全状态无直通；恢复时间和残余脉冲合格], color: amber),
  module-card([M5], [AFE/TGC/AAF], [小信号增益、带宽和动态范围闭环], [8/16ch AFE、DAC TGC、输入校准], [噪声、增益误差、饱和恢复和带宽合格], color: teal),
  module-card([M6], [ADC 与低抖动时钟], [同步 40-50 MS/s、12 bit 采样], [LVDS ADC、clock tree、test pattern], [无 bit slip；ENOB/clock spur/通道 skew 合格], color: violet),
  module-card([M7], [FPGA capture/timing], [唯一硬实时主控], [状态机、FIFO、CRC、触发与错误计数], [连续 30 min 无错帧；所有故障回 SAFE], color: violet),
  module-card([M8], [beamforming/B-mode], [输出可重复二维图像], [delay LUT、apodize、sum、envelope、log], [线靶位置/分辨率/旁瓣达到目标], color: teal),
  module-card([M9], [Doppler DSP], [输出速度、power、variance 和 spectrum], [IQ、wall filter、Kasai、FFT], [流体仿体速度误差和 alias 行为可解释], color: red),
  module-card([M10], [主机与接口], [可靠配置、原始/处理数据搬运], [USB 3 或 GbE 主链路；Wi-Fi 辅助], [吞吐、时延、丢包、升级和日志合格], color: green),
  module-card([M11], [电池/热/机械], [便携供电与可触及温度受控], [2S BMS、PD、散热器、屏蔽、外壳], [2 h 运行、热稳态、跌落和电池保护合格], color: green),
  module-card([M12], [校准与安全], [把电压波形变成可追踪声学指标], [水听器、组织仿体、测试治具、风险文件], [MI/TI/声输出/电气安全记录齐全], color: navy),
)

== 推荐首版系统边界

#panel([Portable Carotid US v1], [
  `96/128 元 5-10 MHz PZT 线阵 + 16 TX / 8 RX + 50 MS/s 12-bit + 中型 FPGA + USB 3/GigE + 可选 Wi-Fi + 2S 电池`。首版只承诺研究级 B-mode；硬件从一开始保留相干 RF/IQ、稳定 PRF 和 Doppler 元数据，但 color/PW Doppler 在 B-mode 通过仿体验收后再启用。
], accent: teal, fill-color: pale-teal)

选择 16 TX / 8 RX 是为了能够直接学习商用架构并控制首板复杂度；若最终目标是临床质量的高速彩色血流，第二版应评估 16/32 路并行接收、更多 FPGA DSP/RAM 和更高速主机接口。不要把 CC3200 或 ESP32 当成并行采集/波束形成核心，它们只适合作为 supervisor、连接和 UI 处理器。

= 分阶段实现与 40 周 Gantt

== 每阶段的产物和通过门

#table(
  columns: (18mm, 30mm, 1fr, 1fr),
  align: (center, left, left, left),
  th([阶段]), th([产物]), th([完成定义]), th([禁止进入下一阶段的条件]),
  [P0], [需求与仿真], [冻结探头、深度、频率、孔径、数据率和风险表], [没有探头数据表；没有声学/电气安全边界],
  [P1], [单通道收发板], [假负载和单元 PZT 下脉冲、保护、AFE、TGC、ADC 可重复], [AFE 过压；恢复时间不稳定；HV 无硬件关断],
  [P2], [8 路 ADC + FPGA], [test pattern、8 路 RF、line buffer、USB 采集 30 min 无错], [bit slip、clock spur、丢帧不可观测],
  [P3], [16 TX / 8 RX 子孔径], [32 元子阵列成像、孔径切换、TGC 与标定闭环], [串扰/旁瓣/保护饱和未达标],
  [P4], [96/128 元 B-mode], [组织仿体中深度、分辨率、帧率和动态范围达标], [只在空气/金属反射上“看见波形”],
  [P5], [Color/PW Doppler], [流体仿体速度误差、alias、wall filter 和角度校正可解释], [只有彩色噪声、没有相干 IQ 验证],
  [P6], [电池一体化], [2 h 热稳态、充电互锁、EMI、机械和日志完整], [边充边扫未隔离；外壳温升/漏电未评估],
  [P7], [预符合性], [风险管理、声输出、电气安全和软件追踪矩阵], [任何人体试用早于批准流程],
)

== 40 周基线计划

#table(
  columns: (32mm,) + (1fr,) * 10,
  align: center,
  th([工作包]), th([1-4]), th([5-8]), th([9-12]), th([13-16]), th([17-20]), th([21-24]), th([25-28]), th([29-32]), th([33-36]), th([37-40]),
  [需求/探头/风险], gantt-cell(active: true, color: navy, label: [P0]), gantt-cell(active: true, color: navy), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(),
  [单通道 HV/AFE], gantt-cell(), gantt-cell(active: true, color: red, label: [P1]), gantt-cell(active: true, color: red), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(),
  [ADC/FPGA capture], gantt-cell(), gantt-cell(active: true, color: violet), gantt-cell(active: true, color: violet, label: [P2]), gantt-cell(active: true, color: violet), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(),
  [16TX/8RX 子阵列], gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(active: true, color: amber, label: [P3]), gantt-cell(active: true, color: amber), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(),
  [96/128 元 B-mode], gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(active: true, color: teal, label: [P4]), gantt-cell(active: true, color: teal), gantt-cell(active: true, color: teal), gantt-cell(), gantt-cell(), gantt-cell(),
  [Color/PW Doppler], gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(active: true, color: red), gantt-cell(active: true, color: red, label: [P5]), gantt-cell(active: true, color: red), gantt-cell(), gantt-cell(),
  [电池/热/机械], gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(active: true, color: green), gantt-cell(active: true, color: green, label: [P6]), gantt-cell(active: true, color: green), gantt-cell(),
  [校准/预符合性], gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(), gantt-cell(active: true, color: navy, label: [P7]), gantt-cell(active: true, color: navy),
)

#panel([Gantt 的使用方式], [
  这是以一支小型硬件/FPGA/算法联合团队为基线的相对计划，不是承诺日期。任何阶段若没有通过门，后续任务可继续做仿真、固件和治具，但不得把未验证 HV/AFE 合并到人体接触样机。
], accent: amber, fill-color: pale-amber)

= 验证、法规与停止条件

== 最小测试矩阵

#table(
  columns: (28mm, 1fr, 1fr),
  align: (left, left, left),
  th([层级]), th([测试对象]), th([必须记录]),
  [电源], [所有 rail：空载/满载/发射/Wi-Fi burst], [电压、纹波、启动顺序、过流、温升],
  [HV], [假负载、探头等效负载、真实探头], [幅度、脉宽、过冲、ringing、重复率、关断],
  [保护], [各 HV/MUX 状态组合], [AFE 端最大残余、电荷恢复、blank margin],
  [模拟], [50 ohm/电容/组织仿体信号], [noise RMS、gain、带宽、THD、饱和恢复],
  [数字], [ADC test pattern、PRBS、长时间采集], [bit error、CRC、丢帧、时钟偏差、timestamp],
  [图像], [线靶、囊肿/对比靶、组织仿体], [轴向/横向分辨率、对比度、深度、帧率],
  [Doppler], [可控流速流体仿体], [速度误差、variance、alias、wall filter 抑制],
  [声学], [校准水听器], [峰值负压、MI、TI、I_SPPA/I_SPTA 等],
)

== 安全边界

- 本报告是研究和工程学习文件，不是医疗器械设计验证报告，也不授权临床诊断。
- 高压测试使用限流电源、绝缘探头、差分高压探头、单手操作规则、放电确认和防护罩；不在通电时插拔阵列探头。
- 首轮声学测试只在水槽和组织仿体中进行；在校准水听器和风险评审完成前不接触人体。
- 需要纳入的标准/流程至少包括 IEC 60601-1、IEC 60601-2-37、IEC 62304、IEC 62366-1、ISO 14971、声输出标识和当地监管要求。
- 人体接触设计还需材料生物相容性、清洁消毒、漏电/隔离、EMC、网络安全、软件可追踪性和临床评价。

== 硬停止条件

#panel([出现任一项立即回到 SAFE], [
  AFE 输入超过绝对最大值；HV 不能由硬件独立关断；MUX 地址存在直通/重叠；ADC 持续饱和但系统仍自动提高增益；采样时钟失锁；电池过温/鼓包/保护动作；充电器连接时患者侧无合规隔离；未测声输出却计划人体试扫。
], accent: red, fill-color: pale-red)

= 文件入口与复现状态

== 商用系统归档

- 原始只读副本：`pcb_reverse_engineering/commercial_fpga_reference/source_original`
- SHA-256 清单：`source_original/MANIFEST_SHA256.csv`，共 77 个源文件、283,433,952 byte。
- KiCad PCB 副本：`commercial_fpga_reference/analysis/pcb/20260725_96ARC_V7.kicad_pcb` 与 `20260725_PowerDaughter_v30.kicad_pcb`。
- PDF/照片渲染：`commercial_fpga_reference/analysis/schematic` 与 `analysis/photos`。
- 规格计算器：`commercial_fpga_reference/analysis/specs/ultrasound_spec_calculator.py`。

== CAD 转换结论

- 两套 `.pcb/.sch` 都以 OLE CFBF 签名 `D0 CF 11 E0` 开头，项目文件为 Altium `PrjPcb`。
- KiCad 10.0.5 CLI 已成功把两块 PCB 以 `--format altium` 导入，统计为 96ARC 334 个 footprint、4484 条 track、949 个 via；PowerDaughter 203 个 footprint、1250 条 track、286 个 via。
- KiCad CLI 只能命令行导入 PCB，不能命令行导入 Altium schematic；原理图目前以交付 PDF、BOM 和 PCB 网络三方交叉分析。
- 转换副本仅用于学习/分析，不可替代原始 Altium 工程和生产 Gerber。

== 最终工程判断

#panel([该怎么继续], [
  WULPUS 用来学完整时序闭环，Pro 用来学 TGC/滤波/偏置，96ARC/PowerDaughter 用来学 96 阵元、16 TX、8 RX、50 MS/s 和 FPGA 数据降维。真正的颈动脉系统应走 FPGA 阵列路线；MCU/ESP32/CC3200 只能做 supervisor 和连接。首个可交付里程碑不是“人体颈动脉图”，而是 *32 阵元子孔径在组织仿体上形成可重复 B-mode，并且所有 HV、保护、TGC、RF 和错误计数都有测量记录*。
], accent: teal, fill-color: pale-teal)

== 责任边界

WULPUS 与 WULPUS Pro 的设计事实来自本地官方仓库快照和源码；商用系统事实来自用户提供的逆向交付文件。`SY2320` 具体器件参数、FPGA 位流和专有算法尚未取得，因此报告对其只作网络级高置信度归纳，不虚构寄存器、时序或成像性能。所有尺寸、功耗、声压和运行时间都需要用目标探头和实板复测后冻结。
