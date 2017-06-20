## About Invoke-RoboCheck
Powershell / PowerCLI module that connects to one or more vCenter Servers and returns health information from ESX.<br>
Designed for Remote Office Branch Office (ROBO) vSphere depoyments, but will work against any
vCenter Server containing ESX hosts.

## Included Functions
The following functions make up the Invoke-RoboCheck module:<br>

`Get-IniContent`<br>
`Out-IniFile`<br>
Invoke-ConfigHandler<br>
Start-Logging<br>
Stop-Logging<br>
Write-Msg<br>
Write-PrettyHash<br>
Invoke-PowerLoader<br>
Invoke-ThrowControl<br>
Test-RuntimeCreds<br>
`Export-PSCredential`<br>
`Import-PSCredential`<br>
New-RoboCredential<br>
Test-Credfile<br>
Import-RoboXmlCreds<br>
Connect-RoboVC<br>
Disconnect-RoboVC<br>
Get-RoboDatastore<br>
Get-EsxNtpHealth<br>
Get-AutoStartConfig<br>
Invoke-RoboCheck<br>

*Note:  Items `highlighted` are exsiting prior art graciously borrowed for this project.  All other items are mostly original.*

> Most of this is setting up the framework, and then the last few functions actually return useful information.

## Exported Functions
Invoke-RoboCheck is the only function the user can interact with.

## License
https://opensource.org/licenses/MIT

## QUICK START
- Import the Module
- Run the script (i.e. Invoke-RoboCheck -Computer vcenter01.lab.local)
- Optionally, edit the auto-generated preferences file at `$Env:USERPROFILE\Invoke-RoboCheck.ini`

## INSTRUCTIONS
Step 1<br>
Download and install PowerCLI<br>
www.vmware.com/go/powercli<br>
Note:  This module supports PowerCLI versions 5.0 to 6.5+.<br>
PowerCLI 6.5 is preferred, but not required.<br>

Step 2<br>
Windows update your machine and upgrade your Powershell version if possible.<br>
This module supports Powershell versions 3 or greater (Powershell 5 preferred, not required).<br>
You can check your Powershell version by running $PSVersionTable.<br>
Note:  This module not intended for or tested on Powershell 6 for linux.<br>

Step 3<br>
Execution Policy<br>
From an elevated Powershell prompt run the following:

    C:\> Get-ExecutionPolicy

*Note: If it comes back as restricted, then you need to change it to RemoteSigned, Unrestricted or Bypass*

    Set-ExecutionPolicy RemoteSigned -Confirm:$false

Step 4<br>
Download the module to the desired path.  You need the entire `Invoke-RoboCheck` folder.

Step 5<br>
After downloading, right-click the folder and go to properties.  Click on 'unblock' if needed.

Step 6<br>
Launch Powershell as administrator (i.e. right-click run as administrator)

Step 7<br>
Import the Module into your Powershell session by using Import-Module.<br>
We do this by pointing to the folder.  You should choose a good location, but for this<br>
example, we are just saving the module to c:\temp and importing from there.<br>

    C:\> Import-Module C:\temp\Invoke-RoboCheck -Verbose
    VERBOSE: Loading module from path 'C:\temp\Invoke-RoboCheck\Invoke-RoboCheck.psd1'.
    VERBOSE: Loading module from path 'C:\temp\Invoke-RoboCheck\Invoke-RoboCheck.psm1'.
    VERBOSE: Importing function 'Invoke-RoboCheck'.
    C:\>

Now that the above is done, you can start using the module by consuming it's main function,
known as Invoke-RoboCheck (same as the module name).

See the cmdlet help for more information:<br>
Get-Help Invoke-RoboCheck -ShowWindow<br>
Get-Help Invoke-RoboCheck -Full<br>
Get-Help Invoke-RoboCheck -Examples<br>

Step 8<br>
The first time you run Invoke-RoboCheck, a file called Invoke-RoboCheck.ini is created for you.<br>
This file controls the configuration for things like path to Credential files (optional), output<br>
directories, naming conventions, etc.  This is stored in your user profile ($Env:USERPROFILE) to ensure<br>
functionality for multiple users on the same box.<br>

*Note:  We set the default locations for logging, etc. using environment variables (i.e. $Env:Temp).*<br>
*However, The paths in your config file will show full paths.*<br>

## EXAMPLE - DEFAULT CONFIG FILE

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

## EXAMPLE - POPULATED CONFIG FILE

    [Output]
    EsxReportName = Robo-Esx-Report
    ReportDir = C:\Users\vmadmin\AppData\Local\Temp
    LogDir = C:\Users\vmadmin\AppData\Local\Temp
    LogName = robo-ps-transcript

    [Options]
    Logging = on
    AutoLaunch = False
    Quiet = True

    [Auth]
    CredFallBackPath = C:\Creds\CredsVC1.enc.xml
    CredentialPath = C:\Creds\CredsVC2.enc.xml

