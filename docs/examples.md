
    SYNTAX
    Invoke-RoboCheck [-Computer] <string[]> [-Credential <pscredential>] [-CredFallBack <pscredential>] [-OutputCSV] [-ReportType <string>] [-Cluster <string[]>] [-SplatPref <array>] [-AutoLaunch] [-Quiet <bool>] 
	[<CommonParameters>]

    Invoke-RoboCheck -SaveCredentials [-CredOutputPath] <string> [<CommonParameters>]

    
    NAME
        Invoke-RoboCheck
        
    SYNOPSIS
        Health check Remote Office Branch Office (ROBO) sites running vSphere.
        
    SYNTAX
        Invoke-RoboCheck [<CommonParameters>]
        
        Invoke-RoboCheck [-Computer] <String[]> [-Credential <PSCredential>] [-CredFallBack <PSCredential>] [-OutputCSV] [-ReportType <String>] [-Cluster <String[]>] [-SplatPref <Array>] [-AutoLaunch] [-Quiet <Boolean>] 
        [<CommonParameters>]
        
        Invoke-RoboCheck [-SaveCredentials] [-CredOutputPath] <String> [<CommonParameters>]
        
        
    DESCRIPTION
        This is the main function for the Invoke-RoboCheck module.
        Here, we connect to one or more vCenter Servers and check ESX
        health.
        

    PARAMETERS
        -Computer <String[]>
            String. The IP Address or DNS name of one or more vCenter Server machines to connect to.
            For IPv6, enclose address in square brackets, for example [fe80::250:56ff:feb0:74bd%4].
            For server lists, provide the path to a text file, for example, "C:\servers.txt".
            
            Required?                    true
            Position?                    1
            Default value                
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -Credential <PSCredential>
            pscredential. The login credentials for vCenter
            Optionally, you can enter just username to be prompted for runtime password.
            
            Required?                    false
            Position?                    named
            Default value                
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -CredFallBack <PSCredential>
            pscredential. If the first login fails, try these.
            Cannot be the same username as Credential.
            
            Required?                    false
            Position?                    named
            Default value                
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -OutputCSV [<SwitchParameter>]
            Switch. Activate this to save reports to CSV.  The path is determined by your Invoke-RoboCheck.ini
            
            Required?                    false
            Position?                    named
            Default value                False
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -ReportType <String>
            validate set.  The default for ReportType is Detailed, which includes everything.  Tab complete though options.
            Other choices include "Standard","NTP","Datastore", or "AutoStart".
            This only affects output, runtime does not decrease with smaller reports.
            
            Required?                    false
            Position?                    named
            Default value                Detailed
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -Cluster <String[]>
            Choose to target ESX hosts only from a particular cluster
            
            Required?                    false
            Position?                    named
            Default value                
            Accept pipeline input?       false
            Accept wildcard characters?  false
	    
        -SaveCredentials [<SwitchParameter>]
            Optionally save an encypted credential to disk.
            This selection presents a Menu based system for user to create up to 4 credential files.
            The Credential files must be created one at time.  Re-run the script to create more if needed.
            The Invoke-RoboCheck function can consume up to 2 cred files.
            After creating your cred files, update the path in your preferences ($Env:USERPROFILE\Invoke-RoboCheck.ini by default).
            
            Required?                    true
            Position?                    1
            Default value                False
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -CredOutputPath <String>
            String.  If saving Credentials to disk with the SaveCredentials parameter, The CredOutputPath (alias Path) allows you to choose the folder
            you want your saved credentials output to.  Remember to update your Invoke-RoboCheck.ini to enjoy seamless logins.
            
            Required?                    true
            Position?                    2
            Default value                
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -AutoLaunch [<SwitchParameter>]
            Switch.  Optionally auto-launch the CSV report.  If set differently in UserPrefs, the runtime choice wins.
            
            Required?                    false
            Position?                    named
            Default value                False
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        -Quiet <Boolean>
            bool.  minimalist output.
            The default is true (quiet output).
            Set to false for more detailed info.
            
            Required?                    false
            Position?                    named
            Default value                True
            Accept pipeline input?       false
            Accept wildcard characters?  false
            
        <CommonParameters>
            This cmdlet supports the common parameters: Verbose, Debug,
            ErrorAction, ErrorVariable, WarningAction, WarningVariable,
            OutBuffer, PipelineVariable, and OutVariable. For more information, see 
            about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
        
    INPUTS
        System.String
   
    OUTPUTS
        Object
        System.String
        System.Management.Automation.PSCredential
            
        
        
        
    NOTES
        
        
            Script:         Invoke-RoboCheck.ps1
            Type:           Function
            ParentModule:   Invoke-RoboCheck
            Author:         Mike Nisk
            Organization:   vmkdaily
            
            ABOUT CREDENTIAL HANDLING
            We consume credentials in the following order:
              
            PSCredential Object  - This always wins
            EncryptedXml         - We try this next if no creds are given
            PassThrough (SSPI)   - Finally, if no other valid credential is found, we use Passthrough (SSPI)
        
        -------------------------- EXAMPLE 1 --------------------------
        
        PS C:\>Invoke-RoboCheck -Computer vcenter01.lab.local
        
        
        Use passthrough authentication (SSPI) to connect to vCenter and return an ESX report object.
        
        
        
        
        
        -------------------------- EXAMPLE 2 --------------------------
        
        PS C:\>Invoke-RoboCheck -Computer vcenter01.lab.local -Credential (Get-Credential)
        
        
        Get prompted for credentials then return the results to screen
        
        
        
        
        
        -------------------------- EXAMPLE 3 --------------------------
        
        PS C:\>Invoke-RoboCheck -SaveCredentials -Path "c:\creds"
        
        
        Example saving a credential to disk.  Provide the name of a folder for Path.
        You will be prompted for username and password.  You can then modify your preferences
        (Invoke-RoboCheck.ini) to reflect the path to your creds.
        After doing so, you no longer need to populate the Credential parameter as the script will automatically
        read the cred files.  Maximum of 2 can be added to prefernce settings for consumption at runtime.
        
        
        
        
        
        -------------------------- EXAMPLE 4 --------------------------
        
        PS C:\>$credsVC = Get-Credential administrator@vsphere.local
        
        
        Invoke-RoboCheck -Computer C:\vc-list.txt -Credential $credsVC -OutputCSV
        Save credentials to a variable.  Then, run a report and save to CSV.
        
        
        
        
        
        -------------------------- EXAMPLE 5 --------------------------
        
        PS C:\>Invoke-RoboCheck -Computer vc01,vc02 -Credential $credsVC
        
        
        Run a report against an array of vcenter names and deliver the info on screen.
        
        
        
        
        
        -------------------------- EXAMPLE 6 --------------------------
        
        PS C:\>Invoke-RoboCheck -Computer bigvc01.lab.local -Cluster labcluster03 -Credential $labCreds -OutputCSV
        
        
        Run a report against a cluster saving the details to CSV.
        
        
        
        
        
        -------------------------- EXAMPLE 7 --------------------------
        
        PS C:\>$report = Invoke-RoboCheck -Computer C:\Pester\robo-vc-list.txt -Credential $credsVC -CredFallBack $CredsRoboSSO -OutputCSV
        
        
        Run a report against a list of vCenters.  The server list should be one vCenter Server per line).
        In this example we use two sets of credentials.  The script will quietly try the next set as needed.
        Finally, ouput the results to CSV.
        
        
        
        
        
        -------------------------- EXAMPLE 8 --------------------------
        
        PS C:\>$report = Invoke-RoboCheck -Computer vcva02.lab.local -Credential $credsLabVC
        
        
        C:\> $report | select Name,State,Model,overallstatus
        
        Name            State     Model     OverallStatus
        ----            -----     -----     -------------
        esx01.lab.local Connected MacPro6,1         green
        esx02.lab.local Connected MacPro6,1         green
        esx03.lab.local Connected MacPro6,1         green
        esx04.lab.local Connected MacPro6,1         green
        
        This example runs the report against vCenter, and saves it to a variable named $report.
        We then only look at a few of the items we are interested in.  To see the full report you can
        $report | Out-GridView
        
        Tip: If you did not use the OutputCSV parameter, but you saved the report to a variable like above,
        then you can still saves to CSV by performing:
        $report | Export-Csv -NoTypeInformation c:\temp\robo-report.csv
        
        
        
        
        
        -------------------------- EXAMPLE 9 --------------------------
        
        PS C:\>$report = Invoke-RoboCheck -Computer vcva02.lab.local -Credential $credsLabVC
        
        
        C:\> $report | select -First 1
        
        Name                 : esx01.lab.local
        State                : Connected
        OverallStatus        : green
        DiffToUTC            : 0.1916
        Datastore1 Free (GB) : 67
        Datastore2 Free (GB) : 99
        MemoryFreeGB         : 28
        CpuUsageMhz          : 9115
        VM Count             : 4
        VmAutoStartOff       : n/a
        EsxStartProtection   : HA Protected
        IsStandalone         : False
        NtpRunning           : True
        NtpServers           : 10.202.3.250
        EsxVersion           : 6.0.0
        EsxBuild             : 3825889
        OsType               : vmnix-x86
        LicenseKey           : XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
        MemoryTotalGB        : 64
        NumCpu               : 4
        ProcessorType        : Intel(R) Xeon(R) CPU E5-1620 v2 @ 3.70GHz
        Manufacturer         : Apple Inc.
        Model                : MacPro6,1
        BIOS                 : MP61.88Z.0116.B16.1509081436
        ParentVC             : vcva02.lab.local
        
        Example showing all items captured and returned in an object for a single ESX host.
        
        
        




