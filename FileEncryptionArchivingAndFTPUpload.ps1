set-alias sevenzip "$env:ProgramFiles\7-Zip\7z.exe"
set-alias axcrypt "$env:ProgramFiles\Axantum\AxCrypt\AxCrypt.exe"

#Visos direktorijos isskyrus 1_Ongoing Projects
Get-ChildItem -Path D:\ARENSIA | Where-Object {$_.PSIsContainer -and $_.Name -ne "1_Ongoing Projects"} | ForEach-Object {
	$source = $_.FullName + "\*"
	$destination = "D:\Archive\" + $_.Name + ".zip"
	sevenzip a -tzip "$destination" $source > $null
	Remove-Item D:\Archive\"$_"-zip.axx -ErrorAction SilentlyContinue
	axcrypt -b 2 -e -k "encryption_key_here" -z "$destination"
}

#1_Ongoing Projects direktorijos
Get-ChildItem -Path 'D:\ARENSIA\1_Ongoing Projects' | Where-Object {$_.PSIsContainer} | ForEach-Object {
	$source = $_.FullName + "\*"
	$destination = "D:\Archive\" + $_.Name + ".zip"
	sevenzip a -tzip "$destination" $source > $null
	Remove-Item D:\Archive\"$_"-zip.axx -ErrorAction SilentlyContinue
	axcrypt -b 2 -e -k "encryption_key_here" -z "$destination"
}

#Palaukti, kol AxCrypt pabaigs darbus ir atrakins failus
Start-Sleep -Seconds 300

Get-ChildItem "D:\Archive\" -Filter *.axx | where {$_.Name -ne "test-7z.axx"} | Foreach-Object {
	$file = "D:\Archive\"+$_.Name
	$ftp = "ftp://username:password@127.0.0.1:2021/"+$_.Name
	$webclient = New-Object System.Net.WebClient
	$uri = New-Object System.Uri($ftp)
	$ErrorActionPreference = "SilentlyContinue"
	do { $webclient.UploadFile($uri, $file) }
	until ($? -eq $true)
}