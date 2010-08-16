#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "grump.ch"
#include "grumpr.ch"

#xtranslate JROW <nSayRow> => <nSayRow>+nRow

#define WARRANTY_AC 3
#define AMC_AC 4
#define ASC_AC 5

//-------------------------------------------------------------
function service( nId )

local oBrowse
local oColumn
local nKey
local lDeleted := .f.
local nRec
local cScreen  := savescreen()
local cMode    := 'P'
local dSDate
local nX

setcolor( boxcolor() )
dispscrn()
makebox( 1, 0, 23, 79, boxcolor(), 0 )
setcolor( scrcolor() )
@  2,  1 say padc( 'ALL Services', 78 )                                                                         
@ 20,  1 say padc( ' þA-Add Entry³þG-Goto Service³þF5-Change Filter³þENTER-Edit³þESC-Exit ', 78 )         
setcolor( boxcolor() )
footline( 21, 01, 78 )
footline( 03, 01, 78 )

use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use service new index SRV_1,SRV_2,SRV_3,SRV_4,SRV_5
set filter to ( empty( A_DATE ) )       // Pending Services
go top

if nId <> NIL
   cMode := 'A'
   set filter to
   seek nId
   if bof() .or. eof()
      go bott
   endif
   _SayStat( cMode, ac_closed( A_DATE ) )
else
   keyboard chr(K_CTRL_PGDN)
endif

oBrowse := srvPendingB()

oBrowse:autoLite := .f.
dispend()
do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   if ac_closed( A_DATE )
      _SayStat( cMode, .t. )
   else
      _SayStat( cMode, .f. )
   endif
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
   case upper( chr( nKey ) ) == 'A' .and. ( !ac_closed( A_DATE ) )

      nRec := addentry()

      sele service

      if cMode == 'P'
         set filter to empty( A_DATE )
      elseif cMode == 'C'
         set filter to ( !Closed )
      elseif cMode == 'A'
         set filter to
      else
         cMode := 'A'
         set filter to
      endif

      _SayStat( cMode, .f. )

      if cMode == 'P' .and. ( !empty( A_DATE ) )            // this service has been attended.
         go bott
         oBrowse:gobottom()
      endif
      oBrowse:refreshall()
      oBrowse:refreshcurrent()
      oBrowse:forcestable()

   case nKey == K_ENTER 
      if eof()
         jAlert( 'No active entry to edit.; Press A to add' )
      else
         AddEntry( id, .t. )
         sele service
         if cMode == 'P'
            set filter to empty( A_DATE )
         elseif cMode == 'C'
            set filter to ( !Closed )
         elseif cMode == 'A'
            set filter to
         endif

         _SayStat( cMode, .f. )

         oBrowse:down()
         oBrowse:up()
         // In order to refresh the FILTER and reshow records.. if any
         // change in the filter key.

         oBrowse:refreshall()
         oBrowse:refreshcurrent()
      endif

   case nKey == K_F5
      if cMode == 'P'
         cMode := 'A'
      elseif cMode == 'A'
         cMode := 'C'
      else 
         cMode := 'P'
      endif
      if cMode == 'P'
         set filter to empty( A_DATE )
      elseif cMode == 'C'
         set filter to ( !Closed )
      elseif cMode == 'A'
         set filter to
      endif

      skip - 1
      skip
      if bof() .or. eof()
         go top
      endif

      _SayStat( cMode, ac_closed( A_DATE ) )

      oBrowse:refreshall()
      oBrowse:forcestable()

   case upper( chr( nKey ) ) == 'G'
      nX := jPick( {'Call Date', 'Attended Date', 'Call No.', 'Customer'} ,;
                    "GOTO : ", , , .f., msgcolor() )
      if nX == 1
         dSDate := date()
         popread( .f., 'Goto Call Date : ', @dSDate, '@D' )
         sele service
         if !empty( dSDate )
            set order to 2 // R_DATE
            set softseek OFF
            go top
            seek dSDate
            if eof()
               msg( 'No service entries on ' + dtoc( dSDate ) + '...' )
               go top
            endif
         endif
      elseif nX == 2
         dSDate := date()
         popread( .f., 'Goto Attended Date : ', @dSDate, '@D' )
         sele service
         if !empty( dSDate )
            set order to 3 // A_DATE
            set softseek OFF
            go top
            seek dSDate
            if eof()
               msg( 'No service entries on ' + dtoc( dSDate ) + '...' )
               go top
            endif
         endif
      elseif nX == 3
         nX := 0
         popread( .f., 'Service No.:', @nX, '99999' )
         if nX > 0
            set order to 1
            set filter to
            cMode := 'A'
            set softseek off
            seek nX
            if !found()
               msg( 'Service call no.' + alltrim( str( nX, 5, 0 ) ) + ' not yet opened!' )
            endif
         endif
      elseif nX == 4
         nX := jAlert('Service Call Type:', {'Paid','Warranty','AMC','ASC'})
         if nX == 1

           cMode := '_'

           sele accounts
           set order to 2
           accview( .t., .f., nil, nil, nil, .f., { || alltrim( upper( accounts->type ) ) == 'DEBTOR' } )
           sele service
           cmFilter("customer=="+cm2Str(accounts->id))
           go top
           if eof()
             msg('Sorry, the customer has not reported any calls yet..!')
             set filter to
             skip -1
             cMode := 'A'
           endif
         elseif nX == 2 .or. nX == 3 .or. nX == 4
           cMode := '_'

           sele accounts
           set order to 1
           // because WARRANTY is 3, AMC 4, ASC 5 (and nX is 2 for war, 3 amc..)
           seek nX+1
           sele subheads
           set order to 2
           SubView()
           sele service
           cmFilter("acc_sub=="+cm2str(subheads->id))
           go top
           if eof()
             msg('Sorry, the customer has not reported any calls yet..!')
             set filter to
             skip -1
             cMode := 'A'
           endif
         endif  
         sele service
      endif

      oBrowse:refreshall()
      oBrowse:forcestable()

   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
   endcase
