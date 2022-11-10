
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>



function Get-GithubUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present", Position=0)]
        [switch]$Authenticated
    )
    try{
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





function Get-GitRepoUrl{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Alias('q')]
        [Parameter(Mandatory=$false)]
        [switch]$Quiet
    )

    $GitExe = Get-GitExecutablePath

    if($Quiet){
        &"$GitExe" 'remote' 'get-url' '--all' 'origin' | out-null
    }else{
        &"$GitExe" 'remote' 'get-url' '--all' 'origin' 
    }
    
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
    Write-Log "Git Status"
    $GitExe = Get-GitExecutablePath
    if($Raw){
        &"$GitExe" status
        return
    }
    $Result = &"$GitExe" status 2> $TmpFile
    $ntc=($Result -match $AnchorClean) ; if($ntc -eq $AnchorClean) {$Clean = $True;$Dirty = $False}
    $ntc=($Result -match $AnchorChange) ; if($ntc -eq $AnchorChange) {$Clean = $False;$Dirty = $True}
    if($Clean){ Write-Log "$AnchorClean"  ; return }
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
