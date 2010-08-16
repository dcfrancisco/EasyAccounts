#include "std.ch"

static lAId
static lAType
static lAAcc
static lComplete
static lByDate
static dS
static dE
static lByPeriod
static lWithOps
//------------------------------------------------
function ledger( lOpenDbf )

local nRec
local nSel
local nDueDays
close all
nRec     := l_initldg( lOpenDbf )
nDueDays := duedays
if lComplete
   close all
   set default to ( dir( 'PULLIMAN' ) )
   use accounts new index ACC_1,ACC_2
   set order to 1
   seek 0           // it is Adm. acc_code
   recallldg()
   close all
   set default to ( dir( 'KOLLAM' ) )
   use accounts new index ACC_1,ACC_2
   set order to 1
   seek 0           // it is Adm. acc_code
   recallldg()
   close all
   set default to ( dir( 'GRAPHICS' ) )
   use accounts new index ACC_1,ACC_2
   set order to 1
   seek 0           // it is Adm. acc_code
   recallldg()
   close all
   if !cmbineledg()
      return .f.
   endif
else
   recallldg()
endif

if nDuedays > 0
   nSel := jAlert( 'Ledger Report : ', { 'Complete', 'Due Amount' } )
   if nSel = 1
      repldg( nRec )
   elseif nSel = 2
      repdues( nRec )
   endif
else
   repldg( nRec )
endif
return .t.

static function l_initldg( lOpenDbf )

local x
local y

if lOpenDbf = NIL
   lOpenDbf := .t.
endif

lByDate   := .f.
lByPeriod := .f.
lWithOps  := .T.

dS := date()
dE := date()

if !lOpenDbf
   setcolor( msgcolor() )
endif

@ 09, 09 clear to 11, 30
@ 09, 09 to 11, 30
@ 10, 10 say '  Ledger Details    '         
accview( .f., .t., .t., iif( lOpenDbf, boxcolor(), msgcolor() ) )               // It opens the database for me...

setcursor( 1 )
if !lOpenDbf
   setcolor( msgcolor() )
endif

@ 13, 09 clear to 17, 37
@ 13, 09 to 17, 37
@ 14, 10 say 'Balance by Date <Y/N> ? ' // NO NEED.......!         
lByDate := opconfirm()
@ 15, 10 say 'By Period <Y/N> ? '         
lByPeriod := opconfirm()
if lByPeriod
   @ 16, 10 say 'With Op.Balance <Y/N> ? '         
   lWithOps := opconfirm()
   @ 18, 09 clear to 21, 37
   @ 18, 09 to 21, 37
   @ 19, 10 say "Starting : " get dS                          
   @ 20, 10 say "Ending   : " get dE valid ( dE >= dS )       
   read
endif

setcolor( boxcolor() )

x := recno()
sele accounts
if id = 0           // Administration
   if opened( 'PULLIMAN' ) .and. opened( 'KOLLAM' ) .and. opened( 'GRAPHICS' )
      lComplete := jAlert( 'Administration Details', { 'Complete', 'Company-wise' } ) = 1
   else
      lComplete := .f.
      msg( 'All companies not opened', 'Consolidated report disabled...' )
   endif
else
   lComplete := .f.
endif
if lOpenDbf
   dispscrn()
endif
ontask( 'Generating Ledger report...' )
sele accounts
set order to 1
lAId   := id
lAType := rtrim( ltrim( type ) )
lAAcc  := rtrim( ltrim( account ) )
set filter to
return x
//------------------------------------------
static function recallldg()

local nCashOp
local nBnkop
local nDayOp
local nOpBal  := 0.00

euse( "LEDGER" )
zap

select accounts
nOpBal := opbal

if rtrim( ltrim( type ) ) = 'Bank'
   use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
   set filter to account == lAId
   go top
   use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
   set filter to account == lAId
   go top
   use bankbook new index BNK_1,BNK_2,BNK_3
   set filter to b_id == lAId
   go top
elseif rtrim( ltrim( account ) ) = 'Cash'
   use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
   set filter to
   go top
   use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
   set filter to account == lAID
   go top
   use bankbook new index BNK_1,BNK_2,BNK_3
   set filter to account == lAId
   go top
else
   use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
   set filter to account == lAId
   go top
   use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
   set filter to account == lAId
   go top
   use bankbook new index BNK_1,BNK_2,BNK_3
   set filter to account == lAId
   go top
endif

if lWithOps
   if nOpBal != 0   // may be -ve or +ve, we want it. but we dont want zERO!
      sele ledger
      append blank
      field->details := 'Op.Balance'
      if nOpBal > 0
         field->debit := nOpBal
      else
         field->credit := abs( nOpBal )
      endif
   endif
else
   nOpBal := 0.00
