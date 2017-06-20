Function Write-Msg {

  <#

      .DESCRIPTION
        Writes output using Write-Output or Write-Verbose,
        depending on the current runtime Verbose mode of the parent module.
        This is part of the Invoke-RoboCheck module.

      .NOTES
        Script:         Write-Msg.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

      .EXAMPLE
      Write-Msg -InputMessage "Hello World"

  #>

  [CmdletBinding(RemotingCapability='None')]
  Param
  (
      [Parameter(Mandatory,HelpMessage='string. The message to input or otherwise pass along the pipeline')]
      [AllowEmptyString()]
      [Alias('InputObject')]
      [Alias('Message')]
      [PSObject]$InputMessage
  )

  Begin {
           
      ## If we cannot determine VerboseMode
      If(!$Script:VerboseMode) {

          Throw 'Cannot determine verbose mode'
      }
  }

  Process {

      switch($VerboseMode){
            
          'off' {
              ## if not in quiet mode and not in verbose
              If(!$Quiet) {
                  $Msg = Write-Output -InputObject ('{0}' -f ($InputMessage))
              }
          }
          
          'on' {
              ## if verbose mode is on
              $Msg = Write-Verbose -Message ('{0}' -f ($InputMessage))
          }
      }
      return $Msg

  }#End Process
}