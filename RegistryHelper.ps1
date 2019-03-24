#wmi functions wrapped in powershell. WMI is on by default and is a lot faster than winrm

#HKLM = 2147483650
Function Connect-ToRemoteRegistry{

    try{

        [Object]$WMIREGISTRYOBJ = Get-WmiObject -List -NameSpace root\default -ComputerName $strComputer | Where-Object {$_.Name -eq "StdRegProv"}

    }catch{

    }
    return $WMIREGISTRYOBJ
}

Function Assert-RegAccess{

    param(
        [string]$strKey,
        [wmiObject]$oWMIRegistry
    )

	$strKeyPath = "SYSTEM\CurrentControlSet"
	 $bHasAccessRight = $oWMIRegistry.CheckAccess($rootIdentifier, $strKeyPath," KEY_QUERY_VALUE")
	if ($bHasAccessRight -ne $True){
        Write-Host "You do not have access, run script as admin"
    }else{

        return $bHasAccessRight

    }
}
#Returns String, Finds key values in Registry, ONLY for REG_SZ type(string)
Function Get-RegistryREG_SZ{

    param(
        [string]$strKeyPath,
        [string]$strKey,
        [wmiObject]$oWMIRegistry,
        [uint32]$rootIdentifier = 2147483650
    )

    $strKeyValue = $oWMIRegistry.GetStringValue($rootIdentifier,$strKeyPath,$strKey).sValue

    return $strKeyValue
}

#Returns String, Find key values in Registry, Only for REG_MULTI_SZ(arrays)
Function Get-RegistryMulti {

    param(
        [string]$strKeyPath,
        [string]$strKey,
        [wmiObject]$oWMIRegistry,
        [uint32]$rootIdentifier = 2147483650
    )
    $arrKeyValue = @()
    $arrKeyValue = $oWMIRegistry.GetMultiStringValue($rootIdentifier,$strKeyPath,$strKey).sValue
    
	return $arrKeyValue
}
#Returns String, Find key values in Registry, Only for DWORD, Returns human readable value
Function Get-RegistryDWord {
    param(
        [string]$strKeypath, 
        [string]$strKey,
        [wmiObject]$oWMIRegistry,
        [uint32]$rootIdentifier = 2147483650
    )
    $strKeyValue = $oWMIRegistry.GetDWORDValue($rootIdentifier,$strKeyPath,$strKey).uValue
    
    return $strKeyValue
	
}

Function Get-AllKeysInSubKey {
    param(
        [string]$strKeyPath,
        [wmiObject]$oWMIRegistry,
        [uint32]$rootIdentifier = 2147483650
    )

    try{

        $arrSubKeys = $oWMIRegistry.EnumKey($rootIdentifier, $strKeyPath)

    }catch{



    }
    return $arrSubKeys
}

Function Get-AllKeyValuePairsInSubkey{

}

Function Get-ValuesOfOneKey{

}

Function Get-KeyValuePair{}

Function Search-RegForKey{}

Function Search-RegForValue{}

Function Write-key{}

Function Remove-Key{}

Function Assert-KeyExists{
    param(
        [string]$strKeyPath,
        [string]$strKeyName,
        [uint32]$rootIdentifier = 2147483650
    )

    $keyLocation = [io.path]::Combine("HKLM:",$strKeyPath, $strKeyName)

    if ((Test-Path $keyLocation) -ne $false){
        return $true
    }else{
        return $false
    }
}


