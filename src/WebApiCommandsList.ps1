
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   PowerShell GitHub Module
#>




function Get-Repositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Github account username") ]
         [string]$Username,
         [Parameter(Mandatory=$false,HelpMessage="Visibility") ]
         [ValidateSet('public','private')]
         [string]$Visibility='private',
         [Parameter(Mandatory=$false,HelpMessage="The page number of the results to fetch") ]
         [int]$Page=1,
         [Parameter(Mandatory=$false,HelpMessage="The number of results per page (max 100)") ]
         [ValidateRange(1,100)]
         [int]$PerPage=100,
         [Parameter(Mandatory=$false,HelpMessage="The property to sort the results by") ]
         [ValidateSet('created', 'updated', 'pushed', 'full_name')]
         [string]$Sort='full_name',
         [Parameter(Mandatory=$false,HelpMessage="Direction") ]
         [ValidateSet('desc','asc')]
         [string]$Direction='desc',
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated after the given time") ]
         [DateTime]$Since,
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated before the given time") ]
         [DateTime]$Before
     )
 
    try{

        function Convert-ToISO8601 {
            param (
                [DateTime]$Date = (Get-Date)
            )
            return $Date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        }

        [bool]$UseSinceArg = $False
        if($Since -ne $Null){
            $UseSinceArg = $True
            $argumentSince = "&since={0}" -f (Convert-ToISO8601 -Date $Since)
        }

        [bool]$UseBeforeArg = $False
        if($Before -ne $Null){
            $UseBeforeArg = $True
            $argumentBefore = "&before={0}" -f (Convert-ToISO8601 -Date $Before)
        }

        switch($Visibility){
            'private'   {
                            if(-not($Username | Get-IsLocalUser)){ throw "cannot fetch other user's private repos" }
                            $RequestUrl = "https://api.github.com/user/repos?sort={0}&direction={1}&page={2}&per_page={3}&visibility={4}" -f $Sort, $Direction, $Page, $PerPage, $Visibility
                        }
            'public'    {
                            $RequestUrl = "https://api.github.com/users/{0}/repos?sort={1}&direction={2}&page={3}&per_page={4}&visibility={5}" -f $Username, $Sort, $Direction, $Page, $PerPage, $Visibility
                            if($Username | Get-IsLocalUser){
                                $RequestUrl = "https://api.github.com/user/repos?sort={0}&direction={1}&page={2}&per_page={3}&visibility={4}" -f $Sort, $Direction, $Page, $PerPage, $Visibility
                            }
                        }
        }

        if($UseSinceArg){
            $RequestUrl += $argumentSince
        }
        if($UseBeforeArg){
            $RequestUrl += $argumentBefore
        }

        Write-verbose "Username      $Username"
        Write-verbose "before        $argumentBefore"
        Write-verbose "since         $argumentSince"
        Write-verbose "RequestUrl    $RequestUrl"
        Write-verbose "Sort          $Sort"
        Write-verbose "Visibility    $Visibility"
        Write-verbose "Direction     $Direction"
        Write-verbose "Page          $Page"
        Write-verbose "PerPage       $PerPage"
        Write-verbose "Visibility    $Visibility"
        Write-verbose "RequestUrl    $RequestUrl"

        $Response = ''
        $UserCredz = Get-GithubUserCredentials
        $HeadersData = Get-GithubAuthorizationHeader
         
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
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Github account username") ]
         [string]$Username,
         [Parameter(Mandatory=$false,HelpMessage="The page number of the results to fetch") ]
         [int]$Page=1,
         [Parameter(Mandatory=$false,HelpMessage="The number of results per page (max 100)") ]
         [ValidateRange(1,100)]
         [int]$PerPage=100,
         [Parameter(Mandatory=$false,HelpMessage="The property to sort the results by") ]
         [ValidateSet('created', 'updated', 'pushed', 'full_name')]
         [string]$Sort='full_name',
         [Parameter(Mandatory=$false,HelpMessage="Direction") ]
         [ValidateSet('desc','asc')]
         [string]$Direction='desc',
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated after the given time") ]
         [DateTime]$Since,
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated before the given time") ]
         [DateTime]$Before
     )
    try{
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
        Write-Verbose "Get-Repositories -User $Username -Visibility 'public'"
        $RequestArgs = @{
            User = $Username 
            Visibility = 'public' 
            Page = $Page
            PerPage = $PerPage 
            Sort = $Sort 
            Direction = $Direction 
        }
        if($Since -ne $Null){
            $RequestArgs['Since'] = $Since
        }
        if($Before -ne $Null){
            $RequestArgs['Before'] = $Before
        }
        return Get-Repositories @RequestArgs
        
    }catch{
        Show-ExceptionDetails $_
    }
 }

function Get-PrivateRepositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Github account username") ]
         [string]$Username,
         [Parameter(Mandatory=$false,HelpMessage="The page number of the results to fetch") ]
         [int]$Page=1,
         [Parameter(Mandatory=$false,HelpMessage="The number of results per page (max 100)") ]
         [ValidateRange(1,100)]
         [int]$PerPage=100,
         [Parameter(Mandatory=$false,HelpMessage="The property to sort the results by") ]
         [ValidateSet('created', 'updated', 'pushed', 'full_name')]
         [string]$Sort='full_name',
         [Parameter(Mandatory=$false,HelpMessage="Direction") ]
         [ValidateSet('desc','asc')]
         [string]$Direction='desc',
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated after the given time") ]
         [DateTime]$Since,
         [Parameter(Mandatory=$false,HelpMessage="Only show repositories updated before the given time") ]
         [DateTime]$Before
     )
    try{
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
        $RequestArgs = @{
            User = $Username 
            Visibility = 'public' 
            Page = $Page
            PerPage = $PerPage 
            Sort = $Sort 
            Direction = $Direction 
        }
        if($Since -ne $Null){
            $RequestArgs['Since'] = $Since
        }
        if($Before -ne $Null){
            $RequestArgs['Before'] = $Before
        }
        return Get-Repositories @RequestArgs
        
    }catch{
        Show-ExceptionDetails $_
    }
 }




function Get-RepositoryList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Github account username") ]
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



function Get-RepositoryPackage{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Github account username") ]
        [String]$Username,
        [Parameter(Mandatory=$true, HelpMessage="repository") ]
        [String]$Repository,
        [Parameter(Mandatory=$false)]
        [String]$Branch="main",
        [Parameter(Mandatory=$false)]
        [ValidateSet('zip','tar')]
        [String]$Type="zip"
    )
    try{
        $RepoList = @()
        if($PSBoundParameters.ContainsKey('Username') -eq $False){
            $Username = (Get-GithubUserCredentials).UserName
            if([string]::IsNullOrEmpty($Username)){ throw "GithubUserCredentials not set. Use Set-GithubUserCredentials or Initialize-GithubModule" }
        }
       

        $RequestUrl="https://github.com/repos/{0}/{1}/{2}ball/{3}" -f $Username, $Repository, $Type, $Branch
     
        $Response = ''
        $UserCredz = Get-GithubUserCredentials
        $HeadersData = Get-GithubAuthorizationHeader

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

        Write-verbose "Username      $Username"
        Write-verbose "Repository    $Repository"
        Write-verbose "Type          $Type"
        Write-verbose "Branch        $Branch"
        Write-verbose "RequestUrl    $RequestUrl"
        $Response = (Invoke-WebRequest @Params).Content
        $ParsedBuffer = $Response | ConvertFrom-Json

        if($ParsedBuffer -eq $Null){$Null }
       
        return $ParsedBuffer
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
        return $Null
    }
    return $Null
   
}
