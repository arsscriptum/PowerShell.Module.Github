
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>




function Get-GhCliSource {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('p')]
        [string]$Path,
        [Alias('f')]
        [Parameter(Mandatory=$false)]
        [switch]$Force 
    )

    try{

        $SourcePath = Join-Path $Path "gh-cli"
        $SourceUrl = 'https://github.com/cli/cli.git'
        pushd $Path

        if($Force){
            Remove-Item $SourcePath -Force -Recurse -ErrorAction Ignore | Out-Null
        }

        if(Test-Path $SourcePath){
            Write-Host "Path `"$SourcePath`" already exists. Use -Force to overwrite"
            return
        }
        Invoke-CloneRepository $SourceUrl $SourcePath
        pushd "gh-cli"

        Write-Host "To build the `"bin\gh.exe`" binary, run this:`n`"go run script\build.go`"" -f DarkCyan

    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}


function Test-GhCliInstallation {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    try{

        $Success = $False

        if($Success){
            Write-Host "Successfully configured Git Authentication for user $LoggedInAs"
        }
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}




function Get-GhCliExePath{   
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $ghCmd = Get-Command 'gh.exe' -ErrorAction Ignore
    if(($ghCmd -ne $Null ) -And (test-path -Path "$($ghCmd.Source)" -PathType Leaf)){
        $ghApp = $ghCmd.Source
        Write-Verbose "✅ Found winget.exe CMD [$ghApp]"
        Return $ghApp 
    }
    
    $expectedLocations="${ENV:ProgramFiles}\GitHub CLI", "${ENV:ProgramFiles(x86)}\GitHub CLI", "C:\ProgramData\chocolatey\bin"
    $ghFiles=$expectedLocations|%{Join-Path $_ 'gh.exe'}
    [String[]]$validGhFiles=@($ghFiles|?{test-path $_})
    $validGhFilesCount = $validGhFiles.Count
    if($validGhFilesCount){
        return $validGhFiles[0]
    }
    Throw "Could not locate gh.exe"
}


