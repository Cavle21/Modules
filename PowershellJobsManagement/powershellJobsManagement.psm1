using namespace System.Collections

class PowershellJob {

    [scriptblock]$scriptblock
    [string]$computerName

    [object]$Runningjob
    [object]$jobResult

    PowershellJob([scriptblock]$scriptblock,[string]$computerName){
        $this.scriptblock = $scriptblock
        $this.computerName = $computerName

    }

    PowershellJob([scriptblock]$scriptblock,[string]$computerName, [ArrayList]$argumentList){

        $this.scriptblock = $scriptblock
        $this.argumentList = $argumentList
        $this.computerName = $computerName

    }

    [void]start(){

        $arguments = @{
            computerName = $this.computer
            scriptBlock = $this.scriptBlock
            argumentList = $this.argumentList
            AsJob = $true
        }

        $this.job =  Invoke-Command @arguments

    }

    [void]stop(){
        
    }

    [object]pollstatus(){

        return Get-Job $this.job.status


    }
    
    [object]returnJobStatus(){

        return Get-Job $this.job.status

    }
}