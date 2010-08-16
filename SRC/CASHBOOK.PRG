#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

static cashbal
static opcash

function cshentry(nId)

local oBrowse
local oColumn
local nKey
local lDeleted := .f.
local bBox
local nRec
setcolor( boxcolor() )
dispscrn()
ontask( 'Counting cash...' )
dispbegin()
bBox := makebox( 3, 1, 21, 78, boxcolor(), 0 )
setcolor( scrcolor() )
@  2,  1 say padc( 'Cashbook as on ' + dtoc( dDate ), 78 )         

if !ac_closed()
   @ 22,  1 say padc( 'þ A - Add Entry   þ D - Delete Entry   þ ENTER - Edit  þ ESC - Exit', 78 )
else
   @ 22,  1 say padc( 'þ ESC - Exit               (A/C Closed)', 78 )         
endif

setcolor( boxcolor() )
use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use cashbook new index CSH_1, CSH_2, CSH_3, CSH_4, CSH_5
recount()
set order to 2
set filter to (!deleted()) .and. date==dDate
go top
seek dDate
if nId <> NIL
 jDbPosition(nId)
endif
dispend()
oBrowse := TBrowseDb( 4, 2, 18, 77 )

/*
*oBrowse := TBrowseNew( 4, 2, 18, 77 )
*oBrowse:skipblock     := { | n | cs_skip( n ) }
*oBrowse:gotopblock    := { || cs_gotop() }
*oBrowse:gobottomblock := { || cs_gobott() }
*/
// Suppressed the above conditonal browsing, since the Comix and ClipMore libs
// would do an INTELLIGENT filter and seek out those records much faster
// while using simple FILTERS..

