# Workflow validator - PowerShell version
# Enforces stage completion and SDD requirements

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

$SDD_DIR = if ($env:SDD_DIR) { $env:SDD_DIR } else { ".sdd" }
$WORKFLOW_DIR = if ($env:WORKFLOW_ENFORCER_DIR) { $env:WORKFLOW_ENFORCER_DIR } else { ".workflow-enforcer" }
$CURRENT_STAGE_FILE = Join-Path $WORKFLOW_DIR "current-stage"
$PLANS_DIR = Join-Path $SDD_DIR "plans"
$REQUIREMENTS_DIR = Join-Path $SDD_DIR "requirements"
$DESIGNS_DIR = Join-Path $SDD_DIR "designs"
$TASKS_DIR = Join-Path $SDD_DIR "tasks"
$PLAN_MANAGER = Join-Path $PROJECT_ROOT "lib\plan_manager.ps1"

function Initialize-Workflow {
    if (-not (Test-Path $PLANS_DIR)) { New-Item -ItemType Directory -Path $PLANS_DIR -Force | Out-Null }
    if (-not (Test-Path $REQUIREMENTS_DIR)) { New-Item -ItemType Directory -Path $REQUIREMENTS_DIR -Force | Out-Null }
    if (-not (Test-Path $DESIGNS_DIR)) { New-Item -ItemType Directory -Path $DESIGNS_DIR -Force | Out-Null }
    if (-not (Test-Path $TASKS_DIR)) { New-Item -ItemType Directory -Path $TASKS_DIR -Force | Out-Null }
    if (-not (Test-Path $WORKFLOW_DIR)) { New-Item -ItemType Directory -Path $WORKFLOW_DIR -Force | Out-Null }
    
    if (-not (Test-Path $CURRENT_STAGE_FILE)) {
        "explore" | Set-Content $CURRENT_STAGE_FILE
    }
    
    if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER generate | Out-Null
    }
}

function Get-CurrentStage {
    if (Test-Path $CURRENT_STAGE_FILE) {
        return Get-Content $CURRENT_STAGE_FILE -Raw | ForEach-Object { $_.Trim() }
    }
    return "explore"
}

function Set-CurrentStage {
    param([string]$Stage)
    
    if (-not (Test-Path $WORKFLOW_DIR)) {
        New-Item -ItemType Directory -Path $WORKFLOW_DIR -Force | Out-Null
    }
    $Stage | Set-Content $CURRENT_STAGE_FILE
}

function Test-FileMinLength {
    param(
        [string]$FilePath,
        [int]$MinLength
    )
    
    if (-not (Test-Path $FilePath)) {
        return $false
    }
    
    $content = Get-Content $FilePath -Raw
    $wordCount = ($content -split '\s+' | Where-Object { $_.Length -gt 0 }).Count
    return $wordCount -ge $MinLength
}

function Test-FileContains {
    param(
        [string]$FilePath,
        [string[]]$RequiredStrings
    )
    
    if (-not (Test-Path $FilePath)) {
        return $false
    }
    
    $content = Get-Content $FilePath -Raw
    foreach ($str in $RequiredStrings) {
        if ($content -notmatch $str) {
            return $false
        }
    }
    return $true
}

function Test-PlanStage {
    $planFiles = Get-ChildItem -Path $PLANS_DIR -Filter "*.md" -ErrorAction SilentlyContinue
    if ($planFiles.Count -eq 0) {
        Write-Host "Error: No plan document found in $PLANS_DIR"
        return $false
    }
    
    $currentPlanId = if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER current
    }
    
    if ($currentPlanId) {
        $planFile = Join-Path $PLANS_DIR "$currentPlanId.md"
        if (Test-Path $planFile) {
            if (-not (Test-FileMinLength -FilePath $planFile -MinLength 200)) {
                Write-Host "Error: Plan document too short (minimum 200 words)"
                return $false
            }
        }
    }
    
    Write-Host "Plan stage validated"
    return $true
}

function Test-RequirementsStage {
    $currentPlanId = if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER current
    }
    
    $reqFile = if ($currentPlanId) {
        Join-Path $REQUIREMENTS_DIR "requirements.$currentPlanId.md"
    } else {
        Get-ChildItem -Path $REQUIREMENTS_DIR -Filter "requirements.plan-*.md" -ErrorAction SilentlyContinue | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    
    if (-not $reqFile -or -not (Test-Path $reqFile)) {
        Write-Host "Error: Requirements document not found for current plan"
        return $false
    }
    
    if (-not (Test-FileMinLength -FilePath $reqFile -MinLength 500)) {
        Write-Host "Error: Requirements document too short (minimum 500 words)"
        return $false
    }
    
    $requiredSections = @("functional", "non.functional", "requirement")
    if (-not (Test-FileContains -FilePath $reqFile -RequiredStrings $requiredSections)) {
        Write-Host "Error: Requirements document missing required sections"
        return $false
    }
    
    Write-Host "Requirements stage validated"
    return $true
}

