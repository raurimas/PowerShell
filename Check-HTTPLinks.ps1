$URLListFile = ".\linkusarasas.txt"  
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue 
$Result = @() 

Foreach($URL in $URLList) {
	try {$request = Invoke-WebRequest -Uri $URL 2> $null}
	catch {$request = $_.Exception.Response}
	$Result += [PSCustomObject] @{
		URL = $URL;
		StatusCode = [int] $request.StatusCode;
		StatusDescription = $request.StatusDescription;
	}
}
$Result | Export-CSV ".\output.csv"