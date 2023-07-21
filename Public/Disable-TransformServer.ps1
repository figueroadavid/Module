function Disable-OMTransformServer {
    $EPSPath            = [system.io.path]::Combine($env:omhome, 'system', 'eps_map') 
    
    $PingMasterPath     = [System.IO.Path]::Combine($env:home, 'system', 'pingMaster')
    $PingMasterIsNone   = (Get-Content -Path $PingMasterPath ) -match '^none$'

    if (-not(Test-Path -Path $EPSPath) -and $PingMasterIsNone) {
        Write-Verbose -Message 'Currently on a Transform server'
        try {
            Get-Service -Name OMIppServ | 
                Set-Service -StartupType Disabled -PassThru |
                Stop-Service -Force
            Write-Verbose -Message 'Successfully disabled the OMIPPServ service'
        }
        catch {
            $_.Exception.Message
        }
        
    }
    else {
        Write-Warning -Message 'Not on a transform server, not proceeding'
    }
}