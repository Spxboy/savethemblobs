# ChatGPT Runtime Repair on Windows (Educational + Integration Guide)

This guide is for Windows users seeing one or more of these symptoms:
- `winget` says **"package not found"** for packages that should exist,
- ChatGPT desktop app installs but will not launch,
- runtime component errors mentioning WebView2 or VC++ redistributables.

## Why this happens

ChatGPT desktop depends on Windows package plumbing and runtime layers:
1. **App Installer / winget metadata** (package discovery and install channel),
2. **Microsoft Edge WebView2 Runtime** (embedded UI runtime),
3. **Microsoft VC++ runtime** (native dependency many apps need).

When any of these are stale/corrupt, installation or startup can fail.

## One-command repair

Open **PowerShell as Administrator** in this repo and run:

```powershell
./windows_chatgpt_fix.ps1 -InstallChatGPT
```

What this does, in order:
- verifies `winget` exists,
- resets/updates winget sources,
- installs/updates WebView2 runtime,
- installs/updates VC++ runtime,
- attempts ChatGPT package install/upgrade.

## Optional flags

- Skip VC++ step:

```powershell
./windows_chatgpt_fix.ps1 -InstallChatGPT -SkipVCRedist
```

- Run dependency-only repair without ChatGPT install:

```powershell
./windows_chatgpt_fix.ps1
```

## If PowerShell blocks script execution

Run once in an elevated PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then rerun the script.

## After repair

1. Reboot Windows.
2. Launch ChatGPT.
3. If install still fails, run `winget search --name ChatGPT` and verify package ids available on your machine.
