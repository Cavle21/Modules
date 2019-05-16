using namespace SonalystsTypes.Attributes.Validation
using namespace SonalystsTypes.Attributes.Transform
using namespace SonalystsTypes.Classes

<#
.Synopsis
    Invokes a sql command while providing extra validation.
.DESCRIPTION
    Invokes a sql command while providing extra validation. It will accept parameterized queries where
    variables are realized through the $variableArray param.
.NOTES
    This is designed to fail and abort the command on the first error at which point it bubbles it immediately to the caller.
.PARAMETER serverInstance
    THe full server instance. Example: "MySqlServer\CONTOSOINST"
.PARAMETER sqlString
    The SQL Query. (Can be parameterized).
.PARAMETER databaseName
    Optional param to allow 
.PARAMETER variableArray
    An associative array containing parameter values.
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -sqlString "SELECT * FROM MYTable"
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -sqlString 'SELECT * FROM MYTable WHERE MyTable.Name=$(Name)' -variableArray @("Name=myname")
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -databaseName CONTOSODB -sqlString "SELECT * FROM MYTable"
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -databaseName CONTOSODB -sqlString 'SELECT * FROM MYTable WHERE MyTable.Name=$(Name)' -variableArray @("Name=myname")
.OUTPUT
    SQLResults object encapsulating the result set, status and status message.
#>
function Invoke-SQLCommandFromString {
    [CmdletBinding()]
    [OutputType([SQLResults])]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serverInstance, 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$sqlString,
        
        [Parameter(Mandatory=$false)]
        [string]$databaseName,
        
        [Parameter(Mandatory=$false)]
        [string[]]$variableArray
    ) 
    $resultObj = [SQLResults]::new();
    $resultObj.Success = $false;

  
    if (-not (Assert-SQLConnectionExists -fullInstanceName $serverInstance)){
         $resultObj.Message = "Provided SQL Server connection: $serverInstance Could not be established. Cannot execute the SQL cmd.";
         return $resultObj;
    }

    $inputSplat = @{
        ServerInstance = "$serverInstance"
        Query = "$sqlString"
        AbortOnError = $true
    }

    if (-not [string]::IsNullOrWhiteSpace($databaseName)) {
        $inputSplat["Database"] = "$databaseName";
    } 

    if ($variableArray -ne $null) {
        if ($variableArray.Count -gt 0) {
            $inputSplat["Variable"] = $variableArray;
        }
    }

    $curDir = Get-Location
    try {
         $ret = Invoke-Sqlcmd @inputSplat -ErrorAction SilentlyContinue;
         $resultObj.ResultSet = $ret;
         $resultObj.Success = $true;
         $resultObj.Message = "Command executed successfully";
    } catch {
        $resultObj.Message = "Error running sql cmd: $_";
        $resultObj.Success = $false;
    }
    cd $curDir;

    return $resultObj;
      
}

<#
.Synopsis
    Invokes a sql command from a sql file while providing extra validation.
.DESCRIPTION
    Invokes a sql command from a sql file while providing extra validation. It will accept parameterized queries where
    variables are realized through the $variableArray param.
.NOTES
    This is designed to fail and abort the command on the first error at which point it bubbles it immediately to the caller.
.PARAMETER serverInstance
    THe full server instance. Example: "MySqlServer\CONTOSOINST"
.PARAMETER sqlFile
    The SQL file. (Can be parameterized).
.PARAMETER databaseName
    Optional param to allow 
.PARAMETER variableArray
    An associative array containing parameter values.
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -sqlFile ..\Scripts\SomeQuery.sql
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -sqlFile ..\Scripts\SomeQueryWithNameParam.sql -variableArray @("Name=myname")
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -databaseName CONTOSODB -sqlFile ..\Scripts\SomeQuery.sql
.EXAMPLE
    Invoke-SQLCommandFromString -serverInstance "MySqlServer\CONTOSOINST" -databaseName CONTOSODB -sqlFile ..\Scripts\SomeQueryWithNameParam.sql -variableArray @("Name=myname")
.OUTPUT
    SQLResults object encapsulating the result set, status and status message.
#>
function Invoke-SQLCommandFromFile {
    [CmdletBinding()]
    [OutputType([SQLResults])]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$serverInstance, 

        [Parameter(Mandatory=$true)]
        [ValidateFileOrPathExists()] 
        [string]$sqlFile,
        
        [Parameter(Mandatory=$false)]
        [string]$databaseName,
        
        [Parameter(Mandatory=$false)]
        [string[]]$variableArray
    ) 
    $resultObj = [SQLResults]::new();
    $resultObj.Success = $false;

    #param parsing and binding should catch this, but just in case
    if (-not (Assert-FileExists -filePath $sqlFile)) {
        $resultObj.Message = "Provided SQL Script file: $sqlFile doest not exist. Cannot execute the SQL cmd.";
        return $resultObj;
    }
    
    if (-not (Assert-SQLConnectionExists -fullInstanceName $serverInstance)){
         $resultObj.Message = "Provided SQL Server connection: $serverInstance Could not be established. Cannot execute the SQL cmd.";
         return $resultObj;
    }

    $inputSplat = @{
        ServerInstance = "$serverInstance"
        InputFile = "$sqlFile"
        AbortOnError = $true
    }
    if (-not [string]::IsNullOrWhiteSpace($databaseName)) {
        $inputSplat["Database"] = "$databaseName";
    } 

    if ($variableArray -ne $null) {
        if ($variableArray.Count -gt 0) {
            $inputSplat["Variable"] = $variableArray;
        }
    }

    $curDir = Get-Location
    try {
         $ret = Invoke-Sqlcmd @inputSplat -ErrorAction SilentlyContinue;
         $resultObj.ResultSet = $ret;
         $resultObj.Success = $true;
         $resultObj.Message = "Command executed successfully";
    } catch {
        $resultObj.Message = "Error running sql cmd: $_";
        $resultObj.Success = $false;
    }

    cd $curDir;

    return $resultObj;
}

Export-ModuleMember -Function 'Invoke-*';
