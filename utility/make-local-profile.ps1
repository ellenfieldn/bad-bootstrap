#Params: Force
param(
    [switch] $Force
  )

function Get-NewRemoteProfileContents {
    param(
        [string] $targetProfile
    )
    $profileContents = @"
if (Test-Path -Path $targetProfile) {
    . $targetProfile
}
"@
    return $profileContents
}

$currentPwshFolder = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))\Powershell"
$localPwshFolder = "$($env:UserProfile)\Documents\Powershell"

if ($currentPwshFolder -eq $localPwshFolder) {
    Write-Host "Powrshell profile is already local. Exiting..."
    exit
}

Write-Host ""
Write-Host "Powershell is not being loaded from a local folder."
Write-Host "  - Current Powershell folder: $currentPwshFolder"
Write-Host "  - Local Powershell folder: $localPwshFolder"

if (-not (Test-Path -Path $localPwshFolder)) {
    Write-Host "`n"
    Write-Host "Local folder does not exist. Creating local Powershell folder at $localPwshFolder"
    mkdir $localPwshFolder
}

$currentProfile = $PROFILE
$targetProfile = "$localPwshFolder\Microsoft.PowerShell_profile.ps1"
Write-Host ""
Write-Host "Current Powershell Profile: $currentProfile"
Write-Host "Desired Powershell Profile: $targetProfile"
Write-Host ""

if ($currentProfile -eq $targetProfile) {
    Write-Host "Powershell profile is already local. Exiting..."
    exit
}

$correctContents = Get-NewRemoteProfileContents -targetProfile $targetProfile
Write-Host ""
Write-Host "Desired Powershell Profile Contents:"
Write-Output $correctContents
Write-Host ""

$currentProfileContents = Get-Content -Path testfile.ps1 -Raw
Write-Host ""
Write-Host "Current Powershell Profile Contents:"
Write-Output $currentProfileContents
Write-Host ""

if ($currentProfileContents -eq $correctContents) {
    Write-Host "Remote powershell profile is already loading the local profile  . Exiting..."
    exit
}

if (Test-Path -Path $targetProfile) {
    if ($Force) {
        Write-Warning "Profile already exists at path: $targetProfile. Forcing overwrite..."
        Remove-Item -Path $targetProfile
    } else {
        Write-Warning "Profile already exists at path: $targetProfile. To force overwrite, use -Force parameter. Exiting..."
        exit
    }
}

Write-Host ""
Write-Host "Copying current profile to local folder..."
Copy-Item -Path $currentProfile -Destination $targetProfile

Write-Host ""
Write-Host "Updating the remote profile to load the local profile..."
Set-Content -Path $currentProfile -Value $correctContents -NoNewLine

Write-Host ""
Write-Host "Complete! Restart Powershell to load the local profile."



# TODO: Stick this in remote profile
