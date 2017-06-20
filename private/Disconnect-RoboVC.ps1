Function Disconnect-RoboVC {

    <#
      .DESCRIPTION
        Disconnect PowerCLI sessions.  This is part of the
        Invoke-RoboCheck module.
    
      .NOTES
        Script:         Disconnect-RoboVC.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

      .EXAMPLE
      Disconnect-RoboVC
      The function takes no parameters.
    #>

    [CmdletBinding()]
    Param() #none

    Begin {
        #nothing
    }

    Process {

        ## Disconnect existing vCenter or ESX host sessions (if any)
      If($global:DefaultVIServer -or $global:DefaultVIServers) {
            $currentVISessions = $global:DefaultVIServers
		    
            If($currentVISessions){
                foreach($session in $currentVISessions) {
                    Write-Msg -InputMessage ('..Disconnecting existing vCenter connection to {0}' -f ($session))
                $null = Disconnect-VIServer -Server $session -Confirm:$False -Force
                } #End foreach
            } #End if
      } #End if
    } #End Process

    End {
        #nothing
    } #End End
}
