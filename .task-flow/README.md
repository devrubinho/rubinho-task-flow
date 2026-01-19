# RBIN Task Flow - Quick Commands

## 🚀 Quick Commands

| Command | Description |
|---------|-------------|
| `task-flow: sync` | Complete synchronization: adds new, removes deleted, updates modified, preserves status |
| `task-flow: think` | Analyzes code and suggests new tasks |
| `task-flow: run next X` | Works on next X subtasks (e.g., `task-flow: run next 4`) |
| `task-flow: run task X` | Executes all pending subtasks of task X (e.g., `task-flow: run task 1`) |
| `task-flow: status` | Shows current task status |
| `task-flow: review` | Reviews tasks marked as "done" |
| `task-flow: refactor` | Refactors code from current commit |
| `task-flow: estimate task X` | Estimates time for task X based on subtasks and experience level |
| `task-flow: report task X` | Generates implementation report for completed task X |

**See complete details below ↓**

---

## Detailed Commands

### `task-flow: sync`
Complete synchronization between `tasks.input.txt` and the system:
- ✅ Adds new tasks from `tasks.input.txt`
- ✅ Removes tasks that were deleted from `tasks.input.txt`
- ✅ Updates tasks that were modified in `tasks.input.txt`
- ✅ Preserves status (done/pending) of existing tasks
- ✅ Synchronizes status between `status.json` and `tasks.status.md` (ensures they are always aligned)

### `task-flow: think`
Analyzes code and suggests new tasks. Asks before adding to `tasks.input.txt`.

### `task-flow: run next X`
Works on next X pending subtasks in sequential order. Implements and marks as "done".

**Examples:**
- `task-flow: run next 4` → Next 4 subtasks
- `task-flow: run next` → Next 1 subtask

### `task-flow: run task X`
Executes all pending subtasks of a specific task. Implements and marks as "done".

**⚠️ Dependency Check:**
- Only executes if all previous tasks (1, 2, ..., X-1) are completely finished
- Allows parallel work by multiple AIs without conflicts
- If there are pending previous tasks, warns which ones need to be completed first

**Examples:**
- `task-flow: run task 1` → All pending subtasks of task 1 (can always execute)
- `task-flow: run task 3` → Only executes if tasks 1 and 2 are complete

### `task-flow: status`
Shows current status of tasks and subtasks from the `tasks.status.md` file.

### `task-flow: review`
Reviews tasks marked as "done" to verify they are actually completed.

### `task-flow: refactor`
Refactors code from current commit. Removes explanatory comments, improves code without changing functionality.

### `task-flow: estimate task X`
Estimates time required to complete a task based on the number of subtasks and developer experience level.

**Output includes:**
- Time estimates for Junior (0-2 years), Mid-level (3-5 years), and Senior (6+ years) developers
- Estimates in hours and business days
- Recommendation for management with buffer

**Examples:**
- `task-flow: estimate task 1` → Shows time estimate for task 1

### `task-flow: report task X`
Generates a detailed implementation report for a completed task in Markdown format.

**Report includes:**
- Task overview and completion status
- List of completed subtasks
- Files created and modified (detected from git history)
- Code change summaries with analysis
- Task creation and completion dates

**Report location:** `.task-flow/docs/task-X-implementation.md`

**Examples:**
- `task-flow: report task 1` → Generates report for task 1

---

## Files

- `.task-flow/tasks.input.txt` - Edit tasks here (format: `- Task description`)
- `.task-flow/tasks.status.md` - ⚠️ **DO NOT EDIT** - Automatically updated by AI
- `.task-flow/.internal/` - ⚠️ **IGNORE** - Internal system files (no need to read or edit)
