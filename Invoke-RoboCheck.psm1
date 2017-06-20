<#	
    ===========================================================================
    Author:       	Mike Nisk 
    Organization: 	vmkdaily 
    Filename:     	Invoke-RoboCheck.psm1
    Version:            2.0.0
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

    ## DEPENDS ON
    $ENV:USERPROFILE\Invoke-RoboCheck.ini
    *CREATED AT RUNTIME IF NEEDED

    ## PREFERENCES
    The first time you run Invoke-RoboCheck, a file called Invoke-RoboCheck.ini is created for you.
    This file controls the configuration for things like path to Credential files (optional), output
    directories, naming conventions, etc.  This is stored in your user profile ($Env:USERPROFILE) to ensure
    functionality for multiple users on the same box.
	     
       Note:  The paths in your config file will show full paths.  It will not actually show $env variables.
       Do not use quotes when manually editing your config file.

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
