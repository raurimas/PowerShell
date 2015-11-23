# WSUS Connection Parameters:
[String]$updateServer = "ad.domain.lan"
[Boolean]$useSecureConnection = $False
[Int32]$portNumber = 80
 
# Cleanup Parameters:
# Decline updates that have not been approved for 30 days or more, are not currently needed by any clients, and are superseded by an aproved update.
[Boolean]$supersededUpdates = $True
# Decline updates that aren't approved and have been expired my Microsoft.
[Boolean]$expiredUpdates = $True
# Delete updates that are expired and have not been approved for 30 days or more.
[Boolean]$obsoleteUpdates = $True
# Delete older update revisions that have not been approved for 30 days or more.
[Boolean]$compressUpdates = $True
# Delete computers that have not contacted the server in 30 days or more.
[Boolean]$obsoleteComputers = $True
# Delete update files that aren't needed by updates or downstream servers.
[Boolean]$unneededContentFiles = $True
 
# Load .NET assembly
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
 
# Connect to WSUS Server
$Wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$useSecureConnection,$portNumber)
 
# Perform Cleanup
$CleanupManager = $Wsus.GetCleanupManager()
$CleanupScope = New-Object Microsoft.UpdateServices.Administration.CleanupScope($supersededUpdates,$expiredUpdates,$obsoleteUpdates,$compressUpdates,$obsoleteComputers,$unneededContentFiles)
$CleanupManager.PerformCleanup($CleanupScope)