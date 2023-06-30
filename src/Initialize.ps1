
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷𝓍   
#̷𝓍   PowerShell GitHub Module
#>


 
function Initialize-GithubModuleWithSecret{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0, HelpMessage="Secret (not test) password unnum")][String]$Password
    ) 
    $TestMode = $False

    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Host '[Initialize-RedditModule] ' -f DarkRed -NoNewLine
        Write-Host "TEST ONLY" -f DarkYellow            
        $TestMode = $True
    }

    # __REPLACE_CODED_STRING__
    $coded_sectest='O9fgLPS5T0VaVO+ScvR8/T2bX60+RnabNrhC8Dff7ORDLeViTbEIYy6LJ47SnKKIQ+Txr7zNiKLwHQvebWEagJfQttSA86sqn/vj1T6dul4VzMTXuM0l+lk0AmhZPV0WJmq55XqINKl5XsrMXouQxIu+qZ/nRCQL6O/pYepT4l6kT/CgGj9tuaZN69LtPFsBIoLB5vhVDtgI7KrbF6QGOQDrV6tHjaTpzvUTm39T4jXqPCifvEhxv8LDPvjXzFc1oKRStaJwN2cyqxX6S5gGyw=='
    
    $exec = Decrypt-String -EncryptedString $coded_sectest -Passphrase $Password
    if($TestMode){
        Write-Host -n -f DarkRed "[WHATIF] " ; Write-Host -f DarkYellow "`n`n$exec`n"
        return
    }
    Invoke-Expression "$exec"
} 

function Uninitialize-GithubModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][String]$Password
    ) 
    
} 


function Initialize-GithubModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][ValidateNotNullOrEmpty()][String]$Username,
        [Parameter(Mandatory=$true,Position=1)][ValidateNotNullOrEmpty()][String]$Password,
        [Parameter(Mandatory=$true,Position=2)][ValidateNotNullOrEmpty()][String]$Client,
        [Parameter(Mandatory=$true,Position=3)][ValidateNotNullOrEmpty()][String]$Secret,
        [Parameter(Mandatory=$true,Position=4)][ValidateNotNullOrEmpty()][String]$Token
    ) 

    $Result = $True
    Write-Verbose "Initialize-GithubModule => Set-GithubAppCredentials -Client $Client -Secret $Secret"
    $Result = $Result -and (Set-GithubAppCredentials -Client $Client -Secret $Secret)
    Write-Verbose "Initialize-GithubModule => Set-GithubUserCredentials -Username $Username -Password $Password"
    $Result = $Result -and (Set-GithubUserCredentials -Username $Username -Password $Password)
    Write-Verbose "Initialize-GithubModule => Set-GithubAccessToken -Username $Username -Token $Token"
    $Result = $Result -and (Set-GithubAccessToken -Username $Username -Token $Token)
    if(!$Result) { throw "Error" }
}





