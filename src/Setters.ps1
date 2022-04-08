<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Github
  ║   Setters.ps1
  ║   SET INFORMATION
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


function Set-GithubAccessToken{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Token,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,  
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Default,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Force      
    )
    $BaseRegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $RegPath = Join-Path $BaseRegPath $Username

    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    if( $TokenPresent ){ 
        Write-Verbose "Token already configured"
        if($Force -eq $False){
            return;
        }
    }
    if($Default){
        [environment]::SetEnvironmentVariable('GITHUB_ACCESSTOKEN',"$Token",'Process')    
        Write-Verbose "set $BaseRegPath default_access_token"
        $ret = New-RegistryValue -Path "$BaseRegPath" -Name 'default_access_token' -Value $Token -Type 'string'
    }
    Write-Verbose "set $RegPath access_token"
    $ret = New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'

    return $ret    
}
function Set-GithubDefaultClonePath{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Path    
    )
    $RegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}

    $ret = New-RegistryValue -Path "$RegPath" -Name 'default_clone_path' -Value $Path -Type 'string'
    [environment]::SetEnvironmentVariable('GITHUB_DEFAULT_CLONE_PATH',"$Path",'Process')
    return $ret    
}

function Set-GithubDefaultServer{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname    
    )
    $RegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}

    $ret = New-RegistryValue -Path "$RegPath" -Name 'hostname' -Value $Hostname -Type 'string'
    [environment]::SetEnvironmentVariable('GITHUB_SERVER',"$Hostname",'Process')
    return $ret    
}

function Set-GithubDefaultUsername{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User      
    )
    $RegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $ok = Set-RegistryValue  "$RegPath" "default_username" "$User"
    [environment]::SetEnvironmentVariable('DEFAULT_GIT_USERNAME',"$User",'Process')
    return $ok
}


