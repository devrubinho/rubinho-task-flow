const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const { showHeader, showSuccess, showError, showWarning, showInfo, showNextSteps } = require('./utils');

// Diretório onde o pacote npm está instalado globalmente
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
    // Verificar se diretório existe
    if (!fs.existsSync(targetPath)) {
      spinner.fail(chalk.red(`Directory not found: ${targetPath}`));
      process.exit(1);
    }

    // Verificar permissões de escrita
    try {
      fs.accessSync(targetPath, fs.constants.W_OK);
    } catch (error) {
      spinner.fail(chalk.red('No write permission in target directory'));
      process.exit(1);
    }

    spinner.text = 'Creating directories...';

    // Criar diretórios necessários
    const dirs = [
      '.cursor/rules',
      '.claude',
      '.gemini',
      '.task-flow'
    ];

    for (const dir of dirs) {
      await fs.ensureDir(path.join(targetPath, dir));
    }

    spinner.text = 'Copying configuration files...';

    // Copiar arquivos de configuração
    await copyConfigs(targetPath);

    spinner.text = 'Updating .gitignore...';

    // Atualizar .gitignore
    await updateGitignore(targetPath);

    spinner.succeed(chalk.green('Installation completed!'));

    console.log('');

    // Mostrar versões configuradas
    await showModelVersions(targetPath);

    showNextSteps(targetPath);

  } catch (error) {
    spinner.fail(chalk.red('Installation failed'));
    console.error(chalk.red('\nError:'), error.message);
    process.exit(1);
  }
}

async function copyConfigs(targetPath) {
  // Copiar regras do Cursor
  const cursorRulesPath = path.join(TEMPLATE_DIR, '.cursor/rules');
  if (fs.existsSync(cursorRulesPath)) {
    await fs.copy(
      cursorRulesPath,
      path.join(targetPath, '.cursor/rules'),
      { overwrite: true }
    );
    showSuccess('Cursor rules');
  }

  // Copiar settings do Cursor
  const cursorSettingsPath = path.join(TEMPLATE_DIR, '.cursor/settings.json');
  if (fs.existsSync(cursorSettingsPath)) {
    await fs.copy(
      cursorSettingsPath,
      path.join(targetPath, '.cursor/settings.json'),
      { overwrite: true }
    );
    showSuccess('Cursor settings');
  }

  // Copiar settings do Claude
  const claudeSettingsPath = path.join(TEMPLATE_DIR, '.claude/settings.json');
  if (fs.existsSync(claudeSettingsPath)) {
    await fs.copy(
      claudeSettingsPath,
      path.join(targetPath, '.claude/settings.json'),
      { overwrite: true }
    );
    showSuccess('Claude settings');
  }

  // Copiar instruções do Claude
  const claudeInstructionsPath = path.join(TEMPLATE_DIR, 'CLAUDE.md');
  if (fs.existsSync(claudeInstructionsPath)) {
    await fs.copy(
      claudeInstructionsPath,
      path.join(targetPath, 'CLAUDE.md'),
      { overwrite: true }
    );
    showSuccess('Claude instructions');
  }

  // Copiar settings do Gemini
  const geminiSettingsPath = path.join(TEMPLATE_DIR, '.gemini/settings.json');
  if (fs.existsSync(geminiSettingsPath)) {
    await fs.copy(
      geminiSettingsPath,
      path.join(targetPath, '.gemini/settings.json'),
      { overwrite: true }
    );
    showSuccess('Gemini settings');
  }

  // Copiar instruções do Gemini
  const geminiInstructionsPath = path.join(TEMPLATE_DIR, 'GEMINI.md');
  if (fs.existsSync(geminiInstructionsPath)) {
    await fs.copy(
      geminiInstructionsPath,
      path.join(targetPath, 'GEMINI.md'),
      { overwrite: true }
    );
    showSuccess('Gemini instructions');
  }

  // Copiar Task Flow (preservando dados internos)
  await copyTaskFlow(targetPath);
}

async function copyTaskFlow(targetPath) {
  const taskFlowSrc = path.join(TEMPLATE_DIR, '.task-flow');
  const taskFlowDest = path.join(targetPath, '.task-flow');

  await fs.ensureDir(taskFlowDest);

  showSuccess('Task Flow directory');
  showInfo('Note: .internal/tasks.json and .internal/status.json are NOT overwritten (your data is safe)');

  // Criar pasta screens
  const screensDest = path.join(taskFlowDest, 'screens');
  await fs.ensureDir(screensDest);
  showSuccess('Screenshots directory (.task-flow/screens/)');

  // Copiar arquivo de exemplo para screens se não existir
  const exampleSrc = path.join(taskFlowSrc, 'screens/example.png.txt');
  const exampleDest = path.join(screensDest, 'example.png.txt');
  if (fs.existsSync(exampleSrc) && !fs.existsSync(exampleDest)) {
    await fs.copy(exampleSrc, exampleDest);
  }

  // Copiar apenas templates, não sobrescrever dados do usuário
  const files = [
    { name: 'README.md', overwrite: true },
    { name: 'tasks.input.txt', overwrite: false },
    { name: 'tasks.status.md', overwrite: false }
  ];

  for (const file of files) {
    const src = path.join(taskFlowSrc, file.name);
    const dest = path.join(taskFlowDest, file.name);

    if (fs.existsSync(src)) {
      // Sempre sobrescrever README, outros arquivos só se não existirem
      if (file.overwrite || !fs.existsSync(dest)) {
        await fs.copy(src, dest, { overwrite: file.overwrite });
      }
    }
  }

  // Não copiar .internal - deixar que seja criado pela IA
}

async function updateGitignore(targetPath) {
  const gitignorePath = path.join(targetPath, '.gitignore');

  // Criar se não existe
  if (!fs.existsSync(gitignorePath)) {
    await fs.writeFile(gitignorePath, '');
  }

  let content = await fs.readFile(gitignorePath, 'utf8');

  // Entradas a adicionar
  const entries = [
    '.claude/',
    '.gemini/',
    '.cursor/',
    '.task-flow/',
    'CLAUDE.md',
    'GEMINI.md'
  ];

  // Remover entradas antigas (caso existam)
  for (const entry of entries) {
    const regex = new RegExp(`^${entry.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, 'gm');
    content = content.replace(regex, '');
  }

  // Remover linhas vazias consecutivas
  content = content.replace(/\n{3,}/g, '\n\n');

  // Adicionar novas entradas
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

  // Claude
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
      // Ignorar erros de parsing
    }
  }

  // Cursor
  const cursorSettingsPath = path.join(targetPath, '.cursor/settings.json');
  if (fs.existsSync(cursorSettingsPath)) {
    try {
      const settings = await fs.readJSON(cursorSettingsPath);
      if (settings.model) {
        console.log(chalk.blue('Cursor:'), chalk.yellow(settings.model));
        hasModels = true;
      }
    } catch (error) {
      // Ignorar erros de parsing
    }
  }

  // Gemini
  const geminiSettingsPath = path.join(targetPath, '.gemini/settings.json');
  if (fs.existsSync(geminiSettingsPath)) {
    try {
      const settings = await fs.readJSON(geminiSettingsPath);
      if (settings.model) {
        console.log(chalk.blue('Gemini:'), chalk.yellow(settings.model));
        hasModels = true;
      }
    } catch (error) {
      // Ignorar erros de parsing
    }
  }

  if (!hasModels) {
    console.log(chalk.yellow('No model versions configured yet'));
  }

  console.log('');
}

module.exports = { installInProject };
