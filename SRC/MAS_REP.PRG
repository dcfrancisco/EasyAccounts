#include "std.ch"
#include "inkey.ch"
//----------------------------------------------
// **EasyAccounts v2.1 Master File Reports
//
//   Also includes BATCH INFO.
//----------------------------------------------
function costrep

local line  := 1
local lTot1 := 0.00
local lTot2 := 0.00
local lbBeg := .t.

use batches new index BAT_2
use master new index MAS_1,MAS_2
set order to 2
go top
JInitRep( "Items List", .F., { || dgItemMas() }, 'Preparing report...', 79 )
jDGSetPBar( reccount() )
jNextLine()
jNextLine()
jAddData( 1, padc( 'Items Master', 79 ) )
jNextLine()
jAddData( 1, replicate( '-', 79 ) )
jNextLine()
jAddData( 1, 'Item' )
jAddData( 49, 'Stock' )
jAddData( 59, 'L/Cost' )
jAddData( 70, 'Retail' )
jNextLine()
jAddData( 1, replicate( '-', 79 ) )
jNextLine()
go top
do while .not. eof()
   if bal > 0
      jAddData( 1, subs( rtrim( ltrim( desc ) ) + '  ' + rtrim( ltrim( details ) ), 1, 45 ), ;
                str( id, 6, 0 ) )
      sele batches
      seek str( master->id, 4, 0 )
      lbBeg := .t.
      do while master->id == batches->id
         if ( begin + rcvd - sold ) > 0
            if !lbBeg
               jNextLine()
               jAddData( 35, 'Next Batch' )
            else
               lbBeg := .f.
            endif
            jAddData( 48, str( begin + rcvd - sold, 5, 0 ), str( master->id, 6, 0 ) )
            if cost <> 0
               jAddData( 54, str( cost, 10, 2 ) )
            endif
         endif
         skip
      enddo
      sele master
      if retail <> 0
         jAddData( 67, str( retail, 10, 2 ) )
      endif
      lTot1 += cost
      jNextLine()
   endif
   jDGIncrPBar()
   skip
enddo

jAddData( 1, repli( '-', 77 ) )
jNextLine()
jNextLine()
jAddData( 1, "   " )
close all

jEndReport()

return .t.
//-----------------
function item_rep( nItemId )

local line   := 1
local x
local nHoriz := 1

if user() == 'ADM'
  msg('I am sorry. Work in progress...!')
  return .f.
endif

use purchase new index PRCH_2
use sales new index SALE_2
use accounts new index ACC_1
use batches new index BAT_2
use master new index MAS_1,MAS_2

if MasEmpty()
   close all
   return .f.
endif

if nItemId = NIL
   whichitem( .f., .f. )
   nItemId := id
else
   seek nItemId
endif

use paccount new index PAC_1
use saccount new index SAC_1

sele sales
seek master->id

sele purchase
seek master->id

JInitRep( "Item Report", .f., { || dgItemRep() },, 76 )

jNextLine()
jAddData( 1, padc( 'ITEM REPORT', 76 ) )
jNextLine()
jAddData( 1, replicate( '-', 76 ) )
jNextLine()
sele master
jAddData( 1, padc( rtrim( ltrim( master->desc ) ), 76 ) )
jNextLine()
jAddData( 1, replicate( '-', 76 ) )
jNextLine()
x := "Op.Stock : " + alltrim( str( begin ) )
x += "     Purchased : " + alltrim( str( rcvd ) )

//x := x+"     Group Stock : "+alltrim(str(g_stock))
// No More GROUPS

jAddData( 1, padc( x, 76 ) )
jNextLine()
x := "Sold : " + alltrim( str( sold ) )
x += "     Bal : " + alltrim( str( bal ) )
jAddData( 1, padc( x, 76 ) )
jNextLine()
jAddData( 1, replicate( '-', 76 ) )
jNextLine()
jAddData( 1, padc( "Transaction History", 76 ) )
jNextLine()
jAddData( 1, replicate( '-', 76 ) )
jNextLine()
jAddData( 1, "Srl" )
jAddData( 6, "Date" )
jAddData( 18, "P/Bill" )
jAddData( 27, "Qty" )
jAddData( 33, "Amount" )
jAddData( 41, "Party" )
jNextLine()
sele purchase
jAddData( 4, "Purchase" )
jNextLine()
do while item_id == master->id .and. ( .not. eof() )
   sele paccount
   seek purchase->id
   sele accounts
   seek paccount->supplier
   sele paccount
   jAddData( 1, str( id, 5, 0 ), 'P' + str( id, 6, 0 ) )
   jAddData( 7, date )
   jAddData( 19, subs( bill, 1, 8 ) )
   jAddData( 28, str( purchase->qty, 4, 0 ) )
   jAddData( 34, str( purchase->cost, 6, 0 ) )
   jAddData( 42, subs( accounts->account, 1, 35 ) )
   jNextLine()
   sele purchase
   skip
