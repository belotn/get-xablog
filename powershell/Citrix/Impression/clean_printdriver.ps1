#Definition des paramètres
Param(
	[string]$FilePath,
	[string]$ServerName,
    [switch]$XACompatibilityList,
    [switch]$WhatIf,
	[switch]$h
)

if ((Get-PSSnapin -Name Citrix* -ErrorAction SilentlyContinue) -eq $null){
    Add-PSSnapin Citrix*
}

#Definition des Lignes de commandes

$sCmdList = "cscript c:\windows\system32\prndrvr.vbs -l -s SERVERNAME | find `"Nom du pilote`""
$sCmdSupp = "cscript c:\windows\system32\prndrvr.vbs -d -s SERVERNAME -m `"PILOTE`" "

#Creation du tableau avec la liste des pilotes autorisés (liste blance)

function Print-Help(){
	echo "clean_printerdriver.ps1 [-FilePath pathtodriverlist] [-ServerName SERVER] [-XACompatibilityList] [-WhatIf]
    will remove driver not in specified file, not installed on the specified server or not in farm compatibility list
clean_printerdriver.ps1 -h 
	display this message"
	Exit 0
}

if($h){
	Print-Help
}

#echo "`$FilePath $FilePath, `$ServerName $ServerName, `$WhatIf $WhatIf" 
#Test-Path variable:FilePath

#Chargement de la WhiteList de pilotes

If( (Test-Path variable:FilePath) -and ($FilePath.length -gt 0 )){
	$aPilotes = Get-Content $FilePath
}elseif( (Test-Path variable:ServerName) -and ($ServerName.length -gt 0)){
    #le retour de la commande prefixe les pilote par Nom du pilote et les postfixe avec ,version,envl
    echo "cmd /c " $sCmdList.REPLACE("SERVERNAME", $ServerName)
	$aPilotes = cmd /c $sCmdList.REPLACE("SERVERNAME", $ServerName)  | % { $_.substring("Nom du pilote ".length, $_.IndexOf(",") - "Nom du pilote ".length )}
}elseif($XACompatibilityList) {
    $aPilotes = Get-XAPrinterDriverCompatibility | % {$_.DriverName}
}else{
	Print-Help
}


$aServers = Get-XAServer	#Gets the XA servers in the farm
foreach( $oServer in $aServers){
    if($whatIf){ echo "Travail sur $oServer"}
	$aResultat = cmd /c $sCmdList.REPLACE("SERVERNAME", $oServer.ServerName)

    foreach( $sLine in $aResultat){
        $sBackup = $sLine
        #Les lignes Commencent par "Nom du pilote "
        $sLine = $sLine.substring("Nom du pilote ".length, $sLine.IndexOf(",") - "Nom du pilote ".length )
        if( $aPilotes -notcontains $sLine){
                If( $WhatIf ){
                    echo "Supression du pilote : $sLine"
                    echo $sCmdSupp.REPLACE("SERVERNAME", $oServer.ServerName).Replace("PILOTE", $sBackup)
                }else{
                   cmd /c $sCmdSupp.REPLACE("SERVERNAME", $ServerName).Replace("PILOTE", $sBackup)
                }
        }else{
            If($WhatIf){
                echo "Ne rien faire pour : $sLine"
            }
        }
    }
}