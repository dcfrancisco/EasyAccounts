/*
#
#     Account sub-system REPORTS Module
#                        for EasyAccounts v1.5
#
#     Developed and Tested by Jasim A Basheer
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
#    --------------------------------
#          Now, NETWORK ENABLED!!
#           (C) Jasim A Basheer
#    ---------------------------------
#
*/
#include "std.ch"
#include "spbrowse.ch"
#include 'inkey.ch'
#include 'box.ch'

static acFile

//---------------------------------------------------
function listacs( nList, lDisplay, dRDate )

local lAId
local lAAcc
local nRec    := 1
local nTot    := 0.00
local line    := 1
local nRetBal
local _cType

local nDTotal
local nCTotal
local nD
local nC

if sp_visor()
   set key K_F2 to managerlevel()
endif

set key K_F2 to

if lDisplay = NIL
   lDisplay := .t.
endif

if nList = 0 .or. nList = NIL
   return .f.
endif

if dRDate = NIL
   private dTDate := jGetDate( 'Balances As On :' )
else
   private dTDate := dRDate
endif

private dS := _jAcStartDate()
private dE := dTDate

EUse( "acbals" )
zap
use accounts new index ACC_1

use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set filte to date <= dTDate
set order to 5
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5
set filte to date <= dTDate
set order to 4
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6
set filte to date <= dTDate
if alltrim( upper( __aTypes[ nList ] ) ) = 'BANK'
   set order to 5
else
   set order to 4
endif

if lDisplay
   JInitRep( "A/C Balances", .t., { || dgALedger( .t. ) }, 'Preparing report...', 66 )
endif

sele accounts

if lDisplay
   jDGSetPBar( reccount() )
endif

nDTotal := 0.00
do while .not. eof()
   if alltrim( upper( type ) ) == alltrim( upper( __aTypes[ nList ] ) )
      nD := opbal   // that may be negative if is in the credit column.
      nC := 0.00    // so, same THING, same EFFECT, same WOrds...!

      select cashbook
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD += amount
            elseif action = 'C'
               nC += amount
            endif
            skip
         enddo
      endif

      if accounts->id == 1              // Cash Account
         select cashbook
         go top
         sum all amount to nTemp1 for action = 'D'          // Expense
         go top
         sum all amount to nTemp2 for action = 'C'          // Income
         nD += nTemp2
         nC += nTemp1
      endif

      select bankbook
      set order to 5 // B_ID
      seek accounts->id
      if found()
         do while b_id == accounts->id
            if action = 'C'             // deposit..
               nD += amount
            elseif action = 'D'         // withdrawal..
               nC += amount
            endif
            skip
         enddo
      endif

      select bankbook
      set order to 4 // account_ID
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD += amount
            elseif action = 'C'
               nC += amount
            endif
            skip
         enddo
      endif

      select daybook
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD += amount
            elseif action = 'C'
               nC += amount
            endif
            skip
         enddo
      endif

      if nD - nC != 0
         sele acbals
         appe blank
         field->id      := accounts->id
         field->account := accounts->account
         field->balance := nD - nC
         sele accounts
         jRLock()
         field->balance := nD - nC
         jRUnLock()
      endif
   endif

   sele accounts
   skip
   jDGIncrPBar()

enddo

if !lDisplay
   sele acbals
   sum all balance to nRetBal
   close all
   return nRetBal
endif

nDTotal := 0.00
nCTotal := 0.00
close all
eUse( "acbals" )
indexbar( "acbals", "account" )         // index on account to acbals.ntx
go top
setprc( 0, 0 )

jAddData( 1, padc( "ACCOUNT BALANCES", 66 ) )
jNextLine()
jAddData( 1, padc( "As on " + dtoc( dTDate ), 66 ) )
jNextLine()
jNextLine()
jAddData( 1, padc( Expand( __aTypeDescs[ nList ] ), 66 ) )
jNextLine()
jNextLine()
jAddData( 1, repli( '-', 66 ) )
jNextLine()
jAddData( 1, 'Account' )
jAddData( 45, 'Debit' )
jAddData( 57, 'Credit' )
jNextLine()
jAddData( 1, repli( '-', 66 ) )
jNextLine()
do while .not. eof()
   jAddData( 1, subs( account, 1, 38 ), str( id, 5, 0 ) )
   jAddData( 40, iif( balance > 0, str( balance, 10, 2 ), space( 10 ) ) )
   jAddData( 55, iif( balance < 0, str( abs( balance ), 10, 2 ), space( 10 ) ) )
   jNextLine()
   if balance > 0
      nDTotal += balance
   else
      nCTotal += abs( balance )
   endif
   skip
   if !jGoReport( inkey() )
      close all
      jNextLine()
      jNextLine()
      jAddData( 5, '** Report aborted by user **' )
      jNextLine()
      jNextLine()
      jEndReport()
      return .f.
   endif
