# TensorX - Theme for VS Code

![TensorX Overview](assets/CleanShot%202026-02-14%20at%2021.47.05@2x.png)
![TensorX UI](assets/CleanShot%202026-02-14%20at%2021.45.00@2x.png)

## Perfect for

- AI engineers
- Vibecoders
- Full-stack developers
- Night-time builders
- Deep work sessions


## Installation

This theme has two parts: a **color theme** and **CSS customizations** that create the floating glass panel look.

### One-Liner Install (Recommended)

#### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/juansemastrangelo/tensorx/main/bootstrap.sh | bash
```

#### Windows

```powershell
irm https://raw.githubusercontent.com/juansemastrangelo/tensorx/main/bootstrap.ps1 | iex
```

The scripts automatically:
- Install the TensorX theme extension
- Install the Custom UI Style extension
- Install Bear Sans UI fonts
- Download and install IBM Plex Mono and FiraCode Nerd Font
- Install Seti Folder icon theme
- Merge settings into your VS Code configuration
- Enable Custom UI Style and reload VS Code

### Manual Installation

#### Step 1: Install the theme

```bash
git clone https://github.com/juansemastrangelo/tensorx.git tensorx
cd tensorx
mkdir -p ~/.vscode/extensions/juansemastrangelo.tensorx-1.0.0
cp package.json ~/.vscode/extensions/juansemastrangelo.tensorx-1.0.0/
cp -r themes ~/.vscode/extensions/juansemastrangelo.tensorx-1.0.0/
```

On Windows (PowerShell):
```powershell
$ext = "$env:USERPROFILE\.vscode\extensions\juansemastrangelo.tensorx-1.0.0"
New-Item -ItemType Directory -Path $ext -Force
Copy-Item package.json $ext\
Copy-Item themes $ext\themes -Recurse
```

#### Step 2: Install Custom UI Style extension

The floating panels, rounded corners, glass borders, and animations require the **Custom UI Style** extension by `subframe7536`.

1. Open Extensions (`Ctrl+Shift+X`)
2. Search for **Custom UI Style**
3. Click Install

#### Step 3: Apply the settings

1. Open Command Palette (`Ctrl+Shift+P`)
2. Search for **Preferences: Open User Settings (JSON)**
3. Merge the contents of this repo's `settings.json` into your settings

#### Step 4: Enable Custom UI Style

1. Open Command Palette (`Ctrl+Shift+P`)
2. Run **Custom UI Style: Enable**
3. VS Code will reload

> **Note:** You may see a "corrupt installation" warning after enabling. This is expected — click the gear icon and select **Don't Show Again**.

## UI Customizations

| Element | Effect |
|---------|--------|
| **Canvas** | Deep dark background behind all panels |
| **Sidebar** | Floating with 24px rounded corners, glass borders, drop shadow |
| **Editor** | Floating with 24px rounded corners, glass borders |
| **Activity bar** | Pill-shaped with glass inset shadows, circular selection indicator |
| **Command center** | Pill-shaped with glass effect |
| **Bottom panel** | Floating with 14px rounded corners, glass borders |
| **Notifications** | 14px rounded corners, glass borders, deep drop shadow |
| **Command palette** | 16px rounded corners, glass borders, rounded list rows |
| **Scrollbars** | Pill-shaped thumbs with fade transition |
| **Tabs** | Browser-tab style, close button fades in on hover |
| **Breadcrumbs** | Hidden until hover with smooth fade transition |
| **Status bar** | Dimmed text that brightens on hover |

![TensorX Syntax](assets/CleanShot%202026-02-13%20at%2023.27.47@2x.png)

## Troubleshooting

### Changes aren't taking effect
1. **Command Palette** → **Custom UI Style: Disable**
2. Reload VS Code
3. **Command Palette** → **Custom UI Style: Enable**
4. Reload VS Code

### "Corrupt installation" warning
Expected after enabling Custom UI Style. Dismiss it or select **Don't Show Again**.

## License

MIT
