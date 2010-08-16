//-------------------------------------
//   EasyAccounts v1.5
//   SALES MODULE
//                   by Jasim A Basheer
//
//-------------------------------------

#include "std.ch"
#include "inkey.ch"

static lChanged
static aChanged := {}

static line
static lExit
static aItems
static lExist
static cOTHER

static nId
static nCustId
static cCustomer
static nTotal
static nIId
static nPaid
static nDiscount
static nQty
static nPrice

static lIsSystem

static axItems

function sales( lAuto )

local _xx := savescreen( 0, 0, 24, 79 )

lExit    := .f.
lChanged := .f.

if lAuto = NIL
   private lIsAuto := .f.
else
   private lIsAuto := .t.
   clear gets
endif

dispend()

opendatas()

if MasEmpty()
   close all
   return .f.
endif

sele sales
go bott

nId := id + 1

do while !lExit
   aItems := {}     // it is static
   sdDate := entr_date()
   s_paintscr()
   if user() != 'ADM'
      set key K_ALT_W to NegBill()
   endif
   @ 04, 01 say "Srl. No.: " get nId pict '999999'       
   read
   set key K_ALT_W to
   if nId = 0
      lExit := .t.
      exit
   elseif nId < 0 .and. ( user() = 'GEN' )
      jAlert( 'Invalid bill no..' )
      loop
   endif
   @ 04, 01 say "Srl. No.:  " + str( nId, 6, 0 )         
   sele sales
   set order to 1
   seek nId
   if found()
      lExist := .t.
      billexist()
   else
      axItems   := {}
      aItems    := {}
      nPaid     := 0.00
      lExist    := .f.
      nTotal    := 0.00
      lIsSystem := .f.
      nDiscount := 0.00
      cOTHER    := space( 10 )
      if getheader()
         s_getcust( .t. )
         Changed( sdDate )
         if addnew()
            getmenu()
         endif
      endif
   endif
enddo
close all
restscreen( 0, 0, 24, 79, _xx )
if lChanged
   s_cleanup()
   ontask( 'Cheking account books...' )
   s_clrac()
   ontask()
endif
ontask( 'Updating...' )
s_updac()
ontask()
return .t.

static function opendatas

use accounts new index ACC_1,ACC_2
set order to 1
go top
use master new index MAS_1,MAS_2
set order to 1
use saccount new index SAC_1,SAC_2,SAC_3
set order to 1
use sales new index SALE_1,SALE_2
use batches new index BAT_1,BAT_2
set order to 1

*use refrs new index REFRS_1,REFRS_2
*use sale_ref new index SREF_1,SREF_2
// The entire REFERENCE system has been commented.. as it has not been
// used and is not practical. - Jasim 14-May-2004

return .t.

static function s_paintscr

dispbegin()
line := 9
setcolor( boxcolor() )
@ 01, 00 clear to 23, 79
@ 01, 00 to 23, 79
setcolor( scrcolor() )
@ 02, 01 say padc( 'Sales', 78 )         
setcolor( boxcolor() )
footline( 03, 01, 78 )
footline( 18, 01, 78 )

@ 04, 01 say "Srl. No.: "          
@ 05, 01 say "Date    : "          
@ 04, 45 say "Customer : "         
footline( 06, 01, 78 )
footline( 08, 01, 78 )
@ 07, 03 say "Item"          
@ 07, 50 say "Qty"           
@ 07, 58 say "Price"         
@ 07, 70 say "Total"         
footline( 21, 01, 78 )
@ 19, 01 say "Total Amount : "         
@ 20, 01 say "Discount     : "         
@ 19, 30 say "Net Amount   : "         
@ 20, 30 say "Paid         : "         
@ 19, 59 say "Balance : "              
dispend()
dispend()
dispend()
return .t.
//--------------------------------------
static function billexist( lGetmenu )

local _x
local _xx
local aConfig := {}
local nProfit := 0.00

dispbegin()
s_paintscr()
@ 04, 01 say "Srl. No.:  " + str( nId, 6, 0 )         

if lGetmenu = NIL
   lGetmenu := .t.
endif

sele saccount
set order to 1
seek nId
if !found()
   tellout( "SALES AND SUMMARY MISMATCH! CANNOT PROCEED" )
   lExit := .f.
   return .f.
endif
nCustId   := customer
nPaid     := paid
nTotal    := total
nDiscount := discount
sdDate    := date
cOTHER    := other
lIsSystem := IsSystem
aItems    := {}
@ 05, 01 say "Date    :  " + dtoc( sdDate )          
@ 05, 24 say "Other:  " + cOTHER + "       "         
dispuser()
sele accounts
set filter to
set order to 1
seek nCustId
if !found()
   dispend()
   tellout( "Sales AND Customer MISMATCH! CANNOT PROCEED" )
   lExit := .f.
   return .f.
endif
@ 04, 45 clear to 05, 78
@ 04, 45 say subs( rtrim( ltrim( account ) ), 1, 77 - 45 )         
@ 05, 45 say subs( rtrim( ltrim( details ) ), 1, 77 - 45 )         
nTotal := 0.00
sele sales
seek nId            // i thought it useless. but faced a lot bitter before
// realizing it was most essential.

do while id == nId .and. ( !eof() )
   _x := item_id
   sele master
   seek _x
   if found()
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
      sele sales
      @ line, 47 say str( qty, 5, 0 )                  
      @ line, 55 say str( price, 10, 2 )               
      @ line, 67 say str( price * qty, 10, 2 )         
      nTotal  += price * qty
      nProfit += ( price - cost ) * qty
      line ++
      if line > 17
         @ 22,  1 clear to 22, 77
         @ 22,  1 say padc( 'PRESS ANY KEY TO CONTINUE...', 77 )         
         setcolor( scrcolor() )
         @ 22, 21 say "þ"         
         @ 22, 57 say "þ"         
         setcolor( boxcolor() )
         setcursor( 0 )
         dispend()
         if inkey() == K_CTRL_Y
            clear typeahead
            inkey( 0 )
            keyboard chr( K_CTRL_Y ) + "0" + chr( K_ENTER )
         else
            inkey( 0 )
         endif
         setcursor( 1 )
         @ 22,  1 clear to 22, 77
         line := 9
         @ 09,  1 clear to 17, 77
      endif
      sele master
      aadd( aItems, { master->id, sales->Qty, sales->price, ;
                      subs( rtrim( ltrim( master->desc ) ) + iif( !empty( master->details ), ;
                      ", ", "" ) + rtrim( ltrim( master->details ) ), 1, 42 ), sales->cost, sales->item_srl, sales->print } )
      sele master
   else
      dispend()
      tellout( "Sales AND MASTER FILE MISMATCH! CANNOT PROCEED" )
      lExit := .t.
      return .f.
   endif
   sele Sales
   skip
