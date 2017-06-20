Function Invoke-ThrowControl {

    <#
      .SYNOPSIS
        Generates a terminating error.  This function is a wrapper
        for the Throw Keyword.

      .DESCRIPTION
        If the Invoke-RoboCheck function must terminate with a
        throw, let's handle runtime sessions and logging first,
        and then throw.
    
      .NOTES
        Script:         Invoke-ThrowControl.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

      .PARAMETER Reason
        String. Optional text describing reason for throwing a terminating error.

      .Example
      Invoke-ThrowControl -Reason "Cannot connect to one or more machines"
      Pass a text string to the throw command, and allow the function to gracefully
      execute any required cleanup.  Finally, share the Reason with user before
      terminating.

      .EXAMPLE
      Invoke-ThrowControl
      Just like a normal throw, there is no need to pass any additional information.
      The function performs it's normal cleanup such as stopping any logging, disconnecting
      from vCenter, etc.  Finally, we throw a terminating error.

    #>

    [CmdletBinding()]
    param (
        
      #string passed to a custom throw message
      [AllowNull()]
      [AllowEmptyString()]
      [string]$Reason
    )
	
    Begin {
      #pre-throw cleanup
      Stop-Logging
      Disconnect-RoboVC
    } #End Begin

    Process {
      ##throw
      If($Reason) {
        Throw ('{0}' -f ($Reason))
      }
      Else {
        Throw
      }
    } #End Process
}