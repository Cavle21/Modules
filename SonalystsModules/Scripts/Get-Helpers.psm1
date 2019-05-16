using namespace SonalystsTypes.Attributes.Validation
using namespace SonalystsTypes.Attributes.Transform
using namespace SonalystsTypes.Classes

<#
.Synopsis
    Convenience function to retrieve the DNS Domain Name
.DESCRIPTION
    Convenience function to retrieve the DNS Domain Name. Nothing special provided for ease of use and code clean up.
.EXAMPLE
    Get-DNSDomainName
.OUTPUT
    System.String. The full DNS domain name: "microsoft.com" 
#>
function Get-DNSDomainName {
    return $env:USERDNSDOMAIN;
}

<#
.Synopsis
    Convenience function to retrieve the Domain Name
.DESCRIPTION
    Convenience function to retrieve the Domain Name. Nothing special provided for ease of use and code clean up.
.EXAMPLE
    Get-DomainName
.OUTPUT
    System.String. The domain name: (assuming the DNS Domain is microsoft.com) "microsoft" 
#>
function Get-DomainName {
    return $env:USERDOMAIN;
}

<#
.Synopsis
    Convenience function to retrieve the Computer Name
.DESCRIPTION
    Convenience function to retrieve the Computer Name. Nothing special provided for ease of use and code clean up.
.EXAMPLE
    Get-ComputerName
.OUTPUT
    System.String. The Computer name: ID1234
#>
function Get-ComputerName {
    return $env:COMPUTERNAME;
}

<#
.Synopsis
    Convenience function to retrieve the WmiObject for a specific service by name.
.DESCRIPTION
    Convenience function to retrieve the WmiObject for a specific service by name. THis provides
    another layer of validation.
.EXAMPLE
    Get-ServiceInfoByName -serviceName 'MSSQL$CONTOSOINST'
.OUTPUT
    System.Object. An object representing the returned service (if found)
#>
function Get-ServiceInfoByName {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serviceName
    ) 
    return (Get-CimInstance -ClassName Win32_Service) | Where-Object { $_.Name -eq $serviceName }
}

<#
.Synopsis
    Convenience function to retrieve the WmiObject for a specific service by display name.
.DESCRIPTION
    Convenience function to retrieve the WmiObject for a specific service by display name. THis provides
    another layer of validation.
.EXAMPLE
    Get-ServiceInfoByDisplayName -serviceDisplayName 'SQL Server (CONTOSOINST)'
.OUTPUT
    System.Object. An object representing the returned service (if found)
#>
function Get-ServiceInfoByDisplayName {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serviceDisplayName
    ) 
    return (Get-CimInstance -ClassName Win32_Service) | Where-Object { $_.DisplayName -eq $serviceDisplayName }
}

<#
.Synopsis
    Convenience function to retrieve the WmiObject for a specific service by service login account name.
.DESCRIPTION
    Convenience function to retrieve the WmiObject for a specific service by service login account name. THis provides
    another layer of validation.
.EXAMPLE
    Get-ServiceInfoByServiceAccountName -serviceAccountName 'NT Service\MSSQL$CONTOSOINST'
.EXAMPLE
    Get-ServiceInfoByServiceAccountName -serviceAccountName 'Microsoft\ContosoDBEng$'
.OUTPUT
    System.Object. An object representing the returned service (if found)
#>
function Get-ServiceInfoByServiceAccountName {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serviceAccountName
    ) 
    return (Get-CimInstance -ClassName Win32_Service) | Where-Object { $_.StartName -eq $serviceAccountName }
}

<#
.Synopsis
    Convenience function to retrieve the fully qualified Domain Name for the computer
.DESCRIPTION
     Convenience function to retrieve the fully qualified Domain Name for the computer. Nothing special provided for ease of use and code clean up.
.EXAMPLE
    Get-FullyQualifiedDomainName
.OUTPUT
    System.String. The fully qualified domain name: "ID1234.microsoft.com" 
#>
function Get-FullyQualifiedDomainName {
    $compName = Get-ComputerName;
    $fqdn = Get-DNSDomainName;

    return "$compName.$fqdn";
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Server Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Server Service Account Name. This will use the standard moniker provided by microsoft
     with regards to how they name their service accounts
.EXAMPLE
     Get-SQLServerServiceAccount -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The account name for the instance's SQL database engine service.
#>
function Get-SQLServerServiceAccount {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )
    
    #The MSDN docs state that the service name of the db engine is always in the format "MSSQL$<InstanceName>", therefore
    # we can look up the database service login by looking up by that moniker.
    $prefix = 'MSSQL$';
    $tempLookup = $prefix + $dbInstanceName;
    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Agent Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Agent Service Account Name. This will use the standard moniker provided by microsoft
     with regards to how they name their service accounts
.EXAMPLE
     Get-SQLServerAgentAccount -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The account name for the instance's SQL agent service.
#>
function Get-SQLServerAgentAccount {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )
    $prefix = 'SQLAgent$';
    $tempLookup = $prefix + $dbInstanceName;

    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Full-text Daemon Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Full-text Daemon Service Account Name. This will use the standard moniker provided by microsoft
     with regards to how they name their service accounts
.EXAMPLE
     Get-SQLServerFullTextDaemonAccount -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The account name for the instance's SQL Full-text Daemon service.
#>
function Get-SQLServerFullTextDaemonAccount {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )
    $prefix = 'MSSQLFDLauncher$';
    $tempLookup = $prefix + $dbInstanceName;

    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null; 
}

