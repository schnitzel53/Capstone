#Connect to Azure Account
#Uses Az PowerShell
Connect-AzAccount

#Get directory to save files to
$directory = Read-Host -Prompt "Please enter a directory to save the files in"

#Export Azure Activity Log to CSV
#az monitor activity-log list | ConvertFrom-Json | Export-Csv -Path C:\AzureActivityLog1.csv
Get-AzLog | Export-Csv -Path $directory\AzureActivity.csv

#List all VMs
Get-AzVM | Export-Csv -Path $directory + "\AzureVMs.csv"

#Get all Disks
Get-AzDisk | Export-Csv -Path $directory + "\AzureDisks.csv"


#List all resources
Get-AzResource | Export-Csv -Path $directory + "AzureResources.csv"


#Requires AzureADPreview module

#Connect to Azure AD
Connect-AzureAD

#Get Azure AD Sign-in Audit log
#Get-AzureADAuditSignInLogs -All $true | Export-Csv -Path $directory + "\AzureADSignIns.csv"

#Get Azure AD Audit Logs
#Get-AzureAdAuditDirectoryLogs -All $true | Export-Csv -Path $directory + "\AzureADAudit.csv"

#Uses AzStorage
#Lists all storage accounts in a subscription
Get-AzStorageAccount | Select StorageAcccountName | Export-Csv -Path $directory + "AzureStorageAccounts.csv"

#Get a storage account
$resourceGroup = "capstone"
$storageAccountName = "capstoneblob1"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

#Create a new storage context
$storageContext = $storageAccount.Context

#Uses AzTable (Can't use AzureRM in script)

#Get Linux Syslogs
$syslogTable = (Get-AzStorageTable -Name LinuxSyslogVer2v0 -Context $storageContext).CloudTable
Get-AzTableRow -Table $syslogTable | Export-Csv -Path $directory + "\syslog.csv"

#Get Windows Event Logs
$winEvtTable = (Get-AzStorageTable -Name WADWindowsEventLogsTable -Context $storageContext).CloudTable
Get-AzTableRow -Table $winEvtTable | Export-Csv -Path $directory + "\winevt.csv"

#Get storage analytics logs
Get-AzStorageBlob -Blob "*.log" -Container '$logs' -Context $storageContext | Get-AzStorageBlobContent -Destination $directory + "\"

#Get NSG Flow logs
Get-AzStorageBlob -Context $context -Container 'insights-logs-networksecuritygroupflowevent' -Blob *.json | Get-AzStorageBlobContent -Destination $directory + "\"


#Look into Get-AzureStorageServiceLoggingProperty
# "" Get-AzureStorageShareStoredAccessPolicy
# "" "" StoragetableAccessPolicy