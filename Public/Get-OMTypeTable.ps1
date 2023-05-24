Function Get-OMTypeTable {
    <#
    .SYNOPSIS
        Retrieves the configuration type information from the types.conf XML file
    .DESCRIPTION
        Retrieves the configuration type information from the types.conf XML file for either
        Trays, Paper Size, or Media Type.  The names and ID numbers are retrieved from the XML file.
        If a specified driver does not exist in types.conf, then no information is returned.
        If an invalid driver name is attemped, then an error is thrown.
    .EXAMPLE
        PS C:\> Get-OMTypeTable -DriverName DellMulti -Display Trays
        TrayName                                               TrayID
        --------                                               ------
        Auto Select                                                15
        Manual Tray                                               257
        Tray 1                                                    259
        Tray 2                                                    260
        Tray 3                                                    261
        Tray 4                                                    262
        Tray 5                                                    263
    .EXAMPLE
        PS C:\> Get-OMTypeTable -DriverName DellMulti -Display PaperSizes
        PaperSizeName                                     PaperSizeID
        -------------                                     -----------
        A3                                                          8
        A4                                                          9
        A5                                                         11
        B4 (JIS)                                                   12
        B5 (JIS)                                                   13
        B6 (JIS)                                                   88
        11x17                                                      17
        Executive                                                   7
        Folio                                                      14
        Legal                                                       5
        Letter                                                      1
        Oficio                                                    265
        Statement                                                   6
        Envelope B5                                                34
        Envelope C4                                                30
        Envelope C5                                                28
        Envelope C6                                                31
        Envelope #9                                                19
        Envelope #10                                               20
        Envelope DL                                                27
        Envelope Monarch                                           37
        Postcard                                                  257
    .EXAMPLE
        PS C:\> Get-OMTypeTable -DriverName DellMulti -Display PaperSizes -SortBy ID
        PaperSizeName                                     PaperSizeID
        -------------                                     -----------
        Letter                                                      1
        Legal                                                       5
        Statement                                                   6
        Executive                                                   7
        A3                                                          8
        A4                                                          9
        A5                                                         11
        B4 (JIS)                                                   12
        B5 (JIS)                                                   13
        Folio                                                      14
        11x17                                                      17
        Envelope #9                                                19
        Envelope #10                                               20
        Envelope DL                                                27
        Envelope C5                                                28
        Envelope C4                                                30
        Envelope C6                                                31
        Envelope B5                                                34
        Envelope Monarch                                           37
        B6 (JIS)                                                   88
        Postcard                                                  257
        Oficio                                                    265
    .EXAMPLE
        PS C:\> Get-OMTypeTable -DriverName DellMulti -Display MediaTypes -SortBy ID
        MediaTypeName                                     MediaTypeID
        -------------                                     -----------
        Auto Select                                               256
        Plain                                                     257
        Recycled                                                  258
        Bond                                                      259
        Envelope                                                  260
        Letterhead                                                261
        Prgetprinted                                                262
        Prepunched                                                263
        Color                                                     264
        Glossy                                                    265
    .INPUTS
        [string]
    .OUTPUTS
        [Array]
    .NOTES
        The module loads the type.conf table into memory, and this function queries
        the XML to output the desired type.  The driver names are case-sensitive because
        they are used in XPath queries.  The function pre-populates driver names using
        powershell functions in order to help guarantee the driver name is spelled correctly.

        Some drivers such as the Zebra drivers do not have configurations in the types.conf file
        so nothing is returned for those.
    .PARAMETER DriverType
        This is the name of the driver configuration as defined in OMPlus.  The function reads
        the types.conf file which is an XML file.  So, the drivername provided is case-sensitive.
    .PARAMETER Display
        This determines which dataset should be returned:
            * Trays
            * Paper Sizes
            * Media Types
    .PARAMETER SortBy
        This determines if the returned data should be sorted by the name or the ID

    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                $Script:OMDrivers.Keys |
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
        [string]$DriverType,

        [parameter()]
        [ValidateSet('Trays','PaperSizes','MediaTypes')]
        [string]$Display = 'Trays',

        [parameter()]
        [ValidateSet('Name','ID')]
        [string]$SortBy = 'Name'
    )
    
    $DriverNames = (Get-OMDriverNames).keys
    If ($DriverNames.Contains($DriverType) ) {
        $DriversWithConfigInformation = Select-Xml -Xml $TypesConf -XPath '/OMPLUS/PTYPE' |
        Select-Object -ExpandProperty node | Select-Object -ExpandProperty name

        if ($DriverType -in $DriversWithConfigInformation) {
            Write-Verbose -Message 'DriverType is in the list of driver types recognized by the system'
        }
        else {
            Write-Warning -Message 'DriverType is in the list of driver types recognized by the system, however there is no configuration information for it.  This is typical for printers like the Zebra models'
            return
        }
    }
    else {
        $Message = 'The supplied DriverType is not valid.  The available drivers are:{0}{1}' -f $Script:CRLF, ($DriverNames -join "`r`n")
        Write-Warning -Message $Message
        return
    }

    $XPath = '/OMPLUS/PTYPE[@name="{0}"]/' -f $DriverType

    switch ($Display) {
        'Trays' {
            switch ($SortBy) {
                'Name' { $SortType = 'TrayName' }
                'ID'   { $SortType = 'TrayID' }
            }
            $XPath  = '{0}/{1}' -f $XPath, 'TRAYS/TRAY'
            $Trays  = Select-Xml -Xml $TypesConf -XPath $XPath | Select-object -ExpandProperty node |
                        Select-Object -Property @{n='TrayName';e={$_.'#text'}},@{n='TrayID';e={[int]::Parse($_.id)}}

            $Trays | Sort-Object -Property $SortType
        }
        'PaperSizes' {
            switch ($SortBy) {
                'Name' { $SortType = 'PaperSizeName' }
                'ID'   { $SortType = 'PaperSizeID' }
            }
            $XPath  = '{0}/{1}' -f $XPath,'PSIZE/PAPER'
            $Paper = Select-XML -XML $TypesConf -XPath $XPath | Select-Object -ExpandProperty Node |
                        Select-Object -Property @{n='PaperSizeName';e={($_.'#text').Trim()}},@{n='PaperSizeID';e={[int]::Parse($_.id)}}

            $Paper | Sort-Object -Property $SortType
        }
        'MediaTypes' {
            switch ($SortBy) {
                'Name' { $SortType = 'MediaTypeName' }
                'ID'   { $SortType = 'MediaTypeID' }
            }
            $XPath  = '{0}/{1}' -f $XPath,'MTYPE/MEDIA'
            $Media = Select-XML -XML $TypesConf -XPath $XPath | Select-Object -ExpandProperty Node |
                        Select-Object -Property @{n='MediaTypeName';e={($_.'#text').Trim()}},@{n='MediaTypeID';e={[int]::Parse($_.id)}}
            $Media | Sort-Object -Property $SortType
        }
    }
}