enddo
sele saccount
@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                        
@ 20, 01 say "Discount     : " + str( nDiscount, 10, 2 )                     
@ 19, 30 say "Net Amount   : " + str( nTotal - nDiscount, 10, 2 )            
@ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                         
@ 19, 59 say "Balance : " + str( nTotal - nDiscount - nPaid, 10, 2 )         
@ 20, 59 say "System  : " + iif( lIsSystem, "Yes", "No" )                    

axItems := aItems

dispend()

if lGetMenu
   if len( aItems ) > 0
      getmenu()
   endif
endif
return .t.
//---------------------------------
static function sayitstripped( aConfig )

local x   := {}
local _x  := 1
local _xx := 1
local _y  := aConfig[ 1 ]
for _x := 2 to len( aConfig )
   _xx := _x
   do while !_xx > len( aConfig )
      if len( _y + ", " + aConfig[ _xx ] ) > 70
         aadd( x, _y )
         _y := aConfig[ _xx ]
         _x ++
      else
         _y += ", " + aConfig[ _xx ]
      endif
      _xx ++
   enddo
   aadd( x, _y )
   _y := ""
   _x := _xx
next
_x := 1
do while .not. _x > len( x )
   @ line,  7 say proper( x[ _x ] )         
   line ++
   if line > 17
      @ 22,  1 clear to 22, 77
      @ 22,  1 say padc( 'PRESS ANY KEY TO CONTINUE...', 77 )         
      setcolor( scrcolor() )
      @ 22, 21 say "þ"         
      @ 22, 57 say "þ"         
      setcolor( boxcolor() )
      setcursor( 0 )
      inkey( 0 )
      setcursor( 1 )
      @ 22,  1 clear to 22, 77
      line := 9
      @ 09,  1 clear to 17, 77
      @ line, 03 say "Config. (Continued..)"         
      line ++
   endif
   _x ++
enddo
line ++
return line
//------------------------
static function getmenu

local x      := 1
local cPType := ' '
do while .t.
   if len( aItems ) > 0
      sele saccount
      set order to 1
      seek nId
      dispbegin()
      @ 22, 01 clear to 22, 77
      @ 22, 01 prompt "NEXT"
      @ 22, 07 prompt "PREVIOUS"
      @ 22, 17 prompt "BILL PRINT"      // MENU NOT TO BE SHOWN AT STARTUP
      if ( !ac_closed( sdDate ) ) .and. ( sameuser() )
         @ 22, 30 prompt "UPDATE"
         @ 22, 40 prompt "ADD/EDIT"
         @ 22, 52 prompt "DELETE"
      else
         if ac_closed( sdDate )
            @ 22, 29 say padc( 'BOOKS CLOSED', 52 - 29 )         
         else
            @ 22, 29 say padc( 'ENTRY USER VARIES', 52 - 29 )         
         endif
      endif

      if user() != 'ADM'
         @ 22, 62 prompt "LEDGER"
      endif

      @ 22, 72 prompt "Exit"
      dispend()

      menu to x
      @ 22, 01 clear to 22, 77
      if x = 1
         nId ++
         keyboard chr( K_ENTER )
         return .t.
      elseif x = 2
         nId --
         keyboard chr( K_ENTER )
         return .t.
      elseif x = 3
         if _DEMO != 'REG'
            jAlert( 'Sorry, this is a LITE version of ' + _EasyAccounts + '.;;' + ;
                    'Please register it to use the feature.' )
         else
            do while .t.
               @ 22,  1 clear to 22, 78
               @ 22, 26 say 'Ready to Print ? <Y/N> ' get cPType pict '!' ;       
                       valid ( cPType = 'Y' .or. cPType = 'O' .or. cPType = 'N' .or. cPType = 'L' .or. cPType = 'M' .or. cPType = 'B' .or. cPType = 'C' .or. cPType = 'H' )
               read
               if cPType = 'N'
                  exit
               elseif cPType = 'H'
                  // Help
                  jAlert( ';Help on Print Formats - Press :                     ;;' + ;
                          '     Y for normal bill without leaving no blank lines;' + ;
                          '     N for aborting bill print                       ;' + ;
                          ';' + ;
                          '     L for Large bill covering an A4 size paper      ;' + ;
                          '     C for Compressed bill, leaving 3 blank lines    ;' + ;
                          '     M for Medium bill covering half the A4 paper    ;' + ;
                          '     B for normal bill with 5 Blank lines            ;' )
                  loop
               endif
               trn_print( cPType )
               exit
            enddo
            loop
         endif
      elseif x = 4 .and. ( ac_closed( sdDate ) .or. !sameuser() )
         jSaveEnv()
         ledger( .f. )
         jRestEnv()
         loop
      elseif x = 5 .and. ( ac_closed( sdDate ) .or. !sameuser() )
         if lIsAuto
            keyboard chr( K_CTRL_Y ) + "0" + chr( K_ENTER )
         endif
         return .t.
      elseif x = 4
         Changed( sdDate )
         doaccount()

         //if jAlert( 'Update Transaction Promoters ?', { 'No', 'Yes' } ) = 2
         //   getreference()
         //endif

         if jAlert( 'Update Serial Numbers ?', { 'No', 'Yes' } ) = 2
            updserials()
         endif
         billexist( .f. )
      elseif x = 5
         Changed( sdDate )
         lChanged := .t.
         axItems  := aItems
         s_undoacc()
         if addnew()
            billexist( .f. )
         endif
      elseif x = 6
         if confirm( "SURE TO DELETE BILL ?" )
            Changed( sdDate )
            s_undoacc()
            s_undomast()
            exit
         endif
      elseif x = 7 .and. user() != 'ADM'
         jSaveEnv()
         ledger( .f. )
         jRestEnv()
         loop
      elseif (x=8) .or. ( x = 7 .and. user() == 'ADM' )
         if lIsAuto
            keyboard chr( K_CTRL_Y ) + "0" + chr( K_ENTER )
         endif
         lExit := .f.
         return .f.
      endif
   else
      return .t.
   endif
enddo
return .f.
//------------------------------
static function addnew

local uIId
local x
local toskip  := 0
local oldline := 0
local lPrint
local cSrl    := space( 78 )

