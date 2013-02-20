import-module grouppolicy
import-module activedirectory

$return=@()
$notme = @(SkipkedOUList)
$ou = Get-ADOrganizationalUnit -Filter 'Name -like "MyOU"'
Get-ADOrganizationalUnit -Filter *  -SearchBase $ou -SearchScope OneLevel | select DistinguishedName,Name |% {
	$_.DistinguishedName
	$cou = $_.DistinguishedName
	if($notme -notcontains $_.Name ){
		Get-ADOrganizationalUnit -Filter 'Name -like "*Citrix"' -SearchBase $_.DistinguishedName -SearchScope OneLevel  |%{
			      $comps = Get-ADComputer -Filter "*" -SearchBase $_.DistinguishedName -SearchScope OneLevel
			      $fail = $false
			      foreach($computer in $comps){
				      #Get the list of valid user profile
				      $computer.Name
				      $computername = $computer.Name

				      $account = $false
					  $reg=$null
				      $uninstallkey = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList"
				      #Ouverture de la ruche sur le serveur distant
				      $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)
				      $regkey=$reg.OpenSubKey($uninstallkey)

				      #Récupération des noms des sous clés
				      $subkeys=$regkey.GetSubKeyNames()
				      foreach($key in $subkeys){
					      	$thisKey=$UninstallKey+"\\"+$key
							$user= $null
							$user = Get-ADUser -Identity $key
							if($user.Name -match "^\d+$"){
								$account = $user.name
								#Go out User searching
								break;
							}
						}
				     
				      if($account){
					      get-GPResultantSetOfPolicy -Computer $computername -User $account -ReportType Xml -Path c:\tmp\report.xml
					      if(test-path c:\tmp\report.xml){
						      [xml]$root = get-content c:\tmp\report.xml
						      if( $root.rsop.computerResults){
							      foreach($policy in $root.rsop.computerResults.ExtensionData[4].Extension.Policy){
								      if($policy.Name -match "loopback"){
									      $return+= @($cou,$policy.Name, $policy.DropDownList.Value.Name)
									      #We found loopback no need to go forward
									      break;
								      }
							      }
							      rm c:\tmp\report.xml
							      #We get a computer result we can exit
							      break
						      }
					      }
				      }
			  }
		}
	}else{
		echo "Skipped"
	}
}
$return