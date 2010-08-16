#include "std.ch"
#include "inkey.ch"
#include "box.ch"

/*
#
#     Menu System for EasyAccounts v1.5
#     Developed and Tested by Jasim A B
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
*/

static edDate
static sp_visor

function pullmenu

local nChoice := 1
local nCount  := 1
local aMenu   := {}
local eD      := entr_date()
local nF
local nC      := space( 2 )

rat_ehh( .t. )

EAMenuInit( @eD )

bungStart()

if ReqServ()
   bungOption( "Service" )
   bungDrop()
   bungOption( "Add/Edit Calls", {|| service() } )
   bungOption( "Service Engineer Report", {|| srv_report() } )
   bungUnDrop()
endif

if user() != 'ADM'

bungOption( "Accounts" )
bungDrop()

mn_acEntry()
mn_acListAcs()
mn_acDSheet()
mn_acReports()

bungOption( "Ledger", { || ledger() } )
bungOption( "CROSSBAR" )
bungOption( "View Cashbook", { || viewCBook() } )
bungOption( "Remar~ks List", { || RemarksList() } )

// No more special privilege to Administration for closing..
// All companies need to be closed individually..

bungOption( "Close Books", { || plCloseBooks() } )

bungUnDrop()

endif

if user() != 'ADM'
   mn_Inv()
   mn_Utils()
else
   bungOption("MAIN")
   bungDrop()
   bungOption( "Stock", { || whichItem() } )
   bungOption( "Sales", { || sales() } )
   bungOption( "Purchase", { || purchase() } )
   bungOption( "Sales ~Report", { || sale_rep() } )
   bungOption( "Purchase ~Report", { || purch_rep() } )
   bungUnDrop()
   bungOption( "E~XIT (Esc)", { || bungeequit() } )
endif


aMenu := bungEnd()

setcolor( pllColor() )

@  1,  0 clear to 3, 79
@  1,  0, 3, 79 box B_SINGLE

clear typeahead

if user() == 'ADM'
   set key K_ALT_M to
   set key K_F5 to             // no pop-up menu..
   set key K_F1 to admHelp()
endif

if ! ReqServ()
   bungee( 2, 2, 78, aMenu, { 2, 25, 45, 68 } )
else
   bungee( 2, 2, 78, aMenu, { 2, 20, 39, 57, 73 } )
   // The service menu is additional..
endif

close all
return .t.
//-------------------------------------------
static function plCloseBooks

local nJ
local nJJ
local cConf := space( 5 )
local nD1   := date() - 30
local nD2   := date()
nJJ := jAlert( 'CLOSE BOOKS : ' + dtoc( dDate ), { 'Abort', 'Continue', 'Range' } )
if nJJ = 2

   cConf := space( 8 )
   popread( .f., "Confirmation : Type 'CLOSE' to continue", ;
            @ cConf, '@!' )

   if rtrim( ltrim( upper( cConf ) ) ) = 'CLOSE'
      if comp_add = 'Administration'
         doclose( entr_date() )
      else
         //if !file( 'ICLOSE.EA' )
         //   msg( 'Individual closure of this company not allowed...' )
         //else
            doclose( entr_date() )
         //endif
      endif
   else
      msg( 'Confirmation failed...' )
   endif
elseif nJJ = 3
   //if comp_add != 'Administration' .and. ( !file( 'ICLOSE.EA' ) )
   //   msg( 'Individual closure of this company not allowed...' )
   //   return .f.
   //endif

   popread( .f., 'Starting Date : ', @nD1, '@D', ;
            'Ending Date   : ', @nD2, '@D' )
   cConf := space( 8 )
   popread( .f., "Confirmation : Type 'CLOSE' to continue", ;
            @ cConf, '@!' )

   if rtrim( ltrim( upper( cConf ) ) ) = 'CLOSE'

      if nD2 > nD1 .and. ( !empty( nD2 ) .and. !empty( nD1 ) )
         setcursor( 0 )
         setcursor( .f. )

         do while ( nD1 != nD2 )
            ontask( '  Closing Date : ' + dtoc( nD1 ) )
            doclose( nD1 )
            nD1 ++
            if inkey() == K_ESC
               msg( 'Closing of books aborted..' )
               exit
            endif
         enddo

         setcursor( .t. )
         setcursor( 1 )
         ontask()
      else
         msg( 'Invalid dates...' )
      endif
   else
      msg( 'Confirmation failed...' )
   endif
