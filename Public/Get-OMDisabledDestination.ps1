function Get-OMDisabledDestination {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Display', 'Email')]
        [string]$Output,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPFrom = ('DisabledMonitor_{0}@harrishealth.org' -f $env:COMPUTERNAME),

        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$SMTPTo = @('david.figueroa@harrishealth.org'),

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPSubject = ('Disabled print queues on {0}' -f $env:COMPUTERNAME),

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPServer = 'hhexch01.hchd.local',

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPPort = 25,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$SendEmailEvenIfNoDisabledPrinters
    )
    $AllPrinters = Get-OMPrinterList -Filter *
    $DisabledPrinters = foreach ($Printer in $AllPrinters) {
        Get-OMPrinterConfiguration -PrinterName $Printer -Property Enable |
            Where-Object Enable -eq 'n' |
            Select-Object -ExpandProperty Printer
    }

    if ($DisabledPrinters.Count -gt 0) {
        if ($Output -eq 'Email') {
            $SMTPSplat = @{
                To          = $SMTPTo
                From        = $SMTPFrom
                Subject     = $SMTPSubject
                SMTPServer  = $SMTPServer
                Port        = $SMTPPort
            }
            $SMTPSplat['Body'] = $DisabledPrinters -join [System.Environment]::NewLine
            Send-MailMessage @SMTPSplat
        }
        else {
            $DisabledPrinters
        }
    }
    else {
        Write-Verbose -Message 'No disabled printers found'
    }
}