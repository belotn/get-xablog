add-pssnapin Citrix*
import-module PSTerminalServices
$sw = [Diagnostics.Stopwatch]::StartNew();
Get-XAServer | % {
    $server =  $_.ServerName
    try {
        $data1 = @();
	get-xasession -servername $_.serverName | where { $_.SessionName -match "^ICA-" -and $_.state -ne 'Listening' -and $_.State -ne 'Down' -and $_.SessionID -gt 0 -and $_.AccountName.length -gt 0 } |  select SessionId |%{ $data1+= $_.SessionID };
	$data1 = $data1 | sort | unique

        $data2 = @();
	Get-TSSEssion -ComputerName $_.ServerName | where { $_.WindowStationName -match "^ICA-" -and $_.State -ne 'Listening' -and $_.State -ne 'Down' -and $_.SessionID -gt 0 -and $_.UserName.length -gt 0 } | select SessionId |%{ $data2+= $_.SessionID };
	$data = $data2 | sort | unique

    }catch{
        write-host "Error : $server Inaccessible"
    }
    if( $data1 -and $data2 ) {
        $resultat = Compare-Object $data1 $data2 -Passthru
        if($resultat.length -gt 0 ){
	  Write-Host $_.ServerName $resultat.length
        }
    }
} 