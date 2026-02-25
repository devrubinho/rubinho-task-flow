#!/usr/bin/env node

const { program } = require('commander');
const path = require('path');
const { installInProject } = require('../lib/install');
const { checkVersionUpdates } = require('../lib/version');
const { estimateTask } = require('../lib/estimate');
const { generateReport } = require('../lib/report');
const chalk = require('chalk');

program
  .name('rbin-task-flow')
  .description('AI-powered task management for Claude and Cursor')
  .version(require('../package.json').version);

program
  .command('init')
  .description('Initialize RBIN Task Flow in current directory')
  .option('-p, --path <path>', 'Target directory (default: current directory)')
  .action(async (options) => {
    const targetPath = options.path || process.cwd();
    await installInProject(targetPath);
  });

program
  .command('update')
  .description('Update RBIN Task Flow in current directory')
  .option('-p, --path <path>', 'Target directory (default: current directory)')
  .action(async (options) => {
    const targetPath = options.path || process.cwd();
    await installInProject(targetPath, { update: true });
  });

program
  .command('version-check')
  .description('Check for model version updates')
  .action(async () => {
    await checkVersionUpdates();
  });

program
  .command('estimate')
  .description('Estimate time for task(s) based on subtasks and experience level')
  .argument('<taskIds>', 'Task ID(s) to estimate (comma-separated or "all")')
  .option('-p, --path <path>', 'Target directory (default: current directory)')
  .action(async (taskIds, options) => {
    const targetPath = options.path || process.cwd();
    await estimateTask(taskIds, targetPath);
  });

program
  .command('report')
  .description('Generate implementation report for completed task(s)')
  .argument('<taskIds>', 'Task ID(s) to generate report for (comma-separated or "all")')
  .option('-p, --path <path>', 'Target directory (default: current directory)')
  .action(async (taskIds, options) => {
    const targetPath = options.path || process.cwd();
    await generateReport(taskIds, targetPath);
  });

program
  .command('info')
  .description('Show information about RBIN Task Flow')
  .action(() => {
    console.log('\n' + chalk.cyan('╔════════════════════════════════════════════════════════════════╗'));
    console.log(chalk.cyan('║') + '        ' + chalk.magenta('✨ RBIN Task Flow ✨') + '                           ' + chalk.cyan('║'));
    console.log(chalk.cyan('╚════════════════════════════════════════════════════════════════╝') + '\n');
    console.log(chalk.blue('AI-powered task management for Claude and Cursor'));
    console.log(chalk.yellow('\nVersion:'), require('../package.json').version);
    console.log(chalk.yellow('Repository:'), 'https://github.com/rbinoliveira/rbin-task-flow');
    console.log(chalk.yellow('\nCommands:'));
    console.log(chalk.cyan('  rbin-task-flow init') + '         - Initialize in current directory');
    console.log(chalk.cyan('  rbin-task-flow update') + '       - Update configurations');
    console.log(chalk.cyan('  rbin-task-flow version-check') + ' - Check for model updates');
    console.log(chalk.cyan('  rbin-task-flow estimate <ids>') + ' - Estimate time (e.g., "1" or "1,2" or "all")');
    console.log(chalk.cyan('  rbin-task-flow report <ids>') + '  - Generate report (e.g., "1" or "1,2" or "all")');
    console.log(chalk.cyan('  rbin-task-flow info') + '         - Show this information\n');
  });

program.parse();
