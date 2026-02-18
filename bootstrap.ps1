# Islands Dark Theme Bootstrap Installer for Windows
# One-liner: irm https://raw.githubusercontent.com/juansemastrangelo/tensorx/main/bootstrap.ps1 | iex

param()

$ErrorActionPreference = "Stop"

echo "ðŸï¸  Islands Dark Theme Bootstrap Installer"
echo "=========================================="
echo ""

$RepoUrl = "https://github.com/juansemastrangelo/tensorx.git"
$InstallDir = "$env:TEMP\tensorx-temp"

echo "ðŸ“¥ Step 1: Downloading Islands Dark..."
echo "   Repository: $RepoUrl"

# Remove old temp directory if exists
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

# Clone repository
try {
    git clone $RepoUrl $InstallDir --quiet
} catch {
    echo "âŒ Failed to download Islands Dark"
    echo "   Make sure Git is installed: https://git-scm.com/download/win"
    exit 1
}

echo "âœ“ Downloaded successfully"
echo ""

echo "ðŸš€ Step 2: Running installer..."
echo ""

# Run installer
cd $InstallDir
try {
    .\install.ps1
} catch {
    echo "âŒ Installation failed"
    echo $_.Exception.Message
    exit 1
}

# Cleanup
echo ""
echo "ðŸ§¹ Step 3: Cleaning up..."
$remove = Read-Host "   Remove temporary files? (y/n)"
if ($remove -eq 'y' -or $remove -eq 'Y') {
    Remove-Item -Recurse -Force $InstallDir
    echo "âœ“ Temporary files removed"
} else {
    echo "   Files kept at: $InstallDir"
}

echo ""
echo "ðŸŽ‰ Done! Enjoy your Islands Dark theme!"

