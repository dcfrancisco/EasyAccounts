#include "std.ch"
#include "ghost.ch"

static print := .t.
static line
static dDate

static nOpCash := 0.00

function daysheet

local xx

if initall( @xx )   // get date set file plswait and such...

   dateday()

   listbank()
   listcash()

   if file( 'ONQ.CMP' ) .or. file( 'QDAY.DAY' )             // This file is present only on Jerome Nag., System.

      listQday()
      listQps()
      sayQremarks()

      // list... to come.
      // Sepearate funtions. because can change its order when and where
      // i like it.
   else

      listDay()
      listPS()      // Purchase/Sales
      sayRemarks()

   endif

   // Display the memo field REMARKS from BOOKSTAT if any..

   signedby()

   unbox( xx )

   goodbye()        // if cant understand from the name, then you are not
   // eligible to sit in this hot hot cold seat.
else
   unbox( xx )
   close all
   return .f.
endif
return .t.

static function initall( xx )

local xxb
close all
line  := 0
dDate := entr_date()
setcolor( scrcolor() )
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
      @ 15, ( 79 / 2 - 12 ) say padc( "BOOKS OPEN", 25 )         
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
if !print
   set printer to (RepPath+'DAYSHEET.TXT')
else
   if !prncheck()
      close all
      return .f.
   endif
endif
set printer on

use accounts new index ACC_1,ACC_2
use cashbook new index CSH_1,CSH_2,CSH_3
set order to 2
niToT   := 0.00
nETot   := 0.00
nOpCash := 0.00     // It is a static variable. Therefore initialize it everytime.

/*
do while ! eof()
   if date > dDate .or. date = dDate
      exit
   endif
   if action='C'
      nOpCash += amount
   elseif action='D'
      nOpCash -= amount
   endif
   skip
enddo
*/

sum all iif( action = 'C', amount, amount * - 1 ) to nOpCash while date < dDate

sele accounts
set order to 1
seek 1              // Cash a/c

nOpCash += opbal

sele cashbook
set filter to ( date == dDate .and. !deleted() )
go top              // NO Need, we have reached the record.

use bankbook new index BNK_1,BNK_2,BNK_3
set order to 3
set filter to ( date == dDate .and. !deleted() )
go top
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
set order to 3
set filter to ( date == dDate .and. !deleted() )
go top
use saccount new index SAC_1,SAC_2,SAC_3
set order to 2
set filter to ( date == dDate .and. !deleted() )
go top
use paccount new index PAC_1,PAC_2,PAC_3
set order to 2
set filter to ( date == dDate .and. !deleted() )
go top
return .t.

static function dateday

if !comp_add = 'Administration'
   @ line, 01 say dtoc( dDate ) + '  ' + cdow( dDate ) + '  ' + gPrefix + iif( !empty( gPrefix ), ', ', '' ) + comp_add         
   if print
      @ line, 01 say dtoc( dDate ) + '  ' + cdow( dDate ) + '  ' + gPrefix + iif( !empty( gPrefix ), ', ', '' ) + ', ' + comp_add         
   endif
else
   @ line, 01 say dtoc( dDate ) + '  ' + cdow( dDate ) + ' ' + comp_add         
   if print
      @ line, 01 say dtoc( dDate ) + '  ' + cdow( dDate ) + ' ' + comp_add         
   endif
endif

if !ac_closed( dDate )
   @ line, 40 say expand( 'ACCOUNTS NOT CLOSED' )         
endif
line ++
return .t.

static function listbank

local lDisplay := .f.
sele bankbook
do while .not. eof()
   if !lDisplay
      line ++
      @ line,  1 say "BANK TRANSACTIONS"         
      if print
         @ line,  1 say "BANK TRANSACTIONS"         
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

   @ line,  1 say subs( b_acname(), 1, 20 )                
   @ line, 22 say subs( findid(), 1, 14 )                  
   @ line, 37 say proper( subs( details, 1, 15 ) )         
   @ line, 53 say iif( action = 'D', 'WD', 'DEP' )         
   @ line, 58 say str( amount, 9, 2 )                      
   line ++
   skip
enddo
sele cashbook
do while .not. eof()
   if type = 'Deposit'
      if !lDisplay
         line ++
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
      @ line, 58 say str( amount, 9, 2 )                      
      line ++
   elseif type = 'Withdrawal'
      if !lDisplay
         line ++
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
      @ line, 58 say str( amount, 9, 2 )                      
      line ++
   endif
   skip
enddo
go top
line ++
return .t.

static function listcash

local nITot   := 0.00
local nETot   := 0.00
local nSales  := 0.00
local cString
@ line,  1 say "CASH BOOK"         
if print
   @ line,  1 say "CASH BOOK"         
