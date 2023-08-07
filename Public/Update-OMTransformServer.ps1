function Update-OMTransformServer {
    <#
    .SYNOPSIS
        It uses the pingmsg.exe utility to trigger updates on the Transform servers

    .DESCRIPTION
        It uses the sendHosts file which contains the FQDN's of all the transform servers to
        send the updates. The primary goal is to replicate the eps_map file from the .\system directory
        on the master print server to the .\constants folder on the transform servers.
    .EXAMPLE
        PS C:\> Update-OMlusTransformServer -verbose 
        VERBOSE: On the primary MPS, continuing
        VERBOSE: The eps_map hashes are not the same; updating this host VOMPLUSTRNP01
        VERBOSE: Using pingmsg to update host: VOMPLUSTRNP01
        VERBOSE: The eps_map hashes are not the same; updating this host VOMPLUSTRNP02
        VERBOSE: Using pingmsg to update host: VOMPLUSTRNP02
        VERBOSE: The eps_map hashes are not the same; updating this host VOMPLUSTRNP03
        VERBOSE: Using pingmsg to update host: VOMPLUSTRNP03
        VERBOSE: The eps_map hashes are not the same; updating this host VOMPLUSTRNP04
        VERBOSE: Using pingmsg to update host: VOMPLUSTRNP04
    .EXAMPLE
        PS C:\> Update-OMTransformServer -Verbose
        VERBOSE: On the primary MPS, continuing
        VERBOSE: The filehashes are identical for VOMPLUSTRNP01; not running the update
        VERBOSE: The filehashes are identical for VOMPLUSTRNP02; not running the update
        VERBOSE: The filehashes are identical for VOMPLUSTRNP03; not running the update
        VERBOSE: The filehashes are identical for VOMPLUSTRNP04; not running the update
    .PARAMETER HashAlgorithm
        Lets the user specify an algorithm for the filehash checking. 
        It is set to a default of SHA256.  
        The options are 'SHA1','SHA256','SHA384','SHA512','MD5'
    .INPUTS
        [string]
    .OUTPUTS
        [none]
    .NOTES
        By default, external changes to the eps_map file do not get replicated to the Transforms servers,
        so this function is necessary to guarantee the changes made are replicated to them.
    #>

    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('SHA1','SHA256','SHA384','SHA512','MD5')]
        [String]$HashAlgorithm  = 'SHA256'
    )

    $EPSMapPath     = [System.IO.Path]::Combine($env:OMHOME, 'system', 'eps_map')

    if (Test-Path -Path $EPSMapPath) {
        Write-Verbose -Message 'On the primary MPS, continuing'
        $EPSMapFileHash = Get-FileHash -Path $EPSMapPath -Algorithm $HashAlgorithm | 
                            Select-Object -ExpandProperty Hash
    }
    else {
        throw 'Not on the Primary MPS, unable to proceed'
    }

    $PingMsgPath        = [IO.Path]::Combine($env:OMHOME, 'bin', 'pingmsg.exe')
    $TransformServers   = Get-Content -Path ([System.IO.Path]::Combine($env:OMHOME, 'system', 'sendHosts'))

    $GetRemoteEPSHash = {
        $EPSMapPath     = [system.io.path]::Combine($env:OMHOME, 'constants', 'eps_map')
        Get-FileHash -Path $EPSMapPath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    }

    $TransformServers | foreach-object {
        $thisHost       = $_
        $TransformHash  = Invoke-Command -ComputerName $thisHost -ScriptBlock $GetRemoteEPSHash
        if ($TransformHash -eq $EPSMapFileHash) {
            $Message    = 'The filehashes are identical for {0}; not running the update' -f $thisHost
            Write-Verbose -Message $Message
        }
        else {
            $Message    = 'The eps_map hashes are not the same; updating this host {0}' -f $thisHost
            Write-Verbose -Message $Message
            Write-Verbose -Message ('Using pingmsg to update host: {0}' -f $thisHost )
            $pingSplat = @{
                FilePath            = $PingMsgPath
                ArgumentList        = $thisHost
                Wait                = $true
                WindowStyle         = 'Hidden'
                WorkingDirectory    = [system.io.path]::Combine($env:OMHOME, 'bin')
            }
            Start-Process @pingSplat -Verb RunAs
        }
    }
}
