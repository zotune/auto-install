ProductName(MSIFile)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'ProductName'")
	view.Execute
	record := view.Fetch
	ProductName := record.StringData(1)
	objRelease(installer)
	Return ProductName
}

ProductCode(MSIFile)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'ProductCode'")
	view.Execute
	record := view.Fetch
	ProductCode := record.StringData(1)
	objRelease(installer)
	Return ProductCode
}

UpgradeCode(MSIFile)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'UpgradeCode'")
	view.Execute
	record := view.Fetch
	UpgradeCode := record.StringData(1)
	objRelease(installer)
	Return UpgradeCode
}
	
ProductVersion(MSIFile)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'ProductVersion'")
	view.Execute
	record := view.Fetch
	ProductVersion := record.StringData(1)
	objRelease(installer)
	Return ProductVersion
}
	
Manufacturer(MSIFile)
{
	msiOpenDatabaseModeReadOnly := 0
	installer := ComObjCreate("WindowsInstaller.Installer")
	openMode := msiOpenDatabaseModeReadOnly		
	database := installer.OpenDatabase(MSIFile, openMode)
	view := database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'Manufacturer'")
	view.Execute
	record := view.Fetch
	Manufacturer := record.StringData(1)
	objRelease(installer)	
	Return Manufacturer
}