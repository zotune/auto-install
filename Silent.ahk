CoordMode, ToolTip, Screen
installersDirectory = C:\Test

Loop %installersDirectory%\*.*
	If ( thisSwitch := UniversalSilentSwitchFinder(A_LoopFileFullPath) )
		ToolTip % installers .= thisSwitch "`n",0,50
MsgBox


UniversalSilentSwitchFinder(filePath,debugMode:=false){
	SplitPath, filePath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	If (OutExtension = "reg"){
		silentSwitchParam = regedit.exe /s "%filePath%"	;Registry Data File"
	}Else If (OutExtension = "inf"){
		silentSwitchParam = rundll32.exe setupapi,InstallHinfSection DefaultInstall 132 "%filePath%"	;Information or Setup File"
	}Else If (OutExtension = "msi"){
		silentSwitchParam = msiexec /i "%filePath%" ALLUSERS=1 /qn /norestart	;Windows installer (msiexec)"
	}Else If (OutExtension = "exe"){
		silentSwitchParam := (thisSwitch:=ExeInstallerIs(filePath)) ? filePath . thisSwitch : ""
	}
	Return silentSwitchParam
}

ExeInstallerIs(filePath){
	If RunCommand("strings /accepteula """ filePath """ |findstr /i ""nsis""|findstr /i ""nullsoft""")
		Return " /S"	;NSIS	- NSIS allows /SD (no message boxes at all)
	If RunCommand("strings /accepteula """ filePath """ |findstr /i ""inno""|findstr /v /i ""< window""")
		Return " /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"	;InnoSetup
	If RunCommand("strings /accepteula """ filePath """ |findstr /i ""7-Zip 7zS.sfx.exe""")
		Return " -gm2"	;Gnu SelfExtracting 7z Archive
	If RunCommand("strings /accepteula """ filePath """ |findstr /i ""RarSfx WinRAR""")
		Return " -s"	;WinRAR Self Extracting Archive
	;InstallShield
}

RunCommand(command) {
	DetectHiddenWindows, On
	Run, % ComSpec,, Hide, vPID
	WinWait, % "ahk_pid " vPID
	DllCall("kernel32\AttachConsole", UInt,vPID),oShell := ComObjCreate("WScript.Shell"),oExec := oShell.Exec(ComSpec " /c " command ),vStdOut := ""
	while !oExec.StdOut.AtEndOfStream
		vStdOut := oExec.StdOut.ReadAll()
	DllCall("kernel32\FreeConsole")
	Process, Close, % vPID
	Return vStdOut
}

