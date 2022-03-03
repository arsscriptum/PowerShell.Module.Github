<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
##
##  Some notes:
##    - In github, go to  // Settings / Developer settings / personal access token
##      to add a personal token with scope "Full control of private repositories"
##      and set variable '$access_token' below
##    - Set variable $organisation for your github organisation or username.
##    - When using multiple ssh keys with one or multiple github accounts
##      the keys are in ssh config file (~/.ssh/config), with differents hosts
##      set the '$github_host' variable accordingly
##
##  Quebec City, Canada, MMXXI
#>


function Script:AutoUpdateProgress {
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}


function Get-GithubModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName"
   
    return $Path
}


function Get-GitRevision {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Repository Path")]
        [Alias('p')] [string] $Path,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Long revision format")]
        [Alias('l')] [switch] $Long,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="No logs, clean output")]
        [Alias('r')] [switch] $Raw        
    )
    try{
        $TmpFile = (New-TemporaryFile).Fullname
        $ShowMessages = $True
        If( $PSBoundParameters.ContainsKey('Raw') -eq $True ){ $ShowMessages = $False }
        $CurrentPath = (Get-Location).Path
        If( $PSBoundParameters.ContainsKey('Path') -eq $True ){
            if(-not(Test-Path -Path $Path -PathType Container)){ throw "Could not locate Path $Path" ; return ''}
            Write-Verbose "Fetching Git Revision from $Path"
        }else{
            # Just so that I can popd at the end withou checking argument
            $Path = $CurrentPath
        }
        pushd $Path
        $Revision = ''  
        if($ShowMessages){
            Write-ChannelMessage "Retrieving git revision for $Path"
        }
        If( $PSBoundParameters.ContainsKey('Long') -eq $True ){
            $Revision = git rev-parse HEAD 2> $TmpFile
        }else{
            $Revision = git rev-parse --short HEAD 2> $TmpFile
        }
        if($?){
            if($ShowMessages){
                Write-ChannelResult " Success. Revision: $Revision"
            }          
        }else{
            $ErrorStr = Get-Content $TmpFile -Raw
            throw "ERROR WHILE FETCHING GIT REVISION in $Path ==> $ErrorStr"
            $Revision = ''
        }
        return $Revision
    } catch {
        Show-ExceptionDetails($_)
    }finally{
        popd
    }
}

function Initialize-GithubModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Token,      
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1,HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$User,   
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2,HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$ClonePath,   
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=3,HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname,   
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,HelpMessage="Overwrite if present")]
        [switch]$Force      
    )
    Set-GithubAccessToken -Token $Token -Force:$Force
    Write-Host "✅ Set-GithubAccessToken $Token"
    Set-GithubDefaultUsername -User $User
    Write-Host "✅ Set-GithubDefaultUsername $User" 
    Set-GithubDefaultServer -Hostname $Hostname
    Write-Host "✅ Set-GithubDefaultServer $Hostname"
    Set-GithubDefaultClonePath -Path $ClonePath
    Write-Host "✅ Set-GithubDefaultClonePath $ClonePath"
}


