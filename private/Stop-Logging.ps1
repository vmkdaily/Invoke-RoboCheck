Function Stop-Logging {

    <#

      .DESCRIPTION
        Stop Logging for vSphere Health Checks using Invoke-RoboCheck.
        We depend on the user preferences being set already.
        This is part of the Invoke-RoboCheck module.

      .NOTES
        Script:         Stop-Logging.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

  #>

  [CmdletBinding()]
  Param() #none

  Process {
      
    ## Stop the Powershell transcript logging
    Try {
      $null = Stop-Transcript -ErrorAction Stop
      Write-Msg -InputMessage 'Transcript logging stopped successfully'
    }
    Catch {
      Write-Warning -Message 'Problem with PowerShell Transcript logging'
    }
	
    If (Test-Path -Path $Script:logfile) {
      Write-Msg -InputMessage ('Log file: {0}' -f $Script:logfile)
    }
    Else {
      Write-Warning -Message 'Log file health is unknown (please review)'
    }
  } #End Process
}
