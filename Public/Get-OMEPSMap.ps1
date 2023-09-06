function Get-OMEPSMap {
    <#
    .SYNOPSIS
        Takes the OMPlus EPS Map and returns the collection of PSCustomObjects representing those records
    .DESCRIPTION
        The script uses the $Script:EPSHeader from the module file to create pscustomobjects representing
        all of the eps_map records. It includes a property called Empty to allow the objects to be
        reconverted to the correct eps_map format, where it terminates in a delimiter (|).
        The script returns a hashtable with:
        @{
            Preamble = <preamble text of the file>
            EPSMap   = <collection of pscustomobjects for each of the records>
            FilePath = The location of the file read in
        }
    .EXAMPLE
        PS C:\> $EPSCollection = Get-OMEPSMap -FilePath $env:OMHOME\System\eps_map
        PS C:\> $EPSCollection.EPSMap[0]
        Server      : server.domain.local
        EPR         : PRINTERNAME
        Destination : PRINTERNAME
        Driver      : DellOPDPCL5
        Tray        : !260
        Duplex      :
        Paper       : !1
        RX          : n
        Media       :

        PS C:\> $EPSCollection.EPSMap[0].PSObject.Properties.Value -join '|'
        server.domain.local|PRINTERNAME|PRINTERNAME|DellOPDPCL5|!260||!1|n|

    .PARAMETER FilePath
        This is the path to the eps_map file.  By default, the script checks the role of the server and
        gets the eps_map file from the correct directory. This is a hidden parameter.

    .INPUTS
        [string]
    .OUTPUTS
        [List`1[pscustomobject]]
        [hashtable]
    .NOTES
        The script reads in the eps_map file and skips all the lines that begin with a #.
        It then takes each line and converts it to a PSCustomObject.
        The script cannot run on the secondary MPS server, since it does not have a copy of the eps_map.
    #>
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [string]$FilePath
    )

    if ($FilePath) {
        $EPSMapPath = $FilePath
    }
    else {
        $ServerRole = Get-OMServerRole 
        switch ($ServerRole) {
            'MPS' {
                $EPSMapPath  = [system.io.path]::combine($env:OMHome, 'system', 'eps_map')
            }
            'TRN'  {
                $EPSMapPath  = [system.io.path]::combine($env:OMHome, 'constants', 'eps_map')
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
    }

    $RawEPSMap          = Get-Content -Path $FilePath
    $EPSPreamble        = $RawEPSMap.Where{ $_ -match '^#'}
    $EPSMap             = $RawEPSMap.Where{ $_ -notmatch '^#' }

    $EPSCollection      = [collections.generic.list[PSCustomObject]]::new()
    $EPSMap | ConvertFrom-Csv -Delimiter '|' -Header $Script:EPSHeader | ForEach-Object {
        $EPSCollection.Add($_)
    }

    @{
        'Preamble'      = $EPSPreamble
        'EPSMap'        = $EPSCollection
        'FilePath'      = $FilePath
        'TimeStamp'     = Get-Item -Path $FilePath | Select-Object -ExpandProperty LastWriteTime
    }
}
