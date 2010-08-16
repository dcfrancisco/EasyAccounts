#include "std.ch"
#include "box.ch"
#include 'inkey.ch'
#include 'setcurs.ch'
//=========================================================
local nSel
local cFile       := 'PRICES.TXT  '
public lHandleHot
public lIsMouse
public mouserow   := 0
public mousecol   := 0                  // SUPER VARIABLES
public nLastEvent := 0
do while .t.
   priceview( .f., .t. )
   getindex()
   close all
   setcolor( scrcolor() )
   @ 08, 26 say padc( 'What to Do ?', 26 )         
   nSel := aPick( 9, 26, 13, 51, { 'Print to Printer', 'Print to File', 'Edit Once More', 'Exit Without Printing' } )
   dispscrn()
   if nSel = 1
      if prncheck()
         prntprn()
         exit
      else
         loop
      endif
   elseif nSel = 2
      popread( .f., 'File Name : ', @cFile, '@!' )
      if !empty( rtrim( ltrim( cFile ) ) )
         prntfile( cFile )
      else
         msg( 'Print Aborted!' )
      endif
      exit
   elseif nSel = 3
      loop
   else
      exit
   endif
enddo
return .t.
//========================================
function getindex()

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
local nOrder    := 0
local nTotal    := 0
setcolor( scrcolor() )
@  2,  1 say padc( 'Set Print Order', 78 )                                                     
@ 22,  1 say padc( 'þ S - Search         þ ENTER - Edit Order      þ ESC - Exit', 78 )         
setcolor( boxcolor() )
@  3,  1 clear to 21, 78
@  3,  1, 21, 78 box B_DOUBLE_SINGLE
sele prices
go top
pack
copy all for print to QMADE
close all
use QMADE
//replace all index with 0
index on str( index, 3, 0 ) + desc to QMADE
go top
oBrowse         := TBrowseDB( 4, 2, 20, 77 )
oBrowse:headSep := 'ÍÍÍ'
//oBrowse:headSep := 'ÍÑÍ'
//oBrowse:colSep := ' ³ '
oBrowse:colSep := '   '

