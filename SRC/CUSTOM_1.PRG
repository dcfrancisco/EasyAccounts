#include "std.ch"

#define DEBTOR      1
#define CREDITOR    2
#define BANK        3
#define STAFFLOAN   4
#define EXPENSE     5
#define FRANCHISEE  6
#define STANDBY     7
#define REPLACEMENT 8

static EAFile
static CPFile
static dBDate
static cText

//------------------------------------
function jFinStat()

&&
&& Total Financial Status comprising
&& all companies entitled for a backup. (system.ea - backup = .t.)
&&

local cprevcomp     := comp_add
local curComp
local nRec
local nLinesPerPage
local cOldEa        := EaAdd1

local nBalTot := 0.00

EAFile := NetDrive + ':\EA\' + DataDir() + '\'
CPFile := NetDrive + ':\EA\'
dBDate := date()
cText  := space( 34 )

popread( .f., 'Backup Date : ', @dBDate, '@D', ;
         'Title Text :', @cText, "@X" )

if empty( dbDate ) .or. empty( alltrim( cText ) )
   msg( "Financial analysis. Process aborted by user" )
   close all
   return .f.
endif

if !file( CPFile + "CAPITAL.DBF" )
   dbcreate( CPFile + "CAPITAL.DBF", { ;
           { "DATE", "D", 10, 0 }, ;
           { "COMPANY", "C", 30, 0 }, ;
           { "STOCK", "N", 10, 0 }, ;
           { "CASH", "N", 10, 0 }, ;
           { "DEBTOR", "N", 10, 0 }, ;
           { "CREDITOR", "N", 10, 0 }, ;
           { "BANK", "N", 10, 0 }, ;
           { "BALANCE", "N", 11, 0 }, ;
           { "REMARKS", "C", 34, 0 } } )
endif

EUse( CPFile + "CAPITAL.DBF" )
locate all for date == dBDate
do while found()
   delete
   continue
enddo
pack
use

close all
use (EAFile+'SYSTEM.EA') new
set filter to backup .and. ( subs( comp, 1, 6 ) != 'SYSTEM' )
go top

ferase( EAFile + 'FINSTAT.TXT' )

dispbegin()
dispscrn()
dispend()
dispend()

set device to printer
set printer on
set printer to ( EAFile + 'FINSTAT.TXT' )

@  0,  0 say "**" + padc( alltrim( cText ), 30 ) + "**"                   
@  1,  0 say "**" + padc( "Date : " + dtoc( dBDate ), 30 ) + "**"         
@  3,  0 say repl( '-', 34 )                                              

set device to screen
set printer off

do while .not. eof()

   dispbegin()
   dispscrn()
   dispend()

   CurComp  := alltrim( comp )
   Comp_add := CurComp
   EaAdd1   := alltrim( comp )
   nRec     := recno()

   ReqInv( .t. )    // Rechecks and reinitaties the ReqInv variable.

   plswait( .t., 'Analyzing ' + alltrim( proper( CurComp ) ) )
   close all
   jSetDefault( CurComp )

   if !file( 'ACC_1.CDX' )
      IndexFiles()  // So even if the backup is just restored, we neednt
      // do the index for all the companies one by one....
   endif

   set device to printer
   set printer on
   set printer to ( EAFile + 'FINSTAT.TXT' ) addi

   nBalTot += _jFinStat()
   jSetDefault( cprevcomp )

   close all
   use (EAFile+'SYSTEM.EA') new
   set filter to backup .and. ( subs( comp, 1, 6 ) != 'SYSTEM' )
   go nRec

   skip

   set printer off
   set device to screen
   plswait( .f. )

enddo

setprc( 0, 0 )
set device to printer
set printer on
set printer to ( EAFile + 'FINSTAT.TXT' ) addi

@  2,  0 say "#### Total Balance : " + alltrim( str( nBalTot, 12, 0 ) ) + " *****"         
@  4,  0 say repl( "*", 34 )                                                               

set device to screen
set printer off
set printer to

close all

jSetDefault( cprevcomp )
comp_add := cPrevComp
EaAdd1   := cOldEa

//nLinesPerPage := jLineFind('Net Balance',EAFile+'FINSTAT.TXT',62)
/*
if jAlert("Run FilePositioning ?",{"No","Yes"}) == 2
  run ("FILEPOS "+EAFile+'FINSTAT.TXT'+" "+EAFILE+"FINVIEW.TXT 16")
endif
*/