endif

retur .t.
//---------------------
function pllColor

return 'W+/N*,GR+/W+,,GR+/B+,BG+/W+'
//---------------------
static function mn_Utils

bungOption( 'Utilities' )
bungDrop()
bungOption( "Change Password", { || chnPword() } )
bungOption( "CROSSBAR" )
bungOption( "Public Accounts", { || Links( .f. ) } )
bungOption( "Reindex Data Files", { || util_mas( .f. ) } )
bungOption( "Create ~New Company", { || AddCompany() } )
bungOption( "CROSSBAR" )
bungOption( "Calculator", { || vs_Calc() } )
bungOption( "Telephone", { || ea_phone() } )
bungOption( "Scheduler", { || ea_appts( .t. ) } )
bungOption( "Colo~rs", { || whatcolor() } )
bungOption( "CROSSBAR" )
bungOption( "View Documentation", { || fileread(1,1,23,79,'C:\EA\WHATSNEW.WHT') } )
bungOption( "About the author", { || aboutMe() } )
bungUnDrop()
bungOption( "Exit", { || bungeequit() } )
bungUnDrop()
return .t.
//------------------------------
static function mn_acEntry

bungOption( "Change Date", { || ChnDate() } )
bungOption( "~Add/Edit Accounts", { || accview( .t., .t., .f., boxcolor() ) } )
bungOption( "Dail~y Remarks", { || DayRemarks() } )
bungOption( "CROSSBAR" )
bungOption( "Enter Cash~book", { || cshEntry() } )
bungOption( "Daybook", { || dbkView() } )
*bungOption( "Voucher Entry", { || NewdbkView() } )
// Compr. V.Entry project discarded.
bungoption( "Bank ~Transactions", { || bankEntry() } )
bungOption( "CROSSBAR" )

return .t.
//--------------------
static function mn_acReports

bungOption( "Reports" )
bungDrop(-1)
bungOption( "~Trial Balance", { || TrialBal() } )
bungOption( "~Balance Sheet" )
bungDrop()
bungOption( "Detailed", { || BSheet(.f.) } )
bungOption( "Summary", { || BSheet(.t.) } )
bungunDrop()
bungOption( "~Periodwise Balances", {|| prdGrpBal() } )
bungOption( "~Group A/C Summary", { || listGroup() } )
bungOption( "~Cash In & Out Statement", { || cashinout() } )
bungUnDrop()
return .t.
//-------------------------------------
static function mn_acDSheet

if file( "COMPANY.ADM" )
   bungOption( "Daily Sheet" )
   bungDrop()
   bungOption( "Education", { || edu_dPrn() } )
   bungOption( gPrefix, { || daysmm() } )
   bungUnDrop()
else
   bungOption( "Daily Sheet", { || daySheet() } )
endif
return .t.
//------------------------------
static function mn_Inv

