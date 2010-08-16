/*
#
#     Accounts sub-system
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

function accview( lAddEdit, lOpen, lView, cColor, lDaybook, lSelSub, bFilter )

local oBrowse
local oColumn
local nKey
local bBox
local cOldScreen := savescreen()
local nTemp
local lOrder

if lSelSub=NIL
   lSelSub := .f.
endif

if bFilter = nil
  bFilter := {||.t.}
endif

if lDaybook = NIL
   lDaybook := .f.
endif

if lDaybook
   lView    := .t.
   lOpen    := .f.
   lAddEdit := .f.
   cColor   := msgcolor()
endif

if cColor = NIL
   cColor := boxcolor()
endif

setcolor( cColor )
if !lOpen
   select accounts
   lOrder := indexord()
endif
if lAddEdit = NIL
   lAddEdit := .t.
endif
if lOpen = NIL
   lOpen := .t.
endif
if lView = NIL
   lView := .t.
endif

if lOpen
   use SUBHEADS new index SUB_1,SUB_2,SUB_3
   use ACCOUNTS new index ACC_1,ACC_2
   seek 1           // Default A/C should come CASH
   set order to 2
else
   sele ACCOUNTS
   set order to 2
endif

if lView .and. ( !lDaybook )
   bBox := makebox( 5, 41, 21, 78, cColor, 0 )
   setcolor( scrcolor() )
   @  4, 41 say padc( 'Select Account', 38 )                          
   @ 22, 41 say padc( 'þ S - Search       þ L - Ledger', 38 )         
   sele ACCOUNTS
   set order to 2
elseif !lDaybook .and. ( !lView )
   bBox := makebox( 3, 1, 21, 78, cColor, 0 )
   setcolor( scrcolor() )
   if lAddEdit
      @  2,  1 say padc( 'Add/Edit Accounts', 78 )                                                           
      @ 22,  1 say padc( 'þ A - Add A/C        þ ENTER - Select    þ E - Edit    þ L - Ledger', 78 )         
   else
      @  2,  1 say padc( 'Select Account', 78 )                                                
      @ 22,  1 say padc( 'þ ENTER - Select     þ S - Search        þ L - Ledger', 78 )         
      sele ACCOUNTS
      set order to 2
   endif
elseif lDayBook
   bBox := makebox( 15, 4, 21, 74, cColor, 0 )
   setcolor( scrcolor() )
   @ 14,  4 say padc( 'Select Account', 71 )                                                
   @ 22,  4 say padc( 'þ ENTER - Select     þ S - Search        þ L - Ledger', 71 )         
   sele ACCOUNTS
   set order to 2
endif

setcolor( cColor )
if ( !lDaybook ) .and. ( !lView )
   oBrowse := TBrowseDB( 4, 2, 20, 77 )
elseif ( !lDaybook ) .and. lView
   oBrowse := TBrowseDB( 6, 42, 20, 77 )
elseif lDaybook
   oBrowse := TBrowseDB( 16, 5, 20, 73 )
endif
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := cColor
oColumn           := TBColumnNew( 'Account Name', { || stBrAcName() } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )

if lView .and. ( !lDaybook )
   oColumn         := TBColumnNew( 'Details', { || subs( details, 1, 45 ) } )
   oColumn:footing := ''
   oBrowse:AddColumn( oColumn )
endif

if ! lDaybook
oColumn         := TBColumnNew( 'Op.Bal', { || stBrOpBal() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
endif

oColumn         := TBColumnNew( 'A/C Type', { || Type + iif(group,' [G]',' [ ]') } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oBrowse:autoLite := .f.
do while nKey <> iif( lView, K_ENTER, K_ESC )
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
   case nKey == K_ALT_R
      plswait( .t., 'Generating HTML...' )
      tb2Html( oBrowse, 'EARep.HTM', 'Accounts List' )
      plswait( .f. )
      msg( 'EARep.HTM created!' )
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
   case upper( chr( nKey ) ) == 'A' .and. lAddEdit
      addaccount()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E' .and. lAddEdit
      editaccount()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'     // Search
      oFilter := { || account + ', ' + details }
      jsfilt( oBrowse, 0, bFilter )
   case upper( chr( nKey ) ) == 'L'     // Ledger
      if id != 0
         nTemp := id
         jSaveEnv()
         close all
         ledger(, nTemp )
         jRestEnv()
      else
         tone( 200, 1 )
         tone( 392, 2 )
      endif
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      set filter to
      // 'Cauz it produces error due to some local variables
      // in the filter condition.
   case nKey == K_ESC .and. ( lDaybook )                    // Abort current record!
      restscreen( 0, 0, 24, 79, cOldScreen )
      return .f.
   endcase

   if nKey == K_ENTER .and. lView
      if empty( rtrim( ltrim( account ) ) )
         jAlert( "CANNOT SELECT AN EMPTY A/C;; Please Re-Enter" )
         nKey := 0
         loop
      else          // No need, because it is in the loop
         exit       // but still..., okay, okay. let it be there.
      endif
   endif

enddo
restscreen( 0, 0, 24, 79, cOldScreen )
if lSelSub
   if accounts->group
      SubView(accounts->id)
   endif
   sele accounts
endif
if .not. lOpen
   set order to (lOrder)
endif
return .t.
//===========================================================
function addaccount( cxType )

local _xx        := savescreen( 0, 0, 24, 79 )
local bBox
local cACName    := space( 40 )
local cACDetails := space( 40 )
local nOpBal     := 0.00
local cOpType    := ' '
local nDueDays   := 15
local nChoice    := 1
local cACType
local nId, lGroup := .f.
local aTypes

if reccount() >= 50 .and. _DEMO != 'REG'
   jAlert( 'Sorry, this is a LITE version of EasyAccounts which does ; not allow ' + ;
           'more than 50 accounts to be added.;; Please register the product and ' + ;
           'avail all the ; great features of ' + _EasyAccounts )
   return .f.
endif

if cxType != NIL
   aTypes := cxType
else
   aTypes := __aTypes
endif
dispscrn()
bBox := makebox( 6, 13, 20, 69, boxcolor() )
setcolor( scrcolor() )
@ 05, 13 say padc( 'Add Account', 57 )         
setcolor( boxcolor() )
do while .t.
   @ 07, 14 say "A/C Name  : " get cACName                                                                 pict '@!'               
   @ 09, 14 say "Details   : " get cACDetails                                                              pict '@!'               
   @ 11, 14 say "Op.Bal    : " get nOpBal         pict '9999999.99'       
   @ 11, 39 get cOpType ;
   valid upper( cOpType ) = 'D' .or. upper( cOpType ) = 'C' .or. cOpType = ' '


   @ 13, 14 say 'A/C Type  : '                                                                                                     
   @ 19, 24 say "<Save>"                                                                                                           
   @ 19, 48 say "<Abort>"                                                                                                          
   read
   if empty( cACName )
      nChoice := 2
      exit
   endif
   cOpType := upper( cOpType )
   @ 07, 14 say "A/C Name  :  " + cACName                      
   @ 09, 14 say "Details   :  " + cACDetails                   
   @ 11, 14 say "Op.Bal    :  " + str( nOpBal, 10, 2 )         

   @ 11, 39 say cOpType                                        
   if cxType = NIL
      @ 11, 42 say chr( 24 )            
      @ 15, 42 say chr( 25 )            
      @ 15, 30 say 'Select -->'         
      @ 10, 43, 16, 68 box B_DOUBLE_SINGLE
      cACType := achoice( 11, 44, 15, 67, aTypes )
      if cACType = 0
         nChoice := 2
         exit
      else
         cACType := aTypes[ cACType ]
      endif
   else
      cACType := cxType
   endif

   if cACType = 'Sundry Creditor' .or. cACType = 'Debtor'
      @ 17, 14 say 'Due Days  : ' get nDueDays pict '99'       
      read
      @ 17, 14 say 'Due Days  : ' + str( nDueDays, 3, 0 )
      lGroup := .f.
   elseif ! ( upper(alltrim(cACType)) = 'BANK' .or. upper(alltrim(cACType)) = 'CASH' )
      lGroup := 'N'
      @ 17, 14 say "Group <Y/N> ? : " get lGroup pict '!' valid lGroup='Y' .or. lGroup='N'
      read
      lGroup := (lGroup=='Y')
      @ 17, 14 say "Group <Y/N> ? : " + iif(lGroup,'YES','NO ')
   endif

   @ 13, 27 say cACType
   @ 19, 24 prompt "<Save>"
   @ 19, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo
if nChoice = 1
   sele accounts
   set filter to
   set order to 1
   go bott
   nId := id + 1
   append blank
   field->Id      := nId
   field->account := proper( cACName )
   field->details := proper( cACDetails )
   field->duedays := nDueDays
   field->group   := lGroup
   if cOpType = 'D'
      field->opbal := nOpBal
   else
      field->opbal := nOpBal * - 1
   endif
   field->type := cACType
   set order to 2
   jRUnLock()
endif
restscreen( 0, 0, 24, 79, _xx )
return nil
//-----------------------------------------------------
function editaccount( cxType )

local _xx        := savescreen( 0, 0, 24, 79 )
local bBox
local cACName    := account
local cACDetails := details
local nOpBal     := abs( opbal )
local cOpType    := iif( opbal < 0, 'C', 'D' )
local nChoice    := 1
local nId, lGroup := group
local nDueDays   := duedays
local aTypes     := __aTypes
local cACType    := ascan( aTypes, rtrim( ltrim( type ) ) )
dispscrn()
bBox := makebox( 4, 13, 18, 69, boxcolor() )
setcolor( scrcolor() )
@ 03, 13 say padc( 'Edit Account', 57 )         
setcolor( boxcolor() )
do while .t.
   @ 05, 14 say "A/C Name  : " get cACName                                                                 pict '@!'               
   @ 07, 14 say "Details   : " get cACDetails                                                              pict '@!'
   @ 09, 14 say "Op.Bal    : " get nOpBal                                                                  pict '9999999.99'       
   @ 09, 39 get cOpType        valid upper( cOpType ) = 'D' .or. upper( cOpType ) = 'C' .or. cOpType = ' '

   @ 11, 14 say 'A/C Type  : '                                                                                                     
   @ 17, 24 say "<Save>"                                                                                                           
   @ 17, 48 say "<Abort>"                                                                                                          
   read
   cOpType := upper( cOpType )
   @ 05, 14 say "A/C Name  :  " + cACName                      
   @ 07, 14 say "Details   :  " + cACDetails                   
   @ 09, 14 say "Op.Bal    :  " + str( nOpBal, 10, 2 )         
   @ 09, 39 say cOpType                                        
   if empty( cACName )
      nChoice := 2
      exit
   endif
   if cxType = NIL
      @ 11, 42 say chr( 24 )         
      @ 15, 42 say chr( 25 )         
      @ 13, 30 say 'Select -->'         
      @ 10, 43, 16, 68 box B_DOUBLE_SINGLE
      cACType := achoice( 11, 44, 15, 67, aTypes,,, cACType )
      if cACType = 0
         nChoice := 2
         exit
      else
         cACType := aTypes[ cACType ]
      endif
      @ 11, 27 say cACType         
   else
      cACType := cxType
      @ 11, 27 say cACType         
   endif
   if cACType = 'Sundry Creditor' .or. cACType = 'Debtor'
      @ 15, 14 say 'Due Days  : ' get nDueDays pict '99'       
      read
      @ 15, 14 say 'Due Days  : ' + str( nDueDays, 3, 0 )
      lGroup := .f.
   elseif ! ( upper(alltrim(cACType)) = 'BANK' .or. upper(alltrim(cACType)) = 'CASH' )
      lGroup := iif( lGroup, 'Y','N' )
      @ 15, 14 say "Group <Y/N> ? : " get lGroup pict '!' valid lGroup='Y' .or. lGroup='N'
      read
      lGroup := (lGroup=='Y')
      @ 15, 14 say "Group <Y/N> ? : " + iif(lGroup,'YES','NO ')
   endif
   @ 17, 24 prompt "<Save>"
   @ 17, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo
if nChoice = 1
   if id = 1        // Cash Account
      if upper( subs( cACName, 1, 4 ) ) != 'CASH'
         msg( 'Cash Account name cannot be altered..' )
         cACName := 'Cash'
         @ 05, 14 say "A/C Name  :  " + cACName         
      endif
   endif
   jRLock()
   field->account := proper( cACName )
   field->details := proper( cACDetails )
   field->group   := lGroup
   field->duedays := nDueDays
   if cOpType = 'D'
      field->opbal := nOpBal
   else
      field->opbal := nOpBal * - 1
   endif
   field->type := cACType
   jRUnLock()
endif
restscreen( 0, 0, 24, 79, _xx )
return nil
//----------------------------------------------
function dayremarks

local lClosed
local cRemarks := " "
ontask( 'Opening remark book...' )
set cursor on
setcursor( .t. )
setcursor( 1 )
use bookstat new index BSTAT_1
locate all for date = entr_date()
if !found()
   append blank
   field->date := entr_date()
else
   lClosed := closed
endif
ontask()
//
// As on 09-11-2002. Father told to allow editing even after closure. So we
// can take printouts of those remarks which have'nt been closed (solved)
// periodwise.
//
cRemarks := j_getmemo( 05, 5, 18, 75, remarks, 'Remarks for ' + dtoc( entr_date() ), .t. )
cRemarks := hardcr( cRemarks )
jRLock()
if !len( alltrim( cRemarks ) ) = 0
   field->remarks := cRemarks
else
   field->remarks := space( 10 )
endif
jRUnLock()
// Field is not being saved by giving direct command.
close all
setcursor( 0 )
setcursor( .f. )
return .t.
//-------------------------------------
function ac_closed( dDate )

local lClose
local cAlias := alias()
if dDate = NIL
   dDate := entr_date()
endif
use bookstat new index BSTAT_1
seek dDate
if !found()
   append blank
   field->closed := .f.
   field->date   := dDate
   lClose        := .f.
else
   lClose := closed
endif
use
if !empty( cAlias )
   select ( cAlias )
endif
return lClose
//------------------------------
function close_ac( dDate )
/*
set console on
set default to ( dir( 'pulliman' ) )
doclose( dDate )
set default to ( dir( 'kollam' ) )
doclose( dDate )
set default to ( dir( 'graphics' ) )
doclose( dDate )
set default to ( dir( 'adm' ) )
doclose( dDate )
*/
// No more grouped closing/opening from Administration -- 01/04/2004 . by jas
// the special privilege of administration company has been removed...
// now only INdividual closures..
return .t.
//----------------------------
function open_ac( dDate )
// No more grouped closing/opening from Administration -- 01/04/2004 . by jas
// the special privilege of administration company has been removed...
// now only INdividual closures..
/*
set default to ( dir( 'pulliman' ) )
doopen( dDate )
set default to ( dir( 'kollam' ) )
doopen( dDate )
set default to ( dir( 'graphics' ) )
doopen( dDate )
set default to ( dir( 'adm' ) )
doopen( dDate )
*/
return .t.
//------------------------------
function doclose( dDate )