enddo
close all
restscreen( 0, 0, 24, 79, cScreen )
return nil
//----------------
static function TProper( cTime )

return subst( cTime, 1, 2 ) + ':' + subst( cTime, 3 )
//------------------------
static function AddEntry( nJob )

local cScreen   := savescreen()
local cCust
local nCust
local dRDate
local cRTime
local cATime
local dADate
local cEng
local nEng
local cType
local cProblem
local cSolution
local nAmount
local lNew      := .f.
local nRow      := 02
local nChoice   := 0
local x
local aMemo
local nSubAcc

sele service
set filter to
set order to 1

dispscrn()
makebox( 01, 00, 23, 79 )
setcolor( boxcolor() )
footline( JROW 01, 01, 78 )
footline( JROW 03, 01, 78 )
footline( JROW 05, 01, 78 )
footline( JROW 07, 01, 78 )
footline( JROW 09, 01, 78 )
footline( JROW 11, 01, 78 )
footline( JROW 16, 01, 78 )

@ JROW 00, 01 say 'Job No.: '            
@ JROW 00, 22 say 'Call Date : '         
@ JROW 00, 52 say 'Call Time : '         

@ JROW 04, 02 say 'Customer       : '         
@ JROW 06, 02 say 'Date Attended  : '         
@ JROW 06, 40 say 'Time Attended : '          
@ JROW 08, 02 say 'Engineer       : '         

@ JROW 10, 02 say 'Amount Charged : '         

@ JROW 11, 58 say '[Problem Reported]'         
@ JROW 16, 58 say '[Action Taken]'             

if nJob = NIL
   go bott
   nJob := id + 1
   @ JROW 00, 01 say 'Job No.: ' get nJob pict '9999'       
   read
   if nJob = 0
      restscreen( 0, 0, 24, 79, cScreen )
      return .f.
   endif
endif

@ JROW 00, 01 say 'Job No.:  ' + str( nJob, 4, 0 )         

