function  Remove-OMPrinter {
    <#
    .SYNOPSIS
        Remove a printer from OMPlus
    .DESCRIPTION
        Uses lpadmin to remove a print destination
    .EXAMPLE
        PS C:\> Remove-OMPrinter -PrinterName Printer1

        Deletes the printer destination from OMPlus
    .EXAMPLE
        PS C:\> Remove-OMPrinter -PrinterName Printer2, Printer 3

        Deletes both printers from OMPlus
    .PARAMETER PrinterName
        This is the name of the printer(s) to remove

    .PARAMETER DelayBetweenPrintersInSeconds
        This is an "invisible" parameter to delay the commands between removing printers

    .INPUTS
        [string]
        [int]
    .OUTPUTS
        [string]
    .NOTES
        Uses the -x option of LPAdmin to remove the print destination.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMPrinterList -filter * |
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

        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [ValidateScript({
            $_ -ge 2
        })]
        [int]$DelayBetweenPrintersInSeconds = 3
    )

    Begin {
        $ExePath = [io.path]::Combine($env:OMHOME, 'bin', 'lpadmin.exe')
    }

    Process {
        foreach ($Printer in $PrinterName) {
            $Printer = Get-OMCaseSensitivePrinterName -PrinterName $Printer
            $Arguments = '-x {0}' -f $Printer
            if ($PSCmdlet.ShouldProcess(('Remove printer {0}' -f $Printer), '', '')) {
                Start-Process -FilePath $ExePath -ArgumentList $Arguments -Wait -WindowStyle Hidden
                if ($IsPrimaryMPS) {
                    Write-Warning -Message ('Do not forget to Remove the EPRs associated with {0}' -f $Printer)
                }
            }
            Start-Sleep -Seconds $DelayBetweenPrintersInSeconds
        }
    }
}
