#include "std.ch"
#include "inkey.ch"
//================================================
// EasyAccounts v2.1 Purchase Module
//        by Jasim A Basheer
//
//         ADDED BATCH PROCESSING ON 22nd August
//
// IMPORTANT NOTE : The Stock Management is a bit complex here.
//                   (**serious** only a bit. not much to bother)
//
// ** Structure of aItems {} ** --->
//    { ItemId[1],Qty[2],Cost[3],Desc+Details[4],Parent[5],0[6] }
//
// ** CREATING A NEW BILL **
//   i) Get Items
//  ii) Update aItems  (ADDNEW)
// iii) Update Master  (ADDNEW)
//  iv) Update BATCHES (ADDNEW)
//   v) Loop 1 to 5.   (ADDNEW)
//  vi) When finished, update PACCOUNT (P_SAVEBILL)
// vii) Flag lChanged TRUE
//
// ** EDITING PREVIOUS BILL **
//   i) Delete from PACCOUNT (P_UNDOACC)
//  ii) Do Previous 5th Step. (ADDNEW)
// iii) Remove previous records from PURCHASE (P_UNDOPRCH from P_SAVEBILL)
//  iv) Update all the items from the beginning (P_SAVEBILL)
//
//             * * * Note - The stock of existing items is not altered in
//                   any way as it is done during ADDNEW only.
//                   So if they had deleted it, the stock is reduced during
//                   deletion. Therefore all worries regarding STOCK
//                   should come to an ultimate rest.
//
//  iv) Update PACCOUNT (P_SAVEBILL)
//   v) Flag lChanged TRUE
//
// ** DELETING PREVIOUS BILL **
//   i) Delete from PACCOUNT (P_UNDOACC)
//  ii) Subtract stock from MASTER for each item     (P_UNDOMAST)
// iii) Delete all entries of the bill from PURCHASE (P_UNDOPRCH)
//  iv) Flag lChanged TRUE
//======================================================

static lChanged
static aChanged := {}

static line
static lExit
static aItems
static lExist
static cBill
static dBDate

static nId
static nSupcode
static cSupName
static nTotal
static nIId
static nPaid
static nBillTax
static nQty
static nCost

static axItems

function purchase( lAuto )

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

// The default date will be the current Entr_date, however, the date can
// be changed during entry.
pdDate := entr_date()

sele purchase
go bott

nId := id + 1

do while !lExit
   aItems := {}     // it is static
   P_paintscr()
   if user() != 'ADM'
      // Allow a seperate hidden series for entering items without bill..
      set key K_ALT_W to NegBill()
   endif
   @ 04, 01 say "Srl. No.: " get nId pict '999999'       
   read
   set key K_ALT_W to
   if nId = 0
      lExit := .t.
      exit
   endif
   @ 04, 01 say "Srl. No.:  " + str( nId, 6, 0 )         
   sele purchase
   set order to 1
   seek nId
   if found()
      lExist := .t.
      billexist()
   else
      axItems  := {}
      aItems   := {}
      nPaid    := 0.00
      lExist   := .f.
      nTotal   := 0.00
      nBillTax := 0.00
      nPaid    := 0.00
      lChanged := .t.
      dBDate   := date()
      cBill    := space( 10 )
      if getheader()
         p_getsup( .t. )
         Changed( pdDate )
         if addnew()
            getmenu()
         endif
      endif
   endif
enddo
close all
restscreen( 0, 0, 24, 79, _xx )
if lChanged
   p_cleanup()
   ontask( 'Cheking account books...' )
   P_clrac()
   ontask()
endif
ontask( 'Updating...' )
P_updac()
ontask()
return .t.

static function opendatas

use accounts new index ACC_1,ACC_2
set order to 1
go top
use master new index MAS_1,MAS_2
set order to 1
use paccount new index PAC_1,PAC_2,PAC_3
set order to 1
use batches new index BAT_1,BAT_2
use purchase new index PRCH_1,PRCH_2
set order to 1
return .t.

static function P_paintscr

