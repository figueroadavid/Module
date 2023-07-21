function Enable-OMPrimaryMPS {
    $EPSPath            = [system.io.path]::Combine($env:omhome, 'system', 'eps_map') 
    
    $PingMasterPath     = [System.IO.Path]::Combine($env:home, 'system', 'pingMaster')
    $PingMasterIsNone   = (Get-Content -Path $PingMasterPath ) -match '^none$'

    if (Test-Path -Path $EPSPath -and $PingMasterIsNone) {
        Write-Verbose -Message 'Currently on a primary master print server'
        try {
            Get-Service -Name ompSrv | 
                Set-Service -StartupType Automatic -PassThru |
                Start-Service -Force
            Write-Verbose -Message 'Successfully enabled the ompServ service'
        }
        catch {
            $_.Exception.Message
        }
        
    }
    else {
        Write-Warning -Message 'Not on primary master print server, not proceeding'
    }
}