Function Connect-OMPrinterURL {
    <#
        .SYNOPSIS
            Starts the printer web page
        .DESCRIPTION
            Retrieves the printer configuration and launches the web page with the default browser.
        .EXAMPLE
            PS C:\> Connect-OMPrinterURL -PrinterName Printer1,Printer2

            Launches the web page for Printer1, waits for 500ms, and launches the web page for Printer2
        .PARAMETER PrinterName
            This is the list of printers to open web pages from
        .PARAMETER DelayBetweenPrintersInMS
            This is the amount of delay between launching the printer web pages.  This gives the browser
            some time to establish the connection
        .PARAMETER SafetyThreshold
            This is the maximum number of pages the function will attempt to open.  This is a safety measure
            to prevent the browser and the system from being overwhelmed with requests to open web pages.
        .INPUTS
            [string]
            [int]
        .OUTPUTS
            [none]
        .NOTES
            This reads in the configuration for the printers and gets the URL, and then uses
            Start-Process to launch the web page, with a configurable delay between each printer.
    #>
    [cmdletbinding()]
param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMPrinterList |
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
        [int]$DelayBetweenPrintersinMS = 500,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$SafetyThreshold = 10

    )

    Begin {
        if ($PrinterName.Count -gt $SafetyThreshold) {
            $Message = 'Only the first {0} pages will be launched; this is a measure to prevent the system from being overwhelmed' -f $SafetyThreshold
            Write-Warning -Message $Message
        }
    }
    process {
        $CurrentCounter = 0
        foreach ($Printer in $PrinterName) {
            $Printer = Get-OMCaseSensitivePrinterName -PrinterName $Printer 
            $CurrentCounter ++
            if ($CurrentCounter -gt $SafetyThreshold) {
                return
            }
            try {
                $thisConfig = Get-OMPrinterConfiguration -PrinterName $Printer -Property URL -ErrorAction Stop
                if ($thisConfig.URL -match 'none' -or 
                        [string]::IsNullOrEmpty($thisConfig.URL) -or 
                        [string]::IsNullOrWhiteSpace($thisConfig.URL) 
                    ) {
                    Write-Warning -Message ('This printer ({0}) does not appear to have a web page defined' -f $Printer)
                    continue
                }
                else {
                    Start-Process -FilePath $thisConfig.URL
                    Start-Sleep -Milliseconds $DelayBetweenPrintersinMS
                }
            }
            catch {
                Write-Warning -Message ('Unable to locate printer ({0}); skipping' -f $Printer )
                continue
            }

        }
    }
}
