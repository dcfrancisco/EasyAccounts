 //===================================================================
// EasyAccounts v2.5 LEDGER
// Optimized and relogiced for speed and
// accuracy.
//
// (C) Jasim A Basheer 2001
//
//
// 14-12-2002
//    Now gives priorities to Daybook transactions of the
//    same date than of cashbook.
//    ie, DAYBOOK 1000 DEBIT BANK INTEREST (to pay)
//        will be shown first than the
//        CASHBOOK 1000 EXPENSE BANK INTEREST (paid)
//
// Jan-Mar 2004
//    Introduced the SUBHEAD system in the application.
//    Modified LEdGER to display subheads also.
//
// 11-May-2004
//    Selective Ledger option. (Can select to include entries
//    only from Cashbook, Daybook or Bankbook or all)
//
//===================================================================

#include "std.ch"
#include "inkey.ch"

#define CSINCOME  iif(cashbook->action='D',cashbook->amount,0.00)
#define CSEXPENSE iif(cashbook->action='C',cashbook->amount,0.00)

#define DBDEBIT  iif(daybook->action='D',daybook->amount,0.00)
#define DBCREDIT iif(daybook->action='C',daybook->amount,0.00)

static lAType
static lAAcc
static lByDate
static lByPeriod
static lWithOps
static lWithAC
static lSummary

//------------------------------------------------
function ledger( lOpenDbf, nAutoId, nGroup, dFrom, dTo, llOp, cShow )

local nRec
local nSel
local nDueDays

private lAId        // To be used for FILTER (ClipMore cannot use LOCAL)
private nSubAcc := - 1                  // Also used in the FILTERs...
private dS      := date()
private dE      := date()

private LEDFile

close all

LEDFile := alltrim( jTempFile( 'LD_', 'DBF' ) )

dbcreate( LEDFile, ;
          { ;
          { 'DATE', 'D', 10, 0 }, ;
          { 'ACCOUNT', 'C', 45, 0 }, ;
          { 'DETAILS', 'C', 70, 0 }, ;
          { 'DEBIT', 'N', 10, 2 }, ;
          { 'CREDIT', 'N', 10, 2 }, ;
          { 'ENTRY', 'C', 15, 0 } ;
          } )

if nAutoId = NIL
   nRec     := l_initldg( lOpenDbf )
   nDueDays := duedays
   private SHOWWHAT := "ALL"

   recallldg()
   repldg( nRec )

   /*
  if nDuedays > 0
     clear typeahead
     nSel := jAlert( 'Ledger Report : ', { 'Complete', 'Due Amount' } )
     if nSel = 1
        repldg( nRec )
     elseif nSel = 2
        repdues( nRec )
     endif
  else
  */
else
   ontask( 'Generating Ledger...' )
   use subheads new index SUB_1,SUB_2,SUB_3
   use accounts new index ACC_1
   set order to 1
   seek nAutoId
   lAId     := nAutoId
   lAType   := rtrim( ltrim( type ) )
   lAAcc    := rtrim( ltrim( proper( account ) ) )
   nRec     := recno()
   nDueDays := duedays
   lByDate  := .f.
   lSummary := .f.
   lWithAc  := .t.

   if llOp == NIL
      lWithOps := .t.
   else
      lWithOps := llOp
   endif

   if nGroup != NIL
      lSummary := .t.
      nSubAcc  := nGroup
   else
      nSubAcc := - 1
   endif
   if dFrom != NIL
      dS        := dFrom
      dE        := dTo
      lByPeriod := .t.
   else
      lByPeriod := .f.
   endif

   if cShow = NIL
      private SHOWWHAT := "ALL"
   else
      private SHOWWHAT := cShow
   endif

   recallldg()
   repldg( nRec )
endif
ferase( LEDFile + '.DBF' )
ferase( LEDFile + '.CDX' )
return .t.

static function l_initldg( lOpenDbf )

local x
local y
local nChoice := 0

if lOpenDbf = NIL
   lOpenDbf := .t.
endif

lByDate   := .f.
lByPeriod := .f.
lWithOps  := .T.
lSummary  := .t.

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

