# ADbS Evolution Plan: OpenCode Integration & Mobile Parity

## TL;DR

> **Quick Summary**: Transform ADbS from a dual-script (Bash/PS1) workflow enforcer into a unified Go binary that runs everywhere—from Windows to Linux to "mere Android" (Termux) and iOS (iSH). Integrate as a first-class plugin for `oh-my-opencode` and maintain tiered feature compatibility (Core everywhere, Advanced desktop-only).

> **Deliverables**:
- Go-based CLI binary (adbs) replacing Shell/PS1 scripts
- OpenCode Skill plugin (adbs-skill) for integration
- Tiered Memory engine (Go core + Python optional)
- Static HTML Dashboard generator
- Multi-arch release pipeline (ARM64, 386, AMD64)

> **Estimated Effort**: Large (3-5 days)
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Go Core CLI → OpenCode Integration → Distribution

---

## Context

### Original Request
User wants to:
1. Complete all missing features in ADbS (OpenSpec, Memory, Dashboard)
2. Integrate with oh-my-opencode as a plugin
3. Support mobile environments (Termux on Android, iSH on iOS)
4. Ensure full E2E test coverage

### Interview Summary
**Key Discussions**:
- **Mobile Constraint**: "Mere Android" with Termux means zero runtime dependencies
- **OpenCode Integration**: ADbS should act as a Skill that Sisyphus calls to enforce SDD workflow
- **Parity Debt**: Current codebase spends ~40% effort maintaining Bash/PS1 dual implementations

**Research Findings**:
- oh-my-opencode exposes plugin/skill interface via ~/.config/opencode/opencode.json
- Termux has bash but lacks GNU extensions
- Go produces static binaries (5-15MB) that work on ARM64 (Android), 386 (iSH)

### Metis Review
**Identified Gaps** (addressed):
- Path Handling: Termux uses $PREFIX - added explicit path detection
- Memory ML Dependencies: sentence_transformers impossible on mobile - tiered approach added
- Installer Assumptions: /usr/local doesn't exist on mobile - added $HOME/.local/bin fallback

---

## Work Objectives

### Core Objective
Transform ADbS into a zero-dependency, cross-platform CLI that:
- Runs natively on Windows, Linux, macOS, Termux (Android), and iSH (iOS)
- Integrates as a Skill plugin for oh-my-opencode
- Maintains 100% backward compatibility with existing workflows

### Concrete Deliverables
1. cmd/adbs/main.go - Unified Go binary entry point
2. internal/cli/ - Command implementation (new, status, done, todo, etc.)
3. internal/memory/ - Native Go KV store + optional Python bridge
4. internal/dashboard/ - Static HTML generator
5. opencode-skill/adbs-skill.json - OpenCode plugin configuration
6. distribution/ - Updated installers for all platforms

### Definition of Done
- adbs --help works identically on all platforms
- adbs setup creates valid .adbs/ structure on Termux/Android
- OpenCode can invoke adbs plan as a Skill
- Memory read/write works without Python
- Dashboard opens in mobile browser as static HTML

### Must Have
- Core CLI commands (new, status, done, list, todo, update)
- Task management (tasks.json read/write)
- OpenSpec proposal generation
- Static Dashboard HTML
- Mobile-compatible installation script

### Must NOT Have (Guardrails)
- NO Python/Node runtime dependency for core functionality
- NO Bash/GNU utils dependency on mobile
- NO GUI requirements (must work in terminal-only envs)
- NO semantic search/Machine Learning on mobile devices
- NO breaking changes to existing .adbs/ data format

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.

### Test Decision
- **Infrastructure exists**: YES (existing bash tests)
- **Automated tests**: Tests-after (porting existing + new Go tests)
- **Framework**: Go testing + Bash smoke tests

### Agent-Executed QA Scenarios

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| CLI/Backend | Bash | Run ./adbs --help, assert stdout contains expected commands |
| Mobile/Restricted | interactive_bash (tmux) | Simulate Termux env, verify no Python/Node calls |
| OpenCode Plugin | Bash (curl) | Validate JSON schema for adbs-skill.json |
| Dashboard | Playwright | Generate HTML, assert file exists, check structure |

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Start Immediately):
├── Task 1: Design Go Architecture & Project Structure
├── Task 2: Implement Core CLI Commands (setup, new, status, done)
└── Task 3: Set up Cross-Compilation Pipeline

Wave 2 (After Wave 1):
├── Task 4: Implement Task Manager (JSON read/write)
├── Task 5: Implement OpenSpec Proposal Engine
├── Task 6: Implement Tiered Memory Engine (Go core)
└── Task 7: Create OpenCode Skill Plugin

Wave 3 (After Wave 2):
├── Task 8: Generate Static Dashboard HTML
├── Task 9: Create Mobile Installation Scripts
├── Task 10: Port Existing Bash Tests to Go
└── Task 11: Smoke Test on Termux (Docker simulation)

