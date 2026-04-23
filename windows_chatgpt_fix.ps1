<#
.SYNOPSIS
Comprehensive repair for ChatGPT runtime issues on Windows.

.DESCRIPTION
This script repairs common causes of ChatGPT desktop launch/install failures:
- winget package lookup/index corruption ("package not found")
- missing Microsoft Edge WebView2 Runtime
- missing Microsoft Visual C++ runtime
- optional ChatGPT install/upgrade step

.EXAMPLE
./windows_chatgpt_fix.ps1

.EXAMPLE
./windows_chatgpt_fix.ps1 -InstallChatGPT
#>

param(
    [switch]$InstallChatGPT,
    [switch]$SkipVCRedist
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "   $Message" -ForegroundColor DarkGray
}

function Ensure-Winget {
    Write-Step "Checking winget availability"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget --version
        return
    }

    Write-Warning "winget is not installed. Install 'App Installer' from Microsoft Store, then rerun this script."
    Write-Host "Store product URL: https://apps.microsoft.com/detail/9NBLGGH4NNS1"
    exit 1
}

function Repair-WingetSources {
    Write-Step "Repairing winget sources"
    winget source reset --force
    winget source update
    winget source list
}

function Ensure-WebView2 {
    Write-Step "Installing/updating Microsoft Edge WebView2 Runtime"
    winget install --id Microsoft.EdgeWebView2Runtime --exact --accept-package-agreements --accept-source-agreements
}

function Ensure-VCRedist {
    if ($SkipVCRedist) {
        Write-Step "Skipping VC++ runtime step (requested)"
        return
    }

    Write-Step "Installing/updating Microsoft Visual C++ 2015-2022 Redistributable"
    winget install --id Microsoft.VCRedist.2015+.x64 --exact --accept-package-agreements --accept-source-agreements
}

function Ensure-ChatGPT {
    if (-not $InstallChatGPT) {
        Write-Step "Skipping ChatGPT package install (pass -InstallChatGPT to enable)"
        return
    }

    Write-Step "Attempting ChatGPT package install/upgrade"
    try {
        winget install --id OpenAI.ChatGPT --exact --accept-package-agreements --accept-source-agreements
        return
    }
    catch {
        Write-Warning "OpenAI.ChatGPT package id install failed. Trying discovery flow..."
    }

    $search = winget search --name ChatGPT
    Write-Info $search
    Write-Warning "Review results above and install the desired package id manually."
}

Write-Host "Starting Windows ChatGPT runtime repair workflow..." -ForegroundColor Green
Write-Info "Tip: Run in an elevated PowerShell session for best results."

Ensure-Winget
Repair-WingetSources
Ensure-WebView2
Ensure-VCRedist
Ensure-ChatGPT

Write-Host "`nRepair workflow complete." -ForegroundColor Green
Write-Host "Next steps: reboot Windows, then launch ChatGPT again." -ForegroundColor Green
