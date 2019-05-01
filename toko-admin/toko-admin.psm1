function _Load-ScriptFiles ($path) {
    Get-ChildItem -Path $path -Filter '*.ps1' -Recurse
}

$toolsPath = "$PSScriptRoot\external-tools"
if (!(Test-Path $toolsPath)) {
    New-Item -Path $toolsPath -ItemType Directory
}

# Do not dot source in function scope it won`t be loaded inside the module
_Load-ScriptFiles "$PSScriptRoot\core" | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
