/***
*
*  Getsys.prg
*
*  Standard Clipper 5.2 GET/READ Subsystem
*
*  Copyright (c) 1991-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  This version adds the following public functions:
*
*     ReadKill( [<lKill>] )       --> lKill
*     ReadUpdated( [<lUpdated>] ) --> lUpdated
*     ReadFormat( [<bFormat>] )   --> bFormat | NIL
*
*  NOTE: compile with /m /n /w
*
*/

#include "Inkey.ch"
#include "Getexit.ch"

#define K_UNDO          K_CTRL_U

//
// State variables for active READ
//
static sbFormat
static slUpdated       := .F.
static slKillRead
static slBumpTop
static slBumpBot
static snLastExitState
static snLastPos
static soActiveGet
static scReadProcName
static snReadProcLine

//
// Format of array used to preserve state variables
//
#define GSV_KILLREAD       1
#define GSV_BUMPTOP        2
#define GSV_BUMPBOT        3
#define GSV_LASTEXIT       4
#define GSV_LASTPOS        5
#define GSV_ACTIVEGET      6
#define GSV_READVAR        7
#define GSV_READPROCNAME   8
#define GSV_READPROCLINE   9

#define GSV_COUNT          9

/***
*
*  ReadModal()
*
*  Standard modal READ on an array of GETs
*
*/
function readmodal( GetList, nPos )

local oGet
local aSavGetSysVars

if ( valtype( sbFormat ) == "B" )
   eval( sbFormat )
endif

if ( empty( GetList ) )

   // S'87 compatibility
   setpos( maxrow() - 1, 0 )
   return ( .F. )   // NOTE

endif

// Preserve state variables
aSavGetSysVars := ClearGetSysVars()

// Set these for use in SET KEYs
scReadProcName := procname( 1 )
snReadProcLine := procline( 1 )

// Set initial GET to be read
if !( valtype( nPos ) == "N" .and. nPos > 0 )
   nPos := Settle( Getlist, 0 )
endif

while !( nPos == 0 )

   // Get next GET from list and post it as the active GET
   PostActiveGet( oGet := GetList[ nPos ] )

   // Read the GET
   if ( valtype( oGet:reader ) == "B" )
      eval( oGet:reader, oGet )         // Use custom reader block
   else
      GetReader( oGet )                 // Use standard reader
   endif

   // Move to next GET based on exit condition
   nPos := Settle( GetList, nPos )

enddo

// Restore state variables
RestoreGetSysVars( aSavGetSysVars )

// S'87 compatibility
setpos( maxrow() - 1, 0 )

return ( slUpdated )

/***
*
*  GetReader()
*
*  Standard modal read of a single GET
*
*/
procedure GetReader( oGet )

// Read the GET if the WHEN condition is satisfied
if ( GetPreValidate( oGet ) )

   // Activate the GET for reading
   oGet:setFocus()

   while ( oGet:exitState == GE_NOEXIT )

      // Check for initial typeout (no editable positions)
      if ( oGet:typeOut )
         oGet:exitState := GE_ENTER
      endif

      // Apply keystrokes until exit
      while ( oGet:exitState == GE_NOEXIT )
         GetApplyKey( oGet, ifscrdo( .t. ) )
         //GetApplyKey( oGet, ChckMsg() )
      enddo

      // Disallow exit if the VALID condition is not satisfied
      if ( !GetPostValidate( oGet ) )
         oGet:exitState := GE_NOEXIT
      endif
   enddo

   // De-activate the GET
   oGet:killFocus()

endif

return

/***
*
*  GetApplyKey()
*
*  Apply a single INKEY() keystroke to a GET
*
*  NOTE: GET must have focus.
*
*/
procedure GetApplyKey( oGet, nKey )

local cKey
local bKeyBlock

// Check for SET KEY first
if !( ( bKeyBlock := setkey( nKey ) ) == NIL )
   GetDoSetKey( bKeyBlock, oGet )
   return           // NOTE
endif