ReqInv( .t. )       // Rechecks and reinitaties the ReqInv variable.

dispbegin()
dispscrn()
dispend()

fileread( 1, 2, 10, 67, EAFile + 'FINSTAT.TXT', 'Consolidated Financial Index' )

return nil

//-------------------------------------
function _jFinStat()

local cBox

local nDebtor   := 0.00
local nBank     := 0.00
local nCash     := 0.00
local nCreditor := 0.00
local nStock    := 0.00
local nLine

local nTemp1
local nTemp2

nDebtor := fin_tot( DEBTOR )
nDebtor += fin_tot( STAFFLOAN )         // staff loan
nDebtor += fin_tot( FRANCHISEE )        // Franchisee

nCreditor := fin_tot( CREDITOR ) * - 1
nBank     := fin_tot( BANK )

close all

//########################### SUMMING CASH

use cashbook
sum all amount to nTemp1 for action = 'D'                   // Expense
sum all amount to nTemp2 for action = 'C'                   // Income
nCash += ( nTemp2 - nTemp1 )

use daybook index DBK_6
// DBK_6 is in ACCOUNT order
seek 1              // 1 - Cash A/C
//sum all debit-credit to nTemp1 while ACCOUNT = 1
//nCash += nTemp1

sum all amount to nTemp1 while ACCOUNT = 1 for action = 'D'                     // Income
sum all amount to nTemp2 while ACCOUNT = 1 for action = 'C'                     // Expense
nCash += ( nTemp1 - nTemp2 )

use bankbook index BNK_5
// BNK_5 is in ACCOUNT order
seek 1              // 1 - Cash A/C
sum all amount to nTemp1 while ACCOUNT = 1 for action = 'D'                     // Income
sum all amount to nTemp2 while ACCOUNT = 1 for action = 'C'                     // Expense
nCash += ( nTemp1 - nTemp2 )

//########################################

if ReqInv( .t. )
   use BATCHES
   sum all cost * ( begin + rcvd - sold ) to nStock
else
   nStock := 0.00
endif

close all

set date brit
set century on

nLine := 01
nCol  := 0

@ nLine, 00 say padc( eaAdd1, 34 )         
nLine ++
@ nLine, 00 say repl( '-', 34 )         
nLine ++
if ReqInv()
   @ nLine,  1 say "C. of Goods"             
   @ nLine, 18 say str( nStock, 10 )         
   nLine ++
endif
@ nLine,  1 say "Cash Balance"           
@ nLine, 18 say str( nCash, 10 )         
nLine ++
@ nLine,  1 say "Bank Balances"          
@ nLine, 18 say str( nBank, 10 )         
nLine ++
@ nLine,  1 say "Debtors"                  
@ nLine, 18 say str( nDebtor, 10 )         
nLine ++
@ nLine,  1 say "Creditors"                  
@ nLine, 18 say str( nCreditor, 10 )         
nLine ++
@ nLine,  1 say repli( '-', 34 )         
nLine ++
@ nLine,  1 say "Net Balance"                                                   
@ nLine, 18 say str( nStock + nBank + nCash + nDebtor - nCreditor, 10 )         
nLine ++
@ nLine,  1 say repli( "=", 34 )         
nLine ++
nLine ++

use (CPFile+"CAPITAL")
append blank
field->date     := dBDate
field->company  := comp_add
field->bank     := nBank
field->cash     := nCash
field->debtor   := nDebtor
field->creditor := nCreditor
field->stock    := nStock
field->balance  := nStock + nBank + nCash + nDebtor - nCreditor
field->remarks  := cText
use

return nStock + nBank + nCash + nDebtor - nCreditor
//--------------
static function fin_tot( nList )

local nTot := 0.00
local nD   := 0.00
local nC   := 0.00
use accounts new index ACC_1
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 5
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5
set order to 4
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6
if nList = BANK
   set order to 5
else
   set order to 4
