using namespace System.Collections
using namespace System.Management.Automation

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
        return $true
    }

    TestWinRMConnection(){}


}