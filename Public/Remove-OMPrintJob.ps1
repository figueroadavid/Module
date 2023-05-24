Function Remove-OMPrintJob {
    <#
    .SYNOPSIS
        Removes print jobs from the OMPlus queues
    .DESCRIPTION
        This script has 4 modes of operation
        1. Cancel the job using teh Using the RID number(s) of the job(s)
        2. Cancel jobs using a 'dccgrp cancel time=__m' to  cancel the jobs older than a specified amount of time
        3. Cancel jobs by resetting the specified printer, and the user is warned that the printer will need to be re-enabled
        4. Cancel jobs based on their status; it is restricted to 'can','intrd','activ' jobs

    .EXAMPLE
        PS C:\> Remove-OMPrintJob -RIDNumber 81000,RID23489,23765,RID81652,364

        This cancels the jobs with the RID numbers of 81000, 23489, 23765, 81652, 00364.  If the job supplied is a 5 digit number, then
        the characters 'RID' are automatically prepended, along with enough 0's to pad the number out to 5 characters.
    .EXAMPLE
        PS C:\> Remove-OMPrintJob -JobAgeInMinutes 30

        This cancels any jobs older than 30 minutes

    .EXAMPLE
        PS C:\> Remove-OMPrintJob -ByPrinter LB-100-100,BT-10-10
        Don't forget to re-enable this printer: LB-100-100
        Don't forget to re-enable this printer: BT-10-10

        This resets both printers (LB-100-100 & BT-10-10) and prints the warning to remember to re-enable it.
        This command is only usable on the Master Print Server.

    .EXAMPLE
        PS C:\> Remove-OMPrintJob -ByStatus intrd

        This cancels all the jobs in an 'intrd' status

    .PARAMETER RIDNumber
        This is the RID number(s) of the print job(s) to cancel; the tag 'RID' can be included or skipped.
        If the RID tag is used, the number must be 5 digits long.  If it is not 5 digits, and the 'RID' tag
        is not used, then the number is padded with leading 0's and RID

    .PARAMETER JobAgeInMinutes
        Print jobs older than this amount of time are cancelled.

    .PARAMETER PrinterName
        This is the name of the printer(s) to cancel jobs on.
        The user is warned to re-enable the printer.  If the user accidentally supplies lower case letters,
        the name is converted to upper case.

    .PARAMETER Status
        This is the status names to cancel jobs for.  It accepts 'can', 'intrd', and 'activ' as valid statuses to
        cancel.

    .PARAMETER ResetSNMP
        (Usable with PrinterName only)
        This switch is used to reset the SNMP flags for a printer (-s)

    .PARAMETER ResetLock
        (Usable with PrinterName only)
        This switch is used to reset the lock flags for a printer (-l)

    .PARAMETER ResetToInactive
        (Usable with PrinterName only)
        This switch is used to reset the printer to an Inactive state and stop any active request (-a)

    .PARAMETER ResetActive
        (Usable with PrinterName only)
        This switch causes the currently active request on a printer to go to an intrd state (-r)

    .PARAMETER ImmediatePurge
        (Usable with RIDNumber only)
        Tells the system to cancel the job, and then purge it immediately without waiting (-k)
    .INPUTS
        [string]
        [int]
    .OUTPUTS
        [none]
    .NOTES
        This is a general wrapper script that invokes the correct command to cancel the job based on parameter chosen.
        It uses dccgrp to cancel by time or by status, and it uses dccreset to cancel jobs by RID, and lastly it uses
        dcccancel to reset jobs by printer name.

    #>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'byAge')]
    param(
        [parameter(Mandatory, ParameterSetName = 'byRID')]
        [string[]]$RIDNumber,

        [parameter(Mandatory, ParameterSetName = 'byAge')]
        [int]$JobAgeInMinutes,

        [parameter(Mandatory, ParameterSetName = 'byPrinter')]
        [string[]]$PrinterName,

        [parameter(Mandatory, ParameterSetName = 'byStatus')]
        [ValidateSet('can','intrd','activ')]
        [string]$Status,

        [parameter(ParameterSetName = 'byPrinter')]
        [switch]$ResetSNMP,

        [parameter(ParameterSetName = 'byPrinter')]
        [switch]$ResetLock,

        [parameter(ParameterSetName = 'byPrinter')]
        [switch]$ResetToInactive,

        [parameter(ParameterSetName = 'byPrinter')]
        [switch]$ResetActive,

        [parameter(ParameterSetName = 'byRID')]
        [switch]$ImmediatePurge
    )

    begin {
        $dccResetPath   = [system.io.path]::Combine($BinPath, 'dccreset.exe')
        $dccCancelPath  = [system.io.path]::Combine($BinPath, 'dcccancel.exe')
        $dccGrpPath     = [system.io.path]::Combine($BinPath, 'dccgrp.exe')
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'byRID' {
                foreach ($Job in $RIDNumber) {
                    if ($Job -match '^\d{1,5}$' -or $Job -cmatch '^RID\d{5}$') {
                        if ($Job -match '^\d{1,5}$') {

                            $thisJob = 'RID{0:00000}' -f $Job
                        }
                        else {
                            $thisJob = $Job
                        }
                        if ($PSCmdlet.ShouldProcess('Cancel job {0}' -f $Job), '', '') {
                            $ProcSplat = @{
                                FilePath        = $dccCancelPath
                                WindowStyle     = 'Hidden'
                                Wait            = $true
                            }
                            if ($ImmediatePurge) {
                                $ProcSplat['ArgumentList'] = ' -i {0} -k' -f $thisJob
                            }
                            else {
                                $ProcSplat['ArgumentList'] = ' -i {0}' -f $thisJob
                            }

                            Start-Process @ProcSplat -verb RunAs
                        }
                    }
                    else {
                        $Message = 'The supplied job name ({0}) is does not match the correct format of 5 digits, or RIDxxxxx; skipping this job' -f $Job
                        Write-Warning -Message $Message
                    }
                }
                break
            }

            'byAge' {
                if ($PSCmdlet.ShouldProcess(('Cancel jobs older than {0} minutes' -f $JobAgeInMinutes), '', '')) {
                    $ProcSplat = @{
                        FilePath        = $dccGrpPath
                        ArgumentList    = 'cancel time={0}m' -f $JobAgeInMinutes
                        WindowStyle     = 'Hidden'
                        Verb            = 'RunAs'
                        Wait            = $true
                    }
                    Start-Process @ProcSplat
                }
            }

            'byPrinter' {
                if ($PSCmdlet.ShouldProcess(('Resetting printer {0}' -f $PrinterName), '', '')) {
                    foreach ($Printer in $PrinterName) {
                        $ProcSplat = @{
                            FilePath        = $dccResetPath
                            WindowStyle     = 'Hidden'
                            Wait            = $true
                        }
                        if ($ResetSNMP -or $ResetLock -or $ResetToInactive -or $ResetActive ) {
                            $SwitchList = New-Object -TypeName System.Collections.Generic.List[char]
                            if ($ResetSNMP)         { $SwitchList.Add('s')}
                            if ($ResetLock)         { $SwitchList.Add('l')}
                            if ($ResetToInactive)   { $SwitchList.Add('a')}
                            if ($ResetActive)       { $SwitchList.Add('r')}
                            $ProcSplat['ArgumentList'] = '-d {0} -{1}' -f ($SwitchList -join '')
                        }
                        else {
                            $ProcSplat['ArgumentList'] = '-d {0}' -f $Printer.ToUpper()
                        }
                        Start-Process @ProcSplat -Verb RunAs
                        Write-Warning -Message ("Don't forget to re-enable this printer: {0}" -f $PrinterName)
                    }
                }
            }

            'byStatus' {
                if ($PSCmdlet.ShouldProcess('Cancel job by status: {0}' -f $Status), '', '') {
                    $ProcSplat = @{
                        FilePath        = $dccGrpPath
                        ArgumentList    = 'cancel status={0}' -f $Status
                        WindowStyle     = 'Hidden'
                        Wait            = $true
                    }
                    Start-Process @ProcSplat -verb RunAs
                }
            }
        }
    }
}