endif
sele accounts
do while .not. eof()
   if ( nList = DEBTOR .and. rtrim( ltrim( type ) ) = 'Debtor' ) ;
        .or. ( nList = CREDITOR .and. rtrim( ltrim( type ) ) = 'Sundry Creditor' ) ;
        .or. ( nList = BANK .and. rtrim( ltrim( type ) ) = 'Bank' ) ;
        .or. ( nList = STAFFLOAN .and. rtrim( ltrim( type ) ) = 'Staff Loan' ) ;
        .or. ( nList = EXPENSE .and. rtrim( ltrim( type ) ) = 'Expense' ) ;
        .or. ( nList = FRANCHISEE .and. rtrim( ltrim( type ) ) = 'Associate' ) ;
        .or. ( nList = STANDBY .and. rtrim( ltrim( type ) ) = 'Standby' ) ;
        .or. ( nList = REPLACEMENT .and. rtrim( ltrim( type ) ) = 'Replacement' ) ;

      nD += opbal   // that may be negative if is in the credit column.

      // ** Thing to note : Do not reinitialize the nC and nD variables
      // because it should cumulate and the final variable is returned
      // only at the end of the loop.

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

      if nList = BANK
         select bankbook
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
      else
         select bankbook
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

   endif

   sele accounts
   skip
enddo
nTot := nD - nC
close all
return nTot
//=================================================================
function PrintCapital( nMode )

local cTitle
local nTot       := 0
local dFrom      := date()
local dTo        := date()
local nCrBal     := 0.00
local nTotInvest := 0.00
local lDetailed  := .f.
local line
local nA,nB,nC,nD,nE,nF,nG,nH,nI,nJ,nK,nL,nM,nN,nO

nA := nB := nC := nD := nE := nF := nG := nH := 0.00

popread( .f., 'From date : ', @dFrom, '@D', ;
         'Till date : ', @dTo, '@D' )

if dTo < dFrom
   msg( 'Invalid dates..!' )
   return .f.
endif

lDetailed := jAlert( 'Include detailed investment list? ', {'Yes','No'} )=1

use (NetDrive+":\EA\CAPITAL")

if ( empty( dFrom ) .or. empty( dTo ) )
   msg( 'No date filter set. Printing all the dates..' )
else
   cmFilter(  'date >= '+cm2str(dFrom)+' .and. date <= '+cm2str(dTo) )
   go top
endif

set device to printer
set printer to (RepPath+"capital.txt")
set printer on
set console off

if ( !empty( dFrom ) ) .and. ( !empty( dTo ) )
   ?
   ? padc( 'Report from : ' + dtoc( dFrom ) + ' to ' + dtoc( dTo ), 94 )
   ?
endif

if nMode = 1
   index on DATE to CAPITAL
else
   index on COMPANY to CAPITAL
endif
go top
nTot := 0
do while .not. eof()
   if nMode = 1
      cTitle := date
      ? padc( dtoc( date ), 22 )
      ?? padc( "Stock", 14 )
      ?? padc( "Cash", 12 )
      ?? padc( "Debtor", 12 )
      ?? padc( "Creditor", 12 )
      ?? padc( "Bank", 12 )
      ?? padc( "Balance", 12 )
   else
      cTitle := company
      ? padr( alltrim( company ), 22 )
      ?? padc( "Stock", 14 )
      ?? padc( "Cash", 12 )
      ?? padc( "Debtor", 12 )
      ?? padc( "Creditor", 12 )
      ?? padc( "Bank", 12 )
      ?? padc( "Balance", 12 )
   endif
   nTot := 0
   do while iif( nMode = 1, cTitle == date, cTitle == company ) .and. ( !eof() )
      if nMode = 1
         ? subs( company, 1, 20 ) + space( 2 )
      else
         ? dtoc( date ) + space( 12 )
      endif
      ?? transform( stock, '999,99,999' ) + space( 2 )
      ?? transform( cash, '999,99,999' ) + space( 2 )
      ?? transform( debtor, '999,99,999' ) + space( 2 )
      ?? transform( creditor, '999,99,999' ) + space( 2 )
      ?? transform( bank, '999,99,999' ) + space( 2 )
      ?? transform( balance, '999,99,999' ) + space( 2 )
      nTot += balance
      skip
   enddo
   if nMode = 1
      ? space( 22 ) + space( 60 )
      ?? repli( '-', 10 )
      ? space( 22 ) + space( 60 )
      ?? transform( nTot, '999,99,999' ) + space( 2 )
   else
      ?
   endif
