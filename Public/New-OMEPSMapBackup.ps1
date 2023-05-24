function New-OMEPSMapBackup {
    <#
    .SYNOPSIS
        Creates backups of the current eps_map file
    .DESCRIPTION
        Creates copies of the current eps_map file;
        If there are more than 10 backup copies, the oldest one is deleted when the backup copy is succesfully created
    .EXAMPLE
        PS C:\> New-OMEPSBackup
        True
    .INPUTS
        [none]
    .OUTPUTS
        [bool]
    .NOTES
        The script returns a true or false if the backup succeeds, or does not.
        It also performs some self-management of backups.
    #>
    [cmdletbinding()]
    param()
    if ($Script:IsPrimaryMPS) {
        $OMSystemPath = [system.io.path]::combine($env:OMHOME, 'system')

        $EPSMap_Today   = 'eps_map.{0:yyyyMMdd}' -f [datetime]::Today
        $EPSMapPath     = [io.path]::combine($OMSystemPath, 'eps_map')
        $BackupPath     = [io.path]::Combine($OMSystemPath, ('eps_map.{0:yyyyMMdd_hhmm}' -f [datetime]::Now))

        $BackupList = Get-ChildItem -Path $OMSystemPath -Filter 'eps_map*' |
                        Where-Object { $_.name -notmatch '^eps_map$' -and $_.name -notmatch $EPSMap_Today } |
                        Sort-Object -Property CreationTime
        try {
            Copy-Item -Path $EPSMapPath -Destination $BackupPath -ErrorAction Stop
            Write-Verbose -Message ('eps_map file backed up to {0}' -f $BackupPath)

            if ($BackupList.Count -gt 10) {
                for ($i = $BackupList.Count; $i -lt 10; $i--) {
                    try {
                        Remove-Item -Path $BackupList[($i - 1)] -ErrorAction Stop
                    }
                    catch {
                        Write-Warning -Message ('Backup count is greater than 10 and failed to remove oldest backup ({0})' -f $BackupPath)
                    }
                }
            }

            $true
        }
        catch {
            Write-Warning -Message 'Unable to backup eps_map file'
            $false
        }
    }
    else {
        Write-Warning -Message 'Not on primary MPS server; no updates being issued'
        $false
    }
}
