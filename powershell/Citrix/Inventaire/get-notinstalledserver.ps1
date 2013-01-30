$xaservers = New-Object System.Collections.ArrayList
get-xaserver | select ServerName | sort ServerName | %{ $xaservers.Add( $_.ServerName ) } 
 
$jobname = "MyPackage"
 
$IMSetting = new-object -com MetaframeCOM.MetaFrameIMConfig;
$IMSetting.jobs | % {
    if( $_.name -match $jobname){
        $_.Servers | % { 
            if( $_.jobStatus -eq 0 -or $_.jobStatus -eq 8 ){
                $server = new-object -com MetaFrameCOM.MetaFrameServer 
                $mfID = new-object -com MetaframeCom.MetaFrameID    
                $mfID.ID64 = $_.server;
                $server.initbyServerID($mfID)
                $xaservers.Remove($server.servername)
            }
        }
    }
}
 
$xaservers