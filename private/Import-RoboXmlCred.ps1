Function Import-RoboXmlCred {   

        <#
        .DESCRIPTION
          Imports login credentials from encrypted xml and converts them into PSCredential objects for consumption by Invoke-RoboCheck.
          Not for interactive use.  The PSCredential is returned to a variable for use in the module when connecting to vCenter.

        
        .NOTES
            Script:         Import-RoboXmlCred.ps1
            Type:           Function
            ParentModule:   Invoke-RoboCheck
            Based On:       Import-PSCredential by Hal Rottenberg
            Author:         Mike Nisk
            Organization:   vmkdaily
            Updated:        05April2017
        
        
        .EXAMPLE
        Import-RoboXmlCred
        The function is designed to run with no parameters.  It looks up the path values based on the Invoke-RoboCheck.ini prefernces.

        NOTE ABOUT CREDENTIAL FILES

          Remember that a cred file can only be consumed by
          the user that created it on the machine it was created on.
        
        .INPUTS
        None
        
        .OUTPUTS
        System.Management.Automation.PSCredential

        #>

    [CmdletBinding()]
    Param() #none

    Process {

        ## if no Credential
        If(!$Credential) {
            Write-Msg -InputMessage 'No runtime Credential found.'

            ## Test the xml at Credential Path
            If(Test-CredFile -Path $Script:UserPref["Auth"]["CredentialPath"] -ErrorAction SilentlyContinue){
                Write-Msg -InputMessage 'Credential by path okay.'
                    
                ## import the Credential from path
                Try {
                    $Script:CredentialFromPath = Import-PSCredential -Path $Script:UserPref["Auth"]["CredentialPath"] -ErrorAction Stop
                }
                Catch {
                    Write-Msg -InputMessage "`tProblem importing hard coded Credential."
                } #End catch
            } #End if
            Else {
                Write-Msg -InputMessage 'Validation failed for Credential by path.'
            } #End else hard coded Credential

            ## if no CredFallBack
            Write-Msg -InputMessage 'No runtime CredFallBack found.'

            ## Test the xml file at CredFallBack path
            If(Test-CredFile -Path $Script:UserPref["Auth"]["CredFallBackPath"] -ErrorAction SilentlyContinue){
                Write-Msg -InputMessage 'CredFallBack by path okay.'
                    
                ## import the CredFallBack from path
                Try {
                    $Script:CredFallBackFromPath = Import-PSCredential -Path $Script:UserPref["Auth"]["CredFallBackPath"] -ErrorAction Stop
                }
                Catch {
                    Write-Msg -InputMessage 'Problem importing CredFallBack by path.'
                } #End catch
            } #End if
            Else {
                Write-Msg -InputMessage 'Validation failed for CredFallBack by path.'
            } #End else hard coded Credential

            ## check validity
            If($CredentialFromPath -or $CredFallBackFromPath) {
                
                If($CredentialFromPath -is [PSCredential]) {
                    $cred1User = ('{0}' -f $CredentialFromPath.GetNetworkCredential().UserName)
                    Write-Msg -InputMessage ('Ready to run as {0} (if needed)' -f ($Cred1User))
                } #End if
                If($CredFallBackFromPath -is [PSCredential]) {
                    $cred2User = ('{0}' -f $CredFallBackFromPath.GetNetworkCredential().UserName)
                    
                    ##prevent lock-outs
                    If ($cred1User -match $cred2User) {
                        Write-Warning -Message 'Halting! Each Credential should be unique to prevent account lockout.'
                        Invoke-ThrowControl -Reason 'Duplicate credentials provided'
                    }
                    Else {
                    Write-Msg -InputMessage ('Ready to run as {0} (if needed)' -f ($Cred2User))
                    }
                } #End if
            } #End if
        } #End if
    } #End Process
}
