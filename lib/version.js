const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const readline = require('readline');

const TEMPLATE_DIR = path.join(__dirname, '..');

function createInterface() {
  return readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
}

function question(rl, query) {
  return new Promise((resolve) => {
    rl.question(query, resolve);
  });
}

async function checkVersionUpdates() {
  const versionsFilePath = path.join(TEMPLATE_DIR, '.model-versions.json');

  if (!fs.existsSync(versionsFilePath)) {
    console.log(chalk.yellow('⚠️  No version file found'));
    return;
  }

  try {
    const versions = await fs.readJSON(versionsFilePath);

    console.log('\n' + chalk.cyan('╔════════════════════════════════════════════════════════════════╗'));
    console.log(chalk.cyan('║') + '        ' + chalk.magenta('📋 Model Version Check') + '                           ' + chalk.cyan('║'));
    console.log(chalk.cyan('╚════════════════════════════════════════════════════════════════╝') + '\n');

    const rl = createInterface();

    if (versions.claude) {
      await checkModelVersion('Claude', versions.claude, '.claude/settings.json', rl);
    }

    if (versions.cursor) {
      await checkModelVersion('Cursor', versions.cursor, '.cursor/settings.json', rl);
    }

    rl.close();

    console.log(chalk.green('\n✅ Version check completed!\n'));

  } catch (error) {
    console.error(chalk.red('Error reading version file:'), error.message);
  }
}

async function checkModelVersion(modelName, versionInfo, settingsPath, rl) {
  const fullSettingsPath = path.join(TEMPLATE_DIR, settingsPath);

  if (!fs.existsSync(fullSettingsPath)) {
    console.log(chalk.gray(`${modelName}: Settings file not found`));
    return;
  }

  try {
    const settings = await fs.readJSON(fullSettingsPath);
    const currentVersion = typeof settings.model === 'string' 
      ? settings.model 
      : settings.model?.name;

    if (!currentVersion) {
      console.log(chalk.gray(`${modelName}: No model configured`));
      return;
    }

    console.log('');
    console.log(chalk.blue('━'.repeat(60)));
    console.log(chalk.blue.bold(`${modelName}:`));
    console.log(chalk.cyan('  Current:'), chalk.yellow(currentVersion));
    console.log(chalk.cyan('  Latest:'), chalk.yellow(versionInfo.latest));

    if (versionInfo.checkUrl) {
      console.log(chalk.cyan('  Info:'), chalk.gray(versionInfo.checkUrl));
    }

    if (currentVersion !== versionInfo.latest) {
      console.log(chalk.yellow('\n  ⚠️  New version available!'));

      const answer = await question(
        rl,
        chalk.blue(`  Update ${modelName} to ${versionInfo.latest}? [y/N]: `)
      );

      if (answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes') {
        if (typeof settings.model === 'object' && settings.model !== null) {
          settings.model.name = versionInfo.latest;
        } else {
          settings.model = versionInfo.latest;
        }
        await fs.writeJSON(fullSettingsPath, settings, { spaces: 2 });
        console.log(chalk.green(`  ✅ ${modelName} updated to ${versionInfo.latest}`));
        console.log(chalk.cyan('     (Repository template updated - run init/update on projects to apply)'));
      } else {
        console.log(chalk.cyan('     Skipped update'));
      }
    } else {
      console.log(chalk.green('  ✅ Up to date'));
    }

  } catch (error) {
    console.log(chalk.red(`${modelName}: Error reading settings -`), error.message);
  }
}

module.exports = { checkVersionUpdates };
