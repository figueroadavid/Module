Function Enable-OMPrinter {
    <#
    .SYNOPSIS
        Enables a previously disabled printer in OMPlus
    .DESCRIPTION
        Uses dccenable.exe to enable a previously disable printer in OMPlus
    .EXAMPLE
        PS C:\> Enable-OMPrinter -PrinterName PRINTER01

        Enables PRINTER01
    .PARAMETER PrinterName
        The list of printers to enable
    .PARAMETER IntervalInMS
        The delay between enabling printers to keep the CPU usage reasonably low.
        It can range from 100ms up to 10000ms, and is defaulted to 500ms.
    .PARAMETER ShowProgress
        A switch to show the progress of the command
    .INPUTS
        [string]
    .OUTPUTS
        [none]
    .NOTES

    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMPrinterList -Filter * |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('PrinterName: {0}' -f $_ )
                    )
                }
        })]
        [string[]]$PrinterName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(100,10000)]
        [int]$IntervalInMS = 500,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowProgress
    )

    begin {
        $PrinterList = Get-OMPrinterList
        if ($ShowProgress) {
            $PrinterNameCount = $PrinterName.Count
            $CurrentCount = 0
        }
        $DCCEnable = [io.path]::combine( $env:OMHOME, 'bin','dccenable.exe' )
    }

    process {
        foreach ($printer in $PrinterName) {
            if ($ShowProgress) {
                $CurrentCount ++
                $ProgSplat = @{
                    Activity        = 'Enabling {0}' -f $Printer
                    status          = '{0} of {1}' -f $CurrentCounter, $PrinterNameCount
                    PercentComplete = [math]::Round( $CurrentCount/$PrinterNameCount * 100, [MidpointRounding]::AwayFromZero)
                }
                Write-Progress @ProgSplat
            }
            if ($Printer -in $PrinterList) {
                $ProcSplat = @{
                    FilePath        = $DCCEnable
                    ArgumentList    = '-d {0}' -f $Printer
                    Wait            = $true
                    WindowStyle     = 'Hidden'
                }
                Start-Process @ProcSplat -Verb RunAs
            }
            else {
                $Message = 'Printer: {0} is not a valid printer for this system; skipping' -f $Printer
                Write-Warning -Message $Message
                continue
            }
            $Message = 'Pausing the loop for ({0}) milliseconds' -f $IntervalInMS
            Write-Verbose -Message $Message
            Start-Sleep -Milliseconds $IntervalInMS
        }
    }
}