enddo
sele sales
jNextLine()
jAddData( 4, "Sales" )
jNextLine()
do while item_id == master->id .and. ( .not. eof() )
   sele saccount
   seek sales->id
   sele accounts
   seek saccount->customer
   sele saccount
   jAddData( 1, str( id, 5, 0 ), 'S' + str( id, 6, 0 ) )
   jAddData( 7, date )
   jAddData( 19, subs( other, 1, 8 ) )
   jAddData( 28, str( sales->qty, 4, 0 ) )
   jAddData( 34, str( sales->price, 6, 0 ) )
   jAddData( 42, subs( accounts->account, 1, 35 ) )
   jNextLine()
   sele sales
   skip
enddo
jNextLine()
jAddData( 2, repli( '-', 18 ) )
jNextLine()
jAddData( 2, padc( "BATCH DETAILS", 18 ) )
jNextLine()
jAddData( 2, "Stock" )
jAddData( 14, "Cost" )
jNextLine()
sele batches
seek str( master->id, 4, 0 )
do while master->id == batches->id .and. ( !eof() )
   jAddData( 2, str( begin + rcvd - sold, 4 ) )
   jAddData( 9, str( cost, 10, 2 ) )
   skip
   jNextLine()
enddo
jNextLine()
jAddData( 2, repli( '=', 18 ) )
jNextLine()

jNextLine()
jAddData( 1, "   " )

close all

jEndReport()

return .t.
//---------------------------------
function pricelist1

local line  := 1
local lTot1 := 0.00
local lTot2 := 0.00

ShowPBar( 'Generating items list with price...' )

set device to printer
set printer on
set printer to ( RepPath + 'MAS_REP.TXT' )
use master new index MAS_1,MAS_2
set order to 2
go top
SayTitles( 79, @line )
line ++
@ line,  1 say padc( 'Price List', 79 )         
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
@ line,  1 say 'Item'            
@ line, 49 say 'Stock'           
@ line, 59 say 'Retail'          
@ line, 70 say 'W/Price'         
line ++
@ line,  1 say replicate( '-', 79 )         
go top
do while .not. eof()
   if bal > 0
      @ line,  1 say subs( rtrim( ltrim( desc ) ) + '  ' + rtrim( ltrim( details ) ), 1, 45 )         
      @ line, 48 say str( bal, 6, 0 )                                                                 
      @ line, 54 say str( retail, 10, 2 )                                                             
      @ line, 67 say str( wprice, 10, 2 )                                                             
      lTot1 += cost
      line ++
   endif
   skip
   IncrPBar()
enddo
line ++
line ++
@ line,  1 say "   "         
set device to screen
set printer off
set printer to
close all
HidePBar()
fileread( 1, 0, 23, 79, RepPath + 'MAS_REP.TXT', 'Master File List' )
return .t.
//--------------------------------------------------------
function trans_rep

local line  := 1
local lTot1 := 0.00
local lTot2 := 0.00
ShowPBar( 'Preparing stock transfer report... Moved Out' )
set device to printer
set printer on
set printer to ( RepPath + 'TRN_REP.TXT' )
SayTitles( 79, @line )
line ++
@ line,  1 say padc( 'Stock Transfer', 79 )         
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
@ line,  2 say 'Srl#'          
@ line,  8 say 'Date'          
@ line, 19 say 'Item'          
@ line, 59 say 'Party'         
@ line, 70 say 'Qty'           
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
use saccount new index sac_1
set filte to other = 'Transfer'
go top
PBarFilter()
use paccount new index pac_1
set filte to bill = 'Transfer'
go top
use purchase new index prch_1
use sales new index sale_1
use master new index mas_1
use accounts new index acc_1
@ line,  1 say "MOVED OUT"         
line ++
sele saccount
do while .not. eof()
   @ line,  1 say str( id, 6, 0 )         
   @ line,  8 say date                    
   sele sales
   seek saccount->id
   do while id == saccount->id .and. ( !eof() )
      sele master
      seek sales->item_id
      @ line, 19 say proper( desc )         
      sele accounts
      seek saccount->customer
      @ line, 52 say proper( subs( account, 1, 17 ) )         
      sele sales
      @ line, 72 say str( qty, 5, 0 )         
      line ++
      sele sales
      skip
   enddo
   sele saccount
   skip
   IncrPBar()
enddo
HidePBar()

