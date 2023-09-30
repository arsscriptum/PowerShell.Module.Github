<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-GithubRepoViewsStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false, HelpMessage="per day/week")]
        [ValidateSet('day','week')]
        [String]$Per='day'
    )   
 
        $UserCredz = Get-GithubUserCredentials
        $AppCredz  = Get-GithubAppCredentials
        [String]$Url =  'https://api.github.com/repos/{0}/{1}/traffic/views?Per={2}' -f ($UserCredz.UserName),$Repository,$Per
 
        $AuStr = 'bearer ' + (Get-GithubAccessToken)
        $Params = @{
            Uri             = $Url
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
                "X-GitHub-Api-Version" = "2022-11-28"
                "Accept" = "application/vnd.github+json" 
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}



function Get-GithubCloneStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false, HelpMessage="per day/week")]
        [ValidateSet('day','week')]
        [String]$Per='day'
    )   
 
        $UserCredz = Get-GithubUserCredentials
        $AppCredz  = Get-GithubAppCredentials
        [String]$Url =  'https://api.github.com/repos/{0}/{1}/traffic/clones?Per={2}' -f ($UserCredz.UserName),$Repository,$Per
        $AuStr = 'bearer ' + (Get-GithubAccessToken)
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
                "X-GitHub-Api-Version" = "2022-11-28"
                "Accept" = "application/vnd.github+json" 
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}


function Get-GithubRepoTopReferralPaths{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false, HelpMessage="per day/week")]
        [ValidateSet('day','week')]
        [String]$Per='day'
    )   
 
        $UserCredz = Get-GithubUserCredentials
        $AppCredz  = Get-GithubAppCredentials
        [String]$Url =  'https://api.github.com/repos/{0}/{1}/traffic/popular/paths?Per={2}' -f ($UserCredz.UserName),$Repository,$Per
        $AuStr = 'bearer ' + (Get-GithubAccessToken)
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
                "X-GitHub-Api-Version" = "2022-11-28"
                "Accept" = "application/vnd.github+json" 
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}


function Get-GithubRepoTopReferralSources{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false, HelpMessage="per day/week")]
        [ValidateSet('day','week')]
        [String]$Per='day'
    )   
 
        $UserCredz = Get-GithubUserCredentials
        $AppCredz  = Get-GithubAppCredentials
        [String]$Url =  'https://api.github.com/repos/{0}/{1}/traffic/popular/referrers' -f ($UserCredz.UserName),$Repository,$Per
        $AuStr = 'bearer ' + (Get-GithubAccessToken)
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = @{
                Authorization = $AuStr
                "X-GitHub-Api-Version" = "2022-11-28"
                "Accept" = "application/vnd.github+json" 
            }
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}



function Save-GithubRepoStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository
    )    
    try{
        $NewFile = $False
        $Path = '{0}\STATS-{1}.{2}' -f (Get-StatsPath), $Repository, "json"
        if(!(Test-Path $Path)){
            $NewFile = $True
        }

        $d = (Get-Date).AddDays(-1)

        $views_stats = Get-GithubRepoViewsStats -Repository "$Repository" -Per week | Select  -ExpandProperty views 
        $clone_stats = Get-GithubCloneStats -Repository "$Repository" -Per week | Select  -ExpandProperty clones 
        [uint32]$UniquesViewsSum = $views_stats | Select -ExpandProperty uniques |  Measure-Object -Sum | Select  -ExpandProperty Sum
        [uint32]$ViewsCountSum = $views_stats | Select -ExpandProperty count |  Measure-Object -Sum | Select  -ExpandProperty Sum
        [uint32]$UniquesClonesSum = $clone_stats | Select -ExpandProperty uniques | Measure-Object -Sum  | Select  -ExpandProperty Sum
        [uint32]$ClonesCountSum = $clone_stats | Select -ExpandProperty count | Measure-Object -Sum  | Select  -ExpandProperty Sum
        [uint32]$views_stats_entries =  $views_stats | Measure-Object  | Select  -ExpandProperty count
        [uint32]$clone_stats_entries =  $clone_stats | Measure-Object  | Select  -ExpandProperty count
        $DateStr = (Get-Date)
        [pscustomobject]$o = [pscustomobject]@{
            UniquesViews = $UniquesViewsSum
            ViewsCount = $ViewsCountSum
            UniquesClones  = $UniquesClonesSum
            ClonesCount  = $ClonesCountSum
            ClonesEntries = $clone_stats_entries
            ViewsEntries = $views_stats_entries
            Repository = "$Repository"
            SampleDate = "$DateStr"
        }
        
        if($NewFile){
            $Json = $o | ConvertTo-Json 
            Set-Content -Path $Path -Value $Json
        }else{
            [PsCustomObject[]]$Stats = Get-Content -Path $Path | ConvertFrom-Json
            $Stats += $o
            $Json = $Stats | ConvertTo-Json 
            Set-Content -Path $Path -Value $Json
        }
        

    }catch{
        Write-Error "$_"
    }
}

