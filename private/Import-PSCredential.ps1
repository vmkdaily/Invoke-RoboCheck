Function Import-PSCredential {

    <#
      .DESCRIPTION
        Imports a PSCredential from an encrypted xml file on disk.
            
      .NOTES
        Script:         Import-PSCredential.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Hal Rottenberg
        Modified:       Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

      .EXAMPLE
      Import-PSCredential -Path <path to cred file>

      ADDITIONAL INFORMATION
        To create the cred file consumed by this script, use the SaveCredentials parameter of the 
        Invoke-RoboCheck module, or run the Export-PSCredential function by @halr9000 out of band.
        You can also follow the Powershell help examples for Get-Credential, which shows how to save
        a Credential to disk. 

    #>

    [CmdletBinding()]
    param (
            
    [ValidateScript({Test-Path -Path $_})]
    [string]$Path = 'credentials.enc.xml' )

    Process {

        if($Path) {
            # Import credential file
            $import = Import-Clixml -Path $Path 

            # Test for valid import
            if(!$import.UserName -or !$import.EncryptedPassword) {
                Throw 'Input is not a valid ExportedPSCredential object, exiting.'
            }
            $Username = $import.Username

            # Decrypt the password and store as a SecureString object for safekeeping
            $SecurePass = $import.EncryptedPassword | ConvertTo-SecureString

            # Build the new credential object
            $CredObj = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePass
            Write-Output -InputObject $CredObj
        }
        Else {
            Write-Msg -InputMessage 'User Preferences not set (or problem reaching path).'
        }
    } #End process
}