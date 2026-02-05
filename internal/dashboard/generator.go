package dashboard

import (
	"fmt"
	"os"
	"path/filepath"
	"time"
)

// DashboardData represents dashboard information
type DashboardData struct {
	ActiveWork  []WorkItem
	Archived    []WorkItem
	Tasks       []TaskItem
	GeneratedAt string
}

// WorkItem represents a work item for display
type WorkItem struct {
	Name      string
	CreatedAt string
}

// TaskItem represents a task for display
type TaskItem struct {
	ID          string
	Description string
	Status      string
}

// GenerateDashboard creates a static HTML dashboard
func GenerateDashboard(dataDir string) error {
	data := DashboardData{
		GeneratedAt: time.Now().Format("2006-01-02 15:04"),
	}

	// Load active work
	workDir := filepath.Join(dataDir, "work")
	if entries, err := os.ReadDir(workDir); err == nil {
		for _, entry := range entries {
			if entry.IsDir() {
				data.ActiveWork = append(data.ActiveWork, WorkItem{
					Name:      entry.Name(),
					CreatedAt: "Recently",
				})
			}
		}
	}

	// Load archived work
	archiveDir := filepath.Join(dataDir, "archive")
	if entries, err := os.ReadDir(archiveDir); err == nil {
		for _, entry := range entries {
			if entry.IsDir() {
				data.Archived = append(data.Archived, WorkItem{
					Name:      entry.Name(),
					CreatedAt: "Completed",
				})
			}
		}
	}

	// Load tasks
	tasksPath := filepath.Join(dataDir, "tasks.json")
	if dataBytes, err := os.ReadFile(tasksPath); err == nil {
		// Parse tasks - simplified for now
		_ = dataBytes
	}

	// Generate HTML
	html := generateHTML(data)

	dashboardPath := filepath.Join(dataDir, "dashboard.html")
	return os.WriteFile(dashboardPath, []byte(html), 0644)
}

func generateHTML(data DashboardData) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADbS Dashboard</title>
    <style>
        :root {
            --primary: #2563eb;
            --success: #16a34a;
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #1e293b;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 20px;
        }
        .container { max-width: 800px; margin: 0 auto; }
        header {
            background: var(--primary);
            color: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        h1 { margin: 0; }
        .card {
            background: var(--card);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .work-item {
            padding: 12px;
            border-left: 4px solid var(--primary);
            background: #f1f5f9;
            margin: 8px 0;
            border-radius: 4px;
        }
        .work-item.archived {
            border-left-color: var(--success);
            opacity: 0.7;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        .stat {
            background: var(--card);
            padding: 20px;
            border-radius: 12px;
            text-align: center;
        }
        .stat-value { font-size: 2em; font-weight: bold; color: var(--primary); }
        .stat-label { color: #64748b; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>ADbS Dashboard</h1>
            <p>Keep your AI focused. Stay organized.</p>
            <small>Generated: %s</small>
        </header>
        
        <div class="stats">
            <div class="stat">
                <div class="stat-value">%d</div>
                <div class="stat-label">Active Work</div>
            </div>
            <div class="stat">
                <div class="stat-value">%d</div>
                <div class="stat-label">Archived</div>
            </div>
            <div class="stat">
                <div class="stat-value">%d</div>
                <div class="stat-label">Tasks</div>
            </div>
        </div>
        
        <div class="card">
            <h2>Active Work</h2>
            %s
        </div>
        
        <div class="card">
            <h2>Archived Work</h2>
            %s
        </div>
    </div>
</body>
</html>`,
		data.GeneratedAt,
		len(data.ActiveWork),
		len(data.Archived),
		len(data.Tasks),
		renderWorkItems(data.ActiveWork, false),
		renderWorkItems(data.Archived, true),
	)
}

func renderWorkItems(items []WorkItem, archived bool) string {
	if len(items) == 0 {
		return "<p>No work items</p>"
	}

	result := ""
	for _, item := range items {
		class := "work-item"
		if archived {
			class += " archived"
		}
		result += fmt.Sprintf(`<div class="%s"><strong>%s</strong></div>`, class, item.Name)
	}
	return result
}