endif
line ++
@ line,  1 say "Transaction"         
@ line, 51 say "Income"              
@ line, 60 say "Expense"             
line ++
// LENGTH - 66
sele cashbook
go top

/*/ -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
NOT DISPLAYING OP. CASH BALANCE
EVEN if IT IS COUNTED UP.
BECUZ THEY DOESNT RETAIN THE AMOUNT IN THEIR CASHBOOK OR DAILYSHEET
EACH DAY. THE MONEY IS SENT EVERYDAY HOME ALONGWITH THE DAILY SHEET...

That( Look up ) is OLD STORY. Now each day, the Cash Bal. is deposited to
Bank. .
., ( ie, therefore ), I count cash bal every day now.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- - */
if !file( 'ONQ.CMP' )
   if nOpCash != 0
      @ line,  1 say 'Op. Cash Balance B/D'         
      @ line, 48 say str( nOpCash, 09, 2 )          
      nITot += nOpCash
      line ++
   endif
endif

do while .not. eof()
   if !( rtrim( ltrim( type ) ) = 'Sales' .and. auto )
      cString := ( proper( subs( rtrim( ltrim( c_acname() ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ;
                   ' - ' + rtrim( ltrim( details ) ), '' ), 1, 46 ) ) )

      @ line,  1 say cString         

      @ line, 48 say c_income()          
      @ line, 58 say c_expense()         
      sele cashbook
      if action = 'C'
         nITot += amount
      else
         nETot += amount
      endif
      line ++
   else
      nSales += amount
   endif
   skip
enddo

if nSales > 0
   @ line,  1 say "Sales"                     
   @ line, 48 say str( nSales, 9, 2 )         
   nITot += nSales
   line ++
endif

@ line, 48 say repli( '-', 9 )         
@ line, 58 say repli( '-', 9 )         
line ++
@ line, 48 say str( nITot, 9, 2 )         
@ line, 58 say str( nETot, 9, 2 )         
if print
   @ line, 68 say "Bal.:" + rtrim( ltrim( str( nITot - nETot, 12, 0 ) ) )         
else
   line ++
   @ line, 29 say 'Balance :'                         
   @ line, 47 say str( nITot - nETot, 10, 2 )         
endif
line ++

if file( 'ONQ.CMP' )
   if nOpCash != 0
      line ++
      @ line,  1 say 'Op.Cash : ' + rtrim( ltrim( str( nOpCash, 09, 2 ) ) )                           
      @ line, 25 say 'Total Bal.: ' + rtrim( ltrim( str( nOpCash + nITot - nETot, 10, 2 ) ) )         
      line ++
      line ++
   endif
endif

return .t.

static function signedby

line ++
line ++
line ++
line ++
if print
   @ line,  0 say "            Prepared by            Verified by" + ;         
           "            Accountant             Manager"
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
if !lDisplay
   @ line,  1 say replicate( '-', 96 )         
   line ++
endif
return .t.
//----------------------------------------------
static function listDay

local lDisplay := .t.
local nNo      := 1
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
      @ line,  1 say 'Srl'                  
      @ line,  5 say "A/C Name"             
      @ line, 61 say "Debit" // 60          
      @ line, 73 say "Credit" // 72         
      line ++
      // LENGTH - 82
      lDisplay := .f.
   endif
   if rtrim( ltrim( daybook->type ) ) == 'Daybook'
      sele accounts
      seek daybook->account
      @ line,  1 say str( nNo, 3, 0 ) + ' By ' + subs( rtrim( ltrim( account ) ), 1, 52 )         
      @ line, 60 say str( daybook->amount, 8, 2 )                                                 
      line ++
      sele daybook
      skip
      sele accounts
      seek daybook->account
      @ line,  1 say space( 3 ) + '   To ' + subs( rtrim( ltrim( account ) ), 1, 52 )         
      @ line, 72 say str( daybook->amount, 8, 2 )                                             
      line ++
      @ line,  5 say '(' + proper( rtrim( ltrim( daybook->details ) ) ) + ')'         
      line ++
      line ++       // Leave ONE BLANK line in between
      nNo ++
   endif
   sele daybook
   skip
enddo
line ++
return .t.
//----------------------------
static function listQDay

local lDisplay := .t.
local nNo      := 1
sele accounts
set order to 1
go top
sele daybook
go top
do while .not. eof()
   if rtrim( ltrim( daybook->type ) ) == 'Daybook'
      if lDisplay
         @ line,  1 say "DAYBOOK"         
         if print
            @ line,  1 say "DAYBOOK"         
         endif
         line ++
         @ line,  1 say 'Srl'              
         @ line,  5 say "A/C Name"         
         @ line, 40 say "Debit"            
         @ line, 51 say " Credit"          
         line ++
         // LENGTH - 82
         lDisplay := .f.
      endif
      sele accounts
      seek daybook->account
      @ line,  1 say str( nNo, 3, 0 ) + ' By ' + subs( rtrim( ltrim( account ) ), 1, 31 )         
      @ line, 40 say str( daybook->amount, 9, 2 )                                                 
      line ++
      sele daybook
      skip
      sele accounts
      seek daybook->account
      @ line,  1 say space( 3 ) + '   To ' + subs( rtrim( ltrim( account ) ), 1, 30 )         
      @ line, 51 say str( daybook->amount, 9, 2 )                                             
      line ++
      @ line,  5 say '(' + proper( rtrim( ltrim( daybook->details ) ) ) + ')'         
      line ++
      line ++       // Leave ONE BLANK line in between
      nNo ++
   endif
   sele daybook
   skip
enddo
line ++
return .t.

static function listqPS

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
   if lDisplay .and. ( rtrim( ltrim( type ) ) != 'Daybook' )
      @ line,  1 say "PURCHASE/SALES"         
      if print
         @ line,  1 say "PURCHASE/SALES"         
      endif
      line ++
      @ line,  1 say "Type"            
      @ line, 10 say "Bill"            
      @ line, 18 say "Party"           
      @ line, 52 say "Total"           
      @ line, 59 say "Paid"            
      @ line, 66 say "Balance"         
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
      @ line, 18 say subs( rtrim( ltrim( account ) ), 1, 30 )         
      select paccount
   elseif rtrim( ltrim( type ) ) = 'Sales'
      @ line,  1 say 'Sales'         
      sele saccount
      seek daybook->inv_id
      @ line, 10 say rtrim( ltrim( str( id, 5, 0 ) ) )         
      sele accounts
      seek saccount->customer
      @ line, 18 say subs( rtrim( ltrim( account ) ), 1, 30 )         
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
      @ line, 18 say subs( account, 1, 30 )         
      sele saccount
   endif
   if rtrim( ltrim( daybook->type ) ) == 'Purchase'
      @ line, 51 say str( total + billtax, 6, 0 )         
      @ line, 58 say noZero( str( paid, 6, 0 ) )          
      if total + billtax - paid != 0
         @ line, 65 say str( total + billtax - paid, 6, 0 ) + ' CR'         
      endif
   elseif rtrim( ltrim( daybook->type ) ) == 'Sales'
      @ line, 51 say str( total, 6, 0 )                  
      @ line, 58 say noZero( str( paid, 6, 0 ) )         
      if ( total - paid != 0 ) .and. ( discount != 0 )
         @ line, 65 say str( total - paid, 6, 0 ) + ' DR'         
      endif
      if discount != 0
         line ++
         @ line, 18 say "AMOUNT DISCOUNTED"                                  
         @ line, 51 say str( discount, 6, 0 )                                
         @ line, 65 say str( total - discount - paid, 6, 0 ) + ' DR'         
         line ++
      endif
   elseif rtrim( ltrim( daybook->type ) ) == 'Transfer' .or. rtrim( ltrim( daybook->type ) ) == 'Standby'
      @ line, 51 say str( daybook->amount, 6, 0 )         
   endif
   if ( rtrim( ltrim( daybook->type ) ) != 'Daybook' )
      line ++
   endif
   sele daybook
   skip
enddo
if !lDisplay
   @ line,  1 say replicate( '-', 74 )         
   line ++
endif
return .t.
//----------------------------------------------
static function sayremarks()

local nMLines := 0
local nCLine  := 0
close all
use bookstat new index BSTAT_1
seek dDate
if found()
   if !empty( subs( rtrim( ltrim( remarks ) ), 1, 62 ) )
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
      @ line,  1 say repli( '-', 96 )         
      line ++
   endif
endif
close all
return .t.
//------------------------------------------------
static function sayQremarks()

local nMLines := 0
local nCLine  := 0
close all
use bookstat new index BSTAT_1
seek dDate
if found()
   if !empty( subs( rtrim( ltrim( remarks ) ), 1, 62 ) )
      @ line,  1 say padc( 'REMARKS', 66 )         
      if print
         @ line,  1 say padc( 'REMARKS', 66 )         
      endif
      line ++
      nMLines := mlcount( remarks, 66 )
      for nCLine := 1 to nMLines
         @ line,  1 say subs( memoline( remarks, 66, nCLine ), 1, 66 )         
         line ++
      next
      @ line,  1 say repli( '-', 66 )         
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
   //if file('ONQ.CMP')
   FILEREAD( 1, 5, 23, 74, RepPath+"DAYSHEET.TXT", 'Daily Sheet',, .f. )
   //else
   // FILEREAD(1,5,23,74,"DAYSHEET.TXT",'Daily Sheet',,.f.)
   //endif
   erase DAYSHEET.TXT
endif
return .t.
//--------------------

*+ EOF: DAY1.PRG
