# Simple JSON-based task manager - PowerShell version
# Alternative to Beads when Go dependency is not available

$TASKS_FILE = if ($env:WORKFLOW_ENFORCER_DIR) { 
    Join-Path $env:WORKFLOW_ENFORCER_DIR "tasks.json"
} else { 
    Join-Path ".workflow-enforcer" "tasks.json"
}

function Initialize-Tasks {
    if (-not (Test-Path $TASKS_FILE)) {
        $data = @{
            tasks = @()
            next_id = 1
        }
        $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
    }
}

function Generate-Id {
    $chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    $random = -join ((1..6) | ForEach-Object { Get-Random -Maximum $chars.Length | ForEach-Object { $chars[$_] } })
    return $random
}

function Generate-HierarchicalId {
    param(
        [string]$Parent
    )
    
    if (-not $Parent) {
        return "task-$(Generate-Id)"
    }
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    $childCount = ($data.tasks | Where-Object { $_.parent -eq $Parent }).Count
    return "$Parent.$($childCount + 1)"
}

function New-Task {
    param(
        [string]$Description,
        [string]$Priority = "medium",
        [string]$Parent = "",
        [string]$DependsOn = "",
        [string]$Tags = ""
    )
    
    Initialize-Tasks
    $id = Generate-HierarchicalId -Parent $Parent
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $tagsArray = if ($Tags) {
        $Tags.Split(",") | ForEach-Object { $_.Trim() }
    } else {
        @()
    }
    
    $dependsArray = if ($DependsOn) {
        $DependsOn.Split(",") | ForEach-Object { $_.Trim() }
    } else {
        @()
    }
    
    $task = @{
        id = $id
        description = $Description
        status = "todo"
        priority = $Priority
        parent = if ($Parent) { $Parent } else { $null }
        depends_on = $dependsArray
        tags = $tagsArray
        comments = @()
        created_at = $timestamp
        updated_at = $timestamp
    }
    
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    $data.tasks += $task
    $data.next_id += 1
    $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
    
    return $id
}

function Update-Task {
    param(
        [string]$Id,
        [string]$Field,
        [string]$Value
    )
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    
    $task = $data.tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1
    if (-not $task) {
        Write-Host "Error: Task not found: $Id"
        return
    }
    
    if ($Field -in @("tags", "depends_on")) {
        $task.$Field = $Value.Split(",") | ForEach-Object { $_.Trim() }
    } else {
        $task.$Field = $Value
    }
    
    $task.updated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
}

function Add-Comment {
    param(
        [string]$Id,
        [string]$Comment
    )
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    
    $task = $data.tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1
    if (-not $task) {
        Write-Host "Error: Task not found: $Id"
        return
    }
    
    if (-not $task.comments) {
        $task.comments = @()
    }
    
    $task.comments += @{
        text = $Comment
        created_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    $task.updated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
}

function Add-Tag {
    param(
        [string]$Id,
        [string]$Tag
    )
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    
    $task = $data.tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1
    if (-not $task) {
        Write-Host "Error: Task not found: $Id"
        return
    }
    
    if (-not $task.tags) {
        $task.tags = @()
    }
    
    if ($Tag -notin $task.tags) {
        $task.tags += $Tag
    }
    
    $task.updated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
}

function Search-Tasks {
    param(
        [string]$Status = "",
        [string]$Priority = "",
        [string]$Tag = "",
        [string]$Description = ""
    )
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    
    $filtered = $data.tasks | Where-Object {
        ($Status -eq "" -or $_.status -eq $Status) -and
        ($Priority -eq "" -or $_.priority -eq $Priority) -and
        ($Tag -eq "" -or $Tag -in $_.tags) -and
        ($Description -eq "" -or $_.description -match [regex]::Escape($Description))
    }
    
    $filtered | ConvertTo-Json -Depth 10
}

function Get-Task {
    param([string]$Id)
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    $task = $data.tasks | Where-Object { $_.id -eq $Id } | Select-Object -First 1
    
    if ($task) {
        $task | ConvertTo-Json -Depth 10
    } else {
        Write-Host "Error: Task not found: $Id"
        exit 1
    }
}

function Remove-Task {
    param([string]$Id)
    
    Initialize-Tasks
    $data = Get-Content $TASKS_FILE | ConvertFrom-Json
    $data.tasks = $data.tasks | Where-Object { $_.id -ne $Id }
    $data | ConvertTo-Json -Depth 10 | Set-Content $TASKS_FILE
}

function Export-Tasks {
    param([string]$OutputFile = "tasks_export.json")
    
    Initialize-Tasks
    Copy-Item $TASKS_FILE $OutputFile
    Write-Host "Tasks exported to $OutputFile"
}

function Import-Tasks {
    param([string]$InputFile = "tasks_export.json")
    
    if (Test-Path $InputFile) {
        Copy-Item $InputFile $TASKS_FILE
        Write-Host "Tasks imported from $InputFile"
    } else {
        Write-Host "Error: File $InputFile not found"
        exit 1
    }
}

# Main command handler
$command = $args[0]

switch ($command) {
    "create" {
        $id = New-Task -Description $args[1] -Priority $args[2] -Parent $args[3] -DependsOn $args[4] -Tags $args[5]
        Write-Output $id
    }
    "update" {
        Update-Task -Id $args[1] -Field $args[2] -Value $args[3]
    }
    "list" {
        Search-Tasks -Status $args[1] -Priority $args[2] -Tag $args[3] -Description $args[4]
    }
    "search" {
        Search-Tasks -Status $args[1] -Priority $args[2] -Tag $args[3] -Description $args[4]
    }
    "get" {
        Get-Task -Id $args[1]
    }
    "delete" {
        Remove-Task -Id $args[1]
    }
    "comment" {
        Add-Comment -Id $args[1] -Comment $args[2]
    }
    "tag" {
        Add-Tag -Id $args[1] -Tag $args[2]
    }
    "export" {
        Export-Tasks -OutputFile $args[1]
    }
    "import" {
        Import-Tasks -InputFile $args[1]
    }
    default {
        Write-Host "Usage: $($MyInvocation.MyCommand.Name) {create|update|list|get|delete|export|import|comment|tag|search} [args]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  create <desc> [priority] [parent] [depends_on] [tags]  - Create a new task"
        Write-Host "  update <id> <field> <value>                            - Update a task field"
        Write-Host "  list [status] [priority] [tag] [desc]                 - List tasks (optionally filtered)"
        Write-Host "  search [status] [priority] [tag] [desc]                - Search tasks"
        Write-Host "  get <id>                                               - Get task by ID"
        Write-Host "  delete <id>                                            - Delete a task"
        Write-Host "  comment <id> <comment>                                 - Add comment to task"
        Write-Host "  tag <id> <tag>                                         - Add tag to task"
        Write-Host "  export [file]                                          - Export tasks to JSON"
        Write-Host "  import [file]                                          - Import tasks from JSON"
        exit 1
    }
}

