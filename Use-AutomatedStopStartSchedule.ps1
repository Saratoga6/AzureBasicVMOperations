#Use-AutomatedStopStartSchedule.ps1  thi sis the experinmental   - ticket 117102816571273

# I cannot get outpout  usingeh workflow context.  I commented ut htose line  with three ###

#I even tried InlineScript {}  but that was 'not recognized'

# The only "actional cmdlets are the StartAzureRMVM  1 time & StopAzureRMVM ( 2 times)

# This script will top and start machines based on Tag 'Use-AutomatedStopStartSchedule'

# Tag Values are a comman seperated array of 4 elements

# The first two,  [0] and [1]  array elements are  free form  and used by script logic, right now being if Active and ad hoc type of sceduleA ,

# meaning basic test box  so , turn off weekends  and use the next two elements as time to do start and stop on weekdays

# Currently Oct 30 2017, [0]  designates if action should be Active.  [1] is ScheduleX  as determined by script presently  used to check if weekend day

# If it is weekend day  then turn off ignore daily scedules for Turn Off [3]  and Turn On [4]

# example value:    Active,ScheduleX,18:00:00,07:00:00   #Active means act on the VM , it uses ScheduleA and turn off time is 6 PM ,  turn on time 7 AM.

# Resource groups are also  checked for the Tag and Value pare of 'Use-AutomatedStopStartSchedule:Active' , if Tag not present script ignores Resource Group contents

#Login-AzureRmAccount

#$myCredential = Get-AutomationPSCredential -Name 'MyCredential'

#$userName = $myCredential.UserName

#$securePassword = $myCredential.Password

#$password = $myCredential.GetNetworkCredential().Password

# Thomas Burke & Chen Xiaolan 11/18/2017

$VirtualMachinesToProcess = @()

$azCredential = Get-AutomationPSCredential -Name "AutoCredential1" # $Automation account AzureCredentialAsset 'AutoAcctDev1'

$null = Login-AzureRmAccount -Credential $azCredential

 

# Get current time

$nowUTC = [system.timezoneinfo]::ConvertTimeToUtc((Get-Date))

Write-Output ("Time in UTC" + ($nowUTC))

$estoffset = [system.timezoneinfo]::FindSystemTimeZoneById("Eastern Standard Time").baseUtcOffset

Write-Output ("Time in Eastern Standard Time " + ($nowUTC + $estoffset))

 

#$LocalBoxTimeNow = [datetime]::Now

$LocalBoxTimeNow = $nowUTC + $estoffset

$ScriptStart = [datetime]::Now

$ScriptStartEST = ($nowUTC + $estoffset)  

$LogTimeEntry = $LocalBoxTimeNow.ToString('yyyy.MM.dd,HH:mm:ss,')

$TimeLongNow = $LocalBoxTimeNow.ToString('HH:mm:ss')

 

# update Log

Write-Output "Script Start $ScriptStart"

$TotalVMCount = $null

$TotalVMCountReport = $null

$ResourceGroupTaggedActive = $null

# List the Subscription targets

$arrSub = "conEd developement", "conEd infrastructure","conEd production"

$VMTransitionalVMPowerStates = $null

$ResourceGroupTaggedActiveReport = $null

# Loop  Subs Begins Subscription targets

foreach($sub in $arrSub)

