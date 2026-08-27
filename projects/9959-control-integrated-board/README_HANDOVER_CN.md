# 9959 Control Integrated Board 交接包

## 内容

- `source/9959 Control Integrated Board.eprj2`：当前 EasyEDA 项目的完整源容器。该 SQLite 项目文件内含项目结构、Board1、PCB 关联、SC00 到 SC12 原理图页、历史记录及项目图片。
- `outputs/20260823_bom_missing_parts/`：当前工作区生成的 BOM 缺料审计及相关 CSV、XLSX、图片和检查结果。
- `reference/current_project_view.png`：本次交接时项目视图截图，用于快速确认项目身份和页签结构。
- `MANIFEST_SHA256.txt`：交接包内文件的相对路径、字节数与 SHA-256 校验值。

## 打开方式

1. 解压本 ZIP。
2. 在 EasyEDA 中打开 `source/9959 Control Integrated Board.eprj2`，或将该文件复制到本机 EasyEDA 项目目录后从项目管理器打开。
3. 打开后应能看到 `Board1`、`PCB1` 以及 `SC00_SYSTEM_OVERVIEW` 至 `SC12_DFT_QC` 的原理图页。

## 打包信息

- 打包日期：2026-08-23
- 源文件原始路径（公开版已脱敏）：`<local-easyeda-project>/9959 Control Integrated Board.eprj2`
- 源文件格式：EasyEDA SQLite project container (`.eprj2`)
- 源文件在打包时的磁盘时间：见 `MANIFEST_SHA256.txt`

## 范围说明

本包覆盖当前截图对应的 9959 项目本身及当前输出物。工作区中的 `pcb_reverse_engineering`、`wulpus`、`wulpus_pro`、`tmp`、`wulpus_reproduction_package` 和便携工具目录属于其他项目、历史分析或运行环境，未混入本项目交接包。

如果 EasyEDA 在打包前存在尚未保存的修改，这些修改不会出现在磁盘上的 `.eprj2` 文件中；打开项目后请以 EasyEDA 中显示的最新版本为准，并在继续编辑前另存一份备份。