@ 13, 09 clear to 18, 38
@ 13, 09 to 18, 38
@ 14, 10 say 'Include A/C Head <Y/N> ? '
lWithAC := opconfirm()
@ 15, 10 say 'Balance by Date  <Y/N> ? '
lByDate := opconfirm()
@ 16, 10 say 'By Period <Y/N> ? '         
lByPeriod := opconfirm()
if lByPeriod
   @ 17, 10 say 'With Op.Balance <Y/N> ? '         
   lWithOps := opconfirm()
   @ 19, 09 clear to 22, 38
   @ 19, 09 to 22, 38
   @ 20, 10 say "Starting : " get dS                          
   @ 21, 10 say "Ending   : " get dE valid ( dE >= dS )       
   read
else
   lWithOps := .t.
endif

setcolor( boxcolor() )

if accounts->group
   nChoice := 0
   do while nChoice == 0
      nChoice := menu_v( "Report Mode:", "Detailed - Entire A/C", ;
                         "Summary  - Entire A/C", ;
                         "By Sub A/C", ;
                         "Ungrouped Entries" )

   enddo
   if nChoice == 1
      nSubAcc  := - 1
      lSummary := .f.
   elseif nChoice == 2
      nSubAcc  := - 1
      lSummary := .t.
   elseif nChoice == 3
      sele subheads
      SubView()
      nSubAcc  := subheads->id
      lSummary := .t.
   elseif nChoice == 4
      nSubAcc  := 0
      lSummary := .t.
   endif
else
   nSubAcc := - 1
endif

sele accounts
x := accounts->( recno() )

if lOpenDbf
   dispscrn()
endif

ontask( 'Generating Ledger...' )
sele accounts
set order to 1
lAId   := id
lAType := rtrim( ltrim( type ) )
lAAcc  := rtrim( ltrim( proper( account ) ) )
set filter to
return x
//------------------------------------------
static function recallldg()

local nCashOp
local nBnkop
local nDayOp
local nOpBal  := 0.00

OnTask()            // Remove any existing plswait windows.

EUse( ( LEDFile ) )
zap

select accounts
if nSubAcc == - 1
   // If we are viewing the a/c of only one sub group, then the opening balance
   // of the entire a/c should not come.
   nOpBal := opbal
endif

JInitRep( "Ledger Statement (" + rtrim( ltrim( laType ) ) + " A/C)", ;
          .f., { || ShowRef() }, 'Organizing Report...', 79 )

if lWIthOps
   SHOWWHAT := "ALL"
endif

if !lByPeriod
   if rtrim( ltrim( type ) ) = 'Bank'
      if nSubAcc == - 1
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
         set filter to account == lAId
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to ( b_id == lAId ) .or. ( account == lAId )
         go top
      else
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
         set filter to account == lAId .and. acc_sub == nSubAcc
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. acc_sub == nSubAcc
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to ( b_id == lAId ) .or. ( account == lAId .and. acc_sub == nSubAcc )
         go top
      endif
   elseif subs( proper( rtrim( ltrim( account ) ) ), 1, 4 ) == 'Cash' .and. lAId = 1
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
      if nSubAcc == - 1
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
         set filter to account == lAId
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to account == lAId
         go top
      else
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
         set filter to account == lAId .and. acc_sub == nSubAcc
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. acc_sub == nSubAcc
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to account == lAId .and. acc_sub == nSubAcc
         go top
      endif
   endif
