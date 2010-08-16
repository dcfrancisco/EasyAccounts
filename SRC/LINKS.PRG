/*
#
#     Links Manager (PUBLIC ACCOUNTS)
#              for EasyAccounts v1.5
#
#     Developed and Tested by Jasim A B
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
#    --------------------------------
#          Now, NETWORK ENABLED!!
#           (C) Jasim A Basheer
#    ---------------------------------
*/

#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

static aComps
static aDirs

function Links( lDoOnlyDir )

static cOldDir
static cOldPath
static cOldComp
static ccurDir

if lDoOnlyDir = NIL
   lDoOnlyDir := .f.
endif

if !lDoOnlyDir
   cOldDir  := dir()
   cOldPath := curdir()
   cOldComp := comp_add
   cCurDir  := NetDrive+':\EA\' + DataDir()
endif

jdDir( ccurDir )
gwChDir( ccurDir )
set default to ( ccurDir )

if lDoOnlyDir       // This func. is called from lnk_1Add to reset the dir.status
   return .t.       // after selecting an account from another company dir.
endif

plInitComps()

if !file('LINKS.DBF')
  dbcreate('LINKS',{ {'DIR','C',8,0},;
                     {'COMP','C',30,0},;
                     {'GLOBAL_ID','N',6,0},;
                     {'ACCOUNT','N',6,0},;
                     {'DESC','C',40,0} })
  ferase('LINKS_1.CDX')     // If it even remotely exists!
endif

if !file( 'LINKS_1.CDX' )
   eUse( "LINKS" )
   IndexBar( 'LINKS_1', 'GLOBAL_ID' )
   IndexBar( 'LINKS_2', 'DESC' )
   set unique on
   IndexBar( 'LINKS_3', 'GLOBAL_ID',,, .T. )
   set unique OFF
endif
close all

eUse( "links" )
set index to LINKS_1, LINKS_2, LINKS_3
set order to 3
linkBrowse()
close all
return .t.

static function LinkBrowse

local oBrowse
local oColumn
local nKey
local bBox
local cOldScreen := savescreen()
local lOrder
local cColor
local _xx
cColor := boxcolor()
setcolor( cColor )
bBox := makebox( 5, 18, 21, 60, cColor, 0 )
setcolor( scrcolor() )
@  4, 18 say padc( 'Public Accounts', 43 )                                  
@ 22, 18 say padc( 'þA-Add   þE-Edit   þR-Report   þS-Search', 43 )         
setcolor( cColor )
oBrowse           := TBrowseDB( 6, 19, 20, 59 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := cColor
oColumn           := TBColumnNew( 'Public Account', { || subs( desc, 1, 37 ) } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      //ÄÄÄÄ highlight current row
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 2, 2 } )
      oBrowse:hilite()
      nKey := inkey( 0 )
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 1, 2 } )
   endif
   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_RIGHT
      oBrowse:right()
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case upper( chr( nKey ) ) == 'A'
      lnk_add()
      sele links
      set order to 3
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E'
      lnk_edit()
      sele links
      set order to 3
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'     // Search
      oFilter := { || desc }
      jsfilt( oBrowse, 0, { || .t. } )
   case upper( chr( nKey ) ) == 'R'
      _xx := savescreen()
      pb_report()
      restscreen( 0, 0, 24, 79, _xx )
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      set filter to
      // 'Cauz it produces error due to some local variables
      // in the filter condition.
   endcase

enddo
restscreen( 0, 0, 24, 79, cOldScreen )
return nil
//-------------------------------------
static function lnk_add()

local bBox
local cPDesc  := space( 40 )
local nChoice := 1
local nId
local cScr    := savescreen( 0, 0, 24, 79 )

bBox := makebox( 10, 18, 15, 64, boxcolor() )
setcolor( scrcolor() )
@ 09, 18 say padc( 'Add Public Account', 47 )         
setcolor( boxcolor() )
@ 11, 22 say "Public A/C :- "         
footline( 13, 19, 64 - 19 )
@ 14, 25 say '<Save>'                   
@ 14, 40 say '<Abort>'                  
@ 12, 22 get cPDesc    pict '@!'        
read
@ 12, 22 say cPDesc         
cPDesc := rtrim( ltrim( cPDesc ) )
if empty( cPDesc )
   unbox( bBox )
   restscreen( 0, 0, 24, 79, cScr )
   return .f.
