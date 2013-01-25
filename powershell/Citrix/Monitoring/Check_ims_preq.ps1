Param(
    [switch]$CreateRequiredValue
)
$defaultTemp ="C:\\Program Files\\Citrix\\Installer\\Temp"
$defaultLog = "C:\\Program Files\\Citrix\\Installer\\Logs"

$uninstallkey = "SOFTWARE\\Citrix\\IMS\\2.0"

Get-XAServer | % {
$reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$_.ServerName)
$regkey=$reg.OpenSubKey($uninstallkey)

$folder = $regkey.getValueNames() | where { $_ -match "Folder" }
	if( $folder -contains "LogFolder" -and $folder -contains "TempFolder"){
        Write-Host  -NoNewLine $_.ServerName
        Write-Host -ForegroundColor Green "[OK]"
	}elseif($folder -contains "LogFolder") {
        Write-Host  -NoNewLine $_.Servername
        if($CreateRequiredValue){
            $writekey = $reg.OpenSubKey($uninstallkey)
            $writekey.setValue('TempFolder',$defaultTemp,'String')
            Write-Host -ForegroundColor Yellow "[PASSED]"
            Write-Host "$UninstallKey\\TempFolder created"
        }else {
            Write-Host -ForegroundColor Red "[KO]"
            Write-Host "Besoin de creer $UninstallKey\\TempFolder"
        }
	}elseif ($folder -contains "TempFolder") {
        Write-Host  -NoNewLine $_.Servername
        if($CreateRequiredValue){
            $writekey = $reg.OpenSubKey($uninstallkey)
            $writekey.setValue('LogFolder',$defaultLog,'String')
            Write-Host -ForegroundColor Yellow "[PASSED]"
            Write-Host "$UninstallKey\\LogFolder created"
        }else {
            Write-Host -ForegroundColor Red "[KO]"
            Write-Host "Besoin de creer $UninstallKey\\LogFolder"
        }
	}else {
       Write-Host  -NoNewLine $_.Servername
        if($CreateRequiredValue){
            $writekey = $reg.OpenSubKey($uninstallkey)
            $writekey.setValue('TempFolder',$defaultTemp,'String')
            Write-Host -ForegroundColor Yellow "[PASSED]"
            Write-Host "$UninstallKey\\TempFolder created"
            $writekey.setValue('LogFolder',$defaultLog,'String')
            Write-Host "$UninstallKey\\LogFolder created"
        }else {
            Write-Host -ForegroundColor Red "[KO]"
            Write-Host "Besoin de creer $UninstallKey\\TempFolder"
            Write-Host "Besoin de creer $UninstallKey\\LogFolder"
        }
	}
}