# PowerShell.Module.Github

## Overview

This module implements general tooling for my Powershell environment. Largely built from scratch, with references from some quality coding resources, it provides world-class support for application development, systems administration and general functionalities.

## Compilation

You need the [PowerShell.ModuleBuilder](https://github.com/arsscriptum/PowerShell.ModuleBuilder) to compile this module.

## Documentation

View [generated documentation](https://github.com/arsscriptum/PowerShell.Module.Github/tree/master/doc)

## View Functions list

### Config

***Functions for Config***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-GithubModuleUserAgent                | [Config.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Config.ps1)                |
| Get-GithubAuthorizationHeader            | [Config.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Config.ps1)            |
| Get-GithubModuleInformation              | [Config.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Config.ps1)              |
| Get-StatsPath                            | [Config.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Config.ps1)                            |

### ConfigGetters

***Functions for ConfigGetters***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-GithubAppCredentials                 | [ConfigGetters.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/ConfigGetters.ps1)                 |
| Get-GithubUserCredentials                | [ConfigGetters.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/ConfigGetters.ps1)                |
| Get-GithubAccessToken                    | [ConfigGetters.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/ConfigGetters.ps1)                    |
| [Get-GitExecutablePath](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/doc/Get-GitExecutablePath.md)                    | [ConfigGetters.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/ConfigGetters.ps1)                    |

### GhAuthentication

***Functions for GhAuthentication***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Invoke-SetupGitAuthentication            | [GhAuthentication.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhAuthentication.ps1)            |
| Get-GithubAuthenticationStatus           | [GhAuthentication.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhAuthentication.ps1)           |

### GhCommands

***Functions for GhCommands***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-RepositoriesDetails                  | [GhCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhCommands.ps1)                  |
| Set-RepositoryVisibility                 | [GhCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhCommands.ps1)                 |
| New-Repository                           | [GhCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhCommands.ps1)                           |
| Remove-Repository                        | [GhCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhCommands.ps1)                        |

### GhInstall

***Functions for GhInstall***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-GhCliSource                          | [GhInstall.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhInstall.ps1)                          |
| Test-GhCliInstallation                   | [GhInstall.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhInstall.ps1)                   |
| Get-GhCliExePath                         | [GhInstall.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GhInstall.ps1)                         |

### GitCommands

***Functions for GitCommands***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-AddedFiles                           | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                           |
| Get-Latest                               | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                               |
| Invoke-GitRevertFiles                    | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                    |
| Get-DeletedFiles                         | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                         |
| Get-ModifiedFiles                        | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                        |
| Show-Diff                                | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                                |
| Save-Changes                             | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                             |
| Invoke-Git                               | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                               |
| Get-GithubUrl                            | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                            |
| Invoke-CloneRepositoryAuthenticated      | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)      |
| Push-Changes                             | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                             |
| Invoke-CloneRepository                   | [GitCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/GitCommands.ps1)                   |

### Initialize

***Functions for Initialize***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Uninitialize-GithubModule                | [Initialize.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Initialize.ps1)                |
| Initialize-GithubModule                  | [Initialize.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Initialize.ps1)                  |
| Initialize-GithubModuleWithSecret        | [Initialize.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Initialize.ps1)        |

### InstallGhClient

***Functions for InstallGhClient***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Invoke-InstallGhClient                   | [InstallGhClient.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/InstallGhClient.ps1)                   |

### Stats

***Functions for Stats***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-GhSavedStatsAllSamples               | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)               |
| Get-GhSavedStatsSorted                   | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                   |
| Update-GhSavedStats                      | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                      |
| Get-GhSavedStats                         | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                         |
| Get-GhStatsArsScriptum                   | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                   |
| Get-GhStatsRedditSupport                 | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                 |
| Get-GhStatsArsScriptum                   | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                   |
| Save-GhStatsArsScriptum                  | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                  |
| Get-GhStatsRepository                    | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                    |
| Save-GhStatsRedditSupport                | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                |
| Get-GhStatsRepositoryCount               | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)               |
| Save-GhStatsRepository                   | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                   |
| Get-GhStatsTopReferrals                  | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                  |
| Get-GhStatsMostPopular                   | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                   |
| Get-GhStatsClones                        | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                        |
| Get-GhStatsViews                         | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                         |
| Get-GhStatsRedditSupport                 | [Stats.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/Stats.ps1)                 |

### WebApiCommands

***Functions for WebApiCommands***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| [Invoke-AutoUpdateProgress](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/doc/Invoke-AutoUpdateProgress.md)                | [WebApiCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommands.ps1)                |
| Sync-UserRepositories                    | [WebApiCommands.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommands.ps1)                    |

### WebApiCommandsList

***Functions for WebApiCommandsList***

|  **Function**                            |  **Source**                              |
|:-----------------------------------------|:-----------------------------------------|
| Get-PrivateRepositories                  | [WebApiCommandsList.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommandsList.ps1)                  |
| Get-Repositories                         | [WebApiCommandsList.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommandsList.ps1)                         |
| Get-PublicRepositories                   | [WebApiCommandsList.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommandsList.ps1)                   |
| Get-RepositoryList                       | [WebApiCommandsList.ps1](https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/WebApiCommandsList.ps1)                       |

