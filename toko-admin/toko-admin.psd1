@{
    RootModule        = 'toko-admin'
    GUID              = 'a3de762d-9ea0-43b5-9476-3ea8bf8b1d93'
    Author            = 'Todor Mitskovski'
    Copyright         = '(c) 2018 Todor Mitskovski. All rights reserved.'
    Description       = 'More user friendly and powerful administration commands.'
    PowerShellVersion = '5.1'
    CLRVersion        = '4.0'
    FunctionsToExport = 'iis-get-websitePort', 'iis-show-appPoolPid', 'iis-get-usedPorts', 'iis-get-appPoolApps', 'iis-create-appPool', 'iis-get-appPools', 'iis-delete-appPool', 'iis-create-website', 'iis-get-siteAppPool', 'iis-test-isPortFree', 'iis-add-sitePort', 'iis-test-isSiteNameDuplicate', 'iis-get-subAppName', 'iis-rename-website', 'iis-new-subApp', 'iis-remove-subApp', 'iis-set-sitePath', 'clear-nugetCache', 'os-popup-notification', 'os-test-isPortFree', 'execute-native', 'unlock-allFiles', 'sql-delete-database', 'sql-rename-database', 'sql-get-dbs', 'sql-get-items', 'sql-update-items', 'sql-insert-items', 'sql-delete-items', 'sql-test-isDbNameDuplicate', 'sql-copy-db', 'sql-create-login', 'sql-delete-login', 'tfs-get-workspaces', 'tf-query-workspaces', 'tfs-delete-workspace', 'tfs-create-workspace', 'tfs-rename-workspace', 'tfs-create-mappings', 'tfs-checkout-file', 'tfs-get-latestChanges', 'tfs-undo-pendingChanges', 'tfs-show-pendingChanges', 'tfs-get-workspaceName', 'tfs-get-branchPath', 'tfs-get-lastWorkspaceChangeset', 'iis-get-binding', 'iis-set-binding', 'Add-ToHostsFile', 'Remove-FromHostsFile', 'get-sqlClient', 'iis-find-site'
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = '*'
    ModuleVersion     = '1.1.3'
    RequiredModules   = @(
        @{ModuleName = 'toko-posh-dev-tools'; ModuleVersion = '0.1.0'; MaximumVersion = '0.*' }
    )
    PrivateData       = @{
        PSData = @{
            ProjectUri   = 'https://github.com/todorm85/toko-admin'
            ReleaseNotes = @'
            1.1.3
                iis-find-site now respects subApps
            1.1.2
                Fixed not found IIS drive when getting all sites
            1.1.1
                Getting branch sometimes gets fake result for specific location where it should return none.
            1.1.0
                TF.exe error stream is redirected to powershell error stream.
            1.0.0
                New api via global object
            0.3.0
                Feature
                    iis-find-site
                    Find site name by path.
            0.2.1
                Fixes
                    Errors from native operations improper error code handling when nesting scopes of modules.
            0.2.0
                Features
                    Added SqlClient object API
                Bugfixes
                    Removed errors when unlocking files
            0.1.3
                Add user configuration for tfPath
                Fix: default credentials not found for sql and server name for TFS
            0.1.2
                Fixed unlocking files
            0.1.1
                Ability to quickly add entries to hosts file. Add-ToHostsFile and Remove-FromHostsFile
            0.1.0
                Initial release containing commonly used administration tasks on windows automated.
                Contains scripts for MSSQL, IIS, Windows, Nuget, TFS.
'@
        }
    }
}
