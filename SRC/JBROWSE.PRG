//-----------------------------------------------------------------
//  JBrowse - Generic Database Browse Function.
//-----------------------------------------------------------------
#include "bgevents.ch"
#include "fileio.ch"
#include "inkey.ch"

#define LINESPERPAGE 48

#define SP_HEADING 1
#define SP_COLUMNS 2
#define SP_FOOTING 3

#define SP_EDIT    4
#define SP_PRINT   5

#define SP_TOP     6
#define SP_LEFT    7
#define SP_BOTT    8
#define SP_RIGHT   9

#define SP_WIDTHS  10
#define SP_TOTALS  11
#define SP_FREEZE  12

#define SP_BLOCK1  13
#define SP_BLOCK2  18
#define SP_WHILE   14
#define SP_SEARCH  15

#define SP_ORDCHANGE 16

#define SP_BPRINT  17
#define SP_TOTAL   19

#define SP_ROWHIGHLIGHT  20

#define SP_DOUBLESPACE 21

static aStuff := {}

//----------------------------------
function spBInit( cHead, aColumns, cFoot )

local aBrow := array( 21 )

aBrow[ SP_HEADING ] := cHead
aBrow[ SP_COLUMNS ] := aColumns
aBrow[ SP_FOOTING ] := cFoot

return aBrow
//------------------------------------
function spBDisplay( aBrow, nTop, nLeft, nBott, nRight, lRowLite )

aBrow[ SP_TOP ]          := nTop
aBrow[ SP_LEFT ]         := nLeft
aBrow[ SP_BOTT ]         := nBott
aBrow[ SP_RIGHT ]        := nRight
aBrow[ SP_ROWHIGHLIGHT ] := lRowLite
return aBrow
//----------------------------------------
function spBConfigure( aBrow, cEdit, lPrint, lOrdChange, lTotal )

aBrow[ SP_EDIT ]      := cEdit
aBrow[ SP_PRINT ]     := lPrint
aBrow[ SP_ORDCHANGE ] := lOrdChange
aBrow[ SP_TOTAL ]     := lTotal
return aBrow
//----------------------------------------
function spBArray( aBrow, aWidth, aTotals, nFreeze )

aBrow[ SP_WIDTHS ] := aWidth
aBrow[ SP_TOTALS ] := aTotals
aBrow[ SP_FREEZE ] := nFreeze
return aBrow
//----------------------------------------
function spBBlocks( aBrow, bCBlock1, bCBlock2, bWhile, bSearch )

aBrow[ SP_BLOCK1 ] := bCBlock1
aBrow[ SP_BLOCK2 ] := bCBlock2
aBrow[ SP_WHILE ]  := bWhile
aBrow[ SP_SEARCH ] := bSearch
return aBrow
//----------------------------------------
function spBPrint( aBrow, bPrint, lDoubleSpace )

aBrow[ SP_BPRINT ]      := bPrint
aBrow[ SP_DOUBLESPACE ] := lDoubleSpace
return aBrow
//-------------------------------------

/*
function spBrowse(cHead,aColumns,cFoot,cEdit,lPrint,nTop,nLeft,;
                       nBott,nRight,aWidth,aTotals,nFreeze,bCustomBlock,bWhile,;
                       bSearch)
*/

function spBrowse( aBrowse, cDispFoot )

local oBrowse
local aHelp
local nKey    := 0
local nWidth

local cOldScreen := savescreen()

local aTots
local i        := 1
local nOldCurs := setcursor( 0 )

local cHead
local aColumns
local cFoot
local cEdit
local lPrint
local nTop
local nLeft
local nBott
local nRight
local aWidth
local aTotals
local nFreeze
local bCBlock1
local bCBlock2
local bWhile
local bSearch
local lOrdChange
local bPrint
local lTotal
local lRowLite
local lDoubleSpace

cHead      := aBrowse[ SP_HEADING ]
aColumns   := aBrowse[ SP_COLUMNS ]
cFoot      := aBrowse[ SP_FOOTING ]
cEdit      := aBrowse[ SP_EDIT ]
lPrint     := aBrowse[ SP_PRINT ]
lOrdChange := aBrowse[ SP_ORDCHANGE ]

