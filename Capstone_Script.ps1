<# Install neccessary modules

Install-Module -Name Az -Scope CurrentUser
Install-Module -Name AzTable -Scope CurrentUser

#>

#Connect to Azure Account
#Uses Az PowerShell
$cred = Get-Credential
Connect-AzAccount -Credential $cred

#Get directory to save files to
$directory = Read-Host -Prompt "Please enter a directory to save the files in"

#Export Azure Activity Log to CSV
Get-AzLog | Export-Csv -Path $directory + "\AzureActivity.csv"

#List all VMs
Get-AzVM | Export-Csv -Path $directory + "\AzureVMs.csv"

#Get all Disks
Get-AzDisk | Export-Csv -Path $directory + "\AzureDisks.csv"

#List all resources
Get-AzResource | Export-Csv -Path $directory + "AzureResources.csv"

#Uses Az.Storage
#Lists all storage accounts in a subscription
Get-AzStorageAccount | Select StorageAcccountName | Export-Csv -Path $directory + "AzureStorageAccounts.csv"


#Get a storage account
$resourceGroup = Read-Host -Prompt "What is the resource group?"
$storageAccountName = Read-Host -Prompt "What is the storage account name?"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

#Create a new storage context
$storageContext = $storageAccount.Context

#Uses Az.Table (Can't use AzureRM in script)

#Get Linux Syslogs
$syslogTable = (Get-AzStorageTable -Name LinuxSyslogVer2v0 -Context $storageContext).CloudTable
Get-AzTableRow -Table $syslogTable | Export-Csv -Path $directory + "\syslog.csv"

#Get Windows Event Logs
$winEvtTable = (Get-AzStorageTable -Name WADWindowsEventLogsTable -Context $storageContext).CloudTable
Get-AzTableRow -Table $winEvtTable | Export-Csv -Path $directory + "\winevt.csv"

#Get storage analytics logs
Get-AzStorageBlob -Blob "*.log" -Container '$logs' -Context $storageContext | Get-AzStorageBlobContent -Destination $directory + "\SA Logging"

#Get NSG Flow logs
Get-AzStorageBlob -Context $context -Container 'insights-logs-networksecuritygroupflowevent' -Blob *.json | Get-AzStorageBlobContent -Destination $directory + "\NSG Logs"
#use get-content and pipe to ConvertFrom-Json


#Take a Azure Disk Snapshot
$resourceGroupName = Read-Host -Prompt "What is the resource group?"
$location = Read-Host -Prompt "What is the location?"
$vmName = Read-Host -Prompt "What is the name of the VM?"
$snapshotName = Read-Host -Prompt "What is the name for the snapshot, no spaces please"

$vm = Get-AzVM -ResourceGroupName $resourcegroupName -Name $vmName
$snapshot = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName


#Azure AD Logs


#Requires AzureADPreview module

#Connect to Azure AD
$tenantId = Read-Host -Prompt "What is the tenant ID?"
Connect-AzureAD -TenantId $tenantId

#Register Azure AD App
$appName = "Capstone_Script_Actual"
$appUri = "https://localhost"
$myapp = New-AzureADApplication -DisplayName $appName -IdentifierUris $appUri
$startdate = Get-Date
$enddate = $startdate.AddYears(3)
$aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $myapp.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startdate -EndDate $enddate
Install-Module MSCloudIdUtils
Import-Module -Name MSCloudIdUtils
Install-MSCloudIdUtilsModule
$cert = New-SelfSignedCertificate -Subject "CN=MSGraph_ReportingAPI" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
Export-Certificate -Cert $cert -FilePath "C:\Reporting\MSGraph_ReportingAPI.cer"
$clientId = Read-Host -Prompt "What is the App Client ID?"

$accessToken = Get-MSCloudIdMsGraphAccessTokenFromCert -TenantDomain $tenantId -ClientId $clientId -Certificate (dir Cert:\CurrentUser\my\"$cert.Thumbprint")

#Get Azure AD Sign-in Audit log
#Get-AzureADAuditSignInLogs -All $true | Export-Csv -Path $directory + "\AzureADSignIns.csv"

#Get Azure AD Audit Logs
#Get-AzureAdAuditDirectoryLogs -All $true | Export-Csv -Path $directory + "\AzureADAudit.csv"

#Get all Azure AD Users
#Get-AzureADUser -All $true | Export-Csv -Path $destination + "\AzureADUsers.csv"
#


#Look into Get-AzureStorageServiceLoggingProperty
# "" Get-AzureStorageShareStoredAccessPolicy
# "" "" StoragetableAccessPolicy

