/**************************************************************
NOTE -
"Type" in BANKBOOK denotes the effect of the transaction on
the A/C (or party) mentioned. Not on the Bank.
(Think replacing the Bankbook with the Cashbook. Same thing,
Same Way, Same EFFECT!)
**************************************************************/

#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

static bankbal

function bankentry(nId)

local oBrowse
local oColumn
local nKey
local lDeleted := .f.
local bBox
local nRec
if dDate = NIL
   dDate := date()
endif
setcolor( boxcolor() )
dispscrn()
dispbegin()
bBox := makebox( 3, 1, 21, 78, boxcolor(), 0 )
setcolor( scrcolor() )
@  2,  1 say padc( 'Bankbook as on ' + dtoc( dDate ), 78 )         
if !ac_closed()
   @ 22,  1 say padc( 'þ A - Add Entry   þ D - Delete Entry   þ ENTER - Edit  þ ESC - Exit', 78 )         
else
   @ 22,  1 say padc( 'þ ESC - Exit', 78 )         
endif
setcolor( boxcolor() )
use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use bankbook new index BNK_1,BNK_2,BNK_3
set order to 3
set filter to ( date == dDate .and. !deleted() )
go top
if nId <> NIL
 jDbPosition(nId)
endif
dispend()
oBrowse           := TBrowseDB( 4, 2, 20, 77 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := boxcolor()
oColumn           := TBColumnNew( 'Bank A/C', { || subs( findid( b_id ), 1, 20 ) } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Affected A/C', { || subs( b_acname(), 1, 20 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Income', { || c_income() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Expense', { || c_expense() } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oBrowse:autoLite := .f.
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
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible + 15, oBrowse:rowPos, oBrowse:rightVisible }, { 2, 2 } )
      oBrowse:hilite()
      dispuser()
      nKey := inkey( 0 )
      oBrowse:colorRect( { oBrowse:rowPos, oBrowse:leftVisible + 15, oBrowse:rowPos, oBrowse:rightVisible }, { 1, 2 } )
   endif
   do case
   case nKey == K_ALT_R
      plswait(.t.,'Generating HTML...')
      tb2Html(oBrowse,'EARep.HTM','Bank Transactions as on'+dtoc(dDate))
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
      if nRec = NIL
         go top
         do while .not. eof()
            skip
         enddo
         skip - 1
      else
         go nRec
      endif
      oBrowse:refreshall()
      oBrowse:refreshcurrent()
   case upper( chr( nKey ) ) == 'D' .and. ( !ac_closed() )
      if sameuser()
         if confirm( "Delete Entry" )
            jRLock()
            delete
            jRUnLock()
            lDeleted := .t.
         endif
      else
         jAlert( 'Entry User Varies. Cannot alter' )
      endif
      oBrowse:refreshall()
      oBrowse:refreshcurrent()
   case nKey == K_ENTER .and. ( !ac_closed() )
      if sameuser()
         nRec := recno()
         editentry()
         go nRec
         oBrowse:refreshcurrent()
      else
         jAlert( 'Entry User Varies. Cannot alter' )
      endif
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      go top
      oBrowse:refreshall()
      oBrowse:refreshcurrent()
      setcolor( scrcolor() )
      @  2,  1 say padc( 'Bankbook as on ' + dtoc( dDate ), 78 )         
      setcolor( boxcolor() )
   endcase
enddo
unbox( bBox )
if lDeleted
   ontask( 'Closing books...' )
   close all
   eUse( "BANKBOOK" )
   set index to BNK_1, BNK_2, BNK_3, BNK_5, BNK_6
   pack
endif
close all
return nil

function findid     // public func. requires in daysheet

sele accounts
set order to 1
seek bankbook->b_id
sele bankbook
return subs( accounts->account, 1, 25 )

function b_acname   // public func. requires in daysheet

sele accounts
set order to 1
seek bankbook->account
sele bankbook
return subs( accounts->account, 1, 45 )

static function c_income

local x
if action = 'C'     // Sometimes they may change
   x := str( amount, 10, 2 )
else
   x := space( 10 )
endif
return x

static function c_expense

local x
if action = 'D'
   x := str( amount, 10, 2 )
else
   x := space( 10 )
endif
return x
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
local nBId
local cBName
local cAType   := ' '
local cDetails := space( 79 )
local aTypes   := { 'Deposit', 'Withdrawal' }
dispscrn()
cType := jPick( aTypes, 'Bank Entry Type' )
if cType = 0
   nChoice := 2
   return nil
else
   sele accounts
   if cType = 1
      set filter to ( type = 'Deposit' )
      cAType := 'C'
   elseif cType = 2
      set filter to ( type = 'Withdrawal' )
      cAType := 'D'
   endif
   go top
   cType := aTypes[ cType ]
endif
bBox := makebox( 6, 13, 20, 69, boxcolor() )
setcolor( scrcolor() )
@ 05, 13 say padc( 'Add Bank Entry', 57 )         
@ 05, 56 say dDate                                
setcolor( boxcolor() )
do while .t.
   setcolor( boxcolor() )
   setcolor( linecolor() )
   @ 07, 14 + ( ( 69 - 14 ) - len( ltrim( padc( cType, 69 - 14 ) ) ) ) ;
                say rtrim( ltrim( padc( rtrim( ltrim( cType ) ), 69 - 14 ) ) )
   setcolor( boxcolor() )
   footline( 08, 14, 69 - 14 )
   footline( 10, 14, 69 - 14 )
   footline( 12, 14, 69 - 14 )
   footline( 14, 14, 69 - 14 )
   footline( 16, 14, 69 - 14 )
   footline( 18, 14, 69 - 14 )
   sele accounts
   set filter to type = 'Bank'
   go top
   accview( .t., .f. )
   nBId   := accounts->id
   cBName := accounts->account
   if alltrim(upper(accounts->type )) != 'BANK'
      jAlert( "Cannot accept A/Cs other than banks.." )
      loop
   endif

   @ 09, 14 say "Bank    : " + rtrim( ltrim( cBName ) )         

   sele accounts
   set filter to

   //if cAType='C'
   //   set filter to type='Debtor'
   //else
   //   set filter to type='Sundry Creditor'
   //endif

   go top
   accview( .t., .f., , , , .t. )
   cACName := accounts->account
   if empty( rtrim( ltrim( cACName ) ) )
      jAlert( "CANNOT ACCEPT BLANK A/Cs.." )
      loop
   endif
   if alltrim(upper(accounts->type)) == 'BANK'
     jAlert("Cannot accept BANK A/Cs as the affected account...")
     loop
   endif

   sele bankbook
   @ 11, 14 say "Account : " + rtrim( ltrim( cACName ) )         
   @ 13, 14 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")
   @ 15, 14 say "Amount  :" get nAmount  pict '9999999.99'       
   @ 15, 39 say cAType                                            
   @ 17, 14 say "Details :" get cDetails pict '@!S40'            
   footline( 18, 14, 69 - 14 )
   read
   if nAmount = 0.00
      nChoice := 2
      exit
   endif
   @ 19, 24 say "<Save>"          
   @ 19, 48 say "<Abort>"         
   read
   @ 19, 24 prompt "<Save>"
   @ 19, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo
if nChoice = 1
   sele bankbook
   set order to 1
   go bott
   nId := id + 1
   append blank
   field->date    := dDate
   field->Id      := nId
   field->b_id    := nBId
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
   set order to 3
endif
sele accounts
set filter to
go top
sele bankbook
go bott
restscreen( 0, 0, 24, 79, _xx )
return _yy
//------------------------------------------------------------
static function editentry

local _xx      := savescreen( 0, 0, 24, 79 )
local _yy
local bBox
local cACName
local nAmount  := 0.00
local nChoice  := 1
local cType
local nId, nSubAcc := bankbook->acc_sub
local nBId
local cBName
local cAType   := ' '
local cDetails := space( 79 )
local aTypes   := { 'Deposit', 'Withdrawal' }
dispscrn()
cType := type
sele accounts
set order to 1
cType := rtrim( ltrim( cType ) )
if cType = aTypes[ 1 ]
   set filter to ( type = 'Deposit' )
   cAType := 'C'
elseif cType = aTypes[ 2 ]
   set filter to ( type = 'Withdraw' )
   cAType := 'D'
endif
go top
bBox := makebox( 6, 13, 20, 69, boxcolor() )
setcolor( scrcolor() )
@ 05, 13 say padc( 'Edit Bank Entry', 57 )         
@ 05, 56 say dDate                                 
setcolor( boxcolor() )
do while .t.
   setcolor( boxcolor() )
   setcolor( linecolor() )
   @ 07, 14 + ( ( 69 - 14 ) - len( ltrim( padc( cType, 69 - 14 ) ) ) ) ;
                say rtrim( ltrim( padc( rtrim( ltrim( cType ) ), 69 - 14 ) ) )
   setcolor( boxcolor() )
   footline( 08, 14, 69 - 14 )
   footline( 10, 14, 69 - 14 )
   footline( 12, 14, 69 - 14 )
   footline( 14, 14, 69 - 14 )
   footline( 16, 14, 69 - 14 )
   footline( 18, 14, 69 - 14 )

   sele accounts
   set filter to type = 'Bank'
   go top
   seek bankbook->b_id
   accview( .t., .f., , , , .f. )   // Do not go into the Sub Account browse.

   nBId   := accounts->id
   cBName := accounts->account
   if empty( rtrim( ltrim( cBName ) ) )
      jAlert( "CANNOT ACCEPT BLANK A/Cs.." )
      loop
   endif
   @ 09, 14 say "Bank    : " + rtrim( ltrim( cBName ) )         
   if alltrim(upper(accounts->type )) != 'BANK'
      jAlert( "Cannot accept A/Cs other than banks.." )
      loop
   endif

   sele accounts
   set filter to
   go top

   seek bankbook->account
   accview( .t., .f. )
   cACName := accounts->account
   if empty( rtrim( ltrim( cACName ) ) )
      jAlert( "CANNOT ACCEPT BLANK A/Cs.." )
      loop
   endif

   sele bankbook
   @ 11, 14 say "Account : " + rtrim( ltrim( cACName ) )         
   cACName := accounts->account
   if empty( rtrim( ltrim( cACName ) ) )
      jAlert( "CANNOT ACCEPT BLANK A/Cs.." )
      loop
   endif

   if alltrim(upper(accounts->type)) == 'BANK'
     jAlert("Cannot accept BANK A/Cs as the affected account...")
     loop
   endif

   if accounts->group
    if bankbook->account == bankbook->id
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

   sele bankbook
   @ 13, 14 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")

   nAmount  := amount
   cDetails := details

   @ 15, 14 say "Amount  :" get nAmount  pict '9999999.99'       
   @ 15, 39 say cAType                                            
   @ 17, 14 say "Details :" get cDetails pict '@!S40'            
   read
   if nAmount = 0.00
      nChoice := 2
      exit
   endif
   @ 19, 24 say "<Save>"          
   @ 19, 48 say "<Abort>"         
   read
   @ 19, 24 prompt "<Save>"
   @ 19, 48 prompt "<Abort>"
   menu to nChoice
   exit
enddo
if nChoice = 1
   sele bankbook
   jRLock()
   field->b_id    := nBId
   field->account := accounts->id
   if accounts->group
      field->acc_sub := subheads->id
   else
      field->acc_sub := 0
   endif
   field->amount  := nAmount
   field->action  := cAType
   field->details := cDetails
   jRUnLock()
   _yy := recno()
   set order to 3
endif
sele accounts
set filter to
go top
sele bankbook
go bott
restscreen( 0, 0, 24, 79, _xx )
return _yy

*+ EOF: BANKBOOK.PRG
