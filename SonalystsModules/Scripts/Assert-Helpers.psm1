using namespace SonalystsTypes.Attributes.Validation
using namespace SonalystsTypes.Attributes.Transform
using namespace SonalystsTypes.Classes

<#
.Synopsis
    Asserts that a provided domain user exists.
.DESCRIPTION
    This function will check the domain user name using the ADSI Searcher accelerator. This function will work on any domain
    joined asset that allows LDAP queries. 
.PARAMETER domainUserName
    The domain user name. This can be: Just the user name (SAMAccoutName), UPN (<username>@<fully qualified domain name>), or down-level (<domain>/<username>)
.EXAMPLE
    Assert-DomainUserExists -domainUserName 'joeuser'
.EXAMPLE
    Assert-DomainUserExists -domainUserName 'joeuser@microsoft.com'
    .EXAMPLE
    Assert-DomainUserExists -domainUserName 'microsoft\joeuser'
.OUTPUTS
    Boolean Literal. Returns true if the domain user exists, false otherwise. 
#>
function Assert-DomainUserExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateDomainUserNameFormat()]
        [string]$domainUserName
    ) 
    
    #assume what was given us was just a user name until we find out otherwise.
    $ret = Get-LDAPBreakdowForFullDomainName -domainCName $domainUserName;
    $nameStr = $ret.Name;
    $searcher = [ADSISearcher]"(samaccountname=$nameStr)";
    if (-not [string]::IsNullOrEmpty($ret.Path)) {
        $ldap = "LDAP://" + $ret.Path;
        $searcher.SearchRoot=[adsi]$ldap
    }
    $results = $searcher.FindOne();
    
    if ($results -eq $null) {
        return $false;
    }

    return $true;
}

<#
.Synopsis
    Asserts that a provided local user exists on the local computer.
.DESCRIPTION
    This function will check the local computer only. Additionally, this provides extra validation before proceeding.
.PARAMETER userName
    The local user name. This is just the user name and nothing else. (i.e. joueser as opposed to Group\joeuser)
.EXAMPLE
    Assert-LocalUserExists -userName 'joeuser'
.OUTPUTS
    Boolean Literal. Returns true if the local user exists, false otherwise. 
#>
function Assert-LocalUserExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$userName
    ) 
    Try {
        $result = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue;

        if ([string]::IsNullOrEmpty($result) -eq $true) {
            return $false;
        }

        return $true;
    } Catch {
        return $false
    }

    return $false
}

<#
.Synopsis
    Asserts that a provided virtual service acccount exists on the computer.
.DESCRIPTION
    This function will check the local computer only. It asserts that a provided virtual service acccount exists on the computer.
    Generally, Vritual Service Accounts are used by some services and maintain the pattern: <ServicePrefix>$<SomeIdentifier>
.PARAMETER virtualServiceAccountName
    The service account start name.
.EXAMPLE
    Assert-ServiceAccountExists -serviceAccountName 'NT Service\MSSQL$CONTOSODB'
 .EXAMPLE
    Assert-ServiceAccountExists -serviceAccountName 'SomeDomain\MSSQL$CONTOSODB$'
.OUTPUTS
    Boolean Literal. Returns true if the service acocunt exists, false otherwise. 
#>
function Assert-ServiceAccountExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serviceAccountName
    ) 
    
    $service = Get-ServiceInfoByServiceAccountName -serviceAccountName $serviceAccountName
    
    return $service -ne $null; 
}

<#
.Synopsis
    Asserts that a provided account exists in the domain, locally or is a virtual service account./
.DESCRIPTION
    This function is provided for convenience. It allows the consumer to check all the "flavors" of accounts without
    having to call the three functions separately. This is useful for checking owners or principles on ACL objects.
.PARAMETER AccountExists
    The user name only. This is just the user name and nothing else. (i.e. MSSQL$CONTOSODB as opposed to NT Service\MSSQL$CONTOSODB )
.EXAMPLE
    Assert-AccountExists -accountName 'MSSQL$CONTOSODB'
.OUTPUTS
    Boolean Literal. Returns true if the acocunt exists, false otherwise. 
