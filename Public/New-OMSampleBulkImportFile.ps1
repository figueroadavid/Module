Function New-OMSampleBulkImportFile {
    <#
    .SYNOPSIS
        Generates a header file to create a new CSV file for bulk importing printers
    .DESCRIPTION
        Generates a header file to create a new CSV file for bulk importing printers
    .EXAMPLE
        PS C:\> $BIFSplat = @{
            FilePath            = 'c:\temp\bulkimport.csv'
            delimiter           = '|'
            PortType            = 'TCPPort'
            OptionalParameter   = 'Comment','Notes','SupportNotes','DoNotValidate','IsTesting'
            IncludeComments     = $true
        }
        PS C:\> New-OMSampleBulkImportFile @BIFSplat
        Explanation of what the example does
    .PARAMETER FilePath
        The output location for the sample file
    .PARAMETER Delimiter
        The delimiter used for the CSV file, it defaults to a comma (,)
    .PARAMETER PortType
        This differentiates between TCP and LPR type printing, the default is TCPPort
    .PARAMETER OptionalParameter
        This is a list of the optional parameters usable for the New-OMPrinter and New-OMBulkImport.
            'Comment', 'Notes', 'DoNotValidate', 'PurgeTime', 'PageLimit', 'SupportNotes',
            'WriteTimeout', 'TranslationTable', 'DriverType', 'PCAPPath', 'UserFilterPath',
            'Filter2', 'Filter3', 'CPSMetering', 'InsertMissingFF', 'FormType', 'LFtoCRLF',
            'CopyBreak', 'FileBreak', 'Banner', 'HasInternalWebServer', 'CustomURL', 'ForceWebServer', 'IsTesting'
    .PARAMETER IncludeComments
        This switch causes the function to include another column that includes comments about the optional parameters

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FilePath,

        [parameter(ValueFromPipelineByPropertyName)]
        [char]$Delimiter = ',' ,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('TCPPort','LPRPort')]
        [string[]]$PortType = 'TCPPort',

        [parameter()]
        [ValidateSet('Comment',
                     'Notes',
                     'DoNotValidate',
                     'PurgeTime',
                     'PageLimit',
                     'SupportNotes',
                     'WriteTimeout',
                     'TranslationTable',
                     'DriverType',
                     'PCAPPath',
                     'UserFilterPath',
                     'Filter2',
                     'Filter3',
                     'CPSMetering',
                     'InsertMissingFF',
                     'FormType',
                     'LFtoCRLF',
                     'CopyBreak',
                     'FileBreak',
                     'Banner',
                     'HasInternalWebServer',
                     'CustomURL',
                     'ForceWebServer',
                     'IsTesting'
        )]
        [String[]]$OptionalParameter,

        [parameter()]
        [switch]$IncludeComments
    )

    $CommentsTable = @{
        'PrinterName'           = 'Mandatory parameter; Name used to create the actual printer; spaces are not allowed'
        'IPAddress'             = 'Mandatory parameter; IP address for the printer, or LPR/LPD print server'
        'PortType'              = 'Mandatory parameter; Flags the printer as TCP/IP or LPR/LPD, the correct header column will be output either TCPPort or LPRPort'
        'TCPPort'               = 'Mandatory parameter: The TCP port used for network communication, between 0 and 65535; the default is 9100'
        'LPRPort'               = 'Mandatory parameter: This is the name of the queue on the LPR/LPD server; the name is generally case-sensitive'
        'Comment'               = 'Optional parameter; Comment for the printer'
        'Notes'                 = 'Optional parameter; Notes field for the printer'
        'DoNotValidate'         = 'Optional parameter; Tells lpadmin not to verify the printer before creating it (-z)'
        'PurgeTime'             = 'Optional parameter; The amount of time in seconds before a print job is purged after changing status to prntd or can'
        'PageLimit'             = 'Optional parameter; The maximum number of pages per job that can be printed out on this printer'
        'SupportNotes'          = 'Optional parameter; Support field for the printer'
        'WriteTimeout'          = 'Optional parameter; How long a print job can take to print before being cancelled (in seconds)'
        'TranslationTable'      = 'Optional parameter; Alternate translation table that needs to be used'
        'DriverType'            = 'Optional parameter; The DriverType for the printer; must be one of the supported ones from the system'
        'PCAPPath'              = 'Optional parameter; if this is included, it indicates the file location for a network pcap to be taken for the printer, and that the pcap should be taken'
        'UserFilterPath'        = 'Optional parameter; User supplied filter for the print jobs'
        'Filter2'               = 'Optional parameter; Secondary user supplied filter for the print jobs'
        'Filter3'               = 'Optional parameter; Tertiary user supplied filter for the print jobs'
        'CPSMetering'           = 'Optional parameter; Characters per second limit for the printer'
        'InsertMissingFF'       = 'Optional parameter; Inserts a form feed between jobs if it is not already present'
        'FormType'              = 'Optional parameter; Sets the form type for the printer'
        'LFtoCRLF'              = 'Optional parameter; Converts line feeds to Carriage Return/Line Feeds'
        'CopyBreak'             = 'Optional parameter; Inserts a form feed between each copy of a multi-copy print job'
        'FileBreak'             = 'Optional parameter; Inserts a form feed between print job files'
        'Banner'                = 'Optional parameter; Inserts a print banner for each print job'
        'HasInternalWebServer'  = 'Optional parameter; Indicates that the printer has a built in web server; if a CustomURL is not supplied it will attempt to create a URL from http://<ipaddress> or https://<ipaddress> '
        'CustomURL'             = "Optional parameter; Indicates that the printer's web server has a custom URL that needs to be used"
        'ForceWebServer'        = 'Optional parameter; Indicates that te default web server URL needs to be set even if neither http://<ipaddress> nor https://<ipaddress> respond '
        'IsTesting'             = 'Optional parameter; Causes the script to return the generated command line rather than execute it'
    }
    $ParameterSet = New-Object -Type System.Collections.Generic.List[string]
    $ParameterSet.Add('PrinterName')
    $ParameterSet.Add('IPAddress')
    $ParameterSet.Add($PortType)
    if ($OptionalParameter) {
        switch ($OptionalParameter.Count) {
            0       { Write-Verbose -Message 'No optional parameters selected'}
            1       { $ParameterSet.Add($OptionalParameter)}
            default { $ParameterSet.AddRange($OptionalParameter)}
        }
    }
    if ($IncludeComments) {
        $OutputHash = [ordered]@{}
        $ParameterSet | ForEach-Object {
            $null = $OutputHash.Add($_, $CommentsTable.$_)
        }
        $OutputPSCO = [pscustomobject]$OutputHash
        $OutputPSCO | Export-CSV -Path $FilePath -Delimiter $Delimiter -NoTypeInformation
    }
    else {
        $ParameterSet -join ',' | Out-File -FilePath $FilePath
    }

}
