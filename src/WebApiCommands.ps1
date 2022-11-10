
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


 