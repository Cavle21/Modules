
Import-Module LoggingFunctions
Import-Module SonalystsModules

$Loggingarguments = @{
    logDirectory = "c:\windows\temp\"
    scriptTitle =  "HyperVFunctions"
}

<#
.SYNOPSIS
    Adds new Virtual Machine to invoking host.
.DESCRIPTION
    Adds new Virtual machine to invoking HyperV host. 
.INPUTS
    Hashtable: $VMInitialSetupParameters 
.OUTPUTS
    None
.NOTES
    General notes
#>
Function Add-NewVM {
    param(
        [parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$VMinitialSetupParameters
    )

    try {
        New-VM @VMinitialSetupParameters -errorAction Stop
        New-logmessage @Loggingarguments -errorLevel "0" -message "VM Added"
    }catch{
        New-logmessage @Loggingarguments -errorLevel "2" -message "Unable to create new VM"
        New-Logmessage @Loggingarguments -errorLevel "2" -Message $_.exception.message
    }
    
}

Function Get-PropertiesForVMCreation {
    param(
        [string]$templateFile
    )

    [xml]$config = Get-SonalystsTransformedXmlObject -path $templateFile

    return $config
}

#setVMProperties

Function set-VMProperties{
    param(
        [string]$VMName,
        [System.Collections.Hashtable]$VMParametersToSet
    )
    try {
        Set-VM @VMParametersToSet -errorAction Stop
    }
    catch {
        New-LogMessage @Loggingarguments -errorLevel "2" -message "Unable to set settings for virtual machine $VMName"
        New-Logmessage @Loggingarguments -errorLevel "2" -Message $_.exception.message
    }
}

#setVMDVD

Function AttachISOToVM {
    param(

    )

}

Function Start-VMbyName {
    param(
        [string]$VMName
    )

    try {
        Start-VM -name $VMName -errorAction Stop
    }
    catch {
        new-logMessage @Loggingarguments -errorLevel "2" -message "Unable to start VM $VMName"
        New-Logmessage @Loggingarguments -errorLevel "2" -Message $_.exception.message
    }

}

Function New-VirtualSwitch{
    param(
        [string]$Name,
        [string]$netAdapterName,
        [boolean]$allowManagementOS
    )

    $VirtualSwitchParameters = @{
        name = $Name
        netAdapterName = $netAdapterName
        allowManagementOS = $allowManagementOS
    }

    try {
        New-vmSwitch @VirtualSwitchParameters -errorAction Stop
    }
    catch {
        New-LogMessage @Loggingarguments -errorLevel "2" -message "Unable to create virtual switch"
        New-Logmessage @Loggingarguments -errorLevel "2" -Message $_.exception.message
    }
}

Function Set-VirtualSwitchProperties {
    param(
        [string]$SwitchType
    )

    $VirtualSwitchParameters = @{
        SwitchType = $SwitchType
    }

    try {
        Set-VMSwitch @VirtualSwitchParameters
    }
    catch {
        New-LogMessage @LoggingArguments -errorLevel  -message "Unable to set vmSwitch settings"
        New-LogMessage @LoggingArguments -errorLevel  -message $_.exception.message
    }

}