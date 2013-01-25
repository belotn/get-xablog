$hash = @{}
$list_soft = @()

get-XAserver | % {
    echo "Working on : " $_.ServerName
    $computername= $_.ServerName

    $array = @()
    $UninstallKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)
    $regkey=$reg.OpenSubKey($UninstallKey)

    $subkeys=$regkey.GetSubKeyNames()
    foreach($key in $subkeys){

        $thisKey=$UninstallKey+"\\"+$key

        $thisSubKey=$reg.OpenSubKey($thisKey)

        if( $list_soft -notcontains $thisSubKey.GetValue("DisplayName") ){
            $list_soft += $thisSubKey.GetValue("DisplayName")
        }
        $val = $thisSubKey.GetValue("DisplayName")
        if( $val){
            $array += $val
        }
    }
    $hash.add($_.Servername,$array)
}

$strCVS =";"
$strCVS+= $list_soft -Join ';'
$finalTab = @($strCVS)

$hash.Keys | %{

    $a = @($_)

    $tmp = $hash.$_

    $list_soft | %{
        if( $tmp -contains $_ ){
            $a+="X"
        }else{
            $a+=" "
        }
    }
    $finalTab+= $a -join ";"
}
$str =  $finalTab -join "`n"
Set-content -Path ".\state_install.csv" $str