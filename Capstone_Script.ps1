#Connect to Azure Account
Connect-AzAccount

#Export Azure Activity Log to CSV
#az monitor activity-log list | ConvertFrom-Json | Export-Csv -Path C:\AzureActivityLog1.csv
Get-AzLog | Export-Csv -Path C:\users\cello\Desktop\AzureActivity.csv

#List all VMs
Get-AzVM | Export-Csv -Path C:\users\cello\Desktop\AzureVMs.csv

#Get all Disks
Get-AzDisk | Export-Csv -Path C:\users\cello\Desktop\AzureDisks.csv


#List all resources
Get-AzResource | Export-Csv -Path C:\users\cello\Desktop\AzureResources.csv

#Get storage blob log
#Get-AzureStorageBlob -Container '$logs'

#Connect to Azure AD
#Connect-AzureAD
#Get Azure AD Sign-in Audit log
#Uses AzureAD Module
#Get-AzureADAuditSignInLogs -All | Export-Csv -Path C:\Users\cello\Desktop\AzureADSignIns.csv