ShowPBar( 'Preparing stock transfer report... Moved In' )
@ line,  1 say "MOVED IN"         
line ++
sele paccount
PBarFilter()
do while .not. eof()
   @ line,  1 say str( id, 6, 0 )         
   @ line,  8 say date                    
   sele purchase
   seek paccount->id
   do while id == paccount->id .and. ( !eof() )
      sele master
      seek purchase->item_id
      @ line, 19 say proper( desc )         
      sele accounts
      seek paccount->supplier
      @ line, 52 say proper( subs( account, 1, 17 ) )         
      sele purchase
      @ line, 72 say str( qty, 5, 0 )         
      line ++
      sele purchase
      skip
   enddo
   sele paccount
   skip
   IncrPBar()
enddo
line ++
line ++
@ line,  1 say "   "         
set device to screen
set printer off
set printer to
close all
HidePBar()
fileread( 1, 0, 23, 79, RepPath + 'TRN_REP.TXT', 'Transfer Report' )
return .t.
//--------------------------------------------------------
function sup_costrep

local line   := 1
local nBNo
local lTot1  := 0.00
local lTot2  := 0.00
local lStart

JInitRep( "Cost Report", .F., { || dgItemMas() }, 'Preparing report...', 79 )
use batches new index BAT_2
use master new index MAS_1,MAS_2
jDGSetPBar( reccount() )
set order to 2
go top
jNextLine()
jAddData( 1, padc( 'Cost Report', 79 ) )
jNextLine()
jAddData( 1, replicate( '-', 79 ) )
jNextLine()
jAddData( 1, 'Item' )
jAddData( 49, 'Stock' )
jAddData( 59, 'Cost' )
jAddData( 70, 'Total' )
jNextLine()
jAddData( 1, replicate( '-', 79 ) )
jNextLine()
go top
do while .not. eof()
   if bal > 0
      jAddData( 1, subs( rtrim( ltrim( desc ) ) + '  ' + rtrim( ltrim( details ) ), 1, 45 ), ;
                str( id, 6, 0 ) )
      nBNo := 0
      sele batches
      seek str( master->id, 4, 0 )
      lStart := .t.
      do while master->id == batches->id
         if !lStart
           if begin+rcvd-sold > 0
              jNextLine()
           endif
         endif
         if ( begin + rcvd - sold ) > 0
            if nBNo != 0
               jAddData( 5, "** Batch" )
            endif
            jAddData( 48, str( begin + rcvd - sold, 5, 0 ) )
            jAddData( 54, str( cost, 10, 2 ) )
            lTot2 += cost * ( begin + rcvd - sold )
            lStart := .f.
            nBNo ++
         endif
         skip
      enddo
      sele master
      jAddData( 67, str( lTot2, 10, 2 ) )
      lTot1 += lTot2
      lTot2 := 0.00
      jNextLine()
   endif
   select master
   skip
   jDGIncrPBar()
enddo

jAddData( 68, repli( '-', 9 ) )
jNextLine()
jAddData( 66, str( lTot1, 11, 2 ) )

jNextLine()
jAddData( 1, "   " )
jNextLine()
close all
jEndReport()

return .t.
//-----------------------------------------------------------------
function stby_rep

local line  := 1
local lTot1 := 0.00
local lTot2 := 0.00
ShowPBar( 'Preparing standby report... Moved Out' )
set device to printer
set printer on
set printer to ( RepPath + 'STN_REP.TXT' )
SayTitles( 79, @line )
line ++
@ line,  1 say padc( 'Standby Report', 79 )         
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
@ line,  2 say 'Srl#'          
@ line,  8 say 'Date'          
@ line, 19 say 'Item'          
@ line, 59 say 'Party'         
@ line, 70 say 'Qty'           
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
use saccount new index sac_1
set filte to other = 'Standby'
go top
use paccount new index pac_1
set filte to bill = 'Standby'
go top
use purchase new index prch_1
use sales new index sale_1
use master new index mas_1
use accounts new index acc_1
@ line,  1 say "MOVED OUT"         
line ++
sele saccount
do while .not. eof()
   @ line,  1 say str( id, 6, 0 )         
   @ line,  8 say date                    
   sele sales
   seek saccount->id
   do while id == saccount->id .and. ( !eof() )
      sele master
      seek sales->item_id
      @ line, 19 say proper( desc )         
      sele accounts
      seek saccount->customer
      @ line, 52 say proper( subs( account, 1, 17 ) )         
      sele sales
      @ line, 72 say str( qty, 5, 0 )         
      line ++
      sele sales
      skip
   enddo
   sele saccount
   skip
   IncrPBar()
enddo

HidePBar()