line := 9
dispbegin()
setcolor( boxcolor() )
@ 01, 00 clear to 23, 79
@ 01, 00 to 23, 79
setcolor( scrcolor() )
@ 02, 01 say padc( 'Purchase', 78 )         
setcolor( boxcolor() )
footline( 03, 01, 78 )
footline( 18, 01, 78 )

@ 04, 01 say "Srl. No.: "          
@ 05, 01 say "Date    : "          
@ 04, 45 say "Supplier : "         
footline( 06, 01, 78 )
footline( 08, 01, 78 )
@ 07, 03 say "Item"          
@ 07, 50 say "Qty"           
@ 07, 58 say "Cost"          
@ 07, 70 say "Total"         
footline( 21, 01, 78 )
@ 19, 01 say "Total Amount : "         
@ 20, 01 say "Total Tax    : "         
@ 19, 30 say "Net Amount   : "         
@ 20, 30 say "Paid         : "         
@ 19, 59 say "Balance : "              
dispend()
return .t.
//--------------------------------------
static function billexist( lGetmenu )

local _x
local _xx
local aConfig := {}

p_paintscr()

@ 04, 01 say "Srl. No.:  " + str( nId, 6, 0 )         

if lGetmenu = NIL
   lGetmenu := .t.
endif

sele paccount
set order to 1
seek nId
if !found()
   tellout( "Purchase AND SUMMARY MISMATCH! CANNOT PROCEED" )
   lExit := .f.
   return .f.
endif
dBDate   := bdate
nPaid    := paid
nTotal   := total
nBillTax := billtax
pdDate   := date
cBill    := bill
aItems   := {}
dispuser()
@ 05, 01 say "Date    :  " + dtoc( pdDate )         
@ 04, 24 say "  Bill: " + cBill + "   "         
@ 05, 24 say "B.Date: " + dtoc(paccount->bdate) + "   "         
sele accounts
set filter to
set order to 1
seek paccount->supplier
if !found()
   tellout( "Purchase AND Supplier MISMATCH! CANNOT PROCEED" )
   lExit := .f.
   return .f.
endif
@ 04, 45 clear to 05, 78
@ 04, 45 say subs( rtrim( ltrim( account ) ), 1, 77 - 45 )         
@ 05, 45 say subs( rtrim( ltrim( details ) ), 1, 77 - 45 )         
nTotal := 0.00
sele Purchase

seek nId            // thought it useless here. but faced a lot bitter before
// realizing it was most essential.

do while id == nId .and. ( !eof() )
   _x := item_id
   sele master
   seek _x
   if found()
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
      sele Purchase
      @ line, 47 say str( qty, 5, 0 )                 
      @ line, 55 say str( cost, 10, 2 )               
      @ line, 67 say str( cost * qty, 10, 2 )         
      nTotal += Cost * qty
      line ++
      if line > 17
         @ 22,  1 clear to 22, 77
         @ 22,  1 say padc( 'PRESS ANY KEY TO CONTINUE...', 77 )         
         setcolor( scrcolor() )
         @ 22, 21 say "þ"         
         @ 22, 57 say "þ"         
         setcolor( boxcolor() )
         setcursor( 0 )
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
      aadd( aItems, { master->id, Purchase->Qty, Purchase->Cost, ;
                      subs( rtrim( ltrim( master->desc ) ) + iif( !empty( master->details ), ;
                      ", ", "" ) + rtrim( ltrim( master->details ) ), 1, 42 ), .f., 0 } )
      sele master
   else
      tellout( "Purchase AND MASTER FILE MISMATCH! CANNOT PROCEED" )
      lExit := .t.
      return .f.
   endif
   sele Purchase
   skip
enddo
sele paccount
@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                       
@ 20, 01 say "Total Tax    : " + str( nBillTax, 10, 2 )                     
@ 19, 30 say "Net Amount   : " + str( nTotal + nBillTax, 10, 2 )            
@ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                        
@ 19, 59 say "Balance : " + str( nTotal + nBillTax - nPaid, 10, 2 )         
axItems := aItems
if lGetMenu
   if len( aItems ) > 0
      getmenu()
   endif
endif
return .t.
//---------------------------------------------
static function getmenu