seek nJob
if !found()
   cCust     := ""
   nCust     := 0
   dRDate    := entr_date()
   cRTime    := subs( time(), 1, 5 )
   cATime    := "00:00"
   dADate    := entr_date()
   cEng      := ""
   nEng      := 0
   cProblem  := ""
   cSolution := ""
   nAmount   := 0.00
   cType     := 'WARRANTY'
   lNew      := .t.
   nSubAcc   := 0
else
   cType := type
   if cType == 'PA'
      cCust := padr( FindHead( service->customer ), 30 )
   else
      sele subheads
      set order to 1
      seek service->acc_sub
      cCust := padr( subheads->subhead, 30 )
   endif
   sele service
   nCust     := customer
   nSubAcc   := acc_sub
   dRDate    := R_DATE
   cRTime    := subs( R_Time, 1, 2 ) + ':' + subs( R_Time, 3 )
   cATime    := subs( A_Time, 1, 2 ) + ':' + subs( A_Time, 3 )
   dADate    := A_Date
   cEng      := padr( FindHead( engineer ), 30 )
   nEng      := engineer
   cProblem  := problem
   cSolution := solution
   nAmount   := amount
   lNew      := .f.
   @ JROW 00, 22 say 'Call Date : ' + dtoc( dRDate )         
   @ JROW 00, 52 say 'Call Time : ' + cRTime                 

   if cType == 'PA'
      scrcenter( JROW 02, 'PAID SERVICE' )
   elseif cType == 'WA'
      scrcenter( JROW 02, 'WARRANTY' )
   elseif cType == 'AS'
      scrcenter( JROW 02, 'SERVICE CONTRACT' )
   elseif cType == 'AM'
      scrcenter( JROW 02, 'MAINTENANCE CONTRACT' )
   endif

   @ JROW 04, 02 say 'Customer       : ' + cCust         

   @ JROW 06, 02 say 'Date Attended  : ' + dtoc( dADate )         

   if !empty( dADate )
      @ JROW 06, 40 say 'Time Attended : ' + cATime         
   else
      @ JROW 06, 40 say '== Service Pending =='         
   endif

   @ JROW 10, 02 say 'Amount Charged : ' + str( nAmount, 5, 0 ) + '  '         

   @ JROW 08, 02 say 'Engineer       : ' + cEng         

   aMemo := Memo2Array( cProblem, 75, 3, .t. )
   for x := 1 to 4
      if x > len( aMemo )
         exit
      endif
      @ JROW 11 + x, 02 say aMemo[ x ]         
   next x

   aMemo := Memo2Array( cSolution, 75, 3, .t. )
   for x := 1 to 4
      if x > len( aMemo )
         exit
      endif
      @ JROW 16 + x, 02 say aMemo[ x ]         
   next x

endif

@ JROW 00, 22 say 'Call Date :' get dRDate pict '@D'       
read
if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

if empty( dRDate )
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

@ JROW 00, 22 say 'Call Date : ' + dtoc( dRDate )         

@ JROW 00, 52 say 'Call Time :' get cRTime valid TimeOk( cRTime ) pict '99:99'      
read
if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

@ JROW 00, 52 say 'Call Time : ' + cRTime         

if cType = 'PA'
   nChoice := 1
elseif cType = 'WA'
   nChoice := 2
elseif cType = 'AS'
   nChoice := 3
elseif cType = 'AM'
   nChoice := 4
else
   nChoice := 1
endif

@ JROW 02, 22 say space( 50 )         

set escape on

@ JROW 02, 22 prompt 'Paid'
@ JROW 02, 27 say '³'         
@ JROW 02, 29 prompt 'Warranty'
@ JROW 02, 38 say '³'         
@ JROW 02, 40 prompt 'Service Cnt.'
@ JROW 02, 52 say '³'         
@ JROW 02, 54 prompt 'Maint. Cnt.'

menu to nChoice

if nChoice == 0 .or. lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

@ JROW 02, 22 say space( 50 )         