function Set-GithubAccessToken {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [ValidateNotNullOrEmpty()]
        [String]$Token,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [switch]$Force      
    )
    $RegPath = Get-GithubModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    
    if( $TokenPresent ){ 
        Write-Verbose "Token already configured"
        if($Force -eq $False){
            return;
        }
    }
    $ret = New-RegistryValue -Path "$RegPath" -Name 'access_token' -Value $Token -Type 'string'
    [environment]::SetEnvironmentVariable('GITHUB_ACCESSTOKEN',"$Token",'Process')
    return $ret    
}
function Set-GithubDefaultClonePath {
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

function Set-GithubDefaultServer {
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

function Get-GithubAccessToken {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'access_token'
    if( $TokenPresent -eq $true ) {
        $Token = Get-RegistryValue -Path "$RegPath" -Entry 'access_token'
        return $Token
    }
    if( $Env:REDDIT_ACCESSTOKEN -ne $null ) { return $Env:REDDIT_ACCESSTOKEN  }
    return $null
}

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

<#
    GithubDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\github.com" -Name 'default_username' -Value 'codecastor'
 #>
function Get-GithubDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_username' -ErrorAction Ignore).default_username
    if( $User -ne $null ) { return $User  }
    if( $Env:DEFAULT_GIT_USERNAME -ne $null ) { return $Env:DEFAULT_GIT_USERNAME ; }    
    if( $Env:USERNAME -ne $null ) { return $Env:USERNAME ; }
    return $null
}

<#
    GithubDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\github.com" -Name 'default_clone_path' -Value 'P:\Github-Repositories'
 #>
function Get-GithubDefaultClonePath {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_clone_path' -ErrorAction Ignore).default_clone_path
    if( $User -ne $null ) { return $User  }
    if( $Env:GITHUB_DEFAULT_DOWNLOAD_PATH -ne $null ) { return $Env:GITHUB_DEFAULT_CLONE_PATH ; }
    if( $Env:DefaultGithubRepositoryPath -ne $null ) { return $Env:GithubDefaultClonePath ; }
    return $null
}

function Get-AccessToken {          # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="For back-compat with v0.1.0, this still supports the deprecated method of using a global variable for storing the Access Token.")]
    [OutputType([String])]
    param(
        [string] $AccessToken
    )

    if (-not [String]::IsNullOrEmpty($AccessToken))
    {
        return $AccessToken
    } 
    $RegPath = Get-GithubModuleRegistryPath
     $Token = (Get-ItemProperty -Path "$RegPath" -Name 'access_token' -ErrorAction Ignore).access_token
     if( $Token -ne $null ) { return $Token  }
     if( $Env:GITHUB_ACCESSTOKEN -ne $null ) { return $Env:GITHUB_ACCESSTOKEN  }
     return $null
}

function Get-GithubServer {          # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $Server = (Get-ItemProperty -Path "$RegPath" -Name 'hostname' -ErrorAction Ignore).hostname
    if( $Server -ne $null ) { return $Server }
     
    if( $Env:GITHUB_SERVER -ne $null ) { return $Env:GITHUB_SERVER  }
    return $null
}

function Get-GitExecutablePath{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $GitPath = (get-command "git.exe" -ErrorAction Ignore).Source
     
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\GitForWindows" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(Test-Path -Path $GitPath){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "$ENV:OrganizationHKCU\Git" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
}

function Get-GHRepositories{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$User
    )
    try{
        $GHX = (Get-Command 'gh.exe').Source
        $Content = &"$GHX" "api" "users/$User/repos"
        $ParsedBuffer=$Content | ConvertFrom-Json 
        return $ParsedBuffer
    } catch {
        Show-ExceptionDetails($_)
    }
}

function Get-RepositoriesFromWeb{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$User,
        [Parameter(Mandatory=$false,Position=1)]
        [System.Management.Automation.PSCredential]$Credential
    )
    try{
        $RepoList = @()

        Write-ChannelMessage "Retrieving repositories for $User......"
        $URL="https://github.com/" + $User + "?tab=repositories"
        if($PSBoundParameters.ContainsKey('Credential')){
            $u=$Credential.UserName
            Write-verbose " using credential [$u]..."
            $Data = (iwr $URL -Credential $Credential)
        }else{
            write-verbose " using DEFAULT credential ..."
            $Data = (iwr $URL )
        }
        
        $SCode = $Data.StatusCode
        $SDesc = $Data.StatusDescription
        if($Data.StatusCode -eq 200){
            $pattern='<a href="/' + $User
            $File = (New-TemporaryFile).Fullname
            Set-Content -Path $File -Value $Data.Content
            $matches=(Select-String -Path $File -Pattern "$pattern" -SimpleMatch -Raw)
            
            $matches | % { $Line = $_ ; 
                $i = $Line.IndexOf("$User") 
                $Line = $Line.SubString($i)
                $ni = $Line.IndexOf('"')
                $Line = $Line.SubString(0,$ni)
                $RepoList += $Line ; 
            }
             $repocount=$RepoList.Length
            Write-verbose "Found $repocount repositories for $User"
            return $RepoList
        }
        throw "HTTP REQUEST RETURNED $SDesc ($SCode)"
    } catch {
        Show-ExceptionDetails($_)
    }
}

