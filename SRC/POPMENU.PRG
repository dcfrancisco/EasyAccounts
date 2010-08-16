#include "std.ch"
#include "inkey.ch"

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

function popMenu

local nChoice := 1
local nCount  := 1
local nF
local nC      := space( 2 )
edDate := dDate

EaMenuInit( @edDate )

do while ( iif( reqinv(), nChoice != 12, nChoice != 10 ) )

   if downclose()
      return .f.
   endif

   // WSS, Graphics doesnt require INVENTORY. So, removed it
   // with condition.           && Jasim 6-11-01 6:15 pm

   if reqinv()
      set key K_F2 to changecomp()
      //set key K_CTRL_ALT_T to traceback()
      setcolor( 'N*/W+' )
      setcolor( boxcolor() )
      @ 05, 25 clear to 22, 55
      @ 05, 25 to 22, 55
      setcolor( scrcolor() )
      @ 04, 26 - 1 say padc( "ENTRYWAY", 31 )         
      setcolor( boxcolor() )
      @ 06, 26 prompt padr( "A. Accounts", 29 )
      @ 07, 26 prompt padr( "B. Inventory", 29 )
      @ 08, 26 prompt padr( "C. Change Password", 29 )
      footline( 09, 26, 29 )
      @ 10, 26 prompt padr( "D. Reindex Files", 29 )
      @ 11, 26 prompt padr( "E. Create New Company", 29 )
      @ 12, 26 prompt padr( "F. Public Accounts", 29 )
      footline( 13, 26, 29 )
      @ 14, 26 prompt padr( "F. Calculator", 29 )
      @ 15, 26 prompt padr( "G. Telephone", 29 )
      @ 16, 26 prompt padr( "H. Scheduler", 29 )
      @ 17, 26 prompt padr( "I. Colors", 29 )
      footline( 18, 26, 29 )
      @ 19, 26 prompt padr( "J. About", 29 )
      footline( 20, 26, 29 )
      @ 21, 26 prompt padr( "K. Exit", 29 )
      menu to nChoice
      set key K_F2 to
      if downclose()
         return .f.
      endif

      cleanup()
      if nChoice = 1
         nCount ++
         acmenu()
         if downclose()
            return .f.
         endif
      elseif nChoice = 2
         nCount ++
         invmenu()
         if downclose()
            return .f.
         endif
         if nCount > 3
            util_mas( .f. )
            nCount := 0
         endif
      elseif nChoice = 3
         chnpword()
      elseif nChoice = 4
         util_mas( .f. )
      elseif nChoice = 5
         AddCompany()
      elseif nChoice = 6
         Links( .f. )
      elseif nChoice = 7
         vs_calc()
      elseif nChoice = 8
         ea_phone()
      elseif nChoice = 9
         ea_appts( .t. )                // open databases for me.
      elseif nChoice = 10
         whatcolor()
      elseif nChoice = 11
         aboutme()
      elseif nChoice = 12
         return .t.       // ask for company
      endif
   else
      set key K_F2 to changecomp()
      setcolor( 'N*/W+' )
      setcolor( boxcolor() )
      @ 06, 25 clear to 21, 55
      @ 06, 25 to 21, 55
      setcolor( scrcolor() )
      @ 05, 26 - 1 say padc( "ENTRYWAY", 31 )         
      setcolor( boxcolor() )
      @ 07, 26 prompt padr( "A. Accounts", 29 )
      footline( 08, 26, 29 )
      @ 09, 26 prompt padr( "B. Reindex Files", 29 )
      @ 10, 26 prompt padr( "C. Create New Company", 29 )
      @ 11, 26 prompt padr( "D. Public Accounts", 29 )
      footline( 12, 26, 29 )
      @ 13, 26 prompt padr( "E. Change Date", 29 )
      @ 14, 26 prompt padr( "F. Scheduler", 29 )
      @ 15, 26 prompt padr( "G. Calculator", 29 )
      @ 16, 26 prompt padr( "H. Colors", 29 )
      footline( 17, 26, 29 )
      @ 18, 26 prompt padr( "I. About", 29 )
      footline( 19, 26, 29 )
      @ 20, 26 prompt padr( "J. Exit", 29 )
      menu to nChoice
      set key K_F2 to
      if downclose()
         return .f.
      endif
      cleanup()
      if nChoice = 1
         nCount ++
         if nCount > 4
            util_mas( .f. )
            nCount := 0
         endif
         acmenu()
         if downclose()
            return .f.
         endif
      elseif nChoice = 2
         indexfiles()
      elseif nChoice = 3
         AddCompany()
      elseif nChoice = 4
         Links( .f. )
      elseif nChoice = 5
         chndate()
      elseif nChoice = 6
         ea_appts( .t. )                // open databases for me.
      elseif nChoice = 7
         vs_calc()
      elseif nChoice = 8
         whatcolor()
      elseif nChoice = 9
         aboutme()
      elseif nChoice = 10
         return .f.
      endif
   endif
   cleanup()
