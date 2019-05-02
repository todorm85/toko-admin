function tfs-get-workspaces ($server) {
    $workspacesQueryResult = tf-query-workspaces $server
    $lines = $workspacesQueryResult | % { $_ }
    for ($i = 3; $i -lt $lines.Count; $i++) {
        $lines[$i].Split(' ')[0]
    }
}

function _get-tfPath {
    $path = $Script:config.tfPath
    if (!(Test-Path -Path $path)) {
        throw "Wrong configuration path for tf.exe tool. Not found in $path. Configure it in $($Script:userConfigPath) -> tfPath. It should be preinstalled with Visual Studio."
    }

    $path
}

function tf-query-workspaces ($server) {
    try {
        execute-native "& `"$(_get-tfPath)`" workspaces /server:$server"
    }
    catch {
        Write-Warning "Error querying tf.exe `n $_"
        return $null     
    }
}

function tfs-delete-workspace {
    Param(
        [Parameter(Mandatory=$true)][string]$workspaceName,
        [Parameter(Mandatory=$true)][string]$server
        )

    execute-native "& `"$(_get-tfPath)`" workspace $workspaceName /delete /noprompt /server:$server" > $null
}

function tfs-create-workspace {
    Param(
        [Parameter(Mandatory=$true)][string]$workspaceName,
        [Parameter(Mandatory=$true)][string]$path,
        [Parameter(Mandatory=$true)][string]$server
        )
    
    # needed otherwise if the current location is mapped to a workspace the command will throw
    Set-Location $path

    execute-native "& `"$(_get-tfPath)`" workspace `"$workspaceName`" /new /permission:private /noprompt /server:$server" > $null
    
    Start-Sleep -m 1000

    try {
        execute-native "& `"$(_get-tfPath)`" workfold /unmap `"$/`" /workspace:$workspaceName /server:$server" > $null
    }
    catch {
        try {
            tfs-delete-workspace $workspaceName $server
        } 
        catch {
            throw "Workspace created but... Error removing default workspace mapping $/. Message: $_"
        }

        throw "WORKSPACE NOT CREATED! Error removing default workspace mapping $/. Message: $_"
    }
}

function tfs-rename-workspace {
    Param(
        [Parameter(Mandatory=$true)][string]$path,
        [Parameter(Mandatory=$true)][string]$newWorkspaceName,
        [Parameter(Mandatory=$true)][string]$server
        )
    
    try {
        $oldLocation = Get-Location
        Set-Location $path
        execute-native "& `"$(_get-tfPath)`" workspace /newname:$newWorkspaceName /noprompt /server:$server"
        Set-Location $oldLocation
    }
    catch {
        Write-Error "Failed to rename workspace. Error: $($_.Exception)"
        return
    }
}

function tfs-create-mappings {
    Param(
        [Parameter(Mandatory=$true)][string]$branch,
        [Parameter(Mandatory=$true)][string]$branchMapPath,
        [Parameter(Mandatory=$true)][string]$workspaceName,
        [Parameter(Mandatory=$true)][string]$server
        )

    # if (Test-Path -Path $branchMapPath) {
    #     throw "$branchMapPath already exists!"
    # }

    # try {
    #     New-Item $branchMapPath -type directory
    # } catch {
    #     throw "could not create directory $branchMapPath"
    # }
    try {
        execute-native "& `"$(_get-tfPath)`" workfold /map `"$branch`" `"$branchMapPath`" /workspace:$workspaceName /server:$server" > $null
    }
    catch {
        Remove-Item $branchMapPath -force
        throw "Error mapping branch to local directory. Message: $_"
    }
}

function tfs-checkout-file {
    Param(
        [Parameter(Mandatory=$true)][string]$filePath
        )

    $oldLocation = Get-Location
    $newLocation = Split-Path $filePath -Parent
    $fileName = Split-Path $filePath -Leaf
    Set-Location $newLocation
    try {
        $output = execute-native "& `"$(_get-tfPath)`" checkout $fileName"
    }
    catch {
        throw "Error checking out file $filePath. Message: $_"
    }
    finally {
        Set-Location $oldLocation
        Write-Information $output
    }
}

