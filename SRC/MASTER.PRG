/*
#
#     Master Items maintainance module
#                for EasyAccounts v1.5
#
#     Developed and Tested by Jasim A B
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
*/

#include "std.ch"
#include "ghost.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

function whichitem( lView, lOpen, lAllowEsc )

local oBrowse
local oColumn
local nKey, nItemId
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
local lBOpened
setcolor( scrcolor() )
if lView = NIL
   lView := .f.
endif
if lOpen = NIL
   lOpen := .t.
endif
if lAllowEsc = NIL
   lAllowEsc := .f.
endif
@  2,  1 say padc( 'Items List', 78 )         
if ( !lView .and. lOpen )
   @ 22,  1 say padc( 'Ч A - Add   Ч E - Edit  Ч F - Filter  Ч S - Search  Ч L - Report  Ч ESC - Abort', 78 )
elseif ( !lView .and. !lOpen )
   @ 22,  1 say padc( 'Ч A - Add   Ч E - Edit   Ч S - Search  Ч L - Report Ч F - Filter  Ч ENTER - Select', 78 )         
else
   @ 22,  1 say padc( 'Ч ENTER - Select Item     Ч F - Filter    Ч S - Search    Ч L - Report', 78 )         
   setcolor( boxcolor() )
   @  1,  0 to 23, 79
endif
setcolor( boxcolor() )
@  3,  1 clear to 21, 78
@  3,  1, 21, 78 box B_DOUBLE_SINGLE
if lOpen
   use batches new index BAT_1,BAT_2
   use master new index mas_1,mas_2
   lBOpened := .t.
else
   sele master
   if select( "BATCHES" ) = 0           // Batches not opened.
      lbOpened := .t.
      use batches new index BAT_1,BAT_2
   else
      lbOpened := .f.
   endif
endif
if eof() .or. bof()
   go top
