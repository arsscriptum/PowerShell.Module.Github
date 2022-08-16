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
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Username,  
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Default,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Force      
    )
    $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    

    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    if( $TokenPresent ){ 
        Write-Verbose "Token already configured"
        if($Force -eq $False){
            return;
        }
    }

    if($PSBoundParameters.ContainsKey('Default')){
        Set-EnvironmentVariable -Name 'GITHUB_ACCESSTOKEN' -Value "$Token" -Scope 'Session'    
        Set-EnvironmentVariable -Name 'GITHUB_ACCESSTOKEN' -Value "$Token" -Scope 'User'    
        Write-Verbose "set $BaseRegPath default_access_token"
        $ret = New-RegistryValue -Path "$BaseRegPath" -Name 'default_access_token' -Value $Token -Type 'string'
    }
    if(($Username -ne $Null ) -And ($Username.Count -gt 0)){
        $RegPath = Join-Path $BaseRegPath $Username
        Write-Verbose "set $RegPath access_token"
        $ret = New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
        $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
        if( $TokenPresent ){ 
            Write-Verbose "Token already configured"
            if($Force -eq $False){
                return;
            }
        }
        $ret = New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
    }
    


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


