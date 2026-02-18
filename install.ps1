# TensorX Theme Installer for Windows

param()

$ErrorActionPreference = "Stop"

Write-Host "TensorX Theme Installer for Windows" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if VS Code is installed
$codePath = Get-Command "code" -ErrorAction SilentlyContinue
if (-not $codePath) {
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
    )

    $found = $false
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $env:Path += ";$(Split-Path $path)"
            $found = $true
            break
        }
    }

    if (-not $found) {
        Write-Host "Error: VS Code CLI (code) not found!" -ForegroundColor Red
        Write-Host "Please install VS Code and make sure 'code' command is in your PATH."
        exit 1
    }
}

Write-Host "VS Code CLI found" -ForegroundColor Green

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontDir)) {
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
}

Write-Host ""
Write-Host "Step 1: Installing TensorX theme extension..."

$extDir = "$env:USERPROFILE\.vscode\extensions\juansemastrangelo.tensorx-1.0.0"
if (Test-Path $extDir) {
    Remove-Item -Recurse -Force $extDir
}
New-Item -ItemType Directory -Path $extDir -Force | Out-Null
Copy-Item "$scriptDir\package.json" "$extDir\" -Force
Copy-Item "$scriptDir\themes" "$extDir\themes" -Recurse -Force

if (Test-Path "$extDir\themes") {
    Write-Host "Theme extension installed" -ForegroundColor Green
} else {
    Write-Host "Failed to install theme extension" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Installing VS Code extensions..."

try {
    code --install-extension subframe7536.custom-ui-style --force 2>$null | Out-Null
    Write-Host "Custom UI Style extension installed" -ForegroundColor Green
} catch {
    Write-Host "Could not install Custom UI Style automatically - install it manually from the marketplace" -ForegroundColor Yellow
}

try {
    code --install-extension l-igh-t.vscode-theme-seti-folder --force 2>$null | Out-Null
    Write-Host "Seti Folder icon theme installed" -ForegroundColor Green
} catch {
    Write-Host "Could not install Seti Folder icon theme automatically" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Installing Bear Sans UI fonts..."
try {
    $fonts = Get-ChildItem "$scriptDir\fonts\*.otf"
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontNames = @{
        "BearSansUI-Regular.otf"              = "Bear Sans UI Regular (TrueType)"
        "BearSansUI-Bold.otf"                 = "Bear Sans UI Bold (TrueType)"
        "BearSansUI-Italic.otf"               = "Bear Sans UI Italic (TrueType)"
        "BearSansUI-BoldItalic.otf"           = "Bear Sans UI Bold Italic (TrueType)"
        "BearSansUI-Medium.otf"               = "Bear Sans UI Medium (TrueType)"
        "BearSansUI-MediumItalic.otf"         = "Bear Sans UI Medium Italic (TrueType)"
        "BearSansUIHeading-Regular.otf"       = "Bear Sans UI Heading Regular (TrueType)"
        "BearSansUIHeading-Bold.otf"          = "Bear Sans UI Heading Bold (TrueType)"
        "BearSansUIHeading-BoldItalic.otf"    = "Bear Sans UI Heading Bold Italic (TrueType)"
        "BearSansUIHeading-RegularItalic.otf" = "Bear Sans UI Heading Italic (TrueType)"
    }
    foreach ($font in $fonts) {
        $dest = Join-Path $fontDir $font.Name
        Copy-Item $font.FullName $dest -Force -ErrorAction SilentlyContinue
        if ($fontNames.ContainsKey($font.Name)) {
            Set-ItemProperty -Path $regPath -Name $fontNames[$font.Name] -Value $dest -ErrorAction SilentlyContinue
        }
    }
    Write-Host "Bear Sans UI fonts installed and registered" -ForegroundColor Green
} catch {
    Write-Host "Could not install Bear Sans UI fonts" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 4: Installing IBM Plex Mono..."
try {
    $ibmTmp = Join-Path $env:TEMP "ibm-plex-mono"
    if (Test-Path $ibmTmp) { Remove-Item -Recurse -Force $ibmTmp }
    New-Item -ItemType Directory -Path $ibmTmp -Force | Out-Null

    Write-Host "   Downloading IBM Plex Mono..." -ForegroundColor DarkGray
    Invoke-WebRequest -Uri "https://fonts.google.com/download?family=IBM+Plex+Mono" -OutFile "$ibmTmp\ibm-plex-mono.zip" -UseBasicParsing
    Expand-Archive -Path "$ibmTmp\ibm-plex-mono.zip" -DestinationPath "$ibmTmp\extracted" -Force
    Get-ChildItem "$ibmTmp\extracted" -Recurse -Filter "*.ttf" | ForEach-Object {
        Copy-Item $_.FullName $fontDir -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -Recurse -Force $ibmTmp
    Write-Host "IBM Plex Mono installed" -ForegroundColor Green
} catch {
    Write-Host "Could not download IBM Plex Mono - download manually from https://fonts.google.com/specimen/IBM+Plex+Mono" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Installing FiraCode Nerd Font..."
try {
    $firaTmp = Join-Path $env:TEMP "firacode-nerd"
    if (Test-Path $firaTmp) { Remove-Item -Recurse -Force $firaTmp }
    New-Item -ItemType Directory -Path $firaTmp -Force | Out-Null

    Write-Host "   Downloading FiraCode Nerd Font..." -ForegroundColor DarkGray
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -OutFile "$firaTmp\FiraCode.zip" -UseBasicParsing
    Expand-Archive -Path "$firaTmp\FiraCode.zip" -DestinationPath "$firaTmp\extracted" -Force
    Get-ChildItem "$firaTmp\extracted" -Recurse -Filter "FiraCodeNerdFontMono*.ttf" | ForEach-Object {
        Copy-Item $_.FullName $fontDir -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -Recurse -Force $firaTmp
    Write-Host "FiraCode Nerd Font Mono installed" -ForegroundColor Green
} catch {
    Write-Host "Could not download FiraCode Nerd Font - download manually from https://www.nerdfonts.com/font-downloads" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 6: Applying VS Code settings..."
$settingsDir = "$env:APPDATA\Code\User"
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}

$settingsFile = Join-Path $settingsDir "settings.json"

function Strip-Jsonc {
    param([string]$Text)
    $Text = $Text -replace '//.*$', ''
    $Text = $Text -replace '/\*[\s\S]*?\*/', ''
    $Text = $Text -replace ',\s*([}\]])', '$1'
    return $Text
}

$newSettingsRaw = Get-Content "$scriptDir\settings.json" -Raw
$newSettings = (Strip-Jsonc $newSettingsRaw) | ConvertFrom-Json

if (Test-Path $settingsFile) {
    Write-Host "   Existing settings.json found - backing up and merging..." -ForegroundColor Yellow
    Copy-Item $settingsFile "$settingsFile.backup" -Force

    try {
        $existingRaw = Get-Content $settingsFile -Raw
        $existingSettings = (Strip-Jsonc $existingRaw) | ConvertFrom-Json

        $mergedSettings = @{}
        $existingSettings.PSObject.Properties | ForEach-Object { $mergedSettings[$_.Name] = $_.Value }
        $newSettings.PSObject.Properties | ForEach-Object { $mergedSettings[$_.Name] = $_.Value }

        $stylesheetKey = 'custom-ui-style.stylesheet'
        if ($existingSettings.$stylesheetKey -and $newSettings.$stylesheetKey) {
            $mergedStylesheet = @{}
            $existingSettings.$stylesheetKey.PSObject.Properties | ForEach-Object { $mergedStylesheet[$_.Name] = $_.Value }
            $newSettings.$stylesheetKey.PSObject.Properties | ForEach-Object { $mergedStylesheet[$_.Name] = $_.Value }
            $mergedSettings[$stylesheetKey] = [PSCustomObject]$mergedStylesheet
        }

        [PSCustomObject]$mergedSettings | ConvertTo-Json -Depth 100 | Set-Content $settingsFile
        Write-Host "Settings merged successfully" -ForegroundColor Green
    } catch {
        Write-Host "Could not merge settings automatically - please merge settings.json manually" -ForegroundColor Yellow
    }
} else {
    Copy-Item "$scriptDir\settings.json" $settingsFile
    Write-Host "Settings applied" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 7: Enabling Custom UI Style..."

$firstRunFile = Join-Path $scriptDir ".islands_dark_first_run"
if (-not (Test-Path $firstRunFile)) {
    New-Item -ItemType File -Path $firstRunFile | Out-Null
    Write-Host ""
    Write-Host "Note: After VS Code reloads, you may see a 'corrupt installation' warning." -ForegroundColor Yellow
    Write-Host "      This is expected - click the gear icon and select 'Don't Show Again'." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to reload VS Code"
}

Write-Host ""
Write-Host "TensorX theme has been installed!" -ForegroundColor Green
Write-Host "   Reloading VS Code..." -ForegroundColor Cyan

try {
    code --reload-window 2>$null
} catch {
    try { code $scriptDir 2>$null } catch {}
}

Write-Host ""
Write-Host "Done! Enjoy TensorX! ðŸï¸" -ForegroundColor Green

Start-Sleep -Seconds 2

