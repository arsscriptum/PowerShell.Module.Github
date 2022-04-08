<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Github
  ║   Authentication.ps1
  ║   GET AUTHENTICATION DATA
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



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


function Set-GithubUserCredentials { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Password 
    )
    
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    Write-Host "✅ Register-AppCredentials -Id $ModuleName -Username $User -Password $Password"
    Register-AppCredentials -Id $ModuleName -Username $User -Password $Password
    
}
function Set-GithubAppCredentials { 
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    Write-Host "✅ Register-AppCredentials -Id $ModuleName -Username $(Get-GithubDefaultUsername) -Password $(Get-GithubAccessToken)"
    Register-AppCredentials -Id $ModuleName -Username $(Get-GithubDefaultUsername) -Password $(Get-GithubAccessToken)
    
}

function Get-GithubUserCredentials { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )
    $Credz =  Get-AppCredentials "User-Github-arsscriptum"

    return $Credz
}

function Get-GithubAppCredentials { 
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


function Get-GithubModuleUserAgent { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Agent = "User-Agent $ModuleName. Custom Module."
   
    return $Agent
}
