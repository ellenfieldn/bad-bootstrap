# Install DSC v3
#winget install --id  9NVTPZWRC6KQ --source msstore

# Install Required PowerShell modules
Install-Module PSReadLine -Force
Install-Module Terminal-Icons -Force
Install-Module posh-git -Force
Install-Module DockerCompletion -Force

# Install a NerdFont
oh-my-posh font install FiraCode
oh-my-posh font install Meslo