Critical Path: Task 1 → Task 2 → Task 4 → Task 7
Parallel Speedup: ~50% faster than sequential

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 3, 4, 5 | None (foundation) |
| 2 | 1 | 4, 5, 7 | 3 |
| 3 | 1 | 11 | 2 |
| 4 | 2 | None | 5, 6, 7 |
| 5 | 2 | None | 4, 6, 7 |
| 6 | 2 | None | 4, 5, 7 |
| 7 | 2, 4, 5 | None | 4, 5, 6 |
| 8 | 2, 4 | None | 9, 10 |
| 9 | 3 | None | 8, 10 |
| 10 | 3 | None | 8, 9 |
| 11 | 3, 9 | None | 8, 10 |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 2, 3 | ultrabrain with git-master |
| 2 | 4, 5, 6, 7 | deep research agent |
| 3 | 8, 9, 10, 11 | visual-engineering with playwright |

---

## TODOs

> Implementation + Test = ONE Task. Never separate.

### Task 1: Design Go Architecture & Project Structure

**What to do**:
- Create cmd/adbs/main.go entry point
- Design internal/cli/ command router pattern
- Define data structures in internal/models/ (Task, Work, Config)
- Establish internal/storage/ for JSON file operations

**Must NOT do**:
- NO Bash script generation (deferred)
- NO Dashboard code (separate task)

**Recommended Agent Profile**:
- Category: ultrabrain (architectural decisions require trade-off analysis)
- Skills: git-master (reference existing Bash implementations)

**Parallelization**: Sequential (Foundation) | Blocks: Tasks 2, 3

**References**:
- bin/workflow-enforcer:1-50 - Command routing logic
- lib/internal/task_backend.sh:20-80 - JSON parsing patterns
- docs/ARCHITECTURE.md:Data Flow - Data flow specification

**Acceptance Criteria**:
- CLI entry point returns help on all platforms
- Cross-platform path handling works
- Custom ADBS_HOME respected

**Commit**: YES
- Message: feat(core): initialize Go project structure
- Files: cmd/adbs/main.go, internal/cli/, internal/models/, internal/storage/

---

### Task 2: Implement Core CLI Commands

**What to do**:
- Implement setup command: Create .adbs/ directory structure
- Implement new command: Create new work item with proposal.md
- Implement status command: Show active work
- Implement done command: Archive work item
- Implement list command: Show all work items
- Implement todo command: Add/update tasks
- Implement update command: Modify task fields

**Must NOT do**:
- NO OpenCode integration (separate task)
- NO Dashboard generation (separate task)

**Recommended Agent Profile**:
- Category: quick (porting existing Bash logic)

**Parallelization**: YES (with Task 3) | Blocks: Tasks 4, 5, 7

**References**:
- lib/internal/work_manager.sh:50-120 - Work item creation
- lib/internal/state_machine.sh:20-80 - State transitions
- config/commands/adbs-new.md - Command specification

**Acceptance Criteria**:
- setup creates valid directory structure
- new creates work item with proposal
- status shows active work
- done archives work item

**Commit**: YES
- Message: feat(core): implement core CLI commands

---

### Task 3: Set up Cross-Compilation Pipeline

**What to do**:
- Configure Makefile for multi-arch builds
- Build for: linux/arm64, linux/386, darwin/amd64, darwin/arm64, windows/amd64
- Create GitHub Actions workflow for automated releases

**Must NOT do**:
- NO installer scripts yet (separate task)

**Recommended Agent Profile**:
- Category: quick (CI/CD configuration)

**Parallelization**: YES (with Task 2) | Blocks: Tasks 9, 10, 11

**References**:
- distribution/scripts/build_packages.sh - Existing build logic
- distribution/scripts/build_packages.ps1 - Windows build logic

**Acceptance Criteria**:
- make build-all produces binaries for all platforms
- Binaries are < 15MB each
- SHA256 checksums generated

**Commit**: YES
- Message: ci: add cross-compilation pipeline

---

### Task 4: Implement Task Manager

**What to do**:
- Implement tasks.json read/write operations
- Support task creation, update, completion
- Handle task dependencies and ordering

**Recommended Agent Profile**:
- Category: quick

**Parallelization**: YES | Blocked By: Task 2

**References**:
- lib/task_manager/simple.sh - Task CRUD operations
- tests/fixtures/tasks/simple_tasks.json - Test fixtures

**Acceptance Criteria**:
- Tasks created via CLI appear in tasks.json
- Task updates persist correctly
- Task completion moves items to done state

---

### Task 5: Implement OpenSpec Proposal Engine

**What to do**:
- Implement proposal.md template generation
- Support structured proposal sections (Context, Work Objectives, TODOs)
- Generate proposal based on user input

**Recommended Agent Profile**:
- Category: deep

**Parallelization**: YES | Blocked By: Task 2

**References**:
- templates/sdd/ - Proposal templates
- .agent/workflows/ - OpenSpec workflows

