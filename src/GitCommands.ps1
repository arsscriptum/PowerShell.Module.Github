
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>


function Invoke-CloneRepository{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="Url", Position=0)]
        [Alias('u')]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, HelpMessage="Destination Directory", Position=1)]
        [Alias('p')]
        [string]$Path,
        [Alias('q')]
        [Parameter(Mandatory=$false)]
        [switch]$Quiet        
    )
  

    Write-Log "git: clone from $Url" 

    $GitExe = Get-GitExecutablePath
    
    if($Quiet){
        &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$Url" "$Path" | out-null
    }else{
        &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$Url" "$Path"
    }    
}


function Invoke-CloneRepositoryAuthenticated{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, HelpMessage="Url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, HelpMessage="Destination Directory", Position=1)]
        [string]$Path,
        [Parameter(Mandatory=$false, HelpMessage="Sha Revision to sync after clone")]
        [string]$Revision,
        [Parameter(Mandatory=$false)]
        [switch]$Quiet        
    )
  
    $u = (Get-GithubUserCredentials).UserName
    $tok = Get-GithubAccessToken
    $DataValid = (! ([string]::IsNullOrEmpty($u)) -And (! [string]::IsNullOrEmpty($tok)))
    
    $err = "Missing auth data. Username: `"{0}`"  Token: `"{1}`"" -f $u, $tok 
    if($False -eq $DataValid){
        Write-Error $err
        return;
    }
    $gitcredz = '//{0}:{1}@' -f $u, $tok 
    $AuthenticatedUrl = $Url.Replace('//', $gitcredz)


    Write-Host "[GIT CLONE] " -n -f DarkCyan
    Write-Host "git: clone from $AuthenticatedUrl"  -f DarkGray

    $GitExe = Get-GitExecutablePath
    
    if($Quiet){
        &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$AuthenticatedUrl" "$Path" | out-null
    }else{
        &"$GitExe" 'clone' '--recurse-submodules' '-j8' "$AuthenticatedUrl" "$Path"
    }    

    if([string]::IsNullOrEmpty($Revision) -eq $False){
        Write-Host "[GIT CLONE] " -n -f DarkCyan
        Write-Host "Revision specified [$Revision], so checking out revision." -f DarkGray
        if([string]::IsNullOrEmpty($Path) -eq $False){
            Push-Location "$Path"
        }else{
            $NewDir = $u.Segments[$u.Segments.Count-1]
            $len = $NewDir.Length
            $NewDir = $NewDir.Substring(0,$len-4)
            Push-Location "$NewDir"
        }

        &"$GitExe" 'checkout' "$Revision" 

        Pop-Location
    }
}



function Get-GithubUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present", Position=0)]
        [switch]$Authenticated
    )
    try{
        Write-Log "git config --get remote.origin.url"
        [string]$UrlString = git config --get remote.origin.url
        [Uri]$GitUrl = $UrlString
        [string]$StrAbsoluteUri = $GitUrl.AbsoluteUri
        if($StrAbsoluteUri -eq ''){
            throw "NOT A GIT REPOSITORY"
            return ''
        }
        
        if($Authenticated){
            $Credz = Get-GithubAppCredentials
            if(($Credz.UserName -eq $Null)-Or($Credz.UserName -eq '')){
                throw "GithubAppCredentials not registered"
                return ''
            }
            $StrRepl = ('https://{0}:{1}@' -f $Credz.UserName, $Credz.GetNetworkCredential().Password)
            $StrAbsoluteUri = $StrAbsoluteUri.Replace('https://',$StrRepl)
        }
        
        return $StrAbsoluteUri
    }
    catch{
        Show-ExceptionDetails $_ -ShowStack:$Global:DebugShowStack
    }
}