enddo
jAddData( 1, subs( account, 1, 38 ) )
jAddData( 40, repli( '-', 10 ) )
jAddData( 55, repli( '-', 10 ) )
jNextLine()
jAddData( 39, str( nDtotal, 11, 2 ) )
jAddData( 54, str( nCTotal, 11, 2 ) )
jNextLine()
jNextLine()
jAddData( 4, "NET BALANCE ==> " )
jAddData( 39, iif( nDTotal - nCTotal > 0, str( nDTotal - nCTotal, 11, 2 ), space( 11 ) ) )
jAddData( 54, iif( nCTotal - nDTotal > 0, str( nCTotal - nDTotal, 11, 2 ), space( 11 ) ) )
jNextLine()
jNextLine()
jNextLine()
jAddData( 1, " " )
close all

if lastkey() != K_ESC
   jEndReport()
endif

return nil
//---------------------
function prdGrpBal( dStart, dEnd, lDisplay, cACGrp )

local nList
local lAId
local lAAcc
local nTot    := 0.00
local line    := 1
local nD
local nC
local nRetBal
local nBank   := 0.00
local nCash   := 0.00
local nDay    := 0.00

local bankTot := 0
local cashTot := 0
local dayTot  := 0
local balTot  := 0

local nChoice
local cScreen := savescreen()

if lDisplay = NIL
   lDisplay := .t.
endif

if dStart == NIL .or. dEnd == NIL

   setcolor( scrcolor() )
   @ 03, 28 say padc( 'Select A/C Group:', 22 )         
   setcolor( boxcolor() )
   nChoice := aPick( 04, 28, 20, 49, __aTypeDescs, msgcolor(), msgcolor(), msgcolor() )

   if nChoice == 0
      return .f.
   endif

   restscreen( 0, 0, 24, 79, cScreen )

   cACGrp := alltrim( __aTypes[ nChoice ] )

   private dS := _jAcStartDate()
   private dE := date()

   popread( .f., 'Starting Date : ', @dS, '@D', ;
            'Ending Date   : ', @dE, '@D' )

   if dS > dE .or. empty( dS )
      jAlert( 'Invalid dates.' )
      return .f.
   endif

else

   private dS := dStart
   private dE := dEnd

   nChoice := ascan( __aTypes, cACGrp )

endif

cScreen := ""

FT_XBOX(,,,, msgcolor(), msgcolor(),, 'Summing up transactions...', 'Please wait...' )

if lDisplay
   JInitRep( "Groupwise Transaction Summary", .f., { || dgALedger( .f., .t. ) }, 'Preparing report...', 66 )
endif

eUse( "ACBALS" )
zap
use accounts new index ACC_1

use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 5
set filter to date >= dS .and. date <= dE
go top
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5
set order to 4
set filter to date >= dS .and. date <= dE
go top
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6
set filter to date >= dS .and. date <= dE
go top

sele accounts

if lDisplay
   jDGSetPBar( reccount() )
endif

do while .not. eof()
   if rtrim( ltrim( type ) ) == cACGrp
      // Why there should be op.bal to come while taking
      // the cash flow out - ie, expense?
      nD := 0.00
      nC := 0.00

      nCash := 0.00
      nBank := 0.00
      nDay  := 0.00

      select cashbook
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD    += amount
               nCash += amount
            elseif action = 'C'
               nC    += amount
               nCash -= amount
            endif
            skip
         enddo
      endif

      if accounts->id == 1              // Cash Account
         select cashbook
         go top
         sum all amount to nTemp1 for action = 'D'          // Expense
         go top
         sum all amount to nTemp2 for action = 'C'          // Income
         nCash += nTemp2
         nCash -= nTemp1

         nD += nTemp2
         nC += nTemp1
      endif

      select bankbook
      set order to 5 // B_ID
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'C'             // Deposit...
               nD    += amount
               nBank += amount
            elseif action = 'D'         // Withdrawal..
               nC    += amount
               nBank -= amount
            endif
            skip
         enddo
      endif

      select bankbook
      set order to 4 // ACCOUNT
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD    += amount
               nBank += amount
            elseif action = 'C'
               nC    += amount
               nBank -= amount
            endif
            skip
         enddo
      endif

      select daybook
      seek accounts->id
      if found()
         do while account == accounts->id
            if action = 'D'
               nD   += amount
               nDay += amount
            elseif action = 'C'
               nC   += amount
               nDay -= amount
            endif
            skip
         enddo
      endif
       if abs(nBank)+abs(nCash)+abs(nDay) > 0
         sele acbals
         appe blank
         field->id      := accounts->id
         field->account := accounts->account
         field->balance := nD - nC
         field->bank    := nBank
         field->cash    := nCash
         field->day     := nDay
       endif
   endif

   sele accounts
   skip
   jDGIncrPBar()
