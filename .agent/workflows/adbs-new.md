---
description: Auto-generate complete workflow (requirements, proposal, design, tasks) from feature description.
---
<!-- ADBS:WORKFLOW:START -->
**Guardrails**
- This workflow automatically generates a complete development workflow from a simple feature description
- Always create ALL files: requirements.md, proposal.md, design.md, tasks.md
- Be specific and measurable in all outputs
- Focus on WHAT needs to be built, not HOW to build it (that comes in implementation)
- Ask clarifying questions if the feature description is vague or ambiguous

**Steps**

1. **Understand Context**
   - Read the feature description provided by the user
   - Review existing codebase structure (use `ls`, `rg` to explore)
   - Identify related files, components, or patterns
   - Note any gaps or ambiguities that need clarification

2. **Extract Requirements** → `requirements.md`
   - Identify functional requirements (what the feature must do)
   - Identify non-functional requirements (performance, security, maintainability)
   - Assign priorities (Critical/High/Medium/Low)
   - Define acceptance criteria for each requirement
   - Make requirements specific and measurable
   
   **Format:**
   ```markdown
   # Requirements
   
   ## Functional Requirements
   
   ### FR-1: [Requirement Name]
   **Description:** [Clear, specific description]
   **Priority:** [High/Medium/Low]
   **Acceptance Criteria:**
   - [Measurable criterion 1]
   - [Measurable criterion 2]
   
   ## Non-Functional Requirements
   
   ### NFR-1: [Requirement Name]
   **Description:** [Clear description]
   **Priority:** [Critical/High/Medium/Low]
   **Metric:** [How to measure]
   ```

3. **Create Proposal** → `proposal.md`
   - Define WHAT is being built (clear, concise)
   - Explain WHY it's needed (business value, user benefit)
   - Outline HOW at high level (3-5 key steps)
   - List measurable success criteria
   - Identify risks with mitigations
   - List dependencies
   - Estimate timeline (Small/Medium/Large)
   
   **Format:**
   ```markdown
   # [Feature Name]
   
   ## What are we building?
   [Clear description]
   
   ## Why?
   [Business value and user benefit]
   
   ## How?
   [High-level approach - 3-5 steps]
   
   ## Success Criteria
   - [ ] [Measurable criterion 1]
   - [ ] [Measurable criterion 2]
   
   ## Risks
   - [Risk 1 and mitigation]
   
   ## Dependencies
   - [Dependency 1]
   
   ## Timeline Estimate
   [Small/Medium/Large]
   ```

4. **Design Architecture** → `design.md`
   - Define architecture overview
   - Identify components and their responsibilities
   - Design data flow between components
   - Define data models
   - Document security considerations
   - Document performance considerations
   - Outline testing strategy
   
   **Format:**
   ```markdown
   # Technical Design: [Feature Name]
   
   ## Architecture Overview
   [High-level description]
   
   ## Components
   
   ### Component 1: [Name]
   **Purpose:** [What it does]
   **Responsibilities:**
   - [Responsibility 1]
   
   **Interfaces:**
   - [Interface 1]
   
   ## Data Flow
   \`\`\`
   [ASCII diagram]
   User → Component A → Component B → Result
   \`\`\`
   
   ## Data Models
   [Define data structures]
   
   ## Security Considerations
   - [Security measure 1]
   
   ## Performance Considerations
   - [Performance consideration 1]
   
   ## Testing Strategy
   - [Testing approach 1]
   ```

5. **Break Down Tasks** → `tasks.md`
   - Organize into phases (Planning, Setup, Implementation, Testing, Review)
   - Create small, specific tasks (1-4 hours each)
   - Order by dependencies
   - Include validation steps
   - Mark planning phase as complete
   
   **Format:**
   ```markdown
   # Tasks: [Feature Name]
   
   ## Phase 1: Planning ✓
   - [x] Extract requirements
   - [x] Create proposal
   - [x] Design architecture
   - [x] Break down tasks
   
   ## Phase 2: Setup
   - [ ] [Setup task 1]
   
   ## Phase 3: Implementation
   - [ ] [Implementation task 1]
     - [ ] [Subtask 1.1]
   
   ## Phase 4: Testing
   - [ ] [Testing task 1]
   
   ## Phase 5: Review
   - [ ] Code review
   - [ ] Security review
   ```

6. **Initialize State Tracking**
   - State is automatically initialized to "planning" (completed)
   - Ready to advance to "designing" after user approval

7. **Present to User**
   - Show summary of generated files
   - Show current state (PLANNING completed)
   - Show next steps (review and approve)
   - Provide commands for next actions

**Validation Checklist**

Before completing, verify:
- [ ] requirements.md exists with at least 3 requirements
- [ ] proposal.md exists with measurable success criteria
- [ ] design.md exists with components and data flow
- [ ] tasks.md exists with tasks broken into phases
- [ ] All requirements have acceptance criteria
- [ ] All success criteria are measurable
- [ ] All tasks are small and specific
- [ ] Dependencies are identified

**Output Format**

After generating all files, output:
```
Generating workflow...
  ✓ Extracted [N] requirements
  ✓ Generated proposal
  ✓ Created design scaffold
  ✓ Broke down into [N] tasks

Created work: [work-name]
Location: .adbs/work/[work-id]/

Generated files:
  • requirements.md ([N] requirements)
  • proposal.md (scope, approach, success criteria)
  • design.md (architecture, components, data flow)
  • tasks.md ([N] tasks across [M] phases)

Current state: PLANNING (completed)
Next step: Review proposal and approve

Commands:
  adbs show [work-name]           # View proposal
  adbs workflow [work-name]       # View workflow status
  adbs progress [work-name]       # Check if ready to advance
  adbs approve [work-name]        # Approve and advance to DESIGNING
```

**Reference**
- Keep requirements focused on WHAT, not HOW
- Make success criteria testable and measurable
- Design should be detailed enough to implement from
- Tasks should be small enough to complete in one session
- Always consider security, performance, and testing

<!-- ADBS:WORKFLOW:END -->
