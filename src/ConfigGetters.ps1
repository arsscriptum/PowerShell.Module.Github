
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



function Get-AuthorizationHeader { # NOEXPORT
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [PSCredential]
        [System.Management.Automation.CredentialAttribute()]$Credential
    )
    
    process {
        'Basic {0}' -f (
            [System.Convert]::ToBase64String(
                [System.Text.Encoding]::ASCII.GetBytes(
                    ('{0}:{1}' -f $Credential.UserName, $Credential.GetNetworkCredential().Password)
                )# End [System.Text.Encoding]::ASCII.GetBytes(
            )# End [System.Convert]::ToBase64String(
        )# End 'Basic {0}' -f
    }# End process
}# End Get-AuthorizationHeader



function Get-GithubAppCredentials {    # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
     $CredId = "$ModuleName-App"
    $Credz =  Get-AppCredentials $CredId
    
    return $Credz
}

function Get-GithubUserCredentials {    # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )

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
function Get-GithubAccessToken {   # NOEXPORT
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

