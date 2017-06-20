Function Test-RuntimeCred {

    <#
      .DESCRIPTION
        Quick check to ensure duplicate user names are not provided for runtime
        PSCredential Objects.  The purpose is to prevent accidental account lock outs.

      .NOTES
        Script:         Test-RuntimeCred.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        31March2017
    #>

    ## check validity
    If($Credential -or $CredFallBack) {
                
        If($Credential -is [PSCredential]) {
            $runtimeCred1User = ('{0}' -f $Credential.GetNetworkCredential().UserName)
            Write-Msg -InputMessage ('Ready to run as {0} (if needed)' -f ($runtimeCred1User))
        } #End if
        If($CredFallBack -is [PSCredential]) {
            $runtimeCred2User = ('{0}' -f $CredFallBack.GetNetworkCredential().UserName)
                    
            ##prevent lock-outs
            If ($runtimeCred1User -match $runtimeCred2User) {
                Write-Warning -Message 'Halting! Each Credential should be unique to prevent account lockout.'
                Invoke-ThrowControl -Reason 'Duplicate credentials provided'
            }
            Else {
            Write-Msg -InputMessage ('Ready to run as {0} (if needed)' -f ($runtimeCred2User))
            }
        } #End if
    } #End if

}