else
   if lWithOps
      if rtrim( ltrim( type ) ) = 'Bank'

         if nSubAcc == - 1
            use cashbook new index CSH_2,CSH_1
            set filter to account == lAId
            set scopebottom to ( dS - 1 )
            sum all CSINCOME - CSEXPENSE to nCashOp
            set scope to

            use daybook new index DBK_2,DBK_1
            set filter to account == lAId
            set scopebottom to ( dS - 1 )
            sum all DBDEBIT - DBCREDIT to nDayOp
            set scope to

            use bankbook new index BNK_2,BNK_1
            set filter to ( b_id == lAId ) .or. ( account == lAId )
            set scopebottom to ( dS - 1 )
            sum all BkBal() to nBnkOp
            set scope to
         else
            use cashbook new index CSH_2,CSH_1
            set filter to account == lAId .and. acc_sub == nSubAcc
            set scopebottom to ( dS - 1 )
            sum all CSINCOME - CSEXPENSE to nCashOp
            set scope to

            use daybook new index DBK_2,DBK_1
            set filter to account == lAId .and. acc_sub == nSubAcc
            set scopebottom to ( dS - 1 )
            sum all DBDEBIT - DBCREDIT to nDayOp
            set scope to

            use bankbook new index BNK_2,BNK_1
            set filter to ( b_id == lAId ) .or. ( account == lAId .and. acc_sub == nSubAcc )
            set scopebottom to ( dS - 1 )
            sum all BkBal() to nBnkOp
            set scope to
         endif
      elseif subs( proper( rtrim( ltrim( account ) ) ), 1, 4 ) == 'Cash' .and. lAId == 1

         use cashbook new index CSH_2,CSH_1
         set scopebottom to ( dS - 1 )
         sum all iif( action = 'C', amount, - 1 * amount ) to nCashOp
         set scope to

         use daybook new index DBK_2,DBK_1
         set filter to account == lAId
         set scopebottom to ( dS - 1 )
         sum all DBDEBIT - DBCREDIT to nDayOp
         set scope to

         use bankbook new index BNK_2,BNK_1
         set filter to account == lAId
         set scopebottom to ( dS - 1 )
         sum all BkBal() to nBnkOp
         set scope to
      else
         if nSubAcc == - 1
            use cashbook new index CSH_2,CSH_1
            set filter to account == lAId
            set scopebottom to ( dS - 1 )
            sum all CSINCOME - CSEXPENSE to nCashOp
            set scope to

            use daybook new index DBK_2,DBK_1
            set filter to account == lAId
            set scopebottom to ( dS - 1 )
            sum all DBDEBIT - DBCREDIT to nDayOp
            set scope to

            use bankbook new index BNK_2,BNK_1
            set filter to account == lAId
            set scopebottom to ( dS - 1 )
            sum all BkBal() to nBnkOp
            set scope to
         else
            use cashbook new index CSH_2,CSH_1
            set filter to account == lAId .and. acc_sub == nSubAcc
            set scopebottom to ( dS - 1 )
            sum all CSINCOME - CSEXPENSE to nCashOp
            set scope to

            use daybook new index DBK_2,DBK_1
            set filter to account == lAId .and. acc_sub == nSubAcc
            set scopebottom to ( dS - 1 )
            sum all DBDEBIT - DBCREDIT to nDayOp
            set scope to

            use bankbook new index BNK_2,BNK_1
            set filter to account == lAId .and. acc_sub == nSubAcc
            set scopebottom to ( dS - 1 )
            sum all BkBal() to nBnkOp
            set scope to
         endif
      endif

      sele bankbook
      use
      sele cashbook
      use
      sele daybook
      use

      nOpBal += ( nBnkOp + nCashOp + nDayOp )

   else
      nOpBal := 0.00
   endif

   sele accounts

   if rtrim( ltrim( type ) ) = 'Bank'
      if nSubAcc == - 1
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
         set filter to account == lAId .and. ( date >= dS .and. date <= dE )
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. ( date >= dS .and. date <= dE )
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to ( b_id == lAId .or. account == lAId ) .and. ( date >= dS .and. date <= dE )
         go top
      else
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
         set filter to account == lAId .and. ( date >= dS .and. date <= dE ) .and. acc_sub == nSubAcc
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. ( date >= dS .and. date <= dE ) .and. acc_sub == nSubAcc
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to ( b_id == lAId .or. account == lAId ) .and. ( date >= dS .and. date <= dE )
         go top
      endif
   elseif subs( proper( rtrim( ltrim( account ) ) ), 1, 4 ) == 'Cash' .and. lAId == 1
      use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
      set filter to ( date >= dS .and. date <= dE )
      go top
      use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
      set filter to account == lAID .and. ( date >= dS .and. date <= dE )
      go top
      use bankbook new index BNK_1,BNK_2,BNK_3
      set filter to account == lAId .and. ( date >= dS .and. date <= dE )
      go top
   else
      if nSubAcc == - 1
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
         set filter to account == lAId .and. ( date >= dS .and. date <= dE )
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. ( date >= dS .and. date <= dE )
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to account == lAId .and. ( date >= dS .and. date <= dE )
         go top
      else
         use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4
         set filter to account == lAId .and. ( date >= dS .and. date <= dE ) .and. acc_sub == nSubAcc
         go top
         use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
         set filter to account == lAId .and. ( date >= dS .and. date <= dE ) .and. acc_sub == nSubAcc
         go top
         use bankbook new index BNK_1,BNK_2,BNK_3
         set filter to account == lAId .and. ( date >= dS .and. date <= dE ) .and. acc_sub == nSubAcc
         go top
      endif
   endif
