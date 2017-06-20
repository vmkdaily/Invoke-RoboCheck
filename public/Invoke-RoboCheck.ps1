Function Invoke-RoboCheck {

    <#

        .SYNOPSIS
          Health check Remote Office Branch Office (ROBO) sites running vSphere.

        .DESCRIPTION
          This is the main function for the Invoke-RoboCheck module.
          Here, we connect to one or more vCenter Servers and check ESX
          health.

        .NOTES
          Script:         Invoke-RoboCheck.ps1
          Type:           Function
          ParentModule:   Invoke-RoboCheck
          Author:         Mike Nisk
          Organization:   vmkdaily
          Updated:        05April2017
        
        ABOUT CREDENTIAL HANDLING
          We consume credentials in the following order:
            
          PSCredential Object  - This always wins
          EncryptedXml         - We try this next if no creds are given
          VICredentialStore    - If still not logged in, we check your local VICredentialStore
          PassThrough (SSPI)   - Finally, if no other valid credential is found, we use Passthrough (SSPI)
    
        .PARAMETER Computer
          String. The IP Address or DNS name of one or more vCenter Server machines to connect to.
          For IPv6, enclose address in square brackets, for example [fe80::250:56ff:feb0:74bd%4].
          For server lists, provide the path to a text file, for example, "C:\servers.txt".

        .PARAMETER Credential
          pscredential. The login credentials for vCenter
	      Optionally, you can enter just username to be prompted for runtime password.

        .PARAMETER CredFallBack
          pscredential. If the first login fails, try these.
	      Cannot be the same username as Credential.

        .PARAMETER OutputCSV
          Switch. Activate this to save reports to CSV.  The path is determined by your Invoke-RoboCheck.ini

        .PARAMETER ReportType
          validate set.  The default for ReportType is Detailed, which includes everything.  Tab complete though options.
          Other choices include "Standard","NTP","Datastore", or "AutoStart".
          This only affects output, runtime does not decrease with smaller reports.

        .PARAMETER Cluster
          Choose to target ESX hosts only from a particular cluster

        .PARAMETER 
          Optionally save an encypted credential to disk.
          This selection presents a Menu based system for user to create up to 4 credential files.
          The Credential files must be created one at time.  Re-run the script to create more if needed.
          The Invoke-RoboCheck function can consume up to 2 cred files.
          After creating your cred files, update the path in your preferences ($Env:USERPROFILE\Invoke-RoboCheck.ini by default).

        .PARAMETER CredOutputPath
          String.  If saving Credentials to disk with the SaveCredential parameter, The CredOutputPath (alias Path) allows you to choose the folder
          you want your saved credentials output to.  Remember to update your Invoke-RoboCheck.ini to enjoy seamless logins.

        .PARAMETER AutoLaunch
          Switch.  Optionally auto-launch the CSV report.  If set differently in UserPrefs, the runtime choice wins.
     
        .PARAMETER Verbose
          Written with strong support for verbose output.

        .PARAMETER Quiet
          bool.  minimalist output.
          The default is true (quiet output).
          Set to false for more detailed info.
        
        .EXAMPLE
        Invoke-RoboCheck -Computer vcenter01.lab.local
        Use passthrough authentication (SSPI) to connect to vCenter and return an ESX report object.
    
        .EXAMPLE
        Invoke-RoboCheck -Computer vcenter01.lab.local -Credential (Get-Credential)
        Get prompted for credentials then return the results to screen

        .EXAMPLE
        Invoke-RoboCheck -SaveCredential -Path "c:\creds"
        Example saving a credential to disk.  Provide the name of a folder for Path.
        You will be prompted for username and password.  You can then modify your preferences
        (Invoke-RoboCheck.ini) to reflect the path to your creds.
        After doing so, you no longer need to populate the Credential parameter as the script will automatically
        read the cred files.  Maximum of 2 can be added to prefernce settings for consumption at runtime.
    
        .EXAMPLE
        $credsVC = Get-Credential administrator@vsphere.local
        Invoke-RoboCheck -Computer C:\vc-list.txt -Credential $credsVC -OutputCSV
        Save credentials to a variable.  Then, run a report and save to CSV.
        
        .EXAMPLE
        Invoke-RoboCheck -Computer vc01,vc02 -Credential $credsVC
        Run a report against an array of vcenter names and deliver the info on screen.

        .EXAMPLE
        Invoke-RoboCheck -Computer bigvc01.lab.local -Cluster labcluster03 -Credential $labCreds -OutputCSV
        Run a report against a cluster saving the details to CSV.

        .EXAMPLE
        $report = Invoke-RoboCheck -Computer C:\Pester\robo-vc-list.txt -Credential $credsVC -CredFallBack $CredsRoboSSO -OutputCSV
        Run a report against a list of vCenters.  The server list should be one vCenter Server per line).
        In this example we use two sets of credentials.  The script will quietly try the next set as needed.
        Finally, ouput the results to CSV.
        .EXAMPLE
        $report = Invoke-RoboCheck -Computer vcva02.lab.local -Credential $credsLabVC
        C:\> $report | select Name,State,Model,overallstatus

        Name            State     Model     OverallStatus
        ----            -----     -----     -------------
        esx01.lab.local Connected MacPro6,1         green
        esx02.lab.local Connected MacPro6,1         green
        esx03.lab.local Connected MacPro6,1         green
        esx04.lab.local Connected MacPro6,1         green

        This example runs the report against vCenter, and saves it to a variable named $report.
        We then only look at a few of the items we are interested in.  To see the full report you can
        $report | Out-GridView

        Tip: If you did not use the OutputCSV parameter, but you saved the report to a variable like above,
        then you can still saves to CSV by performing:
        $report | Export-Csv -NoTypeInformation c:\temp\robo-report.csv

        .EXAMPLE
        $report = Invoke-RoboCheck -Computer vcva02.lab.local -Credential $credsLabVC
        C:\> $report | select -First 1

        Name                 : esx01.lab.local
        State                : Connected
        OverallStatus        : green
        DiffToUTC            : 0.1916
        Datastore1 Free (GB) : 67
        Datastore2 Free (GB) : 99
        MemoryFreeGB         : 28
        CpuUsageMhz          : 9115
        VM Count             : 4
        VmAutoStartOff       : n/a
        EsxStartProtection   : HA Protected
        IsStandalone         : False
        NtpRunning           : True
        NtpServers           : 10.202.3.250
        EsxVersion           : 6.0.0
        EsxBuild             : 3825889
        OsType               : vmnix-x86
        LicenseKey           : XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
        MemoryTotalGB        : 64
        NumCpu               : 4
        ProcessorType        : Intel(R) Xeon(R) CPU E5-1620 v2 @ 3.70GHz
        Manufacturer         : Apple Inc.
        Model                : MacPro6,1
        BIOS                 : MP61.88Z.0116.B16.1509081436
        ParentVC             : vcva02.lab.local

        Example showing all items captured and returned in an object for a single ESX host.

        .INPUTS
        System.String

        .OUTPUTS
        Object
        System.String
        System.Management.Automation.PSCredential

    #>

    [cmdletbinding(DefaultParameterSetName='None')]
    param (
	    
        [Parameter(ParameterSetName='Default',Mandatory,Position=0,
        HelpMessage='String.  One or more vCenter Servers, or path to input file (one server per line).')]
        [string[]]$Computer,

        #PSCredential.  Login credentials for one or more vCenter Server machines.
        [Parameter(ParameterSetName='Default')]
        [AllowNull()]
        [System.Management.Automation.Credential()][PSCredential]$Credential,

        #PSCredential.  Optionally, add another set of creds to try.
        [Parameter(ParameterSetName='Default')]
        [AllowNull()]
        [System.Management.Automation.Credential()][PSCredential]$CredFallBack,

        #switch.  Activate the OutputCSV switch to save ESXi report to CSV.
        [Parameter(ParameterSetName='Default')]
        [switch]$OutputCSV,

        #Report type.  The default is Detailed, which includes everything.  Tab complete though options.
        [Parameter(ParameterSetName='Default')]
        [string][ValidateSet ('Detailed','Standard','NTP','Datastore','AutoStart')]
        $ReportType = 'Detailed',

        #String.  Optionally report agaist a particular vSphere cluster to enumerate ESX host list.
        [Parameter(ParameterSetName='Default')]
        [AllowNull()]
        [string[]]$Cluster,

        [Parameter(ParameterSetName='Menu',HelpMessage='switch. Activate this parameter to save a credential to disk.', Mandatory, Position=0)]
        [switch]$SaveCredential,

        [Parameter(ParameterSetName='Menu',HelpMessage='Addstring.  Output directory to save Credential file when using the SaveCredential feature.', Mandatory, Position=1)]
        [Alias('Path')]
        [string]$CredOutputPath,

        #Switch.  Activate this switch to automatically open the CSV report when ready.
        [Parameter(ParameterSetName='Default')]
        [switch]$AutoLaunch=$false,

        #minimalist output.  default is true.
        [Parameter(ParameterSetName='Default')]
        [bool]$Quiet=$true

    )

    Begin {

        ## gather runtime info
        $thisRuntime = @{
            'Command'          =  $MyInvocation.Mycommand
            'Start Time'       =  (Get-Date)
            'Parameter Set'    =  $PSCmdlet.ParameterSetName
            'Running From'     =  (Get-PSCallStack)[0].Command
        }
        
        ## show runtime info
        Write-PrettyHash -InputHash $thisRuntime -Description 'Runtime Info'

        ## check verbose settings and welcome user
        If(-Not($PSCmdlet.MyInvocation.BoundParameters['Verbose'])) {
          $Script:VerboseMode = 'off'
        }
        Else {
          Write-Verbose -Message 'Welcome to Invoke-RoboCheck'
          Write-Verbose -Message 'Verbose mode is on'
          $Script:VerboseMode = 'on'
        }
        
        ## Run the Credentials Menu if needed, then exit
        If($SaveCredential){

          Write-Msg -InputMessage 'User selected SaveCredential.'
          If($PSCmdlet.MyInvocation.BoundParameters['CredOutputPath']){
            New-RoboCredential -Path $CredOutputPath
          }
          Else {
            # path is mandatory when using SaveCredential, so you cannot land here.
            # This else statement adds support in case user modifies the script
            # to make Path not mandatory, in which case we create the creds
            # in the local directory.
            New-RoboCredential
          }
          break
        }

        ## If not saving creds, begin normal processing
        Else {
        
          ## set the file name (full path to file)
          $RoboIniFile = "$Env:USERPROFILE\Invoke-RoboCheck.ini"

          ## Load configuration settings
          Invoke-ConfigHandler -FilePath $RoboIniFile
          
          #most restrictive
          If(-Not($Script:UserPref)){
            Throw "No config file enumerated! Terminating now."
          }

          ## Logging and reporting
          $dt             = Get-Date -format 'ddMMMyyyy_HHmm'
          $outputfileEsx  = ("{0}\{1}-{2}.csv" -f $Script:UserPref["Output"]["ReportDir"], $Script:UserPref["Output"]["EsxReportName"], $dt)
          $Script:logfile = ("{0}\{1}-{2}.log" -f $Script:UserPref["Output"]["LogDir"], $Script:UserPref["Output"]["LogName"], $dt)
         
          ## handle empty report fields
          ## '' returns nothing.
          ## '-' returns a dash.
          [string]$noResults = ''
            
          ## Start the Powershell Transcript Log
          Start-Logging -Path $logfile

          ## Check CSV auto-launch preference
          ## runtime wins over hardcoded pref
          If($AutoLaunch) {
            Write-Msg -InputMessage 'Runtime:: AutoLaunch for CSV is on'
          }
          Else {
            If(($Script:UserPref["Options"]["AutoLaunch"] -eq 'True')){
              $AutoLaunch = $true
              Write-Msg -InputMessage ('Config:: AutoLaunch for CSV is {0}' -f $AutoLaunch)
            }
          }

          ## runtime credential handling (if any)
          Test-RuntimeCred

          ## local credential handling (if any)
          Import-RoboXmlCred

          ##vCenter List
          Write-Msg -InputMessage '..Generating list of in-scope vCenter Servers'
          If($Computer) {

            ## check if this is a file path
            switch(Test-Path -Path $Computer){
                
              #handle input file
              $true {
                Try {
                  $allVCs = Get-Content -Path $Computer -ErrorAction Stop | Where-Object { $_ -ne 'Name' }
                }
                Catch {
                  Write-Msg -InputMessage ('{0}' -f $_.Exception.Message)
                  Invoke-ThrowControl -Reason ('Problem reading {0} as input file' -f ($Computer))
                } #End catch
              } #End true
                
              #handle server by name/IP
              $false {
                $allVCs = $Computer  
              } #End false
            } #End switch       
          } #End if computer
          Else {
            Write-Warning -Message 'No valid vCenter Server machines to connect to!'
            Invoke-ThrowControl -Reason 'Computer parameter Required!'
          } #End else computer
        } #End Else		
        }#End Begin

    Process {

        ## unless saving creds, we begin normal script activities now
        if(-Not($PSCmdlet.MyInvocation.BoundParameters['SaveCredential'])) {
    
          ## Load PowerCLI
          Invoke-PowerLoader -Verbose:$false

          ## Disconnect existing vCenter or ESX host sessions (if any)
          Disconnect-RoboVC -Verbose:$false

          ## main
          $MainReport = @()
          If($allVCs) {
                
            #region vCenter
            $MyColVC = @()
            Foreach($vc in $allVCs) {

              ## ICMP warm-up
              If(Test-Connection -ComputerName $vc -Count 1 -Quiet) {
                        Write-Msg -InputMessage ('..Processing vCenter {0}' -f $vc)
				    
                        ## Connect to vCenter
                        Connect-RoboVC -Computer $vc -Verbose

                        #region ESX				
                        If($Cluster) {
                            
                            Write-Msg -InputMessage ('User wants {0} hosts only' -f ($Cluster))
                            Try {
                                $HostObjects = Get-VMHost -Location (Get-Cluster -Name $Cluster) -Verbose:$false -ErrorAction Stop | Sort-Object -Property $_.Name
                            }
                            Catch {
                                Write-Msg -InputMessage ('{0}' -f $_.Exception.Message)
                                Invoke-ThrowControl -Reason ('Cannot enumerate requested Cluster {0}' -f ($Cluster))
                            } #End catch
                        } #End if
                        Else {
                    
                            Try {
                                $HostObjects = Get-VMHost -ErrorAction Stop -Verbose:$false | Sort-Object -Property $_.Name
                            }
                            Catch {
                                Write-Warning -Message ('{0}' -f $_.Exception.Message)
                                Write-Warning -Message 'Problem enumerating one or more host objects!'
                            } #End catch
                        } #End else

                        $MyColEsx = @()
                        Foreach ($EsxImpl in $HostObjects) {
					
                            ## Get the string name for esx
                            [string]$StrESX = $EsxImpl | Select-Object -ExpandProperty Name
                            Write-Msg -InputMessage ('..Checking health for {0} on {1}' -f ($StrESX), ($vc))

                  ## ICMP warm-up
                  If (Test-Connection -ComputerName $StrEsx -Count 1 -Quiet) {
                        
                      ## Check ESX to VC connection health 
                      ## Possible states are Connected, Disconnected and Not Responding.
                      [string]$EsxConState = $EsxImpl.ConnectionState
                      If($EsxConState -like 'Connected') {
                          Write-Msg -InputMessage ('{0}: Host Connection State Okay' -f ($StrESX))
                                
                          #region datastores
                          $dsReport = $null
                          $ds1Name = 'Datastore1 (GB Free)'
                          $ds2Name = 'Datastore2 (GB Free)'
                                    
                          $dsReport = Get-RoboDatastore -Computer $EsxImpl -Verbose:$false
                          if($dsReport) {
                              If($dsReport -is [array]) {

                                  #first ds
                                  if($dsReport[0]){
                                      [int]$Ds1FreeSpaceGB    = $dsReport[0].FreeSpaceGB
                                  }
                                  Else {
                                      [int]$Ds1FreeSpaceGB    = $dsReport.FreeSpaceGB
                                  }
                                            
                                  #next ds
                                  if($dsReport[1]){
                                      [int]$Ds2FreeSpaceGB    = $dsReport[1].FreeSpaceGB
                                  }
                                  Else {
                                      $Ds2FreeSpaceGB         = $noResults
                                  }
                              } #End If
                              Else {
                                  
                                  ##not an array, just one
                                  [int]$Ds1FreeSpaceGB        = $dsReport.FreeSpaceGB
                              }
                          }
                          Else {
                            #no results
                            $Ds1FreeSpaceGB = $noResults
                            $Ds2FreeSpaceGB = $noResults
                          } #End else
                          #endregion datastores

                          ## health check NTP
                          $NTPreport = $null
                          $NTPreport = Get-EsxNtpHealth -Computer $EsxImpl
                          [string]$NtpRunning = $NTPreport.NTPServiceRunning
                          [string]$NtpServers = $NTPreport.NtpServers
                          $DiffToUTC = $NTPreport.DiffToUTC

                          ## health check AutoStart protection
                          $AutoStartReport = Get-AutoStartConfig -Computer $EsxImpl
                          $VmAutoStartOff = [string]($AutoStartReport).VMAutoStartOff
                          $EsxStartProtection = [string]($AutoStartReport).EsxStartProtection

                          ## Get Running VM Count
                          If($AutoStartReport.NumRunningVMs) {
                              [int]$vmCount = $AutoStartReport.NumRunningVMs
                          }
                          Else {
                              [int]$vmCount = $EsxImpl | Get-VM -Verbose:$false | Where-Object { $_.PowerState -eq 'PoweredOn' } | Measure-Object | Select-Object -ExpandProperty Count
                          }
                                    
                          ## build esx report object
                          $EsxInfo = [PSCustomObject]@{
                              Name                 =    $StrESX
                              State                =    $EsxConState
                              OverallStatus        =    $EsxImpl.ExtensionData.OverallStatus
                              DiffToUTC            =    $DiffToUTC
                              $Ds1Name             =    [int]$ds1FreeSpaceGB
                              $Ds2Name             =    [int]$ds2FreeSpaceGB
                              MemoryFreeGB         =    [int]($EsxImpl.MemoryTotalGB - $EsxImpl.MemoryUsageGB)
                              CpuUsageMhz          =    $EsxImpl.CpuUsageMhz
                              'VM Count'           =    $vmCount
                              VmAutoStartOff       =    $VmAutoStartOff
                              EsxStartProtection   =    $EsxStartProtection
                              IsStandalone         =    $EsxImpl.IsStandalone
                              NtpRunning           =    $NtpRunning
                              NtpServers           =    $NtpServers
                              EsxVersion           =    $EsxImpl.Version
                              EsxBuild             =    $EsxImpl.Build
                              OsType               =    $EsxImpl.ExtensionData.Config.Product.OsType
                              LicenseKey           =    $EsxImpl.LicenseKey
                              MemoryTotalGB        =    [int]$EsxImpl.MemoryTotalGB
                              NumCPU               =    [int]$EsxImpl.NumCpu
                              ProcessorType        =    $EsxImpl.ProcessorType
                              Manufacturer         =    $EsxImpl.Manufacturer
                              Model                =    $EsxImpl.Model
                              BIOS                 =    $EsxImpl.ExtensionData.Hardware.BiosInfo.BiosVersion
                              ParentVC             =    ($Global:DefaultVIServer).Name
                          } #End object

                          $MyColEsx += $EsxInfo
                      }
                      Else {
                          Write-Warning -Message ('{0}: [state = {1}] on {2}' -f ($StrESX), $EsxConState, ($vc))

                          ## fill empty results since no data
                          Write-Warning -Message ('No results will be returned for {0}!' -f ($StrESX))
                          $EsxInfo = [PSCustomObject]@{
                              Name                 =    $StrESX
                              State                =    $EsxConState
                              OverallStatus        =    $noResults
                              DiffToUTC            =    $noResults
                              $Ds1Name             =    $noResults
                              $Ds2Name             =    $noResults
                              MemoryFreeGB         =    $noResults
                              CpuUsageMhz          =    $noResults
                              'VM Count'           =    $noResults
                              VmAutoStartOff       =    $noResults
                              EsxStartProtection   =    $noResults
                              IsStandalone         =    $noResults
                              NtpRunning           =    $noResults
                              NtpServers           =    $noResults
                              EsxVersion           =    $noResults
                              EsxBuild             =    $noResults
                              OsType               =    $noResults
                              LicenseKey           =    $noResults
                              MemoryTotalGB        =    $noResults
                              NumCPU               =    $noResults
                              ProcessorType        =    $noResults
                              Manufacturer         =    $noResults
                              Model                =    $noResults
                              BIOS                 =    $noResults
                              ParentVC             =    ($Global:DefaultVIServer).Name
                          } #End object
                          $MyColEsx += $EsxInfo
                      } #End Else          
                  } #End if ICMP esx

                  Else {
                    Write-Warning -Message ('Problem reaching ESXi host {0}.Name' -f ($EsxImpl))
                  } #End else ICMP esx
                } #End esx foreach
                $MyColVC += $MyColEsx
                #endregion ESX
              } #End vc if
                
              Else {
                Write-Warning -Message ('Problem reaching {0}' -f ($vc))
              } #End vc ICMP else

              ## Session cleanup
              Disconnect-RoboVC -Verbose:$false
            } #End vc foreach

                switch($ReportType) {

                    'Detailed' {

                        ##reporting setup for output object
                        $OutputParams = @(
                            'Name',
                            'State',
                            'OverallStatus',
                            'DiffToUTC',
                            ('{0}' -f $Ds1Name),
                            ('{0}' -f $Ds2Name),
                            'MemoryFreeGB',
                            'CpuUsageMhz',
                            'VM Count',
                            'VmAutoStartOff',
                            'EsxStartProtection',
                            'IsStandalone',
                            'NtpRunning',
                            'NtpServers',
                            'EsxVersion',
                            'EsxBuild',
                            'OsType',
                            'LicenseKey',
                            'MemoryTotalGB',
                            'NumCpu',
                            'ProcessorType',
                            'Manufacturer',
                            'Model',
                            'BIOS',
                            'ParentVC'
                        )
                    }
                    'Standard' {

                        ##reporting setup for output object
                        $OutputParams = @(
                            'Name',
                            'State',
                            'OverallStatus',
                            'DiffToUTC'
                        )
                    }
                    'Datastore' {
                    
                        ##reporting setup for output object
                        $OutputParams = @(
                            'Name',
                            ('{0}' -f $Ds1Name),
                            ('{0}' -f $Ds2Name)
                        )
                    }
                    'NTP' {

                        ##reporting setup for output object
                        $OutputParams = @(
                            'Name',
                            'DiffToUTC',
                            'NtpRunning',
                            'NtpServers'
                        )
                    }
                    'AutoStart' {
                        ##reporting setup for output object
                        $OutputParams = @(
                            'Name',
                            'VM Count',
                            'VmAutoStartOff',
                            'EsxStartProtection',
                            'IsStandalone',
                            'ParentVC'
                        )
                    }
                } #End switch

                $MainReport += $MyColVC
          } #End allVCs if
        
            if($MainReport){

                #return object results if not exporting to CSV
                If(!$OutputCSV) {
                  Write-Msg -InputMessage '..Preparing object output'
                  return $MainReport | Select-Object -Property $OutputParams
                  }
            }
            else{
                Write-Warning -Message 'No report object available for ouput!'
            }
        } #End if
    } #End Process 

    End {

      ## CSV output
      If($MainReport) {

        ## CSV Output
        If($outputCSV) {
          Write-Msg -InputMessage '..Preparing CSV output'

          ## create CSV output
          $MainReport | Select-Object -Property $OutputParams | Export-Csv -NoTypeInformation -Path $outputfileEsx

          Write-Msg -InputMessage 'Report output file:'
          If(Test-Path -Path $outputfileEsx) {
            Write-Msg -InputMessage $outputfileEsx
          }

          If($AutoLaunch -eq $true){
			        
              ## Launch ESX Report
              If(Test-Path -Path $outputfileEsx) {
                Invoke-Item -Path $outputfileEsx
              } #End test path
          } #End autoLaunch if
        } #End outputCSV
      } #End if main report

      ## script complete
      Write-Msg -InputMessage ('Ending {0} at {1}' -f $MyInvocation.Mycommand, (Get-Date))
        
      ## stop logging
      If ($Script:UserPref["Options"]["Logging"] -eq 'on') {
          Stop-Logging
      } #End if logging
  } #End End
}
