function _Load-ScriptFiles ($path) {
    
}

# init external tools dir
$toolsPath = "$PSScriptRoot\external-tools"
if (!(Test-Path $toolsPath)) {
    New-Item -Path $toolsPath -ItemType Directory
}

# load config
$script:moduleUserDir = "$Global:HOME\documents\toko-admin"
if (-not (Test-Path $moduleUserDir)) {
    New-Item -Path $moduleUserDir -ItemType Directory
}

$defaultConfigPth = "$PSScriptRoot\default_config.json"
$Script:userConfigPath = "$moduleUserDir\config.json"
$Script:config = get-userConfig -defaultConfigPath $defaultConfigPth -userConfigPath $userConfigPath

# load all module script files
Get-ChildItem -Path "$PSScriptRoot\core" -Filter '*.ps1' -Recurse | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
