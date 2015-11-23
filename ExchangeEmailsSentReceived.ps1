Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$From = (Get-Date).AddDays(-7)  
$To = $From.AddDays(1)  
[Int64] $intSent = $intRec = 0 
[Int64] $intSentSize = $intRecSize = 0 
[String] $strEmails = $null  
  
Write-Host "Day Of Week, Date, Sent, Sent Size (MB), Received, Received Size (MB)" -ForegroundColor Yellow  
  
Do  
{  
    $strEmails = "$($From.DayOfWeek),$($From.ToShortDateString()),"  
  
    $intSent = $intRec = 0  	
	 Get-TransportService | Where-Object {$_.Name -like "EX13MBP*"} | Get-MessageTrackingLog -Start $From -End $To -resultsize unlimited | ForEach {  

        If ($_.EventId -eq "RECEIVE" -and $_.Source -eq "STOREDRIVER") 
        { 
            $intSent++ 
            $intSentSize += $_.TotalBytes 
        } 

        If ($_.EventId -eq "DELIVER") 
        { 
            $intRec++ 
            $intRecSize += $_.TotalBytes 
        } 
    }  
  
    $intSentSize = [Math]::Round($intSentSize/1MB, 0) 
    $intRecSize = [Math]::Round($intRecSize/1MB, 0) 
    $strEmails += "$intSent,$intSentSize,$intRec,$intRecSize"  
    $strEmails  
    $From = $From.AddDays(1)  
    $To = $From.AddDays(1)  
}  
While ($To -lt (Get-Date)) 