Function New-RunspacePool {

    <# 
        .SYNOPSIS
            Create a new runspace pool

        .DESCRIPTION
            This function creates a new runspace pool. This is needed to be able to run code multi-threaded. A runspace pool
            holds global scope items for use in all other runspace jobs.

        .PARAMETER Functions
            An array of all functions you want accessable in the runspace pool. If not entered, they will not be available.
            An array of strings function names. NOT an array of functions.

        .PARAMETER Variables
            An array of STRINGS, NOT VARIABLES, of global variables you want global in the runspace. 
            Variables can be added later if you do not want them to be global to the entire pool.

        .EXAMPLE
            $pool = New-RunspacePool

            Description
            -----------
            Create a new runspace pool with default settings, and store it in the pool variable.

        .EXAMPLE
            $pool = New-RunspacePool -functions $functions 

            Description
            -----------
            Create a new runspace pool with functions added in and store it in the pool variable.

        .NOTES
            Make sure your function and variable arrays are filled with strings and not objects($variable). Or they will
            not get passed to the runspace. They must be declared if you want to use them in the runspace. As it runs
            in a separate thread and will not have access to this script's variables.
   
    #>

   [CmdletBinding()]
   param(
        #minimum number of concurrent threads
        [Perameter()]
        [ValidateRange(1,10)]
        [int32]$minRunspaces = 1,
        #maximum number of concurrent threads
        [Perameter()]
        [ValidateRange(1,20)]
        [int32]$maxRunspaces = 15,

        [parameter()]
            [Switch]$MTA,
        [parameter()]
            [string[]]$functions,
        [parameter()]
            [string[]]$variables

   )

   $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
   #'function:' is the namespace for all defined functions.
   if($Functions){
        foreach($func in $Functions){
            try{
                $thisFunction = Get-Item -LiteralPath "function:$func"
                [String]$functionName = $thisFunction.Name
                [ScriptBlock]$functionCode = $thisFunction.ScriptBlock
                $iss.Commands.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $functionName,$functionCode))
                Write-Verbose "Imported $func to Initial Session State"
                Remove-Variable thisFunction, functionName, functionCode
            }
            catch{
                Write-Warning $_.Exception.Message
            }
        }
    }

   if($Variables){
        $thisVariable = Get-Variable $variables
        foreach($var in $thisVariable){
            try{ 
                $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $var.Name, $var.Value, ''))
                Write-Verbose "Imported $var to Initial Session State"
            }
            catch{
                Write-Warning $_.Exception.Message
            }
        }
    }

   $runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(
        $minRunspaces, 
        $maxRunspaces, 
        $iss, 
        $Host
    )
   Write-Verbose 'Created runspace pool'

   if($MTA){
        $runspacePool.ApartmentState = 'MTA'
        Write-Verbose 'ApartmentState: MTA'
    }
    else {
        Write-Verbose 'ApartmentState: STA'
    }

    $runspacePool.Open()
    Write-Verbose 'Runspace Pool Open'
 
    # return the runspace pool object so it can be referenced elsewhere
    Return $runspacePool
}

Function New-RunspaceJob {

   <# 
        .SYNOPSIS
           Spins up new runspace to run scriptblock

        .DESCRIPTION
            When called, this function will start a new runspace (thread) that will be responsible for the script block that it is given.

        .PARAMETER jobName
            Any string name for tracking purposes.
           

        .PARAMETER Scriptblock
            Scriptblock that the user would like executed in another runspace.

        .PARAMETER Runspacepool
            The runspace pool that the runspace will be placed in.

        .PARAMETER Parameters
            The parameters that will be passed to the script block before execution.
            This is a HASHTABLE (Key,Value). Make sure that you are passing a hashtable or it will fail
            Make sure that you have a param() block in your scriptblock or the scriptblock will ignore this

        .EXAMPLE
            New-RunspaceJob -jobName 'BoB' -Scriptblock $scriptblock -runspacepool $runspacepool

            Description
            -----------
            starts a new job with name 'BoB' using the scriptblock provided and placing it in the pool 'runspacepool'
           

        .EXAMPLE
            New-RunspaceJob -jobName 'BoB2' -Scriptblock {&gpudate} -runspacepool $runspacepool

            Description
            -----------
            Starts a new job with name BoB2 in another runspace running gpupdate. Places this runspace (thread) in runspacepool

        .NOTES
            Keep track of what variables are need that were not defined with the creation of the runspacepool. Because it is running on its own
            (at this time) errors are non-terminating and will not report back to the main script.
            If you run into trouble you can close the GUI and type the following in the still open prompt:
            $runspaces.runspace.streams.error
            $runspaces is an array of all runspaces that are generated. Runspace[x].streams shows all output (info, warning, error, etc.) .error contains
            all errors.
   
    #>

   [cmdletBinding()]
   param(
   
    [parameter(Mandatory=$true)]
    [string]$jobName,

    [Parameter(Mandatory = $True)]
    [Scriptblock]$Scriptblock,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,

    [Parameter()]
    [HashTable]$Parameters
   
   )

   $global:runspaceCounter++

   $runspace = [Powershell]::Create()
   $runspace.RunspacePool = $RunspacePool

   $runspace.Addscript($Scriptblock) | Out-null

   if ($Parameters){
        forEach ($parameter in ($parameters.GetEnumerator())){
            $runspace.AddParameter("$($parameter.Key)", $parameter.Value) | Out-Null
        }
   }
   Write-log "Runspace made with Name $jobName and ID $global:runspaceCounter"
    [void]$runspaces.Add(@{
        JobName = $JobName
        InvokeHandle = $runspace.BeginInvoke()
        Runspace = $runspace
        ID = $global:runspaceCounter
    })
}

function Clear-RunspaceJobs {
    Remove-Variable -Name 'Runspaces' -Scope 'Global'
}