function Get-Repositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [string]$User,
         [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Visibility") ]
         [ValidateSet('public','private')]
         [string]$Visibility='private',
         [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
         [switch]$Remote
     )
 
    try{
        $Response = ''
        $Token= Get-GithubAccessToken
        $UserCredz = Get-GithubUserCredentials
        $AppCredz = Get-GithubAppCredentials
        if($UserCredz.UserName -ne $User){
            $Remote = $True
        }

        Write-ChannelMessage "Retrieving repositories for $User......"
        Write-verbose "Retrieving repositories for $User......"
        Write-verbose "GithubAccessToken $Token"
        $headers = @{
            "Content-Type"= "application/x-www-form-urlencoded"
            "Authorization" = $Token
        }

        $RequestUrl = "https://api.github.com/user/repos?sort=updated&direction=desc&per_page=100&visibility=$Visibility" 
        if($Remote){
            $RequestUrl = "https://api.github.com/users/$User/repos?type=all&sort=updated&direction=desc&per_page=100"     
        }
        
        Write-Verbose "IRequestUrl $RequestUrl"

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
        }
        $Params = @{
            Uri             = $RequestUrl
            Body            = $BodyData
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $HeadersData
            Method          = 'GET'
            UseBasicParsing = $true
        }     


        Write-Verbose "Invoke-WebRequest $Params"
        $Response = (Invoke-WebRequest @Params).Content
        $ParsedBuffer = $Response | ConvertFrom-Json

        if($ParsedBuffer -eq $Null){$Null }
        $RepoCount=$ParsedBuffer.Count
        $ret=$ParsedBuffer | select name, private, clone_url, ssh_url, language, updated_at, description
        Write-verbose "ret $ret"
        return $ret
    } catch {
        Show-ExceptionDetails($_) -ShowStack
        return $Null
    }
    return $Null
   
}
function Get-PublicRepositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [string]$User,
         [switch]$Remote
     )
     return Get-Repositories -User $User -Visibility 'public' -Remote:$Remote
 }

function Get-PrivateRepositories {
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Github account username") ]
         [string]$User
     )
     return Get-Repositories -User $User
 }

function Split-RepositoryUrl {
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
        Show-ExceptionDetails($_) -ShowStack
    }
}

function Initialize-Repository {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Repository Path")]
        [Alias('u')] [string] $Url,                
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Force")]
        [Alias('f')] [switch] $Force,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="No logs, clean output")]
        [Alias('q')] [switch] $Quiet 
    )
    try{
        $TmpFile = (New-TemporaryFile).Fullname
        $ShowMessages = $True
        If( $PSBoundParameters.ContainsKey('Quiet') -eq $False ){ $ShowMessages = $False }
        $CurrentPath = (Get-Location).Path

        If( $PSBoundParameters.ContainsKey('Path') -eq $True ){
            if($Force){
                Remove-Item $Path -Recurse -Force -ErrorAction Ignore | out-null 
                New-Item $Path -Force -ErrorAction Ignore | out-null 
            }else{
                if(Test-Path -Path $ModuleBuilderPath -PathType Container){ throw "Destination already exists"; return }
                New-Item $Path -Force -ErrorAction Ignore | out-null 
            }
            
        }else{

        }
        if($ShowMessages) {
             Write-ChannelMessage "CLONING $Url."
        }

        $GitExe = Get-GitExecutablePath
        if($Quiet){
            $stdout_tmp = (New-TemporaryFile).Fullname
             &"$GitExe" clone -j8 --recurse-submodules $Url 1> $stdout_tmp
             Write-Verbose "Logs in $stdout_tmp."
             $log = Get-Content $stdout_tmp -Raw
             Write-Verbose "$log."
        }else{
            
            &"$GitExe" clone -j8 --recurse-submodules $Url     
        }
    } catch {
        Show-ExceptionDetails($_) -ShowStack
        return $False
    }
}



 function Initialize-LocalUserRepository {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Repo URL")]
        [String]$Repository,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Get git output")]
        [Alias('r')] [switch] $Raw,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Launch explorer")]
        [Alias('f')] [switch] $ShowExplorer        
    )
    
    If( $PSBoundParameters.ContainsKey('User') -eq $False ){
        $User = Get-GithubDefaultUsername
        if($User -eq $Null) { throw '"User not specified No Default user configured' }
        Write-Verbose "User not specified, use the default username $User"
    }
    $Url = Resolve-RepositoryUrl -Repository $Repository -User $User
    Write-Verbose "RESOLVE NEW CLONE URL $Url"
    
    Write-ChannelMessage "CLONING URL $Url."

    $TmpFile = (New-TemporaryFile).Fullname
    $GitExe = Get-GitExecutablePath
    try{
        &"$GitExe" clone -j8 --recurse-submodules $Url 1> $TmpFile
        Write-ChannelResult  "Success" 
        if($Raw){
            $log = Get-Content $TmpFile -Raw
            Write-ChannelResult  "$log" 
        }
        if($ShowExplorer){
            $ExplorerExe = (get-command 'explorer.exe').Source
            &$ExplorerExe $Path
        }
    }catch{
        Show-ExceptionDetails($_) -ShowStack
    }
    
}

