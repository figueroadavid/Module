# OMPlus Delivery Manager
<!-- markdownlint-disable MD001 -->
<!-- markdownlint-disable MD024 -->
<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD035 -->
<!-- markdownlint-disable MD042 -->
<!-- markdownlint-disable MD051 -->

![OMPlusLogo](/Private/logo-plustechnologies.webp)

Wrapper module for [OMPlus for Windows](https://www.plustechnologies.com)

The module is written to provide a powershell friendly wrapper for the various binary utilities for OMplus on Windows.
Some additional functionality that does not exist is also added.
Here are the base functions provided

<table>
    <tr>
         <th><a href="#Connect-OMPrinterURL">Connect-OMPrinterURL</a></th>
         <th><a href="#Disable-OMPrimaryMPS">Disable-OMPrimaryMPS</a></th>
         <th><a href="#Disable-OMPrinter">Disable-OMPrinter</a></th>
    </tr>
    <tr>
         <th><a href="#Disable-OMTransformServer">Disable-OMTransformServer</a></th>
         <th><a href="#Enable-OMPrimaryMPS">Enable-OMPrimaryMPS</a></th>
         <th><a href="#Enable-OMPrinter">Enable-OMPrinter</a></th>
    </tr>
    <tr>
         <th><a href="#Enable-OMTransformServer">Enable-OMTransformServer</a></th>
         <th><a href="#Get-OMCaseSensitivePrinterName">Get-OMCaseSensitivePrinterName</a></th>
         <th><a href="#Get-OMDisabledDestination">Get-OMDisabledDestination</a></th>
    </tr>
    <tr>
         <th><a href="#Get-OMDriverNames">Get-OMDriverNames</a></th>
         <th><a href="#Get-OMEPR">Get-OMEPR</a></th>
         <th><a href="#Get-OMEPSMap">Get-OMEPSMap</a></th>
    </tr>
    <tr>
         <th><a href="#Get-OMJobCountByStatus">Get-OMJobCountByStatus</a></th>
         <th><a href="#Get-OMPrinterConfiguration">Get-OMPrinterConfiguration</a></th>
         <th><a href="#Get-OMPrinterList">Get-OMPrinterList</a></th>
    </tr>
    <tr>
         <th><a href="#Get-OMTypeTable">Get-OMTypeTable</a></th>
         <th><a href="#New-OMEPRMulti">New-OMEPRMulti</a></th>
         <th><a href="#New-OMEPR">New-OMEPR</a></th>
    </tr>
    <tr>
         <th><a href="#New-OMEPSMapBackup">New-OMEPSMapBackup</a></th>
         <th><a href="#New-OMPrinter">New-OMPrinter</a></th>
         <th><a href="#Remove-OMDuplicateEPR">Remove-OMDuplicateEPR</a></th>
    </tr>
    <tr>
         <th><a href="#Remove-OMEPR">Remove-OMEPR</a></th>
         <th><a href="#Remove-OMPrinter">Remove-OMPrinter</a></th>
         <th><a href="#Send-OMTestPage">Send-OMTestPage</a></th>
    </tr>
    <tr>
         <th><a href="#Set-OMPrinterConfiguration">Set-OMPrinterConfiguration</a></th>
         <th><a href="#Set-OMPrinterRedirection">Set-OMPrinterRedirection</a></th>
         <th><a href="#Test-Port">Test-Port</a></th>
    </tr>
    <tr>
         <th><a href="#Update-OMEPR">Update-OMEPR</a></th>
         <th><a href="#Update-OMTransformServer">Update-OMTransformServer</a></th>
         <th/>
    </tr>
</table>

## [Bugs :arrow_down:](##Bugs)

## Functions

### `Connect-OMPrinterURL`

Reads in the printer configuration, and if possible, launches the default browser to connect to the defined status URL for the printers

| Parameter Name                | Description   |
| :-------------                | :-----------  |
| `PrinterName`                 | This is the list of printers from which the system will open their status web pages |
| `DelayBetweenPrintersInMS`    | This is the amount of delay between launching the printer web pages.  This gives the browser some time to establish the xonnection, without becoming overwhelmed |
| `SafetyThreshold`             | This is the maximum number of pages the function will attempt to open.  This is a safety measure to prevent the browser and the system from being overwhelmed with requests to open web pages. |

[Jump to Top :arrow_up:](#)

___

### `Disable-OMPrimaryMPS`

Disables the OMP Service (`ompSrv`) service on the primary __master print server__.  This prevents the server from receiving jobs from the transform servers and causes the print jobs to begin routing to the secondary MPS.

| Parameter Name | Description |
| -------------- | ----------- |
| `N/A`          | `N/A`       |

##### _Example_

```ps
PS C:\> Disable-OMPrimaryMPS -Verbose
VERBOSE: Successfully disabled the ompSrv service
```

[Jump to Top :arrow_up:](#)
___

### `Disable-OMTransformServer`

Disables the OM IPP Service (`OMIPPServ`) service on a __transform__ server.  This prevents the server from receiving jobs from Epic.

| Parameter Name | Description |
| -------------- | ----------- |
| `N/A`          | `N/A`       |

##### _Example_

```ps
PS C:\> Disable-OMTransformServer -Verbose
VERBOSE: Successfully disabled the OMIPPServ service
```

[Jump to Top :arrow_up:](#)
___

### `Disable-OMPrinter`

Disables a printer in OMPlus

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names to disnable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `ShowProgress`| Writes a progress bar to show the progress of the cmdlet; this is useful when enabling a large number of printers |

##### _Example_

```powershell
PS C:> Disable-OMPrinter -PrinterName Printer01,Printer02,Printer03
WARNING: Printer: Printer03 is not a valid printer for this system; skipping
```

[Jump to Top :arrow_up:](#)

___

### `Enable-OMPrimaryMPS`

Enables the OMP Service (`ompSrv`) service on the primary __master print server__.  This allows the server to receive jobs from the transform servers.

| Parameter Name | Description |
| -------------- | ----------- |
| `N/A`          | `N/A`       |

##### _Example_

```ps
PS C:\> Enable-OMPrimaryMPS
```

[Jump to Top :arrow_up:](#)
___

### `Enable-OMPrinter`

Enables a previously disabled printer in OMPlus.

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names to enable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `ShowProgress`| Writes a progress bar to show the progress of the cmdlet; this is useful when enabling a large number of printers |

##### _Example_

```powershell
PS C:\> Enable-OMPrinter -PrinterName PRINTER01, PRINTER02, PRINTER03
WARNING: Printer: PRINTER03 is not a valid printer for this system; skipping
```

[Jump to Top :arrow_up:](#)
___

### `Enable-OMTransformServer`

Enables the OM IPP Service (`OMIPPServ`) service on a __transform__ server.  This allows the server to receive jobs from Epic.

| Parameter Name | Description |
| -------------- | ----------- |
| `N/A`          | `N/A`       |

##### _Example_

```ps
PS C:\> Enable-OMTransformServer
```

[Jump to Top :arrow_up:](#)
___

### `Get-OMDriverNames`

Reads and returns the list of driver names from the `types.conf` file in OMPlus

##### _Example_

```powershell
PS C:\> Get-OMDriverNames
Driver                             Display
------                             -------
ZDesignerAM400                     ZDesigner ZM400 200 dpi (ZPL)
HPUPD6                             HP Universal Printing PCL 6
LexUPDv2                           Lexmark Universal v2
DellOPDPCL5                        Dell Open Print Driver (PCL 5)
RICOHPCL6                          RICOH PCL6 UniversalDriver V4.14
HPUPD5                             HP Universal Printing PCL 5
Zebra2.5x4                         ZDesigner ZM400 200 dpi (ZPL)
LexUPDv2PS3                        Lexmark Universal v2 PS3
LexUPDv2XL                         Lexmark Universal v2 XL
XeroxUPDPS                         Xerox Global Print Driver PS
XeroxUPDPCL6                       Xerox Global Print Driver PCL6
```

[Jump to Top :arrow_up:](#)

___

### `Get-OMCaseSensitivePrinterName`

Retrieves the printername in the correct case from the file system, since most of the OMPlus executables are case-sensitive.
This function uses the `[System.IO.DirectoryInfo]` class to retrieve the name from the file system. As such, it can accept
wildcards.

| Parameter Name | Description |
| :------------- | :---------- |
| PrinterName    | The name of the printer to retrieve; this is case-insensitive |

##### _Example_

```powershell
PS C:\> Get-OMCaseSensitivePrinterName -PrinterName printer01
PRINTER01

PS C:\> Get-OMCaseSensitivePrinterName -PrinterName print*
PRINTER01
Printer02
PRINTER03
PRINTER04
PRINTER05
PRINTER15

PS C:\> Get-OMCaseSensitivePrinterName -PrinterName *03
PRINTER03

PS C:\> Get-OMCaseSensitivePrinterName -PrinterName printer?5
PRINTER05
PRINTER15
```

[Jump to Top :arrow_up:](#)

---

### `Get-OMDisabledDestination`

Retrieves the list of all printers that currently show as disabled

| Parameter |  Description |
| --------- | :---- |
| `Output` | The output of the function; it defaults to the display, but can be emailed instead |
| `SMTPFrom` | The _from_ address for sending a mail message |
| `SMTPTo` | The email address that the list is sent _to_ |
| `SMTPSubject` | The subject line for the report email |
| `SMTPServer` | The mail server to send the email to |
| `SMTPort` | The TCP port of the mail server for SMTP mail |
| `SendEmailEvenIfNoDisabledPrinters` | Tells the script send an email, even if there are no disabled printers; intended for automation |
| `ShowProgress` | Shows a progress bar as the printers are evaluated.  Useful for systems with a large amount of printers |

##### _Example_

- [ ] To do: Provide example

[Jump to Top :arrow_up:](#)

---

### `Get-OMDriverNames`

- This function does not take any parameters; it simply lists the available driver types and their associated Windows driver names

##### _Example_

```ps
PS C:\> Get-OMDriverNames
Name                           Value
----                           -----
DellOPDPCL5                    Dell Open Print Driver (PCL 5)
RICOHPCL6                      RICOH PCL6 UniversalDriver V4.4
ZDesignerAM400                 ZDesigner ZM400 200 dpi (ZPL)
HPLJ4100PCL6                   HP LaserJet 4100 PCL 6
HPUPD5                         HP Universal Printing PCL 5
HPUPD6                         HP Universal Printing PCL 6
LexUPDv2                       Lexmark Universal v2
ZebSmallPO                     ZDesigner ZM400 200 dpi (ZPL)
LexUPDv2PS3                    Lexmark Universal v2 PS3
Zebra2.5x4                     ZDesigner ZM400 200 dpi (ZPL)
XeroxUPDPS                     Xerox Global Print Driver PS
XeroxUPDPCL6                   Xerox Global Print Driver PCL6
HPUPDPS7                       HP Universal Printing PS (v7.0.0)
ZT610-300DPI                   ZDesigner ZT610-300dpi ZPL
EpsonT88VI                     EPSON TM-T88VI Receipt5
HPUPDV7                        HP Universal Printing PCL 6 (v7.0.1)
Zebra4w                        ZDesigner ZM400 200 dpi (ZPL)
CANONUFRII                     Canon MF230 Series UFRII LT
Zebra4W300DPI                  ZDesigner ZT610-300dpi ZPL
```

[Jump to Top :arrow_up:](#)

---

### `Get-OMEPR`

| Parameter |          |
| --------- | :------- |
| `Destination` | Retrieves the records associated with a specific destination/printer (mutually exclusive with `Queue`) |
| `Queue` | Retrieves the specific named record (mutually exclusive with `Destination`) |
| `RetrieveNames` | By default, `Get-OMEPR` retrieves the records as they are stored in the `eps_map` file; with this switch, the values are cross-referenced, and the names in the graphical interface are retrieved and displayed. |

##### _Example_

```ps
PS C:\> Get-OMEPR -Destination Printer01 | format-Table -AutoSize
Server                    EPR             Queue       Driver      Tray    Duplex  Paper   RX  Media
------                    ---             -----       ------      ----    ------  -----   --  -----
servername.domain.local   Printer01       Printer01    LexUPDv2    !1              !1      n
servername.domain.local   Printer01-RX$   Printer01    LexUPDv2    !2              !1      n

PS C:\> Get-OMEPR -Destination Printer01 -RetrieveNames | format-Table -AutoSize
Server                    EPR             Queue       Driver      Tray    Duplex  Paper   RX  Media
------                    ---             -----       ------      ----    ------  -----   --  -----
servername.domain.local   Printer01       Printer01    LexUPDv2    Tray 1          Letter  n
servername.domain.local   Printer01-RX$   Printer01    LexUPDv2    Tray 2          Letter  n

PS C:\> Get-OMEPR -Queue Printer01-RX$ | format-Table -AutoSize
Server                    EPR             Queue       Driver      Tray    Duplex  Paper   RX  Media
------                    ---             -----       ------      ----    ------  -----   --  -----
servername.domain.local   Printer01-RX$   Printer01    LexUPDv2    !2              !1      n


PS C:\> Get-OMEPR -Queue Printer01-RX$ -RetrieveNames | format-Table -AutoSize
Server                    EPR             Queue       Driver      Tray    Duplex  Paper   RX  Media
------                    ---             -----       ------      ----    ------  -----   --  -----
servername.domain.local   Printer01-RX$   Printer01    LexUPDv2    Tray 2          Letter  n
```

[Jump to Top :arrow_up:](#)

---

### `Get-OMEPSMap`

Retrieves the eps_map file from the system, and converts it to a series of PSCustomObjects
There is no visible output produced from this command; the command returns a PSCustomObject
consisting of:

```powershell
[pscustomobject]@{
    Preamble = <preamble text of the file>
    EPSMap   = <collection of pscustomobjects for each of the records>
    FilePath = The location of the file read in
}
```

##### _Example_

```powershell
PS C:\> $thisEPSMap = Get-OMEPSMap -FilePath $env:OMHOME\System\eps_map
PS C:\> $thisEPSMap.Preamble
#  File used by EPIC receive service to use proper configuration when mapping
#  VERSION: EPIC 2018
#
#  Server:  The OMS server that handles jobs for this record
#  PrinterPath:  The name of the print queue from EPIC
#  Queue:  The name of the print queue on Server that the job should be spooled to
#  CType:  The conversion type that OM Plus should use for rendering the PDF
#          Options are...
#             postscript  (convert the file to postscript)
#             PDF (leave file as a PDF)
#             <PRINTER NAME>  (use a windows printer to convert the file)
#  Tray:   An ! followed by the number to use for the tray.
#  Duplex: If the job should be duplexed.  Anything but a 0 will duplex
#  Size:   An ! followed by the number to use for the paper size.
#  RX:     If 'y' this job will have the RX flag added.  Not valid if CType is postscript or PDF
#  Media:  An ! followed by the number to use for the media.
#
#Server|PrinterPath|Queue|CType|Tray|Duplex|Size|RX|Media

PS C:\> $thisEPSMap.EPSMap[0]
Server      : server.domain.local
EPR         : PRINTERNAME
Destination : PRINTERNAME
Driver      : DellOPDPCL5
Tray        : !260
Duplex      :
Paper       : !1
RX          : n
Media       :

PS C:\> $thisEPSMap.EPSMap[0].PSObject.Properties.Value -join '|'
server.domain.local|PRINTERNAME|PRINTERNAME|DellOPDPCL5|!260||!1|n|
```

[Jump to Top :arrow_up:](#)

---

### `Get-OMJobCountByStatus`

Retrieves the count of jobs in a given status; the statuses are returned in a hashtable format

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names from which to retrieve the configuration |
| `Property`| Accepts a list of 1 or more property names to return in the PSCustomObject |
|           | `active, can, cmplt, faild, faxed, fpend, held, intrd, malid, partl, prnt, proc, ready, sent, spool, susp, timed, Change Password, xfer, 2big, 2dumb` <br> (There are 2 metadescriptors that can be used to get all of the status types: `all` and `*`) |

##### _Example_

```powershell
PS C:\> help Get-OMJobCountByStatus -ShowWindow

PS C:\> Get-OMJobCountByStatus -Status all

Name                           Value
----                           -----
2dumb                          0
malid                          0
xfer                           0
susp                           0
cmplt                          0
partl                          0
spool                          0
proc                           0
prntd                          102
can                            0
fpend                          0
2big                           0
Change Password                0
intrd                          0
ready                          14
faild                          0
held                           0
sent                           0
faxed                          0
timed                          0
active                         0

PS C:\> Get-OMJobCountByStatus -Status prntd,ready
Name                           Value
----                           -----
ready                          17
prntd                          133
```

[Jump to Top :arrow_up:](#)

___

### `Get-OMPrinterConfiguration`

Reads the configuration of a printer in OMPlus and returns the contents of the configuration file as a PSCustomObject.
The default return includes the Printer, IPAddress, TCPPort, and LPRPort.
The configuration automatically has the printer's name added to the return object as `Printer`

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names from which to retrieve the configuration |
| `Property`| Accepts a list of 1 or more property names to return in the PSCustomObject |
|           | `All,Mode,Device,Stty,Filter,User_Filter,Def_form,Form,Accept,Accepttime,Acceptreason,Enable,Enabletime`<br>`Enablereason,Metering,Model,Filebreak,Copybreak,Banner,Lf_crlf,Close_delay,Writetime,Opentime`<br> `Purgetime,Draintime,Terminfo,Pcap,URL,CMD1,Comments,Support,Xtable,Notify_flag,Notify_info`<br>`Two_way_protocol,Two_way_address,Alt_dest,Sw_dest,Page_limit,Data_types,FO,HD,PG,LG,DC,CP`<br>`RT,EM,PT,PD,LZ,CA,RX,OP`<br> (There are 2 metadescriptors that can be used to get all of the properties:`all`and`*`)|

##### _Example_

```powershell
    PS C:\> Get-OMPrinterConfiguration -PrinterName Printer01
    Printer   IPAddress    TCPPort LPRPort
    -------   ---------    ------- -------
    Printer01 10.0.0.1     9100    none

    PS C:\> Get-OMPrinterConfiguration -PrinterName Printer01 -Property all
    Printer          : Printer01
    Mode             : termserv
    IPAddress        : 10.0.0.1
    TCPPort          : 9100
    Stty             : none
    Filter           : dcctmserv
    User_Filter      : none
    Def_form         : stock
    Form             : stock
    Accept           : y
    Accepttime       : 001443446160
    Acceptreason     : New Printer
    Enable           : y
    Enabletime       : 001445452018
    Enablereason     : Unknown
    Metering         : 0
    Model            : omstandard.js
    Filebreak        : n
    Copybreak        : n
    Banner           : n
    Lf_crlf          : y
    Close_delay      : 10
    Writetime        : 5399
    Opentime         : 180
    Purgetime        : 100
    Draintime        : 5399
    Terminfo         : dumb
    Pcap             : none
    URL              : http://10.0.0.1
    CMD1             : none
    Comments         : none
    Support          : none
    Xtable           : standard
    Notify_flag      : 0
    Notify_info      : none
    Two_way_protocol : none
    Two_way_address  : none
    Alt_dest         : none
    Sw_dest          : none
    Page_limit       : 0
    Data_types       : all
    FO               : n
    HD               : n
    PG               : y
    LG               : 0
    DC               : default
    CP               : y
    RT               : 30
    EM               : none
    PT               : none
    PD               : n

    PS C:\>Get-OMPrinterConfiguration -PrinterName Printer1, Printer2 -Property Mode, URL
    Printer                         Mode                        URL
    -------                         ----                        ---
    Printer1                        termserv                    http://10.0.0.1
    Printer2                        termserv                    http://10.0.0.2
    Printer3                        netprint                    none
```

[Jump to Top :arrow_up:](#)

___

### `Get-OMPrinterList`

Gets and returns the list of printers in OMPlus

| Parameter Name  | Description |
| :-------------- | :---------- |
| `Filter`| This is passed to Get-ChildItem as the _-Filter_ parameter; this uses simple matching with `*` for multiple characters, and `?` for a single character |

##### _Example_

```powershell
PS C:\> Get-OMPrinterList
Printer01
Printer02
Printer03
Printer04
MyPrint01
MyPrint02
MyPrint03
MyPrint04

PS C:\> Get-OMPrinterList -Filter My*
MyPrint01
MyPrint02
MyPrint03
MyPrint04

```

[Jump to Top :arrow_up:](#)

___

### `Get-OMTypeTable`

Retrieves the parameters from the `types.conf` file for Trays, Paper Sizes, and Media Types.

| Parameter | Description |
| --------- | :---------- |
| `DriverType` | This is the name of the driver type configured in the system.  You can see the driver types by using `Get-OMDriverNames` |
| `Display`    | this is the display type of the data (Trays, Paper Sizes, or Media Types) |
| `SortBy`     | This determines if the display is sorted by the name, or the ID number of the reference |

##### _Example_

```powershell
PS C:\> Get-OMTypeTable -DriverName DellMulti -Display Trays
TrayName                                               TrayID
--------                                               ------
Auto Select                                                15
Manual Tray                                               257
Tray 1                                                    259
Tray 2                                                    260
Tray 3                                                    261
Tray 4                                                    262
Tray 5                                                    263

PS C:\> Get-OMTypeTable -DriverName DellMulti -Display PaperSizes
PaperSizeName                                     PaperSizeID
-------------                                     -----------
A3                                                          8
A4                                                          9
A5                                                         11
B4 (JIS)                                                   12
B5 (JIS)                                                   13
B6 (JIS)                                                   88
11x17                                                      17
Executive                                                   7
Folio                                                      14
Legal                                                       5
Letter                                                      1
Oficio                                                    265
Statement                                                   6
Envelope B5                                                34
Envelope C4                                                30
Envelope C5                                                28
Envelope C6                                                31
Envelope #9                                                19
Envelope #10                                               20
Envelope DL                                                27
Envelope Monarch                                           37
Postcard                                                  257

PS C:\> Get-OMTypeTable -DriverName DellMulti -Display PaperSizes -SortBy ID
PaperSizeName                                     PaperSizeID
-------------                                     -----------
Letter                                                      1
Legal                                                       5
Statement                                                   6
Executive                                                   7
A3                                                          8
A4                                                          9
A5                                                         11
B4 (JIS)                                                   12
B5 (JIS)                                                   13
Folio                                                      14
11x17                                                      17
Envelope #9                                                19
Envelope #10                                               20
Envelope DL                                                27
Envelope C5                                                28
Envelope C4                                                30
Envelope C6                                                31
Envelope B5                                                34
Envelope Monarch                                           37
B6 (JIS)                                                   88
Postcard                                                  257
Oficio                                                    265

PS C:\> Get-OMTypeTable -DriverName DellMulti -Display MediaTypes -SortBy ID
MediaTypeName                                     MediaTypeID
-------------                                     -----------
Auto Select                                               256
Plain                                                     257
Recycled                                                  258
Bond                                                      259
Envelope                                                  260
Letterhead                                                261
Prgetprinted                                              262
Prepunched                                                263
Color                                                     264
Glossy                                                    265
```

[Jump to Top :arrow_up:](#)

___

### `New-OMBulkImport`

Reads in a CSV file of printers and feeds them into the New-OMPrinter function to create new OMPlus printers.
The field names must match the parameters for `New-OMPrinter`

| Parameter Name  | Description |
| :-------------- | :---------- |
| `FilePath`| The path to the CSV file to read in |
| `Delimiter`| The character used to separate the fields, it defaults to a commma |

##### _Example_

```powershell
PS C:\> New-OMBulkImport -FilePath c:\temp\omplusimport.csv -delimiter '|'
```

[Jump to Top :arrow_up:](#)

___

### `New-OMEPRMulti`

###### <font color="red">[_Experimental_]</font>

This is an experimental function to generate multiple EPR's for a single destination.
This is **not** ready for production use at this time.

| Parameter | Description |
| --------- | :---------- |
| `Destination` | The name of the printer/destination to generate records for |
| `TrayCount` | The number of trays to add |
| `DriverName` | The driver type of the printer. (See `Get-OMDriverNames`) |
| `DuplexOption` | The duplex setting to use for the EPR |
| `PaperSize` | The paper size to use for the EPR |
| `MediaType` | What media type to use for the EPR |
| `HasRXTray` | Determines if the last tray should be flagged as a prescription tray |
| `Append` | Determines if the generated records should be appended to the `eps_map` file |

[Jump to Top :arrow_up:](#)

___

### `New-OMEPR`

This creates a correctly formatted Epic Print Record for the `eps_map` file.
Depending on the version of Powershell used (> 5), the parameter names will provide tab-completion assistance.

| Parameter Name | Description |
| :-------------- | :---------- |
| `Queue` | The name of the EPR Queue Name for the Record; there can be multiple Queues per Destination |
| `Destination` | The printer/destination name in OMPlus |
| `DriverName` | The name of the driver used in the system; this name _is **case-sensitive**_; this name comes from the _Types_ list in the OMPlus Administration tool (See the `Get-OMDriverNames` function|
| `TrayName` | This is the name of the tray to use.  It must match the trays available in the `types.conf`. |
| `DuplexOption` | This is the Duplex option setting in the _Epic Print Record_ tool; it comes from the `types.conf` file; it can be _None_ (which is blank), _Simplex_, _Horizontal_ (Short Edge), or _Vertical_ (Long Edge) |
| `PaperSize` | This is the size of the paper; it also comes from the `types.conf` file |
| `IsRx` | Sets the flag if the EPR is designated for prescriptions, it defaults to 'n'; which is unchecked in the Transform tool |
| `MediaType` | Determines which media type the printer is using.  It defaults to 'none' |
| `Append` | This tells the function to end the EPR record to the end of the `eps_map` file and calls the `Update-OMTransformServer` function to notify the Transform servers of the change(s) |
| `Force` | This is used as part of the `Set-Content` operation used to overwrite the existing `eps_map` and should generally not be necessary |
| `UpdateTransform` | This triggers the `Update-Transform` command to trigger the normal OMPlus replication mechanism |
| `AllowMixedCase` | By default, this function will force the Queue name to UPPER CASE to match Epic requirements.  This switch causes the function to NOT force them to uppercase |
| `OverRide` | This switch allows the script to generate an EPR even if the printer does not exist |

##### _Example_

```powershell
PS C:\> $EPRSplat = @{
    EPRQueue        = 'PRINTER01'
    OMQueue         = 'PRINTER01'
    DriverName      = 'DellOPDPCL5'
    TrayName        = 'Tray 1'
    DuplexOption    = 'Horizontal'
    PaperSize       = 'Letter'
    IsRX            = 'n'
    MediaType       = 'Bond'
    Append          = $true
    UpdateTransform = $true
}
PS C:\> New-OMEPR @EPRSplat
server01.domain.local|PRINTER01|PRINTER01|DellOPDPCL5|!259|Horizontal|!1|n|!259
VERBOSE: Using pingmsg to update host: transformserver01.hchd.local
VERBOSE: Triggering update for transformserver01.hchd.local
VERBOSE: Using pingmsg to update host: transformserver02.hchd.local
VERBOSE: Triggering update for transformserver02.hchd.local
VERBOSE: Using pingmsg to update host: transformserver03.hchd.local
VERBOSE: Triggering update for transformserver03.hchd.local
VERBOSE: Using pingmsg to update host: transformserver04.hchd.local
VERBOSE: Triggering update for transformserver04.hchd.local

PS C:\> $EPRSplat = @{
    EPRQueue        = 'Printer01-T2'
    OMQueue         = 'Printer01'
    DriverName      = 'DellOPDPCL5'
    TrayName        = 'Tray 2'
    DuplexOption    = 'Vertical'
    PaperSize       = 'Legal'
    IsRX            = 'y'
    MediaType       = 'Glossy'
    AllowMixedCase  = $true
}
PS C:\> New-OMEPR @EPRSplat
server01.domain.local|Printer01-T2|PRINTER01|DellOPDPCL5|!260|Vertical|!5|y|!265
```

[Jump to Top :arrow_up:](#)

___

### `New-OMEPSMapBackup`

This function creates a backup of the `eps_map` file.  It automatically generates the name based on the date, and
automatically keeps the number of backups to 10.

The function has no parameters, and only functions on the primary _master print server_

##### _Example_

```powershell
PS C:\> New-OMEPSMapBackup
```

[Jump to Top :arrow_up:](#)

___

### `New-OMPrinter`

Creates a new OMPlus printer

| Parameter Name | Description |
| :-------------- | :---------- |
|`PrinterName` | The name of the printer to create|
|`IPAddress` | The IP address of the printer; `lpadmin.exe` does not require an IP address depending on the printer type, but the vast majority of printers managed by OMPlus are on the network and do need IP Addresses.  The script validates the number is in the range of `0-65535`|
|`TCPPort` | The TCP port used for the printer; it defaults to `9100`|
|`LPRPort` | The name of the LPD/LPR queue; if this is used the script will replace the TCPPort with the LPRPort queue name|
|`Comment` | This supplies the comment (`-ocmt`) parameter;|
|`HasInternalWebServer` | This sets the _`Has Internal Web Server`_ flag for the printer; if _`CustomURL`_ is not supplied, the script tests for a web page on port `80`(`http`), and then on port `443`(`https`) if `80` does not respond; (`-ourl`)|
|`CustomURL` | This is used with the _HasInternalWebServer_ to set the -ourl parameter, and must be used if the web page is not accessed by the IP address on a standard `http`(`80`) or `https`(`443`) port|
|`ForceWebServer` | Used in combination with _HasInternalWebServer_ to set the `-ourl` port without verifying that the URL responds (http, https, custom)|
|`PurgeTime` | Overrides the default purge time from the system for the printer; this value is in seconds (`-opurgetime`)|
|`PageLimit` | Overrides the default page limit from the system for the printer (`-opagelimit`)|
|`Notes` | This supplies the the Notes field (`-onoteinfo`)|
|`SupportNotes` | Supplies the Support Notes field (`-osupport`)|
|`WriteTimeout` | Overrides the default timeout value for print jobs for this printer (`-owritetimeout`)|
|`TranslationTable` | Overrides the default translation table for the system for this printer (`-otrantrable`)|
|`DriverType` | Sets the correct driver type; this script was written for Powershell 4; the administrator needs to first get the correct driver types to set the list for `[ValidateSet()]`; however, future versions will automatically prepopulate this list with ArgumentCompleters (`-oPT`)|
|`Mode` | Defaults to `termserv`; `LPRPort` is also supplied, this is changed to 'netprint' (`-omode`)|
|`FormType` | Overrides the default form type for the printer (`-oform`)|
|`PCAPPath` | Enables the PCAP capture for the printer, and sets the file path for the capture file (`-oPcap`)|
|`UserFilterPath` | Sets a user defined filter script for print jobs (`-ousrfilter`); the file must exist on the system|
|`Filter2` | Sets a secondary user defined filter script for print jobs (`-ofilter2`); the file must exist on the system|
|`Filter3` | Sets a secondary user defined filter script for print jobs (`-ofilter3`); the file must exist on the system|
|`CPSMetering` | Overrides the default characters per second metering for printer (`-ometering`)|
|`Banner` | If used, and set to \$true, then `-obanner` is used and banner pages are injected between print jobs, if set to $false, then `-onobanner` is used|
|`DoNotValidate` | Sets the -z flag so that lpadmin does not try to verify the printer's existence|
|`LFtoCRLF` | If used, and set to \$true, then `-olfc` is used and LF characters are converted to CRLF characters, if set to $false, then `-onolfc` is used|
|`CopyBreak` | If used, and set to \$true, then `-ocopybreak` is used and page breaks are inserted between print jobs, and if set to $false `-onocopybreak` is used, and page breaks are removed from between print jobs|
|`FileBreak` | If used, and set to \$true, then `-ofilebreak` is used and page breaks are inserted between files submitted, and if set to $false, then `-onofilebreak` is used and page breaks between files are removed|
|`InsertMissingFF` | If used, then if form feeds are missing between jobs, then they are inserted (`-ofilesometimes`)|
|`IsTesting` | if used, displays the generated command line without actually creating the printer|
|`IsFullTesting` | if used, displays all the supplied parameters, and then displays the generated command line|
|`IsForEpic` | if used, it _sanitizes_ the record to match Epic standards - letters are converted to upper case, and spaces are replaced with hypens|

##### _Example_

```powershell
PS C:\> $PrintSplat = @{
            IsTesting             = $true
            PrinterName           = 'TestPrinter'
            IPAddress             = '10.0.4.112'
            Port                  = 9100
            Comment               = 'Beaker'
            HasInternalWebServer  = $true
            ForceWebServer        = $true
            PurgeTime             = 45
            PageLimit             = 5
            Notes                 = 'Test Notes'
            SupportNotes          = 'Support Notes'
            WriteTimeout          = 60
            DriverType            = 'HPUPD5'
            Mode                  = 'termserv'
            FormType              = 'Letter'
            PCAPPath              = 'c:\temp\test.pcap'
            CPSMetering           = 5000
            Banner                = $true
            FileBreak             = $true
            CopyBreak             = $true
            DoNotValidate         = $true
            LFtoCRLF              = $true
            InsertMissingFF       = $true
}
PS C:\> New-OMPrinter @PrintSplat -IsTesting
C:\Plustech\OMPlus\Server\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -omode="termserv" -opurgetime=45
-ourl="http://10.0.4.112" -ometering=5000 -oPcap="c:\temp\test.pcap" -opagelimit=5 -onoteinfo="Test Notes" -z
-owritetime=60 -ocmnt="Beaker" -obanner -oform="Letter" -olfc -onocopybreak -osupport="Support Notes"
-omode="termserv" -ofilesometimes -onofilebreak -oPTHPUPD5

PS C:\> New-OMPrinter @PrintSplat -Verbose
Creating printer: TESTPRINTER

```

___

### `Remove-OMDuplicateEPR`

###### <font color="red">[_Experimental_]</font>

This is an experimental function used to clean up duplicated records in the `eps_map` file.

| Parameter | Description |
| --------- | :---------- |
| `FilePath` | Used to designate an `eps_map` file not in the default location` |

[Jump to Top :arrow_up:](#)

___

### `New-OMSampleBulkImportFile`

This creates a sample csv file that is appropriate to import into `New-OMBulkImport`

| Parameter Name| Description |
| :-- | :-- |
| `FilePath` | The output path for the sample file |
| `Delimiter` | A single character delimiter for the output file; it defaults to a comma (`,`) |
| `PortType` | Defaults to `TCPPort`, the other option is `LPRPort` |
| `IncludeComments` | This adds a series of comments for the optional _Parameters_ giving explanations to those _Parameters_ |
| `OptionalParameter` | A list of the available optional _Parameters_ to include in the output file; |
| | `HasInternalWebServer`, `Comment`, `PCAPpath`, `FileBreak`, `CustomURL`, `Notes`, `CPSMetering`, `Banner`, `ForceWebServer`, `SupportNotes`, `InsertMissingFF` ,`WriteTimeout`, `DriverType`, `UserFilterPath` , `FormType`, `TranslationTable`, `DoNotValidate`, `Filter2`, `LFtoCRLF`, `PageLimit`, `PurgeTime`, `Filter3`,`CopyBreak`, `Model`, `Mode`, `DoNotValidate`, `IsTesting`, `IsFullTesting`, `UseEpicFormat`, `AllowMixedCase`|

##### _Example_

```powershell
PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $true
}
PS C:\> New-OMSampleBulkImportFile @SampleSplat

#Contents of the file
"PrinterName","IPAddress","TCPPort","HasInternalWebServer","ForceWebServer","DriverType","DoNotValidate","Comment","IsTesting"
"Mandatory parameter; Name used to create the actual printer; spaces are not allowed","Mandatory parameter; IP address for the printer, or LPR/LPD print server","Mandatory parameter: The TCP port used for network communication, between 0 and 65535; the default is 9100","Optional parameter; Indicates that the printer has a built in web server; if a CustomURL is not supplied it will attempt to create a URL from http://<ipaddress> or https://<ipaddress> ","Optional parameter; Indicates that te default web server URL needs to be set even if neither http://<ipaddress> nor https://<ipaddress> respond ","Optional parameter; The DriverType for the printer; must be one of the supported ones from the system","Optional parameter; Tells lpadmin not to verify the printer before creating it (-z)","Optional parameter; Comment for the printer","Optional parameter; Causes the script to return the generated command line rather than execute it"

PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $false
}

PS C:\> New-OMSampleBulkImportFile @SampleSplat

#Contents of the file
PrinterName,IPAddress,TCPPort,HasInternalWebServer,ForceWebServer,DriverType,DoNotValidate,Comment,IsTesting
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMDuplicateEPR`

###### <font color="red">[_Experimental_]</font>

This function scans the eps_map file and removes duplicate entries based on the EPR Queue name.
The function also makes a backup copy of the eps_map file for safety.

| Parameter Name        | Description |
| :-------------        | :---------- |
| `ShowDuplicateRecords` | This shows the duplicate records as they are found, and returns a table of the duplicate records found at the end.  The original records are not returned. The temporary file created is then copied over the eps_map file and the Update-OMTransformServer function is called|

##### _Example_

```powershell
PS C:\> Remove-OMDuplicateEPR -ShowDuplicateRecords -Verbose
VERBOSE:    Duplicate record for PRINTER01 found at line 35
                omplusserver01.domain.local|PRINTER01|PRINTER01|XeroxUPDPCL6|!260||!1|n|
VERBOSE:    Duplicate record for PRINTER02 found at line 85
                omplusserver01.domain.local|PRINTER02|PRINTER02|XeroxUPDPCL6|!260||!1|n|
Name            Value
----            -----
PRINTER01_35    omplusserver01.domain.local|PRINTER01|PRINTER01|XeroxUPDPCL6|!260||!1|n|
PRINTER02_85    omplusserver01.domain.local|PRINTER02|PRINTER02|XeroxUPDPCL6|!260||!1|n|

PS C:\> Remove-OMDuplicateEPR -ShowDuplicateRecords
Name            Value
----            -----
PRINTER01_35    omplusserver01.domain.local|PRINTER01|PRINTER01|XeroxUPDPCL6|!260||!1|n|
PRINTER02_85    omplusserver01.domain.local|PRINTER02|PRINTER02|XeroxUPDPCL6|!260||!1|n|
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMEPR`

###### <font color="red">[_Experimental_]</font>

This removes EPR Records from the `eps_map` file, and notifies the Transform servers of the record removal
This is an especially risky function, and has multiple built in safety precautions.
The first step it takes is to create a backup of the `eps_map` file, with a naming convention of: `eps_map_datetime.bkp`
The datetime syntax used is `yyMMdd_hhmmss`; so the current name as of this writing would be `eps_map_210322_111908.bkp`

| Parameter Name              | Description |
| :-------------------------------------------              | :---------- |
| `MatchField`              | The name of the field used to determine which records to select for deleting. It is predefined as `EPR Record`, `Queue`, `EPS Base`, `Tray`, `Simplex/Duplex`, `Paper Size`, `RX`, `Media Type`|
| `MatchType`               | This determines if the match should be a _simple match_ or a _regular expressions_ match; it defaults to _simple_|
| `MatchPattern`            | This is the text string to define the matching pattern used by the `MatchType` |
| `ReallyDoIt`              | This tells the function that you really do intend to make this change; this is one of the important safety switches |
| `ThreshholdPercent`       | By default, this is set to 1 (percent), if the function will remove more than this percentage of the records, it will error out and not perform the function; this is another critical safety switch to this function |
| `OverrideThreshold`       | This switch tells the function to ignore the `ThreshholdPercent` switch; this is a very dangerous switch, and must be used with extreme caution |

##### _Example_

```powershell
PS C:\> $RemoveSplat = @{
    MatchField      = 'EPR Record'
    MatchType       = 'Simple'
    MatchPattern    = 'PRINTER-0*'
}
PS C:\> Remove-OMEPR @RemoveSplat -Verbose
The new eps_map will contain 6399 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
ReallyDoIt switch not specified, not updating the file

PS C:\> Remove-OMEPR @RemoveSplat -Verbose -ReallyDoIt
The new eps_map will contain 6399 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
WARNING: eps_map being updated

PS C:\> $RemoveSplat = @{
    MatchField      = 'EPR Record'
    MatchType       = 'Simple'
    MatchPattern    = '*PR*'
}
PS C:\> Remove-OMEPR @RemoveSplat -ReallyDoIt -Verbose
The new eps_map will contain 2390 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
MYPRINTER01
....
ZZPRINTER50

This action will remove more than 1% of the records from eps_map

```

___

### `Remove-OMPrinter`

This uses `lpadmin.exe` to delete the given printers by name; when the printers are deleted the function throws up a warning to remind the administrator to remove the OMPlus EPR Record for the printer.

| Parameter Name | Description |
| -- | -- |
| `PrinterName` | The list of printers to remove |

##### _Example_

```powershell
PS C:\> Get-OMPrinterList -Filter Office1Prt_* | ForEach-Object { Remove-OMPrinter -PrinterName $_ }
WARNING: Do not forget to Remove the EPR Record for Office1Prt_001
WARNING: Do not forget to Remove the EPR Record for Office1Prt_002
WARNING: Do not forget to Remove the EPR Record for Office1Prt_003
WARNING: Do not forget to Remove the EPR Record for Office1Prt_004
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMPrintJob`

This function deletes print jobs that exists in the system. It has 4 modes of operation:

1. By RID number: Deletes the job with the job number  (uses `dcccancel.exe`)
2. By Age: Deletes all print jobs older than the specified time in minutes (uses `dccgrp.exe`)
3. By Printer: Resets the printer, thereby deleting the print jobs going to that printer (uses `dccreset.exe`)
4. By Status: Cancels all jobs with the given status (uses `dccgrp.exe`)

| Parameter Name | Description |
| :-- | :-- |
| `RIDNumber` | [by RID number] The RIDNumber(s) of the print jobs to delete |
| `ImmediatePurge` | [by RID number] adds the flag to automatically purges the jobs |
| `JobAgeInMinutes` | [by Job Age] Jobs older than this number of minutes in age are cancelled |
| `PrinterName` | [by the printer] This printer is reset, cancelling the jobs on this printer and disabling the printer |
| `ResetSNMP` | [by the printer] Adds the flag to reset the SNMP data |
| `ResetLock` | [by the printer] Adds the flag to reset the lock data |
| `ResetToInactive` | [by the printer] Adds the flag to reset the printer, and set it to disabled |
| `ResetActive` | [by the printer] Adds the flag to reset the printer, and set it back to enabled |
| `Status` | [by Job Status] The jobs with this status are cancelled |

##### _Examples_

```powershell
PS C:\> Remove-OMPrintJob -RIDNumber RID35332
PS C:\> Remove-OMPrintJob -JobAgeInMinutes 60
PS C:\> Remove-OMPrintJob -PrinterName Printer01
WARNING: Don't forget to re-enable this printer: Printer01
PS C:\> Remove-OMPrintJob -Status activ
```

[Jump to Top :arrow_up:](#)

___

## `Send-OMTestPage`

Similar to the Test Page functionality of the graphical user interface, this script will send the configuration file of the printer to that printer as a print job.

##### <font color="red">Experimental</font>

| Parameter | Description |
| --------- | :---------- |
| `PrinterName` | The list of printers to send test pages |
| `ShowOutput`  | Returns the output of stdout that is generated by `lpadmin.exe` |

##### _Example_

```powershell
PS C:\Windows\system32> Send-OMTestPage -PrinterName Printer01

PS C:\Windows\system32> Send-OMTestPage -PrinterName printer01 -ShowOutput
Processing files...
LPPNT5057I-dcclp: Queueing configuration from server01!username to PRINTER01 as RID99999/server0116826956612522_server0199999; simple, 1 pages
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMSecondaryMPSPrinters`

#### _<font color="red">Temporarily removed</font>_

When a printer is removed from the primary MPS server, the secondary server does not remove that same printer.
Each MPS server maintains its own licensing, so this can result in the secondary server exceeding its license.
This function will remove the printers that have not been removed from the secondary MPS server.  It has 3 modes of
operation.

1. ByDir  = The function directly compares the list of printer directories from the OMPlus installations to generate the list of printers to remove; this is the default mode of operation
2. ByFile = The function takes in 2 lists of printers, and uses that to generate the list of printers to remove
3. ByList = The function takes the list of printers from the primary MPS server, the list of printers from the secondary server, and generates the list of printers to remove

| Parameter Name | Description |
| :-- | :-- |
| `PrimaryPrinterFile` | [byFile] The file containing the list of printers from the primary MPS server |
| `SecondaryPrinterFile` | [byFile] The file containing the list of printers from the secondary MPS server |
| `PrimaryMPSPrinterDirectory` | [byDir] The directory containing the printers from the primary MPS server; it uses the environment variables set by the module to locate the printers by default |
| `SecondaryMPSPrinterDirectory` | [byDir] The directory containing the printers from the secondary MPS server; it uses the environment variables set by the module to locate the printers by default |
| `PrimaryList` | [byList] The list of printers from the primary MPS server |
| `SecondaryList` | [byList] The list of printers from the secondary MPS server |

##### _Example_

```powershell
PS C:\> Remove-OMSecondaryMPSPrinters -SecondaryMPSIsTransform -WhatIf -Verbose
$SecondaryMPSIsTransform switch is present, not deleting transform printers
Removing this printer list from mpsserver02
MyPrinter05
MyPrinter06

PS C:\> Remove-OMSecondaryMPSPrinters -Verbose
$SecondaryMPSIsTransform switch is not present, any pt_transform printers will be deleted along with the rest
WARNING: Do not forget to Remove the EPR Record for MyPrinter05
WARNING: Do not forget to Remove the EPR Record for MyPrinter06
WARNING: Do not forget to Remove the EPR Record for pt_transform_01
WARNING: Do not forget to Remove the EPR Record for pt_transform_01


```

### `Set-OMPrinterConfiguration`

##### _<font color="red">Experimental</font>_

This function modifies an existing OMPlus printer. IPAddress, TCPPort, and LPRPort are automatically retrieved from the existing printer.

| Parameter Name | Description |
| :-------------- | :---------- |
|`PrinterName` | The name of the printer to create|
|`Comment` | This supplies the comment (`-ocmt`) parameter;|
|`HasInternalWebServer` | This sets the _`Has Internal Web Server`_ flag for the printer; if _`CustomURL`_ is not supplied, the script tests for a web page on port `80`(`http`), and then on port `443`(`https`) if `80` does not respond; (`-ourl`)|
|`CustomURL` | This is used with the _HasInternalWebServer_ to set the -ourl parameter, and must be used if the web page is not accessed by the IP address on a standard `http`(`80`) or `https`(`443`) port|
|`ForceWebServer` | Used in combination with _HasInternalWebServer_ to set the `-ourl` port without verifying that the URL responds (http, https, custom)|
|`PurgeTime` | Overrides the default purge time from the system for the printer; this value is in seconds (`-opurgetime`)|
|`PageLimit` | Overrides the default page limit from the system for the printer (`-opagelimit`)|
|`Notes` | This supplies the the Notes field (`-onoteinfo`)|
|`SupportNotes` | Supplies the Support Notes field (`-osupport`)|
|`WriteTimeout` | Overrides the default timeout value for print jobs for this printer (`-owritetimeout`)|
|`TranslationTable` | Overrides the default translation table for the system for this printer (`-otrantrable`)|
|`DriverType` | Sets the correct driver type|
|`FormType` | Overrides the default form type for the printer (`-oform`)|
|`PCAPPath` | Enables the PCAP capture for the printer, and sets the file path for the capture file (`-oPcap`)|
|`UserFilterPath` | Sets a user defined filter script for print jobs (`-ousrfilter`); the file must exist on the system|
|`Filter2` | Sets a secondary user defined filter script for print jobs (`-ofilter2`); the file must exist on the system|
|`Filter3` | Sets a secondary user defined filter script for print jobs (`-ofilter3`); the file must exist on the system|
|`CPSMetering` | Overrides the default characters per second metering for printer (`-ometering`)|
|`Banner` | If used, and set to \$true, then `-obanner` is used and banner pages are injected between print jobs, if set to $false, then `-onobanner` is used|
|`DoNotValidate` | Sets the -z flag so that lpadmin does not try to verify the printer's existence|
|`LFtoCRLF` | If used, and set to \$true, then `-olfc` is used and LF characters are converted to CRLF characters, if set to $false, then `-onolfc` is used|
|`CopyBreak` | If used, and set to \$true, then `-ocopybreak` is used and page breaks are inserted between print jobs, and if set to $false `-onocopybreak` is used, and page breaks are removed from between print jobs|
|`FileBreak` | If used, and set to \$true, then `-ofilebreak` is used and page breaks are inserted between files submitted, and if set to $false, then `-onofilebreak` is used and page breaks between files are removed|
|`InsertMissingFF` | If used, then if form feeds are missing between jobs, then they are inserted (`-ofilesometimes`)|
|`IsTesting` | if used, displays the generated command line without actually creating the printer|
|`IsFullTesting` | if used, displays all the supplied parameters, and then displays the generated command line|
|`IsForEpic` | if used, it _sanitizes_ the record to match Epic standards - letters are converted to upper case, and spaces are replaced with hypens|

##### _Example_

```powershell
PS C:\> $PrintSplat = @{
    IsTesting     = $true
    PrinterName   = 'TestPrinter'
    Notes         = 'Test Notes; We added a update here'
}
PS C:\> Set-OMPrinterConfiguration @PrintSplat
D:\OMPlus\Server\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -onoteinfo="Test Notes; We added an update here"
```

[Jump to Top :arrow_up:](#)
___

## `Set-OMPrinterRedirection`

##### _<font color="red">Experimental</font>_

This sets a printer to send any incoming jobs to another printer instead. This is used when a printer is physically disabled, and the users need the print jobs to come out on another printer.

| Parameter | Description |
| --------- | :---------- |
| `PrinterName`    | The name of the printer to redirect |
| `AltPrinter`     | The name of the printer where the jobs should be sent |
| `Reset`          | Disable the printer redirection |
| `PrintDebugInfo` | Test switch to dump out debugging data for OMPlus |
| `ReallyDoIt`     | This function is considered relatively dangerous, and without this switch the redirection or reset will not be performed |

##### _Example_

```powershell
PS C:\> Set-OMPrinterAltDestination -PrinterName Printer01 -AltPrinter Printer02

PS C:\> Set-OMPrinterRedirection -PrinterName Printer01 -Reset
```

[Jump to Top :arrow_up:](#)
___

### `Sync-OMSecondaryPrinters`

#### _<font color="red">Temporarily Removed</font>_

This function uses dmdestsync.exe to either push a printer from the primary MPS server, or pull it from the secondary (depending on where it is run from).

| Parameter Name | Description |
| :-- | :-- |
| `PrinterName` | The specific printer(s) to pull/push; if it is set to 'All', it will sync all of the printers. With _All_ printers, it is a slow process.  |
| `ShowProgress` | This will display a progress bar showing the printers as they are synchronized. |

##### _Example_

```powershell
PS C:\Sync-OMSecondaryPrinters -PrinterName Printer01, Printer02

PS C:\Sync-OMSecondaryPrinters -PrinterName All
The PrinterName list contains "All", this will take some time
```

[Jump to Top :arrow_up:](#)

___

### `Test-Port`

This is a generic function to test the reponsiveness of a remote machine on a specific TCP port.

| Parameter Name | Description |
| :-- | :-- |
| `ComputerName` | The resolvable name or ip address to test |
| `TCPPort` | The TCP port to test; it is defaulted to TCP/9100; other typical ports to test are 515 for LPR/LPD, 80/443 for web pages etc.|
| `TimeOutinMilliseconds` | The timeout that the script will wait for, before giving up and returning `$false`.  It is defaulted to 3000 (3 seconds). |

##### _Example_

```powershell
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 9100
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 515
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 80
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 443
False
```

[Jump to Top :arrow_up:](#)

___

## `Update-OMEPR`

##### _<font color="red">Experimental</font>_

| Parameter | Description |
| --------- | :---------- |
| `Destination`  | The name of the printer/destination to modify records for; this can target multiple records (queues) at once |
| `DriverName`   | The new drivername to apply to the EPR |
| `DuplexOption` | The new duplex setting to apply to the EPR |
| `IsRX`         | The new RX setting for the EPR |
| `MediaType`    | The new media type to apply to the EPR |
| `Override`     | |
| `PaperSize`    | The new paper size to apply to the EPR |
| `Queue`        | The specific EPR to update |
| `TrayName`     | The new tray to apply to the EPR |

##### _Example_

[Jump to Top :arrow_up:](#)

___

### `Update-OMTransformServer`

This function triggers the automatic update of the `eps_map` and other files from the primary MPS server to the secondary MPS server.
It happens automatically when the Save button in the EPR Records dialog is clicked.  If the `eps_map` file is updated, and this function is not called, the Transform Servers are not aware of the new printers and updated EPR Records.
It reads the `sendHosts` file and uses `pingmessage.exe` against the hosts in that file.

There are no parameters for this function

##### _Example_

```powershell
PS C:\> Update-OMTransformServer
VERBOSE: Using pingmsg to update host: transformserver01.hchd.local
VERBOSE: Triggering update for transformserver01.hchd.local
VERBOSE: Using pingmsg to update host: transformserver02.hchd.local
VERBOSE: Triggering update for transformserver02.hchd.local
VERBOSE: Using pingmsg to update host: transformserver03.hchd.local
VERBOSE: Triggering update for transformserver03.hchd.local
VERBOSE: Using pingmsg to update host: transformserver04.hchd.local
VERBOSE: Triggering update for transformserver04.hchd.local
```

[Jump to Top :arrow_up:](#)

---

## Known Bugs

<a name="bugs"></a>
