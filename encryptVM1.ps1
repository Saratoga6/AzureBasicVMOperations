#####################################################################
#encryptVM1.ps1
#reference document : SOP_v1_Azure_VM_CREATE-ENCRYPT-BACK-RESTORE.doc
# encrypt an existing vm 
####################################################################
#identify the resource group
##############################################
login-AzureRmAccount
$sub = "conEd infrastructure"
$rg = "infrastructureServices"
Select-AzureRmSubscription -SubscriptionName $sub
#########################################
# get keys from vault
#########################################
$kvName =   "kvInfraServBackup2"
$kv  = Get-AzureRmKeyVault  -VaultName $kvName -ResourceGroup $rg
$bek = Get-AzureKeyVaultKey -VaultName $kvName -KeyName "bek"
$kek = Get-AzureKeyVaultKey -VaultName $kvName -KeyName "kek"
#########################################
# get application context
#########################################
$appName = "appBitlocker"
$app   = Get-AzureRmADApplication -DisplayNameStartWith $appName
$secret  = 'qsmqhWfoeN/CVrcr4iyN9dolJqG0RMQ8i15azufTjVo='
#########################################
# encrypt
#########################################
$vm = Read-Host -Prompt 'Enter name of the guest to be encrypted (this maytake approx 10 min)'
#$vm = "a001dpm1"
Set-AzureRmVMDiskEncryptionExtension –ResourceGroupName $rg –VMNAme $vm -Verbose `
–AadClientID $app.ApplicationId -AadClientSecret $secret `
-DiskEncryptionKeyVaultUrl $bek.Key.Kid -DiskEncryptionKeyVaultId $kv.ResourceId`
 -KeyEncryptionKeyUrl      $kek.Key.Kid  -KeyEncryptionKeyVaultId $kv.ResourceId
#########################################
#Verify Disk Encrypted
#########################################
Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName "infrastructureServices" -VMName $vm
