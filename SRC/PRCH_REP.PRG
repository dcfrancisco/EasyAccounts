#include "std.ch"

function purch_rep

local line      := 0
local nSrl      := 0
local nTot      := 0.00
local nMonthTot := 0.00
opendatas()

private d1        := date()
private d2        := date()

popread(.f., "þ Purchase Report þ From :", @d1, '@D',;
             "                      To :", @d2, '@D' )

if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
   close all
   return .f.
endif

sele paccount
set filter to date >= d1 .and. date <= d2
go top
set device to printer
set printer on
set printer to (RepPath+'prch_det.TXT')
SayTitles( 49, @line )
line ++
if !( d1 == d2 )
   @ line,  0 say padc( 'Purchase Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 49 )         
else
   @ line,  0 say padc( 'Purchase Details of ' + dtoc( d1 ), 49 )         
endif
line ++
@ line,  0 say repli( '-', 49 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 34 say 'Cost'                     
@ line, 44 say 'Total'                    
line ++
@ line,  0 say repli( '-', 49 )         
line ++
do while .not. eof()
  if (user() != 'ADM') .or. (user() == 'ADM' .and. paccount->id > 0)
   // NO WITHOUT PURCHASE SHOULD BE SHOWN FOR USER-ADM
   nTot := 0.00
   nSrl := 0
   if !( d1 == d2 )                     // if only one date is sel., then no date is required.
      @ line,  1 say 'Date : ' + dtoc( date )                        
      @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
   else
      @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
   endif
   sele accounts
   seek paccount->supplier
   if found()
      if d1 == d2
         @ line, 16 say 'Supplier : ' + rtrim( ltrim( proper( account ) ) )         
      else
         @ line, 30 say 'Supplier : ' + rtrim( ltrim( proper( account ) ) )         
      endif
   else
      @ line, 30 say 'Supplier details absent!'         
   endif
   line ++
   if !empty( rtrim( ltrim( paccount->bill ) ) )
      @ line, 01 say upper( paccount->bill )         
      line ++
   endif
   sele purchase
   seek paccount->id
   do while id == paccount->id .and. ( !eof() )
      sele master
      seek purchase->item_id
      if found()
         @ line,  1 say subs( proper( desc ), 1, 25 )         
      endif
      @ line, 28 say str( purchase->qty, 3, 0 )         

      if purchase->cost > 0
         @ line, 33 say str( purchase->cost, 6, 0 )                         
         @ line, 42 say str( purchase->cost * purchase->qty, 7, 0 )         
      endif

      line ++
      nTot += purchase->cost * purchase->qty
      if ( purchase->cost * purchase->qty ) > 0
         nSrl ++
      endif
      sele purchase
      skip
   enddo
   nMonthTot += nTot
   if nSrl > 1
      @ line, 44 say repli( '-', 5 )         
      line ++
      @ line, 42 say str( nTot, 7, 0 )         
      line ++
   endif
   line ++
  endif
   select paccount
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
fileread( 04, 08, 19, 65, RepPath+'prch_det.TXT', 'Purchase Details' )
return .t.
//----------------
static function opendatas

use accounts new index ACC_1,ACC_2
set order to 1
go top
use master new index MAS_1,MAS_2
set order to 1
use paccount new index PAC_1,PAC_2,PAC_3
set order to 1
use purchase new index PRCH_1,PRCH_2
set order to 1
return .t.
//--------------------
function prch_party

local line      := 0
local nSrl      := 0, call := ' '
local nSupplier
local nSupTot   := 0.00
local nTot      := 0.00
local nMonthTot := 0.00

private d1        := date()
private d2        := date()

opendatas()
setcolor( scrcolor() )
@ 07, 22 say padc( 'PURCHASE REPORT', 47 - 21 )         
setcolor( boxcolor() )
@ 08, 22 clear to 14, 48
@ 08, 22 to 14, 48
@ 09, 23 say padc( 'Party Wise', 22 )               
@ 11, 24 say 'From : '                get d1        
read
d2 := d1
@ 12, 24 say 'To   : ' get d2        
read
if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
   close all
   return .f.
endif
/*
@ 12, 24 say '<A>ll/<P>artywise : ' get call valid call = 'A' .or. call = 'P'
read
if call = 'P'
*/
   accview( .f., .f., .t. )
   nSupplier := id
   sele paccount
   set filter to ( date >= d1 .and. date <= d2 ) .and. ( supplier = accounts->id )
   call := .f.
/*
else
   nSupplier := 0
   sele paccount
   set order to 3
   set filter to ( date >= d1 .and. date <= d2 )
   call := .t.
endif
*/

go top
set device to printer
set printer on
set printer to (RepPath+'supplier.TXT')
SayTitles( 49, @line )
line ++
if !( d1 == d2 )
   @ line,  0 say padc( 'Purchase Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 49 )         
else
   @ line,  0 say padc( 'Purchase Details of ' + dtoc( d1 ), 49 )         
endif
line ++
if !call
   @ line,  0 say padc( 'SUPPLIER : ' + rtrim( ltrim( proper( accounts->account ) ) ), 49 )         
else
   @ line,  0 say padc( 'All Suppliers', 49 )         
endif
line ++
@ line,  0 say repli( '-', 49 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 34 say 'Cost'                     
@ line, 44 say 'Total'                    
line ++
@ line,  0 say repli( '-', 49 )         
line ++

if !call
   do while .not. eof()
  if (user() != 'ADM') .or. (user() == 'ADM' .and. paccount->id > 0)
   // NO WITHOUT PURCHASE SHOULD BE SHOWN FOR USER-ADM
      nTot := 0.00
      nSrl := 0
      if !( d1 == d2 )                  // if only one date is sel., then no date is required.
         @ line,  1 say 'Date : ' + dtoc( date )                        
         @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      else
         @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
      endif
      if !empty( rtrim( ltrim( paccount->bill ) ) )
         @ line, 30 say upper( paccount->bill )         
      endif
      line ++
      sele purchase
      seek paccount->id
      do while id == paccount->id .and. ( !eof() )
         sele master
         seek purchase->item_id
         if found()
            @ line,  1 say subs( proper( desc ), 1, 25 )         
         endif
         @ line, 28 say str( purchase->qty, 3, 0 )         

         if purchase->cost > 0
            @ line, 33 say str( purchase->cost, 6, 0 )                         
            @ line, 42 say str( purchase->cost * purchase->qty, 7, 0 )         
         endif

         line ++
         nTot += purchase->cost * purchase->qty
         if ( purchase->cost * purchase->qty ) > 0
            nSrl ++
         endif
         sele purchase
         skip
      enddo
      nMonthTot += nTot
      if nSrl > 1
         @ line, 44 say repli( '-', 5 )         
         line ++
         @ line, 42 say str( nTot, 7, 0 )         
         line ++
      endif
      line ++
     endif
      select paccount
      skip
   enddo
else
   do while .not. eof()
      nSupplier := supplier
      nSupTot   := 0.00
      sele accounts
      seek nSupplier
      sele paccount
      @ line,  0 say 'SUPPLIER : ' + rtrim( ltrim( proper( accounts->account ) ) )         
      line ++
      do while supplier == nSupplier .and. ( !eof() )
  if (user() != 'ADM') .or. (user() == 'ADM' .and. paccount->id > 0)
   // NO WITHOUT PURCHASE SHOULD BE SHOWN FOR USER-ADM
         nTot := 0.00
         nSrl := 0
         if !( d1 == d2 )               // if only one date is sel., then no date is required.
            @ line,  1 say 'Date : ' + dtoc( date )                        
            @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
         else
            @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
         endif
         if !empty( rtrim( ltrim( paccount->bill ) ) )
            @ line, 30 say upper( paccount->bill )         
         endif
         line ++
         sele purchase
         seek paccount->id
         do while id == paccount->id .and. ( !eof() )
            sele master
            seek purchase->item_id
            if found()
               @ line,  1 say subs( proper( desc ), 1, 25 )         
            endif
            @ line, 28 say str( purchase->qty, 3, 0 )         

            if purchase->cost > 0
               @ line, 33 say str( purchase->cost, 6, 0 )                         
               @ line, 42 say str( purchase->cost * purchase->qty, 7, 0 )         
            endif

            line ++
            nTot += purchase->cost * purchase->qty
            if ( purchase->cost * purchase->qty ) > 0
               nSrl ++
            endif
            sele purchase
            skip
         enddo
         nMonthTot += nTot
         nSupTot   += nTot
         if nSrl > 1
            @ line, 44 say repli( '-', 5 )         
            line ++
            @ line, 42 say str( nTot, 7, 0 )         
            line ++
         endif
         line ++
        endif
         select paccount
         skip
      enddo
      @ line, 44 say repli( '-', 5 )         
      line ++
      @ line, 20 say 'Supplier Tot.:'             
      @ line, 42 say str( nSupTot, 7, 0 )         
      line ++
   enddo
endif
@ line, 44 say repli( '-', 5 )         
line ++
@ line, 24 say 'Grand Total --> '             
@ line, 42 say str( nMonthTot, 7, 0 )         
line ++
line ++
line ++
@ line,  1 say " "         
close all
set device to screen
set printer off
set printer to
fileread( 04, 08, 19, 65, RepPath+'supplier.TXT', 'Purchase Details by Supplier' )
return .t.
//----------------

*+ EOF: PRCH_REP.PRG
