$Searcher = New-Object DirectoryServices.DirectorySearcher
$Searcher.Filter = '(&(objectCategory=User)(sAMAccountName=MyUser))'
$Searcher.SearchRoot = 'LDAP://dc=ds,dc=example,dc=com'
$user = [adsi]$Searcher.FindAll()[0].Path 
$groups = @($user.memberOf | % { ([adsi]"LDAP://$_").Cn })
$admin = @(Get-xaadministrator | select AdministratorName | % { $_.AdministratorNAme.Split()[0] })
$mygroup = compare-object  $groups $admin -ExcludeDifferent -IncludeEqual -Passthru