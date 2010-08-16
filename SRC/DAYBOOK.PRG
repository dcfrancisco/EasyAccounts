#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

function newDbkView
private dbkTemp := alltrim(jTempFile("tmp","dbf"))
private oBrowse
*jAlert('Comprehensive voucher entry temporarily disabled..')

sMkDbkTemp( dbkTemp )
sMultDay()
close all
ferase(dbkTemp+'.DBF')
ferase(dbkTemp+'.CDX')

return .t.
//--------------

static function sMultDay(lNew)
local bBox, oColumn, nKey := 0
local nVBal := 0.00,X

// **********************
// 'DbkTemp' is actually a string variable which contains the name
// of the temporary file used. Since this app. works in a network environ.,
// we cant use only just one temp. file for all the clients. So, each
// client has to create its own temp. file for doing something.
// ***********************

if lNew=NIL
  lNew := .t.
endif

bBox := makebox( 2, 4, 11, 74, boxcolor(), 0 )
setcolor(scrcolor())
@ 2, 4 say padc("þ Voucher Entry þ", 71)
@11, 4 say padc("þ ESC - Abort þ", 71)
setcolor(boxcolor())
makebox( 3, 4, 10, 74, boxcolor(), 0 )
close all
use ACCOUNTS new index ACC_1,ACC_2
seek 1           // Default A/C should come CASH
set order to 2

eUse(DBKTEMP) 
set filte to !deleted()
go top
if eof()
  appe blank
  keyboard chr(K_ENTER)
endif

sum all debit-credit to nVBal
go top

oBrowse := TBrowseDB(4, 5, 9, 73)

oBrowse:autoLite := .f.
oBrowse:headSep := 'ÍÑÍ'
oBrowse:colSep  := ' ³ '

oColumn := TBColumnNew('Account', { | | nd_acname() } )
oBrowse:AddColumn( oColumn )

oColumn := TBColumnNew('Debit', {|| iif(debit=0,space(9),str(debit,9,2))} )
oBrowse:AddColumn( oColumn )

oColumn := TBColumnNew('Credit',{|| iif(credit=0,space(9),str(credit,9,2)) } )
oBrowse:AddColumn( oColumn )

do while nKey <> K_ESC

   dispbegin()

   setcolor(scrcolor())
   if nVBal > 0
      @11, 4 say padc("Diff. In Balance : DR. "+ alltrim(str(nVBal,19,2))+"             þ ESC - Abort þ", 71)
   elseif nVBal < 0
      @11, 4 say padc("Diff. In Balance : CR. "+ alltrim(str(abs(nVBal),19,2))+"             þ ESC - Abort þ", 71)
   elseif nVBal = 0
      @11, 4 say padc("No Diff In Balance.         þ ESC - Abort þ", 71)
   endif
   setcolor(boxcolor())

   oBrowse:forcestable()

   dispend()

   if oBrowse:stable
      if oBrowse:hitBottom
         append blank
         oBrowse:down()
         oBrowse:forcestable()
         oBrowse:refreshall()
         if cmFiltCount() < 4
           keyboard repli( chr(K_UP), cmFiltCount() )+repli( chr(K_DOWN), cmFiltCount()-1 )+chr(K_ENTER)
         else
           keyboard repli( chr(K_UP),4)+repli(chr(K_DOWN),3)+chr(K_ENTER)
         endif
         /*
         keyboard repli(chr(K_UP),iif(cmFiltCount() < 4,cmFiltCount(),4))+;
                  repli(chr(K_DOWN),iif(cmFiltCount() < 4,cmFiltCount(),4))+chr(K_ENTER)
         */
         oBrowse:hitbottom := .f.
      endif
      setcursor(0)
      oBrowse:hilite()
      nKey := inkey( 0 )
      oBrowse:dehilite()
   endif

   do case
   case nKey == K_ALT_R
      plswait(.t.,'Generating HTML...')
      tb2Html(oBrowse,'EARep.HTM','Daybook Voucher' )
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
   case nKey == K_F8
      vs_calc()
   case nKey == K_F9
      calendar()
   case nKey == K_F5
      pop_menu()
      go top
      oBrowse:refreshall()
   case nKey == K_ENTER
      if oBrowse:colpos = 1        // Account
         sele ACCOUNTS
         if (DBKTEMP)->account != 0
            set order to 1
            seek ( DBKTEMP )->account
            set order to 2
         else
            sele ACCOUNTS
            set order to 2
            go top
         endif
         if accview( ,,,,.t. )
            sele accounts
            set order to 1
            sele ( DBKTEMP )
            jRLock()
            field->account := ACCOUNTS->id
            jRUnLock()
            oBrowse:refreshcurrent()
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         else
            sele ( DBKTEMP )
            if (debit+credit) = 0      // Delete the curr. entry
               jRLock()
               delete
               jRUnLock()
               skip
               if eof()
                 skip -1
               endif
               oBrowse:refreshall()
            endif
         endif
      elseif oBrowse:colpos = 2
         if debit = 0 
           if nVBal < 0     // Now it is credit. bal. so issue a corres. debit entry
             jRLock()
             field->debit := abs(nVBal)
             jRUnLock()
             dbEditCell(oBrowse,2)
             oBrowse:refreshcurrent()
             if debit = 0
               keyboard chr(K_RIGHT)+chr(K_ENTER)
             endif
           else
             dbEditCell(oBrowse,2)
             oBrowse:refreshcurrent()
             if debit > 0 .and. (nVBal + debit) <> 0
                keyboard chr(K_LEFT)+chr(K_DOWN)
             elseif debit = 0
                keyboard chr(K_RIGHT)+chr(K_ENTER)
             endif
           endif
         else
           dbEditCell(oBrowse,2)
         endif
         jRLock()
         field->credit := 0.00
         jRUnLock()
         oBrowse:refreshcurrent()
       elseif oBrowse:colpos = 3
         if credit = 0 
           if nVBal > 0     // Now it is credit. bal. so issue a corres. debit entry
             jRLock()
             field->credit := abs(nVBal)
             jRUnLock()
             dbEditCell(oBrowse,3)
           else
             dbEditCell(oBrowse,3)  
           endif
         else
           dbEditCell(oBrowse,3)  
         endif
         jRLock()
         field->debit := 0.00
         jRUnLock()
         oBrowse:refreshcurrent()
         nVBal := nvCount()
         if nvBal <> 0
            keyboard chr(K_LEFT)+chr(K_LEFT)+chr(K_DOWN)
         endif
      endif
   endcase
   nvBal := nvCount()
   select ( DBKTEMP )