if nChoice == 1
   cType := 'PA'
   scrcenter( JROW 02, 'PAID SERVICE' )
elseif nChoice == 2
   cType := 'WA'
   scrcenter( JROW 02, 'WARRANTY' )
elseif nChoice == 3
   scrcenter( JROW 02, 'SERVICE CONTRACT' )
   cType := 'AS'
elseif nChoice == 4
   scrcenter( JROW 02, 'MAINTENANCE CONTRACT' )
   cType := 'AM'
endif

sele service
@ JROW 04, 02 say 'Customer       : ' + cCust         

if cType == 'PA'    // For Paid customers, use the Direct Account from ACCOUNTS.DBF
   nSubAcc := 0
   sele accounts
   if nCust != 0
      FindHead( nCust )
      // The FindHead issues a SET FILTER TO command for an effective SEEK.
      // So, we should put the filter only after it.
      set filter to alltrim( upper( type ) ) == 'DEBTOR'
   else
      set filter to alltrim( upper( type ) ) == 'DEBTOR'
      go top
   endif
   accview( .t., .f., nil, nil, nil, .f., { || alltrim( upper( accounts->type ) ) == 'DEBTOR' } )
   nSubAcc := 0
   cCust   := padr( accounts->account, 30 )
   nCust   := accounts->id
else
   sele accounts
   set order to 1
   if cType == 'WA'
      seek WARRANTY_AC
   elseif cType == 'AS'
      seek ASC_AC
   elseif cType == 'AM'
      seek AMC_AC
   endif
   SubView()
   set filter to
   nSubAcc := subheads->id
   nCust   := accounts->id
   cCust   := padr( subheads->subhead, 30 )
endif

@ JROW 04, 02 say 'Customer       : ' + cCust         

@ JROW 06, 02 say 'Date Attended  :' get dADate pict '@D' valid ( empty( dADate ) .or. dADate >= dRDate )      
read
@ JROW 06, 02 say 'Date Attended  : ' + dtoc( dADate )         

if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

@ JROW 06, 35 say space( 35 )         

if !empty( dADate )
   @ JROW 06, 40 say 'Time Attended :' get cATime pict '99:99' valid TimeOk( cATime )      
   read
   @ JROW 06, 40 say 'Time Attended : ' + cATime         
   if lastkey() == K_ESC
      restscreen( 0, 0, 24, 79, cScreen )
      return .f.
   endif
else
   cATime := '00:00'
   @ JROW 06, 40 say '== Service Pending =='         
endif

sele service
@ JROW 08, 02 say 'Engineer       : ' + cEng         
sele accounts
if nEng != 0
   FindHead( nEng )
   // The FindHead issues a SET FILTER TO command for an effective SEEK.
   // So, we should put the filter only after it.
   set filter to alltrim( upper( type ) ) = 'SERVICE ENGG.'
else
   set filter to alltrim( upper( type ) ) = 'SERVICE ENGG.'
   go top
endif
accview( .t., .f., nil, nil, nil, .f., { || alltrim( upper( accounts->type ) ) == 'SERVICE ENGG.' } )
cEng := padr( accounts->account, 30 )
nEng := accounts->id
@ JROW 08, 02 say 'Engineer       : ' + cEng         

@ JROW 10, 02 say 'Amount Charged :' get nAmount pict '99999'       
read
@ JROW 10, 02 say 'Amount Charged : ' + str( nAmount, 5, 0 ) + '  '         

if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

footline( JROW 11, 01, 78 )
@ JROW 12, 02 clear to JROW 20, 77

cProblem := j_getmemo( JROW 12, 02, JROW 20, 77, cProblem, 'Problem Reported', .t., GetColor( 2 ) )
if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

cSolution := j_getmemo( JROW 12, 02, JROW 20, 77, cSolution, 'Action Taken', .t., GetColor( 2 ) )
if lastkey() == K_ESC
   restscreen( 0, 0, 24, 79, cScreen )
   return .f.
endif

@ JROW 12, 01 clear to JROW 20, 78

