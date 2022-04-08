<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Github
  ║   Setters.ps1
  ║   SET INFORMATION
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>





function Set-GithubDefaultUsername {
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