## EXAMPLE - SCREEN OUTPUT RUNNING IN VERBOSE MODE<br>

    PS C:\> $report = Invoke-RoboCheck -Computer vcva02.lab.local -Verbose
    VERBOSE: --Start of Runtime Info--
    VERBOSE:   Running From  : Invoke-RoboCheck
    VERBOSE:   Command       : Invoke-RoboCheck
    VERBOSE:   Parameter Set : Default
    VERBOSE:   Start Time    : 5/6/2017 10:11:25 AM
    VERBOSE: --End of Runtime Info--
    VERBOSE: Welcome to Invoke-RoboCheck
    VERBOSE: Verbose mode is on
    VERBOSE: Config file is already populated (ok).
    VERBOSE: Get-IniContent:: Function started
    VERBOSE: Get-IniContent:: Processing file: C:\Users\vmadmin\Invoke-RoboCheck.ini
    VERBOSE: Get-IniContent:: Adding section : Output
    VERBOSE: Get-IniContent:: Adding key EsxReportName with value: Robo-Esx-Report
    VERBOSE: Get-IniContent:: Adding key ReportDir with value: C:\Users\vmadmin\AppData\Local\Temp
    VERBOSE: Get-IniContent:: Adding key LogDir with value: C:\Users\vmadmin\AppData\Local\Temp
    VERBOSE: Get-IniContent:: Adding key LogName with value: robo-ps-transcript
    VERBOSE: Get-IniContent:: Adding section : Options
    VERBOSE: Get-IniContent:: Adding key Logging with value: on
    VERBOSE: Get-IniContent:: Adding key AutoLaunch with value: False
    VERBOSE: Get-IniContent:: Adding key Quiet with value: True
    VERBOSE: Get-IniContent:: Adding section : Auth
    VERBOSE: Get-IniContent:: Adding key CredFallBackPath with value: C:\Creds\CredsVC1.enc.xml
    VERBOSE: Get-IniContent:: Adding key CredentialPath with value: C:\Creds\CredsVC2.enc.xml
    VERBOSE: Get-IniContent:: Finished Processing file: C:\Users\vmadmin\Invoke-RoboCheck.ini
    VERBOSE: Get-IniContent:: Function ended
    VERBOSE: Transcript Logging is on
    VERBOSE: No runtime Credential found.
    VERBOSE: Path to C:\Creds\CredsVC2.enc.xml looks okay
    VERBOSE: Validation succeeded for C:\Creds\CredsVC2.enc.xml
    VERBOSE: Credential by path okay.
    VERBOSE: No runtime CredFallBack found.
    VERBOSE: Path to C:\Creds\CredsVC1.enc.xml looks okay
    VERBOSE: Validation succeeded for C:\Creds\CredsVC1.enc.xml
    VERBOSE: CredFallBack by path okay.
    VERBOSE: Ready to run as administrator@vsphere.local (if needed)
    VERBOSE: Ready to run as vmadmin@lab.local (if needed)
    VERBOSE: ..Generating list of in-scope vCenter Servers
    VERBOSE: ..Processing vCenter vcva02.lab.local
    VERBOSE: Using provided Credential of administrator@vsphere.local
    VERBOSE: Connected to vcva02.lab.local
    VERBOSE: ..Checking health for esx01.lab.local on vcva02.lab.local
    VERBOSE: esx01.lab.local: Host Connection State Okay
    VERBOSE: Host esx01.lab.local participates in vSphere ha-fdm
    VERBOSE: ..Checking health for esx02.lab.local on vcva02.lab.local
    VERBOSE: esx02.lab.local: Host Connection State Okay
    VERBOSE: Host esx02.lab.local participates in vSphere ha-fdm
    VERBOSE: ..Checking health for esx03.lab.local on vcva02.lab.local
    VERBOSE: esx03.lab.local: Host Connection State Okay
    VERBOSE: Host esx03.lab.local participates in vSphere ha-fdm
    VERBOSE: ..Checking health for esx04.lab.local on vcva02.lab.local
    WARNING: esx04.lab.local: [state = Disconnected] on vcva02.lab.local
    WARNING: No results will be returned for esx04.lab.local!
    VERBOSE: ..Preparing object output
    VERBOSE: Ending Invoke-RoboCheck at 5/6/2017 10:11:29 AM
    VERBOSE: Transcript logging stopped successfully
    VERBOSE: Log file: C:\Users\vmadmin\AppData\Local\Temp\robo-ps-transcript-06May2017_1011.log
    PS C:\>



