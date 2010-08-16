/*
   This file contains a comprehensive Clipper 5.x error-logger, i.e.,
   whenever a run-time error occurs, all relevant information concerning
   said error will be written to a text file.  Obviously this is far
   more reliable than trusting the end user to give you information
   about the error.  If you have either Telepathy or Faxual (both
   products are sold by Extrasensory Software), and are feeling
   ambitious, you could improve upon this by having the error log file
   automatically sent to you via modem or fax.  This also completely
   eliminates the end user from "the loop" (except, of course, for
   the fact that they will have caused the error in the first place,
   but that's what end users are for).

   All calls to Clipper's ALERT() function have been replaced with
   GFALERT(), the Grumpfish Library equivalent that is mouse-aware.

   Legalese:  The basic DefError() function is Copyright (c) 1990-1993
   by Computer Associates International, Inc.

   Numerous modifications by Greg Lief, 1991-1993, including:

   1) graceful handling of printer errors
   2) logging relevant error information to a log file
   3) mouseability

   New functions include:

        LogError()
        IfEmpty()
        PrintError()
        ConvertArgs()
        DosErrCode()
        DosErrText()
        GenCodeText()

   To use this error logger in your Clipper 5.x applications, compile
   this file with the syntax:

   CLIPPER ERRORLOG /N /W

   If you are using CA-Clipper 5.2, please use the following syntax
   for compilation (be sure to specify "CLIPPER52" in upper-case!):

   CLIPPER ERRORLOG /N /W /DCLIPPER52

   You may wish to change the manifest constants APP_NAME and LOGFILE,
   which appear below.  The APP_NAME will be written as part of the
   error log.  The LOGFILE denotes the name of the error log file. The
   default filename is ERROR.TXT.

   Be sure to link ERRORLOG.OBJ in with the rest of your object files.
   That's all, folks!

   Special thanks to Craig Yellick for his assistance with the
   functions IfEmpty() and DosErrText().

*/

#include "error.ch"
#include "grump.ch"        // for WAITOFF()

// used below
#define NTRIM(n)  ( LTrim(Str(n)) )

#define LOGFILE   ERRORS.DAT      // dont use quotes

/***
*	ErrorSys()
*
*	Note:  automatically executes at startup
*/
proc ErrorSys()

errorblock( { | e | DefError( e ) } )
return

/***
*	DefError()
*/
static func DefError( e )

local cMessage
local aOptions
local nChoice
local nLastkey

// Greg's additions begin here
nLastkey := lastkey()

// check for printer error
if e:genCode == EG_PRINT
   return PrintError()
endif

/*
   // hook for you to handle corrupted indeces
   if e:genCode == EG_CORRUPTION
      FT_XBOX(,,,,msgcolor(),msgcolor(),,'Index File Corruption Detected','Rebuilding Indices...')
      tone(2991,1)
      tone(4561,1)
      tone(6591,1)
      jSaveEnv()
      close all
      indexfiles()
      jRestEnv()
      return .t.
   endif
*/

// Greg's additions end here... see below for more

// by default, division by zero yields zero
if ( e:genCode == EG_ZERODIV )
   return ( 0 )
endif

// for network open error, set NETERR() and subsystem default
if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
    CLEAR TYPEAHEAD
    if jAlert(' Error : Cannot open file - '+e:fileName, {'Retry','Quit'}) == 2
      ExitMethod := 'Error'
      close all
      set colo to
      clear
      ? 'Exiting...'
      quit
    else
      return .t.
    endif
endif

// for lock error during APPEND BLANK, set NETERR() and subsystem default
if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
   neterr( .t. )
   return ( .f. )   // NOTE
endif

// build error message
cMessage := ErrorMessage( e )

// build options array
aOptions := { "Shutdown EA" }

if ( e:canRetry )
   aadd( aOptions, "Try Again" )
endif

if ( e:canDefault )
   aadd( aOptions, "Ignore" )
endif

