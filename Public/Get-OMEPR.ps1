function Get-OMEPR {
    <#
    .SYNOPSIS
        Retrieve EPR's matching a specific name (queue or printer)
    .DESCRIPTION
        Uses the Get-OMEPSMap function to retrieve the OMPlus eps_map records and
        returns the records based on the the queue name (EPR Record), or the printer (OMPlus queue).
    .PARAMETER Destination
        This is the destination name of the printer.  It refers to the device as opposed to the individual tray.
        A destination printer can have multiple trays (queues).

    .PARAMETER Queue
        This is the name of the OMPlus queue.  It refers to the individual queue name/tray name as defined in Epic.
        Each physical tray in a printer will have it's own queue name.

    .PARAMETER RetrieveNames
        This switch will cause the script to search the types.conf information and convert the numerical ID's for
        the trays, paper sizes, and media types to their names as presented in the driver.  The duplex settings are
        converted from Horizontal/Vertical to Short Edge/Long Edge.  This causes the outputted record data to look
        the same as it does in the java client interface.

    .EXAMPLE
        PS C:\> Get-OMEPR -Destination KB-9-241 | format-Table -AutoSize
        Server                    EPR             Destination Driver      Tray    Duplex  Paper   RX  Media
        ------                    ---             ----------- ------      ----    ------  -----   --  -----
        servername.domain.local   KB-9-241        KB-9-241    LexUPDv2    !1              !1      n
        servername.domain.local   KB-9-241-RX$    KB-9-241    LexUPDv2    !2              !1      n

    .EXAMPLE
        PS C:\> Get-OMEPR -Destination KB-9-241 -RetrieveNames | format-Table -AutoSize
        Server                    EPR             Destination Driver      Tray    Duplex  Paper   RX  Media
        ------                    ---             ----------- ------      ----    ------  -----   --  -----
        servername.domain.local   KB-9-241        KB-9-241    LexUPDv2    Tray 1          Letter  n
        servername.domain.local   KB-9-241-RX$    KB-9-241    LexUPDv2    Tray 2          Letter  n

    .EXAMPLE
        PS C:\> Get-OMEPR -Queue KB-9-241-RX$ | format-Table -AutoSize
        Server                    EPR             Destination Driver      Tray    Duplex  Paper   RX  Media
        ------                    ---             ----------- ------      ----    ------  -----   --  -----
        servername.domain.local   KB-9-241-RX$    KB-9-241    LexUPDv2    !2              !1      n

    .EXAMPLE
        PS C:\> Get-OMEPR -Queue KB-9-241-RX$ -RetrieveNames | format-Table -AutoSize
        Server                    EPR             Destination Driver      Tray    Duplex  Paper   RX  Media
        ------                    ---             ----------- ------      ----    ------  -----   --  -----
        servername.domain.local   KB-9-241-RX$    KB-9-241    LexUPDv2    Tray 2          Letter  n

    .INPUTS
        [string]

    .OUTPUTS
        [pscustomboject]

    .NOTES
        The script uses powershell Regular Expression matching, so all records that look the same
        as the inputted values will be retrieved.  This also means that the matching is done in a
        case-insensitive fashion (since we are running on Windows).

        There are 2 basic modes of operation.  The first one is to get the specific EPR's based on the
        name of the EPR Queue name.  A single physical printer might have multiple EPR's (one per tray, or
        for mutually exclusive options - like duplexing/non-duplexing).
        The second mode is to pull EPRs based on the destination - the physical printer definition.

        If the script is run on a transform server, the names will not be retrieved, because Types.conf does not
        exist on the Transform servers.

    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byDestination')]
        [Alias('Printer', 'OMQueue')]
        [string]$Destination,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byQueue')]
        [Alias('EPR')]
        [string]$Queue,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$RetrieveNames
    )

    if ($Script:IsPrimaryMPS -or $Script:IsTransformServer) {
        Write-Verbose -Message 'On either the Primary MPS or a Transform server; continuing'
    }
    else {
        Write-Warning 'On secondary MPS server, unable to retrieve eps_map'
        return
    }

    $EPSMap = (Get-OMEPSMap).EPSMap

    switch ($PSCmdlet.ParameterSetName) {
        'byDestination' {
            $Records = $EPSMap | Where-Object Destination -match $Destination
        }
        'byQueue' {
            $Records = $EPSMap | Where-Object EPR -match ('^{0}$' -f $Queue)
        }
    }

    if ($RetrieveNames -and $Script:IsPrimaryMPS) {
        $TypesConfPath = (Get-Item -Path ([System.IO.Path]::Combine($ENV:OMHOME, 'system', 'types.conf'))).FullName
        $TypesConf = New-Object -TypeName xml
        $TypesConf.Load($TypesConfPath)

        foreach ($Record in $Records) {
            $Driver = $Record.Driver

            Write-Verbose -Message 'Enumerate the Tray ID, strip the ! and get the text name'
            if ($null -eq $Record.Tray ) {
                $trayName   = 'none'
            }
            else {
                $trayID     = $Record.Tray.Replace('!','')
                $XPath      = '/OMPLUS/PTYPE[@name="{0}"]/TRAYS/TRAY[@id={1}]' -f $Driver, $trayID
                $trayName   = $TypesConf.SelectNodes($XPath) | Select-Object -ExpandProperty InnerXML
            }

            Write-Verbose -Message 'Enumerate the Simplex/Duplex name'
            if ($null -eq $Record.Duplex ) {
                $DuplexName = 'none'
            }
            else {
                switch ($Record.Duplex) {
                    'Horizontal'    { $DuplexName = 'Short Edge'}
                    'Vertical'      { $DuplexName = 'Long Edge'}
                    default         { $DuplexName = $Record.Duplex}
                }
            }

            Write-Verbose -Message 'Enumerate the Paper Size ID, strip the ! and get the text name'
            if ([system.string]::IsNullOrEmpty($Record.Paper)) {
                $PaperName  = ''
            }
            else {
                $PaperID    = $Record.Tray.Replace('!','')
                $XPath      = '/OMPLUS/PTYPE[@name="{0}"]/PSIZE/PAPER[@id={1}]' -f $Driver, $PaperID
                $PaperName  = $TypesConf.SelectNodes($XPath) | Select-Object -ExpandProperty InnerXML
            }

            Write-Verbose -Message 'Enumerate the RX setting'
            if ([system.string]::IsNullOrEmpty($Record.RX) ) {
                $RxSetting  = ''
            }
            else {
                $RxSetting = $Record.RX
            }

            Write-Verbose -Message 'Enumerate the Media Type ID, strip the ! and get the text name'
            if ([system.string]::IsNullOrEmpty($Record.Media) ) {
                $MediaName  = ''
            }
            else {
                $MediaID    = $Record.Tray.Replace('!','')
                $XPath      = '/OMPLUS/PTYPE[@name="{0}"]/MTYPE/Media[@id={1}]' -f $Driver, $MediaID
                $MediaName  = $TypesConf.SelectNodes($XPath) | Select-Object -ExpandProperty InnerXML
            }

            [PSCustomObject]@{
                'Server'        =  $Record.Server
                'EPR'           =  $Record.EPR
                'Destination'   =  $Record.Destination
                'Driver'        =  $Record.Driver
                'Tray'          =  $TrayName
                'Duplex'        =  $DuplexName
                'Paper'         =  $PaperName
                'RX'            =  $RxSetting
                'Media'         =  $MediaName
            }
            Remove-Variable -Name TrayName, DuplexName, PaperName, RxSetting, MediaName
        }
    }
    else {
        $Records
    }
}
