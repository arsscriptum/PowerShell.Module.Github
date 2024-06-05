
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>


function Get-GithubModuleRegistryPath {  # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName"
   
    return $Path
}


function Resolve-RepositoryUrl {    # NOEXPORT
    param(
        [parameter(mandatory=$true)]
        [ValidateScript({
            $Uri = [uri]$_
            $Scheme = $Uri.Scheme
            $Hostname = $Uri.Host
            $SegmentCount = $Uri.Segments.Count
            if($SegmentCount -ne 3) { Throw "Invalid Url [url segment]" }
            if($Hostname -ne 'github.com') { Throw "Invalid Url [Hostname] $Hostname not github.com" }
            if($Scheme -ne 'https') { Throw "Invalid Url [Scheme] $Scheme not https" }
            return $True
        })]
        [Alias('u')] [string]$Repository,        
        [parameter(mandatory=$true)]
        [String]$User
    )

    $SplitUrl = Split-RepositoryUrl -Url $Repository
    $Url = "git@github.com-$User" + ':' + $User + '/' + $SplitUrl.Filename

    return $Url
}



function Load-ProjectPage {  
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    try{
        if(!(Get-Command "Get-GithubUrl" -ErrorAction Ignore)){ throw "missing Get-GithubUrl command" ; }
        if(!(Get-Command "Get-ChromePath" -ErrorAction Ignore)){ throw "missing Get-ChromePath command" ; }
        [string]$Url = ( ((Get-GithubUrl) -as [string]).Replace('.git','') )
        [Uri]$TestUri = [Uri]$Url
        [bool]$IsValid = (($TestUri.Host -eq "github.com") -And ($TestUri.IsAbsoluteUri -eq $True) -And ($TestUri.IsFile -eq $False) -And ($TestUri.IsLoopback -eq $False))
        if($IsValid -eq $False){ throw "invalid url"; }
        Write-Host "The project page url is `"$Url`"";
        &(Get-ChromePath) "$Url"
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}



function Split-RepositoryUrl {   # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Repository Url")]
        [ValidateScript({
            $Uri = [uri]$_
            $Scheme = $Uri.Scheme
            $Hostname = $Uri.Host
            $SegmentCount = $Uri.Segments.Count
            if($SegmentCount -ne 3) { Throw "Invalid Url [segment]" }
            if($Hostname -ne 'github.com') { Throw "Invalid Url [Hostname]" }
            if($Scheme -ne 'https') { Throw "Invalid Url [Scheme]" }
            return $True
        })]
        [Alias('u')] [string] $Url
    )
    try{
        [System.Uri]$Uri = [uri]$Url
        $Scheme = $Uri.Scheme
        $Hostname = $Uri.Host
        $Segments = $Uri.Segments
        $Filename = $Segments[2]
        $Len = $Filename.Length - 4
        $Basename = $Filename.SubString(0,$Len)
        $Extension = $Filename.SubString($Len)
        $AbsoluteUri = $Uri.AbsoluteUri
        [pscustomobject]$obj = @{
            Url = $AbsoluteUri
            Scheme = $Scheme
            Hostname = $Hostname
            Filename = $Filename
            Basename = $Basename
            Extension = $Extension
        }
        return $obj
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}
