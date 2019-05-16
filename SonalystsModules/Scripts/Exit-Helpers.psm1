
<#
.Synopsis
    Exits the script with a message provided and additional exit action.
.DESCRIPTION
    Exits the script with a message provided and additional exit action. Similar to the dispose pattern
    in C# this affords us a last ditch effort to clean up resources and clean up after ourselves if necessary. 
.NOTES
    exitMode Error will halt the script from continuing to execute.
.PARAMETER message
    The message to display on exit.
.PARAMETER exitMode
    The mode at which we are exiting. Error = Stop the script immediatley and exit with error action stop. Warning = Warning message then exit. Success = Normal message then exit.
.EXAMPLE
    Exit-WithMessage -message "Script Failed with some scary error!" -exitMode Error
.EXAMPLE
    Exit-WithMessage -message "Script completed with warnings" -exitMode Warning
.EXAMPLE
    Exit-WithMessage -message "Script completed successully" -exitMode Success
#>
function Exit-WithMessage {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$message, 
            
        [Parameter(Mandatory=$true)]
        [ValidateSet("Success","Warning","Error")]
        [ValidateNotNullOrEmpty()]
        [string]$exitMode,

        [Parameter(Mandatory=$false)]
        [Exception]$exception
    )  

    switch ($exitMode) {
        "Success" { Write-Host $message}
        "Warning" { Write-Warning $message}
        "Error" { 
            if ($exception -ne $null) {
               Write-Error -Message $message -Exception $exception -ErrorAction Stop 
            } else {
                Write-Error -Message $message -ErrorAction Stop 
            }
         }
    }

    cd $PSCmdlet.MyInvocation.PSScriptRoot;

    Exit;
}


Export-ModuleMember -Function 'Exit-*';