footline( 19, 2, 76 )
@ 20,  2 say "Op.Cash : " + rtrim( ltrim( str( opcash ) ) ) + '      '
@ 20, 24 say "Day's Cash : " + rtrim( ltrim( str( cashbal ) ) ) + '    '
@ 20, 51 say "Final Bal. :" + rtrim( ltrim( str( cashbal+opcash ) ) )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := boxcolor()
oColumn           := TBColumnNew( '   Account', { || c_acname() } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Income', { || c_income() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Expense', { || c_expense() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( '     Details', { || proper( subs( details, 1, 20 ) ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( '   Sub A/C  ', { || c_subac() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oBrowse:autoLite := .f.
dispend()
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
      *oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 2, 2 } )
      oBrowse:hilite()
      dispuser()
      nKey := inkey( 0 )
      *oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible, oBrowse:rowPos, oBrowse:rightVisible }, { 1, 2 } )
   endif
   do case
   case nKey == K_ALT_R
      plswait(.t.,'Generating HTML...')
      tb2Html(oBrowse,'EARep.HTM','Cash book as on '+dtoc(dDate))
      plswait(.f.)
      msg('EARep.HTM created!')
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
   case upper( chr( nKey ) ) == 'A' .and. ( !ac_closed() )
      nRec := addentry()
      if nRec != NIL
         go nRec
         recash()
      else         // No entry made. So go to the bottom entry to show ADD
         go top
         do while .not. eof()
            skip
         enddo
         skip - 1
         if ! date == entr_date()
           skip // Go EOF if no records for that date.
         endif
       endif

      oBrowse:refreshall()
      oBrowse:refreshcurrent()
   case upper( chr( nKey ) ) == 'D' .and. ( !ac_closed() )
      if !sameuser()
         jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                 'You are not authorized to alter it.' )
      else
         if confirm( "Delete Entry" )
            decash()
            jRLock()
            blankrec()
            RLOCK()
            delete
            jRUnLock()
            lDeleted := .t.
         endif
         oBrowse:refreshall()
      endif
      oBrowse:refreshcurrent()
   case nKey == K_ENTER .and. ( !ac_closed() )
      if !sameuser()
         jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                 'You are not authorized to alter it.' )
      else
         nRec := recno()
         decash()
         editentry()
         go nRec
         recash()
      endif
      oBrowse:refreshcurrent()
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      decash()
      go top
      seek dDate
      oBrowse:refreshall()
      oBrowse:refreshcurrent()
      setcolor( scrcolor() )
      @  2,  1 say padc( 'Cashbook as on ' + dtoc( dDate ), 78 )         
      setcolor( boxcolor() )
   endcase
enddo
unbox( bBox )
if lDeleted
   ontask( 'Closing books...' )
   close all
   eUse( "CASHBOOK" )
   set index to CSH_1, CSH_2, CSH_3, CSH_4, CSH_5
   pack
endif
close all
return nil

static function recount

local x := 0.00
local y, nAcRec
ontask( 'Counting cash....' )
sele accounts
nAcRec := recno()
set order to 1
seek 1      // Cash A/C
opcash := opbal
go nAcRec
sele cashbook
y      := recno()
set order to 2
go top
do while .not. eof()
   *if ( date < dDate .or. date = dDate ) .and. ( !deleted() )
   // By Jasim on 27-11-2002 (My Birthday)
   // 'Cauz now op.bal is calculated seperately in 'opcash'
   // and the total cash bal. is known by adding day's cash(x)+opcash
   if date = dDate .and. ! deleted()
      x += iif( action = 'D', amount * - 1, amount )
   elseif date > dDate
      exit
   endif
   if date < dDate
      opcash += iif( action = 'D', amount * - 1, amount )   // Needs to know op.bal also
   endif
   skip
enddo
ontask()
cashbal := x
setcolor( boxcolor() )
@ 20,  2 say "Op.Cash : " + rtrim( ltrim( str( opcash ) ) ) + '      '          
@ 20, 24 say "Day's Cash : " + rtrim( ltrim( str( cashbal ) ) ) + '      '         
@ 20, 51 say "Final Bal. : " + rtrim( ltrim( str( cashbal+opcash ) ) ) + '      '         
go top
seek dDate
return x

static function decash

sele cashbook
cashbal -= iif( action = 'D', amount * - 1, amount )
setcolor( boxcolor() )
@ 20,  2 say "Op.Cash : " + rtrim( ltrim( str( opcash ) ) ) + '      '          
@ 20, 24 say "Day's Cash : " + rtrim( ltrim( str( cashbal ) ) ) + '      '         
@ 20, 51 say "Final Bal. : " + rtrim( ltrim( str( cashbal+opcash ) ) ) + '      '         
return .t.

static function recash

sele cashbook
cashbal += iif( action = 'D', amount * - 1, amount )
setcolor( boxcolor() )
@ 20,  2 say "Op.Cash : " + rtrim( ltrim( str( opcash ) ) ) + '      '          
@ 20, 24 say "Day's Cash : " + rtrim( ltrim( str( cashbal ) ) ) + '      '         
@ 20, 51 say "Final Bal. : " + rtrim( ltrim( str( cashbal+opcash ) ) ) + '      '         
return .t.

function c_acname(xDoSubs)   // public fun. requires in daysheet
select cashbook
if !eof()
   sele accounts
   set order to 1
   seek cashbook->account
   sele cashbook
   if xDoSubs=NIL
      return subs( accounts->account, 1, 25 )
   endif
   return accounts->account
endif
return space( 25 )

function c_subac
sele cashbook
if ! eof()
 sele accounts
 set order to 1
 seek cashbook->account
 if accounts->group
     sele subheads
     set order to 1
     seek cashbook->acc_sub
     set order to 2
     sele cashbook
     return subs(subheads->subhead,1,25)
endif
endif
sele cashbook
return space(25)

function c_income   // public fun. requires in daysheet

local x
if action = 'C'     // Sometimes they may change
   x := str( amount, 09, 2 )
else
   x := space( 09 )
endif
return x

function c_expense  // public fun. requires in daysheet

local x
if action = 'D'
   x := str( amount, 09, 2 )
else
   x := space( 09 )
endif
return x
//-------------------
static function editentry

local _xx      := savescreen( 0, 0, 24, 79 )
local bBox
local cACName  := space( 40 )
local nAmount  := amount
local nChoice  := 0
local cType    := type
local nId
local cAType   := action
local cXX
local cDetails := details, nSubAcc := acc_sub
dispscrn()
sele accounts

go top
set order to 1
seek cashbook->account
set order to 2
bBox := makebox( 7, 13, 19, 69, boxcolor() )
setcolor( scrcolor() )
@ 06, 13 say padc( 'Edit Cashbook Entry', 57 )         
@ 06, 56 say dDate                                     
setcolor( boxcolor() )
do while .t.
   footline( 09, 14, 69 - 14 )
   setcolor( linecolor() )
   @ 08, 14 + ( ( 69 - 14 ) - len( ltrim( padc( cType, 69 - 14 ) ) ) ) ;
                say rtrim( ltrim( padc( rtrim( ltrim( cType ) ), 69 - 14 ) ) )
   setcolor( boxcolor() )
   sele accounts
   accview( .t., .f., , , , .f. )   // Do not go into the Sub Account browse.
   cACName := accounts->account
   sele cashbook
   footline( 09, 14, 69 - 14 )
   @ 10, 14 say "Account : " + rtrim( ltrim( cACName ) )         
   footline( 11, 14, 69 - 14 )

   if accounts->group
    if cashbook->account == accounts->id
       // ie, The Account now selected is the same as was in the database.
       // Then, the SubGroup too should be the same for Browse.
       sele subheads
       set order to 1
       seek nSubAcc
       set order to 2
    else
       sele subheads
       set order to 2
       go top
    endif
    SubView()
   endif

   sele cashbook   
   @ 12, 14 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")
   footline( 13, 14, 69 - 14 )
   @ 14, 14 say "Amount  : " get nAmount pict '9999999.99'
   @ 14, 39 say cAType         
   footline( 15, 14, 69 - 14 )
   @ 16, 14 say "Details : " get cDetails pict '@!S40'       
   footline( 17, 14, 69 - 14 )
   read
   if nAmount = 0
      sele accounts
      set filter to
      go top
      sele cashbook
      restscreen( 0, 0, 24, 79, _xx )
      return .f.
   endif
   @ 18, 24 say "<Save>"
   @ 18, 48 say "<Abort>"         
   read
   if empty( cACName )
      nChoice := 2
      exit
   endif
   @ 18, 24 prompt "<Save>"
   @ 18, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo
if nChoice = 1
   //if (cType='Expense' .or. cType='Income') .and. (accounts->type == 'Bank')
   sele cashbook
   jRLock()
   field->date    := dDate
   field->account := accounts->id
   if accounts->group
      field->acc_sub := subheads->id
   else
      field->acc_sub := 0
   endif
   field->amount  := nAmount
   field->action  := cAType
   field->details := cDetails
   field->type    := cType
   set order to 3
   jRUnLock()
   //else
   // jAlert('Bank transactions are to be operated either through Deposit or Withdrawal')
   //endif
endif
sele accounts
set filter to
go top
sele cashbook
restscreen( 0, 0, 24, 79, _xx )
return nil
//-------------------------------
static function addentry

local _xx      := savescreen( 0, 0, 24, 79 )
local _yy
local bBox
local cACName
local nAmount  := 0.00
local nChoice  := 1
local cType
local nId
local cAType   := ' '
local cDetails := space( 79 )
local aTypes   := { 'Expense', 'Income', 'Deposit', 'Withdrawal' }

dispscrn()
cType := jPick( aTypes, 'Entry Type' )

if cType = 0
   nChoice := 2
   sele accounts
   set filter to
   go top
   sele cashbook
   restscreen( 0, 0, 24, 79, _xx )
   return nil
else
   sele accounts
   if cType = 1
      set filter to ( type = 'Expense' .or. type = 'Creditor' .or. type = 'Purchase' )
   elseif cType = 2
      set filter to ( type = 'Income' .or. type = 'Debtor' .or. type = 'Capital' .or. type = 'Sales' )
   elseif cType = 3 .or. cType = 4
      set filter to ( type = 'Bank' )
   endif
   go top
   if cType = 1
      cAType := 'D'
   elseif cType = 2
      cAType := 'C'
   elseif cType = 3
      cAType := 'D'
   elseif cType = 4
      cAType := 'C'
   endif
   cType := aTypes[ cType ]
endif

bBox := makebox( 7, 13, 19, 69, boxcolor() )
setcolor( scrcolor() )
@ 06, 13 say padc( 'Add Cashbook Entry', 57 )         
@ 06, 56 say dDate                                    
setcolor( boxcolor() )

do while .t.

   footline( 09, 14, 69 - 14 )
   setcolor( boxcolor() )
   setcolor( linecolor() )
   @ 08, 14 + ( ( 69 - 14 ) - len( ltrim( padc( cType, 69 - 14 ) ) ) ) say rtrim( ltrim( padc( rtrim( ltrim( cType ) ), 69 - 14 ) ) )         

   setcolor( boxcolor() )
   sele accounts
   go top
   accview( .t., .f., , , , .t. )
   cACName := accounts->account
   sele cashbook
   footline( 09, 14, 69 - 14 )
   @ 10, 14 say "Account : " + rtrim( ltrim( cACName ) )         
   footline( 11, 14, 69 - 14 )

   if empty( cACName )
      nChoice := 2
      exit
   endif
   footline( 11, 14, 69 - 14 )
   @ 12, 14 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")
   footline( 13, 14, 69 - 14 )
   @ 14, 14 say "Amount  : " get nAmount pict '9999999.99'       
   @ 14, 39 say cAType         
   footline( 15, 14, 69 - 14 )
   @ 16, 14 say "Details : " get cDetails pict '@!S40'       
   read

   if nAmount = 0.00
      nChoice := 2
      exit
   endif

   @ 18, 24 say "<Save>"          
   @ 18, 48 say "<Abort>"         
   read
   @ 18, 24 prompt "<Save>"
   @ 18, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo

if nChoice = 1
   //if (cType='Expense' .or. cType='Income') .and. (accounts->type == 'Bank')
   sele cashbook
   set order to 1
   go bott
   nId := id + 1
   append blank
   field->date    := dDate
   field->Id      := nId
   field->account := accounts->id
   if accounts->group
      field->acc_sub := subheads->id
   else
      field->acc_sub := 0
   endif
   field->amount  := nAmount
   field->action  := cAType
   field->details := cDetails
   field->type    := cType
   field->user    := user()
   jRUnLock()
   _yy := recno()
   set order to 2
   //else
   // jAlert('Bank transactions are to be operated either through Deposit or Withdrawal')
   //endif
endif

sele accounts
set filter to
go top
sele cashbook
go top
seek dDate
restscreen( 0, 0, 24, 79, _xx )
return _yy
//-----------------------------------------
function viewCBook

local oBrowse
local oColumn
local nKey
local lDeleted := .f.
local bBox, cSearch := space(65)
local nRec, lByDate := .t., dFindDate := date()
setcolor( boxcolor() )
dispscrn()
dispbegin()
bBox := makebox( 3, 1, 21, 78, boxcolor(), 0 )
setcolor( scrcolor() )
@  2,  1 say padc( 'View Cashbook by Date', 78 )         
@ 22,  1 say padc( 'þG-Go Date       þO-Order         þS-Search A/C         þF-Filter', 78 )
setcolor( boxcolor() )
use accounts new index ACC_1,ACC_2
use cashbook new shared index CSH_2, CSH_5   // Date,Account orders.
set order to 1
go bottom

keyboard repli( CHR(K_UP), 14 )        // When it GO BOTTOM, only 1 record
                               // will be displayed. So when we skip back, there
                               // will be a comfortable number of records displayed.
dispend()     
oBrowse := TBrowseDB( 4, 2, 20, 77 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := boxcolor()
oColumn           := TBColumnNew( 'Date', { || date } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn           := TBColumnNew( 'Account', { || c_acname() } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Amount', { || str(amount,9,2) +' '+action } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Details', { || proper( subs( details, 1, 20 ) ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oBrowse:autoLite := .f.
do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      If oBrowse:hitBottom
         tone( 300, 2 )
      endif
      //ÄÄÄÄ highlight current row
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible + 15, oBrowse:rowPos, oBrowse:rightVisible }, { 2, 2 } )
      oBrowse:hilite()
      dispuser()
      nKey := inkey( 0 )
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible + 15, oBrowse:rowPos, oBrowse:rightVisible }, { 1, 2 } )
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
   case upper( chr( nKey ) ) == 'F'     // Filter
      oFilter := { || c_acName() + ', ' + details }
      jsfilt( oBrowse, 0, { || .t. } )
   case upper( chr( nKey ) ) == 'S'     // Search
      popread(.t.,'Search for A/C : ',@cSearch,'@S45')
      set exact off
      set softseek on
      plswait(.t.,'Searching...')
      sele accounts
      set order to 2
      seek proper(alltrim(cSearch))
      if eof()
        msg('No Match Found!')
        go bott
      endif
      set order to 1
      sele cashbook
      set order to 2
      seek accounts->id
      if ! found()
         go bott
      endif
      plswait(.f.)
      
      // In the old method, we were searching for the A/C from the Daybook
      // (using c_acName which again searches in the Account file which is
      // very slow.)

      // Now it directly searches in the accounts file and is more fast and
      // places the record pointer in the daybook accordingly.

      lByDate := .f.
      setcolor( scrcolor() )
      @  2,  1 say padc( 'View Cashbook by Account', 78 )         
      setcolor( boxcolor() )
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'G'     // Go Date
      popread(.f.,'Go to Date : ',@dFindDate,'@D')
      set order to 1
      lByDate := .t.
      setcolor( scrcolor() )
      @  2,  1 say padc( 'View Cashbook by Date', 78 )         
      setcolor( boxcolor() )
      set softseek on
      seek dFindDate
      if eof()
        msg('No Match Found!')
        go bott
      elseif date != dFindDate
        msg('No Exact Match Found. Record positioned to the nearest matching one.')
      endif
      oBrowse:refreshall()
   case upper(chr(nKey)) == 'O'
     if lByDate
        lByDate := .f.
        set order to 2
        setcolor( scrcolor() )
        @  2,  1 say padc( 'View Cashbook by Account', 78 )         
        setcolor( boxcolor() )
        oBrowse:refreshall()
     else
        lByDate := .t.
        set order to 1
        setcolor( scrcolor() )
        @  2,  1 say padc( 'View Cashbook by Date', 78 )         
        setcolor( boxcolor() )
        oBrowse:refreshall()
     endif
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
   endcase
enddo
unbox( bBox )
close all
return nil
//================================
/*
// The Following are disabled, beacause, with the new Fast Index-intelligent
// Comix+ClipMore SET FILTER, the entries can be located fast and Furious!
static func cs_skip( n )
local nSkipped := 0
if n > 0
  do while (date == dDate) .and. (nSkipped <> n) .and. (! eof() )
     skip
     nSkipped++
  enddo
elseif n < 0
  do while (date == dDate) .and. (nSkipped <> n) .and. (! bof() )
     skip -1
     nSkipped--
  enddo
endif
if (date != dDate)      // Skipped past the date.
 if n > 0
   skip -1
   nSkipped --
 elseif n < 0
   skip
   nSkipped++
 endif
endif
if date != dDate
  go top
  seek dDate
endif
if bof()
  nSkipped++
elseif bof()
  nSkipped--
endif
return nSkipped
//---------------------
static func cs_gotop
do while (date == dDate) .and. (!bof())
 skip -1
enddo
skip
return .t.
//-----------------
static func cs_gobott
do while (date == dDate) .and. (!eof())
 skip
enddo
skip -1
return .t.
//-------------------
*/

*+ EOF: CASHBOOK.PRG
