
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
    $coded_sectest='nsxkRxfV+nekbZdUfWsXhBoBCKId6Xw88cwcE/BMxlf2ig1vpkl1GwyOBxKYi6SFGd7gp1eSI9K+tBtH2cOgTuCsFMriNv8C1LAf7iuaD1bZYBo6YsaA1Upx98ofUYDgplQDjygTenettVgPalV2v41wnObhxY5OAIJqFcvJx6fSws2/3w8DiuFvOhTHpqNd81Ig3kxyXC7njlDvyXbOzxNtptgNkTNGnlhSLKIv/ag4s2XZtmeiMa54sieACOW1TFozTDiZlXPWyQvB490KCNB6Hjig3WZnOaUz/gV19wER9QFeBELYnwVIYftTa1y7Qalc7E8Wj4J/78uHJau8ayqogiBWwsFAj5MXmDDyV1PcE65c0r5Z7TIyeAD7uXFQTz60LKAN0N8kDkw6kHGzK8GxL7+BjL1FNsI3k1hnjjCGiLCFXhSpiiHwUdEa3z0B'
    
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
        [Parameter(Mandatory=$true,Position=4)][ValidateNotNullOrEmpty()][String]$Token,
        [Parameter(Mandatory=$true,Position=5)][ValidateSet('legacy','finegrained')][String]$TokenType,
        [Parameter(Mandatory=$true,Position=6)][ValidateNotNullOrEmpty()][String]$FineGrainedToken
    ) 

    $Result = $True
    Write-Verbose "Initialize-GithubModule => Set-GithubAppCredentials -Client $Client -Secret $Secret"
    $Result = $Result -and (Set-GithubAppCredentials -Client $Client -Secret $Secret)
    Write-Verbose "Initialize-GithubModule => Set-GithubUserCredentials -Username $Username -Password $Password"
    $Result = $Result -and (Set-GithubUserCredentials -Username $Username -Password $Password)
    Write-Verbose "Initialize-GithubModule => Set-GithubAccessToken -Username $Username -Token $Token"
    $Result = $Result -and (Set-GithubAccessToken -Token $Token)
    if(!$Result) { throw "Error" }

    Set-GithubFinedGrainToken -Token $FineGrainedToken
    Set-GithubTokenType $TokenType
}





