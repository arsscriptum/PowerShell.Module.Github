
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>




function Write-ReadMe_OLD{
    [CmdletBinding()]
    Param ()
    $CurrentPath    = $PWD.Path
    $SourcePath     = (Join-Path "$PSScriptRoot" "src")
    $DocPath        = (Join-Path "$PSScriptRoot" "doc")
    $RootPath       = "$CurrentPath"
    if($ENV:modcore){
        $SourcePath = (Join-Path "$ENV:modcore" "src")    
        $RootPath   = "$ENV:modcore"

    }
    $OutHtmlFile    = (Join-Path "$RootPath" "Functions.html")    
    $OutREADME      = (Join-Path "$RootPath" "README.md")    
    $READMEBase      = (Join-Path "$RootPath" "README.base")    
    if(-not(Test-Path -Path $SourcePath -PathType Container)){
        throw "cant find source directory"
    }

    Write-Host "Writing $OutHtmlFile..." -f DarkCyan -n 

    $FunctionTable = [System.Collections.ArrayList]::new()
    $funcs = Get-FunctionList $SourcePath | select Name,Base
    ForEach($f in $funcs){
        $name = $f.Name
        $base = $f.Base
        $link = "https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/src/$base.ps1"
        $dat = "$link"
        $doc = "https://github.com/arsscriptum/PowerShell.Module.Github/blob/master/doc/$name.md"
        $f.Base = $dat

        [pscustomobject]$o = @{
            Name = $name
            File = $base
            Link = $link
            Documentation = $doc
        }
        $Null = $FunctionTable.Add($o)
    }

    $FunctionTable  | ConvertTo-HTML -Property @{Label="Name";Expression={"<a href='$($_.Documentation)'>$($_.Name)</a>"}},@{Label="File";Expression={"<a href='$($_.Link)'>$($_.File)</a>"}} | set-content  $OutHtmlFile

    $Html = Get-Content $OutHtmlFile

    Add-Type -AssemblyName System.Web
    [System.Web.HttpUtility]::HtmlDecode($Html) | Out-File $OutHtmlFile

    Write-Host " Done" -f DarkGreen

    $Functions = [System.Collections.ArrayList]::new()
    $html = Get-Content $OutHtmlFile -Raw
    $s = $html.IndexOf('<table>')
    $e = $html.IndexOf('</table>',$s)
    $l = $html.Length
    $Functions = $html.substring($s, $e-$s+8)
    #For($i = $s ; $i -le $e ; $i++){
    #    $tmp = $html[$i]      
    #    $Functions.Add($tmp) | Out-Null
    #}

    $BaseFile = [System.Collections.ArrayList]::new()
    $rmf = Get-Content $READMEBase
    For($i = 6 ; $i -le $($rmf.Length) ; $i++){
        $tmp = $rmf[$i]      
        $BaseFile.Add($tmp) | Out-Null
    }

    Write-Host "Writing $OutREADME..." -f DarkCyan -n 
    $BaseFile | set-content -Path "$OutREADME"
    $Functions | add-content -Path "$OutREADME"
    Write-Host " Done" -f DarkGreen    
}



function Write-ReadMe{
    [CmdletBinding()]
    Param ()
    $CurrentPath    = $PWD.Path
    $SourcePath     = (Join-Path "$PSScriptRoot" "src")
    $DocPath        = (Join-Path "$PSScriptRoot" "doc")
    $RootPath       = "$CurrentPath"
    if($ENV:modcore){
        $SourcePath = (Join-Path "$ENV:ModGithub" "src")    
        $RootPath   = "$ENV:ModGithub"

    }
    $OutFuncFile    = (Join-Path "$RootPath" "Functions.md")    
    $OutREADME      = (Join-Path "$RootPath" "README.md")    
    $READMEBase      = (Join-Path "$RootPath" "README.base")    
    if(-not(Test-Path -Path $SourcePath -PathType Container)){
        throw "cant find source directory"
    }

    Write-Host "Writing $OutFuncFile..." -f DarkCyan -n 
    Invoke-GenerateFunctionTable -Repository "PowerShell.Module.Github" -Path $SourcePath -DocumentationPath $DocPath > "$OutFuncFile"


    Write-Host "Writing $OutREADME..." -f DarkCyan -n 
    Get-Content -Path "$READMEBase" -Encoding utf8  | Select -Skip 7 | set-content -Path "$OutREADME" -Encoding utf8 
    Get-Content -Path "$OutFuncFile" -Encoding utf8 -Raw | add-content -Path "$OutREADME" -Encoding utf8 
    Write-Host " Done" -f DarkGreen    
}
Write-ReadMe