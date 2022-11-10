
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>




$Script:W32ApiCode = @"

using System;
using System.Threading;
using System.Runtime.InteropServices;
namespace W32API
{
    public static class Mouse
    {
        [DllImport("User32.dll")]
        public static extern bool SetCursorPos(int X,int Y);
    }
}

"@


function Invoke-SetupGitAuthentication {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    try{

        Add-Type -AssemblyName System.Windows.Forms    
        $screens = [System.Windows.Forms.SystemInformation]::VirtualScreen    

        if(-not('W32API.Mouse' -as [Type])){
            try{
                Add-Type -TypeDefinition $Script:W32ApiCode
            }catch{}
        }

        $new_x = $($screens.Width) / 2
        $new_y = $($screens.Height) / 2

        [Windows.Forms.Cursor]::Position = "$new_x, $new_y"
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $new_x, $new_y

        try{
            Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
        }catch{}
      
        #move 10% along x and 10% along y and send left mouse click
        #[W.U32]::mouse_event(0x02 -bor 0x04 -bor 0x8000 -bor 0x01, .1*65535, .1 *65535, 0, 0);
        [W.U32]::mouse_event(6,0,0,0,0);

        $token =  Get-GithubAccessToken
        if([String]::IsNullOrEmpty($token)) { throw "invalid token" }
        $ghpath = (Get-Command 'gh.exe').Source
        if([String]::IsNullOrEmpty($ghpath)) { throw "gh.exe path" }

        &"$ghpath" "auth" "logout"

        $arguments = @("auth" , "login")
        Start-Process -FilePath $ghpath -ArgumentList $arguments -WindowStyle Maximized
        Start-Sleep 2
        $wshell = New-Object -ComObject wscript.shell;

        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 3
        [System.Windows.Forms.SendKeys]::SendWait('{DOWN}')
        
        Start-Sleep 2

        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
        Start-Sleep 2
        [System.Windows.Forms.SendKeys]::SendWait($token)
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

