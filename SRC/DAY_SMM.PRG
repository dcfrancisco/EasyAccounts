//----------------------
// DAILY SHEET
//----------------------

#include "ghost.ch"
#include "std.ch"

static print := .t.
static line  := 1

static nOpCash := 0.00
static nJTCash := 0.00
static nJCash  := 0.00
static nJOp    := 0.00

function daysmm

local xx
local oldx  := comp_add
local oldxx := curdir()

private dDate := date()
// Should be decalred private here since if it is declared static (as in the old prog.),
// the cmFilter - Comix's set filter to will take the value of the private variable
// which is actually the entry date. Here, we are entering another date than the
// entry date but that wont be considered..
//
// So make this dDate private to give it visibility over the other public dDate
// which is the entry date.

set printer to (RepPath+'DAYSHEET.TXT')
set printer on
@  0,  0 say ""         
set printer off
set printer to
nJCash  := 0.00
nJTCash := 0.00
nOPCash := 0.00
if initall( @xx )   // get date set file plswait and such...

   /* He first told to compress. Now changed his position..., I am helpless..
   if print
      ??chr(15)
   endif
   */

   @ line, 01 say 'Daily Sheet - ' + dtoc( dDate ) + '  ' + cdow( dDate )         

   GWChDir( dir() + '\pulliman' )
   set default to ( dir() + "\pulliman" )

   if !ac_closed( dDate )
      @ line, 45 say padc( expand( 'ACCOUNTS NOT CLOSED' ), 66 )         
   endif
   line ++

   GWChDir( dir() + '\pulliman' )
   set default to ( dir() + "\pulliman" )
   comp_add := 'Pulliman Jun.'
   smm_doit()
   @ line,  1 say repli( '-', 155 )         
   line ++

   /*
   set default to c:\ea\02\kollam
   comp_add := 'Kollam'
   smm_doit()
   @ line, 1 say repli('-',155)
   line++
   // Told to take the Kollam printouts seperate. Only the PLL and ADM print
   // should come togethor (One time, one thing, after sometime another reform..!)
   */

   /*
   set default to c:\ea\02\graphics
   comp_add := 'Graphics'
   smm_doit()
   */

   // Graphics should not come as
   // it should go alongwith Education.

   GWChDir( dir() + '\adm' )
   set default to ( dir() + "\adm" )
   gwchDir( NetDrive() + ":\EA\02\ADM" )
   comp_add := 'Administration'
   smm_doit()
   @ line,  1 say repli( '-', 155 )         
   line ++

   GWChDir( dir() + '\adv' )
   set default to ( dir() + "\adv" )
   gwchDir( NetDrive() + ":\EA\02\ADV" )
   comp_add := 'Advertising'
   smm_doit()

   GWChDir( dir() + '\servpll' )
   set default to ( dir() + "\servpll" )
   gwchDir( NetDrive() + ":\EA\02\servpll" )
   comp_add := 'Service, Pulliman'
   smm_doit()

   GWChDir( dir() + '\servkyl' )
   set default to ( dir() + "\servkyl" )
   gwchDir( NetDrive() + ":\EA\02\servkyl" )
   comp_add := 'Service, Kayamkulam'
   smm_doit()

   GWChDir( dir() + '\servqln' )
   set default to ( dir() + "\servqln" )
   gwchDir( NetDrive() + ":\EA\02\servqln" )
   comp_add := 'Service, Kollam'
   smm_doit()

   @ line,  1 say repli( '-', 155 )         
   line ++

   signedby()

   unbox( xx )

   comp_add := oldx

   goodbye()        // if cant understand from the name, then you are not
   // eligible to sit in this hot hot cold seat.

   set default to ( NetDrive() + ":\" + oldxx )
else
   unbox( xx )
   close all
   return .f.
endif
return .t.
//----------------------------------------------------------
function smm_doit( nDEA, nDD )

local nnn

if nDEA != nil
   line := nDEA
endif

if nDD != nil
   dDate := nDD
endif

countcash()
dateday()

listbank()
nnn := listcash()
listday()

if ReqInv(.T.)
   listps()
endif
if ReqServ(.t.)
   listServ()
endif

// list... to come.
// Sepearate funtions. because can change its order when and where
// i like it.

sayremarks()
// Display the memo field REMARKS from BOOKSTAT if any..
line ++

return { nnn[ 1 ], nnn[ 2 ], line }

static function initall( xx )

local xxb
close all
line := 0
setcolor( scrcolor() )

dDate := entr_date()

@ 09, ( 79 / 2 - 12 ) say padc( 'Daily Sheet', 25 )         
setcolor( boxcolor() )
xx := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
@ 12, ( 79 / 2 ) - 12 + 3 say "Date :" get dDate        
read
if dDate > date()
   close all
   return .f.
else
   if !ac_closed( dDate )
      setcolor( scrcolor() )
      @ 15, ( 79 / 2 - 12 ) say padc( 'BOOKS OPEN', 25 )         
      setcolor( boxcolor() )
   endif
   @ 12, ( 79 / 2 ) - 11 say space( 23 )            
   @ 11, ( 79 / 2 ) - 11 say '  PRINT TO ?'         
   @ 12, ( 79 / 2 ) - 11 + 5 prompt "Screen"
   @ 13, ( 79 / 2 ) - 11 + 5 prompt "Printer"
   menu to xxb
   if xxb = 0
      close all
      return .f.
   elseif xxb = 1
      print := .f.
   else
      print := .t.
   endif

   @ 11, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 13, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 12, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 12, ( 79 / 2 ) - 11 say padc( 'Printing report...', 22 )         
endif
set device to printer
set console off
set default to ( dir() )
GwChDir( dir() )
if !print
   set printer to (RepPath+'DAYSHEET.TXT') additive
else
   if !isprinter()
      close all
      return .f.
   endif
endif
set printer on
return .t.

static function countcash

if ReqServ()
   use service new index SRV_1,SRV_2,SRV_3
   set order to 1  // ID
endif

use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use cashbook new index CSH_1,CSH_2,CSH_3
set order to 2
go top
nOpCash := 0.00     // It is a static variable. Therefore initialize it everytime.
do while date < dDate .and. ( !eof() )
   if date > dDate .or. date = dDate
      exit
   endif
   if action = 'C'
      nOpCash += amount
   elseif action = 'D'
      nOpCash -= amount
   endif
   skip
enddo
set filter to ( date == dDate .and. !deleted() )

go top              // NO Need, we have reached the record.

use bankbook new index BNK_1,BNK_2,BNK_3
set order to 2
set filter to ( date == dDate .and. !deleted() )
go top
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
set order to 2
set filter to ( date == dDate .and. !deleted() )
go top
if ReqInv(.T.)
   use saccount new index SAC_1,SAC_2,SAC_3
   set order to 2
   set filter to ( date == dDate .and. !deleted() )
   go top
   use paccount new index PAC_1,PAC_2,PAC_3
   set order to 2
   set filter to ( date == dDate .and. !deleted() )
   go top
endif
return .t.

static function dateday

// NOT ENOUGH SPACE
if !comp_add = 'Administration'
   @ line, 01 say padr( comp_add, 66 )         
   if print
      @ line, 01 say padr( comp_add, 66 )         
   endif
else
   @ line, 01 say padr( comp_add, 66 )         
   if print
      @ line, 01 say padr( comp_add, 66 )         
   endif
endif
line ++
return .t.

static function listbank

local lDisplay := .f.
sele bankbook
do while .not. eof()
   if !lDisplay
      @ line,  1 say "BANK TRANSACTIONS"         
      line ++
      @ line,  1 say "Party"          
      @ line, 22 say "Bank"           
      @ line, 37 say "Cheque"         
      @ line, 53 say "Type"           
      @ line, 60 say "Amount"         
      line ++
      lDisplay := .t.
   endif

   @ line,  1 say subs( b_acname(), 1, 20 )                
   @ line, 22 say subs( findid(), 1, 14 )                  
   @ line, 37 say proper( subs( details, 1, 15 ) )         
   @ line, 53 say iif( action = 'D', 'WD', 'DEP' )         
   @ line, 60 say str( amount, 9, 2 )                      
   line ++
   skip
enddo
sele cashbook
do while .not. eof()
   if type = 'Deposit'
      if !lDisplay
         @ line,  1 say "Bank Transactions"         
         if print
            @ line,  1 say "Bank Transactions"         
         endif
         line ++
         @ line,  1 say "Party"          
         @ line, 22 say "Bank"           
         @ line, 37 say "Cheque"         
         @ line, 53 say "Type"           
         @ line, 60 say "Amount"         
         line ++
         @ line,  1 say replicate( '-', 66 )         
         line ++
         lDisplay := .t.
      endif
      @ line,  1 say "Deposit"                                
      @ line, 22 say subs( c_acname(), 1, 14 )                
      @ line, 37 say proper( subs( details, 1, 15 ) )         
      @ line, 53 say 'DEP'                                    
      @ line, 60 say str( amount, 9, 2 )                      
      line ++
   elseif type = 'Withdrawal'
      if !lDisplay
         @ line,  1 say "Bank Transactions"         
         if print
            @ line,  1 say "Bank Transactions"         
         endif
         line ++
         @ line,  1 say "Party"          
         @ line, 22 say "Bank"           
         @ line, 37 say "Cheque"         
         @ line, 53 say "Type"           
         @ line, 60 say "Amount"         
         line ++
         @ line,  1 say replicate( '-', 66 )         
         line ++
         lDisplay := .t.
      endif
      @ line,  1 say "Withdrawal"                             
      @ line, 22 say subs( c_acname(), 1, 14 )                
      @ line, 37 say proper( subs( details, 1, 15 ) )         
      @ line, 53 say 'WD'                                     
      @ line, 60 say str( amount, 9, 2 )                      
      line ++
   endif
   skip
enddo
go top
if lDisplay
   line ++
endif
return .t.

static function listcash

local nITot    := 0.00
local nETot    := 0.00
local nSales   := 0.00
local cString
local lDisplay := .f.

sele cashbook
go top
if !eof()

   @ line,  1 say "Transaction"         
   @ line, 53 say "Income"              
   @ line, 67 say "Expense"             
   line ++

   /*/ -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   NOT DISPLAYING OP. CASH BALANCE
   EVEN if IT IS COUNTED UP.
   BECUZ THEY DOESNT RETAIN THE AMOUNT IN THEIR CASHBOOK OR DAILYSHEET
   EACH DAY. THE MONEY IS SENT EVERYDAY HOME ALONGWITH THE DAILY SHEET...

   That( Look up ) is OLD STORY. Now each day, the Cash Bal. is deposited to
   Bank. .
   ., ( ie, therefore ), I count cash bal every day now.
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- - */

   do while .not. eof()
      if !( rtrim( ltrim( type ) ) = 'Sales' .and. auto )
         cString := ( proper( subs( rtrim( ltrim( c_acname() ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ;
                      ' - ' + rtrim( ltrim( details ) ), '' ), 1, 46 ) ) )

         @ line,  1 say cString         

         @ line, 52 say c_income()          
         @ line, 67 say c_expense()         
         sele cashbook
         if action = 'C'
            nITot += amount
         else
            nETot += amount
         endif
         line ++
         if acc_sub != 0
            cString := alltrim(subs('['+alltrim(FindSubHead( cashbook->acc_sub )),1,24))+']'
            @ line, 1 say cString
            line++
         endif
      else
         nSales += amount
      endif
      skip
   enddo

   if nSales != 0
      @ line,  1 say "Sales"                     
      @ line, 52 say str( nSales, 9, 2 )         
      nITot += nSales
      line ++
   endif

   @ line, 52 say repli( '-', 9 )         
   @ line, 67 say repli( '-', 9 )         
   line ++
   if nOpCash != 0
      @ line,  2 say "Op.Bal:" + str( nOpCash, 10, 2 ) + "  Cl.Bal:" + str( nOpCash + ( nITot - nETot ), 10, 2 )         
   endif
   nJCash  += nOpCash + nITot - nETot
   nJTCash += nITot - nETot
   @ line, 52 say str( nITot, 9, 2 )         
   @ line, 67 say str( nETot, 9, 2 )         
   if print
      @ line, 80 say "Bal - " + rtrim( ltrim( str( nITot - nETot, 12, 2 ) ) )         
   else
      line ++
      @ line, 32 say 'Balance :'                         
      @ line, 52 say str( nITot - nETot, 10, 2 )         
   endif

else

   if nOpCash != 0
      @ line,  1 say 'Op. Cash Balance ( No Transactions )'         
      if nOpCash > 0
         @ line, 52 say str( nOpCash, 09, 2 )         
      else
         @ line, 67 say str( abs( nOpCash ), 09, 2 )         
      endif
      nJCash += nOpCash
      line ++
   endif

endif
line ++
return { nOpCash + nITot - nETot, nITot - nETot }

static function signedby

@ line, 01 say "T/Cash Bal.: " + rtrim( ltrim( str( nJCash, 11, 2 ) ) )          
@ line, 50 say "D/Cash Bal.: " + rtrim( ltrim( str( nJTCash, 11, 2 ) ) )         
if print
   @ line, 01 say "T/Cash Bal.: " + rtrim( ltrim( str( nJCash, 11, 2 ) ) )          
   @ line, 50 say "D/Cash Bal.: " + rtrim( ltrim( str( nJTCash, 11, 2 ) ) )         
endif
line ++
line ++
line ++
line ++
line ++
if print
   @ line,  0 say "            Prepared by            Verified by" + ;         
           "            Accountant             Manager"
   line ++
   line ++
   @ line,  1 say chr( 10 ) + chr( 10 ) + chr( 10 )         
else
   line ++
   line ++
   line ++
   @ line,  1 say " "         
endif
return .t.
//----------------------------------------------
static function listPS

local lDisplay := .t.
sele saccount
set order to 1
sele paccount
set order to 1
sele accounts
set order to 1
sele daybook
go top
do while .not. eof()
   if lDisplay
      @ line,  1 say "PURCHASE/SALES"         
      if print
         @ line,  1 say "PURCHASE/SALES"         
      endif
      line ++
      if print
         ?? chr( 15 )
      endif
      @ line,  1 say "Type"            
      @ line, 10 say "Bill"            
      @ line, 18 say "Party"           
      @ line, 72 say "Total"           
      @ line, 79 say "Paid"            
      @ line, 86 say "Balance"         
      line ++
      // LENGTH - 96
      lDisplay := .f.
   endif
   if rtrim( ltrim( type ) ) = 'Purchase'
      @ line,  1 say 'Purchase'         
      sele paccount
      seek daybook->inv_id
      @ line, 10 say subs( rtrim( ltrim( bill ) ), 1, 5 )         
      sele accounts
      seek paccount->supplier
      @ line, 18 say subs( rtrim( ltrim( account ) ), 1, 50 )         
      select paccount
   elseif rtrim( ltrim( type ) ) = 'Sales'
      @ line,  1 say 'Sales'         
      sele saccount
      seek daybook->inv_id
      @ line, 10 say rtrim( ltrim( str( id, 5, 0 ) ) )         
      sele accounts
      seek saccount->customer
      @ line, 18 say subs( rtrim( ltrim( account ) ), 1, 50 )         
      sele saccount
   elseif rtrim( ltrim( type ) ) = 'Transfer'
      @ line,  1 say rtrim( ltrim( details ) )         
      if daybook->action = 'D'
         sele saccount
         seek daybook->inv_id
         sele accounts
         seek saccount->customer
      else
         sele paccount
         seek daybook->inv_id
         sele accounts
         seek paccount->supplier
      endif
      @ line, 18 say subs( account, 1, 20 )         
      sele saccount
   elseif rtrim( ltrim( type ) ) = 'Standby'
      @ line,  1 say subs( rtrim( ltrim( details ) ), 1, 14 )         
      if daybook->action = 'D'
         sele saccount
         seek daybook->inv_id
         sele accounts
         seek saccount->customer
      else
         sele paccount
         seek daybook->inv_id
         sele accounts
         seek paccount->supplier
      endif
      @ line, 18 say subs( account, 1, 50 )         
      sele saccount
   endif
   if rtrim( ltrim( daybook->type ) ) == 'Purchase'
      @ line, 71 say str( total + billtax, 6, 0 )         
      @ line, 78 say noZero( str( paid, 6, 0 ) )          
      if total + billtax - paid != 0
         @ line, 85 say str( total + billtax - paid, 6, 0 ) + ' CR'         
      endif
   elseif rtrim( ltrim( daybook->type ) ) == 'Sales'

      @ line, 71 say str( total, 6, 0 )                  
      @ line, 78 say noZero( str( paid, 6, 0 ) )         

      if ( total - paid ) > 0 .and. discount = 0
         @ line, 85 say str( total - paid, 6, 0 ) + ' DR'         
      endif

      if discount != 0
         line ++
         @ line, 18 say "AMOUNT DISCOUNTED"                                  
         @ line, 78 say str( discount, 6, 0 )                                
         @ line, 85 say str( total - discount - paid, 6, 0 ) + ' DR'         
         line ++
      endif
   elseif rtrim( ltrim( daybook->type ) ) == 'Transfer' .or. rtrim( ltrim( daybook->type ) ) == 'Standby'
      @ line, 71 say str( daybook->amount, 6, 0 )         
   endif

   if ( rtrim( ltrim( daybook->type ) ) != 'Daybook' )
      line ++
   endif

   sele daybook
   skip
enddo

if lDisplay
   if comp_add != 'Administration' .and. comp_add != 'Graphics' .and. comp_add != 'Microsolutions' .and. comp_add != 'Advertisement'
      line ++
      @ line,  1 say padc( 'NO PURCHASE/SALES !', 66 )         
      line ++
   endif
endif
return .t.
//----------------------------------------------
static function listDay

local lDisplay := .t.
local nNo      := 1
local cNarr1   := ""
local cNarr2   := "", cSub1, cSub2
sele accounts
set order to 1
go top
sele daybook
go top
do while .not. eof()
   if lDisplay
      @ line,  1 say "DAYBOOK"         
      if print
         @ line,  1 say "DAYBOOK"         
      endif
      line ++
      if print
         ?? chr( 15 )
      endif
      @ line,  1 say 'Srl'                    
      @ line,  5 say " Dr."                   
      @ line, 48 say "Cr." // 60              
      @ line, 91 say "  Amount" // 72         
      line ++
      // LENGTH - 91
      lDisplay := .f.
   endif
   if rtrim( ltrim( daybook->type ) ) == 'Daybook'
      sele accounts
      seek daybook->account
      @ line,  0 say str( nNo, 3, 0 ) + "  " + padr( rtrim( ltrim( account ) ), 40 )         
      cNarr1 := '(' + subs( proper( rtrim( ltrim( daybook->details ) ) ), 1, 38 ) + ')'
      if daybook->acc_sub != 0
         cSub1 := alltrim(subs('['+alltrim(FindSubHead( daybook->acc_sub )),1,33))+']'
      else
         cSub1 := space(1)
      endif
      sele daybook
      skip
      sele accounts
      seek daybook->account
      @ line, 48 say padr( rtrim( ltrim( account ) ), 40 )         
      @ line, 91 say str( daybook->amount, 8, 2 )                  
      cNarr2 := '(' + subs( proper( rtrim( ltrim( daybook->details ) ) ), 1, 38 ) + ')'
      line ++
      if daybook->acc_sub != 0
         cSub2 := alltrim(subs('['+alltrim(FindSubHead( daybook->acc_sub )),1,33))+']'
      else
         cSub2 := space(1)
      endif

      if (! empty(cSub1)) .or. (!empty(cSub2))
         @ line,  5 say cSub1
         @ line, 48 say cSub2
         line ++
      endif

      @ line,  5 say cNarr1         
      @ line, 48 say cNarr2         
      line ++
      nNo ++
   endif
   sele daybook
   skip
enddo
if print
   ?? chr( 18 )
endif
line ++
return .t.
//----------------------------
static function ListServ

local lDisplay := .t.
local nNo      := 1
local cNarr1   := ""
sele accounts
set order to 1
go top
sele daybook
go top
do while .not. eof()
   if lDisplay
      @ line,  1 say "SERVICE"         
      if print
         @ line,  1 say "SERVICE"         
      endif
      line ++
      if print
         ?? chr( 15 )
      endif
      @ line, 02 say 'Type'
      @ line, 08 say 'Reported On'
      @ line, 22 say "Customer"
      @ line, 52 say "S/Engineer"
      @ line, 82 say "   Amount"
      line ++
      // LENGTH - 91
      lDisplay := .f.
   endif

   if rtrim( ltrim( daybook->type ) ) == 'Service'
      sele daybook
      if account == WARRANTY_AC
        cNarr1 := '   WA   '
      elseif account == AMC_AC
        cNarr1 := '   AMC  '
      elseif account == ASC_AC
        cNarr1 := '   ASC  '
      endif

      sele service
      seek daybook->inv_id
      cNarr1 := cNarr1+' '+dtoc(service->r_date)

      // Customer name
      sele subheads
      set order to 1
      seek daybook->acc_sub
      cNarr1 := cNarr1+"   "+subs(subheads->subhead,1,28)
      sele daybook
      skip

      // Service Engineer Name
      sele accounts
      seek daybook->account
      cNarr1 := cNarr1+"  "+subs(accounts->account,1,28)+"  "+str(daybook->amount,10,2)
      @ line,  0 say cNarr1

      line ++
      nNo ++
   endif
   sele daybook
   skip
enddo
if print
   ?? chr( 18 )
endif
line ++
return .t.
//--------------------------
static function sayremarks()

local nMLines := 0
local nCLine  := 0
close all
use bookstat new index BSTAT_1
seek dDate
if found()
   if !empty( subs( rtrim( ltrim( remarks ) ), 1, 62 ) )
      @ line,  1 say repli( '-', 66 )         
      line ++
      @ line,  1 say padc( 'REMARKS', 66 )         
      if print
         @ line,  1 say padc( 'REMARKS', 66 )         
      endif
      line ++
      nMLines := mlcount( remarks, 66 )
      for nCLine := 1 to nMLines
         @ line,  1 say memoline( remarks, 66, nCLine )         
         line ++
      next
      line ++
   endif
endif
close all
return .t.
//------------------------------------------------
static function goodbye

close all
set device to screen
set printer off
set printer to
set console on
if !print
   set default to ( dir() )
   GwChDir( dir() )
   FILEREAD( 1, 5, 23, 74, (RepPath+'DAYSHEET.TXT'), 'Daily Sheet',, .f. )
   erase DAYSHEET.TXT
   jSetDefault( Comp_add )
endif
return .t.

*+ EOF: DAY_SMM.PRG
