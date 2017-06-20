Function Get-AutoStartConfig {

    <#

      .SYNOPSIS
        This function performs read-only Auto-Start Reporting for ESXi and VMs.

      .DESCRIPTION
        The VMware vSphere auto-start feature is designed for ESXi hosts that do not have HA protection.
        This script identifies ESXi hosts (from the connected vCenter) that are not participating in vSphere HA,
        and then returns information about the configured start protection.
        In addition to ESX Start Protection review, the script also checks virtual machine auto-start.

      .NOTES
        Script:         Get-AutoStartConfig.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Modified:       05April2017

      .PARAMETER Computer
        The Esx Object to interrogate.

      .EXAMPLE
      $esx = Get-VMHost | Get-Random
      Get-AutoStartConfig -Computer $esx

    #>

    [cmdletbinding()]
    param (
      [Parameter(Mandatory, HelpMessage = 'ESXi host object')]
      [PSObject[]]$Computer    
    )

    Begin {
    ## VMs to ignore
    $IgnoredVMs = @('*test*','*Windows*','*Serial*')

    ## exclusive of the above, uncomment the following:
    #$IgnoredVMs = ""
    }

    Process {
        ## main
      $AutoStartReport = @()
      Foreach ($VMhostImpl in $Computer) {
		
          ## If Connected
          if(($VMhostImpl.ExtensionData.Runtime.ConnectionState) -like 'connected') {
            
            ## If ESX host is not HA protected
            If(!$VMHostImpl.Parent.HAEnabled -and !$VMHostImpl.ExtensionData.Runtime.DasHostState){
            
              Write-Msg -InputMessage ('{0} is not an HA Protectected host.' -f $VMhostImpl.Name)
              Write-Msg -InputMessage '..Checking ESX auto-start configuration.'
			
              ## Returns true if startup protection is configured at the ESX level
              [bool]$HostAutoStart = (Get-VMHostStartPolicy -Verbose:$false -VMHost $VMHostImpl).Enabled
           
              If($HostAutoStart -eq $true) {
            
                  ## This host uses ESX auto-start
                  [string]$EsxStartProtection = 'ESX Auto-Start'
                  Write-Msg -InputMessage ('HostAutoStart Enabled: {0}' -f ($HostAutoStart))
                          
                  ## Get list of running VMs
                  $PoweredOnVMs = $VMHostImpl | Get-VM -Verbose:$false | Where-Object { $_.PowerState -eq 'PoweredOn' }
                  [int]$numRunningVMs = $PoweredOnVMs.Count
                
                  ## Ignore user-specified displaynames
                  $InScopeVMs = $PoweredOnVMs | Where-Object { $_.Name -notlike $IgnoredVMs[0] -and $_.Name -notlike $IgnoredVMs[1] } #-and $_.Name -notlike $IgnoredVMs[2] }
        
                  ## Only VMs without HA protection can be configured for auto-start
                  $VmList = $InScopeVMs | Where-Object { $_.ExtensionData.Runtime.DasVmProtection.DasProtected -ne 'true' }
        
                  ## string the VM names
                  ## the policy cmdlet runs a bit faster on string input
                  $strVMList = $VmList | Select-Object -ExpandProperty Name

                  ## Finally, get virtual machine start policy objects
                  Try {
                      $VmStartPolicyAll = Get-VMStartPolicy -VM $strVMList -Verbose:$false -ErrorAction Stop
                  }
                  Catch {
                      Write-Msg -InputMessage 'Problem checking Start Policy for one or more VMs'
                      Write-Warning -Message ("{0}`:{1}" -f $VMhostImpl.Name, $_.Exception.Message)
                  }

                  Try {
                      $VmStartPolicyNone = $VmStartPolicyAll | Where-Object { $_.StartAction -eq 'None' }
                  }
                  Catch {
                      Write-Verbose -Message ('Auto-start seems Okay for all VMs on {0}' -f $VMhostImpl.Name)
                  }

                  If($VmStartPolicyNone) {
                    [string]$VmAutoStart = ($VmStartPolicyNone | Select-Object -ExpandProperty VM).Name -join ','
                  }
                  Else {
                    [string]$VmAutoStart = 'none (ok)'
                  }
              } #End if
              Else {
                  ## This host has no Start Protection configured
                  [string]$EsxStartProtection = 'Unprotected'
                  [string]$VmAutoStart = 'Unprotected' 
              }
            } #End if
            Else {
              Write-Msg -InputMessage ('Host {0} participates in vSphere ha-fdm' -f $VMHostImpl.Name)
              [string]$EsxStartProtection = 'HA Protected'
              [string]$VmAutoStart = 'n/a'
            }

            ##create object
            $AutoStartReport += $VMHostImpl | Select-Object -Property Name,@{n='EsxStartProtection';e={$EsxStartProtection}},@{n='VMAutoStartOff';e={$VmAutoStart}},@{n='NumRunningVMs';e={$numRunningVMs}}
          }#end if connected
            
          ## If not connected
          Else {
              Write-Warning -Message ('Protection info for {0} unavailable!  Host is not connected to VC.' -f ($VMhostImpl))
              $AutoStartReport = New-Object -TypeName PSObject -Property @{
                  EsxStartProtection   = ''
                  VMAutoStartOff       = ''
                  NumRunningVMs        = '' 
              }
          } #End Else
    }#End foreach esx
    return $AutoStartReport
  }#End Process
}
