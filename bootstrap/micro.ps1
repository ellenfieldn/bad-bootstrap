# Downloads the latest release
# TODO: Filter out prerelease and draft
$repo = "zyedidia/micro"

$ToolName = "micro";
$DestinationPath = "C:\tools\portable\$($ToolName)";
$DownloadLocation = "$($DestinationPath)\$($ToolName).zip";

# Download latest dotnet/codeformatter release from github
$releases = "https://api.github.com/repos/$repo/releases"
Write-Host Determining latest release
$latest = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0]
$targetAsset = $latest.assets | where { $_.name -like 'micro-*-win64.zip' }
$downloadUrl = $targetAsset.browser_download_url

# Cleanup Old Version
if (Test-Path $DestinationPath) {
	rm $DestinationPath -Recurse
}

# install
mkdir $DestinationPath
Write-Host Downloading files to $DownloadLocation
Invoke-WebRequest $downloadUrl -UseBasicParsing -OutFile $DownloadLocation; 
Expand-Archive $DownloadLocation -DestinationPath $DestinationPath
rm $DownloadLocation;
$folder = Get-Item $DestinationPath | Get-ChildItem
mv "$($folder)\*" $DestinationPath
rm $folder

# Make a symlink so we can keep the license without making thing messy
if (-not (Test-Path "C:\tools\portable\$($ToolName).exe")) {
	New-Item -ItemType HardLink -Path "C:\tools\portable\$($ToolName).exe" -Target "C:\tools\portable\$($ToolName)\$($ToolName).exe"
}
