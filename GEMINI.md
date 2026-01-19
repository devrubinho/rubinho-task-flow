# Gemini Instructions

## Development Rules

All development rules are automatically loaded from `.cursor/rules/` directory. These rules include:
- Cursor rules formatting guidelines
- Self-improvement processes
- Code commenting standards
- Commit practices
- Git command control
- Task execution management with RBIN Task Flow

## RBIN Task Flow

This project uses RBIN Task Flow for task management:
- **Task Definition**: Edit `.task-flow/tasks.input.txt` using simple format: `- Task description`
- **AI Commands**: Use AI-powered commands for task management:
  - `task-flow: sync` - Synchronize tasks from tasks.input.txt
  - `task-flow: run next X` - Work on next X subtasks
  - `task-flow: run task X` - Execute all pending subtasks of task X
  - `task-flow: status` - View current task status
  - `task-flow: review` - Review completed tasks
  - `task-flow: think` - Analyze code and suggest new tasks
  - `task-flow: refactor` - Refactor code from current commit
  - `task-flow: estimate task X` - Estimate time for task X based on subtasks and experience level
  - `task-flow: report task X` - Generate implementation report for completed task X
- **Files**:
  - `.task-flow/tasks.input.txt` - Define your tasks here
  - `.task-flow/tasks.status.md` - Auto-generated status (DO NOT EDIT manually)
  - `.task-flow/.internal/` - Internal system files (ignore)

Follow all rules defined in `.cursor/rules/` for consistent development practices.