function Initialize-RepositoryAdvanced {
   [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Full repository Url https or ssh") ]
        [ValidateScript({
            $Uri=[System.Uri]$_
            $Protocol = $Uri.Scheme
            if(($Protocol -ne 'http') -And ($Protocol -ne 'https')){
                throw "Invalid repository. Must be Url starting with http/https"
            }
            
            return $true 
        })]
        [String]$Repository,  
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Local path must exist")]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Alias('p')]
        [String]$Path, 
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, HelpMessage="Quiet mode") ]
        [Alias('q')]
        [switch]$Quiet
    )  
 
    try{
        $Path = (Resolve-Path $Path).Path
        $GitExe = Get-GitExecutablePath
        $HdlProcess =  $null
        $ProcessExitCode = 0
        $ArgumentList = "clone $Repository $Path"
        write-verbose "GitExecutablePath : $GitExe"
        write-verbose "Command Line      : $GitExe $ArgumentList"
        If(( $PSBoundParameters.ContainsKey('Verbose') -eq $True ) -Or ($Quiet -eq $true) ) {
            if($PSCmdlet.ShouldProcess($Repository)){
                $HdlProcess = Start-Process -FilePath $GitExe -ArgumentList $ArgumentList -Wait -NoNewWindow -PassThru
            }
        }else{
            $stdout_tmp = (New-TemporaryFile).Fullname
            $stderr_tmp = (New-TemporaryFile).Fullname
            write-verbose "Redirection StdOut : $stdout_tmp"
            write-verbose "Redirection StdErr : $stderr_tmp"
            if($PSCmdlet.ShouldProcess($Repository)){
                $HdlProcess = Start-Process -FilePath $GitExe -ArgumentList $ArgumentList -Wait -NoNewWindow -RedirectStandardOutput $stdout_tmp -RedirectStandardError $stderr_tmp -PassThru
                write-verbose "WaitForExit..."
                $null=$HdlProcess.WaitForExit();
                $null=$HdlProcess.HasExited();
                $ProcessExitCode = $HdlProcess.ExitCode
                write-verbose "ProcessExitCode $ProcessExitCode" 
            }
        }

        if( ($ProcessExitCode -ne 0) -And ($Quiet -eq $false) ) {
            Write-ChannelResult " ERROR Git exited with status code $ProcessExitCode" -Warning
            throw " ERROR Git exited with status code $ProcessExitCode"
        }

        if($Quiet -eq $false){
            Write-ChannelResult  "Git Clone $Repository"       
        }

    } catch {
        Show-ExceptionDetails($_) -ShowStack
        return $False
    }
    return $true
 }


function Save-Changes{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Alias('m','msg','message','d')]
        [Parameter(Mandatory=$false)]
        [string]$Description = 'automatic-commit'
    )
  

    $Dir=(Get-Location).Path
    Write-Host "git: commit and push from " -f DarkCyan -NoNewLine
    Write-Host "$Dir" -f DarkRed

    $CommitMessage='"'+$Description+'"'
    $GitExe = Get-GitExecutablePath

    &"$GitExe" commit -a -m "$CommitMessage"
}




