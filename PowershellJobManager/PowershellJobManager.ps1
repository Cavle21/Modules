using namespace System.Collections
using module PowershellJobsManagement\PowershellJobsManagement.psm1

class PowershellJobManager {

    [ArrayList]$RegisteredJobs

    PowershellJobManager(){}

    [void]StartAll(){
        
    }

    [void]StopAll(){

    }

    RegisterJob($ScriptBlock, $computerName){

        $job = [PowershellJob]::New($scriptBlock, $computerName)
        #build job object to pass to jobClass
    }

    UnregisterJob(){
        #remove jobs that have been generated
    }

    RecieveAllJobStatus(){
        #poll all jobs and return their status
    }
    
}