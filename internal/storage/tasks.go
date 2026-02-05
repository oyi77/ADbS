package storage

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

// TaskState represents task state in the state file
type TaskState struct {
	Tasks     []Task `json:"tasks"`
	UpdatedAt string `json:"updatedAt"`
}

// LoadTaskState loads the task state from internal/state.json
func LoadTaskState(dataDir string) (*TaskState, error) {
	statePath := filepath.Join(dataDir, "internal", "state.json")

	data, err := os.ReadFile(statePath)
	if err != nil {
		if os.IsNotExist(err) {
			// Return empty state if file doesn't exist
			return &TaskState{
				Tasks:     []Task{},
				UpdatedAt: time.Now().Format(time.RFC3339),
			}, nil
		}
		return nil, fmt.Errorf("failed to read state.json: %w", err)
	}

	var state TaskState
	if err := json.Unmarshal(data, &state); err != nil {
		return nil, fmt.Errorf("failed to parse state.json: %w", err)
	}

	return &state, nil
}

// SaveTaskState saves task state to internal/state.json
func SaveTaskState(dataDir string, state *TaskState) error {
	statePath := filepath.Join(dataDir, "internal", "state.json")
	state.UpdatedAt = time.Now().Format(time.RFC3339)

	data, err := json.MarshalIndent(state, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal state: %w", err)
	}

	if err := os.WriteFile(statePath, data, 0644); err != nil {
		return fmt.Errorf("failed to write state.json: %w", err)
	}

	return nil
}

// AddTask adds a task to the state
func AddTask(dataDir string, description string) (*Task, error) {
	state, err := LoadTaskState(dataDir)
	if err != nil {
		return nil, err
	}

	taskID := fmt.Sprintf("t%d", len(state.Tasks)+1)
	task := Task{
		ID:          taskID,
		Description: description,
		Status:      "pending",
		CreatedAt:   time.Now().Format(time.RFC3339),
	}

	state.Tasks = append(state.Tasks, task)
	if err := SaveTaskState(dataDir, state); err != nil {
		return nil, err
	}

	return &task, nil
}

// UpdateTaskStatus updates the status of a task
func UpdateTaskStatus(dataDir string, taskID string, status string) error {
	state, err := LoadTaskState(dataDir)
	if err != nil {
		return err
	}

	found := false
	for i, task := range state.Tasks {
		if task.ID == taskID {
			state.Tasks[i].Status = status
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("task not found: %s", taskID)
	}

	return SaveTaskState(dataDir, state)
}

// GetTasks returns all tasks
func GetTasks(dataDir string) ([]Task, error) {
	state, err := LoadTaskState(dataDir)
	if err != nil {
		return nil, err
	}
	return state.Tasks, nil
}