do case
case ( nKey == K_UP )
   oGet:exitState := GE_UP

case ( nKey == K_SH_TAB )
   oGet:exitState := GE_UP

case ( nKey == K_DOWN )
   oGet:exitState := GE_DOWN

case ( nKey == K_TAB )
   oGet:exitState := GE_DOWN

case ( nKey == K_ENTER )
   oGet:exitState := GE_ENTER

case ( nKey == K_ESC )
   if ( set( _SET_ESCAPE ) )

      oGet:undo()
      oGet:exitState := GE_ESCAPE

   endif

case ( nKey == K_PGUP )
   oGet:exitState := GE_WRITE

case ( nKey == K_PGDN )
   oGet:exitState := GE_WRITE

case ( nKey == K_CTRL_HOME )
   oGet:exitState := GE_TOP

#ifdef CTRL_END_SPECIAL

   // Both ^W and ^End go to the last GET
case ( nKey == K_CTRL_END )
   oGet:exitState := GE_BOTTOM

#else

   // Both ^W and ^End terminate the READ (the default)
case ( nKey == K_CTRL_W )
   oGet:exitState := GE_WRITE

#endif

case ( nKey == K_INS )
   set( _SET_INSERT, !set( _SET_INSERT ) )
   ShowScoreboard()

case ( nKey == K_UNDO )
   oGet:undo()

case ( nKey == K_HOME )
   oGet:home()

case ( nKey == K_END )
   oGet:end()

case ( nKey == K_RIGHT )
   oGet:right()

case ( nKey == K_LEFT )
   oGet:left()

case ( nKey == K_CTRL_RIGHT )
   oGet:wordRight()

case ( nKey == K_CTRL_LEFT )
   oGet:wordLeft()

case ( nKey == K_BS )
   oGet:backSpace()

case ( nKey == K_DEL )
   oGet:delete()

case ( nKey == K_CTRL_T )
   oGet:delWordRight()

case ( nKey == K_CTRL_Y )
   oGet:delEnd()

case ( nKey == K_CTRL_BS )
   oGet:delWordLeft()

otherwise

   if ( nKey >= 32 .and. nKey <= 255 )

      cKey := chr( nKey )

      if ( oGet:type == "N" .and. ( cKey == "." .or. cKey == "," ) )
         oGet:toDecPos()
      else

         if ( set( _SET_INSERT ) )
            oGet:insert( cKey )
         else
            oGet:overstrike( cKey )
         endif

         if ( oGet:typeOut )
            if ( set( _SET_BELL ) )
               ?? chr( 7 )
            endif

            if ( !set( _SET_CONFIRM ) )
               oGet:exitState := GE_ENTER
            endif
         endif

      endif

   endif

endcase

return

/***
*
*  GetPreValidate()
*
*  Test entry condition (WHEN clause) for a GET
*
*/
function GetPreValidate( oGet )

local lSavUpdated
local lWhen       := .T.

if !( oGet:preBlock == NIL )

   lSavUpdated := slUpdated

   lWhen := eval( oGet:preBlock, oGet )

   oGet:display()

   ShowScoreBoard()
   slUpdated := lSavUpdated

endif

if ( slKillRead )

   lWhen          := .F.
   oGet:exitState := GE_ESCAPE          // Provokes ReadModal() exit

elseif ( !lWhen )

   oGet:exitState := GE_WHEN            // Indicates failure

else

   oGet:exitState := GE_NOEXIT          // Prepares for editing

end

return ( lWhen )

/***
*
*  GetPostValidate()
*
*  Test exit condition (VALID clause) for a GET
*
*  NOTE: Bad dates are rejected in such a way as to preserve edit buffer
*
*/
function GetPostValidate( oGet )

local lSavUpdated
local lValid      := .T.

if ( oGet:exitState == GE_ESCAPE )
   return ( .T. )   // NOTE
endif

if ( oGet:badDate() )
   oGet:home()
   DateMsg()
   ShowScoreboard()
   return ( .F. )   // NOTE
endif

