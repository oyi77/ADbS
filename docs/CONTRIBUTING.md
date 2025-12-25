# Contributing to ADbS

Thank you for your interest in contributing to ADbS! We welcome contributions from everyone.

## Getting Started

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** locally:
    ```bash
    git clone https://github.com/your-username/ADbS.git
    cd ADbS
    ```
3.  **Run the tests** to ensure everything is working:
    ```bash
    bats tests/unit/ tests/integration/
    ```

## Development Workflow

We use **ADbS** to develop **ADbS**. Please follow the workflows described below.

### 1. Small Features & Bug Fixes (OpenSpec)

For discrete changes, use the **OpenSpec** workflow:

1.  **Initialize OpenSpec** (if not already done):
    ```bash
    adbs openspec init
    ```
2.  **Propose a Change**:
    ```bash
    adbs openspec propose "fix-bug-in-generator"
    ```
3.  **Edit the Proposal**:
    Modify `.openspec/changes/<date>-fix-bug-in-generator/proposal.md` to describe your plan.
4.  **Implement & Test**:
    Write your code and tests. ensure `bats tests/` passes.
5.  **Archive**:
    When complete, archive the proposal:
    ```bash
    adbs openspec archive "<date>-fix-bug-in-generator"
    ```

### 2. Major Features (Classic SDD)

For large architectural changes, use the **Classic SDD** workflow:

1.  **Initialize SDD**:
    ```bash
    adbs init
    ```
2.  **Follow the Stages**:
    *   **Explore**: Research and list files.
    *   **Plan**: Create a plan in `.sdd/plans/`.
    *   **Requirements**: Define requirements in `.sdd/requirements/`.
    *   **Design**: Create technical design in `.sdd/designs/`.
    *   **Tasks**: Break down work in `.sdd/tasks/`.
3.  **Validate & Advance**:
    Run `adbs validate` and `adbs next` to move through stages.

## Code Standards

*   **Shell Scripts**:
    *   Use `#!/bin/bash`.
    *   Use `set -e` to fail fast.
    *   Follow POSIX standards where possible.
    *   Variable names: `snake_case`.
*   **Tests**:
    *   Write tests for every new feature or bug fix.
    *   Use [BATS](https://github.com/bats-core/bats-core).
    *   Place unit tests in `tests/unit/` and integration tests in `tests/integration/`.

## Submitting a Pull Request

1.  Push your changes to your fork.
2.  Open a Pull Request against the `main` branch.
3.  Ensure all CI checks pass.
4.  Provide a clear description of your changes.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