function Invoke-Git {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, position=0)]
        [string[]]$GitArguments,
        [Parameter(Mandatory = $False)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $False)]
        [switch]$RedirectOutput       
    )

    $GitExe = Get-GitExecutablePath

    if(($WorkingDirectory -eq $null) -Or ($WorkingDirectory.Length -eq 0)){
        $WorkingDirectory=(Get-Location).Path
    }

    [string]$FNameOut = $Null
    [string]$FNameErr = $Null

    $startProcessParams = @{
        FilePath                = "$GitExe"
        WorkingDirectory        = "$WorkingDirectory"
        ArgumentList            = $GitArguments
        NoNewWindow             = $true
        Wait                    = $true
        PassThru                = $true        
    }   

    if($RedirectOutput){
        $Guid=$(( New-Guid ).Guid)  
        $FNameOut=$env:Temp + "\InvokeProcessOut"+$Guid.substring(0,4)+".log"
        $FNameErr=$env:Temp + "\InvokeProcessErr"+$Guid.substring(0,4)+".log"

        $startProcessParams['RedirectStandardOutput']  = $FNameOut
        $startProcessParams['RedirectStandardError']   = $FNameErr
    }


    $cmdName=""
    $cmdId=0
    $cmdExitCode=0
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $cmd = Start-Process @startProcessParams | Out-null
    $cmdExitCode = $cmd.ExitCode
    $cmdId = $cmd.Id 
    $cmdName=$cmd.Name 

    $stdOut = ''
    $stdErr = ''
    if($RedirectOutput){
        $stdOut = Get-Content -Path $FNameOut -Raw
        $stdErr = Get-Content -Path $FNameErr -Raw
        if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
            $stdOut = $stdOut.Trim()
        }
        if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
            $stdErr = $stdErr.Trim()
        }        
    }

    $res = [PSCustomObject]@{
        Name            = $cmdName
        Id              = $cmdId
        FilePath        = "$GitExe"
        WorkingDirectory= "$WorkingDirectory"
        ArgumentList    = $GitArguments        
        ExitCode        = $cmdExitCode
        ElapsedSeconds  = $stopwatch.Elapsed.Seconds
        ElapsedMs       = $stopwatch.Elapsed.Milliseconds
        Output          = $stdOut
        Error           = $stdErr        
    }
    return $res                    
}


function Save-Changes{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Alias('m','msg','message','d')]
        [Parameter(Mandatory=$false)]
        [string]$Description = 'automatic-commit',
        [Alias('q')]
        [Parameter(Mandatory=$false)]
        [switch]$Quiet        
    )
  

    $Dir=(Get-Location).Path
    Write-Host "git: commit and push from " -f DarkCyan -NoNewLine
    Write-Host "$Dir" -f DarkRed

    $CommitMessage='"'+$Description+'"'
    $GitExe = Get-GitExecutablePath

    
    if($Quiet){
        &"$GitExe" commit -a -m "$CommitMessage" | out-null    
    }else{
        &"$GitExe" commit -a -m "$CommitMessage"
    }    
}





