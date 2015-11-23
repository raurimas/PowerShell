$domain = "ad.domain.local" 
 
import-module activedirectory 
"The domain is " + $domain 
$samaccountname = Read-Host 'What is the User samaccountname?' 
$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest() 
$domaincontrollers = $myforest.Sites | % { $_.Servers } | Select Name 
$RealUserLastLogon = $null 
$LastusedDC = $null 
$domainsuffix = "*."+$domain 
foreach ($DomainController in $DomainControllers)  
{ 
    if ($DomainController.Name -like $domainsuffix ) 
    { 
        $UserLastlogon = Get-ADUser -Identity $samaccountname -Properties LastLogon -Server $DomainController.Name 
        if ($RealUserLastLogon -le [DateTime]::FromFileTime($UserLastlogon.LastLogon)) 
        { 
            $RealUserLastLogon = [DateTime]::FromFileTime($UserLastlogon.LastLogon) 
            $LastusedDC =  $DomainController.Name 
        } 
    } 
} 
"The last logon occured the " + $RealUserLastLogon + "" 
"It was done against " + $LastusedDC + "" 
$mesage = "............." 
$exit = Read-Host $mesage