#Singleinstance, force
#Persistent
#Include MSIinfo.ahk
#Include WatchFolder.ahk
#Include FileGetVersionInfo_AW.ahk
#Include Std.ahk

Folder:=ComObjCreate("Shell.Application").NameSpace("shell:downloads").self.path

Output("Auto-install (also unpack/uninstall) by Mikael Ellingsen (zotune@gmail.com)`nListening to changes in " Folder)

RunAsAdmin()
WatchFolder(Folder, "Detected", True, 0x01)

Detected(Directory, Changes) {
    ; static previousPath := ""
    For Each, Change In Changes {
        Action := Change.Action
        Path := Change.Name
        SplitPath, Path, Name, Dir, Extension, OutNameNoExt
        SplitPath, Dir, ParentName, ParentDir

        if (Action != 1) and (Action != 4)
            break
        if ((Extension = "exe" or Extension = "msi") and (InStr(Name,"32bit") or InStr(Name,"32-bit") or InStr(Name,"keygen") or (InStr(Name,"x86") and !InStr(Name,"64"))))
            break
        while IsLocked(Path)
            sleep, 500
        if (Extension = "exe"){
            Output("`n[=== """ Name """ ===]")
            Output("Scanning for silent install switches")
            ProductName := FileGetVersionInfo_AW(Path,"ProductName")
            if (InStr(ProductName,"NVIDIA Package")=1)
                SilentArguments := "-s"
            else
                SilentArguments := ExeInstallerIs(Path)
            if (SilentArguments = "")
            {
                Run, "%Path%" /?,, Min
                WinWait, ahk_exe %Name%
                WinGetText, Text, ahk_exe %Name%
                WinClose, ahk_exe %Name%
                Parameters := ["/INSTALL","/SILENT","/QUIET","/NORESTART","/SUPPRESSMSGBOXES"]
                for a, Parameter in Parameters
                {
                    if InStr(Text, Parameter)
                        SilentArguments .= " " Parameter
                }
            }
            if (SilentArguments != "")
            {
                NameWithoutVersion := NameWithoutVersion(ProductName)
                
                ; if (NameWithoutVersion != "")
                ;     UninstallString := GetUninstallString(NameWithoutVersion)
                ; if (UninstallString != "")
                ; {
                ;     Output("Uninstalling using " UninstallString)
                ;     RunWait, %UninstallString%,, Min ;S required for NSIS
                ;     Output("Uninstalled " NameWithoutVersion)
                ; }
                ; else
                ;     Output("Did not find other versions of " NameWithoutVersion)

                SilentArguments:=Trim(SilentArguments," ")
                Output("Installing using """ Name """ " SilentArguments)
                RunWait, "%Path%" %SilentArguments%,, Min
                Output("Installed " NameWithoutVersion)
            }
            else
                Output("Found no silent install switches")
            Output("[=== """ Name """ ===]")
        }
        else if (Extension = "msi"){
            if FileExist(Dir "\" OutNameNoExt ".exe")
                break
            Output("`n[=== """ Name """ ===]")
            NameWithoutVersion := NameWithoutVersion(ProductName(Path))
            UninstallString := GetUninstallString(NameWithoutVersion,Manufacturer(Path))
            if (UninstallString != "")
            {
                Output("Uninstalling using " UninstallString)
                RunWait, %UninstallString%,, Min
                Output("Uninstalled " NameWithoutVersion)
            } 
            else
                Output("Did not find other versions of " NameWithoutVersion)
            Output("Installing using msiexec /i """ Path """ ALLUSERS=1 /qn /norestart")
            RunWait, msiexec /i "%Path%" ALLUSERS=1 /qn /norestart,, Min
            Output("Installed " NameWithoutVersion)
            Output("[=== """ Name """ ===]")
        }
        else if (Extension = "rar") or (Extension = "zip") or (Extension = "7z") or (Extension = "iso")
        {
            Output("`n[=== """ Name """ ===]")
            7zipPath=%ProgramFiles%\7-Zip\7z.exe
            if !FileExist(7zipPath)
                Output("ERROR: 7-zip not installed at: """ 7zipPath """")
            Output("Unpacking " Name)
            ; FileList := []
            ; Loop, Files, % Dir "\*.*", F
            ;     if (A_LoopFileExt != "nfo") and (A_LoopFileExt != "sfv")
            ;         FileList.Push(A_LoopFileFullPath)
            ; msgbox % Name
            RunWait, "%7zipPath%" x "%Path%" -aoa -o"%Dir%\%OutNameNoExt%" -bb1,, Hide
            ; for index, FilePath in FileList
            ;     FileDelete, %FilePath%
            Output("[=== """ Name """ ===]")
        }
    }
}

IsLocked(Path)
{
    sleep, 500
    if (File := FileOpen(Path, "rw")) ;impedes Notepad/Paint saving sometimes
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
    RunWait, %comspec% /c strings2.exe "%filePath%" > output.txt, % A_ScriptDir, Min
    Loop, Read, %A_ScriptDir%\output.txt
    {
        if ((InStr(A_LoopReadLine,"nsis")=1) or (InStr(A_LoopReadLine,"nullsoft")=1))
            Return "/S"	;NSIS	- NSIS allows /SD (no message boxes at all)
        else if ((InStr(A_LoopReadLine,"inno")=1) and !(InStr(A_LoopReadLine,"< window")=1))
            Return "/TYPE=FULL /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"	;InnoSetup
        else if (InStr(A_LoopReadLine,"InstallAware")=1)
            Return "/s"
        else if (InStr(A_LoopReadLine,"installshield")=1)
            Return "/s"
        else if (InStr(A_LoopReadLine,"7-Zip 7zS.sfx.exe")=1)
            Return "-gm2"	;Gnu SelfExtracting 7z Archive
        else if (InStr(A_LoopReadLine,"RarSfx WinRAR")=1)
            Return "-s"	;WinRAR Self Extracting Archive
    }
}