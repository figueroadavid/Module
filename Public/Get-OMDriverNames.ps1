function Get-OMDriverNames {
    <#
    .SYNOPSIS
        Returns the list of valid drivers for OMPlus
    .DESCRIPTION
        Reads in the om_eps_win_queues.csv and returns the list of valid drivers for OMPlus
    .EXAMPLE
        PS C:\> Get-OMDriverList
        Name                           Value
        ----                           -----
        ZDesignerAM400                 ZDesigner ZM400 200 dpi (ZPL)
        HPUPD6                         HP Universal Printing PCL 6
        LexUPDv2                       Lexmark Universal v2
        DellOPDPCL5                    Dell Open Print Driver (PCL 5)
        RICOHPCL6                      RICOH PCL6 UniversalDriver V4.14
        HPUPD5                         HP Universal Printing PCL 5
        Zebra2.5x4                     ZDesigner ZM400 200 dpi (ZPL)
        LexUPDv2PS3                    Lexmark Universal v2 PS3
        LexUPDv2XL                     Lexmark Universal v2 XL
        XeroxUPDPS                     Xerox Global Print Driver PS
        XeroxUPDPCL6                   Xerox Global Print Driver PCL6
        HPUPDPS7                       HP Universal Printing PS (v7.0.0)
        EpsonT88VI                     EPSON TM-T88VI Receipt5
        ZT610-300DPI                   ZDesigner ZT610-300dpi ZPL
    .INPUTS
        [none]
    .OUTPUTS
        [none]
    .NOTES
        Retrieves the list of drivernames from the system.  The name is the configuration used
        in the eps_map, and the value is the actual Windows driver used on the Transform servers.
        This function does not work on the Secondary MPS server; it only works on the Primary MPS
        or the Transform servers.
    #>
    if ($Script:IsPrimaryMPS -or $Script:IsTransformServer) {
        $Script:OMDrivers
    }
    else {
        Write-Warning -Message 'On the secondary MPS server, this list is not available'
    }
}
