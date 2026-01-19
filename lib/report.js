const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const { execSync } = require('child_process');
const { parseTaskIds } = require('./utils');

async function generateReport(taskIdsInput, targetPath = process.cwd()) {
  const tasksPath = path.join(targetPath, '.task-flow/.internal/tasks.json');
  const statusPath = path.join(targetPath, '.task-flow/.internal/status.json');
  const docsDir = path.join(targetPath, '.task-flow/docs');

  if (!fs.existsSync(tasksPath)) {
    console.log(chalk.red('❌ Tasks file not found. Run "task-flow: sync" first.'));
    return;
  }

  if (!fs.existsSync(statusPath)) {
    console.log(chalk.red('❌ Status file not found. Run "task-flow: sync" first.'));
    return;
  }

  try {
    const tasksData = await fs.readJSON(tasksPath);
    const statusData = await fs.readJSON(statusPath);
    
    const taskIds = parseTaskIds(taskIdsInput, tasksData.tasks);
    
    if (taskIds.length === 0) {
      console.log(chalk.red('❌ No valid task IDs provided.'));
      return;
    }

    await fs.ensureDir(docsDir);

    let successCount = 0;
    let errorCount = 0;

    for (const taskId of taskIds) {
      const task = tasksData.tasks.find(t => t.id === taskId);

      if (!task) {
        console.log(chalk.red(`❌ Task ${taskId} not found.`));
        errorCount++;
        continue;
      }

      const taskStatus = statusData.tasks[taskId.toString()];
      
      if (!taskStatus) {
        console.log(chalk.yellow(`⚠️  Task ${taskId} has no status information.`));
      }

      const isCompleted = taskStatus && taskStatus.status === 'done';
      const allSubtasksDone = taskStatus && taskStatus.subtasks 
        ? Object.values(taskStatus.subtasks).every(status => status === 'done')
        : false;

      if (!isCompleted && !allSubtasksDone) {
        console.log(chalk.yellow(`⚠️  Task ${taskId} is not completed. Generating partial report...`));
      }

      const reportContent = await buildReport(task, taskStatus, targetPath);
      const reportPath = path.join(docsDir, `task-${taskId}-implementation.md`);

      await fs.writeFile(reportPath, reportContent, 'utf8');

      console.log(chalk.green(`✅ Report generated: ${reportPath}`));
      successCount++;
    }

    if (taskIds.length > 1) {
      console.log(chalk.cyan(`\n📊 Generated ${successCount} report(s), ${errorCount} error(s)`));
    }

  } catch (error) {
    console.error(chalk.red('Error generating report:'), error.message);
  }
}

async function buildReport(task, taskStatus, targetPath) {
  const completionDate = new Date().toISOString().split('T')[0];
  
  let content = `# Task ${task.id}: ${task.title}\n\n`;
  content += `**Status**: ${taskStatus?.status === 'done' ? '✅ Completed' : '⏳ In Progress'}\n`;
  content += `**Report Date**: ${completionDate}\n\n`;
  
  content += `## Overview\n\n`;
  content += `${task.description || task.originalRequest || 'No description available.'}\n\n`;

  const completedSubtasks = task.subtasks?.filter(st => 
    taskStatus?.subtasks?.[st.id.toString()] === 'done'
  ) || [];

  content += `## Implementation Summary\n\n`;
  content += `This task was completed through ${completedSubtasks.length} of ${task.subtasks?.length || 0} subtasks. `;
  content += `The implementation involved creating and modifying code files to achieve the task objectives.\n\n`;

  const fileChanges = await getFileChanges(targetPath, task.id);
  const changeSummaries = await analyzeFileChanges(targetPath, fileChanges);

  if (fileChanges.created.length > 0 || fileChanges.modified.length > 0) {
    content += `## Code Changes\n\n`;
    
    if (fileChanges.created.length > 0) {
      content += `### New Files Created\n\n`;
      fileChanges.created.forEach(file => {
        const summary = changeSummaries[file];
        content += `#### \`${file}\`\n\n`;
        if (summary) {
          content += `${summary}\n\n`;
        } else {
          content += `New file created as part of the implementation.\n\n`;
        }
      });
    }
    
    if (fileChanges.modified.length > 0) {
      content += `### Files Modified\n\n`;
      fileChanges.modified.forEach(file => {
        const summary = changeSummaries[file];
        content += `#### \`${file}\`\n\n`;
        if (summary) {
          content += `${summary}\n\n`;
        } else {
          content += `File was modified to implement required functionality.\n\n`;
        }
      });
    }
  }

  if (task.subtasks && completedSubtasks.length > 0) {
    content += `## Completed Subtasks\n\n`;
    
    completedSubtasks.forEach(subtask => {
      content += `### ✅ Subtask ${task.id}.${subtask.id}: ${subtask.title}\n\n`;
      content += `${subtask.description || 'No description available.'}\n\n`;
    });
  }

  if (fileChanges.created.length === 0 && fileChanges.modified.length === 0) {
    content += `## Note\n\n`;
    content += `_File changes could not be automatically detected from git history. `;
    content += `This may indicate that changes haven't been committed yet, or the task was completed without git tracking._\n\n`;
  }

  if (task.createdAt) {
    content += `---\n\n`;
    content += `**Task Created**: ${new Date(task.createdAt).toLocaleDateString()}\n`;
    if (taskStatus?.status === 'done') {
      content += `**Task Completed**: ${completionDate}\n`;
    }
  }

  return content;
}

