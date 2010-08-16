#include "std.ch"

function tellprofit

local nPrch   := 0.00
local nSale   := 0.00
local nProfit := 0.00
local dS      := date()
local dE      := date()
local nDTotal
local nCTotal
local nD
local nC

popread( .f., 'From   : ', @dS, '@D', ;
         'To     : ', @dE, '@D' )

use master new index MAS_1,MAS_2
use sales new index SALE_1,SALE_2
use purchase new index PRCH_1,PRCH_2

use saccount new index SAC_1,SAC_2
set filter to ( date >= dS .and. date <= dE ) .and. ordoth()
go top
use paccount new index PAC_1,PAC_2
set filter to ( date >= dS .and. date <= dE ) .and. ordbill()
go top
do while .not. eof()

   select purchase
   seek paccount->id
   do while id == paccount->id .and. ( !eof() )
      nPrch += cost * qty
      skip
   enddo
   sele paccount
   skip
enddo

sele saccount
do while .not. eof()
   sele sales
   seek saccount->id
   do while id == saccount->id .and. ( !eof() )
      nSale   += price * qty
      nProfit += ( price - cost ) * qty
      skip
   enddo
   sele saccount
   skip
enddo

close all
msg( "  P&L Report - " + dtoc( dS ) + ' to ' + dtoc( dE ), ;
     '', ;
     '  Total Purchase Made  : ' + str( nPrch, 10, 2 ), ;
     '  Sales Turnover       : ' + str( nSale, 10, 2 ), ;
     '  Sales Profit         : ' + str( nProfit, 10, 2 ), ;
     '  ---------------------------------' )

return .t.
//--------------------
function ordbill

local x
if proper( subs( bill, 1, 7 ) ) = 'Standby' .or. proper( subs( bill, 1, 8 ) ) = 'Transfer' ;
           .or. proper( subs( bill, 1, 7 ) ) = 'Replace'
   x := .f.
else
   x := .t.
endif
return x
//---------
function ordoth

local x
if proper( subs( other, 1, 7 ) ) = 'Standby' .or. proper( subs( other, 1, 8 ) ) = 'Transfer' ;
           .or. proper( subs( other, 1, 7 ) ) = 'Replace'
   x := .f.
else
   x := .t.
endif
return x
//--------------------------------------

*+ EOF: PROFITS.PRG
