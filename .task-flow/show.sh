#!/bin/bash

[ -z "$1" ] && {
  echo "❌ Error: Task ID not provided"
  echo "   Usage: Called from menu option 3"
  exit 1
}

ROOT_DIR=$(pwd)
TASKS_FILE="$ROOT_DIR/.task-flow/tasks.json"
STATUS_FILE="$ROOT_DIR/.task-flow/status.json"

[ ! -f "$TASKS_FILE" ] && echo "⚠️  No tasks found." && exit 1

node -e "
const fs = require('fs');
const tasks = JSON.parse(fs.readFileSync('$TASKS_FILE', 'utf8'));
const status = JSON.parse(fs.readFileSync('$STATUS_FILE', 'utf8'));
const taskId = parseInt('$1');
const task = tasks.tasks.find(t => t.id === taskId);

if (!task) {
  console.error('❌ Task $1 not found');
  process.exit(1);
}

const taskStatus = status.tasks[task.id] || { status: 'pending', subtasks: {} };

console.log(\`\n📋 Task #\${task.id}: \${task.title}\n\`);
console.log('═══════════════════════════════════════════════════════════════\n');
console.log(\`📝 Description: \${task.description}\`);
console.log(\`📅 Created at: \${new Date(task.createdAt).toLocaleString('en-US')}\`);
console.log(\`🎯 Status: \${taskStatus.status}\`);
console.log(\`📌 Original request: \${task.originalRequest}\n\`);
console.log('📦 Subtasks:\n');

task.subtasks.forEach(st => {
  const stStatus = taskStatus.subtasks[st.id] || 'pending';
  const emoji = stStatus === 'done' ? '✅' : stStatus === 'in_progress' ? '🔄' : '⏹️';
  console.log(\`\${emoji} Subtask #\${task.id}.\${st.id}: \${st.title}\`);
  console.log(\`   Status: \${stStatus}\`);
  if (st.description) console.log(\`   Description: \${st.description}\`);
  console.log(\`\n   Instructions:\n\`);
  console.log(st.instructions.split('\\\\n').map(line => '   ' + line).join('\\n'));
  console.log('\n───────────────────────────────────────────────────────────────\n');
});

console.log('💡 Use menu option 4 to mark subtask as done\n');
"