function Push-Changes {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$DeployPath,
        [Parameter(Mandatory=$false)]
        [string]$Description = '',
        [Parameter(Mandatory=$false)]
        [Alias('q')]
        [switch]$Quiet,
        [Parameter(Mandatory=$false)]
        [switch]$Authenticated 
    )
    try{
        [string]$datestr=(get-date).GetDateTimeFormats()[23]
        if($Description -eq ''){$Description = "'$datestr : automatic-commit'"; }

        If($PSBoundParameters.ContainsKey('DeployPath') -eq $False ){
            $DeployPath = (Get-Location).Path
        }else{
            pushd $DeployPath
        }

        $GitArgs=@("add", "*")
        Write-Log  "git add"
        $Null = Invoke-Git -GitArgument $GitArgs -RedirectOutput:$Quiet

        $GitArgs=@("commit", "-a", "-m", "auto")
        Write-Log "git commit"
        $Null = Invoke-Git -GitArgument $GitArgs -RedirectOutput:$Quiet
      
        $GitArgs=@('push')
        if($Authenticated){ $GitArgs += (Get-GithubUrl -Authenticated) }
        Write-Log "git push"
        $Null = Invoke-Git -GitArgument $GitArgs -RedirectOutput:$Quiet
        
        popd
    }catch{
       Show-ExceptionDetails $_ -ShowStack:$Global:DebugShowStack
    }
 } 


 

 function Get-GitStatus {
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
    Write-Log "Git Status"
    $GitExe = Get-GitExecutablePath
    if($Raw){
        &"$GitExe" status
        return
    }
    $Result = &"$GitExe" status 2> $TmpFile

    $HasUntracked = $False
    ForEach($l in $Result){ if($l.Contains("Untracked")) { $HasUntracked = $True; break; }}
    if($HasUntracked){
        $i=0
        While($Result[$i].StartsWith("Untracked") -eq $False){$i++}
         $i = $i + 2 
         $untracked = $Result[$i].Trim() 
         &"$GitExe" "add" "$untracked"
    }

    $ntc=($Result -match $AnchorClean) ; if($ntc -eq $AnchorClean) {$Clean = $True;$Dirty = $False}
    $ntc=($Result -match $AnchorChange) ; if($ntc -eq $AnchorChange) {$Clean = $False;$Dirty = $True}
    if($Clean){ Write-Log "$AnchorClean"  ; return }
    if($Dirty){
        
        $Mods=($Result | select-string 'modified' -Raw -List)
        ForEach($file in $Mods){
            $file = $file.TrimStart().Replace('modified:','').Trim()
           $file
            $Modified.Add($file) | Out-null
         }
        $dels=($Result | select-string 'deleted' -Raw -List)
        ForEach($file in $dels){
            $file = $file.TrimStart().Replace('deleted:','').Trim()
            $Deleted.Add($file) | Out-null
         }
        $adds=($Result | select-string 'new' -Raw -List)
        ForEach($file in $adds){
            $file = $file.TrimStart().Replace('new file:','').Trim()
            $Added.Add($file) | Out-null
         }
    }

    $FilesStatus = @() 

    if($Modified.Count){
        
        ForEach($m in $Modified){
            $o = [PsCustomObject]@{
                Path = "$m"
                Status = "Modified"
            }
            $FilesStatus += $o
        }
    }

    if($Added.Count){
        
        ForEach($m in $Added){
            $o = [PsCustomObject]@{
                Path = "$m"
                Status = "Added"
            }
            $FilesStatus += $o
        }      
    }
    
    if($Deleted.Count){
        ForEach($m in $Deleted){
            $o = [PsCustomObject]@{
                Path = "$m"
                Status = "Deleted"
            }
            $FilesStatus += $o
        }    
    }
    $FilesStatus
}


function Get-ModifiedFiles{
   [CmdletBinding(SupportsShouldProcess)]
    param()

    Get-GitStatus | Where Status -eq 'Modified'
}

function Get-AddedFiles{
   [CmdletBinding(SupportsShouldProcess)]
    param()
    
    Get-GitStatus | Where Status -eq 'Added'
}


function Get-DeletedFiles{
   [CmdletBinding(SupportsShouldProcess)]
    param()
    
    Get-GitStatus | Where Status -eq 'Deleted'
}


function Invoke-GitRevertFiles{
   [CmdletBinding(SupportsShouldProcess)]
    param()
    $GitExe = Get-GitExecutablePath
    Get-GitStatus | Where Status -eq 'Deleted' | % {
        $f = $_
        &"$GitExe" "checkout" "$f"
    }
    Get-GitStatus | Where Status -eq 'Modified' | % {
        $f = $_
        &"$GitExe" "checkout" "$f"
    }
    Get-GitStatus | Where Status -eq 'Added' | % {
        $f = $_
        &"$GitExe" "rm" "$f" "-f"
    }
}



function Show-Diff{
   [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Submodules") ]
        [switch]$Recurse
    )
    Write-Log "Diff"
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
        
        Write-Log "Pulling Latest code for $Repository and all sub modules..." 
        &"$GitExe"  pull --recurse
       
        Write-Log "Rebasing all sub modules..." 
        &"$GitExe"  submodule update --remote --rebase
    }else{
       
        Write-Log "Pulling Latest code for $Repository"
        &"$GitExe"  pull
    }
   
    Write-Log "Operation completed"  
}