do while .t.
   @ 22, 01 clear to 22, 50
   @ 22, 02 say "Add : "         
   @ 22, 10 prompt "ITEM"
   @ 22, 20 prompt "GROUP"
   if len( aItems ) > 0 .and. ( !ac_closed( sdDate ) )
      @ 22, 30 prompt "Delete"
      @ 22, 39 prompt "Save"
   else
      @ 22, 30 prompt "Exit"
   endif
   menu to x
   @ 22, 01 clear to 22, 40
   if x = 0
      loop
   elseif x = 1 .and. checkclose( sdDate )
      @ 22, 02 say 'SELECT ITEM'         
      sele master
      set order to 2
      whichitem( .t., .f. )             // lView-True, lOpen-False
      set filter to
      set order to 1
      nIId := id
      if bal = 0
         @ 22, 02 say padc( 'NO BALANCE STOCK', 76 )         
         tone( 300, 1 )
         tone( 2312, 1 )
         tone( 430, 1 )
         tone( 4230, 2 )
         @ 22, 02 say space( 76 )         
         loop
      endif
      if ascan( aItems, { | aII | aII[ 1 ] == nIId } ) != 0
         msg( "Item already entered..." )
         loop
      endif
      sele master
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
   elseif x = 2 .and. checkclose( sdDate )
      /*
      @ 22,02 say 'SELECT GROUP'
      sele master
      set order to 2
      whichgroup(.t.)
      set filter to
      set order to 1
      nIId := id
      if ascan(aItems, { |aII| aII[1] == nIId}) != 0
         msg("Item already entered...")
         loop
      endif
      sele master
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )
      */
      ontask( 'Group option disabled !' )
      inkey( .5 )
      ontask()
      loop
   elseif x = 3 .and. ( len( aItems ) > 0 )
      s_deleteitem()
      loop
   elseif x = 3 .and. ( len( aItems ) = 0 )
      s_savebill()
      exit
   elseif x = 4
      s_savebill()
      exit
   endif
   @ 22, 01 clear to 22, 50
   if HOBranch()
      @ 22, 55 say "Srl:" + EncSrl( master->cost )         
   endif
   nQty := 1
   do while .t.
      @ 22, 01 say "Quantity : " get nQty picture '999999'       
      read
      if ( nQty > 0 )
         if nQty > master->bal
            tone( 300, 1 )
            msg( "NOT ENOUGH STOCK" )
            loop
         endif
         exit
      endif
   enddo
   @ line, 47 say str( nQty, 5, 0 )         
   nprice := master->retail
   do while .t.
      @ 22, 01 say space( 30 )                                   
      @ 22, 01 say "Price : "  get nprice pict '999999.99'       
      read
      exit
   enddo

   ProfitAlert( nPrice, Cost )

   @ line, 55 say str( nprice, 10, 2 )                
   @ line, 67 say str( nprice * nQty, 10, 2 )         

   select MASTER    //   ***   ****   ******

   @ 21, 29 say 'SERIAL NUMBER '                  
   @ 22, 01 say space( 78 )                        
   @ 22, 01 get cSrl              pict '@X'        
   read
   @ 22, 01 say space( 78 )         
   footline( 21, 01, 78 )

   if HOBranch()
      if nPrice < master->cost
         setcolor( "W*/R+" )
         @ 22, 55 say "Srl:" + EncSrl( nPrice - master->cost )         
         setcolor( boxcolor() )
      elseif nPrice == master->cost
         setcolor( "W/B*" )
         @ 22, 55 say "Srl:" + EncSrl( 00000 )         
         setcolor( boxcolor() )
      else
         setcolor( boxcolor() )
         @ 22, 55 say "Srl:" + EncSrl( nPrice - master->cost )         
      endif
   endif

   //if jAlert( 'Normal Output ?', { 'Yes', 'No' } ) = 1
   //else
   //   lPrint := .f.
   //endif

   lPrint := .t.

   //****** I have put S_IncrBatch right inside the array where the Avg.Cost
   // should come. So there should be no doubt regarding where BATCHing takes place.

   aadd( aItems, { master->id, nQty, nprice, subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 ), S_IncrBatch(), cSrl, lPrint } )
   if aItems[ len( aItems ), 5 ] == 0   // Cost is ZERO.
      tone( 900, 1 )
      tone( 1233, 2 )
      tone( 400, 2 )
      jAlert( 'This item is having ZERO cost !!' )
   endif

   sele master
   jRLock()
   field->sold := sold + nQty           // Do whatever is to be
   field->bal  := bal - nQty            // done in MASTER.DBF

   if !( rtrim( ltrim( proper( cOther ) ) ) = 'Transfer' .or. rtrim( ltrim( proper( cOther ) ) ) = 'Standby' )
      field->retail := nPrice
   endif

   jRUnLock()

   if toskip = 0
      line ++
   else
      line    += toskip
      oldline := 0
      toskip  := 0
   endif
   if line > 17
      @ 22,  1 clear to 22, 77
      @ 22,  1 say padc( 'PRESS ANY KEY TO CONTINUE...', 77 )         
      setcolor( scrcolor() )
      @ 22, 21 say "þ"         
      @ 22, 57 say "þ"         
      setcolor( boxcolor() )
      setcursor( 0 )
      inkey( 0 )
      setcursor( 1 )
      @ 22,  1 clear to 22, 77
      line := 9
      @ 09,  1 clear to 17, 77
   endif
   nTotal += ( nprice * nQty )
   @ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                        
   @ 20, 01 say "Discount     : " + str( nDiscount, 10, 2 )                     
   @ 19, 30 say "Net Amount   : " + str( nTotal - nDiscount, 10, 2 )            
   @ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                         
   @ 19, 59 say "Balance : " + str( nTotal - nDiscount - nPaid, 10, 2 )         
   @ 20, 59 say "System  : " + iif( lIsSystem, "Yes", "No" )                    
enddo
return len( aItems ) > 0
//---------------------------
static function s_deleteitem

local _xyx   := savescreen()
local _x     := 1
local _y     := 0
local maxlen := 0
local x      := len( aItems )
local y

local jx
local jy
local jxx
local jyy

local _yxy := {}

do while .not. _x > len( aItems )
   _y     := max( _y, len( aItems[ _x, 4 ] ) )
   maxlen := max( maxlen, len( aItems[ _x, 4 ] ) )
   aadd( _yxy, aItems[ _x, 4 ] )
   _x ++
enddo

_x := mchoice( _yxy,,,, 'Delete Which Item ?' )
if _x = 0 .or. _x = NIL
   return .f.
endif

if confirm( "Delete" )
   sele master
   seek aItems[ _x, 1 ]
   if found()

      jRLock()
      field->sold := sold - aItems[ _x, 2 ]                 // Do whatever is to be
      field->bal  := bal + aItems[ _x, 2 ]                  // done in MASTER.DBF
      jRUnLock()

      nIId := master->id                // Are referenced to in S_DecrBatch()
      nQty := aItems[ _x, 2 ]
      S_DecrBatch()

   else
      message( "MASTER and Sales Mismatch! DATA CORRUPT.." )
   endif

   jY := {}
   for jx := 1 to len( aItems )
      if !( jx == _x )                  // Avoid that single element and add all the
         aadd( jy, aItems[ jx ] )       // others to the array. EASIER than ADEL!
      endif
   next jx
   aItems := jY

   s_disparray()
   sele Sales
   seek nId
endif

@ 22,  1 clear to 22, 78
return .t.
//---------------------------------
static function s_disparray

