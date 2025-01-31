function Get-TargetFrameworkVersion {
    param(
        [string]$filter = "*.csproj"
    )
    Get-ChildItem -Recurse -Filter $filter 
        | Select-String -Pattern "<TargetFrameworkVersion>(?<TargetFramework>.*)</TargetFrameworkVersion>"
        | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Filename
                FrameworkVersion = $_.Matches.Groups 
                    | Where-Object { $_.Name -eq 'TargetFramework' } 
                    | Select-Object -ExpandProperty Value
                Path = $_.Path | Resolve-Path -Relative
            }
    }
}
# As GroupInfo
# $groups = Get-TargetFrameworkVersion | Group-Object -Property FrameworkVersion
# ($groups | ? { $_.Name -eq "v4.5" }).Group

# As HashTable
# $groups = Get-TargetFrameworkVersion | Group-Object -Property FrameworkVersion -AsHashTable
# $groups."v4.5"

function Find-Solutions {
    param(
        [string]$filter = "*.sln"
    )
    Get-ChildItem -Recurse -Filter $filter 
        | Select-Object -ExpandProperty FullName 
        | Resolve-Path -Relative
}

filter ConvertTo-JobMatrix {
    "'$_',"
}

function Clean-Packages {
    param(
        [string]$sln,
        [switch]$all,
        [switch]$cleanLocals
    )
    $InformationPreference = "Continue"

    if($all)
    {
        Write-Information "Removing all packages"
        Get-ChildItem -Recurse -Filter "packages" | Remove-Item -Recurse
    }

    $slnFolder = $sln | Split-Path -Parent
    $packagesFolder = Join-Path $slnFolder "packages"
    if(Test-Path $packagesFolder)
    {
        Write-Information "Removing $packagesFolder"
        Remove-Item $packagesFolder -Recurse
    }

    if($cleanLocals)
    {
        Write-Information "Cleaning local packages"
        nuget locals all -clear
    }
}

function Restore-Packages-Csproj {
    param(
        [string]$file
    )
    $InformationPreference = "Continue"
    Write-Information "Restoring packages for $file"
    $projectFolder = $file | Split-Path -Parent
    $packageFolder = Join-Path $projectFolder "packages"
    nuget restore $file -PackagesDirectory $packageFolder
}