enddo

if !lDisplay
   sele acbals
   sum all balance to nRetBal
   close all
   return nRetBal
endif

close all

if lDisplay

   use acbals
   index on account to acbals
   go top
   line := 1
   jNextLine()
   jAddData( 0, padc( "TRANSACTION SUMMARY", 78 ) )
   jNextLine()
   jAddData( 0, padc( repli( '=', 78 ), 78 ) )
   jNextLine()
   jAddData( 0, padc( __aTypeDescs[ nChoice ], 78 ) )
   jNextLine()
   jAddData( 0, padc( dtoc( dS ) + ' To ' + dtoc( dE ), 78 ) )
   jNextLine()
   jAddData( 0, repli( '-', 78 ) )
   jNextLine()
   jAddData( 0, 'Account' )
   jAddData( 26, padl( "CASH", 09 ) )
   jAddData( 39, padl( "BANK", 09 ) )
   jAddData( 53, padl( "DAYBOOK", 09 ) )
   jAddData( 66, padl( "Total", 09 ) )
   jNextLine()
   jAddData( 0, repli( '-', 78 ) )
   jNextLine()

   do while .not. eof()
      jAddData( 0, subs( account, 1, 24 ), str( id, 5, 0 ) )
      if cash != 0
         jAddData( 26, str( abs( cash ), 8, 0 ) + ' ' + iif( cash > 0, 'D ', ' C' ) )
         cashtot += cash
      endif
      if bank != 0
         jAddData( 39, str( abs( bank ), 8, 0 ) + ' ' + iif( bank > 0, 'D ', ' C' ) )
         banktot += bank
      endif
      if day != 0
         jAddData( 53, str( abs( day ), 8, 0 ) + ' ' + iif( day > 0, 'D ', ' C' ) )
         daytot += day
      endif
      if balance != 0
         jAddData( 66, str( abs( balance ), 8, 0 ) + ' ' + iif( balance > 0, 'D ', ' C' ) )
         balTot += balance
      endif
      jNextLine()
      skip
      if !jGoReport( inkey() )
         close all
         jNextLine()
         jNextLine()
         jAddData( 5, '** Report aborted by user **' )
         jNextLine()
         jNextLine()
         jEndReport()
         return .f.
      endif
   enddo

   jAddData( 25, repli( '-', 52 ) )
   jNextLine()

   if cashTot != 0
      jAddData( 26, str( abs( cashTot ), 8, 0 ) + ' ' + iif( cashTot > 0, 'D ', ' C' ) )
   endif
   if bankTot != 0
      jAddData( 39, str( abs( bankTot ), 8, 0 ) + ' ' + iif( bankTot > 0, 'D ', ' C' ) )
   endif
   if dayTot != 0
      jAddData( 53, str( abs( dayTot ), 8, 0 ) + ' ' + iif( dayTot > 0, 'D ', ' C' ) )
   endif
   if balTot != 0
      jAddData( 66, str( abs( balTot ), 8, 0 ) + ' ' + iif( balTot > 0, 'D ', ' C' ) )
   endif
   jNextLine()
   jNextLine()
   jNextLine()
   jAddData( 0, " " )
   close all
   if lastkey() != K_ESC
      jEndReport()
   endif
endif

return nil
//----------------------
function dgALedger( lWithOp, lAskType )

local nAId := alltrim( jRefdata() ), nType
if empty( nAId ) .or. val( nAId ) = 0
   return .f.
