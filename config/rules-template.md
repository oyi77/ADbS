# AI Development Workflow Enforcement Rules

## Overview

This project uses **SDD (Specification-Driven Development)** and **Beads** task management to ensure systematic, high-quality development and prevent AI hallucinations.

## Workflow Stages

You MUST follow these stages in order:

1. **Explore** - Research and understand the problem
2. **Plan** - Outline objectives and approach
3. **SDD - Requirements** - Define functional and non-functional requirements
4. **SDD - Design** - Create architecture and design documents
5. **SDD - Tasks** - Break down work into specific tasks
6. **Assign** - Use Beads (or task manager) to track tasks
7. **Execution** - Implement and test

## Stage Enforcement

### Before Starting Any Stage

1. Check the current stage: Read `.workflow-enforcer/current-stage`
2. Validate previous stage completion: Run `adbs validate`
3. Only proceed if validation passes

### Stage Requirements

#### Explore Stage
- Document research findings
- Understand problem domain
- Identify constraints and assumptions
- Create exploration notes in `.workflow-enforcer/artifacts/explore.md`

#### Plan Stage
- Outline high-level objectives
- Define strategies and approach
- Create plan document in `.workflow-enforcer/artifacts/plan.md`

#### SDD - Requirements Stage
- Use template: `templates/sdd/requirements.md.template`
- Define functional requirements with acceptance criteria
- Define non-functional requirements (performance, security, scalability)
- Document constraints and assumptions
- Save to `.workflow-enforcer/artifacts/requirements.md`
- Minimum 500 words required

#### SDD - Design Stage
- Use template: `templates/sdd/design.md.template`
- Define architecture and components
- Document data flow
- Specify technology choices with rationale
- Document security and error handling
- Save to `.workflow-enforcer/artifacts/design.md`
- Minimum 500 words required

#### SDD - Tasks Stage
- Use template: `templates/sdd/tasks.md.template`
- Break down work into specific, actionable tasks
- Define task dependencies
- Prioritize tasks
- Minimum 3 tasks required
- Save to `.workflow-enforcer/artifacts/tasks.md`

#### Assign Stage
- Use Beads (or task manager) to create tasks
- Command: `adbs task create "Task description"`
- Link tasks to requirements and design
- Set task dependencies
- Update task status as work progresses

#### Execution Stage
- Implement tasks in priority order
- Follow design specifications
- Update task status: `adbs task update <id> --status in-progress`
- Mark tasks complete: `adbs task update <id> --status done`

## SDD Enforcement Rules

### Requirements Must Include:
- Functional requirements with acceptance criteria
- Non-functional requirements (performance, security, scalability)
- Constraints and assumptions
- Dependencies

### Design Must Include:
- Architecture overview
- Component design
- Data flow diagrams/descriptions
- Technology choices with rationale
- Security considerations
- Error handling strategy

### Tasks Must Include:
- Specific, actionable task descriptions
- Priority levels
- Dependencies between tasks
- Acceptance criteria per task
- Minimum 3 tasks

## Beads Integration

### Using Beads

If Beads is available, use it for task management:

```bash
# Create a task
bd create "Task description" --priority 1

# List tasks
bd list

# Update task status
bd update <id> --status in-progress

# Mark task complete
bd update <id> --status done
```

### Using Alternative Task Manager

If Beads is not available, use the alternative:

```bash
# Create a task
adbs task create "Task description" --priority high

# List tasks
adbs task list

# Update task status
adbs task update <id> --status in-progress

# Mark task complete
adbs task update <id> --status done
```

## Validation Rules

### Stage Transition Rules

- **Explore → Plan**: Exploration notes must exist
- **Plan → Requirements**: Plan document must exist
- **Requirements → Design**: Requirements document must be complete (500+ words, all required sections)
- **Design → Tasks**: Design document must be complete (500+ words, all required sections)
- **Tasks → Assign**: Tasks document must have minimum 3 tasks
- **Assign → Execution**: At least one task must be created in task manager

### Validation Commands

```bash
# Validate current stage
adbs validate

# Move to next stage (only if validation passes)
adbs next
```

## Prohibited Behaviors

1. **DO NOT** skip stages - each stage must be completed before moving to the next
2. **DO NOT** start implementation without completing requirements and design
3. **DO NOT** create tasks without linking them to requirements
4. **DO NOT** proceed to execution without task assignment
5. **DO NOT** modify artifacts after stage completion without validation

## Best Practices

1. **Always validate** before moving to the next stage
2. **Document thoroughly** - better to over-document than under-document
3. **Link artifacts** - reference requirements in design, design in tasks
4. **Update task status** regularly as work progresses
5. **Review and refine** - iterate on requirements and design before execution

## File Locations

- Current stage: `.workflow-enforcer/current-stage`
- Artifacts: `.workflow-enforcer/artifacts/`
- Tasks: `.workflow-enforcer/tasks.json` (if using alternative task manager)
- Configuration: `config/workflow.yaml`
- Templates: `templates/sdd/`

## Getting Help

- Check workflow status: `adbs status`
- Validate current stage: `adbs validate`
- View configuration: `cat config/workflow.yaml`

**Note**: `adbs` is a shorter alias for `workflow-enforcer`. Both commands work identically.

Remember: Following this workflow prevents hallucinations, ensures quality, and maintains systematic development practices.

