using namespace System.Collections
using namespace System.Management.Automation
using module ..\ComputerObject.psm1 

class PowershellJob {

    [scriptblock]$currentscriptblock
    [Computer]$computer
    [Job]$Runningjob
    [object]$jobResult
    [boolean]$asyncJobs
    [Queue]$scriptBlockQueue

    PowershellJob([scriptblock]$scriptblock,[Computer]$computer,[boolean]$asyncJobs){
        $this.scriptBlockQueue.Enqueue($scriptblock)
        $this.computer = $computer
        $this.asyncJobs = $asyncJobs

    }

    PowershellJob([scriptblock]$scriptblock,[computer]$computer, [ArrayList]$argumentList,[boolean]$asyncJobs){

        $this.scriptBlockQueue.Enqueue($scriptblock)
        $this.argumentList = $argumentList
        $this.computer = $computer
        $this.asyncJobs = $asyncJobs

    }

    PowershellJob([ArrayList]$scriptblocks, [computer]$computer, [ArrayList]$argumentList,[boolean]$asyncJobs){
        ForEach ($scriptBlock in $scriptBlocks){
            $this.scriptBlockQueue.Enqueue($scriptBlock)
        }

        $this.computer = $computer
        $this.argumentList = $argumentList
        $this.asyncJobs = $asyncJobs
    }

    [void]start(){

        $arguments = @{
            computer = $this.computer.hostName
            argumentList = $this.argumentList
            AsJob = $this.asyncJobs
        }

        
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

    [void]ContinueWith (){}
}