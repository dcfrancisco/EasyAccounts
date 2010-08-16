#include "std.ch"

#define R_ALL       1
#define WOTRANSFER  2
#define WOGENERALSALESTRANSFER  3
#define GENERALSALESONLY  4
#define TRANSFERONLY  5

function sale_rep


local line      := 0
local nSrl      := 0
local nTot      := 0.00
local nMonthTot := 0.00
local nInclude  := 0

private d1        := date()
private d2        := date()
// These are referred to in the FILTER condition.

if ! ReqInv()
  jAlert('Sorry, this company is not configured for inventory control..')
  return .f.
endif

popread(.f., "þ Sales Report þ From :", @d1, '@D',;
             "                   To :", @d2, '@D' )

if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
   close all
   return .f.
endif

opendatas()

nInclude := menu_v( "Include Transactions:",;
                         "All",;
                         "Without Transfer",;
                         "Without General Sales/Transfer",;
                         "General Sales Only",;
                         "Transfer Only"  )
if nInclude = 0
  close all
  return .f.
endif

ShowPBar( 'Preparing sales report...' )
sele saccount
if nInclude=R_ALL .or. nInclude=GENERALSALESONLY
   set filter to date >= d1 .and. date <= d2
elseif nInclude=WOTRANSFER .or. nInclude=WOGENERALSALESTRANSFER
   set filter to (date >= d1 .and. date <= d2) .AND. upper(OTHER) != 'TRANSFER'
elseif nInclude=TRANSFERONLY
   set filter to (date >= d1 .and. date <= d2) .AND. upper(OTHER) == 'TRANSFER'
endif

go top

PBarFilter()        // Counts the record for progress bar. ( it is a filter)
// Its actually a time waste. But i want to implement progress bar.
// So it doesnt matter (for me) whether the report becomes slow or not.

set device to printer
set printer on
set printer to ( RepPath + 'SALE_DET.TXT' )

SayTitles( 49, @Line )
line ++

