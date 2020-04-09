﻿<# Install neccessary modules

Install-Module -Name Az -Scope CurrentUser
Install-Module -Name AzTable -Scope CurrentUser
Install-Module -Name AzureADPreview -Scope CurrentUser
Install-Module MSCloudIdUtils
Install-MSCloudIdUtilsModule

#>

<# Import the neccessary modules to potentially speed up program

Import-Module -Name Az -Scope CurrentUser
Import-Module -Name AzTable -Scope CurrentUser
Import-Module -Name AzureADPreview -Scope CurrentUser
Import-Module MSCloudIdUtils
Import-MSCloudIdUtilsModule

#>

#Connect to Azure Account
#Uses Az PowerShell
$cred = Get-Credential -Message "Please enter the credentials to connect to the Azure subscrription"
Connect-AzAccount -Credential $cred

#Get directory to save files to
$directory = Read-Host -Prompt "Please enter a directory to save the files in"

function Menu(){
    cls
    Write-Host "Azure Options:"
    Write-Host "1. Get Azure Activity log"
    Write-Host "2. Get a list of all Azure VMs"
    Write-Host "3. Get a list of all disks for Azure VMs"
    Write-Host "4. Get a list of all Azure resources"
    Write-Host "5. Get a list of all storage accounts"
    Write-Host "6. Retrieve syslogs for Linux VMs logging to storage accounts"
    Write-Host "7. Retrieve Windows Event Logs for Windows VMs logging to storage accounts"
    Write-Host "8. Retreive storage account logs"
    Write-Host "9. Retrieve network security group flow logs"
    Write-Host "10. Take a snapshot of an Azure disk"
    Write-Host "11. Register an Azure AD app (Required for options 11-13)"
    Write-Host "12. Retrieve a list of all Azure AD users"
    Write-Host "13. Retrieve the Azure AD audit log (Requires Azure AD P2)"
    Write-Host "14. Retreive the Azure AD sign in log (Requires Azure AD P2)"
    Write-Host "15. Quit"

    $userChoice = Read-Host -Prompt "Please select an option"

    Switch ($userChoice){
        1 {AzureActivityLog}
        2 {AzureVmList}
        3 {AzureDisks}
        4 {AzureResources}
        5 {AzureStorage}
        6 {Syslog}
        7 {Evtlog}
        8 {StorageAnalyticsLogs}
        9 {NsgFlowLogs}
        10 {AzureSnapshot}
        11 {RegisterAzureADApp}
        12 {AzureADUsers}
        13 {AzureADAudit}
        14 {AzureADSignIns}
        15 {exit(0)}
        default {Write-Host "Invalid choice"; sleep 3; menu}
    }
}

#Export Azure Activity Log to CSV
function AzureActivityLog(){
    Get-AzLog | Export-Csv -Path $directory + "\AzureActivity.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $directory + "\AzureActivity.csv" | Tee-Object -FilePath "$directory + "\AzureActivityLogHash.txt""

    Write-Host "Azure Activity log downloaded to "$directory" +\AzureActivity.csv"
    sleep 3
    menu
}

#List all VMs
function AzureVmList(){
    Get-AzVM | Export-Csv -Path $directory + "\AzureVMs.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $directory + "\AzureVMs.csv" | Tee-Object -FilePath "$directory + "\AzureVMsHash.txt""

    Write-Host "Azure VM list downloaded to "$directory" +\AzureVMs.csv"
    sleep 3
    menu
}

#Get all Disks
function AzureDisks(){
    Get-AzDisk | Export-Csv -Path $directory + "\AzureDisks.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $directory + "\AzureDisks.csv" | Tee-Object -FilePath "$directory + "\AzureDisksHash.txt""

    Write-Host "Azure Activity Log downloaded to "$directory" +\AzureDisks.csv"
    sleep 3
    menu
}

#List all resources
function AzureResources(){
    Get-AzResource | Export-Csv -Path $directory + "AzureResources.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureResources.csv" | Tee-Object -FilePath "$directory + "\AzureResourcesHash.txt""

    Write-Host "Azure resources list downloaded to "$directory" +\AzureResources.csv"
    sleep 3
    menu
}

#Lists all storage accounts in a subscription
function AzureStorage(){
    Get-AzStorageAccount | Select StorageAcccountName | Export-Csv -Path $directory + "AzureStorageAccounts.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureStorageAccounts.csv" | Tee-Object -FilePath "$directory + "\AzureStorageAccountsHash.txt""

    Write-Host "Azure storage accounts list downloaded to "$directory" +\AzureStorageAccounts.csv"
    sleep 3
    menu
}

#Get Syslogs stored in a storage account
function Syslog(){
    $syslogResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $syslogStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $syslogStorageAccount = Get-AzStorageAccount -ResourceGroupName $syslogResourceGroup -Name $syslogStorageAccountName

    #Create a new storage context
    $syslogStorageContext = $syslogStorageAccount.Context

    #Get Linux Syslogs
    $syslogTable = (Get-AzStorageTable -Name LinuxSyslogVer2v0 -Context $syslogStorageContext).CloudTable
    Get-AzTableRow -Table $syslogTable | Export-Csv -Path $directory + "\AzureSyslog.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureSyslog.csv" | Tee-Object -FilePath "$directory + "\AzureSyslogHash.txt""

    Write-Host "Azure Linux VM Syslogs downloaded to "$directory" +\AzureSyslog.csv"
    sleep 3
    menu
}


