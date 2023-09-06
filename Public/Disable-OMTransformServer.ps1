function Disable-OMTransformServer {
    $ServerRole = Get-OMServerRole
    if ($ServerRole -notmatch 'TRN') {
        throw 'Not on an OMPlus Transform server; not disabling this server'
    }

    try {
        Get-Service -Name OMIppServ -ErrorAction Stop| 
            Set-Service -StartupType Disabled -PassThru -ErrorAction Stop|
            Stop-Service -Force -ErrorAction Stop
        Write-Verbose -Message 'Successfully disabled the OMIPPServ service'
    }
    catch {
        $_.Exception.Message
    }
}