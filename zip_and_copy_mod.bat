@echo off
@REM powershell -executionpolicy bypass -File .\zip_and_copy_mod.ps1
lua52 .\zip_and_copy_mod.lua %~dp0 %*
@REM pause