// put up alert box
nChoice := 0
do while ( nChoice == 0 )

   set device to screen
   set printer off
   set printer to

   CLEAR TYPEAHEAD
   if ( empty( e:osCode ) )
      nChoice := jAlert( cMessage, aOptions )
   else
      // logic added by Greg to display 'not enough file handles' message
      nChoice := jAlert( "Application not configured for use;;Check SET FILES configuration;" + ;
                         e:description + " " + e:filename, ;
                         { 'Shutdown EA' } )
      quit
   endif

   if ( nChoice == NIL )
      exit
   endif

enddo

if ( !empty( nChoice ) )
   // do as instructed
   if ( aOptions[ nChoice ] == "Shutdown EA" )
      close all
   elseif ( aOptions[ nChoice ] == "Try Again" )
      return ( .t. )
   elseif ( aOptions[ nChoice ] == "Ignore" )
      return ( .f. )
   endif
endif

FT_XBOX(,,,, msgcolor(), msgcolor(),, 'Writing Error Log', 'Please wait...' )
tone( 2991, 1 )
tone( 4561, 1 )
tone( 6591, 1 )
LogError( e, nLastkey )
FT_XBOX(,,,, msgcolor(), msgcolor(),, '** ' + _EasyAccounts + ' abnormal Shutdown', 'Errorlog Written.' )

// give up
errorlevel( 1 )

//***************************INSERTED BY JASIM****************************
//closedatas(comp_add)
&& TO AVOID THE "EA WINDOW ALREADY OPENED" BY NOT EXECUTING THE EXIT PROC.
//*************************************************************************
quit

return ( .f. )

/***
*       ErrorMessage() - Copyright (c) Nantucket Corporation
*/
static func ErrorMessage( e )

local cMessage
// start error message
cMessage := ''
cMessage += if( e:severity > ES_WARNING, "Found Error! ", "Warning! " )
// add subsystem name if available
cMessage += ";;"
// add subsystem's error code if available

// add error description if available
if ( valtype( e:description ) == "C" )
   cMessage += ( "  " + e:description )
end

// add either filename or operation
if ( !empty( e:filename ) )
   cMessage += ( ": " + e:filename )
elseif ( !empty( e:operation ) )
   cMessage += ( ": " + e:operation )
end
return ( cMessage )

/*
     Function: LogError()
     Author:   Greg Lief
     Purpose:  Write relevant error info to log file
     Notes:    Default filename is ERROR.TXT.  This can be changed by
               modifying the manifest constant LOGFILE (see above).
*/
static function LogError( e, nLastkey )

local r
local c
local h
local y
local maxr  := maxrow()
local maxc  := maxcol()
local args  := convertargs( e:args )
local info_ := { "args          " + args, ;
                 "description   " + e:description, ;
                 "filename      " + ifempty( e:filename ), ;
                 "genCode       " + gencodetext( e:genCode ), ;
                 "operation     " + ifempty( e:operation ), ;
                 "osCode        " + doserrcode( e ), ;
                 "severity      " + NTRIM( e:severity ), ;
                 "subCode       " + NTRIM( e:subCode ), ;
                 "subSystem     " + e:subSystem, ;
                 "tries         " + NTRIM( e:tries ), ;
                 replicate( "-", 45 ), ;
                 "Free memory   (0)  " + NTRIM( memory( 0 ) ), ;
                 "Largest block (1)  " + NTRIM( memory( 1 ) ), ;
                 "Run area      (2)  " + NTRIM( memory( 2 ) ), ;
                 "VM available  (3)  " + NTRIM( memory( 3 ) ), ;
                 "EMS available (4)  " + NTRIM( memory( 4 ) ) }
local aInfo
local i         := 2
local cAlias    := ifempty( alias() )
local nWorkArea := select()

#ifdef CLIPPER52
local aRDDs    := rddlist()
local cRDDName := if( empty( alias() ), "<none>", rddname() )
#endif

dbcloseall()        // to ensure enough file handles to write error log
set device to printer
set printer to LOGFILE additive
set print on
set console off

//ÄÄÄÄÄ ensure that we have a file handle to write the error log
h := fopen( "NUL" )
if h <> - 1
   fclose( h )
