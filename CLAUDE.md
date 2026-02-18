# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TensorX** is a VS Code color theme extension — a modern, deep-black dark theme designed for AI engineers and developers working with modern software stacks. It consists of two parts:
1. A **color theme** (`themes/islands-dark.json`) — loaded natively by VS Code via `package.json`
2. **CSS customizations** (`settings.json` under `custom-ui-style.stylesheet`) — applied via the "Custom UI Style" extension (subframe7536) to create floating panels, rounded corners, and glass-effect borders

## No Build Step

This is a static extension — no compilation, bundling, or build tools. There are no `devDependencies` or `node_modules`. Changes to `themes/islands-dark.json` or `settings.json` take effect immediately after reloading VS Code.

## Testing Changes

Testing is visual/manual:
1. Copy the extension folder to `~/.vscode/extensions/juansemastrangelo.tensorx-1.0.0/` (or run `install.sh` / `install.ps1`)
2. In VS Code: **Command Palette → Developer: Reload Window**
3. For CSS changes to `settings.json`: **Custom UI Style: Disable** then **Enable**

## Key Files

- `themes/islands-dark.json` — All VS Code color tokens (UI colors + syntax token colors). Base canvas is `#121216`.
- `settings.json` — CSS rules injected via Custom UI Style. Sets `workbench.colorTheme: "TensorX"`, font preferences, and all layout CSS.
- `fonts/` — Bear Sans UI `.otf` files (UI font). IBM Plex Mono (editor) and FiraCode Nerd Font Mono (terminal) are downloaded by the installer.
- `install.sh` / `install.ps1` — Full cross-platform installers. On Windows, also registers fonts in `HKCU` registry.
- `bootstrap.sh` / `bootstrap.ps1` — One-liner bootstrap that clones and runs the installer.

## Applying Settings Changes in Dev

When `settings.json` is modified, re-apply to VS Code user settings:
```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Users\juans\AppData\Local\Temp\merge-islands.ps1"
```
Then: **Custom UI Style: Disable** → **Enable**

## Publishing to VS Code Marketplace

```bash
vsce package          # creates tensorx-1.0.0.vsix
vsce login juansemastrangelo
vsce publish
```

The `.vsix` contains only `themes/`, `package.json`, `README.md`, `LICENSE` (~10KB).
