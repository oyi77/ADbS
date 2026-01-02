#!/bin/bash
# ADbS Dashboard Generator & Launcher
# Generates a standalone, lightweight, single-file HTML dashboard.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${ADBS_DIR:-.adbs}/work"
DASHBOARD_DIR="${ADBS_DIR:-.adbs}/dashboard"
MEMORY_LIB="$SCRIPT_DIR/memory.sh"

mkdir -p "$DASHBOARD_DIR"

# Collect Data via helper functions
get_work_items() {
    if [ ! -d "$WORK_DIR" ]; then return; fi
    for work in "$WORK_DIR"/*; do
        if [ -d "$work" ]; then
            name=$(basename "$work")
            desc="No description"
            if [ -f "$work/proposal.md" ]; then
                desc=$(grep -m 1 "^# " "$work/proposal.md" | sed 's/^# //')
            fi
            date_prefix=$(echo "$name" | grep -o "^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}")
            clean_name=$(echo "$name" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
            
            # Escape JSON special chars (basic)
            safe_desc=$(echo "$desc" | sed 's/"/\\"/g')
            safe_name=$(echo "$clean_name" | sed 's/"/\\"/g')
            safe_date=$(echo "$date_prefix" | sed 's/"/\\"/g')
            
            echo "{\"name\": \"$safe_name\", \"date\": \"$safe_date\", \"description\": \"$safe_desc\"},"
        fi
    done
}

get_preferences() {
    if [ ! -f "$MEMORY_LIB" ]; then return; fi
    source "$MEMORY_LIB" >/dev/null 2>&1
    
    # Run list_preferences in a way that gives us parseable output
    # list_preferences output format: key=value (Source)
    # We'll parse this into JSON objects
    
    while read -r line; do
        if [ -n "$line" ]; then
            key=$(echo "$line" | cut -d'=' -f1)
            rest=$(echo "$line" | cut -d'=' -f2-)
            value=$(echo "$rest" | sed 's/ (.*)$//')
            source_tag=$(echo "$rest" | grep -o "(.*)" | tr -d '()')
            
            safe_key=$(echo "$key" | sed 's/"/\\"/g')
            safe_value=$(echo "$value" | sed 's/"/\\"/g')
            safe_source=$(echo "$source_tag" | sed 's/"/\\"/g')
            
            echo "{\"key\": \"$safe_key\", \"value\": \"$safe_value\", \"source\": \"$safe_source\"},"
        fi
    done < <(list_preferences "true")
}

WORK_JSON="[$(get_work_items | sed '$s/,$//')]"
PREFS_JSON="[$(get_preferences | sed '$s/,$//')]"

# Generate Single File HTML
cat > "$DASHBOARD_DIR/index.html" <<EOF
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
                No active work found. Use <code>adbs new</code> to start something.
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
        // Data injected by build script
        const workItems = $WORK_JSON;
        const preferences = $PREFS_JSON;

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
EOF

echo "Dashboard generated at $DASHBOARD_DIR/index.html"
echo "Starting local Python server on port 8000..."
echo "Open http://localhost:8000 in your browser."
echo "Press Ctrl+C to stop."

cd "$DASHBOARD_DIR"

# Launch Server or Open File
echo "Attempting to launch dashboard..."

# Try Python
if command -v python3 &>/dev/null; then
    echo "Starting local Python 3 server on http://localhost:8000"
    echo "Press Ctrl+C to stop."
    python3 -m http.server 8000
elif command -v python &>/dev/null; then
    echo "Starting local Python server on http://localhost:8000"
    echo "Press Ctrl+C to stop."
    python -m http.server 8000
else
    # Fallback: Serverless Mode
    echo "Notice: No suitable web server found (Python/Node)."
    echo "Entering Serverless Mode: Opening file directly."
    
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        start index.html
    elif command -v xdg-open &>/dev/null; then
        xdg-open index.html
    elif command -v open &>/dev/null; then
        open index.html
    else
        echo "Error: Could not open browser automatically."
        echo "Please open this file in your browser:"
        echo "  $DASHBOARD_DIR/index.html"
    fi
fi
