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

class SqlClient {
    [string] hidden $user
    [string] hidden $pass
    [string] hidden $server

    SqlClient($user, $pass, $server) {
        _sql-load-module
        $this.user = $user
        $this.pass = $pass
        $this.server = $server
    }

    [System.Object[]] GetDbs() {
        return sql-get-dbs -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }

    [void] CopyDb([string] $source, [string] $target) {
        sql-copy-db -SourceDBName $source -targetDbName $target -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }

    [void] Delete([string]$dbName) {
        sql-delete-database -dbName $dbName -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }

    [System.Object[]] GetItems([string]$db, [string]$table, [string]$where, [string]$select) {
        return sql-get-items -dbName $db -tableName $table -selectFilter $select -whereFilter $where -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }

    [void] UpdateItems([string]$db, [string]$table, [string]$where, [string]$value) {
        sql-update-items -dbName $db -tableName $table -value $value -whereFilter $where -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }
    
    [void] InsertItems([string]$db, [string]$table, [string]$columns, [string]$values) {
        sql-insert-items -dbName $db -tableName $table -values $values -columns $columns -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }

    [bool] IsDuplicate([string]$dbName) {
        return sql-test-isDbNameDuplicate -dbName $dbName -user $this.user -pass $this.pass -sqlServerInstance $this.server
    }
}

Export-ModuleMember -Function * -Alias *