function Sync-UserRepositories
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Github account username") ]
        [string]$User,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Local path (must exist)") ]
        [String]$Path,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Host name in case user has multiple git accounts setup") ]
        [string]$HostName="github.com",
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Force clone (attempt) even if connection test fails") ]
        [switch]$Force,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Host name in case user has multiple git accounts setup") ]
        [array]$Exceptions
    )  

    try{

        [string]$Protocol="HTTPS"
        [int]$Port=443
        $TestOnly = $false
        If($PSBoundParameters.ContainsKey('WhatIf') -eq $True ){
            $TestOnly = $true
            write-verbose "-WhatIf: Test Only"
        }
        # Action based on the choice (removed ssh support)
        <#
        switch($Protocol){
            'SSH' {
                Write-Host -ForegroundColor DarkRed "[GIT] " -NoNewline 
                Write-Host "SSH - Cloning using SSH"  -ForegroundColor Yellow
                $Port=22
            }
            'HTTPS' {
                Write-Host -ForegroundColor DarkRed "[GIT] " -NoNewline 
                Write-Host "HTTPS - Cloning using HTTPS"  -ForegroundColor Yellow
                $Port=443
            }
        }#>

        $connection_success = Test-Connection -TargetName $HostName -IPv4 -TcpPort $Port -EA Ignore
        if(($connection_success -eq $false) -And ($Force -eq $false)){
            throw "Cannot connect to $HostName on port $Port"
        }

        $reposdata=Get-PublicRepositories -User $User -Remote
        if($reposdata -eq $null){
            Write-Host "[ERROR] " -n -f DarkRed
            Write-Host "Failed to get repo data for user $User MAY BE INVALID USER" -f DarkYellow
            Write-Host "try gh api users/$User/repos" -f DarkGray
            return $Null
        }

        if( $PSBoundParameters.ContainsKey('Path') -eq $False ){
            $DefaultPath = Get-GithubDefaultClonePath
            $Path = Join-Path $DefaultPath $User
          
        }
        if(Test-Path $Path -PathType Container){
            $childs= gci -Path $Path -recurse
            if($childs -ne $null) { throw "Path $Path already exist, and not empty" }
        }
        $Dir = New-Directory $Path
        if(-not $Dir) { throw "Error" }

        $ErrorsCount = 0
        $Script:ProgressTitle = "Clonig repositories from $User"
        $Script:StepNumber = 0
        $Script:TotalSteps = $reposdata.Count
        pushd $Path
        $reposdata.ForEach({
            $Name=$_.name
            $Desc=$_.description
            $Url=$_.clone_url
            write-verbose "Name: $Name"
            write-verbose "Desc: $Desc"
            write-verbose "Url: $Url" 

            If($PSBoundParameters.ContainsKey('Exceptions') -eq $True ){
                
                ForEach($exc in $Exceptions){
                    if($exc -match $Name){
                        Write-ChannelResult "$Name EXCEPTION REPO!" -Warning 
                        continue
                    }    
                }
                
            }


            $Script:ProgressMessage="Cloning $Url ($Script:StepNumber of $Script:TotalSteps)"
            Write-Host  "[GIT] " -NoNewline -ForegroundColor DarkRed
            Write-Host "$Script:ProgressMessage" -f DarkGray            
            $WhatIfValue = $False
            If($PSBoundParameters.ContainsKey('WhatIf') -eq $True ){  $WhatIfValue = $True }

            $res=Initialize-Repository -Url $Url -Quiet

            if($res -eq $false){
                throw " $Name clone error "
            }
            AutoUpdateProgress
            
        })
        popd
        Write-Progress -Activity $Script:ProgressTitle -Completed 
        if($ErrorsCount -eq 0){
            Write-Host  "[DONE]`t" -NoNewline -ForegroundColor DarkGreen
            Write-Host "$ErrorsCount errors." -f DarkGray
            $ExplorerExe = (get-command 'explorer.exe').Source
            &$ExplorerExe $Path
        }else{
            Write-Host  "[DONE]`t" -NoNewline -ForegroundColor Red
            Write-Host "$ErrorsCount errors." -f DarkYellow
            $ExplorerExe = (get-command 'explorer.exe').Source
            &$ExplorerExe $Path
        }
     } catch {
        Show-ExceptionDetails($_) -ShowStack
    }
}