local x := 1
do while .t.
   sele pAccount
   if len( aItems ) > 0
      @ 22, 01 prompt "NEXT"
      @ 22, 09 prompt "PREVIOUS"
      @ 22, 23 prompt "UPDATE"          // MENU NOT TO BE SHOWN AT STARTUP
      @ 22, 37 prompt "PRINT"
      @ 22, 49 prompt "ADD/EDIT"
      @ 22, 61 prompt "DELETE"
      @ 22, 71 prompt "Exit"
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
         if !sameuser()
            jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                    'You are not authorized to alter it.' )
         else
            sele paccount
            set order to 1
            seek nId
            if found()
               pdDate := date
               cBill  := bill
               getheader()
               jRLock()
               field->date := pdDate
               field->bill := cBill
               jRUnLock()
            else
               msg( 'Mismatch with summary...' )
            endif
            Changed( pdDate )
            doaccount()
         endif
      elseif x = 4
         trn_print()
      elseif x = 5
         if !sameuser()
            jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                    'You are not authorized to alter it.' )
         else
            Changed( pdDate )
            axItems := aitems
            P_undoacc()
            if addnew()
               billexist( .f. )
            endif
         endif
      elseif x = 6
         if !sameuser()
            jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                    'You are not authorized to alter it.' )
         else
            if confirm( "SURE TO DELETE BILL ?" )
               Changed( pdDate )
               if P_okDel()
                  P_undoacc()
                  P_undomast()
                  P_undoprch()          // is just a repetition. P_UNDOMAST already
                  // deletes those entries..
                  exit
               endif
            endif
         endif
      elseif x = 7
         if lIsAuto
            keyboard chr( K_CTRL_Y ) + "0" + chr( K_ENTER )
         endif
         lExit := .F.
         return .F.
      endif
   else
      lExit := .t.
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

do while .t.

   @ 22, 01 clear to 22, 78
   @ 22, 10 prompt "Add Item"
   if len( aItems ) > 0
      @ 22, 30 prompt "Delete"
      @ 22, 39 prompt "Save"
   else
      @ 22, 30 prompt "Exit"
   endif
   menu to x
   @ 22, 01 clear to 22, 78
   if x = 0
      loop
   elseif x = 1
      @ 22, 02 say 'SELECT ITEM'         
      sele master
      set order to 2
      whichitem( .f., .f. )             // lView-False, should add if needed. lOpen-False.
      set filter to
      set order to 1
      nIId := id
      if ascan( aItems, { | aII | aII[ 1 ] == nIId } ) != 0
         msg( "Duplicate item exists...", "Cannot add again" )
         loop
      endif
      sele master
      @ line, 03 say subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 )         
   elseif x = 2 .and. ( len( aItems ) > 0 )
      P_deleteitem()
      loop
   elseif x = 2 .and. ( len( aItems ) = 0 )
      P_savebill()
      exit
   elseif x = 3
      P_savebill()
      exit
   endif
   @ 22, 01 clear to 22, 50
   nQty := 1
   do while .t.
      @ 22, 01 say "Quantity : " get nQty picture '999999'       
      read
      if !( nQty = 0 )
         exit
      endif
   enddo
   @ line, 47 say str( nQty, 5, 0 )         

   nCost := master->cost

   do while .t.
      @ 22, 01 say space( 30 )                                  
      @ 22, 01 say "Cost : "   get nCost pict '999999.99'       
      read
      exit
   enddo

   @ line, 55 say str( nCost, 10, 2 )                
   @ line, 67 say str( nCost * nQty, 10, 2 )         
   sele master
   aadd( aItems, { master->id, nQty, nCost, subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 ), .f., 0 } )

   jRLock()
   field->rcvd := rcvd + nQty           // Do whatever is to be
   field->bal  := bal + nQty            // done in MASTER.DBF
   field->cost := nCost
   sele BATCHES
   set order to 1
   // Batch Processing below...

   seek str( master->id, 4, 0 ) + str( nCost, 9, 2 )
   if !found()
      append blank
      field->ID   := master->id
      field->COST := nCost
      field->RCVD := nQty
      jRUnLock()
      jAlert( "New Batch Created!" )
   else
      jRLock()
      field->RCVD := RCVD + nQty
      jRUnLock()
   endif
   sele master
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
   nTotal += ( nCost * nQty )
   @ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                       
   @ 20, 01 say "Total Tax    : " + str( nBillTax, 10, 2 )                     
   @ 19, 30 say "Net Amount   : " + str( nTotal + nBillTax, 10, 2 )            
   @ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                        
   @ 19, 59 say "Balance : " + str( nTotal + nBillTax - nPaid, 10, 2 )         
