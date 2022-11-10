
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>



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
         Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}
 


function Remove-Repository {
     param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="The repository name") ]
        [string]$Name  
     )
 
    try{
        $GhExe = (Get-Command gh.exe).Source
        
        &"$GhExe" repo delete $Name
        
    }
    catch{
         Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
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
         Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}




function Get-RepositoriesDetails{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Username
    )
    try{
        $GHX = (Get-Command 'gh.exe').Source
        $Content = &"$GHX" "api" "users/$Username/repos"
        $ParsedBuffer=$Content | ConvertFrom-Json 
        return $ParsedBuffer
    } catch {
        Show-ExceptionDetails($_)
    }
}