#Get Windows Event Logs
function Evtlog(){

    $winEvtResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $winEvtStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $winEvtStorageAccount = Get-AzStorageAccount -ResourceGroupName $winEvtResourceGroup -Name $winEvtStorageAccountName

    #Create a new storage context
    $winEvtStorageContext = $winEvtStorageAccount.Context

    $winEvtTable = (Get-AzStorageTable -Name WADWindowsEventLogsTable -Context $winEvtStorageContext).CloudTable
    Get-AzTableRow -Table $winEvtTable | Export-Csv -Path $directory + "\AzureWinEvt.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureWinEvt.csv" | Tee-Object -FilePath "$directory + "\WindowsEventLogHash.txt""

    Write-Host "Azure Windows VM Event Logs downloaded to "$directory" +\AzureWinEvt.csv"
    sleep 3
    menu
}

function StorageAnalyticsLogs(){

    $saResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $saStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $saStorageAccount = Get-AzStorageAccount -ResourceGroupName $saResourceGroup -Name $saStorageAccountName

    #Create a new storage context
    $saStorageContext = $saStorageAccount.Context

    #Get storage analytics logs
    Get-AzStorageBlob -Blob "*.log" -Container '$logs' -Context $saStorageContext | Get-AzStorageBlobContent -Destination $directory + "\SA Logging"

    Write-Host "Azure Storage Analytics logs downloaded to "$directory" +\SA Logging"
    sleep 3
    menu
}

#Get NSG Flow logs
function NsgFlowLogs(){

    $nsgResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $nsgStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $nsgStorageAccount = Get-AzStorageAccount -ResourceGroupName $nsgResourceGroup -Name $nsgStorageAccountName

    #Create a new storage context
    $nsgStorageContext = $nsgStorageAccount.Context

    Get-AzStorageBlob -Context $nsgStorageContext -Container 'insights-logs-networksecuritygroupflowevent' -Blob *.json | Get-AzStorageBlobContent -Destination $directory + "\NSG Logs"

    Write-Host "Azure NSG flow logs downloaded to "$directory" +\NSG Logs"
    sleep 3
    menu
}

#Take a Azure Disk Snapshot
function AzureSnapshot(){

    $snapResourceGroupName = Read-Host -Prompt "What is the resource group for the disk to be snapshotted?"
    $snapLocation = Read-Host -Prompt "What is the regional location of the VM?"
    $snapVmName = Read-Host -Prompt "What is the name of the VM?"
    $snapshotName = Read-Host -Prompt "What is the name for the snapshot, no spaces please"
    $snapVM = Get-AzVM -ResourceGroupName $snapResourceGroupName -Name $snapVmName
    $availableDisks = $snapVM.StorageProfile.DataDisks + $snapVM.StorageProfile.OsDisk
    $availableDisks
    Read-Host
    $snapshot = New-AzSnapshotConfig -SourceUri $snapVM.StorageProfile.OsDisk.ManagedDisk.Id -Location $snapLocation -CreateOption copy
    New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $snapResourceGroupName

    Write-Host "Azure VM snapshot made with the name "$snapshotName""
    Write-Host "Please log in to the Azure portal and export the snapshot for further analysis"
    sleep 3
    menu
}

#Azure AD Logs

function RegisterAzureADApp(){
    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Register Azure AD App
    $appName = "Capstone_Script_Actual"
    $appUri = "https://localhost"
    $myapp = New-AzureADApplication -DisplayName $appName -IdentifierUris $appUri
    $startdate = Get-Date
    $enddate = $startdate.AddMonths(3)
    $aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $myapp.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startdate -EndDate $enddate
    #Install-Module MSCloudIdUtils
    Import-Module -Name MSCloudIdUtils
    #Install-MSCloudIdUtilsModule
    $cert = New-SelfSignedCertificate -Subject "CN=MSGraph_ReportingAPI" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
    Export-Certificate -Cert $cert -FilePath "C:\Reporting\MSGraph_ReportingAPI.cer"
    $clientId = Read-Host -Prompt "What is the App Client ID?"
    $accessToken = Get-MSCloudIdMsGraphAccessTokenFromCert -TenantDomain $tenantId -ClientId $clientId -Certificate (dir Cert:\CurrentUser\my\"$cert.Thumbprint")

    Write-Host "Azure AD app successfully registered"
    Write-Host "Please log in to Azure AD for the subscription and assign the app the appropriate API permissions"
    Write-Host "Appropriate app permissions are located in AppPermissions.txt"

    sleep 5
    menu
}

function AzureADSignIns(){

    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Get Azure AD Sign-in Audit log
    Get-AzureADAuditSignInLogs -All $true | Export-Csv -Path $directory + "\AzureADSignIns.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureADSignIns.csv" | Tee-Object -FilePath "$directory + "\AzureADSignInsHash.txt""

    Write-Host "Azure Windows VM Event Logs downloaded to "$directory" +\AzureADSignIns.csv"
    sleep 3
    menu
}

function AzureADAudit(){

    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Get Azure AD Audit Logs
    Get-AzureADAuditDirectoryLogs -All $true | Export-Csv -Path $directory + "\AzureADAudit.csv"

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureADAudit.csv" | Tee-Object -FilePath "$directory + "\AzureADAuditHash.txt""

    Write-Host "Azure Windows VM Event Logs downloaded to "$directory" +\AzureADAudit.csv"
    sleep 3
    menu
}

function AzureADUsers(){

    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Get all Azure AD Users
    Get-AzureADUser -All $true | Export-Csv -Path $destination + "\AzureADUsers.csv"
    
    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA1 $directory + "\AzureADUsers.csv" | Tee-Object -FilePath "$directory + "\AzureADUsersHash.txt""

    Write-Host "Azure Windows VM Event Logs downloaded to "$directory" +\AzureADUsers.csv"
    sleep 3
    menu
}
#


#Look into Get-AzureStorageServiceLoggingProperty
# "" Get-AzureStorageShareStoredAccessPolicy
# "" "" StoragetableAccessPolicy

Menu
