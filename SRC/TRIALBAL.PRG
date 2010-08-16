/*
#
#     Account sub-system REPORTS - Trial Balance
#                        for EasyAccounts v2.1
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
#include 'inkey.ch'
#include 'box.ch'

function trialBal()

local lAId
local lAAcc
local nRec   := 1
local nTemp1
local nTemp2
local nTot   := 0.00
local line   := 1

local nDTotal
local nCTotal
local nD
local nC
local nD1
local nC1

private dTDate := jGetDate( 'Trial Balance As On :' )
if empty( dTDate )
   return .f.
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
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6 // Ord.4 Account
// Ord.5 Bank
set filte to date <= dTDate

//ShowPBar( 'Filtering transactions till ' + dtoc( dTDate ) + '...' )

JInitRep( "Trial Balance", .f., { || dgALedger(.t.) }, 'Preparing report...', 66 )
sele accounts

jDGSetPBar( reccount() )

sele accounts
nDTotal := 0.00
do while .not. eof()

   nD := opbal      // that may be negative if is in the credit column.
   nC := 0.00       // so, same THING, same EFFECT, same WOrds...!

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

   if accounts->id == 1                 // Cash Account
      select cashbook
      go top
      sum all amount to nTemp1 for action = 'D'             // Expense
      go top
      sum all amount to nTemp2 for action = 'C'             // Income
      nD += nTemp2
      nC += nTemp1
   endif

   select bankbook  // As a transacted Bank
   set order to 5
   go top
   seek accounts->id
   if found()
      do while b_id == accounts->id
         if action = 'C'
            nD += amount
         elseif action = 'D'
            nC += amount
         endif
         skip
      enddo
   endif

   select bankbook  // As an A/C in transaction
   set order to 4
   go top
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
      field->type    := accounts->type
      field->balance := nD - nC
      sele accounts
      jRLock()
      field->balance := nD - nC
      jRUnLock()
   endif

   sele accounts
   skip
   jDGIncrPBar()
   //nRec ++
   //RefreshPBar( ( nRec / reccount() ) * 100 )

enddo

//HidePBar()

nDTotal := 0.00
nCTotal := 0.00
nD1     := 0.00
nC1     := 0.00
close all
eUse( "acbals" )
indexbar( "acbals", "type+account" )    // index on type+account to acbals.ntx
go top
setprc( 0, 0 )

//ShowPBar( 'Writing trial balance...' )
//nRec := 1
set device to printer
set printer to ( RepPath + 'TRIAL.TXT' )
set console off
set printer on
line := 1
//SayTitles( 66, @line )
jNextLine()
jAddData( 1, padc( "TRIAL BALANCE AS ON " + dtoc( dTDate ), 66 ) )
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
   nTemp1 := type
   // jAddData( 1, LeftAlign( "[ " + rtrim( ltrim( upper( __aTypeDescs[ascan(__aTypes,rtrim(ltrim(type)))] ) ) ) + " ]", 66 ) )
   jAddData( 1, "[ " + rtrim( ltrim( upper( __aTypeDescs[ascan(__aTypes,rtrim(ltrim(type)))] ) ) ) + " ]" )
   jNextLine()
   do while type == nTemp1 .and. ( !eof() )
      jAddData( 1, subs( account, 1, 38 ), str( id, 5, 0 ) )
      jAddData( 40, iif( balance > 0, str( balance, 10, 2 ), space( 10 ) ) )
      jAddData( 55, iif( balance < 0, str( abs( balance ), 10, 2 ), space( 10 ) ) )
      jNextLine()
      if balance > 0
         nD1 += balance
      else
         nC1 += abs( balance )
      endif
      //nRec ++
      skip
      //RefreshPBar( ( nRec / reccount() ) * 100 )
   enddo
   jAddData( 40, repli( "-", 10 ) )
   jAddData( 55, repli( '-', 10 ) )
   jNextLine()
   jAddData( 25, 'Group Total : ' )
   jAddData( 40, str( nD1, 10, 2 ) )
   jAddData( 55, str( nC1, 10, 2 ) )
   jNextLine()
   if nD1 - nC1 != 0
      if nD1 > nC1
         jAddData( 40, str( nD1 - nC1, 10, 2 ) )
      else
         jAddData( 55, str( nC1 - nD1, 10, 2 ) )
      endif
      jNextLine()
   endif
   jNextLine()

   nDTotal += nD1
   nCTotal += nC1

   nD1 := 0.00
   nC1 := 0.00

enddo

if ReqInv()

   use saccount new
   sum all total, DISCOUNT to nTemp1, nTemp2 for date <= dTDate
   use
   //jAddData( 1, LeftAlign( "[ PURCHASE & SALES ]", 66 ) )
   jAddData( 1, "[ PURCHASE & SALES ]" )
   jNextLine()
   jAddData( 1, 'Sales' )
   jAddData( 55, str( nTemp1, 10, 2 ) )
   nC1 += nTemp1
   jNextLine()
   jAddData( 1, 'Discount Given' )
   jAddData( 40, str( nTemp2, 10, 2 ) )
//   jAddData( 65, chr(255) )
   nD1 += nTemp2
   jNextLine()
   jAddData( 1, 'Purchase' )
   use paccount new
   sum all total, BILLTAX to nTemp1, nTemp2 for date <= dTDate
   use
   jAddData( 40, str( nTemp1, 10, 2 ) )
//   jAddData( 65, chr(255) )
   nD1 += nTemp1
   jNextLine()
   jAddData( 1, 'Other Charges/Discounts' )
   jAddData( iif( nTemp2 > 0, 40, 55 ), str( nTemp2, 10, 2 ) )
//   jAddData( 65, chr(255) )

   if nTemp2 > 0
      nD1 += nTemp2
   else
      nC1 += abs( nTemp2 )
   endif
   jNextLine()

   jAddData( 40, repli( '-', 10 ) )
   jAddData( 55, repli( '-', 10 ) )
   jNextLine()
   jAddData( 25, 'Group Total : ' )
   jAddData( 40, str( nD1, 10, 2 ) )
   jAddData( 55, str( nC1, 10, 2 ) )
//   jAddData( 66, chr(255) )
   jNextLine()
   nDTotal += nD1
   nCTotal += nC1

   if nD1 - nC1 != 0
      if nD1 > nC1
         jAddData( 40, str( nD1 - nC1, 10, 2 ) )
//         jAddData( 66, chr(255) )
      else
         jAddData( 55, str( nC1 - nD1, 10, 2 ) )
//         jAddData( 66, chr(255) )
      endif
      jNextLine()
   endif
   jNextLine()
endif

jNextLine()

jAddData( 40, repli( '=', 25 ) )        // Draw a continious line which shows it apart.
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
/*
set device to screen
set printer off
set printer to
HidePBar()
fileread( 4, 05, 20, 75, RepPath+'TRIAL.TXT', 'Trial Balance' )
*/

jGoReport( inkey() )

if lastkey() != K_ESC
   jEndReport()
endif

return nil

*+ EOF: TRIALBAL.PRG