local nSale      := 0.00
local nPurch     := 0.00
local nProfit    := 0.00
local nDiscount  := 0.00
local nDocId
local nTemProfit := 0.00

&& A New method for searching in SALES file where there is no date.
&& I need to go through saccount for the sales. At that time, I write
&& down the beginning Sale ID and ending Sale ID and seeks it in Sales
&& and continues down till I reach the End Id.
&&
&& But there is a problem with End ID, in Saccount it is in Date index
&& and SALE is in Doc.ID order. if data is fed not in the proper
&& order (ie, doc.no of different dates are mixed in no order.), the
&& End Id may come too late (ie, after evaluating the records not of
&& that date) or too early (ie,before evaluating all the records of
&& that date) therefore it is better to avoid the End Id and I am doing so.

// GUYS! But I feel it buggy and tiresome. So left off.
// May use this technic in some other situation.

use bookstat new index BSTAT_1
seek dDate

if ReqInv(.t.) .and. file( 'PACCOUNT.DBF' ) .and. file( 'SACCOUNT.DBF' ) .and. file( 'SALES.DBF' )

   use PACCOUNT new index PAC_2
   use SACCOUNT new index SAC_2,SAC_1
   use SALES new index SALE_1
   sele saccount
   seek dDate
   if found()
      do while date == dDate .and. ( !eof() )
         nSale     += total
         nDiscount += discount
         skip
      enddo
   endif

   sele saccount
   set order to 2 // earlier it was DATE, now it Should be DOC.NO
   sele sales
   go top
   do while .not. eof()
      nDocId := id
      sele saccount
      seek sales->id
      if date == dDate .and. ( ( rtrim( ltrim( other ) ) != 'Standby' ) .and. ( rtrim( ltrim( other ) ) != 'Transfer' ) .and. ( rtrim( ltrim( other ) ) != 'Return' ) )
         sele sales
         do while id == nDocId .and. ( !eof() )
            nProfit    += price - cost
            nTemProfit += price - cost
            skip
         enddo
      else
         sele sales
         skip
      endif
      nTemProfit := 0.00
      sele sales
   enddo

   sele paccount
   seek dDate
   if found()
      if ( ( rtrim( ltrim( bill ) ) != 'Standby' ) .and. ( rtrim( ltrim( bill ) ) != 'Transfer' ) .and. ( rtrim( ltrim( bill ) ) != 'Return' ) )
         do while date == dDate .and. ( !eof() )
            nPurch += total
            skip
         enddo
      else
         skip
      endif
   endif