else
   jSaveEnv()
   close all
   if lAskType == NIL
      lAskType := 'ALL'
   elseif lAskType
      nType := jAlert( 'Show Entries: ', { 'ALL', 'Cashbook', 'Bankbook', 'Daybook' }, nBoxColor() )
      if nType == 1
         lAskType := 'ALL'
      elseif nType == 2
         lAskType := 'CASHBOOK'
      elseif nType == 3
         lAskType := 'BANKBOOK'
      elseif nType == 4
         lAskType := 'DAYBOOK'
      else
         jRestEnv()
         return .f.
      endif
   endif

   if dS == NIL .and. dE == NIL
      ledger( .t., val( nAId ), nil, nil, nil, nil, lAskType )
   else
      ledger( .t., val( nAId ), nil, dS, dE, lWithOp, lAskType )
   endif
   close all
   jRestEnv()
endif
return .t.
//-----------------------------------
function listGroup( lDisplay, nAcc, dFrom, dTo )

local lAId
local lAAcc
local nRec      := 1
local nTot      := 0.00
local line      := 1
local nRetBal
local nGroup
local nSub
local cParentAc := ""

local nDTotal
local nCTotal
local nD
local nC

local lByPeriod

if lDisplay == NIL
   lDisplay := .t.
endif

use SUBHEADS new index SUB_1,SUB_2,SUB_3
use ACCOUNTS new index ACC_1,ACC_2
set filter to accounts->group
go top

if lDisplay
   accview( .t., .f., .t.,, .f., .f., { || accounts->group } )
else
   seek nAcc
endif

cParentAc := alltrim( accounts->account )
// Used during OUTPUT DISPLAY when all files are closed.

// acFile is declared STATIC.

if lDisplay
   lByPeriod := jAlert( 'Report : ', { '[ Entire ]', '[ By Period ]' } )
   if lByPeriod == 0
      close all
      return .f.
   endif

   if lByPeriod == 2
      lByPeriod := .t.

      private dS := _jAcStartDate()
      private dE := date()

      popread( .f., 'Starting Date : ', @dS, '@D', ;
               'Ending Date   : ', @dE, '@D' )
      if dS > dE .or. empty( dS )
         jAlert( 'Invalid dates.' )
         return .f.
      endif
   else
      lByPeriod := .f.
      private dS := NIL
      private dE := NIL
   endif
else
   if dFrom == NIL .or. dTo == NIL
      lByPeriod := .f.
      private dS := NIL
      private dE := NIL
   else
      lByPeriod := .t.
      private dS := dFrom
      private dE := dTo
   endif
endif

acFile := jTempFile( 'TMPAC', 'DBF' )
dbcreate( ACFILE, { { 'PARENT_ID', 'N',  5, 0 }, ;
                    { 'ACC_SUB'  , 'N',  5, 0 }, ;
                    { 'SUBHEAD'  , 'C', 60, 0 }, ;
                    { 'BALANCE'  , 'N', 11, 2 } } )
EUse( acFile )

use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 5
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5
set order to 4
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6
if alltrim( upper( accounts->type ) ) == 'BANK'
   set order to 5 // bnk_6 - b_id
else
   set order to 4 // BNK_5 - account
endif

JInitRep( "Group Report-" + alltrim( accounts->account ), .t., { || subgrKey() }, 'Preparing report...', 66 )

sele subheads
set filter to parent_id == accounts->id
go top
do while .not. eof()
   sele ( acFile )
   append blank
   field->parent_id := accounts->id
   field->acc_sub   := subheads->id
   field->subhead   := subheads->subhead
   sele subheads
   skip
enddo

sele ( acFile )
append blank
field->parent_id := accounts->id
field->acc_sub   := 0
field->subhead   := chr( 255 ) + 'Ungrouped Entries'
field->balance   := 0.00

indexbar( acFile, "acc_sub" )           // index on ++ACC_SUB++ to (acfile).cdx

nDTotal := 0.00

select cashbook
if lByPeriod
   set filte to ( account == accounts->id ) .and. ( date >= dS .and. date <= dE )
else
   set filter to account == accounts->id
endif
go top

do while .not. eof()
   ( acFile )->( dbseek( cashbook->acc_sub ) )
   _PutAmount()
   skip
enddo

select bankbook
if lByPeriod
   set filte to ( account == accounts->id ) .and. ( date >= dS .and. date <= dE )
else
   set filter to account == accounts->id
endif
go top

do while .not. eof()
   ( acFile )->( dbseek( bankbook->acc_sub ) )
   _PutAmount()
   skip
enddo

select daybook
if lByPeriod
   set filte to ( account == accounts->id ) .and. ( date >= dS .and. date <= dE )
else
   set filter to account == accounts->id
endif
go top
do while .not. eof()
   ( acFile )->( dbseek( daybook->acc_sub ) )
   _PutAmount()
   skip
enddo

