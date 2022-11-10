
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>



function Set-GithubAccessToken{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Username,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Token    
    )
    try{
        $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; }
        
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
        }
         
        if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }

        $RegPath = Join-Path $BaseRegPath $Username
        Write-Verbose "set $RegPath access_token"
        Remove-RegistryValue -Path "$RegPath" -Name 'access_token'
        New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
        
    }catch{
         Show-ExceptionDetails $_
    }
}



function Set-GithubUserCredentials { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Username,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Password 
    )
    
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    Write-Verbose "Register-AppCredentials -Id $ModuleName -Username $Username -Password $Password"
    Register-AppCredentials -Id $ModuleName -Username $Username -Password $Password
    
}
function Set-GithubAppCredentials { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Client,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$Secret 
        )
    
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $CredId = "$ModuleName-App"
    Write-Verbose "CredId $CredId ModuleName $ModuleName"

    
    Write-Verbose " Register-AppCredentials -Id $CredId -Username $Client -Password $Secret"
    Register-AppCredentials -Id $CredId -Username $Client -Password $Secret
    
}