#include "std.ch"
#include "inkey.ch"
#include "box.ch"
#include "ghost.ch"

#define R_ALL       1
#define WOTRANSFER  2
#define WOGENERALSALESTRANSFER  3
#define GENERALSALESONLY  4
#define TRANSFERONLY  5

//----------------------------------------
// CreateUser()
//    For EA v2.5 PRO by Jasim A Basheer
// ---------------------------------------
function CreateUser

local cUCode  := space( 3 )
local cUName  := space( 20 )
local cPass   := space( 10 )
local nChoice
local cScrn   := savescreen()
local cPass1  := space( 10 )
local lExist
if !sp_visor()
   jAlert( 'User creation capability available only to the Supervisor' )
   return .f.
endif
jSaveEnv()
close all
if !file( NetDrive+':\EA\' + DataDir() + '\USERS.DBF' )
   jAlert( 'User creation capability can be accessed ; only from the database server.' )
   jRestEnv()
   return .f.
endif
UOpen( NetDrive+':\EA\' + DataDir() + '\USERS.DBF' )
use ( NetDrive+':\EA\'+DataDir()+'\USERS.DBF') new
setcolor( scrcolor() )
@ 09, 10 say padc( 'Create/Edit User', 41 )         
setcolor( boxcolor() )
makebox( 10, 10, 18, 50 )
@ 12, 12 say 'User Code     : '                             
@ 13, 12 say 'User Name     : '                             
@ 14, 12 say 'Password      : '                             
@ 15, 12 say 'Confirm       : '                             
@ 12, 12 say 'User Code     :'  get cUCode pict '!!!'       
footline( 16, 11, 39 )
@ 17, 20 say '<Create>'         
@ 17, 35 say '<Abort>'          
read
cUCode := rtrim( ltrim( cUCode ) )
if empty( cUCode )
   jRestEnv()
   return .f.
endif
locate all for cUCode == user
if found()
   setcolor( scrcolor() )
   @ 09, 10 say padc( 'Edit User', 41 )         
   setcolor( boxcolor() )
   lExist := .t.
   cUName := username
//   cPass  := padr( jDecrypt( password, eval( _bEasyKey ) ), 10 )

   cPass  := padr( jDecrypt( password, "This is EasyAccounts PRO.. by Jasim" ), 10 )
   // See the User Add procedure for comments.
   

   cPass1 := cPass
   @ 17, 20 say '<Update>'         
else
   setcolor( scrcolor() )
   @ 09, 10 say padc( 'Create New User', 41 )         
   setcolor( boxcolor() )
   lExist := .f.
   cUName := space( 20 )
   cPass  := space( 10 )
   cPass1 := space( 10 )
   @ 17, 20 say '<Create>'         
endif

@ 12, 12 say 'User Code     : ' + cUCode + space( 3 )                            
@ 13, 12 say 'User Name     :'                        get cUName pict '@!'       
read
cUName := rtrim( ltrim( cUName ) )
if empty( cUName )
   jRestEnv()
   return .f.
endif
@ 13, 12 say 'User Name     : ' + padr( cUName, 20 )         

do while .t.
   if !lExist
      @ 14, 12 say 'Password      :' get cPass pict '@!' PASSWORD       
   else
      @ 14, 12 say 'Password      :' get cPass pict '@!'       
   endif
   read
   cPass := rtrim( ltrim( cPass ) )
   if empty( cPass )
      if jAlert( 'Continue with Empty Password ?', { 'Yes', 'No' } ) = 1
         exit
      else
         loop
      endif
   endif
   if !lExist
      @ 15, 12 say 'Confirm       :' get cPass1 pict '@!' PASSWORD       
      read
      if rtrim( ltrim( cPass1 ) ) != rtrim( ltrim( cPass ) )
         jAlert( 'Retyped password mismatches!' )
         cPass1 := space( 10 )
         cPass  := space( 10 )
         loop
      else
         exit
      endif
   else
      exit
   endif
enddo
footline( 16, 11, 39 )
if !lExist
   @ 17, 20 prompt '<Create>'
else
   @ 17, 20 prompt '<Update>'
endif
@ 17, 35 prompt '<Abort>'
menu to nChoice
if nChoice = 1
   if !lExist
      append blank
   else
      jRLock()
   endif
   field->USER     := cUCode
   field->USERNAME := cUName
   //field->PASSWORD := jEncrypt( padr( rtrim( ltrim( cPass ) ), 10 ), eval( _bEasyKey ) )
   field->PASSWORD := jEncrypt( padr( rtrim( ltrim( cPass ) ), 10 ), "This is EasyAccounts PRO.. by Jasim")

// Made on 12-03-2006. 9:00 am. I have decided to let EA be
// public.. source and all.. no more security checks needed...
// Also to give the entire source to download on the Net and on my
// blog www.jabpaacet.blogspot.com
//
// So no more encryption using the HDD srl number.. just go for a normal
// kinda routine so that the program works wherever it is copied to..


   jRUnLock()
   close all
   OpenUsers()      // Add this user to the public aUsers array.
   if !lExist
      jAlert( 'User : ' + cUName + ' Created!' )
   else
      jAlert( 'User : ' + cUName + ' Updated!' )
   endif
endif
jRestEnv()
return .t.
//----------------------------------------------
function managerlevel

local x
local y
local z    := savescreen()
local nSel
local xx   := row()
local yy   := col()

local aMenu

jSaveEnv()
close all
dispscrn()
set key K_F2 to

// if BRJAConfrm()
// No more BRJA.. show this menu when pressing ALT+M..
// because this privilege is only for login with SUP..

// EDUCATION FEE COLLECTION REPORT function is disabled from now on
// (during the generic making..)
// the function is there (and NOT commented) **eCollection()**

//  sup_special() for cash balance also disabled.. as part of generification.

do while .t.
   nSel := menu_v( 'MIS Module :', ;
                   'A. Assets Flow', ;
                   'B. Financial Analysis', ;
                   'C. Sales/Purchase Profit Report', ;
                   'D. Open Books', ;
                   'E. View Users List', ;
                   'F. Integrity Check', ;
                   'G. Year End Closing', ;
                   'H. Edit Company Info', ;
                   'I. Stock Report' )

   if nSel = 1
      AssetFlow()
   elseif nSel = 2
      x := jAlert( 'Analysis Type : ', ;
                   { 'Monitor by Period', ;
                   'Monitor by Company', ;
                   'Take Current Snapshot' } )
      if x = 1
         PrintCapital( 1 )
      elseif x = 2
         PrintCapital( 2 )
      else
         jFinStat()
      endif
   elseif nSel == 3
      UserLevel()
   elseif nSel = 4
      openbooks()
   elseif nSel = 5
      pwordlist()
   elseif nSel = 6
      intg_date()
   elseif nSel = 7
      yrClose()
   elseif nSel = 8
      editcompany()
   elseif nSel = 9
      custStockRep()
   else
      exit
   endif
enddo
close all
restscreen( 0, 0, 24, 79, z )
@ xx, yy say ""         
close all
jRestEnv()
return .t.
//---------------
function sup_sales( WhichType, dFrom, dTo, lDisplay, nInclude )

local line       := 0
local nSrl       := 0
local nTot       := 0.00
local nMonthTot  := 0.00
local nTot1      := 0.00
local nTot2      := 0.00
local nTot3      := 0.00
local nTot4      := 0.00
local nTot5      := 0.00
local nMonthTot1 := 0.00
local nMonthTot2 := 0.00
local nMonthTot3 := 0.00
local nMonthTot4 := 0.00
local nMonthTot5 := 0.00
local nSystemsNo := 0

if lDisplay == NIL
   lDisplay := .t.
endif

if ! ReqInv()
  jAlert('Sorry, this company is not configured for inventory control..')
  return .f.
endif

if dFrom == NIL .or. dTo == NIL

   private d1 := date()
   private d2 := date()

   popread( .f., "þ Detailed Sales Report þ From :", @d1, '@D', ;
            "                            To :", @d2, '@D' )

   if d1 > d2 .or. empty( d1 ) .or. empty( d2 )
      close all
      return .f.
   endif

else

   private d1 := dFrom
   private d2 := dTo

endif

if nInclude == NIL

   nInclude := menu_v( "Include Transactions:", ;
                       "All", ;
                       "Without Transfer", ;
                       "Without General Sales/Transfer", ;
                       "General Sales Only", ;
                       "Transfer Only" )
   if nInclude = 0
      close all
      return .f.
   endif
endif

use accounts new index ACC_1,ACC_2
set order to 1
go top
use master new index MAS_1,MAS_2
set order to 1
use saccount new index SAC_1,SAC_2,SAC_3
set order to 1
use sales new index SALE_1,SALE_2
set order to 1

sele saccount
ShowPBar( "Preparing sales report..." )
if WhichType = "SYSTEM"

   if nInclude = R_ALL .or. nInclude = GENERALSALESONLY
      set filter to date >= d1 .and. date <= d2 .and. ( IsSystem )
   elseif nInclude = WOTRANSFER .or. nInclude = WOGENERALSALESTRANSFER
      set filter to ( IsSystem ) .and. ( date >= d1 .and. date <= d2 ) .and. upper( OTHER ) != 'TRANSFER'
   elseif nInclude = TRANSFERONLY
      set filter to ( IsSystem ) .and. ( date >= d1 .and. date <= d2 ) .and. upper( OTHER ) == 'TRANSFER'
   endif
else
   if nInclude = R_ALL .or. nInclude = GENERALSALESONLY
      set filter to date >= d1 .and. date <= d2 .and. ( !IsSystem )
   elseif nInclude = WOTRANSFER .or. nInclude = WOGENERALSALESTRANSFER
      set filter to ( !IsSystem ) .and. ( date >= d1 .and. date <= d2 ) .and. upper( OTHER ) != 'TRANSFER'
   elseif nInclude = TRANSFERONLY
      set filter to ( !IsSystem ) .and. ( date >= d1 .and. date <= d2 ) .and. upper( OTHER ) == 'TRANSFER'
   endif
endif

PBarFilter()
go top
set device to printer
set printer on
set printer to SALE_SUP.TXT

SayTitles( 57, @line )
line ++

if !( d1 == d2 )
   @ line,  0 say padc( 'Sales Details from ' + dtoc( d1 ) + ' to ' + dtoc( d2 ), 57 )         
else
   @ line,  0 say padc( 'Sales Details of ' + dtoc( d1 ), 57 )         
endif
line ++

if WhichType = "SYSTEM"
   @ line,  0 say padc( "SYSTEM SALES", 57 )         
else
   @ line,  0 say padc( "SPARE SALES", 57 )         
endif

line ++
if nInclude = GENERALSALESONLY
   @ line,  0 say padc( 'General Sales', 49 )         
elseif nInclude = WOTRANSFER
   @ line,  0 say padc( 'All Sale Bills excluding Transfers', 49 )         
elseif nInclude = WOGENERALSALESTRANSFER
   @ line,  0 say padc( 'Sale Bills excluding Transfers and General Sales', 49 )         
elseif nInclude = TRANSFERONLY
   @ line,  0 say padc( 'Transfer Bills only', 49 )         
endif
line ++

@ line,  0 say repli( '-', 57 )         
line ++
@ line,  0 say 'Item Description'         
@ line, 28 say 'Qty'                      
@ line, 33 say 'T/Cost'                   
@ line, 41 say 'T/RPrice'                 
@ line, 52 say 'Profit'                   
line ++
@ line,  0 say repli( '-', 57 )         
line ++
do while .not. eof()
   nTot := 0.00
   nSrl := 0

   sele accounts
   seek saccount->customer

   sele saccount

   if nInclude == R_ALL .or. nInclude == WOTRANSFER .or. nInclude == TRANSFERONLY .or. ;
              ( nInclude == GENERALSALESONLY .and. alltrim( upper( accounts->account ) ) == 'GENERAL SALES' ) .or. ;
              nInclude == WOGENERALSALESTRANSFER .and. alltrim( upper( accounts->account ) ) != 'GENERAL SALES'

      if WhichType = "SYSTEM"
         nSystemsNo ++
         if !( d1 == d2 )               // if only one date is sel., then no date is required.
            @ line,  1 say 'No.: ' + rtrim( ltrim( str( nSystemsNo ) ) ) + ' Srl : ' + rtrim( ltrim( str( saccount->id ) ) ) + " Date : " + dtoc( date )         
            @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )                                                                                               
         else
            @ line,  1 say 'No.: ' + rtrim( ltrim( str( nSystemsNo ) ) ) + ' Srl : ' + rtrim( ltrim( str( saccount->id ) ) ) + " Bill : " + rtrim( ltrim( str( id ) ) )         
         endif
      else
         if !( d1 == d2 )               // if only one date is sel., then no date is required.
            @ line,  1 say 'Date : ' + dtoc( date )                        
            @ line, 19 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
         else
            @ line,  1 say 'Bill : ' + rtrim( ltrim( str( id ) ) )         
         endif
      endif
      line ++

      sele accounts
      if found()
         @ line,  1 say 'Customer : ' + rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", ", "" ) + rtrim( ltrim( proper( details ) ) )         
      else
         @ line,  1 say 'Customer details absent!'         
      endif
      line ++
      if !empty( rtrim( ltrim( saccount->other ) ) )
         @ line, 01 say upper( saccount->other )         
         line ++
      endif
      sele sales
      seek saccount->id
      do while id == saccount->id .and. ( !eof() )
         sele master
         seek sales->item_id
         if found()
            @ line,  1 say subs( proper( desc ), 1, 25 )         
         endif
         @ line, 28 say str( sales->qty, 3, 0 )         

         @ line, 32 say str( ( sales->cost * sales->qty ), 6, 0 ) // T.Cost                          
         @ line, 39 say str( ( sales->qty * sales->price ), 7, 0 ) // T.Retail                       
         @ line, 48 say str( ( sales->price - sales->cost ) * sales->qty, 7, 0 ) // T.Profit         

         line ++
         nTot1 += sales->cost * sales->qty
         nTot2 += sales->price * sales->qty
         nTot3 += ( sales->price - sales->cost ) * sales->qty

         nSrl ++

         sele sales
         skip
      enddo
      if ( nSrl > 1 ) .or. saccount->discount > 0
         @ line, 32 say repli( '-', 23 )         
         line ++
         @ line, 32 say str( nTot1, 6, 0 )         
         @ line, 39 say str( nTot2, 7, 0 )         
         @ line, 48 say str( nTot3, 7, 0 )         
         if saccount->discount > 0
            line ++
            @ line, 15 say "DISCOUNT"                              
            @ line, 48 say str( saccount->discount, 7, 0 )         
            line ++
            @ line, 48 say replicate( '-', 7 )         
            line ++
            @ line, 15 say "Balance"                                       
            @ line, 48 say str( nTot3 - saccount->discount, 7, 0 )         
            nTot3 -= saccount->discount
         endif
      endif

      nMonthTot1 += nTot1
      nMonthTot2 += nTot2
      nMonthTot3 += nTot3

      nTot1 := 0.00
      nTot2 := 0.00
      nTot3 := 0.00
      nTot4 := 0.00
      nTot5 := 0.00
      line ++
   endif
   select saccount
   skip
   IncrPBar()
enddo

if nSystemsNo > 1
   @ line, 02 say "Total " + rtrim( ltrim( str( nSystemsNo ) ) ) + " systems sold."         
endif
@ line, 32 say repli( '-', 23 )         
line ++
@ line, 15 say 'Grand Total --> '              
@ line, 32 say str( nMonthTot1, 6, 0 )         
@ line, 39 say str( nMonthTot2, 7, 0 )         
@ line, 48 say str( nMonthTot3, 7, 0 )         
line ++
line ++
line ++
@ line,  1 say " "         
close all
set device to screen
set printer off
set printer to
HidePBar()
if lDisplay
   fileread( 01, 04, 23, 72, 'SALE_SUP.TXT', 'Sales Details' )
endif
return nMonthTot3
//----------------------------
function sup_special

local aCash   := {}
local nD      := 0.00
local nC      := 0.00
local xCash
local x       := 1
local nChoice

if !file( 'WCEA.SYS' )                  // F10 means create new user for company other than
   CreateUser()     // WSS. For WSS, we want the cash balance.
   return
endif

if !sp_visor()
   jAlert( 'Key not active!' )
   return
elseif !file( 'COMPANY.ADM' )
   jAlert( "Open company as Administration to view cash balance..." )
   return
else
   jSaveenv()
   plswait( .t., 'Counting cash...Education' )
   aadd( aCash, { 'WC, Pulliman (Software)', sumCM( NetDrive() + ':\CMANAGE\EDU\PLLSF' ) } )
   aadd( aCash, { 'WC, Pulliman (Hardware)', sumCM( NetDrive() + ':\CMANAGE\EDU\HW' ) } )
   aadd( aCash, { 'WC, Kayamkulam', sumCM( NetDrive() + ':\CMANAGE\EDU\KYLM' ) } )
   aadd( aCash, { 'WC, Karunagappally', sumCM( NetDrive() + ':\CMANAGE\EDU\KPLY' ) } )
   aadd( aCash, { '', 0.00 } )
   plswait( .f. )
   plswait( .t., 'Counting cash...Systems & Services' )
   aadd( aCash, { 'WSS, Pulliman', sumEA( dir() + '\PULLIMAN' ) } )
   aadd( aCash, { 'WSS, Kollam', sumEA( dir() + '\KOLLAM' ) } )
   aadd( aCash, { '', 0.00 } )
   plswait( .f. )
   plswait( .t., 'Counting cash...Alternate Cash accounts' )
   aadd( aCash, { 'Microsolutions', sumEA( dir() + '\MICROS' ) } )
   aadd( aCash, { 'Graphics', sumEA( dir() + '\GRAPHICS' ) } )
   aadd( aCash, { 'Advertisement', sumEA( dir() + '\ADV' ) } )
   aadd( aCash, { 'Administration', sumEA( dir() + '\ADM' ) } )
   plswait( .f. )
   setcolor( boxcolor() )
   xCash := makebox( 02, 01, 04 + len( aCash ) + 6, 56, boxcolor() )
   setcolor( scrcolor() )
   @ 03, 02 say padc( 'CASH BALANCE SUMMARY', 54 )         
   setcolor( boxcolor() )
   footline( 4, 02, 54 )
   setcolor( msgcolor() )
   @ 05, 06 say "Cash Account"         
   @ 05, 35 say "Debit"                
   @ 05, 45 say "Credit"               
   setcolor( boxcolor() )
   for x := 1 to len( aCash )
      @ 05 + x, 06 say aCash[ x, 1 ]         
      if aCash[ x, 2 ] > 0
         @ 05 + x, 32 say str( aCash[ x, 2 ], 8, 0 )         
      elseif aCash[ x, 2 ] < 0
         @ 05 + x, 42 say str( abs( aCash[ x, 2 ] ), 8, 0 )         
      endif
      if aCash[ x, 2 ] > 0
         nD += abs( aCash[ x, 2 ] )
      else
         nC += abs( aCash[ x, 2 ] )
      endif
   next x
   @ 05 + x, 32 say repli( '-', 8 )              
   @ 05 + x, 42 say repli( '-', 8 )              
   @ 06 + x, 32 say str( nD, 8, 0 )              
   @ 06 + x, 42 say str( nC, 8, 0 )              
   @ 07 + x, 32 say str( nD - nC, 8, 0 )         
   setcursor( 0 )
   @ 05 + x, 05, 08 + x, 11 box B_DOUBLE_SINGLE
   do while .t.
      @ 06 + x, 06 prompt "EXIT"
      @ 07 + x, 06 prompt "PRINT"
      nChoice := 1
      menu to nChoice
      if nChoice = 1 .or. nChoice = 0
         exit
      else
         prn_cash( aCash )
      endif
   enddo
   unbox( xCash )
   close all
   jRestEnv()
endif
return .t.
//----------------------
static function sumCM( cPath )

local nBal := 0.00
use
use (cPath+'\NEWD') index (cPath+'\SUBDAT') SHARED READONLY
seek 1
do while pagecode == 1 .and. ( !eof() )                     // Cash
   nBal += debit - credit
   skip
enddo
use
return nBal
//---------------------
static function sumEA( cPath )

local nBal := 0.00
use
use (cPath+'\CASHBOOK')
do while !eof()
   if action = 'C'
      nBal += amount
   else
      nBal -= amount
   endif
   skip
enddo
use
return nBal
//-----------------------
static function prn_cash( aCash )

local x
local nD := 0.00
local nC := 0.00
if prncheck()
   set device to printer
   set printer on
   @ 00, 02 say padc( 'CASH BALANCE SUMMARY', 54 )         
   @ 01, 06 say "Cash Account"                             
   @ 01, 35 say "Debit"                                    
   @ 01, 45 say "Credit"                                   
   for x := 1 to len( aCash )
      @ 01 + x, 06 say aCash[ x, 1 ]         
      if aCash[ x, 2 ] > 0
         @ 01 + x, 32 say str( aCash[ x, 2 ], 8, 0 )         
      elseif aCash[ x, 2 ] < 0
         @ 01 + x, 42 say str( abs( aCash[ x, 2 ] ), 8, 0 )         
      endif
      if aCash[ x, 2 ] > 0
         nD += abs( aCash[ x, 2 ] )
      else
         nC += abs( aCash[ x, 2 ] )
      endif
   next x
   @ 01 + x, 32 say repli( '-', 8 )              
   @ 01 + x, 42 say repli( '-', 8 )              
   @ 02 + x, 32 say str( nD, 8, 0 )              
   @ 02 + x, 42 say str( nC, 8, 0 )              
   @ 03 + x, 32 say str( nD - nC, 8, 0 )         
   @  7 + x, 00 say " "                          
   set device to screen
   set printer off
   set printer to
endif
return .t.
//-----------------------------
function intg_date

int_lDate()
int_NotClosed()
return .t.
//------------------------------
static function int_NotClosed

local aNotClosed := {}
local dCDate,dSDate
local x
local aFinal     := {}
local cTemp      := jTempFile( 'TMP', 'DBF' )

jSaveenv()
setcolor( scrcolor() )
@ 05, 12 say padc( "Integrity Verification - Books not closed", 49 )         
dbcreate( CTEMP, { { 'DATE', 'D', 10, 0 } } )
euse( "bookstat" )
set index to BSTAT_1
dele all for empty( date )
pack
use
euse( "Bookstat" )
index on DATE to BSTAT_1
go top
dSDate := _jAcStartDate()
do while date < dSDate
  skip
enddo

use (cTemp) new
sele bookstat
dcDate := date + 1
if !closed
  sele (cTemp)
  append blank
  field->date := date
  sele bookstat
endif
skip
do while .not. eof()
   if ( dcDate != date ) .or. ( !closed )
      sele ( cTemp )
      append blank
      field->date := dcDate
      sele bookstat
      if dcDate = date
         skip
      endif
   else
      skip
   endif
   dcDate ++
enddo
close all
use (cTemp) new
do while .not. eof()
  aadd( aFinal, dtoc(date)+", "+cdow(date)+" "+cmonth(date)+" "+str(year(date),4,0) )
  skip
enddo
close all
use bookstat index BSTAT_1
go bott
aadd( aFinal, 'Last date in entry register:' + dtoc( date ) + ' ' + iif( closed, 'Closed', 'NOT CLOSED' ) )
close all
ferase( cTemp + ".DBF" )
aPick( 06, 12, 17, 60, aFinal, boxColor(), boxColor(), boxColor() )
if jAlert( 'Take a Print Out ?', { '[ No ]', '[ Yes ]' } ) == 2
   set printer to INTLIST.TXT
   set device to printer
   set printer on
   set console off
   ?
   ? upper( comp_add )
   ? '---------- Integrity Verification'
   ? '================================='
   ? '       Dates not closed.         '
   ? '================================='
   for x := 1 to len( aFinal )
      ? aFinal[ x ]
   next x
   ?
   ?
   set console on
   set printer off
   set printer to
   set device to screen
   fileread( 1, 0, 23, 79, 'INTLIST.txt', 'Integrity Verification - Dates not closed' )
   ferase( 'INTLIST.TXT' )
endif
close all
jRestEnv()
return .t.
//=================================

static function int_lDate

jSaveenv()
makebox( 06, 12, 17, 60, boxcolor() )
setcolor( scrcolor() )
@ 05, 12 say padc( "Manual Integrity Verification (Date)", 60 - 12 )         
setcolor( boxcolor() )

if ReqInv()
   use saccount index SAC_2
   go bott
   @ 08, 20 say 'Sales'         
   @ 08, 45 say date            

   use paccount index PAC_2
   go bott
   @ 09, 20 say 'Purchase'         
   @ 09, 45 say date               

endif

use cashbook index CSH_2
go bott
@ 11, 20 say 'Cashbook'         
@ 11, 45 say date               

use daybook index DBK_2
go bott
@ 12, 20 say 'Daybook'         
@ 12, 45 say date              

use bankbook index BNK_2
go bott
@ 13, 20 say 'Bankbook'         
@ 13, 45 say date               

setcolor( invrt_clr( boxcolor() ) )
@ 15, 28 say "Press a key..."         
setcolor( boxcolor() )
close all
inkey( 0 )
jRestEnv()
return .t.
//=================================
function UserLevel( lSup )

local x
if user() != 'SUP'
   set key K_ALT_M to
endif
if user() == 'SUP' .or. user() == 'NIS' .or. user() == 'MAN'
   x := menu_v( 'Sales Reports :', 'Detailed System Sales', 'Detailed Spares List' )
   if x = 0 .or. x = NIL
      return .f.
   elseif x = 1
      sup_sales( 'SYSTEM' )
   elseif x = 2
      sup_sales( 'SPARES' )
   endif
   //else
   //   sup_sales( 'SYSTEM' )
else
   jAlert( 'Function Capability not available!' )
endif
if user() != 'SUP'
   set key K_ALT_M to UserLevel()
endif
return .t.
//----------------------
static function writeBals

local nD      := 0.00
local nC      := 0.00
local nDTotal := 0.00, nTemp1, nTemp2
close all
eUse( "acbals" )
zap
eUse( "accounts" )
set index to ACC_1
replace all balance with 0.00
go top
ShowPBar( 'Writing balances...' )
use cashbook new index CSH_1,CSH_2,CSH_3,CSH_4,CSH_5
set order to 5
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5
set order to 4
use bankbook new index BNK_1,BNK_2,BNK_3,BNK_5,BNK_6

sele accounts
go top
nDTotal := 0.00
do while .not. eof()
 // do not include INCOME and EXPENSE account bal. while carrying forward..
 if upper(alltrim(type)) != 'INCOME' .and. upper(alltrim(type)) != 'EXPENSE'
   nD := opbal      // that may be negative if is in the credit column.
   nC := 0.00       // so, same THING, same EFFECT, same WOrds...!

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

   select bankbook
   set order to 4
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

   select bankbook
   set order to 5
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

      if accounts->id == 1              // Cash Account
         select cashbook
         go top
         sum all amount to nTemp1 for action = 'D'          // Expense
         go top
         sum all amount to nTemp2 for action = 'C'          // Income
         nD += nTemp2
         nC += nTemp1
      endif


   if nD - nC != 0
      sele acbals
      appe blank
      field->id      := accounts->id
      field->account := accounts->account
      field->balance := nD - nC
   endif

   sele accounts
   field->balance := nD - nC
 endif

 sele accounts
 skip
 IncrPBar()
enddo
close all
HidePBar()
return nil
//==========
static function yrClose

local xx   := space( 15 )
local cDir := space( 8 )
jSaveEnv()
/*
jAlert( 'Note: This year end should be applied for a company, say ;' + ;
        'PULLIMAN after :;' + ;
        '   i) Renaming PULLIMAN PLL02-03  (or whatever the year);' + ;
        '  ii) MD PULLIMAN                           ;' + ;
        'iii) XCopy PLL02-03\*.* PULLIMAN /E         ;' + ;
        ';Then give the input for COMPANY DIRECTORY to be closed;' + ;
        'as PULLIMAN in the next input dialog. This will update ;' + ;
        'the op. bal in PULLIMAN with the closing balances and  ;' + ;
        'erases all sales, purchase, daybook, cashbook etc.etc.' )
*/

jAlert('Note: The EOY procedure is done by:                                  ;;'+;
       '    i) Finds the closing stock and account bal. for this company.    ;'+;
       '   ii) The closing stock value and each account bal. is saved to disk;'+;
       '  iii) All the closing bal. in the accounts file is cleared.         ;'+;
       '   iv) All the begin,rcvd,sold,bal stock counter are cleared.        ;'+;
       '    v) Daybook is cleared. Sales and Purchase are also cleared.      ;'+;
       '   vi) The closing stock value and each account bal. is written      ;'+;
       '       to the accounts and master file from the data in step (ii)    ;;'+;
       '   ie. the EOY operates on the current company itself and the        ;'+;
       "     software does not make backup of the previous years' data.      ;"+;
       '     The user has to create a seperate catalog of companies for the  ;'+;
       "     previous years' data and should copy the data to that catalog.  ;")
/*
popread( .f., 'Company Directory to be Closed : ', @cDir, "XXXXXXXXX" )
cDir := rtrim( ltrim( cDir ) )
if empty( cDir )
   msg( "Empty Directory!" )
   return .f.
endif
*/
cDir := eaCompDir
popread( .t., "Year End Closing ["+alltrim(cDir)+"] : Type 'YES' to Continue", @xx, "XXX" )
if rtrim( ltrim( xx ) ) == "YES"
   plswait( .t., 'Writing balances...' )
   set default to ( dir() + '\' + cDir )
   gwchDir( dir() + '\' + cDir )
   close all
   OpenDir()
   WriteBals()
   plswait( .t., 'Carrying down opening balances...' )
   eUse( "ACCOUNTS" )
   replace all opbal with balance
   plswait( .t., 'Processing Cashbook...' )
   eUse( "CASHBOOK" )
   zap
   plswait( .t., 'Processing Daybook...' )
   eUse( "DAYBOOK" )
   zap
   plswait( .t., 'Processing Banks...' )
   eUse( "BANKBOOK" )
   zap
   if file( 'SALES.DBF' ) .and. file( 'SACCOUNT.DBF' ) .and. file( 'PURCHASE.DBF' )
      plswait( .t., 'Closing sales...' )
      eUse( "SALES" )
      zap
      eUse( "SACCOUNT" )
      zap
      plswait( .t., 'Closing purchases...' )
      eUse( "PURCHASE" )
      zap
      eUse( "PACCOUNT" )
      zap

      plswait(.t., 'Clearing master file...')
      eUse("master")
      replace all begin with bal,opcost with cost, rcvd with 0,sold with 0   // All others will be reset in INDEXFILES
      delete all for bal == 0
      pack
      use

      plswait(.t., 'Clearing batches...')
      eUse("batches")
      delete all for (begin+rcvd-sold == 0)
      replace all begin with ( begin + rcvd - sold ), rcvd with 0, sold with 0
      pack

      // there is no bal. field in BATCHES, it is calculated using this formula..


   endif

   indexfiles()
   close all

   FT_XBOX(,,,, msgcolor(), msgcolor(),, '*** YEAR END PROCESS ***', 'Accounts closed...!' )
   tone( 2991, 1 )
   tone( 4561, 1 )
   tone( 320, 1 )
   tone( 452, 2 )
   tone( 922, 3 )
   tone( 6591, 1 )
   tone( 2120, 3 )
   inkey( 0 )
   jRestEnv()
else
   msg( "Year end aborted..!" )
endif
close all
return .t.
//===========================================================

*+ EOF: USERS.PRG
