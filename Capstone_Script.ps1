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

#Get storage blob log
#Get-AzureStorageBlob -Container '$logs'

#Requires AzureADPreview module

#Connect to Azure AD
Connect-AzureAD

#Get Azure AD Sign-in Audit log
#Get-AzureADAuditSignInLogs -All $true | Export-Csv -Path $directory + "\AzureADSignIns.csv"

#Get Azure AD Audit Logs
#Get-AzureAdAuditDirectoryLogs -All $true | Export-Csv -Path $directory + "\AzureADAudit.csv"

#Uses Azure.Storage
#Lists all storage accounts in a subscription
Get-AzStorageAccount | Select StorageAcccountName | Export-Csv -Path $directory + "AzureStorageAccounts.csv"

#Get a storage account
$resourceGroup = "capstone"
$storageAccountName = "capstoneblob1"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

#Create a new storage context
#Get the storage key
$storageKey = Read-Host -Prompt "Please enter the key for the storage account"

$storageContext = New-AzureStorageContext -StorageAccountName "capstoneblob1" -StorageAccountKey $storageKey

#Get Linux Syslogs

Get-AzureStorageTable -Name "LinuxSyslogVer2v0" -Context $context

#Get Windows Event Logs
Get-AzureStorageTable -Name "WADWindowsEventLogsTable" -Context $context

#Look into Get-AzureStorageServiceLoggingProperty
# "" Get-AzureStorageShareStoredAccessPolicy
# "" "" StoragetableAccessPolicy