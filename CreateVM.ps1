#create-vm

# Script header for conedison powersehll azure VM operations

# Select thru subscription and rg availiable

# Get Credentials

Login-AzureRmAccount

########################################################

########################################################

# Header Start

# Header version 5

#

#

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

        -Title "Select an Resource Group(infrastructureServices for internal or sandbox, AppDevelopment for biztalk,  rgDev1 for all else in development sub …" `

        -PassThru).ResourceGroupName

 

<#

help Get-AzureRmStorageAccount -full only produces below, need to modify the select-object

by running in internet connect stte to subscription to see columns

 

    PS C:\> # Get all Storage Accounts in the subscription

              Get-AzureRmStorageAccount

   

#>

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

        -Title "Select the vnetRG (InfrastructureServices = infrastructureNetworks,  AppDevelopment OR rgDev1 = coneddevtestrg746542)" `

        -PassThru).ResourceGroupName

<#

$subnet  =

    (Get-AzureRmVirtualNetwork | Select-Object subnets, ResourceGroupName, Name| `

     Out-GridView `

        -Title "Select the subnet" `

        -PassThru).subnets

>#>


$objVirtualNetwork  = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet

 

$subnetName =  $objVirtualNetwork.Subnets.Name | Out-GridView `

                 -Title "Select an Azure Subnet (InfrastructureServices = Infrastructure-Subnet, AppDevedlopment = DevTestSubnet1, rgDev1 = DevTestSubnet1)" `

                 -PassThru

 

#$subnet = $vnet.Subnets |  Where-Object Name -eq $subnetName

# Select an Azure Virtual Network $vnet

#$kvName =

#    (Get-AzureRmKeyVault | Select-Object VaultName, ResourceGroupName | `

#     Out-GridView `

#        -Title "Select VaultName (Use ceAppDevelopmentKeyVault)" `

#        -PassThru).VaultName

########################################################

# Locations Selection ##################################

########################################################

$arrlocation = 'eastus', 'eastus2'

$loc =

    ($arrlocation | `

     Out-GridView `

        -Title "Select location for resource " `

        -PassThru)

########################################################

# Header end

########################################################

########################################################

# Ask user for name of host they like to create

$vm = Read-Host -Prompt 'Input desired hostname of VM to perform actions with (max 15 characters)'

########################################################

# Select the Image

# https://social.msdn.microsoft.com/Forums/azure/en-US/d50b1092-3ad1-4cee-8142-c91f69fd83cf/iterate-through-blob-files-in-azure-storage?forum=windowsazuredata

########################################################

#$image

#  (bt12image-osDisk.828edb03-decc-4f10-948a-5a12f7f3dcc8.vhd Use for Biztalk Dev)  #  special eiexde32 image name

#Build path to pre-existing image file locaitons based in storage account selected 

#$path1 ='https://'

#$path2 ='/system/Microsoft.Compute/Images/' 

#$path2 = '.blob.core.windows.net/images/'

#$path3 = 'not in use'

# $imagepath = $path1 +$acct+  $path2 + $image

# 'system/Microsoft.Compute/Images/images'

 

# --- # $imagepath = "https://$acct.blob.core.windows.net/system/Microsoft.Compute/Images/images"

#Define Context Variable and container

 

$StorageAccounKeysObject = Get-AzureRmStorageAccountKey -ResourceGroupName $rg  -Name $acct

$StorageAccounKey1  = $StorageAccounKeysObject[0].Value

$StorageAccountContext = New-AzureStorageContext -StorageAccountName $acct -StorageAccountKey $StorageAccounKey1

 

$ContainerName = Get-AzureStorageContainer -Context $StorageAccountContext -Name system*

 

#List all blobs in a container.

$VHDImageFileObjects = Get-AzureStorageBlob -Container $ContainerName.Name -Context $StorageAccountContext |`

           Where-Object {($_.Name -like '*curr*' -and $_.Name -notlike '*json')}

#$VHDImageFileObjects.Count

#$VHDImageFileObjects.Name

#$VHDImageFileObjects | Select-Object Name,LastModified,Length | Format-Table -AutoSize

 

 

#select image and build path to image

$image = ($VHDImageFileObjects|Select-Object Name,LastModified,Length,`

     BlobType,ICloudBlob,ContentType,SnapshotTime,ContinuationToken,Context |  `

     Out-GridView `

        -Title "Select Image" `

        -PassThru)

        #    https://ceinfralocal.blob.core.windows.net/system/Microsoft.Compute/Images/images

$imagepath = "https://$acct.blob.core.windows.net/system/"+ $image.Name

$imageinfoz = $image | Select-Object Name,LastModified,Length | Format-Table

########################################################

# Select Size of Machine

########################################################

$dataGB  = 0 # GB for e:\ drive

########################################################

# Select $Size

########################################################

<#

$arrSize = @{ "Standard_A0" = "Core 1, Ram  0.75 GB, Disk 20  GB, Max DataDisk(DD)  1, Max DD IOPS  1x500, Max NIC/Bandwidth 2/Low" ;`

              "Standard_A1" = "Core 1, Ram  1.75 GB, Disk 70  GB, Max DataDisk(DD)  2, Max DD IOPS  2x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A2" = "Core 2, Ram  3.50 GB, Disk 135 GB, Max DataDisk(DD)  4, Max DD IOPS  4x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A3" = "Core 4, Ram  7.00 GB, Disk 285 GB, Max DataDisk(DD)  8, Max DD IOPS  8x500, Max NIC/Bandwidth 2/High" ;`

              "Standard_A4" = "Core 8, Ram 14.00 GB, Disk 605 GB, Max DataDisk(DD) 16, Max DD IOPS 16x500, Max NIC/Bandwidth 4/High" ;`

              "Standard_A5" = "Core 2, Ram 14.00 GB, Disk 135 GB, Max DataDisk(DD)  4, Max DD IOPS  4x500, Max NIC/Bandwidth 2/Moderate" ;`

              "Standard_A6" = "Core 4, Ram 28.00 GB, Disk 285 GB, Max DataDisk(DD)  8, Max DD IOPS  8x500, Max NIC/Bandwidth 2/High" ;`

              "Standard_A7" = "Core 8, Ram 28.00 GB, Disk 605 GB, Max DataDisk(DD) 16, Max DD IOPS 16x500, Max NIC/Bandwidth 4/High" ;`

              "Standard_A7" = "Core 8, Ram 28.00 GB, Disk 605 GB, Max DataDisk(DD) 16, Max DD IOPS 16x500, Max NIC/Bandwidth 4/High" ;`

            }

#>

$arrSize =  Get-AzureRmVMSize -Location $loc

 

$sizeHashPair=

    $arrSize `

    | Out-GridView `

        -Title "Select Size VM (  uP clocks 1.68GHz)" `

         -PassThru

$size = $sizeHashPair.Name

# Uncomment this next line and enter whatever size machien you like that is not present in the list above.

# This will overwite your selection in the mnenu and buiold the machien yiou need. 

# for example if you want to build a a Standard DS4 v2  then $size = "Standard DS4 v2"

 

# $size  = "<whatever the size is>"

 

########################################################

#prompt user to continue

########################################################

#

Write-Host 'VM specification and locations:' -BackgroundColor Black -ForegroundColor Yellow

Write-Host "VM Name                    $vm"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Subscription Name          $sub"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Resource Group Name        $rg"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Storage Account            $acct"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Image Name                 "  -BackgroundColor Black -ForegroundColor Yellow

#Write-Host "Image Infoz                      "  -BackgroundColor Black -ForegroundColor Yellow

$imageinfoz     

#Write-Host "Image Path                 $imagepath"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Virtual Network            $vnet"  -BackgroundColor Black -ForegroundColor Yellow

Write-Host "Image Size                 $size"  -BackgroundColor Black -ForegroundColor Yellow

#Write-Host ""  -BackgroundColor Black -ForegroundColor Yellow

 

 

Function ContinuteOrBreak

{

write-host -nonewline "Continue? (Y/N) "

$response = read-host

if ( $response -ne "Y" ) { break }

}

Write-Host -NoNewline "Continue with Above?" | ContinuteOrBreak

#

#$logPath = "f:\azure\logs\"

########################################################

# connect to subscription

########################################################

$dummy = Select-AzureRmSubscription -SubscriptionName $sub

########################################################

# Set appropriate OS default admin account name and prompt password for same.

########################################################

$adminwin    = "allegheny"

$adminlinux    = "darv0s"

If ($image -like '*rhel*')

    {

    Write-Host "Setting LINUX default admin name to $adminlinux for new deploys"  -BackgroundColor Black -ForegroundColor Yellow

    $admin     = $adminlinux

     }

    ElseIf($image -like '*win*')

    {

    Write-Host "Setting Windows default admin name to $adminwin  for new deploys"  -BackgroundColor Black -ForegroundColor Yellow

    $admin     = $adminwin

    }

 

$oCredLocal = Get-Credential -userName $admin –Message "Enter guest's local admin password (12-char minimum)"

########################################################

# create nic (confirm overwrite on rerun)

########################################################

$nicName  = $vm + "_nic1"

$oVN  = get-AzureRmVirtualNetwork -ResourceGroupName $vNetRG -name $vNet

# $subnet = "DevTestSubnet1"

$oSN  = get-AzureRmVirtualNetworkSubnetConfig -name $SubnetName -VirtualNetwork $oVN

$oNic = new-AzureRmNetworkInterface -Name $nicName -Subnet $oSN -Location $loc -ResourceGroupName $rg

#$oNic.IpConfigurations[0].PrivateIpAllocationMethod = "Static" this does not work !!! find another way

 

########################################################

# construct the config object - the attributes of the guest

########################################################

 

$config = new-AzureRmVMConfig -vmName $vm -vmSize $size

 

If ($image -like '*rhel*')

    {

     Write-Host "LINUX Set-AzureRmVMOperatingSystem"  -BackgroundColor Black -ForegroundColor Yellow

     Set-AzureRmVMOperatingSystem  -ComputerName $vm -Credential $oCredLocal -Linux -VM $config

     #Set-AzureRmVMOperatingSystem -ComputerName $vm -Credential $oCredLocal -Linux -VM $config -DisablePasswordAuthentication -ProvisionVMAgent

     }

    ElseIf($image -like '*win*')

    {

    Write-Host "WINDOWS Set-AzureRmVMOperatingSystem"  -BackgroundColor Black -ForegroundColor Yellow

    Set-AzureRmVMOperatingSystem  -vm $config -Windows -Credential $oCredLocal -ComputerName $vm -ProvisionVMAgent -TimeZone "Eastern Standard Time"

    }

 

 

 

 

$dummy = Add-AzureRmVMNetworkInterface -vm $config -Id $oNic.Id

 

$diskName = $vm + "_boot"

$diskUri  = "https://" + $acct + ".blob.core.windows.net/vhds/" + $diskName + ".vhd"

# https://appdevelopment1657.blob.core.windows.net/vhds

#echo $diskName

#echo $diskUri

 

If ($image -like '*rhel*')

    {

     Write-Host "LINUX dummy"  -BackgroundColor Black -ForegroundColor Yellow

     $dummy = Set-AzureRmVMOSDisk -vm $config -Name $diskName -VhdUri $diskUri -Caching ReadWrite -CreateOption fromImage -SourceImageUri  $imagepath -Linux

     }

    ElseIf($image -like '*win*')

    {

    Write-Host "WINDOWS dummy"  -BackgroundColor Black -ForegroundColor Yellow

    $dummy = Set-AzureRmVMOSDisk -vm $config -Name $diskName -VhdUri $diskUri -Caching ReadWrite -CreateOption fromImage -SourceImageUri $imagepath -Windows

    }

 

 

if ($dataGB -ne 0) {

$diskName = $vm + "_data1"

$diskUri  = "https://" + $acct + ".blob.core.windows.net/vhds/" + $diskName + ".vhd"

Add-AzureRmVMDataDisk         -VM $config -Name $diskName -VhdUri $diskUri -Caching ReadWrite -CreateOption empty -DiskSizeInGB $dataGB

}

 

########################################################

# create the guest from the config - this can take half an hour

########################################################

#$start = Get-Date

Write-Host "Starting build processs for VM:$VM in sub:$sub, rg:$rg  This will take 10-20 minutes." -BackgroundColor Black -ForegroundColor Yellow

If ($image -like '*rhel*')

    {

     Write-Host "LINUX NewAxureRMVM"  -BackgroundColor Black -ForegroundColor Yellow

     #New-AzureVMConfig -Name "MySUSEVM2" -InstanceSize ExtraSmall -ImageName (Get-AzureVMImage)[7].ImageName ` | Add-AzureProvisioningConfig –Linux –LinuxUser $lxUser -Password $adminPassword ` | New-AzureVM

     new-azureRmVM -ResourceGroupName $rg -vm $config -Location $loc

     }

    ElseIf($image -like '*win*')

    {

    Write-Host "WINDOWS NewAxureRMVM"  -BackgroundColor Black -ForegroundColor Yellow

    new-azureRmVM -ResourceGroupName $rg -vm $config  -Location $loc -LicenseType "Windows_Server"

    }

 

 

 

#$end = Get-Date

#$duration = New-TimeSpan –Start $Start –End $End

#Write-Host "build took " $("{0:N2}" -f $duration.TotalSeconds) " seconds"

#$json = $logPath + $vm + ".json"

get-azureRmVm -ResourceGroupName $rg -vmName $vm

# Get-AzureRmTag

# https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags

# possible way to get IP addy

#Get-AzureRmNetworkInterface -ResourceGroupName $RG| ForEach { $Interface = $_.Name; $IPs = $_ | Get-AzureRmNetworkInterfaceIpConfig | Select PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress }