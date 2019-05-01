$global:hostsPath = "$($env:windir)\system32\Drivers\etc\hosts"

# Get the Handle.exe tool by Sysinternals
$handleLink = "https://download.sysinternals.com/files/Handle.zip"
$handleExternalToolsDir = "$PSScriptRoot\..\external-tools\handle"
if (!(Test-Path $handleExternalToolsDir)) {
    New-Item -Path $handleExternalToolsDir -ItemType Directory
}

$handleToolPath = "$handleExternalToolsDir\handle.exe"
if (!(Test-Path $handleToolPath)) {
    $archive = "$handleExternalToolsDir\Handle.zip"
    try {
        Invoke-WebRequest -Uri $handleLink -OutFile $archive
        expand-archive -path $archive -destinationpath $handleExternalToolsDir
        . "$handleExternalToolsDir\Eula.txt"
        Remove-Item -Path $archive -Force
    }
    catch {
        Write-Error "Error fetching the handle tool from $handleLink auto unlocking files will not work."        
    }
}

function os-popup-notification {
    Param (
        [Parameter(Mandatory = $false)][string] $msg = "No message provided."
    )

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 

    $objNotifyIcon.Icon = "${PSScriptRoot}\..\resources\icon.ico"
    $objNotifyIcon.BalloonTipIcon = "Info"
    $objNotifyIcon.BalloonTipText = $msg
    $objNotifyIcon.BalloonTipTitle = "Powershell operation done."
     
    $objNotifyIcon.Visible = $True 
    $objNotifyIcon.ShowBalloonTip(10000)
}

function os-test-isPortFree {
    Param($port)

    $openedSockets = Get-NetTCPConnection -State Listen
    $isFree = $true
    ForEach ($socket in $openedSockets) {
        if ($socket.localPort -eq $port) {
            $isFree = $false
            break
        }
    }

    return $isFree
}

<#
.EXAMPLE
$path = "tf.exe"
execute-native "& `"$path`" workspaces `"C:\dummySubApp`""
#>
function execute-native ($command, [array]$successCodes) {
    $output = Invoke-Expression $command
    
    if ($Global:LASTEXITCODE -and -not ($successCodes -and $successCodes.Count -gt 0 -and $successCodes.Contains($Global:LASTEXITCODE))) {
        throw "Error executing native operation ($command). Last exit code was $Global:LASTEXITCODE. Native call output: $output`n"
    }
    else {
        $output
    }
}

function unlock-allFiles ($path) {
    if (!$path -or !(Test-Path $path)) {
        throw "The supplied path `"$path`" was not found.";
    }
    
    $handlesPath = "$PSScriptRoot\..\external-tools\handle.exe"
    if (!$handlesPath) {
        Write-Error "Handles tool not found. Unlocking open files will not work. Project files might need to be cleaned up manually if opened."
    }
    
    $handlesList = execute-native "& `"$handlesPath`" /accepteula `"$path`""
    $pids = New-Object -TypeName System.Collections.ArrayList
    $handlesList | ForEach-Object { 
        $isFound = $_ -match "^.*pid: (?<pid>.*?) .*$"
        if ($isFound) {
            $id = $Matches.pid
            if (-not $pids.Contains($id)) {
                $pids.Add($id) > $null
            }
        }
    }

    $pids | ForEach-Object {
        Get-Process -Id $_ | % {
            # $date = [datetime]::Now
            # "$date : Forcing stop of process Name:$($_.Name) File:$($_.FileName) Path:$($_.Path) `nModules:$($_.Modules)" | Out-File "$home\Desktop\unlock-allFiles-log.txt" -Append
            Stop-Process $_ -Force -ErrorAction Continue
        }
    }
}

function Add-ToHostsFile ($address, $hostname) {
    If ((Get-Content $Global:hostsPath) -notcontains "$address $hostname") {
        Add-Content -Encoding utf8 $Global:hostsPath "$address $hostname" -ErrorAction Stop
    }
}

function Remove-FromHostsFile ($hostname) {
    $address = $null
    (Get-Content $Global:hostsPath) | ForEach-Object {
        $found = $_ -match "^(?<address>.*?) $hostname$"
        if ($found) {
            $address = $Matches.address
        }
    } | Out-Null

    if (-not $address) {
        throw 'Domain not found in hosts file.'
    }

    (Get-Content $global:hostsPath) |
        Where-Object { $_ -notmatch ".*? $hostname$" } |
        Out-File $global:hostsPath -Force -Encoding utf8 -ErrorAction Stop

    return $address
}