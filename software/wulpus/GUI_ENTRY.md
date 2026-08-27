# WULPUS v1 GUI entry

## Official debug files

- Notebook: [`wulpus_gui.ipynb`](wulpus_gui.ipynb)
- GUI implementation: [`wulpus/gui.py`](wulpus/gui.py)
- Configuration panels: [`wulpus/rx_tx_conf_gui.py`](wulpus/rx_tx_conf_gui.py)
  and [`wulpus/uss_conf_gui.py`](wulpus/uss_conf_gui.py)
- Example configuration/data: [`examples`](examples)
- Windows launcher: [`run_gui.ps1`](run_gui.ps1)

## Launch

Use Python 3.9 and the pinned environment in
[`requirements_clean.yml`](requirements_clean.yml):

```powershell
conda env create -f requirements_clean.yml
conda activate wulpus_env
cd software/wulpus
jupyter notebook wulpus_gui.ipynb
```

On Windows the same entry can be started from this directory with
`./run_gui.ps1`.

Run Jupyter from this directory so the notebook's relative `examples/` paths
resolve. Execute the notebook's cells in order; its final GUI cell constructs
`WulpusGuiSingleCh` from the official `wulpus` package.

## Hardware check before acquisition

The notebook can be opened and its plotting/configuration cells can be tested
without a board. Before opening a serial port, verify the v1 Acquisition PCB,
HV PCB, programmer connection, current-limited supply, dummy load, and HV
discharge procedure described in the board manufacturing README. Do not attach
a transducer during the first power-up.
