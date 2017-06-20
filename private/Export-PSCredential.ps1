Function Export-PSCredential {    

    <#
      .DESCRIPTION
        Exports a PSCredential to an encrypted xml file on disk.
        Used by the Invoke-RoboCheck Module if saving Credentials to
        disk with the SaveCredentials parameter.
            
      .NOTES
        Function:       Export-PSCredential
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Hal Rottenberg
        Modified:       Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

        Author: 	Hal Rottenberg <hal@halr9000.com>
        Url:		http://halr9000.com/article/tag/lib-authentication.ps1
        Purpose:	These functions allow one to easily save network credentials to disk in a relatively
                        secure manner.  The resulting on-disk credential file can only be decrypted
                        by the same user account which performed the encryption.  For more details, see
                        the help files for ConvertFrom-SecureString and ConvertTo-SecureString as well as
                        MSDN pages about Windows Data Protection API.

        Usage:	        Export-PSCredential [-Credential <PSCredential object>] [-Path <file to export>]
                        Export-PSCredential [-Credential <username>] [-Path <file to export>]
                        If Credential is not specififed, user is prompted by Get-Credential cmdlet.
                        If a username is specified, then Get-Credential will prompt for password.
                        If the Path is not specififed, it will default to "./credentials.enc.xml".
                        Output: FileInfo object referring to saved credentials

                        Import-PSCredential [-Path <file to import>]

                        If not specififed, Path is "./credentials.enc.xml".
                        Output: PSCredential object

      .EXAMPLE
      $creds = Get-Credential
      Export-PSCredential -Credential $creds -Path c:\creds\myCreds.enc.xml
      This example illustrates using Get-Credential to be prompted for username and password.
      Then, we save that to a variable called $creds.  Finally, we use Export-PSCredential to
      write the Credential to disk. 

      ALTERNATIVES FOR CREDENTIAL FILES ON DISK

        You may also consider using the PowerCLI New-VICredentialStoreItem cmdlet instead.  Once created,
        that provides automatic checks against the VICredentialStore before using passthrough (SSPI). 

    #>

    [CmdletBinding()]
  param ( [System.Management.Automation.Credential()][PSCredential]$Credential = (Get-Credential), [string]$Path = 'credentials.enc.xml' )

    Begin {
	    
        # Look at the object type of the $Credential parameter to determine how to handle it
        switch ( $Credential.GetType().Name ) {
          # It is a credential, so continue
          PSCredential		{ continue }
          # It is a string, so use that as the username and prompt for the password
          String				{ $Credential = Get-Credential -Credential $Credential }
          # In all other caess, throw an error and exit
          default				{ Throw 'You must specify a credential object to export to disk.' }
        } #End switch
    } #End Begin
	
    Process {
      # Create temporary object to be serialized to disk
      $export = '' | Select-Object -Property Username, EncryptedPassword
	
      # Give object a type name which can be identified later
      $export.PSObject.TypeNames.Insert(0,'ExportedPSCredential')
	
      $export.Username = $Credential.Username

      # Encrypt SecureString password using Data Protection API
      # Only the current user account can decrypt this cipher
      $export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString
    } #End Process

    End {

      # Export using the Export-Clixml cmdlet
      $export | Export-Clixml -Path $Path
      Write-Msg -InputMessage 'Credentials saved to: '

      # Return FileInfo object referring to saved credentials
      Get-Item -Path $Path
    } #End End
}