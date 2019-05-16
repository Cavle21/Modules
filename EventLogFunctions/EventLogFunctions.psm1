using namespace System.Diagnostics.Eventing
Import-Module SonalystsModules
Import-module LoggingFunctions

<#
.SYNOPSIS
    Enables specified event log
.DESCRIPTION
    Enabled event log event listener in the windows event log program.
.INPUTS
    Event log name (windows-microsoft-DNSClient)
.OUTPUTS
    None
.NOTES
    
#>
Function Enable-EventLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$eventLogName
    )

    $log = [Reader.EventLogConfiguration]::New($eventLogName)
    $log.IsEnabled=$true
    $log.SaveChanges()
}

<#
.SYNOPSIS
    Checks that eventlog is enabled.
.DESCRIPTION
    Checks windows event collector to see that an event log event is enabled.
.INPUTS
    Event log name (Windows-microsoft-DNSClient)
.OUTPUTS
    boolean result
.NOTES
    Name of event can be found in the event log properties.
#>

Function Assert-EventLogEnabled {
    param (
        [parameter(Mandatory = $true)]
        [string]$logName
    )

    $logConfiguration = [Reader.EventLogConfiguration]::New($logName)

    if (($logConfiguration.IsEnabled) -eq $true){
        return $true
    }else {
        return $false
    }
}

Function Enable-WindowsEventCollection {
    
}