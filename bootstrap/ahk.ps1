$InstallerPath = $env:TEMP + "\ahk-v2.exe";
Invoke-WebRequest "https://www.autohotkey.com/download/ahk-v2.exe" -OutFile $InstallerPath; 
start $InstallerPath /silent
Remove-Item $InstallerPath;

