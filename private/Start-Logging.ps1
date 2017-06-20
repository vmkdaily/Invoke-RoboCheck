Function Start-Logging {
  <#

      .DESCRIPTION
        Start Logging for vSphere Health Checks using Invoke-RoboCheck.
        We depend on the user preferences being set already.
        This is part of the Invoke-RoboCheck module.

      .NOTES
        Script:         Start-Logging.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

  #>

  Param
  (
      [Parameter(Mandatory,HelpMessage='Path to existing folder to save Powershell Transcript log')]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({Test-Path -LiteralPath $_ -PathType Container -IsValid})]
      [string]$Path
  )

    
  Process {

    If ($Script:UserPref["Options"]["Logging"] -eq 'on') {

          Write-Verbose -Message ('Transcript Logging is {0}' -f $Script:UserPref["Options"]["Logging"])
		
          Try {
              $null = Start-Transcript -Path $Path -ErrorAction Stop
          }
      Catch {
              Write-Warning -Message ('{0}' -f $_.Exception.Message)
              Throw 'Cannot start logging'
          } 
    } #End if
  }# End Process
}