else
   //ÄÄÄÄÄ redirect everything to the screen (argh...)
   set alternate to
   set printer to
   set console on
endif

? _EasyAccounts + ' ****** ERROR LOG :'
?
? 'Run-time error occurred on ' + dtoc( date() ) + ' at ' + time()
? 'Current directory:       ' + curdir()
?? '   Available diskspace: ' + NTRIM( diskspace() )
? 'Last key pressed:        ' + ltrim( str( nLastkey ) )
? 'Current workarea name:   ' + cAlias
? 'Current workarea number: ' + ltrim( str( nWorkArea ) )

#ifdef CLIPPER52
? "Currently Active RDD:    " + cRDDName
? "Available RDDs: "
y := len( aRDDs )
for i := 1 to y
   ?? aRDDs[ i ]
   if i < y
      ?? ", "
   endif
next
i := 2
#endif

?
? 'Crucial environmental variables:'
? "PATH    = " + ifempty( gete( "PATH" ) )
? "COMSPEC = " + ifempty( gete( "COMSPEC" ) )
? "CLIPPER = " + ifempty( gete( "CLIPPER" ) )
?
?
? "Instance Var  Contents"
? replicate( "-", 50 )
y := len( info_ )
for i := 1 to y
   ? info_[ i ]
next
?
? "Traceback: Procedure/Method Name (Line)"
? replicate( "-", 39 )
i := 1
do while ( !empty( procname( i ) ) )
   ? trim( procname( i ) ) + "(" + rtrim( ltrim( str( procline( i ++ ) ) ) ) + ")"
enddo
?

? replicate( '-', 21 ) + ' application screen at time of error ' + ;
             replicate( '-', 21 ) + chr( 13 ) + chr( 10 )
/*
   The easy way out would be to save the entire screen and then parse
   through it discarding all of the color attributes.  Instead, Ira Emus
   has suggested the following method, which although slower than the
   previously mentioned method, is more bullet-proof because it
   does not require allocating any significant amount of memory
   for the screen shot.  This will be much safer in conditions
   where memory is at a extreme premium.
*/
for r := 0 to maxr
   for c := 0 to maxc
      ?? left( savescreen( r, c, r, c ), 1 )
   next
   ?? chr( 13 ) + chr( 10 )
next
?
? replicate( "=", 79 )
?
?
set printer off
set device to screen
set console on
set printer to
set alternate to
return nil

static function IfEmpty( msg )

local ret_val := "<none>"
if !empty( msg )
   ret_val := left( msg, 68 )
endif
return ret_val

static function PrintError

local buffer
local getlist   := {}
local cfile     := space( 8 )
local ret_val   := .f.
local nchoice   := 0
local oldrow    := row()
local oldcol    := col()
local oldcursor := setcursor()
local olddevice := set( _SET_DEVICE, "SCREEN" )
local oldprint  := set( _SET_PRINTER, .f. )
/*
do while nchoice == 0
   nchoice := jAlert("The printer is not responding!;" + ;
         "(proc " + procname(3) + ", line " + NTRIM(procline(3)) + ")", ;
         {"Retry", "Break", "File", "Quit" })
enddo
do case
   case nchoice == 1
      ret_val := .t.
   case nchoice == 3
      buffer := savescreen(0, 0, 0, maxcol())
      scroll(0, 0, 0, maxcol())
      @ 0, 0 say "Enter filename:" get cfile
      setcursor(1)
      read
      setcursor(oldcursor)
      restscreen(0, 0, 0, maxcol(), buffer)
      set(_SET_PRINTFILE, cfile)
      ret_val := .t.
   case nchoice == 4
      quit
endcase
setpos(oldrow, oldcol)
set(_SET_DEVICE, olddevice)
set(_SET_PRINTER, oldprint)
if nchoice == 2
   break
endif
*/
set printer off
set printer to
set device to screen
if prncheck()
   ret_val := .t.
else
   do while empty( rtrim( ltrim( cFile ) ) )
      popread( .f., 'Alternate File Name : ', @cFile, '@!' )
   enddo
   set( _SET_PRINTFILE, cfile )
