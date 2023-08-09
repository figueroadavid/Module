function Show-OMPlusHealthCheck {
    <#
        .SYNOPSIS
            Runs a general health check against the different OMPlus servers.
        .DESCRIPTION
            This runs several functions based on the switches used to run a healthcheck against the OMPlus environment.
            It MUST be run from one of the OMPlus servers, and all fo the OMPlus servers need to have the OMPlus module installed.
        .PARAMETER ComputerName
            The name of the computer to execute the Health Check on.  If it is not the local server, 
            the server is accessed through Powershell Remoting
        .PARAMETER IncludeDCCInfo
            This tells the script to retrieve the DCCInfo cmdlet 
        .PARAMETER IncludeImportantJobCounts
            This tells the script to include just the "important" job counts - this includes ready,prntd,can,intrd
        .PARAMETER IncludeAllJobCounts
            This tells the script to include the counts for all available statuses on the system
        .PARAMETER IncludeServices
            This tells the script to include information about the OMPlus services, and the Print Spooler.
        .PARAMETER IncludeDisabledQueues
            This tells the script to include information about which print queues are disabled on the server.
            This includes the pt_transform queues on the Transform servers.
        .PARAMETER IncludeEPSSyncStatus
            This tells the script to check the synchronization status of the eps_map file.  If the script is run on 
            the MPS server, it shows the comparison to all of the Transform servers.  If it is run on a Transform 
            server, it only compares the MPS and that particular Transform server.
        .NOTES
            This script requires powershell remoting to be active on all of the servers involved.
        .EXAMPLE
            
    #>

    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeDCCInfo,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeImportantJobCounts,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeAllJobCounts,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeServices,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeDisabledQueues,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IncludeEPSSyncStatus 
    )

    begin {
        # Self-elevate the script if required
        if ( ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') -eq $false) {
            if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
                $CommandLine = ('-File "{0} {1}"' -f $MyInvocation.MyCommand.Path, $MyInvocation.UnboundArguments)
                Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
                Exit
            }
        }

        if ( $null = Get-Module -Name OMPlus) {
            try { 
                Write-Verbose -Message 'Trying to load OMPlus module'
                Import-Module -Name OMPlus -ErrorAction Stop
            }
            catch {
                throw 'Unable to load OMPlus module, unable to proceed'
            }
        }

        $GetDCCInfo = {
            dccinfo | ForEach-Object {
                if ($_ -match '^(?<key>.+?)(\s{2}|\s*[:=]\s*)(?<value>.+)') {
                    $thisKey    = ($Matches['key']).Trim()
                    $thisValue  = $Matches['value']

                    if ($thisValue -is [string]) {
                        $thisValue = $thisValue.Trim()
                    }
                    
                    switch -Regex ($thisKey) {
                        'bytes$' {
                            if ($thisValue -match '\D+') {
                                Write-Verbose -Message 'The value is not a digit, no transform needed'
                            }
                            else {
                                $thisKey = '{0}_in_GB' -f $thisKey 
                                $thisValue = [math]::Round( $thisValue/1GB,2)
                            }
                            break 
                        }
                        'size$' {
                            $thisKey = '{0}_in_MB' -f $thisKey 
                            $thisValue = [math]::Round( $thisValue/1MB,2)
                            break
                        }
                    }

                    [pscustomobject]@{
                        'Key'           = $thisKey
                        'Value'         = $thisValue
                    }
                }
                else {
                    Write-Warning -Message 'The output data does not match the expected format.  That data is: {0}' -f $_
                }
            } | Format-Table -AutoSize
        }

        $GetServiceInfo = {
            $TransformEPSPath   = [system.io.path]::Combine($env:omhome, 'constants', 'eps_map')
            $MPSEPSPath         = [system.io.path]::Combine($env:omhome, 'constants', 'eps_map')
            if (Test-Path -Path $TransformEPSPath) {
                $ServerRole     = 'TRN'
            }
            elseif (Test-Path -Path $MPSEPSPath) {
                $ServerRole     = 'MPS'
            } 
            else {
                $ServerRole     = 'BKP'
            }

            $ServiceNotes       = @{
                OMAdminServ         = 'Admin service; this communicates with the various interfaces'
                OMe2eServ           = 'End2End service; this handles the communication between servers'
                OMIPPServ           = 'IPP Service; this communicates with Epic, and with printers runnning IPP; it is critical on Transform servers'
                ompLogServ          = 'Logging service; this logs the activities to the central log on the server'
                ompServ             = 'This is the service on the MPS that receives the jobs from the transform servers; it is critical on the MPS'
                omRemoteServ        = 'This transmits the eps_map and the OM_EPS_WIN_Queues.csv from the MPS to the Transform servers'
                OMSchedServ         = 'This is the service that actually runs the jobs'
                OMStatusServ        = 'This communicates the status to the UIs in conjunction with the admin service; it is critical'
                OMLPSServ           = 'This is the LPD service, we do not use it at HHS'
                OMMSEmailClientServ = 'This is the email client service, we do not use it at HHS'
                OMScanServ          = 'This is the scanning service, we do not use it at HHS'
                iSat                = 'This is the iSatellite client service, we do not use it at HHS'
                iSatServ            = 'This is the iSatellite server service, we do not use it at HHS'
            }
            Get-Service -Name om*,isat* | 
                Select-Object -Property Name,Status,@{n='Notes'; e={$ServiceNotes[$_.Name]}}
        }

        $GetDisabledQueues = {
            '-- {0} --' -f $Computer
            $DisabledList = Get-OMDisabledDestination
            'Total Disabled Queues: {0}' -f $DisabledList.Count 
            $DisabledList
        }

        $GetImportantJobCounts = {
            Get-OMJobCountbyStatus -Status prntd,ready,can,intrd 
        }

        $GetAllJobCounts = {
            Get-OMJobCountbyStatus -Status all  
        }

        $GetEPSSyncStatus = {
            $TransformEPSPath    = [system.io.path]::Combine($env:omhome, 'constants', 'eps_map')
            $MPSEPSPath          = [system.io.path]::Combine($env:omhome, 'system', 'eps_map')

            if (Test-Path -Path $TransformEPSPath) {
                $LocalEPSHash    = Get-FileHash -Path $TransformEPSPath -Algorithm SHA256| 
                    Select-Object -ExpandProperty Hash
                
                $pingHostPath    = [environment]::Combine($env:omhome, 'system', 'pingHost')
                $MPSComputerName = Get-Content -Path $pingHostPath

                $MPSFileHash     = Invoke-Command -ComputerName $MPSComputerName -ScriptBlock {
                    $MPSEPSPath  = [system.io.path]::Combine($env:omhome, 'system', 'eps_map')
                    Get-FileHash -Path $MPSEPSPath -Algorithm SHA256 |
                        Select-Object -ExpandProperty Hash
                }

                if ($LocalEPSHash -eq $MPSFileHash) {
                    Write-Verbose -Message 'The eps_map file is in sync with the MPS' -Verbose
                }
                else {
                    Write-Warning -Message 'The eps_map file is NOT in sync with the MPS'
                }
            }
            elseif (Test-Path -Path $MPSEPSPath) {
                $LocalEPSHash    = Get-FileHash -Path $MPSEPSPath -Algorithm SHA256| 
                    Select-Object -ExpandProperty Hash
                
                $sendHostPath    = [System.IO.Path]::Combine($env:omhome, 'system', 'sendHosts')
                $TRNComputerName = Get-Content -Path $sendHostPath

                ForEach ($computer in $TRNComputerName) {
                    $TRNFileHash     = Invoke-Command -ComputerName $Computer -ScriptBlock {
                        $TRNEPSPath  = [system.io.path]::Combine($env:omhome, 'constants', 'eps_map')
                        Get-FileHash -Path $TRNEPSPath -Algorithm SHA256 |
                            Select-Object -ExpandProperty Hash
                    }
                    [pscustomobject]@{
                        ComputerName    = $computer
                        EPSIsInSync     = $TRNFileHash -eq $LocalEPSHash
                        MPSHash         = $LocalEPSHash
                        TRNHash         = $TRNFileHash
                    }
                }
            } 
            else {
                Write-Warning -Message 'This is a backup MPS server, it does not have a copy of the eps_map file'
            }

        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            $ComputerBanner = $Computer.PadLeft(60,'-')
            $ComputerBanner = $ComputerBanner.PadRight(120,'-')
            $Banner = '{0}{1}{2}{1}{0}' -f $('-' * 120),"`r`n", $ComputerBanner 
            $Banner 

            if ($Computer -eq $env:COMPUTERNAME) {
                $RunLocal = $true
            }
            else {
                $RunLocal = $false
                if (Test-WSMan -ComputerName $Computer) {
                    try {
                        $Session = New-PSSession -ComputerName $Computer 
                        Invoke-Command -Session $Session -ScriptBlock { 
                            try {
                                Import-Module OMPlus -ErrorAction Stop 
                            }
                            catch {
                                throw ('Unable to load OMPlus on [{0}]' -f $env:COMPUTERNAME) 
                            }
                        }
                    }
                    catch {
                        $Message = 'Unable to create remoting session and/or import the OMPlus module; skipping this server: {0}' -f $Computer 
                        Write-Warning -Message $Message
                        return 
                    }
                }
            }

            if ($IncludeDCCInfo) {
                if ($RunLocal) {
                    & $GetDCCInfo
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetDCCInfo
                }
            }

            if ($IncludeServices) {
                if ($RunLocal) {
                    & $GetServiceInfo
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetServiceInfo
                }
            }
            
            if ($IncludeDisabledQueues) {
                if ($RunLocal) {
                    & $GetDisabledQueues
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetDisabledQueues
                }
            }

            if ($IncludeImportantJobCounts -and -not $IncludeImportantJobCounts) {
                if ($RunLocal) {
                    & $GetImportantJobCounts
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetImportantJobCounts
                }
            }

            if ($IncludeAllJobCounts) {
                if ($RunLocal) {
                    & $GetAllJobCounts
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetAllJobCounts
                }
            }

            if ($IncludeEPSSyncStatus) {
                if ($RunLocal) {
                    & $GetEPSSyncStatus
                }
                else {
                    Invoke-Command -Session $Session -ScriptBlock $GetEPSSyncStatus
                }
            }

            if (-not $RunLocal) {
                Remove-PSSession -Session $Session
            }
        }
    }
}