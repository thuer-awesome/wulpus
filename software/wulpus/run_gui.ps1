param(
    [string]$Notebook = "wulpus_gui.ipynb"
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot
& jupyter notebook $Notebook
exit $LASTEXITCODE