async function getFileChanges(targetPath, taskId) {
  const created = [];
  const modified = [];

  try {
    const isGitRepo = fs.existsSync(path.join(targetPath, '.git'));
    
    if (!isGitRepo) {
      return { created, modified };
    }

    const gitLog = execSync(
      `git log --all --oneline --grep="task ${taskId}" --grep="Task ${taskId}" --grep="task-${taskId}" --grep="Task ${taskId}:" -i`,
      { cwd: targetPath, encoding: 'utf8', stdio: ['pipe', 'pipe', 'ignore'] }
    ).trim();

    if (gitLog) {
      const commits = gitLog.split('\n').map(line => line.split(' ')[0]);
      
      for (const commit of commits) {
        try {
          const diff = execSync(
            `git diff-tree --no-commit-id --name-status -r ${commit}`,
            { cwd: targetPath, encoding: 'utf8', stdio: ['pipe', 'pipe', 'ignore'] }
          ).trim();

          diff.split('\n').forEach(line => {
            const match = line.match(/^([AMD])\s+(.+)$/);
            if (match) {
              const status = match[1];
              const file = match[2];
              
              if (status === 'A') {
                if (!created.includes(file)) created.push(file);
              } else if (status === 'M' || status === 'D') {
                if (!modified.includes(file) && !created.includes(file)) modified.push(file);
              }
            }
          });
        } catch (error) {
        }
      }
    }
  } catch (error) {
  }

  return { created, modified };
}

async function analyzeFileChanges(targetPath, fileChanges) {
  const summaries = {};

  for (const file of [...fileChanges.created, ...fileChanges.modified]) {
    const filePath = path.join(targetPath, file);
    
    if (!fs.existsSync(filePath)) {
      continue;
    }

    try {
      const fileContent = await fs.readFile(filePath, 'utf8');
      const fileExt = path.extname(file).toLowerCase();
      
      let summary = '';

      if (fileChanges.created.includes(file)) {
        summary = generateFileSummary(file, fileContent, fileExt, 'created');
      } else {
        summary = generateFileSummary(file, fileContent, fileExt, 'modified');
      }

      summaries[file] = summary;
    } catch (error) {
      summaries[file] = `File ${fileChanges.created.includes(file) ? 'created' : 'modified'} as part of the implementation.`;
    }
  }

  return summaries;
}

function generateFileSummary(filePath, content, ext, type) {
  const fileName = path.basename(filePath);
  const lines = content.split('\n').length;
  
  let summary = '';
  
  if (type === 'created') {
    summary = `This new file was created to implement part of the task. `;
  } else {
    summary = `This file was modified to implement required functionality. `;
  }

  summary += `The file contains approximately ${lines} lines of code. `;

  if (ext === '.ts' || ext === '.tsx' || ext === '.js' || ext === '.jsx') {
    const hasExports = /export\s+(default\s+)?(function|class|const|let|var|interface|type|enum)/.test(content);
    const hasImports = /^import\s+/.test(content);
    const hasComponents = /(function|const)\s+\w+\s*[=:]\s*(\(|function|React\.FC)/.test(content);
    const functionCount = (content.match(/(?:function|const|let|var)\s+\w+\s*[=:]/g) || []).length;
    const classCount = (content.match(/class\s+\w+/g) || []).length;
    
    if (hasComponents) {
      summary += `It appears to be a React component or JavaScript module. `;
    } else if (classCount > 0) {
      summary += `It contains ${classCount} class${classCount > 1 ? 'es' : ''}. `;
    } else if (functionCount > 0) {
      summary += `It contains ${functionCount} function${functionCount > 1 ? 's' : ''} or method${functionCount > 1 ? 's' : ''}. `;
    }
    
    if (hasExports) {
      summary += `The file exports functionality for use in other parts of the application. `;
    }
    
    if (hasImports) {
      const importCount = (content.match(/^import\s+/gm) || []).length;
      summary += `It imports ${importCount} dependenc${importCount > 1 ? 'ies' : 'y'} from other modules.`;
    }
  } else if (ext === '.css' || ext === '.scss' || ext === '.less') {
    const ruleCount = (content.match(/[^{}]+{[^}]*}/g) || []).length;
    summary += `It contains ${ruleCount} CSS rule${ruleCount !== 1 ? 's' : ''} for styling the user interface.`;
  } else if (ext === '.json') {
    summary += `It contains configuration or data in JSON format.`;
  } else if (ext === '.md') {
    summary += `It contains documentation or markdown content.`;
  } else if (ext === '.test.ts' || ext === '.test.js' || ext === '.spec.ts' || ext === '.spec.js') {
    const testCount = (content.match(/(?:it|test|describe|test\(|it\(|describe\()/g) || []).length;
    summary += `It contains ${testCount} test case${testCount !== 1 ? 's' : ''} for verifying the implementation.`;
  } else if (ext === '.html') {
    summary += `It contains HTML markup for the user interface.`;
  } else if (ext === '.py') {
    const functionCount = (content.match(/def\s+\w+/g) || []).length;
    const classCount = (content.match(/class\s+\w+/g) || []).length;
    summary += `It contains ${functionCount} function${functionCount !== 1 ? 's' : ''} and ${classCount} class${classCount !== 1 ? 'es' : ''}.`;
  } else {
    summary += `It is a ${ext.substring(1).toUpperCase()} file.`;
  }

  return summary;
}

module.exports = { generateReport };