**Acceptance Criteria**:
- adbs new "feature" generates valid proposal.md
- Proposal contains required sections
- Template variables replaced correctly

---

### Task 6: Implement Tiered Memory Engine

**What to do**:
- Implement native Go KV store for preferences
- Create optional Python bridge for advanced indexing
- Ensure backward compatibility with existing memory.conf

**Recommended Agent Profile**:
- Category: deep

**Parallelization**: YES | Blocked By: Task 2

**References**:
- lib/internal/memory.sh - Memory operations
- lib/memory.py - Advanced indexing (optional)

**Acceptance Criteria**:
- Memory read/write works without Python
- Preferences persist across sessions
- Python bridge available but not required

---

### Task 7: Create OpenCode Skill Plugin

**What to do**:
- Create adbs-skill.json configuration
- Define skill interface for OpenCode
- Document integration steps

**Recommended Agent Profile**:
- Category: deep

**Parallelization**: YES | Blocked By: Task 2

**References**:
- .agent/rules/adbs_development.md - Existing ADbS rules
- OpenCode plugin documentation

**Acceptance Criteria**:
- adbs-skill.json validates against OpenCode schema
- OpenCode can invoke ADbS commands
- Skill appears in OpenCode skill list

---

### Task 8: Generate Static Dashboard HTML

**What to do**:
- Generate static HTML dashboard
- Include work items, tasks, and statistics
- Ensure mobile-friendly responsive design

**Recommended Agent Profile**:
- Category: visual-engineering

**Parallelization**: YES | Blocked By: Task 2

**References**:
- dashboard/src/ - Existing React dashboard
- lib/internal/dashboard.sh - Dashboard generation

**Acceptance Criteria**:
- adbs dashboard generates index.html
- Dashboard works in mobile browser
- All data displayed correctly

---

### Task 9: Create Mobile Installation Scripts

**What to do**:
- Update install.sh for Termux (use $PREFIX)
- Create install.ps1 for Windows
- Document mobile-specific setup

**Recommended Agent Profile**:
- Category: quick

**Parallelization**: YES | Blocked By: Task 3

**References**:
- distribution/install.sh - Existing installer
- distribution/install.ps1 - PowerShell installer

**Acceptance Criteria**:
- Termux installation works
- Binary added to PATH
- First-run setup succeeds

---

### Task 10: Port Existing Bash Tests to Go

**What to do**:
- Port tests/ bash tests to Go
- Add unit tests for CLI commands
- Add integration tests for workflow

**Recommended Agent Profile**:
- Category: quick

**Parallelization**: YES | Blocked By: Task 3

**References**:
- tests/ - Existing test suite
- tests/fixtures/ - Test fixtures

**Acceptance Criteria**:
- All CLI commands have test coverage
- Tests pass on all platforms
- Coverage > 80%

---

### Task 11: Smoke Test on Termux

**What to do**:
- Simulate Termux environment using Docker
- Run core CLI commands
- Verify no runtime dependencies missing

**Recommended Agent Profile**:
- Category: quick

**Parallelization**: YES | Blocked By: Task 3, 9

**References**:
- .github/workflows/test.yml - CI configuration

**Acceptance Criteria**:
- Docker-based Termux simulation runs
- All core commands execute successfully
- No "command not found" errors

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | feat(core): initialize Go project structure | cmd/, internal/ | go build |
| 2 | feat(core): implement core CLI commands | internal/cli/*.go | ./adbs --help |
| 3 | ci: add cross-compilation pipeline | Makefile, .github/workflows/ | Binary artifacts |
| 4 | feat(core): implement task manager | internal/storage/ | Tasks CRUD |
| 5 | feat(core): implement OpenSpec proposal | internal/openspec/ | Proposal generation |
| 6 | feat(core): implement memory engine | internal/memory/ | Memory CRUD |
| 7 | feat(plugin): add OpenCode integration | opencode-skill/ | JSON validation |
| 8 | feat(ui): generate static dashboard | internal/dashboard/ | HTML generation |
| 9 | dist: create mobile installers | distribution/ | Installation test |
| 10 | test: port bash tests to Go | *_test.go | go test |
| 11 | ci: smoke test on Termux | tests/termux/ | Docker simulation |

---

## Success Criteria

### Verification Commands
```
# All platforms
./adbs --help
./adbs setup
./adbs new "test"
./adbs status
./adbs todo "task"
./adbs done "test"

# OpenCode integration
cat opencode-skill/adbs-skill.json | jq .

# Dashboard
cat dashboard.html | grep "Active Work"

# Cross-compilation
make build-all
ls -lh adbs-*
```

### Final Checklist
- [x] Go binary works on Windows, Linux, macOS
- [x] Go binary works on Termux (Android)
- [x] OpenCode integration functions correctly
- [x] Memory engine works without Python
- [x] Dashboard generates static HTML
- [x] All existing workflows preserved
- [x] Test coverage > 80%
