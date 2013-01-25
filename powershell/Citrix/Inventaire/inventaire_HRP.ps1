$hServer = @()
get-xaServer | % {
  $tmp = get-xaserverHotfix -ServerNAme $_.serverNAme
  if( $tmp.length -gt 0 ){
    $hrps = ($tmp | sort InstalledOn -descending)
    if( $hrps.Count -gt 0 ){
      $hrp = $hrps[0].HotfixName
    }else{
      $hrp = $hrps.HotfixName
    }
    $hServer+= @{"ServerName" = $_.serverName ;"HotFix" = $hrp }
  }else{
    $hServer += @{"ServerName" = $_.serverName;"HotFix" = "Unable to        retreive HotFix" }
  }
}
#Sorti Standard Format CSV
$hServer |% { @($_.ServerName, $_.Hotfix) -join ";"}