if !( d1 == d2 )
   @ line,  0 say padc( 'Sales Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 49 )         
else
   @ line,  0 say padc( 'Sales Details of ' + dtoc( d1 ), 49 )         
endif
line ++
if nInclude=GENERALSALESONLY
   @ line, 0 say padc('General Sales',49 )
elseif nInclude=WOTRANSFER 
   @ line, 0 say padc('All Sale Bills excluding Transfers',49 )
elseif nInclude=WOGENERALSALESTRANSFER
   @ line, 0 say padc('Sale Bills excluding Transfers and General Sales',49 )
elseif nInclude=TRANSFERONLY
   @ line, 0 say padc('Transfer Bills only',49 )
endif
line++
@ line,  0 say repli( '-', 49 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 34 say 'Price'                    
@ line, 44 say 'Total'                    
line ++
@ line,  0 say repli( '-', 49 )         
line ++
do while .not. eof()
  if (user() != 'ADM') .or. (user() == 'ADM' .and. saccount->id > 0) 
   // no WITHOUT billings..
   nTot := 0.00
   nSrl := 0
   sele accounts
   seek saccount->customer
   sele saccount

   if nInclude==R_ALL .or. nInclude==WOTRANSFER .or. nInclude==TRANSFERONLY .or. ;
     ( nInclude==GENERALSALESONLY .AND. alltrim( upper( accounts->account) ) == 'GENERAL SALES') .or. ;
     nInclude==WOGENERALSALESTRANSFER .and. alltrim( upper( accounts->account) ) != 'GENERAL SALES'

      if !( d1 == d2 )                  // if only one date is sel., then no date is required.
         @ line,  1 say 'Date : ' + dtoc( date )                        
         @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      else
         @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      endif
      sele accounts
      if found()
         if d1 == d2
            @ line, 18 say 'Customer : ' + rtrim( ltrim( proper( account ) ) )         
         else
            @ line, 32 say 'Customer : ' + rtrim( ltrim( proper( account ) ) )         
         endif
      else
         @ line, 32 say 'Customer details absent!'         
      endif
      line ++
      if !empty( rtrim( ltrim( saccount->other )))
         @ line, 01 say upper( saccount->other )
         line ++
      endif
      sele sales
      seek saccount->id
      do while id == saccount->id .and. ( !eof() )
         sele master
         seek sales->item_id
         if found()
            @ line,  1 say subs( proper( desc ), 1, 25 )         
         endif
         @ line, 28 say str( sales->qty, 3, 0 )         

         if sales->price > 0
            @ line, 33 say str( sales->price, 6, 0 )                      
            @ line, 42 say str( sales->price * sales->qty, 7, 0 )         
         endif

         line ++
         nTot += sales->price * sales->qty
         if ( sales->Price * sales->qty ) > 0
            nSrl ++
         endif
         sele sales
         skip
      enddo
      if nSrl > 1 .and. ( saccount->discount = 0 )
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
      elseif ( nSrl > 1 .or. saccount->discount != 0 )
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
         if saccount->discount > 0
            @ line, 20 say '  Discount :'                          
            @ line, 42 say str( saccount->discount, 7, 0 )         
            line ++
            @ line, 20 say 'Net Amount :'                                 
            @ line, 42 say str( nTot - saccount->discount, 7, 0 )         
            line ++
            nTot -= saccount->discount
         endif
      endif

      nMonthTot += nTot
      line ++
   endif
  endif
   select saccount
   IncrPBar()
   skip
enddo

if sp_visor()
   @ line, 44 say repli( '-', 5 )         
   line ++
   @ line, 24 say 'Grand Total --> '             
   @ line, 42 say str( nMonthTot, 7, 0 )         
endif

line ++
line ++
line ++
@ line,  1 say " "         
close all
set device to screen
set printer off
set printer to
HidePBar()
fileread( 04, 08, 19, 65, RepPath + 'SALE_DET.TXT', 'Sales Details' )
return .t.
//----------------
static function opendatas

use accounts new index ACC_1,ACC_2
set order to 1
go top
use master new index MAS_1,MAS_2
set order to 1
use saccount new index SAC_1,SAC_2,SAC_3
set order to 1
use sales new index SALE_1,SALE_2
set order to 1
return .t.
//----------------------
function syssalerep

// This report DOES 'NOT' involve transfers..
// This is done in the SET FILTER CONDITION.
local line       := 0
local nMin       := 12000
local nSrl       := 0
local nTot       := 0.00
local nMonthTot  := 0.00
local nSystemsNo := 0
opendatas()

private d1         := date()
private d2         := date()
// are referred to in the FIlter..

if ! ReqInv()
  jAlert('Sorry, this company is not configured for inventory control..')
  return .f.
endif

setcolor( scrcolor() )
@ 09, 22 say padc( 'SYSTEM SALE REPORT', 31 )
setcolor( boxcolor() )
@ 10, 22 clear to 13, 52
@ 10, 22 to 13, 52
@ 11, 24 say 'From : ' get d1        
read
d2 := d1
@ 12, 24 say 'To   : ' get d2        
read
if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
   close all
   return .f.
endif

ShowPBar( 'Preparing system sales report...' )
sele saccount
set filter to (date >= d1 .and. date <= d2) .AND. upper(OTHER) != 'TRANSFER'
// No transfer should come up in the system sales reports..
go top

pBarFilter()

set device to printer
set printer on
set printer to ( RepPath + 'SYSSALE.TXT' )

SayTitles( 49, @Line )
line ++

if !( d1 == d2 )
   @ line,  0 say padc( 'System Sales Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 49 )         
else
   @ line,  0 say padc( 'System Sales Details of ' + dtoc( d1 ), 49 )         
endif
line ++
@ line,  0 say repli( '-', 49 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 34 say 'Price'                    
@ line, 44 say 'Total'                    
line ++
@ line,  0 say repli( '-', 49 )         
line ++
do while .not. eof()
   if IsSystem .AND. ID > 0
      nSystemsNo ++
      nTot := 0.00
      nSrl := 0
      if !( d1 == d2 )                  // if only one date is sel., then no date is required.
         @ line,  1 say 'No.: ' + rtrim( ltrim( str( nSystemsNo ) ) ) + ' Srl : ' + rtrim( ltrim( str( saccount->id ) ) ) + " Date : " + dtoc( date )         
         @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )                                                                                               
      else
         @ line,  1 say 'No.: ' + rtrim( ltrim( str( nSystemsNo ) ) ) + ' Srl : ' + rtrim( ltrim( str( saccount->id ) ) ) + " Bill : " + rtrim( ltrim( str( id ) ) )         
      endif
      line ++
      sele accounts
      seek saccount->customer
      if found()
         @ line,  1 say 'Customer : ' + rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", ", "" ) + rtrim( ltrim( proper( details ) ) )         
      else
         @ line, 30 say 'Customer details absent!'         
      endif
      line ++
      if !empty( rtrim( ltrim( saccount->other ) ) )
         @ line, 01 say upper( saccount->other )         
         line ++
      endif
      sele sales
      seek saccount->id
      do while id == saccount->id .and. ( !eof() )
         sele master
         seek sales->item_id
         if found()
            @ line,  1 say subs( proper( desc ), 1, 25 )         
         endif
         @ line, 28 say str( sales->qty, 3, 0 )         

         if sales->price > 0
            @ line, 33 say str( sales->price, 6, 0 )                      
            @ line, 42 say str( sales->price * sales->qty, 7, 0 )         
         endif

         line ++
         nTot += sales->price * sales->qty
         if ( sales->Price * sales->qty ) > 0
            nSrl ++
         endif
         sele sales
         skip
      enddo

      if nSrl > 1 .and. ( saccount->discount = 0 )
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
      elseif ( nSrl > 1 .or. saccount->discount != 0 )
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
         if saccount->discount > 0
            @ line, 20 say '  Discount :'                          
            @ line, 42 say str( saccount->discount, 7, 0 )         
            line ++
            @ line, 20 say 'Net Amount :'                                 
            @ line, 42 say str( nTot - saccount->discount, 7, 0 )         
            line ++
            nTot -= saccount->discount
         endif
      endif

      nMonthTot += nTot
      line ++
   endif
   select saccount
   skip
   IncrPBar()
enddo

if sp_visor()
   if nSystemsNo > 1
      @ line, 02 say "Total " + rtrim( ltrim( str( nSystemsNo ) ) ) + " systems sold."         
   endif
   @ line, 44 say repli( '-', 5 )         
   line ++
   @ line, 24 say 'Grand Total --> '             
   @ line, 42 say str( nMonthTot, 7, 0 )         
endif

line ++
line ++
line ++
@ line,  1 say " "         
close all
HidePBar()

set device to screen
set printer off
set printer to
fileread( 04, 08, 19, 65, RepPath + 'SYSSALE.TXT', 'Systemwise Sale Report' )
return .t.
//============================
function amountwisesalerep

local line      := 0
local nMin      := 12000
local nSrl      := 0
local nTot      := 0.00
local nMonthTot := 0.00, nInclude

private d1        := date()
private d2        := date()
// These are referred to in the FILTER condition.

if ! ReqInv()
  jAlert('Sorry, this company is not configured for inventory control..')
  return .f.
endif

popread(.f., "þ Sales Report þ From :", @d1, '@D',;
             "                   To :", @d2, '@D' )

if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
   close all
   return .f.
endif

popread(.t., "þ Sales Report þ Minimum Amount Level :",@nMin,'9999999')
if nMin = 0
   close all
   return .f.
endif

nInclude := menu_v( "Include Transactions:",;
                         "All",;
                         "Without Transfer",;
                         "Without General Sales/Transfer",;
                         "General Sales Only",;
                         "Transfer Only"  )
if nInclude = 0
  close all
  return .f.
endif

opendatas()

sele saccount

if nInclude=R_ALL .or. nInclude=GENERALSALESONLY
   set filter to date >= d1 .and. date <= d2
elseif nInclude=WOTRANSFER .or. nInclude=WOGENERALSALESTRANSFER
   set filter to (date >= d1 .and. date <= d2) .AND. upper(OTHER) != 'TRANSFER'
elseif nInclude=TRANSFERONLY
   set filter to (date >= d1 .and. date <= d2) .AND. upper(OTHER) == 'TRANSFER'
endif

go top

ShowPBar( 'Preparing amountwise sales report...' )
PBarFilter()
set device to printer
set printer on
set printer to ( RepPath + 'AMNTSALE.TXT' )
SayTitles( 49, @Line )
line ++
if !( d1 == d2 )
   @ line,  0 say padc( 'Sales Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 49 )         
else
   @ line,  0 say padc( 'Sales Details of ' + dtoc( d1 ), 49 )         
endif
line ++
@ line,  0 say padc( 'Invoices starting from Rs.' + rtrim( ltrim( str( nMin ) ) ) + ' onwards', 49 )         
line ++
if nInclude=GENERALSALESONLY
   @ line, 0 say padc('General Sales Only',49 )
elseif nInclude=WOTRANSFER 
   @ line, 0 say padc('Sale Bills excluding Transfers',49 )
elseif nInclude=WOGENERALSALESTRANSFER
   @ line, 0 say padc('Sale Bills excluding Transfers and General Sales',49 )
elseif nInclude=TRANSFERONLY
   @ line, 0 say padc('Transfer Bills only',49 )
endif
line ++
@ line,  0 say repli( '-', 49 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 34 say 'Price'                    
@ line, 44 say 'Total'                    
line ++
@ line,  0 say repli( '-', 49 )         
line ++
do while .not. eof()
   if saccount->total >= nMin
      nTot := 0.00
      nSrl := 0
      if !( d1 == d2 )                  // if only one date is sel., then no date is required.
         @ line,  1 say 'Date : ' + dtoc( date )                        
         @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      else
         @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      endif
      sele accounts
      seek saccount->customer
      if found()
         if d1 == d2
            @ line, 18 say 'Customer : ' + rtrim( ltrim( proper( account ) ) )         
         else
            @ line, 32 say 'Customer : ' + rtrim( ltrim( proper( account ) ) )         
         endif
      else
         @ line, 32 say 'Customer details absent!'         
      endif
      line ++
      if !empty( rtrim( ltrim( saccount->other ) ) )
         @ line, 01 say upper( saccount->other )         
         line ++
      endif
      sele sales
      seek saccount->id
      do while id == saccount->id .and. ( !eof() )
         sele master
         seek sales->item_id
         if found()
            @ line,  1 say subs( proper( desc ), 1, 25 )         
         endif
         @ line, 28 say str( sales->qty, 3, 0 )         

         if sales->price > 0
            @ line, 33 say str( sales->price, 6, 0 )                      
            @ line, 42 say str( sales->price * sales->qty, 7, 0 )         
         endif

         line ++
         nTot += sales->price * sales->qty
         if ( sales->Price * sales->qty ) > 0
            nSrl ++
         endif
         sele sales
         skip
      enddo
      if nSrl > 1
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
      endif
      nMonthTot += nTot
      line ++
   endif
   select saccount
   skip
   IncrPBar()
enddo

if sp_visor()
   @ line, 44 say repli( '-', 5 )         
   line ++
   @ line, 24 say 'Grand Total --> '             
   @ line, 42 say str( nMonthTot, 7, 0 )         
endif

line ++
line ++
line ++
@ line,  1 say " "         
close all
set device to screen
set printer off
set printer to
HidePBar()
fileread( 04, 08, 19, 65, RepPath + 'AMNTSALE.TXT', 'Sales Details by Bill Amount' )
return .t.

*+ EOF: SALE_REP.PRG