endif

sele cashbook
do while .not. eof()
   sele ledger
   appe blank
   field->date    := cashbook->date
   field->details := proper( cashbook->details )
   if lAAcc = 'Cash'
      field->credit := iif( cashbook->action = 'D', cashbook->amount, 0.00 )
      field->debit  := iif( cashbook->action = 'C', cashbook->amount, 0.00 )
   else
      field->debit  := iif( cashbook->action = 'D', cashbook->amount, 0.00 )
      field->credit := iif( cashbook->action = 'C', cashbook->amount, 0.00 )
   endif
   sele cashbook
   skip
enddo

sele bankbook
do while .not. eof()
   sele ledger
   appe blank
   field->date := bankbook->date
   sele accounts

   if rtrim( ltrim( lAtype ) ) != 'Bank'
      seek bankbook->b_id
   else
      seek bankbook->account
   endif

   if found()
      y := subs( account, 1, 14 )
   else
      msg( "Bankbook record " + rtrim( ltrim( str( recno() ) ) ) + " mismatches with account!" )
      close all
      return .f.
   endif
   sele ledger
   field->details := proper( y + '  ' + bankbook->details )
   if lAType = 'Bank'
      field->debit  := iif( bankbook->action = 'C', bankbook->amount, 0.00 )
      field->credit := iif( bankbook->action = 'D', bankbook->amount, 0.00 )
   else
      field->debit  := iif( bankbook->action = 'D', bankbook->amount, 0.00 )
      field->credit := iif( bankbook->action = 'C', bankbook->amount, 0.00 )
   endif
   sele bankbook
   skip
enddo

sele daybook
do while .not. eof()
   sele ledger
   appe blank
   field->date    := daybook->date
   field->details := proper( daybook->details )
   field->debit   := iif( daybook->action = 'D', daybook->amount, 0.00 )
   field->credit  := iif( daybook->action = 'C', daybook->amount, 0.00 )
   sele daybook
   skip
enddo

close all

if lByPeriod
   splitdbk()
endif
return .T.

static function repldg( x )

local line      := 1
local lCash
local dDate
local totdebit  := 0.00
local totcredit := 0.00
local lSupp
use ledger
if lByPeriod .and. lComplete
   close all
   splitdbk()
   use ledger new
   go top
endif
index on date to LDG_1
close all
use accounts new
go x
use ledger NEW index LDG_1
go top
set device to printer
set printer to (RepPath+'LEDGER.TXT')
set printer on
@ line,  0 say padc( 'Wintech Systems & Services', 79 )         
line ++
@ line,  0 say padc( comp_add, 79 )         
line ++
line ++
if lAID != 0 .and. lAid != 1
   @ line,  0 say padc( 'Ledger A/C', 79 )         
   line ++
   sele accounts
   @ line,  0 say padc( rtrim( ltrim( account ) ), 79 )         
elseif lAID = 1
   @ line,  0 say padc( 'CASH BOOK', 79 )         
   line ++
endif
if lAId = 0
   @ line,  0 say padc( iif( lComplete, 'Consolidated Report', 'Branch Report' ), 79 )         
   line ++
   @ line,  0 say padc( 'ADMINISTRATION', 79 )         
endif
sele accounts
if rtrim( ltrim( account ) ) == 'Cash'
   lCash := .t.
else
   lCash := .f.
endif
line ++
@ line,  0 say repli( '-', 79 )         
line ++
@ line,  0 say "Date"                
@ line, 12 say "Transaction"         
@ line, 58 say "Debit"               
@ line, 69 say "Credit"              
line ++
@ line,  0 say repli( '-', 79 )         
line ++
sele ledger
do while .not. eof()
   if !deleted()
      // if lCash .or. lByDate   (DAILY-SHEET SYSTEM ABANDONED.)
      //                         (NOW DEPOSIT CASH EVERY TIME TO BANK)
      if lByDate
         dDate := date
         do while dDate == date .and. ( !eof() )
            if !empty( date )
               @ line,  0 say date         
            endif
            @ line, 12 say details         
            if debit > 0
               @ line, 58 say str( debit, 9, 2 )         
            else
               @ line, 69 say str( credit, 9, 2 )         
            endif
            line ++
            totdebit  += debit
            totcredit += credit
            skip
         enddo
         @ line, 58 say repli( '-', 9 )         
         @ line, 69 say repli( '-', 9 )         
         line ++
         @ line, 58 say str( totdebit, 9, 2 )          
         @ line, 69 say str( totcredit, 9, 2 )         
         line ++
         @ line, 40 say "Date Balance : "         
         if totdebit > totcredit
            @ line, 58 say str( totdebit - totcredit, 9, 2 )         
            totdebit  -= totcredit
            totcredit := 0.00
         else
            @ line, 69 say str( totcredit - totdebit, 9, 2 )         
            totcredit -= totdebit
            totdebit  := 0.00
            // TO AVOID ***** MARKS as the result of cumulating amount.
         endif

         /*
         if lCash
            totdebit := 0.00     // make the bal. zero only for CAsh A/C
            totcredit := 0.00
         endif
         DAILY SHEET SYSTEM ABANDONED.
         */
         line ++
         line ++
      else
         if !empty( date )
            @ line,  0 say date         
         endif
         @ line, 12 say details         
         if debit > 0
            @ line, 58 say str( debit, 9, 2 )         
         else
            @ line, 69 say str( credit, 9, 2 )         
         endif
         line ++
         totdebit  += debit
         totcredit += credit
         skip
      endif
   else
      skip
   endif
