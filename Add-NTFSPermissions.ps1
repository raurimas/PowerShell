#CSV document format
#Path|Group|NTFSPermissions|Inheritance
#C:\test|Domain Admins|FullControl|ContainerInherit,ObjectInherit
#C:\test\1\2\3|Domain Users|Read|None,None
#NTFS permissions: AppendData, ChangePermissions, CreateDirectories, CreateFiles, Delete, DeleteSubdirectoriesAndFiles, ExecuteFile, FullControl, ListDirectory, Modify, Read, ReadAndExecute, ReadAttributes, ReadData, ReadExtendedAttributes, ReadPermissions, Synchronize, TakeOwnership, Traverse, Write, WriteAttributes, WriteData, WriteExtendedAttributes

$Permissions = Import-Csv .\NTFSPermissions.csv -Delimiter '|'
$Domain = "AD.domain.local" #Active Directory domain name

function AddNTFSPermissions {
	Param ($Path, $Domain, $Group, $Permissions, $Inheritance)
	$Acl = Get-Acl $Path
	$ADGroup = $Domain + '\' + $Group
	$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ADGroup,$Permissions,$Inheritance,"None","Allow")
	$Acl.AddAccessRule($Rule)
	Set-Acl $Path $Acl
	}
	
ForEach ($Line in $Permissions) {
	if (Test-Path -Path $Line.Path) {
        AddNTFSPermissions $Line.Path $Domain $Line.Group $Line.NTFSPermissions $Line.Inheritance
		}
		else {
			New-Item -ItemType Directory -Force -Path $Line.Path | Out-Null
			AddNTFSPermissions $Line.Path $Domain $Line.Group $Line.NTFSPermissions $Line.Inheritance
			}
	}