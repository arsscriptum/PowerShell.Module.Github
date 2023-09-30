
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
      
        Import-Module 'PowerShell.Module.Github' *> "$ENV\Temp\test.out"

        try{
            $id = 1
            $First = $True
            $LastUpdateTime = (Get-Date)
            if($First -eq $True){
                $First = $False
                $LastUpdateTime = (Get-Date).AddMinutes(-50)
            }
            while($True){
                
                Start-Sleep 5
                [timespan]$Diff = (Get-Date) - $LastUpdateTime
                if($Diff.Minutes -gt 30){
                    $LastUpdateTime = (Get-Date)
                    $StrDate = (Get-Date)
                    Write-Host "[Update] num $id started on $StrDate"
                    $Null = Update-GithubSavedStats
                    $StrDate = (Get-Date)
                    Write-Host "[Update] num $id ended on $StrDate"
                    $id++
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