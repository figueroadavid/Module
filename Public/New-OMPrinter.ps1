Function New-OMPrinter {
    <#
    .SYNOPSIS
        Creates printers for OMPlus

    .DESCRIPTION
        Takes a set of parameters and generates a command line string for the OMPlus utility lpadmin.exe

    .EXAMPLE
        PS C:\> $PrintSplat = @{
            IsTesting 				= $true
            PrinterName 			= 'TestPrinter'
            IPAddress 				= '10.0.4.112'
            Port					= 9100
            Comment 				= 'Beaker'
            HasInternalWebServer 	= $true
            ForceWebServer 			= $true
            PurgeTime 				= 45
            PageLimit 				= 5
            Notes 					= 'Test Notes'
            SupportNotes 			= 'Support Notes'
            WriteTimeout 			= 60
            Model 				    = 'omstandard.js'
            Mode 					= 'termserv'
            FormType 				= 'Letter'
            PCAPPath 				= 'c:\temp\test.pcap'
            CPSMetering 			= 5000
            Banner 					= $true
            FileBreak 				= $true
            CopyBreak 				= $true
            DoNotValidate 			= $true
            LFtoCRLF 				= $true
            InsertMissingFF 		= $true
        }
        PS C:\> New-OMPrinter @PrintSplat
        D:\Plustech\OMPlus\Server\\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -omode="termserv" -opurgetime=45
        -ourl="http://10.0.4.112" -ometering=5000 -oPcap="c:\temp\test.pcap" -opagelimit=5 -onoteinfo="Test Notes" -z
        -owritetime=60 -ocmnt="Beaker" -obanner -oform="Letter" -olfc -onocopybreak -osupport="Support Notes"
        -omode="termserv" -ofilesometimes -onofilebreak -oPTomstandard.js

        This example inputs many different parameters and outputs the intended command line (because we are using
        the IsTesting parameter)
    .INPUTS
        [string]
        [IPAddress]
        [int]
        [switch]
        [bool]

    .OUTPUTS
        [string]

    .NOTES
        This command assembles the command line string for the lpadmin.exe utility.  This is a very complex
        utility with numerous options.  This script simplifies the typing and allows for an easier
        bulk creation of printers.

        It creates the mandatory parameters in a collection, and then it adds the other subsequent parameters
        as supplied by the user.   The string is then output and the lpadmin.exe command line is either displayed
        or executed.

        This script was built referencing the OMPlus Delivery Manager PDF from PlusTechnologies

    .PARAMETER PrinterName
        This is the name of the printer to create

    .PARAMETER IPAddress
        This is the ip address of the printer that will be created.  The script was built around IPv4, but
        there is nothing in the script to prevent it from using IPv6 (if lpadmin.exe supports it)
        The script checks if the passed value is a legitimate IP Address.  If it is not, then it checks if the supplied
        value is a resolvable name, and it throws an error if it is a name and is not resolvable.

    .PARAMETER Port
        This is the TCP Port to use for printing on the newly created printer.
        It defaults to standard TCP/IP printing on port 9100

    .PARAMETER LPRPort
        This is the queue name used for LPR/LPD printers

    .PARAMETER Comment
        This is the optional comment for the printer.

    .PARAMETER HasInternalWebServer
        This is used to flag the printer as having a supporting web page.
        If a CustomURL is not supplied, the script will test for port 80 (http://<ipaddress>) and if that fails,
        it will attempt port 443 (https://<ipaddress>), and if that fails, a warning is written and nothing is added for it.
        However, if -ForceWebServer is specified, it will add it as http even though the port is not
        responding when the script is run.

    .PARAMETER CustomURL
        If the HasInternalWebServer switch is used, and this parameter is provided, this will be inserted as
        the URL to use for accessing the print server.  No validation is done against this CustomURL

    .PARAMETER ForceWebServer
        If the HasInternalWebServer switch is used and the print server is down/not responding, and this switch
        is used, the printer will be configured with a URL of http://<ipaddress> despite failing validation.

    .PARAMETER UseEpicFormat
        This converts printer names to upper case and replaces any spaces with hyphens.  This helps the name
        to conform to Epic requirements.

    .PARAMETER PurgeTime
        This is the length of time (in seconds) a document is held before being purged.

    .PARAMETER PageLimit
        Specified the maximum number of pages that will be printed in a single job

    .PARAMETER Notes
        Adds text notes to the printer in the supported Notes field. If the value supplied to this parameter contains
        double quotes ("), they are stripped out automatically to prevent command line issues.

    .PARAMETER SupportNotes
        Adds text notes to the printer in the supported SupportNotes field. If the value supplied to this parameter contains
        double quotes ("), they are stripped out automatically to prevent command line issues.

    .PARAMETER WriteTimeout
        Sets the amount of time that a print job must complete in before it is terminated

    .PARAMETER TranslationTable
        Sets a different translation table for the print jobs

    .PARAMETER Model
        Selects the correct type/model of driver for the printer.  The list of drivers can be obtained using the
        Get-OMDriverNames function.

    .PARAMETER Mode
        Selects the correct print mode for the printer. Most printers use the default value of 'termserv'
        The complete list is:
        'pipe','windows','termserv','netprint','ipp','telnet','alttelnet',
        'ftp','web','pager','fax','email','system','omplus','lpplus','directory',
        'reptdist','ecivprinter','Virtual','scsi','parallel','serial'

    .PARAMETER FormType
        Sets the printer to use a specific pre-defined form type.

    .PARAMETER PCAPPath
        If this is used, it defines the path where the PCAP capture will be outputted.
        This is primarily a troubleshooting function.

    .PARAMETER UserFilterPath
        Provides a path to a user-defined filter

    .PARAMETER Filter2
        Provides a path to a second user-defined filter

    .PARAMETER Filter3
        Provides a path to a third user-defined filter

    .PARAMETER CPSMetering
        Sets the maximum number of characters per second the printer will accept.
        Primarily for dot-matrix and band printers

    .PARAMETER Banner
        If this parameter is used with $true, a banner page is inserted
        If this parameter is used with $false, banner pages are turned off

    .PARAMETER DoNotValidate
        Turns on the -z switch so that OMPlus does not try to validate the existence of the printer
        before creating it.
        This is primarily for use with bulk creation of printers.

    .PARAMETER LFtoCRLF
        If this parameter is used with $true, LineFeeds are converted to Carriage Return/LineFeed characters
        If this parameter is used with $false, the conversion of LineFeed to Carriage Return/LineFeed is explicitly turned off

    .PARAMETER CopyBreak
        If this parameter is used with $true, a form feed is output between copies of a print job
        If this parameter is used with $false, form feeds between copies of a print job are explicitly turned off

    .PARAMETER FileBreak
        If this parameter is used with $true, a form feed is output between print jobs
        If this parameter is used with $false, form feeds between print jobs are explicitly turned off

    .PARAMETER InsertMissingFF
        Inserts a form feed at the end of a file if there is not one there already

    .PARAMETER IsTesting
        Used to test the output of the script.  It will generate the command line and output it, but not
        actually execute it.

    .PARAMETER UseEpicFormat
        Converts the supplied printername to UPPERCASE, and replaces any spaces in the name with underscores (_)
        This switch overrides UseEpicFormat

    .PARAMETER AllowMixedCase
        Allows the user to supply a printername in mixed case, otherwise, the printername is automatically converted
        to all UPPERCASE
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrinterName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if ($_ -is [ipaddress]) {
                $true
            }
            else {
                try {
                    $null = [net.dns]::GetHostByName($_)
                    $true
                }
                catch {
                    $Message = 'Could not resolve the ip address for {0}' -f $_
                    Write-Warning -Message $Message
                    $false
                }
            }
        })]
        [string]$IPAddress,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,65535)]
        [int]$TCPPort = 9100,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$LPRPort,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-ChildItem -Path $env:OMModel | Select-object -ExpandProperty 'BaseName' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('Model: {0}' -f $_ )
                    )
                }
        })]
        [string]$Model,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Comment,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$HasInternalWebServer,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$CustomURL,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ForceWebServer,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('termserv','netprint','pipe','windows','ipp','telnet','alttelnet',
                        'ftp','web','pager','fax','email','system','omplus','lpplus','directory',
                        'reptdist','ecivprinter','Virtual','scsi','parallel','serial')]
        [string]$Mode = 'termserv',

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('z')]
        [switch]$DoNotValidate,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$PurgeTime,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$PageLimit,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Notes,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SupportNotes,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$WriteTimeout,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$TranslationTable,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-ChildItem -Path $env:OMForms | Select-Object -ExpandProperty BaseName |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('FormType: {0}' -f $_ )
                    )
                }
        })]
        [string]$FormType,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$PCAPPath,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$UserFilterPath,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$Filter2,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$Filter3,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$CPSMetering,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$Banner,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('lfc')]
        [bool]$LFtoCRLF,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$CopyBreak,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$FileBreak,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('filesometimes')]
        [switch]$InsertMissingFF,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsTesting,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsFullTesting,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$UseEpicFormat,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$AllowMixedCase
    )

    Begin {

        $ServerRole = Get-OMServerRole 
        switch ($ServerRole) {
            'MPS' {
                Write-Verbose -Message 'On PrimaryMPS, proceeding'
            }
            'TRN'  {
                $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'receiveHosts'))
                Write-Warning -Message 'On a transform server; printers should only be created on the primary MPS: {0}' -f $PrimaryMPS
                return 
            }
            'BKP' {
                $PrimaryMPS  = Get-Content -Path ([system.io.path]::combine($env:OMHome, 'system', 'pingMaster'))
                Write-Warning -Message 'On the secondary MPS server, printers should only be created on the primary MPS: {0}' -f $PrimaryMPS
                return 
            }
            default {
                Write-Warning -Message 'Not on an OMPlus server'
                return 
            }
        }
    
        if ($IsFullTesting) {
            $PSBoundParameters
        }

        if ($AllowMixedCase -or $UseEpicFormat) {
            Write-Verbose -Message '$AllowMixedCase supplied, printernames will not be converted'
        }
        else {
            $PrinterName = $PrinterName.ToUpper()
        }

        if ($UseEpicFormat) {
            Write-Verbose -Message 'Set name to Upper case, and replace spaces with hyphens; this overrides AllowMixedCase'
            $PrinterName = $PrinterName.ToUpper().Replace(' ', '-')
        }

        if ($Model) {
            $ValidModels = Get-ChildItem -Path ([System.IO.Path]::combine($env:OMHOME, 'model')) | Select-Object -ExpandProperty BaseName
            if ($Model -in $ValidModels) {
                $Message = 'Model "{0}" is a valid type' -f $Model
                Write-Verbose -Message $Message
            }
            else {
                $Message = 'Model "{0}" is not a valid type.{1}ValidTypes are:{2}' -f $Model, $CRLF,($ValidModels -join $CRLF)
                throw $Message
            }
        }

        if ($Notes) {
            if ($Notes.Contains('"')) {
                $Notes = $Notes.Replace('"', "'")
                Write-Warning -Message 'The Notes parameter contains a double-quote, replacing it with a single quote'
            }
        }

        if ($SupportNotes) {
            if ($SupportNotes.Contains('"')) {
                $SupportNotes = $SupportNotes.Replace('"', "'")
                Write-Warning -Message 'The SupportNotes parameter contains a double-quote, replacing it with a single quote'
            }
        }
        if ($Comment) {
            if ($Comment.Contains('"')) {
                $Comment = $Comment.Replace('"', "'")
                Write-Warning -Message 'The Comment parameter contains a double-quote, replacing it with a single quote'
            }
        }
        if ($PCAPPath) {
            if ($PCAPPath.Contains('"')) {
                $PCAPPath = $PCAPPath.Replace('"', '')
                Write-Warning -Message 'The PCAPPath parameter contains a double-quote, stripping it out so that we do not have two sets of double quotes'
            }
        }

        $PrinterList = Get-OMPrinterList
        if ($PrinterName -in $PrinterList) {
            $Message = 'This printer ({0}) already exists; {1}Please re-run this command with either a new name or use the Set-OMPrinter command' -f $PrinterName, $CRLF
            Write-Warning -Message $Message
            return
        }
    }

    process {
        Write-Verbose -Message 'Begin building command line string for lpadmin'
        $ArgString = [Collections.Generic.List[string]]::New()
        $null = $ArgString.Add( ('-p{0}' -f $PrinterName) )
        if ($LPRPort) {
            $null = $ArgString.Add( ('-v{0}!{1}' -f $ipaddress, $LPRPort) )
            $null = $ArgString.Add( '-omode="netprint"' )
        }
        else {
            $null = $ArgString.Add( ('-v{0}!{1}' -f $IPAddress, $TCPPort))
            $null = $ArgString.Add( ('-omode="{0}"' -f $Mode))
        }

        foreach ($Parameter in $PSBoundParameters.Keys) {
            switch ($Parameter) {
                'Comment'           { $null = $ArgString.Add( ('-ocmnt="{0}"' -f $Comment) );                   break}
                'Notes'             { $null = $ArgString.Add( ('-onoteinfo="{0}"' -f $Notes));                  break}
                'DoNotValidate'     { $null = $ArgString.Add(  '-z') ;                                          break}
                'PurgeTime'         { $null = $ArgString.Add( ('-opurgetime={0}' -f $PurgeTime.ToString()));    break}
                'PageLimit'         { $null = $ArgString.add( ('-opagelimit={0}' -f $PageLimit.ToString()));    break}
                'SupportNotes'      { $null = $ArgString.Add( ('-osupport="{0}"' -f $SupportNotes));            break}
                'WriteTimeout'      { $null = $ArgString.add( ('-owritetime={0}' -f $WriteTimeout.ToString())); break}
                'TranslationTable'  { $null = $ArgString.Add( ('-otrantable="{0}"' -f $TranslationTable));      break}
                'Model'             { $null = $ArgString.Add( ('-oPT={0}' -f $Model));                          break}
                'PCAPPath'          { $null = $ArgString.Add( ('-oPcap="{0}"' -f $PCAPPath));                   break}
                'UserFilterPath'    { $null = $ArgString.Add( ('-ousrfilter="{0}"' -f $UserFilterPath));        break}
                'Filter2'           { $null = $ArgString.add( ('-ofilter2="{0}"' -f $Filter2));                 break}
                'Filter3'           { $null = $ArgString.add( ('-ofilter3="{0}"' -f $Filter3));                 break}
                'CPSMetering'       { $null = $ArgString.Add( ('-ometering={0}' -f $CPSMetering.ToString()));   break}
                'InsertMissingFF'   { $null = $ArgString.add(  '-ofilesometimes');                              break}
                'FormType'          { $null = $ArgString.add( ('-oform="{0}"' -f $FormType));                   break}
                'LFtoCRLF'          {
                    switch ($LFtoCRLF) {
                        $true   { $null = $ArgString.Add('-olfc')}
                        $false  { $null = $ArgString.Add('-nolfc')}
                    }
                    break
                }
                'CopyBreak'         {
                    switch ($CopyBreak) {
                        $true   { $null = $ArgString.Add('-ocopybreak') }
                        $false  { $null = $ArgString.Add('-onocopybreak')}
                    }
                    break
                }
                'FileBreak'         {
                    switch ($FileBreak) {
                        $true   { $null = $ArgString.Add('-ofilebreak') }
                        $false  { $null = $ArgString.Add('-onofilebreak')}
                    }
                    break
                }
                'Banner'     {
                    switch ($Banner) {
                        $true   { $null = $ArgString.Add('-obanner')}
                        $false  { $null = $ArgString.Add('-onobanner')}
                    }
                    break
                }
                'HasInternalWebServer'  {
                    if ($CustomURL) {
                        $null = $ArgString.Add( '-ourl="{0}"' -f $CustomURL)
                    }
                    elseif ($DoNotValidate) {
                        $Message = 'Adding a http URL address for the webserver, since DoNotValidate was set'
                        Write-Warning -Message $Message
                        $null = $ArgString.Add( ('-ourl="http://{0}"' -f $ipaddress) )
                    }
                    else {
                        if (Test-Port -ComputerName $ipaddress -TCPPort 80 -TimeoutInMs 1000) {
                            Write-Verbose -Message 'Found http port, adding URL'
                            $null = $ArgString.Add( ('-ourl="http://{0}"' -f $ipaddress) )
                        }
                        elseif (Test-Port -ComputerName $ipaddress -TCPPort 443 -TimeoutInMs 1000) {
                            Write-Verbose -Message 'Found https port, adding URL'
                            $null = $ArgString.Add( ('-ourl="https://{0}"' -f $ipaddress) )
                        }
                        elseif ($ForceWebServer) {
                            $Message = 'Forcing a http URL address for the webserver, currently it appears to be offline'
                            Write-Warning -Message $Message
                            $null = $ArgString.Add( ('-ourl="http://{0}"' -f $ipaddress) )
                        }
                        else {
                            $Message = 'Unable to locate a webserver on port 80 or 443 for {0}, not setting this parameter' -f $PrinterName
                            Write-Warning -Message $Message
                        }
                    }
                    break
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess(('Create printer {0}' -f $PrinterName), '', '')) {
            $LPAdmin = [System.IO.Path]::combine( $env:OMHOME, 'bin', 'lpadmin.exe' )
            if ($IsTesting -or $IsFullTesting) {
                '{0} {1}' -f $LPAdmin, ($ArgString -join ' ')
            }
            else {
                Write-Verbose -Message ('Creating printer ({0})' -f $PrinterName)
                $ProcStart = @{
                    FilePath        = $LPAdmin
                    ArgumentList    = $ArgString
                    Wait            = $true
					WindowStyle 	= 'Hidden'
                }
				
                Start-Process @ProcStart -Verb RunAs
            }
        }
    }
}
