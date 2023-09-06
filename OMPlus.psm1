using namespace system.io

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
