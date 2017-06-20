Function New-RoboCredential {

    <#
    
      .Synopsis
        Presents an interactive menu allowing user to save a Credential an xml file as a secure string.

      .DESCRIPTION
         Based on the Import/Export PSCredential Functions by Hal Rottenberg circa 2010.
         This script contains everything you need to get started with saving and reading back credential files.
         This uses Powershell version 2 syntax.  This functionality is still useful in Powershell 5 and later.

      .Notes
        Script:         New-RoboCredential.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017
        Requires:	Depends on the Import/Export PSCredential Functions by Hal Rottenberg (included)
        Based on:       Option menu based on prior art by Ryan Fromm, VMware PSO 2011

      .EXAMPLE
       .\New-RoboCredential.ps1
       Consume the interactive menu and then save the resulting cred file to the current directory

      .EXAMPLE
       .\New-RoboCredential.ps1 -CredOutputPath "C:\Pester"
       Consume the interactive menu and then save the resulting cred file to the desired path
    
      .INPUTS
      System.String

      .OUTPUTS
      Encrypted xml credential

      ABOUT USING CREDENTIALS
       As with all Powershell credentials, these will only work with the user that created them.
       
      IMPORTANT
        Remember to delete or update Credential files when your password changes.

    #>

    [CmdletBinding()]
    param (

          #Path to save the encrypted cred files.
          #The function herein supports creating missing directories, however we still require path.
          #Valid path is enforced when user calls the main Invoke-RoboCheck function.
          [Alias('Path')]
          [string]$CredOutputPath = $PWD
    )

    Begin {

        ## Choose your naming standard for Credfiles here.
        ## Or leave the defaults that are provided below.
        ## We add the path later.
        $credName1 = 'CredsVC1.enc.xml'
        $credName2 = 'CredsVC2.enc.xml'
        $credName3 = 'CredsVC3.enc.xml'
        $credName4 = 'CredsVC4.enc.xml'

        ## create directory if it is missing.
        ## default is true which will create the desired directory if it does not exist.
        [bool]$CreateDirectory = $true

        ## Set to true to prevent fall-back to present working directory for credential file output.
        ## The default is false which allows the creds to be saved to $PWD
        [bool]$ExclusiveDirectory = $false

        ## ConsolePrompting
        ## We prompt user for credentials from the command line instead of pop-up window
        ## Later, we set it back to normal
        $key = 'HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds'
        [string]$normalPref = Get-ItemProperty -Path $key -Name ConsolePrompting | Select-Object -ExpandProperty ConsolePrompting
        [string]$runtimePref = 'True'
        If($normalPref -notmatch $runtimePref) {
            Write-Output -InputObject ('Current ConsolePrompting setting is {0}' -f ($normalPref))
            Write-Output -InputObject ('Changing runtime ConsolePrompting to {0}' -f ($runtimePref))
    
            Try {
                Set-ItemProperty -Path $key -Name ConsolePrompting -Value $runtimePref
            }
            Catch {
                Write-Output -InputObject 'Cannot set console prompting.'
                Write-Output -InputObject 'User will be prompted with Windows Forms GUI to enter credentials'
            }

        }
        
        ## Clear Screen only if not in verbose mode
        If($VerboseMode -eq 'Off') {
            Clear-Host
        }

        Function Save-ToLocalPath {

            ## If we cannot create a directory, we use current.
            ## However, we first check if user allows local directory.
            If($ExclusiveDirectory){
                Write-Warning -Message 'User prefers saving ONLY to their specified directory.'
                Throw ('Cannot access or create {0}' -f ($CredOutputPath))
            }
            Else {
                Write-Output -InputObject ('Using current directory {0} instead!' -f ($PWD))
                $CredOutputPath = $PWD
            }
        }
    }

    Process {

        ## Determine path to save output files
        if(Test-Path -Path $CredOutputPath -ErrorAction SilentlyContinue) {
            Write-Output -InputObject ('Using Credential output path of {0}' -f ($CredOutputPath))
        }
        Else {

            ## if we're allowed (based on preferences) to create folders
            If($CreateDirectory -eq $true){
                    
                ## try creating directory for cred file output
                Try {
                    $null = New-Item -ItemType Directory -Path $CredOutputPath -Force -ErrorAction Stop
                }
                Catch {
                    Write-Warning -Message ('Problem creating directory {0}!' -f ($CredOutputPath))
                    Write-Output -InputObject ('{0}' -f $_.Exception.Message)
                    
                    ## try saving to local, if allowed
                    Save-ToLocaPath
                } #End catch
            } #End if
            Else {
                
                ## try saving to local, if allowed
                Save-ToLocaPath 
            } #End else
        } #End else

        Function Start-CredMenu {
            ## Welcome
            Write-Output -InputObject "`nWelcome to SaveCredentials"
            Write-Output -InputObject 'A feature of the Invoke-RoboCheck module.'
            Write-Output -InputObject ('Credentials will be saved to {0}' -f $CredOutputPath)
            Write-Output -InputObject 'What would you like to do?'
            Write-Output -InputObject ' ' 

            ## Select function MENU
            Write-Output -InputObject 'Save Credentials for:'
            Write-Output -InputObject '1. vCenter Credential 1'
            Write-Output -InputObject '2. vCenter Credential 2'
            Write-Output -InputObject '3. vCenter Credential 3'
            Write-Output -InputObject '4. vCenter Credential 4'
            Write-Output -InputObject ' '
            Write-Output -InputObject "X. Exit`n"
        
            #region main
            Try {
            
                $prompt = Read-Host -Prompt 'Select 1-4'

                switch ($prompt) {
  
                  1 {
                        ## vCenter Creds #1
                        Write-Output -InputObject 'Enter your vCenter Login info'
                        $CredsVC1 = Get-Credential
                        Export-PSCredential -Credential $CredsVC1 -Path ('{0}\{1}' -f $CredOutputPath, $credName1)
                  }
                  2 {
                        ## vCenter Creds #2
                        Write-Output -InputObject 'Enter your vCenter Login info'
                        $CredsVC2 = Get-Credential
                        Export-PSCredential -Credential $CredsVC2 -Path ('{0}\{1}' -f $CredOutputPath, $credName2)
                  }
                  3 {
                        ## vCenter Creds #3
                        Write-Output -InputObject 'Enter your vCenter Login info'
                        $CredsVC3 = Get-Credential
                        Export-PSCredential -Credential $CredsVC3 -Path ('{0}\{1}' -f $CredOutputPath, $credName3)
                  }
                  4 {
                        ## vCenter Creds #4
                        Write-Output -InputObject 'Enter your vCenter Login info'
                        $CredsVC4 = Get-Credential
                        Export-PSCredential -Credential $CredsVC4 -Path ('{0}\{1}' -f $CredOutputPath, $credName4)
                  }
                  x {
                        break
                    } 
                  default {
                        Write-Output -InputObject "** The selection could not be determined **`n"
                        Start-Sleep -Seconds 2
                  }
                }
            }
            #endregion
            Catch {
                Write-Warning -Message 'We encountered a problem with the Menu System.'
                Write-Output -InputObject ('{0}' -f $_.Exception.Message)
            }

            Finally {
    
                ## Configure console prompting to reflect the previous setting
                If($normalPref -notmatch $runtimePref) {
                    Write-Output -InputObject 'Setting ConsolePrompting back to its original value'
                    Set-ItemProperty -Path $key -Name ConsolePrompting -Value $normalPref
                }
            } #End Finally
        } #End function Cred-Menu

        ## run the cred-menu function
        Start-CredMenu
    } #End Process

    End {
        Write-Output -InputObject 'Credential processing complete.'
        Write-Output -InputObject 'Run the script again to add more'
    } #End End
}