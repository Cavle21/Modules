#region imports and usings
using namespace System.Security.Cryptography

Import-Module LoggingFunctions
Import-Module SonalystsModules
[Reflection.Assembly]::LoadWithPartialName("System.Security") 
$Loggingarguments = @{
    logDirectory = "c:\windows\temp\"
    scriptTitle =  "SecurityFunctions"
}
#endregion

#region Functions

#region Invoke-EncryptString
<#
.SYNOPSIS
    This function is to Encrypt A String. 
.DESCRIPTION
    This function takes a a string and applies an encryption algo using passphrase, salt and init.
    It uses SHA256 and runs through the has 5 times and returns a 32 bit key. It then uses the init to 
    generate a unique hash. The key and hash are then used to encrypt the string.
    It MUST be at least 14 characters include 1 alphanumeric 2 numeric and 2 special characters. 
.EXAMPLE
    PS C:\> Invoke-EncryptString -String "stringtoEncrypt" -Passphrase "90234kkasfd@(#" -salt "98234kjaf---" -init "00982034lkdf'';\"
    Encryptes "stringToEncrypt" using the passphrase salt and init.
.INPUTS
    [String]$string is the string to encrypt
    [string]$passphrase is a second security "password" that has to be passed to decrypt. 
    [string]$salt is used during the generation of the crypto password to prevent password guessing. 
    [string]$init is used to compute the crypto hash -- a checksum of the encryption
    All MUST be at least 14 characters include 1 alpha, 2 numeric and, 2 special characters.
.OUTPUTS
    $string encrypted by salt and IV as string.
.NOTES
    Everything is sent to function as unencrypted string. The function takes care of settings the items to bits
    For use with the encryption algos.
    SAVE YOUR passphrase, salt and init. It will be needed to decrypted the string.
#>
Function Invoke-EncryptString() { 

    param(
        [parameter(Mandatory=$True)]
            [string]$String, 
        [parameter(Mandatory=$True)]
            [string]$Passphrase, 
        [parameter(Mandatory=$True)]
            [string]$salt, 
        [parameter(Mandatory=$True)]
            [string]$init
    )
    #region Complexity Checks.
    try {
        Assert-StringComplexity -stringToTest $String
    }catch{
        Write-host "String failed complexity checks."
        $_.exception.message
        exit
    }
    try {
        Assert-StringComplexity -stringToTest $Passphrase
    }catch{
        Write-host "Passphrase failed complexity checks."
        $_.exception.message
        exit
    }
    try {
        Assert-StringComplexity -stringToTest $salt
    }catch{
        Write-host "salt failed complexity checks."
        $_.exception.message
        exit
    }
    try {
        Assert-StringComplexity -stringToTest $init
    }catch{
        Write-host "init failed complexity checks."
        $_.exception.message
        exit
    }
    #endRegion
    
    # Create a COM Object for RijndaelManaged Cryptography 
    $r = new-Object System.Security.Cryptography.AESManaged
    # Convert the Passphrase to UTF8 Bytes 
    [byte[]]$pass = [Text.Encoding]::UTF8.GetBytes($Passphrase) 
    # Convert the Salt to UTF Bytes 
    [byte[]]$salt = [Text.Encoding]::UTF8.GetBytes($salt) 
    
    # Create the Encryption Key using the passphrase, salt and SHA256 algorithm at 256 bits 
    $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA256", 5).GetBytes(32) #256/8 
    # Create the Intersecting Vector Cryptology Hash with the init 
    $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15] 
        
    # Starts the New Encryption using the Key and IV    
    $c = $r.CreateEncryptor() 
    # Creates a MemoryStream to do the encryption in 
    $ms = new-Object IO.MemoryStream 
    # Creates the new Cryptology Stream --> Outputs to $MS or Memory Stream 
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write" 
    # Starts the new Cryptology Stream 
    $sw = new-Object IO.StreamWriter $cs 
    # Writes the string in the Cryptology Stream 
    $sw.Write($String) 
    # Stops the stream writer 
    $sw.Close() 
    # Stops the Cryptology Stream 
    $cs.Close() 
    # Stops writing to Memory 
    $ms.Close() 
    # Clears the IV and HASH from memory to prevent memory read attacks 
    $r.Clear() 
    # Takes the MemoryStream and puts it to an array 
    [byte[]]$result = $ms.ToArray() 
    # Converts the array from Base 64 to a string and returns 
    return [Convert]::ToBase64String($result) 
} 
#endregion

#region Invoke-DecryptString
<#
.SYNOPSIS
    Decrypts provided string
.DESCRIPTION
    Uses passphrase, salt and init used to encrypt string to decrypt the string.
.EXAMPLE
    Invoke-decryptstring -String "==asdfh23935(()(" -Passphrase "90234kkasfd@(#" -salt "98234kjaf---" -init "00982034lkdf'';\"
    Decrypts string using passphrase salt and init that was used to encrypt the string.
.INPUTS
    [securestring]$Encryptedpassword,
    [string]$Passphrase,
    [string]$salt, 
    [string]$init
.OUTPUTS
    string decrypted version of encryptedPassword.