enddo
if nMode = 1
   set default to C:\EA\02\TEST
   GwChDir( "C:\EA\02\TEST" )
   set printer off
   set device to screen
   nCrBal := listacs( 9, .f. )  // 9 IS " Sundry Creditor "
   set printer on
   set device to printer

   ? space( 22 ) + padl( 'Personal Creditors Bal :', 55 ) + space( 5 )
   ?? transform( nCrBal, '999,99,999' ) + space( 2 )

   use D:\JASIM\CLWORKS\STATUS\INV
   sum all total to nTotInvest

   ? space( 22 ) + padl( 'Total Investment Made  :', 55 ) + space( 5 )
   ?? transform( nTotInvest, '999,99,999' ) + space( 2 )

   ? padl( '                           ', 22 ) + space( 60 )
   ?? '----------'
   // Do not change--> The balance is actually nTot+nCrBal
   // NOT nTot-nCrBal (since nTot and nCrBal both are credit balances
   // and are negative values)
   ? space( 22 ) + space( 60 ) + transform( nTot + nCrBal + nTotInvest, '999,99,999' ) + space( 2 )
   ?
   ?
   if lDetailed
      use D:\JASIM\CLWORKS\STATUS\INV
      line := Prow()
      @ line,  1 say padc( 'INVESTMENTS', 78 )         
      line ++
      @ line, 16 say padc( 'Fixed', 27 )         
      @ line, 43 say padc( 'Deposits', 27 )         
      line ++
      @ line,  1 say repli( '-', 78 )         
      line ++
      @ line,  1 say "Division"         
      @ line, 13 say "Comp."            
      @ line, 21 say "Furn."            
      @ line, 29 say "Intrr."           
      @ line, 37 say "|"                
      @ line, 39 say "Bldng."           
      @ line, 47 say "Tele."            
      @ line, 55 say "Elec."            
      @ line, 63 say "Others"           
      @ line, 71 say "TOTAL"            
      line ++
      @ line,  1 say repli( '-', 77 )         
      line ++

      do while .not. eof()
         @ line,  1 say whichdiv( div )                          
         @ line, 12 say tellit( str( computer, 7, 0 ) )          
         @ line, 20 say tellit( str( furniture, 7, 0 ) )         
         @ line, 28 say tellit( str( interior, 7, 0 ) )          
         @ line, 37 say "|"                                      
         @ line, 38 say tellit( str( building, 7, 0 ) )          
         @ line, 46 say tellit( str( telephone, 7, 0 ) )         
         @ line, 54 say tellit( str( electr, 7, 0 ) )            
         @ line, 62 say tellit( str( others, 7, 0 ) )            
         @ line, 70 say tellit( str( total, 8, 0 ) )             
         nA += computer
         nB += furniture
         nC += interior
         nD += building
         nE += telephone
         nF += electr
         nG += others
         nH += total
         skip
         line ++
      enddo
      @ line,  1 say repli( '-', 78 )         
      line ++
      @ line, 02 say "TOTALS"                
      @ line, 12 say str( nA, 7, 0 )         
      @ line, 20 say str( nB, 7, 0 )         
      @ line, 28 say str( nC, 7, 0 )         
      @ line, 38 say str( nD, 7, 0 )         
      @ line, 46 say str( nE, 7, 0 )         
      @ line, 54 say str( nF, 7, 0 )         
      @ line, 62 say str( nG, 7, 0 )         
      @ line, 70 say str( nH, 8, 0 )         
      line ++
      line ++
      close all
   endif

endif
?
?
?
?
set device to screen
set printer off
set printer to
set console on
close all
fileread( 1, 0, 23, 79, RepPath+'CAPITAL.TXT', "Jas's Financial Investment Monitor" )
return .t.
//-------------------------------------------------------------------------
function custStockRep

local dFrom     := date()
local dTo       := date()
local nOpStock  := 0.00
local nTotSale  := 0.00
local nTotPurch := 0.00
local nFile

popread( .f., 'From : ', @dFrom, '@D', ;
         '  To : ', @dTo, '@D' )

if empty( dFrom ) .or. empty( dTo ) .or. dFrom > dTo
   msg( 'Invalid dates...' )
   return .f.
endif

plswait( .t., 'Counting opening stock...' )
use master new index MAS_1
use sales new index sale_1,sale_2
set order to 1
use purchase new index prch_1,prch_2
set order to 1
use paccount new index pac_1,pac_2
use saccount new index sac_1,sac_2

sele saccount
set order to 2
DateFind( dFrom, dTo )
do while date >= dFrom .and. date <= dTo .and. ( !eof() )
   sele sales
   seek saccount->id
   do while sales->id == saccount->id .and. ( !eof() )
      nTotSale += sales->cost * sales->qty
      skip
   enddo
   sele saccount
   skip