endif

use accounts new ALIAS accFinder index ACC_1
use daybook new ALIAS dbkFinder index DBK_3

if nOpBal != 0      // may be -ve or +ve, we want it. but we dont want zERO!
   sele ( LEDFile )
   append blank
   field->details := ' OPENING BALANCE'
   if nOpBal > 0
      field->debit := nOpBal
   else
      field->credit := abs( nOpBal )
   endif
   field->entry := 'OPBAL'
endif

plswait( .f. )

if SHOWWHAT == 'ALL' .or. SHOWWHAT == 'DAYBOOK'
   JNewPBar( "Processing Daybook..." )
   sele daybook
   JDgSetPBar( cmFiltCount() )
   do while .not. eof()
      if ! deleted()
      if lWithAc
        if daybook->action=='D'
           sele dbkFinder
           seek daybook->id+1
        elseif daybook->action=='C'
           sele dbkFinder
           seek daybook->id-1
        endif
      endif
      sele ( LEDFile )
      appe blank
      field->date := daybook->date
      if ( !lSummary ) .and. ( daybook->ACC_SUB != 0 )
         sele subheads
         seek daybook->ACC_SUB
         sele ( LEDFile )
         field->details := '[' + alltrim( subheads->subhead ) + ']'
      endif
      field->details := alltrim( details ) + " " + alltrim( proper( daybook->details ) )

      if lWithAc
        sele accFinder
        seek dbkFinder->account
        sele (LEDFILE)
        field->account := accFinder->account
      endif

      field->debit   := iif( daybook->action = 'D', daybook->amount, 0.00 )
      field->credit  := iif( daybook->action = 'C', daybook->amount, 0.00 )
      field->entry   := 'DB' + str( daybook->id, 5, 0 ) + str( daybook->inv_id, 5, 0 ) + subs( upper( daybook->type ), 1, 3 )
      endif

      sele daybook
      skip
      JDgIncrPBar()
   enddo
endif

if SHOWWHAT == 'ALL' .or. SHOWWHAT == 'CASHBOOK'
   sele cashbook
   JNewPBar( "Processing Cashbook..." )
   JDgSetPBar( cmFiltCount() )

   do while .not. eof()
      if ! deleted()
      sele ( LEDFile )
      appe blank
      field->date := cashbook->date
      if ( !lSummary ) .and. ( cashbook->ACC_SUB != 0 )
         sele subheads
         seek cashbook->ACC_SUB
         sele ( LEDFile )
         field->details := '[' + alltrim( subheads->subhead ) + ']'
      endif
      field->details := alltrim( details ) + " " + alltrim( proper( cashbook->details ) )

      if lWithAc
        if lAId != 1
           field->account := "Cash"
        else
            sele accFinder
            seek cashbook->account
            sele (LEDFILE)
            field->account := accFinder->account
        endif
      endif

      if lAId == 1  // Cash
         field->credit := iif( cashbook->action = 'D', cashbook->amount, 0.00 )
         field->debit  := iif( cashbook->action = 'C', cashbook->amount, 0.00 )
      else
         field->debit  := iif( cashbook->action = 'D', cashbook->amount, 0.00 )
         field->credit := iif( cashbook->action = 'C', cashbook->amount, 0.00 )
      endif
      field->entry := 'CS' + str( cashbook->id, 10, 0 )
      endif
      sele cashbook
      skip
      JDgIncrPBar()
   enddo