enddo
return .t.

static function invmenu

local nChoice  := 1
local aPrompts := {}
do while nChoice != 16
   if downclose()
      return .f.
   endif
   jSetDefault( comp_add )
   set key K_F2 to changecomp()
   setcolor( 'N*/W+' )
   setcolor( boxcolor() )
   @ 05, 25 clear to 20, 55
   @ 05, 25 to 20, 55
   setcolor( scrcolor() )
   @ 04, 26 - 1 say padc( "INVENTORY", 31 )         
   setcolor( boxcolor() )

   aPrompts := {}
   aadd( aPrompts, padr( "A. Add/Edit Items", 29 ) )
   aadd( aPrompts, padr( "B. Sales", 29 ) )
   aadd( aPrompts, padr( "C. Purchase", 29 ) )
   aadd( aPrompts, padr( "D. Replacement", 29 ) )
   aadd( aPrompts, padr( "E. Standby", 29 ) )
   //aadd(aPrompts,"")
   aadd( aPrompts, repli( chr( 205 ), 29 ) )
   aadd( aPrompts, padr( "F. Master Lists", 29 ) )
   aadd( aPrompts, padr( "G. Item Report", 29 ) )
   aadd( aPrompts, padr( "H. Transfer Report", 29 ) )
   aadd( aPrompts, padr( "I. Sales Report", 29 ) )
   aadd( aPrompts, padr( "J. Purchase Report", 29 ) )
   //aadd(aPrompts,"")
   aadd( aPrompts, repli( chr( 205 ), 29 ) )
   aadd( aPrompts, padr( "K. Amountwise Sales Report", 29 ) )
   aadd( aPrompts, padr( "L. System Sales Report", 29 ) )

   if HOBranch()
      aadd( aPrompts, padr( "M. Detailed System Sales", 29 ) )
      aadd( aPrompts, padr( "N. Detailed Spares Sales", 29 ) )
   endif

   //aadd(aPrompts,"")
   aadd( aPrompts, repli( chr( 205 ), 29 ) )
   aadd( aPrompts, padr( "O. Calculator", 29 ) )
   aadd( aPrompts, padr( "P. EXIT", 29 ) )

   nChoice := arMenu( aPrompts, 6, 26, 19, 54, nChoice )

   set key K_ENTER to
   set key K_F2 to
   if downclose()
      return .f.
   endif
   cleanup()
   if nChoice = 1
      whichitem()
   elseif nChoice = 2
      sales()
   elseif nChoice = 3
      purchase()
   elseif nChoice = 4
      m_replace()
   elseif nChoice = 5
      m_standby()
   elseif nChoice = 6
      maslists()
   elseif nChoice = 7
      item_rep()
   elseif nChoice = 8
      trans_rep()
   elseif nChoice = 9
      sale_rep()
   elseif nChoice = 10
      if jPick( { 'By Date        ', 'Partywise' }, 'Purchase Report' ) = 2
         prch_party()
      else
         purch_rep()
      endif
   elseif nChoice = 11
      amountwisesalerep()
   elseif nChoice = 12
      syssalerep()
   elseif nChoice = 13
      if HOBranch()
         sup_sales( "SYSTEM" )
      else
         vs_calc()
      endif
   elseif nChoice = 14
      if HOBranch()
         sup_sales( "SPARES" )
      else
         nChoice := 16
      endif
   elseif nChoice = 15
      vs_calc()
   endif
   cleanup()
enddo
return nil
//===========================
static function acmenu

