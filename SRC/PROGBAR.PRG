/*
#
#     User Interaction - Progress Bar
#              for EasyAccounts v2.1
#
#     Developed and Tested by Jasim A B
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
#    --------------------------------
#           (C) Jasim A Basheer
#    ---------------------------------
*/

#include "std.ch"
#include "grump.ch"
#include "fileio.ch"

static nGraphLen    // must be re-initialized each time INDEXBAR() is called

static jnRec
static nTotRecs
static jOldState
static jOldFile
static jOldAlt
static jOldAltFile
static jOldConsole
static lpBarActive
static cMessage
static oldscrn
static nnRow
static nnLeft

function ShowPBar( cMsg, nRow, lShouldNotDisp )

local xx
local nLeft
local cInColor
local nOldRow  := row()
local nOldCol  := col()
local NoldP1   := prow()
local noldp2   := pcol()

jnRec    := 1
nTotRecs := 0

lpBarActive := .t.

jResetSets()

if ( lShouldNotDisp == NIL .and. lShouldNotDisp != .T. )
   dispscrn()       // Clear off all the eariler leftovers...
endif

if cMsg = NIL
   cMsg := "Please Wait..."
endif

cMessage := cMsg

nGraphLen := 0
GFSaveEnv(, 0 )

default nRow to ( maxrow() / 2 ) - 3
nnRow := nRow
ColorSet( C_MESSAGE )
nLeft := ( maxcol() / 2 ) - 30
dispbegin()
oldscrn := shadowbox( nRow, nLeft, nRow + 6, nLeft + 63, 2 )
@ nRow + 3, nLeft + 2 ssay 'ณ'
@ nRow + 3, nLeft + 61 ssay 'ณ'
@ nRow + 4, nLeft + 2 ssay 'ิ' + replicate( "อออออฯ", 9 ) + 'ออออพ'
@ nRow + 5, nLeft + 2 ssay '0'
for xx := 1 to 10
   @ nRow + 5, nLeft + xx * 6 ssay str( 10 * xx, 3 )
next
SCRNCENTER( nRow + 1, cMsg )

ColorSet( C_APICK_STATUSBAR )
@ nRow + 3, nLeft + 3 ssay replicate( chr( 177 ), 58 )
setpos( nRow + 3, nLeft + 3 )
nnLeft := nLeft
dispend()
ColorSet( C_APICK_INDICATOR )

setcolor( cInColor )
@ nOldRow, nOldCol say ""         
setprc( noldp1, noldp2 )

jRestoreSets()

return .t.
//------------------------
function IncrPBar

jnRec ++
if nTotRecs = 0
   RefreshPBar( ( jnRec / reccount() ) * 100 )
else
   RefreshPBar( ( jnRec / nTotRecs ) * 100 )
endif
return .t.
//------------------------
function RefreshPBar( nPerc )

local oldcol
local cOldColor := setcolor()
local nPDisp

nPerc := round( nPerc, 0 )
if nPerc > 100
   nPerc := 100
endif
setcursor( 0 )
setcursor( .f. )
jResetSets()

ColorSet( C_MESSAGE )
oldcol := col()
dispbegin()
SCRNCENTER( nnRow + 1, rtrim( ltrim( cMessage ) ) + "  " + rtrim( ltrim( str( round( nPerc, 0 ) ) ) ) + "%" )
setpos( nnRow + 3, oldcol )
ColorSet( C_APICK_INDICATOR )

nPDisp := round( ( nPerc / 100 ) * 58, 0 )
if nPDisp > 58
   nPDisp := 58
endif

@ nnRow + 3, nnLeft + 3 say repli( chr( 219 ), nPDisp )         

/*
do while nGraphLen < nPDisp
   dispout(chr(219))       
   nGraphLen++
enddo
*/

dispend()

jRestoreSets()
setcolor( cOldColor )

return .t.

//-------------------------------
function HidePBar

jResetSets()
byebyebox( oldscrn )
GFRestEnv()
jRestoreSets()
jnRec       := 0
lpBarActive := .f.
cUnder      := ""
cMessage    := ""
setcursor( .t. )
setcursor( 1 )
return .t.
//----------------------------
function IsPBarActive

if lpBarActive = NIL
   lpBarActive := .f.
endif
return lpBarActive
//-------------------------------
function jResetSets

jOldState   := set( _SET_DEVICE )
jOldFile    := set( _SET_PRINTFILE )
jOldAlt     := set( _SET_ALTERNATE )
jOldAltFile := set( _SET_ALTFILE )
jOldConsole := set( _SET_CONSOLE )

set device to screen
set printer off
set printer to
set console on

set alternate off
set alternate to
return .t.
//--------------------------------
function jRestoreSets

set( _SET_DEVICE, jOldState )
if jOldState = 'PRINTER'
   set printer on
else
   set printer off
endif

set( _SET_PRINTFILE, jOldFile, .t. )    // True means additive.
set( _SET_CONSOLE, jOldConsole )
set( _SET_ALTERNATE, jOldAlt )
set( _SET_ALTFILE, jOldAltFile, .t. )
return .t.
//---------------------
function PBarFilter

local x := recno()
nTotRecs := 0
do while .not. eof()
   nTotRecs ++
   skip
enddo
go x
return .t.
//---------------------
function SetPBarCount( nCount )

nTotRecs := nCount
return .t.
//--------------------
function MakePBarActive(lWhat)
local lOldPBar := iif(lpBarActive=NIL,.F.,lpBarActive)
if lWhat != NIL
   lpBarActive := lWhat
endif
return lOldPBar
//------------------
*+ EOF: PROGBAR.PRG
