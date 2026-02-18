#!/bin/bash

set -e

echo "TensorX Theme Installer for macOS/Linux"
echo "========================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v code &> /dev/null; then
    echo -e "${RED}Error: VS Code CLI (code) not found!${NC}"
    echo "Please install VS Code and make sure 'code' is in your PATH."
    echo "  1. Open VS Code"
    echo "  2. Press Cmd+Shift+P (macOS) or Ctrl+Shift+P (Linux)"
    echo "  3. Type 'Shell Command: Install code command in PATH'"
    exit 1
fi

echo -e "${GREEN}VS Code CLI found${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
fi

echo ""
echo "Step 1: Installing TensorX theme extension..."

EXT_DIR="$HOME/.vscode/extensions/juansemastrangelo.tensorx-1.0.0"
rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"
cp "$SCRIPT_DIR/package.json" "$EXT_DIR/"
cp -r "$SCRIPT_DIR/themes" "$EXT_DIR/"

if [ -d "$EXT_DIR/themes" ]; then
    echo -e "${GREEN}Theme extension installed${NC}"
else
    echo -e "${RED}Failed to install theme extension${NC}"
    exit 1
fi

echo ""
echo "Step 2: Installing VS Code extensions..."

if code --install-extension subframe7536.custom-ui-style --force &>/dev/null; then
    echo -e "${GREEN}Custom UI Style extension installed${NC}"
else
    echo -e "${YELLOW}Could not install Custom UI Style automatically - install it manually from the marketplace${NC}"
fi

if code --install-extension l-igh-t.vscode-theme-seti-folder --force &>/dev/null; then
    echo -e "${GREEN}Seti Folder icon theme installed${NC}"
else
    echo -e "${YELLOW}Could not install Seti Folder icon theme automatically${NC}"
fi

echo ""
echo "Step 3: Installing Bear Sans UI fonts..."
if cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null; then
    echo -e "${GREEN}Bear Sans UI fonts installed${NC}"
else
    echo -e "${YELLOW}Could not install Bear Sans UI fonts${NC}"
fi

echo ""
echo "Step 4: Installing IBM Plex Mono..."

IBM_INSTALLED=false

if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    if brew install --cask font-ibm-plex-mono &>/dev/null; then
        echo -e "${GREEN}IBM Plex Mono installed via Homebrew${NC}"
        IBM_INSTALLED=true
    fi
fi

if [ "$IBM_INSTALLED" = false ]; then
    FONT_TMP=$(mktemp -d)
    echo "   Downloading IBM Plex Mono..."
    if curl -fsSL "https://fonts.google.com/download?family=IBM+Plex+Mono" -o "$FONT_TMP/ibm-plex-mono.zip" 2>/dev/null; then
        unzip -q "$FONT_TMP/ibm-plex-mono.zip" -d "$FONT_TMP/ibm-plex-mono" 2>/dev/null
        find "$FONT_TMP/ibm-plex-mono" -name "*.ttf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null
        rm -rf "$FONT_TMP"
        echo -e "${GREEN}IBM Plex Mono installed${NC}"
    else
        rm -rf "$FONT_TMP"
        echo -e "${YELLOW}Could not download IBM Plex Mono - download manually from https://fonts.google.com/specimen/IBM+Plex+Mono${NC}"
    fi
fi

echo ""
echo "Step 5: Installing FiraCode Nerd Font..."

FIRA_TMP=$(mktemp -d)
echo "   Downloading FiraCode Nerd Font..."
if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -o "$FIRA_TMP/FiraCode.zip" 2>/dev/null; then
    unzip -q "$FIRA_TMP/FiraCode.zip" -d "$FIRA_TMP/FiraCode" 2>/dev/null
    find "$FIRA_TMP/FiraCode" -name "FiraCodeNerdFontMono*.ttf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null
    rm -rf "$FIRA_TMP"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        fc-cache -f 2>/dev/null || true
    fi
    echo -e "${GREEN}FiraCode Nerd Font Mono installed${NC}"
else
    rm -rf "$FIRA_TMP"
    echo -e "${YELLOW}Could not download FiraCode Nerd Font - download manually from https://www.nerdfonts.com/font-downloads${NC}"
fi

echo ""
echo "Step 6: Applying VS Code settings..."
SETTINGS_DIR="$HOME/.config/Code/User"
if [[ "$OSTYPE" == "darwin"* ]]; then
    SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
fi

mkdir -p "$SETTINGS_DIR"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}   Existing settings.json found - backing up and merging...${NC}"
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"

    if command -v node &> /dev/null; then
        node << 'NODE_SCRIPT'
const fs = require('fs');
const path = require('path');

function stripJsonc(text) {
    text = text.replace(/\/\/(?=(?:[^"\\]|\\.)*$)/gm, '');
    text = text.replace(/\/\*[\s\S]*?\*\//g, '');
    text = text.replace(/,\s*([}\]])/g, '$1');
    return text;
}

const scriptDir = process.cwd();
const newSettings = JSON.parse(stripJsonc(fs.readFileSync(path.join(scriptDir, 'settings.json'), 'utf8')));

let settingsDir;
if (process.platform === 'darwin') {
    settingsDir = path.join(process.env.HOME, 'Library/Application Support/Code/User');
} else {
    settingsDir = path.join(process.env.HOME, '.config/Code/User');
}

const settingsFile = path.join(settingsDir, 'settings.json');
const existingSettings = JSON.parse(stripJsonc(fs.readFileSync(settingsFile, 'utf8')));
const mergedSettings = { ...existingSettings, ...newSettings };

const key = 'custom-ui-style.stylesheet';
if (existingSettings[key] && newSettings[key]) {
    mergedSettings[key] = { ...existingSettings[key], ...newSettings[key] };
}

fs.writeFileSync(settingsFile, JSON.stringify(mergedSettings, null, 2));
console.log('Settings merged successfully');
NODE_SCRIPT
    else
        echo -e "${YELLOW}   Node.js not found - please merge settings.json manually${NC}"
    fi
else
    cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
    echo -e "${GREEN}Settings applied${NC}"
fi

echo ""
echo "Step 7: Enabling Custom UI Style..."

FIRST_RUN_FILE="$SCRIPT_DIR/.tensorx_first_run"
if [ ! -f "$FIRST_RUN_FILE" ]; then
    touch "$FIRST_RUN_FILE"
    echo ""
    echo -e "${YELLOW}Note: After VS Code reloads, you may see a 'corrupt installation' warning.${NC}"
    echo -e "${YELLOW}      This is expected - click the gear icon and select 'Don't Show Again'.${NC}"
    echo ""
    if [ -t 0 ]; then
        read -p "Press Enter to reload VS Code..."
    fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e 'display notification "TensorX installed successfully!" with title "TensorX"' 2>/dev/null || true
fi

echo "   Reloading VS Code..."
code --reload-window 2>/dev/null || code . 2>/dev/null || true

echo ""
echo -e "${GREEN}Done! Enjoy TensorX!${NC}"
