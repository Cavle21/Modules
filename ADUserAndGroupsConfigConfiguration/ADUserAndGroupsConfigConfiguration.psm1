<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

Import-Module SecurityFunctions
Import-Module LoggingFunctions
Import-Module SonalystsModules


#######################################################################################################################################
######## DO NOT CHANGE - Changing vars here can make it impossible to decrypt previous config files ###################################
$MasterUIDPassphrase = 'cshVu3-L.TFCY8]i@pu~'							# NEVER change any of this information, or you will 
$MasterUIDSalt = '.K{N~V3/h)S1c61s{0$f'										# not be able to decrypt previous config files.
$MasterUIDIV = "6,R`1&i}T)IGy$;'tf=j"
######## DO NOT CHANGE - Changing vars here can make it impossible to decrypt previous config files ###################################
#######################################################################################################################################


Function Open-ConfigFile {
	param(
		[parameter()]
		[string]$configFileLocation
	)

	Try {
		[xml]$ConfigFile = Get-Content "$configFileLocation"
	}
	Catch {
		# If there is an error reading the config file throw an error and exit
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Host Config File Read Failed!! `nUnabled to read file: $FailedItem `nError message: $ErrorMessage	-ForegroundColor Red
		exit
	}
	
	return $ConfigFile
}
Function New-UID {
    param(
        [parameter()]
            [string]$MasterUIDPassphrase,
        [paramter()]
            [string]$masterUIDSsalt,
        [Paramter()]
            [string]$masterUIDIV
    )
    
    $PasswordsSalt = GET-NewPassword -CheckComplexity
    $PasswordsIV = GET-NewPassword -CheckComplexity
    $PasswordsPassphrase = GET-NewPassword -checkComplexity
	
    If ($uidSALT -eq $uidIV) {
		# The SALT and the IV are the same, this is not acceptable.
		$PasswordsSalt = GET-NewPassword -CheckComplexity
        $PasswordsIV = GET-NewPassword -CheckComplexity
        $PasswordsPassphrase = GET-NewPassword -checkComplexity
		
	}Else {
	
        $uidToEncrypt = "$PasswordsSalt $PasswordsIV $PasswordsPassphrase"
	
	    # Encrypt the Salt IV, and passphrase.
        $NewUID = Encrypt-String -string $uidToEncrypt -Passphrase $MasterUIDPassphrase -Salt $MasterUIDSalt -init $MasterUIDIV 
        Write-Host "Encrypted Unique Salt IV, and passphrase (The new UID): $NewUID" 

	    return $NewUID
    }
}#workedon

Function Save-NewUID {

	param(
		[Parameter(Mandatory=$true)]
		[ValidateScript({Test-Path -Path $_ })]
        [string]$configFileLocation,
        [Parameter()]
        [string]$UID
	)

	# Read the config file. Error and exit if not found. Save to a different var so only this function changes get saved
	$SaveNewUIDConfigFile = Open-ConfigFile -configFileLocation $configFileLocation
    
    if ([string]::IsNullOrWhiteSpace($UID)){

	    [string]$UIDtoSave = New-UID -MasterUIDPassphrase $MasterUIDPassphrase -MasterUIDSalt $MasterUIDSalt -MasterUIDIV $MasterUIDIV
    }
	# Write the new UID and what was used to encrypt it
	#region Save UID and Components
	try{
		$SaveNewUIDConfigFile.configuration.systemInfo.uid = [string]$UIDtoSave
	}catch{
		Write-host $_.exception.message
		throw "Failed to write to Config file"
	}
	try{
		$SaveNewUIDConfigFile.configuration.systemInfo.MasterUIDPassphrase = [string]$MasterUIDPassphrase
	}catch{
		Write-host $_.exception.message
		throw "Failed to write to Config file"
	}
	try{
		$SaveNewUIDConfigFile.configuration.systemInfo.MasterUIDSalt = [string]$MasterUIDSalt 
	}catch{
		Write-host $_.exception.message
		throw "Failed to write to Config file"
	}
	try{
		$SaveNewUIDConfigFile.configuration.systemInfo.MasterUIDIV = [string]$MasterUIDIV
	}catch{
		Write-host $_.exception.message
		throw "Failed to write to Config file"
	}
	#endregion 

	# Overwrite the config file
	try{
		Invoke-SaveConfigFileChanges -configFileLocation $configFileLocation
	}catch{
		Write-host $_.exception.message
		throw "Failed to save Config file"
	}
	Write-Host
	Write-Host Config File Saved -ForegroundColor Yellow
		
	exit
}#workedon

Function Invoke-EncryptConfigPasswords {
    param(
		[parameter(Mandatory=$true)]
		[ValidateScript({Test-Path -Path $_ })]
        [string]$configFileLocation
    )
	
	# Decrypt the UID to get the SALT and IV
	# [0] = SALT [1] = IV [2] = Passphrase
	[System.Collections.ArrayList]$UIDComponents = Invoke-DecryptConfigUID -configFileLocation $configFileLocation

    $configFile = Open-ConfigFile -configFileLocation $configFileLocation

    Write-Host
	Write-Host SALT: $UIDComponents[0]
	Write-Host IV: $UIDComponents[1]
	Write-host Passphrase: $UIDComponents[2]

	# Process userAccounts
	foreach($account in $ConfigFile.configuration.userAccounts.account){
		Write-Host 
		Write-Host Username: $account.username 
		Write-Host Plain Text Password: $account.password

		$arguments = @{
			string = $account.password
			Passphrase = $UIDComponents[2]
			salt = $UIDComponents[0]
			init = $UIDComponents[1]
		}
		
		[string]$EncryptedPW = Invoke-EncryptString @arguments
		
		$account.password = $EncryptedPW
		
		Write-Host Encrypted Password: $account.password
	}
	
    Invoke-SaveConfigFileChanges -configFileLocation $configFileLocation
}#workedon

