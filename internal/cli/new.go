package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"time"
)

// NewWork creates a new work item
func NewWork(name string, dataDir string) error {
	// Create timestamp-based ID
	timestamp := time.Now().Format("2006-01-02")
	workID := fmt.Sprintf("%s-%s", timestamp, sanitizeName(name))

	workDir := filepath.Join(dataDir, "work", workID)
	if err := os.MkdirAll(workDir, 0755); err != nil {
		return fmt.Errorf("failed to create work directory: %w", err)
	}

	// Create proposal.md
	proposalPath := filepath.Join(workDir, "proposal.md")
	proposalContent := fmt.Sprintf("# %s\n\n## Context\n\n## Work Objectives\n\n## Tasks\n\n", name)
	if err := os.WriteFile(proposalPath, []byte(proposalContent), 0644); err != nil {
		return fmt.Errorf("failed to create proposal: %w", err)
	}

	fmt.Printf("Created new work: %s (%s)\n", name, workID)
	return nil
}

func sanitizeName(name string) string {
	// Simple sanitization - replace spaces with dashes
	result := ""
	for _, c := range name {
		if c == ' ' || c == '_' {
			result += "-"
		} else if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' {
			result += string(c)
		}
	}
	return result
}
