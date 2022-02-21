
<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell GitHub Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Set-RepoPublic {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="url") ]
         [string]$Repo
     )
 
    try{
        $Response = ''
        $Token= Get-GithubAccessToken
        $UserCredz = Get-GithubUserCredentials
        $AppCredz = Get-GithubAppCredentials
     
        Write-ChannelMessage "Retrieving repositories for $User......"
        Write-verbose "Retrieving repositories for $User......"
        Write-verbose "GithubAccessToken $Token"
        $headers = @{
            "Accept" = "application/vnd.github.nebula-preview+json"
            
            "Authorization" = $Token
        }

        $u = $UserCredz.UserName
        $RequestUrl = "https://api.github.com/repos/$u/$Repo" 
        Write-Verbose "RequestUrl $RequestUrl"
        $AccessToken = (Get-GithubAccessToken)
        $HeadersData = @{
            'Accept' =  'application/vnd.github.v3+json'
            'User-Agent' = Get-GithubModuleUserAgent
        }
        $HeadersData['Authorization'] = "token $AccessToken"

        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
            "visibility"= "public"
        }
        Write-Verbose "BodyData $BodyData"
        $Params = @{
            Uri             = $RequestUrl
            Body            = $BodyData
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $HeadersData
            Method          = 'PATCH'
            UseBasicParsing = $true
        }     
        Write-Verbose "Params $Params"

        Write-Verbose "Invoke-WebRequest $Params"
        $Response = (Invoke-WebRequest @Params).Content
        $ParsedBuffer = $Response | ConvertFrom-Json
        $ParsedBuffer

    } catch {
        Show-ExceptionDetails($_) -ShowStack
        return $Null
    }
    return $Null
   
}