Function Invoke-SaveConfigFileChanges () {

	param(
		[Parameter(Mandatory=$true)]
		[ValidateScript({Test-Path -Path $_ })]
		[string]$configFileLocation
	)	
	try {
		$ConfigFile.Save($configFileLocation)
	}
	catch {
		write-host $_.exception.message
		throw "failed to save config file. Changes were not saved."
		exit
	}
	
	Write-Host
	Write-Host Config File Saved -ForegroundColor Yellow

	exit
}#workedon

Function Invoke-DecryptConfigUID {

    param(
        [parameter(Mandator=$true)]
        [ValidateScript({Test-Path -Path $_ })]
            [string]$configFileLocation
    )

	$configFile = Open-ConfigFile -configFileLocation $configFileLocation

    #region GetUIDComponents
	
	 [string]$EncryptedUID = $ConfigFile.configuration.systemInfo.uid

    if ([string]::IsNullOrWhiteSpace($encryptedUID)){

        throw "There is no encrypted UID to decrypt. Create one first then run this again."
        exit

    }
    [string]$EncryptedUIDPassphrase = $ConfigFile.configuration.systemInfo.MasterUIDPassphrase

    if ([string]::IsNullOrWhiteSpace($EncryptedUIDPassphrase)){

        throw "There is no encrypted UIDPassphrase to decrypt UID with. Create one first then run this again."
        exit

    }
    [string]$EncryptedUIDSalt = $ConfigFile.configuration.systemInfo.MasterUIDSalt

    if ([string]::IsNullOrWhiteSpace($EncryptedMasterUIDSalt)){

        throw "There is no encrypted UIDPassphrase to decrypt UID with. Create one first then run this again."
        exit

    }
    [string]$EncryptedUIDIV = $ConfigFile.configuration.systemInfo.MasterUIDIV

    if ([string]::IsNullOrWhiteSpace($EncryptedUIDIV)){

        throw "There is no encrypted UIDPassphrase to decrypt UID with. Create one first then run this again."
        exit

    }

	#endRegion
	
	# Decrypt the UID in the config to retrieve the SALT and IV
	# Decrypt the string
	Try {
    	$decryptedUID = Decrypt-String $encryptedUID $MasterUIDPassphrase $MasterUIDSalt $MasterUIDIV 
	}Catch {
		# If there is an error show message and exit
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Host Invalid UID ERROR! The UID is invalid and can not be read. `nError message: $ErrorMessage -ForegroundColor Red
	}
	
	# Split the UID into vars
    [System.Collections.ArrayList]$arrUIDComponents = $decryptedUID -split ' '
		
	# Return the SALT and IV
	return $arrUIDComponents

}#workedon

Function Invoke-EncryptConfigUID {
    param(
        [parameter()]
        [ValidateScript({Test-Path -path $_})]
        [string]$configFileLocation
    )

    $uidToEncrypt = Get-ConfigUID -configFileLocation $configFileLocation

    $encryptedUID = Invoke-EncryptString -string $uidToEncrypt -Passphrase $MasterUIDPassphrase -Salt $MasterUIDSalt -init $MasterUIDIV

    Write-host "UIDEncrypted: $encryptedUID"
    
}

Function Invoke-DecryptConfigPasswords {
    param(
		[parameter(Mandatory=$true)]
		[ValidateScript({Test-Path -Path $_ })]
        [string]$configFilelocation
    )
	
	# Decrypt the UID to get the SALT and IV and passphrase
	# [0] = SALT [1] = IV [2] = Passphrase
	$configFile = Open-ConfigFile -configFileLocation $configFilelocation
	
    if ([string]::IsNullOrWhiteSpace($ConfigFile.configuration.SystemInfo.uid) -eq $true){
        return
	}
	
    [System.Collections.ArrayList]$UIDComponents = Invoke-DecryptConfigUID -configFileLocation $configFilelocation
		
			# Process userAccounts and decrypt their passwords
	foreach($account in $ConfigFile.configuration.userAccounts.account){
		Write-Host 
		Write-Host Username: $account.username 
		Write-Host encrypted Password: $account.password

		$arguments = @{
			string = $account.password
			Passphrase = $UIDComponents[2]
			salt = $UIDComponents[0]
			init = $UIDComponents[1]
		}
		
		[string]$DecryptedPW = Invoke-DecryptString @arguments
		$account.password = [string]$DecryptedPW
    }

    Invoke-SaveConfigFileChanges -configFileLocation $configFileLocation
}#workedon

Function Get-ConfigUID {
    param(
        [parameter()]
        [ValidateScript({Test-Path -path $_})]
        [string]$configFileLocation
    )

	$configFile = Open-ConfigFile -configFileLocation $config
    
    [string]$EncryptedUID = $ConfigFile.configuration.systemInfo.uid

    if ([string]::IsNullOrWhiteSpace($EncryptedUID)){
        Write-host "There is no UID in the configFile. Returning Null"
    }
    return $EncryptedUID

}

