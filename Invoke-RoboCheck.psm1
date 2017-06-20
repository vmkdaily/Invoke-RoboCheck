<#	
    ===========================================================================
    Author:       	Mike Nisk 
    Organization: 	vmkdaily 
    Filename:     	Invoke-RoboCheck.psm1
    Version:        2.0.0
    -------------------------------------------------------------------------
    Module Name: Invoke-RoboCheck
    ===========================================================================

    ## ABOUT
    The Invoke-RoboCheck module connects to one or more vCenter Servers and returns health information from ESX.
    See Help Invoke-RoboCheck -Full for detailed usage information.

    ## AUDIENCE
    Designed for Remote Office Branch Office (ROBO) vSphere depoyments, but will work against any
    vCenter Server containing ESX hosts.

    ## CREDENTIAL SUPPORT
    This module provides extensive credential handling, allowing user to provide runtime credentials on the fly
    for up to Two (2) Credentials (Credential and CredFallBack).  We also allow user to hard-code in the UserPrefs, the
    path to a primary and secondary encrypted xml credential file.  We also allow user to create and save encrypted
    credentials to file (if desired) by using the SaveCredential parameter.  If no credentials are provided at runtime or
    by path, then we try the local VICredentialStore, and finally pass-through (SSPI).
    
    ## QUICK START
    - Import the Module
    - Run the script (i.e.Invoke-RoboCheck -Computer vcenter01.lab.local)
    - Upon first run, $Env:USERPROFILE\Robo-Check.ini is created for you (modify if desired)


    ## MODULE CONTENTS
    Invoke-RoboCheck.psd1
    Invoke-RoboCheck.psm1

    ## DEPENDS ON
    $ENV:USERPROFILE\Invoke-RoboCheck.ini
    *CREATED AT RUNTIME IF NEEDED

    ## INSTRUCTIONS
    Step 1.  Download and install PowerCLI
             www.vmware.com/go/powercli
             Note:  This module supports PowerCLI versions 5.0 to 6.5+.
             PowerCLI 6.5 is preferred, but not required.

    Step 2.  Windows update your machine and upgrade your Powershell version if possible.
             This module supports Powershell versions 3 or greater (Powershell 5 preferred, not required).
             You can check your Powershell version by running $PSVersionTable.
             Note:  This module not intended for or tested on Powershell 6 for linux.

    Step 3.  Execution Policy
             From an elevated Powershell prompt run the following:
	     
             C:\> Get-ExecutionPolicy
             Note: If it comes back as restricted, then you need to change it to RemoteSigned, Unrestricted or Bypass.
             Set-ExecutionPolicy RemoteSigned -Confirm:$false

    Step 4.  Download the module to the desired path.  You need the entire Invoke-RoboCheck folder.

    Step 5.  After downloading, right-click the folder and go to properties.  Click on 'unblock' if needed.

    Step 6.  Launch Powershell as administrator (i.e. right-click run as administrator)

    Step 7.  Import the Module into your Powershell session by using Import-Module.
             We do this by pointing to the folder.  You should choose a good location, but for this
             example, we are just saving the module to c:\temp and importing from there.

             C:\> Import-Module C:\temp\Invoke-RoboCheck -Verbose
            VERBOSE: Loading module from path 'C:\temp\Invoke-RoboCheck\Invoke-RoboCheck.psd1'.
            VERBOSE: Loading module from path 'C:\temp\Invoke-RoboCheck\Invoke-RoboCheck.psm1'.
            VERBOSE: Importing function 'Invoke-RoboCheck'.
             C:\>

             Now that the above is done, you can start using the module by consuming it's main function,
             known as Invoke-RoboCheck (same as the module name).

             See the cmdlet help for more information
             Get-Help Invoke-RoboCheck -ShowWindow
             Get-Help Invoke-RoboCheck -Full
             Get-Help Invoke-RoboCheck -Examples

    Step 8.  The first time you run Invoke-RoboCheck, a file called Invoke-RoboCheck.ini is created for you.
             This file controls the configuration for things like path to Credential files (optional), output
             directories, naming conventions, etc.  This is stored in your user profile ($Env:USERPROFILE) to ensure
             functionality for multiple users on the same box.
	     
       Note:  The paths in your config file will show full paths.  It will not actually show $env variables.

              ##EXAMPLE OF DEFAULT CONFIG FILE

              [Output]
              EsxReportName = Robo-Esx-Report
              ReportDir = $Env:Temp
              LogDir = $Env:Temp
              LogName = robo-ps-transcript

              [Options]
              AutoStart = false
              Logging = on
              Quiet = true

              [Auth]
              CredFallBackPath = 
              CredentialPath = 

#>

# Function loader based on:
# https://github.com/adamrushuk/PSvCloud/blob/master/PSvCloud/PSvCloud.psm1


# Get public and private function files
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($FunctionFile in @($Public + $Private)) {

    try {

        . $FunctionFile.fullname

    }
    catch {

        Write-Error -Message "Failed to import function $($FunctionFile.fullname): $_"
    }
}

# Export the Public modules
Export-ModuleMember -Function $Public.Basename
