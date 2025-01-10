

function Set-GithubAccessToken{ 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Token    
    )
    try{
        $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; }
        
        $Username = (Get-GithubUserCredentials).UserName
        if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }

        $RegPath = Join-Path $BaseRegPath $Username
        Write-Verbose "set $RegPath access_token"
        Remove-RegistryValue -Path "$RegPath" -Name 'access_token'
        New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
        
    }catch{
         Show-ExceptionDetails $_
    }
}

function Set-GithubFinedGrainToken{ 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Token    
    )
    try{
        $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; }
        
        $Username = (Get-GithubUserCredentials).UserName
        
         
        if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }

        $RegPath = Join-Path $BaseRegPath $Username
        Write-Verbose "set $RegPath fine-grained-pat"
        Remove-RegistryValue -Path "$RegPath" -Name 'fine-grained-pat'
        New-RegistryValue -Path "$RegPath" -Name 'fine-grained-pat' -Value $Token -Type 'string'
        
    }catch{
         Show-ExceptionDetails $_
    }
}


function Set-GithubTokenType{ 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('legacy','finegrained')]
        [String]$TokenType    
    )
    try{
        $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; }
        

        $Username = (Get-GithubUserCredentials).UserName
        if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }

        $RegPath = Join-Path $BaseRegPath $Username
       
        Remove-RegistryValue -Path "$RegPath" -Name 'token_type'
        New-RegistryValue -Path "$RegPath" -Name 'token_type' -Value $TokenType -Type 'string'
        
    }catch{
         Show-ExceptionDetails $_
    }
}


function Set-GithubUserCredentials {    # NOEXPORT
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
function Set-GithubAppCredentials {    # NOEXPORT
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