using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

$script:currentMs = 0
$script:steps = @{}

function LogStep(
        [string]$action,
        [switch]$verbose
    ) {
    $stepMs = $stopwatch.Elapsed.TotalMilliseconds - $script:currentMs
    $script:steps["$action"] = $stepMs
    if($verbose) {
        Write-Host "$($action): $($stepMs)ms"
    }
    $script:currentMs = $stopwatch.Elapsed.TotalMilliseconds
}

function Output-Steps() {
    $totalMs = $stopwatch.Elapsed.TotalMilliseconds
    $script:steps.GetEnumerator() | Sort-Object -Property Value -Descending | 
        Format-Table @{
                'Label'='Action'; 
                'Expression'={$_.Key}
            },
            @{
                'Label'='Time (ms)'; 
                'Expression'={$_.Value}
            },
            @{
                'Label'='Percentage'; 
                'Expression'={[math]::Round(($_.Value / $totalMs) * 100, 2)}
            }
        }

Write-Host "Loading Profile"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Import-Module PSReadLine
LogStep "Import-Module PSReadLine"

Import-Module -Name Terminal-Icons
LogStep "Import-Module Terminal-Icons"

# Git Autocompletion
Import-Module posh-git
LogStep "Import-Module posh-git"

# Docker Autocomplete 
Import-Module DockerCompletion
LogStep "Import-Module DockerCompletion"

Write-Host "Modules Imported"

# Podman Autocomplete
C:\Users\NELLENFIELD\.pwsh\completions\podman.ps1
LogStep "podman completion"

oh-my-posh init pwsh --config C:\tools\config\default.omp.json | Invoke-Expression
LogStep "oh-my-posh init"

# ZOxide for ezpz directory navigation
Invoke-Expression (& { (zoxide init powershell | Out-String) })
LogStep "zoxide init"

# Autocomplete for Zoxide
Register-ArgumentCompleter -Native -CommandName z -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        $commandElements = $commandAst.CommandElements | Select-Object -Expand Value -Skip 1
        zoxide query --list $commandElements | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
LogStep "zoxide completion"

# ZLocation for ezpz directory navigation
#Import-Module ZLocation
#LogStep "Import-Module ZLocation"
#Write-Host -Foreground Green "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations.`n"

#Kubectl autocomplete
C:\Users\NELLENFIELD\.pwsh\completions\kubectl.ps1
LogStep "kubectl completion"

C:\Users\NELLENFIELD\.pwsh\completions\kustomize.ps1
LogStep "kustomize completion"

# Taskfile.dev completions
Invoke-Expression  (&task --completion powershell | Out-String)
LogStep "taskfile.dev completions"

# Powershell completion for OnePassword
C:\Users\NELLENFIELD\.pwsh\completions\op.ps1
LogStep "op completion"

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
LogStep "winget completion"

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
         }
}
LogStep "dotnet completion"

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
LogStep "az completion"

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

Set-PSReadLineOption -MaximumHistoryCount 5000 -HistoryNoDuplicates

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


Set-Alias msbuild "C:\Program Files\Microsoft Visual Studio\2022\Preview\MSBuild\Current\bin\msbuild.exe"



class RepoCompleter : IArgumentCompleter {

    [string] $RepoBasePath

    RepoCompleter([string] $repoBasePath) {
        $this.RepoBasePath = $repoBasePath
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters) {

        $resultList = [List[CompletionResult]]::new()
        $repos = Get-ChildItem -Directory -Path $this.RepoBasePath | Select-Object -ExpandProperty Name | Where-Object {
            $_ -like "*$wordToComplete*"
        }

        foreach ($i in $repos) {
            $resultList.Add([CompletionResult]::new($i.ToString()))
        }

        return $resultList
    }
}

class RepoCompletionsAttribute : ArgumentCompleterAttribute, IArgumentCompleterFactory {
    [string] $RepoBasePath

    RepoCompletionsAttribute() {
        $this.RepoBasePath = "$env:USERPROFILE/source/repos"
    }

    [IArgumentCompleter] Create() { return [RepoCompleter]::new($this.RepoBasePath) }
}

