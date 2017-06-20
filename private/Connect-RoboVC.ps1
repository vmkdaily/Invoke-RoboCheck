Function Connect-RoboVC {

    <#
      .DESCRIPTION
        Connects to vCenter.  This is part of the Invoke-RoboCheck module.

      .NOTES
        Script:         Connect-RoboVC.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

      .PARAMETER Computer
        The IP Address or DNS name of the vCenter Server machine to connect to.
        For IPv6, enclose address in square brackets, for example [fe80::250:56ff:feb0:74bd%4]

      .EXAMPLE
      Connect-RoboVC -Computer vcenter01.lab.local

    #>
    
    Param(
    
    [Parameter(Mandatory,HelpMessage='string. IP Address or DNS name of target VMware vCenter Server machine.')]
    [string]$Computer

    )

    Process {

        If($Credential) {

            ## try the main Credential
            Try {
                $null = Connect-VIServer -Server $Computer -Credential $Credential -ErrorAction Stop -WarningAction SilentlyContinue
                Write-Msg -InputMessage ('Using provided Credential of {0}' -f $Credential.GetNetworkCredential().UserName)
            }
            Catch {

                Write-Warning -Message ('Error Detected! {0}' -f $_.Exception.Message)
                Write-Warning -Message ('Problem connecting to vCenter {0} using main Credential' -f ($Computer))

                ## quietly move on to fall-back creds (if any)
                If($CredFallBack) {

                    Try { 
                        $null = Connect-VIServer -Server $Computer -Credential $CredFallBack -ErrorAction Stop -WarningAction SilentlyContinue
                        Write-Msg -InputMessage ('Using fall-back Credential of {0}' -f $CredFallBack.GetNetworkCredential().UserName)
                    }
                    Catch {
                        Write-Warning -Message ('Error Detected! {0}' -f $_.Exception.Message)
                        Write-Warning -Message ('Problem connecting to vCenter {0} using CredFallBack credentials' -f ($Computer))
                    }
                }
                Else {
                    Write-Msg -InputMessage 'No CredFallBack provided.'
                }
            }
        } #End if Credential by Object

        # If we have cred files on disk
        Elseif($CredentialFromPath -or $CredFallBackFromPath) {
                
            ## try the main Credential by path
            ## you can have more than one, but the first must be populated
            If($CredentialFromPath -is [PSCredential]) {

                Try {
                    $null = Connect-VIServer -Server $Computer -Credential $CredentialFromPath -ErrorAction Stop -WarningAction SilentlyContinue
                    Write-Msg -InputMessage ('Using provided Credential of {0}' -f $CredentialFromPath.GetNetworkCredential().UserName)
                }
                Catch {
                    
                    ## quietly move on to fall-back creds by path (if any)
                    ## we only try this if the primary credential by path has failed
                    If($CredFallBackFromPath -is [PSCredential]) {

                        Try {
                            $null = Connect-VIServer -Server $Computer -Credential $CredFallBackFromPath -ErrorAction Stop -WarningAction SilentlyContinue
                            Write-Msg -InputMessage ('Using fall-back Credential of {0}' -f $CredFallBackFromPath.GetNetworkCredential().UserName)
                        }
                        Catch {
                            Write-Warning -Message ('Error Detected! {0}' -f $_.Exception.Message)
                            Write-Warning -Message ('Problem connecting to vCenter {0} using the provided xml cred file(s) from path.' -f ($Computer))
                        }
                    }
                    Else {
                        Write-Msg -InputMessage 'No valid Credentials by path can be found.'
                    }
                } #End Catch
            } #End If
        } #End Elseif

        ## fallback to local machine VICredentialStore and then SSPI
        Else {

            Write-Msg -InputMessage 'No valid runtime credentials found'
            Write-Msg -InputMessage "..Trying native Connect-VIServer options (VICredentialStore and Pass-Through) as $($env:USERDOMAIN)\$($env:USERNAME)"
            Try {     
                $null = Connect-VIServer -Server $Computer -ErrorAction Stop -WarningAction SilentlyContinue -Force
            }
            Catch {
                Write-Warning -Message ('Error Detected! {0}' -f $_.Exception.Message)
                Write-Warning -Message ('Problem connecting to vCenter {0} using SSPI (pass-through)' -f ($Computer))
            }
        } #End Else
    } #End Process

    End {

        ## if we're still not connected
        If(!$Global:DefaultVIServer.IsConnected) {
            Write-Msg -InputMessage ("{0}`: Problem Connecting!" -f ($Computer))
            Invoke-ThrowControl -Reason 'Problem enumerating one or more vCenter Servers!' #throw here is most restrictive and recommended
        } #End if throw needed
        Else {	
          ## If connection ok
          If($Global:DefaultVIServer.IsConnected) {
            Write-Msg -InputMessage ('Connected to {0}' -f ($Global:DefaultVIServer))
          } #End if vc ok
        } #End else
    } #End End
}