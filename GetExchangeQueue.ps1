foreach ($i in Get-ExchangeServer)
{
    if ($i.ishubtransportserver -eq "True")
    {
	$messages = 0
        foreach ($queue in Get-Queue -Server $i.Name)
        {
            $messages = $messages + $queue.Messagecount
        }
	Write-host "Server: " $i.Name	"Messages in queues: "$messages
    }
}
