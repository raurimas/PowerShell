param( 
    [string] $Filename = $(throw "File with computernames to query needs to be supplied.") 
    )
function SaveComputerSecurityLog($computer)
{
	$CsvFile="$computer.csv"
	Write-Host $CsvFile
	get-wmiobject -query "Select * from Win32_NTLogEvent Where Logfile = 'Security'" -computername $computer | Export-Csv -Path $csvfile -NoTypeInformation
}

$computers=Get-Content $Filename
foreach($computer in $computers)
{
	SaveComputerSecurityLog($computer)
}

