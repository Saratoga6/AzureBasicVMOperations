# upload the boot drive from the bizTalk9d hyper-v cluster to the appdevelopment1657 storage account

# edit the server name and path to the VHD on the local server

############################################################

Login-AzureRmAccount

 

############################################################

############################################################

# Upload the VHD from the hyper-v cluster to the Azure storage account

# edit the server name and path to the VHD on the local server

Write-Host 'Script will upload Hyper-V 2012 quiescent VHD to Azure'-BackgroundColor DarkBlue

Write-Host 'Script wiol give option create a Reference VM based'-BackgroundColor DarkBlue

Write-Host 'Prerequisite'-BackgroundColor DarkBlue

Write-Host ' - Mounted path to the VHD you intent to uploaded'-BackgroundColor DarkBlue

Write-Host ' - VHD must be stopped, a fixed disk and host must be Hyper-V 2012'-BackgroundColor DarkBlue

Write-Host 'If you do not have above , fix , then  restart script'-BackgroundColor DarkBlue

Start-Sleep -Seconds 11

Write-Host ''

############################################################

# Make array of OS Type they can use then ask them in grid view which

#  this $OsType variable is used in cmdlet to make the VM by attach disk param

############################################################

$arrOsType = ("Windows", "Linux")

$OsType=

    $arrOsType `

    | Out-GridView `

        -Title "Select an OsType" `

         -PassThru

########################################################

# Select VHD

Write-Host 'Select your VHD to upload' -BackgroundColor DarkBlue

$PathLocal = New-Object system.windows.forms.openfiledialog

$PathLocal.InitialDirectory = 'c:\'

$PathLocal.MultiSelect = $true

$PathLocal.showdialog()

$PathLocal.filenames

$PathLocalFileObject  = Get-Item -Path $PathLocal.filenames

############################################################

 

$VHDFileName = $PathLocalFileObject.Name

$VHDFileName = $VHDFileName.Substring(0,$VHDFileName.Length-4)

$vm = $VHDFileName

#$pathLocal = 'Y:\ClusterStorage\Volume7\redhat\rhel7small.vhd'

$pathLocal = $PathLocal.filenames

 

 

 

########################################################

# Header Start

# Header version 4 (Fix all the $acct StrorageAccountObject n

#########################################################

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

        -Title "Select an Resource Group(infrastructureServices for internal or sandbox, AppDevelopment for biztalk,  rgDev1 for all else in development sub …" `

        -PassThru).ResourceGroupName

 

 

   

# Get all Storage Accounts in the subscription

$acct = (Get-AzureRmStorageAccount| Select-Object StorageAccountName, ResourceGroupName | `

         Out-GridView `

         -Title "Select StorageAccountName (InfrastructureServices=ceInfraLocal, AppDevelopment = appdevelopment1657 , rgDev1 = rgdev1disks280) " `

         -PassThru)

$StorageAccountObject  = $acct

$acct = $acct.StorageAccountName

 

# Select an Azure Virtual Network $vnet

$vnet = (Get-AzureRmVirtualNetwork | Select-Object Name, ResourceGroupName | `

     Out-GridView `

        -Title "Select vnet name(InfrastructureServices=infrastructureNet, AppDevelopment or rgDev1 = DtlConEdDevTestvNet)" `

        -PassThru).Name

$vnetRG = (Get-AzureRmVirtualNetwork | Select-Object ResourceGroupName ,Name| `

     Out-GridView `

        -Title "Select the vnetRG (InfrastructureServices=infrastructureNetworks,AppDevelopment and rgDev1 = coneddevtestrg746542)" `

        -PassThru).ResourceGroupName

$subnet  =

    (Get-AzureRmVirtualNetwork | Select-Object subnets, ResourceGroupName, Name| `

     Out-GridView `

        -Title "Select the subnet" `

        -PassThru).subnets

 

$objVirtualNetwork  = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet

 

