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
        $c = Get-GithubCloneStats -Repository "PowerShell.Reddit.Support" -Per day
        $stats = $c.clones | where timestamp -gt $d 
        $stats | % {
            $o = $_
            $SumUniqueClones += $o.uniques
            $TotalClonesCount += $o.count
        }
  
        $SumUniqueViews = 0
        $TotalViewsCount = 0
        $c = Get-GithubRepoViewsStats -Repository "PowerShell.Reddit.Support" -Per day
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

        $v = Get-GithubRepoViewsStats -Repository "$Repository" -Per day
        $stats = $v.views | where timestamp -gt $d
        $UniquesViews = $stats.uniques
        $ViewsCount = $stats.count
        $Timestamp = (Get-Date).GetDateTimeFormats()[26]
        $c = Get-GithubCloneStats -Repository "$Repository" -Per day
        $stats = $c.clones | where timestamp -gt $d
        $UniquesClones = $stats.uniques
        $ClonesCount = $stats.count
        
        $o = [PsCustomObject]@{
            UniquesViews = $UniquesViews
            ViewsCount = $ViewsCount
            UniquesClones = $UniquesClones
            ClonesCount = $ClonesCount
            Timestamp = $Timestamp
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
        [String]$Repository
    )     
    try{
        $Path = '{0}\STATS-{1}.{2}' -f (Get-StatsPath), $Repository, "json"
        if(!(Test-Path $Path)){
            throw "no file $Path"
        }

        $Stats = Get-Content -Path $Path | ConvertFrom-Json
        $Stats | ft
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
        GEt-GithubRepoStats -Repository "PowerShell.Reddit.Support"
    }catch{
        Write-Error "$_"
    }
}
