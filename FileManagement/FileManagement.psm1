Function Assert-PathExists { 
    param (
        [string]$path
    ) 

    If ((Test-Path $path) -eq $false) {
        return $false
    } else {
        return $true
    }
}

Function New-Folder {
    param (
        [string]$folderPath,
        [string]$folderName
    )

    $folderPathName = [io.path]::Combine($folderPath, $folderName)

    try {

        New-Item -ItemType directory -Path "$folderPathName" | Out-Null

    }catch {
        
    }

    if((Assert-PathExists) -eq $false){
        Write-host "FolderCreation failed."
        
    }else{
        Write-Host $folderPathName + "already exists".
    }
}

Function Remove-FolderContents{
    param(
        [string]$folderPath,
        [switch]$recurse
    )
    if ((Assert-PathExists) -eq $true -and (Assert-FolderHasContents) -eq $true){
        if ($true -eq $recurse){
            try {
                Get-ChildItem $folderPath -Recurse | Remove-Item -Force
            }catch{

            }
        }else {
            Get-ChildItem $folderPath | Remove-Item
        }
    }else{
        Write-host "$folderPath does not exist. Please specify a location."
    }
}

Function Assert-FolderHasContents{
    param(
        [string]$folderPath
    )

    if ((Assert-PathExists -pathToTest $folderPath) -eq $true){
        $contents = Get-ChildItem $folderPath -Recurse
        if ($null -ne $contents){
            return $true
        }else{
            return $false
        }
    }else{
        Write-host "File does not exist"
        return $false
    }
}

Function findFileInLocation {

    param(
        [string]$filelocation,
        [string]$fileName,
        [switch]$recurse
    )

    $arguments = @{
        path = $filelocation
        recurse = $recurse
    }

    $returned = Get-ChildItem @arguments | Where-Object {$_.name -eq $fileName}

    return $returned
}

Function Invoke-RoboDance {

    param(

        [string]$DirDestExp,
        [string]$DirSourceExp

    )
    #copy contents

    Try {
                    
        # Here's your chance, do the dance, it's the Robocopy jam
        Robocopy "$DirSourceExp" "$DirDestExp" /E /Z /r:2 /W:3 /dcopy:T /MT /MIR /log+:"$RobocopyLogFile"| Out-File -force -FilePath "$RobocopyLogFile.STDOUT" 

        # Check the exit code from robocopy 
        Switch ($LastExitCode) {
            16 {Write-Log "Robocopy exitcode: $LastExitCode - ***SERIOUS FATAL ERROR*** " -EntryType "Error" }
            15 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + FAIL + MISMATCHES + XTRA " -EntryType "Error" }
            14 {Write-Log "Robocopy exitcode: $LastExitCode - FAIL + MISMATCHES + XTRA " -EntryType "Error" }
            13 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + FAIL + MISMATCHES " -EntryType "Error" }
            12 {Write-Log "Robocopy exitcode: $LastExitCode - FAIL + MISMATCHES " -EntryType "Error" }
            11 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + FAIL + XTRA " -EntryType "Error" }
            10 {Write-Log "Robocopy exitcode: $LastExitCode - FAIL + XTRA " -EntryType "Error" }
            9 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + FAIL " -EntryType "Error" }
            8 {Write-Log "Robocopy exitcode: $LastExitCode - FAIL " -EntryType "Error" }
            7 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + MISMATCHES + XTRA " -EntryType "Warning" }
            6 {Write-Log "Robocopy exitcode: $LastExitCode - MISMATCHES + XTRA " -EntryType "Warning" }
            5 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + MISMATCHES " -EntryType "Warning" }
            4 {Write-Log "Robocopy exitcode: $LastExitCode - MISMATCHES " -EntryType "Warning" }
            3 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY + XTRA " -EntryType "Information" }
            2 {Write-Log "Robocopy exitcode: $LastExitCode - XTRA " -EntryType "Information" }
            1 {Write-Log "Robocopy exitcode: $LastExitCode - OKCOPY " -EntryType "Information" }
            0 {Write-Log "Robocopy exitcode: $LastExitCode - No Change " -EntryType "Information" }

        }

    }Catch {

        Write-Log -Message "Failed to copy $($DirSourceExp). Message: $($_.Exception.Message)" -EntryType "Error"

    }   
}

function Import-ConfigFile {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
    }
    
    process {
    }
    
    end {
    }
}