local _x
local _xx
local aConfig := {}
@ 05, 01 say "Date    :  " + dtoc( sdDate )         
sele accounts
@ 04, 45 say rtrim( ltrim( account ) ) + space( 10 )         
@ 05, 45 say subs( rtrim( ltrim( details ) ), 30 )           
nTotal := 0.00
_x     := 1
@ 09,  1 clear to 17, 77
line := 9
sele Sales
do while !_x > len( aItems )
   @ line, 03 say subs( aItems[ _x, 4 ], 1, 42 ) // desc                           
   @ line, 47 say str( aItems[ _x, 2 ], 6, 0 ) // qty                              
   @ line, 55 say str( aItems[ _x, 3 ], 10, 2 ) // price                           
   @ line, 67 say str( aItems[ _x, 3 ] * aItems[ _x, 2 ], 10, 2 ) // total         
   nTotal += aItems[ _x, 3 ] * aItems[ _x, 2 ]
   line ++
   if line > 17
      @ 22,  1 clear to 22, 77
      @ 22,  1 say padc( 'PRESS ANY KEY TO CONTINUE...', 77 )         
      setcolor( scrcolor() )
      @ 22, 21 say "þ"         
      @ 22, 57 say "þ"         
      setcolor( boxcolor() )
      setcursor( 0 )
      inkey( 0 )
      setcursor( 1 )
      @ 22,  1 clear to 22, 77
      line := 9
      @ 09,  1 clear to 17, 77
   endif
   sele master
   _x ++
enddo
@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                        
@ 20, 01 say "Discount     : " + str( nDiscount, 10, 2 )                     
@ 19, 30 say "Net Amount   : " + str( nTotal - nDiscount, 10, 2 )            
@ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                         
@ 19, 59 say "Balance : " + str( nTotal - nDiscount - nPaid, 10, 2 )         
return .t.

static function getheader

sdDate := entr_date()

@ 05, 01 say "Date    : " get sdDate                 
@ 05, 24 say "Other: "    get cOTHER pict '@!'       
read

memory_refresh()

if checkclose( sdDate )
  if sdDate > date()
     jAlert('SORRY. Cannot accept future dates..')
     return .f.
   endif
   @ 05, 01 say "Date    :  " + dtoc( sdDate )         
   cOTHER := PROPER( COTHER )
   @ 05, 24 say "Other:  " + cOTHER + "       "         
   @ 04, 45 say "Customer : "                           
else
   return .f.
endif

return .t.

static function s_savebill

local x        := 1
local nxTot    := 0.00
local nOldPaid := 0.00
local nOldDisc := 0.00
local nMargin  := 0.00

memory_refresh()

Changed( sdDate )

if len( axItems ) > 0
   nOldPaid := nPaid
   nOldDisc := nDiscount
   s_undoitem()
endif

sele Sales
do while .not. x > len( aItems )
   append blank
   jRLock()
   field->ID       := nId
   field->ITEM_ID  := aItems[ x, 1 ]
   field->QTY      := aItems[ x, 2 ]
   field->price    := aItems[ x, 3 ]
   field->COST     := aItems[ x, 5 ]
   field->ITEM_SRL := aItems[ x, 6 ]
   field->print    := aItems[ x, 7 ]
   nxTot           += price * QTY
   nMargin         += ( price - cost ) * qty
   sele Sales
   jRUnLock()
   x ++
enddo
sele saccount
if len( aItems ) > 0
   append blank
   jRLock()
   field->id    := nId
   field->other := cOTHER
   field->date  := sdDate

   field->customer := nCustId

   // field->customer := accounts->id
   // ===== The frequent CUSTOMER/SALES MISMATCH.. errors are SUPPOSED to be
   // due to invalid record pointer in the ACCOUNTS.DBF..
   // So, placed the CUSTOMER id into nCustId and let me check what happens.
   //         20-12-2003 Jasim

   field->total := nxTot

   if len( axItems ) > 0
      field->paid     := nOldPaid       // An existing bill. Maintain old paid bal.
      field->discount := nOldDisc
   else
      field->paid := field->total
   endif

   field->margin := nMargin
   field->user   := user()
   field->account := .f.

   jRUnLock()
   nTotal    := total
   nDiscount := discount
   nPaid     := paid

   /*
   sele sale_ref
   set order to 1
   seek nId
   if !found()
      append blank
      jRLock()
      field->date     := sdDate
      field->sale_id  := nId
      field->refrs_id := 'DIRECT'
      field->perc     := 100
      jRUnLock()
   endif
   */

endif

@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                        
@ 20, 01 say "Discount     : " + str( saccount->discount, 10, 2 )            
@ 19, 30 say "Net Amount   : " + str( nTotal - nDiscount, 10, 2 )            
@ 20, 30 say "Paid         : " + str( saccount->paid, 10, 2 )                
@ 19, 59 say "Balance : " + str( nTotal - nDiscount - nPaid, 10, 2 )         
@ 20, 59 say "System  : " + iif( lIsSystem, "Yes", "No" )                    

@ 22,  1 clear to 22, 77

memory_refresh()

if len( aItems ) > 0
   doAccount()
endif

select Sales
return .t.

static function doaccount

local cSys := " "
memory_refresh()

@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )         
do while .t.
   sele saccount
   jRLock()
   @ 20, 01 say "Discount     : " get saccount->discount pict '9999999.99'       
   read
   if saccount->total = saccount->discount
      tone( 300, 1 )
      tone( 2931, 2 )
      jAlert( 'Cannot give discount for the whole amount!' )
      tone( 3212, 1 )
      loop
   endif
   exit
enddo
nDiscount := saccount->discount
@ 19, 30 say "Net Amount   : " + str( nTotal - nDiscount, 10, 2 )         
if rtrim( ltrim( accounts->account ) ) == 'GENERAL SALES'
   saccount->paid := nTotal - nDiscount
endif
@ 20, 30 say "Paid         : " get saccount->paid pict '9999999.99'       
read
nPaid := saccount->paid
@ 20, 30 say "Paid         :  " + str( nPaid, 10, 2 )         
jRUnLock()

cSys := iif( lIsSystem, "Yes", "No" )
if lIsSystem
   lIsSystem := jAlert( "Is this a SYSTEM ?", { "Yes", "No" } ) = 1
else
   lIsSystem := jAlert( "Is this a SYSTEM ?", { "No", "Yes" } ) = 2
endif
read
@ 20, 59 say "System  :    " + iif( lIsSystem, "Yes ", "No " )         
sele sAccount
jRLock()
saccount->IsSystem := lIsSystem
jRUnLock()
inkey( .3 )
memory_refresh()
return .t.
//----------------------------------------------
static function s_getcust( lNew )

select accounts
set order to 2
if lNew
   go top
endif
custlist( .t. )
nCustId := id
@ 04, 45 say rtrim( ltrim( account ) ) + space( 10 )          
@ 05, 45 say subs( rtrim( ltrim( details ) ), 1, 30 )         
return .t.

static function s_undoacc

use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
set order to 5
seek saccount->id
do while found()
  blankrec()
  jRLock()
  delete
  jRUnLock()
  seek saccount->id
enddo
sele daybook
use

use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 4
seek saccount->id
if found()
  blankrec()
  jRLock()
  delete
  jRUnLock()