footline( JROW 11, 01, 78 )
@ JROW 11, 58 say '[Problem Reported]'         

aMemo := Memo2Array( cProblem, 75, 3, .t. )
for x := 1 to 4
   if x > len( aMemo )
      exit
   endif
   @ JROW 11 + x, 02 say aMemo[ x ]         
next x

footline( JROW 16, 01, 78 )
@ JROW 16, 58 say '[Action Taken]'         

aMemo := Memo2Array( cSolution, 75, 3, .t. )
for x := 1 to 4
   if x > len( aMemo )
      exit
   endif
   @ JROW 16 + x, 02 say aMemo[ x ]         
next x

if !ac_closed( service->A_DATE ) 
if jAlert( "Save Entry?", { "[ Yes ]", "[ No ]" } ) == 1
   select service
   if lNew
      append blank
      field->id := nJob
   else
      JRLock()
   endif
   field->R_DATE := dRDate
   field->A_DATE := dADate
   field->R_TIME := subs( cRTime, 1, 2 ) + subs( cRTime, 4 )                    // To eliminiate the : delimeter
   field->A_TIME := subs( cATime, 1, 2 ) + subs( cATime, 4 )
   field->type   := upper( cType )

   field->customer := nCust
   field->acc_sub  := nSubAcc
   field->engineer := nEng
   field->problem  := cProblem
   field->solution := cSolution
   field->amount   := nAmount
   if !empty( a_date )
      field->closed := .t.
   else
      field->closed := .f.
   endif

   jRUnLock()

   UpdDBook()
else
   msg( 'Entry not saved...' )
endif
else
msg("The entry date has been closed..","Changes not saved.")
endif

restscreen( 0, 0, 24, 79, cScreen )

return service->( recno() )
//=================================================================
static function TimeOk( cTime )

local nHours := val( subs( cTime, 1, 2 ) )
local nMin   := val( subs( cTime, 4, 2 ) )
// Time should be after 6'Oclock in the morning and between 24 hrs
return ( nHours > 6 ) .and. ( nHours <= 24 .and. nMin < 60 )
//-----------------------------------------------------------------
static function srvPendingB