endif
setcursor( oldcursor )
restscreen( 0, 0, 0, maxcol(), buffer )
ret_val := .t.
setpos( oldrow, oldcol )
set( _SET_DEVICE, olddevice )
set( _SET_PRINTER, oldprint )

return ( ret_val )

/*
     Function: ConvertArgs()
     Author:   Greg Lief
     Purpose:  Convert e:args array to character string so that it
               can be written to the log file
     Returns:  character string
*/
static function convertargs( a )

local ret_val
local numargs := if( a <> NIL, len( a ), 0 )
local x
local ctype
if numargs > 0
   ret_val := '{ '
   for x := 1 to numargs
      ctype := valtype( a[ x ] )
      do case
      case ctype == "C"
         ret_val += a[ x ]
      case ctype == "N"
         ret_val += NTRIM( a[ x ] )
      case ctype == "D"
         ret_val += dtoc( a[ x ] )
      case ctype == "L"
         ret_val += if( a[ x ], ".T.", ".F." )
      case ctype == "O"
         ret_val += a[ x ] :className + " Object"
      case ctype == "U"
         ret_val += "NIL"
      endcase
      //ÄÄÄÄÄ separate arguments
      if x < numargs
         ret_val += ', '
      endif
   next
   ret_val += ' }'
endif
return ifempty( ret_val )

/*
     Function: DosErrCode()
     Author:   Craig Yellick (tweaked by Greg Lief)
     Purpose:  Build description of operating system error
     Returns:  character string
*/
//  Build description of operating system error
static function DosErrCode( e )

local msg
if e:osCode > 0
   msg := NTRIM( e:osCode ) + ": " + left( DosErrText( e:osCode ), 37 )
else
   msg := "(not an operating system error)"
endif
return msg

/*
     Function: DosErrText()
     Author:   Craig Yellick
     Purpose:  Provide full description of DOS error code (see table D-1
               in the Clipper 5.0 "Programming & Utilities Guide")
     Returns:  character string
*/
static function DosErrText( n )

local desc_ := { "Invalid function number", ;               // 1
                 "File not found", ;    // 2
                 "Path not found", ;    // 3
                 "Too many files open (no handles left)", ;                     // 4
                 "Access denied", ;     // 5
                 "Invalid handle", ;    // 6
                 "Memory control blocks destroyed (oh, my)", ;                  // 7
                 "Insufficient memory", ;                   // 8
                 "Invalid memory block address", ;          // 9
                 "Invalid environment", ;                   // 10
                 "Invalid format", ;    // 11
                 "Invalid access code", ;                   // 12
                 "Invalid data", ;      // 13
                 , ;                    // 14
                 "Invalid drive was specified", ;           // 15
                 "Attempt to remove the current directory", ;                   // 16
                 "Not same device", ;   // 17
                 "No more files", ;     // 18
                 "Attempt to write on write-protected diskette", ;              // 19
                 "Unknown unit", ;      // 20
                 "Drive not ready", ;   // 21
                 "Unknown command", ;   // 22
                 "Data error (CRC)", ;  // 23
                 "Bad request structure length", ;          // 24
                 "Seek error", ;        // 25
                 "Unknown media type", ;                    // 26
                 "Sector not found", ;  // 27
                 "Printer out of paper", ;                  // 28
                 "Write fault", ;       // 29
                 "Read fault", ;        // 30
                 "General failure", ;   // 31
                 "Sharing violation", ;                     // 32
                 "Lock violation", ;    // 33
                 "Invalid disk change", ;                   // 34
                 "FCB unavailable", ;   // 35
                 "Sharing buffer overflow", ;               // 36
                 ,,,,,,,,,,,,, ;        // 37-49
                 "Network request not supported", ;         // 50
                 "Remote computer not listening", ;         // 51
                 "Duplicate name on network", ;             // 52
                 "Network name not found", ;                // 53
                 "Network busy", ;      // 54
                 "Network device no longer exists", ;       // 55
                 "Network BIOS command limit exceeded", ;   // 56
                 "Network adapter hardware error", ;        // 57
                 "Incorrect response from network", ;       // 58
                 "Unexpected network error", ;              // 59
                 "Incompatible remote adapter", ;           // 60
                 "Print queue full", ;  // 61
                 "Not enough space for print file", ;       // 62
                 "Print file deleted (not enough space)", ;                     // 63
                 "Network name deleted", ;                  // 64
                 "Access denied", ;     // 65
                 "Network device type incorrect", ;         // 66
                 "Network name not found", ;                // 67
                 "Network name limit exceeded", ;           // 68
                 "Network BIOS session limit exceeded", ;   // 69
                 "Temporarily paused", ;                    // 70
                 "Network request not accepted", ;          // 71
                 "Print or disk redirection paused", ;      // 72
                 ,,,,,,, ;              // 73-79
                 "File already exists", ;                   // 80
                 , ;                    // 81
                 "Cannot make directory entry", ;           // 82
                 "Fail on INT 24h", ;   // 83
                 "Too many redirections", ;                 // 84
                 "Duplicate redirection", ;                 // 85
                 "Invalid password", ;  // 86
                 "Invalid parameter", ;                     // 87
                 "Network device fault", ;                  // 88
                 ;
                 "Undefined or reserved error code!" }      // +1
