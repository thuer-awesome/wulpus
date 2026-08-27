# WULPUS PRO GUI entry

## Official debug files

- General serial workflow: [`wulpus_pro_gui.ipynb`](wulpus_pro_gui.ipynb)
- TGC experiment workflow: [`wulpus_pro_gui_tgc.ipynb`](wulpus_pro_gui_tgc.ipynb)
- polyCMUT/Wi-Fi workflow: [`wulpus_pro_cmuts_gui.ipynb`](wulpus_pro_cmuts_gui.ipynb)
- GUI implementation: [`wulpus/gui.py`](wulpus/gui.py)
- Configuration panels: [`wulpus/rx_tx_conf_gui.py`](wulpus/rx_tx_conf_gui.py),
  [`wulpus/uss_conf_gui_pro.py`](wulpus/uss_conf_gui_pro.py), and
  [`wulpus/uss_conf_gui.py`](wulpus/uss_conf_gui.py)
- Example configuration/data: [`examples`](examples)
- Windows launcher: [`run_gui.ps1`](run_gui.ps1)

## Launch

Use Python 3.9 and the pinned environment in
[`requirements.yml`](requirements.yml):

```powershell
conda env create -f requirements.yml
conda activate wulpus_pro_env
cd software/wulpus-pro
jupyter notebook wulpus_pro_gui.ipynb
```

On Windows the launcher accepts any of the three official notebook names, for
example `./run_gui.ps1 wulpus_pro_gui_tgc.ipynb`.

Open the TGC or polyCMUT notebook when that is the intended experiment. The
polyCMUT notebook creates the official `WulpusWiFi` connection and expects the
PRO firmware/network configuration; the other two notebooks use the serial
`WulpusDongle` path. Run Jupyter from this directory so relative example files
and the PRO `wulpus.log` output behave as documented upstream.

## Hardware check before acquisition

Read the PRO acquisition-board errata and assembly README before powering the
board. Use a current-limited supply and dummy load, verify the 3V3/5V/15V/HV
rails and connector orientation, and confirm the HV discharge procedure. The
notebooks' import/configuration cells are safe for a host-only smoke test; a
serial or Wi-Fi acquisition requires the programmed board and matching firmware.