oColumn         := TBColumnNew( 'Srl', { || str( index, 3, 0 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Item Description', { || padr( subs( rtrim( ltrim( proper( desc ) ) ) + ' ' + rtrim( ltrim( proper( details ) ) ), 1, 50 ), 50 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'ÿPriceÿ', { || str( PRICE, 7, 0 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

nKey := 0

do while .t.
   if nKey == K_ESC
      exit
   endif
   oBrowse:colpos := 1
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      nKey := inkey( 0 )
   endif

   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case isdigit( chr( nKey ) )
      keyboard chr( K_ENTER ) + chr( nKey )
   case nKey == K_ENTER
      nOrder ++
      popread( .f., 'Serial Number : ', @nOrder, '99' )
      field->index := nOrder
      oBrowse:forcestable()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || qmade->desc + ", " + subs( qmade->details, 1, 20 ) }
      jsfilt( oBrowse, 0, { || .t. } )
   case nKey == K_F8
      vs_calc()
   endcase
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
close all
use prices
delete all for print
pack
append from qmade
return nil
//---------------------------

function priceview( lView, lOpen )

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
local cItem
local cDetails
local nPrice
local nTotal    := 0
local jxx
setcolor( scrcolor() )
if lView = NIL
   lView := .f.
endif
if lOpen = NIL
   lOpen := .t.
endif
@  4,  1 say padc( 'Make Quotation', 78 )         
if ( !lView .and. lOpen )
   @ 18,  1 say padc( 'þ A - Add    þ E - Edit   þ D - Delete   þ S - Search     þ ESC - Abort', 78 )         
elseif ( !lView .and. !lOpen )
   @ 18,  1 say padc( 'þ A - Add   þ E - Edit  þ D - Delete  þ S - Search   þ ENTER - Select', 78 )         
else
   @ 18,  1 say padc( 'þ ENTER - Select Item         þ S - Search', 78 )         
   setcolor( boxcolor() )
   @  1,  0 to 23, 79
endif
setcolor( boxcolor() )
@  5,  1 clear to 17, 78
@  5,  1, 17, 78 box B_DOUBLE_SINGLE
if lOpen
   use prices new
   pack
   //replace all print with .f.
   go top
   sum all price to nTotal for ( print .and. ( !deleted() ) )
   go top
   index on desc to prices
   set filter to .not. deleted()
   go top
else
   sele prices
   //replace all print with .f.
   go top
   sum all price to nTotal for ( print .and. ( !deleted() ) )
   set filter to .not. deleted()
endif
oBrowse         := TBrowseDB( 6, 2, 16, 77 )
oBrowse:headSep := 'ÍÍÍ'
//oBrowse:headSep := 'ÍÑÍ'
//oBrowse:colSep := ' ³ '
oBrowse:colSep := '   '

oColumn         := TBColumnNew( '   ', { || checktoprn() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Item Description', { || padr( subs( rtrim( ltrim( proper( desc ) ) ) + ' ' + rtrim( ltrim( proper( details ) ) ), 1, 50 ), 50 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'ÿPriceÿ', { || str( PRICE, 7, 0 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

nKey := 0

setcolor( msgcolor() )
scrcenter( 20, 'Total Value of Tagged Items : ' + str( nTotal, 8, 0 ), 78 )
setcolor( boxcolor() )

do while .t.
   if nKey == K_ESC
      exit
   endif
   oBrowse:colpos := 2
   dispbegin()
   do while ( nKey := inkey() ) == 0 .and. !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      nKey := inkey( 0 )
   endif

   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
      /*
      case nKey == K_LEFT
           oBrowse:left()
      case nKey == K_RIGHT
           oBrowse:right()
           */
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case upper( chr( nKey ) ) == 'A' .and. ( !lView )
      cItem    := space( len( desc ) )
      cDetails := space( len( details ) )
      nPrice   := 0.00
      popread( .f., 'Item Name : ', @cItem, '@!', ;
               'Details   : ', @cDetails, '@!', ;
               'Price     : ', @nPrice, '999999' )
      if !empty( rtrim( ltrim( cItem ) ) )
         //cItem := m_stdform(cItem)
         append blank
         field->desc    := cItem
         field->details := cDetails
         field->price   := nPrice
         oBrowse:refreshall()
      endif
   case upper( chr( nKey ) ) == 'E' .and. ( !lView )
      jxx := print
      jxy := price
      if jxx
         nTotal -= price
      endif
      cItem    := desc
      cDetails := details
      nPrice   := price
      popread( .f., 'Item Name : ', @cItem, '@!', ;
               'Details   : ', @cDetails, '@!', ;
               'Price     : ', @nPrice, '999999' )
      if !empty( rtrim( ltrim( cItem ) ) )
         //cItem := m_stdform(cItem)
         field->desc    := cItem
         field->details := cDetails
         field->price   := nPrice
         oBrowse:refreshall()
         if jxx
            nTotal += nPrice
         endif
      else
         nTotal += jxy
      endif
      setcolor( msgcolor() )
      scrcenter( 20, 'Total Value of Tagged Items : ' + str( nTotal, 8, 0 ), 78 )
      setcolor( boxcolor() )
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || prices->desc + ", " + subs( prices->details, 1, 20 ) }
      jsfilt( oBrowse, 0, { || .t. } )
   case upper( chr( nKey ) ) == 'D'
      delete
      oBrowse:refreshall()
   case nKey == K_ENTER
      if print      // 'cauz if it was earlier print then the amount was added.
         nTotal -= price                // now it should be reduced.
      else
         nTotal += price
      endif
      field->print := !print            // the opp.one
      setcolor( msgcolor() )
      scrcenter( 20, 'Total Value of Tagged Items : ' + str( nTotal, 8, 0 ), 78 )
      setcolor( boxcolor() )
      oBrowse:refreshcurrent()
      keyboard chr( K_DOWN )
   case nKey == K_F8
      vs_calc()
   endcase
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
return nil
//---------------------------
static function m_stdform( cWhat )      // INTELLIGENT Function...

local aRepl := { ;
                 { "MOTHERBOARD", "M/B" }, { "MAINBOARD", "M/B" }, ;
                 { "HARDDISK", "HDD" }, { "HARD DISK", "HDD" }, ;
                 { "HARDDISK DRIVE", "HDD" }, { "HARD DISK DRIVE", "HDD" }, ;
                 { "CDDRIVE", "CDD" }, { "CDR DRIVE", "CDD" }, ;
                 { "CD DRIVE", "CDD" }, { "CDROM DRIVE", "CDD" }, ;
                 { "CD-DRIVE", "CDD" }, { "CD-ROM DRIVE", "CDD" }, ;
                 { "FLOPPY DISK DRIVE", "FDD" }, { "FDD DRIVE", "FDD" }, ;
                 { "FLOPPY DRIVE", "FDD" }, { "FLOPPYDISK DRIVE", "FDD" }, ;
                 { "AGP CARD", "AGP" }, { "SOUNDCARD", "SOUND CARD" }, ;
                 { "DVD DRIVE", "DVD" }, { "DVDROM DRIVE", "DVD" }, ;
                 { "DVD-DRIVE", "DVD" }, { "DVD-ROM DRIVE", "DVD" }, ;
                 { "K/B", "KEYBOARD" }, { "KEY BOARD", "KEYBOARD" }, ;
                 { "INTERNAL MODEM", "I/MODEM" }, { "MODEM INTERNAL", "I/MODEM" }, ;
                 { "EXTERNAL MODEM", "E/MODEM" }, { "MODEM EXTERNAL", "E/MODEM" } ;
                 }
local xx
local yy
yy    := len( cWhat )
cWhat := rtrim( ltrim( cWhat ) )
if cWhat != NIL .and. len( cWhat ) > 0
   xx := ascan( aRepl, { | axxy | axxy[ 1 ] = subs( cWhat, 1, len( axxy[ 1 ] ) ) } )
   if xx != 0
      cWhat := strtran( cWhat, aRepl[ xx, 1 ], aRepl[ xx, 2 ] )
      // Make to the STD form.
   endif
endif
cWhat += space( yy - len( cWhat ) )
return cWhat
//---------------------------------------------------
static function checktoprn

local x
if print
   x := '[X]'
else
   x := '[ ]'
endif
return x
//---------------------------------
function prntprn

local line := 0
local nTot := 0.00
local nSrl := 1
close all
use qmade index qmade
go top
set device to printer
set printer on
@ line,  0 say padc( 'Wintech Systems & Services', 65 )         
@ line,  0 say padc( 'Wintech Systems & Services', 65 )         
@ line,  0 say padc( 'Wintech Systems & Services', 65 )         
line ++
@ line,  0 say padc( 'Pulliman Jun., Karunagappally', 65 )         
line ++
line ++
@ line,  0 say padc( 'Q U O T A T I O N', 65 )         
@ line,  0 say padc( 'Q U O T A T I O N', 65 )         
line ++
@ line,  0 say padc( 'Prices as on ' + cdow( date() ) + ' ' + subs( dtoc( date() ), 4, ;         
        2 ) + ' ' + cmonth( date() ) + ' ' + str( year( date() ), 4, 0 ), 65 )
line ++
@ line,  0 say repli( '-', 65 )         
line ++
@ line,  0 say "Srl"                 
@ line,  5 say 'Particulars'         
@ line, 58 say 'Price'               
line ++
@ line,  0 say repli( '-', 65 )         
line ++
do while .not. eof()
   @ line,  0 say str( nSrl, 3, 0 )                                                                                                                                    
   @ line,  5 say subs( proper( rtrim( ltrim( desc ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ', ' + rtrim( ltrim( proper( details ) ) ), "" ), 1, 48 )         
   @ line, 56 say str( price, 9, 2 )                                                                                                                                   
   nTot += price
   line ++
   nSrl ++
   skip
enddo
@ line, 57 say repli( '-', 8 )         
line ++
@ line, 35 say 'Total Amount :- '         
@ line, 55 say str( nTot, 10, 2 )         
line ++
@ line,  0 say repli( '=', 65 )         
line ++
line ++
line ++
line ++
@ line,  0 say chr( 10 ) + chr( 10 )         
line ++
line ++
@ line,  0 say " "         
set device to screen
set printer off
set printer to
close all
return .t.
//==============================
function prntfile( cFile )

local line := 0
local nTot := 0.00
local nSrl := 1
close all
use qmade index qmade
go top
set device to printer
set printer to ( cFile )
set printer on
@ line,  0 say padc( 'Wintech Systems & Services', 65 )         
line ++
@ line,  0 say padc( 'Pulliman Jun., Karunagappally', 65 )         
line ++
line ++
@ line,  0 say padc( 'Q U O T A T I O N', 65 )         
line ++
@ line,  0 say padc( 'Prices as on ' + cdow( date() ) + ' ' + subs( dtoc( date() ), 4, ;         
        2 ) + ' ' + cmonth( date() ) + ' ' + str( year( date() ), 4, 0 ), 65 )
line ++
@ line,  0 say repli( '-', 65 )         
line ++
@ line,  0 say 'Srl'                 
@ line,  5 say 'Particulars'         
@ line, 58 say 'Price'               
line ++
@ line,  0 say repli( '-', 65 )         
line ++
do while .not. eof()
   @ line,  0 say str( nSrl, 3, 0 )                                                                                                                                    
   @ line,  5 say subs( proper( rtrim( ltrim( desc ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ', ' + rtrim( ltrim( proper( details ) ) ), "" ), 1, 48 )         
   @ line, 56 say str( price, 9, 2 )                                                                                                                                   
   nTot += price
   nSrl ++
   line ++
   skip
enddo
@ line, 57 say repli( '-', 8 )         
line ++
@ line, 35 say 'Total Amount :- '         
@ line, 55 say str( nTot, 10, 2 )         
line ++
@ line,  0 say repli( '=', 65 )         
line ++
line ++
line ++
line ++
line ++
line ++
@ line,  0 say " "         
set device to screen
set printer off
set printer to
close all
fileread( 03, 05, 21, 73, cFile, 'Quotation Preview' )
return .t.

// eof: MASTER.PRG

*+ EOF: PRICES.PRG
