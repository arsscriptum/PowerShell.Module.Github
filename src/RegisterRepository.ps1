<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function New-RepositoryRegistration{

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true) ]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true) ]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true) ]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true) ]
        [ValidateNotNullOrEmpty()]
        [string]$User,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [switch]$UseBuildautomation,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [string]$ExportPath,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [string]$BuildConfig,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [string]$BuildScript,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [switch]$Force        
    )

    $Script:DefaultBuildConfig = "buildcfg.ini"
    $Script:DefaultBuildScript = "Build.bat"
    $Script:DefaultExportPath = "$ENV:ToolsRoot"

    $Script:RegPath = "$ENV:OrganizationHKCU\development\repositories\$Name"

    if($Force){
        $Null = Remove-Item -Path $Script:RegPath -Force -Recurse -ErrorAction Ignore
        $Null = New-Item -Path $Script:RegPath -Force -ErrorAction Ignore
    }elseif(Test-Path $Script:RegPath){
        Write-Error "$Name Alredy Registered in $Script:RegPath. Overwrite with -Force"
        return    
    }
    $Null = New-Item -Path $Script:RegPath -Force -ErrorAction Ignore
    $NowStr =  (get-date).GetDateTimeFormats()[12]
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "CONFIGURATION of REPOSITORY $Name" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed   
    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "User"             -Value $User -Force).PSPath 
    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "LocalPath"        -Value $Path -Force).PSPath
    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "RepositoryUrl"    -Value $RepositoryUrl -Force).PSPath   
    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "Creation"         -Value $NowStr -Force).PSPath   
    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "LastUpdate"       -Value $NowStr -Force).PSPath

    Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "UseBuildautomation"  -Value $UseBuildautomation -Force).PSPath
    if($UseBuildautomation){
        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "UseBuildautomation"  -Value $UseBuildautomation -Force).PSPath

        If( $PSBoundParameters.ContainsKey('ExportPath') -eq $True ){
            Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "ExportPath"      -Value $ExportPath -Force).PSPath
        }

        If( $PSBoundParameters.ContainsKey('BuildConfig') -eq $True ){
            Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "BuildConfig"     -Value $BuildConfig -Force).PSPath
        }

        If( $PSBoundParameters.ContainsKey('BuildScript') -eq $True ){
            Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "BuildScript"     -Value $BuildScript -Force).PSPath
        }
    }else{
        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "ExportPath"    -Value $Script:DefaultExportPath -Force).PSPath   
        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "BuildConfig"   -Value $Script:DefaultBuildConfig -Force).PSPath   
        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPath -Name "BuildScript"   -Value $Script:DefaultBuildScript -Force).PSPath
    }
}



function Submit-RepositoryInfo{

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true) ]
        [switch]$Force
        )


    $Path = (Get-Location).Path 
    $Name = (Get-Item $Path).Name
    $User = Get-GithubDefaultUsername
    $Url =  git remote get-url --all origin
    $BuildConfig = $Script:DefaultBuildConfig
    $BuildScript = $Script:DefaultBuildScript
    $ExportPath = $Script:DefaultExportPath


    Write-Host "===============================================================================" -f DarkRed
    Write-Host "Automatic Submit-RepositoryInfo" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed   

    Write-Host "Path `t" -NoNewLine -f DarkYellow;  Write-Host "$Path" -f Gray 
    Write-Host "Name `t" -NoNewLine -f DarkYellow;  Write-Host "$Name" -f Gray 
    Write-Host "User `t" -NoNewLine -f DarkYellow;  Write-Host "$User" -f Gray 
    Write-Host "Url `t" -NoNewLine -f DarkYellow;  Write-Host "$Url" -f Gray 
    Write-Host "BuildConfig `t" -NoNewLine -f DarkYellow;  Write-Host "$BuildConfig" -f Gray 
    Write-Host "BuildScript `t" -NoNewLine -f DarkYellow;  Write-Host "$BuildScript" -f Gray 
    Write-Host "ExportPath `t" -NoNewLine -f DarkYellow;  Write-Host "$ExportPath" -f Gray 


    New-RepositoryRegistration -Path $Path -Name $Name -RepositoryUrl $Url -User $User -UseBuildautomation -ExportPath $ExportPath -BuildConfig $BuildConfig -BuildScript $BuildScript -Force:$Force
}