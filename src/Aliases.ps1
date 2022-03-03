<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# GitHub.ps1
#===============================================================================
New-Alias -Name listrepo -value Get-GHRepositories -Force
New-Alias -Name listprivaterepo -value Get-PrivateRepositories -Force
New-Alias -Name listpublicrepo -value Get-PublicRepositories -Force

# git status
New-Alias -Name state -Value Get-Status -Force
New-Alias -Name stat -Value Get-Status -Force
# diff
New-Alias -Name gdiff -Value Show-Diff -Force

New-Alias -Name rev -Value Get-GitRevision -Force

# push
New-Alias -Name gpush -value Push-Changes -Force
New-Alias -Name gpush-auth -value Push-ChangesAuthenticated -Force

New-Alias -Name clonemine -value Initialize-LocalUserRepository -Force
# clone user
New-Alias -Name cloneuser -value Sync-UserRepositories -Force

# commit
New-Alias -Name commit -value Save-Changes -Force

# clone myself
New-Alias -Name clone -Value Initialize-Repository -Force

# repo
New-Alias -Name cloneurl -Value Resolve-RepositoryUrl -Force

# pull 
New-Alias -Name fetch -value Update-Repository -Force
New-Alias -Name update -value Update-Repository -Force
New-Alias -Name getlatest -value Update-Repository -Force
New-Alias -Name pull -value Update-Repository -Force
New-Alias -Name up -value Update-Repository -Force

# pull 
New-Alias -Name newr -value New-Repository -Force

New-Alias -Name parserepourl -value Split-RepositoryUrl -Force
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7nJdNJFkZ8bwmK51LVZpndKQ
# U4SgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUAR8knj1b1Oa2jB6ZKRi3
# sIRYhNIwDQYJKoZIhvcNAQEBBQAEggEA1Qkx1E5Lz3dFNcpOeFOo15Sc0rcjI35Y
# dKxB0pRw8cmkOyxFuD5s0g+O3pqgOJis0p0F7sYXEjgVdiGffHqJkm75FXWYIXW1
# qg8hc8JHyy67dn/BDWl32ybPyvJq4AlQ3WZx2x7Rhb4p4ES7Sg4rzQQlmaJvhodh
# zQDKm8j9lz8GThiXUW+Gm15nlYeAXJp8W79v9g1nP64JQ4TKa24POMCzNrtg3uUt
# PrfQr251dMjjSZ2ZSJnrBB9xWL3ltEiPXb6RwRvFQQIdgYH5fsawJlsOl0PgKqrm
# KRyZvyjYdB1T8KqiyY8VrAuFD8f1p/d6ClyQXN6pLAcFqvCrSvuK9g==
# SIG # End signature block
