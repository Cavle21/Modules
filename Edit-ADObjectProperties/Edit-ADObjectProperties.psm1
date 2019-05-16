


<#
.Synopsis
    Edits organizational unit's user permissions.
.DESCRIPTION
    using provided Organizational Unit location and users to remove this script will find and remove all matching users in the one OU
.PARAMETER arrUsersToRemove
    Mandatory: This is the collection of usernames to check for an remove from the ou you pass to the script.
.PARAMETER OULocationAndName
    Mandatory: This is the location of the OU in Active Directory
.EXAMPLE
    Edit-OUPermissions -arrusersToRemove "name", "name2" -OULocationsAndName "OU=Servers", "DC=ad", "DC=COM"
.OUTPUTS
    
.NOTES
    This is written on the assumption that powershell is not the software passing the parameters (MDT, CMD, etc). In the case of the creation of this script
    MDT does not recognize arrays as a thing. So the arguments for each of the parameters have to be passed as comma delineated strings.
#>

Function Edit-OUPermissions {

    param(
        [parameter(Mandatory = $true)]
            [string[]]$arrUsersToRemove,
        [parameter(Mandatory = $true)]
            [string[]]$OULocationAndName

    )

    #break out command delinated string into separate parts.
    $arrUsersToRemove = $arrUsersToRemove -split ',' 
    Import-Module HelperFunctions.psm1
    Import-Module ActiveDirectory

    $logDirectory = "D:\logs\Edit-OUPermissions"
    write-log -logdirectory $logDirectory -entryType information -message $arrUsersToRemove.GetType()

    try{
        New-ADOrganizationalUnit -Name "Servers"
    }catch {
        $_.exception.message
        Throw "Unable to create OU 'Servers'"
        exit
    }

    #ad: is the "Drive" of active directory objects.
    Set-Location "ad:"

    $ACLS = Get-Acl $OULocationAndName

    $originalACLS = $ACLS

    #remove user from acls that match user list.
    ForEach ($acl in $acls.Access){
        if($arrUsersToRemove.Contains($acl.identityreference.value)){
            write-log -logdirectory $logDirectory -entrytyep information -message "removing $($acl.IdentityReference.value)"; 
            $acls.RemoveAccessRule($acl)
        }
    }

    #set the acls back.
    Set-Acl -Path $OULocationAndName -AclObject $ACLS

    #check to make sure that it worked.
    $newACLS = Get-Acl $OULocationAndName
    if ($originalACLS -eq $newACLS){
        Wwrite-log -logdirectory $logDirectory -entryType Error -message "Access change for $OULocationAndName failed. No changes made at all."
        Throw "Access change for $OULocationAndName failed. No changes made at all."
    }

    ForEach ($acl in $newACLS){
        if ($arrUsersToRemove.Contains($acl.identityreference.value)){
            write-log -logdirectory $logDirectory -entryType error -message "Access change for $OULocationAndName failed. $($acl.identityreference.value) is still present."
            Throw "Access change for $OULocationAndName failed. $($acl.identityreference.value) is still present."
        }
    }

    #throw will exit script
    write-log -logdirectory $logDirectory -entryType information -message "ACL update completed successfully"
}
