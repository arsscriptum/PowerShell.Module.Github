
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
    $coded_sectest='267lRO90gE2DpPKSXZhuTJCR5QX53Oeln/Qwy7N8RGl0UwoB78h0+Nj4xDpDHZFRs68LqQlBAzXMr72VomBwPLjl1vsGULdMERgDdoEhmLXYBzGPxbtePKnYX8hMZin2p5qTnUcYr6+QV2sCcpFtoN/fkxjnswLLkW7bK2BWwgw/+9yie8BCOgJV7NkwJj+LhGOkuZykAafp3e9a3si5v+rCxdazga4huIkfH3M/huz0UB/0jcUxrr7DKLwgtOqwkEwVkp15q2cXxbQcXOAXDgZWMD2ERR32sbh7xX3DAUzHL5DfDz7ZK2aHF3hloz+yScyOFzeAXSHIyoPHofQPvTyCOF4QclvI2CEikCPQ4rpkToUi+untnxXwS45P5PIUahhICG9L3eMpcYgt5hsb7A=='
    
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