nTop   := aBrowse[ SP_TOP ]
nLeft  := aBrowse[ SP_LEFT ]
nBott  := aBrowse[ SP_BOTT ]
nRight := aBrowse[ SP_RIGHT ]

aWidth  := aBrowse[ SP_WIDTHS ]
aTotals := aBrowse[ SP_TOTALS ]
nFreeze := aBrowse[ SP_FREEZE ]

bCBlock1 := aBrowse[ SP_BLOCK1 ]
bCBlock2 := aBrowse[ SP_BLOCK2 ]
bWhile   := aBrowse[ SP_WHILE ]
bSearch  := aBrowse[ SP_SEARCH ]

bPrint := aBrowse[ SP_BPRINT ]
lTotal := aBrowse[ SP_TOTAL ]

lRowLite     := aBrowse[ SP_ROWHIGHLIGHT ]
lDoubleSpace := aBrowse[ SP_DOUBLESPACE ]

if lDoubleSpace == NIL
   lDoubleSpace := "N"
elseif valtype( lDoubleSpace ) == 'L'
   if lDoubleSpace
      lDoubleSpace := 'Y'
   else
      lDoubleSpace := 'N'
   endif
endif

if lRowLite = NIL
   lRowLite := .t.
endif

if nTop = NIL
   nTop   := 2
   nLeft  := 1
   nBott  := 21
   nRight := 78
endif

if lPrint = NIL
   lPrint := .f.
endif

if valtype( cEdit ) != 'C'
   cEdit := 'NO'
endif

if lOrdChange = NIL
   lOrdChange := .t.
endif

if aTotals = NIL
   aTotals := {}
endif

if cHead = NIL
   cHead := ''
endif

if lTotal = NIL
   lTotal := .t.
endif

setcolor( BoxColor() )

nWidth := ( nRight - nLeft ) - 2

@ nTop, nLeft clear to nBott, nRight
@ nTop, nLeft to nBott, nRight
@ nTop, nRight - 13 say 'þ F1 - Help'         

if !empty( cHead )
   @ nTop + 1, nLeft + 1 say padc( cHead, nWidth + 1 )         
   @ nTop + 2, nLeft + 1 say repli( 'Í', nWidth + 1 )          
endif

if cDispFoot != NIL
   setcolor( ScrColor() )
   @ nBott + 1, nLeft say padr( cDispFoot, nWidth + 3 )         
   setcolor( BoxColor() )
endif

if cFoot != NIL     // There is a footing..
   setcolor( ScrColor() )
   @ nBott + 1, nLeft say padr( cFoot, nWidth + 3 )         
   setcolor( BoxColor() )
endif

if bWhile = NIL
   if !empty( cHead )
      oBrowse := tBrowseDB( nTop + 3, nLeft + 1, nBott - 1, nRight - 1 )
   else
      oBrowse := tBrowseDB( nTop + 1, nLeft + 1, nBott - 1, nRight - 1 )
   endif
else
   oBrowse               := tBrowseNew( nTop + 3, nLeft + 1, nBott - 1, nRight - 1 )
   oBrowse:gotopblock    := { || obGoTop( bWhile ) }
   oBrowse:gobottomblock := { || obGoBott( bWhile ) }
   oBrowse:skipblock     := { | nRecs | obSkip( nRecs, bWhile ) }
endif

oBrowse:headsep := "Ä"
oBrowse:colsep  := " ³ "

if len( aTotals ) > 0
   oBrowse:footsep := "Í"
endif

if lTotal
   aTots := findtot( aColumns )
else
   aTots := afill( array( len( aColumns ) ), 0.00 )
endif

aeval( aWidth, { || aWidth[ i ] := iif( len( aColumns[ i ] :heading ) > aWidth[ i ], len( aColumns[ i ] :heading ), ;
                 aWidth[ i ] ), aWidth[ i ] := iif( len( alltrim( str( aTots[ i ] ) ) ) > aWidth[ i ], ;
                 len( alltrim( str( aTots[ i ] ) ) ), aWidth[ i ] ), i ++ } )
i := 1

aeval( aColumns, { | oColumn | oBrowse:AddColumn( oColumn ) } )

if nFreeze != NIL
   oBrowse:freeze := nFreeze
endif

if lRowLite
   oBrowse:autolite := .f.