local nChoice := 1
local nJ
local nJJ
local cConf   := space( 5 )
local nD1     := date() - 30
local nD2     := date()
do while nChoice != 14
   if downclose()
      return .f.
   endif
   jSetDefault( comp_add )
   set key K_F2 to changecomp()
   setcolor( 'N*/W+' )
   setcolor( boxcolor() )
   @ 04, 25 clear to 20, 55
   @ 04, 25 to 20, 55
   setcolor( scrcolor() )
   @ 03, 26 - 1 say padc( "ACCOUNTS", 31 )         
   setcolor( boxcolor() )
   @ 05, 26 prompt padr( "A. Add/Edit Accounts", 29 )
   @ 06, 26 prompt padr( "B. Enter Cashbook", 29 )
   @ 07, 26 prompt padr( "C. Daybook", 29 )
   @ 08, 26 prompt padr( "D. Bank Transactions", 29 )
   @ 09, 26 prompt padr( "E. Print Daily-Sheet", 29 )
   @ 10, 26 prompt padr( "F. Change Date", 29 )
   @ 11, 26 prompt padr( "G. List A/C Balances", 29 )
   @ 12, 26 prompt padr( "H. Expense Summary", 29 )
   @ 13, 26 prompt padr( "I. Income Summary", 29 )
   @ 14, 26 prompt padr( "K. Trial Balance", 29 )
   @ 15, 26 prompt padr( "L. Ledger", 29 )
   @ 16, 26 prompt padr( "M. Daily Remarks", 29 )
   footline( 17, 26, 29 )
   if file('COMPANY.ADM') .or. file('ICLOSE.EA')
      @ 18, 26 prompt padr( "N. Close Books", 29 )
   else
      @ 18, 26 prompt padr( "N. Calculator", 29 )
   endif
   @ 19, 26 prompt padr( "O. EXIT", 29 )
   menu to nChoice
   set key K_F2 to
   if downclose()
      return .f.
   endif
   cleanup()
   if nChoice = 1
      accview( .t., .t., .f., boxcolor() )
   elseif nChoice = 2
      cshentry()
   elseif nChoice = 3
      dbkview()
   elseif nChoice = 4
      bankentry()
   elseif nChoice = 5
      if file( 'COMPANY.ADM' )
         nJ := 1
         do while nJ != 0
            dispscrn()
            nJ := menu_v( 'Daily Sheet', 'Education', gPrefix )
            if nJ = 1
               edu_dprn()
            elseif nJ = 2
               daysmm()
            endif
         enddo
      else
         daysheet()
      endif
   elseif nChoice = 6
      edDate := chndate()
   elseif nChoice = 7
      listacs()
   elseif nChoice = 8
      printexp()
   elseif nChoice = 9
      printinc()
   elseif nChoice = 10
      TrialBal()
   elseif nChoice = 11
      ledger()
   elseif nChoice = 12
      dayremarks()
   elseif nChoice = 13

      //if comp_add='Administration' .and. (opened('PULLIMAN') .and. ;
      //   opened('KOLLAM') .and. opened('GRAPHICS') )
      if comp_add = 'Administration'
         nJJ := jAlert( 'CLOSE BOOKS : ' + dtoc( dDate ), { 'Abort', 'Continue', 'Range' } )
         if nJJ = 2
            cConf := space( 8 )
            popread( .f., "Confirmation : Type 'CLOSE' to continue", ;
                     @ cConf, '@!' )
            if rtrim( ltrim( upper( cConf ) ) ) = 'CLOSE'
               doclose( entr_date() )
            else
               msg( 'Confirmation failed...' )
            endif
         elseif nJJ = 3
            popread( .f., 'Starting Date : ', @nD1, '@D', ;
                     'Ending Date   : ', @nD2, '@D' )
            cConf := space( 8 )
            popread( .f., "Confirmation : Type 'CLOSE' to continue", ;
                     @ cConf, '@!' )
            if rtrim( ltrim( upper( cConf ) ) ) = 'CLOSE'
               if nD2 > nD1 .and. ( !empty( nD2 ) .and. !empty( nD1 ) )
                  setcursor( 0 )
                  setcursor( .f. )
                  set device to printer
                  set printer to ( dir() + '\PROFITS.TXT' )
                  set printer on
                  set console off
                  ? ' Negative Profits Listing ***'
                  ?

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
      elseif file('ICLOSE.EA')
         if jAlert( 'CLOSE BOOKS : ' + dtoc( entr_date() ), { 'Abort', 'Continue' } ) = 2
            doclose( entr_date() )
         endif
      else
         vs_calc()
      endif
   endif
   cleanup()