enddo
return len( aItems ) > 0
//---------------------------
static function P_deleteitem

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

// No need. all the same if same item.
// We havent changed any stock positions yet.
if confirm( "Delete" )
   sele master
   seek aItems[ _x, 1 ]
   if found()
      if bal >= aItems[ _x, 2 ]
         jRLock()
         field->rcvd := rcvd - aItems[ _x, 2 ]              // Do whatever is to be
         field->bal  := bal - aItems[ _x, 2 ]
         jRUnLock()
         sele BATCHES
         set order to 1
         seek str( master->id, 4, 0 ) + str( aItems[ _x, 3 ], 9, 2 )       // _x,3 - Cost
         if !found()
            set order to 2
            seek str( master->id, 4, 0 )
            if !found()
               jAlert( "ERROR : Item for deletion missing from BATCHES;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
            endif
         endif
         if found()
            jRLock()
            field->rcvd := rcvd - aItems[ _x, 2 ]           // Qty
            jRUnLock()
         endif
      else
         jAlert( 'Not enough balance stock to delete this purchase' )
         return .f.
      endif
   else
      message( "MASTER and Purchase Mismatch! DATA CORRUPT.." )
   endif
   jY := {}
   for jx := 1 to len( aItems )
      if !( jx == _x )                  // Avoid that single element and add all the
         aadd( jy, aItems[ jx ] )       // others to the array. EASIER than ADEL!
      endif
   next jx
   aItems := jY

   P_disparray()
   sele Purchase
   seek nId
endif
@ 22,  1 clear to 22, 78
return .t.
//---------------------------------
static function P_disparray

local _x
local _xx
local aConfig := {}
@ 05, 01 say "Date    :  " + dtoc( pdDate )         
sele accounts
@ 04, 45 say rtrim( ltrim( account ) ) + space( 10 )         
@ 05, 45 say subs( rtrim( ltrim( details ) ), 30 )           
nTotal := 0.00
_x     := 1
@ 09,  1 clear to 17, 77
line := 9
sele Purchase
do while !_x > len( aItems )
   @ line, 03 say subs( aItems[ _x, 4 ], 1, 42 ) // desc                           
   @ line, 47 say str( aItems[ _x, 2 ], 6, 0 ) // qty                              
   @ line, 55 say str( aItems[ _x, 3 ], 10, 2 ) // Cost                            
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
@ 20, 01 say "Total Tax    : " + str( nBillTax, 10, 2 )                     
@ 19, 30 say "Net Amount   : " + str( nTotal + nBillTax, 10, 2 )            
@ 20, 30 say "Paid         : " + str( nPaid, 10, 2 )                        
@ 19, 59 say "Balance : " + str( nTotal + nBillTax - nPaid, 10, 2 )         
return .t.

static function getheader

@ 05, 01 say "Date    : " get pdDate // Change ENTRY DATE if you want...        
read
@ 05, 01 say "Date    :  " + dtoc( pdDate )                           
@ 04, 24 say "  Bill:" get cBill pict '@!'
@ 05, 24 say "B.Date:" get dBDate
read
cBill := proper( cBill )
@ 04, 24 say "  Bill: " + cBill + "   "         
@ 05, 24 say "B.Date: " + dtoc(dBDate) + "   "         
return .t.

static function P_savebill

local x     := 1
local nxTot := 0.00

Changed( pdDate )

if len( axItems ) > 0
   p_undoprch()
endif
sele Purchase
do while .not. x > len( aItems )
   append blank
   jRLock()
   field->ID      := nId
   field->ITEM_ID := aItems[ x, 1 ]
   field->QTY     := aItems[ x, 2 ]
   field->Cost    := aItems[ x, 3 ]
   jRUnLock()
   nxTot += Cost * QTY
   sele Purchase
   x ++
enddo
sele paccount

if len( aItems ) > 0
   append blank
   jRLock()
   field->id       := nId
   field->bill     := cBill
   field->bdate    := dBDate
   field->date     := pdDate
   field->Supplier := accounts->id
   field->total    := nxTot
   field->user     := user()
   jRUnLock()
   nTotal   := total
   nBilltax := billtax
   nPaid    := paid
endif

@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )                       
@ 20, 01 say "Total Tax    : " + str( paccount->billtax, 10, 2 )            
@ 19, 30 say "Net Amount   : " + str( nTotal + nBillTax, 10, 2 )            
@ 20, 30 say "Paid         : " + str( paccount->paid, 10, 2 )               
@ 19, 59 say "Balance : " + str( nTotal + nBillTax - nPaid, 10, 2 )         
select purchase
return .t.