if !lDisplay
   sele ( acFile )
   sum all balance to nRetBal
   close all
   return nRetBal
endif

nDTotal := 0.00
nCTotal := 0.00
close all
eUse( acFile )
indexbar( acFile, "subhead" )           // index on subhead to (acfile).cdx
go top
setprc( 0, 0 )

jAddData( 1, padc( "GROUP A/C SUMMARY", 66 ) )
jNextLine()
jAddData( 1, padc( cParentAc, 66 ) )
jNextLine()
if lByPeriod
   jAddData( 1, padc( '[ From ' + dtoc( dS ) + ' to ' + dtoc( dE ) + ' without Op. Balance ]', 66 ) )
   jNextLine()
endif
jNextLine()
jAddData( 1, repli( '-', 66 ) )
jNextLine()
jAddData( 1, 'Sub-Account' )
jAddData( 45, 'Debit' )
jAddData( 57, 'Credit' )
jNextLine()
jAddData( 1, repli( '-', 66 ) )
jNextLine()
do while .not. eof()
   if balance != 0
      jAddData( 1, subs( subhead, 1, 38 ), str( parent_id, 5, 0 ) + ' ' + str( acc_sub, 5, 0 ) )
      jAddData( 40, iif( balance > 0, str( balance, 10, 2 ), space( 10 ) ) )
      jAddData( 55, iif( balance < 0, str( abs( balance ), 10, 2 ), space( 10 ) ) )
      jNextLine()
      if balance > 0
         nDTotal += balance
      else
         nCTotal += abs( balance )
      endif
   endif

   skip
   if !jGoReport( inkey() )
      close all
      jNextLine()
      jNextLine()
      jAddData( 5, '** Report aborted by user **' )
      jNextLine()
      jNextLine()
      jEndReport()
      return .f.
   endif
enddo
jAddData( 1, subs( subhead, 1, 38 ) )
jAddData( 40, repli( '-', 10 ) )
jAddData( 55, repli( '-', 10 ) )
jNextLine()
jAddData( 39, str( nDtotal, 11, 2 ) )
jAddData( 54, str( nCTotal, 11, 2 ) )
jNextLine()
jNextLine()
jAddData( 4, "NET BALANCE ==> " )
jAddData( 39, iif( nDTotal - nCTotal > 0, str( nDTotal - nCTotal, 11, 2 ), space( 11 ) ) )
jAddData( 54, iif( nCTotal - nDTotal > 0, str( nCTotal - nDTotal, 11, 2 ), space( 11 ) ) )
jNextLine()
jNextLine()
jNextLine()
jAddData( 1, " " )
close all
ferase( acFile + '.DBF' )
ferase( acFile + '.CDX' )
ferase( acFile + '.NTX' )

if lastkey() != K_ESC
   jEndReport()
endif

return nil
//---------------------
static function _PutAmount

// Used only by ListGroup for updating balance amount
// into the temporary file.

local cOldFile := alias()
local cAction  := action
local nAmount  := amount

if cAction = 'D'
   sele ( acFile )
   field->balance += nAmount
elseif cAction = 'C'
   sele ( acFile )
   field->balance -= nAmount
endif

select ( cOldFile )
return .t.
//-------------------------------
function subGrKey

local nAId := alltrim( jRefdata() ), nGroup
nGroup := val( subs( nAId, 6 ) )
nAId   := val( subs( nAId, 1, 5 ) )
if nAId = 0
   return .f.
else
   jSaveEnv()
   close all
   if dS == NIL
      ledger( .t., nAId, nGroup )
   else
      ledger( .t., nAId, nGroup, dS, dE, .f. )              // openfiles, acc.id, sub acc id,from date, to date, show op.bal
   endif
   close all
   jRestEnv()
endif
return .t.
//-----------------------------------
function cashinout

local aCols    := {}
local aBrowse
local cScrn    := savescreen()
local dDate
local nITotal  := 0.00
local nETotal  := 0.00
local lDayTot  := .f.
local lDaySaid := .f.

private dFrom := date()
private dTo   := date()

popread( .f., 'Starting Date : ', @dFrom, '@D', ;
         'Ending Date   : ', @dTo, '@D' )

if dFrom > dTo .or. empty( dFrom )
   jAlert( 'Invalid dates.' )
   return .f.
endif

lDayTot := jAlert( 'Balance by Date ?', { 'Yes', 'No' } )
if lDayTot == 1
   lDayTot := .t.
elseif lDayTot == 2
   lDayTot := .f.
