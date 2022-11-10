
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>




function Get-Repositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [string]$Username,
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Visibility") ]
         [ValidateSet('public','private')]
         [string]$Visibility='private'
     )
 
    try{

        $Response = ''
        $Token= Get-GithubAccessToken
        $UserCredz = Get-GithubUserCredentials
        $AppCredz = Get-GithubAppCredentials
        


        Write-verbose "Retrieving repositories for $Username......"
        Write-verbose "GithubAccessToken $Token"

        $headers = @{
            "Content-Type"= "application/x-www-form-urlencoded"
            "Authorization" = $Token
        }


        switch($Visibility){
            'private'   {
                            if(-not($Username | Get-IsLocalUser)){ throw "cannot fetch other user's private repos" }
                            $RequestUrl = "https://api.github.com/user/repos?sort=updated&direction=desc&per_page=100&visibility=$Visibility" 
                        }
            'public'    {
                            $RequestUrl = "https://api.github.com/users/$Username/repos?type=all&sort=updated&direction=desc&per_page=100" 
                            if($Username | Get-IsLocalUser){
                                $RequestUrl = "https://api.github.com/user/repos?sort=updated&direction=desc&per_page=100&visibility=$Visibility" 
                            }
                        }
        }
       
       
        Write-verbose "Visibility $Visibility"
        Write-verbose "RequestUrl $RequestUrl"
        

        $AccessToken = $Token
        $HeadersData = @{
            'Accept' =  'application/vnd.github.v3+json'
            'User-Agent' = Get-GithubModuleUserAgent
        }
        $HeadersData['Authorization'] = "token $AccessToken"

        $BodyData = @{
            grant_type  = 'password'
            username    = $UserCredz.UserName
            password    = $UserCredz.GetNetworkCredential().Password    
        }
        $Params = @{
            Uri             = $RequestUrl
            Body            = $BodyData
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $HeadersData
            Method          = 'GET'
            UseBasicParsing = $true
        }     

        Write-Verbose($HeadersData |  Out-DumpTable)
        Write-Verbose($BodyData |  Out-DumpTable)
        Write-Verbose($Params |  Out-DumpTable)

    
        $Response = (Invoke-WebRequest @Params).Content
        $ParsedBuffer = $Response | ConvertFrom-Json

        if($ParsedBuffer -eq $Null){$Null }
        $RepoCount=$ParsedBuffer.Count
        $ret=$ParsedBuffer | select name, private, clone_url, ssh_url, language, updated_at, description
        Write-verbose "ret $ret"
        return $ret
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
        return $Null
    }
    return $Null
   
}

function Get-PublicRepositories {
    [CmdletBinding(SupportsShouldProcess)]
    param(
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [ValidateNotNullOrEmpty()]
         [string]$Username
    )
    try{
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
        Write-Verbose "Get-Repositories -User $Username -Visibility 'public'"
        return Get-Repositories -User $Username -Visibility 'public'
    }catch{
        Show-ExceptionDetails $_
    }
 }

function Get-PrivateRepositories {
    [CmdletBinding(SupportsShouldProcess)]
    param(
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [ValidateNotNullOrEmpty()]
         [string]$Username
    )
    try{
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
        Write-Verbose "Get-Repositories -User $Username -Visibility 'private'"
        return Get-Repositories -User $Username -Visibility 'private'
    }catch{
        Show-ExceptionDetails $_
    }
 }




function Get-RepositoryList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [String]$Username,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )
    try{
        $RepoList = @()
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
       
        $URL="https://github.com/" + $Username + "?tab=repositories"
        if($PSBoundParameters.ContainsKey('Credential')){
            $u=$Credential.UserName
            Write-verbose " using credential [$u]..."
            $Data = (iwr $URL -Credential $Credential)
        }else{
            write-verbose " using DEFAULT credential ..."
            $Data = (iwr $URL )
        }
        
        write-verbose "HTTP REQUEST RETURNED $SDesc ($SCode)"
        $SCode = $Data.StatusCode
        $SDesc = $Data.StatusDescription
        if($Data.StatusCode -eq 200){
            $pattern='<a href="/' + $Username
            $File = (New-TemporaryFile).Fullname
            Set-Content -Path $File -Value $Data.Content
            $matches=(Select-String -Path $File -Pattern "$pattern" -SimpleMatch -Raw)
            
            $matches | % { $Line = $_ ; 
                $i = $Line.IndexOf("$Username") 
                $Line = $Line.SubString($i)
                $ni = $Line.IndexOf('"')
                $Line = $Line.SubString(0,$ni)
                $RepoList += $Line ; 
            }
             $repocount=$RepoList.Length
            Write-verbose "Found $repocount repositories for $Username"
            $RepoList
        }
        
    } catch {
        Show-ExceptionDetails($_)
    }
}