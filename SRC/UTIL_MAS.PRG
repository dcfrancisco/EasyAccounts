#include "std.ch"
//===================================================
#define NUMBER_OF_USERS 1

#define WARRANTY_AC 3
#define AMC_AC 4
#define ASC_AC 5

function UTIL_MAS( lAsk )

if lAsk .and. jAlert( 'DATA MAINTENANCE;; This Process may take some time.; Continue ?', ;
           { "Yes", "No" } ) == 1
   clearall()
   tone( 210, 2 )
   tone( 304, 1 )
   tone( 359, 3 )
   jAlert( "Data maintenance complete..!" )
elseif !lAsk
   clearall()
endif
return .t.
//-----------------------------------------------------
static function clearall

if LogInfo() [NUMBER_OF_USERS] = 1
   indexfiles()

   ontask( 'Clearing entries... DAYBOOK' )
   eUse( "DAYBOOK" )
   delete all for auto
   ontask( 'Clearing entries... CASHBOOK' )
   eUse( "CASHBOOK" )
   delete all for auto

   if ReqInv()
      ontask( 'Setting data structure... SALES' )
      eUse( "SACCOUNT" )
      replace all account with .f.
      ontask( 'Setting data structure... PURCHASE' )
      eUse( "PACCOUNT" )
      replace all account with .f.
      close all
      plswait( .f. )
      set exclusive on
      jLMsg( .f. )
      plswait( .t., 'Clearing sales account...' )
      u_clearsacc()
      plswait( .t., 'Rewriting stock balances...' )
      u_clearstock()
      plswait( .t., 'Posting sales details...' )
      u_saleaccup()
      plswait( .t., 'Updating Purchase Transactions...' )
      u_purchaccup()
      plswait( .t., 'Clearing off temporary entries...' )
      u_deldots()
   endif

   if file( 'SERVICE.DBF' )
      plswait( .t., 'Updating entries from Service..' )
      u_updServEntry()
   endif

   set exclusive on
   plswait( .t., 'Optimizing daybook...' )
   close all
   use daybook
   pack
   plswait( .t., 'Optimizing cashbook...' )
   use cashbook
   pack
   use
   set exclusive OFF
   jLMsg( .t. )

   indexfiles()
   set exclusive OFF
endif
return .t.
//--------------------------------------------
static function u_clearstock

// Function does two things
// Counts total sold and rcvd and writes to MASTER
// On the above loop, it also rewrites the BATCH positions.

local nPurch
local nTransfer
local nSale
ontask( 'Rewriting stock balances.... MASTER & BATCHES' )
use batches new
delete all for (begin==0)
pack
replace all rcvd with 0,sold with 0

ib( 'str(id,4,0)+str(cost,9,2)', 'BAT_1' )
ib( 'str(id,4,0)', 'BAT_2' )
use
use batches new index BAT_1,BAT_2
use paccount new index PAC_1
use purchase new index PRCH_2
use sales new index SALE_2
use master new index MAS_1
do while .not. eof()

   nPurch := 0
   nSale  := 0
   sele purchase
   go top
   seek master->id
   do while master->id == purchase->ITEM_id .and. !eof()
      sele paccount
      seek purchase->id
      sele batches
      seek str( master->id, 4, 0 ) + str( purchase->cost, 9, 2 )
      if !found()
         append blank
         field->id   := master->id
         field->rcvd := purchase->qty
         field->cost := purchase->cost
         sele master
         field->cost := purchase->cost
      else
         JRLock()
         field->rcvd := rcvd + purchase->qty
         jRUnLock()
      endif
      nPurch += purchase->qty
      sele purchase
      skip
   enddo
   sele sales
   go top
   seek master->id
   do while master->id == sales->ITEM_id .and. !eof()
      nSale += qty
      u_UpdBatch( master->id, sales->qty )
      sele sales
      skip
   enddo

   sele master
   field->sold := nSale
   field->rcvd := nPurch
   field->bal  := begin + rcvd - sold
   skip
enddo
ontask()
close all
return nil
//-----------------------------------------------------
static function u_saleaccup

local x := 0
close all
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
use saccount new index SAC_1,SAC_2,SAC_3
set order to 2
go top
do while .not. eof()
   if !account
      if paid > 0
         sele cashbook
         go bott
         x := id + 1
         append blank
         field->id      := x
         field->date    := saccount->date
         field->type    := 'Sales'
         field->inv_id  := saccount->id
         field->amount  := saccount->paid
         field->details := 'Sales Bill : ' + rtrim( ltrim( str( saccount->id ) ) )
         field->account := saccount->customer
         field->action  := 'C'
         field->auto    := .t.
      endif

      sele daybook
      if saccount->total > 0
         go bott
         x := id + 1
         append blank
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
      endif

      sele saccount
      field->account := .t.
   endif
   skip
enddo
close all
return .t.
//-------------------------------------
static function u_purchaccup

