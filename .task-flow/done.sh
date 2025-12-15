#!/bin/bash

[ -z "$1" ] && {
  echo "❌ Error: Subtask ID not provided"
  echo "   Usage: Called from menu option 4"
  exit 1
}

ROOT_DIR=$(pwd)
STATUS_FILE="$ROOT_DIR/.task-flow/status.json"
TASKS_FILE="$ROOT_DIR/.task-flow/tasks.json"

[ ! -f "$STATUS_FILE" ] && echo "⚠️  Status file not found." && exit 1

IFS='.' read -r TASK_ID SUBTASK_ID <<< "$1"

[ -z "$TASK_ID" ] || [ -z "$SUBTASK_ID" ] && {
  echo "❌ Invalid format. Use: task_id.subtask_id (ex: 1.2)"
  exit 1
}

node -e "
const fs = require('fs');

const tasks = JSON.parse(fs.readFileSync('$TASKS_FILE', 'utf8'));
const status = JSON.parse(fs.readFileSync('$STATUS_FILE', 'utf8'));

const taskId = parseInt('$TASK_ID');
const subtaskId = parseInt('$SUBTASK_ID');

const task = tasks.tasks.find(t => t.id === taskId);
if (!task) {
  console.error('❌ Task $TASK_ID not found');
  process.exit(1);
}

const subtask = task.subtasks.find(st => st.id === subtaskId);
if (!subtask) {
  console.error('❌ Subtask $TASK_ID.$SUBTASK_ID not found');
  process.exit(1);
}

if (!status.tasks[taskId]) {
  status.tasks[taskId] = { status: 'pending', subtasks: {} };
}

status.tasks[taskId].subtasks[subtaskId] = 'done';

const allDone = task.subtasks.every(st =>
  status.tasks[taskId].subtasks[st.id] === 'done'
);

if (allDone) {
  status.tasks[taskId].status = 'done';
}

status.lastUpdated = new Date().toISOString();
fs.writeFileSync('$STATUS_FILE', JSON.stringify(status, null, 2) + '\n', 'utf8');

console.log(\`\n✅ Subtask #\${taskId}.\${subtaskId} marked as done!\`);
console.log(\`   Title: \${subtask.title}\`);

if (allDone) {
  console.log(\`\n🎉 Congrats! All subtasks for Task #\${taskId} completed!\`);
  console.log(\`   Main task: \${task.title}\`);
}

console.log();
"

echo "📊 Return to menu to view complete progress"
echo ""
