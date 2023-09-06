function Remove-OMPDuplicateEPR {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [ValidateScript({
            Test-Path -path $_
        })]
        [string]$FilePath
    )

    if ($FilePath) {
        Write-Verbose -Message 'Using the file path provided'
    }
    else {
        $ServerRole = Get-OMServerRole 
        switch ($ServerRole) {
            'MPS' {
                Write-Verbose -Message 'On PrimaryMPS, proceeding'
            }
            'TRN'  {
                $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'receiveHosts'))
                Write-Warning -Message 'On a transform server; the eps_map should only be updated on the primary MPS: {0}' -f $PrimaryMPS
                return 
            }
            'BKP' {
                $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'pingMaster'))
                Write-Warning -Message 'On a transform server; the eps_map cannot only be updated on the secondary MPS; the primary MPS is: {0}' -f $PrimaryMPS
                return 
            }
            default {
                Write-Warning -Message 'Not on an OMPlus server'
                return 
            }
        }
    }

    $DupRecords = $EPSMap.EPSMap | Group-Object -Property 'EPR' | Where-Object Count -gt 1
    Write-Warning -Message 'THIS IS NOT READY FOR PRODUCTION YET - IT DOES NOT ACTUALLY DO ANYTHING YET'
}
