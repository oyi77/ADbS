# ADbS Testing Suite

This directory contains the automated test suite for ADbS (Ai Don't be Stupid).

## Structure

```
tests/
├── test_helper.bash       # Common test utilities and setup
├── unit/                  # Unit tests for individual components
├── integration/           # Integration tests for workflows
├── fixtures/              # Test data and mock files
└── README.md             # This file
```

## Running Tests

### Prerequisites

Install BATS (Bash Automated Testing System):

**Windows (PowerShell):**
```powershell
npm install -g bats
```

**macOS:**
```bash
brew install bats-core
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install bats
```

### Run All Tests

```bash
# From project root
bats tests/

# With tap output
bats tests/ -t

# Verbose output
bats tests/ --verbose
```

### Run Specific Test Files

```bash
# Run unit tests only
bats tests/unit/

# Run a specific test file
bats tests/unit/test_platform_detector.bats
```

## Writing Tests

### Test File Naming

- Unit tests: `test_<component>.bats`
- Integration tests: `test_<workflow>_workflow.bats`

### Test Structure

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
    local test_data="value"
    
    # Act
    run some_command "$test_data"
    
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected"* ]]
}
```

### Test Naming Convention

Use descriptive names following this pattern:
```
component_function_scenario_expectedResult
```

Examples:
- `validator_getCurrentStage_whenStageExists_returnsStage`
- `taskManager_createTask_whenValidInput_createsTask`
- `openspec_propose_whenValidName_createsProposal`

## Test Coverage

Current coverage goals:
- **Week 1**: 30% (core functions)
- **Week 2**: 50% (main workflows)
- **Week 3**: 60% (edge cases)
- **Week 4**: 70% (error handling)
- **Week 5**: 70%+ (polish)

## CI/CD

Tests run automatically on:
- Every push to `main` or `develop`
- Every pull request
- Platforms: Ubuntu, macOS, Windows

See `.github/workflows/test.yml` for CI configuration.

## Debugging Tests

### Run with Debug Output

```bash
# Show all output
bats tests/unit/test_file.bats --verbose

# Show specific debug messages
# In your test, use: echo "DEBUG: $var" >&3
bats tests/unit/test_file.bats --tap
```

### Common Issues

**Test fails with "command not found":**
- Ensure scripts are executable: `chmod +x lib/**/*.sh`
- Check PATH includes project bin directory

**Temporary directory not cleaned up:**
- Check `teardown()` is called
- Manually clean: `rm -rf /tmp/tmp.*`

**Tests pass locally but fail in CI:**
- Check platform-specific commands
- Verify all dependencies are installed in CI
- Review GitHub Actions logs

## Best Practices

1. **Keep tests fast** - Aim for < 5 minutes total
2. **Make tests independent** - No shared state between tests
3. **Use descriptive names** - Test name should explain what it tests
4. **Test one thing** - Each test should verify one behavior
5. **Clean up** - Always clean up in teardown
6. **Mock external dependencies** - Don't rely on network, external services

## Helper Functions

Available in `test_helper.bash`:

- `setup_test_env()` - Initialize test environment
- `teardown_test_env()` - Clean up after tests
- `create_sample_plan()` - Generate sample plan file
- `create_sample_requirements()` - Generate sample requirements
- `create_sample_design()` - Generate sample design
- `create_sample_tasks()` - Generate sample tasks
- `assert_file_exists()` - Assert file exists
- `assert_dir_exists()` - Assert directory exists
- `assert_contains()` - Assert string contains substring

## Resources

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [BATS GitHub](https://github.com/bats-core/bats-core)
- [Shell Testing Best Practices](https://google.github.io/styleguide/shellguide.html)

## Contributing

When adding new tests:

1. Follow the naming convention
2. Use test helper functions
3. Add comments for complex logic
4. Ensure tests pass locally before committing
5. Update this README if adding new patterns

---

**Last Updated**: December 25, 2025  
**Test Coverage**: 0% (initial setup)  
**Target Coverage**: 70%+
