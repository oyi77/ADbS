# Wrapper for ADbS Memory Engine (Python)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$PythonScript = Join-Path $ProjectRoot "lib\memory.py"

# Find python
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    $PythonCmd = "python"
} elseif (Get-Command "python3" -ErrorAction SilentlyContinue) {
    $PythonCmd = "python3"
} else {
    # Fallback Mode: Native PowerShell
    $Command = $args[0]
    
    if ($Command -eq "query") {
        Write-Warning "Python not found. Using simple native search."
        $Term = $args[1]
        # Simple recursive search, excluding common noise
        Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue | 
            Where-Object { $_.FullName -notmatch "\\.git\\" -and $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\.adbs\\" } |
            Select-String -Pattern $Term -SimpleMatch | 
            Select-Object -First 20 |
            ForEach-Object {
                [PSCustomObject]@{
                    path = $_.Path
                    preview = $_.Line.Trim()
                    type = "native-grep"
                }
            } | ConvertTo-Json
    }
    elseif ($Command -eq "index") {
        Write-Warning "Python not found. Indexing is not required for native search."
    }
    else {
        Write-Warning "Python not found. Only 'query' works in native fallback mode."
    }
    exit 0
}

& $PythonCmd $PythonScript @args
