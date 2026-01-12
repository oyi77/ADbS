# Changelog

All notable changes to ADbS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-02

### Added
- Initial release of ADbS (AI Development Assistant)
- Core workflow management (`adbs new`, `adbs status`, `adbs done`)
- AI-powered workflow generation with `--ai-generate` flag
- State machine for workflow progression (PLANNING → DESIGNING → IMPLEMENTING → TESTING → REVIEWING → DONE)
- Task management system
- Multi-IDE support (Cursor, Windsurf, Zed, VS Code, JetBrains, etc.)
- Automatic rules generation for detected IDEs
- Cross-platform support (Windows, macOS, Linux)
- Agent templates for different workflow stages
- Migration support from legacy structures

### Fixed
- Cross-platform compatibility issues with sed and date commands
- Unreachable code in work_manager.sh
- Error handling and cleanup on workflow generation failures
- JSON parsing with jq/python fallbacks
- Process substitution for POSIX compatibility
- Platform detection error handling
- Installation automation with --yes flag

### Changed
- Simplified workflow detection (always use OpenSpec)
- Optimized file counting operations using shell globbing
- Improved feature name extraction
- Updated directory structure to use .adbs instead of legacy .sdd
- Enhanced error messages for better user experience

### Security
- Added input validation throughout
- Removed hardcoded credentials
- Improved error handling to prevent information disclosure

## [Unreleased]

### Planned
- Test suite implementation (target: 70% coverage)
- Performance optimizations
- Additional IDE integrations
- Enhanced AI workflow generation
- Plugin system for extensibility