{ #SUB


  Write-Output "  - - - - - - - - - - - "

  Write-Output "subscription:  $sub"

  Write-Output "  - - - - - - - - - - - "

  $null = Select-AzureRmSubscription -SubscriptionName $sub

  $SubscriptionObject = Get-AzureRmSubscription -SubscriptionName $sub

  $SubscriptionID = $SubscriptionObject.Id

  $i = 0

  $TotalVMCountReport =$TotalVMCountReport + $ResourceGroupVMCount

  Do

  {

      $RGObject = Get-AzureRmResourceGroup # -Name "rgfw1"

      If($RGObject[$i].Tags.Count -ne 0)

        {

            $x = 0

            Do

            {

                If ($RGObject[$i].Tags.Keys -eq "Use-AutomatedStopStartSchedule" -and $RGObject[$i].Tags.Values -eq "Active")

                {

                    #Read the PowerON PowerOff PowerWeekend Tags for Each VM

                    $Vms = Get-AzureRmVm -ResourceGroupName $RGObject[$i].ResourceGroupName   #"AnalyticsPOC"#

                    $CurrentRGName  = $RGObject[$i].ResourceGroupName

                    Write-Output  "- - -"

                    Write-Output "Resource Group : $CurrentRGName  is an ACTIVE Tagged AutoStopStart container"

                    Write-Output "   Will now check each VM for Tag: Use-AutomatedStopStartSchedule"

                    Write-Output  "- - -"

                    $ResourceGroupVMCount  = $vms.Count

                    $ResourceGroupTaggedActive = "$ResourceGroupTaggedActive  $CurrentRGName`r`n"

                    $ResourceGroupTaggedActiveReport =  $ResourceGroupTaggedActive

                    $n = 0

                    Do

                    {

                        Try

                            {

                                $CurrentVMName  = $Vms[$n].Name

                            }

                                        Catch

                                      {

                                $errorMessage = $_

                                      }

                            $errorMessage = $_

                            Write-Output  "___________________________"

                            Write-Output   $CurrentVMName

                            Write-Output  "Testing Tag $CurrentVMName"

                            # If 'Active' is in the Key, parse the key delimited by comma into array.

                            If (($Vms[$n].Tags.Keys).contains("Use-AutomatedStopStartSchedule") )

                            {

                                $KeyList  = $Vms[$n].Tags.Values

                                $arrKeyListRows  = $KeyList.split("`r")

                                #find correct key list index for "Use-AutomatedStopStartSchedule" in $arrKeyListRows

                                $ki = -1

                                Do

                                {

                                    If($arrKeyListRows[$ki].length -gt 7)

                                    {

                                    # Write-Output $arrKeyListRows[$ki].substring(0,7)

                                    If($arrKeyListRows[$ki].substring(0,7) -eq "Active,")

                                        {

                                        $KeyListArrayRow = $arrKeyListRows[$ki]

                                        }

                                    }

                                    $ki++

                                }while( $ki -lt $KeyList.Count)

 

 

 

                                $KeyListArray  = $KeyListArrayRow.split(",")

# Write-Output "line 94 KeyList variable `r`n $KeyList"

# break

                                If ($KeyListArray[0] -eq  "Active")

                                {

                                    $CurrentVMName = $Vms[$n].Name

                                    Write-Output  "$CurrentVMName : Actively Scheduled AutoStoStart Device. Determining PowerStatus..."

 

                                    # Get PowerState of CurrentVM  https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.compute.fluent.powerstate?view=azure-dotnet

                                    $VMDetail = Get-AzureRmVM -ResourceGroupName $CurrentRGName -Name $CurrentVMName -Status

                                    $VMStatusCodes = $VMDetail.Statuses.Code

                                    #Begin Loop thru each status type reported on VM, some status types are not power state they are things like provision state which can ignore

                                    foreach($VMPowerStatus in $VMStatusCodes )

                                    {

                                     if ($VMPowerStatus -like "PowerState*")

                                         {

                                            $VMPowerCurrentStatus = $VMPowerStatus

                                            Write-Output  "$CurrentVMName has current power state $VMPowerCurrentStatus"

                                         }

                                     ElseIf ($VMPowerStatus -like "*updating")

                                         {

                                            $VMTrasitionalStatus = $VMPowerStatus

                                            Write-Output  "$CurrentVMName has a trasitional state and should be investigated $VMTrasitionalStatus"

                                         }

 

                                     }

 

                                     # check if it is Weekend... If the Machine $KeyListArray[1]

                                     # is ScheduleA  then it is OK to keep off for weekend.

                                     # If  is not weekend move to next case

                                     <#

                                                                           If (`

                                      ($DayOfWeek -eq "Saturday" -or $DayOfWeek -eq "Sunday") -and  ($KeyListArray[1] -eq "ScheduleA") `

                                      -and `

                                      ($VMPowerCurrentStatus -eq "PowerState/stopped") -and ( $VMTrasitionalStatus -notlike "*updating" )

                                      )

                                      {

                                        Write-Output "Today is $DayOfWeek, $CurrentVMName is Tagged $KeyListArray[1], Power state is $VMPowerCurrentStatus"

                                        Write-Output "     $CurrentVMName $VMTrasitionalStatus wierd state , skipping, should be investigated"

                                        # Code to Stop Box

                                        $context = Get-AzureRmContext

                                        $Parameters = @{"SubscriptionId"= $context.Subscription.Id ; "ResourceGroupName" = $CurrentRGName; "Name" = $CurrentVMName;"Action" = "stop"}

                                        $VirtualMachinesToProcess += $Parameters

                                        # Start-AzureRmAutomationRunbook -ResourceGroupName "rgDev1" -AutomationAccountName "AutoAcctDev1" -Name "StartStopVM" -Parameters $Parameters

                                      }

                                     #>

                                     $DayOfWeek = $LocalBoxTimeNow.DayOfWeek

                                     If (`

                                     ($DayOfWeek -eq "Saturday" -or $DayOfWeek -eq "Sunday") -and  ($KeyListArray[1] -eq "ScheduleA") `

                                     -and `

                                     ($VMPowerCurrentStatus -eq "PowerState/running")

                                      )

                                      {

                                        Write-Output "Today is $DayOfWeek, $CurrentVMName is Tagged $KeyListArray[1], Power state is $VMPowerCurrentStatus"

                                        Write-Output "     Stopping $CurrentVMName"

                                        # Code to Stop Box

                                        #Stop-AzureRmVM -ResourceGroupName $CurrentRGName -Name $CurrentVMName -Force

                                        $context = Get-AzureRmContext

                                        $Parameters = @{"SubscriptionId"= $context.Subscription.Id ; "ResourceGroupName" = $CurrentRGName; "Name" = $CurrentVMName;"Action" = "stop"}

                                        $VirtualMachinesToProcess += $Parameters

                                        # Start-AzureRmAutomationRunbook -ResourceGroupName 'rgDev1' -AutomationAccountName 'AutoAcctDev1' -Name 'StartStopVM' -Parameters $Parameters

                                      }

                                                                                       

                                      # Define What 'ScheduleA' basically  for now it means Deallocated on weekends

                                      ElseIF((($DayOfWeek -ne "Saturday") -or ($DayOfWeek -ne "Sunday")) -and  ($KeyListArray[1] -eq "ScheduleA"))

                                      {

                                                         # Begin the Daily Check ElseIf

                                                         # This is a daily check Read the current time , the machine scheduled start time $KeyListArray[2]

                                                         # and the machine scheduled stop time $KeyListArray[3]

                                                         # if the box is in correct state do nothing , if it is not in correct state do something.

                                                         # check for correct state

                                                        Write-Output "Passed $KeyListArray[1] `r`n                       Performing Daily Check, $DayOfWeek,  $CurrentVMName is $VMPowerCurrentStatus"

                                                        $TotalSecondsDay = 86400 # Total seconds in a day, use as point of reference comparison operations

                                                        $estoffset = [system.timezoneinfo]::FindSystemTimeZoneById("Eastern Standard Time").baseUtcOffset

                                                        #Write-Host ("Time in Eastern Standard Time " + ($nowUTC + $estoffset))

                                                        $TurnOffdt  = [DateTime]$KeyListArray[2] #+ $estoffset

                                                        #Write-Output "TurnOff Key  =  $KeyListArray[2]  after offset  = $TurnOffdt"

                                                        $TurnOndt  = [DateTime]$KeyListArray[3] #+ $estoffset

                                                        $TurnOff = $TurnOffdt.ToString('HH:mm:ss')

                                                        Write-Output "Script TurnOff $TurnOff"

                                                        $TurnOn = $TurnOndt.ToString('HH:mm:ss')

                                                        Write-Output "Script TurnOn $TurnOn"                                                     

                                                        #$TurnOff  = $KeyListArray[2]

                                                        #$TurnOn  = $KeyListArray[3]

                                                        $TurnOffSeconds = ([TimeSpan]::Parse($TurnOff)).TotalSeconds

                                                        $TurnOnSeconds = ([TimeSpan]::Parse( $TurnOn)).TotalSeconds

                                                        $TimeLongNowSeconds= ([TimeSpan]::Parse($TimeLongNow)).TotalSeconds

                           

                                                        Write-Output "$CurrentVMName scheduled for Turn Off: $TurnOff, scheduled for Turn On: $TurnOn"

 

                                                        # Go thru logic if the PowerState Correct for TimeNow

                                                        $BeginTimePower = $TurnOnSeconds

                                                        $VMTimePower =  $TimeLongNowSeconds

                                                        $EndTimePower = $TurnOffSeconds

                                                        #    ( ( ($BeginTimePower -lt $VMTimePower) -and ($VMTimePower -lt $EndTimePower) )-and ($VMPowerCurrentStatus -eq "PowerState/running") )

 

                                                             If( ( ($VMTimePower -lt $BeginTimePower ) -or ($VMTimePower -gt $EndTimePower ) ) -and ($VMPowerCurrentStatus -eq "PowerState/running") )  #offtime and on :: shutoff

                                                                        {

                                                                        Write-Output "$CurrentVMName , Time= $TimeLongNow ,ScheduleOff/On=  $TurnOndt/$TurnOff , PowerState= $VMPowerCurrentStatus,  STOP ACTION"

                                                                        #Stop-AzureRmVM -ResourceGroupName $CurrentRGName -Name $CurrentVMName -Force

                                                                        $context = Get-AzureRmContext

                                                                        $Parameters = @{

                                                                        "SubscriptionId"       = $context.Subscription.Id

                                                                        "ResourceGroupName"    = $CurrentRGName

                                                                        "Name"                 = $CurrentVMName

                                                                        "Action"               = 'stop'

 

                                                                        }

                                                                        $VirtualMachinesToProcess += $Parameters

                                                                        # Start-AzureRmAutomationRunbook -ResourceGroupName "rgDev1" -AutomationAccountName "AutoAcctDev1" -Name "StartStopVM" -Parameters $Parameters

                                                                        }


                                                             ElseIF ( ( ($VMTimePower -lt $BeginTimePower ) -or ($VMTimePower -gt $EndTimePower ) ) -and ($VMPowerCurrentStatus -eq "PowerState/deallocated") )  #offtime and off :: no action

                                                                        {

                                                                        Write-Output "$CurrentVMName , Time= $TimeLongNow ,ScheduleOff/On=  $TurnOndt/$TurnOff , PowerState= $VMPowerCurrentStatus,  NO ACTION"

                                                                        }                 

                     

                                                             ElseIf ( ( ($BeginTimePower -lt $VMTimePower) -and ($VMTimePower -lt $EndTimePower) )-and ($VMPowerCurrentStatus -eq "PowerState/running") )    #ontime and on :: no action

                                                                        {

                                                                        Write-Output "$CurrentVMName , Time= $TimeLongNow ,ScheduleOff/On=  $TurnOndt/$TurnOff , PowerState= $VMPowerCurrentStatus,  NO ACTION"

                                                                        }

                                       

                                                             ElseIf ( ( ($BeginTimePower -lt $VMTimePower) -and ($VMTimePower -lt $EndTimePower) )-and ($VMPowerCurrentStatus -eq "PowerState/deallocated") ) #ontime and off :: turn on

                                                                        {

                                                                        Write-Output "$CurrentVMName , Time= $TimeLongNow ,ScheduleOff/On=  $TurnOndt/$TurnOff , PowerState= $VMPowerCurrentStatus,  START ACTION"

                                                                        #Start-AzureRmVM -ResourceGroupName $CurrentRGName -Name $CurrentVMName

                                                                        $context = Get-AzureRmContext

                                                                        $Parameters = @{"SubscriptionId"= $context.Subscription.Id ; "ResourceGroupName" = $CurrentRGName; "Name" = $CurrentVMName;"Action" = "start"}

                                                                        $VirtualMachinesToProcess += $Parameters

                                                                        # Start-AzureRmAutomationRunbook -ResourceGroupName "rgDev1" -AutomationAccountName "AutoAcctDev1" -Name "StartStopVM" -Parameters $Parameters

                                                                        }

 

                                                             Else  # all others  record

                                                                        {

                                                                        Write-Output  "! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !"

                                                                        Write-Output "Else --- End Loop of VM Chek. Next line identifies an unscriptred state"

                                                                        Write-Output "$CurrentVMName , Time= $TimeLongNow ,ScheduleOff/On=  $TurnOndt/$TurnOff , PowerState= $VMPowerCurrentStatus,  UNDEFINED ACTION"

                                                                        $VMTransitionalVMPowerStates  = "$CurrentVMName PowerStatus: $VMPowerCurrentStatus is Reported. Attention maybe required if persists.`r`n"

                                                                        $VMTransitionalVMPowerStatesReport = "$VMTransitionalVMPowerStatesReport  $VMTransitionalVMPowerStates"

                                                                        Write-Output  "! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !"

                                                                        }

 

                                                        #Write-Output  "___________________________"


                                                    } # End the Daily Check ElseIf

 

                                                    Write-Output  ""

 

                                                 } # End Do Loop

                                     } # end if for testing for Active KeyValue[0]

                                         $n++

                                        }While($n -lt $Vms.Count)

 

                    }


                    $x++

                    }while($x -lt $RGObject[$i].Tags.Count)

                                

           

               } # end  If then check on $NULL tags

           

                                   

          $i++

          }While($i -lt $RGObject.Count)

 

 

}  # SUB

 

