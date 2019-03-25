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

    PowershellJob([ArrayList]$scriptblocks, [string]$computerName, [ArrayList]$argumentList){
        $this.scriptblock = $scriptblocks
        $this.computerName = $computerName
        $this.argumentList = $argumentList
    }

    [void]start(){

        $arguments = @{
            computerName = $this.computer
            scriptBlock = $this.scriptBlock
            argumentList = $this.argumentList
            AsJob = $true
        }

        $this.job =  Invoke-Command -ScriptBlock {Start-Job $this.job} -ComputerName $this.computerName

    }

    [void]stop(){
        
    }

    [object]pollstatus(){

        return Get-Job $this.job


    }
    
    [object]returnJobStatus(){

        return Get-Job $this.job.status

    }
}