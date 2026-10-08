<div align="center">

```
 #   #  #####  ####    ###
  # #   #      #   #  #   #
   #    ####   ####   #   #
  # #   #      #  #   #   #
 #   #  #####  #   #   ###
```

# XERO

**Drivers. Apps. Restore. Zero fuss.**

A single-file, interactive Windows toolkit to back up and restore your drivers, install your essential apps, and export or restore your installed-apps list, all from a clean terminal menu.

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue)
![Type](https://img.shields.io/badge/script-Batch-green)
![Requires](https://img.shields.io/badge/requires-winget-orange)

</div>

---

## Why XERO?

Reinstalling Windows is painful: you lose your drivers, hunt down installers, and try to remember what you had installed. XERO turns that into a few keypresses. No dependencies, no installer, no PowerShell script to carry around. Just one `.bat` file.

## Features

- **Backup drivers**: exports every third-party driver using DISM.
- **Restore drivers**: reinstalls them from your backup with PnPUtil.
- **Install essential apps**: install the whole list in one go, or pick apps by number.
- **Export installed apps**: saves a restorable `.json` and a readable `.txt` list of what's on your PC.
- **Restore apps from list**: reinstalls everything from an exported list with winget.
- **Self-elevating**: asks for administrator rights on its own.
- **Interactive menu**: ASCII logo, boot sequence, and time-aware greeting.

## Requirements

- Windows 10 or Windows 11
- [winget](https://learn.microsoft.com/windows/package-manager/) (App Installer from the Microsoft Store; included on current Windows 11)
- Administrator rights (XERO requests them automatically)
- An internet connection for the app install and restore options

## Quick start

Just Open it and you are good to go..

## Menu

```
[1]  Backup my drivers
[2]  Restore my drivers
[3]  Install essential apps
[4]  Export my installed apps list
[5]  Restore apps from an exported list
[0]  Exit
```



### 3. Install essential apps
Choose **all at once** or **one by one**. In one-by-one mode you get a numbered list. Enter numbers separated by spaces or commas (for example `1 4 9`), or `A` for everything. A failed install never stops the rest, and you get a summary at the end.

### 4. Export installed apps list
Creates two files in `XERO_Backup\Apps`:

| File | Purpose |
|---|---|
| `installed-apps.json` | Used by XERO to restore your apps later |
| `installed-apps.txt` | Human-readable list of app names |

### 5. Restore apps from list
Reads `installed-apps.json` (or any file you point it to) and reinstalls what winget can find. Unavailable apps are skipped.

## Default essential apps

| # | App | # | App |
|---|---|---|---|
| 1 | Notepad++ | 8 | UniGetUI |
| 2 | Windows Terminal | 9 | 7-Zip |
| 3 | Node.js | 10 | PotPlayer |
| 4 | Zen Browser (Twilight) | 11 | Ghost Downloader |
| 5 | Opera | 12 | Telegram Desktop |
| 6 | Brave | 13 | VLC Media Player |
| 7 | Shift | 14 | SumatraPDF |

## Customization

Open `xero.bat` in any text editor.

**Change what Xero calls you** (top of the file):

```bat
set "BOSS=Boss"
```

**Add or remove essential apps.** Add a line in the app list and raise `APP_COUNT`:

```bat
set "APP_COUNT=15"
call :defapp 15 "Publisher.PackageId" "Display Name"
```

Find package IDs with `winget search <name>`.

## Backup folder layout

```
XERO_Backup/
├── Drivers/                 # exported driver packages
└── Apps/
    ├── installed-apps.json  # restorable app list
    └── installed-apps.txt   # readable app list
```

Copy the `XERO_Backup` folder to a USB drive or cloud storage before you reinstall Windows.

## Limitations

- Only apps available in winget sources can be restored automatically. Portable apps and manually installed software appear in the `.txt` list but won't be reinstalled.
- Some Microsoft Store and system components may fail to restore. XERO continues and reports a summary.
- Driver restore works best on the same hardware. Restoring on a different machine may install drivers that don't apply to it.
- Backed-up drivers are only the third-party drivers Windows exports. Drivers built into Windows are not included.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Winget is not available" | Install **App Installer** from the Microsoft Store, then reopen XERO |
| Window closes instantly | Run `xero.bat` from Command Prompt to see the error |
| Driver restore reports warnings | Usually means some drivers are already installed or unsigned; check the output |
| An app fails to install | It may already be installed, or its package ID changed; check with `winget search` |

## Contributing

Issues and pull requests are welcome. Ideas on the roadmap:

- Create a restore point before restoring drivers
- Zip backups with a date in the file name
- Custom app lists loaded from a file
- Auto-detect and use a backup folder on external drives

## Disclaimer

XERO changes system drivers and installs software. Use it at your own risk and keep a separate backup of important data. Always review the script before running it on a machine you care about.

## License

Released under the [MIT License](LICENSE).