endif

do while iif( ;
                 cEdit == 'ENTER' .or. cEdit = 'F5', ;
                 nKey != K_ESC, ;
                 nKey != K_ENTER .and. nKey != K_ESC )

   skip 0
   oBrowse:refreshcurrent()             // To refresh records if any...

   oBrowse:forcestable()                // same as : do while ! oBrowse:stabilize();enddo

   if lRowLite
      oBrowse:colorRect( {oBrowse:rowPos, oBrowse:leftvisible, oBrowse:rowPos, oBrowse:rightvisible }, { 5, 6 })
      oBrowse:colorRect( { oBrowse:rowPos, 1, oBrowse:rowPos, oBrowse:rightvisible }, { 5, 6 } )
      oBrowse:hiLite()                  // highlight current cell
   endif

   // if oBrowse:hitbottom .or. oBrowse:hittop ; endif
   // NPN told no SOUND please..!

   setcursor( 0 )

   if len( aStuff ) > 0
      nKey := aStuff[ 1 ]
      adel( aStuff, 1 )
      asize( aStuff, len( aStuff ) - 1 )
   else
      nKey := inkey( 0 )
   endif

   if valtype( bCBlock1 ) = 'B'
      nKey := eval( bCBlock1, nKey, oBrowse )
   endif

   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_RIGHT
      oBrowse:right()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_PGUP
      oBrowse:pageup()
   case nKey == K_PGDN
      oBrowse:pagedown()
   case nKey == K_CTRL_END
      oBrowse:gobottom()
   case nKey == K_CTRL_HOME
      oBrowse:gotop()
   case nKey == K_END
      oBrowse:panend()
   case nKey == K_HOME
      oBrowse:panhome()
   case nKey == K_ALT_R
      lRowLite         := !lRowLite
      oBrowse:autolite := !lRowLite
   case nKey == K_F1
      aHelp := {}
      aadd( aHelp, '' )
      aadd( aHelp, 'Help' )
      aadd( aHelp, repli( '=', 45 ) )
      if cEdit == 'ENTER'
         aadd( aHelp, ' þ ENTER - Edit ' )
         aadd( aHelp, '' )
      elseif cEdit == 'CTRL'
         aadd( aHelp, ' þ CTRL+F5 - Edit ' )
         aadd( aHelp, '' )
      elseif cEdit == 'F5'
         aadd( aHelp, ' þ F5 - Edit ' )
         aadd( aHelp, '' )
      endif
      if lPrint
         aadd( aHelp, ' þ F9 - Print' )
         aadd( aHelp, '' )
      endif
      if valtype( bSearch ) == 'B'
         aadd( aHelp, ' þ F12 - Search' )
         aadd( aHelp, '' )
      endif
      if lOrdChange
         aadd( aHelp, ' þ CTRL_F12 - Change Controlling Index' )
         aadd( aHelp, '' )
      endif
      if lRowLite
         aadd( aHelp, ' þ ALT_R - Turn Row Highlight OFF' )
         aadd( aHelp, '' )
      else
         aadd( aHelp, ' þ ALT_R - Turn Row Highlight ON' )
         aadd( aHelp, '' )
      endif
      aadd( aHelp, 'Use UP, DOWN, PAGE UP, PAGEDOWN, END, HOME,' )
      aadd( aHelp, 'CTRL+END and CTRL+HOME keys for Navigation' )
      aadd( aHelp, '' )
      aadd( aHelp, repli( '=', 45 ) )
      SayMsg( aHelp, 03 )
   case nKey == K_F9
      if ( lPrint .and. ( len( aWidth ) >= len( aColumns ) ) )
         if bPrint = NIL
            ReportPrint( aColumns, aWidth, cHead, cFoot, aTots, lDoubleSpace )
            SpoolDisplay()
         else
            eval( bPrint, aColumns, aWidth, cHead, cFoot, aTots, lDoubleSpace )
         endif
      else
         tone( 300, 2 )
         if len( aWidth ) = 0
            sayMsg( "No widths array supplied. Cannot take print.." )
         elseif len( aWidth ) <> len( aColumns )
            sayMsg( "Width array size mismatches..!" )
         endif
      endif
   case ( ( nKey == K_ENTER .and. ( cEdit == 'ENTER' ) ) .or. ;
             ( nKey == K_F5 .and. cEdit == 'F5' ) .or. ;
             ( nKey == K_CTRL_F5 .and. cEdit == 'CTRL' ) )

      obEdit( oBrowse )
      oBrowse:refreshall()
   case nKey == K_CTRL_F12
      if lOrdChange
         sPopOrder()
         if fieldpos( 'SRL' ) != 0      // If the .dbf contains an SRL field..
            RecReSrl( K_CTRL_F12 )
         endif
         oBrowse:gotop()
         oBrowse:invalidate()
         oBrowse:refreshall()
      else
         msg( 'Sorry, cannot change index orders for this browse...' )
      endif
   case nKey == K_F12
      if valtype( bSearch ) == 'B'
         eval( bSearch, oBrowse )
      else
         msg( 'Search not available for this browse...' )
      endif
   endcase

   if valtype( bCBlock2 ) = 'B'
      oBrowse:forcestable()
      nKey := eval( bCBlock2, nKey, oBrowse )
   endif

