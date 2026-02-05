package cli

import (
	"fmt"
	"os"
	"path/filepath"
)

// Setup initializes the ADbS directory structure
func Setup(dataDir string) error {
	dirs := []string{
		dataDir,
		filepath.Join(dataDir, "work"),
		filepath.Join(dataDir, "archive"),
		filepath.Join(dataDir, "internal"),
	}

	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", dir, err)
		}
	}

	fmt.Printf("ADbS initialized at: %s\n", dataDir)
	return nil
}
