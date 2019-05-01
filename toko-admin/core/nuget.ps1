# Get Nuget.exe
$nugetDownloadLink = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$toolDir = "$PSScriptRoot\..\external-tools\nuget"
if (!(Test-Path $toolDir)) {
    New-Item -Path $toolDir -ItemType Directory
}

$nugetExePath = "$toolDir\nuget.exe"
if (!(Test-Path $nugetExePath)) {
    try {
        Invoke-WebRequest -Uri $nugetDownloadLink -OutFile $nugetExePath
    }
    catch {
        Write-Error "Error fetching the nuget tool from $nugetDownloadLink nuget operations might not work"
    }
}

function clear-nugetCache {
    execute-native "& `"$($PSScriptRoot)\..\external-tools\nuget\nuget.exe`" locals all -clear"
}
