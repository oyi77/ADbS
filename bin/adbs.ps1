# ADbS - Short alias for workflow-enforcer (PowerShell)

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$SCRIPT_DIR\workflow-enforcer.ps1" $args