#>
function Assert-AccountExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$accountName
    ) 

    $ret = Assert-DomainUserExists -domainUserName $accountName;
    if ($ret -eq $false) {
        Write-Warning -Message "Failed to find $accountName in the domain... Checking local users";
        $ret = Assert-LocalUserExists -userName $accountName;
        if ($ret -eq $false) { 
            Write-Warning -Message "Failed to find $accountName in local users... Checking virtual service accounts";
            $ret = Assert-ServiceAccountExists -serviceAccountName $accountName;
        }
         
    }

    return $ret;
}

<#
.Synopsis
    Asserts a file or path exists.
.DESCRIPTION
    This is a convenience function to allow for finer grained validation before proceeding.
.PARAMETER filePath
    The file path to check.
.EXAMPLE
    Assert-FileExists -filePath "C:\Path\file.txt"
.EXAMPLE
    Assert-FileExists -filePath "C:\Path\SomePath"
.OUTPUTS
    Boolean Literal. Returns true if the file exists, false otherwise. 
#>
function Assert-FileExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$filePath
    ) 
    if (-not (Test-Path -Path $filePath -ErrorAction SilentlyContinue)) {
        return $false;
    }

    return $true;
}

<#
.Synopsis
    Asserts a sql connection can be established.
.DESCRIPTION
    This is a convenience function to allow for finer grained validation before proceeding. This will
    check if a connection can be established to a server instance and optionally a specific database.
.NOTES
    This will only work off of the standard <server>\<instance name> paradigm for instance name.
.PARAMETER fullInstanceName
    The full instance name to check. This will only work off of the standard <server>\<instance name> paradigm.
.PARAMETER databaseName
    Optional parameter to establish a connection to a specific database within the instance.
.EXAMPLE
    Assert-SQLConnectionExists -fullInstanceName CONTOSOServer\CONTOSOINST
.EXAMPLE
    Assert-SQLConnectionExists -fullInstanceName CONTOSOServer\CONTOSOINST -databaseName CONTOSODB
.OUTPUTS
    Boolean Literal. Returns true if the conenction can be established and therefore exists, false otherwise. 
#>
function Assert-SQLConnectionExists {
    [CmdletBinding()]
     param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [ExpandParamString()]
        [string]$fullInstanceName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$databaseName
    ) 

    $dbConnection = New-Object System.Data.SqlClient.SqlConnection;
    try {
        $dbConnection.ConnectionString = "Data Source=$fullInstanceName; "
        if ($databaseName -ne $null) {
            $dbConnection.ConnectionString += "Database=$databaseName; "
        }
        $dbConnection.ConnectionString += "Integrated Security=True"
        $dbConnection.Open();
        return $true;
    } catch {
        return $false;
    } finally {
        $dbConnection.Close();
    }

    return $false;
}

<#
.Synopsis
    Asserts that a provided domain computer exists.
.DESCRIPTION
    This function will check the domain user name using the ADSI Searcher accelerator. This function will work on any domain
    joined asset that allows LDAP queries. 
.PARAMETER domainUserName
    The domain user name. This can be: Just the name (name), UPN (<computer name>@<fully qualified domain name>), or down-level (<domain>/<computer name>)
.EXAMPLE
    Assert-ComputerExists -domainName 'id1234'
.EXAMPLE
    Assert-ComputerExists -domainName 'id1234@microsoft.com'
.EXAMPLE
    Assert-ComputerExists -domainName 'microsoft\id1234'
.OUTPUTS
    Boolean Literal. Returns true if the domain user exists, false otherwise. 
#>
function Assert-ComputerExists {
    [CmdletBinding()]
    param (   
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateDomainUserNameFormat()]
        [string]$domainName
    ) 

    $ret = Get-LDAPBreakdowForFullDomainName -domainName $domainName;
    $nameStr = $ret.Name;
    $searcher = [ADSISearcher]"(&(objectCategory=computer)(name=$nameStr))";
    if (-not [string]::IsNullOrEmpty($ret.Path)) {
        $ldap = "LDAP://" + $ret.Path;
        $searcher.SearchRoot=[adsi]$ldap
    }
    $results = $searcher.FindOne();
    
    if ($results -eq $null) {
        return $false;
    }

    return $true;
}

Export-ModuleMember -Function 'Assert-*';

