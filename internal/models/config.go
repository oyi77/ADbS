package models

import (
	"os"
	"path/filepath"
)

// Config holds ADbS configuration
type Config struct {
	DataDir    string
	WorkDir    string
	ArchiveDir string
}

// LoadConfig loads configuration from environment or defaults
func LoadConfig() Config {
	dataDir := ".adbs"
	if envDir := os.Getenv("ADBS_HOME"); envDir != "" {
		dataDir = envDir
	}

	return Config{
		DataDir:    dataDir,
		WorkDir:    filepath.Join(dataDir, "work"),
		ArchiveDir: filepath.Join(dataDir, "archive"),
	}
}
