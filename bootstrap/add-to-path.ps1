function Add-PathDirectory {
	param (
		[string]$targetDir
	)
	$pathDirs = [Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
	if($targetDir -notin $pathDirs)
	{
		[Environment]::SetEnvironmentVariable('PATH', ($pathDirs + $targetDir) -join ';', 'User')
	}
	
	$pathDirs = [Environment]::GetEnvironmentVariable('PATH', 'Process') -split ';'
	if($targetDir -notin $pathDirs)
	{
		[Environment]::SetEnvironmentVariable('PATH', ($pathDirs + $targetDir) -join ';', 'Process')
	}
}

Add-PathDirectory "C:\tools\portable"