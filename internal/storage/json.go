package storage

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// Task represents a single task
type Task struct {
	ID          string `json:"id"`
	Description string `json:"description"`
	Status      string `json:"status"`
	CreatedAt   string `json:"createdAt"`
}

// ReadTasks loads and parses tasks.json
func ReadTasks(dataDir string) ([]Task, error) {
	tasksPath := filepath.Join(dataDir, "tasks.json")

	data, err := os.ReadFile(tasksPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read tasks.json: %w", err)
	}

	var tasks []Task
	if err := json.Unmarshal(data, &tasks); err != nil {
		return nil, fmt.Errorf("failed to parse tasks.json: %w", err)
	}

	return tasks, nil
}

// WriteTasks saves tasks to JSON file
func WriteTasks(dataDir string, tasks []Task) error {
	tasksPath := filepath.Join(dataDir, "tasks.json")

	data, err := json.MarshalIndent(tasks, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal tasks: %w", err)
	}

	if err := os.WriteFile(tasksPath, data, 0644); err != nil {
		return fmt.Errorf("failed to write tasks.json: %w", err)
	}

	return nil
}
