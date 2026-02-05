package cli

import (
	"fmt"
	"os"
	"path/filepath"
)

// List shows all work items (active and archived)
func List(dataDir string) error {
	workDir := filepath.Join(dataDir, "work")
	archiveDir := filepath.Join(dataDir, "archive")

	fmt.Println("Active Work:")

	workEntries, err := os.ReadDir(workDir)
	if err != nil {
		if !os.IsNotExist(err) {
			return fmt.Errorf("failed to read work directory: %w", err)
		}
	}

	if len(workEntries) == 0 {
		fmt.Println("  (none)")
	}

	for _, entry := range workEntries {
		if entry.IsDir() {
			fmt.Printf("  • %s\n", entry.Name())
		}
	}

	fmt.Println("\nArchived:")

	archiveEntries, err := os.ReadDir(archiveDir)
	if err != nil {
		if !os.IsNotExist(err) {
			return fmt.Errorf("failed to read archive directory: %w", err)
		}
	}

	if len(archiveEntries) == 0 {
		fmt.Println("  (none)")
	}

	for _, entry := range archiveEntries {
		if entry.IsDir() {
			fmt.Printf("  ✓ %s\n", entry.Name())
		}
	}

	return nil
}