endif

if SHOWWHAT == 'ALL' .or. SHOWWHAT == 'BANKBOOK'
   sele bankbook
   JNewPBar( "Processing Bank Entries..." )
   JDgSetPBar( cmFiltCount() )

   do while .not. eof()
      if ! deleted()
      sele ( LEDFile )
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
      sele ( LEDFile )
      if ( !lSummary ) .and. ( bankbook->ACC_SUB != 0 )
         sele subheads
         seek bankbook->ACC_SUB
         sele ( LEDFile )
         field->details := '[' + alltrim( subheads->subhead ) + ']'
      endif
      field->details := alltrim( details ) + " " + alltrim( proper( y + '  ' + bankbook->details ) )

      if lWithAc
        sele accFinder
        seek iif( rtrim(ltrim(lAtype)) == 'Bank', bankbook->account, bankbook->b_id)
        sele (LEDFILE)
        field->account := accFinder->account
      endif

      if lAType = 'Bank'
         field->debit  := iif( bankbook->action = 'C', bankbook->amount, 0.00 )
         field->credit := iif( bankbook->action = 'D', bankbook->amount, 0.00 )
      else
         field->debit  := iif( bankbook->action = 'D', bankbook->amount, 0.00 )
         field->credit := iif( bankbook->action = 'C', bankbook->amount, 0.00 )
      endif
      field->entry := 'BK' + str( bankbook->id, 10, 0 )
      endif

      sele bankbook
      skip
      JDgIncrPBar()
   enddo
endif

close all

return .T.

static function repldg( x )

local line      := 1
local lCash
local dDate
local totdebit  := 0.00
local totcredit := 0.00
local lSupp, lDetShowed := .f.
eUse( LEDFile )
indexbar( LEDFile, 'DATE' )
close all
if nSubAcc != - 1
   use subheads new index SUB_1
   seek nSubAcc
endif
use accounts new
go x
eUse( LEDFile )
set index to ( LEDFile )
go top

jNextLine()

if lAID != 0 .and. lAid != 1
   jAddData( 0, padc( 'Ledger A/C', 79 ) )
   jNextLine()
   sele accounts
   jAddData( 0, padc( rtrim( ltrim( account ) ), 79 ) )
   jNextLine()
   if nSubAcc != - 1
      sele subheads
      if nSubAcc == 0
         jAddData( 0, padc( 'Ungrouped Entries', 79 ) )
      else
         jAddData( 0, padc( rtrim( ltrim( 'SUB A/C: ' + alltrim( subheads->subhead ) ) ), 79 ) )
      endif
      jNextLine()
      use
   endif
elseif lAID = 1
   jAddData( 0, padc( 'CASH BOOK', 79 ) )
   jNextLine()
endif
sele accounts
if rtrim( ltrim( account ) ) == 'Cash'
   lCash := .t.
else
   lCash := .f.
endif

if lByPeriod
   jAddData( 0, padc( dtoc( dS ) + ' TO ' + dtoc( dE ), 79 ) )
   jNextLine()
endif

jNextLine()
if SHOWWHAT != 'ALL'
   jAddData( 0, padc( '[ Showing only ' + proper( SHOWWHAT ) + ' entries ]', 79 ) )
   jNextLine()
endif
jAddData( 0, repli( '-', 77 ) )
jNextLine()
jAddData( 0, "Date" )
jAddData( 11, "Transaction" )
if alltrim( upper( accounts->type ) ) == 'BANK'
   jAddData( 55, "Deposit" )
   jAddData( 66, "Withdrawal" )
else
   jAddData( 55, "Debit" )
   jAddData( 66, "Credit" )