enddo
if !lByDate
   @ line, 58 say repli( '-', 9 )         
   @ line, 69 say repli( '-', 9 )         
   line ++
   @ line, 57 say str( totdebit, 10, 2 )          
   @ line, 68 say str( totcredit, 10, 2 )         
   line ++
   @ line, 40 say "Net Balance :"         
   if totdebit > totcredit
      @ line, 57 say str( totdebit - totcredit, 10, 2 )         
   else
      @ line, 69 say str( totcredit - totdebit, 9, 2 )         
   endif
endif

line ++
line ++
line ++
line ++
@ line,  0 say padc( "**End Report**", 79 )         
set device to screen
set printer off
set printer to
close all
ontask()
FILEREAD( 1, 0, 23, 79, RepPath+"LEDGER.TXT", 'Ledger Report' )
return .t.
//-------------------
static function splitdbk()

local nOpBal := 0.00
use ledger new
index on date to LDG_1
go top
do while .not. eof()
   if date < dS
      nOpBal += ( debit - credit )
      delete
      skip
   elseif date == dS .and. rtrim( ltrim( upper( details ) ) ) == 'OP.BALANCE'
      nOpBal += ( debit - credit )
      delete
      skip
   elseif date > dE
      delete
      skip
   elseif date >= dS .and. date <= dE
      skip
   endif
enddo
if lWithOps
   append blank
   field->details := 'Op.Balance as of ' + dtoc( dS )
   if nOpBal > 0
      field->debit := nOpBal
   elseif nOpBal < 0
      field->credit := abs( nOpBal )
   endif
endif
close all
return .t.
//----------------
static function cmbineledg()

close all
if comp_add = 'Kollam'
   set default to ( dir( 'Kollam' ) )
   use ledger new
   append from ( dir( 'Pulliman' ) + '\ledger' )
   append from ( dir( 'Graphics' ) + '\ledger' )
elseif comp_add = 'Pulliman Jun.'
   set default to ( dir( 'Pulliman' ) )
   use ledger new
   append from ( dir( 'Kollam' ) + '\ledger' )
   append from ( dir( 'Graphics' ) + '\ledger' )
elseif comp_add = 'Graphics'
   set default to ( dir( 'Graphics' ) )
   use ledger new
   append from ( dir( 'Pulliman' ) + '\ledger' )
   append from ( dir( 'Kollam' ) + '\ledger' )
else
   msg( 'COMBINE LEDGERS', 'Company not authorized!', 'Cannot take administration reports..' )
   close all
   return .f.
endif
close all
return .t.
//--------------------
static function repdues( x )

local line      := 1
local lCash
local dDate
local totdebit  := 0.00
local totcredit := 0.00
local nDueAmnt  := 0.00
use ledger
if lByPeriod .and. lComplete
   close all
   splitdbk()
   use ledger new
   go top
endif
index on date to LDG_1
close all
use accounts new
go x
lSupp := ( type = 'Sundry Creditor' )
use ledger NEW index LDG_1
go top
set device to printer
set printer to (RepPath+'DUELIST.TXT')
set printer on
@ line,  0 say padc( 'Wintech Systems & Services', 79 )         
line ++
@ line,  0 say padc( comp_add, 79 )         
line ++
@ line,  0 say padc( 'Dues List', 79 )         
line ++
line ++
sele accounts
@ line,  0 say padc( rtrim( ltrim( account ) ), 79 )         
sele accounts
if rtrim( ltrim( account ) ) == 'Cash'
   lCash := .t.
else
   lCash := .f.
endif
line ++
@ line,  0 say repli( '-', 79 )         
line ++
@ line,  0 say "Date"                
@ line, 12 say "Transaction"         
@ line, 58 say "Debit"               
@ line, 69 say "Credit"              
line ++
@ line,  0 say repli( '-', 79 )         
line ++
sele ledger
pack
go top
do while .not. eof()
   if date < ( date() - accounts->duedays )
      if ( date() - accounts->duedays - date ) > 15         // No bills 10 days before.
         nDueAmnt += debit - credit
      else
         delete
      endif
   else
      if ( lSupp .and. ( debit > credit ) ) .or. ( .not. lSupp .and. ( credit > debit ) )
         delete
      endif
   endif
   skip
