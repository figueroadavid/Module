function Get-OMCaseSensitivePrinterName {
    <#
    .SYNOPSIS
    Retrieves the printer name in its proper case

    .DESCRIPTION
    The command line utilities for OMPlus require case-sensitive printer names.
    This function retrieves the actual directory name of the printer and returns it as created,
    rather than as supplied.

    .PARAMETER PrinterName
    The name of the printer to retrieve

    .EXAMPLE
    PS C:\> Get-OMCaseSensitivePrinterName -PrinterName kb-9-240
    KB-9-240

    .EXAMPLE
    PS C:\> Get-OMCaseSensitivePrinterName -PrinterName print*
    PRINTER01
    Printer02
    PRINTER03
    PRINTER04
    PRINTER05
    PRINTER15

    .EXAMPLE
    PS C:\> Get-OMCaseSensitivePrinterName -PrinterName *03
    PRINTER03

    .EXAMPLE
    PS C:\> Get-OMCaseSensitivePrinterName -PrinterName printer?5
    PRINTER05
    PRINTER15

    .NOTES
    This takes advantage of the fact that the EnumerateDirectories method of the [system.io.directoryinfo] object
    preserves the case of the subdirectory.  Because of htise, it can accept wildcards to retrieve the names.
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrinterName
    )

    $PrinterHome = Get-Item -Path ([system.io.path]::Combine($env:OMHOME, 'printers'))

    $PrinterHome.EnumerateDirectories($PrinterName).name
}