function tfs-get-latestChanges {
    Param(
        [Parameter(Mandatory=$true)][string]$branchMapPath,
        [switch]$overwrite
        )

    if (-not(Test-Path -Path $branchMapPath)) {
        throw "Get latest changes failed! Branch map path location does not exist: $branchMapPath."
    }

    $oldLocation = Get-Location
    Set-Location -Path $branchMapPath
    
    if ($overwrite) {
        $output = execute-native "& `"$(_get-tfPath)`" get /overwrite /noprompt" -successCodes @(1)
    } else {
        $output = execute-native "& `"$(_get-tfPath)`" get" -successCodes @(1)
    }

    if ($Script:LASTEXITCODE -eq 1) {
        $output -match ".*?(?<conflicts>\d+) conflicts, \d+ warnings, (?<errors>\d+) errors.*"
        $conflictsCount = 0
        if ($Matches.conflicts) {
            $conflictsCount = [int]::Parse($Matches.conflicts)
        }

        $errorsCount = 0
        if ($Matches.errors) {
            $errorsCount = [int]::Parse($Matches.errors)
        }

        $errors = ''
        if ($conflictsCount -gt 0) {
            $errors = "$errors`nThere were $conflictsCount conflicts when getting latest."
        }
        
        if ($errorsCount -gt 0) {
            $errors = "$erors`nThere were $errorsCount errors when getting latest."
        }

        if ($errors) {
            throw $errors
        }
    }

    Set-Location $oldLocation
    
    return $output
}

function tfs-undo-pendingChanges {
    Param(
        [Parameter(Mandatory=$true)][string]$localPath
        )

    execute-native "& `"$(_get-tfPath)`" undo /recursive /noprompt $localPath" -successCodes @(1)
}

function tfs-show-pendingChanges {
    Param(
        [Parameter(Mandatory=$true)][string]$workspaceName,
        [ValidateSet("Detailed","Brief")][string]$format)

    execute-native "& `"$(_get-tfPath)`" stat /workspace:$workspaceName /format:$format"
}

function tfs-get-workspaceName {
    Param(
        [string]$path
        )
    
    $oldLocation = Get-Location
    Set-Location $path
    try {
        $wsInfo = execute-native "& `"$(_get-tfPath)`" workfold"
    }
    catch {
        Write-Warning "Error querying workspace name: $_"
    }

    Set-Location $oldLocation

    try {
        $wsInfo = $wsInfo.split(':')
        $wsInfo = $wsInfo[2].split('(')
        $wsInfo = $wsInfo[0].trim()
    } catch {
        Write-Warning "No workspace info from TFS! If that is unexpected your credentials could have expired. To renew them login from visual studio..."
        $wsInfo = ''
    }

    return $wsInfo
}

function tfs-get-branchPath {
    Param(
        [string]$path
        )
    
    $oldLocation = Get-Location
    try {
        Set-Location $path
        $wsInfo = execute-native "& `"$(_get-tfPath)`" workfold"
    }
    catch {
        Set-Location $oldLocation
        if ($Script:LASTEXITCODE -eq 100) {
            $wsInfo = ''
        } else {
            throw $_
        }
    }

    try {
        $res = $wsInfo[3].split(':')[0].trim()
    } catch {
        $res = ''
    }

    return $res
}

function tfs-get-lastWorkspaceChangeset {
    param (
        $path
    )

    $oldLocation = Get-Location
    Set-Location $path
    $wsInfo = execute-native "& `"$(_get-tfPath)`" history . /recursive /stopafter:1 -version:W /noprompt"
    Set-Location $oldLocation
    return $wsInfo
}