Import-Module ActiveDirectory
$OUs = Get-ADOrganizationalUnit -Filter {Name -like '*'} | Select-Object Name, DistinguishedName
foreach ($OU in $OUs) {
$OUName = $OU.Name
Get-ADUser -Filter * -SearchBase $OU.DistinguishedName -Properties mail | Select Name, SamAccountName, Mail | Export-Csv "C:\$OUName.csv"
}
