---
title: "Contributing"
description: "How to contribute to ADbS"
date: 2025-01-01
weight: 60
---

# Contributing to ADbS

Thank you for your interest in contributing to ADbS! We welcome contributions from everyone.

## Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/ADbS.git
   cd ADbS
   ```
3. **Run the tests** to ensure everything is working:
   ```bash
   bats tests/unit/ tests/integration/
   ```

## Development Workflow

We use **ADbS** to develop **ADbS**. Please follow the workflows described below.

### Small Features & Bug Fixes

For discrete changes, use the standard ADbS workflow:

1. **Start new work**:
   ```bash
   adbs new "fix-bug-in-generator"
   ```

2. **Edit the Proposal**:
   Modify `.adbs/work/<date>-fix-bug-in-generator/proposal.md` to describe your plan.

3. **Implement & Test**:
   Write your code and tests. Ensure `bats tests/` passes.

4. **Complete the work**:
   When complete, mark it as done:
   ```bash
   adbs done "fix-bug-in-generator"
   ```

### Major Features

For large architectural changes:

1. **Start new work**:
   ```bash
   adbs new "major-feature-name"
   ```

2. **Create detailed proposal**:
   Edit `.adbs/work/<date>-major-feature-name/proposal.md` with:
   - What you're building
   - Why you're building it
   - How you'll approach it
   - When it's done (checklist)

3. **Break down into tasks**:
   ```bash
   adbs todo "Research approach"
   adbs todo "Design architecture"
   adbs todo "Implement core functionality"
   adbs todo "Write tests"
   ```

4. **Implement & Test**:
   Work through your tasks, ensuring tests pass.

5. **Complete the work**:
   ```bash
   adbs done "major-feature-name"
   ```

## Code Standards

### Shell Scripts

- Use `#!/bin/bash`
- Use `set -e` to fail fast
- Follow POSIX standards where possible
- Variable names: `snake_case`
- Add comments for complex logic

### Tests

- Write tests for every new feature or bug fix
- Use [BATS](https://github.com/bats-core/bats-core)
- Place unit tests in `tests/unit/` and integration tests in `tests/integration/`
- Ensure all tests pass before submitting

### Documentation

- Update relevant documentation when adding features
- Keep code comments clear and concise
- Update examples if behavior changes

## Submitting a Pull Request

1. **Push your changes** to your fork:
   ```bash
   git push origin your-branch-name
   ```

2. **Open a Pull Request** against the `main` branch on GitHub.

3. **Ensure all CI checks pass**:
   - Tests must pass
   - Code must follow style guidelines
   - Documentation must be updated if needed

4. **Provide a clear description**:
   - What changes you made
   - Why you made them
   - How to test the changes
   - Any breaking changes

### Pull Request Template

When opening a PR, include:

- **Description**: What this PR does
- **Type**: Bug fix, feature, documentation, etc.
- **Testing**: How to test the changes
- **Checklist**: Confirm you've completed necessary steps

## Areas for Contribution

We welcome contributions in these areas:

- **Bug fixes**: Report and fix issues
- **New features**: Propose and implement new functionality
- **Documentation**: Improve guides, examples, and API docs
- **Tests**: Add test coverage
- **Examples**: Create example projects or workflows
- **IDE support**: Add support for new IDEs
- **Performance**: Optimize existing code

## Getting Help

- **Questions?** Open an issue on GitHub
- **Found a bug?** Report it in the issues
- **Want to discuss?** Open a discussion thread

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to ADbS! 🎉

