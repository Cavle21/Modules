Function Get-FromVault{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Mode')]
        [Validateset('GetLatest','GetWorking')]
            [string]$mode,

        [Parameter()]
            [string]$folderToUpdate,

        [Parameter()]
            [string]$repository = "OIU",

        [Parameter(Mandatory=$True)]
            [string]$securePassword,

        [Parameter()]
            [string]$hostServer = "vault.sonalysts.com"

    )
    <#
.DESCRIPTION
Allows users to access two functions of vault. Get the working folder (GetWorking) or get latest from a 
vault directory (GetLatest)

.PARAMETER $securePassword
The user will need the password to access vault. 


.EXAMPLE
Get-FromVault -GetLatest -FolderToUpdate '$/Documents/' [-repository "OIU] -value $securePassword

.EXAMPLE
Get-FromVault -GetWorking -value $securePassword


.NOTES
stole and modified from stephon's WeeklyAVPackager
'$' will always be root. So, to get the weekly av packager user will input '$/Tools/WeeklyAVPackager/'
For the -FolderToUpdate make sure you use forward slash(/) not backslash (\)

#>


    $filePath = "C:\Program Files (x86)\SourceGear\Vault Client"
    $executable = "vault.exe"

    if ($mode -eq 'GetWorking'){
        Write-log "Getting working folder from vault"

        $arguments = "ListWorkingFolders -host $hostServer -user $env:Username -password $securePassword -ssl -repository $repository"

        $result = Invoke-Process -commandPath $filePath -executable $executable -commandArguments $arguments -CMD $false
        [xml]$exitMessage = $result.stdOut
        if ($exitMessage.Vault.result.success -eq $true){
            $localFolder = $exitMessage.Vault.listworkingfolders.workingfolder.localfolder
            Write-log "Got the working folder!"
            return $localFolder
        }else{
            Write-Verbose $result.vault.error
            Write-log -EntryType Error -message "Failed to get working folder." $exitMessage.Vault.Error 
            return $false
        }
    }
    elseif ($mode -eq 'GetLatest'){
        if ($folderToUpdate){
            Write-log "Grabbing latest for $folderToUpdate from vault repository $repository"

            #NOTICE THE DOUBLE DOUBLE QUOTES AROUND THE VAULT PATH##
            $arguments = "GET ""$folderToUpdate"" -host $hostServer -merge overwrite -setfiletime current -user $env:USERNAME -password $securePassword -ssl -repository $repository"

            $result = Invoke-Process -commandPath $filePath -executable $executable -commandArguments $arguments -CMD $false
            [xml]$exitMessage = $result.stdout

        }else{
            Write-Verbose "You need to specify a vault directory when trying the get latest of a vault directory."
            return $false
        }
        if ($exitMessage.vault.result.success -eq $true){
            Write-Log "Get Latest Succeeded!"
            return $true
        }else{
            Write-log -EntryType Error -message "Get Latest Failed! Terminating script."
            $vaultError = $exitMessage.vault.error.exception
            Write-log -EntryType Error -message $vaultError
            Write-Verbose $exitMessage.vault.error
            return $false
        }
    }else{
        Write-host "No perameter specified. Choose WorkingFolder or GetLatest -folderToUpdate <folderinvault>"
    }
}

Function Get-WorkingFolders {

    param(

    )

    $filePath = "C:\Program Files (x86)\SourceGear\Vault Client"
    $executable = "vault.exe"

    Write-log "Getting working folder from vault"

    $arguments = "ListWorkingFolders -host $hostServer -user $env:Username -password $securePassword -ssl -repository $repository"

    $result = Invoke-Process -commandPath $filePath -executable $executable -commandArguments $arguments -CMD $false
    [xml]$exitMessage = $result.stdOut
    if ($exitMessage.Vault.result.success -eq $true){
        $localFolder = $exitMessage.Vault.listworkingfolders.workingfolder.localfolder
        Write-log "Got the working folder!"
        return $localFolder
    }else{
        Write-Verbose $result.vault.error
        Write-log -EntryType Error -message "Failed to get working folder." $exitMessage.Vault.Error 
        return $false
    }

}

Function Get-LatestofFolder {

}

Function Assert-LoginCredentialsAreCorrect{

}

Function Check-VaultLogin {

    param(

        [string]$message = "Enter Vault Password"

    )

    $SecurePass = Get-Credential -message "$message" -UserName $env:USERNAME
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass.password)
    $securePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    
    $result = Assert-VaultCredsValid -$securePassword 
    if($result){
        return $securePassword
    }else{
        Check-VaultLogin -message "Incorrect Username/Password. `n Enter Vault Password"
    }
}
Function Assert-VaultCredsValid {
    
    param(
        [Parameter(Mandatory=$true)]
            [string]$securePassword
    )

    [xml]$returnedResult = Get-FromVault -mode GetWorking -value $securePassword

    $result = "$returnedResult.vault.result.success"

    if ($result -eq "True"){
        return $true
    }else{
        return $false
    }
    return $result   
}

Function Assert-VaultIsInstalled {

}