endif

sele bookstat
if !found()
   append blank
   field->date := dDate
endif

jRLock()
field->profit   := nProfit
field->sale     := nSale
field->purchase := nPurch
field->discount := nDiscount
field->closed   := .t.
jRUnLock()
close all

return .t.
//-----------------------------------------
function doopen( dDate )

use bookstat new index BSTAT_1
seek dDate
if found()
   jRLock()
   field->closed := .f.
   jRUnLock()
endif
close all
return .t.
//-----------------------------------------
function RemarksList

local dFrom    := date() - 7
local dTo      := date()
local nLine    := 1
local nCurrent
local aMemo
popread( .f., 'From :', @dFrom, '@D', 'To   :', @dTo, '@D' )
if empty( dFrom ) .or. empty( dTo ) .or. ( dFrom > dTo )
   msg( 'Invalid dates...' )
   return .f.
endif
use bookstat new index BSTAT_1
locate all for ( date >= dFrom .and. date <= dTo )
// Maybe the exact dFrom may not be in it. Therefore we open the
// database in date order and can see which date lies first in the
// specified date.
if ( !found() ) .or. eof()
   close all
   msg( 'No remarks in the specified date range...' )
   return .f.
endif

set printer to ( RepPath + "REMLIST.TXT" )
set device to printer
set printer on

