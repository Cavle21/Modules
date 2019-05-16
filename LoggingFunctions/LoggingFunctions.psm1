Import-Module SonalystsModules

<#
.SYNOPSIS
    Acts as middleman function to simplify what is passed to write-log. This function is optional.
.DESCRIPTION
    Takes input and formats it to send to write-log. The parameters are small and simplified and only one parameter is mandatory.
    It will fill in default values for everything else. It will also write to the host console if available.
.EXAMPLE
    New-LogMessage -message "Help me" -scriptTitle "My Script Name" -errorLevel "0" -eventID "1001" -logDirectory "C:\windows\Temp"
    Writes "help me" to the event log with event ID 1001, then writes that to a textfile at C:\windows\temp\My Script Name.txt

.EXAMPLE
    New-LogMessage -m "It Worked" -st "Invoked Script name" -el "0" -ID "1001" -ld "C:\users\bob\desktop"
    Writes "It Worked" to the event log with event ID 1001, then writes that to a text file at c:\users\bob\desktop\Invoked Script Name.txt
    Then write to console DATETIME[Information]"It Worked"
.INPUTS
    Message, ScriptTitle, ErrorLevel, eventID, LogDirectory
.PARAMETER message
    Mandatory: String: Alias: m
    Message that will be written in the logs.
.PARAMETER scriptTitle
    -Optional: String: Alias: st
    Name of calling script. This can be used to customize the name of the text file written. It can also be used to identify the event log that
    is written.
.PARAMETER errorLevel
    Optional: String: Alias: el
    Allowed values:
    0: Information
    1: Warning
    2: Error
    This will be tagged with the log that is written in both the event log and the text file.
.PARAMETER LogDirectory
    Mandatory: String: Alias: ld
    Must be a path that script calling user can make changes to.
    This is the directory path that will be where the text file is created. The location does not have to be created
    in advance.
.OUTPUTS
    event log event is written and a text file is generated
.NOTES
    General notes
#>

$OutputSeparator = "-------------------------------------------------------------"
function New-LogMessage {
    param(
        [parameter()]
        [alias("m")]
            [string]$message,
        [parameter()]
        [alias("st")]
            [string]$scriptTitle = "LoggingFunctions",
        [parameter()]
        [alias("el")]
        [ValidateSet("0", "1", "2")]
            [string]$errorLevel = "0",
        [Parameter()]
        [alias("ID")]
            [string]$eventID = "1",
        [parameter()]
        [alias("ld")]
            [string]$logDirectory
    )

    #translate error level to full text for write-log function
    switch ($errorLevel) {
        0 { $EntryType = "Information" }

        1 { $EntryType = "Warning"}

        2 { $EntryType = "Error"}

        Default {Throw "$errorLevel is invalid"; exit}
    }

    #gather variables for splatting
    $arguments = @{
        logDirectory = $logDirectory
        message = $message
        scriptTitle = $scriptTitle
        entryType = $EntryType
        eventID = $eventID

    }

    #splat arguments to write-log function.
    Write-log @arguments
    
}

Function Write-Log {
    # Information is the default EntryType for an event log (Error, Warning, Information)
    # 1 is the default EventID for an event log
    # $Message must be passed to this function

    [CmdletBinding()]

    Param(
        [parameter()]
            [string]$LogDirectory = "D:\logs",
        [parameter()]
            [string]$scriptTitle,
        [Parameter()]
            [string]$message, 
        [parameter()]
        [ValidateSet("Information", "Warning", "Error")]
            [string]$EntryType = "Information", 
        [parameter()]
            [string]$EventID = "1"
    )

    $scriptLogFileLocation = [IO.path]::Combine($LogDirectory,$scriptTitle)

    $scriptLogFile = $scriptLogFileLocation + ".txt"
    

    # If the log directory is not present, create it.
    If ((test-path -path $scriptLogFileLocation) -eq $False) {
        try {
            New-Item $scriptLogFileLocation -type directory 
        }Catch{
            New-ConsoleLogMessage -EntryType "Error" -logTime $LogTime -Message "Unable to create log directory"
            New-EventLogMessage -ScriptTitle $scriptTitle -EntryType "Error" -Message $_.exception.message
            New-ConsoleLogMessage -EntryType "Error" -logTime $LogTime -Message $_.Exception.message
        }
    }
    # Set the time into a var so all the logs have the same time
    $LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Write to the text log file, appending to it.
    Write-Output "$LogTime [$EntryType] $Message" | Out-File -FilePath $ScriptLogFile -Append
    
}

