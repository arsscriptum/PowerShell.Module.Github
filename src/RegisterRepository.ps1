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
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcGCghwdqtfssMvNRoYX8xL/P
# /AygggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUu/LbIlasGfPVnC9mFBCo
# HwQeSvowDQYJKoZIhvcNAQEBBQAEggEAhy21hiXYABq85B050zLmuBks+oRu8RQ6
# zkDxTGgMbXJVB1Vh4hmsFIIhsHujDqIOkMC9mgmQXkfVMBwssjXPnS4xvGkKpSko
# C6j3xwlmkrzcD2lfNSnfJ5Bd/SfJ4obGDH5z7h1P7YK50p7CllaoeB3eVQREPH39
# jDOlb8A8owDfC9xqExcQRTVsZ+o3N4JYqsBnDBXlpds1i0lF2jq7v6Ojxs1ej034
# JQYrxiseckpBhEkbLz2e5UWyibHF9Pd92cIjnXc5F53EUKMNnVhfKWagu+i5F2gO
# oDcNLGq7DnmQk4hgXSalhsoLyq1SmqmbvnC7ERjSKA/Mh0P5G8ez6Q==
# SIG # End signature block
