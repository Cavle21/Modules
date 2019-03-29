using namespace System.Collections

class Computer {
    [String]$IPAddress
    [string]$hostName
    [STring]$macAddress
    [PSCredential]$credentials

    Computer(){}

    Computer([PSCredential]$credentials){
        $this.credentials = $credentials
    }

    ValidateCredentials(){}

    TestNetConnection(){}

    [Boolean]TestWMIConnection ($computer){

    # Send the script block
        Write-host "Sending scriptBlock to: $computer"
        Invoke-Command -ScriptBlock {Test-WSMan} -ComputerName $computer -AsJob -ThrottleLimit 60 | Out-Null

    # Retrieve the results
        Write-Host "Waiting for system to complete..."
        do {
            $running = Get-Job -State Running
            start-sleep -Seconds 1
        } While ($running)

        Get-Job | ForEach-Object {
            If ($_.State -eq "Failed") {
                Remove-Job -Job $_
                $wmsManResult =  $false
            } Else {
                Remove-Job -Job $_
                $wmsManResult =  $true
            }
        }

    return $wmsManResult
    }

    TestWinRMConnection(){}


}