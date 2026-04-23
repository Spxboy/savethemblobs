<#
.SYNOPSIS
Repairs common Windows ChatGPT install/runtime issues tied to package discovery and Edge WebView2.

.DESCRIPTION
This script performs a "simultaneous" repair workflow:
1) Verifies winget/App Installer availability.
2) Resets winget sources (fixes many "package not found" issues).
3) Installs or upgrades Microsoft Edge WebView2 Runtime.
4) Optionally installs/updates Microsoft Visual C++ runtime.

Run from an elevated PowerShell prompt for best results.
#>

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Ensure-Winget {
    Write-Step "Checking winget availability"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget --version
        return
    }

    Write-Warning "winget was not found. Install App Installer from Microsoft Store and re-run this script."
    Write-Host "Store product: https://apps.microsoft.com/detail/9NBLGGH4NNS1"
    exit 1
}

function Reset-WingetSources {
    Write-Step "Resetting winget sources (repairs package lookup index)"
    winget source reset --force
    winget source update
    winget source list
}

function Install-WebView2 {
    Write-Step "Installing/updating Microsoft Edge WebView2 Runtime"
    winget install --id Microsoft.EdgeWebView2Runtime --exact --accept-package-agreements --accept-source-agreements
}

function Install-VCRedist {
    Write-Step "Installing/updating Microsoft Visual C++ 2015-2022 Redistributable"
    winget install --id Microsoft.VCRedist.2015+.x64 --exact --accept-package-agreements --accept-source-agreements
}

Write-Host "This script repairs common ChatGPT-on-Windows dependency issues." -ForegroundColor Green
Ensure-Winget
Reset-WingetSources
Install-WebView2
Install-VCRedist

Write-Host "`nDone. Please restart Windows, then launch ChatGPT again." -ForegroundColor Green