.NOTES
    If you cannot find your passphrase, salt and init you used to encrypt this string, you cannot
    decrypt this string.
#>
Function Invoke-DecryptString() { 

    param(
        [string]$Encryptedpassword,
        [string]$Passphrase,
        [string]$salt, 
        [string]$init
    )
    # If the value in the $Encrypted is a string, convert it to Base64 
    if($Encryptedpassword -is [string]){ 
        [byte[]]$Encryptedpassword = [Convert]::FromBase64String($Encryptedpassword) 
    } 
    
    # Create a COM Object for RijndaelManaged Cryptography 
    $r = new-Object System.Security.Cryptography.RijndaelManaged 
    # Convert the Passphrase to UTF8 Bytes 
    [byte[]]$pass = [Text.Encoding]::UTF8.GetBytes($Passphrase) 
    # Convert the Salt to UTF8 Bytes 
    [byte[]]$salt = [Text.Encoding]::UTF8.GetBytes($salt) 
    
    # Create the Encryption Key using the passphrase, salt and SHA1 algorithm at 256 bits 
    $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA256", 5).GetBytes(32) #256/8 
    # Create the Intersecting Vector Cryptology Hash with the init 
    $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15] 
    
    
    # Create a new Decryptor 
    $d = $r.CreateDecryptor() 
    # Create a New memory stream with the encrypted value. 
    $ms = new-Object IO.MemoryStream @(,$Encryptedpassword)
    # Read the new memory stream and read it in the cryptology stream 
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$d,"Read" 
    # Read the new decrypted stream 
    $sr = new-Object IO.StreamReader $cs 
    # Return from the function the stream to the pipeline, this acts as a 'return'
    Write-Output $sr.ReadToEnd() 
    # Stops the stream     
    $sr.Close() 
    # Stops the crypology stream 
    $cs.Close() 
    # Stops the memory stream 
    $ms.Close() 
    # Clears the RijndaelManaged Cryptology IV and Key 
    $r.Clear() 
} 
#endRegion

#region Get-NewPassword
<#
.SYNOPSIS
    Generates unique password.
.DESCRIPTION
    Generates a unique password based on password length and complexity parameters. 
.EXAMPLE
    PS C:\> Get-NewPassword
    Explanation of what the example does
.INPUTS
    PasswordLength (default = 20)(recommended 14+)
    Complexity can be from 1 - 4 with the results being 
    1 - Pure lowercase Ascii 
    2 - Mix Uppercase and Lowercase Ascii 
    3 - Ascii Upper/Lower with Numbers 
    4 - Ascii Upper/Lower with Numbers and Punctuation (recommended) (default)
    switch CheckComplexity runs password through password checker to make sure it passes:
    atleast 1 alpha
    atleast 2 numeric
    atleast 2 special
    atleast 14 characters
    it will only activate, even if you call it, if the password length is 14+ and complexity is 4
.OUTPUTS
    string Password
.NOTES
    Any compexity less than 4 with characters less than 14 will not pass most password requirements.
#>
Function GET-NewPassword() { 
 
    param(
        [parameter()]
            [int]$PasswordLength = 20,
        [parameter()]
            [int]$Complexity = 4,
        [parameter()]
            [switch]$checkComplexity
    )
    #Define character set to be used
    [int32[]]$ArrayofAscii=26,97,26,65,10,48,15,33 

    Write-host "Generating new password."
    
    # Nullify the Variable holding the password 
    $NewPassword=$NULL
    
    Foreach ($counter in 1..$PasswordLength) { 
    
        # Pick a random pair (4 possible) 
        # in the array to generate out random letters / numbers 
        
        $pickSet=(GET-Random $complexity)*2 
        
        $NewPassword=$NewPassword+[char]((get-random $ArrayOfAscii[$pickset])+$ArrayOfAscii[$pickset+1]) 
    }
    
    if (($PasswordLength -gt 14) -and ($Complexity -eq 4) -and ($checkComplexity = $true)){
        $res = Assert-StringComplexity -stringToTest $NewPassword
        $loopCounter = 0
        if ($res -eq $true){
            return $NewPassword
        }else{
            if($loopCounter -ne 20){
                $loopCounter++
                GET-NewPassword -PasswordLength $PasswordLength -Complexity 4 -checkComplexity
            }else{
                Write-host $NewPassword
                throw "Password generator could not create a passing password. Please try again."
                exit
            }
        }
    }else {
        Write-host "Complexity checker was not run."
    }
    Return $NewPassword 
}
#endregion

#region Get-NewSalt
<#
.SYNOPSIS
    Creates a new salt
.DESCRIPTION
    Similarly to new-Password this script makes a random 14 character string. Unlike new-password
    this one will always do a complexity check.
.EXAMPLE
    PS C:\> Get-NewSalt
    Generates and returns a randomized string
.INPUTS
    None
.OUTPUTS
    String
.NOTES
   