enddo
return .t.
//---------------
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
//---------
function m_standby

local x := 1
do while x != 0
   dispbegin()
   dispscrn()
   dispend()
   x := menu_v( "อออออออ STANDBY ออออออ", "Add/Edit Standby Details", "Print/View Report" )
   if x = 1
      sbBrowse()
   elseif x = 2
      sbDues()
   endif
enddo
return .t.
//-------------
function m_replace

local x := 1
do while x != 0
   dispbegin()
   dispscrn()
   dispend()
   x := menu_v( "อออออออ REPLACEMENT ออออออ", "Add/Edit Replacement Details", "Print/View Report" )
   if x = 1
      rpBrowse()
   elseif x = 2
      rpDues()
   endif
enddo
return .t.
//-------------
function setsp( lLogic )

sp_visor := lLogic
return sp_visor
//-------------
function sp_visor

if sp_visor = NIL
   sp_visor := .f.
endif
return sp_visor
//-------------
function maslists

local nMenu := menu_v( "Report", "Complete Items", "Cost Report", "Price List" )
if nMenu = 0 .or. nMenu = NIL
   return .f.
elseif nMenu = 1
   allitems()
elseif nMenu = 2
   if !sp_visor()
      costrep()
   else
      sup_costrep()
   endif
else
   pricelist1()
endif
return .t.
//--------------
function entr_date( dSetDate )
if dSetDate != NIL
  edDate := dSetDate
  dDate := edDate
endif
return iif( !edDate = NIL, edDate, date() )
//-------------
function whatcolor

local x := menu_v( "Colors", "Change Current Settings", "Reset to default settings" )
if x = 0
   return .f.
elseif x = 1
   chn_color()
elseif x = 2
   close all
   c_loadit('RESET')     // first time it replaces the records
   gwdisablecolor()
   c_loadit()            // the second time, it activates the colors
endif
return .t.
//------------------
function traceback

local i  := 0
local yy := savescreen( 0, 0, 24, 79 )
local xx := ""
xx += "Traceback: Procedure/Method Name (Line);"
xx += replicate( "-", 39 ) + ';;'
do while ( !empty( procname( i ) ) )
   xx += trim( procname( i ) ) + "(" + rtrim( ltrim( str( procline( i ++ ) ) ) ) + ")" + ';'
enddo
@ 11, 19, 21, 51 box B_DOUBLE_SINGLE
memoedit( 12, 20, 20, 50, xx, .f. )
restscreen( 0, 0, 24, 79, yy )
return .t.
//-------------------
function pop_menu

if .not. empty( rtrim( ltrim( userName() ) ) )
   if ReqInv()
      InvPopMenu()
   else
      AccPopMenu()
   endif
else

   jSaveEnv()

   set default to ( dir() + "\PULLIMAN" )
   gwchdir( dir() + "\PULLIMAN" )
   OpenDir()

   keyboard "F" + chr( K_ENTER )        // to directly go to search phone.
   ea_phone()
   set default to ( dir() )
   close all
   jRestEnv()
   return nil
endif
return .t.
//-------------------------------------------
static function InvPopMenu

local cOldS    := savescreen( 0, 0, 24, 79 )
local aActions

local nSel
local cOldColor := setcolor()

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
      sysstatus()
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
static function AccPopMenu

local cOldS    := savescreen( 0, 0, 24, 79 )
local aActions

local nSel
local cOldColor := setcolor()

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
      sysstatus()
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
function marketing

local x := 1
setcolor( boxcolor() )
do while .not. x = 0
   close all
   dispbegin()
   dispscrn()
   setcolor( scrcolor() )
   @  8, 26 say padc( 'Marketing', 51 - 25 )         
   dispend()
   x := aPick( 9, 26, 13, 51, { 'Add/Edit Promoters', 'Payments', 'View Individual Accounts', 'Get Complete Report' } )
   if x = 1
      refrs_view( .F., .T. )
   elseif x = 2
      addeditpays()
   elseif x = 3
      viewindacc()
   elseif x = 4
      tone( 2932, 1 )
      tone( 4231, 1 )
      jAlert( 'Work In Progres!!!' )
      tone( 6231, 1 )
   else
      exit
   endif
enddo
dispscrn()
return .t.
//-------------------------------------------

*+ EOF: POPMENU.PRG
