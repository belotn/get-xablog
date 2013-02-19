$username ="MyUser"
$password="MyPwd"
$dsnfilename="Path/to/my/newdsn"

Get-xaserver |% {
	$serverName = $_.servername
	
	$command = "cmd /c dsmaint config /user:$username /pwd:$password /dsn:$dsnfilename > c:\tmp\dsm_config.log"
	$process = [WMICLASS]"\\$serverName\ROOT\CIMV2:win32_process"
	$result = $process.Create($command)

	$depsvc = Get-Service -ComputerName $serverName  -name IMAService -dependentservices | Where-Object {$_.Status -eq "Running"} |Select -Property Name
	$depsvc | %{
		$svc = Get-Service -ComputerName $serverName  -name $_.Name 
		$svc.Stop()
		while($svc.status -ne "Stopped"){
			$svc.refresh()
			Start-Sleep -seconds 1
		}
	}

	$service = Get-Service -ComputerName $serverName -name IMAService
	$service.stop()
	while($service.status -ne "Stopped"){
	   $service.refresh()
	   Start-Sleep -seconds 1
	}
	$service.start()
	while($service.status -ne "Running"){
	   $service.refresh()
	   Start-Sleep -seconds 1
	}

	$depsvc | %{
		$svc = Get-Service -ComputerName $serverName  -name $_.Name 
		$svc.Start()
		while($svc.status -ne "Running"){
			$svc.refresh()
			Start-Sleep -seconds 1
		}
	}
}