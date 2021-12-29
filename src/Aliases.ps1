<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# GitHub.ps1
#===============================================================================
New-Alias -Name listrepo -value Get-GHRepositories
New-Alias -Name listprivaterepo -value Get-PrivateRepositories
New-Alias -Name listpublicrepo -value Get-PublicRepositories

# git status
New-Alias -Name state -Value Get-Status
New-Alias -Name stat -Value Get-Status
# diff
New-Alias -Name gdiff -Value Show-Diff

New-Alias -Name rev -Value Get-GitRevision

# push
New-Alias -Name push -value Push-Changes

New-Alias -Name clonemine -value Initialize-LocalUserRepository
# clone user
New-Alias -Name cloneuser -value Sync-UserRepositories

# commit
New-Alias -Name commit -value Save-Changes

# clone myself
New-Alias -Name clone -Value Initialize-Repository

# repo
New-Alias -Name cloneurl -Value Resolve-RepositoryUrl

# pull 
New-Alias -Name fetch -value Update-Repository
New-Alias -Name update -value Update-Repository
New-Alias -Name getlatest -value Update-Repository
New-Alias -Name pull -value Update-Repository
New-Alias -Name up -value Update-Repository

# pull 
New-Alias -Name newr -value New-Repository

New-Alias -Name parserepourl -value Split-RepositoryUrl