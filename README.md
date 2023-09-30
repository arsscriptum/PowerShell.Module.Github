# PowerShell.Module.GitHub

A little module that implements and automate my github operations that I do on the regular.

## Stats

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-GhSavedStatsSample                | Stats                |
| Get-GhStatsPublicRepos                | Stats                |
| Update-GhSavedStats                   | Stats                |
| Get-GhSavedStats                      | Stats                |
| Get-GhStatsArsScriptum                | Stats                |
| Get-GhStatsRedditSupport              | Stats                |
| Get-GhStatsArsScriptum                | Stats                |
| Save-GhStatsArsScriptum               | Stats                |
| Get-GhStatsRepository                 | Stats                |
| Save-GhStatsRedditSupport             | Stats                |
| Get-GhStatsRepositoryCount            | Stats                |
| Save-GhStatsRepository                | Stats                |
| Get-GhStatsTopReferrals               | Stats                |
| Get-GhStatsMostPopular                | Stats                |
| Get-GhStatsClones                     | Stats                |
| Get-GhStatsViews                      | Stats                |
| Get-GhStatsRedditSupport              | Stats                |

## Config

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-GithubModuleUserAgent             | Config               |
| Get-GithubAuthorizationHeader         | Config               |
| Get-GithubModuleInformation           | Config               |
| Get-StatsPath                         | Config               |


## ConfigGetters

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-GithubAppCredentials              | ConfigGetters        |
| Get-GithubUserCredentials             | ConfigGetters        |
| Get-GithubAccessToken                 | ConfigGetters        |
| Get-GitExecutablePath                 | ConfigGetters        |


## GhAuthentication

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Invoke-SetupGitAuthentication         | GhAuthentication     |
| Get-GithubAuthenticationStatus        | GhAuthentication     |


## GhCommands

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-RepositoriesDetails               | GhCommands           |
| Set-RepositoryVisibility              | GhCommands           |
| New-Repository                        | GhCommands           |
| Remove-Repository                     | GhCommands           |


## GhInstall

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-GhCliSource                       | GhInstall            |
| Test-GhCliInstallation                | GhInstall            |
| Get-GhCliExePath                      | GhInstall            |


## GitCommands

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-AddedFiles                        | GitCommands          |
| Get-Latest                            | GitCommands          |
| Invoke-GitRevertFiles                 | GitCommands          |
| Get-DeletedFiles                      | GitCommands          |
| Get-ModifiedFiles                     | GitCommands          |
| Show-Diff                             | GitCommands          |
| Save-Changes                          | GitCommands          |
| Invoke-Git                            | GitCommands          |
| Get-GithubUrl                         | GitCommands          |
| Invoke-CloneRepositoryAuthenticated   | GitCommands          |
| Push-Changes                          | GitCommands          |
| Invoke-CloneRepository                | GitCommands          |



## Initialize

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Uninitialize-GithubModule             | Initialize           |
| Initialize-GithubModule               | Initialize           |
| Initialize-GithubModuleWithSecret     | Initialize           |
| Invoke-InstallGhClient                | Initialize           |


## WebApiCommands

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Invoke-AutoUpdateProgress             | WebApiCommands       |
| Sync-UserRepositories                 | WebApiCommands       |


## WebApiCommandsList

|  **Name**                             |  **Category**        |
|---------------------------------------|----------------------|
| Get-PrivateRepositories               | WebApiCommandsList   |
| Get-Repositories                      | WebApiCommandsList   |
| Get-PublicRepositories                | WebApiCommandsList   |
| Get-RepositoryList                    | WebApiCommandsList   |