endif
sele cashbook
use

sele saccount
jRLock()
delete
blankrec()
jRUnLock()
sele Sales
return .t.
//----------------------------------------
static function s_undoitem

sele Sales
set order to 1
seek nId
do while id == nId .and. ( !eof() )
   blankrec()
   jRLock()
   delete
   jRUnLock()
   seek nId
enddo
return .t.
//---------------------------------------------
static function s_undomast

sele Sales
set order to 1
seek nId
do while id == nId .and. ( !eof() )
   sele master
   seek Sales->item_id
   if found()
      jRLock()
      field->sold := sold - Sales->qty
      field->bal  := bal + Sales->qty
      jRUnLock()

      nIId := sales->item_id
      nQty := sales->qty

      S_DecrBatch()

      sele sales
      blankrec()
      jRLock()
      delete
      jRUnLock()
      seek nId
   else
      message( 'Sales and MASTER MISMATCH !' )
   endif
   sele Sales
enddo
return .t.
//----------------------------------------------
static function s_cleanup

local x := 1
close all
use saccount new index SAC_1,SAC_2,SAC_3
set order to 1
use sales new index SALE_1,SALE_2
set order to 1
ontask( 'Verifiying summary..' )
do while .not. eof()
   sele saccount
   seek sales->id
   if !found()
      sele sales
      x := id
      do while id == x .and. ( !eof() )
         blankrec()
         jRLock()
         delete
         jRUnLock()
         skip
      enddo
   else
      sele sales
      skip
   endif
   sele sales
enddo
close all
ontask()
return .t.
//---------------------------------------------
static function s_clrac

local x := 1
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
set order to 5
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 4
use saccount new index SAC_1,SAC_2,SAC_3
set order to 2
for x := 1 to len( aChanged )
   sele saccount
   set order to 2
   seek aChanged[ x ]
   do while aChanged[ x ] == date .and. ( !eof() )
      jRLock()
      field->account := .f.
      jRUnLock()
      sele cashbook
      seek saccount->id
      if found()
         if !type = 'Sales'
            do while inv_id == saccount->id .and. ( type != 'Sales' )
               skip
            enddo
         endif
         do while inv_id == saccount->id .and. ( type = 'Sales' ) .and. ( !eof() )                  // PROCEED !
            blankrec()
            jRLock()
            delete
            jRUnLock()
            seek saccount->id
         enddo
      endif
      sele daybook
      seek saccount->id
      if found()
         if !type = 'Sales'
            do while inv_id == saccount->id .and. ( type != 'Sales' )
               skip
            enddo
         endif
         do while inv_id == saccount->id .and. ( type = 'Sales' ) .and. ( !eof() )                  // PROCEED !
            blankrec()
            jRLock()
            delete
            jRUnLock()
            seek saccount->id
         enddo
      endif
      sele saccount
      skip
   enddo
next x
return nil
//----------------------------
static function s_updac

local x := 0
close all
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
use saccount new index SAC_1,SAC_2,SAC_3
set order to 2
do while .not. eof()
   if !account
      if paid > 0
         sele cashbook
         go bott
         x := id + 1
         append blank
         jRLock()
         field->id      := x
         field->date    := saccount->date
         field->type    := 'Sales'
         field->inv_id  := saccount->id
         field->amount  := saccount->paid
         field->details := 'Sales Bill : ' + rtrim( ltrim( str( saccount->id ) ) )
         field->account := saccount->customer
         field->action  := 'C'
         field->auto    := .t.
         jRUnLock()
      endif

      sele daybook
      if saccount->total > 0
         go bott
         x := id + 1
         append blank
         jRLock()
         field->id   := x
         field->date := saccount->date
         if saccount->other = 'Transfer'
            field->type := 'Transfer'
         elseif saccount->other = 'Standby'
            field->type := 'Standby'
         else
            field->type := 'Sales'
         endif
         field->inv_id := saccount->id
         field->amount := saccount->total - saccount->discount

         if saccount->other = 'Transfer'
            field->details := 'Transfer S/' + rtrim( ltrim( str( saccount->id ) ) )
         elseif saccount->other = 'Standby'
            field->details := 'Standby  S/' + rtrim( ltrim( str( saccount->id ) ) )
         else
            field->details := 'Sales Bill : ' + rtrim( ltrim( str( saccount->id ) ) )
         endif

         field->account := saccount->customer
         field->action  := 'D'
         field->auto    := .t.
         jRUnLock()
      endif
      sele saccount
      jRLock()
      field->account := .t.
      jRUnLock()
   endif
   skip
enddo
close all
return .t.
//-------------------------------------
static function trn_print( cPConfig )

local line       := 1
local cSLine1    := ""
local cSLine2    := ""
local nSrlLines  := 0
local nSkLines   := 0
local nTotal     := 0.00
local cDesc
local cStrAmount

sele sales
set order to 1
seek nId

if !prncheck()
   set printer to BILL.TXT
endif
setprc( 0, 0 )
set device to printer
set printer on
prn_reset()
if cPConfig != 'O'
   if cPConfig = 'C'
      @ line,  0 say chr( 15 )         
      setprc( 0, 0 )
   endif
   if cPConfig != 'C'
      prn_lq()
      prn_bigchar()
      if !empty( eaHead )
         @ line,  0 say 'GW1' + padc( eaHead, 40 ) + "W0H"         
         line ++
      endif

      if !empty( eaTitle )
         @ line,  0 say 'GW1' + padc( eaTitle, 40 ) + "W0H"         
         line ++
      endif
   else
      if !empty( eaHead )
         @ line,  0 say '' + padc( eaHead, 39 )         
         @ line,  0 say padc( eaHead, 39 )               
         line ++
      endif

      if !empty( eaTitle )
         @ line,  0 say '' + padc( eaTitle, 39 )         
         @ line,  0 say padc( eaTitle, 39 )               
         line ++
      endif
      @ line,  0 say chr( 15 )         
   endif

   prn_draft()
   prn_smallchar()

   setprc( prow(), 0 )

   if !empty( eaAdd1 )
      @ line,  0 say padc( eaAdd1, 78 )         
      line ++
   endif
   if !empty( eaAdd2 )
      @ line,  0 say padc( eaAdd2, 78 )         
      line ++
   endif
   if !empty( eaAdd3 )
      @ line,  0 say padc( eaAdd3, 78 )         
      line ++
   endif

   cSLine1 += subs( eaLeft1 + space( ( 78 - ( len( eaLeft1 ) + len( eaRight1 ) ) ) ) + eaRight1, 1, 78 )
   cSLine2 += subs( eaLeft2 + space( ( 78 - ( len( eaLeft2 ) + len( eaRight2 ) ) ) ) + eaRight2, 1, 78 )

   @ line,  0 say cSLine1         
   line ++
   @ line,  0 say cSLine2         
   line ++
   line ++

   sele saccount
   seek nId
   if nId > 0
   if rtrim( ltrim( other ) ) = 'Replacement'
      @ line,  0 say padc( 'REPLACEMENT', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'REPLACEMENT', 78 )         
      endif
   elseif rtrim( ltrim( other ) ) = 'Standby'
      @ line,  0 say padc( 'STANDBY ITEMS', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'STANDBY ITEMS', 78 )         
      endif
   elseif rtrim( ltrim( other ) ) = 'Transfer'
      @ line,  0 say padc( 'TRANSFER NOTE', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'TRANSFER NOTE', 78 )         
      endif
   elseif rtrim( ltrim( other ) ) = 'Debit'
      @ line,  0 say padc( 'DEBIT NOTE', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'DEBIT NOTE', 78 )         
      endif
   elseif rtrim( ltrim( other ) ) = 'Return'
      @ line,  0 say padc( 'SALES RETURN', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'SALES RETURN', 78 )         
      endif
   else
      @ line,  0 say padc( 'SALES INVOICE', 78 )         
      if cPConfig != 'C'
         @ line,  0 say padc( 'SALES INVOICE', 78 )         
         @ line,  0 say padc( 'SALES INVOICE', 78 )         
      endif
   endif
   elseif nId < 0
      @ line, 0 say padc( 'DELIVERY CHALLAN', 78 )
   endif