endif

@ 14, 25 prompt '<Save>'
@ 14, 40 prompt '<Abort>'
menu to nChoice
if nChoice = 2
   unbox( bBox )
   restscreen( 0, 0, 24, 79, cScr )
   return .f.
else
   set order to 1
   go bott
   nId := GLOBAL_ID + 1
   set order to 3
   append blank
   field->GLOBAL_ID := nId
   field->DESC      := cPDesc
   unbox( bBox )
   restscreen( 0, 0, 24, 79, cScr )
   lnk_Edit()
endif
unbox( bBox )
restscreen( 0, 0, 24, 79, cScr )
return .t.
//-----------------------------------------------
static function lnk_Edit

local bBox, pDesc := links->desc, pId := GLOBAL_ID, pComp := alltrim( comp )
local pDir     := rtrim( ltrim( dir ) )
local pAccount := account
local _xx      := savescreen()
dispscrn()

bBox := makebox( 06, 13, 20, 69, boxcolor() )

setcolor( scrcolor() )
@ 05, 13 say padc( 'Edit Public Account', 57 )         
setcolor( boxcolor() )

@ 07, 14 say 'Public A/C : ' + alltrim( subs( pDesc, 1, 40 ) )         
footline( 08, 14, 55 )

if account = 0
   lnk_1Add( .t., pId, pDesc )
endif

pDesc    := desc
pId      := GLOBAL_ID
pComp    := alltrim( comp )
pDir     := rtrim( ltrim( dir ) )
pAccount := account

set order to 2
cmFilter( "GLOBAL_ID == "+cm2Str(pId) )
go top
lnk_gAcs( pId )
set filter to
set order to 3
go top

unbox( bBox )

restscreen( 0, 0, 24, 79, _xx )
return nil

//-------------------------
static function plInitComps

aComps := {}
aDirs  := {}
use SYSTEM.EA
// Directory is set to EA\02 or whatever it is..
do while .not. eof()
   if !subs( alltrim( upper( comp ) ), 1, 6 ) = 'SYSTEM'
      aadd( aComps, comp )              // aPick requires a single dimensioned array.
      aadd( aDirs, dir )
   endif
   skip
enddo
use
return .t.
//-------------------------

static function lnk_1Add( lEdit, cGId, cPDesc )

local cComp
local cDir
local nAcId
local cAcName
local nChoice
local _jXx    := savescreen()
dispscrn()
makebox( 10, 13, 19, 66 )
setcolor( scrcolor() )
@ 09, 13 say padc( 'Create new Link', 54 )         
setcolor( boxcolor() )
@ 11, 14 say "Public A/C : " + subs( cPDesc, 1, 28 )         
footline( 12, 14, 52 )
@ 13, 15 say 'Link from company : '             
@ 15, 15 say 'Account to be linked :- '         
cComp := aPick(,,,, aComps, boxColor(), boxColor(), boxColor() )

if cComp = 0 .or. cComp = NIL
   restscreen( 0, 0, 24, 79, _jXx )
   return .f.
endif