enddo
unbox( bBox )
setcursor(1)
close all
eUse(dbkTemp)
delet all for debit+credit=0
pack
go top
if cmFiltCount() > 1
  if nVCount() <> 0
    jAlert("Voucher not tallied. Data not processed.")
  else
    // Creates needed entries in all the books...
    if !  ProcessVoucher()
      jAlert('Automatic voucher placement failed..!')
    endif
  endif
else
  jAlert('Voucher not processed...')
endif
return .t.
//========================================
function nd_acname   
sele accounts
set order to 1
seek ( DBKTEMP )->account
sele ( DBKTEMP )
return padr( alltrim(accounts->account)+iif(!empty(alltrim(accounts->details)),', '+alltrim(accounts->details),''), 40 )
//---------------------------------------------------------
static function dbEditCell(oBrowse,nCol)
local oColumn := oBrowse:getColumn(oBrowse:colPos)
local xOldvalue := eval(oColumn:block)
local lInsState := set(_SET_INSERT)
//ÄÄÄÄ set insert key to toggle both insert mode & cursor
local lOldins := setkey( K_INS, {|| setcursor( ;
         if(readinsert(! readInsert()), SC_NORMAL, SC_INSERT))} )

//ÄÄÄÄ initial cursor setting based on current mode
local nOldcursor := setcursor( if(readInsert(), SC_INSERT, SC_NORMAL) )
local nValue := val(alltrim(eval(oColumn:block)))

//ÄÄÄÄ create corresponding GET with GETNEW() and read it now
@ row(), col() get nValue picture '999999.99'
read

jRLock()
fieldput(nCol, nValue)
jRUnLock()

setcursor(nOldcursor)      // turn cursor back off
setkey(K_INS, lOldins)     // reset INS key
set(_SET_INSERT, lInsState)
return ( eval(oColumn:block) <> xOldvalue )

function sMkDbkTemp(dbkTemp)
dbcreate(dbkTemp, { ;
       { 'ACCOUNT', 'N', 4, 0},;
       { 'DEBIT', 'N', 11, 2 },;
       { 'CREDIT','N', 11, 2 },;
       { 'DETAILS', 'C', 50, 0 } ;
       } )
return dbkTemp
//------------------------
/*
static function nvCount
local nRec,lEof, lBof, nBal := 0
local x := 0, y
sele ( DBKTEMP )
oBrowse:forcestable()
nRec := recno()
lEof := eof() .or. oBrowse:hitbottom()
lBof := bof()                              
nBal := 0.00
sum all debit-credit to nBal
oBrowse:gotop()
do while .not. (recno() == nRec) .and. (!eof())
 oBrowse:down()
 oBrowse:forcestable()
enddo
if lEof
 oBrowse:down()
 oBrowse:forcestable()
endif
return nBal
*/
//--------------------------
static function nvCount
local nRec,lEof, lBof, nBal := 0
local nDE := 0, nCE := 0
sele ( DBKTEMP )
nRec := recno()
lEof := eof()
lBof := bof()                              
nBal := 0.00
go top
do while .not. eof()
  nBal += debit-credit
  if debit > 0
    nDE++
  elseif credit > 0
    nCE++
  endif
  skip
enddo
go nRec

if nDE > 1 .and. nCE > 1  // Cannot process such a voucher...
  jAlert("Cannot accept a voucher having more than one debit entry ; as well as more than one credit entry.;; Please give the input accordingly...")
  field->account := 0
  field->debit := 0
  field->credit := 0
  delete
  skip -1
  oBrowse:forcestable()
  oBrowse:refreshall()
