Function Get-OMPrinterConfiguration {
    <#
        .SYNOPSIS
            Retrieves the properties of one or more configurations in OMPlus
        .DESCRIPTION
            The utility reads the configuration file from the printer directory and converts the information
            into a PSCustomObject.
        .EXAMPLE 
            PS C:\> Get-OMPrinterConfiguration -PrinterName Printer01
            Printer   IPAddress    TCPPort LPRPort
            -------   ---------    ------- -------
            Printer01 10.0.0.1     9100    none

        .EXAMPLE
            PS C:\> Get-OMPrinterConfiguration -PrinterName Printer01 -Property all

            Printer          : Printer01
            Mode             : termserv
            IPAddress        : 10.0.0.1
            TCPPort          : 9100
            Stty             : none
            Filter           : dcctmserv
            User_Filter      : none
            Def_form         : stock
            Form             : stock
            Accept           : y
            Accepttime       : 001443446160
            Acceptreason     : New Printer
            Enable           : y
            Enabletime       : 001445452018
            Enablereason     : Unknown
            Metering         : 0
            Model            : omstandard.js
            Filebreak        : n
            Copybreak        : n
            Banner           : n
            Lf_crlf          : y
            Close_delay      : 10
            Writetime        : 5399
            Opentime         : 180
            Purgetime        : 100
            Draintime        : 5399
            Terminfo         : dumb
            Pcap             : none
            URL              : http://10.0.0.1
            CMD1             : none
            Comments         : none
            Support          : none
            Xtable           : standard
            Notify_flag      : 0
            Notify_info      : none
            Two_way_protocol : none
            Two_way_address  : none
            Alt_dest         : none
            Sw_dest          : none
            Page_limit       : 0
            Data_types       : all
            FO               : n
            HD               : n
            PG               : y
            LG               : 0
            DC               : default
            CP               : y
            RT               : 30
            EM               : none
            PT               : none
            PD               : n

        .EXAMPLE
            PS C:\>Get-OMPrinterConfiguration -PrinterName Printer1, Printer2 -Property Mode, URL

            Printer                         Mode                        URL
            -------                         ----                        ---
            Printer1                        termserv                    http://10.0.0.1
            Printer2                        termserv                    http://10.0.0.2
            Printer3                        netprint                    none

        .PARAMETER PrinterName
            The name of the printer(s) to retrieve the configuration from

        .PARAMETER Property
            The list of properties to return from the printer objects queried

        .INPUTS
            [string]
        .OUTPUTS
            [pscustomobject]
        .NOTES
            The script reads in the properties to create a hashtable and the converts it a PSCustomObject.
            The printer configuration file does not provide the printers actual name, so the 'printer' property is
            automatically added containing the printer name.
            The printer's name is always added as a property to the return object.
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
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
        [ValidateSet('All', 'Mode','Device','Stty','Filter','User_Filter','Def_form','Form','Accept',
        'Accepttime','Acceptreason','Enable','Enabletime','Enablereason','Metering',
        'Model','Filebreak','Copybreak','Banner','Lf_crlf','Close_delay','Writetime',
        'Opentime','Purgetime','Draintime','Terminfo','Pcap','URL','CMD1','Comments',
        'Support','Xtable','Notify_flag','Notify_info','Two_way_protocol',
        'Two_way_address','Alt_dest','Sw_dest','Page_limit','Data_types','FO','HD',
        'PG','LG','DC','CP','RT','EM','PT','PD','LZ','CA','RX','OP', '*')]
        [string[]]$Property = 'Device'
    )

    if ($Property -contains 'All' -or $Property -contains '*') {
        $AllProperties = $true
    }

    foreach ($Printer in $PrinterName) {
        $originalPrinterName = $printer
        $Printer = Get-OMCaseSensitivePrinterName -PrinterName $Printer

        if ($null -eq $printer) {
            Write-Warning -Message ('The printer ({0}) does not exist; skipping this printer' -f $originalPrinterName)
            continue 
        }
        $ConfigPath = [IO.Path]::Combine($env:OMHOME, 'printers', $Printer, 'configuration')
        $Config = Get-Content -Path $ConfigPath -ErrorAction Stop

        $Output = [pscustomobject]@{
            Printer = $Printer
        }

        $Config | ForEach-Object {
            $null = $_ -match '^(?<KeyName>\w+):\s(?<ValueName>.*)$'
            if ($Matches.KeyName -in $Property -or $AllProperties ) {
                if ($Matches.KeyName -eq 'Device') {
                    $IPAddress, $TCPPort = $Matches.ValueName.split('!')
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name 'IPAddress' -Value $IPAddress
                    if ($TCPPort -match '^\d+$') {
                        Add-Member -InputObject $Output -MemberType NoteProperty -Name 'TCPPort' -Value $TCPPort
                        Add-Member -InputObject $Output -MemberType NoteProperty -Name 'LPRPort' -Value 'none'
                    }
                    else {
                        Add-Member -InputObject $Output -MemberType NoteProperty -Name 'TCPPort' -Value 515
                        Add-Member -InputObject $Output -MemberType NoteProperty -Name 'LPRPort' -Value $TCPPort
                    }
                }
                elseif( $Matches.KeyName -eq 'AcceptTime' -or $Matches.KeyName -eq 'EnableTime' ) {
                    $thisDateTime = [System.DateTimeOffset]::FromUnixTimeSeconds($Matches.ValueName)
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $Matches.KeyName -Value $thisDateTime
                }
                else {
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $Matches.KeyName -Value $Matches.ValueName
                }
            }
        }
        $Output
    }
}
