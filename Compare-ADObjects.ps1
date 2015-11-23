Import-Module ActiveDirectory
$group1 = Get-ADGroupMember -identity "G_Vilnius"
$group2 = Get-ADGroupMember -identity "G_Vertinimas"

$group1.SamAccountName | where {$group2.SAMAccountName -contains $psitem}