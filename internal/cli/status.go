package cli

import (
	"fmt"
	"os"
	"path/filepath"
)

// Status shows the current active work
func Status(dataDir string) error {
	workDir := filepath.Join(dataDir, "work")

	entries, err := os.ReadDir(workDir)
	if err != nil {
		if os.IsNotExist(err) {
			fmt.Println("No active work. Use 'adbs new' to start.")
			return nil
		}
		return fmt.Errorf("failed to read work directory: %w", err)
	}

	activeCount := 0
	for _, entry := range entries {
		if entry.IsDir() {
			activeCount++
			fmt.Printf("• %s\n", entry.Name())
		}
	}

	fmt.Printf("\nActive work: %d\n", activeCount)
	return nil
}
