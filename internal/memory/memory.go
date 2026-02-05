package memory

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// MemoryEntry represents a memory entry
type MemoryEntry struct {
	Key      string `json:"key"`
	Value    string `json:"value"`
	Category string `json:"category"`
}

// Memory provides a simple key-value memory store
type Memory struct {
	dataDir string
}

// NewMemory creates a new memory instance
func NewMemory(dataDir string) *Memory {
	return &Memory{dataDir: dataDir}
}

// Set stores a memory entry
func (m *Memory) Set(key string, value string, category string) error {
	memoryPath := filepath.Join(m.dataDir, "memory.json")

	var entries map[string]MemoryEntry
	if data, err := os.ReadFile(memoryPath); err == nil {
		json.Unmarshal(data, &entries)
	} else {
		entries = make(map[string]MemoryEntry)
	}

	entries[key] = MemoryEntry{
		Key:      key,
		Value:    value,
		Category: category,
	}

	data, _ := json.MarshalIndent(entries, "", "  ")
	return os.WriteFile(memoryPath, data, 0644)
}

// Get retrieves a memory entry
func (m *Memory) Get(key string) (MemoryEntry, error) {
	memoryPath := filepath.Join(m.dataDir, "memory.json")

	var entries map[string]MemoryEntry
	if data, err := os.ReadFile(memoryPath); err == nil {
		json.Unmarshal(data, &entries)
	} else {
		return MemoryEntry{}, fmt.Errorf("memory entry not found: %s", key)
	}

	if entry, ok := entries[key]; ok {
		return entry, nil
	}

	return MemoryEntry{}, fmt.Errorf("memory entry not found: %s", key)
}

// GetAll returns all memory entries
func (m *Memory) GetAll() ([]MemoryEntry, error) {
	memoryPath := filepath.Join(m.dataDir, "memory.json")

	var entries map[string]MemoryEntry
	if data, err := os.ReadFile(memoryPath); err == nil {
		json.Unmarshal(data, &entries)
	} else {
		return []MemoryEntry{}, nil
	}

	result := make([]MemoryEntry, 0, len(entries))
	for _, entry := range entries {
		result = append(result, entry)
	}

	return result, nil
}

// Delete removes a memory entry
func (m *Memory) Delete(key string) error {
	memoryPath := filepath.Join(m.dataDir, "memory.json")

	var entries map[string]MemoryEntry
	if data, err := os.ReadFile(memoryPath); err == nil {
		json.Unmarshal(data, &entries)
	} else {
		return fmt.Errorf("memory entry not found: %s", key)
	}

	if _, ok := entries[key]; !ok {
		return fmt.Errorf("memory entry not found: %s", key)
	}

	delete(entries, key)

	data, _ := json.MarshalIndent(entries, "", "  ")
	return os.WriteFile(memoryPath, data, 0644)
}

// Has checks if a key exists
func (m *Memory) Has(key string) bool {
	memoryPath := filepath.Join(m.dataDir, "memory.json")

	var entries map[string]MemoryEntry
	if data, err := os.ReadFile(memoryPath); err == nil {
		json.Unmarshal(data, &entries)
	} else {
		return false
	}

	_, ok := entries[key]
	return ok
}
