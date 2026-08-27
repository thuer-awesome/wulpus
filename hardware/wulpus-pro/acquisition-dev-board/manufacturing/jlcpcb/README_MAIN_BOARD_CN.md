# WULPUS Pro 采集开发板 - 嘉立创下单说明

## 直接使用的文件

- PCB 裸板上传：01_PCB_Gerber_Drill/wulpus_pro_acquisition_dev_board_gerber_drill_jlcpcb.zip
- 嘉立创贴片 BOM：02_PCBA_BOM_CPL/BOM_JLCPCB.csv
- 嘉立创贴片坐标：02_PCBA_BOM_CPL/CPL_JLCPCB.csv
- 全器件逐位号核对：02_PCBA_BOM_CPL/COMPONENT_CHECKLIST.csv
- 官方装配图：02_PCBA_BOM_CPL/wulpus_pro_acq_pcb_assembly.PDF
- 官方问题清单：03_Reference/ERRATA.MD
- 中文处理说明：03_Reference/ERRATA_ACTIONS_CN.md
- 嘉立创官方设计层叠：03_Reference/wulpus_pro_acq_jlcpcb_JLC061011_2116A.stackup

## 嘉立创 PCB 参数

| 参数 | 严格设置 |
|---|---|
| 板层 | 6 层 |
| 板厚 | 嘉立创订单标称 1.0 mm；官方装配图层叠总厚标为约 0.95 mm |
| 层叠 | JLC061011_2116A；把 stackup 文件交给工程确认 |
| 铜厚 | 源层叠为外层约 1 oz、内层约 1 oz；以指定层叠为准 |
| 阻抗 | Yes，单端 50 ohm，公差 10% |
| 阻抗线宽 | 外层 0.208 mm；内层 L3/L4 0.152 mm；不得单独改 Gerber 线宽 |
| 表面处理 | 推荐 ENIG 沉金，适合 0.4 mm 连接器和细间距器件；这是工艺建议，不是仓库中的强制字段 |
| 阻焊/字符 | 建议绿色/白色；颜色不影响电气设计 |
| 盲埋孔/HDI | No；官方钻孔是 Top-Bottom 通孔文件 |
| 金手指/半孔/边镀 | No |
| 钻孔 | 单一 wulpus_pro_acq.TXT 同时含 PTH 和 NPTH，不得漏掉其中任一类 |

阻抗层叠中的标称配置为 S50、50 ohm +/-10%。源文件计算值约 46.39 至 46.86 ohm，仍在 10% 公差范围内。应让嘉立创按同一层叠做工程补偿，不要自行改 Gerber。下单页面选 1.0 mm 是工厂标称板厚，官方装配图的具体介质和铜层相加显示约 0.95 mm，两者不是互相矛盾的两个订单选项。

机械层闭合外轮廓约 79.30 x 38.00 mm；机械层中的长槽/开槽区域数据总体延伸约 81.05 x 38.00 mm。下单尺寸以嘉立创 Gerber 预览自动识别和工程 CAM 复核为准，不手工覆盖尺寸；重点检查所有长槽、凹口和 4 个 M2 安装孔。

## PCBA 参数

- 官方生产变体：pzt_hia_no_bias。
- BOM 来源：BOM_clean.xlsx。它修正了原始 variant BOM 中几行 Name/Description 颠倒的问题；两个官方文件均保留在目录中。
- 双面 SMT：共 157 个贴装位号，Top 72 个，Bottom 85 个。
- 手焊 PTH：X1、X3、X4 为 6Pin 2.54 mm 排针；X5、X6、X7、X8 为 2Pin 2.54 mm 排针，共 7 个，未放入嘉立创 BOM/CPL。
- 坐标由官方 mil 乘 0.0254 转成 mm，原点和负坐标保持不变。若系统拒绝负坐标，不可只平移 CPL；让 CAM 同时对 Gerber 和坐标设置同一原点。
- 29 个坐标对象不在官方 BOM：A1、M1-M4、J7/J8/J9/J13、TP1-TP20。它们是 Logo、安装孔、焊桥或测试焊盘，不采购、不贴元件。详见 PLACEMENT_EXCLUSIONS.csv。

## 元件自动匹配

- 优先按 Manufacturer Part Number 1 匹配；该字段为空时才回退到 Name。
- Source_Name、Source_MPN1 和最终 Preferred_MPN 都保存在 COMPONENT_CHECKLIST.csv，必须逐项核对。
- MCU、HV2707、放大器、升压芯片、晶振、U.FL、DF40/DF52、PJ1 等禁止未经工程确认替代。
- J1/J2 和 PJ1 的方向、面别、Pin 1 必须对装配图；J4/J6/PJ1/J12 是 Bottom。

## 下单前停止条件

没有完成 03_Reference/ERRATA_ACTIONS_CN.md 的六项评审，不应直接批量生产。尤其是 U16 输入电容、C12 缺失、R23/RGND workaround、PJ1 镜像和 J1/J2 高度。

该提交没有随主板发布独立 DRC 报告；本包没有伪造一份。Gerber 下单后仍需通过嘉立创 CAM/DFM，并由设计方复查阻抗、开槽、阻焊、孔径和细间距焊盘。