elseif cPConfig = 'O'
   @ line,  0 say padc( 'ESTIMATE', 78 )         
   @ line,  0 say padc( 'ESTIMATE', 78 )         
endif
line ++
@ line,  0 say subs( "To : " + rtrim( ltrim( proper( accounts->account ) ) ), 1, 53 )         
if cPConfig != 'C'
   @ line,  0 say subs( "To : " + rtrim( ltrim( proper( accounts->account ) ) ), 1, 53 )         
endif
if cPConfig != 'O' .and. saccount->id > 0
   @ line, 61 say "Bill : " + rtrim( ltrim( str( saccount->id ) ) )         
   if cPConfig != 'C'
      @ line, 61 say "Bill : " + rtrim( ltrim( str( saccount->id ) ) )         
   endif
endif
line ++
@ line,  0 say "     " + subs( rtrim( ltrim( proper( accounts->details ) ) ), 1, 53 )         
@ line, 61 say "Date : " + dtoc( saccount->date )                                             
if cPConfig != 'C'
   @ line, 61 say "Date : " + dtoc( saccount->date )         
endif
line ++
sele accounts
seek saccount->customer
@ line,  1 say repli( '-', 77 )         
line ++
@ line,  0 say '| Item Description'         
@ line, 49 say '|'                          
@ line, 51 say 'Qty'                        
@ line, 55 say '|'                          
@ line, 57 say '  Price  '                  
@ line, 67 say '|'                          
@ line, 69 say 'Total'                      
@ line, 78 say '|'                          
line ++
@ line,  0 say "|"                      
@ line,  1 say repli( '-', 77 )         
@ line, 78 say "|"                      
line ++
nSrlLines := line
sele sales
seek nId
do while nId == id .and. ( !eof() )
   if sales->print
      sele master
      seek sales->item_id
      if sales->price > 0
         cDesc := upper( master->desc )
      else
         cDesc := proper( master->desc )
      endif
      cDesc := alltrim( cDesc )
      if len( alltrim( master->details ) ) > 0
         if sales->price > 0
            cDesc += ", " + alltrim( upper( master->details ) )
         else
            cDesc += ", " + alltrim( proper( master->details ) )
         endif
      endif
      cDesc := subs( cDesc, 1, 48 )
      @ line,  0 say '| ' + cDesc         
      sele sales
      @ line, 49 say '|'                      
      @ line, 50 say str( qty, 4, 0 )         
      @ line, 55 say '|'                      
      if price != 0
         @ line, 57 say str( price, 9, 2 )                      
         @ line, 67 say "|"                                     
         @ line, 68 say str( price * qty, 10, 2 ) + '|'         
      else
         @ line, 67 say "|"         
         @ line, 78 say "|"         
      endif
      line ++
      if !empty( rtrim( ltrim( sales->item_srl ) ) )
         @ line,  0 say "|"          
         @ line, 49 say '| '         
         @ line, 55 say '| '         
         @ line, 67 say "|"          
         @ line, 78 say "|"          
         if cPConfig != 'C'
            if !len( alltrim( sales->item_srl ) ) > 61
               @ line,  1 say " " + subs( " (S/N-" + rtrim( ltrim( sales->item_srl ) ), 1, 69 ) + ")  "         
            else
               @ line,  1 say " " + subs( " (S/N-" + rtrim( ltrim( sales->item_srl ) ), 1, 62 ) + ".....   "         
            endif
         else
            if !len( alltrim( sales->item_srl ) ) > 38
               @ line,  1 say subs( "(S/N-" + rtrim( ltrim( sales->item_srl ) ) + ")", 1, 45 )         
            else
               @ line,  1 say subs( "(S/N-" + rtrim( ltrim( sales->item_srl ) ), 1, 40 ) + "....."         
            endif
         endif
         line ++
         @ line,  0 say "|"          
         @ line, 49 say '| '         
         @ line, 55 say '| '         
         @ line, 67 say "|"          
         @ line, 78 say "|"          
         line ++
      endif
      nTotal += price * qty
   endif
   sele sales
   skip
enddo
if cPConfig == 'L'
   nSrlLines := line - nSrlLines
   do while nSrlLines < 32
      @ line,  0 say '| '         
      @ line, 49 say '| '         
      @ line, 55 say '| '         
      @ line, 67 say "|"          
      @ line, 78 say "|"          
      nSrlLines ++
      line ++
   enddo
elseif cPConfig == 'M'
   nSrlLines := line - nSrlLines
   do while nSrlLines < 20
      @ line,  0 say '| '         
      @ line, 49 say '| '         
      @ line, 55 say '| '         
      @ line, 67 say "|"          
      @ line, 78 say "|"          
      nSrlLines ++
      line ++
   enddo
elseif cPConfig == 'B' .or. cPConfig == 'C'
   do while nSkLines < iif( cPConfig == 'B', 5, 3 )
      @ line,  0 say '| '         
      @ line, 49 say '| '         
      @ line, 55 say '| '         
      @ line, 67 say "|"          
      @ line, 78 say "|"          
      nSkLines ++
      line ++
   enddo
endif
@ line,  0 say "|"                      
@ line,  1 say repli( '-', 77 )         
@ line, 78 say "|"                      
line ++
@ line,  0 say "|"         
@ line, 78 say "|"         

if cPConfig != 'C'
   if nTotal - ( saccount->discount + saccount->paid ) = 0  // Cash sales
      @ line,  1 say ' ' + rtrim( ltrim( subs( inwords( nTotal - saccount->discount ), 1, 109 ) ) ) + ' only.   '         
   else
      @ line,  1 say ' ' + rtrim( ltrim( subs( inwords( nTotal - ( saccount->discount + saccount->paid ) ), 1, 109 ) ) ) + ' only.   '         
   endif
   // It is compressed mode.
