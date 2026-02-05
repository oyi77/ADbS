package cli

import (
	"fmt"
	"os"
	"path/filepath"
)

// Done marks work as complete and archives it
func Done(workName string, dataDir string) error {
	workDir := filepath.Join(dataDir, "work", workName)

	if _, err := os.Stat(workDir); os.IsNotExist(err) {
		return fmt.Errorf("work not found: %s", workName)
	}

	// Read proposal for archive
	proposalPath := filepath.Join(workDir, "proposal.md")
	proposalData, err := os.ReadFile(proposalPath)
	if err != nil {
		return fmt.Errorf("failed to read proposal: %w", err)
	}

	// Create archive directory with timestamp
	archiveName := fmt.Sprintf("%s-done", workName)
	archiveDir := filepath.Join(dataDir, "archive", archiveName)
	if err := os.MkdirAll(archiveDir, 0755); err != nil {
		return fmt.Errorf("failed to create archive directory: %w", err)
	}

	// Write proposal to archive
	archiveProposalPath := filepath.Join(archiveDir, "proposal.md")
	if err := os.WriteFile(archiveProposalPath, proposalData, 0644); err != nil {
		return fmt.Errorf("failed to write archived proposal: %w", err)
	}

	// Remove original work directory
	if err := os.RemoveAll(workDir); err != nil {
		return fmt.Errorf("failed to remove work directory: %w", err)
	}

	fmt.Printf("Completed: %s\n", workName)
	fmt.Printf("Archived to: %s\n", archiveDir)
	return nil
}
