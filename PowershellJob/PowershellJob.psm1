using namespace System.Collections

class PowershellJob {

    [scriptblock]$currentscriptblock
    [string]$computerName

    [object]$Runningjob
    [object]$jobResult
    [boolean]$asyncJobs
    [Queue]$scriptBlockQueue

    PowershellJob([scriptblock]$scriptblock,[string]$computerName,[boolean]$asyncJobs){
        $this.scriptBlockQueue.Enqueue($scriptblock)
        $this.computerName = $computerName
        $this.asyncJobs = $asyncJobs

    }

    PowershellJob([scriptblock]$scriptblock,[string]$computerName, [ArrayList]$argumentList,[boolean]$asyncJobs){

        $this.scriptBlockQueue.Enqueue($scriptblock)
        $this.argumentList = $argumentList
        $this.computerName = $computerName
        $this.asyncJobs = $asyncJobs

    }

    PowershellJob([ArrayList]$scriptblocks, [string]$computerName, [ArrayList]$argumentList,[boolean]$asyncJobs){
        ForEach ($scriptBlock in $scriptBlocks){
            $this.scriptBlockQueue.Enqueue($scriptBlock)
        }

        $this.computerName = $computerName
        $this.argumentList = $argumentList
        $this.asyncJobs = $asyncJobs
    }

    [void]start(){

        $arguments = @{
            computerName = $this.computer
            argumentList = $this.argumentList
            AsJob = $this.asyncJobs
        }

        $this.job =  Invoke-Command -ScriptBlock {Start-Job $using:scriptBlock} @arguments
    }

    [void]stop(){
        
    }

    [object]pollCurrentJob(){
        return $this.scriptBlockQueue.Peek()
    }

    [object]pollstatus(){

        return Get-Job $this.job
    }
    
    [object]returnJobStatus(){

        return Get-Job $this.job.status

    }
}