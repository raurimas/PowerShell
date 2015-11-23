$rootfolder = Get-ChildItem -Path \\nasopp03\EPKIS -Recurse -Directory
foreach ($userfolder in $rootfolder) {
    Write-Host "Directory:" $userfolder.FullName
    Get-acl $userfolder.FullName | foreach {Write-Host "Owner: " $_.Owner "`nNTFS Security: " $_.AccessToString}
	Write-Host "`n"
}