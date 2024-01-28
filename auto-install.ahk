#Singleinstance, force
#Persistent
#NoTrayIcon
#Include %A_ScriptDir%\WatchFolder.ahk
#Include %A_ScriptDir%\FileGetVersionInfo_AW.ahk
#Include %A_ScriptDir%\Std.ahk
#Include %A_ScriptDir%\taskbarInterface.ahk

;Config
Folder:=ComObjCreate("Shell.Application").NameSpace("shell:downloads").self.path
;Config end

RunAsAdmin()
ForCompile()

Stdout("Auto-install by Mikael Ellingsen (zotune@gmail.com)`nhttps://github.com/zotune/auto-install`nFolder currently set to: '" Folder "'`n`n- Press SPACE to pause/resume`n- Press F5 to reload`n- Press F1 for help`n- Press F or D to open listening folder`n- Press S to open script folder`n- Press ESC to exit`n`n[=== LISTENING ===]")
WatchFolder(Folder, "DetectFile", True, 0x01)
; EnvGet, ProgramFilesX86, ProgramFiles(x86)
; WatchFolder(ProgramFiles, "DetectFolder", False, 0x16), WatchFolder(ProgramFilesX86, "DetectFolder", False, 0x16)

Global tbi, Download, Idle, Install, Pause
WinGet, ID, IDLast , % "ahk_pid " GetCurrentProcess()
tbi:= new taskbarInterface(ID)

Icon := LoadPicture(A_WorkingDir "\app.ico", "Icon1", isIcon)
tbi.setTaskBarIcon(Icon)

Download := LoadPicture(A_WorkingDir "\download.ico", "Icon1", isIcon)
Idle := LoadPicture(A_WorkingDir "\idle.ico", "Icon1", isIcon)
Pause := LoadPicture(A_WorkingDir "\pause.ico", "Icon1", isIcon)
Install := LoadPicture(A_WorkingDir "\install.ico", "Icon1", isIcon)
tbi.setOverlayIcon(Idle)

; DetectFolder(Directory, Changes) {
;     global prevPath
;     For Each, Change In Changes {
;         Action := Change.Action
;         Path := Change.Name
;         if (Path = prevPath)
;             continue
;         prevPath := Path
;         if (Action = 3)
;         {
;             Stdout("New app found in: " Path)
;         }
;     }
; }


