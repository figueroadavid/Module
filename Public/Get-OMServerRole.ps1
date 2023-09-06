function Get-OMServerRole {
    <#
    .SYNOPSIS
        This returns the role of the server in the OMPlus ecosystem.
    .DESCRIPTION
        The system checks for the location of the eps_map file to determine if it is the primary MPS, or a transform server.
        If it is not in either location it checks for the OMHOME environment variable, which would make it the 
        backup MPS.  If none of these apply, then it is assumed that OMPlus is not installed.
    .NOTES
        This is primarily used by other functions in the module, since not all functions apply to all roles. 
    .EXAMPLE
        PS C:\> Get-OMServerRole
        MPS
    .EXAMPLE
        PS C:\> Get-OMServerRole
        TRN
    .EXAMPLE
        PS C:\> Get-OMServerRole
        BKP
    #>
    
    
    $TransformEPSPath   = [system.io.path]::Combine($env:omhome, 'constants', 'eps_map')
    $MPSEPSPath         = [system.io.path]::Combine($env:omhome, 'system', 'eps_map')
    if (Test-Path -Path $TransformEPSPath) {
        $ServerRole     = 'TRN'
    }
    elseif (Test-Path -Path $MPSEPSPath) {
        $ServerRole     = 'MPS'
    } 
    elseif ($env:omhome) {
        $ServerRole     = 'BKP'
    }
    else {
        $ServerRole     = 'NOT'
        Write-Warning 'This is NOT an OMPlus server'
    }
    $ServerRole
}