enddo
if nDueAmnt != 0
   append blank
   field->date    := date() - ( accounts->duedays + 15 )
   field->details := 'PREVIOUS DUE'
   if nDueAmnt > 0
      field->debit := nDueAmnt
   elseif nDueamnt < 0
      field->credit := abs( nDueAmnt )
   endif
endif
copy structure to ldg1
use ldg1
go bott
skip - 1
appe rest from ledger for details = 'PREVIOUS DUE'
// TO MAKE IT FAST THAN LOOPING FROM THE TOP
go top
appe all from ledger for deleted()
recall all
index on date to LDG_1
go top
do while .not. eof()
   if !deleted()
      // if lCash .or. lByDate   (DAILY-SHEET SYSTEM ABANDONED.)
      //                         (NOW DEPOSIT CASH EVERY TIME TO BANK)
      if lByDate
         dDate := date
         do while dDate == date .and. ( !eof() )
            if !empty( date )
               @ line,  0 say date         
            endif
            @ line, 12 say details         
            if debit > 0
               @ line, 58 say str( debit, 9, 2 )         
            else
               @ line, 69 say str( credit, 9, 2 )         
            endif
            line ++
            totdebit  += debit
            totcredit += credit
            skip
            if ( totdebit > totcredit .and. ( credit > debit ) ) .or. ( totcredit > totdebit .and. ( debit > credit ) )
               // ie, he is a customer and has now paid some cash. then display
               // balance.   OR he is a vendor and we now has paid him cash.
               @ line, 58 say repli( '-', 9 )         
               @ line, 69 say repli( '-', 9 )         
               line ++
               @ line, 58 say str( totdebit, 9, 2 )          
               @ line, 69 say str( totcredit, 9, 2 )         
               line ++
               @ line, 40 say "Balance : "         
               if totdebit > totcredit
                  @ line, 58 say str( totdebit - totcredit, 9, 2 )         
                  totdebit  -= totcredit
                  totcredit := 0.00
               else
                  @ line, 69 say str( totcredit - totdebit, 9, 2 )         
                  totcredit -= totdebit
                  totdebit  := 0.00
                  // TO AVOID ***** MARKS as the result of cumulating amount.
               endif
            endif
         enddo
         @ line, 58 say repli( '-', 9 )         
         @ line, 69 say repli( '-', 9 )         
         line ++
         @ line, 58 say str( totdebit, 9, 2 )          
         @ line, 69 say str( totcredit, 9, 2 )         
         line ++
         @ line, 40 say "Day's Due : "         
         if totdebit > totcredit
            @ line, 58 say str( totdebit - totcredit, 9, 2 )         
            totdebit  -= totcredit
            totcredit := 0.00
         else
            @ line, 69 say str( totcredit - totdebit, 9, 2 )         
            totcredit -= totdebit
            totdebit  := 0.00
            // TO AVOID ***** MARKS as the result of cumulating amount.
         endif

         /*
         if lCash
            totdebit := 0.00     // make the bal. zero only for CAsh A/C
            totcredit := 0.00
         endif
         DAILY SHEET SYSTEM ABANDONED.
         */
         line ++
         line ++
      else
         if !empty( date )
            @ line,  0 say date         
         endif
         @ line, 12 say details         
         if debit > 0
            @ line, 58 say str( debit, 9, 2 )         
         else
            @ line, 69 say str( credit, 9, 2 )         
         endif
         line ++
         totdebit  += debit
         totcredit += credit
         skip
      endif
   else
      skip
   endif
enddo
if !lByDate
   @ line, 58 say repli( '-', 9 )         
   @ line, 69 say repli( '-', 9 )         
   line ++
   @ line, 57 say str( totdebit, 10, 2 )          
   @ line, 68 say str( totcredit, 10, 2 )         
   line ++
   @ line, 40 say "TOTAL DUE :"         
   if totdebit > totcredit
      @ line, 57 say str( totdebit - totcredit, 10, 2 )         
   else
      @ line, 69 say str( totcredit - totdebit, 9, 2 )         
   endif
endif

line ++
line ++
line ++
line ++
@ line,  0 say padc( "**End Report**", 79 )         
set device to screen
set printer off
set printer to
close all
ontask()
FILEREAD( 1, 0, 23, 79, (RepPath+'DUELIST.TXT'), 'Dues List' )
return .t.
//-------------------

*+ EOF: DBK_REP.PRG