DetectFile(Directory, Changes) {
    For Each, Change In Changes {
        Action := Change.Action
        Path := Change.Name
        SplitPath, Path, Name, Dir, Extension, OutNameNoExt
        SplitPath, Dir, ParentName, ParentDir

        if (Action != 1) and (Action != 4)
            continue
        if ((Extension = "exe" or Extension = "msi") and (InStr(Name,"32bit") or InStr(Name,"32-bit") or InStr(Name,"keygen") or InStr(Name,"activate") or (InStr(Name,"x86") and !InStr(Name,"64"))))
            continue
        while IsLocked(Path)
        {
            if (A_Index = 1)
                tbi.setOverlayIcon(Download)
            sleep, 500
        }
        tbi.SetProgressType("INDETERMINATE")
        tbi.setOverlayIcon(Install)
        if (Extension = "exe"){
            Stdout("`n[=== """ Name """ ===]")
            Stdout("Scanning for silent install switches")
            ProductName := FileGetVersionInfo_AW(Path,"ProductName")
            if (InStr(ProductName,"NVIDIA Package")=1)
                SilentArguments := "-s"
            else
                SilentArguments := ExeInstallerIs(Path)
            ; Commented out auto detect silent install switches (required for installers where info is only available in /? help)
            ; if (SilentArguments = "")
            ; {
            ;     Run, "%Path%" /?,, Min
            ;     WinWait, ahk_exe %Name%
            ;     WinGetText, Text, ahk_exe %Name%
            ;     WinClose, ahk_exe %Name%
            ;     Parameters := ["/INSTALL","/SILENT","/QUIET","/NORESTART","/SUPPRESSMSGBOXES"]
            ;     for a, Parameter in Parameters
            ;     {
            ;         if InStr(Text, Parameter)
            ;             SilentArguments .= " " Parameter
            ;     }
            ; }
            if (SilentArguments != "")
            {
                NameWithoutVersion := NameWithoutVersion(ProductName)
                ;Commented out uninstall for .exe
                ; if (NameWithoutVersion != "")
                ;     UninstallString := GetUninstallString(NameWithoutVersion)
                ; if (UninstallString != "")
                ; {
                ;     Stdout("Uninstalling using " UninstallString)
                ;     RunWait, %UninstallString%,, Min ;S required for NSIS
                ;     Stdout("Uninstalled " NameWithoutVersion)
                ; }
                ; else
                ;     Stdout("Did not find other versions of " NameWithoutVersion)
                SilentArguments:=Trim(SilentArguments," ")
                Stdout("Installing using """ Name """ " SilentArguments)
                RunWait, "%Path%" %SilentArguments%,, Min
                Stdout("Installed " NameWithoutVersion)
            }
            else
                Stdout("Found no silent install switches")
            Stdout("[=== """ Name """ ===]")
        }
        else if (Extension = "msi"){
            if FileExist(Dir "\" OutNameNoExt ".exe")
                continue
            Stdout("`n[=== """ Name """ ===]")
            NameWithoutVersion := NameWithoutVersion(MSIInfo(Path,"ProductName"))
            UninstallString := GetUninstallString(NameWithoutVersion,MSIInfo(Path,"Manufacturer"))
            if (UninstallString != "")
            {
                Stdout("Uninstalling using " UninstallString)
                RunWait, %UninstallString%,, Min
                Stdout("Uninstalled " NameWithoutVersion)
            } 
            else
                Stdout("Did not find other versions of " NameWithoutVersion)
            Stdout("Installing using msiexec /i """ Path """ ALLUSERS=1 /qn /norestart")
            RunWait, msiexec /i "%Path%" ALLUSERS=1 /qn /norestart,, Min
            Stdout("Installed " NameWithoutVersion)
            Stdout("[=== """ Name """ ===]")
        }
        else if (Extension = "rar") or (Extension = "zip") or (Extension = "7z") or (Extension = "iso")
        {
            Stdout("`n[=== """ Name """ ===]")
            7zipPath=%ProgramFiles%\7-Zip\7z.exe
            if !FileExist(7zipPath)
                Stdout("ERROR: 7-zip not installed at: """ 7zipPath """")
            Stdout("Unpacking " Name)
            ; Commented out delete files method
            ; FileList := []
            ; Loop, Files, % Dir "\*.*", F
            ;     if (A_LoopFileExt != "nfo") and (A_LoopFileExt != "sfv")
            ;         FileList.Push(A_LoopFileFullPath)
            RunWait, "%7zipPath%" x "%Path%" -aoa -o"%Dir%\%OutNameNoExt%" -bb1,, Hide
            ; for index, FilePath in FileList
            ;     FileDelete, %FilePath%
            Stdout("[=== """ Name """ ===]")
        }
    }
    tbi.setOverlayIcon(Idle)
    tbi.SetProgressType("Off")
}

IsLocked(Path)
{
    sleep, 500
    if (File := FileOpen(Path, "rw"))
        Return 0, File.Close() ;unlocked
    else
        Return 1 ;locked
}

NameWithoutVersion(Name)
{
    return Trim(RegExReplace(Name, "\d+\.?\s*")," ")
}

GetUninstallString(ProductNameWithoutVersion,PublisherFromInstall="")
{
	for a, RegistryType in StrSplit("32,64",",")
	{
		SetRegView, % RegistryType
		Loop, Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, R
		{
			RegRead, Publisher
			if !(InStr(Publisher,PublisherFromInstall) = 1) and (PublisherFromInstall != "")
				continue
            
			RegRead, DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%, DisplayName
            DisplayNameWithoutVersion := NameWithoutVersion(DisplayName)
            
            if InStr(DisplayNameWithoutVersion,ProductNameWithoutVersion)
            {
                RegRead, UninstallString, %A_LoopRegKey%\%A_LoopRegSubKey%, UninstallString
                InnoSetupAppPath := "Inno Setup: App Path"
                RegRead, InnoSetupAppPath, %A_LoopRegKey%\%A_LoopRegSubKey%, % InnoSetupAppPath
                if (InnoSetupAppPath != "")
                    UninstallString := UninstallString " /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
                else if (Instr(UninstallString,"msiexec" = 1))
                {
                    Loop, Parse, A_LoopRegSubKey,\
                        UninstallString:=A_LoopField
                    UninstallString := "msiexec /x " UninstallString " ALLUSERS=1 /qn /norestart"
                }
                else if !(InStr(UninstallString,"msiexec") = 1)
                    UninstallString := UninstallString " /S"

                Return UninstallString
            } 
		}
	}
}

RunAsAdmin()
{
	if A_IsAdmin
		Return
	full_command_line := DllCall("GetCommandLine", "str")
	Run *RunAs %full_command_line%, "%A_ScriptDir%"
    ExitApp
}

ExeInstallerIs(filePath){
    RunWait, %comspec% /c strings2.exe "%filePath%" > strings2.txt, % A_ScriptDir, Min
    Loop, Read, %A_ScriptDir%\strings2.txt
    {
        if ((InStr(A_LoopReadLine,"nsis")=1) or (InStr(A_LoopReadLine,"nullsoft")=1))
            Return "/S" ;NSIS
        else if ((InStr(A_LoopReadLine,"inno")=1) and !(InStr(A_LoopReadLine,"< window")=1))
            Return "/TYPE=FULL /VERYSILENT /SUPPRESSMSGBOXES /NORESTART" ;InnoSetup
        else if (InStr(A_LoopReadLine,"InstallAware")=1)
            Return "/s" ;InstallAware
        else if (InStr(A_LoopReadLine,"installshield")=1)
            Return "/s" ;InstallShield
        else if (InStr(A_LoopReadLine,"7-Zip 7zS.sfx.exe")=1)
            Return "-gm2" ;Gnu SelfExtracting 7z Archive
        else if (InStr(A_LoopReadLine,"RarSfx WinRAR")=1)
            Return "-s" ;WinRAR Self Extracting Archive
    }
}

MSIInfo(MSIFile, Type)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = '" . Type . "'")
	view.Execute
	record := view.Fetch
	Type := record.StringData(1)
	objRelease(installer)
	Return Type
}

ForCompile()
{
    FileInstall, strings2.exe, strings2.exe
    FileInstall, app.ico, app.ico
    FileInstall, download.ico, download.ico
    FileInstall, idle.ico, idle.ico
    FileInstall, install.ico, install.ico
    FileInstall, pause.ico, pause.ico
}

#If WinActive("ahk_pid " GetCurrentProcess())
F5::
Critical
Reload
Return

ESC::
Critical
ExitApp
Return

F1::
Run, https://github.com/zotune/auto-install
Return

SPACE::
spacePressCount++
if (Mod(spacePressCount, 2) != 0)
{
    tbi.setOverlayIcon(Pause)
    WatchFolder("**PAUSE", True)
    Stdout("[=== LISTENING PAUSED ===]")
}
else
{
    tbi.setOverlayIcon(Idle)
    WatchFolder("**PAUSE", False)
    Stdout("[=== LISTENING ===]")
}
return

F::
D::
    Run, explorer.exe "%Folder%"
return

S::
    Run, explorer.exe "%A_ScriptDir%"
return