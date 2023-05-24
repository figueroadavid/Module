function Remove-OMPDuplicateEPR {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [ValidateScript({
            Test-Path -path $_
        })]
        [string]$FilePath
    )

    if ($IsPrimaryMPS -or $FilePath) {
        Write-Verbose -Message 'On Primary MPS, continuing'
        if ($IsPrimaryMPS) {
            $EPSMap = Get-OMEPSMap
        }
        else {
            $EPSMap = Get-OMEPSMap -FilePath $FilePath
        }
    }
    else {
        throw 'Not on PrimaryMPS'
    }

    $DupRecords = $EPSMap.EPSMap | Group-Object -Property 'EPR' | Where-Object Count -gt 1
    Write-Warning -Message 'THIS IS NOT READY FOR PRODUCTION YET - IT DOES NOT ACTUALLY DO ANYTHING YET'
}
