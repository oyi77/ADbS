# Plan ID Management System - PowerShell version

$SDD_DIR = if ($env:SDD_DIR) { $env:SDD_DIR } else { ".sdd" }
$PLANS_DIR = Join-Path $SDD_DIR "plans"
$REQUIREMENTS_DIR = Join-Path $SDD_DIR "requirements"
$DESIGNS_DIR = Join-Path $SDD_DIR "designs"
$TASKS_DIR = Join-Path $SDD_DIR "tasks"
$PLAN_INDEX = Join-Path $PLANS_DIR ".index.json"

function Initialize-PlanIndex {
    if (-not (Test-Path $PLANS_DIR)) { New-Item -ItemType Directory -Path $PLANS_DIR -Force | Out-Null }
    if (-not (Test-Path $REQUIREMENTS_DIR)) { New-Item -ItemType Directory -Path $REQUIREMENTS_DIR -Force | Out-Null }
    if (-not (Test-Path $DESIGNS_DIR)) { New-Item -ItemType Directory -Path $DESIGNS_DIR -Force | Out-Null }
    if (-not (Test-Path $TASKS_DIR)) { New-Item -ItemType Directory -Path $TASKS_DIR -Force | Out-Null }
    
    if (-not (Test-Path $PLAN_INDEX)) {
        $index = @{
            next_id = 1
            plans = @()
        }
        $index | ConvertTo-Json -Depth 10 | Set-Content $PLAN_INDEX
    }
}

function Generate-PlanId {
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        $nextId = $index.next_id
        return "plan-{0:D3}" -f $nextId
    }
    
    return "plan-001"
}

function Get-CurrentPlanId {
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        $activePlan = $index.plans | Where-Object { $_.status -eq "active" } | Select-Object -First 1
        if ($activePlan) {
            return $activePlan.id
        }
    }
    
    return $null
}

function New-Plan {
    $planId = Generate-PlanId
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        
        # Deactivate all plans
        foreach ($plan in $index.plans) {
            $plan.status = "inactive"
        }
        
        # Add new plan
        $newPlan = @{
            id = $planId
            created_at = $timestamp
            status = "active"
            artifacts = @{}
        }
        
        $index.plans += $newPlan
        $index.next_id += 1
        
        $index | ConvertTo-Json -Depth 10 | Set-Content $PLAN_INDEX
    }
    
    return $planId
}

function Link-Artifact {
    param(
        [string]$PlanId,
        [string]$ArtifactType,
        [string]$Filename
    )
    
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        $plan = $index.plans | Where-Object { $_.id -eq $PlanId } | Select-Object -First 1
        
        if ($plan) {
            if (-not $plan.artifacts) {
                $plan.artifacts = @{}
            }
            $plan.artifacts.$ArtifactType = $Filename
            $index | ConvertTo-Json -Depth 10 | Set-Content $PLAN_INDEX
        }
    }
}

function Get-PlanArtifacts {
    param([string]$PlanId)
    
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        $plan = $index.plans | Where-Object { $_.id -eq $PlanId } | Select-Object -First 1
        
        if ($plan -and $plan.artifacts) {
            return $plan.artifacts | ConvertTo-Json -Depth 10
        }
    }
    
    return "{}"
}

function Get-Plans {
    Initialize-PlanIndex
    
    if (Test-Path $PLAN_INDEX) {
        $index = Get-Content $PLAN_INDEX | ConvertFrom-Json
        foreach ($plan in $index.plans) {
            Write-Output "$($plan.id) | $($plan.status) | $($plan.created_at)"
        }
    }
}

# Main command handler
$command = $args[0]

switch ($command) {
    "generate" {
        Generate-PlanId
    }
    "current" {
        Get-CurrentPlanId
    }
    "create" {
        New-Plan
    }
    "link" {
        if ($args.Count -ge 4) {
            Link-Artifact -PlanId $args[1] -ArtifactType $args[2] -Filename $args[3]
        } else {
            Write-Host "Usage: plan_manager.ps1 link <id> <type> <file>"
            exit 1
        }
    }
    "artifacts" {
        if ($args.Count -ge 2) {
            Get-PlanArtifacts -PlanId $args[1]
        } else {
            Write-Host "Usage: plan_manager.ps1 artifacts <id>"
            exit 1
        }
    }
    "list" {
        Get-Plans
    }
    default {
        Write-Host "Usage: $($MyInvocation.MyCommand.Name) {generate|current|create|link|artifacts|list}"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  generate              - Generate next plan ID"
        Write-Host "  current               - Get current active plan ID"
        Write-Host "  create                - Create new plan and return ID"
        Write-Host "  link <id> <type> <file> - Link artifact to plan"
        Write-Host "  artifacts <id>       - Get artifacts for a plan"
        Write-Host "  list                  - List all plans"
        exit 1
    }
}

