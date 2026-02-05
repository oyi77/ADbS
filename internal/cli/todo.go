package cli

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

// Task represents a single task
type Task struct {
	ID          string `json:"id"`
	Description string `json:"description"`
	Status      string `json:"status"`
	CreatedAt   string `json:"createdAt"`
}

// Todo adds a new task
func Todo(description string, dataDir string) error {
	tasksPath := filepath.Join(dataDir, "tasks.json")

	var tasks []Task

	// Read existing tasks
	if data, err := os.ReadFile(tasksPath); err == nil {
		json.Unmarshal(data, &tasks)
	}

	// Generate task ID
	taskID := fmt.Sprintf("t%d", len(tasks)+1)

	newTask := Task{
		ID:          taskID,
		Description: description,
		Status:      "pending",
		CreatedAt:   time.Now().Format(time.RFC3339),
	}

	tasks = append(tasks, newTask)

	// Write back
	data, _ := json.MarshalIndent(tasks, "", "  ")
	os.WriteFile(tasksPath, data, 0644)

	fmt.Printf("Added task: %s - %s\n", taskID, description)
	return nil
}

// ListTasks lists all tasks
func ListTasks(dataDir string) error {
	tasksPath := filepath.Join(dataDir, "tasks.json")

	var tasks []Task
	if data, err := os.ReadFile(tasksPath); err == nil {
		json.Unmarshal(data, &tasks)
	}

	for _, task := range tasks {
		status := "[ ]"
		if task.Status == "done" {
			status = "[✓]"
		}
		fmt.Printf("%s %s: %s\n", status, task.ID, task.Description)
	}

	return nil
}