if ReqInv()

   bungOption( "Inventory" )
   bungDrop()
   bungOption( "Add/Edit Items", { || whichItem() } )
   bungOption( "Sales", { || sales() } )
   bungOption( "Purchase", { || purchase() } )
   bungOption( "Replacement", { || m_replace() } )
   bungOption( "Stand~by", { || m_standby() } )
   bungOption( "CROSSBAR" )
   bungOption( "Master Lists" )
   bungDrop()
   // bungOption( "Cost Report", { || iif( sp_visor(), sup_costrep(), costrep() ) } )
   // Changed on 07-02-2004 by JAS after confirming with father.
   bungOption( "Cost Report", { || sup_costrep() } )

   bungOption( "Complete ~Report", { || allItems() } )
   bungOption( "Price List - Printable", { || PriceList1() } )
   bungUnDrop()
   bungOption( "Item Report", { || item_rep() } )
   bungOption( "Transfer Report", { || trans_rep() } )
   bungOption( "CROSSBAR" )
   bungOption( "Sales ~Report", { || sale_rep() } )
   bungOption( "Amountwise Sales Report", { || amountwisesalerep() } )
   bungOption( "System Sa~les Report", { || sysSaleRep() } )

   //
   // "if HOBranch()"
   //
   // Cannot use HOBranch - all the users would be able to see profit.
   // We need only specific users.
   // As on 29/09/2002
   //

   bungOption( "CROSSBAR" )
   bungOption( "Purchase Report" )
   bungDrop()
   bungOption( "By Party", { || prch_party() } )
   bungOption( "Datewise", { || purch_rep() } )
   bungUnDrop()
   bungUnDrop()
endif
return .t.
//--------------------------------
static function mn_acListAcs

bungOption( "List A/C Bala~nces" )
bungDrop(-10,8)
bungOption( "A. Assets - Current", { || listAcs( 1 ) } )
bungOption( "B. Fixed Assets", { || listAcs( 2 ) } )
bungOption( "C. Bank Accounts", { || listAcs( 3 ) } )
bungOption( "D. Expenses", { || listAcs( 4 ) } )
bungOption( "E. Income A/Cs", { || listAcs( 5 ) } )
bungOption( "F. Tax Collected", { || listAcs( 6 ) } )
bungOption( "G. Purchase A/Cs", { || listAcs( 7 ) } )
bungOption( "H. Sales A/Cs", { || listAcs( 8 ) } )
bungOption( "I. Sundry Creditors", { || listAcs( 9 ) } )
bungOption( "J. Sundry Debtors", { || listAcs( 10 ) } )
bungOption( "K. Capital A/Cs", { || listAcs( 11 ) } )
bungOption( "L. Staff Loan A/Cs", { || listAcs( 12 ) } )
bungOption( "M. Associates", { || listAcs( 13 ) } )
bungOption( "N. Standby A/Cs", { || listAcs( 14 ) } )
bungOption( "O. Replacement A/Cs", { || listAcs( 15 ) } )
bungOption( "P. B.D.E A/Cs", { || listAcs( 16 ) } )
bungOption( "Q. Service Engg. A/Cs", { || listAcs( 17 ) } )
bungOption( "R. Loan A/Cs", { || listAcs( 18 ) } )
bungUnDrop()
return .t.
//---------------------
function chndate    // public func.may require in ENTRY TIME

local xxb
setcolor( scrcolor() )
@ 09, ( 79 / 2 - 12 ) say padc( 'CHANGE ENTRY DATE', 25 )         
setcolor( boxcolor() )
xx := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
if edDate = NIL
   if dDate != NIL
      edDate := dDate
   else
      dDate  := date()
      edDate := date()
   endif
endif
@ 12, ( 79 / 2 ) - 12 + 07 get edDate         
read
dDate := edDate
dispscrn()
return dDate
//----------------------------------------------
function entr_date( dSetDate )
if dSetDate != NIL
  edDate := dSetDate
  dDate := edDate
endif
if edDate=NIL
  if dDate=NIL
    edDate := date()
  else
    edDate := dDate
  endif
endif
return iif( !edDate = NIL, edDate, date() )
//----------------------------------------------
function InvPopMenu

local cOldS    := savescreen( 0, 0, 24, 79 )
local aActions

local nSel
local cOldColor := setcolor()

if user() == 'ADM'
  return .f.
endif

if edDate = NIL
   if dDate != NIL
      edDate := dDate
   else
      dDate  := date()
      edDate := date()
   endif
endif

set key K_F5 to

aActions := { 'Find Phone Number', 'Change Entry Date', 'Item Report', 'Accounts', 'Master', 'Cashbook', 'Bankbook', 'Daybook', ;
              'Sales', 'Purchase', 'Ledger', 'EA Status' }

