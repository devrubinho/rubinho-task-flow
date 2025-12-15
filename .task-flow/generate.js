#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const https = require('https');

const ROOT_DIR = process.cwd();
const TASKS_INPUT_FILE = path.join(ROOT_DIR, '.task-flow', 'tasks.txt');
const TASKS_OUTPUT_FILE = path.join(ROOT_DIR, '.task-flow', 'tasks.json');
const STATUS_FILE = path.join(ROOT_DIR, '.task-flow', 'status.json');

function loadTasksFromFile() {
  if (!fs.existsSync(TASKS_INPUT_FILE)) {
    throw new Error('tasks.txt not found in .task-flow/');
  }

  const content = fs.readFileSync(TASKS_INPUT_FILE, 'utf8');
  const tasks = [];
  const lines = content.split('\n');

  for (const line of lines) {
    const match = line.match(/^-\s*\[\s*\]\s*(.+)$/);
    if (match) tasks.push(match[1].trim());
  }

  return tasks;
}

function loadGeneratedTasks() {
  if (!fs.existsSync(TASKS_OUTPUT_FILE)) {
    return { version: '1.0.0', generatedAt: null, tasks: [] };
  }
  return JSON.parse(fs.readFileSync(TASKS_OUTPUT_FILE, 'utf8'));
}

function saveGeneratedTasks(data) {
  data.generatedAt = new Date().toISOString();
  fs.writeFileSync(TASKS_OUTPUT_FILE, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

function loadStatus() {
  if (!fs.existsSync(STATUS_FILE)) {
    return { version: '1.0.0', lastUpdated: null, tasks: {} };
  }
  return JSON.parse(fs.readFileSync(STATUS_FILE, 'utf8'));
}

function saveStatus(data) {
  data.lastUpdated = new Date().toISOString();
  fs.writeFileSync(STATUS_FILE, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

function createPrompt(taskDescription) {
  return `You are an assistant specialized in creating detailed subtasks for software development.

Main task: ${taskDescription}

Create between 3-8 subtasks following this JSON format:

{
  "title": "Main Task Title",
  "description": "General description of what will be done",
  "subtasks": [
    {
      "id": 1,
      "title": "Subtask title",
      "description": "Brief description",
      "instructions": "CONTEXT:\\n- Relevant files: [list]\\n- Patterns to follow: [patterns]\\n- Dependencies: [deps]\\n\\nOBJECTIVE:\\n[What to do in detail]\\n\\nIMPLEMENTATION:\\n1. [Detailed step 1]\\n2. [Detailed step 2]\\n3. [Continue...]\\n\\nVALIDATION:\\n- [How to verify correctness]\\n- [Commands to test]\\n- [Expected result]"
    }
  ]
}

IMPORTANT:
- Each subtask must be complete and self-contained
- Extremely detailed and specific instructions
- Include file names when possible
- Include code examples when relevant
- Be clear so an AI can work without questions
- Use the instruction format shown above

Return ONLY valid JSON, no markdown, no additional explanations.`;
}

async function callClaudeAPI(prompt) {
  throw new Error('Direct API calls are not supported. This tool is designed to work with Claude Code and Cursor Pro.');
}

async function generateAllTasks() {
  const taskDescriptions = loadTasksFromFile();

  if (taskDescriptions.length === 0) {
    console.log('\n⚠️  No tasks found in tasks.txt\n');
    console.log('Add tasks in format: - [ ] Task description\n');
    return;
  }

  console.log(`\n🤖 Generating ${taskDescriptions.length} task(s)...\n`);

  const tasksData = loadGeneratedTasks();
  const statusData = loadStatus();

  let nextTaskId = tasksData.tasks.length > 0
    ? Math.max(...tasksData.tasks.map(t => t.id)) + 1
    : 1;

  for (const description of taskDescriptions) {
    try {
      console.log(`📡 Processing: "${description}"`);

      const prompt = createPrompt(description);
      const result = await callClaudeAPI(prompt);

      const newTask = {
        id: nextTaskId,
        title: result.title,
        description: result.description,
        originalRequest: description,
        createdAt: new Date().toISOString(),
        subtasks: result.subtasks.map((st) => ({
          id: st.id,
          title: st.title,
          description: st.description || '',
          instructions: st.instructions
        }))
      };

      tasksData.tasks.push(newTask);

      statusData.tasks[nextTaskId] = {
        status: 'pending',
        subtasks: {}
      };

      newTask.subtasks.forEach(st => {
        statusData.tasks[nextTaskId].subtasks[st.id] = 'pending';
      });

      console.log(`✅ Task ${nextTaskId} created with ${newTask.subtasks.length} subtasks\n`);

      nextTaskId++;
      await new Promise(resolve => setTimeout(resolve, 1000));

    } catch (error) {
      console.error(`❌ Error generating task "${description}": ${error.message}\n`);
    }
  }

  saveGeneratedTasks(tasksData);
  saveStatus(statusData);

  console.log(`\n✨ Generation complete! Use menu option 2 to view tasks\n`);
}

async function main() {
  try {
    await generateAllTasks();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { generateAllTasks };
