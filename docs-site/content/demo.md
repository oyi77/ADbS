---
title: "Demo"
description: "See ADbS in action with interactive code examples"
date: 2025-01-01
weight: 40
---

# Demo: ADbS in Action

See how ADbS helps you work more effectively with AI coding assistants through practical examples.

## Complete Workflow Example

Let's walk through a complete example of using ADbS to build a feature from start to finish.

### Step 1: Initialize ADbS

First, set up ADbS in your project:

```bash
$ adbs setup
✓ ADbS initialized successfully
✓ Detected IDE: Cursor
✓ Generated rules for Cursor
✓ Ready to use!
```

### Step 2: Start New Work

Create a new work item for a feature you want to build:

```bash
$ adbs new "add payment processing"
✓ Started new work: add payment processing

Next steps:
  1. Edit the work plan: .adbs/work/2025-12-30-add-payment-processing/proposal.md
  2. Check status: adbs status
  3. Mark done: adbs done "add payment processing"
```

### Step 3: Check Status

See what you're currently working on:

```bash
$ adbs status
ADbS Status
===========

Active work: 1
Completed: 0

Active Work:

  • add payment processing
    Created: 2025-12-30
    Location: .adbs/work/2025-12-30-add-payment-processing/
```

### Step 4: Add Tasks

Break down the work into manageable tasks:

```bash
$ adbs todo "Research payment providers"
✓ Added task: Research payment providers

$ adbs todo "Implement Stripe integration" --priority high
✓ Added task: Implement Stripe integration (priority: high)

$ adbs todo "Write tests for payment flow" --tags "testing,payment"
✓ Added task: Write tests for payment flow (tags: testing, payment)
```

### Step 5: View All Work and Tasks

See everything at a glance:

```bash
$ adbs list
ADbS Work & Tasks
=================

Active Work:
  • add payment processing

Tasks:
  • Research payment providers (todo)
  • Implement Stripe integration (todo, priority: high)
  • Write tests for payment flow (todo, tags: testing, payment)
```

### Step 6: Work with Your AI Assistant

Now when you work with your AI assistant (Cursor, Windsurf, etc.), it automatically sees:

- Your active work: "add payment processing"
- The work plan in `.adbs/work/2025-12-30-add-payment-processing/proposal.md`
- Your tasks and priorities

Your AI stays focused on the payment processing feature and won't get distracted!

### Step 7: Update Work Plan

Edit the proposal file to keep your AI focused:

```markdown
# Add Payment Processing

## What are we building?
A payment processing system using Stripe that allows users to make purchases.

## Why?
Users need a way to purchase products in our application.

## How?
1. Research payment providers (Stripe, PayPal, etc.)
2. Integrate Stripe API
3. Create payment form component
4. Implement payment processing logic
5. Add error handling and validation
6. Write comprehensive tests

## Done when...
- [ ] Users can enter payment information
- [ ] Payments are processed securely via Stripe
- [ ] Payment errors are handled gracefully
- [ ] All tests pass
- [ ] Documentation is updated
```

### Step 8: Complete the Work

When you're finished, mark the work as complete:

```bash
$ adbs done "add payment processing"
✓ Completed: add payment processing

Archived to: .adbs/archive/2025-12-30-add-payment-processing
```

### Step 9: Final Status Check

```bash
$ adbs status
ADbS Status
===========

Active work: 0
Completed: 1

Completed Work:
  • add payment processing (completed: 2025-12-30)
```

## Command Examples

### Creating Multiple Work Items

```bash
$ adbs new "add user login"
✓ Started new work: add user login

$ adbs new "fix memory leak"
✓ Started new work: fix memory leak

$ adbs new "refactor database layer"
✓ Started new work: refactor database layer

$ adbs status
Active work: 3
  • add user login
  • fix memory leak
  • refactor database layer
```

### Managing Tasks with Priorities

```bash
$ adbs todo "Critical security fix" --priority high
✓ Added task: Critical security fix (priority: high)

$ adbs todo "Update documentation" --priority low
✓ Added task: Update documentation (priority: low)

$ adbs list --tasks --priority high
Tasks (high priority):
  • Critical security fix (todo)
```

### Filtering Tasks

```bash
$ adbs list --tasks --status todo
Tasks (todo):
  • Research payment providers
  • Implement Stripe integration
  • Write tests for payment flow

$ adbs list --tasks --status done
Tasks (done):
  • Set up development environment
  • Create project structure
```

### Viewing Work Details

```bash
$ adbs show "add payment processing"
Work: add payment processing
=============================

Created: 2025-12-30
Status: active
Location: .adbs/work/2025-12-30-add-payment-processing/

Proposal: .adbs/work/2025-12-30-add-payment-processing/proposal.md

Tasks:
  • Research payment providers (todo)
  • Implement Stripe integration (todo, priority: high)
  • Write tests for payment flow (todo)
```

### Updating Tasks

```bash
$ adbs update task-123 status done
✓ Updated task: Research payment providers (status: done)

$ adbs update task-456 priority medium
✓ Updated task: Implement Stripe integration (priority: medium)
```

## Real-World Scenarios

### Scenario 1: Starting a New Feature

```bash
# 1. Start the feature
$ adbs new "user authentication"

# 2. Add initial tasks
$ adbs todo "Design login form UI"
$ adbs todo "Implement authentication API"
$ adbs todo "Add password reset flow"

# 3. Check what you're working on
$ adbs status

# 4. Your AI assistant now knows:
#    - You're working on "user authentication"
#    - The tasks you need to complete
#    - The work plan in the proposal file
```

### Scenario 2: Bug Fixing

```bash
# 1. Create work item for the bug
$ adbs new "fix memory leak in image processor"

# 2. Add investigation tasks
$ adbs todo "Reproduce the memory leak"
$ adbs todo "Identify root cause"
$ adbs todo "Implement fix"
$ adbs todo "Add regression test"

# 3. Your AI assistant focuses on:
#    - The specific bug you're fixing
#    - The investigation steps
#    - The fix implementation
```

### Scenario 3: Refactoring

```bash
# 1. Start refactoring work
$ adbs new "refactor database layer"

# 2. Break down into tasks
$ adbs todo "Extract database connection logic"
$ adbs todo "Create repository pattern"
$ adbs todo "Update all database calls"
$ adbs todo "Run full test suite"

# 3. Keep AI focused on:
#    - The refactoring goals
#    - The specific changes needed
#    - Testing requirements
```

## Benefits You'll See

### Before ADbS

- AI forgets what you're working on
- AI suggests unrelated features
- You lose track of tasks
- Context switching is difficult

### After ADbS

- ✅ AI stays focused on your current work
- ✅ AI suggests relevant solutions
- ✅ Tasks are organized automatically
- ✅ Clear context for every conversation

## Next Steps

- Read the [Usage Guide](/usage/) for detailed instructions
- Check out the [Installation Guide](/installation/) to get started
- Explore the [Documentation](/docs/) for advanced features

---

**Ready to try ADbS?** [Install it now](/installation/) and start working more effectively with your AI assistant!

