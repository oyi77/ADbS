@echo off
REM CMD wrapper for installer
REM Detects PowerShell and uses it, otherwise falls back to bash

set SCRIPT_DIR=%~dp0

REM Try PowerShell first
where powershell >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" %*
    exit /b %ERRORLEVEL%
)

REM Fallback to bash (Git Bash/WSL)
where bash >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    bash "%SCRIPT_DIR%install.sh" %*
    exit /b %ERRORLEVEL%
)

echo Error: Neither PowerShell nor bash found. Please install one of them.
exit /b 1

