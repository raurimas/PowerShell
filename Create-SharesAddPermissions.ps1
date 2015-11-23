#CSV document format
#Path|Sharename|Group|SharePermissions|Description
#C:\test|test|Domain Admins|Full|test description
#Share permissions: Full, Read, Change
$Permissions = Import-Csv .\SharePermissions.csv -Delimiter '|'
$Domain = "AD.domain.local" #Active Directory domain name

ForEach ($Line in $Permissions) {
	$Path = $Line.Path
	$Sharename = $Line.Sharename
	$Group = $Line.Group
	$SharePermissions = $Line.SharePermissions
	$Description = $Line.Description
	$MaximumAllowed = [System.UInt32]::MaxValue
	
	if ($SharePermissions -eq 'Full') {$AccessMask = '2032127'}
		elseif ($SharePermissions -eq 'Change') {$AccessMask = '1245631'}
			else {$AccessMask = '1179817'}
	
	$Share = $SecSettings = $SecDACLs = $null
	
	#Grabbing Share Information
	$Share = Get-WmiObject -Class "Win32_Share" -ErrorAction SilentlyContinue | where {$_.Name -like $Sharename} 
 
	#Testing whether share exists  
	if ($Share -ne $null) {
		$ace = $trustee = $null
		$aces = @()	
		if ($Description -eq $null) {$Description = ""}
		
		#Pulling and storing file share security information based on the desired file share
		$SecSettings = Get-WmiObject win32_logicalsharesecuritysetting | where {$_.Name -like $Sharename} 
		$SecDescriptor = $SecSettings.GetSecurityDescriptor()
		$SecDACLs = ($SecDescriptor.Descriptor).DACL
		
		#Verifying the user or group is not already granted rights to the file share
		if ($SecDACLs.Trustee.Name -notcontains $Group) {
		
			#Adding desired credentials as a trustee
			$trustee = ([wmiclass]'Win32_trustee').psbase.CreateInstance()
			$trustee.Domain = $Domain
			$trustee.Name = $Group
			
			#Adding desired credentials and setting access level to ACE
			$ace = ([wmiclass]'Win32_ACE').psbase.CreateInstance()
			$ace.AccessMask = $AccessMask
			$ace.AceFlags = 3
			$ace.AceType = 0
			$ace.Trustee = $trustee
			$aces += $ace
			
			#Pulling existing DACLs on the file share
			foreach ($dacl in $SecDACLs) {
				$ace = $trustee = $null
				$trustee = ([wmiclass]'Win32_trustee').psbase.CreateInstance()
				$trustee.Domain = $dacl.Trustee.Domain
				$trustee.Name = $dacl.Trustee.Name
				$ace = ([wmiclass]'Win32_ACE').psbase.CreateInstance()
				$ace.AccessMask = $dacl.AccessMask
				$ace.AceFlags = 3
				$ace.AceType = 0
				$ace.Trustee = $trustee
				$aces += $ace
			}
			
			#Creating and setting the Security Descriptor including the new DACL
			$sd = ([wmiclass]'Win32_SecurityDescriptor').psbase.CreateInstance()
			$sd.ControlFlags = 4
			$sd.DACL = $aces
			
			#Setting the Security Descriptor on the file share
			$Share.SetShareInfo($MaximumAllowed, $Description, $sd) | Out-Null
			Write-Host $SharePermissions 'permissions have been assigned on' $Sharename 'for' $Group -ForegroundColor Green
		} else {Write-Host $Group 'already has' $SharePermissions 'permissions on' $Sharename -ForegroundColor Red
			}			
	} else { 
		#Directory creation
		New-Item -ItemType Directory -Force -Path $Path | Out-Null
		
		#Create a shared folder and set share permissions
		net share $Sharename=$Path /grant:"$Domain"\"$Group,$SharePermissions" /unlimited /remark:$Description /cache:None >$null
		Write-Host "Shared directory" $Sharename "successfully created. Shared for" $Group "with" $SharePermissions "permissions"		
		}
}