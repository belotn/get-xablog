Param(
	[Parameter(Mandatory=$true)][string]$GPOSource,
	[Parameter(Mandatory=$true)][string]$GPOTarget
)
import-module ActiveDirectory
import-module GroupPolicy

# GPO Source de la configuration
$gpo = Get-GPO -Name $GPOSource
# GPO Cible
$target = Get-GPO -Name $GPOTarget

#La clé contenant la configuration
$Key = "HKEY_LOCAL_MACHINE\Software"

#Parcours du registre source et copie des valeurs dans la GPO cible.
function rCopyGPORegistryContent($Key){
	$error.PSBase.Clear()
	$path = Get-GPRegistryValue -GUID $gpo.ID -Key $Key
	If ($error.Count -eq 0) {
		ForEach ($keypath in $path) {
			If ( $keypath.HasValue) {
				$newPath = $keypath.FullKeyPath.Replace("HKEY_LOCAL_MACHINE","HKCU")
				Set-GPRegistryValue -Guid $target.Id -Key $newPath -ValueName $keypath.ValueName -Type $keypath.Type -Value $keypath.value
			}else{
			   rGCopyGPORegistryContent( $keypath.FullKeyPath )
			}
		}
	} Else {
		$error
	}
}

rCopyGPORegistryContent($Key)