
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍 
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/  Http
#>

function Start-SaveStatsJob{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $SaveStatsScript = {
          param()
      
        Import-Module 'PowerShell.Module.Github'
        try{

            $LastUpdateTime= Get-Date
            while($True){
                Start-Sleep 5
                [timespan]$Diff = (Get-Date) - $LastUpdateTime
                if($Diff.Minutes -gt 20){
                    $LastUpdateTime = Get-Date
                    Save-GithubSupportStats 
                    Save-GithubPagesStats
                    $pub = Get-PublicRepositories -Username "arsscriptum" | Select -ExpandProperty name
                    ForEach($p in $pub){
                        Save-GithubRepoStats -Repository "$p"
                    }
                }
            }
        }catch{
            Write-Output "$_"
    }}.GetNewClosure()

    [scriptblock]$SaveStatsScriptBlock = [scriptblock]::create($SaveStatsScript) 

    $jobby = Start-Job -Name "savestats" -ScriptBlock $SaveStatsScriptBlock 

    $jobby
}

Start-SaveStatsJob