Function Connect-OMPrinterURL {
    <#
        .SYNOPSIS
            Starts the printer web page
        .DESCRIPTION
            Retrieves the printer configuration and launches the web page with the default browser.
        .EXAMPLE
            PS C:\> Connect-OMPrinterURL -PrinterName Printer1,Printer2

            Launches the web page for Printer1, waits for 500ms, and launches the web page for Printer2
        .EXAMPLE 
            PS C:\> Connect-OMPrinterURL -PrinterName PRINTER01 -UseThisBrowser Chrome
        .PARAMETER PrinterName
            This is the list of printers to open web pages from
        .PARAMETER DelayBetweenPrintersInMS
            This is the amount of delay between launching the printer web pages.  This gives the browser
            some time to establish the connection
        .PARAMETER SafetyThreshold
            This is the maximum number of pages the function will attempt to open.  This is a safety measure
            to prevent the browser and the system from being overwhelmed with requests to open web pages.
        .PARAMETER UseThisBrowser
            Lets the user select the browser to use to connect.  It will use the normal default browser
            if nothing is selected. 
            Currently, it has support for IE, Edge, Chrome, and FireFox.
            Specifying the browser will cause it to be launched in its privacy mode.  
            Using the 'default' setting will not trigger the privacy mode.

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
        [int]$SafetyThreshold = 10,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('IE', 'MSEdge', 'Chrome', 'FireFox', 'default')]
        [string]$UseThisBrowser = 'MSEdge'

    )

    Begin {
        $ServerRole = Get-OMServerRole
        if ($ServerRole -notmatch 'MPS|BKP') {
            throw 'The server is not an OMPlus Master Print Server'
        }

        if ($PrinterName.Count -gt $SafetyThreshold) {
            $Message = 'Only the first {0} pages will be launched; this is a measure to prevent the system from being overwhelmed' -f $SafetyThreshold
            Write-Warning -Message $Message
        }

        Write-Verbose 'Confirming if the selected browser is installed'
        switch ($UseThisBrowser) {
            'IE' {
                $ExeToUse = 'iexplore.exe -private'
            }
            'MSEdge' {
                if ( (Test-Path -Path HKLM:\SOFTWARE\Microsoft\Edge) -or 
                        (Test-Path -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Edge)
                ) {
                    $ExeToUse       = 'msedge.exe'
                    $ArgumentList   = ' -inPrivate {0}'
                }
                else {
                    Throw 'Edge does not appear to be installed, please try a different browser'
                }
            }
            'Chrome' {
                if ( (Test-Path -Path HKLM:\SOFTWARE\Google\Chrome) -or 
                        (Test-Path -Path HKLM:\SOFTWARE\Wow6432Node\Google\Chrome)
                ) {
                    $ExeToUse       = 'chrome.exe'
                    $ArgumentList   = ' -incognito {0}'
                }
                else {
                    Throw 'Chrome does not appear to be installed, please try a different browser'
                }
            }
            'FireFox' {
                if ( (Test-Path -Path HKLM:\SOFTWARE\Mozilla\FireFox) -or 
                        (Test-Path -Path HKLM:\SOFTWARE\Wow6432Node\Mozilla\Firefox) 
                ) {
                    $ExeToUse       = 'firefox.exe'
                    $ArgumentList   = '-private-window {0}'
                }
            }
            default {
                Write-Verbose -Message 'No browser selected - using the registered default browser'
                $ExeToUse       = ''
                $ArgumentList   = '{0}'
            }
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
                    $ArgumentList = $ArgumentList -f $thisConfig.URL

                    if ($UseThisBrowser -eq 'default') {
                        Start-Process -FilePath $ArgumentList    
                    } 
                    else {
                        Start-Process -FilePath  $ExeToUse -ArgumentList $ArgumentList 
                        Start-Sleep -Milliseconds $DelayBetweenPrintersinMS
                    }
                }
            }
            catch {
                Write-Warning -Message ('Unable to locate printer ({0}); skipping' -f $Printer )
                continue
            }

        }
    }
}