function cdr {
    param(
        [RepoCompletionsAttribute()]
        [string]$repoName
    )
    Write-Host "Repo: $repoName"

    $repoPath = Get-RepoPath $repoName
    if (Test-Path $repoPath) {
        Set-Location $repoPath
    } else {
        Write-Host "Repo not found: $repoName"
    }
}

function coder {
    param(
        [RepoCompletionsAttribute()]
        [string]$repoName
    )
    Write-Host "Repo: $repoName"

    $repoPath = Get-RepoPath $repoName
    if (Test-Path $repoPath) {
        code $repoPath
    } else {
        Write-Host "Repo not found: $repoName"
    }
}

function Get-RepoPath {
    param(
        [string]$repoName
    )
    # $repoPath = "~\source\repos\$repoName" does not work with vs code for some reason.
    "$env:USERPROFILE/source/repos/$repoName"
}

function listr {
    $repoPath = Get-RepoPath
    Get-ChildItem -Directory -Path $repoPath | Select-Object -ExpandProperty Name
}

function Out-Completion {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern("^\w+$")] 
        [string[]]$command,

        [Parameter(Mandatory = $false)]
        [string[]]$commandArgs = @("completion", "powershell"),

        [Parameter(Mandatory = $false)]
        [string]$completionDir = "$HOME\.pwsh\completions"
    )
    Begin {
        $InformationPreference = "Continue"
        $ErrorActionPreference = 'Stop'
        Write-Information `n"Saving shell completions to $completionDir"
    }
    Process {
        foreach ($c in $command) {
            $completionLocation = join-path $completionDir "$c.ps1"

            Write-Information "> $c $commandArgs"
            & $command @commandArgs > $completionLocation
        }
    }
    End {
        Write-Host "`nDone!"
    }
}

function Get-Completions {
    param(
        [string]$command,
        [string]$completionDir = "$HOME\.pwsh\completions"
    )
    Get-Content -Path (Join-Path $completionDir "$command.ps1") -Raw
}

function Set-Completions {
    param(
        [string]$command,
        [string]$completionContent,
        [string]$completionDir = "$HOME\.pwsh\completions"
    )
    $completionContent | Out-File -FilePath (Join-Path $completionDir "$command.ps1")
}

function Install-Completions {
    $commands = @("kubectl", "kustomize", "op", "podman")
    $commands | Out-Completion

    #podman is special... We have to fix it up a little bit
    Write-Host "`nFixing up podman completions..."
    $podmanCompletions = (Get-Completions "podman").Replace('podman.exe','podman').Replace('PODMAN.EXE','PODMAN') 
    Set-Completions -command "podman" -completionContent $podmanCompletions
    Write-Host "`nDone!"
}

Set-Alias -Name oc -Value Out-Completion


function Find-VisualStudio() {
    Write-Information "Finding VisualStudio .exe path"
    $vsWherePath = join-path ${env:ProgramFiles(x86)} "\Microsoft Visual Studio\Installer\vswhere.exe"
    Write-Debug "Checking for vswhere.exe at $vsWherePath"
    if (-not (Test-Path $vsWherePath)) {
        Write-Error "vswhere.exe not found at $vsWherePath"
        exit 1
    }

    Write-Debug "Finding VisualStudio Installation Location using:"

    $vsWhereArgs = @("-products", "*", "-property", "productPath", "-latest")
    Write-Debug "  -> $vsWherePath $vsWhereArgs"
    $vsPath = & $vsWherePath @vsWhereArgs
    if (-not $vsPath) {
        Write-Error "Failed to find Visual Studio Installation"
        exit 1
    }

    Write-Information "Found VisualStudio (devenv.exe) at $vsPath"

    return $vsPath
}

function Open-VisualStudio {
    $vsPath = Find-VisualStudio
    & $vsPath @args
}

Set-Alias -Name vs -Value Open-VisualStudio

fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression

LogStep "The Rest"
$stopwatch.Stop()

Output-Steps

function Set-Location-RepoRoot {
    $repoPath = git rev-parse --show-toplevel
    Set-Location $repoPath
}

Set-Alias -Name rr -Value Set-Location-RepoRoot

