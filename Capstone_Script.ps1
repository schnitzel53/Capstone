#Connect to Azure Account
$cred = Get-Credential -Message "Please enter the credentials to connect to the Azure subscrription. Credentials must be security administrator or higher."
Connect-AzAccount -Credential $cred

#Get directory to save files to
$directory = Read-Host -Prompt "Please enter a directory to save the files in"

cls 

function Menu(){
    Write-Host ""
    Write-Host "Azure Options:"
    Write-Host "Please run option 15 before the first use"
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
    Write-Host "11. Register an Azure AD app (Required for options 12-14)"
    Write-Host "12. Retrieve a list of all Azure AD users"
    Write-Host "13. Retrieve the Azure AD audit log"
    Write-Host "14. Retrieve the Azure AD sign in log"
    Write-Host "15. Install the neccesary modules (PLEASE RUN BEFORE FIRST USE)"
    Write-Host "16. Quit"

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
        15 {InstallAzureModules}
        16 {Write-Host "Exiting"; sleep 1; exit(0)}
        default {Write-Host "Invalid choice"; sleep 3; menu}
    }
}

#Export Azure Activity Log to CSV
function AzureActivityLog(){
    Write-Host "Exporting the Azure Activity Log"
    $activityFile = -join("$directory", "\AzureActivity.csv")
    Get-AzLog | Export-Csv -Path $activityFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $activityFile | Tee-Object -FilePath (-join("$directory", "\AzureActivityLogHash.txt"))

    Write-Host "Azure Activity log downloaded to $activityFile"
    sleep 5
    menu
}

#List all VMs
function AzureVmList(){
    $azVmFile = -join("$directory", "\AzureVMs.csv")
    Get-AzVM | Export-Csv -Path $azVmFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azVmFile | Tee-Object -FilePath (-join("$directory","\AzureVMsHash.txt"))

    Write-Host "Azure VM list downloaded to $azVmFile"
    sleep 5
    menu
}

#Get all Disks
function AzureDisks(){
    $azDisksFile = -join("$directory","\AzureDisks.csv")
    Get-AzDisk | Export-Csv -Path $azDisksFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azDisksFile | Tee-Object -FilePath (-join("$directory", "\AzureDisksHash.txt"))

    Write-Host "Azure Activity Log downloaded to $azDisksFile"
    sleep 5
    menu
}

#List all resources
function AzureResources(){
    $azResourcesFile = -join("$directory", "\AzureResources.csv")
    Get-AzResource | Export-Csv -Path $azResourcesFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azResourcesFile | Tee-Object -FilePath (-join("$directory","\AzureResourcesHash.txt"))

    Write-Host "Azure resources list downloaded to $azResourcesFile"
    sleep 5
    menu
}

#Lists all storage accounts in a subscription
function AzureStorage(){
    $azStorageFile = -join("$directory", "\AzureStorageAccounts.csv")
    Get-AzStorageAccount | Select StorageAcccountName | Export-Csv -Path $azStorageFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azStorageFile | Tee-Object -FilePath (-join("$directory","\AzureStorageAccountsHash.txt"))

    Write-Host "Azure storage accounts list downloaded to $azStorageFile"
    sleep 5
    menu
}

#Get Syslogs stored in a storage account
function Syslog(){
    $azSyslogFile = -join("$directory", "\AzureSyslog.csv")
    $syslogResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $syslogStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $syslogStorageAccount = Get-AzStorageAccount -ResourceGroupName $syslogResourceGroup -Name $syslogStorageAccountName

    #Create a new storage context
    $syslogStorageContext = $syslogStorageAccount.Context

    #Get Linux Syslogs
    $syslogTable = (Get-AzStorageTable -Name LinuxSyslogVer2v0 -Context $syslogStorageContext).CloudTable
    Get-AzTableRow -Table $syslogTable | Export-Csv -Path $azSyslogFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azSyslogFile | Tee-Object -FilePath (-join("$directory","\AzureSyslogHash.txt"))

    Write-Host "Azure Linux VM Syslogs downloaded to $azSyslogFile"
    sleep 5
    menu
}


#Get Windows Event Logs
function Evtlog(){
    $azEvtFile = -join("$directory","\AzureWinEvt.csv")
    $winEvtResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $winEvtStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $winEvtStorageAccount = Get-AzStorageAccount -ResourceGroupName $winEvtResourceGroup -Name $winEvtStorageAccountName

    #Create a new storage context
    $winEvtStorageContext = $winEvtStorageAccount.Context

    $winEvtTable = (Get-AzStorageTable -Name WADWindowsEventLogsTable -Context $winEvtStorageContext).CloudTable
    Get-AzTableRow -Table $winEvtTable | Export-Csv -Path $azEvtFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $azEvtFile | Tee-Object -FilePath (-join("$directory","\WindowsEventLogHash.txt"))

    Write-Host "Azure Windows VM Event Logs downloaded to $azEvtFile"
    sleep 5
    menu
}

