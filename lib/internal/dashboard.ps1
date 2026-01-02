# ADbS Dashboard Generator (PowerShell Native)
# Generates dashboard without requiring Bash

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ADbS Logic to find paths (Mirroring Bash logic)
# Try to find .adbs directory
$AdbsDir = ".adbs"
if ($env:ADBS_DIR) { $AdbsDir = $env:ADBS_DIR }

$WorkDir = Join-Path $AdbsDir "work"
$DashboardDir = Join-Path $AdbsDir "dashboard"
$MemoryFile = Join-Path $AdbsDir "config\memory.conf"
$GlobalMemoryFile = Join-Path $env:USERPROFILE ".adbs_profile\memory.conf"

# Create dashboard dir
New-Item -ItemType Directory -Path $DashboardDir -Force | Out-Null

# --- Helper Functions ---

function Get-WorkItemsJSON {
    $jsonItems = @()
    
    if (Test-Path $WorkDir) {
        $workItems = Get-ChildItem -Path $WorkDir -Directory
        foreach ($item in $workItems) {
            $name = $item.Name
            $desc = "No description"
            
            $propFile = Join-Path $item.FullName "proposal.md"
            if (Test-Path $propFile) {
                $firstLine = Get-Content $propFile -TotalCount 1
                if ($firstLine -match "^#\s*(.*)") {
                    $desc = $matches[1]
                }
            }
            
            # Regex to extract date and name
            $date = ""
            $cleanName = $name
            if ($name -match "^(\d{4}-\d{2}-\d{2})-(.*)") {
                $date = $matches[1]
                $cleanName = $matches[2]
            }
            
            # Escape for JSON
            $safeName = $cleanName -replace '"','\"'
            $safeDate = $date -replace '"','\"'
            $safeDesc = $desc -replace '"','\"'
            
            $jsonItems += "{ `"name`": `"$safeName`", `"date`": `"$safeDate`", `"description`": `"$safeDesc`" }"
        }
    }
    
    return "[" + ($jsonItems -join ",") + "]"
}

function Get-PreferencesJSON {
    $jsonItems = @()
    $prefs = @{}
    
    # Read Global First
    if (Test-Path $GlobalMemoryFile) {
        Get-Content $GlobalMemoryFile | ForEach-Object {
            if ($_ -match "^(.*?)=(.*)$") {
                $key = $matches[1]
                $val = $matches[2]
                $prefs[$key] = @{ Value = $val; Source = "Global" }
            }
        }
    }
    
    # Read Project (Overrides Global for value, but source tracking might differ? 
    # Actually memory.sh get_preference logic: Global > Project. 
    # Wait, memory.sh:
    # "Check Global first... If not found, check Project"
    # So Global takes precedence.
    
    if (Test-Path $MemoryFile) {
        Get-Content $MemoryFile | ForEach-Object {
            if ($_ -match "^(.*?)=(.*)$") {
                $key = $matches[1]
                $val = $matches[2]
                
                # Only add if not in global (since global takes precedence)
                if (-not $prefs.ContainsKey($key)) {
                     $prefs[$key] = @{ Value = $val; Source = "Project" }
                }
            }
        }
    }
    
    foreach ($key in $prefs.Keys) {
        $p = $prefs[$key]
        $safeKey = $key -replace '"','\"'
        $safeVal = $p.Value -replace '"','\"'
        $safeSrc = $p.Source -replace '"','\"'
        
        $jsonItems += "{ `"key`": `"$safeKey`", `"value`": `"$safeVal`", `"source`": `"$safeSrc`" }"
    }
    
    return "[" + ($jsonItems -join ",") + "]"
}

# --- Generate Content ---

$WorkJson = Get-WorkItemsJSON
$PrefsJson = Get-PreferencesJSON

$HtmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADbS Dashboard</title>
    <style>
        :root {
            --bg-color: #121212;
            --card-bg: #1e1e1e;
            --text-primary: #e0e0e0;
            --text-secondary: #aaaaaa;
            --accent-color: #64b5f6;
            --border-color: #333;
            --success-color: #4caf50;
            --info-color: #2196f3;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-primary);
            margin: 0;
            padding: 40px;
            line-height: 1.6;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        header {
            border-bottom: 2px solid var(--border-color);
            margin-bottom: 40px;
            padding-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        h1 {
            color: var(--accent-color);
            margin: 0;
            font-size: 2.5em;
        }
        .subtitle {
            color: var(--text-secondary);
            font-size: 1.1em;
        }
        section {
            margin-bottom: 60px;
        }
        h2 {
            color: var(--text-primary);
            border-left: 5px solid var(--accent-color);
            padding-left: 15px;
            margin-bottom: 25px;
            font-size: 1.8em;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .card {
            background-color: var(--card-bg);
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.2);
            transition: transform 0.2s, box-shadow 0.2s;
            border: 1px solid transparent;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 12px rgba(0,0,0,0.3);
            border-color: var(--accent-color);
        }
        .card h3 {
            margin-top: 0;
            color: var(--accent-color);
            font-size: 1.4em;
        }
        .card-meta {
            font-size: 0.85em;
            color: var(--text-secondary);
            margin-bottom: 15px;
            display: block;
        }
        .card p {
            color: var(--text-primary);
            margin-bottom: 0;
        }
        .list-group {
            background-color: var(--card-bg);
            border-radius: 12px;
            padding: 0;
            list-style: none;
            overflow: hidden;
        }
        .list-item {
            padding: 20px 25px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .list-item:last-child {
            border-bottom: none;
        }
        .badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.8em;
            font-weight: bold;
            color: white;
            text-transform: uppercase;
        }
        .badge.global { background-color: var(--info-color); }
        .badge.project { background-color: var(--success-color); }
        
        .empty-state {
            text-align: center;
            color: var(--text-secondary);
            padding: 40px;
            font-style: italic;
            background: var(--card-bg);
            border-radius: 12px;
        }
        
        /* Stats row */
        .stats {
            display: flex;
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: linear-gradient(135deg, #2d2d2d 0%, #1e1e1e 100%);
            flex: 1;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
        }
        .stat-number {
            font-size: 3em;
            font-weight: bold;
            color: var(--accent-color);
            display: block;
        }
        .stat-label {
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1>ADbS Dashboard</h1>
                <span class="subtitle">AI Development Assistant Monitor</span>
            </div>
            <div style="text-align: right; font-size: 0.9em; color: var(--text-secondary);">
                Generated: <span id="gen-date"></span>
            </div>
        </header>
        
        <div class="stats">
            <div class="stat-card">
                <span class="stat-number" id="work-count">0</span>
                <span class="stat-label">Active Projects</span>
            </div>
            <div class="stat-card">
                <span class="stat-number" id="pref-count">0</span>
                <span class="stat-label">Learned Preferences</span>
            </div>
            <div class="stat-card">
                <span class="stat-number">100%</span>
                <span class="stat-label">System Status</span>
            </div>
        </div>

        <section>
            <h2>Active Work</h2>
            <div id="work-container" class="grid">
                <!-- Populated by JS -->
            </div>
            <div id="work-empty" class="empty-state" style="display:none">
                No active work found. Use <code style="color:var(--accent-color)">adbs new</code> to start something.
            </div>
        </section>

        <section>
            <h2>Learned Preferences</h2>
            <ul id="prefs-container" class="list-group">
                <!-- Populated by JS -->
            </ul>
             <div id="prefs-empty" class="empty-state" style="display:none">
                No preferences learned yet.
            </div>
        </section>
    </div>

    <script>
        // Data injected by PowerShell script
        const workItems = $WorkJson;
        const preferences = $PrefsJson;

        // Initialize Dashboard
        document.getElementById('gen-date').textContent = new Date().toLocaleString();
        
        // Update Stats
        document.getElementById('work-count').textContent = workItems.length;
        document.getElementById('pref-count').textContent = preferences.length;

        // Render Work
        const workContainer = document.getElementById('work-container');
        const workEmpty = document.getElementById('work-empty');
        
        if (workItems.length === 0) {
            workEmpty.style.display = 'block';
        } else {
            workItems.forEach(item => {
                const card = document.createElement('div');
                card.className = 'card';
                card.innerHTML = \`
                    <h3>\${item.name}</h3>
                    <span class="card-meta">Created: \${item.date}</span>
                    <p>\${item.description}</p>
                \`;
                workContainer.appendChild(card);
            });
        }

        // Render Preferences
        const prefsContainer = document.getElementById('prefs-container');
        const prefsEmpty = document.getElementById('prefs-empty');
        
        if (preferences.length === 0) {
            prefsEmpty.style.display = 'block';
        } else {
            preferences.forEach(pref => {
                const li = document.createElement('li');
                li.className = 'list-item';
                const badgeClass = pref.source.toLowerCase() === 'global' ? 'global' : 'project';
                li.innerHTML = \`
                    <div>
                        <strong>\${pref.key}</strong>
                        <div style="color:var(--text-secondary); font-size:0.9em">\${pref.value}</div>
                    </div>
                    <span class="badge \${badgeClass}">\${pref.source}</span>
                \`;
                prefsContainer.appendChild(li);
            });
        }
    </script>
</body>
</html>
"@

$IndexPath = Join-Path $DashboardDir "index.html"
$HtmlContent | Set-Content $IndexPath -Encoding UTF8

Write-Host "Dashboard generated at $IndexPath"

# Launch
Write-Host "Attempting to launch..."

# Try Python if available (better experience)
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    Write-Host "Starting Python server on http://localhost:8000"
    Set-Location $DashboardDir
    python -m http.server 8000
} elseif (Get-Command "python3" -ErrorAction SilentlyContinue) {
    Write-Host "Starting Python 3 server on http://localhost:8000"
    Set-Location $DashboardDir
    python3 -m http.server 8000
} else {
    Write-Host "Opening file directly in default browser..."
    Start-Process $IndexPath
}