function Get-GithubRepoStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false)]
        [int]$Sample=-1
    )     
    try{
        $Path = '{0}\STATS-{1}.{2}' -f (Get-StatsPath), $Repository, "json"
        if(!(Test-Path $Path)){
            throw "no file $Path"
        }

        $Stats = Get-Content -Path $Path | ConvertFrom-Json
        if($Sample -lt 0){
            $RetStats = $Stats[($Stats.Count) + $Sample]
        }else{
            $RetStats = $Stats[$Sample]
        }
        $RetStats
    }catch{
        Write-Error "$_"
    }
}

function Save-GithubSupportStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Save-GithubRepoStats -Repository "PowerShell.Reddit.Support"
    }catch{
        Write-Error "$_"
    }
}


function Get-GithubSupportStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Get-GithubRepoStats -Repository "PowerShell.Reddit.Support"
    }catch{
        Write-Error "$_"
    }
}


function Save-GithubPagesStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Save-GithubRepoStats -Repository "arsscriptum.github.io"
    }catch{
        Write-Error "$_"
    }
}


function Get-GithubPagesStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Get-GithubRepoStats -Repository "arsscriptum.github.io"
    }catch{
        Write-Error "$_"
    }
}


function Get-GithubRedditSupportStats{
    [CmdletBinding(SupportsShouldProcess)]
        param(
        [Parameter(Mandatory=$false, HelpMessage="days")]
        [int]$Days=30
    )
        $d = (Get-Date).AddDays(-$Days)
        
        $Time = "{0} - {1}" -f ($d.GetDateTimeFormats()[15]),((Get-Date).GetDateTimeFormats()[15])
        
        $SumUniqueClones = 0
        $TotalClonesCount = 0
        $c = Get-GithubCloneStats -Repository "PowerShell.Reddit.Support" -Per week
        $stats = $c.clones | where timestamp -gt $d 
        $stats | % {
            $o = $_
            $SumUniqueClones += $o.uniques
            $TotalClonesCount += $o.count
        }
  
        $SumUniqueViews = 0
        $TotalViewsCount = 0
        $c = Get-GithubRepoViewsStats -Repository "PowerShell.Reddit.Support" -Per week
        $stats = $c.views | where timestamp -gt $d
        $stats | % {
            $o = $_
            $SumUniqueViews += $o.uniques
            $TotalViewsCount += $o.count
        }
        $UniquesViews = $stats.uniques
        $ViewsCount = $stats.count
        $o = [PsCustomObject]@{
            UniquesViews = $SumUniqueViews
            ViewsCount = $TotalViewsCount
            UniquesClones = $SumUniqueClones
            ClonesCount = $TotalClonesCount
            Time = $Time
        }
        $o | ft
}


