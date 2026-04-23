<#
.SYNOPSIS
Optimizes Discord, Equibop, and Google Chrome on Windows.

.DESCRIPTION
Performs safe, repeatable maintenance for Chromium/Electron-style desktop apps:
- optionally stops running app processes
- clears cache folders (Cache, Code Cache, GPUCache)
- prints recommended launch flags
- can create desktop launchers for Equibop/Chrome with performance flags

.EXAMPLE
./windows_apps_optimize.ps1 -OptimizeDiscord -OptimizeEquibop -OptimizeChrome
#>

param(
    [switch]$OptimizeDiscord,
    [switch]$OptimizeEquibop,
    [switch]$OptimizeChrome,
    [switch]$CreateOptimizedLaunchers,
    [switch]$SkipProcessStop
)

$ErrorActionPreference = "Stop"

function Write-Step { param([string]$m) Write-Host "`n==> $m" -ForegroundColor Cyan }
function Write-Info { param([string]$m) Write-Host "   $m" -ForegroundColor DarkGray }

function Stop-AppIfRunning {
    param([string]$ProcessName)
    if ($SkipProcessStop) {
        Write-Info "Skipping stop for $ProcessName (requested)."
        return
    }

    $p = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($p) {
        Write-Info "Stopping $ProcessName"
        $p | Stop-Process -Force
    }
}

function Clear-CacheSet {
    param([string[]]$Paths)
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            Write-Info "Clearing $path"
            Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function New-DesktopLauncher {
    param(
        [string]$Name,
        [string]$Target,
        [string]$Args
    )

    if (-not (Test-Path $Target)) {
        Write-Info "Launcher skipped for $Name (target not found): $Target"
        return
    }

    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop ("$Name (Optimized).lnk")
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $Target
    $shortcut.Arguments = $Args
    $shortcut.WorkingDirectory = Split-Path -Parent $Target
    $shortcut.Save()
    Write-Info "Created launcher: $shortcutPath"
}

function Optimize-Discord {
    Write-Step "Optimizing Discord"
    Stop-AppIfRunning -ProcessName "Discord"
    $base = Join-Path $env:APPDATA "discord"
    Clear-CacheSet -Paths @(
        (Join-Path $base "Cache"),
        (Join-Path $base "Code Cache"),
        (Join-Path $base "GPUCache")
    )
    Write-Info "Recommendation: In Discord > Settings > Advanced, keep hardware acceleration enabled unless unstable on your GPU."
}

function Optimize-Equibop {
    Write-Step "Optimizing Equibop"
    Stop-AppIfRunning -ProcessName "Equibop"
    $paths = @(
        (Join-Path $env:APPDATA "Equibop\Cache"),
        (Join-Path $env:APPDATA "Equibop\Code Cache"),
        (Join-Path $env:APPDATA "Equibop\GPUCache"),
        (Join-Path $env:LOCALAPPDATA "Equibop\Cache"),
        (Join-Path $env:LOCALAPPDATA "Equibop\Code Cache"),
        (Join-Path $env:LOCALAPPDATA "Equibop\GPUCache")
    )
    Clear-CacheSet -Paths $paths

    if ($CreateOptimizedLaunchers) {
        New-DesktopLauncher -Name "Equibop" -Target (Join-Path $env:LOCALAPPDATA "Programs\Equibop\Equibop.exe") -Args "--enable-gpu-rasterization --enable-zero-copy"
    }
}

function Optimize-Chrome {
    Write-Step "Optimizing Google Chrome"
    Stop-AppIfRunning -ProcessName "chrome"
    $base = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default"
    Clear-CacheSet -Paths @(
        (Join-Path $base "Cache"),
        (Join-Path $base "Code Cache"),
        (Join-Path $base "GPUCache")
    )

    if ($CreateOptimizedLaunchers) {
        New-DesktopLauncher -Name "Google Chrome" -Target (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe") -Args "--enable-gpu-rasterization --enable-zero-copy"
    }

    Write-Info "Recommendation: In Chrome > Settings > Performance, enable Memory Saver and Energy Saver as needed."
}

if (-not ($OptimizeDiscord -or $OptimizeEquibop -or $OptimizeChrome)) {
    Write-Warning "No optimization targets specified. Use one or more of: -OptimizeDiscord -OptimizeEquibop -OptimizeChrome"
    exit 1
}

Write-Host "Starting app optimization workflow..." -ForegroundColor Green

if ($OptimizeDiscord) { Optimize-Discord }
if ($OptimizeEquibop) { Optimize-Equibop }
if ($OptimizeChrome) { Optimize-Chrome }

Write-Host "`nDone. Relaunch selected apps and verify performance/latency." -ForegroundColor Green