enddo

restscreen( 0, 0, 24, 80, cOldScreen )
setcursor( nOldCurs )

return .t.
//----------------------------------------------------------------------------
function SPStuff( aKeys )               // Stuffs the string into SPBrowse's inkey buffer

// Using KEYBOARD does not work.. instead use SPStuff.
local x
for x := 1 to len( aKeys )
   aadd( aStuff, aKeys[ x ] )
next x
return .t.
//-----------------------

/*
static function obPrint( aColumns, aWidths, cHead, aTotals)

local cDHead := "", oCol, nWidth, aDecimals := {}
local x
for x := 1 to len(aColumns)
  cDHead += padr( oColumns[x]:heading, aWidths[x] )+space(2)

  if valtype( eval( oColumns[x]:block ) ) = 'N' .and.;
     ( at('.', str(eval(oColumns[x]:block)) ) ) != 0

        aadd( aDecimals, i )
  endif

next x

cDHead := subs( cDHead,1, len(cDHead)-2 )
// Understand from the for x:=... it adds an unnecassary space(2)
// after the last heading.

nWidth := len(cDHead)

set device to printer
set printer to ob.txt
set printer on
do while .not. eof()
   @ prow(),0 say padc(PCompany,nWidth)
   @ prow()+1,0 say repl('-',nWidth)
   @ prow()+1,0 say cDHead
   @ prow()+1,0 say repl('-',nWidth)
   do while (.not. eof()) .and. prow() < LINESPERPAGE
      setprc(prow()+1,0)
      for x := 1 to len(aColumns)
        oCol := aColumns[x]
        if valtype(eval(oCol:block)) = 'C'
           @ prow(), pcol() say padr(eval(oCol:block), aWidths[x])
        elseif valtype(eval(oCol:block)) = 'L'
           @ prow(), pcol() say iif( eval(oCol:block), 'Y', 'N' )
        elseif valtype(eval(oCol:block)) = 'N'
           if empty(aScan(aDecimals,x))
             @ prow(), pcol() say str( eval(oCol:block), aWidths[x] )
           else
             @ prow(), pcol() say str( eval(oCol:block), aWidths[x],2 )
           endif
        elseif valtype(eval(oCol:block)) = 'D'
           @ prow(), pcol() say padr(dtoc(eval(oCol:block)), aWidths[x])
        endif
        @ prow(),pcol() say space(2)
      next x
      skip
   enddo
   if eof() .and. !empty(sr)
      @prow()+2,0 SAY REPL("-",nWidth)
      printtot(aTotals,aDecimals,aWidths)
      @prow()+2,0 SAY REPL("-",nWidth)
   endif
   @prow()+2,0 SAY REPL("-",nWidth)
   @prow()+1,0 say dtos(date())+strtran(time(),":")
   if !eof()
     @prow(),40 say "CONTINUED.."
   endif
   @prow(),60 say "Page No. : "+STR(PNO,3)+"/"+str(nopa,3)
PNO++
EJECT
ENDD
if pm="Y" ; @prow(),pcol()+1 say chr(18) ; endi
SET DEVI TO SCRE

enddo

RETURN .T.
*/
//----------------------------------------
static function obGoTop( bWhile )

