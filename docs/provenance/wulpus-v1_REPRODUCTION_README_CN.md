# WULPUS 复刻最简说明

本目录已经按复刻用途整理好官方 `pulp-bio/wulpus` 仓库文件。官方仓库快照见 `SOURCE_INFO.txt`，详细装配和排障请看 `04_docs/docs/wulpus_user_manual.pdf`。

## 1. 先看这些目录

- `01_pcb/fab_order_zips/`
  - 直接给 PCB 厂或贴片厂的下单包。
  - `acquisition_pcb_fab_order.zip`: WULPUS 采集板。
  - `hv_pcb_fab_order.zip`: WULPUS 高压 HV MUX 板。
  - `msp430_programmer_pcb_fab_order.zip`: MSP430 编程转接板。
  - `nrf52_programmer_pcb_fab_order.zip`: nRF52 编程转接板。
- `01_pcb/main_boards_altium_sources/`
  - 采集板和高压板的完整 Altium 源工程，包含 `.PrjPcb`、`.PcbDoc`、`.SchDoc`、库、规则、BOM、Gerber、钻孔和装配资料。
- `01_pcb/wulpus_programmer_pcbs/`
  - 两块编程转接板的 BOM、装配图和生产文件。
- `01_pcb/wulpus_silicone_package/`
  - 硅胶外壳模具 STL。FDM 用 `*_fdm.stl`，树脂/SLA 用 `*_resin.stl`，硅胶盖用 `wulpus_silicone_cap_mold.stl`。
- `02_firmware/`
  - PCB 上要烧录的固件源码和官方烧录说明。
- `03_host_software/sw/`
  - 电脑端 Python GUI、Jupyter notebook、示例配置和 Conda 环境文件。
- `04_docs/docs/`
  - 用户手册、照片和系统图。

## 2. PCB 下单最短流程

1. 主设备需要两块 PCB：
   - Acquisition PCB: `01_pcb/fab_order_zips/acquisition_pcb_fab_order.zip`
   - High-Voltage PCB: `01_pcb/fab_order_zips/hv_pcb_fab_order.zip`
2. 如果你没有现成调试线，也一起做两块编程转接板：
   - `01_pcb/fab_order_zips/msp430_programmer_pcb_fab_order.zip`
   - `01_pcb/fab_order_zips/nrf52_programmer_pcb_fab_order.zip`
3. 下单时把对应 zip 直接发给 PCB 厂或 PCBA 厂。每个 zip 内含 Gerber、NC Drill、Pick Place、stackup、BOM 和 assembly drawing；两块主板还带 schematics PDF。
4. 如果工厂要求改格式或确认层叠，打开对应 Altium 源工程：
   - `01_pcb/main_boards_altium_sources/wulpus_acquisition_pcb/wulpus_acq_pcb.PrjPcb`
   - `01_pcb/main_boards_altium_sources/wulpus_hv_pcb/wulpus_hv_mux.PrjPcb`

## 3. PCB 需要烧录的程序

WULPUS 复刻后需要烧三份固件：

1. 采集板 MSP430FR5043 超声 MCU
   - 源码目录: `02_firmware/msp430/wulpus_msp430_firmware`
   - 官方步骤: `02_firmware/msp430/how_to_setup_msp_430_toolchain_and_flash.md`
   - 工具: TI Code Composer Studio 11.0.0.00012，MSP-FET，MSP430 支持包。
2. 采集板 nRF52832 BLE MCU
   - 源码目录: `02_firmware/nrf52/ble_peripheral/US_probe_nRF52_firmware`
   - 官方步骤: `02_firmware/nrf52/how_to_setup_nRF52_toolchain.md` 和 `02_firmware/nrf52/how_to_flash_nrf52832.md`
   - 工具: SEGGER Embedded Studio for ARM 5.62，J-Link 7.56a，nRF Command Line Tools 10.14.0，Nordic nRF5 SDK 17.1.0。
3. USB dongle nRF52840
   - 源码目录: `02_firmware/nrf52/peripheral/US_probe_dongle_firmware`
   - 官方步骤: `02_firmware/nrf52/how_to_setup_nRF52_toolchain.md` 和 `02_firmware/nrf52/how_to_flash_nrf52840_dongle.md`
   - 工具: SEGGER Embedded Studio，nRF Connect for Desktop Programmer，Nordic nRF5 SDK 17.1.0，SoftDevice S140 7.2.0。

注意：官方 README 里有些 nRF52 路径写成了 `hw/nRF52`，本整理包里的实际路径是 `02_firmware/nrf52`。

## 4. 烧录顺序

1. 先确认 PCBA 无短路，供电电流正常，电池/USB 供电跳线位置正确。
2. 用 MSP-FET 通过 8-pin Molex 接口烧录 MSP430FR5043。
3. 用 J-Link 通过 6-pin Molex 接口烧录采集板 nRF52832。
4. 将 nRF52840 USB dongle 进 DFU 模式，用 nRF Connect Programmer 写入应用 hex 和 SoftDevice S140 hex。
5. 断电重启采集板和 dongle，再用电脑端 GUI 连接测试。

## 5. 电脑端 GUI 最短流程

1. 安装 Miniconda 或 Anaconda。
2. 打开终端，进入 `03_host_software/sw`。
3. 创建环境：

```powershell
conda env create -f requirements.yml
```

4. 启动 notebook：

```powershell
conda activate wulpus_env
jupyter notebook
```

5. 在浏览器中打开 `wulpus_gui.ipynb`，按 notebook 里的步骤连接 USB dongle 和采集数据。

## 6. 复刻提醒

- 这是超声高压发射相关硬件，第一次上电请用限流电源，先做空载和假负载验证，不要直接用于人体。
- 两块主板的完整制造和装配说明在用户手册第 2 章，使用方法在第 3 章。
- 固件依赖 Nordic SDK 和 TI/SEGGER 工具链，仓库里包含项目源码，但不包含这些厂家工具和 SDK 安装包。