static function doaccount

@ 19, 01 say "Total Amount : " + str( nTotal, 10, 2 )         
jRLock()
@ 20, 01 say "Total Tax    : " get paccount->billtax pict '9999999.99'       
read
nBillTax := paccount->billtax
@ 19, 30 say "Net Amount   : " + str( nTotal + nBillTax, 10, 2 )                                            
@ 20, 30 say "Paid         : "                                   get paccount->paid pict '9999999.99'       
read
jRUnLock()
nPaid := paccount->paid
@ 19, 59 say "Balance : " + str( nTotal + nBillTax - nPaid, 10, 2 )         
inkey( .3 )
return .t.
//----------------------------------------------
static function P_getsup( lNew )

select accounts
set order to 2
if lNew
   go top
endif
suplist( .t. )
nSupcode := id
@ 04, 45 say rtrim( ltrim( account ) ) + space( 10 )          
@ 05, 45 say subs( rtrim( ltrim( details ) ), 1, 30 )         
return .t.

static function P_undoacc

sele paccount
jRLock()
delete
blankrec()
jRUnLock()
sele Purchase
return .t.
//----------------------------------------
static function p_undoprch

sele Purchase
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
static function P_undomast

sele Purchase
set order to 1
seek nId
do while id == nId .and. ( !eof() )
   sele master
   seek Purchase->item_id
   if found()
      jRLock()
      field->rcvd := rcvd - Purchase->qty
      field->bal  := bal - Purchase->qty
      jRUnLock()

      sele BATCHES
      set order to 1
      seek str( purchase->item_id, 4, 0 ) + str( purchase->cost, 9, 2 )         // _x,3 - Cost
      if !found()
         set order to 2
         seek str( master->id, 4, 0 )
         if !found()
            jAlert( "ERROR : Item for deletion missing from BATCHES;Although this error is ignored, this means your data is corrupt; Please contact the software administrator urgently" )
         endif
      endif
      if found()
         jRLock()
         field->rcvd := rcvd - Purchase->qty                // Qty
         jRUnLock()
      endif

      sele Purchase
      blankrec()
      jRLock()
      delete
      jRUnLock()
      seek nId
   else
      message( 'Purchase and MASTER MISMATCH !' )
   endif
   sele Purchase
enddo
return .t.
//----------------------------------------------
static function P_clrac

use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
set order to 5
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 4
use paccount new index PAC_1,PAC_2,PAC_3
set order to 2

for x := 1 to len( aChanged )
   sele paccount
   set order to 2
   seek aChanged[ x ]
   do while aChanged[ x ] == date .and. ( !eof() )
      jRLock()
      field->account := .f.
      jRUnLock()
      sele cashbook
      seek paccount->id
      if found()
         if !type = 'Purchase'
            do while inv_id == paccount->id .and. ( type != 'Purchase' )
               skip
            enddo
         endif
         do while inv_id == paccount->id .and. ( type = 'Purchase' ) .and. ( !eof() )               // PROCEED !
            blankrec()
            jRLock()
            delete
            jRUnLock()
            seek paccount->id
         enddo
      endif
      sele daybook
      seek paccount->id
      if found()
         if !type = 'Purchase'
            do while inv_id == paccount->id .and. ( type != 'Purchase' )
               skip
            enddo
         endif
         do while inv_id == paccount->id .and. ( type = 'Purchase' ) .and. ( !eof() )               // PROCEED !
            blankrec()
            jRLock()
            delete
            jRUnLock()
            seek paccount->id
         enddo
      endif
      sele paccount
      skip
   enddo
