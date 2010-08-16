#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

function Dbkview(nId)

local oBrowse
local oColumn
local nKey
local lDeleted := .f.
local bBox
local nRec
setcolor( boxcolor() )
dispscrn()
dispbegin()
bBox := makebox( 3, 1, 21, 78, boxcolor(), 0 )
setcolor( scrcolor() )
@  2,  1 say padc( 'Daybook as on ' + dtoc( dDate ), 78 )         
if !ac_closed()
   @ 22,  1 say padc( 'þ A - Simple Entry    þ V - View Voucher    þ ESC - Exit    þ D - Delete', 78 )         
else
   @ 22,  1 say padc( 'þ V - View Voucher        þ ESC - Exit', 78 )         
endif

setcolor( boxcolor() )
use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
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
oColumn           := TBColumnNew( 'Type', { || type } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( '   Account', { || subs( d_acname(), 1, 15 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Debit', { || iif( action = 'D', str( amount, 9, 2 ), space( 9 ) ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Credit', { || iif( action = 'C', str( amount, 9, 2 ), space( 9 ) ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Details', { || subs( details, 1, 15 ) } )
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
      tb2Html(oBrowse,'EARep.HTM','Daybook as on '+dtoc(dDate))
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
   case upper( chr( nKey ) ) == 'V'
      d_viewvoucher()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'A' .and. ( !ac_closed() )
      d_addvoucher()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'D' .and. ( !ac_closed() )
      if sameuser()
         d_delvoucher()
         lDeleted := .t.
      else
         jAlert( 'This entry was created by ' + uName( user ) + ' ;' + ;
                 'You are not authorized to alter it.' )
      endif
      oBrowse:refreshall()
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
      @  2,  1 say padc( 'Daybook as on ' + dtoc( dDate ), 78 )         
      setcolor( boxcolor() )
   endcase
   select DayBook
enddo
unbox( bBox )
close all

if lDeleted
   ontask( 'Closing books...' )
   close all
   eUse( "DAYBOOK" )
   set index to DBK_1, DBK_2, DBK_3, DBK_4, DBK_5, DBK_6
   pack
endif

return nil

function d_acname   // public fun. requires in daysheet

sele accounts
set order to 1
seek daybook->account
sele daybook
return subs( accounts->account, 1, 25 )

static function d_addvoucher

local cOldScrn := savescreen()
local nId
local cDr
local nDr, nDrSub
local ccDr     := space( 50 )
local cCr
local nCr, nCrSub
local ccCr     := space( 50 )
local nAmount  := 0.00
local ccAction := ' '
dispscrn()
@ 07,  8 clear to 19, 70
@ 07,  8 to 19, 70
setcolor( scrcolor() )
@ 06,  8 say padc( 'Add Voucher', 70 - 7 )         
setcolor( boxcolor() )
@ 08,  9 say "Date    : " + dtoc( entr_date() )         
@ 10,  9 say "Dr.     : "                               
@ 11,  9 say "Sub A/C : "                               
@ 12,  9 say "Details : "                               
@ 14,  9 say "Cr.     : "                               
@ 15,  9 say "Sub A/C : "                               
@ 16,  9 say "Details : "                               
@ 18,  9 say "Amount  : "                               
select accounts
set order to 2
set filter to
go top
accview( .t., .f., .t.,,, .t. )
setcursor( 1 )
cDr := account
nDr := id
@ 10,  9 say "Dr.     : " + subs( cDr, 1, 58 )
@ 11,  9 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")
if accounts->group
  nDrSub := subheads->id
else
  nDrSub := 0
endif
@ 12,  9 say "Details :" get ccDr picture '@!'       
read
@ 12,  9 say "Details : " + ccDr         

ccCr := ccDr
select accounts
set filter to
go top
*accview( .t., .f., ,.t.,nil,.f., .t. )
accview( .t., .f., .t.,,, .t. )
setcursor( 1 )
cCr := account
nCr := id
@ 14,  9 say "Cr.     : " + subs( cCr, 1, 58 )
if accounts->group
  nCrSub := subheads->id
else
  nCrSub := 0
endif
@ 15,  9 say "Sub A/C : "+iif(accounts->group,subheads->subhead,"")
@ 16,  9 say "Details :"                       get ccCr picture '@!'       
read
@ 16,  9 say "Details : " + ccCr         

@ 18,  9 say "Amount  :" get nAmount pict '999999.99'       
read
if nAmount = 0.00
   restscreen( 0, 0, 24, 79, cOldScrn )
   return .f.
endif
@ 18,  9 say "Amount  : " + str( nAmount, 9, 2 )         
setcolor( msgcolor() )
setcursor( 1 )
if jPick( { "Save", "Abort" }, "Select:", 2, 4 ) == 1
   setcolor( boxcolor() )
   select daybook
   set order to 1
   set filter to
   go bott
   nId := id + 1

   append blank
   field->id      := nId
   field->date    := entr_date()
   field->type    := 'Daybook'
   field->action  := 'D'
   field->amount  := nAmount
   field->account := nDr
   field->acc_sub := nDrSub
   field->details := ccDr
   field->user    := user()
   jRUnLock()

   append blank
   field->id      := nId + 1
   field->date    := entr_date()
   field->type    := 'Daybook'
   field->action  := 'C'
   field->amount  := nAmount
   field->account := nCr
   field->acc_sub := nCrSub
   field->details := ccCr
   field->user    := user()
   jRUnLock()

   setcolor( boxcolor() )

endif

setcolor( boxcolor() )
restscreen( 0, 0, 24, 79, cOldScrn )
sele accounts
set filter to
select daybook
set order to 3
set filter to ( date == dDate .and. !deleted() )
go top
return .t.

static function d_delvoucher

local nIID
local nAmount
sele daybook
set order to 1
if confirm( 'Delete Voucher ?' )
   if action = 'D'
      nIID    := id
      nAmount := amount
      blankrec()
      jRLock()
      delete
      jRUnLock()
      go top
      seek nIID + 1
      if nAmount != amount
         jAlert( "Daybook integrity failure!;; Deletion partial!" )
      else
         blankrec()
         jRLock()
         delete
         jRUnLock()
         go top
      endif
   else
      nIID    := id
      nAmount := amount
      blankrec()
      jRLock()
      delete
      jRUnLock()
      go top
      seek nIID - 1
      if nAmount != amount
         jAlert( "Daybook integrity failure!;; Deletion partial!" )
      else
         blankrec()
         jRLock()
         delete
         jRUnLock()
         go top
      endif
   endif
endif
return .t.
//====================================================
static function d_viewvoucher
local nRec := daybook->(recno())
local aVouchs := {}

if alltrim(upper(type)) == 'DAYBOOK'
if action != 'D'
  skip -1
endif

aadd( aVouchs, padc(alltrim(type)+' Entry',70))
aadd( aVouchs, repli('Í',70) )
aadd( aVouchs, " ")

sele accounts
set order to 1
seek daybook->account
sele daybook

aadd( aVouchs, "Dr. : "+accounts->account )
if daybook->acc_sub != 0
  sele subheads
  set order to 1
  seek daybook->acc_sub
  aadd( aVouchs, "Sub : "+alltrim(subheads->subhead)+"]")
endif

if ! empty(alltrim(daybook->details))
  aadd( aVouchs, alltrim(daybook->details) )
endif

aadd( aVouchs, " " )
skip

sele accounts
set order to 1
seek daybook->account
sele daybook

aadd( aVouchs, "Cr. : "+accounts->account )
if daybook->acc_sub != 0
  sele subheads
  set order to 1
  seek daybook->acc_sub
  aadd( aVouchs, "Sub : "+alltrim(subheads->subhead)+"]")
endif

if ! empty(alltrim(daybook->details))
  aadd( aVouchs, alltrim(daybook->details) )
endif


aadd( aVouchs, " " )
                       
aadd( aVouchs, padc("Amount : "+alltrim(str(daybook->amount)),70) )

aadd( aVouchs, " ")

sele daybook
go (nRec)

else

aadd( aVouchs, padc(alltrim(type)+' Entry',70))
aadd( aVouchs, repli('Í',70) )
aadd( aVouchs, " ")

sele accounts
set order to 1
seek daybook->account
sele daybook

if action == 'D'
   aadd( aVouchs, "Dr. : "+accounts->account )
else
   aadd( aVouchs, "Cr. : "+accounts->account )
endif

if daybook->acc_sub != 0
  sele subheads
  set order to 1
  seek daybook->acc_sub
  aadd( aVouchs, "Sub : "+alltrim(subheads->subhead)+"]")
endif

if ! empty(alltrim(daybook->details))
  aadd( aVouchs, alltrim(daybook->details) )
endif

aadd( aVouchs, " " )
                       
aadd( aVouchs, padc("Amount : "+alltrim(str(daybook->amount)),70) )

aadd( aVouchs, " ")

sele daybook

endif

jPick( aVouchs, "þ View Voucher þ",2,-4,.F.,msgcolor() )

return .t.