ShowPBar( "Preparing standby report... Moved In" )
@ line,  1 say "MOVED IN"         
line ++
sele paccount
do while .not. eof()
   @ line,  1 say str( id, 6, 0 )         
   @ line,  8 say date                    
   sele purchase
   seek paccount->id
   do while id == paccount->id .and. ( !eof() )
      sele master
      seek purchase->item_id
      @ line, 19 say proper( desc )         
      sele accounts
      seek paccount->supplier
      @ line, 52 say proper( subs( account, 1, 17 ) )         
      sele purchase
      @ line, 72 say str( qty, 5, 0 )         
      line ++
      sele purchase
      skip
   enddo
   sele paccount
   skip
   IncrPBar()
enddo
line ++
line ++
@ line,  1 say "   "         
set device to screen
set printer off
set printer to
close all
HidePBar()
fileread( 1, 0, 23, 79, RepPath + 'STN_REP.TXT', 'Standby Report' )
return .t.
//--------------------------------------------------------
function allitems

local line  := 1
local lTot1 := 0.00
local lTot2 := 0.00
ShowPBar()
set device to printer
set printer on
set printer to ( RepPath + 'ITM_REP.TXT' )
use master new index MAS_1,MAS_2
set order to 2
go top
SayTitles( 79, @line )
line ++
@ line,  1 say padc( 'Items Master', 79 )         
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
@ line,  1 say 'Item'           
@ line, 49 say 'Stock'          
@ line, 59 say 'Cost'           
@ line, 70 say 'Retail'         
line ++
@ line,  1 say replicate( '-', 79 )         
line ++
go top
do while .not. eof()
   @ line,  1 say subs( rtrim( ltrim( desc ) ) + '  ' + rtrim( ltrim( details ) ), 1, 45 )         
   @ line, 48 say str( bal, 6, 0 )                                                                 
   @ line, 54 say str( cost, 10, 2 )                                                               
   @ line, 67 say str( retail, 10, 2 )                                                             
   lTot1 += cost
   line ++
   skip
   IncrPBar()
enddo
line ++
@ line,  1 say "   "         
set device to screen
set printer off
set printer to
close all
HidePBar()
fileread( 1, 0, 23, 79, RepPath + 'ITM_REP.TXT', 'Master File List' )
return .t.
//-----------------
function ViewBats   // View Batches

local aBatches := {}
local nWidth
local nMasId
local cMasDesc
local nTop
local nHeight
if select ( "MASTER" ) = 0
   set key K_F11 to
   jAlert( 'Items master not active. Cannot view Batch Details' )
   set key K_F11 to ViewBats()
   return .f.
endif

nMasId   := master->id
cMasDesc := master->desc

jSaveEnv()
close all
aadd( aBatches, padc( subs( rtrim( ltrim( upper( cMasDesc ) ) ), 1, 27 ), 27 ) )
aadd( aBatches, repli( '-', 27 ) )
aadd( aBatches, padc( 'Stock' + space( 2 ) + '   Cost', 27 ) )
use batches new index BAT_2
seek str( nMasId, 4, 0 )
do while nMasId == batches->id .and. ( !eof() )
   aadd( aBatches, padc( str( begin + rcvd - sold, 4, 0 ) + space( 2 ) + str( batches->cost, 8, 2 ), 27 ) )
   skip
enddo
aadd( aBatches, "" )
close all
setcolor( scrcolor() )
@ 13, 48 say padc( 'View Batch Info.', 29 )         

setcolor( msgColor() )

// Pressing F5 creates a new aPick func.
// It uses static variables which is changed for use with POPMENU
// So, when the control returns, the memory contains info about POPMENU
// not about this one. So it conflicts and produces an ARRAY BOUND ERROR

set key K_F11 to
set key K_F5 to
aPick( 14, 48, 22, 76, aBatches, msgColor(), msgColor(), msgColor() )
set key K_F5 to pop_menu()
set key K_F11 to ViewBats()
jRestEnv()
return .t.
//------------------
function dgItemMas

local nAId := alltrim( jRefdata() )
if empty( nAId ) .or. val( nAId ) = 0
   return .f.
else
   jSaveEnv()
   close all
   item_rep( val( nAId ) )
   close all
   jRestEnv()
endif
return .t.
//----------------------
function dgItemRep

local nAId := alltrim( jRefdata() )
if empty( nAId ) .or. val( subs( nAId, 2 ) ) = 0
   return .f.
else
   jSaveEnv()
   close all
   altd( .t. )
   if subs( nAId, 1, 1 ) = 'P'          // Purchase
      keyboard ( subs( nAid, 2, 7 ) + chr( K_ENTER ) )
      Purchase( .T. )
   elseif subs( nAId, 1, 1 ) = 'S'      // Sales
      keyboard ( subs( nAid, 2, 7 ) + chr( K_ENTER ) )
      Sales( .T. )
   endif
   close all
   jRestEnv()
endif
return .t.
//----------------------

*+ EOF: MAS_REP.PRG