next x

return nil
//----------------------------
static function P_updac

local x := 0
close all
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
use paccount new index PAC_1,PAC_2,PAC_3
set order to 2
go top
do while .not. eof()
   if !account

      // These narrations - details are important. Their layout (exact column positions)
      // are used in LEDGER and other DIRECTGO reports for extracting the billno.
      // So be careful

      if paid > 0
         sele cashbook
         go bott
         x := id + 1
         append blank
         jRLock()
         field->id      := x
         field->date    := paccount->date
         field->type    := 'Purchase'
         field->inv_id  := paccount->id
         field->amount  := paccount->paid
         field->details := 'Payment P/Bill : ' + rtrim( ltrim( paccount->bill ) ) + ' dtd.'+dtoc(paccount->date)+'  Srl: ' + rtrim( ltrim( str( paccount->id ) ) )
         field->account := paccount->Supplier
         field->action  := 'D'
         field->auto    := .t.
         jRUnLock()
      endif

      sele daybook

      // These narrations - details are important. Their layout (exact column positions)
      // are used in LEDGER and other DIRECTGO reports for extracting the billno.
      // So be careful

      if paccount->total > 0
         go bott
         x := id + 1
         append blank
         jRLock()
         field->id     := x
         field->date   := paccount->date
         field->type   := iif( paccount->bill = 'Transfer', 'Transfer', iif( paccount->bill = 'Standby', 'Standby', 'Purchase' ) )
         field->inv_id := paccount->id
         field->amount := paccount->total + paccount->billtax
         if ( paccount->bill = 'Transfer' )
            field->details := 'Transfer P/' + rtrim( ltrim( str( paccount->id ) ) )
         elseif ( paccount->bill = 'Standby' )
            field->details := 'Standby  P/' + rtrim( ltrim( str( paccount->id ) ) )
         else
            field->details := 'P/Bill : ' + rtrim( ltrim( paccount->bill ) ) + ' dtd.'+dtoc(paccount->date)+'  Srl: ' + rtrim( ltrim( str( paccount->id ) ) )
         endif
         field->account := paccount->Supplier
         field->action  := 'C'
         field->auto    := .t.
         jRUnLock()
      endif

      sele paccount
      jRLock()
      field->account := .t.
      jRUnLock()
   endif
   skip
enddo
close all
return .t.
//-------------------------------------
static function P_cleanup

local x := 1
close all
use paccount new index PAC_1,PAC_2,PAC_3
set order to 1
go top
use purchase new index PRCH_1,PRCH_2
set order to 1
go top
ontask( 'Verifiying summary..' )
do while .not. eof()
   sele paccount
   seek purchase->id
   if !found()
      sele purchase
      x := id
      do while id == x .and. ( !eof() )
         blankrec()
         jRLock()
         delete
         jRUnLock()
         skip
      enddo
   else
      sele purchase
      skip
   endif
   sele purchase
enddo
close all
ontask()
return .t.
//-------------------------
static function trn_print