SayTitles( 68, @nLine )
nLine ++
@ nLine,  1 say padc( 'Remarks from ' + dtoc( dFrom ) + ' to ' + dtoc( dTo ), 68 )         
nLine ++
@ nLine,  1 say repli( '-', 68 )         
nLine ++
do while ( date >= dFrom .and. date <= dTo ) .and. ( !eof() )
   if !empty( alltrim( remarks ) )
      @ nLine,  1 say cdow( date ) + ' ' + alltrim( str( day( date ) ) ) + ' ' + cmonth( date ) + ' ' + ;         
              str( year( date ), 4, 0 ) + ' ** ' + dtoc( date )
      nLine ++
      aMemo := Memo2Array( remarks, 68, 3, .t. )
      for nCurrent := 1 to len( aMemo )
         @ nLine,  1 say aMemo[ nCurrent ]         
         nLine ++
      next nCurrent

      @ nLine,  1 say repli( '-', 68 )         
      nLine ++
   endif
   skip
enddo
nLine ++
nLine ++
nLine ++
@ nLine,  0 say space( 10 )         
set device to screen
set printer off
set printer to
fileread( 1, 10, 23, 69, ( RepPath + 'REMLIST.TXT' ), 'Remarks Report' )
return .t.
//----------------------------------------------------
static function stBrACName

