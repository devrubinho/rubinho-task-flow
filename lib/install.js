const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const { showHeader, showSuccess, showError, showWarning, showInfo, showNextSteps } = require('./utils');

const TEMPLATE_DIR = path.join(__dirname, '..');

async function installInProject(targetPath, options = {}) {
  const isUpdate = options.update || false;

  showHeader();

  if (isUpdate) {
    console.log(chalk.blue('🔄 Updating RBIN Task Flow...'));
  } else {
    console.log(chalk.blue('🚀 Installing RBIN Task Flow...'));
  }

  console.log(chalk.blue('📁 Target:'), targetPath, '\n');

  const spinner = ora('Processing...').start();

  try {
    if (!fs.existsSync(targetPath)) {
      spinner.fail(chalk.red(`Directory not found: ${targetPath}`));
      process.exit(1);
    }

    try {
      fs.accessSync(targetPath, fs.constants.W_OK);
    } catch (error) {
      spinner.fail(chalk.red('No write permission in target directory'));
      process.exit(1);
    }

    spinner.text = 'Creating directories...';

    const dirs = [
      '.cursor/rules',
      '.claude',
      '.task-flow'
    ];

    for (const dir of dirs) {
      await fs.ensureDir(path.join(targetPath, dir));
    }

    spinner.text = 'Copying configuration files...';

    await copyConfigs(targetPath);

    spinner.text = 'Updating .gitignore...';

    await updateGitignore(targetPath);

    spinner.succeed(chalk.green('Installation completed!'));

    console.log('');

    await showModelVersions(targetPath);

    showNextSteps(targetPath);

  } catch (error) {
    spinner.fail(chalk.red('Installation failed'));
    console.error(chalk.red('\nError:'), error.message);
    process.exit(1);
  }
}

async function copyConfigs(targetPath) {
  const cursorRulesPath = path.join(TEMPLATE_DIR, '.cursor/rules');
  if (fs.existsSync(cursorRulesPath)) {
    await fs.copy(
      cursorRulesPath,
      path.join(targetPath, '.cursor/rules'),
      { overwrite: true }
    );
    showSuccess('Cursor rules');
  }

  const cursorSettingsPath = path.join(TEMPLATE_DIR, '.cursor/settings.json');
  if (fs.existsSync(cursorSettingsPath)) {
    await fs.copy(
      cursorSettingsPath,
      path.join(targetPath, '.cursor/settings.json'),
      { overwrite: true }
    );
    showSuccess('Cursor settings');
  }

  const claudeSettingsPath = path.join(TEMPLATE_DIR, '.claude/settings.json');
  if (fs.existsSync(claudeSettingsPath)) {
    await fs.copy(
      claudeSettingsPath,
      path.join(targetPath, '.claude/settings.json'),
      { overwrite: true }
    );
    showSuccess('Claude settings');
  }

  const claudeInstructionsPath = path.join(TEMPLATE_DIR, 'CLAUDE.md');
  if (fs.existsSync(claudeInstructionsPath)) {
    await fs.copy(
      claudeInstructionsPath,
      path.join(targetPath, 'CLAUDE.md'),
      { overwrite: true }
    );
    showSuccess('Claude instructions');
  }

  await copyTaskFlow(targetPath);
}

async function copyTaskFlow(targetPath) {
  const taskFlowSrc = path.join(TEMPLATE_DIR, '.task-flow');
  const taskFlowDest = path.join(targetPath, '.task-flow');

  await fs.ensureDir(taskFlowDest);

  showSuccess('Task Flow directory');
  showInfo('Note: .internal/tasks.json and .internal/status.json are NOT overwritten (your data is safe)');

  const contextsDest = path.join(taskFlowDest, 'contexts');
  await fs.ensureDir(contextsDest);
  showSuccess('Contexts directory (.task-flow/contexts/)');

  const docsDest = path.join(taskFlowDest, 'docs');
  await fs.ensureDir(docsDest);
  showSuccess('Documentation directory (.task-flow/docs/)');

  const exampleSrc = path.join(taskFlowSrc, 'contexts/example.png.txt');
  const exampleDest = path.join(contextsDest, 'example.png.txt');
  if (fs.existsSync(exampleSrc) && !fs.existsSync(exampleDest)) {
    await fs.copy(exampleSrc, exampleDest);
  }

  const files = [
    { name: 'README.md', overwrite: true },
    { name: 'tasks.input.txt', overwrite: false },
    { name: 'tasks.status.md', overwrite: false }
  ];

  for (const file of files) {
    const src = path.join(taskFlowSrc, file.name);
    const dest = path.join(taskFlowDest, file.name);

    if (fs.existsSync(src)) {
      if (file.overwrite || !fs.existsSync(dest)) {
        await fs.copy(src, dest, { overwrite: file.overwrite });
      }
    }
  }
}

async function updateGitignore(targetPath) {
  const gitignorePath = path.join(targetPath, '.gitignore');

  if (!fs.existsSync(gitignorePath)) {
    await fs.writeFile(gitignorePath, '');
  }

  let content = await fs.readFile(gitignorePath, 'utf8');

  const entries = [
    '.claude/',
    '.cursor/',
    '.task-flow/',
    'CLAUDE.md'
  ];

  for (const entry of entries) {
    const regex = new RegExp(`^${entry.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, 'gm');
    content = content.replace(regex, '');
  }

  content = content.replace(/\n{3,}/g, '\n\n');

  if (!content.endsWith('\n')) {
    content += '\n';
  }

  content += '\n' + entries.join('\n') + '\n';

  await fs.writeFile(gitignorePath, content);

  showSuccess('.gitignore updated');
}

async function showModelVersions(targetPath) {
  console.log(chalk.cyan('═'.repeat(60)));
  console.log(chalk.magenta('📋 Model Versions Configured:'));
  console.log(chalk.cyan('═'.repeat(60)));
  console.log('');

  let hasModels = false;

  const claudeSettingsPath = path.join(targetPath, '.claude/settings.json');
  if (fs.existsSync(claudeSettingsPath)) {
    try {
      const settings = await fs.readJSON(claudeSettingsPath);
      if (settings.model) {
        console.log(chalk.blue('Claude:'), chalk.yellow(settings.model));
        hasModels = true;
      } else {
        console.log(chalk.blue('Claude:'), chalk.yellow('Default (recommended)'));
        hasModels = true;
      }
    } catch (error) {
    }
  }

  const cursorSettingsPath = path.join(targetPath, '.cursor/settings.json');
  if (fs.existsSync(cursorSettingsPath)) {
    try {
      const settings = await fs.readJSON(cursorSettingsPath);
      if (settings.model) {
        console.log(chalk.blue('Cursor:'), chalk.yellow(settings.model));
        hasModels = true;
      }
    } catch (error) {
    }
  }

  if (!hasModels) {
    console.log(chalk.yellow('No model versions configured yet'));
  }

  console.log('');
}

module.exports = { installInProject };