function Get-GithubPagesStats{
    [CmdletBinding(SupportsShouldProcess)]
        param(
        [Parameter(Mandatory=$false, HelpMessage="days")]
        [int]$Days=30
    )
        $d = (Get-Date).AddDays(-$Days)
        
        $Time = "{0} - {1}" -f ($d.GetDateTimeFormats()[15]),((Get-Date).GetDateTimeFormats()[15])
        
        $SumUniqueClones = 0
        $TotalClonesCount = 0
        $c = Get-GithubCloneStats -Repository "arsscriptum.github.io" -Per week
        $stats = $c.clones | where timestamp -gt $d 
        $stats | % {
            $o = $_
            $SumUniqueClones += $o.uniques
            $TotalClonesCount += $o.count
        }
  
        $SumUniqueViews = 0
        $TotalViewsCount = 0
        $c = Get-GithubRepoViewsStats -Repository "arsscriptum.github.io" -Per week
        $stats = $c.views | where timestamp -gt $d
        $stats | % {
            $o = $_
            $SumUniqueViews += $o.uniques
            $TotalViewsCount += $o.count
        }
        $UniquesViews = $stats.uniques
        $ViewsCount = $stats.count
        $o = [PsCustomObject]@{
            UniquesViews = $SumUniqueViews
            ViewsCount = $TotalViewsCount
            UniquesClones = $SumUniqueClones
            ClonesCount = $TotalClonesCount
            Time = $Time
        }
        $o | ft
}



function Get-GithubSavedStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [int]$Sample=-1
    )
        try{
            $LastUpdateTime= Get-Date
            [System.Collections.ArrayList]$data = [System.Collections.ArrayList]::new()
            $pub = Get-PublicRepositories -Username "arsscriptum" | Select -ExpandProperty name
            ForEach($p in $pub){
                $stats = get-GithubRepoStats -Repository "$p" -Sample $Sample
               
                [uint32]$UniquesViewsSum = $stats | Select -ExpandProperty UniquesViews
                [uint32]$ViewsCountSum =  $stats | Select -ExpandProperty ViewsCount
                [uint32]$UniquesClonesSum =  $stats | Select -ExpandProperty UniquesClones
                [uint32]$ClonesCountSum =  $stats | Select -ExpandProperty ClonesCount
                [uint32]$ClonesEntries =   $stats | Select -ExpandProperty ClonesEntries
                [uint32]$ViewsEntries =   $stats | Select -ExpandProperty ViewsEntries
                $SampleDate =   $stats | Select -ExpandProperty SampleDate
                    [pscustomobject]$new = [pscustomobject]@{
                        UniquesViews = $UniquesViewsSum
                        ViewsCount = $ViewsCountSum
                        UniquesClones  = $UniquesClonesSum
                        ClonesCount  = $ClonesCountSum
                        ViewsEntries = $ViewsEntries
                        ClonesEntries = $ClonesEntries
                        Repository = "$p"
                        SampleDate = "$SampleDate"
                    }
                    [void]$data.Add($new)
            }
                
            $data
        }catch{
            Write-Output "$_"
    }
}



function Update-GithubSavedStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()
        try{
            
            $pub = Get-PublicRepositories -Username "arsscriptum" | Select -ExpandProperty name
            $count = $pub.Count
            $index = 1
            $status =  "Updating Stats {0}%" -f 1
            Write-Progress -Activity "STATS" -Status $status -PercentComplete 1
            ForEach($p in $pub){
                $index++
                $raw_percentage = ($index/$count)*100
                $percentage = [math]::Round($raw_percentage)
                if($percentage -gt 100){$percentage = 100}
                $status =  "Updating `"$p`""
                $statuslen = $status.Length
                $status = Get-PaddedString -String $status -Size 45
                $status = "{0} {1}%" -f $status,$percentage
                Write-Progress -Activity "STATS" -Status $status -PercentComplete $percentage
                Save-GithubRepoStats -Repository "$p"
            }
            Write-Progress -Activity "STATS" -Completed
            Get-GithubSavedStats
        }catch{
            Write-Output "$_"
    }
}



function Get-GithubAllSavedStats{
    [CmdletBinding(SupportsShouldProcess)]
    param()
        try{
            
            Get-GithubSavedStats | sort -Property UniquesClones -Descending | Select Repository,UniquesClones,UniquesViews,SampleDate
        }catch{
            Write-Output "$_"
    }
}

