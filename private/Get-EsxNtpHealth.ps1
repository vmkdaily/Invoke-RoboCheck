Function Get-EsxNtpHealth {

    <#

      .DESCRIPTION
        Get the NTP health for ESX hosts.  This is part of the vSphere health
        checks performed by the parent module Invoke-RoboCheck.

      .NOTES
        Script:         Get-EsxNtpHealth.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Modified:       Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017
        Based on:       http://psvmware.wordpress.com/2013/09/03/get-vmhosttimereport-reporting-time-from-vmhost-system/
        
    #>
	
  [cmdletbinding()]
  param (
    [Parameter(Mandatory, HelpMessage = 'ESXi host object')]
    [PSObject[]]$Computer
  )
	
  Process {
    $TimeReport = $null
    $TimeReport = @()
    foreach ($VMhostImpl in $Computer) {
			
            if(($VMhostImpl.ExtensionData.Runtime.ConnectionState) -like 'connected'){
                Write-Debug -Message ('Get-EsxNtpHealth function shows {0} as connected' -f ($VMhostImpl))
                $VMHostView = $VMhostImpl | Get-View -Verbose:$false
                $VMHostDateTimeSystem = Get-View -ID $VMHostView.ConfigManager.DateTimeSystem -Verbose:$false
                $VMHostServiceSystem = Get-View -ID $VMHostView.ConfigManager.ServiceSystem -Verbose:$false
                $VMHostTime = $VMHostDateTimeSystem.QueryDateTime()
                $NtpServiceState = ($VMHostServiceSystem.ServiceInfo.Service | Where-Object { $_.Key -eq 'ntpd' }).Running
                $NtpServers = $VMHostDateTimeSystem.DateTimeInfo.NtpConfig.Server
                $UTCTime = (Get-Date).ToUniversalTime()
			
          ## build up the time report
          $TimeReport += $VMhostImpl | Select-Object -Property Name,`
                              @{ n = 'VMHostTime'; e = { $VMHostTime } },`
                              @{ n = 'UTCTime'; e = { $UTCTime } },`
                              @{ n = 'NTPServers'; e = { $NtpServers } },`
                              @{ n = 'NTPServiceRunning'; e = { $NtpServiceState } },`
                              @{ n = 'DiffToUTC'; e = { [Math]::Round([math]::abs(($VMHostTime - $UTCTime).TotalSeconds), 5) } }
            }
            else {
                ## return null values
                $TimeReport = New-Object -TypeName PSObject -Property @{
                    VMHostTime        = ''
                    UTCTime           = ''
                    NTPServers        = ''
                    NTPServiceRunning = ''
                    DiffToUTC         = '' 
                }
            }
    }
    return $TimeReport
  }
}