function Test-DesignStage {
    $currentPlanId = if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER current
    }
    
    $designFile = if ($currentPlanId) {
        Join-Path $DESIGNS_DIR "design.$currentPlanId.md"
    } else {
        Get-ChildItem -Path $DESIGNS_DIR -Filter "design.plan-*.md" -ErrorAction SilentlyContinue | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    
    if (-not $designFile -or -not (Test-Path $designFile)) {
        Write-Host "Error: Design document not found for current plan"
        return $false
    }
    
    if (-not (Test-FileMinLength -FilePath $designFile -MinLength 500)) {
        Write-Host "Error: Design document too short (minimum 500 words)"
        return $false
    }
    
    $requiredSections = @("architecture", "component", "data.flow")
    if (-not (Test-FileContains -FilePath $designFile -RequiredStrings $requiredSections)) {
        Write-Host "Error: Design document missing required sections"
        return $false
    }
    
    Write-Host "Design stage validated"
    return $true
}

function Test-TasksStage {
    $currentPlanId = if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER current
    }
    
    $tasksFile = if ($currentPlanId) {
        Join-Path $TASKS_DIR "tasks.$currentPlanId.md"
    } else {
        Get-ChildItem -Path $TASKS_DIR -Filter "tasks.plan-*.md" -ErrorAction SilentlyContinue | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    
    if (-not $tasksFile -or -not (Test-Path $tasksFile)) {
        Write-Host "Error: Tasks document not found for current plan"
        return $false
    }
    
    $content = Get-Content $tasksFile -Raw
    $taskCount = ([regex]::Matches($content, '^### Task \d+:')).Count
    
    if ($taskCount -lt 3) {
        Write-Host "Error: Tasks document must contain at least 3 tasks (found $taskCount)"
        return $false
    }
    
    if ($content -notmatch "task") {
        Write-Host "Error: Tasks document missing task list"
        return $false
    }
    
    Write-Host "Tasks stage validated ($taskCount tasks found)"
    return $true
}

function Test-AssignStage {
    $tasksJson = Join-Path $WORKFLOW_DIR "tasks.json"
    
    if (-not (Test-Path $tasksJson)) {
        Write-Host "Error: Task manager not initialized. Create at least one task."
        return $false
    }
    
    $tasks = Get-Content $tasksJson | ConvertFrom-Json
    if ($tasks.tasks.Count -lt 1) {
        Write-Host "Error: At least one task must be created in task manager"
        return $false
    }
    
    Write-Host "Assign stage validated"
    return $true
}

function Test-CurrentStage {
    Initialize-Workflow
    $currentStage = Get-CurrentStage
    
    switch ($currentStage) {
        "explore" { return $true }  # Explore always passes
        "plan" { return Test-PlanStage }
        "requirements" { return Test-RequirementsStage }
        "design" { return Test-DesignStage }
        "tasks" { return Test-TasksStage }
        "assign" { return Test-AssignStage }
        "execution" { 
            Write-Host "Execution stage - validation always passes (work in progress)"
            return $true
        }
        default {
            Write-Host "Error: Unknown stage: $currentStage"
            return $false
        }
    }
}

function Get-NextStage {
    param([string]$CurrentStage)
    
    switch ($CurrentStage) {
        "explore" { return "plan" }
        "plan" { return "requirements" }
        "requirements" { return "design" }
        "design" { return "tasks" }
        "tasks" { return "assign" }
        "assign" { return "execution" }
        "execution" { return "execution" }
        default { return "explore" }
    }
}

function Move-NextStage {
    $currentStage = Get-CurrentStage
    
    if (Test-CurrentStage) {
        $nextStage = Get-NextStage -CurrentStage $currentStage
        Set-CurrentStage -Stage $nextStage
        Write-Host "Advanced to stage: $nextStage"
        return $true
    } else {
        Write-Host "Cannot advance: current stage validation failed"
        return $false
    }
}

function Show-Status {
    Initialize-Workflow
    $currentStage = Get-CurrentStage
    $currentPlanId = if (Test-Path $PLAN_MANAGER) {
        & $PLAN_MANAGER current
    }
    
    Write-Host "Current stage: $currentStage"
    if ($currentPlanId) {
        Write-Host "Current plan: $currentPlanId"
    }
    Write-Host ""
    Write-Host "SDD Artifacts:"
    Write-Host "  Plans: $((Get-ChildItem -Path $PLANS_DIR -Filter '*.md' -ErrorAction SilentlyContinue).Count) file(s)"
    Write-Host "  Requirements: $((Get-ChildItem -Path $REQUIREMENTS_DIR -Filter '*.md' -ErrorAction SilentlyContinue).Count) file(s)"
    Write-Host "  Designs: $((Get-ChildItem -Path $DESIGNS_DIR -Filter '*.md' -ErrorAction SilentlyContinue).Count) file(s)"
    Write-Host "  Tasks: $((Get-ChildItem -Path $TASKS_DIR -Filter '*.md' -ErrorAction SilentlyContinue).Count) file(s)"
    Write-Host ""
    Write-Host "Validation:"
    if (Test-CurrentStage) {
        Write-Host "  ✓ Current stage is valid"
    } else {
        Write-Host "  ✗ Current stage validation failed"
    }
}

# Main command handler
$command = $args[0]

switch ($command) {
    "validate" {
        if (-not (Test-CurrentStage)) { exit 1 }
    }
    "next" {
        if (-not (Move-NextStage)) { exit 1 }
    }
    "status" {
        Show-Status
    }
    "current" {
        Get-CurrentStage
    }
    "set" {
        if ($args.Count -lt 2) {
            Write-Host "Error: Stage name required"
            exit 1
        }
        Set-CurrentStage -Stage $args[1]
        Write-Host "Stage set to: $($args[1])"
    }
    default {
        Write-Host "Usage: $($MyInvocation.MyCommand.Name) {validate|next|status|current|set <stage>}"
        exit 1
    }
}

