Function Set-OMPrinterConfiguration {
    <#
    .SYNOPSIS
        Modifies the configuration of an existing printer
    .DESCRIPTION
        Takes a set of parameters and generates a command line string for the OMPlus utility lpadmin.exe;
        The script will pull the IP Address of the existing printer in order to prevent a new printer from
        being accidentally generated.
    .EXAMPLE
        PS C:\> $PrintSplat = @{
            IsTesting 				= $true
            PrinterName 			= 'TestPrinter'
            Notes 					= 'Test Notes; We added a update here'
        }
        PS C:\> Set-OMPrinterConfiguration @PrintSplat
        D:\OMPlus\Server\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -onoteinfo="Test Notes; We added an update here"

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
        utility with numerous options.  This is very similar to the New-OMPrinter command, however, it looks for
        the IP address out of the existing configuration.  This help prevents a new printer from being accidentally created.

        It creates the mandatory parameters in a collection, and then it adds the other subsequent parameters
        as supplied by the user.   The string is then output and the lpadmin.exe command line is either displayed
        or executed.

        This script was built referencing the OMPlus Delivery Manager PDF from PlusTechnologies
    .PARAMETER PrinterName
        This is the name of the printer to create
    .PARAMETER Port
        This is the TCP Port to use for printing on the printer.
        It defaults to standard TCP/IP printing on port 9100
    .PARAMETER LPRPort
        This is the queue name used for LPR/LPD printers
    .PARAMETER Comment
        This is the optional comment for the printer.
    .PARAMETER URL
        This will set the URL property for the printer.  If no custom URL is supplied, the printer's IP will 
        be set as a plain http://<ipaddress>
    .PARAMETER CustomURL
        If the URL switch is used, and this parameter is provided, this will be inserted as
        the URL to use for accessing the print server.  No validation is done against this CustomURL
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
    .PARAMETER OpenTime
        The amount of time the system will wait attempting to open a printer for sending a job.  
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
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMPrinterList |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [Management.Automation.CompletionResultType]::ParameterValue,
                        ('PrinterName: {0}' -f $_ )
                    )
                }
        })]
        [string]$PrinterName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,65535)]
        [int]$TCPPort = 9100,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$LPRPort,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-ChildItem -Path ([system.io.path]::Combine($env:OMHOME, 'model')) | Select-object -ExpandProperty 'BaseName' |
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
        [switch]$URL,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
            $thisURI = [uri]"$_"
            if ($thisURI.IsUNC) {
                $true
            }
            elseif ($thisURI.IsAbsoluteURI) {
                $true
            }
            else {
                throw ('({0}) is not a valid URL' -f $thisURI)
                $false
            }
        })]
        [string]$CustomURL,

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
        [ValidateRange(1,180)]
        [int]$OpenTime,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$WriteTimeout,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$TranslationTable,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-ChildItem -Path ([system.io.path]::Combine($env:OMHOME, 'forms')) | Select-Object -ExpandProperty BaseName |
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
        [switch]$IsFullTesting
    )

    Begin {
        $EPSMapTestPath = [system.io.path]::combine($env:OMHOME, 'system', 'eps_map')
        if (Test-Path -Path $EPSMapTestPath) {
            Write-Verbose -Message 'On PrimaryMPS, proceeding'
        }
        else {
            throw 'Not on Primary MPS; unable to proceed'
        }

        $PrinterName = Get-OMCaseSensitivePrinterName -PrinterName $PrinterName

        if ($IsFullTesting) {
            $PSBoundParameters
            return
        }

        if ($Model) {
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
    }

    process {
        Write-Verbose -Message 'Begin building command line string for lpadmin'
            $ArgString = [Collections.Generic.List[string]]::New()
            $null = $ArgString.Add( ('-p{0}' -f $PrinterName) )

        $PrinterConfiguration = Get-OMPrinterConfiguration -PrinterName $PrinterName -Property all 

        foreach ($Parameter in $PSBoundParameters.Keys) {
            switch ($Parameter) {
                'Comment'           { $null = $ArgString.Add( ('-ocmnt="{0}"' -f $Comment) );                   break}
                'Notes'             { $null = $ArgString.Add( ('-onoteinfo="{0}"' -f $Notes));                  break}
                'DoNotValidate'     { $null = $ArgString.Add(  '-z') ;                                          break}
                'PurgeTime'         { $null = $ArgString.Add( ('-opurgetime={0}' -f $PurgeTime.ToString()));    break}
                'PageLimit'         { $null = $ArgString.add( ('-opagelimit={0}' -f $PageLimit.ToString()));    break}
                'SupportNotes'      { $null = $ArgString.Add( ('-osupport="{0}"' -f $SupportNotes));            break}
                'OpenTime'          { $null = $ArgString.Add( ('-oopentime={0}' -f $OpenTime));                 break}
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
                'URL'  {
                    if ($CustomURL) {
                        $null = $ArgString.Add( '-ourl="{0}"' -f $CustomURL)
                    }
                    elseif ($DoNotValidate) {
                        $Message = 'Adding a http URL address for the webserver, since DoNotValidate was set'
                        Write-Warning -Message $Message
                        $null = $ArgString.Add( ('-ourl="http://{0}"' -f $PrinterConfiguration.IPaddress) )
                    }
                    else {
                        if (Test-Port -ComputerName $PrinterConfiguration.IPaddress -TCPPort 80) {
                            Write-Verbose -Message 'Found http port, adding URL'
                            $null = $ArgString.Add( ('-ourl="http://{0}"' -f $PrinterConfiguration.IPaddress) )
                        }
                        elseif (Test-Port -ComputerName $PrinterConfiguration.IPaddress -TCPPort 443) {
                            Write-Verbose -Message 'Found https port, adding URL'
                            $null = $ArgString.Add( ('-ourl="https://{0}"' -f $PrinterConfiguration.IPaddress) )
                        }
                    }
                    break
                }
                'LPRPort' {
                    $ArgString.Add( ('-omode=netprint'))
                    $ArgString.Add( ('-v{0}!{1}' -f $PrinterConfiguration.ipaddress, $LPRPort) )
                }
                'TCPPort' {
                    $ArgString.Add( ('-omode=termserv') )
                    $ArgString.Add( ('-v{0}!{1}' -f $PrinterConfiguration.ipaddress, $TCPPort) )
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess(('Modifying printer {0}' -f $PrinterName), '', '')) {
            $LPAdmin = [System.IO.Path]::combine( $env:OMHOME, 'bin', 'lpadmin.exe' )
            if ($IsTesting -or $IsFullTesting) {
                '{0} {1}' -f $LPAdmin, ($ArgString -join ' ')
            }
            else {
                Write-Verbose -Message ('Modifying printer ({0})' -f $PrinterName)
                $ProcStart = @{
                    FilePath        = $LPAdmin
                    ArgumentList    = $ArgString
                    Wait            = $true
					NoNewWindow		= $true
                }
                Start-Process @ProcStart -Verb RunAs
            }
        }
    }
}
