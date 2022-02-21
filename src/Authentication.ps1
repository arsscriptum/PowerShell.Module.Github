



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
    $Credz =  Get-AppCredentials "PowerShell-Github-arsscriptum"
    
    return $Credz
}


function Get-GithubModuleUserAgent { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Agent = "User-Agent $ModuleName. Custom Module."
   
    return $Agent
}