#>
function Get-NewSalt { 

    param(
        [int]$PasswordLength = 14, 
        [int]$Complexity = 4
    )
 
    #Define character set to be used
    [int32[]]$ArrayofAscii=26,97,26,65,10,48,15,33 

    Write-host "Generating new password."

    # Complexity can be from 1 - 4 with the results being 
    # 1 - Pure lowercase Ascii 
    # 2 - Mix Uppercase and Lowercase Ascii 
    # 3 - Ascii Upper/Lower with Numbers 
    # 4 - Ascii Upper/Lower with Numbers and Punctuation 
    If ($Complexity -eq $NULL) { $Complexity=4 } 
    
    # Password Length can be from 1 to as Crazy as you want 
    If ($PasswordLength -eq $NULL) {$PasswordLength=20} 
    
    # Nullify the Variable holding the password 
    $NewPassword=$NULL
    
    # Here is our loop 
    Foreach ($counter in 1..$PasswordLength) { 
    
        # What we do here is pick a random pair (4 possible) 
        # in the array to generate out random letters / numbers 
        
        $pickSet=(GET-Random $complexity)*2 
        
        $NewPassword=$NewPassword+[char]((get-random $ArrayOfAscii[$pickset])+$ArrayOfAscii[$pickset+1])
        
        $res = Assert-StringComplexity -stringToTest $NewPassword
        $loopCounter = 0
        if ($res -eq $true){
            return $NewPassword
        }else{
            if($loopCounter -ne 20){
                $loopCounter++
                GET-NewPassword -PasswordLength $PasswordLength -Complexity 4 -checkComplexity
            }else{
                Write-host $NewPassword
                throw "Password generator could not create a passing password. Please try again."
                exit
            }
        }
    } 
    
    Return $NewPassword 
}
#endregion

#region Assert-StringComplexity
<#
.SYNOPSIS
    Enforces complexity of string.
.DESCRIPTION
    Runs a string through 4 checks
    Length
    Special Chars: need at least 2
    Numbers: need at least 2
    Alpha
.EXAMPLE
    PS C:\> Assert-StringComplexity -stringToTest "boB"
    returns false, boB is not long enough

.EXAMPLE
    PS C:\> Assert-StringComplexity -stringToTest "B0Bby!!00kklasldkj0234jadf"
    returns true, password is complex enough
.INPUTS
    Mandatory: string: StringToTest
    Optional: int passwordLength 
.OUTPUTS
    boolean
.NOTES
    
#>
Function Assert-StringComplexity{

    param(
        [Parameter(Mandatory=$true)]
        [string]$stringToTest,
        [int]$passwordLength = 14

    )
    #check length
    if ($stringToTest.Length -lt $passwordLength){

        throw "Password length must be at least 14 characters."
        return $false
    }
    #check for special chars
    if ($stringToTest -cnotmatch '[!@#$%^&*()_+{}|:"\][;,./<>?]{2}'){
        throw "Atleast two special Characters are required."
        return $false
    }
    #check for numerics
    if ($stringToTest -cnotmatch '[0-9]{2}'){

        throw "Atleast two numeric characters are required."
        return $false
    }
    #check for alphas
    if ($stringToTest -cnotmatch '[a-zA-Z]'){

        throw "Atleast one alpha character must be present."
        return $false
    }

    return $true

}
#endregion

#region Convert-StringToSecureString
<#
.SYNOPSIS
    Converts String to secure string
.DESCRIPTION
    Uses to ConvertTo-SecureString powershell cmdlet to convert the passed plain text file to 
    a secure string.
.EXAMPLE
    PS C:\> $ecureString = Convert-StringToSecureString -stringToConvert "BOB"
    Encrypts "BOB"
.INPUTS
    Mandatory: String: Cannot Be Null, Empty, or Whitespace: string - String to encrypt
    Optional : String: key - key to add to string encryption, you will need this to decrypt
.OUTPUTS
    Secure String 
.NOTES
    
#>
Function Convert-StringToSecureString{

    param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullEmptyOrWhitespace()]
        [string]$stringToConvert,
        [Parameter()]
        [string]$key
    )


    if ($null -eq $keyFile){
        try{
            $securedString = ConvertTo-SecureString -String $stringToConvert -ErrorAction Stop
        }catch{
            New-LogMessage @loggingArguments -errorLevel "2" -message "Could not convert string"
            New-LogMessage @loggingArguments -errorLevel "2" -message $_.exception.message
        }
    }else {
        try {
            $securedString = ConvertTo-SecureString -string $stringToConvert -SecureKey $key -ErrorAction Stop
        }
        catch {
            New-LogMessage @loggingArguments -errorLevel "2" -message "Could not convert string"
            New-LogMessage @loggingArguments -errorLevel "2" -message $_.exception.message
        }
    }
    #convert plain text passphrases to secure strings

    return $securedString
}
#endregion
#region Convert-SecureStringToString
Function Convert-SecureStringToString{
    param(
        [securestring]$stringToConvert
    )
    try{
        $unsecuredString = ConvertFrom-SecureString -SecureString $stringToConvert -errorAction Stop
    }catch{
        Write-host $_.exception.message
    }
    return $unsecuredString
}
#endregion

#endregion


Export-ModuleMember -Function Invoke-EncryptString, Invoke-DecryptString, Get-NewPassword, Get-NewSalt, Assert-StringComplexity, Convert-StringToSecureString, Convert-SecureStringToString