local x := 0
close all
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
use paccount new index PAC_1,PAC_2,PAC_3
set order to 2
go top
do while .not. eof()
   if !account
      if paid > 0
         sele cashbook
         go bott
         x := id + 1
         append blank
         field->id      := x
         field->date    := paccount->date
         field->type    := 'Purchase'
         field->inv_id  := paccount->id
         field->amount  := paccount->paid
         field->details := 'Payment P/Bill : ' + rtrim( ltrim( paccount->bill ) ) + ' dtd.'+dtoc(paccount->date)+'  Srl: ' + rtrim( ltrim( str( paccount->id ) ) )
         field->account := paccount->Supplier
         field->action  := 'D'
         field->auto    := .t.
      endif

      sele daybook
      if paccount->total > 0
         go bott
         x := id + 1
         append blank
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
      endif
      sele paccount
      field->account := .t.
   endif
   skip
enddo
close all
return .t.
//-------------------------------------
function u_deldots

close all
use master
set filter to rtrim( ltrim( desc ) ) == '.' .and. ( begin + rcvd + sold + bal ) == 0
delete all
set filter to
go top
pack
close all
//----------------------------------
static function u_clearsacc

local x := 0
close all
use saccount new index SAC_1
go top
do while .not. eof()
   x := id
   skip
   do while x = id .and. ( !eof() )
      dele
      skip
   enddo
enddo
close all
return .t.
//-------------------------------------
static function U_UpdBatch( nId, nQty )

// This function is designed for handling sale trans. which spans
// multiple batches within one transaction itself..

local nRemain  := nQty
local nTotCost := 0.00
local nCount   := 0

// Average can be found out only by (adding ALL the costs) divide number of costs.
// I have experimentally proved that doing nAvgCost := (nAvgCost+cost)/2 within the
// loop wont work.

select batches
set order to 2
seek str( nId, 4, 0 )
if found()
   do while id == nId .and. ( !eof() )
      if ( begin + rcvd - sold ) >= nRemain                 // Have enough to hold whole of nRemain?
         nTotCost += ( cost * nRemain )
         nCount   += nRemain
         jRLock()
         field->sold := sold + nRemain
         jRUnLock()
         nRemain := 0
         exit
      elseif ( begin + rcvd - sold ) > 0                    // We know it is not as much as nRemain
         nTotCost += ( cost * ( begin + rcvd - sold ) )     // then does it,at least, have some Stock?
         nCount   += begin + rcvd - sold
         nRemain  -= ( begin + rcvd - sold )
         jRLock()
         field->sold := ( begin + rcvd )                    //==> sold+(begin+rcvd-sold). so bal will be 0
         jRUnLock()
      endif
      skip
   enddo
   if nRemain > 0
      jAlert( "ERROR : " + rtrim( ltrim( subs( master->desc, 1, 40 ) ) ) + ';; Stock not available for batch processing' )
   endif
else
   jAlert( "ERROR : " + rtrim( ltrim( subs( master->desc, 1, 40 ) ) ) + ';; Stock not available for batch processing' )
endif
select batches
set order to 1
return ( nTotCost / nCount )            // The Avg. cost
//=============================================================
static function ib( cKey, cFile )

indexbar( cFile, cKey )
return .t.
//------------------------------------------------------------
static function u_UpdServEntry

local nId

use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use service new
go top
do while .not. eof()
if service->amount > 0 .and. ( !empty( service->A_Date ) )
   // If it is chargeable and also the service has been attended to...
   sele daybook
   set order to 1
   go bott
   nId := id + 1

   sele daybook
   append blank
   field->id   := nId
   field->type := 'Service'
   field->date := service->A_DATE

   if service->type == 'PA'             // Paid Service - the customer has to pay it
      field->account := service->CUSTOMER
      field->details := "S/C : " + alltrim( str( service->id ) ) + " (" + alltrim( FindHead( service->engineer ) ) + ")"
   elseif service->type == 'WA'         // Warranty service - reduce from the Warranty cash deposit
      field->account := WARRANTY_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   elseif service->type == 'AM'         // AMC
      field->account := AMC_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   elseif service->type == 'AS'         // ASC
      field->account := ASC_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   endif

   field->acc_sub := service->acc_sub
   field->amount := service->amount
   field->inv_id := service->id
   field->action := 'D'
   field->auto   := .t.
   field->user   := '_S_'

   append blank
   field->id      := nId + 1
   field->type    := 'Service'
   field->date    := service->A_DATE
   field->account := service->ENGINEER
   field->amount  := service->amount
   field->inv_id  := service->id
   field->action  := 'C'

   if service->type == 'PA'             // Paid Service
      field->details := "Cash [" + alltrim( str( service->id ) ) + "] " + alltrim( FindHead( service->customer ) )
   elseif service->type == 'WA'
      field->details := "Warranty [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   elseif service->type == 'AM'
      field->details := "AMC [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   elseif service->type == 'AS'
      field->details := "ASC [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   endif

   field->auto := .t.
   field->user := '_S_'

   jRUnLock()

   sele service
   jRLock()
   field->dbk_id := nId
   jRUnLock()
   commit
endif
skip
enddo
commit
close all
return .t.

*+ EOF: UTIL_MAS.PRG
