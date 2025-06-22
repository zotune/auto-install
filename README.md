
<img width="96" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/21bac34d-255b-4f61-b969-c8062f65ba13">

# Features
* Listen for archives and installers to appear in **Downloads** folder (as well as any subfolders)
* Auto-unpack `.zip`, `.rar`, `.7z` and `.iso` archives
* Auto-run `.msi` installers silently (will also uninstall first)
* Auto-detect installer type and run `.exe` installers silently (currently supports [NSIS](https://nsis.sourceforge.io/Main_Page), [Inno Setup](https://jrsoftware.org/isinfo.php), [InstallAware](https://www.installaware.com/) and [InstallShield](https://www.revenera.com/install/products/installshield) installers)

# How to use
* Install latest [AutoHotkey_1.1.x.x_setup.exe](https://www.autohotkey.com/download/1.1/?C=M;O=D) using installer (v2 is not supported)
* Install [7-Zip 64-bit](https://www.7-zip.org/) using installer
* Download and unpack [auto-install](https://codeload.github.com/zotune/auto-install/zip/refs/heads/main)
* Run `auto-install.ahk` (or run `auto-install.exe.ahk` and then `auto-install.exe`)
* Open folder `%UserProfile%\Downloads`
* Put installers/archives in the **Downloads** folder, they should automatically unpack and install

e.g. `Bitwig Studio 5.1.2.msi` downloaded from the [Bitwig download page](https://www.bitwig.com/download/) using [Google Chrome](https://www.google.com/chrome/):

<img width="219" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/5c86f819-883a-4bc5-ba9b-09b22d75982d">

↓

<img width="673" alt="image" src="https://github.com/zotune/auto-install/assets/13079592/6b6b7b89-9637-4726-be81-faa59a2b858e">

# Use-cases
* Automatically unpack and install hardware drivers or software you download with your browser, e.g. Google Chrome (notably installers that are not yet available for package managers such as [WinGet](https://github.com/microsoft/winget-cli) or [Ninite](https://ninite.com))
* Save all your drivers/software in a folder, and when reinstalling Windows, copy/move them to **Downloads** folder to automatically unpack and install them all.

_protip: most apps save their settings in folders `%AppData%`, `%LocalAppData%`, `%ProgramData%`, `%USERPROFILE%\Documents`  or windows registry paths such as `Computer\HKEY_CURRENT_USER\SOFTWARE`. if you backup these, you will probably be able to automatically restore your app settings after reinstalling windows (instead of having to configure them again manually). more on this [here](https://www.reddit.com/r/software/comments/3g4slg/before_upgrading_windows_using_a_clean_install/)_

# Troubleshooting

## I am out of disk space and I don't want to install to default installer folder

* Run this in cmd/powershell: `mklink /j "<DefaultInstallerLocation>" "<DesiredLocation>"`
* Then run the installer (or move it to **Downloads** folder to auto-install)

e.g.: run `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

## I installed to default installer folder, but now I want to move it to a different drive

* Move the whole folder from `<AlreadyInstalledLocation>` to `<DesiredLocation>` (not the contents)
* Run this in cmd/powershell: `mklink /j "<AlreadyInstalledLocation>" "<DesiredLocation>"`

e.g.: move `C:\Program Files\Bitwig Studio` folder to `D:\Apps\`, resulting in `D:\Apps\Bitwig Studio`. then run: `mklink /j "C:\Program Files\Bitwig Studio" "D:\Apps\Bitwig Studio"`

_protip: you can also save the `mklink` command in notepad and run it as a `.bat` file_

## One of the installers I tried did not run silently

Create an [issue](https://github.com/zotune/auto-install/issues). Describe the problem and be sure to include `strings2.txt` which should have been created next to `auto-install.ahk` when it scanned for silent install parameters. It usually contains words such as `NSIS`, `Inno Setup` etc which `auto-install` uses to determine which type of installer.

## Is there a standalone binary `auto-install.exe` I can use?

Yes. Simply run `auto-install.exe.ahk` and `AutoHotkey` should create a standalone compiled version for you in the same folder

_protip: this will have proper taskbar icon, and you can pin it to the taskbar_

## Does the app leave any files when I remove it?

No. It's a portable app which uses only the folder it is located in to generate things. Simply delete the script folder and it should be like the app never existed.

## I am afraid it will run everything that is already in my Downloads folder

It won't. `WatchFolder()` function only listens for changes (new files added to the **Downloads** folder or its subfolders). In any case, if you ever need to kill the app, simply press `ESC` when it is open.

## Is it safe?

Yes — all source code is available [here on GitHub](https://github.com/zotune/auto-install). There’s no hidden behavior. However, note that the app will run any installer you drop into your Downloads folder, so be cautious about what executables you use. Always verify the source.

## Can I choose to only install only certain options for the installers, such as `.aax` or `.vst` for music plugins?

Not directly. Installers don't typically offer a flags for all the options. For music plugins, `.aax`, `.vst3`, etc. don't take much space, but you can do the following:

1. Install everything
2. Use [Everything](https://www.voidtools.com/) or similar to search for `.aaxplugin`, `.clap`, `.vst3`
3. Manually delete what you don’t need — **after verifying the plugins still work**

---

## Can I use a folder other than `Downloads`?

Yes. Modify this line in `auto-install.ahk`:

`Folder := ComObjCreate("Shell.Application").NameSpace("shell:downloads").self.path` to something like `Folder := "D:\Temp"`

## It does not work?

1. Ensure you are using AutoHotkey v1.1 (not v2) and follow the instructions carefully.
2. Ensure you copy or download the installersr into the folder **while** `auto-install.ahk` is still running. It will not work if the installers are already present in the folder when you start `auto-install.ahk`

## Uses the following binaries/modules
* [strings2](https://github.com/glmcdona/strings2/releases) by **Geoff McDonald**
* [WatchFolder()](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=8384&hilit=watch) by **just me**
* [FileGetVersionInfo_AW()](https://www.autohotkey.com/board/topic/59496-filegetversioninfo-aw/) by **SKAN**
* [Stdout()](https://www.autohotkey.com/boards/viewtopic.php?style=7&t=56877) by **CyL0N**
* [taskbarInterface{}](https://github.com/HelgeffegleH/taskbarInterface) by **HelgeffegleH**

_64-bit operating system and installers are prioritized. Not for Mac OS or Linux._

<a href="https://www.buymeacoffee.com/adore" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