// If editing occurred, assign the new value to the variable
if ( oGet:changed )
   oGet:assign()
   slUpdated := .T.
endif

// Reform edit buffer, set cursor to home position, redisplay
oGet:reset()

// Check VALID condition if specified
if !( oGet:postBlock == NIL )

   lSavUpdated := slUpdated

   // S'87 compatibility
   setpos( oGet:row, oGet:col + len( oGet:buffer ) )

   lValid := eval( oGet:postBlock, oGet )

   // Reset S'87 compatibility cursor position
   setpos( oGet:row, oGet:col )

   ShowScoreBoard()
   oGet:updateBuffer()

   slUpdated := lSavUpdated

   if ( slKillRead )
      oGet:exitState := GE_ESCAPE       // Provokes ReadModal() exit
      lValid         := .T.

   endif
endif

return ( lValid )

/***
*
*  GetDoSetKey()
*
*  Process SET KEY during editing
*
*/
procedure GetDoSetKey( keyBlock, oGet )

local lSavUpdated

// If editing has occurred, assign variable
if ( oGet:changed )
   oGet:assign()
   slUpdated := .T.
endif

lSavUpdated := slUpdated

eval( keyBlock, scReadProcName, snReadProcLine, readvar() )

ShowScoreboard()
oGet:updateBuffer()

slUpdated := lSavUpdated

if ( slKillRead )
   oGet:exitState := GE_ESCAPE          // provokes ReadModal() exit
endif

return

/***
*              READ services
*/

/***
*
*  Settle()
*
*  Returns new position in array of Get objects, based on:
*     - current position
*     - exitState of Get object at current position
*
*  NOTES: return value of 0 indicates termination of READ
*         exitState of old Get is transferred to new Get
*
*/
static function Settle( GetList, nPos )

local nExitState

if ( nPos == 0 )
   nExitState := GE_DOWN
else
   nExitState := GetList[ nPos ] :exitState
endif

if ( nExitState == GE_ESCAPE .or. nExitState == GE_WRITE )
   return ( 0 )     // NOTE
endif

if !( nExitState == GE_WHEN )
   // Reset state info
   snLastPos := nPos
   slBumpTop := .F.
   slBumpBot := .F.
else
   // Re-use last exitState, do not disturb state info
   nExitState := snLastExitState
endif

//
// Move
//
do case
case ( nExitState == GE_UP )
   nPos --

case ( nExitState == GE_DOWN )
   nPos ++

case ( nExitState == GE_TOP )
   nPos       := 1
   slBumpTop  := .T.
   nExitState := GE_DOWN

case ( nExitState == GE_BOTTOM )
   nPos       := len( GetList )
   slBumpBot  := .T.
   nExitState := GE_UP

case ( nExitState == GE_ENTER )
   nPos ++

endcase

//
// Bounce
//
if ( nPos == 0 )    // Bumped top
   if ( !readexit() .and. !slBumpBot )
      slBumpTop  := .T.
      nPos       := snLastPos
      nExitState := GE_DOWN
   endif

elseif ( nPos == len( GetList ) + 1 )   // Bumped bottom
   if ( !readexit() .and. !( nExitState == GE_ENTER ) .and. !slBumpTop )
      slBumpBot  := .T.
      nPos       := snLastPos
      nExitState := GE_UP
   else
      nPos := 0
   endif
endif

// Record exit state
snLastExitState := nExitState

if !( nPos == 0 )
   GetList[ nPos ] :exitState := nExitState
endif

return ( nPos )

/***
*
*  PostActiveGet()
*
*  Post active GET for ReadVar(), GetActive()
*
*/
static procedure PostActiveGet( oGet )

GetActive( oGet )
readvar( GetReadVar( oGet ) )

ShowScoreBoard()

return

/***
*
*  ClearGetSysVars()
*
*  Save and clear READ state variables. Return array of saved values
*
*  NOTE: 'Updated' status is cleared but not saved (S'87 compatibility)
*/
static function ClearGetSysVars()

