@echo off
REM CMD wrapper for workflow-enforcer
REM Detects PowerShell and uses it, otherwise falls back to bash

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..

REM Try PowerShell first
where powershell >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%workflow-enforcer.ps1" %*
    exit /b %ERRORLEVEL%
)

REM Fallback to bash (Git Bash/WSL)
where bash >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    bash "%SCRIPT_DIR%..\bin\workflow-enforcer" %*
    exit /b %ERRORLEVEL%
)

echo Error: Neither PowerShell nor bash found. Please install one of them.
exit /b 1

