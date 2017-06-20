Function Invoke-ConfigHandler {

  <#
      .DESCRIPTION
        Handle Configuration file for the Invoke-RoboCheck module.
      
      .NOTES
        Script:         InvokeConfigHandler.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017

  #>

  [CmdletBinding()]
  Param(

  [Parameter(Mandatory)]
  [string]$FilePath
  )
  
  Begin {
    
    ## create file if it does not exist
    If(-Not(Test-Path $FilePath -ErrorAction SilentlyContinue)){

        try {
            $null = New-Item -ItemType File -Path $FilePath -Force -ErrorAction Stop
            Write-Verbose -Message ('Created File :: {0}' -f $FilePath)
        }
        catch {
            Write-Warning -Message ('{0}' -f $_.Exception.Message)
            Write-Warning -Message ('Cannot create :: {0}' -f $FilePath)
            Throw 'Problem creating user preferences file!'
        }
    } #End If

    ##SUB FUNCTIONS
    Function Set-RoboConfigDefaults {
      $CategoryAuth           =  @{"CredentialPath"="";"CredFallBackPath"=""}
      $CategoryOutput         =  @{"ReportDir"=$env:Temp;"LogDir"=$env:Temp;"LogName"="robo-ps-transcript";"EsxReportName"="Robo-Esx-Report"}
      $CategoryOptions        =  @{"Logging"="on";"AutoLaunch"=$false;"Quiet"=$true}
      $NewINIContent          =  @{"Auth"=$CategoryAuth;"Output"=$CategoryOutput;"Options"=$CategoryOptions}
      Return $NewINIContent
    }

     Function Export-RoboConfig {
        $IniContent = Set-RoboConfigDefaults
        Out-IniFile -InputObject $IniContent -FilePath $FilePath -Loose -Force
      }

      Function Import-RoboConfig {
        Param()
        $Script:UserPref = Get-IniContent -FilePath $FilePath
      }

      Function New-RoboDefaultConfig {
        Export-RoboConfig
        Import-RoboConfig
      }

  } #End Begin
  
  Process {

      #Check if file is populated
      If((Get-Item $FilePath).Length -gt 0){
        Write-Verbose -Message "Config file is already populated (ok)."
        
        #load existing
        try {
            Import-RoboConfig -ErrorAction Stop
        }
        Catch {
          Write-Warning -Message ('{0}' -f $_.Exception.Message)
          Write-Warning -Message 'file exists, but is not valid.'
          New-RoboDefaultConfig
        }

      } #End If
      Else {
        Write-Warning -Message "Config file exists, but is not populated (zero length)"
        Write-Verbose -Message "Setting defaults for config"
        New-RoboDefaultConfig
      }
      
      #If we don't have anything yet
      If(!$Script:UserPref) {
          
        Try {
          #try loading
          $Script:UserPref = Import-RoboConfig
        }
        Catch {
          #falling back to defaults for this runtime
          Write-Warning -Message 'Cannot load preferences file! Using Module Defaults.'
          New-RoboDefaultConfig
      
          If(-Not($Script:UserPref)) {
            Throw "Cannot load preferences or defaults!  Giving up."
          } #End If
        } #End Catch
      } #End If
  } #End Process
}
