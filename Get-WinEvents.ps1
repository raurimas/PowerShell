$EventStart = ((Get-Date).addDays(-1))
$EventEnd = Get-Date

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$excludedIDs = Get-Content "C:\WinEvents\ExcludedEventIDs.txt"

$logs = Get-WinEvent -Logname ForwardedEvents -ErrorAction SilentlyContinue | Where-Object {($_.TimeCreated -ge $EventStart) -and ($excludedIDs -notcontains $_.ID)}
$logs += Get-WinEvent -ComputerName ex13casp01 -FilterHashTable @{LogName="Microsoft-Exchange-ManagedAvailability/Monitoring"; StartTime=(get-date).AddDays(-1); EndTime=(get-date)} -ErrorAction SilentlyContinue | Where-Object {($_.Message -NotLike "*is below critical threshold on space for last*") -and ($_.Message -NotLike "*is low on log volume space*") -and ($_.LevelDisplayName -ne "Information") -and ($excludedIDs -notcontains $_.ID)}
$logs += Get-WinEvent -ComputerName ex13casp02 -FilterHashTable @{LogName="Microsoft-Exchange-ManagedAvailability/Monitoring"; StartTime=(get-date).AddDays(-1); EndTime=(get-date)} -ErrorAction SilentlyContinue | Where-Object {($_.Message -NotLike "*is below critical threshold on space for last*") -and ($_.Message -NotLike "*is low on log volume space*") -and ($_.LevelDisplayName -ne "Information") -and ($excludedIDs -notcontains $_.ID)}
$logs += Get-WinEvent -ComputerName ex13mbp03 -FilterHashTable @{LogName="Microsoft-Exchange-ManagedAvailability/Monitoring"; StartTime=(get-date).AddDays(-1); EndTime=(get-date)} -ErrorAction SilentlyContinue | Where-Object {($_.Message -NotLike "*is below critical threshold on space for last*") -and ($_.Message -NotLike "*is low on log volume space*") -and ($_.LevelDisplayName -ne "Information") -and ($excludedIDs -notcontains $_.ID)}
$logs += Get-WinEvent -ComputerName ex13mbp04 -FilterHashTable @{LogName="Microsoft-Exchange-ManagedAvailability/Monitoring"; StartTime=(get-date).AddDays(-1); EndTime=(get-date)} -ErrorAction SilentlyContinue | Where-Object {($_.Message -NotLike "*is below critical threshold on space for last*") -and ($_.Message -NotLike "*is low on log volume space*") -and ($_.LevelDisplayName -ne "Information") -and ($excludedIDs -notcontains $_.ID)}

foreach ($log in $logs)
{
	$logXML = [xml]$log.ToXml()
	if ($log.Message -eq $null) {$log.Message = $logXML.Event.RenderingInfo.Message}
	if ($log.Level -eq 1) {Add-Member -InputObject $log -MemberType NoteProperty -Name LevelName -Value "Critical"}
	elseif ($log.Level -eq 2) {Add-Member -InputObject $log -MemberType NoteProperty -Name LevelName -Value "Error"}
	elseif ($log.Level -eq 3) {Add-Member -InputObject $log -MemberType NoteProperty -Name LevelName -Value "Warning"}
	elseif ($log.Level -eq 4 -or $log.Level -eq 0) {Add-Member -InputObject $log -MemberType NoteProperty -Name LevelName -Value "Information"}
}

$logs | Select-Object ID, ProviderName, Message, LogName, LevelName, MachineName | Group-Object -Property Message, LogName, LevelName, MachineName, ID, ProviderName | %{[PSCustomObject]@{
Hostname = $_.group[0].MachineName
"Log Name" = $_.group[0].LogName
"Event ID" = $_.group[0].ID
Count = $_.count
Level = $_.group[0].LevelName
Provider = $_.group[0].ProviderName
Message = $_.group[0].Message}} | ConvertTo-Html -Head $style | Set-Content "C:\WinEvents\EventLogs.html"

Send-MailMessage -SmtpServer smtp.server.addr -To recipient@domain.net -From eventlogs@domain.net -Subject "Windows Event Logs" -Body "Windows Event Logs for $EventStart - $EventEnd" -BodyAsHtml -Attachment "C:\WinEvents\EventLogs.html"