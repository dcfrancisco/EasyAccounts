#include "std.ch"
#include "inkey.ch"
#include "box.ch"
#ifndef K_LBUTTONDOWN
#define K_LBUTTONDOWN   1002   //   mouse left key press
#define K_RBUTTONDOWN   1004   //   mouse right key press
#endif
#define K_MOUSELEFT K_LBUTTONDOWN
#define K_MOUSERIGHT K_RBUTTONDOWN

static savedwn := {}
static cWindow
static jui_wa  := {}

//-------------------------------------------------------------
// W_M - Windowing Module
//
// Rearranges ROW and COL according to the window
// Also features CENTER and BOTTOM clauses in SAY and PROMPT commands
// for automatic alignment
//
// Drawback : As a lot of 'iif( ' goes in the header file for arranging
//            the coordinates, the EXE size increases considerably and so
//            the amount of memory used.
//            Use of this code should be restricted unless this demerit
//            is removed.
//
// Author : Jasim A Basheer
//-----------------------------------------------------------------

init procedure wnd_init

public jui_wa := {}
aadd( jui_wa, { - 1, - 1, 25, 80, "", nil } )
return

function wnd_create( row1, col1, row2, col2, title, dspwin )

setblink( .F. )
setcolor( boxcolor() )
//"W+/BG")
sls_xplode( .F. )
aadd( jui_wa, { row1, col1, row2, col2, title, makebox( row1, col1, row2, col2, setcolor(), 1 ) } )
sls_xplode( .T. )
if dspwin = NIL .or. dspwin
   setcolor( "N*/W*" )
   @ row1, col1 say padc( rtrim( ltrim( title ) ), col2 - col1 + 1 )         
   setcolor( defcolor() )
else
   unbox( jui_wa[ len( jui_wa ), 6 ] )
endif
setcolor( defcolor() )
return .t.

function wnd_row( cR )

return jui_wa[ len( jui_wa ), 1 ] + 1 + cR

function wnd_col( cC )

return jui_wa[ len( jui_wa ), 2 ] + 1 + cC

function wnd_center( nCol, cExp )

nCol := wnd_col( nCol )
if valtype( cExp ) = 'N'
   cExp := rtrim( ltrim( str( cExp, 18, 2 ) ) )
endif
cExp := strtran( cExp, space( 1 ), chr( 255 ) )             //we don't want trim to trim these ones
cExp := rtrim( padc( rtrim( ltrim( cExp ) ), wnd_right() - nCol ) )
nCol += ( len( cExp ) - len( ltrim( cExp ) ) )
return nCol

function wnd_right( nCol, xpr )

if nCol = NIL
   nCol := jui_wa[ len( jui_wa ), 4 ] - 1
else
   xpr  := rtrim( ltrim( xpr ) )
   nCol := wnd_right() - ( nCol + len( xpr ) - 1 )
endif
return nCol

function wnd_close( wNum )

local aOth
if wNum = NIL
   wNum := len( jui_wa )
endif
if wNum > len( jui_wa ) .or. wNum == 1
   return .f.
endif
unbox( jui_wa[ wNum, 6 ] )
aOth := ascan( savedwn, { | nJui | nJui[ 1 ] == len( jui_wa ) } )
if aOth != 0
   adel( savedwn, aOth )
   asize( savedwn, len( savedwn ) - 1 )
endif
setcolor( "N/BG" )
asize( jui_wa, len( jui_wa ) - 1 )
return .t.

function wnd_bott( nnRow )

if nnRow = NIL
   nnRow := jui_wa[ len( jui_wa ), 3 ] - 1
else
   nnRow := ( jui_wa[ len( jui_wa ), 3 ] - 1 ) - nnRow
endif
return nnRow

function wnd_move

local mRow1
local mRow2
local mCol1
local mCol2
local nOldRow := wnd_uRow( row() )
local nOldCol := wnd_uCol( col() )
local nOldRs  := {}
local nRow1   := jui_wa[ len( jui_wa ), 1 ]
local nRow2   := jui_wa[ len( jui_wa ), 3 ]
local nCol1   := jui_wa[ len( jui_wa ), 2 ]
local nCol2   := jui_wa[ len( jui_wa ), 4 ]
local nKey    := 0
setcolor( "N*/W*" )
@ nRow1, wnd_right( 0, "Moving" ) say "Moving"         
setcolor( "N/BG" )
wnd_rstgets()
do while nKey != K_ENTER
   nKey := rat_event( 0 )
   asize( nOldRs, 4 )
   nOldRs[ 1 ] := nRow1
   nOldRs[ 2 ] := nCol1
   nOldRs[ 3 ] := nRow2
   nOldRs[ 4 ] := nCol2
   if nKey == K_UP
      if nRow1 > 0
         nRow1 --
         nRow2 --
      else
         tone( 300, 3 )
      endif
   elseif nKey == K_DOWN
      if nRow2 < 24
         nRow1 ++
         nRow2 ++
      else
         tone( 300, 3 )
      endif
   elseif nKey == K_RIGHT
      if nCol2 < 79
         nCol1 ++
         nCol2 ++
      else
         tone( 300, 3 )
      endif
   elseif nKey == K_LEFT
      if nCol1 > 0
         nCol1 --
         nCol2 --
      else
         tone( 300, 3 )
      endif
   endif
   if nKey = K_LEFT .or. nKey = K_RIGHT .or. nKey = K_UP .or. nKey = K_DOWN
      jui_wa[ len( jui_wa ), 1 ] := nRow1
      jui_wa[ len( jui_wa ), 2 ] := nCol1
      jui_wa[ len( jui_wa ), 3 ] := nRow2
      jui_wa[ len( jui_wa ), 4 ] := nCol2
      wnd_refresh( len( jui_wa ), nOldRs )
      @ nRow1, wnd_right( 0, "Moving" ) + len( "Moving" ) say ""         
   endif
