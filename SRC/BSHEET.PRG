/*
#
#     Account sub-system REPORTS - BALANCE Sheet
#                        for EasyAccounts v4.0
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

static ASSETDb
static LIABDb
static BSheetDB

function BSheet(lSummary)

local lAId
local lAAcc
local nRec   := 1
local nTemp1
local nTemp2
local nTot   := 0.00
local line   := 1
local cType,cDescType

local nDTotal
local nCTotal
local nD
local nC
local nD1
local nC1
local nTypBal  := 0.00
local nAssets  := 0.00
local nLiabs   := 0.00, nStock, lStockDisplayed := .f.
local lOldPBar := MakePBarActive( .t. )

private dTDate := jGetDate( 'Balance Sheet As On :' )
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

sele accounts

ShowPBar("Generating Balance Sheet...")
SetPBarCount( reccount() )
nDTotal := 0.00
do while .not. eof()

   if _BType()
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

      select bankbook                   // As a transacted Bank
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

      select bankbook                   // As an A/C in transaction
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
   endif
   sele accounts
   skip
   IncrPBar()

enddo

nDTotal := 0.00
nCTotal := 0.00
nD1     := 0.00
nC1     := 0.00
close all

HidePBar()

eUse( "acbals" )
indexbar( "acbals", "type+account" )    // index on type+account to acbals.ntx

plswait(.t.,'Processing account balances...')

ASSETDb := jTempFile( 'ASSET', 'DBF' )
copy all for _BS_Type('ASSET') to (ASSETDb)
sele acbals
go top
LIABDb := jTempFile( 'LIAB', 'DBF' )
copy all for _BS_Type('LIAB') to (LIABDb)

BSheetDb := jTempFile( 'BSHEET', 'DBF' )
dbcreate( BSheetDb, { ;
                      { 'LIAB', 'C', 36, 0 }, ;
                      { 'ASSET', 'C', 36, 0 }, ;
                      { 'L_ID', 'N', 6, 0 }, ;
                      { 'A_ID', 'N', 6, 0 } } )

nStock := _BCostOfGoods()

close all

// === ASSETS
//-------------------

EUse( BSheetDb )
EUse( ASSETDb )
do while .not. eof()
   nTypBal := 0.00

   cType := type
   cDescType := __aTypeDescs[ascan(__aTypes, alltrim(cType))]
   sele ( BSheetDb )
   append blank
   if !lSummary
      append blank
      field->ASSET := padc( '[ ' + alltrim( upper( cDescType ) ) + ' ]', 36 )
      skip
      if (!lStockDisplayed) .and. nStock > 0 .and.;
         alltrim(upper(cDescType)) == 'ASSETS - CURRENT'

         lStockDisplayed := .t.
         append blank
         field->ASSET := padr('Total Stock Value',22)+'  '+str(nStock,11,2)
         skip
         nTypBal += nStock
      endif
   else
      field->ASSET := upper( cDescType )
   endif

   sele ( ASSETDb )

   do while cType == type .and. ( !eof() )
      sele ( BSheetDb )
      if !lSummary
         append blank
         field->ASSET := subs( ( ASSETDb )->ACCOUNT, 1, 22 ) + '  ' + str( ( ASSETDb )->balance, 11, 2 )
         field->A_ID  := ( ASSETDb )->id
      endif
      nTypBal += ( ASSETDb )->BALANCE
      sele ( ASSETDb )
      skip
   enddo
   sele ( BSheetDb )
   if lSummary
      field->ASSET := subs( ASSET, 1, 22 ) + '  ' + str( nTypBal, 11, 2 )
      //append blank
   else
      append blank
      field->ASSET := space( 25 ) + repl( '-', 10 )
      append blank
      field->ASSET := padr( '   Total ->', 22 ) + '  '+ str( nTypBal, 11, 2 )
   endif
   nAssets += nTypBal

   sele ( ASSETDb )
enddo

if lSummary .and. nStock > 0
  sele ( BSheetDb )
  append blank
  field->ASSET := padr("COST OF GOODS", 22)+'  '+str(nStock,11,2)
  nAssets += nStock
endif

sele (ASSETDb)

// == LIABILITES
//-------------------

sele ( BSheetDb )
go top
EUse( LIABDb )
do while .not. eof()
   cType := type
   sele ( BSheetDb )

   if eof()
      append blank
   endif

   if !lSummary
      field->LIAB := padc( '[ ' + alltrim( upper( CTYPE ) ) + ' ]', 36 )
      skip
   else
      field->LIAB := upper( cType )
   endif

   sele ( LIABDb )

   nTypBal := 0.00

   do while cType == type .and. ( !eof() )
      sele ( BSheetDb )
      if !lSummary
         if eof()
            append blank
         endif
         field->LIAB := subs( ( LIABDb )->ACCOUNT, 1, 22 ) + '  ' + str( ( LIABDb )->balance * - 1, 11, 2 )
         field->L_ID := ( LIABDb )->id
         sele ( BSheetDb )
         skip
      endif
      nTypBal += ( LIABDb )->BALANCE

      sele ( LIABDb )
      skip
   enddo
   sele ( BSheetDb )
   if lSummary
      field->LIAB := subs( LIAB, 1, 22 ) + '  ' + str( nTypBal * - 1, 11, 2 )
      skip
   else
      skip
      if eof()
         append blank
      endif
      field->LIAB := space( 25 ) + repl( '-', 10 )
      skip
      if eof()
         append blank
      endif
      field->LIAB := padr( '   Total ->', 22 ) + '  ' + str( nTypBal * - 1, 11, 2 )
   endif
   nLiabs += ( nTypBal * - 1 )

   sele ( LIABDb )

enddo
close all
ferase( LIABDB + '.DBF' )
ferase( ASSETDB + '.DBF' )

EUse( BSheetDB )
Plswait(.f.)

BS_Disp( lSummary, nLiabs, nAssets, dTDate )
close all
ferase( BSHEETDB + '.DBF' )

MakePBarActive( lOldPBar )
return nil
//------------------------------------------------------------------
static function _BType

return _BS_Type( 'LIAB' ) .or. _BS_Type( 'ASSET' )
// If this a/c is to come in the bal. sheet, it should be either an ASSET or LIAB.
//------------------------------------------------------------------
static function _BS_Type( cB )

local cType := alltrim( upper( type ) )                     // can either be acbals or account (for _BType uses account.dbf)
if cB == 'ASSET'
   return cType == 'ASSETS - CURRENT' .or. cType == 'FIXED ASSETS' .or. cType = 'BANK' .or. cType = 'DEBTOR' .or. cType = 'STAFF LOAN' .or. cType = 'ASSOCIATE' .or. cType == 'DEPOSIT'
endif
// Then it is naturally liability otherwise..
return cType = 'SUNDRY CREDITOR' .or. cType == 'CAPITAL' .or. cType == 'TAX COLLECTED'
//-----------------------------------------------------------------------------------------
static function BS_Disp( lSummary, nLiabs, nAssets, dBDate )

local oBrowse
local oColumn
local oScreen := savescreen( 1, 0, 23, 79 )
local oMaxLength := 78, nLine := 1, lToFile := .f.
local x
if lSummary
   @ 04,  0 clear to 20, 79
   @ 04,  0 to 20, 79
   oBrowse := TbrowseDb( 09, 01, 16, 78 )
   setcolor( scrcolor() )
   @ 05,  1 say padc( 'Balance Sheet - Summary (As on '+dtoc(dBDate)+')', 78 )
   setcolor( boxcolor() )
   footline( 06, 1, 78 )
   @ 07,  1 say padc( 'Liabilities', 34 )         
   @ 07, 36 say padc( 'Assets', 34 )              
   footline( 08, 1, 78 )
   footline( 17, 1, 78 )
   setcolor( yBoxColor( 1 ) )
   @ 18, 23 say str( nLiabs, 15, 2 )
   @ 18, 60 say str( nAssets, 15, 2 )
   setcolor( boxcolor() )
else
   @ 01,  0 clear to 23, 79
   @ 01,  0 to 23, 79
   oBrowse := TBrowseDb( 06, 01, 20, 78 )
   setcolor( scrcolor() )
   @ 02,  1 say padc( 'Balance Sheet - Detailed (As on '+dtoc(dBDate)+')', 78 )         
   setcolor( boxcolor() )
   footline( 03, 1, 78 )
   @ 04,  1 say padc( 'Liabilities', 34 )         
   @ 04, 36 say padc( 'Assets', 34 )              
   footline( 05, 1, 78 )
   footline( 21, 1, 78 )
   setcolor( yBoxColor( 1 ) )
   @ 22, 23 say str( nLiabs, 15, 2 )
   @ 22, 60 say str( nAssets, 15, 2 )
   setcolor( boxcolor() )
endif
oColumn := tbcolumnNew( "", { || liab } )
oBrowse:addcolumn( oColumn )
oColumn := tbcolumnNew( "", { || asset } )
oBrowse:addcolumn( oColumn )
x := 0
do while x != K_ESC
   oBrowse:forcestable()
   x := inkey( 0 )
   do case
   case x == K_ENTER
      BS_Drill( lSummary, oBrowse:colpos, dBDate )
   case x == K_DOWN
      oBrowse:down()
   case x == K_UP
      oBrowse:up()
   case x == K_LEFT
      oBrowse:left()
   case x == K_RIGHT
      oBrowse:right()
   case x == K_PGDN
      oBrowse:pageDown()
   case x == K_PGUP
      oBrowse:pageUp()
   case x == K_CTRL_PGDN
      oBrowse:goBottom()
   case x == K_CTRL_PGUP
      oBrowse:goTop()
   case x == K_HOME
      oBrowse:home()
   case x == K_END
      oBrowse:end()
   case x == K_CTRL_HOME
      oBrowse:panHome()
   case x == K_CTRL_END
      oBrowse:panEnd()
   case x == K_CTRL_LEFT
      oBrowse:panLeft()
   case x == K_CTRL_RIGHT
      oBrowse:panRight()
   case x == K_F8
      vs_calc()
   case x == K_F9
      calendar()
   case x == K_F5
      pop_menu()
   endcase
enddo
if jAlert('Print Balance Sheet ?', {'Yes','No'}) == 1
 setprc(0,0)
 lToFile := .f.
 if ! prncheck()
   set device to printer
   set printer to BSHEET.TXT
   set printer on
   lToFile := .t.
 else
   set printer to
   set device to printer
   set printer on
 endif

    nLine := 1
      if !empty( eaHead )
         @ nLine, 0 say padc( eaHead, 78 )
         nLine++
      endif
      if !empty( eaTitle )
         @ nLine, 0 say  padc( eaTitle, 78 ) 
         nLine++
      endif
      if eaShowAdd
         if !empty( eaAdd1 )
            @ nLine, 0 say  padc( eaAdd1, 78 )
            nLine++
         endif
         if !empty( eaAdd2 )
            @ nLine, 0 say  padc( eaAdd2, 78 )
            nLine++
         endif
         if !empty( eaAdd3 )
            @ nLine, 0 say  padc( eaAdd3, 78 )
            nLine++
         endif
      endif
      nLine++
      if lSummary
        @ nLine,  0 say padc( 'Balance Sheet - Summary (As on '+dtoc(dBDate)+')', 78 )
      else
        @ nLine,  0 say padc( 'Balance Sheet - Detailed (As on '+dtoc(dBDate)+')', 78 )
      endif
      nLine++
      @ nLine, 0 say repli('-',78)
      nLine++
      @ nLine, 0 say padc('Liabilities',34)
      @ nLine,35 say padc('Assets',33)
      nLine++
      @ nLine, 0 say repli('-',78)
      nLine++
      go top
      do while .not. eof()
         @ nLine, 0 say liab
         @ nLine,38 say asset
         nLine++
         skip
      enddo
      @ nLine, 0 say repli('=',78)
      nLine++
      @ nLine, 5 say "Total --> "
      @ nLine,21 say str( nLiabs, 15, 2 )
      @ nLine,58 say str( nAssets, 15, 2 )
      nLine++
      @ nLine, 0 say repli('-',78)
      nLine++
      nLine++
      nLine++
      @ nLine, 0 say ""
      if !lToFile
        eject
      endif
  set device to screen
  set printer off
  set printer to
  close all
  if lToFile
    fileread(1,0,23,79,'BSHEET.TXT','Balance Sheet')
  endif
endif

close all
restscreen( 1, 0, 23, 79, oScreen )
return .t.
//---------------------------------------------------------------------
static function BS_Drill( lSummary, nPos, dDate )

local nId
local cHead
if !lSummary
   if nPos == 1     // Liabili
      nId := ( BSheetDb )->l_id
   elseif nPos == 2                     // Asset
      nId := ( BSheetDb )->a_id
   endif
   if nId != 0
      jSaveEnv()
      close all
      ledger( .t., nId )
      close all
      jRestEnv()
   elseif nId == 0 .and. nPos == 2 // Assets
      if subs(asset,1,17) == 'Total Stock Value'
         jSaveEnv()
         close all
         sup_costrep()
         close all
         jRestEnv()
      endif
   endif                
elseif lSummary
   if nPos == 1
      cHead := subs( liab, 1, 22 )
   else
      cHead := subs( asset, 1, 22 )
   endif
   if empty(alltrim(cHead))
     nId := 0
   else
      nId := ascan( __aTypeDescs, rtrim( ltrim( proper( cHead ) ) ) )
   endif
   if nId > 0
      jSaveEnv()
      close all
      listacs( nId, .t., dDate )
      close all
      jRestEnv()
   elseif nId == 0 .and. nPos == 2 // Assets
      if upper(subs(asset,1,13)) == 'COST OF GOODS'
         jSaveEnv()                  
         close all
         sup_costrep()
         close all
         jRestEnv()
      endif
   endif
endif
return .t.
//-----------------------------
static function _BCostOfGoods
local nStock := 0.00
jSaveEnv()
close all
if ReqInv( .t. )
   use BATCHES new
   sum all cost * ( begin + rcvd - sold ) to nStock
   use
else
   nStock := 0.00
endif
jRestEnv()
return nStock
//-----------------------------

*+ EOF: BSHEET.PRG
