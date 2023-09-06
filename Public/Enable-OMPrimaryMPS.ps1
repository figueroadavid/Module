function Enable-OMPrimaryMPS {
    $ServerRole = Get-OMServerRole
    if ($ServerRole -notmatch 'MPS') {
        throw 'The server is not the OMPlus primary Master Print Server'
    }

    try {
        Get-Service -Name ompSrv -ErrorAction Stop | 
            Set-Service -StartupType Automatic -PassThru -ErrorAction Stop |
            Start-Service -Force -ErrorAction Stop
        Write-Verbose -Message 'Successfully enabled the ompServ service'
    }
    catch {
        $_.Exception.Message
    }
}