local oBrowse
oBrowse           := TbrowseDB( 4, 2, 19, 77 )
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oBrowse:colorSpec := boxcolor()
oColumn           := TBColumnNew( 'Call Date', { || dtoc( R_DATE ) } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'C.Time', { || TProper( R_TIME ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Customer', { || subs(ExactCust(),1,15) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Job No.', { || str( id, 5, 0 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Engineer', { || subs( FindHead( engineer ), 1, 15 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

oColumn         := TBColumnNew( 'Type', { || type } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
return oBrowse
//------------------------------------------------------------
static function UpdDBook

local nId
sele service
if dbk_id != 0
   sele daybook
   set order to 5
   seek service->id
   if found()
      if !type = 'Service'
         do while inv_id == service->id .and. ( type != 'Service' )
            skip
         enddo
      endif
      do while inv_id == service->id .and. ( type = 'Service' ) .and. ( !eof() )
         blankrec()
         jRLock()
         delete
         jRUnLock()
         seek service->id
      enddo
   endif
endif

if service->amount > 0 .and. ( !empty( service->A_Date ) )
   // If it is chargeable and also the service has been attended to...
   sele daybook
   set order to 1
   go bott
   nId := id + 1

   sele daybook
   append blank
   field->id   := nId
   field->type := 'Service'
   field->date := service->A_DATE

   if service->type == 'PA'             // Paid Service - the customer has to pay it
      field->account := service->CUSTOMER
      field->details := "S/C : " + alltrim( str( service->id ) ) + " (" + alltrim( FindHead( service->engineer ) ) + ")"
   elseif service->type == 'WA'         // Warranty service - reduce from the Warranty cash deposit
      field->account := WARRANTY_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   elseif service->type == 'AM'         // AMC
      field->account := AMC_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   elseif service->type == 'AS'         // ASC
      field->account := ASC_AC
      field->details := "S/C : " + alltrim( str( service->id ) ) + " To:" + alltrim( FindSubHead( service->acc_sub ) ) + " [" + ;
                        alltrim( FindHead( service->engineer ) ) + "]"
   endif

   field->acc_sub := service->acc_sub
   field->amount  := service->amount
   field->inv_id  := service->id
   field->action  := 'D'
   field->auto    := .t.
   field->user    := '_S_'

   append blank
   field->id      := nId + 1
   field->type    := 'Service'
   field->date    := service->A_DATE
   field->account := service->ENGINEER
   field->amount  := service->amount
   field->inv_id  := service->id
   field->action  := 'C'

   if service->type == 'PA'             // Paid Service
      field->details := "Cash [" + alltrim( str( service->id ) ) + "] " + alltrim( FindHead( service->customer ) )
   elseif service->type == 'WA'
      field->details := "Warranty [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   elseif service->type == 'AM'
      field->details := "AMC [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   elseif service->type == 'AS'
      field->details := "ASC [" + alltrim( str( service->id ) ) + "] " + alltrim( FindSubHead( service->acc_sub ) )
   endif

   field->auto := .t.
   field->user := '_S_'

   jRUnLock()

   sele service
   jRLock()
   field->dbk_id := nId
   jRUnLock()
   commit
endif

sele service
setcolor( boxcolor() )
return .t.
//-------------------------
function ExactCust()    //  a public function- used in SERV_REP.prg also.

local cRet := ""
sele service
if type == 'PA'
   cRet := FindHead( service->customer )
else
   cRet := FindSubHead( service->acc_sub )
endif
sele service
return cRet
//-------------------------
static function _SayStat( ccMode, lClosed )

setcolor( scrcolor() )

if ccMode == 'A'
   @  2,  1 say padc( '[ALL] Service Calls', 78 )         
elseif ccMode == 'P'
   @  2,  1 say padc( '[UN-ATTENDED] Service Calls', 78 )         
elseif ccMode == 'C'
   @  2,  1 say padc( '[OPEN] Service Calls', 78 )         
elseif ccMode == '_'
   @  2,  1 say padc( 'Service Calls filtered by Customer', 78 )         
endif

setcolor( boxcolor() )

@ 22, 02 say space( 74 )         

if empty( A_DATE )
   @ 22, 02 say 'Service not attended'         
elseif ( !empty( A_DATE ) ) .and. CLOSED
   @ 22, 02 say 'Attended on: ' + dtoc( A_DATE ) + ' Time: ' + subs( A_Time, 1, 2 ) + ':' + subs( A_Time, 3 ) + ;         
           ' - CLOSED'
elseif ( !empty( A_DATE ) ) .and. ( !CLOSED ) .and. New_no == 0
   @ 22, 02 say 'Attended on: ' + dtoc( A_DATE ) + ' Time: ' + subs( A_Time, 1, 2 ) + ':' + subs( A_Time, 3 ) + ;         
           ' - NOT CLOSED'
elseif ( !empty( A_DATE ) ) .and. ( !CLOSED ) .and. New_no > 0
   @ 22, 02 say 'Attended on: ' + dtoc( A_DATE ) + ' Time: ' + subs( A_Time, 1, 2 ) + ':' + subs( A_Time, 3 ) + ;         
           ' - Cont.:' + alltrim( str( new_no, 5, 0 ) )
endif

if lClosed
   @ 22, 56 say '[' + dtoc( A_DATE ) + ' A/C Closed]'         
else
   @ 22, 56 say '                       '         
endif

return nil
//=========================================================================
/*
static function srvAdd
local nChoice, nCont

nChoice := jAlert('þ Add Service þ', { '[Fresh Service Call]','[Continuation Call]' })

if nChoice=NIL .or. nChoice = 0
  return .f.
endif

if nChoice == 1
  addentry(, .f. )
elseif nChoice == 2
  nCont := 0
  popread(.f.,'Continued Service of Call No.: ',@nCont
*/

*+ EOF: SERVICE.PRG
