# WULPUS Pro 完整复刻包

本包来自 pulp-bio/wulpus-pro 仓库 dev 分支提交 d49cf62a53e260d7670d7375b2f6ca3aad627ea7。完整官方工程源码按用途重新归档，所有 349 个 Git 跟踪文件均已逐文件 SHA256 验证为字节一致。

## 目录

- 01_pcb/main_boards_altium_sources
  - 两块 PCB 的完整 Altium 工程、库、3D、History 和原始 fabrication_outputs。
- 01_pcb/jlcpcb_order_packages
  - 两块板分别整理的嘉立创 PCB/PCBA 下单包。
- 01_pcb/fab_order_zips
  - 每块板的完整厂商沟通 ZIP；内部仍按 Gerber、PCBA 和参考资料分目录。
- 02_firmware
  - MSP430、nRF52 DK、nRF52840 Dongle 和 ESP32-C6 的全部官方固件源码。
- 03_host_software/sw
  - Python 包、Jupyter notebooks、Conda 环境、pyproject.toml 和 uv.lock。
- 04_docs
  - 文档缺失说明和旧版官方用户手册参考副本。
- 05_original_repo_metadata
  - 仓库根 README/CHANGELOG、提交信息和跟踪文件清单。
- wulpus-pro.zip
  - 未重新分类的完整 Git 跟踪文件快照，便于恢复原仓库目录结构。

## 实际要制造和购买

需要制造：

1. WULPUS Pro acquisition development board：6 层、1.0 mm、受控阻抗。
2. polyCMUT adapter：可选，2 层；仓库无官方生产 stackup，建议普通 1.6 mm/1 oz/不控阻抗。

需要另购，仓库没有其 PCB 生产工程：

- Nordic nRF52 DK（PCA10040 / nRF52832），作为 BLE/SPI Host 方案。
- Nordic nRF52840 USB Dongle（PCA10059），配合 nRF52 DK 与电脑通信。
- 可选 ESP32-C6-DEVKITM-1，作为 Wi-Fi/SPI Host 方案。
- 换能器、配套 interposer/连接器、电源和编程器。

Pro 主板已集成旧版的采集和高压功能，所以不能按旧版四板清单重复下单。旧版 MSP430 编程转接板又因 PJ1 镜像不能直接连接 Pro。

## 最短制造流程

1. 先读 01_pcb/jlcpcb_order_packages/README_JLCPCB_CN.md。
2. 主板必须读 ERRATA.MD 和 ERRATA_ACTIONS_CN.md，再决定 U16 输入电容、C12、R23/RGND、PJ1 线序和 J1/J2 高度。
3. PCB 页面只上传每板 01_PCB_Gerber_Drill 下的扁平 Gerber ZIP。
4. 需要 SMT 时上传同板 BOM_JLCPCB.csv 和 CPL_JLCPCB.csv，逐项核对 COMPONENT_CHECKLIST.csv。
5. 主板先做 1 至 3 套工程样机；不要未验证就批量生产。
6. 收板后手焊主板 7 个 PTH 排针；转接板手焊 J5，再装配 P1/polyCMUT。

## 固件

主板 MSP430：

- 目录：02_firmware/msp430
- 使用仓库内 CCS 工程和官方说明编译/烧录。
- 注意 PJ1 镜像，烧录线必须逐针核对，不能直接套用旧版转接板。

nRF52 DK + USB Dongle 路线：

- DK 固件：02_firmware/nrf52/ble_peripheral/US_probe_nRF52_firmware
- Dongle 固件：02_firmware/nrf52/peripheral/US_probe_dongle_firmware
- DK 为 PCA10040/nRF52832，Dongle 为 PCA10059/nRF52840。

ESP32 Wi-Fi 路线：

- 目录：02_firmware/esp32
- 框架：ESP-IDF，仓库 sdkconfig 对应 ESP-IDF 5.4.1。
- 官方测试板：ESP32-C6-DEVKITM-1。
- 接线和使用方式见该目录 README.md。

## nRF52 DK 接线

| 信号 | nRF52 DK | Pro 主板 |
|---|---|---|
| SPI_SS | P0.04 | X3.4 |
| SPI_CLK | P0.29 | X3.3 |
| SPI_MISO | P0.30 | X3.1 |
| SPI_MOSI | P0.31 | X3.2 |
| Data_ready | P0.24 | X4.2 |
| BLE_conn_ready | P0.25 | X4.3 |

ESP32-C6 的对应接线以 02_firmware/esp32/README.md 为准。

## GUI 最短流程

在 03_host_software/sw 中执行：

    conda env create -f requirements.yml
    conda activate wulpus_env
    jupyter notebook

然后打开 wulpus_pro_gui.ipynb。Wi-Fi 路线使用 wulpus.wifi.WulpusWiFi，示例见 ESP32 README。

## 上电顺序和安全

nRF52 路线按官方 README：

1. 先插 USB Dongle，并给 nRF52 DK 供电。
2. 确认 Dongle 连接指示正常；失败时先复位 DK。
3. 连接建立后才给 WULPUS Pro 主板上电。
4. 第一次主板上电使用限流电源和假负载，先确认短路、静态电流和高压节点。

系统涉及约 30 V 激励/偏置。调试前断电并确认储能电容已放电；未经电气、热、机械和生物安全验证，不得直接用于人体。
