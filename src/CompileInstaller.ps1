
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>


function Invoke-CompiledInstaller {  #NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
        )


        $CodeMSI = @"

            `$prevProgressPreference = `$global:ProgressPreference
            `$global:ProgressPreference = 'SilentlyContinue'
            
            `$Url = 'https://github.com/cli/cli/releases/download/v2.20.2/gh_2.20.2_windows_amd64.msi'
            `$DestFile = `"`$ENV:Temp\gh_2.20.2_windows_amd64.msi`"
            Invoke-WebRequest -Uri `$Url  -OutFile `$DestFile
            `$global:ProgressPreference = `$prevProgressPreference
           
            if(Test-Path `$DestFile){
                &`"`$DestFile`" '/quiet' '/passive' '/norestart'
            }

            Start-Sleep 5
"@




        $CodeChoco = @"

        function Get-ChocoExePath{   
            [CmdletBinding(SupportsShouldProcess)]
            param()

            `$chocoCmd = Get-Command 'choco.exe' -ErrorAction Ignore
            if((`$chocoCmd -ne `$Null ) -And (test-path -Path '`$(`$chocoCmd.Source)' -PathType Leaf)){
                `$chocoApp = `$chocoCmd.Source
                Write-Verbose '✅ Found choco.exe CMD [`$chocoApp]'
                Return `$chocoApp 
            }
           

            `$chocoApp = `"`$ENV:ProgramData\chocolatey\bin`"
            `$chocoApp = Join-Path `$chocoApp 'choco.exe'
            if(test-path `$chocoApp){
                return `$chocoApp
            }
            Throw 'Could not locate choco.exe'
        }

        `$ChocoExePath = Get-ChocoExePath

        &`"`$ChocoExePath`" 'install' 'gh'

        Start-Sleep 5
"@


        $CodeWinGet = @"

        function Get-WinGetExePath{   
            [CmdletBinding(SupportsShouldProcess)]
            param()

            `$wingetCmd = Get-Command 'winget.exe' -ErrorAction Ignore
            if((`$wingetCmd -ne `$Null ) -And (test-path -Path '`$(`$wingetCmd.Source)' -PathType Leaf)){
                `$wingetApp = `$wingetCmd.Source
                Write-Verbose '✅ Found winget.exe CMD [`$wingetApp]'
                Return `$wingetApp 
            }
           

            `$wingetApp = (Resolve-Path "`$ENV:APPDATA\..\Local\Microsoft\WindowsApps").Path
            `$wingetApp = Join-Path `$wingetApp 'winget.exe'
            if(test-path `$wingetApp){
                return `$wingetApp
            }
            Throw 'Could not locate winget.exe'
        }

        `$WinGetExePath = Get-WinGetExePath

        &`"`$WinGetExePath`" 'install' '--id' 'GitHub.cli'

        Start-Sleep 5
"@


        $bytes = [System.Text.Encoding]::Unicode.GetBytes($CodeMSI)
        $EncodedCommandMSI = [Convert]::ToBase64String($bytes)

        $bytes = [System.Text.Encoding]::Unicode.GetBytes($CodeChoco)
        $EncodedCommandChoco = [Convert]::ToBase64String($bytes)

        $bytes = [System.Text.Encoding]::Unicode.GetBytes($CodeWinGet)
        $EncodedCommandWinGet = [Convert]::ToBase64String($bytes)


        $Compiled = @"

        `$EncodedCommandMSI = `"$EncodedCommandMSI`"
        `$EncodedCommandChoco = `"$EncodedCommandChoco`"
        `$EncodedCommandWinGet = `"$EncodedCommandWinGet`"

"@


        Set-Content $Path -Value $Compiled 


}



function Invoke-CompiledUninstaller {  #NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
        )


        $CodeChoco = @"

        function Get-ChocoExePath{   
            [CmdletBinding(SupportsShouldProcess)]
            param()

            `$chocoCmd = Get-Command 'choco.exe' -ErrorAction Ignore
            if((`$chocoCmd -ne `$Null ) -And (test-path -Path '`$(`$chocoCmd.Source)' -PathType Leaf)){
                `$chocoApp = `$chocoCmd.Source
                Write-Verbose '✅ Found choco.exe CMD [`$chocoApp]'
                Return `$chocoApp 
            }
           

            `$chocoApp = `"`$ENV:ProgramData\chocolatey\bin`"
            `$chocoApp = Join-Path `$chocoApp 'choco.exe'
            if(test-path `$chocoApp){
                return `$chocoApp
            }
            Throw 'Could not locate choco.exe'
        }

        `$ChocoExePath = Get-ChocoExePath

        &`"`$ChocoExePath`" 'uninstall' 'gh'

        Start-Sleep 5
"@


        $CodeWinGet = @"

        function Get-WinGetExePath{   
            [CmdletBinding(SupportsShouldProcess)]
            param()

            `$wingetCmd = Get-Command 'winget.exe' -ErrorAction Ignore
            if((`$wingetCmd -ne `$Null ) -And (test-path -Path '`$(`$wingetCmd.Source)' -PathType Leaf)){
                `$wingetApp = `$wingetCmd.Source
                Write-Verbose '✅ Found winget.exe CMD [`$wingetApp]'
                Return `$wingetApp 
            }
           

            `$wingetApp = (Resolve-Path "`$ENV:APPDATA\..\Local\Microsoft\WindowsApps").Path
            `$wingetApp = Join-Path `$wingetApp 'winget.exe'
            if(test-path `$wingetApp){
                return `$wingetApp
            }
            Throw 'Could not locate winget.exe'
        }

        `$WinGetExePath = Get-WinGetExePath

        &`"`$WinGetExePath`" 'uninstall' '--id' 'GitHub.cli'

        Start-Sleep 5
"@


        $bytes = [System.Text.Encoding]::Unicode.GetBytes($CodeChoco)
        $EncodedCommandChoco = [Convert]::ToBase64String($bytes)

        $bytes = [System.Text.Encoding]::Unicode.GetBytes($CodeWinGet)
        $EncodedCommandWinGet = [Convert]::ToBase64String($bytes)


        $Compiled = @"


        `$EncodedCommandChoco = `"$EncodedCommandChoco`"
        `$EncodedCommandWinGet = `"$EncodedCommandWinGet`"

"@


        Set-Content $Path -Value $Compiled 


}