function Push-Changes {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$DeployPath,
        [Alias('m','msg','message','d')]
        [Parameter(Mandatory=$false)]
        [string]$Description = 'automatic-commit'
    )
    
    $GitExe = Get-GitExecutablePath
    If($PSBoundParameters.ContainsKey('DeployPath') -eq $False ){
        $CurrentPath = (Get-Location).Path
    }else{
        pushd $DeployPath
    }

    Write-ChannelMessage  " adding files in the repository."
    Write-ChannelMessage  " From $DeployPath" 
    &"$GitExe" add *

    Get-Status
    Write-ChannelMessage " commiting files in the repository. please wait......"
    Write-ChannelMessage "Description $Description"
    &"$GitExe" commit -a -m "$Description"

    Write-ChannelMessage " pushing changes..."
    &"$GitExe" push (Get-GithubUrl -Authenticated)

    popd
 }

 function Get-Status {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false)]
        [switch]$Raw
    )
    $Modified = [System.Collections.ArrayList]::new()
    $Added = [System.Collections.ArrayList]::new()
    $Deleted = [System.Collections.ArrayList]::new()

    $TmpFile = (New-TemporaryFile).Fullname
    $Dirty = $False
    $Clean = $True
    $AnchorClean='nothing to commit, working tree clean'
    $AnchorChange='Changes to be committed:'
    Write-ChannelMessage "Git Status"
    $GitExe = Get-GitExecutablePath
    if($Raw){
        &"$GitExe" status
        return
    }
    $Result = &"$GitExe" status 2> $TmpFile
    $ntc=($Result -match $AnchorClean) ; if($ntc -eq $AnchorClean) {$Clean = $True;$Dirty = $False}
    $ntc=($Result -match $AnchorChange) ; if($ntc -eq $AnchorChange) {$Clean = $False;$Dirty = $True}
    if($Clean){ Write-ChannelResult "$AnchorClean"  ; return }
    if($Dirty){
        
         $Mods=($Result | select-string 'modified' -Raw -List)
         ForEach($file in $Mods){
            $i = $file.LastIndexOf(' ') + 1
            $f=$file.Substring($i).Trim()
            $Modified.Add($f) | Out-null
         }
    
         $adds=($Result | select-string 'new file' -Raw -List)
         ForEach($file in $adds){
            $i = $file.LastIndexOf(' ') + 1
            $f=$file.Substring($i).Trim()
            $Added.Add($f) | Out-null
         }
         
         $dels=($Result | select-string 'deleted' -Raw -List)
         ForEach($file in $dels){
            $i = $file.LastIndexOf(' ') + 1
            $f=$file.Substring($i).Trim()
            $Deleted.Add($f) | Out-null
         }         
    }

    if($Modified.Count){
        
        Write-Host "`nModified files" -f DarkCyan
        $Modified.ForEach({ Write-Host "`t | $_" -n -f DarkCyan })   
    }

    if($Added.Count){
        
        Write-Host "`nAdded files" -f DarkGreen    
        $Added.ForEach({ Write-Host "`t | $_" -n -f DarkGreen })        
    }
    
    if($Deleted.Count){
       
        Write-Host "`nDeleted files" -f DarkRed     
        $Deleted.ForEach({ Write-Host "`t | $_" -n -f DarkRed })        
    }
}

 function Show-Diff{

    Write-ChannelMessage "Diff"
    $GitExe = Get-GitExecutablePath
    &"$GitExe" difftool
}


function Get-Latest {
   [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Submodules") ]
        [switch]$Recurse
    )
    $Directory = Get-ScriptDirectory
    $Repository = (Get-Item $Directory).Name
    

    $GitExe = Get-GitExecutablePath

    if($Recurse){
        
        Write-ChannelMessage "Pulling Latest code for $Repository and all sub modules..." 
        &"$GitExe"  pull --recurse
       
        Write-ChannelMessage "Rebasing all sub modules..." 
        &"$GitExe"  submodule update --remote --rebase
    }else{
       
        Write-ChannelMessage "Pulling Latest code for $Repository"
        &"$GitExe"  pull
    }
   
    Write-ChannelMessage "Operation completed"  
}

function Resolve-RepositoryUrl {
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


function New-SubModule {
   [CmdletBinding(SupportsShouldProcess)]
    Param
    (
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
        [Alias('u')] [string]$Url
    ) 

    $Url = Resolve-RepositoryUrl -Repository $Url -User 'arsscriptum'
   
    
    $stdout_tmp = (New-TemporaryFile).Fullname

    try{
        $SplitUrl = Split-RepositoryUrl -Url $Url
        $NewPath = (Get-Location).Path + '\' + $SplitUrl.Basename
        $GitExe = Get-GitExecutablePath
        Write-ChannelMessage "Add submodule from $Url"
        &"$GitExe" submodule add $Url 1> $stdout_tmp
        $Mod = (gci $NewPath -Recurse -File)
        $ModCount = $Mod.Count
        Write-ChannelResult " clone complete $ModCount files"
         Write-ChannelMessage "Cloning sub modules"
        &"$GitExe" submodule update --init --recursive 1>> $stdout_tmp

         Write-ChannelResult "lgs are in $stdout_tmp"

    } catch {
        Show-ExceptionDetails($_) -ShowStack
    }
 
}

function New-Repository {
     param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository name") ]
        [string]$Name,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="The repository description") ]
        [string]$Description = "",        
        [switch]$Public      
     )
 
    try{
        $GhExe = (Get-Command gh.exe).Source
        $ExpExe = (Get-Command explorer.exe).Source
        $CurrentPath = (Get-Location).Path
        $NewPath = Join-Path $CurrentPath $Name
        $DateStr = (get-date).GetDateTimeFormats()[6]
        $me = whoami
        if($Description -eq ''){
            $Description = "Repository $Name created on $DateStr by $me"
        }
        if($Public){
            &"$GhExe" repo create $Name --public --clone --disable-wiki --disable-issues --description "$Description"
        }else{
            &"$GhExe" repo create $Name --private --clone --disable-wiki --disable-issues --description "$Description"
        }
        &"$ExpExe" $NewPath
    }
    catch{
         Show-ExceptionDetails($_) -ShowStack
    }
}
 