function StorageAnalyticsLogs(){
    $saFile = -join("$directory","\SA Logging\")
    mkdir $saFile
    $saResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $saStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $saStorageAccount = Get-AzStorageAccount -ResourceGroupName $saResourceGroup -Name $saStorageAccountName

    #Create a new storage context
    $saStorageContext = $saStorageAccount.Context

    #Get storage analytics logs
    Get-AzStorageBlob -Blob "*.log" -Container '$logs' -Context $saStorageContext | Get-AzStorageBlobContent -Destination $saFile

    Write-Host "Azure Storage Analytics logs downloaded to $saFile"
    sleep 5
    menu
}

#Get NSG Flow logs
function NsgFlowLogs(){
    $nsgFile = -join("$directory","\NSG Logs\")
    mkdir $nsgFile
    $nsgResourceGroup = Read-Host -Prompt "What is the resource group for the storage account where the logs are stored?"
    $nsgStorageAccountName = Read-Host -Prompt "What is the storage account name where the logs are stored?"
    $nsgStorageAccount = Get-AzStorageAccount -ResourceGroupName $nsgResourceGroup -Name $nsgStorageAccountName

    #Create a new storage context
    $nsgStorageContext = $nsgStorageAccount.Context

    Get-AzStorageBlob -Context $nsgStorageContext -Container 'insights-logs-networksecuritygroupflowevent' -Blob *.json | Get-AzStorageBlobContent -Destination $nsgFile

    Write-Host "Azure NSG flow logs downloaded to $nsgFile"
    sleep 5
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
    Write-Host "Available disks to snapshot:"
    foreach ($disk in $availableDisks){
        $disk.Name
    }
    $diskChoice = Read-Host -Prompt "Would you like to snapshot the [O]S disk or the [D]ata disks?"
    if ($diskChoice == "d" or $diskChoice == "D"){
        $snapshot = New-AzSnapshotConfig -SourceUri $snapVM.StorageProfile.DataDisk.ManagedDisk.Id -Location $snapLocation -CreateOption copy
    }
    elseif ($diskChoice == "o" or $diskChoice == "O"){
        $snapshot = New-AzSnapshotConfig -SourceUri $snapVM.StorageProfile.OsDisk.ManagedDisk.Id -Location $snapLocation -CreateOption copy
    }

    else{
        Write-Host "Invalid choice"
        Menu
    }
    New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $snapResourceGroupName

    Write-Host "Azure VM snapshot made with the name "$snapshotName""
    Write-Host "Please log in to the Azure portal and export the snapshot for further analysis"
    sleep 5
    menu
}

#Azure AD Logs

function RegisterAzureADApp(){
    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Register Azure AD App
    $appName = "Azure_Log_App"
    $appUri = "https://localhost"
    $myapp = New-AzureADApplication -DisplayName $appName -IdentifierUris $appUri
    $startdate = Get-Date
    $enddate = $startdate.AddMonths(3)
    $aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $myapp.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startdate -EndDate $enddate
    #Install-Module MSCloudIdUtils
    Import-Module -Name MSCloudIdUtils
    #Install-MSCloudIdUtilsModule
    $cert = New-SelfSignedCertificate -Subject "CN=MSGraph_ReportingAPI" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
    Export-Certificate -Cert $cert -FilePath (-join("$directory","AzureLogAppCert.cer"))
    $clientId = Read-Host -Prompt "What is the App Client ID? (found in the Azure portal under Azure AD\App registrations\Azure_Log_App)"
    $accessToken = Get-MSCloudIdMsGraphAccessTokenFromCert -TenantDomain $tenantId -ClientId $clientId -Certificate (dir Cert:\CurrentUser\my\"$cert.Thumbprint")

    Write-Host "Azure AD app successfully registered"
    Write-Host "Please log in to Azure AD for the subscription and assign the app the appropriate API permissions"
    Write-Host "Appropriate app permissions and certificate location are located in AzureAppPermissions.txt"

    sleep 5
    menu
}

function AzureADSignIns(){
    $adSigninFile = -join("$directory","\AzureADSignIns.csv")
    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId
    

    #Get Azure AD Sign-in Audit log
    Get-AzureADAuditSignInLogs -All $true | Export-Csv -Path $adSigninFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $adSigninFile | Tee-Object -FilePath (-join("$directory","\AzureADSignInsHash.txt"))

    Write-Host "Azure AD Sign-in Logs downloaded to $adSigninFile"
    sleep 5
    menu
}

function AzureADAudit(){
    $adAuditFile = -join("$directory","\AzureADAudit.csv")
    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId

    #Get Azure AD Audit Logs
    Get-AzureADAuditDirectoryLogs -All $true | Export-Csv -Path $adAuditFile

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $adAuditFile | Tee-Object -FilePath (-join("$directory","\AzureADAuditHash.txt"))

    Write-Host "Azure AD Audit Logs downloaded to $adAuditFile"
    sleep 5
    menu
}

function AzureADUsers(){
    #Connect to Azure AD
    $tenantId = Read-Host -Prompt "What is the tenant ID?"
    Connect-AzureAD -TenantId $tenantId
    $adUsersPath = -join("$destination","\AzureADUsers.csv")

    #Get all Azure AD Users
    Get-AzureADUser -All $true | Export-Csv -Path $adUsersPath

    #Obtain aquisition hash
    Get-FileHash -Algorithm SHA256 $adUsersPath | Tee-Object -FilePath (-join("$directory","AzureADUsersHash.txt"))

    Write-Host "Azure AD users downloaded to $adUsersPath"
    sleep 5
    menu
}

function InstallAzureModules(){
    # Install neccessary modules
    Install-Module -Name Az -Scope CurrentUser
    Install-Module -Name AzTable -Scope CurrentUser
    Install-Module -Name AzureADPreview -Scope CurrentUser
    Install-Module -Name MSCloudIdUtils -Scope CurrentUser
}

Menu