param(
    [ValidateSet("wulpus_pro_gui.ipynb", "wulpus_pro_gui_tgc.ipynb", "wulpus_pro_cmuts_gui.ipynb")]
    [string]$Notebook = "wulpus_pro_gui.ipynb"
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot
& jupyter notebook $Notebook
exit $LASTEXITCODE
