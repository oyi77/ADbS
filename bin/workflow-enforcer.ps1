# Main CLI tool for workflow enforcement - PowerShell version

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

$WORKFLOW_ENFORCER_DIR = if ($env:WORKFLOW_ENFORCER_DIR) { $env:WORKFLOW_ENFORCER_DIR } else { ".workflow-enforcer" }
$VALIDATOR = Join-Path $PROJECT_ROOT "lib\validator\workflow.ps1"
$TASK_MANAGER = Join-Path $PROJECT_ROOT "lib\task_manager\simple.ps1"
$PLATFORM_DETECTOR = Join-Path $PROJECT_ROOT "lib\platform_detector.ps1"
$OPENSPEC = Join-Path $PROJECT_ROOT "lib\openspec.ps1"

$command = $args[0]

switch ($command) {
    "status" {
        & $VALIDATOR status
    }
    "validate" {
        & $VALIDATOR validate
    }
    "next" {
        & $VALIDATOR next
    }
    "current" {
        & $VALIDATOR current
    }
    "set" {
        & $VALIDATOR set $args[1..($args.Length-1)]
    }
    "task" {
        & $TASK_MANAGER $args[1..($args.Length-1)]
    }
    "platform" {
        $subCommand = $args[1]
        switch ($subCommand) {
            "detect" { & $PLATFORM_DETECTOR detect }
            "detect-all" { & $PLATFORM_DETECTOR detect-all }
            "rules-dir" { & $PLATFORM_DETECTOR rules-dir $args[2] }
            "rules-dirs" { & $PLATFORM_DETECTOR rules-dirs }
            "rules-file" { & $PLATFORM_DETECTOR rules-file }
            default {
                Write-Host "Usage: adbs platform {detect|detect-all|rules-dir|rules-dirs|rules-file}"
                Write-Host "       (or: workflow-enforcer platform ...)"
                exit 1
            }
        }
    }
    "openspec" {
        & $OPENSPEC $args[1..($args.Length-1)]
    }
    "propose" {
        & $OPENSPEC "propose" $args[1..($args.Length-1)]
    }
    "archive" {
        & $OPENSPEC "archive" $args[1..($args.Length-1)]
    }
    "specs" {
        & $OPENSPEC "specs" $args[1..($args.Length-1)]
    }
    "init" {
        if (-not (Test-Path "$WORKFLOW_ENFORCER_DIR")) {
            New-Item -ItemType Directory -Path $WORKFLOW_ENFORCER_DIR -Force | Out-Null
        }
        if (-not (Test-Path ".sdd\plans")) {
            New-Item -ItemType Directory -Path ".sdd\plans" -Force | Out-Null
        }
        if (-not (Test-Path ".sdd\requirements")) {
            New-Item -ItemType Directory -Path ".sdd\requirements" -Force | Out-Null
        }
        if (-not (Test-Path ".sdd\designs")) {
            New-Item -ItemType Directory -Path ".sdd\designs" -Force | Out-Null
        }
        if (-not (Test-Path ".sdd\tasks")) {
            New-Item -ItemType Directory -Path ".sdd\tasks" -Force | Out-Null
        }
        if (-not (Test-Path "$WORKFLOW_ENFORCER_DIR\current-stage")) {
            "explore" | Set-Content "$WORKFLOW_ENFORCER_DIR\current-stage"
            Write-Host "Initialized workflow - starting at 'explore' stage"
        } else {
            Write-Host "Workflow already initialized"
            & $VALIDATOR status
        }
    }
    { $_ -in @("help", "--help", "-h") } {
        Write-Host @"
ADbS - Ai Dont be Stupid, please!

Usage: workflow-enforcer <command> [args]
(or use 'adbs' as a shorter alias)

Commands:
  status              Show current workflow status
  validate            Validate current stage
  next                Advance to next stage (if validated)
  current             Get current stage name
  set <stage>         Set stage manually (use with caution)
  
  task <cmd>          Task management commands
    create <desc>     Create a new task
    list              List all tasks
    update <id>       Update a task
    get <id>          Get task details
    delete <id>       Delete a task
    export [file]     Export tasks to JSON
    import [file]     Import tasks from JSON
  
  platform <cmd>     Platform detection
    detect            Detect current IDE/platform
    rules-dir         Get rules directory for platform
    rules-file        Get rules filename
  
  init                Initialize workflow in current directory
  
  # OpenSpec Workflow
  propose <name>      Create a new change proposal
  archive <id>        Archive a completed change
  specs               List system specifications

  openspec            Advanced OpenSpec commands (init, list)
  help                Show this help message

Examples:
  adbs init
  adbs status
  adbs validate
  adbs next
  adbs task create "Implement feature X" --priority high
  adbs task list

Note: 'adbs' is a shorter alias for 'workflow-enforcer'

For more information, see README.md
"@
    }
    default {
        Write-Host "Unknown command: $command"
        Write-Host "Run 'adbs help' or 'workflow-enforcer help' for usage information"
        exit 1
    }
}

