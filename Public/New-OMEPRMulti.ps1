Function New-OMEPRMulti {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [ValidateScript({
            if ($_ -match '^(\w+\.){1,}\w+\.\w+$') {
                Write-Verbose -Message ('{0} appears to be a valid FQDN' -f $_)
            }
            else {
                throw ('{0} appears to be an invalid FQDN; please verify your records when complete' -f $_)
            }
            $true
        })]
        [string]$ServerName = ([net.dns]::GetHostByName($env:computername).hostname),

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('OMQueueName', 'PrinterName')]
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
                        ('Printer Name: {0}' -f $_ )
                    )
                }
        })]
        [string]$Destination,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,5)]
        [int]$TrayCount = 0,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                (Get-OMDriverNames).Keys |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('Driver Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$DriverName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
        [string]$DuplexOption = 'None',

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType PaperSizes   | Select-object -ExpandProperty 'PaperSizeRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('Tray Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$PaperSize = 'Letter',

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType MediaType   | Select-object -ExpandProperty 'MediaTypeRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('Tray Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$MediaType = 'None',

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$HasRXTray,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$Append
    )

    Begin {
        $Destination = Get-OMCaseSensitivePrinterName -PrinterName $Destination
    }

    Process {
        if ($TrayCount -eq 0) {
            $EPRSplat = @{
                'ServerName'    = $ServerName
                'EPRQueue'      = $Destination
                'OMQueue'       = $Destination
                'DriverName'    = $DriverName
            }
            $RecordSet = @(New-OMEPRRecord @EPRSplat)
        }
        else {
            $RecordSet = for ($i = 1; $i -le $TrayCount; $i++) {
                $EPRSplat = @{
                    'ServerName'    = $ServerName
                    'OMQueue'       = $Destination
                    'DriverName'    = $DriverName
                    'PaperSize'     = $PaperSize
                    'DuplexOption'  = $DuplexOption
                    'MediaType'     = $MediaType
                    'TrayName'      = 'Tray $i'
                }
                switch ($i) {
                    1 { $TrayExtension = ''}
                    default { $TrayExtension = '-T{0}' -f $i}
                }
                if ($HasRXTray -and $i -eq $TrayCount) {
                    $TrayExtension = '-RX'
                }
                $EPRSplat.Add('EPRQueue', ('{0}{1}' -f $Destination, $TrayExtension))
                New-OMEPRRecord @EPRSplat
                $EPRSplat.Clear()
            }
        }
    }

    End {
        $Message = 'Would create these records:{0}{1}' -f [System.Environment]::NewLine, $RecordSet
        if ($PSCmdlet.ShouldProcess($Message, '', '')) {
            if ($Append) {
                $EPSPath = '{0}\eps_map' -f $script:OMSystem
                try {
                    Add-Content -Path $EPSPath -Value $RecordSet -ErrorAction Stop
                    Update-OMTransformServer
                }
                catch {
                    Write-Warning -Message ('Unable to update {0}; please investigate' -f $EPSPath)
                }
            }
            else {
                $RecordSet
            }
        }
    }
}