$null = Select-AzureRmSubscription -SubscriptionName "conEd developement"

$VirtualMachinesToProcess | ForEach-Object {

    $null = Start-AzureRmAutomationRunbook -ResourceGroupName rgDev1 -AutomationAccountName AutoAcctDev1 -Name StartStopVM -Parameters $_

}

$VirtualMachinesToProcess | Out-File "output.txt"

 

# Email report

Write-Output ""

$nowUTC2 = [system.timezoneinfo]::ConvertTimeToUtc((Get-Date))

$ScriptEndEST = ($nowUTC2 + $estoffset)

$ScriptElapsedTimeTotalMinutes = (New-TimeSpan -Start $ScriptStartEST -End $ScriptEndEST).TotalMinutes

$report  = "Script Start $ScriptStartEST `r`nScriptEnd  $ScriptEndEST`r`n`

Elapsed Time Minutes $ScriptElapsedTimeTotalMinutes`r`n`

Resource Group Tagged Active  `r`n$ResourceGroupTaggedActive`r`n`

VM in Transitional PowerState `r`n$VMTransitionalVMPowerStatesReport`r`n`

Total VM Processed $TotalVMCountReport"

Write-Output  $report

 

$to = @("quigleyj@coned.com", "rogersp@coned.com")

Send-MailMessage -To $to -Body $report -From $azCredential.username -Credential $azCredential `

    -UseSsl -Port 587 -SmtpServer 'smtp.office365.com' -BodyAsHtml `

    -Subject "azure auto shutdown automation status"  -Attachments "output.txt"