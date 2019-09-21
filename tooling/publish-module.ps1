Param(
    [Parameter(Mandatory = $true)][string]$version
)

Set-Location "$PSScriptRoot"

git tag $version
git push origin --tags

Publish-Module -Name "toko-admin" -NuGetApiKey $Env:NuGetApiKey
