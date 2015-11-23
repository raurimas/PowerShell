Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$PFData_old = Get-Content "C:\ExchMailFlow\MailFlow.txt"
$PFData_new= Get-PublicFolder -Identity "\VPO REAL" -Recurse | Get-PublicFolderStatistics
$Delta = $PFData_new.ItemCount - $PFData_old
$PFData_new.ItemCount | Out-File -FilePath "C:\ExchMailFlow\MailFlow.txt"
# Zabbix does not want any \r\n
Write-Host $Delta -nonewline