enddo

sele paccount
set order to 2
DateFind( dFrom, dTo )
do while date >= dFrom .and. date <= dTo .and. ( !eof() )
   sele purchase
   seek paccount->id
   do while purchase->id == paccount->id .and. ( !eof() )
      nTotPurch += purchase->cost * purchase->qty
      skip
   enddo
   sele paccount
   skip
enddo

sele saccount
set order to 1
go top

sele paccount
set order to 1
go top

sele sales
set order to 2
go top

sele purchase
set order to 2
go top

sele master
go top

do while .not. eof()

   nOpStock += begin * opcost
   sele sales
   seek master->id
   do while sales->item_id == master->id .and. ( !eof() )
      sele saccount
      seek sales->id
      if !found()
         msg( 'Bill Id in Sales not found in Saccount' )
         close all
         quit
      endif
      if saccount->date < dFrom
         nOpStock -= sales->cost * sales->qty
      endif

      sele sales
      skip
   enddo

   sele purchase
   seek master->id
   do while purchase->item_id == master->id .and. ( !eof() )
      sele paccount
      seek purchase->id
      if !found()
         msg( 'Bill Id in Purchase not found in Paccount' )
         close all
         quit
      endif
      if paccount->date < dFrom
         nOpStock += purchase->cost * purchase->qty
      endif

      sele purchase
      skip
   enddo

   sele master
   skip
enddo
close all
nFile := fcreate( 'PRDCHK.TXT' )
fwrite( nFile, chr( 13 ) + chr( 10 ) + ;
        padc( 'Period Wise analysis from ' + dtoc( dFrom ) + ' to ' + dtoc( dTo ), 50 ) + ;
        chr( 13 ) + chr( 10 ) + ;
        repli( '-', 50 ) + ;
        chr( 13 ) + chr( 10 ) + ;
        ' Opening Stock Value : ' + str( nOpStock, 10, 2 ) + chr( 13 ) + chr( 10 ) + ;
        ' Total Purchase Made : ' + str( nTotPurch, 10, 2 ) + chr( 13 ) + chr( 10 ) + ;
        '                       ' + repli( '-', 10 ) + chr( 13 ) + chr( 10 ) + ;
        '                       ' + str( nOpStock + nTotPurch, 10, 2 ) + chr( 13 ) + chr( 10 ) + ;
        ' Total Sales Amount  : ' + str( nTotSale, 10, 2 ) + chr( 13 ) + chr( 10 ) + ;
        '                       ' + repli( '-', 10 ) + chr( 13 ) + chr( 10 ) + ;
        ' Closing Stock Value : ' + str( nOpStock + nTotPurch - nTotSale, 10, 2 ) + chr( 13 ) + chr( 10 ) + ;
        '                       ' + repli( '=', 10 ) + chr( 13 ) + chr( 10 ) + ;
        chr( 13 ) + chr( 10 ) + chr( 13 ) + chr( 10 ) )
fclose( nFile )
close all
fileread( 1, 1, 23, 79, 'PRDCHK.TXT', 'Report' )
return .t.
//==================================================================
function DateFind( dFrom, dTo )

seek dFrom
if !found()
   do while (!found()) .and. ( dFrom <= dTo )
      dFrom ++
      seek dFrom
   enddo
endif
return found()
//-----------------
function whichdiv(nDiv)
local cDiv
if nDiv=1
   cDiv := 'WSS.Kollam '
elseif nDiv=2
   cDiv := 'WSS.Kply   '
elseif nDiv=3
   cDiv := 'WC.Kylm    '
elseif nDiv=4
   cDiv := 'WC.Adv.Lane'
elseif nDiv=5
   cDiv := 'WC.Pulliman'
elseif nDiv=6
   cDiv := 'WC.Hardware'
elseif nDiv=7
   cDiv := 'Graphics   '
elseif nDiv=8
   cDiv := 'M/Solutions'
elseif nDiv=9
   cDiv := 'Admin.     '
endif
return cDiv
//-------------------------------
function tellit(what)
local retval := ''
if val(rtrim(ltrim(what)))=0
   retval := padc('-',7)
else
   retval := what
endif
return retval
//-----------------

*+ EOF: CUSTOM_1.PRG