endif
jNextLine()
jAddData( 0, repli( '-', 77 ) )
jNextLine()
sele ( LEDFile )
do while .not. eof()
   if !deleted()
      if lByDate
         dDate := date
         do while dDate == date .and. ( !eof() )
            lDetShowed := .f.
            if !empty( date )
               jAddData( 0, date )
            endif
            if ! lWithAc
               lDetShowed := .t.
               jAddData( 11, subs( alltrim( details ), 1, 41 ) )
            elseif lWithAc
               if len(alltrim(account))+len(alltrim(details))+3 <= 41
                 jAddData( 11, subs(alltrim(account)+iif(!empty(details),' - '+alltrim(details),''),1,41) )
                 lDetShowed := .t.
               else
                 jAddData( 11, subs(alltrim(account),1,41) )
                 lDetShowed := .f.
               endif
            endif
            if debit > 0
               jAddData( 54, str( debit, 10, 2 ), ENTRY )
            else
               jAddData( 65, str( credit, 10, 2 ), ENTRY )
            endif
            jNextLine()
            if ! lDetShowed
              jAddData(11, '['+alltrim(details)+']' )
              jNextLine()
            endif
            totdebit  += debit
            totcredit += credit
            skip
         enddo
         jAddData( 55, repli( '-', 9 ) )
         jAddData( 66, repli( '-', 9 ) )
         jNextLine()
         jAddData( 54, str( totdebit, 10, 2 ) )
         jAddData( 65, str( totcredit, 10, 2 ) )
         jNextLine()
         jAddData( 40, "Date Balance :" )
         if totdebit > totcredit
            jAddData( 54, str( totdebit - totcredit, 10, 2 ) )
            totdebit  -= totcredit
            totcredit := 0.00
         else
            jAddData( 65, str( totcredit - totdebit, 10, 2 ) )
            totcredit -= totdebit
            totdebit  := 0.00
         endif
         jNextLine()
         jNextLine()
      else
         lDetShowed := .f.

         if !empty( date )
            jAddData( 0, date )
         endif
            if ! lWithAc
               lDetShowed := .t.
               jAddData( 11, subs( alltrim( details ), 1, 41 ) )
            elseif lWithAc
               if len(alltrim(account))+len(alltrim(details))+3 <= 41
                 jAddData( 11, subs(alltrim(account)+iif(!empty(details),' - '+alltrim(details),''),1,41) )
                 lDetShowed := .t.
               else
                 jAddData( 11, subs(alltrim(account),1,41) )
                 lDetShowed := .f.
               endif
            endif

         if debit > 0
            jAddData( 54, str( debit, 10, 2 ), ENTRY )
         else
            jAddData( 65, str( credit, 10, 2 ), ENTRY )
         endif
         jNextLine()
            if ! lDetShowed
              jAddData(11, '['+alltrim(details)+']' )
              jNextLine()
            endif
         totdebit  += debit
         totcredit += credit
         skip
      endif
   else
      skip
   endif
   if !jGoReport( inkey() )
      jNextLine()
      jNextLine()
      jAddData( 5, '** Report aborted by user **' )
      jNextLine()
      jNextLine()
      close all
      jEndReport()
      return .f.
   endif
enddo
if !lByDate
   jAddData( 55, repli( '-', 9 ) )
   jAddData( 66, repli( '-', 9 ) )
   jNextLine()
   jAddData( 54, str( totdebit, 10, 2 ) )
   jAddData( 65, str( totcredit, 10, 2 ) )
   jNextLine()
   jAddData( 40, "Net Balance :" )
   if totdebit > totcredit
      jAddData( 54, str( totdebit - totcredit, 10, 2 ) )
   else
      jAddData( 65, str( totcredit - totdebit, 10, 2 ) )
   endif
endif

jNextLine()
jNextLine()
jNextLine()
jNextLine()
jAddData( 0, padc( "**End Report**", 79 ) )

close all
ontask()

if lastkey() != K_ESC
   jEndReport()
endif

return .t.
//-------------------
static function splitdbk()

local nOpBal := 0.00
eUse( LEDFile )
indexbar( LEDFile, 'DATE' )
go top
ShowPBar( "Arranging transactions by date..." )
do while .not. eof()
   if date < dS
      nOpBal += ( debit - credit )
      delete
      skip
   elseif date == dS .and. rtrim( ltrim( upper( details ) ) ) == 'OPENING BALANCE'
      nOpBal += ( debit - credit )
      delete
      skip
   elseif date > dE
      delete
      skip
   elseif date >= dS .and. date <= dE
      skip
   endif
   IncrPBar()
