using namespace System.Collections



class PowershellJob {

    [scriptblock]$scriptblock
    [string]$computerName

    [object]$Runningjob
    [object]$jobResult
    [boolean]$asyncJobs

    PowershellJob([scriptblock]$scriptblock,[string]$computerName,[boolean]$asyncJobs){
        $this.scriptblocks = $scriptblock
        $this.computerName = $computerName
        $this.asyncJobs = $asyncJobs

    }

    PowershellJob([scriptblock]$scriptblock,[string]$computerName, [ArrayList]$argumentList,[boolean]$asyncJobs){

        $this.scriptblocks = $scriptblock
        $this.argumentList = $argumentList
        $this.computerName = $computerName
        $this.asyncJobs = $asyncJobs

    }

    <#PowershellJob([ArrayList]$scriptblocks, [string]$computerName, [ArrayList]$argumentList,[boolean]$asyncJobs){
        $this.scriptblock = $scriptblocks
        $this.computerName = $computerName
        $this.argumentList = $argumentList
        $this.asyncJobs = $asyncJobs
    }#>

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

    [object]pollstatus(){

        return Get-Job $this.job


    }
    
    [object]returnJobStatus(){

        return Get-Job $this.job.status

    }
}