endif
oBrowse         := TBrowseDB( 4, 2, 20, 77 )
oBrowse:headSep := 'мям'
oBrowse:colSep  := ' Ё '
oColumn         := TBColumnNew( 'Name of Item', fieldblock( 'DESC' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Details', { || subs( DETAILS, 1, 20 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Stock', { || BAL } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Retail', fieldblock( 'RETAIL' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'W/Sale', fieldblock( 'WPRICE' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

nKey := 0

do while .t.
   if !lOpen
      if nKey == K_ENTER
         exit
      endif
   elseif (lOpen .or. lAllowEsc)
      if nKey == K_ESC
         exit
      endif
   endif
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
   case nKey == K_ALT_R
      plswait(.t.,'Generating HTML...')
      tb2Html(oBrowse,'EARep.HTM','Master List')
      plswait(.f.)
      msg('EARep.HTM created!')
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_RIGHT
      oBrowse:right()
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
      m_additem()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E' .and. ( !lView )
      m_edititem()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || master->desc + ", " + subs( master->details, 1, 20 ) }
      jsfilt( oBrowse, 0, {|| .t.} )
   case upper( chr( nKey ) ) == 'L'
      nItemId := master->id
      jSaveEnv()
      close all
      Item_Rep( nItemId )
      close all
      jRestEnv()
   case upper( chr( nKey ) ) == 'F'
     if ! empty(dbfilter())
       cmFilter ( dbfilter() + " .and. bal > 0")
     else
       set filte to bal > 0
     endif
     go top
     oBrowse:refreshall()
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
   case setkey( nKey ) # NIL
      eval( setkey( nKey ), 'WHICHITEM', 0, '' )
   endcase

   if nKey == K_ENTER
      if eof()
         jAlert( "CANNOT ACCEPT BLANK ITEM;;" + ;
                 "Please Re-Enter" )
         nKey := 0
         loop
      endif
   endif

enddo

set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
select master
return ( lastkey() == K_ENTER )
//---------------------------
static function m_additem( lBegin )

local _xx      := savescreen()
local _oldrec
local nId
local cDesc    := space( len( desc ) )
local cDetails := space( len( details ) )
local nBegin   := 0
local nRetail  := 0.00
local nCost    := 0.00
local nWhole   := 0.00
local _yesorno := ' '
local lExit    := .f.
if lBegin = NIL
   lBegin := .t.
endif

sele master
_oldrec := recno()

if ! _DEMO = 'REG'
   if reccount() >= 200
     jAlert('Sorry, this is a DEMO version of '+_EasyAccounts+'. ;'+;
            'Please register it to add more than 200 items.')
     return .f.
   endif
endif

dispscrn()
setcolor( scrcolor() )
@  6,  1 say padc( 'Add Item', 78 )         

setcolor(boxgetcolor())

do while !lExit
   _yesorno := ' '
   @  7,  1 clear to 14, 78
   @  7,  1 to 14, 78

   @  8,  2 say "Name of Item......:"         
   @  9,  2 say "Details...........:"         
   @ 10,  2 say "Op.Stock..........:"         
   @ 11,  2 say "Retail Price......:"         
   @ 12,  2 say "Wholesale Price...:"         
   @ 13,  2 say "Op.Cost (if any)..:"         
   setcolor( boxgetcolor() )
   @  8,  2 say "Name of Item......:" get cDesc    pict '@!S50'                               
   @  9,  2 say "Details...........:" get cDetails pict '@!S50' when ( !empty( cDesc ) )      
   read
   cDesc := m_stdform( cDesc )
   @  8,  2 say "Name of Item......: " + cDesc         
   if empty( cDesc )
      lExit := .t.
      exit
   endif
   @ 10,  2 say "Op.Stock..........:    " get nBegin  pict '99999'           
   @ 11,  2 say "Retail Price......:"     get nRetail pict '999999.99'       
   @ 12,  2 say "Wholesale Price...:"     get nWhole  pict '999999.99'       
   @ 13,  2 say "Op.Cost (if any)..:"     get nCost   pict '999999.99'       
   read
   if confirm( "Save Item Details", 15 )
      sele master
      set order to 1
      set filter to
      go bottom
      nId := id + 1
      append blank
      field->id      := nId
      field->desc    := cDesc
      field->details := cDetails
      field->begin   := nBegin
      field->bal     := nBegin
      field->cost    := nCost
      field->opcost  := nCost
      field->wprice  := nWhole
      field->retail  := nRetail
      jRUnLock()
      sele batches
      append blank
      field->id    := nId
      field->begin := nBegin
      field->cost  := nCost
      sele master
      if confirm( "Continue with Data Entry", 15 )
         cDesc    := space( len( desc ) )
         cDetails := space( len( details ) )
         nBegin   := 0
         nRetail  := 0.00
         nCost    := 0.00
         nWhole   := 0.00
         _yesorno := ' '
         lExit    := .f.
      else
         lExit := .t.
      endif
   else
      sele master
      go _oldrec
   endif
enddo
select master
restscreen( 0, 0, 24, 79, _xx )
return nil
//---------------------------------------
static function m_edititem()

local _xx      := savescreen()
local _oldrec
local nResp
local nId
local cDesc    := desc
local cDetails := details
local nBegin   := begin
local nRetail  := retail
local nCost    := opcost
local nWhole   := wprice
local _yesorno := ' '
local lExit    := .f.

sele master
_oldrec := recno()

dispscrn()
setcolor( scrcolor() )
@  6,  1 say padc( 'Edit Item', 78 )         

setcolor( boxgetcolor() )

do while !lExit
   _yesorno := ' '
   @  7,  1 clear to 14, 78
   @  7,  1 to 14, 78

   @  8,  2 say "Name of Item......:"         
   @  9,  2 say "Details...........:"         
   if !stockentry()
      setcolor( noncolor() )
      @ 10,  2 say "Op.Stock..........:    " + str( nBegin, 5, 0 )         
      setcolor( boxgetcolor() )
   else
      @ 10,  2 say "Op.Stock..........:    " + str( nBegin, 5, 0 )         
   endif
   @ 11,  2 say "Retail Price......:" + str( nRetail, 9, 2 )         
   @ 12,  2 say "Wholesale Price...:" + str( nWhole, 9, 2 )          
   @ 13,  2 say "Op.Cost (if any)..:" + str( nCost, 9, 2 )           
   setcolor( boxgetcolor() )
   @  8,  2 say "Name of Item......:" get cDesc    pict '@!S50'                               
   @  9,  2 say "Details...........:" get cDetails pict '@!S50' when ( !empty( cDesc ) )      
   read
   cDesc := m_stdform( cDesc )
   @  8,  2 say "Name of Item......: " + cDesc         

   if empty( cDesc )
      lExit := .t.
      exit
   endif
   if stockentry()
      @ 10,  2 say "Op.Stock..........:    " get nBegin pict '99999'       
   endif
   @ 11,  2 say "Retail Price......:" get nRetail pict '999999.99'       
   @ 12,  2 say "Wholesale Price...:" get nWhole  pict '999999.99'       
   @ 13,  2 say "Op.Cost (if any)..:" get nCost   pict '999999.99'       
   read
   if confirm( "Save Item Details", 15 )
      sele master

      if alltrim( cDesc ) == "." .and. ( begin + rcvd + sold + bal > 0 )
         jAlert( "Item already in transaction. Cannot delete" )
      else
         jRLock()
         field->desc := cDesc
         jRUnLock()
      endif

      jRLock()
      field->details := cDetails
      jRUnLock()

      if stockentry()

         mst_BChange( nBegin, nCost )

         select master
         jRLock()
         field->begin := nBegin
         jRUnLock()

      else

         mst_BChange( nBegin, nCost, .f. )

      endif

      sele master
      jRLock()
      field->bal    := begin + rcvd - sold
      field->wprice := nWhole
      field->retail := nRetail
      jRUnLock()
      lExit := .t.

      /*
        replace cost with nCost  && CAN CHANGE - No need for batch
      */
      // Old Line and Comments. But now CANNOT CHANGE so easily. Needs BATCH

   else
      sele master
      go _oldrec
   endif
enddo
restscreen( 0, 0, 24, 79, _xx )
return nil
//-------------------------
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
static function mst_BChange( nBeg, nCost, lChangeBegin )

local nResp
if lChangeBegin = NIL
   lChangeBegin := .f.
endif
sele batches
set order to 2
seek str( master->id, 4, 0 )
if found()
   do while begin != master->begin
      skip
   enddo

   if master->id == batches->id
      sele master
      jRLock()
      sele batches
      jRLock()

      if lChangeBegin
         batches->begin := nBegin
      endif

      // We Change ONLY opening cost in MASTER.
      // If they want to change the COST, let them make a purchase, man!!!

      batches->cost  := nCost
      master->opcost := nCost

      sele master
      jRUnLock()
      sele batches
      jRUnLock()

   else
      jAlert( 'ERROR : No corresponding entry for Begining stock found; in BATCHES. Although this error is; now ignored, your data is corrupt.;;  Please contact the software administrator urgently' )
   endif
else
   jAlert( 'ERROR : No corresponding entry for this item ; in BATCHES. Although this error is; now ignored, your data is corrupt.;;  Please contact the software administrator urgently' )
endif
sele batches
set order to 1
sele master
return .t.

*+ EOF: MASTER.PRG
