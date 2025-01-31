# Measure the startup time of pwsh (PowerShell Core) in milliseconds
# Do not load the profile so we can isolate the time for the shell itself to load
$p = 0
1..100 | ForEach-Object {
    Write-Progress -Id 1 -Activity 'pwsh' -PercentComplete $_
    $p += (Measure-Command {
        pwsh -noprofile -command 1
    }).TotalMilliseconds 
}
Write-Progress -id 1 -Activity 'profile' -Completed
$p = $p/100
$p


# Measure the time it takes for powershell to load with the profile
$a = 0
1..100 | ForEach-Object {
    Write-Progress -Id 1 -Activity 'profile' -PercentComplete $_
    $a += (Measure-Command {
        pwsh -command 1
    }).TotalMilliseconds
}
Write-Progress -id 1 -activity 'profile' -Completed

# Subtract the time it takes to load the shell without the profile from the time 
# it takes to load the shell with the profile
$profile_time = $a/100 - $p

Write-Host "Time to load pwsh without profile: $p"
Write-Host "Time to load pwsh with profile: $a"
Write-Host "\nTime to load profile: $profile_time"