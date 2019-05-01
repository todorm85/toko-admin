Set-Location "$PSScriptRoot\..\"

git clean -xdf

$apiKey = Read-Host -Prompt "API Key: "
Publish-Module -Name "toko-admin" -NuGetApiKey $apiKey
