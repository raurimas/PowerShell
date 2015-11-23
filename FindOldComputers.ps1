Import-module ActiveDirectory  
$domain = "AD.domain.local"  
$DaysInactive = 90  
$time = (Get-Date).Adddays(-($DaysInactive)) 
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv OLD_Computers.csv -notypeinformation