local aSavSysVars[ GSV_COUNT ]

// Save current sys vars
aSavSysVars[ GSV_KILLREAD ]     := slKillRead
aSavSysVars[ GSV_BUMPTOP ]      := slBumpTop
aSavSysVars[ GSV_BUMPBOT ]      := slBumpBot
aSavSysVars[ GSV_LASTEXIT ]     := snLastExitState
aSavSysVars[ GSV_LASTPOS ]      := snLastPos
aSavSysVars[ GSV_ACTIVEGET ]    := GetActive( NIL )
aSavSysVars[ GSV_READVAR ]      := readvar( "" )
aSavSysVars[ GSV_READPROCNAME ] := scReadProcName
aSavSysVars[ GSV_READPROCLINE ] := snReadProcLine

// Re-init old ones
slKillRead      := .F.
slBumpTop       := .F.
slBumpBot       := .F.
snLastExitState := 0
snLastPos       := 0
scReadProcName  := ""
snReadProcLine  := 0
slUpdated       := .F.

return ( aSavSysVars )

/***
*
*  RestoreGetSysVars()
*
*  Restore READ state variables from array of saved values
*
*  NOTE: 'Updated' status is not restored (S'87 compatibility)
*
*/
static procedure RestoreGetSysVars( aSavSysVars )

slKillRead      := aSavSysVars[ GSV_KILLREAD ]
slBumpTop       := aSavSysVars[ GSV_BUMPTOP ]
slBumpBot       := aSavSysVars[ GSV_BUMPBOT ]
snLastExitState := aSavSysVars[ GSV_LASTEXIT ]
snLastPos       := aSavSysVars[ GSV_LASTPOS ]

GetActive( aSavSysVars[ GSV_ACTIVEGET ] )

readvar( aSavSysVars[ GSV_READVAR ] )

scReadProcName := aSavSysVars[ GSV_READPROCNAME ]
snReadProcLine := aSavSysVars[ GSV_READPROCLINE ]

return

/***
*
*  GetReadVar()
*
*  Set READVAR() value from a GET
*
*/
static function GetReadVar( oGet )

local cName := upper( oGet:name )
local i

// The following code includes subscripts in the name returned by
// this FUNCTIONtion, if the get variable is an array element
//
// Subscripts are retrieved from the oGet:subscript instance variable
//
// NOTE: Incompatible with Summer 87
//
if !( oGet:subscript == NIL )
   for i := 1 to len( oGet:subscript )
      cName += "[" + ltrim( str( oGet:subscript[ i ] ) ) + "]"
   next
end

return ( cName )

/***
*              System Services
*/

/***
*
*  __SetFormat()
*
*  SET FORMAT service
*
*/
procedure __SetFormat( b )

sbFormat := if( valtype( b ) == "B", b, NIL )
return

/***
*
*  __KillRead()
*
*  CLEAR GETS service
*
*/
procedure __KillRead()

slKillRead := .T.
return

/***
*
*  GetActive()
*
*  Retrieves currently active GET object
*/
function GetActive( g )

local oldActive := soActiveGet

if ( pcount() > 0 )
   soActiveGet := g
endif

return ( oldActive )

/***
*
*  Updated()
*
*/
function updated()

return slUpdated

/***
*
*  ReadExit()
*
*/
function readexit( lNew )

return ( set( _SET_EXIT, lNew ) )

/***
*
*  ReadInsert()
*
*/
function readinsert( lNew )

return ( set( _SET_INSERT, lNew ) )

/***
*              Wacky Compatibility Services
*/

// Display coordinates for SCOREBOARD
#define SCORE_ROW      0
#define SCORE_COL      60

/***
*
*  ShowScoreboard()
*
*/
static procedure ShowScoreboard()

local nRow
local nCol

if ( set( _SET_SCOREBOARD ) )
   nRow := row()
   nCol := col()

   setpos( SCORE_ROW, SCORE_COL )
   dispout( if( set( _SET_INSERT ), "Ins", "   " ) )
   setpos( nRow, nCol )