do while ( eval( bWhile ) .and. ( !bof() ) )
   skip - 1
enddo
if !bof()
   skip
endif
return .t.
//------------------------------
static function obGoBott( bWhile )

do while eval( bWhile ) .and. ( !eof() )
   skip
enddo
skip - 1
return .t.
//---------------------------------
static function obSkip( nRecs, bWhile )

local nSkipped := 0
if nRecs > 0        // Skip front
   do while ( nSkipped < nRecs ) .and. ( !eof() ) .and. ( eval( bWhile ) )
      skip
      if ( !eof() ) .and. ( eval( bWhile ) )
         nSkipped ++
      endif
   enddo
elseif nRecs < 0    // skip back
   do while ( nSkipped > nRecs ) .and. ( !bof() ) .and. ( eval( bWhile ) )
      skip - 1
      if ( !bof() ) .and. ( eval( bWhile ) )
         nSkipped --
      endif
   enddo
endif
if eof() .or. ( !eval( bWhile ) )
   if nRecs > 0
      skip - 1
   elseif nRecs < 0
      skip
   endif
endif
return nSkipped
//-------------------------------------
function REPORTPRINT( co, wid, HEAD, cFoot, sr, lsp )       // By Srini Sir..

//-- Following line by JAS
local nOldRec := recno()
local cScreen := savescreen()
//----

//
// This function is essentially the same REPORTPRINT developed by Srini sir.
// Since it is working reasonably good.., I thought i neednt waste time for
// remaking it...
//                  Jasim

local i
local c
local r
local pno       := 1
local LOL       := 0
local lCompress := .F.
local nopa
local scr
local allpage   := " "
local stpg      := 1
local dr        := {}
local getlist   := {}
for i := 1 to len( co )
   iif( valtype( eval( co[ i ] :block ) ) = "N" .and. ;
        ! empty( at( ".", str( eval( co[ i ] :block ) ) ) ), aadd( dr, i ), " " )
next
lCompress := jAlert( "Print in Compressed Mode ?", { 'No', 'Yes' } ) == 2
nopa      := iif( empty( reccount() % 48 ), reccount() / 48, int( reccount() / 48 ) + 1 )

nopa := iif( pcount() = 6 .and. lsp = "Y", nopa * 2, nopa )
if nopa > 1

   stpg := 1
   popread( .f., 'Print from page no.:', @stpg, '9999' )
   if stpg < 1
      stpg := 1
   endif
   if stpg != 1
      allpage := 'N'
   else
      allpage := 'Y'
   endif
endi
go top
if allpage = "N"
   skip( stpg - 1 ) * 48
   pno := stpg
endi

// This line by JAS
BACKGROUND EVENTS STOP
//--------

princhek()
set devi to print
if lCompress
   @ prow(), 0 say chr( 15 )         
endi

aeval( WID, { | T | LOL := LOL + T + 1 } )
LOL --

do while !eof()

   set device to screen
   set printer off

   FT_DispMsg( { HEAD, '', 'Printing...', '', 'þ Page : ' + alltrim( str( pno ) ) + "/" + alltrim( str( nopa ) ) + " þ " } )

   set device to printer
   set printer on

   @ prow(), 0     say PADC( PCompany, LOL )         
   @ prow() + 1, 0 say PADC( HEAD, LOL )             
   @ prow() + 1, 0 say repl( "-", LOL )              
   i := 1
   c := 0
   r := prow() + 1
   aeval( co, { | t | devpos( r, c ), devout( t:heading ), c := ( c + wid[ i ] + 1 ), i ++ } )
   @ prow() + 1, 0 say repl( "-", LOL )         
   do while !eof() .and. prow() < 53
      r := iif( pcount() = 6 .and. lsp = "Y", prow() + 2, prow() + 1 )
      c := 0
      for i := 1 to len( co )
         if valtype( eval( co[ i ] :block ) ) = "N"
            @ r, c say iif( empty( ascan( dr, i ) ), str( eval( co[ i ] :block ), wid[ i ] ), ;         
                    str( eval( co[ i ] :block ), wid[ i ], 2 ) )
         else
            @ r, c say padr( eval( co[ i ] :block ), wid[ i ] )         
         endi
         // aeval(co, {|t| devpos(r,c),devout(eval(t:block)),c:=(c+wid[i]+1),i++})
         c := ( c + wid[ i ] + 1 )
      next
      skip
   endd
   if eof() .and. !empty( sr )
      c := 0
      @ prow() + 2, 0 say repl( "-", LOL )         
      printtot( sr, dr, wid )
      @ prow() + 1, 0 say repl( "-", LOL )         
   endi
   if cFoot != NIL
      if ( !empty( alltrim( cFoot ) ) )
         @ prow() + 1, 0 say repl( "-", LOL )         
         @ prow() + 1, 0 say cFoot                    
         @ prow() + 1, 0 say repl( "-", LOL )         
      endif
   endif
   @ prow() + 1, 0 say repl( "-", LOL )                                
   @ prow() + 1, 0 say dtos( date() ) + strtran( time(), ":" )         
   if !eof()
      @ prow(), 40 say "CONTINUED.."         
   endi
   @ prow(), 60 say "Page No. : " + str( PNO, 3 ) + "/" + str( nopa, 3 )         
   PNO ++
   eject

   set device to screen
   set printer off

   set device to printer
   set printer on

