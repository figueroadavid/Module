function Disable-OMPrimaryMPS {
    $ServerRole = Get-OMServerRole
    if ($ServerRole -notmatch 'MPS') {
        throw 'The server is not the OMPlus primary Master Print Server'
    }

    try {
        Get-Service -Name ompSrv -ErrorAction Stop| 
            Set-Service -StartupType Disabled -PassThru -ErrorAction Stop|
            Stop-Service -Force -ErrorAction Stop
        Write-Verbose -Message 'Successfully disabled and stopped the ompServ service'    
    }
    catch {
        $_.Exception.Message
    }



}