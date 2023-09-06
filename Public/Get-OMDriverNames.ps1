function Get-OMDriverNames {
    <#
    .SYNOPSIS
        Returns the list of valid drivers for OMPlus
    .DESCRIPTION
        Reads in the om_eps_win_queues.csv and returns the list of valid drivers for OMPlus
    .EXAMPLE
        PS C:\> Get-OMDriverList
        Name                           Value
        ----                           -----
        DellOPDPCL5                    Dell Open Print Driver (PCL 5)
        HPUPD5                         HP Universal Printing PCL 5
        HPUPD6                         HP Universal Printing PCL 6
        LexUPDv2                       Lexmark Universal v2
        HPUPDPS7                       HP Universal Printing PS (v7.0.0)
    .EXAMPLE 
        PS C:\> Get-OMDriverList -Sorted 
        Name                           Value
        ----                           -----
        DellOPDPCL5                    Dell Open Print Driver (PCL 5)
        HPUPD5                         HP Universal Printing PCL 5
        HPUPD6                         HP Universal Printing PCL 6
        HPUPDPS7                       HP Universal Printing PS (v7.0.0)
        LexUPDv2                       Lexmark Universal v2
    .PARAMETER Sorted
        This causes the script to sort the drivernames by name
    .PARAMETER GetTimeStamp
        This causes the script to add the timestamp to the results
    
    .INPUTS
        [none]
    .OUTPUTS
        [none]
    .NOTES
        Retrieves the list of drivernames from the system.  The name is the configuration used
        in the eps_map, and the value is the actual Windows driver used on the Transform servers.
        This function does not work on the Secondary MPS server; it only works on the Primary MPS
        or the Transform servers.
    #>
    [cmdletbinding()] 
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$Sorted,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$GetTimeStamp 
    )

    $ServerRole = Get-OMServerRole 
    switch ($ServerRole) {
        'MPS' {
            $OMQueueCSVPath = [system.io.path]::combine($env:OMHome,'system', 'OM_EPS_WIN_Queues.csv')
        }
        'TRN'  {
            $OMQueueCSVPath = [system.io.path]::combine($env:OMHome,'constants', 'OM_EPS_WIN_Queues.csv')
        }
        'BKP' {
            Write-Warning -Message 'On the secondary MPS server, this list is not available'
            return 
        }
        default {
            Write-Warning -Message 'Not on an OMPlus server'
            return 
        }
    }

    $Contents = Get-Content -path $OMQueuePath

    if ($GetTimeStamp) {
        $UnixTimeStamp  = $Contents | Where-Object { $_ -notmatch ','} | Select-Object -First 1
        $TimeStamp      = [DateTimeOffset]::FromUnixTimeSeconds($TimeStamp)
    }

    $Results = $Contents.Where{ $_ -match ',' }.Replace(',', '=') |
        ConvertFrom-StringData

    if ($GetTimeStamp) {
        $Results['TimeStamp'] = $TimeStamp
    }


    if ($Sorted) {
        $Results = $Results.GetEnumerator() | Sort-Object -Property Keys 
    }
    else {
        $Results
    }
}