enddo
if lWithOps
   append blank
   field->details := ' OPENING BALANCE AS OF ' + dtoc( dS )
   if nOpBal > 0
      field->debit := nOpBal
   elseif nOpBal < 0
      field->credit := abs( nOpBal )
   endif
endif
close all
HidePBar()
return .t.
//----------------
static function cmbineledg()

close all
if comp_add = 'Kollam'
   set default to ( dir( 'Kollam' ) )
   use (LEDFile) new
   append from ( dir( 'Pulliman' ) + '\' + LEDFile )
   append from ( dir( 'Graphics' ) + '\' + LEDFile )
elseif comp_add = 'Pulliman Jun.'
   set default to ( dir( 'Pulliman' ) )
   use ledger new
   append from ( dir( 'Kollam' ) + '\' + LEDFile )
   append from ( dir( 'Graphics' ) + '\' + LEDFile )
elseif comp_add = 'Graphics'
   set default to ( dir( 'Graphics' ) )
   use ledger new
   append from ( dir( 'Pulliman' ) + '\' + LEDFile )
   append from ( dir( 'Kollam' ) + '\' + LEDFile )
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
local cAccName  := ""
eUse( LEDFile )
indexbar( LEDFile, 'DATE' )
close all
use accounts new
go x
lSupp := ( type = 'Sundry Creditor' )
eUse( LEDFile )
set index to ( LEDFile )
go top
setprc( 0, 0 )
sele ( LEDFile )
pack
go top
do while .not. eof()
   if ( ( LEDFile )->date < date() - accounts->duedays )    // Tran. earlier than due period. ( It is due )
      nDueAmnt += debit - credit
      delete
   else             // Tran. in,between or after due period
      if ( date() - accounts->duedays < ( LEDFile )->date )                     // Tran. not due
         if !( ( lSupp .and. Debit > Credit ) .or. ( !lSupp .and. Credit > debit ) )
            // Check whether it is a payment. (If it is, the amount should be reduced from the due.)
            delete  // It is a purchase which is not due
         endif
      else          // Tran. DUE!!!
      endif         // Do nothing leave the record as it is.
   endif
   sele ( LEDFile )
   skip
enddo

/*
        nDueAmnt += debit - credit
  if ! (date()-(LEDFile)->date > accounts->duedays)
    if (lSupp .and. (debit>credit)) .or. (.not. lSupp .and. (credit>debit))
       delete
    endif
  else
    nDueAmnt += debit-credit
  endif
  skip
enddo
*/

/*
  if (date()-accounts->duedays - (LEDFile)->date) > accounts->duedays  // No bills 10 days before.
    if (LEDFile)->date <= date()-accounts->duedays
      nDueAmnt += debit-credit
    else
      delete
    endif
  else
    if (lSupp .and. (debit>credit)) .or. (.not. lSupp .and. (credit >debit))
       delete
    endif
  endif
  skip
*/

sele ( LEDFile )
pack
go top
if nDueAmnt != 0
   append blank
   field->date    := date() - accounts->duedays
   field->details := 'PREVIOUS DUEÿ'    // there is a chr(255) to make it distinct.
   if nDueAmnt > 0
      field->debit := nDueAmnt
   elseif nDueamnt < 0
      field->credit := abs( nDueAmnt )
   endif
endif
/*
copy structure to ldg1
eUse('ldg1')
sele (LEDFile)
set order to 0
go bott
skip -4
appe rest from (LEDFile) for details='PREVIOUS DUEÿ'  // there is a chr(255) to make it distinct.
go top
appe all from (LEDFile) for details != 'PREVIOUS DUEÿ'  // there is a chr(255) to make it distinct.
*/
cAccName := accounts->account
close all
eUse( LEDFile )
indexbar( LEDFile, 'DATE' )
go top

set device to printer
set printer to ( RepPath + 'DUELIST.TXT' )
set printer on
@ line,  0 say padc( 'Wintech Systems & Services', 79 )         
line ++
@ line,  0 say padc( comp_add, 79 )         
line ++
@ line,  0 say padc( 'Dues List', 79 )         
line ++
line ++
@ line,  0 say padc( rtrim( ltrim( cAccName ) ), 79 )         
if subs( proper( rtrim( ltrim( cAccName ) ) ), 1, 4 ) == 'Cash'
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
FILEREAD( 1, 0, 23, 79, RepPath + "DUELIST.TXT", 'Dues List' )
return .t.
//-------------------
function ShowRef

local cSaleNo   := ""
local cPurchNo  := ""
local dPrevDate := dDate

dispbegin()

if subs( dgLine(), 13, 13 ) == 'Sales Bill : '
   cSaleNo := alltrim( subs( dgLine(), at( 'Bill :', dgLine() ) + 7, 6 ) )
elseif subs( dgLine(), 13, 11 ) == 'Transfer S/'
   cSaleNo := alltrim( subs( dgLine(), at( ' S/', dgLine() ) + 3, 6 ) )
elseif subs( dgLine(), 13, 11 ) == 'Standby  S/'
   cSaleNo := alltrim( subs( dgLine(), at( ' S/', dgLine() ) + 3, 6 ) )
elseif subs( dgLine(), 13, 12 ) == 'Payment Bill'
   cPurchNo := alltrim( subs( dgLine(), at( 'Srl :', dgLine() ) + len( 'Srl :' ), 6 ) )
elseif subs( dgLine(), 13, 13 ) == 'Purchase Bill'
   cPurchNo := alltrim( subs( dgLine(), at( 'Srl :', dgLine() ) + len( 'Srl :' ) + 1, 6 ) )
elseif subs( dgLine(), 13, 11 ) == 'Transfer P/'
   cPurchNo := alltrim( subs( dgLine(), at( ' P/', dgLine() ) + 3, 6 ) )
elseif subs( dgLine(), 13, 11 ) == 'Standby  P/'
   cPurchNo := alltrim( subs( dgLine(), at( ' P/', dgLine() ) + 3, 5 ) )
endif

jSaveEnv()
close all

altd( .t. )

if val( cSaleNo ) <> 0
   keyboard ( cSaleNo + chr( K_ENTER ) )
   Sales( .T. )
elseif val( cPurchNo ) <> 0
   keyboard ( cPurchNo + chr( K_ENTER ) )
   Purchase( .T. )
else
   if subs( jRefData(), 1, 2 ) == 'CS'
      entr_date( ctod( subs( dgLine(), 1, 10 ) ) )
      cshEntry( val( subs( jRefData(), 3 ) ) )
   elseif subs( jRefData(), 1, 2 ) == 'DB'
      entr_date( ctod( subs( dgLine(), 1, 10 ) ) )
      if at( 'SER', upper( jRefData() ) ) != 0
         altd( .T. )
         Service( val( subs( jRefData(), 8, 5 ) ) )
         // That part is the INV_ID field which is actually the Service no.
         // the format for a Daybook entry's string is:
         //  entry := 'DB' + str( daybook->id, 5, 0 ) + str(daybook->inv_id,5,0) + upper( daybook->type )
      else
         altd( .t. )
         dbkView( val( subs( jRefData(), 3, 5 ) ) )
      endif
   elseif subs( jRefData(), 1, 2 ) == 'BK'
      entr_date( ctod( subs( dgLine(), 1, 10 ) ) )
      bankEntry( val( subs( jRefData(), 3 ) ) )
   endif
endif

close all
jRestEnv()
getlist := {}

entr_date( dPrevDate )
clear typeahead

dispend()
return .t.
//=============
static function BkBal

local nRet := 0.00
if ( bankbook->account == lAId .and. bankbook->action = 'D' ) .or. ;
     ( bankbook->b_id == lAId .and. bankbook->action = 'C' )
   nRet += amount
elseif ( bankbook->account == lAId .and. bankbook->action = 'C' ) .or. ;
            ( bankbook->b_id == lAId .and. bankbook->action = 'D' )
   nRet -= amount
endif
return nRet

*+ EOF: LEDGER.PRG