enddo
wnd_setgets()
@ wnd_Row( nOldRow ), wnd_Col( nOldCol ) say ""         
setcolor( "N*/W*" )
@ nRow1, wnd_right( 0, "Moving" ) say "      "         
setcolor( defcolor() )
@ wnd_Row( nOldRow ), wnd_Col( nOldCol ) say ""         
return .T.

function wnd_refresh( lNum, aOld )

local movescr := savescreen( aOld[ 1 ], aOld[ 2 ], aOld[ 3 ], aOld[ 4 ] )
dispbegin()
//unbox(jui_wa[lNum,6],aOld[1],aOld[2],aOld[3],aOld[4])
unbox( jui_wa[ lNum, 6 ] )
jui_wa[ lNum, 6 ] := makebox( jui_wa[ lNum, 1 ], jui_wa[ lNum, 2 ], jui_wa[ lNum, 3 ], jui_wa[ lNum, 4 ], "W+/BG", 1 )
restscreen( jui_wa[ lNum, 1 ], jui_wa[ lNum, 2 ], jui_wa[ lNum, 3 ], jui_wa[ lNum, 4 ], movescr )
dispend()
return .T.

function wnd_uRow( cR )

return cR - ( jui_wa[ len( jui_wa ), 1 ] + 1 )

function wnd_uCol( cC )

return cC - ( jui_wa[ len( jui_wa ), 2 ] + 1 )

function wnd_rstgets

local c := 1
do while .not. c > len( getlist )
   getlist[ c ] :col := wnd_uCol( getlist[ c ] :col )
   getlist[ c ] :row := wnd_uRow( getlist[ c ] :row )
   c ++
enddo
return getlist

function wnd_setgets

local c := 1
do while .not. c > len( getlist )
   getlist[ c ] :col := wnd_Col( getlist[ c ] :col )
   getlist[ c ] :row := wnd_Row( getlist[ c ] :row )
   c ++
enddo
return getlist

function w_row

return wnd_uRow( row() )

function w_col

return wnd_uCol( col() )

function wnd_status( cTitle )

local oldR := row()
local oldC := col()
if cTitle = NIL
   cTitle := jui_wa[ len( jui_wa ), 5 ]
else
   setcolor( "N*/W*" )
   jui_wa[ len( jui_wa ), 5 ] := cTitle
   @ jui_wa[ len( jui_wa ), 1 ], jui_wa[ len( jui_wa ), 2 ] say padc( rtrim( ltrim( cTitle ) ), jui_wa[ len( jui_wa ), 4 ] - jui_wa[ len( jui_wa ), 2 ] + 1 )         
   setcolor( "N/BG" )
endif
@ wnd_Urow( oldR ), wnd_uCol( oldC ) say ""         
return cTitle

function wnd_save

local lNum := len( jui_wa )
aadd( savedwn, { len( jui_wa ), savescreen( jui_wa[ lNum, 1 ], jui_wa[ lNum, 2 ], jui_wa[ lNum, 3 ], jui_wa[ lNum, 4 ] ) } )
return cWindow

function wnd_hide

local cColor := setcolor()
//restscreen(jui_wa[lNum,1],jui_wa[lNum,2],jui_wa[lNum,3],jui_wa[lNum,4],jui_wa[lNum,5])
unbox( jui_wa[ len( jui_wa ), 6 ] )
setcolor( cColor )
return .t.

function wnd_restore( delwin )

local lNum := savedwn[ len( savedwn ), 1 ]
restscreen( jui_wa[ lNum, 1 ], jui_wa[ lNum, 2 ], jui_wa[ lNum, 3 ], jui_wa[ lNum, 4 ], savedwn[ len( savedwn ), 2 ] )
if delwin = NIL .or. delwin
   asize( savedwn, len( savedwn ) - 1 )
endif
return cWindow

function rowstart( no_of_rows )

return int( ( maxrow() / 2 ) - ( int( no_of_rows / 2 ) ) )

function colstart( no_of_cols )

return int( ( maxcol() / 2 ) - ( int( no_of_cols / 2 ) ) )

function wnd_msg( msg, how )

local nCh
if empty( msg )
   return .F.
endif
wnd_save()
wnd_hide()
wnd_create( rowstart( 3 ), colstart( len( msg ) + 4 ), rowstart( 3 ) + 3, colstart( len( msg ) + 4 ) + len( msg ) + 4, "MESSAGE" )
@ wnd_row(  0 ), wnd_center( 0, msg ) say msg         
if how = 1          // ERROR
   tone( 300, 2 )
   tone( 280, 1 )
   tone( 304, 2 )
elseif how = 2      // EXCLAIM
   tone( 350, 2 )
   tone( 213, 2 )
   tone( 421, 1 )
elseif how = 3      // SUCCESS
   tone( 212, 2 )
   tone( 360, 1 )
endif
@ wnd_row(  1 ), wnd_center( 0, "Ok" ) prompt "Ok"
menu to nCH
wnd_restore()
wnd_close()
return .t.

function nwnd_say( row, col, string )

@ row, col say string         
return .T.

function defcolor

return "N/BG"

function boxcolor

return 'W+/BG'

function clsallwin

while wnd_close()
enddo
return .t.

*+ EOF: W_M.PRG