return ;
        padr( alltrim( ACCOUNT ) + ;
        iif( empty( alltrim( details ) ), "", ", " + alltrim( details ) ), 33 )

static function stBrOpBal

return iif( opbal != 0, str( abs( opbal ), 10, 2 ) + ' ' + iif( opbal > 0, 'Dr', 'Cr' ), space( 13 ) )
//--------------------------------------------------------------
function SubView()
local oBrowse
local oColumn
local nKey
local bBox
local cOldScreen := savescreen()
local nAcId, nSubId

local nId, cSubName := space(40), cDetails := space(40)

sele subheads
set order to 2   // PARENT_ID+SUBGROUP NAME
set filter to parent_id == accounts->id
if parent_id != accounts->id    // The record is wrongly positioned...
  go top
endif

bBox := makebox( 3, 35, 21, 78,, 0 )
setcolor(scrcolor())
@  2,  35 say padc( 'SUB-ACCOUNTS of '+alltrim(accounts->account), 44 )
@ 22,  35 say padc( '  þ A/E - Add/Edit             þ ENTER - Select', 44 )         
setcolor(boxcolor())

oBrowse := TBrowseDB( 4, 36, 20, 77 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oColumn           := TBColumnNew( 'Subhead Name', { || subhead } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Details', { || details } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oBrowse:autoLite := .f.

do while nKey <> K_ENTER
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
   case nKey == K_ALT_R
      plswait( .t., 'Generating HTML...' )
      tb2Html( oBrowse, 'EARep.HTM', 'Subheads List of '+alltrim(accounts->account) )
      plswait( .f. )
      msg( 'EARep.HTM created!' )
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
      cSubName := space(40)
      cDetails := space(40)
      popread(.f.,'þ Add þ Subhead Name : ', @cSubName,'@!',;
                  '             Details : ', @cDetails,'@!')
      cSubName := alltrim(cSubName)
      cDetails := alltrim(cDetails)
      if ! empty(cSubName)
         sele subheads
         set order to 1
         set filter to
         go bott
         nId := id + 1
         append blank
         field->id := nId 
         field->parent_id := accounts->id
         field->subhead := cSubName
         field->details := cDetails
         jRUnLock()

         set filter to parent_id == accounts->id
         go top
         oBrowse:refreshall()
      else
         msg('Invalid entry..')
      endif
   case upper( chr( nKey ) ) == 'E'
      sele subheads
      cSubName := subhead
      cDetails := details
      popread(.f.,'þ Edit þ Subhead Name : ', @cSubName,'@!',;
                  '             Details : ', @cDetails,'@!')
      cSubName := alltrim(cSubName)
      cDetails := alltrim(cDetails)
      if ! empty(cSubName)
         jRLock()
         field->subhead := cSubName
         field->details := cDetails
         jRUnLock()
         oBrowse:refreshall()
      else
         msg('Invalid entry..')
      endif
   case upper( chr( nKey ) ) == 'S'     // Search
      oFilter := { || subhead + ', ' + details }
      jsfilt( oBrowse, 0, { || parent_id == accounts->id } )
   case upper( chr( nKey ) ) == 'L'    // ledger
      nAcId := accounts->id
      nSubId := subheads->id
      jSaveEnv()
      close all
      ledger( .t., nAcId, nSubId )
      close all
      jRestEnv()
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
   endcase

   if nKey == K_ENTER
      if empty( rtrim( ltrim( subhead ) ) )
         jAlert( "CANNOT SELECT AN EMPTY SUB-A/C;; Please Re-Enter" )
         nKey := 0
         loop
      else          // No need, because it is in the loop
         exit       // but still..., okay, okay. let it be there.
      endif
   endif
enddo
restscreen( 0, 0, 24, 79, cOldScreen )
return .t.
//------------------------------------------------------------
*+ EOF: ACCOUNTS.PRG
