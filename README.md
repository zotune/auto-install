# Features:
* Listen for archives and installers to appear in **Downloads** folder (as well as any subfolders)
* Auto-unpack `.zip`, `.rar`, `.7z` and `.iso` archives
* Auto-run `.msi` installers silently (will also uninstall first)
* Auto-detect installer type and run `.exe` installers silently (currently supports [NSIS](https://nsis.sourceforge.io/Main_Page), [Inno Setup](https://jrsoftware.org/isinfo.php), [InstallAware](https://www.installaware.com/) and [InstallShield](https://www.revenera.com/install/products/installshield) installers)

# How to use:
* Install [AutoHotkey v1.1.37.01](https://www.autohotkey.com/download/) using installer (v2 is not supported)
* Install [7-Zip 64-bit](https://www.7-zip.org/) using installer
* Download and unpack [auto-install](https://codeload.github.com/zotune/auto-install/zip/refs/heads/main)
* Run `auto-install.ahk` (it will run as admin)
* Open folder `%UserProfile%\Downloads`
* Put installers/archives in the **Downloads** folder, they should automatically unpack and install

e.g. `Bitwig Studio 5.1.2.msi` downloaded from the [Bitwig download page](https://www.bitwig.com/download/) using [Google Chrome](https://www.google.com/chrome/):

<img width="219" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/5c86f819-883a-4bc5-ba9b-09b22d75982d">

↓

<img width="673" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/b42f1abc-91b1-44dd-bc1c-9fda650bc4cc">

# Use-cases:
* Automatically unpack and install hardware drivers or software you download with your browser, e.g. Google Chrome (notably installers that are not yet available for package managers such as [WinGet](https://github.com/microsoft/winget-cli) or [Ninite](https://ninite.com))
* Save all your drivers/software in a folder, and when reformatting Windows, copy/move them to **Downloads** folder to automatically unpack and install them all.

# Troubleshooting:

## I am out of disk space and I don't want to install to default installer folder:

* Run this in cmd/powershell: `mklink /j "<DefaultInstallerLocation>" "<DesiredLocation>"`
* Then run the installer (or move it to **Downloads** folder to auto-install)

e.g.: run `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

## I installed to default installer folder, but now I want to move it to a different drive:

* Move the whole folder from `<AlreadyInstalledLocation>` to `<DesiredLocation>` (not the contents)
* Run this in cmd/powershell: `mklink /j "<AlreadyInstalledLocation>" "<DesiredLocation>"`

e.g.: move `C:\Program Files\Bitwig Studio` folder to `D:\Apps\`, resulting in `D:\Apps\Bitwig Studio`. then run: `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

_protip: you can also save the `mklink` command in notepad and run it as a `.bat` file_

## One of the installers I tried did not run silently:

Create an [issue](https://github.com/zotune/auto-install/issues). Describe the problem and be sure to include `strings2.txt` which should have been created next to `auto-install.ahk` when it scanned for silent install parameters.

### Uses the following binaries/modules:
* [strings2](https://github.com/glmcdona/strings2/releases) by **Geoff McDonald**
* [WatchFolder()](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=8384&hilit=watch) by **just me**
* [FileGetVersionInfo_AW()](https://www.autohotkey.com/board/topic/59496-filegetversioninfo-aw/) by **SKAN**
* [Stdout()](https://www.autohotkey.com/boards/viewtopic.php?style=7&t=56877) by **CyL0N**
* [SetTaskbarProgress()](https://www.autohotkey.com/board/topic/46860-windows-7-settaskbarprogress/page-2) by Lexikos and gwarble

_64-bit operating system and installers are prioritized. Not for Mac OS or Linux._

<a href="https://www.buymeacoffee.com/adore" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