endd
if lCompress
   @ prow(), pcol() + 1 say chr( 18 )         
endi
set console on
set devi to scre
set printer to
set printer off

BACKGROUND EVENTS START

//-- Jas
go nOldRec
//---

restscreen( 0, 0, 24, 79, cScreen )
return NIL
// ----------------------------------------------------------------------
function printtot( sr, dr, wid )        // By Srini Sir. Part of his REPORTPRINT

local r
local c := 0
local l
r := prow() + 1
for i := 1 to len( sr )
   if valtype( sr[ i ] ) = "N" .and. !empty( sr[ i ] )
      @ r, c say iif( empty( ascan( dr, i ) ), str( sr[ i ], wid[ i ] ), str( sr[ i ], wid[ i ], 2 ) )         
   endi
   c := ( c + wid[ i ] + 1 )
next
return nil
// ----------------------------------------------------------------------
func findtot( co )  // Part of Srini Sir's REPORTPRINT

local i    := 0
local sr   := afill( array( len( co ) ), 0.00 )
local nRec := recno()
for i := 1 to len( co )
   go top
   if valtype( eval( co[ i ] :block ) ) = "N"
      dbeval( { || sr[ i ] += eval( co[ i ] :block ) } )
   endi
next
go ( nRec )
return sr
//-----------------
func drawtot( br, sr )                  // Part of Srini Sir's REPORTPRINT

local c := col()
@ 23,  0 clea to 23, 79
if valtype( eval( br:getcolumn( br:colpos ) :block ) ) = "N"
   @ 23, c say str( sr[ br:colpos ], br:getcolumn( br:colpos ) :width, 2 )         
endi
return nil
// ----------------------------------------------------------------------
static function OBEdit( oBrowse )

local oColumn   := oBrowse:getColumn( oBrowse:colPos )
local xOldvalue := eval( oColumn:block )
local lInsState := set( _SET_INSERT )
//ÄÄÄÄ set insert key to toggle both insert mode & cursor
local lOldins := setkey( K_INS, { || setcursor( ;
        if( readinsert( !readinsert() ), 1, 3 ) ) } )

//ÄÄÄÄ initial cursor setting based on current mode
local nOldcursor := setcursor( 1 )

jRLock()
//ÄÄÄÄ create corresponding GET with GETNEW() and read it now
readmodal( { getnew( row(), col(), oColumn:block, oColumn:heading, ;
             oColumn:picture, oBrowse:colorSpec ) } )
jRUnLock()
setcursor( nOldcursor )                 // turn cursor back off
setkey( K_INS, lOldins )                // reset INS key
set( _SET_INSERT, lInsState )
return ( eval( oColumn:block ) <> xOldvalue )
//---------------------------------------------------------------------
function SpoolDisplay()

if !empty( POldSpool )
   if jAlert( 'View Spool File : ' + POldSpool + ' ? ', { 'Yes', 'No' } ) = 1
      fileread( 2, 2, 22, 77, POldSpool )
   endif
endif
return .t.

*+ EOF: JBROWSE.PRG
