Function New-OMBulkImport {
    <#
    .SYNOPSIS
        Initiates a bulk import run of a CSV file into the New-OMPrinter command.
    .DESCRIPTION
        The script takes the FilePath, and imports the CSV File, and then sends each
        CSV Record into New-OMPrinter using powershell splatting of the available
        paramters.
    .EXAMPLE
        PS C:\> New-OMBulkImport -FilePath c:\temp\omplusimport.csv -delimiter '|'

        Imports the pipe delimited list into New-OMPrinter, thereby generating
        the correct lpadmin commands to add the printer. If the CSV record contains a populated column
        for IsTesting, then the lpadmin commands are displayed rather than issued.
    .INPUTS
        [string]
    .OUTPUTS
        none or [string]
    .NOTES
        This initiates a bulk import of the import CSV file set up for New-OMPrinter.
        If the given CSV contains 'TRUE' or 'FALSE', they are converted to true powershell
        boolen values ($true, $false).  New-OMPrinter expects boolean values in certain
        fields which to not translate properly to text.
    .PARAMETER FilePath
        The path to the CSV file
    .PARAMETER Delimiter
        This is the delimiter used by the file, the default is a comma ','
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FilePath,

        [Parameter()]
        [char]$Delimiter = ','
    )

    Begin {
        $CSV = Import-CSV -Path $FilePath -Delimiter $Delimiter
        $SuppliedProperties = $CSV | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

        if ($CSV.Count -gt 10) {
            $ShowProgress   = $true
            $CurrentCounter = 0
            $TotalCount = $CSV.Count
        }

    }

    Process {
        foreach ($Record in $CSV) {
            $OMSplat = @{}
            foreach ($Property in $SuppliedProperties) {
                if ($Record.$Property -match 'TRUE|FALSE') {
                    switch ($Record.$Property) {
                        'TRUE'  {$OMSplat[$Property] = $TRUE; break }
                        'FALSE' {$OMSplat[$Property] = $FALSE }
                    }
                }
                else {
                    $OMSplat[$Property] = $Record.$Property
                }
            }
            if ($ShowProgress) {
                $CurrentCounter ++
                $ProgSplat = @{
                    Activity            = 'Creating printer {0}' -f $OMSplat['PrinterName']
                    CurrentOperation    = '{0} of {1}' -f $CurrentCounter, $TotalCount
                    PercentComplete     = [math]::round($CurrentCounter/$TotalCount * 100, [system.midpointrounding]::awayfromzero)
                }
                Write-Progress @ProgSplat
            }
            New-OMPrinter @OMSplat
        }
    }
}
