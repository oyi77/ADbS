---
title: "Testing"
description: "Testing strategy and best practices for ADbS"
date: 2025-01-01
---

# ADbS Testing Documentation

This document describes the testing strategy, setup, and best practices for the ADbS project.

## Testing Framework

We use **BATS (Bash Automated Testing System)** for testing shell scripts.

### Why BATS?

- Native support for Bash scripts
- Simple, readable test syntax
- Cross-platform compatibility
- Integration with CI/CD
- Active community and maintenance

## Test Structure

```
tests/
├── test_helper.bash           # Shared test utilities
├── unit/                      # Unit tests
│   ├── test_platform_detector.bats
│   ├── test_validator.bats
│   ├── test_openspec.bats
│   └── test_task_manager.bats
├── integration/               # Integration tests
│   ├── test_sdd_workflow.bats
│   └── test_openspec_workflow.bats
└── fixtures/                  # Test data
```

## Running Tests

### Local Development

```bash
# Install BATS
# Windows: npm install -g bats
# macOS: brew install bats-core
# Linux: sudo apt-get install bats

# Run all tests
bats tests/

# Run specific test suite
bats tests/unit/
bats tests/integration/

# Run single test file
bats tests/unit/test_validator.bats

# Verbose output
bats tests/ --verbose

# TAP format
bats tests/ -t
```

### CI/CD

Tests run automatically on:
- Every push to `main` or `develop`
- Every pull request
- Platforms: Ubuntu, macOS, Windows

See `.github/workflows/test.yml` for configuration.

## Writing Tests

### Test File Template

```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "component_function_scenario_expectedResult" {
    # Arrange
    local input="test"
    
    # Act
    run command_to_test "$input"
    
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected"* ]]
}
```

### Naming Conventions

**Test Files:**
- Unit tests: `test_<component>.bats`
- Integration tests: `test_<workflow>_workflow.bats`

**Test Names:**
```
component_function_scenario_expectedResult
```

Examples:
- `validator_getCurrentStage_whenStageExists_returnsStage`
- `openspec_propose_whenValidName_createsProposal`
- `taskManager_create_whenValidInput_createsTask`

### Assertions

```bash
# Exit status
[ "$status" -eq 0 ]        # Success
[ "$status" -ne 0 ]        # Failure

# Output contains
[[ "$output" == *"text"* ]]

# File/directory exists
[ -f "$file" ]
[ -d "$directory" ]

# String comparison
[[ "$var" == "value" ]]

# Helper assertions
assert_file_exists "$file"
assert_dir_exists "$dir"
assert_contains "$haystack" "$needle"
```

## Test Helper Functions

Available in `test_helper.bash`:

### Environment Setup
```bash
setup_test_env()          # Initialize test environment
teardown_test_env()       # Clean up after tests
```

### Sample Data Generators
```bash
create_sample_plan()          # Generate sample plan
create_sample_requirements()  # Generate sample requirements
create_sample_design()        # Generate sample design
create_sample_tasks()         # Generate sample tasks
```

### Assertions
```bash
assert_file_exists "$file"
assert_dir_exists "$dir"
assert_contains "$haystack" "$needle"
```

## Coverage Goals

| Week | Coverage | Focus |
|------|----------|-------|
| 1 | 30% | Core functions |
| 2 | 50% | Main workflows |
| 3 | 60% | Edge cases |
| 4 | 70% | Error handling |
| 5 | 70%+ | Polish |

## Best Practices

### 1. Keep Tests Fast
- Target: < 5 minutes total
- Use mocks for external dependencies
- Avoid network calls
- Clean up temporary files

### 2. Make Tests Independent
- No shared state between tests
- Each test should pass in isolation
- Use `setup()` and `teardown()`

### 3. Test One Thing
- Each test verifies one behavior
- Clear, focused assertions
- Descriptive test names

### 4. Use Descriptive Names
- Test name explains what it tests
- Follow naming convention
- Include scenario and expected result

### 5. Clean Up Resources
- Always implement `teardown()`
- Remove temporary files/directories
- Reset environment variables

### 6. Mock External Dependencies
- Don't rely on network
- Mock external services
- Use test fixtures

## Debugging Tests

### Show Debug Output

```bash
# In your test
echo "DEBUG: $variable" >&3

# Run with verbose
bats tests/unit/test_file.bats --verbose
```

### Run Single Test

```bash
# Run specific test file
bats tests/unit/test_validator.bats

# Run with TAP output for details
bats tests/unit/test_validator.bats -t
```

### Common Issues

**"command not found":**
```bash
# Make scripts executable
chmod +x lib/**/*.sh
chmod +x bin/*
```

**Temporary directory not cleaned:**
```bash
# Check teardown() is called
# Manually clean: rm -rf /tmp/tmp.*
```

**Tests pass locally but fail in CI:**
- Check platform-specific commands
- Verify dependencies in CI config
- Review GitHub Actions logs

## Continuous Integration

### GitHub Actions Workflow

Located at `.github/workflows/test.yml`

**Features:**
- Multi-platform testing (Ubuntu, macOS, Windows)
- Automatic BATS installation
- Test result artifacts
- ShellCheck linting

**Triggers:**
- Push to main/develop
- Pull requests
- Manual workflow dispatch

### Status Badges

Add to README.md:
```markdown
![Tests](https://github.com/your-username/ADbS/workflows/Tests/badge.svg)
```

## Future Enhancements

- [ ] Code coverage reporting (with kcov)
- [ ] Performance benchmarking
- [ ] Mutation testing
- [ ] Test result dashboard
- [ ] Automated test generation

## Resources

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [BATS GitHub](https://github.com/bats-core/bats-core)
- [Shell Testing Guide](https://google.github.io/styleguide/shellguide.html)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

**Last Updated**: January 2025  
**Test Coverage**: 65 unit tests  
**Target Coverage**: 70%+

