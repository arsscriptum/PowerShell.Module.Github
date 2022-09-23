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
        [String]$User      
    )
    try{
        $RegPath = $BaseRegPath = Get-GithubModuleRegistryPath
        if( $RegPath -eq "" ) { throw "not in module"; return ;}
        
         if($PSBoundParameters.ContainsKey('User') -eq $False){
            $User = (Get-GithubUserCredentials).UserName
         } 
         
        if(($User -ne $Null ) -And ($User.Length -gt 0)){
            $RegPath = Join-Path $BaseRegPath $User
            Write-Verbose "set $RegPath access_token"
            Remove-RegistryValue -Path "$RegPath" -Name 'access_token'
            New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
        } 
    }catch{
         Show-ExceptionDetails $_
    }
  
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


