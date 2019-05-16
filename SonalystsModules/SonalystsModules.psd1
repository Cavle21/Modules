#
# Module manifest for module 'SonalystsHelpers'
#
# Generated by: adm-wks-chalacy
#
# Generated on: 4/10/2019
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'SonalystsTypes.dll'

# Version number of this module.
ModuleVersion = '1.2'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '7d04c52a-28e0-44f2-be88-01b7e417150b'

# Author of this module
Author = 'chalacy'

# Company or vendor of this module
CompanyName = 'Sonalysts, Inc.'

# Copyright statement for this module
Copyright = '(c) 2019 Sonalysts, Inc. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module is a collection of common functionality we use on a daily basis. It is an aggrgate of multiple script module. Each module has functions that are documented through comment based help.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()
#  '.\Modules\Assert-Helpers.psm1',
#   '.\Modules\Get-Helpers.psm1',
#   '.\Modules\Invoke-Helpers.psm1'
#)

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @('SonalystsTypes.dll')

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
#ScriptsToProcess = @(
#   'Classes\ExpandParamStringAttribute.ps1',
#   'Classes\ValidateFileOrPathExistsAttribute.ps1',
#   'Classes\ValidateNotNullEmptyOrWhitespaceAttribute.ps1'
#)

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
   'Scripts\Get-Helpers.psm1',
   'Scripts\Invoke-Helpers.psm1',
   'Scripts\Assert-Helpers.psm1',
   'Scripts\Exit-Helpers.psm1'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
#ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

