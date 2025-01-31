function Find-MsBuild() {
    Write-Information "::group::Finding MSBuild path"
    $vsWherePath = join-path ${env:ProgramFiles(x86)} "\Microsoft Visual Studio\Installer\vswhere.exe"
    Write-Information "Checking for vswhere.exe at $vsWherePath"
    if (-not (Test-Path $vsWherePath)) {
        Write-Error "vswhere.exe not found at $vsWherePath"
        exit 1
    }

    Write-Information "Finding VisualStudio Installation Location using:"
    Write-Information "  -> $vsWherePath -products * -requires Microsoft.Component.MSBuild -property installationPath -latest"
    $vsPath = &  $vsWherePath -products * -requires Microsoft.Component.MSBuild -property installationPath -latest
    if (-not $vsPath) {
        Write-Error "Failed to find Visual Studio Installation Path"
        exit 1
    }

    $msbuildPath = join-path $vsPath "\MSBuild\Current\Bin\MSBuild.exe"
    if (-not (Test-Path $msbuildPath)) {
        Write-Error "MSBuild.exe not found at $msbuildPath"
        exit 1
    }

    Write-Information "Found MSBuild at $msbuildPath"
    Write-Information "::endgroup::"

    return $msbuildPath
}