else
   if nTotal - ( saccount->discount + saccount->paid ) = 0  // Cash sales
      @ line,  1 say ' ' + rtrim( ltrim( subs( inwords( nTotal - saccount->discount ), 1, 68 ) ) ) + ' only.  '         
   else
      @ line,  1 say ' ' + rtrim( ltrim( subs( inwords( nTotal - ( saccount->discount + saccount->paid ) ), 1, 68 ) ) ) + ' only.  '         
   endif
endif

@ line, min( 73, pcol() + 2 ) say "   "         
line ++
@ line,  0 say "|"                           
@ line, 47 say '     Bill Amount : '         
@ line, 67 say str( nTotal, 11, 2 )          
@ line, 78 say '|'                           
line ++
if saccount->discount > 0
   @ line,  0 say '|'                                      
   @ line, 47 say 'Special Discount : '                    
   @ line, 67 say str( saccount->discount, 11, 2 )         
   @ line, 78 say '|'                                      
   line ++
endif
if saccount->paid <> ( nTotal - saccount->discount )
   @ line,  0 say '|'                           
   @ line, 47 say '       Cash Paid : '         
   if saccount->paid <> 0
      @ line, 67 say str( saccount->paid, 11, 2 )         
   else
      @ line, 67 say padc( "NIL", 11 )         
   endif
   @ line, 78 say '|'         
   line ++
   @ line,  0 say '|'         
   @ line, 78 say '|'         
   line ++
   @ line,  0 say '|'         
   @ line, 78 say '|'         
   line ++
   @ line,  0 say '|'                                                                    
   @ line, 47 say '     Net Balance : '                                                  
   @ line, 67 say str( nTotal - ( saccount->discount + saccount->paid ), 11, 2 )         
   if !cPConfig = 'C'
      @ line, 67 say str( nTotal - ( saccount->discount + saccount->paid ), 11, 2 )         
   endif
   @ line, 78 say '|'         
   line ++
else
   if saccount->discount > 0
      @ line,  0 say '|'         
      @ line, 78 say '|'         
      line ++
      @ line,  0 say '|'                                               
      @ line, 47 say '      Net Amount : '                             
      @ line, 67 say str( nTotal - saccount->discount, 11, 2 )         
      if !cPConfig = 'C'
         @ line, 67 say str( nTotal - saccount->discount, 11, 2 )         
      endif
      @ line, 78 say '|'         
      line ++
   endif
endif
if cPConfig != 'O' .and. ( !empty( alltrim( eaBill ) ) )
   @ line,  0 say "|"                      
   @ line,  1 say repli( '-', 77 )         
   @ line, 78 say "|"                      
   line ++
   @ line,  0 say '|'                                   
   @ line,  1 say padc( alltrim( eaBill ), 75 )         
   @ line, 78 say '|'                                   
   line ++
endif
@ line,  1 say repli( '-', 77 )         
line ++
line ++
if !cPConfig = 'O'
   @ line, 01 say 'For ' + proper( alltrim( eaTitle ) )         
   if !cPConfig = 'C'
      @ line, 01 say '    ' + proper( alltrim( eaTitle ) )         
   endif
   line ++
   line ++
   line ++
   line ++
   @ line, 01 say 'Authorised Signatory'         
endif
line ++
line ++
line ++
line ++
line ++
line ++
line ++
@ line, 0 say chr(12)+chr(27)+"@"+chr(13) // these sequences were captured from the EOF of a windows printout..
// @ line, 0 say '  '+chr(10)+chr(13)+chr(10)+'@'+chr(15)+chr(12) // chr-12-eject!
setprc(0,0)
set device to screen
set printer off
set printer to
sele sales
seek nId
return .t.
//---------------------------------------------
static function updserials

line := 9
@ 21, 29 say 'SERIAL NUMBER '         
@ 22, 01 clear to 22, 78
@ 09, 01 clear to 17, 78
sele sales
go top
seek nId
do while id == nId .and. ( !eof() )
   sele master
   seek sales->item_id
   if found()
      setcolor( msgcolor() )
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
      sele sales
      @ line, 47 say str( qty, 5, 0 )                  
      @ line, 55 say str( price, 10, 2 )               
      @ line, 67 say str( price * qty, 10, 2 )         
      setcolor( boxcolor() )
      sele sales
      jRLock()
      @ 22, 01 get sales->item_srl pict '@X'        
      read
      jRUnLock()
      sele master
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
      sele sales
      @ line, 47 say str( qty, 5, 0 )                  
      @ line, 55 say str( price, 10, 2 )               
      @ line, 67 say str( price * qty, 10, 2 )         
      line ++
      if line > 17
         line := 9
         @ 09,  1 clear to 17, 77
      endif
   else
      tone( 3200, 1 )
      plswait( .t., 'Item referred to in sales not in Items Master!' )
      tone( 2900, 1 )
      tone( 3450, 2 )
      tone( 4450, 2 )
      plswait( .f. )
   endif
   sele sales
   skip
enddo
footline( 21, 01, 78 )
sele sales
go top
seek nId
return .t.
//============================================
/*
static function getreference

local cOldScrn := savescreen( 12, 29, 24, 79 )
local nR1      := space( 9 )
local cR1      := space( 25 )
local nP1      := 100
local nR2      := space( 9 )
local cR2      := space( 25 )
local nP2      := 0
local nR3      := space( 9 )
local cR3      := space( 25 )
local nP3      := 0
setcolor( scrcolor() )
@ 12, 30 say padc( 'Transaction Promoters :', 47 )         
setcolor( boxcolor() )
@ 13, 30 clear to 19, 77
@ 13, 30 to 19, 77
@ 14, 32 say 'Promoter Name'         
@ 14, 64 say 'Involvement %'         

sele sale_ref
seek nId
do while deleted()
   skip
enddo
if nId == sale_id
   nR1 := refrs_id
   nP1 := perc
   skip
   if sale_id == nId
      nR2 := refrs_id
      nP2 := perc
      skip
      if sale_id == nId
         nR3 := refrs_id
         nP3 := perc
      endif
   endif
endif
go top
footline( 15, 31, 46 )
sele refrs
if !empty( rtrim( ltrim( nR1 ) ) )
   set order to 1
   go top
   seek nR1
   if !found()
      go top
   endif
endif
set order to 2
refrs_view( .t., .f. )
@ 16, 32 say subs( proper( refrs->name ), 1, 30 )         
cR1 := proper( refrs->name )
nR1 := refrs->id
@ 16, 70 get nP1 pict '999' valid nP1 <= 100       
read
if nP1 = 0
   restscreen( 12, 29, 24, 79, cOldScrn )
   return nil
endif
if nP1 < 100
   if !empty( rtrim( ltrim( nR2 ) ) )
      set order to 1
      go top
      seek nR2
      if !found()
         go top
      endif
   endif
   set order to 2
   refrs_view( .t., .f. )
   cR2 := proper( refrs->name )
   nR2 := refrs->id
   @ 17, 32 say subs( proper( refrs->name ), 1, 30 )                                                     
   @ 17, 71 get nP2                                  pict '99' valid .not. ( ( nP1 + nP2 ) > 100 )       
   read
   if nP2 = 0
      restscreen( 12, 29, 24, 79, cOldScrn )
      return nil
   endif
   if nP1 + nP2 < 100
      if !empty( rtrim( ltrim( nR3 ) ) )
         set order to 1
         go top
         seek nR3
         if !found()
            go top
         endif
      endif
      set order to 2
      refrs_view( .t., .f. )
      cR3 := proper( refrs->name )
      nR3 := refrs->id
      nP3 := 100 - ( nP1 + nP2 )
      @ 18, 32 say subs( proper( refrs->name ), 1, 30 )                                                  
      @ 18, 71 get nP3                                  pict '99' valid ( nP1 + nP2 + nP3 == 100 )       
      read
      if nP3 = 0
         restscreen( 12, 29, 24, 79, cOldScrn )
         return nil
      endif
   endif
endif
sele sale_ref
seek nId
if found()
   do while sale_id == nId .and. ( !eof() )
      jRLock()
      delete
      jRUnLock()
      skip
   enddo
endif
go bott
appe blank
jRLock()
field->date     := sdDate
field->sale_id  := nId
field->refrs_id := nR1
field->perc     := nP1
if nP2 > 0
   appe blank
   field->date     := sdDate
   field->sale_id  := nId
   field->refrs_id := nR2
   field->perc     := nP2
   if nP3 > 0
      appe blank
      field->date     := sdDate
      field->sale_id  := nId
      field->refrs_id := nR3
      field->perc     := nP3
   endif
endif
jRUnLock()
sele sales

restscreen( 12, 29, 24, 79, cOldScrn )
return .t.
*/
//========================================
static function ProfitAlert( nRetail, nPurchase )

