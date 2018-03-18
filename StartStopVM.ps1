#StartStopVM
Param (

    [Parameter(Mandatory=$true)]

    [object] $SubscriptionId,

    [Parameter(Mandatory=$true)]

    [object] $ResourceGroupName,

    [Parameter(Mandatory=$true)]

    [object] $Name,

    [Parameter(Mandatory=$true)]

    [string] $Action

)

 

# Get login credential asset

$azCredential = Get-AutomationPSCredential -Name "AutoCredential1" # $Automation account AzureCredentialAsset 'AutoAcctDev1'

# Login to Azure

$null = Login-AzureRmAccount -Credential $azCredential # -ErrorAction Stop

# Select the subscription

$null = Select-AzureRmSubscription -SubscriptionId $SubscriptionId #-ErrorAction Stop

 

Write-Output ("Performing action '{0}' against virtual machine '{1}'." -f $Action, $Name)

 

switch ($Action) {

    'start' { Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $Name  } #-ErrorAction Stop

    'stop'  { Stop-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $Name -Force } # -ErrorAction Stop

}