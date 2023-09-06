Function New-OMEPR {
    <#
    .SYNOPSIS
        This will generate an OMPlus EPR record for the eps_map file
    .DESCRIPTION
        <work in progress>
    .EXAMPLE
        PS C:\> $EPRSplat = @{
            ServerName      = 'server01.domain.local'
            EPRQueue        = 'PRINTER01'
            OMQueue         = 'PRINTER01'
            DriverName      = 'DellOPDPCL5'
            TrayName        = 'Tray 1'
            DuplexOption    = 'Horizontal'
            PaperSize       = 'Letter'
            IsRX            = 'n'
            MediaType       = 'Bond'
            Append          = $true
            UpdateTransform = $true
        }
        PS C:\> New-OMEPR @EPRSplat
        server01.domain.local|PRINTER01|PRINTER01|DellOPDPCL5|!259|Horizontal|!1|n|!259

    .PARAMETER ServerName
        This is the fully qualified domain name of the server which will have the
        generated EPR record.  This parameter is hidden, since it will almost always
        be used on the primary MPS server.

    .PARAMETER Queue
        The name of the EPR Queue in OMPlus. 
        Each tray in a laser printer will typically get its own Queue name.

    .PARAMETER Destination
        The name of the OMPlus Queue name (i.e. the printer itself or the receiving server).

    .PARAMETER DriverName
        This is the name of the print driver in OMPlus to use for the EPR Record.
        The name must match one of the types listed in the Types menu in OMPlus Control Panel.

    .PARAMETER TrayName
        This is the display name of the Tray.  It must match exactly one entry for the Driver
        in the types.conf file.  When the EPR record is generated, the name here is replaced with
        the correct ID number from trays.conf.
        If no TrayName is provided, the generated EPR record will contain an empty field.

    .PARAMETER DuplexOption
        This is the option Duplexing parameter for the EPR Record.
        It can be set to None, Simplex, Horizontal, or Vertical.
        None implies that the field in the generated EPR record will be empty.
        In the GUI, Horizontal appears as 'Short Edge', and
        Vertical appears as 'Long Edge'.  However, 'Horizontal' and 'Vertical' are
        the terms actually used in the eps_map file.

    .PARAMETER PaperSize
        This is the displayname of the paper size to be chosen.
        If no PaperSize is provided, the generated EPR record will contain an empty field.

    .PARAMETER IsRX
        Determines if the RX field is present in the generated EPR record.  It defaults to 'n'
        which is unchecked in the GUI.  The other option is to put in 'y' which marks the checkbox
        in the GUI.
        
    .PARAMETER MediaType
        This is the displayname of the media type used in the EPR Record.
        If no MediaType is provided, the generated EPR record will contain an empty field.

    .PARAMETER Append
        This switch tells the script to automatically append the record to the eps_map.
        
    .PARAMETER UpdateTransform
        This switch tells the script to run Update-OMTransformServer at the end.  

    .PARAMETER AllowMixedCase
        By default, the script will force the Queue and Destination names to upper case.
        Using this switch allows the script to use the case as inserted into the parameter.
    
    .PARAMETER OverRide
        Allows the script to generate EPR's even without the printer exisitng ahead of time.

    .INPUTS
        [string]

    .OUTPUTS
        [string]

    .NOTES
        For the TrayName, PaperSize, and MediaType fields, the supplied names are matched against the
        available names in the types.conf file, and if more than one match is found, or if no matches
        are found, the record is not generated, and a warning is thrown. The text supplied is escaped
        to make sure the RegEx pattern is valid for the RegEx engine.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)]
        [Alias('EPRQueueName')]
        [string]$Queue,

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
                        ('Tray Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$TrayName = 'None',

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
        [string]$PaperSize = 'None',

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
                        ('Tray Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$MediaType = 'None',

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

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$Append,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$UpdateTransform,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$AllowMixedCase,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$OverRide
    )

    begin {

        $ServerRole = Get-OMServerRole 
        switch ($ServerRole) {
            'MPS' {
                $EPSMapPath     = [system.io.path]::combine($env:OMHome,'system', 'eps_map')
                $TypesConfPath  = [system.io.path]::combine($env:OMHome, 'system', 'types.conf')
            }
            'TRN'  {
                $Message = 'On Transform server, the eps_map cannot be modified here'
                Write-Warning -Message $Message 
                return 
            }
            'BKP' {
                Write-Warning -Message 'On the secondary MPS server, the eps_map is not available'
                return 
            }
            default {
                Write-Warning -Message 'Not on an OMPlus server'
                return 
            }
        }
    
        if ($Append) {
            $EPSMapPath = [io.path]::Combine($env:OMHOME, 'system', 'eps_map')
        }

        $EPSMap = (Get-OMEPSMap).epsmap 
        $TestQueue  = [regex]::Escape($Queue)

        if ($EPSMap.EPR -contains $Queue) {
            $FlatRecord = $EPSMap | Where-Object EPR -match $TestQueue | Format-Table
            $Message = 'Duplicate EPR/Queue Name, not continuing{0}Existing queue:{0}{1}' -f [Environment]::NewLine, $FlatRecord
            Write-Warning  -Message $Message
            return 
        }

        $TypesConf = New-Object -TypeName xml
        $TypesConf.Load($TypesConfPath)
        $TypesConfDriverList = Select-XML -XPath '/OMPLUS/PTYPE' | 
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty name 

        if ($Driver -in $TypesConfDriverList) {
            if ($TrayName  -ne 'None') { $TrayDictionary      = Get-OMTypeTable -DriverType $DriverName -Display Trays }
            if ($PaperSize -ne 'None') { $PaperSizeDictionary = Get-OMTypeTable -DriverType $DriverName -Display PaperSizes }
            if ($MediaType -ne 'None') { $MediaTypeDictionary = Get-OMTypeTable -DriverType $DriverName -Display MediaTypes }
            $NoTypeDataAvailable = $false 
        }
        else {
            $NoTypeDataAvailable = $true 
        }
        
        $PrinterDir = Get-Item -Path ([system.io.path]::Combine($env:OMHOME, 'printers'))
        $OMQueue = $PrinterDir.EnumerateDirectories($Destination).name 

        if (-not $OMQueue -or $OverRide) {
            throw 'This destination (printer) does not exist; not creating the EPR'
        }
    }

    process {
        $thisRecord = New-Object -TypeName System.Collections.Generic.List[string]
        $thisRecord.Add($ServerName)
        if ($AllowMixedCase) {
            $thisRecord.Add($Queue)
        }
        else {
            $thisRecord.Add(($Queue.ToUpper()))
        }

        $thisRecord.Add($DriverName)

        if ($TrayName -eq 'None' -or $NoTypeDataAvailable) {
            $thisRecord.Add('DELETEME')
        }
        else {
            $thisMatch = $TrayDictionary.Where{ $_.TrayName -like $TrayName }
            switch ($thisMatch.Count) {
                0 {
                    $thisRecord.Add('DELETEME')
                    $Message = 'No tray names match {0}, putting in an empty field' -f $TrayName
                    Write-Warning -Message $Message
                }
                1 {
                    $thisRecord.Add( ('!{0}' -f $thisMatch.TrayID) )
                }
                default {
                    $Message = 'TrayName ({0}) matches too many items, please narrow the list and try again:{1}{2}' -f $TrayName, "`r`n", ($TrayDictionary.TrayName -join "`r`n")
                    throw $Message
                }
            }
            Remove-Variable -Name thisMatch
        }

        if ($DuplexOption -eq 'None' -or $NoTypeDataAvailable) {
            $thisRecord.Add('DELETEME')
        }
        else {
            $thisRecord.Add($DuplexOption)
        }

        if ($PaperSize -eq 'None' -or $NoTypeDataAvailable) {
            $thisRecord.Add('DELETEME')
        }
        else {
            $thisMatch = $PaperSizeDictionary.Where{ $_.PaperSizeName -like $PaperSize }
            switch ($thisMatch.Count) {
                0 {
                    $thisRecord.Add('DELETEME')
                    $Message = 'No PaperSize names match {0}, putting in an empty field' -f $PaperSize
                    Write-Warning -Message $Message
                    break
                }
                1 {
                    $thisRecord.Add( ('!{0}' -f $thisMatch.PaperSizeID) )
                }
                default {
                    $Message = 'PaperSize ({0}) matches too many items, please narrow the list and try again:{1}{2}' -f $PaperSize, "`r`n", ($PaperSizeDictionary.PaperSizeName -join "`r`n")
                    throw $Message
                }
            }
            Remove-Variable -Name thisMatch
        }

        $thisRecord.Add($IsRX)

        if ($MediaType -eq 'None' -or $NoTypeDataAvailable) {
            $thisRecord.Add('DELETEME')
        }
        else {
            $thisMatch = $MediaTypeDictionary.Where{ $_.MediaTypeName -like $MediaType }

            switch ($thisMatch.Count) {
                0 {
                    $thisRecord.Add('DELETEME')
                    $Message = 'No MediaType names match {0}, putting in an empty field' -f $MediaType
                    Write-Warning -Message $Message
                    break
                }
                1 {
                    $thisRecord.Add( ('!{0}' -f $thisMatch.MediaTypeID) )
                    break
                }
                default {
                    $Message = 'MediaType ({0}) matches too many items, please narrow the list and try again:{1}{2}' -f $MediaType, "`r`n", ($MediaTypeDictionary.MediaTypeName -join "`r`n")
                    throw $Message
                }
            }
            Remove-Variable -Name thisMatch
        }
        $thisRecord = $thisRecord -join '|' -replace 'DELETEME'
    }

    end {
        if ($Append -and $PSCmdlet.ShouldProcess('Updating eps_map file', '', '')) {
            $Content = (Get-Content -Path $EPSMapPath -Raw).TrimEnd() += "`r`n$thisRecord"
            Set-Content -Path $EPSMapPath -Value $Content -Force

            if ($UpdateTransform) {
                Update-OMTransformServer
            }
            else {
                Write-Warning -Message 'Do not forget to run Update-OMTransformServer'
            }
        }
        else {
            $thisRecord
        }
    }
}
