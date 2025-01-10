<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-GhStatsViews{
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
 
        $hearderz = Get-GithubAuthorizationHeader
        $Params = @{
            Uri             = $Url
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $hearderz
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}

function Get-GhStatsCodeFrequency{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository
    )   
 
        $UserCredz = Get-GithubUserCredentials
        $AppCredz  = Get-GithubAppCredentials
        [String]$Url =  'https://api.github.com/repos/{0}/{1}/stats/code_frequency' -f ($UserCredz.UserName),$Repository
        $hearderz = Get-GithubAuthorizationHeader
        
        $Params = @{
            Uri             = $Url
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $hearderz
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Data = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         
         [pscustomobject]$res = [pscustomobject]@{
            Timestamp  = $Data[0]
            Additions  = $Data[1]          
            Deletions  = $Data[2]
        }
         $res
}


function Get-GhStatsClones{
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
        $hearderz = Get-GithubAuthorizationHeader
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $hearderz
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}


function Get-GhStatsMostPopular{
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
        $hearderz = Get-GithubAuthorizationHeader
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $hearderz
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}


function Get-GhStatsTopReferrals{
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
        $hearderz = Get-GithubAuthorizationHeader
        $Params = @{
            Uri             = $Url
    
            UserAgent       = Get-GithubModuleUserAgent
            Headers         = $hearderz
            Method          = 'GET'
            UseBasicParsing = $true
        }      

         $Response = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json  
         $Response
         Write-Verbose "Invoke-WebRequest Response: $Response"
}



function Save-GhStatsRepository{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository,
        [Parameter(Mandatory=$false, HelpMessage="per day/week")]
        [ValidateSet('day','week')]
        [String]$Per='day'
    )    
    try{
        $NewFile = $False
        $Path = '{0}\STATS-{1}.{2}' -f (Get-StatsPath), $Repository, "json"
        if(!(Test-Path $Path)){
            $NewFile = $True
        }
        $d = (Get-Date).AddDays(-1)
        $views_stats = Get-GhStatsViews -Repository "$Repository" -Per $Per | Select  -ExpandProperty views 
        $clone_stats = Get-GhStatsClones -Repository "$Repository" -Per $Per | Select  -ExpandProperty clones 
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
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Get-GhStatsRepositoryCount{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository
    )     
    try{
        $Path = '{0}\STATS-{1}.{2}' -f (Get-StatsPath), $Repository, "json"
        if(!(Test-Path $Path)){
            throw "no file $Path"
        }
        $Stats = Get-Content -Path $Path | ConvertFrom-Json
        
        [int]$StatsCount = $Stats.Count
        $StatsCount
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Get-GhStatsRepository{
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
        Show-ExceptionDetails $_ -ShowStack
    }
}

function Save-GhStatsRedditSupport{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Save-GhStatsRepository -Repository "PowerShell.Reddit.Support"
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Get-GhStatsRedditSupport{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Get-GhStatsRepository -Repository "PowerShell.Reddit.Support"
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Save-GhStatsArsScriptum{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Save-GhStatsRepository -Repository "arsscriptum.github.io"
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Get-GhStatsArsScriptum{
    [CmdletBinding(SupportsShouldProcess)]
    param()  
    try{
        Get-GhStatsRepository -Repository "arsscriptum.github.io"
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Get-GhStatsRedditSupport{
    [CmdletBinding(SupportsShouldProcess)]
        param(
        [Parameter(Mandatory=$false, HelpMessage="days")]
        [int]$Days=30
    )
        $d = (Get-Date).AddDays(-$Days)
        
        $Time = "{0} - {1}" -f ($d.GetDateTimeFormats()[15]),((Get-Date).GetDateTimeFormats()[15])
        
        $SumUniqueClones = 0
        $TotalClonesCount = 0
        $c = Get-GhStatsClones -Repository "PowerShell.Reddit.Support" -Per week
        $stats = $c.clones | where timestamp -gt $d 
        $stats | % {
            $o = $_
            $SumUniqueClones += $o.uniques
            $TotalClonesCount += $o.count
        }
  
        $SumUniqueViews = 0
        $TotalViewsCount = 0
        $c = Get-GhStatsViews -Repository "PowerShell.Reddit.Support" -Per week
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


function Get-GhStatsArsScriptum{
    [CmdletBinding(SupportsShouldProcess)]
        param(
        [Parameter(Mandatory=$false, HelpMessage="days")]
        [int]$Days=30
    )
        $d = (Get-Date).AddDays(-$Days)
        
        $Time = "{0} - {1}" -f ($d.GetDateTimeFormats()[15]),((Get-Date).GetDateTimeFormats()[15])
        
        $SumUniqueClones = 0
        $TotalClonesCount = 0
        $c = Get-GhStatsClones -Repository "arsscriptum.github.io" -Per week
        $stats = $c.clones | where timestamp -gt $d 
        $stats | % {
            $o = $_
            $SumUniqueClones += $o.uniques
            $TotalClonesCount += $o.count
        }
  
        $SumUniqueViews = 0
        $TotalViewsCount = 0
        $c = Get-GhStatsViews -Repository "arsscriptum.github.io" -Per week
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



function Get-GhSavedStats{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [String]$Repository,
        [Parameter(Mandatory=$false)]
        [int]$Sample=-1
    )
        try{
            $pub = @()
            if([string]::IsNullOrEmpty($Repository) -eq $False){
                $pub = Get-PublicRepositories -Username "arsscriptum" | Where name -eq "$Repository" | Select -ExpandProperty name
            }else{
                $pub = Get-PublicRepositories -Username "arsscriptum" | Select -ExpandProperty name
            }
            $LastUpdateTime= Get-Date
            [System.Collections.ArrayList]$data = [System.Collections.ArrayList]::new()
            
            ForEach($p in $pub){
                $stats = get-GhStatsRepository -Repository "$p" -Sample $Sample
               
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
           Show-ExceptionDetails $_ -ShowStack
    }
}



function Update-GhSavedStats{
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
                Save-GhStatsRepository -Repository "$p"
            }
            Write-Progress -Activity "STATS" -Completed
            Get-GhSavedStats
        }catch{
            Show-ExceptionDetails $_ -ShowStack
    }
}



function Get-GhSavedStatsSorted{
    [CmdletBinding(SupportsShouldProcess)]
    param()
        try{
            
            Get-GhSavedStats | sort -Property UniquesClones -Descending | Select Repository,UniquesClones,UniquesViews,SampleDate
        }catch{
            Show-ExceptionDetails $_ -ShowStack
    }
}



function Get-GhSavedStatsAllSamples{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Repository")]
        [ValidateNotNullOrEmpty()]
        [String]$Repository
    )  
        try{
            [System.Collections.ArrayList]$data = [System.Collections.ArrayList]::new()
            $GithubSavedStatsCount = Get-GhStatsRepositoryCount -Repository "$Repository"
            For($i = 0 ; $i -lt $GithubSavedStatsCount ; $i++){
                $stats = Get-GhStatsRepository -Repository "$Repository" -Sample $i
                [void]$data.Add($stats)
            }
            $data
        }catch{
            Show-ExceptionDetails $_ -ShowStack
    }
}

