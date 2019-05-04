@{
    RootModule        = 'toko-admin'
    GUID              = 'a3de762d-9ea0-43b5-9476-3ea8bf8b1d93'
    Author            = 'Todor Mitskovski'
    Copyright         = '(c) 2018 Todor Mitskovski. All rights reserved.'
    Description       = 'More user friendly and powerful administration commands.'
    PowerShellVersion = '5.1'
    CLRVersion        = '4.0'
    FunctionsToExport = 'iis-get-websitePort', 'iis-show-appPoolPid', 'iis-get-usedPorts', 'iis-get-appPoolApps', 'iis-create-appPool', 'iis-get-appPools', 'iis-delete-appPool', 'iis-create-website', 'iis-get-siteAppPool', 'iis-test-isPortFree', 'iis-add-sitePort', 'iis-test-isSiteNameDuplicate', 'iis-get-subAppName', 'iis-rename-website', 'iis-new-subApp', 'iis-remove-subApp', 'iis-set-sitePath', 'clear-nugetCache', 'os-popup-notification', 'os-test-isPortFree', 'execute-native', 'unlock-allFiles', 'sql-delete-database', 'sql-rename-database', 'sql-get-dbs', 'sql-get-items', 'sql-update-items', 'sql-insert-items', 'sql-delete-items', 'sql-test-isDbNameDuplicate', 'sql-copy-db', 'sql-create-login', 'sql-delete-login', 'tfs-get-workspaces', 'tf-query-workspaces', 'tfs-delete-workspace', 'tfs-create-workspace', 'tfs-rename-workspace', 'tfs-create-mappings', 'tfs-checkout-file', 'tfs-get-latestChanges', 'tfs-undo-pendingChanges', 'tfs-show-pendingChanges', 'tfs-get-workspaceName', 'tfs-get-branchPath', 'tfs-get-lastWorkspaceChangeset', 'iis-get-binding', 'iis-set-binding', 'Add-ToHostsFile', 'Remove-FromHostsFile', 'get-sqlClient'
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = '*'
    ModuleVersion     = '0.2.0'
    RequiredModules   = @(
        @{ModuleName = 'toko-posh-dev-tools'; ModuleVersion = '0.1.0'; MaximumVersion = '0.*' }
    )
    PrivateData       = @{
        PSData = @{
            ProjectUri   = 'https://github.com/todorm85/toko-admin'
            ReleaseNotes = @'
## 0.1.3
Add user configuration for tfPath
Fix: default credentials not found for sql and server name for TFS
## 0.1.2
Fixed unlocking files
## 0.1.1
Ability to quickly add entries to hosts file. Add-ToHostsFile and Remove-FromHostsFile
## 0.1.0
Initial release containing commonly used administration tasks on windows automated.
Contains scripts for MSSQL, IIS, Windows, Nuget, TFS.
'@
        }
    }
}
