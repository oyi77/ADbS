package storage

import (
	"os"
	"path/filepath"
	"testing"
)

func createTestDir(t *testing.T) string {
	tmpDir, err := os.MkdirTemp("", "adbs-storage-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	// Create internal directory for state.json
	os.MkdirAll(filepath.Join(tmpDir, "internal"), 0755)
	return tmpDir
}

func TestTaskOperations(t *testing.T) {
	tmpDir := createTestDir(t)
	defer os.RemoveAll(tmpDir)

	// Test LoadTaskState returns empty state for new directory
	state, err := LoadTaskState(tmpDir)
	if err != nil {
		t.Fatalf("LoadTaskState failed: %v", err)
	}

	if len(state.Tasks) != 0 {
		t.Errorf("Expected 0 tasks, got %d", len(state.Tasks))
	}

	// Test AddTask
	task, err := AddTask(tmpDir, "Test task")
	if err != nil {
		t.Fatalf("AddTask failed: %v", err)
	}

	if task.Description != "Test task" {
		t.Errorf("Expected description 'Test task', got '%s'", task.Description)
	}

	if task.ID != "t1" {
		t.Errorf("Expected ID 't1', got '%s'", task.ID)
	}

	// Test GetTasks
	tasks, err := GetTasks(tmpDir)
	if err != nil {
		t.Fatalf("GetTasks failed: %v", err)
	}

	if len(tasks) != 1 {
		t.Errorf("Expected 1 task, got %d", len(tasks))
	}

	// Test UpdateTaskStatus
	if err := UpdateTaskStatus(tmpDir, "t1", "done"); err != nil {
		t.Fatalf("UpdateTaskStatus failed: %v", err)
	}

	updatedTasks, _ := GetTasks(tmpDir)
	if updatedTasks[0].Status != "done" {
		t.Errorf("Expected status 'done', got '%s'", updatedTasks[0].Status)
	}
}
