@echo off
REM ADbS - Short alias for workflow-enforcer (CMD)

set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%workflow-enforcer.bat" %*

