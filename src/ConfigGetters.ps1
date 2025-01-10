
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>


function Get-IsLocalUser {    # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Username")]
        [String]$Username
    )

    $u = (Get-GithubUserCredentials).UserName
    $u -like $Username
}



function Get-GithubAuthorizationHeader {   
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $Credential = 
    $TokenType = Get-GithubTokenType
    $token=''
    if($TokenType -eq 'legacy'){
        $token = Get-GithubAccessToken
    }else{
        $token = Get-GithubFinedGrainToken
    }
    
    $Headers = @{
        "Authorization" = "token $token"
        "X-GitHub-Api-Version" = "2022-11-28"
        "Accept" = "application/vnd.github+json" 
    }
    $Headers
}



function Get-GithubAppCredentials {    
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
     $CredId = "$ModuleName-App"
    $Credz =  Get-AppCredentials $CredId
    
    return $Credz
}

function Get-GithubUserCredentials {    
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module

    $Credz =  Get-AppCredentials $ModuleName
    
    return $Credz
}


function Get-GithubModuleUserAgent {    # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Agent = "User-Agent $ModuleName. Custom Module."
   
    return $Agent
}


# =============================================================
# GET GithubAccessToken
# =============================================================
function Get-GithubAccessToken {   
    [CmdletBinding(SupportsShouldProcess)]
    param(
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [ValidateNotNullOrEmpty()]
         [string]$User
    )
    try{
        if($PSBoundParameters.ContainsKey('User') -eq $False){
            $User = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($User)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }

        $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
    
        $RegPath = Join-Path $BaseRegPath $User

        $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
        Get-RegistryValue -Path "$RegPath" -Entry 'access_token'
    }catch{
        Show-ExceptionDetails $_
    }
 }


function Get-GithubFinedGrainToken {    
    [CmdletBinding(SupportsShouldProcess)]
    param(
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [ValidateNotNullOrEmpty()]
         [string]$User
    )
    try{
        if($PSBoundParameters.ContainsKey('User') -eq $False){
            $User = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($User)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }

        $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
    
        $RegPath = Join-Path $BaseRegPath $User

        $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'fine-grained-pat'
        Get-RegistryValue -Path "$RegPath" -Entry 'fine-grained-pat'
    }catch{
        Show-ExceptionDetails $_
    }
 }


function Get-GithubTokenType {   
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try{

        $User = (Get-GithubUserCredentials).UserName
        if([string]::IsNullOrEmpty($User)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }

        $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
    
        $RegPath = Join-Path $BaseRegPath $User

        $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'token_type'
        Get-RegistryValue -Path "$RegPath" -Entry 'token_type'
    }catch{
        Show-ExceptionDetails $_
    }
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