Function New-ConsoleLogMessage {

    param (
        [parameter()]
        [ValidateSet("Information","Warning","Error")]
            [string]$EntryType = "Information",
        [parameter()]
            [date]$LogTime,
        [parameter()]
            [string]$Message
    )

    Switch ($EntryType)
    {
        "Information" { Write-Output "$LogTime [$EntryType] $Message" | Out-Host }
        "Warning" {Write-Warning "$LogTime [$EntryType] - $Message" | Out-Host }
        "Error" {Write-Error "$LogTime [$EntryType] - $Message" | Out-Host }
        default {Write-Output "$LogTime [$EntryType] $Message" | Out-Host }
    }
}

<#
.SYNOPSIS
    Writes an event in the event log.
.DESCRIPTION
    Takes given parameters, checks if the script title is registered with the event log (Assert-EventLogSourceExists)
    , if not , it creates a new one (New-EventLogRegistration) then write to the event log.
.EXAMPLE
    New-EventLogMessage -scriptTitle "BoBsScript" -entryType "Information" -message "This completed."
    Writes new message to console with message "This completed."
.PARAMETER ScriptTitle
    String: Title of calling script. Used as unique ID so its events are trackable.
.PARAMETER EntryType
    String: Level of urgency of message. Allowed values are: information, Warning, Error
.PARAMETER Message
    String: Message that you wish to pass to event log.
.OUTPUTS
    True/false based on function success.
.NOTES
    General notes
#>
Function New-EventLogMessage {

    param(
        [parameter()]
            [string]$ScriptTitle,
        [parameter()]
        [ValidateSet("Information","Warning","Error")]
            [string]$EntryType = "Information",
        [parameter()]
            [string]$Message
    )

    $LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    #cannot write to event log if the "source"(in our case the scripttitle) is registered.
    if ((Assert-EventLogSourceExists) -eq $false){
        New-EventLogRegistration
    }

    try{
        Write-EventLog -LogName Application -Source "$ScriptTitle" -Category "0" -EntryType $EntryType -EventID $EventID -Message "$Message"
    } catch {
        New-ConsoleLogMessage -EntryType $EntryType -logTime $LogTime -Message $Message
        return $false
    }

    return $true
}

<#
.SYNOPSIS
    Checks to see if the calling script can write to the event log.
.DESCRIPTION
    Checks to see if the calling script has been registered in the event log. This is to allow the calling script to write to the event log
    This must be done before the calling script can write to the event log.
.EXAMPLE
    Assert-EventLogSourceExists -scriptTitle "BobsScript"
    Registers "BoBsScript" to the eventlog so that it can write to the event log.
.INPUTS
    ScriptTitle: String: Mandatory: the name that will be associated with the calling script writing events.
.OUTPUTS
    boolean True/false: validate that the script was registered or is already registered.
.NOTES
    This is required for a calling script to write to the event log.
#>
function Assert-EventLogSourceExists {
    

    param(
        [parameter(Mandatory = $true)]
        [string]$ScriptTitle
    )

    If ([System.Diagnostics.EventLog]::SourceExists($ScriptTitle) -eq $False) { 
        # Source does not exist
        return $False
    }else{
        return $true
    }
}

function New-EventLogRegistration {
    param(
        [parameter(Mandatory = $true)]
            [string]$nameOfRegistration
    )

    try{
        New-EventLog -LogName Application -Source "$ScriptTitle" 
    }catch{
        throw "Unable to create new event source."
    }
}


Export-ModuleMember -Function New-LogMessage, Write-log, New-ConsoleLogMessage, New-EventLogMessage, Assert-EventLogSourceExists, New-EventLogRegistration -Variable $outputSeparater

