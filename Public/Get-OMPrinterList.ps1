Function Get-OMPrinterList {
    <#
    .SYNOPSIS
        Retrieves a list of printers from OMPlus
    .DESCRIPTION
        It reads in the directory names in the 'printers' subdirectory in the OMPlusHome Path, and returns just the names
    .EXAMPLE
        PS C:\> Get-OMPrinterList
        Printer01
        Printer02
        Printer03
        Printer04
        MyPrint01
        MyPrint02
        MyPrint03
        MyPrint04

        Retrieves the list of printers in the directory
    .EXAMPLE
        PS C:\> Get-OMPrinterList -Filter printer*
        Printer01
        Printer02
        Printer03
        Printer04
    .INPUTS
        [string]
    .OUTPUTS
        [string]
    .NOTES
        The Filter parameter is passed to Get-ChildItem as the Filter parameter.
    #>
    [cmdletbinding()]
    param(
        [parameter()]
        [string]$Filter
    )

    $OMPrinterPath = [system.io.path]::Combine($env:OMHOME,'printers')
    if ($Filter) {
        Get-ChildItem -Path $OMPrinterPath -Directory -Filter $Filter | Select-Object -ExpandProperty BaseName
    }
    else {
        Get-ChildItem -Path $OMPrinterPath -Directory | Select-Object -ExpandProperty BaseName
    }
}
