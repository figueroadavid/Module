function Get-OMJobCountByStatus {
    <#
    .SYNOPSIS
        Provides the current status counts for the current server
    .DESCRIPTION
        Uses dccgrp.exe to get the list of jobs in each requested status and presents the list of statuses.
    .EXAMPLE
        PS C:\> Get-OMJobCountByStatus -Status all
        Name                           Value
        ----                           -----
        2big                           0
        2dumb                          0
        active                         0
        can                            0
        Change Password                0
        cmplt                          0
        faild                          0
        faxed                          0
        fpend                          0
        held                           0
        intrd                          0
        malid                          0
        partl                          0
        prntd                          96
        proc                           0
        ready                          15
        sent                           0
        spool                          0
        susp                           0
        timed                          0
        xfer                           0
    .INPUTS
        [string]
    .OUTPUTS
        [hashtable]
    .NOTES
        The 'proc' category rarely has anything over 0 and jobs that appear hung in the GUI will not show up
        in the proc count here.
    .PARAMETER Status
        This is the list of statuses you can check.
            all,    active,     can,    cmplt,  faild,  faxed,
            fpend,  held,       intrd,  malid,  partl,  prntd,
            proc,   ready,      sent,   spool,  susp,   timed,
            Change Password,    xfer,   2big,   2dumb
    .PARAMETER Sorted
        Sorts the returned list alphabetically
    #>

    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('all', 'active', 'can', 'cmplt', 'faild', 'faxed',
                     'fpend', 'held', 'intrd', 'malid', 'partl', 'prntd',
                     'proc', 'ready', 'sent', 'spool', 'susp', 'timed',
                     'Change Password', 'xfer', '2big', '2dumb', '*'
                     )]
        [String[]]$Status = 'intrd',

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$Sorted
    )

    $Return = @{}
    if ($Status -eq 'All' -or $Status -eq '*') {
        $Status = 'active', 'can', 'cmplt', 'faild', 'faxed',
        'fpend', 'held', 'intrd', 'malid', 'partl', 'prntd',
        'proc', 'ready', 'sent', 'spool', 'susp', 'timed',
        'Change Password', 'xfer', '2big', '2dumb'
    }

    $DCCGrpPath     = [io.path]::Combine($env:OMHOME, 'bin', 'dccgrp.exe')

    foreach ($state in $Status ) {
        Write-Verbose -message ('Processing list for ({0})' -f $state)
        $thisCount      = (& $DCCGrpPath list status=$state | Where-Object { $_ -notmatch 'No requests'}).count
        $Return.Add($state, $thisCount)
    }

    if ($Sorted) {
        $Return.GetEnumerator() | Sort-Object -Property Name
    }
    else {
        $Return
    }
}
