$dgs = Get-DistributionGroup -resultsize Unlimited
$dgm = @()
foreach($dg in $dgs)
{
$dgm += Get-DistributionGroup $dg | Select-Object DisplayName,PrimarySmtpAddress,@{Name=“EmailAddresses”;Expression={$_.EmailAddresses | Where-Object {$_.PrefixString -ceq “smtp”} | ForEach-Object {$_.SmtpAddress}}}
}
$dgm | Export-CSV -Path C:\filename.csv -NoTypeInformation -Encoding “Unicode”