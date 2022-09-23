<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Github
  ║   Getters.ps1
  ║   GET INFORMATION
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>
# =============================================================
# GET GithubAccessToken
# =============================================================
function Get-GithubAccessToken {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User   
    )
    if($PSBoundParameters.ContainsKey('User') -eq $False){
        $User = (Get-GithubUserCredentials).UserName
    }

    $BaseRegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    
    $RegPath = Join-Path $BaseRegPath $User

    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    Get-RegistryValue -Path "$RegPath" -Entry 'access_token'
}


# =============================================================
# GET DefaultUsername
# =============================================================

function Get-GithubDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_username' -ErrorAction Ignore).default_username
    if( $User -ne $null ) { return $User  }
    if( $Env:DEFAULT_GIT_USERNAME -ne $null ) { return $Env:DEFAULT_GIT_USERNAME ; }    
    if( $Env:USERNAME -ne $null ) { return $Env:USERNAME ; }
    return $null
}

# =============================================================
# GET DefaultClonePath
# =============================================================

function Get-GithubDefaultClonePath {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_clone_path' -ErrorAction Ignore).default_clone_path
    if( $User -ne $null ) { return $User  }
    if( $Env:GITHUB_DEFAULT_DOWNLOAD_PATH -ne $null ) { return $Env:GITHUB_DEFAULT_CLONE_PATH ; }
    if( $Env:DefaultGithubRepositoryPath -ne $null ) { return $Env:GithubDefaultClonePath ; }
    return $null
}


# =============================================================
# GET SERVER
# =============================================================

function Get-GithubServer {          # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $Server = (Get-ItemProperty -Path "$RegPath" -Name 'hostname' -ErrorAction Ignore).hostname
    if( $Server -ne $null ) { return $Server }
     
    if( $Env:GITHUB_SERVER -ne $null ) { return $Env:GITHUB_SERVER  }
    return $null
}

# =============================================================
# GET GitExecutablePath
# =============================================================

function Get-GitExecutablePath{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $GitPath = (get-command "git.exe" -ErrorAction Ignore).Source
     
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\GitForWindows" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(Test-Path -Path $GitPath){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "$ENV:OrganizationHKCU\Git" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
}


# =============================================================
# GET GithubUrl
# =============================================================

function Get-GithubUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present", Position=0)]
        [switch]$Authenticated
    )
    try{
        [string]$UrlString = git config --get remote.origin.url
        [Uri]$GitUrl = $UrlString
        [string]$StrAbsoluteUri = $GitUrl.AbsoluteUri
        if($StrAbsoluteUri -eq ''){
            throw "NOT A GIT REPOSITORY"
            return ''
        }
        
        if($Authenticated){
            $Credz = Get-GithubAppCredentials
            if(($Credz.UserName -eq $Null)-Or($Credz.UserName -eq '')){
                throw "GithubAppCredentials not registered"
                return ''
            }
            $StrRepl = ('https://{0}:{1}@' -f $Credz.UserName, $Credz.GetNetworkCredential().Password)
            $StrAbsoluteUri = $StrAbsoluteUri.Replace('https://',$StrRepl)
        }
        
        return $StrAbsoluteUri
    }
    catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


