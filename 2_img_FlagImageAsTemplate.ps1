########################################################

#CEXX_Image2_FlagImageAsTemplate.ps1

#set image in azure to be a deploable

#

########################################################

# Header Start

# Header version 1

#

#

Login-AzureRmAccount

########################################################

# Selectable Definitions

########################################################

# Select an Azure Subscription

$Sub =

    (Get-AzureRMSubscription |   `

     Out-GridView `

        -Title "Select an Azure Subscription" `

        -PassThru).Name

        #-PassThru).SubscriptionId

#Select-AzureRMSubscription -SubscriptionId $subscriptionId

# Set the Subscription context to limit the number of subsequent choices

Select-AzureRMSubscription -SubscriptionName $sub

# Select an Resource Group under Subscription context above

$rg =

    (Get-AzureRMResourceGroup |Select-Object ResourceGroupName, Location, Tags |`

         Out-GridView `

        -Title "Select an Azure RG ( IS=infrastructureServices  …" `

        -PassThru).ResourceGroupName

#Select VM

$VMObject=

    Get-AzureRMVM `

    | Out-GridView `

        -Title "Select a VM" `

         -PassThru

$vm = $VMObject.Name

# Add resource group context to VM

$VMObject=Get-AzurermVM -ResourceGroupName $rg -Name $vm

<#

$acct = (Get-AzureRmStorageAccount| Select-Object StorageAccountName, ResourceGroupName | `

         Out-GridView `

         -Title "Select StorageAccountName (IS=ceInfraLocal, Dev=appdevelopment1657) " `

         -PassThru).StorageAccountName

 

# Select an Azure Virtual Network $vnet

$vnet = (Get-AzureRmVirtualNetwork | Select-Object Name, ResourceGroupName | `

     Out-GridView `

        -Title "Select vnet name(IS =infrastructureNet, ..." `

        -PassThru).Name

$vnetRG = (Get-AzureRmVirtualNetwork | Select-Object ResourceGroupName ,Name| `

     Out-GridView `

        -Title "Select the vnetRG (IS = infrastructureNetworks..." `

        -PassThru).ResourceGroupName

 

$subnet  =

    (Get-AzureRmVirtualNetwork | Select-Object subnets, ResourceGroupName, Name| `

     Out-GridView `

        -Title "Select the subnet" `

        -PassThru).subnets

> 


$objVirtualNetwork  = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet

 

$subnetName =  $objVirtualNetwork.Subnets.Name | Out-GridView `

                 -Title "Select an Azure Subnet (IS = Infrastructure-Subnet..." `

                 -PassThru

 #>

#$subnet = $vnet.Subnets |  Where-Object Name -eq $subnetName

# Select an Azure Virtual Network $vnet

#$kvName =

#    (Get-AzureRmKeyVault | Select-Object VaultName, ResourceGroupName | `

#     Out-GridView `

#        -Title "Select VaultName (Use ceAppDevelopmentKeyVault)" `

#        -PassThru).VaultName

########################################################

########################################################

# Static Definitions

$loc = "eastus"

 

########################################################

# Header end

########################################################

 

 

Write-Host 'Hostname to flag as generalized gold image: ' $vm -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host 'Next you will be promted to enter the gold image vhd prefix' -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host 'Most important part is of name is *current* in the begining for current gold image source and  ' -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host '*rhel* for RedHat and *win* for windows the remainder characters are free form in terms of script logic ' -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host 'Suggested format for *current image:' -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host '   current-XXXX-YYYY where X is OS & major version and YYYY free form field for minor build notes as in ,'-ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host '   current-rhel7-1310 represents  RH Enterprise Linux 7.1 Kernel 3.10 ' -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host '   current-win2012-SP1 represents wins 2012 service pack 1' -ForegroundColor Yellow -BackgroundColor DarkBlue

$VHDNamePrefix = Read-Host -Prompt 'Prefix of Gold VHD'

Stop-AzureRmVM -ResourceGroupName $rg -Name $vm

Set-AzureRmVm -ResourceGroupName $rg -Name $vm -Generalized

Save-AzureRmVMImage -ResourceGroupName $rg -VMName $vm -DestinationContainerName images -VHDNamePrefix $VHDNamePrefix

Write-Host "Save image is set on   $VHDNamePrefix.vhd completed" -ForegroundColor Yellow -BackgroundColor DarkBlue

Write-Host "Clean up by deleting your original Reference VM $vm once you have confirmed deploying new VM from VHD image you save above." -ForegroundColor Yellow -BackgroundColor DarkBlue

#Write-Host "If you used the Script CEXX_Image1_VHD-Upload-Azure-StartTemplateVM.ps1 , you VHD is already in the default location for storage account using this fomart path:" -ForegroundColor Yellow -BackgroundColor DarkBlue

#Write-Host "https://<storage_account_name>.blob.core.windows.net/system/Microsoft.Compute/Images/image/" -ForegroundColor Yellow -BackgroundColor DarkBlue

#Write-Host " therefore, you do not need to do anything else" -ForegroundColor Yellow -BackgroundColor DarkBlue

#Write-Host "However, if you used this script independant of Script CEXX_Upload-vhd_DeployReferenceVM.ps1 " -ForegroundColor Yellow -BackgroundColor DarkBlue

#Write-Host "you need to move this VHD to appropriate storage  location manaully using Azure Storage Explorer" -ForegroundColor Yellow -BackgroundColor DarkBlue