endif
if lEof
 go lastrec()+1
endif
return nBal

//=======================================
static function ProcessVoucher
local aSource := {} // The source a/c will be only one (since we dont allow multiple dr. and crs..)
local aTargets := {}
local nDrCash := 0.0
local nDbDebit := 0.00, nDbCredit := 0.00
local x := 0
local aSrcType,nEntryId

index on credit-debit to (dbkTemp)
go top
do while debit > 0 .and. (!eof())
  x++
  skip
enddo
if x > 1   // More than one debit entry. So, the source is a CREDIT entry...
  aSource := { account, debit, credit, details }
elseif x = 1 // Only one debit entry. So, the source is the DEBIT itself
         // This can also happen if there is only one debit and credit entry.
        // No problem for that too...
  go top
  aSource := { account, debit, credit, details }
endif
if x = 1
 skip
 do while credit > 0 .and. (!eof())
   aadd(aTargets, { account, debit, credit, details })
   skip
 enddo
elseif x > 1
 go top
 do while debit > 0 .and. (!eof())
   aadd(aTargets, { account, debit, credit, details })
   skip
 enddo
endif
close all
use cashbook new index CSH_1, CSH_2, CSH_3, CSH_4, CSH_5
use bankbook new index BNK_1,BNK_2,BNK_3
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6

use accounts new index ACC_1,ACC_2
set order to 1

seek aSource[1]     // Pagecode
if ! found()
  jAlert('Error during voucher processing. Voucher not updated...')
  close all
  return .f.
endif
aSrcType := type

for x := 1 to len(aTargets)
  if alltrim( upper(aSrcType) ) == 'BANK'
    if aTargets[x,1] = 1  // Cash So must be a deposit or withdrawal..
       sele cashbook
       nEntryId := j_LastId()
       append blank
       replace id with nEntryId
       replace date with entr_date()
       replace account with aSource[1]
       replace amount with aTargets[x,2]+aTargets[x,3]
       replace details with aTargets[x,4]
       replace action with iif(aTargets[x,2] > 0, 'D', 'C')
       replace type with iif(action='D','Deposit','Withdrawal')
       replace user with user()
       jRUnLock()
    else
       sele accounts
       set order to 1
       go top
       seek aTargets[x,1]
       if ! found()
         jAlert('Error during voucher processing. Voucher not completely updated...')
         exit
       endif
       sele bankbook
       nEntryId := j_LastId()
       append blank
       replace id with nEntryId
       replace date with entr_date()
       replace b_id with aSource[1]
       replace account with aTargets[x,1]
       replace amount with aTargets[x,2]+aTargets[x,3]
       replace details with aTargets[x,4]
       replace action with iif(aTargets[x,2] > 0, 'D', 'C')
       replace type with iif(action='D','Withdrawal','Deposit')
       replace user with user()
       jRUnLock()
    endif
  elseif aSource[1] == 1 // Cash
    if ! aTargets[x,1] = 1  // Target is also a cash. So ignore that entry...
       sele accounts
       set order to 1
       go top
       seek aTargets[x,1]
       if ! found()
         jAlert('Error during voucher processing. Voucher not completely updated...')
         exit
       endif
       sele cashbook
       nEntryId := j_LastId()
       append blank
       replace id with nEntryId
       replace date with entr_date()
       replace account with aTargets[x,1]
       replace amount with aTargets[x,2]+aTargets[x,3]
       replace details with aTargets[x,4]
       replace action with iif(aTargets[x,2] > 0, 'D', 'C')
       if alltrim(upper(accounts->type)) != 'BANK'
         replace type with iif(action='D','Expense','Income')
       else
         replace type with iif(action='D','Deposit','Withdrawal')
       endif
       replace user with user()
       jRUnLock()
    endif
  else
     sele daybook
     nEntryId := j_LastId()
     append blank
     replace id with nEntryId
     replace date with entr_date()
     replace account with aTargets[x,1]
     replace amount with aTargets[x,2]+aTargets[x,3]
     replace details with aTargets[x,4]
     replace action with iif(aTargets[x,2] > 0, 'D', 'C')
     replace type with 'Daybook'
     replace user with user()
     nDbDebit += aTargets[x,2]
     nDbCredit += aTargets[x,3]
     jRUnLock()
  endif
next x
if (nDbDebit-nDbCredit) <> 0
     sele daybook
     nEntryId := j_LastId()
     append blank
     replace id with nEntryId
     replace date with entr_date()
     replace account with aSource[1]
     replace amount with abs(nDbDebit-nDbCredit)
     replace details with aSource[4]
     replace action with iif(nDbDebit < nDbCredit, 'D', 'C')
     replace type with 'Daybook'
     replace user with user()
     jRUnLock()
endif
close all
return .t.
//=======================================
static function j_LastId
local nLastLid
set order to 1
go bott
nLastId := id+1
return nLastId

*+ EOF: DAYBOOK.PRG
