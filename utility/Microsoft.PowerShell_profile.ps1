Import-Module PSReadLine

Import-Module -Name Terminal-Icons

# Git Autocompletion
Import-Module posh-git

# Docker Autocomplete 
Import-Module DockerCompletion

# Podman Autocomplete
$(podman completion powershell | Out-String).Replace('podman.exe','podman').Replace('PODMAN.EXE','PODMAN') | Invoke-Expression

oh-my-posh init pwsh --config C:\tools\config\default.omp.json | Invoke-Expression
# oh-my-posh init pwsh --config C:\Users\NELLENFIELD\AppData\Local\Programs\oh-my-posh\themes\kushal.omp.json | Invoke-Expression

# ZLocation for ezpz directory navigation
Import-Module ZLocation
Write-Host -Foreground Green "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations.`n"

#Kubectl autocomplete
kubectl completion powershell | Out-String | Invoke-Expression

# PowerShell autocomplete for winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
         }
 }

 # Powershell parameter completion for Azure CLI
 Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $completion_file = New-TemporaryFile
    $env:ARGCOMPLETE_USE_TEMPFILES = 1
    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
    $env:COMP_LINE = $wordToComplete
    $env:COMP_POINT = $cursorPosition
    $env:_ARGCOMPLETE = 1
    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
    $env:_ARGCOMPLETE_IFS = "`n"
    $env:_ARGCOMPLETE_SHELL = 'powershell'
    az 2>&1 | Out-Null
    Get-Content $completion_file | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
}

# Powershell completion for OnePassword
op completion powershell | Out-String | Invoke-Expression

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# `ForwardChar` accepts the entire suggestion text when the cursor is at the end of the line.
# This custom binding makes `RightArrow` behave similarly - accepting the next word instead of the entire suggestion text.
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow `
                         -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
                         -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
    }
}

Set-PSReadLineKeyHandler -Key Ctrl+f -Function SwitchPredictionView
Set-Alias -Name cf -Value SwitchPredictionView

function Set-DockerConfig {
    param(
        [string]$targetOS
    )

    if ($targetOS -eq "Windows") {
        $dockerContext = "windows"
    } else {
        $dockerContext = "linux"
    }

    # Set the docker context
    docker context use $dockerContext

    $currentHost = Get-DockerHost
    Write-Host "Switched to Docker context: $dockerContext on $currentHost"
}

function Get-DockerHost {
    $currentHost = docker context inspect --format '{{.Endpoints.docker.Host}}'
    $currentHost
}

function Use-WindowsContainers { Set-DockerConfig -targetOS "Windows" }
function Use-LinuxContainers { Set-DockerConfig -targetOS "Linux" }

Set-Alias -Name wc -Value Use-WindowsContainers
Set-Alias -Name lc -Value Use-LinuxContainers

function Set-DockerHost {
    $currentHost = Get-DockerHost
    $env:DOCKER_HOST = $currentHost
}

function Reset-DockerHost {
    $env:DOCKER_HOST = $null
}
