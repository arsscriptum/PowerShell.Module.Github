
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>




function Invoke-SetupGitAuthentication {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    try{


        $ghpath = (Get-Command 'gh.exe').Source

        &"$ghpath" "auth" "logout"

        $arguments = @("auth" , "login")
        Start-Process -FilePath $ghpath -ArgumentList $arguments -WindowStyle Maximized

        $wshell = New-Object -ComObject wscript.shell;

        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        [System.Windows.Forms.SendKeys]::SendWait('{DOWN}')
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('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')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')

        &"$ghpath" "auth" "status" *> out.txt
        $Constant = 'Logged in to github.com as '
        $ConstantLen = $Constant.Length
        $LoggedInAs = ''

        $Success = $False
        Get-Content .\out.txt | % { 
            if($_ -match $Constant){
                $i = $_.IndexOf('Logged in to github.com as ')
                $i = $i + $ConstantLen
                $Success = $True
                $LoggedInAs = $_.Substring($i)
            }
        }

        if($Success){
            Write-Host "Successfully configured Git Authentication for user $LoggedInAs"
        }
    } catch {
        Show-ExceptionDetails($_) -ShowStack:$Global:DebugShowStack
    }
}

