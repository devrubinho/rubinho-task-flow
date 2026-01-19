# RBIN Task Flow - Quick Commands

## 🚀 Quick Commands

| Command | Description |
|---------|-------------|
| `task-flow: sync` | Complete synchronization: adds new, removes deleted, updates modified, preserves status |
| `task-flow: think` | Analyzes code and suggests new tasks |
| `task-flow: status` | Shows current task status |
| `task-flow: run next X` | Works on next X subtasks (e.g., `task-flow: run next 4`) |
| `task-flow: run X` | Executes all pending subtasks of task X (e.g., `task-flow: run 1`) |
| `task-flow: run X,Y` | Executes multiple tasks (e.g., `task-flow: run 10,11`) |
| `task-flow: run all` | Executes all tasks |
| `task-flow: review X` | Reviews specific task(s) (e.g., `task-flow: review 1` or `task-flow: review 10,11` or `task-flow: review all`) |
| `task-flow: refactor X` | Refactors specific task(s) (e.g., `task-flow: refactor 1` or `task-flow: refactor 10,11` or `task-flow: refactor all`) |
| `task-flow: estimate X` | Estimates time for task X (e.g., `task-flow: estimate 1` or `task-flow: estimate 10,11`) |
| `task-flow: report X` | Generates implementation report for task X (e.g., `task-flow: report 1` or `task-flow: report 10,11`) |

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

### `task-flow: status`
Shows current status of tasks and subtasks from the `tasks.status.md` file.

---

## Commands with Task ID

### `task-flow: run next X`
Works on next X pending subtasks in sequential order. Implements and marks as "done".

**Examples:**
- `task-flow: run next 4` → Next 4 subtasks
- `task-flow: run next` → Next 1 subtask

### `task-flow: run X` (simplified syntax)
Executes all pending subtasks of a specific task. Implements and marks as "done".

**⚠️ Dependency Check:**
- Only executes if all previous tasks (1, 2, ..., X-1) are completely finished
- Allows parallel work by multiple AIs without conflicts
- If there are pending previous tasks, warns which ones need to be completed first

**Examples:**
- `task-flow: run 1` → All pending subtasks of task 1 (can always execute)
- `task-flow: run 10,11` → All pending subtasks of tasks 10 and 11
- `task-flow: run all` → All pending subtasks of all tasks
- `task-flow: run 3` → Only executes if tasks 1 and 2 are complete

### `task-flow: review X`
Reviews specific task(s) marked as "done" to verify they are actually completed.

**Examples:**
- `task-flow: review 1` → Reviews task 1
- `task-flow: review 10,11` → Reviews tasks 10 and 11
- `task-flow: review all` → Reviews all tasks

### `task-flow: refactor X`
Refactors code from specific task(s). Removes explanatory comments, improves code without changing functionality.

**Examples:**
- `task-flow: refactor 1` → Refactors task 1
- `task-flow: refactor 10,11` → Refactors tasks 10 and 11
- `task-flow: refactor all` → Refactors all tasks

### `task-flow: estimate X` (simplified syntax)
Estimates time required to complete task(s) based on the number of subtasks and developer experience level.

**Output includes:**
- Time estimates for Junior (0-2 years), Mid-level (3-5 years), and Senior (6+ years) developers
- Estimates in hours and business days
- Recommendation for management with buffer

**Examples:**
- `task-flow: estimate 1` → Shows time estimate for task 1
- `task-flow: estimate 10,11` → Shows time estimates for tasks 10 and 11
- `task-flow: estimate all` → Shows time estimates for all tasks

### `task-flow: report X` (simplified syntax)
Generates a detailed implementation report for completed task(s) in Markdown format.

**Report includes:**
- Task overview and completion status
- List of completed subtasks
- Files created and modified (detected from git history)
- Code change summaries with analysis
- Task creation and completion dates

**Report location:** `.task-flow/docs/task-X-implementation.md`

**Examples:**
- `task-flow: report 1` → Generates report for task 1
- `task-flow: report 10,11` → Generates reports for tasks 10 and 11
- `task-flow: report all` → Generates reports for all tasks

---

## Files

- `.task-flow/tasks.input.txt` - Edit tasks here (format: `- Task description`)
- `.task-flow/tasks.status.md` - ⚠️ **DO NOT EDIT** - Automatically updated by AI
- `.task-flow/.internal/` - ⚠️ **IGNORE** - Internal system files (no need to read or edit)
