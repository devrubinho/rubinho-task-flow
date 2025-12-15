#!/bin/bash

ROOT_DIR=$(pwd)
TASKS_FILE="$ROOT_DIR/.task-flow/tasks.json"
STATUS_FILE="$ROOT_DIR/.task-flow/status.json"

YELLOW='\033[1;33m'
NC='\033[0m'

[ ! -f "$TASKS_FILE" ] || [ ! -f "$STATUS_FILE" ] && {
  echo -e "${YELLOW}⚠️  No tasks found.${NC}"
  echo -e "Use menu option 1 to generate tasks from tasks.txt\n"
  exit 0
}
node -e "
const fs = require('fs');

const tasks = JSON.parse(fs.readFileSync('$TASKS_FILE', 'utf8'));
const status = JSON.parse(fs.readFileSync('$STATUS_FILE', 'utf8'));

console.log('\n📊 Tasks Status\n');
console.log('═══════════════════════════════════════════════════════════════\n');

if (tasks.tasks.length === 0) {
  console.log('⚠️  No tasks generated yet.\n');
  console.log('Use menu option 1 to generate tasks\n');
  process.exit(0);
}

tasks.tasks.forEach(task => {
  const taskStatus = status.tasks[task.id] || { status: 'unknown', subtasks: {} };
  const totalSubtasks = task.subtasks.length;
  const completedSubtasks = Object.values(taskStatus.subtasks).filter(s => s === 'done').length;

  const statusEmoji = taskStatus.status === 'done' ? '✅' :
                      taskStatus.status === 'in_progress' ? '🔄' : '⏳';

  console.log(\`\${statusEmoji} Task #\${task.id}: \${task.title}\`);
  console.log(\`   Progress: \${completedSubtasks}/\${totalSubtasks} subtasks completed\`);
  console.log(\`   Status: \${taskStatus.status}\`);
  console.log();

  task.subtasks.forEach(st => {
    const stStatus = taskStatus.subtasks[st.id] || 'pending';
    const stEmoji = stStatus === 'done' ? '✅' :
                    stStatus === 'in_progress' ? '🔄' : '⏹️';
    console.log(\`   \${stEmoji} \${task.id}.\${st.id} - \${st.title}\`);
  });

  console.log('\n───────────────────────────────────────────────────────────────\n');
});

console.log('💡 Use menu options to:');
console.log('   Option 3 - View task details');
console.log('   Option 4 - Mark subtask as done');
console.log();
"
