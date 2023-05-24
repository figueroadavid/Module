Function Update-OMEPR {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [string]$ServerName = $([Net.Dns]::GetHostByName($env:computername) |
            Select-Object -ExpandProperty HostName  ),

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('EPR')]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                $(Get-OMEPSMap).EPR |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('Queue: {0}' -f $_ )
                    )
                }
        })]
        [string]$Queue,

        [parameter(ValueFromPipelineByPropertyName)]
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
                        ('Destination: {0}' -f $_ )
                    )
                }
        })]
        [string]$Destination,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMDriverNames | Select-object -ExpandProperty 'Driver' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('DriverName: {0}' -f $_ )
                    )
                }
        })]
        [string]$DriverName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType Trays   | Select-object -ExpandProperty 'TrayRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('TrayName: {0}' -f $_ )
                    )
                }
        })]
        [string]$TrayName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
        [string]$DuplexOption,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType MediaType   | Select-object -ExpandProperty 'PaperSizeRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('PaperSize: {0}' -f $_ )
                    )
                }
        })]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('n','y')]
        [string]$IsRX = 'n',

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
                        ('MediaType: {0}' -f $_ )
                    )
                }
        })]
        [string]$MediaType,

        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [switch]$Override,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$DoNotBackup
    )

    Begin {
        if ($PSBoundParameters.ContainsKey('Destination') -or
            $PSBoundParameters.ContainsKey('DriverName') -or 
            $PSBoundParameters.ContainsKey('TrayName') -or
            $PSBoundParameters.ContainsKey('DuplexOption') -or
            $PSBoundParameters.ContainsKey('PaperSize') -or
            $PSBoundParameters.ContainsKey('IsRX') -or
            $PSBoundParameters.ContainsKey('MediaType') -or
            $PSBoundParameters.ContainsKey('Servername') ) {
            Write-Verbose -Message '$PSBoundParameters contains one of the update values'
        }
        else {
            throw 'No update parameters provided, nothing to do!'
        }

        if ($DoNotBackup) {
            Write-Verbose -Message 'No backup taken intentionally'
        }
        else {
            if (New-OMEPSMapBackup) {
                Write-Verbose -Message 'Successful backup of eps_map taken'
            }
            else {
                if ($Override) {
                    Write-Warning -Message 'Override specified; proceeding even without a good backup'
                }
                else {
                    throw 'Unable to backup eps_map file; unable to continue'
                }
            }
        }
        $EPSMap               = Get-OMEPSMap
        $breakHere = $true 
        $RegExQueueName       = '^{0}$' -f [regex]::escape($Queue)
    }

    process {
        $MatchingEPR          = $EPSMap.epsmap.Where{ $_.EPR -match $RegExQueueName}

        switch ($MatchingEPR.Count) {
            0 { throw ('No matching records for queue {0}' -f $Queue); break }
            1 { 
                Write-Verbose -Message ('Found record for queue {0}' -f $Queue)
                $MatchingEPR = $MatchingEPR[0]
                break
            }
            default { 
                $Message = 'Multiple records found for queue {0}, please correct this and try again{1}{2}' -f $Queue, [environment]::newline, $MatchingEPR
                throw $Message 
            }
        }        
        
        if ($DriverName) {
            Write-Verbose -Message ('Using the new DriverName {0} to get driver data (trays, paper sizes, media)' -f $DriverName)
            $thisDriver = $DriverName
            $MatchingEPR.Driver = $DriverName
        }
        else {
            Write-Verbose -Message 'The driver name {0} has not been supplied, using the existing drivername {1}' -f $DriverName, $MatchingEPR.Driver 
            $thisDriver = $MatchingEPR.Driver
        }
        $TrayTable      = Get-OMTypeTable -DriverType $thisDriver -Display Trays
        $PaperSizeTable = Get-OMTypeTable -DriverType $thisDriver -Display PaperSizes
        $MediaTypeTable = Get-OMTypeTable -DriverType $thisDriver -Display MediaTypes  

        if ($Destination)   {
            $MatchingEPR.Destination  = $Destination
        }
        if ($TrayName -and -not $NoValidTrays)      {
            $MatchingEPR.Tray         = '!{0}' -f ($TrayTable | Where-Object TrayRef -eq $TrayName | Select-Object -ExpandProperty TrayID)
        }
        if ($DuplexOption)  {
            $MatchingEPR.Duplex       = $DuplexOption
        }
        if ($PaperSize -and -not $NoValidPaperSizes)     {
            $MatchingEPR.Paper        = '!{0}' -f $PaperSizeTable | Where-Object PaperSizeRef -eq $PaperSize | Select-Object -ExpandProperty PaperSizeID
        }
        if ($IsRX)          {
            $MatchingEPR.RX           = $IsRX
        }
        if ($MediaType -and -not $NoValidMediaTypes)     {
            $MatchingEPR.Media        = '!{0}' -f $MediaTypeTable | Where-Object MediaTypeRef -eq $MediaType | Select-Object -ExpandProperty MediaTypeID
        }
        if ($Servername)    {
            $MatchingEPR.Server       = $Servername
        }

        $TempEPS        = New-TemporaryFile
        $TempEPSStream  = [io.streamwriter]::new($TempEPS.FullName)
        $TempEPSStream.Write($EPSMap.preamble)

        foreach ($Record in $EPSMap.epsmap) {
            $thisRecord = ($Record.PSObject.Properties).values -join '|'
            $thisRecord
            $TempEPSStream.WriteLine( $thisRecord )
        }
    }

    end {
        $TempEPSStream.Flush()
        $TempEPSStream.Dispose()

        if ($PSCmdlet.ShouldProcess('Would change the EPR for {0}' -f $Queue,'', '')) {
            try {
                Copy-Item -Path $TempEPS -Destination $EPSMap
                Write-Warning -Message 'Do not forget to run Update-OMTransformServer to make the updated EPR active'
                #Remove-Item -Path $TempEPS -Force
            }
            catch {
                Write-Warning -Message ('Could not copy temporary file ({0}) to overwrite the eps_map, please manually copy it. ' -f $TempEPS.FullName)
            }
        }
    }
}