endif

return

/***
*
*  DateMsg()
*
*/
static procedure DateMsg()

local nRow
local nCol

if ( set( _SET_SCOREBOARD ) )

   nRow := row()
   nCol := col()

   setpos( SCORE_ROW, SCORE_COL )
   dispout( "Invalid Date" )
   setpos( nRow, nCol )

   while ( nextkey() == 0 )
   end

   setpos( SCORE_ROW, SCORE_COL )
   dispout( space( 12 ) )
   setpos( nRow, nCol )

endif

return

/***
*
*  RangeCheck()
*
*  NOTE: Unused second param for 5.00 compatibility.
*
*/
function RangeCheck( oGet, junk, lo, hi )

local cMsg
local nRow
local nCol
local xValue

if ( !oGet:changed )
   return ( .T. )   // NOTE
endif

xValue := oGet:varGet()

if ( xValue >= lo .and. xValue <= hi )
   return ( .T. )   // NOTE
endif

if ( set( _SET_SCOREBOARD ) )

   cMsg := "Range: " + ltrim( transform( lo, "" ) ) + ;
           " - " + ltrim( transform( hi, "" ) )

   if ( len( cMsg ) > maxcol() )
      cMsg := substr( cMsg, 1, maxcol() )
   endif

   nRow := row()
   nCol := col()

   setpos( SCORE_ROW, min( 60, maxcol() - len( cMsg ) ) )
   dispout( cMsg )
   setpos( nRow, nCol )

   while ( nextkey() == 0 )
   end

   setpos( SCORE_ROW, min( 60, maxcol() - len( cMsg ) ) )
   dispout( space( len( cMsg ) ) )
   setpos( nRow, nCol )

endif

return ( .F. )

/***
*
*  ReadKill()
*
*/
function ReadKill( lKill )

local lSavKill := slKillRead

if ( pcount() > 0 )
   slKillRead := lKill
endif

return ( lSavKill )

/***
*
*  ReadUpdated()
*
*/
function ReadUpdated( lUpdated )

local lSavUpdated := slUpdated

if ( pcount() > 0 )
   slUpdated := lUpdated
endif

return ( lSavUpdated )

/***
*
*  ReadFormat()
*
*/
function ReadFormat( b )

local bSavFormat := sbFormat

if ( pcount() > 0 )
   sbFormat := b
endif

return ( bSavFormat )
//-------
function ifscrdo( lGetsys )

local x     := iif( lGetsys, inkey( 300 ), 0 )
local y
local xxold := setcolor()
setcursor( 0 )
setcursor( .f. )
set cursor off
if x = 0
   y := savescreen()
   dispbegin()
   dispscrn()
   dispend()
   do while donecessary( lGetSys )
      dispbegin()
      moveEA_e()    // ALL OF THESE FUNCS. ARE PROGRESSIVE
      moveEA_A()    // PART BY PART ONLY HAPPENS EACH TIME.
      moveINANDOUT()
      dispend()
      dispend()
   enddo
   restscreen( 0, 0, 24, 79, y )
endif
setcursor( 1 )
setcolor( xxold )
return x
//-----------------------
static function donecessary( lAfterKey )

static x := 0
local y
if lAfterKey
   y := ( inkey() == 0 )
else
   x ++
   y := !( x > 60 )
endif
return y
//------------------------
static function moveEA_e( aPos )

static nRow       := 11
static nCol       := 03
static lGoRight   := .t.
static lGoUp      := .t.
static aColors    := { 'W', 'BR', 'R', 'GR', 'BG', 'B', 'G' }
static whichcolor := 0

local aA := { "ллллллллл лллллл лллллл лл лл", ;
              "л         л    л л      лл лл", ;
              "ллллллллл лллллл лллллл ллллл", ;
              "л         л    л      л    лл", ;
              "ллллллллл л    л лллллл ллллл" }

local x := 1
local y

dispscrn( .t. )

//setcolor('+' + aColors[++whichcolor % 7 + 1] + '/N*')

