Function Assert-PathExists { 
    param (
        [string]$pathToTest
    ) 
    If ((Test-Path $pathToTest) -eq $false) {
        Write-Host "$pathToTest does not exist"
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

    if((test-path $folderPathName) -eq $false){
        Write-host "Folder does not exist, making one"
        New-Item -ItemType directory -Path "$folderPathName" | Out-Null
    }else{
        Write-Host $folderPathName + "already exists".
    }
}

Function Remove-FolderContents{
    param(
        [string]$folderPath,
        [switch]$recurse
    )
    if ((Test-Path $folderPath) -eq $true){
        if ($true -eq $recurse){
            Get-ChildItem $folderPath  -Recurse | Remove-Item -Force
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





