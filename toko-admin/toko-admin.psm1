function _Load-ScriptFiles ($path) {
    
}

# init module user dir
$script:moduleUserDir = "$Global:HOME\documents\toko-admin"
if (-not (Test-Path $moduleUserDir)) {
    New-Item -Path $moduleUserDir -ItemType Directory
}

# init external tools dir
$Script:externalToolsPath = "$script:moduleUserDir\external-tools"
if (!(Test-Path $Script:externalToolsPath)) {
    New-Item -Path $Script:externalToolsPath -ItemType Directory
}

# load config
$defaultConfigPth = "$PSScriptRoot\default_config.json"
$Script:userConfigPath = "$moduleUserDir\config.json"
$Script:config = get-userConfig -defaultConfigPath $defaultConfigPth -userConfigPath $userConfigPath

# load all module script files
Get-ChildItem -Path "$PSScriptRoot\core" -Filter '*.ps1' -Recurse | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
