function Update-OMTransformServer {
    <#
    .SYNOPSIS
        It uses the pingmsg.exe utility to trigger updates on the Transform servers

    .DESCRIPTION
        It uses the sendHosts file which contains the FQDN's of all the transform servers to
        send the updates. The primary goal is to replicate the eps_map file from the .\system directory
        on the master print server to the .\constants folder on the transform servers.
    .EXAMPLE
        PS C:\> Update-OMlusTransformServer
        Using pingmsg to update host: srvtran01
        Using pingmsg to update host: srvtran02
        Using pingmsg to update host: srvtran03
        Using pingmsg to update host: srvtran04
    .INPUTS
        [none]
    .OUTPUTS
        [none]
    .NOTES
        By default, external changes to the eps_map file do not get replicated to the Transforms servers,
        so this function is necessary to guarantee the changes made are replicated to them.
    #>

    [cmdletbinding()]
    param()
    if ($Script:IsPrimaryMPS) {
        Write-Verbose -Message 'On the primary MPS, continuing'
    }
    else {
        throw 'Not on the Primary MPS, unable to proceed'
    }

    $PingMsgPath                = [IO.Path]::Combine($env:OMHOME, 'bin', 'pingmsg.exe')
    if ($Script:TransformServers) {
        Write-Verbose -Message '$Script:TransformServers exists'
    }
    else {
        Write-Warning -Message '$Script:TransformServers variable is missing; recreating, but please investigate'
        $Script:TransformServers = Get-Content -Path ([System.IO.Path]::Combine($env:OMHOME, 'system', 'sendHosts'))
    }

    $Script:TransformServers | ForEach-Object {
        $thisHost               = $_
        Write-Verbose -Message ('Using pingmsg to update host: {0}' -f $thisHost ) -Verbose
        $pingSplat = @{
            FilePath            = $PingMsgPath
            ArgumentList        = $thisHost
            Wait                = $true
            WindowStyle         = 'Hidden'
            WorkingDirectory    = [system.io.path]::Combine($env:OMHOME, 'bin')
        }
        Write-Verbose -Message ('Triggering update for {0}' -f $thisHost) -Verbose
        Start-Process @pingSplat -Verb RunAs
    }
}
