function Enable-TransformServer {
    $ServerRole = Get-OMServerRole
    if ($ServerRole -notmatch 'TRN') {
        throw 'Not on an OMPlus Transform server; not disabling this server'
    }

    try {
        Get-Service -Name OMIppServ -ErrorAction Stop | 
            Set-Service -StartupType Automatic -PassThru -ErrorAction Stop |
            Start-Service -Force -ErrorAction Stop 
        Write-Verbose -Message 'Successfully enabled the OMIPPServ service'
    }
    catch {
        $_.Exception.Message
    }
}