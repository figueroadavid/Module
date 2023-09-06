function Send-OMTestPage {
    <#
        .SYNOPSIS
        Send a test print job to an OMPlus printer

        .DESCRIPTION
        Uses the native dcclp.exe command to send the configuration file to the printer.
        This is exactly the same as the GUI 'Test Page' command.

        .PARAMETER PrinterName
        The name of the printer(s) to send a test page.

        .PARAMETER ShowOutput
        If this switch is provided the text output of the dcclp command is also displayed.

        .EXAMPLE
        PS C:\> Send-OMTestPage -PrinterName BT-9-98,BT-9-99

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
        [switch]$ShowOutput
    )

    $ServerRole = Get-OMServerRole 
    switch ($ServerRole) {
        'MPS' {
            $DCCLPPath = [system.io.path]::Combine($env:omhome, 'bin', 'dcclp.exe')        }
        'TRN'  {
            $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'receiveHosts'))
            $Message = 'On Transform server, test prints should only be sent on the primary MPS: {0}' -f $PrimaryMPS
            Write-Warning -Message $Message 
            return 
        }
        'BKP' {
            $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'pingMaster'))
            Write-Warning -Message 'On the secondary MPS server, test prints should only be sent on the primary MPS: {0}' -f $PrimaryMPS
            return 
        }
        default {
            Write-Warning -Message 'Not on an OMPlus server'
            return 
        }
    }

    foreach ($Printer in $PrinterName) {

        $Printer = Get-OMCaseSensitivePrinterName -PrinterName $Printer
        $PrintConfigPath = [system.io.path]::combine($env:omhome, 'printers', $Printer, 'configuration')
        try {
            $null = Test-Path -Path $PrintConfigPath -ErrorAction Stop
        }
        catch {
            $Message = ('Unable to send print job to ({0}), the configuration file ({1}) appears to be missing; skipping this printer' -f $Printer, $PrintConfigPath)
            Write-Warning -Message $Message
            continue
        }


        Write-Verbose -Message ('Sending test job to {0}' -f $Printer )
        $ProcStartInfo                          = New-Object -TypeName System.Diagnostics.ProcessStartInfo
        $ProcStartInfo.CreateNoWindow           = $true
        $ProcStartInfo.RedirectStandardError    = $true
        $ProcStartInfo.RedirectStandardOutput   = $true
        $ProcStartInfo.FileName                 = $DCCLPPath
        $ProcStartInfo.Arguments                = '-d {0} {1}' -f $Printer, $PrintConfigPath
        $ProcStartInfo.Verb                     = 'runas'
		$ProcStartInfo.UseShellExecute          = $false
        $Process                                = New-Object -TypeName System.Diagnostics.Process
        $Process.StartInfo                      = $ProcStartInfo
        
        $null = $Process.Start()
        $Process.WaitForExit()
        $ExitCode                               = $Process.ExitCode
        
        $Result = $Process.StandardOutput.ReadToEnd()

        if ($ShowOutput) {
            $Result
        }

		if ($ExitCode -eq 0 ) {
            Write-Verbose -Message ('Successfully sent test page to ({0})' -f $Printer)
		}
        else {
            Write-Warning -Message ('Test Print sent to ({0}) does not appear to be successful, please verify' -f $Printer)
        }
    }
}
