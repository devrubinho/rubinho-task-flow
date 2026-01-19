const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');

async function estimateTask(taskId, targetPath = process.cwd()) {
  const tasksPath = path.join(targetPath, '.task-flow/.internal/tasks.json');

  if (!fs.existsSync(tasksPath)) {
    console.log(chalk.red('❌ Tasks file not found. Run "task-flow: sync" first.'));
    return;
  }

  try {
    const tasksData = await fs.readJSON(tasksPath);
    const task = tasksData.tasks.find(t => t.id === parseInt(taskId));

    if (!task) {
      console.log(chalk.red(`❌ Task ${taskId} not found.`));
      return;
    }

    const subtaskCount = task.subtasks ? task.subtasks.length : 0;

    if (subtaskCount === 0) {
      console.log(chalk.yellow(`⚠️  Task ${taskId} has no subtasks. Cannot estimate.`));
      return;
    }

    const estimates = calculateEstimates(subtaskCount);

    console.log('\n' + chalk.cyan('═'.repeat(70)));
    console.log(chalk.magenta('📊 Task Estimation Report'));
    console.log(chalk.cyan('═'.repeat(70)) + '\n');

    console.log(chalk.blue.bold('Task:'), chalk.yellow(`#${taskId} - ${task.title}\n`));
    console.log(chalk.blue(`Complexity: ${chalk.yellow(subtaskCount)} subtasks\n`));

    console.log(chalk.cyan('─'.repeat(70)));
    console.log(chalk.magenta.bold('Time Estimates by Experience Level:\n'));

    const juniorDays = Math.ceil(estimates.junior.upper / 8);
    const midDays = Math.ceil(estimates.mid.upper / 8);
    const seniorDays = Math.ceil(estimates.senior.upper / 8);

    console.log(chalk.gray('👶 Junior Developer (0-2 years):'));
    console.log(chalk.white('   Hours:'), chalk.yellow(`${estimates.junior.lower}-${estimates.junior.upper} hours`));
    console.log(chalk.white('   Days: '), chalk.yellow(`~${juniorDays} business day(s)`));
    console.log('');

    console.log(chalk.gray('👨‍💼 Mid-level Developer (3-5 years):'));
    console.log(chalk.white('   Hours:'), chalk.yellow(`${estimates.mid.lower}-${estimates.mid.upper} hours`));
    console.log(chalk.white('   Days: '), chalk.yellow(`~${midDays} business day(s)`));
    console.log('');

    console.log(chalk.gray('👴 Senior Developer (6+ years):'));
    console.log(chalk.white('   Hours:'), chalk.yellow(`${estimates.senior.lower}-${estimates.senior.upper} hours`));
    console.log(chalk.white('   Days: '), chalk.yellow(`~${seniorDays} business day(s)`));
    console.log('');

    console.log(chalk.cyan('─'.repeat(70)));
    console.log(chalk.magenta.bold('Recommendation for Management:\n'));
    console.log(chalk.white('   Recommended estimate:'), chalk.yellow(`${estimates.mid.lower}-${estimates.mid.upper} hours`), chalk.gray('(mid-level baseline)'));
    console.log(chalk.white('   Buffer recommended:'), chalk.yellow(`+20%`), chalk.gray('for unexpected issues'));
    console.log(chalk.white('   Total estimate:'), chalk.yellow(`${Math.round(estimates.mid.upper * 1.2)} hours`), chalk.gray(`(~${Math.ceil(estimates.mid.upper * 1.2 / 8)} business days)`));
    console.log('');

  } catch (error) {
    console.error(chalk.red('Error reading tasks:'), error.message);
  }
}

function calculateEstimates(subtaskCount) {
  const baseLower = subtaskCount * 2;
  const baseUpper = subtaskCount * 3;

  return {
    junior: {
      lower: Math.round(baseLower * 1.5),
      upper: Math.round(baseUpper * 1.5)
    },
    mid: {
      lower: baseLower,
      upper: baseUpper
    },
    senior: {
      lower: Math.round(baseLower * 0.7),
      upper: Math.round(baseUpper * 0.7)
    }
  };
}

module.exports = { estimateTask };