@ nRow - 1, nCol - 1 clear to nRow + len( aA ) + 1, nCol + len( aA[ 1 ] ) + 1
@ nRow - 1, nCol - 1 to nRow + len( aA ) + 1, nCol + len( aA[ 1 ] ) + 1
for x := 1 to len( aA )
   @ nRow, nCol say aA[ x ]         
   nRow ++
next x

nRow -= len( aA )

if lgoUp
   nRow --
   if nRow < 3
      lgoUp := .f.
   endif
else
   nRow ++
   if nRow > 15
      lGoUp := .t.
   endif
endif

if lGoRight
   if nCol < 40
      nCol += 1
   else
      lGoRight := .f.
   endif
else
   if nCol > 3
      nCol -= 1
   else
      lGoRight := .t.
   endif
endif
for y := 1 to 8000
next y
return .t.
//----------------------
static function moveEA_a( aPos )

static nRow     := 11
static nCol     := 03
static lGoRight := .t.
static lGoUp    := .f.

static aColors    := { 'W', 'BR', 'R', 'GR', 'BG', 'B', 'G' }
static whichcolor := 4

local aA := { "ллллллл  ллллл  ллллл   лллл   л    л  лллл  л ллллл лллл", ;
              "л     л  л      л      л    л  л    л  л  л  л   л   л   ", ;
              "ллллллл  л      л      л    л  л    л  л  л  л   л   лллл", ;
              "л     л  л      л      л    л  л    л  л  л  л   л      л", ;
              "л     л  ллллл  ллллл   лллл    мммм   л  лллл   л   лллл" }

local x := 1
local y

//setcolor('+' + aColors[++whichcolor % 7 + 1] + '/N*')

@ nRow - 1, nCol - 1 clear to nRow + len( aA ) + 1, nCol + len( aA[ 1 ] ) + 1
@ nRow - 1, nCol - 1 to nRow + len( aA ) + 1, nCol + len( aA[ 1 ] ) + 1
for x := 1 to len( aA )
   @ nRow, nCol say aA[ x ]         
   nRow ++
next x

nRow -= len( aA )

if lgoUp
   nRow --
   if nRow < 3
      lgoUp := .f.
   endif
else
   nRow ++
   if nRow > 15
      lGoUp := .t.
   endif
endif

if lGoRight
   if nCol < 22
      nCol += 1
   else
      lGoRight := .f.
   endif
else
   if nCol > 3
      nCol -= 1
   else
      lGoRight := .t.
   endif
endif
for y := 1 to 8000
next y
return .t.
//----------------
static function moveINANDOUT

static x   := 1
static y   := 1
static jx  := 'EasyAccounts!'
static jy  := 'Accounts - Easy!'
static lDo := .t.
setcolor( "N*/W+" )
setblink( .f. )
@ 24,  0 say space( 80 )         
if !lDo
   @ 24,  0 say padc( subs( jy, 1, y ) + space( len( jy ) - y ), 79 )         
   if y >= len( jy )
      y   := 1
      lDo := .t.
   else
      y ++
   endif
elseif lDo
   @ 24,  0 say padc( subs( jx, 1, y ), 79 )         
   if y >= len( jx )
      if jx = 'EasyAccounts!'
         jx := 'Accounts - Easy!'
      else
         jx := 'EasyAccounts!'
      endif
      y   := 1
      lDo := .f.
   else
      y ++
   endif
endif
for x := 1 to 3000
next x
return .t.
//---------------------------------
/*
function ChkMsg
local cMessage := space(filesize(MSGFILE))
local cTo := "",x := {},y
fseek(MSGFILE,0)
cMessage := fread(MSGFILE,cMessage,len(cMessage))
cTo := subs( cMessage, at( chr(255) )+1 )
cMessage := subs(cMessage,1, chr(255) -1)
for y := 1 to len(cTo)
   aadd(x, subs(cTo,y,2) )
   y += 2
next y
cTo := ""
*/

*+ EOF: GETSYS.PRG
