@echo off
setlocal
for %%I in ("%~dp0..\..") do set "ROOT=%%~fI"
set "TYPST=%ROOT%\pcb_reverse_engineering\tools\typst_portable\app\typst-x86_64-pc-windows-msvc\typst.exe"
set "SOURCE=%ROOT%\pcb_reverse_engineering\report\portable_ultrasound_three_system_study_cn.typ"
set "OUTPUT=%ROOT%\pcb_reverse_engineering\output\pdf\Portable_Ultrasound_Three_System_Study_CN.pdf"

if not exist "%TYPST%" (
  echo Typst executable not found: %TYPST%
  exit /b 1
)

"%TYPST%" compile --root "%ROOT%" --font-path "%WINDIR%\Fonts" "%SOURCE%" "%OUTPUT%"
exit /b %ERRORLEVEL%