/*
   Check that code number is within known upper limit,
   and that a description is available for it.
*/
if ( n > ( len( desc_ ) - 1 ) ) .or. ( desc_[ n ] == NIL )
   n := len( desc_ )
endif
return desc_[ n ]

/*
     Function: GenCodeText()
     Author:   Greg Lief
     Purpose:  Provide complete description of general error code
               (including manifest constant from ERROR.CH)
     Notes:    this is specific to the Clipper 5.01 version of the
               ERROR.CH header file.  In the event that these codes
               change in a future version of Clipper, this function
               will have to be modified accordingly.
     Returns:  character string
*/
static function GenCodeText( n )

local desc_ := { "EG_ARG", ;            // 1
                 "EG_BOUND", ;          // 2
                 "EG_STROVERFLOW", ;    // 3
                 "EG_NUMOVERFLOW", ;    // 4
                 "EG_ZERODIV", ;        // 5
                 "EG_NUMERR", ;         // 6
                 "EG_SYNTAX", ;         // 7
                 "EG_COMPLEXITY", ;     // 8
                 ,, ;                   // 9-10
                 "EG_MEM", ;            // 11
                 "EG_NOFUNC", ;         // 12
                 "EG_NOMETHOD", ;       // 13
                 "EG_NOVAR", ;          // 14
                 "EG_NOALIAS", ;        // 15
                 "EG_NOVARMETHOD", ;    // 16
                 "EG_BADALIAS", ;       // 17 (new w/ 5.01a)
                 "EG_DUPALIAS", ;       // 18 (new w/ 5.01a)
                 , ;                    // 19
                 "EG_CREATE", ;         // 20
                 "EG_OPEN", ;           // 21
                 "EG_CLOSE", ;          // 22
                 "EG_READ", ;           // 23
                 "EG_WRITE", ;          // 24
                 "EG_PRINT", ;          // 25
                 ,,,, ;                 // 26-29
                 "EG_UNSUPPORTED", ;    // 30
                 "EG_LIMIT", ;          // 31
                 "EG_CORRUPTION", ;     // 32
                 "EG_DATATYPE", ;       // 33
                 "EG_DATAWIDTH", ;      // 34
                 "EG_NOTABLE", ;        // 35
                 "EG_NOORDER", ;        // 36
                 "EG_SHARED", ;         // 37
                 "EG_UNLOCKED", ;       // 38
                 "EG_READONLY", ;       // 39
                 "EG_APPENDLOCK", ;     // 40
                 ;
                 "Unknown or reserved" }                    // +1
/*
   Check that code number is within known upper limit,
   and that a description is available for it.
*/
if ( n > ( len( desc_ ) - 1 ) ) .or. ( desc_[ n ] == NIL )
   n := len( desc_ )
endif
return NTRIM( n ) + ": " + desc_[ n ]

// end of file ERRORSYS.PRG

*+ EOF: ERRORSYS.PRG
