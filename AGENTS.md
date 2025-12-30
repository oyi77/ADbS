<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

<!-- ADBS:START -->
# ADbS Workflow Instructions

These instructions are for AI assistants working with ADbS.

## When User Creates New Work

When the user runs `adbs new "feature description"` or `adbs new "feature description" --ai-generate`:

1. **Automatically trigger workflow generation** by reading `.agent/workflows/adbs-new.md`
2. **Generate ALL required files**:
   - `requirements.md` - Extract functional and non-functional requirements
   - `proposal.md` - Create proposal with scope, approach, success criteria
   - `design.md` - Design architecture, components, data flow
   - `tasks.md` - Break down into small, actionable tasks
3. **Follow the guardrails** in `adbs-new.md` strictly
4. **Ask clarifying questions** if feature description is vague

## Workflow States

Work progresses through these states:
- **PLANNING** - Requirements, proposal, design created (auto-generated)
- **DESIGNING** - Review and refine design
- **IMPLEMENTING** - Write code following design
- **TESTING** - Run tests, verify quality
- **REVIEWING** - Code review, security check
- **DONE** - Complete and archived

## Agent Roles

Follow these role-specific rules:

### Planner Agent (PLANNING state)
- Read: `.agent/workflows/adbs-new.md`
- Create: requirements.md, proposal.md, design.md, tasks.md
- Focus: WHAT to build, not HOW

### Designer Agent (DESIGNING state)
- Read: `templates/agents/designer.md` (when created)
- Refine: design.md based on feedback
- Focus: Architecture, components, interfaces

### Implementer Agent (IMPLEMENTING state)
- Read: `templates/agents/implementer.md`
- Write: Code following design.md
- Write: Tests for all code
- Validate: Linting passes, tests pass, coverage >80%

### Reviewer Agent (REVIEWING state)
- Read: `templates/agents/reviewer.md` (when created)
- Review: Code quality, security, test coverage
- Approve or request changes

## Commands for AI

When working with ADbS:

```bash
# Check current state
adbs workflow <work-name>

# Check if ready to advance
adbs progress <work-name>

# Advance to next state
adbs advance <work-name>

# View work details
adbs show <work-name>
```

## Key Principles

1. **Auto-generate workflows** - Don't ask user to create requirements/design manually
2. **Be specific** - All requirements and success criteria must be measurable
3. **Validate gates** - Can't advance states without meeting criteria
4. **Maintain quality** - Code must pass linting, tests, coverage checks
5. **Follow design** - Implementation must match design.md

<!-- ADBS:END -->