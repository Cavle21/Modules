class EventHandler {

    RegisterEvent([string]$sourceIdentifier){
        Register-EngineEvent -SourceIdentifier $sourceIdentifier -Action {
            Write-host $_.messageData
        }
    }

    NewEvent ([string]$sourceIdentifier, [string]$messageData, [string]$sendingObjectName){
        New-Event -SourceIdentifier $sourceIdentifier -Sender $sendingObjectName -MessageData $messageData
    }

    ListEvents (){
        Write-host Get-Event | Select-Object SourceIdentifier, MessageData, SendingObject
    }

    RegisterForwardingEvent([string]$sourceIdentifier){
        Register-EngineEvent -SourceIdentifier $sourceIdentifier -Forward
    }

}