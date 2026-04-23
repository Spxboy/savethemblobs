# Discord + Equibop + Chrome Optimization (Windows)

This guide focuses on practical performance cleanup for Discord, Equibop, and Google Chrome.

## What the optimization script does

Run:

```powershell
./windows_apps_optimize.ps1 -OptimizeDiscord -OptimizeEquibop -OptimizeChrome -CreateOptimizedLaunchers
```

The script:
- stops the selected app processes (unless `-SkipProcessStop`),
- clears `Cache`, `Code Cache`, and `GPUCache`,
- optionally creates desktop launchers with conservative GPU acceleration flags.

## Why this helps

Electron/Chromium apps accumulate cache artifacts over time. Clearing stale cache and GPU cache can reduce jitter, startup lag, and rendering hitching.

## Useful command variants

Discord only:

```powershell
./windows_apps_optimize.ps1 -OptimizeDiscord
```

Equibop + Chrome only:

```powershell
./windows_apps_optimize.ps1 -OptimizeEquibop -OptimizeChrome
```

Keep apps running (skip process stop):

```powershell
./windows_apps_optimize.ps1 -OptimizeDiscord -SkipProcessStop
```

## Additional in-app tuning (recommended)

- Discord: Settings → Advanced → hardware acceleration ON unless unstable.
- Chrome: Settings → Performance → Memory Saver ON for lower RAM pressure.
- Equibop: keep stable release + avoid stacking too many visual plugins/themes.

## Safety notes

- Cache cleanup logs you out in some app sessions depending on local state.
- Closing apps before optimization gives best results.
- Reboot after heavy optimization if the system is still sluggish.
