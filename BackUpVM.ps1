#####################################################################
# Setup_VMBackupv1.ps1
# reference document : SOP_v1_Azure_VM_CREATE-ENCRYPT-BACK-RESTORE.doc
# encrypt an ezisting vm 
####################################################################
##########################################
# Setup backup VM and trigger backup.
#########################################
$vm = Read-Host -Prompt 'Enter name of the guest to be placed into backup rotation (you will also be given option to initiate backup)'
#########################################
# Set vault context 
#########################################
$vault = Get-AzureRmRecoveryServicesVault -Name "RecoveryVaultEastLocal" 
$rg = "infrastructureServices"
Set-AzureRmRecoveryServicesVaultContext -vault $vault 
#Set VM Backup Policy
$pol=Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "Daily10PMEST"
Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -Name $vm -ResourceGroupName $rg

#########################################
# Ask if you want to trigger backup now or wait for Policy time?
#########################################
Function ContinuteOrBreak
{
 write-host -nonewline "Continue? (Y/N) "
 $response = read-host
 if ( $response -ne "Y" ) { exit }
}
Write-Host -NoNewline "$vm added Backup Rotation. Would you like to Trigger an backup now?" | ContinuteOrBreak
#Initialte a manual Backup
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -Name $vm
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
    