local line   := 1
local nTotal := 0.00
sele purchase
set order to 1
seek nId
if prncheck()
   setprc( 0, 0 )
   set device to printer
   set printer on
   prn_reset()
   prn_lq()
   prn_bigchar()
   @ line,  1 say padc( eaTitle, 29 )         
   prn_draft()
   prn_smallchar()
   line ++
   @ line,  1 say padc( comp_add, 58 )         
   @ line,  1 say padc( comp_add, 58 )         
   line ++
   sele paccount
   seek nId
   //@ line, 1 say "Date : "+dtoc(entr_date())
   if rtrim( ltrim( bill ) ) = 'Rep'
      @ line,  1 say padc( 'REPLACEMENT', 58 )         
      @ line,  1 say padc( 'REPLACEMENT', 58 )         
   elseif rtrim( ltrim( bill ) ) = 'Standby'
      @ line,  1 say padc( 'STANDBY ITEMS', 58 )         
      @ line,  1 say padc( 'STANDBY ITEMS', 58 )         
   elseif rtrim( ltrim( bill ) ) = 'Transfer'
      @ line,  1 say padc( 'TRANSFER NOTE', 58 )         
      @ line,  1 say padc( 'TRANSFER NOTE', 58 )         
   elseif rtrim( ltrim( bill ) ) = 'Return'
      @ line,  1 say padc( 'PURCHASE RETURN', 58 )         
      @ line,  1 say padc( 'PURCHASE RETURN', 58 )         
   else
      @ line,  1 say padc( 'CREDIT NOTE', 58 )         
      @ line,  1 say padc( 'CREDIT NOTE', 58 )         
   endif
   //@ line,53 say "No.:"+rtrim(ltrim(str(nId,5,0)))
   line ++
   @ line,  1 say "To : " + rtrim( ltrim( proper( accounts->account ) ) ) + ;         
           iif( !empty( rtrim( ltrim( accounts->details ) ) ), ', ' + rtrim( ltrim( proper( accounts->details ) ) ), '' )
   @ line,  1 say "To : " + rtrim( ltrim( proper( accounts->account ) ) ) + ;         
           iif( !empty( rtrim( ltrim( accounts->details ) ) ), ', ' + rtrim( ltrim( proper( accounts->details ) ) ), '' )
   @ line, 42 say "Date : " + dtoc( pdDate )         
   line ++
   sele accounts
   seek paccount->supplier
   @ line,  1 say repli( '-', 58 )         
   line ++
   @ line,  1 say 'Item Description'         
   @ line, 35 say 'Qty'                      
   @ line, 43 say 'Cost'                     
   @ line, 54 say 'Total'                    
   line ++
   @ line,  1 say repli( '-', 58 )         
   line ++
   sele purchase
   seek nId
   do while nId == id .and. ( !eof() )
      sele master
      seek purchase->item_id
      @ line,  1 say subs( rtrim( ltrim( master->desc ) ), 1, 31 )         
      sele purchase
      @ line, 33 say str( qty, 5, 0 )                
      @ line, 40 say str( cost, 8, 2 )               
      @ line, 50 say str( cost * qty, 9, 2 )         
      line ++
      nTotal += cost * qty
      sele purchase
      skip
   enddo
   @ line,  1 say repli( '-', 58 )         
   line ++
   @ line,  1 say '' + subs( inwords( nTotal ), 1, 48 ) + ' only.    '         
   @ line, 49 say space( 5 )                                                      
   @ line, 49 say str( nTotal, 10, 2 )                                            
   @ line, 49 say str( nTotal, 10, 2 )                                            
   line ++
   @ line,  1 say repli( '=', 58 )         
   line ++
   @ line, 25 say 'For ' + eaTitle         
   line ++
   line ++
   line ++
   @ line, 25 say 'Authorised Signatory'         
   line ++
   line ++
   line ++
   @ line,  1 say '             '         
   set device to screen
   set printer off
   set printer to
   sele purchase
   seek nId
endif
return .t.
//-----------------------------------------------
static function P_okDel

sele Purchase
set order to 1
seek nId
do while id == nId .and. ( !eof() )
   sele master
   seek Purchase->item_id
   if found()
      if !bal >= purchase->qty
         msg( 'Not enough balance stock to delete item - ', rtrim( ltrim( subs( master->desc, 1, 40 ) ) ) )
         return .f.
      endif
   else
      jAlert( 'Item in purchase missing from master' )
      return .f.
   endif
   sele Purchase
   skip
enddo
return .t.
//----------------------------------
static function GoLastBatch()

local x := id
do while id == x .and. ( !eof() )
   skip
enddo
skip - 1
return .t.
//-----------------------------------
static function NegBill

sele purchase
set order to 1
go top
keyboard chr( K_CTRL_Y ) + alltrim( str( id - 1 ) )
return .t.
//----------------------------------------------
static function Changed( pdDate )

lChanged := .t.
if ascan( aChanged, pdDate ) == 0
   aadd( aChanged, pdDate )
endif
return .t.
//-------------------------------

*+ EOF: PURCHASE.PRG
