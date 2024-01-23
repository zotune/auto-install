**Features:**
* Listens for installers and archives to appear in **Downloads** folder (as well as any subfolders)
* Automatically unpack `.zip`, `.rar`, `.7z` and `.iso` archives
* Automatically silent install `.msi` installers (will also uninstall first)
* Automatically detect and silent install `.exe` installers (currently supports [NSIS](https://nsis.sourceforge.io/Main_Page), [Inno Setup](https://jrsoftware.org/isinfo.php), [InstallAware](https://www.installaware.com/) and [InstallShield](https://www.revenera.com/install/products/installshield) installers)

**How to use:**
* Install [AutoHotkey v1.1.37.01](https://www.autohotkey.com/download/) using installer (v2 is not supported)
* Install [7-Zip 64-bit](https://www.7-zip.org/) using installer
* Download and unpack [auto-install](https://codeload.github.com/zotune/auto-install/zip/refs/heads/main)
* Run `auto-install.ahk` (it will run as admin)
* Open folder `%UserProfile%\Downloads`
* Put installers/archives in the **Downloads** folder, they should automatically unpack and install

e.g. `Bitwig Studio 5.1.2.msi` downloaded from the [Bitwig download page](https://www.bitwig.com/download/) using [Google Chrome](https://www.google.com/chrome/):

<img width="225" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/53264396-6481-42be-9c0a-613d4fc28d4c">

↓

<img width="598" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/9fd56cc6-2f4b-424a-8ed1-52eebb9eabeb">

**Use-cases:**
* Automatically unpack and install hardware drivers or software you download with your browser, e.g. Google Chrome (notably installers that are not yet available for package managers such as [WinGet](https://github.com/microsoft/winget-cli))
* Save all your drivers/software in a folder, and when reformatting Windows, copy/move them to **Downloads** folder to automatically unpack and install them all.

**Troubleshooting:**

**I am out of disk space and I don't want to install to default installer folder:**

* Run this in cmd/powershell: `mklink /j "<DefaultInstallerLocation>" "<DesiredLocation>"`
* Then run the installer (or move it to **Downloads** folder to auto-install)

e.g.: run `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

**I installed to default installer folder, but now I want to move it to a different drive:**

* Move the whole folder from `<AlreadyInstalledLocation>` to `<DesiredLocation>` (not the contents)
* Run this in cmd/powershell: `mklink /j "<AlreadyInstalledLocation>" "<DesiredLocation>"`

e.g.: move `C:\Program Files\Bitwig Studio` folder to `D:\Apps\`, resulting in `D:\Apps\Bitwig Studio`. then run: `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

_protip: you can also save the `mklink` command in notepad and run it as a `.bat` file_

**Uses the following binaries/modules:**
* [strings2](https://github.com/glmcdona/strings2/releases) by **Geoff McDonald**
* [WatchFolder()](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=8384&hilit=watch) by **just me**
* [FileGetVersionInfo_AW()](https://www.autohotkey.com/board/topic/59496-filegetversioninfo-aw/) by **SKAN**
* [Stdout()](https://www.autohotkey.com/boards/viewtopic.php?style=7&t=56877) by **CyL0N**
* [SetTaskbarProgress](https://www.autohotkey.com/board/topic/46860-windows-7-settaskbarprogress/page-2) by Lexikos and gwarble

_64-bit operating system and installers are prioritized. Not for Mac OS or Linux._

<a href="https://www.buymeacoffee.com/adore" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
