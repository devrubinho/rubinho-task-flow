const chalk = require('chalk');

function showHeader() {
  console.clear();
  console.log(chalk.cyan('╔════════════════════════════════════════════════════════════════╗'));
  console.log(chalk.cyan('║') + '        ' + chalk.magenta('✨ RBIN Task Flow - Installation ✨') + '          ' + chalk.cyan('║'));
  console.log(chalk.cyan('╚════════════════════════════════════════════════════════════════╝') + '\n');
}

function showSuccess(message) {
  console.log(chalk.green('✅ ' + message));
}

function showError(message) {
  console.log(chalk.red('❌ ' + message));
}

function showWarning(message) {
  console.log(chalk.yellow('⚠️  ' + message));
}

function showInfo(message) {
  console.log(chalk.blue('ℹ️  ' + message));
}

function showNextSteps(targetPath) {
  console.log('\n' + chalk.cyan('═'.repeat(60)));
  console.log(chalk.magenta.bold('  Next Steps:'));
  console.log(chalk.cyan('═'.repeat(60)));
  console.log(chalk.blue('  1.'), 'Edit', chalk.yellow('.task-flow/tasks.input.txt'));
  console.log(chalk.blue('  2.'), 'Use AI command:', chalk.cyan('task-flow: sync'));
  console.log(chalk.blue('  3.'), 'Work on tasks:', chalk.cyan('task-flow: run next X'));
  console.log(chalk.blue('  4.'), 'Check status:', chalk.cyan('task-flow: status'));
  console.log(chalk.cyan('═'.repeat(60)));
  console.log(chalk.blue('\n  See'), chalk.yellow('.task-flow/README.md'), chalk.blue('for all available commands\n'));
}

function parseTaskIds(input, allTasks = []) {
  if (!input || input.trim().toLowerCase() === 'all') {
    return allTasks.map(t => t.id);
  }
  
  const ids = input.split(',')
    .map(id => id.trim())
    .filter(id => id.length > 0)
    .map(id => parseInt(id))
    .filter(id => !isNaN(id));
  
  return ids;
}

module.exports = {
  showHeader,
  showSuccess,
  showError,
  showWarning,
  showInfo,
  showNextSteps,
  parseTaskIds
};