cDir  := aDirs[ cComp ]
cComp := aComps[ cComp ]
@ 13, 15 say 'Link from company : ' + subs( cComp, 1, 51 )         
@ 15, 15 say 'Account to be linked :- '                            
set default to ( NetDrive+':\EA\' + DataDir() + '\' + cDir )
gwChDir( NetDrive+':\EA\' + DataDir() + '\' + cDir )
accView( .f., .t., .t., msgColor() )
// opens ACCOUNTS,indices and selects the account.
setcolor( boxcolor() )
nAcId   := id
cAcName := account
use
select SUBHEADS
use
select LINKS
@ 15, 15 say 'Account to be linked :- '
setcolor( msgColor() )
@ 16, 19 say subs( cAcName, 1, 45 )         
setcolor( boxcolor() )
@ 18, 30 prompt '<Save>'
@ 18, 40 prompt '<Abort>'
menu to nChoice
if nChoice = 1
   if !lEdit
      append blank
   endif
   field->GLOBAL_ID := cGId
   field->DESC      := cPDesc
   field->dir       := cDir
   field->COMP      := cComp
   field->ACCOUNT   := nAcId
endif

links( .t. )
restscreen( 0, 0, 24, 79, _jXx )
return .t.

//-------------------------
static function lnk_gAcs( pId )

local oBrowse
local oColumn
local nKey
local cOldScreen := savescreen()
local lOrder
local cPDesc     := links->desc
setcolor( scrcolor() )
@ 19, 14 say padc( "þ A - Add   þ D - Delete   þ S - Search   þ ESC - Exit", 55 )         
setcolor( boxcolor() )
footline( 18, 14, 55 )
oBrowse           := TBrowseDB( 9, 15, 17, 68 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := boxcolor()
oColumn           := TBColumnNew( 'Company', { || subs( COMP, 1, 25 ) } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Account', { || subs( lnk_tellac(), 1, 25 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      //ÄÄÄÄ highlight current row
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 2, 2 } )
      oBrowse:hilite()
      nKey := inkey( 0 )
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 1, 2 } )
   endif
   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_RIGHT
      oBrowse:right()
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case upper( chr( nKey ) ) == 'A'
      lnk_1Add( .f., pId, cPDesc )
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'D'
      plswait( .t., 'Please wait..' )
      delete
      pack
      set order to 1
      go top
      plswait( .f. )
      oBrowse:refreshall()
      oBrowse:forcestable()
      do while .not. oBrowse:stabilize()
      enddo
   case upper( chr( nKey ) ) == 'S'     // Search
      oFilter := { || comp + " " + lnk_tellac() }
      jsfilt( oBrowse, 0, { || GLOBAL_ID == pId } )
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      set filter to
      // 'Cauz it produces error due to some local variables
      // in the filter condition.
   endcase
enddo
restscreen( 0, 0, 24, 79, cOldScreen )
return nil
//-----------------------
static function lnk_TellAcc( lDoLink )

local cDir := alltrim( dir ), cRet
if lDoLink = NIL
   lDoLink := .t.