<#
.Synopsis
    Convenience function to retrieve the SQL Browser Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Browser Service Account Name.The browser
     service is not instance specific.
.EXAMPLE
     Get-SQLServerBrowserAccount
.OUTPUT
    System.String. The account name for the SQL Browser service.
#>
function Get-SQLServerBrowserAccount {
    $tempLookup = 'SQLBrowser';
    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null;
}

<#
.Synopsis
    Convenience function to retrieve the SQL VSS Writer Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL VSS Writer Service Account Name. The VSS Writer
     service is not instance specific.
.EXAMPLE
     Get-SQLServerVSSWriterAccount
.OUTPUT
    System.String. The account name for the SQL VSS Writer service.
#>
function Get-SQLServerVSSWriterAccount {
    $tempLookup = 'SQLWriter';
    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL CEIP Service Account Name
.DESCRIPTION
     Convenience function to retrieve the instance's SQL CEIP Service Account Name. This will use the standard moniker provided by microsoft
     with regards to how they name their service accounts
.EXAMPLE
     Get-SQLServerCEIPAccount -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The account name for the instance's SQL CEIP service.
#>
function Get-SQLServerCEIPAccount {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    ) 

    $prefix = 'SQLTELEMETRY$';
    $tempLookup = $prefix + $dbInstanceName;

    $service = Get-ServiceInfoByName -serviceName $tempLookup;

    if ($service -ne $null) {
        return $service.StartName;
    }

    return $null;
}

<#
.Synopsis
    Convenience function to retrieve a domain distinguished name.
.DESCRIPTION
     Convenience function to retrieve a domain distinguished name. This will
     walk down the domain tree to figure out the root distinguished name of the 
     passed in partial domain.
.EXAMPLE
     Get-DomainDistinguishedName -domainName Microsoft
.EXAMPLE
     Get-DomainDistinguishedName -domainName Microsoft.Mail
.OUTPUT
    System.String. The domain distinguished name: (dc=microsoft,dc=mail,dc=com).
#>
function Get-DomainDistinguishedName {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$domainName
    )
    $searchString = "";
    $parts = $domainName.Split('.');
    #This is a full path if it contains a dot.
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $part = $parts[$i];
        $searchString += "(dc=$part)";
    }
    Write-Verbose $searchString

    $searcher = [ADSISearcher]"(|$searchString)"
    $entry = $searcher.FindOne();

    if ($entry -ne $null) {
        return $entry.GetDirectoryEntry().distinguishedName;
    }

    return $domainName;
}

<#
.Synopsis
    Convenience function to retrieve a name and the LDAP path for a domain CN
.DESCRIPTION
     Convenience function to retrieve a name and the LDAP path for a domain CN. This will
     break down the name passed in to the function to glean the LDAP distinguisehd path and the
     name in a nice neat type. The CN can be a computer, OU, grou, user, etc..
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName joeuser
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName id1234
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName joeuser@microsoft.com
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName id1234@microsoft.com
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName microsoft/joeuser
.EXAMPLE
     Get-LDAPBreakdowForFullDomainName -domainCName microsoft/id1234
.OUTPUT
    SonalystsTypes.Classes.LDAPResultsBreakdown. An object encapsulating the resultant name and path.
