
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>




function New-GitHubRepository {  # NOEXPORT
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

        Write-Log "Creating New Repository $Name => Private $Private"
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


 


function Invoke-AutoUpdateProgress_CloneUser{
    [int32]$PercentComplete = (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($PercentComplete -gt 100){$PercentComplete = 100}
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete $PercentComplete
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}

function Sync-UserRepositories {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true, 
            HelpMessage="Username or owner of the repositories you want to clone")]
        [Alias('u', 'usr')]
        [String]$Username,
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true, 
            HelpMessage="Destination directory")]
        [Alias('d', 'dst')]
        [String]$DestinationPath,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="If set, this flag will make it so that a root folder will be created (named after the user to clone), under which the repositories will be cloned")]
        [Alias('c')]
        [switch]$CreateRootFolder,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Simulation: dont clone, just list the operations to do and repositories to clone (equivalent to -WhatIf)")]
        [Alias('l')]
        [switch]$ListOnly,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Overwrite existing directories")]
        [Alias('f')]
        [switch]$Force,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Open file explorer after download")]
        [Alias('o')]
        [switch]$OpenAfterDownload,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Less outputs")]
        [Alias('q')]
        [switch]$Quiet
    )

    try{

        if($ListOnly){
            Write-Verbose "ListOnly         : Setting WHATIF"
            $WhatIf = $True
        }
        if($WhatIf){
            $ListOnly = $True
        }

        Write-Verbose "Username         : $Username"
        Write-Verbose "DestinationPath  : $DestinationPath"
        Write-Verbose "CreateRootFolder : $CreateRootFolder"

        $ClonePath = $DestinationPath

        if($CreateRootFolder){
            $ClonePath = Join-Path $DestinationPath $Username

            if($Force){
                Write-Verbose "Force : deleting $ClonePath"
                Remove-Item -Path $ClonePath -Recurse -Force -ErrorAction Ignore -WhatIf:$ListOnly | Out-Null
            }
            if(Test-Path $ClonePath -PathType Container -ErrorAction Ignore){
                throw "`"$DestinationPath`" already contains a folder named `"$Username`""
            }

            Write-Verbose "Creating Root folder: $ClonePath"
            
            New-Item -Path $ClonePath -ItemType directory -Force -WhatIf:$ListOnly -ErrorAction Ignore | Out-Null
        }
        $LogFile = New-RandomFilename

        # Get all the repositories we want to clone
        $RepoList = Get-PublicRepositories -Username $Username
        if(-not $RepoList){
            throw "No repository found for user $Username"
        }

        $GitExe = Get-GitExecutablePath
        if(-not(Test-Path $GitExe -PathType Leaf -ErrorAction Ignore)){
            throw "`"$GitExe`" not found"
        } 
        $Script:ProgressTitle = "STATE: CLONE USER $Username"
        $TotalTicks = 0
        $TotalBytes = 0
        $Script:TotalSteps = $RepoList.Count
        Write-verbose "Found $RepoCount repositories for $Username"
        $SyncStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
        ForEach($Repo in $RepoList){

            $CloneUrl = $Repo.clone_url
            $RepoName = $Repo.name
            $Description = $Repo.description

            $RepoClonePath = Join-Path $ClonePath $RepoName

            write-verbose "Cloning $RepoName in `"$RepoClonePath`""
            Write-Verbose "`"$GitExe`" 'clone' '--recurse-submodules' '-j8' `"$CloneUrl`" `"$RepoClonePath`""

            
            if($WhatIf){
                Start-Sleep -Millisecond 5
                continue;
            }

            if($Quiet){
                &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$CloneUrl" "$RepoClonePath" *> $LogFile
            }else{
                &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$CloneUrl" "$RepoClonePath"
            }  
            [timespan]$ts =  $SyncStopWatch.Elapsed
            $TotalTicks += $ts.Ticks 
 
            $RepoBytes = (Get-FolderSize "$RepoClonePath" | Select TotalBytes | select -First 1)
            $TotalBytes += $RepoBytes.TotalBytes
            $SizeStr = Convert-Bytes $RepoBytes.TotalBytes -Format MB
            $TotalBytesStr = Convert-Bytes $TotalBytes -Format MB
            $Script:ProgressMessage = "Cloned {0} of {1} repositories in {2:mm:ss}. Last {3}, Total {4}" -f $Script:StepNumber, $Script:TotalSteps, ([datetime]$TotalTicks), $SizeStr, $TotalBytesStr
            Invoke-AutoUpdateProgress_CloneUser
            
            if($ts.Ticks -gt 0){
                $ElapsedTimeStr = "`"$RepoName`" cloned in {0:mm:ss}" -f ([datetime]$TotalTicks)
            }

            Write-Verbose "$ElapsedTimeStr"
        }

        $Title = "OPERATION COMPLETED"
        $Message = "Sync Complete for $Username to $ClonePath"
        $IconPath = Get-ToolsModuleDownloadIconPath
        Show-SystemTrayNotification $Message $Title $IconPath
     
       
        if($OpenAfterDownload){
            $ExplorerPath = 'C:\Windows\explorer.exe'
            &"$ExplorerPath" "$ClonePath"
        }


    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}
