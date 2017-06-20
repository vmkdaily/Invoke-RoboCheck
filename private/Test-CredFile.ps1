Function Test-Credfile {
    
    <#
      .DESCRIPTION
        Tests an encrypted xml credential file for validity.
        Does not test actual login to target devices, but simply confirms
        the health of the Credential file itself.

      .SYNOPSIS
        Returns true if the credential passes validation.
        Returns false if the credential fails validation.
        
      .NOTES
        Script:         Test-CredFile.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Based On:       Import-PSCredential by Hal Rottenberg
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017
        
      .PARAMETER Path
      String.  The path to the encrypted credential.

      .EXAMPLE
      Test-CredFile -Path "C:\Creds\credentials.enc.xml"

      .INPUTS
      System.String
        
      .OUTPUTS
      System.Boolean

      ABOUT CREDENTIAL FILES
        Credential files can only be consumed by
        the user that created it on the machine it was created on.
        See Help Get-Credential for more information.

    #>
    
    Param(

        [Parameter(Mandatory,HelpMessage='Path to the cred file')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Path
    )

    Begin {
        If($Path) {
            Try {
                Test-Path -Path $Path -ErrorAction Stop
                Write-Msg -InputMessage ("Path to {0} looks okay" -f $Path)
                [bool]$PathReachable = $true
            }
            Catch {
                Write-Warning -Message 'Path to creds not valid!  Please update UserPref settings.'
            }
        } #End if
    } #End Begin

    Process {
             
        If($PathReachable) {
          # Import credential file
          $import = Import-Clixml -Path $Path 
    	
          # Test for valid import
          if(!$import.UserName -or !$import.EncryptedPassword) {
                Write-Msg -InputMessage ("Cannot import credential from {0}" -f ($path))
            return $false
          } #End if
            Else {
                Write-Msg -InputMessage ("Validation succeeded for {0}" -f ($path))
                return $true
            } #End Else
        } #End if reachable
    } #End Process
}