function New-GitHubRepository {     # NOEXPORT
     param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository name") ]
        [string]$Name,
        [switch]$Private,
        #write full native response to the pipeline
        [switch]$Raw        
     )
 
    try{
        $Response = ''
        $AccessToken= Get-GithubAccessToken
        $Token= Get-GithubAccessToken

        Write-ChannelMessage "Creating New Repository $Name => Private $Private"
        Write-verbose "GithubAccessToken $Token"
        $privateStr = 'false'
        if($Private) {$privateStr = 'true' }
        
        $AcceptHeader = 'application/vnd.github.v3+json'
        $ContentType= "application/json"
        # 'Accept' = $AcceptHeader
        $headers = @{
                'User-Agent' = 'PowerShell'
        }
        $headers['Authorization'] = "token $AccessToken"
        $headers.Add("Content-Type", $ContentType)
        $hashBody = @{
            'name' = $Name
            'description' = 'New Repo'
        }

        $Private = $True
        #if ($PSBoundParameters.ContainsKey('Private')) { $hashBody['private'] = $Private.ToBool() }
        $hashBody['private'] = $Private.ToBool()
        $RequestUrl = "https://api.github.com/user/repos" 
        $body = $hashBody | ConvertTo-Json
        #define parameter hashtable for Invoke-RestMethod
        $paramHash = @{
            Uri = "https://api.github.com/user/repos" 
            Method = "Post"
            body = $body 
            ContentType = "application/json"
            Headers = $headers
            UseBasicParsing = $True
            DisableKeepAlive = $True
        }

        $ParamStr = $paramHash.ToString()

        #should process
   
        $r = Invoke-RestMethod @paramHash

        if ($r.id -AND $Raw) {
            Write-Verbose "[PROCESS] Raw result"
            $r

        } elseif ($r.id) {
            write-Verbose "[PROCESS] Formatted results"

            $r | Select-Object @{Name = "Name";Expression = {$_.name}},
            @{Name = "Description";Expression = {$_.description}},
            @{Name = "Private";Expression = {$_.private}},
            @{Name = "Issues";Expression = {$_.has_issues}},
            @{Name = "Wiki";Expression = {$_.has_wiki}},
            @{Name = "URL";Expression = {$_.html_url}},
            @{Name = "Clone";Expression = {$_.clone_url}}
        } else {
            
            Write-Warning "Something went wrong with this process"
        }

        if ($r.clone_url) {
          $msg = @"

To push an existing local repository to Github run these commands:
-> git remote add origin $($r.clone_url)"
-> git push -u origin master

"@
            Write-Host $msg -ForegroundColor Blue

        }
        

        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"

    }catch
    {
        $ex = $null
        $message = $null
        $statusCode = $null
        $statusDescription = $null
        $requestId = $null
        $innerMessage = $null
        $rawContent = $null

        if ($_.Exception -is [System.Net.WebException])
        {
            $ex = $_.Exception
            $message = $_.Exception.Message
            $statusCode = $ex.Response.StatusCode.value__ # Note that value__ is not a typo.
            $statusDescription = $ex.Response.StatusDescription
            $innerMessage = $_.ErrorDetails.Message
            try
            {
                $rawContent = Get-HttpWebResponseContent -WebResponse $ex.Response
            }
            catch
            {
                Write-Host "Unable to retrieve the raw HTTP Web Response: $_" 
            }

            if ($ex.Response.Headers.Count -gt 0)
            {
                $requestId = $ex.Response.Headers['X-GitHub-Request-Id']
            }
        }
        else
        {
            $ex = $_.Exception
            $message = $_.Exception.Message
            $innerMessage = $_.ErrorDetails.Message

            if (-not [string]::IsNullOrEmpty($innerMessage))
            {
                 $innerMessageJson = ($innerMessage | ConvertFrom-Json)
                if ($innerMessageJson -is [String])
                {
                    $output += $innerMessageJson.Trim()
                }
                elseif (-not [String]::IsNullOrWhiteSpace($innerMessageJson.message))
                {
                    $innerMessageJson
                    $output += "$($innerMessageJson.message.Trim()) | $($innerMessageJson.documentation_url.Trim())"
                    if ($innerMessageJson.errors)
                    {
                        $output += "$($innerMessageJson.errors | Format-Table | Out-String)"
                    }
                }
                else
                {
                    # In this case, it's probably not a normal message from the API
                    $output += ($innerMessageJson | Out-String)
                }
            }
        
            Write-Host "[ERROR] " -f DarkRed -NoNewLine
            Write-Host "message $message" -f DarkYellow
            Write-Host "[ERROR] " -f DarkRed -NoNewLine
            Write-Host "$output" -f DarkYellow

            return $null
        }
    }
 }  