$subnetName =  $objVirtualNetwork.Subnets.Name | Out-GridView `

                 -Title "Select an Azure Subnet (InfrastructureServices = Infrastructure-Subnet, AppDevedlopment=DevTestSubnet1,rgDev1 = DevTestSubnet1)" `

                 -PassThru

 

<#

# Select a Recovery Vault 

$RecoveryVaultName  =

    (Get-AzureRmRecoveryServicesVault -ResourceGroupName $rg | Select-Object Name, ResourceGroupName, Type, ID, Location, subscriptionId, Properties|`

         Out-GridView `

        -Title "Select an Resource Group(infrastructureServices for internal or sandbox, AppDevelopment for biztalk,  rgDev1 for all else in development sub …" `

        -PassThru).Name

$RecoveryVaultObject = Get-AzureRmRecoveryServicesVault -Name $RecoveryVaultName

#Set Recovery Vault context

Set-AzureRmRecoveryServicesVaultContext -vault $RecoveryVaultObject 

 

 

#Select VM

$VMObject=

    Get-AzureRMVM `

    | Out-GridView `

        -Title "Select a source VM to restore" `

         -PassThru

$vmName = $VMObject.Name  

#Add resource group context to VM

#$VMObject=Get-AzurermVM -ResourceGroupName $rg -Name $vm

 

 

 

$objVirtualNetwork  = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet.Name

 

$subnetName =  $objVirtualNetwork.Subnets.Name | Out-GridView `

                 -Title "Select an Azure Subnet (InfrastructureServices = Infrastructure-Subnet, AppDevedlopment=DevTestSubnet1,rgDev1 = DevTestSubnet1)" `

                 -PassThru

 

 

#$subnet = $vnet.Subnets |  Where-Object Name -eq $subnetName

# Select an Azure Virtual Network $vnet

 

$kvName =

    (Get-AzureRmKeyVault | Select-Object VaultName, ResourceGroupName | `

     Out-GridView `

        -Title "Select VaultName (coned Development =ceAppDevelopmentKeyVault,conEd InfrastructureServices = kvInfraServBackup2 )" `

        -PassThru).VaultName

#>

 

########################################################

# Static Definitions

$loc = "eastus"

 

########################################################

# Header end

########################################################

#$acct = 'ceinfralocal'

$sContainer = "vhds"

#$rg = "InfrastructureServices"

#$sub = "coned Infrastructure"

$vhd = $vm + "_boot.vhd"

$pathAzure = "https://" + $acct + ".blob.core.windows.net/" + $scontainer + "/" + $vhd

Select-AzureRmSubscription -SubscriptionName $sub

Add-AzureRmVhd  -LocalFilePath $PathLocalFileObject -Destination $pathAzure -ResourceGroupName $rg

$sObj = Get-AzureRmStorageAccount -ResourceGroupName $rg -Name $acct

Get-AzureStorageBlob  -Context $sObj.Context -Container $sContainer -Blob $vhd

 

#

Write-Host "When the VHD finish uploading, a new Reference VM will be created called $vm"

#

#########################################

# Ask if you want to build a reference VM based on this vhd

#########################################

Function ContinuteOrBreak

{

write-host -nonewline "Continue to build a Reference VM $vm based on this vhd $PathLocalFileObject.Name  ? (Y/N) " -BackgroundColor DarkBlue -ForegroundColor Yellow

$response = read-host

if ( $response -ne "Y" ) { break }

}

ContinuteOrBreak

########################################################

# create nic (confirm overwrite on rerun)

########################################################

 

$nic    = $VM + "_nic1"

$oVN    = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet

$oSN    = get-AzureRmVirtualNetworkSubnetConfig -name  $subnetName -VirtualNetwork $oVN

$oNic   = new-AzureRmNetworkInterface -Name $nic -Subnet $oSN -Location $loc -ResourceGroupName $rg

$oNic.IpConfigurations[0].PrivateIpAllocationMethod = "Static"

 

 

 

#

#create reference vm based on uploaded vhd

#

 

$pathAzure = "https://" + $acct + ".blob.core.windows.net/" + $scontainer + "/" +  $vm + "_boot.vhd"

$bootName =  $vm + "_boot"

 

########################################################

# construct the config object - the attributes of the guest

########################################################

 

########################################################

# Select $Size

########################################################

$arrSize = @{ "Standard_A0" = "Core 1, Ram  0.75 GB, Disk 20  GB, Max DataDisk(DD)  1, Max DD IOPS  1x500, Max NIC/Bandwidth 2/Low" ;`

              "Standard_A1" = "Core 1, Ram  1.75 GB, Disk 70  GB, Max DataDisk(DD)  2, Max DD IOPS  2x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A2" = "Core 2, Ram  3.50 GB, Disk 135 GB, Max DataDisk(DD)  4, Max DD IOPS  4x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A3" = "Core 4, Ram  7.00 GB, Disk 285 GB, Max DataDisk(DD)  8, Max DD IOPS  8x500, Max NIC/Bandwidth 2/High" ;`

              "Standard_A4" = "Core 8, Ram 14.00 GB, Disk 605 GB, Max DataDisk(DD) 16, Max DD IOPS 16x500, Max NIC/Bandwidth 4/High" ;`

              "Standard_A5" = "Core 2, Ram 14.00 GB, Disk 135 GB, Max DataDisk(DD)  4, Max DD IOPS  4x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A6" = "Core 4, Ram 28.00 GB, Disk 285 GB, Max DataDisk(DD)  8, Max DD IOPS  8x500, Max NIC/Bandwidth 2/High" ;`

              "Standard_A7" = "Core 8, Ram 28.00 GB, Disk 605 GB, Max DataDisk(DD) 16, Max DD IOPS 16x500, Max NIC/Bandwidth 4/High" ;`

            }

 

$sizeHashPair=

    $arrSize `

    | Out-GridView `

        -Title "Select Size VM (  uP clocks 1.68GHz)" `

         -PassThru

$size = $sizeHashPair.Name

 

$config = new-AzureRmVMConfig -vmName  $vm -vmSize $size

#Set-AzureRmVMOperatingSystem  -vm $config -Windows -Credential $oCredLocal -ComputerName $VMNameNew -ProvisionVMAgent -TimeZone "Eastern Standard Time"

Add-AzureRmVMNetworkInterface -vm $config -Id $oNic.Id

 

########################################################

# Check OS flavor based on the naming of the VHD then set the

# appropriate variable in Set-AzureRMVMOSDisk

########################################################

If ($OSType -eq 'Linux')

    {

    Write-Host "Linux shall be used for Set-AzureRmVMOSDisk cmdlet" -BackgroundColor DarkBlue

    Set-AzureRmVMOSDisk  -vm $config -Name $bootName -VhdUri $pathAzure -Linux -CreateOption "Attach"

    }

    ElseIf($OSType -eq 'Windows')

    {

    Write-Host "Windows shall be used for Set-AzureRmVMOSDisk cmdlet" -BackgroundColor DarkBlue

    Set-AzureRmVMOSDisk  -vm $config -Name $bootName -VhdUri $pathAzure -Windows -CreateOption "Attach"

    }

 

 

########################################################

#Add-AzureRmVMDataDisk         -VM $config -Name $dataName -VhdUri $dataUri -Caching ReadWrite -CreateOption empty -DiskSizeInGB $dataGB

 

########################################################

# create the guest from the config - this can take half an hour

########################################################

new-azureRmVM -ResourceGroupName $rg -vm $config  -Location $loc -Verbose

#$json = ".\logs\" +  $vm + ".json"

#get-azureRmVm -ResourceGroupName $rg -vmName  $vm | out-file $json