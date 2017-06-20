Function Get-RoboDatastore {

    <#
      .DESCRIPTION
        Gather datastore info from ESX.  Used only with
        the Invoke-RoboCheck module.  Modify as needed.

      .NOTES
        Script:         Get-RoboDatastore
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Modified:       05April2017

      ABOUT CHOOSING CUSTOM DATATORES

        You may choose to modify the function hereinbelow to reflect
        your datastores of interest.  Currently, the script sorts by smallest
        to largest datastore size, then selects the first 2.
    #>

    [cmdletbinding()]
  param (
    [Parameter(Mandatory, HelpMessage = 'ESXi host object')]
    [PSObject[]]$Computer
       
  )
	
  Process {
        
        $dsCol = $null
        $dsCol = @()
        foreach($VMHostImpl in $Computer) {
			
            if(($VMHostImpl.ExtensionData.Runtime.ConnectionState) -like 'connected') {
               
                ## Get Datastore Info					
              Try {

                $ds = Get-Datastore -RelatedObject $VMHostImpl -ErrorAction Stop | Sort-Object -Property CapacityGB
              }
              Catch {

                    Try {
                        Write-Msg -InputMessage 'Attempting legacy Get-Datastore'
                        $ds = $VMHostImpl | Get-Datastore -ErrorAction Stop | Sort-Object -Property CapacityGB
                    }
                    Catch {
                        Write-Warning -Message ('{0}' -f $_.Exception.Message)
                        Invoke-ThrowControl -Reason ("{0}`: Host connection problem?  Cannot enumerate datastores" -f ($VMHostImpl))
                    }
                }

                If($ds) {
                    $dsCol += $ds
                } #End if
            } #End if
            Else {
                Write-Warning -Message ('Host {0} is not connnected!' -f ($VMHostImpl))
            }
        } #End foreach

        $result = $null
        $result = $ds | Where-Object { $_.Name } | Foreach-Object {
            New-Object -TypeName PSObject -Property @{
            Name            = $_.ExtensionData.Info.Name
            CapacityGB      = $_.ExtensionData.Summary.Capacity/1gb
            FreeSpaceGB     = $_.ExtensionData.info.FreeSpace/1gb
            OverallStatus   = $_.ExtensionData.Info.OverallStatus
            ConfigStatus    = $_.ExtensionData.Info.ConfigStatus
          }
      $dsCol += $result
    } #End foreach
    return $dsCol | Select-Object -Property Name,FreeSpaceGB -First 2
  } #End Process
}