function Remove-Repository {
     param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository name, including the username like arsscriptum/ProcessTest") ]
        [string]$Name,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="no question") ]
        [switch]$Force       
     )
 
    try{
        $Response = ''
        $AccessToken= Get-GithubAccessToken
        $Token= Get-GithubAccessToken

        Write-verbose "GithubAccessToken $Token"
        Write-ChannelMessage "Delete Git HubRepository : $Name"

        if($Force -eq $False){
            Write-Host -ForegroundColor DarkRed "[CONFIRMATION 1] " -NoNewline
            $a=Read-Host -Prompt "DELETING REPOSITORY $Name ! Are you sure (y/N)?" ; if($a -notmatch "y") {return;}
             Write-Host -ForegroundColor DarkRed "[CONFIRMATION 2] " -NoNewline
            $a=Read-Host -Prompt "Type in the repository name again:" ; if($a -ne "$Name") {
                Write-ChannelResult "EXITED" -Warning
                return;
            }
        }

        $AcceptHeader = 'application/vnd.github.v3+json'
        $ContentType= "application/json"
        $headers = @{
            'User-Agent' = 'PowerShell'
        }
        $headers['Authorization'] = "token $AccessToken"
        $headers.Add("Content-Type", $ContentType)
        $hashBody = @{
            'name' = $Name
        }

        $RequestUrl = "https://api.github.com/repos/$Name"
        $body = $hashBody | ConvertTo-Json
        #define parameter hashtable for Invoke-RestMethod
        $paramHash = @{
            Uri =  "https://api.github.com/repos/$Name"
            Method = "DELETE"
            body = $body 
            ContentType = "application/json"
            Headers = $headers
            UseBasicParsing = $True
            DisableKeepAlive = $True
        }
        $ParamStr = $paramHash.ToString()
        #should process
        $r = Invoke-RestMethod @paramHash
        Write-ChannelResult "DELETED $Name"

    }catch{
        Write-Host "[ERROR] " -f DarkRed -NoNewLine
        Write-Host "message $_" -f DarkYellow
    }
 } 




function Set-RepositoryVisibility {
     param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository name") ]
        [string]$Name,      
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository visibility") ]
        [ValidateSet('public','private')]
        [string]$Visibility         
     )
 
    try{
        $GhExe = (Get-Command gh.exe).Source
        $result = &"$GhExe" "api" "-X" "PATCH" "/repos/arsscriptum/$Name" "-fvisibility=$Visibility" "--preview" "nebula"
        $Obj = $result | ConvertFrom-Json
        $vis = $Obj.visibility
        $url = $Obj.html_url
        $des = $Obj.description
        $fna = $Obj.full_name
        Write-Host "[set visibility] " -n -f DarkRed ; Write-Host "$vis" -f DarkYellow
        Write-Host "[set visibility] " -n -f DarkRed ; Write-Host "$url" -f DarkYellow
        Write-Host "[set visibility] " -n -f DarkRed ; Write-Host "$des" -f DarkYellow
        Write-Host "[set visibility] " -n -f DarkRed ; Write-Host "$fna" -f DarkYellow
    }
    catch{
         Show-ExceptionDetails($_) -ShowStack
    }
}
  
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNLK7LsMWeWphOFoAofNmQG/d
# 6lCgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUsuyr2wHYDAVID24liutG
# B7jokqwwDQYJKoZIhvcNAQEBBQAEggEAZxyCnUW17cCylqSjSmQrhYqiYklmVMrL
# jwxdyz2u5M51Sxuudyla0vUQaQ9z/wzkr+jSp3yryxSIqwyA5Ksn7jFO2lSgLpbS
# kq2OzlXyi2jjtjDikpL+atKh/4WlCvl26GS4kjqsrOkrlD8ZfXlYyzMtpl4uAQnL
# ECxzxhY7Kn3G5ECjroDHMmK4WoxGK/Hb9YQxrA+4kxng9kbeWkCsCGg+Ir9fQldt
# ZB+OLHaNT4XpSDrRt040nkQD1/8Xzqa6TMr/w8+Z4b8GSzPQ4H15p4Sb4nlhNo1N
# mnK8X4UFwzzzOE9gneEXELwRTdGTubIZdMXu2lpYQWpwvsrA8rWp0g==
# SIG # End signature block