#>
function Get-LDAPBreakdowForFullDomainName {
    [CmdletBinding()]
    [OutputType([LDAPResultsBreakdown])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateDomainUserNameFormat()]
        [string]$domainCName
    )

    $retVal = [LDAPResultsBreakdown]::new();
    
    $retVal.Name = $domainCName;
    $retVal.Path = $null;
    if ($domainCName.Contains('\')) {
        $parts = $domainCName.Split('\');
        $retVal.Name = $parts[1];
        if (-not $parts[0].Contains(' ')) {
            $domainString = Get-DomainDistinguishedName -domainName $parts[0]
            $retVal.Path = "$domainString"
        }
    }

    if ($domainCName.Contains('@')) {
        $parts = $domainCName.Split('@');

        $retVal.Name = $parts[0];

        $theRest = $parts[1];

        $dotParts = $theRest.Split('.');
        $domainString = "";
        for ($i = 0; $i -lt $dotParts.Count; $i++) {
            $part = $dotParts[$i];
            $domainString += "DC=$part";

            #add commas to all parts except the last. We will add the just before the com.
            if ($i -ne $parts.Count - 1) {
                $domainString += ',';
            }
        }

        $retVal.Path = "$domainString"
    }

    return $retVal;
}

<#
.Synopsis
    Convenience function to retrieve the instance's registry path.
.DESCRIPTION
     Convenience function to retrieve the instance's registry path. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerIntanceRegistryPath -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The resgirtys path of the server instance.
#>
function Get-SQLServerIntanceRegistryPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $basePath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\";

    $lookup = $basePath + "Instance Names\SQL";

    $subKey = Get-ItemPropertyValue -Path $lookup -Name $dbInstanceName;

    if (-not [string]::IsNullOrEmpty($subKey)) {
        return $basePath +  $subKey;
    }

    return "";
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQLDataRoot directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQLDataRoot directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLPath -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQLDataRoot directory of the server instance.
#>
function Get-SQLServerInstanceSQLDataRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\Setup";
    $valueName = "SQLDataRoot";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQLBinRoot directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQLBinRoot directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLBinRoot -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQLBinRoot directory of the server instance.
#>
function Get-SQLServerInstanceSQLBinRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\Setup";
    $valueName = "SQLBinRoot";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQLPath directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQLPath directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLPath -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQLPath directory of the server instance.
#>
function Get-SQLServerInstanceSQLPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\Setup";
    $valueName = "SQLPath";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Agent Jobs directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Agent Jobs directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLJobsDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Agent Jobs directory of the server instance.
#>
function Get-SQLServerInstanceSQLAgentJobsDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\SQLServerAgent";
    $valueName = "WorkingDirectory";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL BackupDirectory directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL BackupDirectory directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLBackupDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Backup Directory directory of the server instance.
#>
function Get-SQLServerInstanceSQLBackupDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\MSSQLServer";
    $valueName = "BackupDirectory";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Program directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Program directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLProgramDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Program Directory directory of the server instance.
#>
function Get-SQLServerInstanceSQLProgramDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\Setup";
    $valueName = "SqlProgramDir";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Log directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Log directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceSQLLogDir -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Log directory of the server instance.
#>
function Get-SQLServerInstanceSQLLogDir {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\MSSQLServer\Parameters";

    $values = Get-Item -Path $path

    $data = Get-ItemPropertyValue -Path $path -Name $values.Property;

    foreach ($param in $data) {
        $paramString = $param.ToString();

        if ($paramString.StartsWith("-e")) { #MSDN states that the startup param -e indicates where the error log is to be placed. We only need the directory so we are parsing that so.
            $ret = $paramString.Substring(2).Replace("\ERRORLOG","");

            return $ret;
        }
    }

    return "";
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Data directory. This assumes it is querying
    an instance on the same computer.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Log directory. This
     will be run on the comptuer that houses the SQL Data.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceDataDirectory -instance CONTOSOINST
.OUTPUT
    System.String. The SQL Data directory of the server instance.
#>
function Get-SQLServerInstanceDataDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $connection = "$env:COMPUTERNAME\$dbInstanceName"

    [SQLResults]$ret = Invoke-SQLCommandFromString -serverInstance $connection -sqlString "SELECT SERVERPROPERTY('InstanceDefaultDataPath') AS DataPath";

    if ($ret.Success) {
        $row = [System.Data.DataRow]$ret.ResultSet;

        $pathStr = $row.DataPath;

        return $pathStr.TrimEnd([System.IO.Path]::DirectorySeparatorChar);
    }

    return "";
}

<#
.Synopsis
    Convenience function to retrieve the instance's SQL Replication directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Replication directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceReplicationDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Replication directory of the server instance.
#>
function Get-SQLServerInstanceReplicationDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    $instPath = Get-SQLServerIntanceRegistryPath -dbInstanceName $dbInstanceName;
    $path = $instPath + "\Replication";
    $valueName = "WorkingDirectory";

    return Get-ItemPropertyValue -Path $path -Name $valueName;
}


<#
.Synopsis
    Convenience function to retrieve the instance's SQL FT Data directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL FT Data directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceFTDataDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL FT Data directory of the server instance.
#>
function Get-SQLServerInstanceFTDataDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    #TODO: If we can make this more agnostic, do so, otherwise this is the default.
    $basePath = Get-SQLServerInstanceSQLDataRoot -dbInstanceName $dbInstanceName;

    return "$basePath\FTData";
}


<#
.Synopsis
    Convenience function to retrieve the instance's SQL Install directory.
.DESCRIPTION
     Convenience function to retrieve the instance's SQL Install directory. This
     will be run on the comptuer that houses the SQL Server.
.NOTES
    Must be run on the server that houses the instance.
.PARAMETER dbInstanceName
    The instance to interrogate.
.EXAMPLE
     Get-SQLServerInstanceInstallDirectory -dbInstanceName CONTOSOINST
.OUTPUT
    System.String. The SQL Install directory of the server instance.
#>
function Get-SQLServerInstanceInstallDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$dbInstanceName
    )

    #TODO: If we can make this more agnostic, do so, otherwise this is the default.
    $basePath = Get-SQLServerInstanceSQLDataRoot -dbInstanceName $dbInstanceName;

    return "$basePath\Install";
}


Export-ModuleMember -Function 'Get-*';