endif
if !empty( cDir )
   if ! file( NetDrive+':\EA\' + DataDir() + '\' + cDir+'\ACCOUNTS.DBF')
      jAlert(" ** DATA COMPANY MISSING **;"+cDir+" data directory "+;
             "missing from the catalog. Either delete the defective link or "+;
             "provide the required data directory in this catalog" )

      cRet := "Data Directory Missing!"
      select LINKS
   else
      set default to ( NetDrive+':\EA\' + DataDir() + '\' + cDir )
      gwChDir( NetDrive+':\EA\' + DataDir() + '\' + cDir )
      use accounts new index ACC_1
      seek links->account
      if !found()
         cRet := "** LINKED A/C MISSING! **"
      else
         cRet := subs( account, 1, 45 )
      endif
      use
      if lDoLink
         Links( .t. )
      endif
      select LINKS
   endif
else
   cRet := 'No Account Linked!'
endif
return cRet
//--------------------
static function pb_report

local _xx         := savescreen()
local bBox
local pDesc       := links->desc
local lSummary
local lGrpDate
local lByDate
local lByPeriod
local lWithOp
local lWithIDComp
local lWithIdAC
local dFrom
local dTo
local nGId
local cIdDesc
DispScrn()

bBox := makebox( 04, 13, 20, 69, boxcolor() )
// To save the portion of SCRCOLOR HEADING too...

makebox( 05, 13, 20, 69, boxcolor() )

setcolor( scrcolor() )
@ 04, 13 say padc( 'Ledger of Public Account', 57 )         
setcolor( boxcolor() )

@ 06, 15 say 'Public A/C  : ' + alltrim( subs( pDesc, 1, 38 ) )         
footline( 07, 14, 55 )
@ 08, 15 say 'Report Type : '         
@ 09, 15 say 'Order By    : '         
footline( 10, 14, 55 )
@ 11, 15 say 'By Period ? <Y/N> '         
@ 11, 42 say 'From :'                     
@ 12, 42 say '  To :'                     
footline( 13, 14, 55 )
@ 14, 15 say 'With :'                                   
@ 15, 15 say '    Daily Balance ? <Y/N> '               
@ 16, 15 say '    Op.Balance ? <Y/N> '                  
@ 17, 15 say '    A/C Company Name ? <Y/N> '            
@ 18, 15 say '    Individual A/C Name ? <Y/N> '         

//            12345678901234
@ 08, 15 + 14 + 2 prompt '<Detailed>'
@ 08, 42 prompt '<Summary>'
menu to lSummary
if lSummary = 0
   unbox( bBox )
   restscreen( 0, 0, 24, 79, _xx )
   return .f.
elseif lSummary = 2
   lSummary := .t.
else
   lSummary := .f.
endif

if !lSummary
   @ 09, 15 say 'Order By    : '         
   @ 09, 15 + 14 + 2 prompt '<By Date>'
   @ 09, 42 prompt '<By Account>'
   menu to lGrpDate
   if lGrpDate = 0
      unbox( bBox )
      restscreen( 0, 0, 24, 79, _xx )
      return .f.
   elseif lGrpDate = 1
      lGrpDate := .t.
   else
      lGrpDate := .f.
   endif
endif

@ 11, 15 say 'By Period ? <Y/N> '         
clear typeahead
lByPeriod := opconfirm()
@ 11, 15 say 'By Period ? <Y/N> ' + iif( lByPeriod, 'Yes', 'No' )         

if lByPeriod
   dFrom := date()
   dTo   := date()
   @ 11, 42 say 'From :' get dFrom pict '@D'       
   @ 12, 42 say '  To :' get dTo   pict '@D'       
   read
   @ 11, 42 say 'From : ' + dtoc( dFrom )         
   @ 12, 42 say '  To : ' + dtoc( dTo )           

   if empty( dFrom ) .or. empty( dTo ) .or. ( dFrom > dTo )
      msg( 'Invalid Dates!' )
      restscreen( 0, 0, 24, 79, _xx )
      return .f.
   endif
endif
@ 15, 15 say '    Daily Balance ? <Y/N> '         
lByDate := opconfirm()
@ 15, 15 say '    Daily Balance ? <Y/N> ' + iif( lByDate, 'Yes', 'No' )         

@ 16, 15 say '    Op.Balance ? <Y/N> '         
lWithOp := opconfirm()
@ 16, 15 say '    Op.Balance ? <Y/N> ' + iif( lWithOp, "Yes", "No" )         

@ 17, 15 say '    A/C Company Name ? <Y/N> '         
lWithIdComp := opconfirm()
@ 17, 15 say '    A/C Company Name ? <Y/N> ' + iif( lWithIdComp, "Yes", "No" )         

@ 18, 15 say '    Individual A/C Name ? <Y/N> '         
lWithIdAC := opconfirm()
@ 18, 15 say '    Individual A/C Name ? <Y/N> ' + iif( lWithIdAC, "Yes", "No" )         

unbox( bBox )

Links( .t. )        // Go to C:\EA\02 in case there is any change in directories.

eUse( "PREPORT" )
zap

sele links
set order to 1
nGId := GLOBAL_ID
go top
seek nGId
setcursor( 0 )
set cursor off
do while nGId == GLOBAL_ID .and. ( !eof() )
   cIdDesc := rtrim( ltrim( comp ) ) + ", " + rtrim( ltrim( lnk_TellAc( .f. ) ) )

   if ! file( NetDrive+":\EA\" + DataDir() + "\" + links->dir+"\ACCOUNTS.DBF" )
      jAlert(" ** DATA COMPANY MISSING **;"+cDir+" data directory "+;
             "missing from the catalog. Either delete the defective link or "+;
             "provide the required data directory in this catalog" )
   else
      set default to ( NetDrive+":\EA\" + DataDir() + "\" + links->dir )
      GwChDir( NetDrive+":\EA\" + DataDir() + "\" + links->dir )
      if !lSummary
         plswait( .t., 'Grouping transactions...' + cIdDesc )
         pb_ILedger( rtrim( ltrim( links->comp ) ), alltrim( lnk_TellAc( .f. ) ), lByDate, lByPeriod, lWithOp, lWithIdAC, lWithIdComp, dFrom, dTo )
         plswait( .f. )
      else
         //pb_IBals( cIdDesc, lWithOp )
      endif
      sele links
      skip
   endif
enddo
setcursor( 1 )
set cursor on
sele PREPORT
use

links( .t. )

if ( !lSummary ) .and. ( lByPeriod )
   splitdbk( dFrom, dTo, lWithOp )
endif

eUse( "PREPORT" )
indexbar( 'PREP_1', 'DATE' )
use
if lGrpDate
   lnk_led1( pDesc, lByDate, lWithIdAC, lWithIDComp, dFrom, dTo )
else
   //lnk_led2( pDesc, lByDate, lWithIdAC, lWithIDComp, dFrom, dTo )
endif
set cursor on
setcursor( 1 )
return .t.
//-----------------------------------------
static function pb_ILedger( cIdComp, cIdAcc, lByDate, lByPeriod, lWithOp, lWithIdAC, lWithIDComp, dFrom, dTo )

local nCashOp
local nBnkop
local nDayOp
local nOpBal  := 0.00
local lCash   := ( links->account = 1 )                     // is cash or not
local lBank
PRIVATE lAId    := links->account         // is cash or not
use accounts new index ACC_1
seek lAId
if found()
   nOpBal := opbal
   lBank  := rtrim( ltrim( upper( type ) ) ) == 'BANK'
else
   jAlert( "** Linked Account Missing **" )
   return .f.
endif

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
elseif proper( rtrim( ltrim( account ) ) ) == 'Cash'
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

if lWithOp
   if nOpBal != 0   // may be -ve or +ve, we want it. but we dont want zERO!
      sele PREPORT
      append blank
      if lWithIdComp
         field->id_desc := cIdComp
      endif
      if lWithIdAc
         field->id_desc := id_desc+" " + cIdAcc
      endif
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
   sele PREPORT
   appe blank
   if lWithIdComp
      field->id_desc := cIdComp
   endif
   if lWithIdAc
      field->id_desc := id_desc+" " + cIdAcc
   endif
   field->date    := cashbook->date
   field->details := proper( cashbook->details )
   if lCash
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
   sele PREPORT
   appe blank
   if lWithIdComp
      field->id_desc := cIdComp
   endif
   if lWithIdAc
      field->id_desc := id_Desc+" " + cIdAcc
   endif
   field->date := bankbook->date
   sele accounts

   if lBank
      seek bankbook->b_id
   else
      seek bankbook->account
   endif

   if found()
      y := subs( account, 1, 24 )
   else
      msg( "Bankbook record " + rtrim( ltrim( str( recno() ) ) ) + " mismatches with account!" )
      return .f.
   endif
   sele PREPORT
   if !lWithIdAC
      field->details := proper( y + '  ' + bankbook->details )
   else
      field->details := bankbook->details
   endif
   if lBank
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
   sele PREPORT
   appe blank
   if lWithIdComp
      field->id_desc := cIdComp
   endif
   if lWithIdAc
      field->id_desc := id_Desc+" " + cIdAcc
   endif
   field->date    := daybook->date
   field->details := proper( daybook->details )
   field->debit   := iif( daybook->action = 'D', daybook->amount, 0.00 )
   field->credit  := iif( daybook->action = 'C', daybook->amount, 0.00 )
   sele daybook
   skip
enddo

sele daybook
use
sele cashbook
use
sele accounts
use
sele bankbook
use
sele LINKS
return .t.
//-------------------
static function splitdbk( dS, dE, lWithOp )

local nOpBal := 0.00
eUse( "PREPORT" )
indexbar( 'PREP_1', 'DATE' )
go top
ShowPBar( "Arranging transactions by date..." )
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
   IncrPBar()
enddo
if lWithOp
   append blank
   field->details := 'Op.Balance as of ' + dtoc( dS )
   if nOpBal > 0
      field->debit := nOpBal
   elseif nOpBal < 0
      field->credit := abs( nOpBal )
   endif
endif
HidePBar()
sele PREPORT
use
return .t.
//----------------
static function lnk_led1( cPubDesc, lByDate, lWithIDAC, lWithIDComp, dFrom, dTo )

local line      := 1
local dDate
local totdebit  := 0.00
local totcredit := 0.00
local lSupp
use PREPORT NEW index PREP_1
go top
ShowPBar( "Writing ledger report..." )
set device to printer
set printer to (RepPath+'PREPORT.TXT')
set printer on
SayTitles( 99, @line )
line ++
@ line,  0 say padc( 'Public Account Report', 99 )         
line ++
@ line,  0 say padc( upper( alltrim( cPubDesc ) ), 99 )         
line ++
if !( dFrom = NIL )
   @ line,  0 say padc( 'From : ' + dtoc( dFrom ) + '  To : ' + dtoc( dTo ), 99 )         
   line ++
endif
line ++
@ line,  0 say repli( '-', 99 )         
line ++
@ line,  0 say "Date"                
@ line, 12 say "Transaction"         
@ line, 78 say "Debit"               
@ line, 89 say "Credit"              
line ++
@ line,  0 say repli( '-', 99 )         
line ++
sele PREPORT
do while .not. eof()
   if !deleted()
      if lByDate
         dDate := date
         do while dDate == date .and. ( !eof() )
            if !empty( date )
               @ line,  0 say date         
            endif
            if !empty( alltrim( ID_DESC ) )
               @ line, 12 say subs( rtrim( ltrim( ID_DESC ) ) + ', ' + rtrim( ltrim( details ) ), 1, 53 )         
            else
               @ line, 12 say details         
            endif
            if debit > 0
               @ line, 77 say str( debit, 10, 2 )         
            else
               @ line, 88 say str( credit, 10, 2 )         
            endif
            line ++
            totdebit  += debit
            totcredit += credit
            IncrPBar()
            skip
         enddo
         @ line, 78 say repli( '-', 9 )         
         @ line, 89 say repli( '-', 9 )         
         line ++
         @ line, 77 say str( totdebit, 10, 2 )          
         @ line, 88 say str( totcredit, 10, 2 )         
         line ++
         @ line, 60 say "Date Balance : "         
         if totdebit > totcredit
            @ line, 77 say str( totdebit - totcredit, 10, 2 )         
            totdebit  -= totcredit
            totcredit := 0.00
         else
            @ line, 88 say str( totcredit - totdebit, 10, 2 )         
            totcredit -= totdebit
            totdebit  := 0.00
         endif
         line ++
         line ++
      else
         if !empty( date )
            @ line,  0 say date         
         endif
         if !empty( alltrim( ID_DESC ) )
            @ line, 12 say subs( rtrim( ltrim( ID_DESC ) ) + ', ' + rtrim( ltrim( details ) ), 1, 53 )         
         else
            @ line, 12 say details         
         endif
         if debit > 0
            @ line, 77 say str( debit, 10, 2 )         
         else
            @ line, 88 say str( credit, 10, 2 )         
         endif
         line ++
         totdebit  += debit
         totcredit += credit
         IncrPBar()
         skip
      endif
   else
      IncrPBar()
      skip
   endif
enddo
if !lByDate
   @ line, 78 say repli( '-', 9 )         
   @ line, 89 say repli( '-', 9 )         
   line ++
   @ line, 77 say str( totdebit, 10, 2 )          
   @ line, 88 say str( totcredit, 10, 2 )         
   line ++
   @ line, 60 say "Net Balance :"         
   if totdebit > totcredit
      @ line, 77 say str( totdebit - totcredit, 10, 2 )         
   else
      @ line, 88 say str( totcredit - totdebit, 10, 2 )         
   endif
endif

line ++
line ++
line ++
line ++
@ line,  0 say padc( "**End Report**", 99 )         
set device to screen
set printer off
set printer to
sele PREPORT
use
ontask()
HidePBar()
FILEREAD( 1, 0, 23, 79, RepPath+"PREPORT.TXT", 'Public Account Report' )
return .t.
//-------------------
func PB_IBALS
return .t.
func LNK_LED2
return .t.
//-----------

*+ EOF: LINKS.PRG