if HOBranch()
   if nRetail = 0
      @ 200, 300 say chr( 7 )         
   else
      if nRetail = nPurchase
         tone( 3400, 1 )
         tone( 3403, 1 )
         tone( 3406, 2 )
      elseif nRetail < nPurchase
         tone( 5820, 2 )
         tone( 5823, 1 )
         tone( 5825, 3 )
      endif
   endif
endif
return .t.
//==============
static function S_IncrBatch()

local nRemain  := nQty
local nTotCost := 0.00
local nCount   := 0

// Average can be found out only by (adding ALL the costs) divide number of costs.
// I have experimentally proved that doing nAvgCost := (nAvgCost+cost)/2 within the
// loop wont work.

select batches
set order to 2
seek str( nIId, 4, 0 )
if found()
   do while id == nIId .and. ( !eof() )
      if ( begin + rcvd - sold ) >= nRemain                 // Have enough to hold whole of nRemain?
         nTotCost += cost * nRemain
         nCount   += nRemain
         jRLock()
         field->sold := sold + nRemain
         jRUnLock()
         nRemain := 0
         exit
      elseif ( begin + rcvd - sold ) > 0                    // We know it is not as much as nRemain
         nTotCost += cost * ( begin + rcvd - sold )         // then does it,at least, have some Stock?
         nCount   += ( begin + rcvd - sold )
         nRemain  -= ( begin + rcvd - sold )
         jRLock()
         field->sold := ( begin + rcvd )                    //==> sold+(begin+rcvd-sold). so bal will be 0
         jRUnLock()
      endif
      skip
   enddo
   if nRemain > 0
      jAlert( "ERROR : Stock not available in Batches;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
   endif
else
   jAlert( "ERROR : Stock not available in Batches;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
endif
select batches
set order to 1
return ( nTotCost / nCount )            // The Avg. cost
//-----------------------------------------------
static function S_DecrBatch

local nRemain := nQty
select batches
set order to 2
seek str( master->id, 4, 0 )
if found()
   do while id == nIId .and. ( !eof() )
      if sold >= nRemain                // Have enough to hold whole of nRemain?
         jRLock()
         field->sold := sold - nRemain
         jRUnLock()
         nRemain := 0
         exit
      elseif sold > 0                   // We know it is not as much as nRemain
         jRLock()   // then does it,at least, have some Stock?
         nRemain     -= sold
         field->sold := 0
         jRUnLock()
      endif
      skip
   enddo
   if nRemain > 0
      jAlert( "ERROR : Sold quantity not in Batches;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
   endif
else
   jAlert( "ERROR : Sold quantity not in Batches;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
endif
select batches
set order to 1
return nil
//-----------------------------------------------
/*
static function wnd_print()

// Generates a TEXT file for windows printing.
// A VB app runs in the background as a daemon which should continiously
// check for the presence for this TEXT file using a timer and should
// read the input and give the windows printout.
//
// A small such app. can be found by searching for EABILL.VBP
// But it does not give a good output. So the project is withdrawn.
// Better be off with normal DOS printing....

local line      := 0
local nTotal    := 0.00
local cCompany  := comp_add
local cCompany1 := ""
sele sales
set order to 1
seek nId

   setprc( 0, 0 )
   set device to printer
   set printer to C:\EABILL.TXT
   set printer on
   @ line, 0 say "1"+str( saccount->id, 4, 0 ) + " " + dtoc( saccount->date ) + rtrim(ltrim( proper ( accounts->account ) ))
   line ++
   @ line, 0 say rtrim(ltrim(proper(accounts->details)))
   line++
   sele sales
   seek nId
   do while nId == id .and. ( !eof() )
      if sales->print
         sele master
         seek sales->item_id
         if sales->price > 0
            @ line,  0 say subs( rtrim( ltrim( upper( master->desc ) ) ), 1, 45 )         
         else
            @ line,  0 say subs( rtrim( ltrim( proper( master->desc ) ) ), 1, 45 )         
         endif
         sele sales
         @ line, 46 say str( qty, 4, 0 )
         @ line, 51 say str( price, 10, 0)
         if !empty( rtrim( ltrim( sales->item_srl ) ) )
            @ line,  63 say subs(rtrim( ltrim( sales->item_srl ) ), 1, 40 )
         endif
         nTotal += price * qty
         line++
      endif
      sele sales
      skip
   enddo
   @ line,  0  say "~" + str(nTotal,12,0)+ rtrim( ltrim( subs( inwords( nTotal ), 1, 70 ) ) ) + ' only.'         
   line ++
   set device to screen
   set printer off
   set printer to
   sele sales
   seek nId
return .t.
*/
//---------------------------------------------
static function NegBill

sele sales
set order to 1
go top
keyboard chr( K_CTRL_Y ) + alltrim( str( id - 1 ) )
return .t.
//-------------------------------
static function Changed( sdDate )

lChanged := .t.
if ascan( aChanged, sdDate ) == 0
   aadd( aChanged, sdDate )
endif
return .t.
//-------------------------------

*+ EOF: SALES.PRG