jSaveEnv()
setcolor( boxcolor() )
close all
tone( 4321, 1 )
setcolor( scrcolor() )
@ 14, 55 say padc( 'þ Select Action þ', 23 )         
setcolor( boxcolor() )
nSel := apick( 15, 55, 22, 77, aActions )
tone( 3211, 1 )

if nSel = 0 .or. nSel = NIL
   close all
   jRestEnv()
   set key K_F5 to pop_menu()
   restscreen( 0, 0, 24, 79, cOldS )
   setcolor( 'B*/W*' )
   if edDate = NIL
      if dDate != NIL
         edDate := dDate
      else
         dDate  := date()
         edDate := date()
      endif
   endif
   @ 24, 59 say 'Entry Date:' + dtoc( edDate )         
   setcolor( cOldColor )
   return .f.
else
   dispscrn()
   if nSel = 1
      keyboard "F" + chr( K_ENTER )     // to directly go to search phone.
      ea_phone()
   elseif nSel = 2
      edDate := chndate()
   elseif nSel = 3
      item_rep()
   elseif nSel = 4
      accview( .t., .t., .f., boxcolor() )
   elseif nSel = 5
      whichitem()
   elseif nSel = 6
      cshentry()
   elseif nSel = 7
      bankentry()
   elseif nSel = 8
      dbkview()
   elseif nSel = 9
      sales()
   elseif nSel = 10
      purchase()
   elseif nSel = 11
      ledger( .f. )
   elseif nSel = 12
      sysStatus()
   endif
   close all
   jRestEnv()
endif
set key K_F5 to pop_menu()
restscreen( 0, 0, 24, 79, cOldS )
setcolor( 'B*/W*' )
dDate := edDate
@ 24, 59 say 'Entry Date:' + dtoc( edDate )         
setcolor( cOldColor )
return .t.
//==============================
function AccPopMenu

local cOldS    := savescreen( 0, 0, 24, 79 )
local aActions

local nSel
local cOldColor := setcolor()

if user() == 'ADM'
  return .f.
endif

if edDate = NIL
   if dDate != NIL
      edDate := dDate
   else
      dDate  := date()
      edDate := date()
   endif
endif

set key K_F5 to

aActions := { 'Find Phone Number', 'Change Entry Date', 'Add/Edit Accounts', 'Cashbook', 'Bankbook', 'Daybook', ;
              'Ledger', 'EA Status' }

jSaveEnv()
setcolor( boxcolor() )
close all
tone( 4321, 1 )
setcolor( scrcolor() )
@ 14, 55 say padc( 'þ Select Action þ', 23 )         
setcolor( boxcolor() )
nSel := apick( 15, 55, 22, 77, aActions )
tone( 3211, 1 )

if nSel = 0 .or. nSel = NIL
   close all
   jRestEnv()
   set key K_F5 to pop_menu()
   restscreen( 0, 0, 24, 79, cOldS )
   setcolor( 'B*/W*' )
   dDate := edDate
   @ 24, 59 say 'Entry Date:' + dtoc( edDate )         
   setcolor( cOldColor )
   return .f.
else
   dispscrn()
   if nSel = 1
      keyboard "F" + chr( K_ENTER )     // to directly go to search phone.
      ea_phone()
   elseif nSel = 2
      edDate := chndate()
   elseif nSel = 3
      accview( .t., .t., .f., boxcolor() )
   elseif nSel = 4
      cshentry()
   elseif nSel = 5
      bankentry()
   elseif nSel = 6
      dbkview()
   elseif nSel = 7
      ledger( .f. )
   elseif nSel = 8
      sysStatus()
   endif
   close all
   jRestEnv()
endif
set key K_F5 to pop_menu()
restscreen( 0, 0, 24, 79, cOldS )
setcolor( 'B*/W*' )
dDate := edDate
@ 24, 59 say 'Entry Date:' + dtoc( edDate )         
setcolor( cOldColor )
return .t.
//------------------------------------------
static function admHelp
jAlert("EasyAccounts created by Jasim A Basheer;; Press ESC to exit out of the program")
return .t.

*+ EOF: PULLMENU.PRG
