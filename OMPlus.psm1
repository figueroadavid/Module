using namespace system.io

$thisHostName = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).hostname

if (Test-Path -Path ([System.IO.Path]::combine($env:OMHOME, 'system', 'OM_EPS_WIN_Queues.csv'))) {
    Write-Verbose -Message ('Found OM_EPS_WIN_Queues.csv, we are the primary MPS')
    $Script:IsPrimaryMPS        = $true
    $Script:PrimaryMPS          = $thisHostName

    $Script:pingParms           = [System.IO.Path]::combine($env:OMHOME, 'system', 'pingParms')
    $Script:SecondaryMPS        = (Get-Content -Raw -Path $pingParms | ConvertFrom-StringData)['backup']

    $Script:TransformServers    = Get-Content -Path ([System.IO.Path]::combine($env:OMHOME, 'system', 'sendHosts'))

    $Script:OMQueuePath         = [System.IO.Path]::combine($env:OMHOME, 'system', 'OM_EPS_WIN_Queues.csv')
    $Script:OMDrivers           = ((Get-Content -path $OMQueuePath).Where{ $_ -match ',' }).Replace(',', '=') |
                                    ConvertFrom-StringData

    $Script:TypesConf           = [xml]::new()
    $Script:TypesConf.Load( $([System.IO.Path]::combine($env:OMHOME, 'system', 'types.conf')) )

    $Script:ValidModels         = Get-ChildItem -Path ([System.IO.Path]::combine($env:OMHOME, 'model')) | Select-Object -ExpandProperty BaseName
}
elseif ( Test-Path -path ([System.IO.Path]::combine($env:OMHome, 'constants', 'server_backup')) ) {
    $Script:IsTransformServer   = $true
    $Script:PrimaryMPS, $Script:SecondaryMPS  = (Get-Content -path ([System.IO.Path]::combine($env:OMHOME, 'system', 'server_backup')) |
                                    Where-Object { $_ -match ':' }).Split(':')
    $Script:OMQueuePath         = [System.IO.Path]::Combine($env:OMHOME, 'constants', 'om_eps_win_queues.csv')
    $Script:OMDrivers           = ((Get-Content -path $OMQueuePath).Where{ $_ -match ',' }).Replace(',', '=') |
                                    ConvertFrom-StringData
}
else {
    Write-Verbose -Message ('OM_EPS_WIN_Queues.csv NOT found, we are not on the primary MPS')
    $Script:PrimaryMPS          = Get-Content -Path ([System.IO.Path]::combine($env:OMHOME, 'system', 'pingMaster'))
    $Script:SecondaryMPS        = $thisHostName
}

Get-ChildItem -Path $PSScriptRoot\Private -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName )
        . $_.FullName
    }

Get-ChildItem -Path $PSScriptRoot\Public -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName )
        . $_.FullName
    }

$Script:CRLF                    = [System.Environment]::NewLine
$Script:TAB                     = "`t"

$Script:EPSHeader = 'Server','EPR','Destination','Driver','Tray','Duplex','Paper','RX','Media'

<#
    Module debugging:
    $Module = Get-Module omplus
    $Command = { $host.enternestedprompt() }
    & $Module $command

    & (Get-Module <name>) { $Host.EnterNestedPrompt() }
    -- don't forget to exit it
    & (Get-Module <name>) { $Script:varname }

    & (module) { command }
#>
