'use strict';

const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const SETUP_KEY = 'tensorx.setupComplete';

const FONT_REGISTRY_MAP = {
    'BearSansUI-Regular.otf':              'Bear Sans UI Regular (TrueType)',
    'BearSansUI-Bold.otf':                 'Bear Sans UI Bold (TrueType)',
    'BearSansUI-Italic.otf':               'Bear Sans UI Italic (TrueType)',
    'BearSansUI-BoldItalic.otf':           'Bear Sans UI Bold Italic (TrueType)',
    'BearSansUI-Medium.otf':               'Bear Sans UI Medium (TrueType)',
    'BearSansUI-MediumItalic.otf':         'Bear Sans UI Medium Italic (TrueType)',
    'BearSansUIHeading-Regular.otf':       'Bear Sans UI Heading Regular (TrueType)',
    'BearSansUIHeading-Bold.otf':          'Bear Sans UI Heading Bold (TrueType)',
    'BearSansUIHeading-BoldItalic.otf':    'Bear Sans UI Heading Bold Italic (TrueType)',
    'BearSansUIHeading-RegularItalic.otf': 'Bear Sans UI Heading Italic (TrueType)',
};

function getFontDir() {
    const platform = os.platform();
    if (platform === 'darwin') return path.join(os.homedir(), 'Library', 'Fonts');
    if (platform === 'linux')  return path.join(os.homedir(), '.local', 'share', 'fonts');
    if (platform === 'win32')  return path.join(process.env.LOCALAPPDATA || '', 'Microsoft', 'Windows', 'Fonts');
    return null;
}

function installFonts(extensionPath) {
    const fontsDir = path.join(extensionPath, 'fonts');
    if (!fs.existsSync(fontsDir)) return;

    const fontDir = getFontDir();
    if (!fontDir) return;

    if (!fs.existsSync(fontDir)) fs.mkdirSync(fontDir, { recursive: true });

    const files = fs.readdirSync(fontsDir).filter(f => f.endsWith('.otf'));
    for (const file of files) {
        const dest = path.join(fontDir, file);
        try {
            fs.copyFileSync(path.join(fontsDir, file), dest);

            if (os.platform() === 'win32' && FONT_REGISTRY_MAP[file]) {
                const regKey = 'HKCU\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts';
                execSync(`reg add "${regKey}" /v "${FONT_REGISTRY_MAP[file]}" /d "${dest}" /f`, { stdio: 'ignore' });
            }
        } catch (_) {}
    }

    if (os.platform() === 'linux') {
        try { execSync('fc-cache -f', { stdio: 'ignore' }); } catch (_) {}
    }
}

async function applySettings(extensionPath) {
    const settingsPath = path.join(extensionPath, 'settings.json');
    if (!fs.existsSync(settingsPath)) return;

    const newSettings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    const config = vscode.workspace.getConfiguration();

    for (const [key, value] of Object.entries(newSettings)) {
        try {
            await config.update(key, value, vscode.ConfigurationTarget.Global);
        } catch (_) {}
    }
}

async function activate(context) {
    if (context.globalState.get(SETUP_KEY)) return;

    const answer = await vscode.window.showInformationMessage(
        'TensorX: Set up the complete UI experience? (installs fonts, CSS effects, icon theme)',
        'Set up everything',
        'Color theme only'
    );

    context.globalState.update(SETUP_KEY, true);

    if (answer !== 'Set up everything') return;

    await vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: 'TensorX Setup',
        cancellable: false
    }, async (progress) => {
        progress.report({ message: 'Installing Custom UI Style...' });
        try {
            await vscode.commands.executeCommand(
                'workbench.extensions.installExtension',
                'subframe7536.custom-ui-style'
            );
        } catch (_) {}

        progress.report({ increment: 25, message: 'Installing Seti Folder icons...' });
        try {
            await vscode.commands.executeCommand(
                'workbench.extensions.installExtension',
                'l-igh-t.vscode-theme-seti-folder'
            );
        } catch (_) {}

        progress.report({ increment: 25, message: 'Installing fonts...' });
        installFonts(context.extensionPath);

        progress.report({ increment: 25, message: 'Applying settings...' });
        await applySettings(context.extensionPath);

        progress.report({ increment: 25, message: 'Done!' });
    });

    const enable = await vscode.window.showInformationMessage(
        'TensorX: Last step — enable Custom UI Style to activate floating panels and glass effects.',
        'Enable now'
    );

    if (enable === 'Enable now') {
        try {
            await vscode.commands.executeCommand('custom-ui-style.enable');
        } catch (_) {
            vscode.window.showInformationMessage(
                'TensorX: Open Command Palette and run "Custom UI Style: Enable" to finish setup.'
            );
        }
    }
}

function deactivate() {}

module.exports = { activate, deactivate };
