Function Write-PrettyHash {

    <#
    
      .DESCRIPTION
        Neatly format a hashtable for verbose output

      .NOTES
        Script:         Write-PrettyHash.ps1
        Type:           Function
        ParentModule:   Invoke-RoboCheck
        Author:         Mike Nisk
        Organization:   vmkdaily
        Updated:        05April2017
        Based On:       http://www.integrationtrench.com/2014/07/neatly-formatting-hashtable-in-verbose.html
    
      .EXAMPLE
      C:\> $hash = @{
         'Item A' = 1
         'Item B' = 2
         'Item C' = 3
      }
      C:\>
      C:\>Write-PrettyHash -InputHash $hash -Verbose
      VERBOSE: --Start of Input Object--
      VERBOSE:   Item A : 1
      VERBOSE:   Item B : 2
      VERBOSE:   Item C : 3
      VERBOSE: --End of Input Object--
      C:\>
      This shows the creation of an example hashtable and then running the function.

      .EXAMPLE
      $hash | Write-PrettyHash -Verbose
      Build on the above example, we use the same $hash variable we created earlier.
      Then, we pass that through the PowerShell Pipeline '|' to the function.

      ABOUT ACCEPTABLE INPUTS

        This function will only take a hashtable.  Specifically,
        do not try to pass PSObject (PSCustomObject).

      .INPUTS
      HASHTABLE
    
      .OUTPUTS
      None
      System.String

    #> 

    [CmdletBinding(DefaultParameterSetName='none')]
    Param(

        #hashtable to input.
        #If blank, we return some basic info (i.e. ComputerName,Date,PowerShell Version).  
        [Parameter(ValueFromPipeline)]
        [Parameter(ParameterSetName='Default')]
        [AllowNull()]
        [hashtable]$InputHash,

        #string.  Text to include in the intro message.  This is optional.
        #This shows up in the verbose output just before your hashtable contents.
        [Parameter(ParameterSetName='Default')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$IntroMsg,

        #string.  Text to include in the outro message.  This is optional.
        #This shows up in the verbose output right after your hashtable contents.
        [Parameter(ParameterSetName='Default')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$OutroMsg,

        #string. Description of your input.  This is optional.
        #If intro and outro are null, we use this to describe both intro and outro.  If all are populated this is a pre-intro description.
        [Parameter(ParameterSetName='Default')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Description,

        #boolen.  Supresses all wrapper messages surrounding your input (i.e. intro outro).  Default is $false.
        [Parameter(ParameterSetName='Default')]
        [bool]$Quiet=$false,

        #boolen.  Activate this switch to perform slightly more aggressive input checks.
        #This will throw more often, but you will get exactly what you want once it's done right.
        #Activating this switch makes the InputHash Mandatory.
        [Parameter(ParameterSetName='Default')]
        [bool]$StrictMode=$False
    )

    Begin {

        ## set intro and outro messages (optional)
        If(!$introMsg -and !$OutroMsg) {

            If($Description) {

                [string]$IntroMsg = ('--Start of {0}--' -f ($Description))
                [string]$OutroMsg = ('--End of {0}--' -f ($Description))
            }
            Else {
                
                ##use default wrappers unless in quiet mode
                If($quiet -eq $false) {
                [string]$introMsg = '--Start of Input Object--'
                [string]$OutroMsg = '--End of Input Object--'
                }
            }
        }


        If(-Not($InputHash)){

            if($StrictMode -eq $true){
                Throw 'InputHash is required!'
            }
            Else {

              ## Populate the InputHash with basic runtime info, if none was provided by user
              $InputHash = @{
                'Computer'   = $Env:ComputerName
                'Date'       = (Get-Date)
                'PSVersion'  = $PSVersionTable.PSVersion | Select-Object -ExpandProperty Major
                }
            }
        }

    } #End Begin

    Process {

        if($InputHash -is [hashtable]) {
	    
            ##intro message (optional)
            If($introMsg) {
                Write-Verbose -Message ('{0}' -f ($introMsg))
            }
		    
            ## main
            ## The following snippet is from Craig Martin
            $columnWidth = $InputHash.Keys.length | Sort-Object| Select-Object -Last 1
            $InputHash.GetEnumerator() | ForEach-Object {
              Write-Verbose -Message ("  {0,-$columnWidth} : {1}" -F $_.Key, $_.Value)
            }

            ##outro message (optional)
            If($OutroMsg) {
              Write-Verbose -Message ('{0}' -f ($OutroMsg))
            }
        } #End if hash
        Else {
            Write-Warning -Message 'Input must be a hashtable!'  
            Throw 'No hashtable found from InputHash!'
        }
    } #End Process
}