else
   close all
   return .f.
endif

JInitRep( "Cash In & Out Statement", .f., { || goCEntry() }, 'Preparing report...', 79 )

use accounts new index ACC_1,ACC_2
use subheads new index SUB_1,SUB_2,SUB_3
use cashbook new shared index CSH_2, CSH_5 // Date,Account orders.
set filte to date >= dFrom .and. date <= dTo
go top
JDgSetPBar( cmFiltCount() )

jAddData( 0, padc( 'Cash In & Out Statement', 79 ) )
jNextLine()
jAddData( 0, padc( '[ From ' + dtoc( dFrom ) + ' to ' + dtoc( dTo ) + ' ]', 79 ) )
jNextLine()
jAddData( 0, repli( '=', 79 ) )
jNextLine()
jAddData( 0, 'Date' )
jAddData( 11, 'Account/Narration' )
jAddData( 59, 'Debit' )
jAddData( 71, 'Credit' )
jNextLine()

do while .not. eof()
   lDaySaid := .f.
   dDate    := date
   do while dDate == date .and. ( !eof() )

      sele accounts
      seek cashbook->account

      sele cashbook
      if upper( alltrim( accounts->type ) ) != "LOANS RECEIVED"

         jAddData( 0, dtoc( date ) )

         sele accounts
         jAddData( 11, padr( rtrim( ltrim( subs( rtrim( ltrim( proper( accounts->account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", " + details, space( 40 ) ), 1, 40 ) ) ), 40 ) )
         sele cashbook

         if action == 'C'
            jAddData( 55, str( cashbook->amount, 10, 2 ), dtoc( cashbook->date ) + str( cashbook->id, 7, 0 ) )
            nITotal += cashbook->amount
         else
            jAddData( 67, str( cashbook->amount, 10, 2 ), dtoc( cashbook->date ) + str( cashbook->id, 7, 0 ) )
            nETotal += cashbook->amount
         endif
         jNextLine()

         if accounts->group
            sele subheads
            set order to 1
            seek cashbook->acc_sub
            jAddData( 11, "[ Sub A/C: " + alltrim( subheads->subhead ) + " ]", dtoc( cashbook->date ) + str( cashbook->id, 7, 0 ) )
            jNextLine()
            sele cashbook
         endif
         if !empty( alltrim( cashbook->details ) )
            jAddData( 11, "(" + alltrim( cashbook->details ) + ")", dtoc( cashbook->date ) + str( cashbook->id, 7, 0 ) )
            jNextLine()
         endif
      endif
      sele cashbook
      skip
      JDgIncrPBar()
   enddo

   if lDayTot .or. cashbook->( eof() )
      jAddData( 55, repli( iif( cashbook->( eof() ), '=', '-' ), 22 ) )
      jNextLine()
      jAddData( 55, str( nITotal, 10, 2 ) )
      jAddData( 67, str( nETotal, 10, 2 ) )
      nITotal -= nETotal
      nETotal := 0.00
      jNextLine()
      if nITotal < 0
         nETotal := abs( nITotal )
         nITotal := 0.00
         if cashbook->( eof() )
            jAddData( 34, "Grand Total -->" )
         else
            jAddData( 44, "Day Bal.:" )
         endif
         jAddData( 67, str( nETotal, 10, 2 ) )
         jNextLine()
      elseif nITotal > 0
         if cashbook->( eof() )
            jAddData( 34, "Grand Total -->" )
         else
            jAddData( 44, "Day Bal.:" )
         endif
         jAddData( 55, str( nITotal, 10, 2 ) )
         jNextLine()
      endif
      jNextLine()
   endif
enddo
jNextLine()
jAddData( 0, repli( '-', 79 ) )
jNextLine()
jAddData( 0, 'Note: Report excludes transactions with LOAN RECEIVED A/Cs.' )
jNextLine()
jAddData( 0, '      Opening Cash Balance is not counted.' )

close all

if lastkey() != K_ESC
   jEndReport()
endif

return .t.
//---------------------------------------------------------
static function GoCEntry

local dPrevDate := dDate
if !empty( ctod( subs( jRefData(), 1, 10 ) ) )
   jSaveEnv()
   close all
   entr_date( ctod( subs( jRefData(), 1, 10 ) ) )
   cshentry( val( subs( jRefData(), 11 ) ) )
   close all
   jRestEnv()
   entr_date( dPrevDate )
else
   tone( 300, 2 )
endif
return .t.
//----------------------------------------------------------

*+ EOF: ACC_REP.PRG
