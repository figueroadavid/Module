function Remove-OMEPR {
    <#
    .SYNOPSIS
        Remove EPR records from the eps_map file
    .DESCRIPTION
        The script takes a search type (i.e. the EPR name or the destination/printer name) and
        removes those records from the eps_map and calls the function to update the transform
        servers.
    .EXAMPLE
        PS C:\> Remove-OMEPR -LocateBy Destination -SearchTerm AC-10-38
        Removes any EPRs/Queue based on the Destination/OMQueue of AC-10-38.
        If AC-10-38 had 4 queues for it, all of them would be removed.

    .EXAMPLE
        PS C:\> Remove-OMEPR -LocateBy EPR -SearchTerm AC-10-38-RX
        Removes the EPR/Queue for the record AC-10-38-RX.  The other queues for
        AC-10-38 would not be removed.
    .PARAMETER LocateBy
        This determines which record of the EPR will be searched.  It can be the
        EPR/Queue which represents the tray of the record, or it can be the
        Destination which is the physicl device itself.

        If we had these 5 records:
        server1.domain.local|ZZ-107-154|ZZ-107-154|RICOH|!1||!1|n|
        server1.domain.local|ZZ-108-37|ZZ-108-37|Lexmark|!1||!1|n|
        server1.domain.local|ZZ-108-37-RX$|ZZ-108-37|Lexmark|!257||!1|n|
        server1.domain.local|ZZ-108-37-T2$|ZZ-108-37|Lexmark|!2||!1|n|
        server1.domain.local|ZZ-108-37-T3$|ZZ-108-37|Lexmark|!3||!1|n|

        The printer ZZ-108-37 has 4 EPRS, and 1 destination.
        The printer ZZ-107-54 has 1 EPR and 1 destination.
    .PARAMETER SearchTerm
        This is the text to be searched for in the field selected by the LocateBy parameter.

        If we had these 5 records:
        server1.domain.local|ZZ-107-154|ZZ-107-154|RICOH|!1||!1|n|
        server1.domain.local|ZZ-108-37|ZZ-108-37|Lexmark|!1||!1|n|
        server1.domain.local|ZZ-108-37-RX$|ZZ-108-37|Lexmark|!257||!1|n|
        server1.domain.local|ZZ-108-37-T2$|ZZ-108-37|Lexmark|!2||!1|n|
        server1.domain.local|ZZ-108-37-T3$|ZZ-108-37|Lexmark|!3||!1|n|

        The record for ZZ-107-154 could be searched for in either the EPR or the Destination with the
        same term.  The record for ZZ-108-37-RX$ could be located using the EPR field.  If the
        admin were to select the destination ZZ-108-37, then all 4 EPRs for it would be deleted.

    .PARAMETER DoNotAppend
        The script builds a temporary eps_map file, and then copies it over the real eps_map.
        Using the DoNotAppend switch prevents this from happening, and the eps_map file is
        left untouched.

    .PARAMETER OverrideWarning
        By default, the script will not allow more than 1% of the records to be removed at a time.
        Using the OverrideWarning forces the script to accept any amount of changes.  This is a
        very dangerous operation and should be used with extreme caution.

    .INPUTS
        [String]
    .OUTPUTS
        [None]
    .NOTES
        The existing eps_map is backed up for safety and will be in the same directory with a
        timestamp.  The naming format is eps_map.yyyyMMdd_hhmm
        The temporary eps_map file that gets created is deleted at the end of the script.
        The script explicitly does not support wildcards in order to prevent unintended removals.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('EPR', 'Destination')]
        [string]$LocateBy,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String[]]$SearchTerm,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$DoNotAppend,

        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [switch]$OverrideWarning
    )

    begin {
        $EPSMapPath = [system.io.path]::combine($env:OMHOME, 'system', 'eps_map')
    }
    
    process {
        if (Test-Path -Path $EPSMapPath) {
            if (New-OMEPSMapBackup) {
                Write-Verbose -Message 'EPS_Map backed up'
            }
            elseif ($OverrideWarning) {
                Write-Warning -Message 'EPS_Map not backed up, but override specified; continuing function'
            }
            else {
                Throw -Message 'Not on the primary MPS; unable to continue'
            }

            $EPSMap                 = Get-OMEPSMap
            $TotalOriginalCount     = $EPSMap.EPSMap.Count

            $TempEPSMap             = New-TemporaryFile -WhatIf:$false
            $TempStream             = [System.IO.StreamWriter]::New($TempEPSMap.FullName)
        }
        else {
            throw 'Not on the primary MPS server, the eps_map cannot be modified here'
        }

        $EPSRecords = $EPSMap.EPSMap.Where{ $_.$LocateBy -notin $SearchTerm }
        $Message = 'Removing these EPS Records:{0}{1}' -f [Environment]::NewLine, $EPSRecords
        Write-Verbose -Message $Message -Verbose

        if ($PSCmdlet.ShouldProcess('Creating StreamWriter as a temporary eps_map file', '', '')) {
            $TempStream.WriteLine( ($EPSMap.Preamble -join [Environment]::NewLine) )
            $TempStream.WriteLine( [Environment]::NewLine )
        }

        foreach ($item in $EPSRecords) {
            $RecordString = $item.PSObject.Properties.Value -join '|'
            Write-Verbose -Message $RecordString
            if ($PSCmdlet.ShouldProcess(('Creating EPR string ({0})' -f $RecordString), '', '')) {
                $TempStream.WriteLine( $RecordString)
            }
        }

        $TempStream.Flush()
        $TempStream.Dispose()

        if ($PSCmdlet.ShouldProcess('Copying back to the correct location, and running Update-TransformServer', '', '')) {
            $ThresholdPercentage = [math]::Round( $( ($TotalOriginalCount - $EPSRecords.Count)/$TotalOriginalCount * 100), [MidpointRounding]::AwayFromZero)
            if ($OverrideWarning) {
                $Message = '$OverrideWarning specified, ignoring the Threshold percentage{0}{1} records removed' -f $CRLF, ($TotalOriginalCount - $EPSRecords.count)
                Write-Warning -Message $Message
            }
            elseif ($ThresholdPercentage -gt 1) {
                throw ('Too many records are being removed ({0}), not proceeding' -f $EPSRecords.count)
            }
        }
    }
    end {
        if ($DoNotAppend) {
            Write-Verbose -Message 'DoNotAppend specified; not copying the temporary file'
        }
        else {
            do {
                try {
                    Copy-Item -Path $TempEPSMap.FullName -Destination $EPSMap.FilePath -Force -ErrorAction Stop
                    $CopySucceeded = $true 
                }
                catch {
                    $errorCounter ++
                    Write-Verbose -Message 'Failed to copy eps_map'
                    Start-Sleep -Milliseconds 500
                }
            } until ($CopySucceeded -or ($errorCounter -ge 10) )
        }

        if ($CopySucceeded) {
            $Message = @'
            Total Beginning Records: {0}
            Total End Records:       {1}
            Total Filtered Count:    {2}
'@
            $Message = $Message -f $TotalOriginalCount, $EPSRecords.Count, ($TotalOriginalCount - $EPSRecords.Count )
            Write-Verbose -Message $Message
            if ($PSCmdlet.ShouldProcess('Would run Update-OMTransformServer', '', '')) {
                Update-OMTransformServer
            }
        }
        else {
            Write-Warning 'Unable to copy the updated eps_map'
        }
        Remove-Item -Path $TempEPSMap -ErrorAction SilentlyContinue
    }
}
