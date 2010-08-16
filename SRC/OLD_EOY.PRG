static function cpyOps

local cSource := space( 8 )
local cTarg   := space( 8 )
local cConf   := space( 10 )

//***********
// First writes the closing balances in the source directory.
// Copies it to the target directory\OPBALS.DBF
// In the target directory, opens OPBALS and writes the balances
// to the ACCOUNTS database as Op.Bal
//***********

popread( .t., 'Copy closings balances from : ', @cSource, '@!', ;
         'Write as Op.Balances to (dir.name) : ', @cTarg, '@!' )
cSource := rtrim( ltrim( cSource ) )
cTarg   := rtrim( ltrim( cTarg ) )
if file( dir() + '\' + cSource + '\accounts.dbf', dir() + '\' + cTarg + '\accounts.dbf' )
   popread( .f., "Type 'CARRY OPS' to confirm : ", @cConf, '@!' )
   cConf := rtrim( ltrim( upper( cConf ) ) )
   if cConf == 'CARRY OPS'
      doOpBF( cSource, cTarg )
   else
      msg( "Confirmation failed..!" )
   endif
else
   msg( 'Invalid directories..!' )
endif
return .f.
close all
return nil
//----------------------
static function doOpBF( cFDbf, cTDbf )

local nCount := 0
plswait( .t., 'Copying opening balances...' )
set default to ( dir() + '\' + cFDbf )
gwchDir( dir() + '\' + cFDbf )
writeBals()
copy file (dir()+'\'+cFDbf+'\acbals.dbf') to (dir()+'\'+cTDbf+'\opbals.dbf')
gwchDir( cTDbf )
set default to ( dir() + '\' + cTDbf )
close all
plswait( .t., 'Refreshing previous counters...' )
eUse( "ACCOUNTS" )
set index to ACC_1
replace all opbal with 0.00
go top
use opbals new
do while .not. eof()
   sele accounts
   seek opbals->id
   if found()
      field->opbal := opbals->balance
   else
      field->opbal := 0.00
      nCount ++
   endif
   sele opbals
   skip
enddo
plswait( .t., 'Recalling process history...' )
close all
gwchDir( dir() + '\' + jdDir() )
set default to ( dir() + '\' + jdDir() )
plswait( .f. )
tone( 2304, 1 )
tone( 5623, 2 )
jAlert( 'Opening balances carried from ' + cFDbf + ' to ' + cTDbf + " (" + rtrim( ltrim( str( nCount ) ) ) + ")" )
return .t.
//-------------------------------------------------------------
function BRJAConfrm

x := upper( chr( inkey( 0 ) ) )
y := upper( chr( inkey( 0 ) ) )
if x = 'B' .and. y = 'A'
   x := upper( chr( inkey( 0 ) ) )
   y := upper( chr( inkey( 0 ) ) )
   if x = 'S' .and. y = 'U'
      x := upper( chr( inkey( 0 ) ) )
      y := upper( chr( inkey( 0 ) ) )
      if x = 'R' .and. y = 'E'
         x := upper( chr( inkey( 0 ) ) )
         y := upper( chr( inkey( 0 ) ) )
         if x = 'J' .and. y = 'A'
            return .t.
         endif
      endif
   endif
endif
return .f.
//--------------------------------
static function eCollection             // Education.

local sD    := date()
local eD    := date()
local nPlSf := 0.00
local nPlHw := 0.00
local nKylm := 0.00
local nAdv  := 0.00
local line  := 0
popread( .f., 'Starting Date : ', @sD, '@D', ;
         'Ending Date   : ', @eD, '@D' )
plswait( .t., 'Summing up values, Pulliman...' )
use (NetDrive()+":\cManage\edu\pllsf\newd")
sum all debit to nPlSf1 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
sum all credit to nPlSf2 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
use (NetDrive()+":\cManage\edu\hw\newd")
sum all debit to nPlHw1 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
sum all credit to nPlHw2 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
plswait( .f. )
plswait( .t., 'Kayamkulam...' )
use (NetDrive()+":\cManage\edu\kylm\newd")
sum all debit to nKylm1 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
sum all credit to nKylm2 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
plswait( .t., 'Advocates Lane...' )
use (NetDrive()+":\cManage\edu\kply\newd")
sum all debit to nKply1 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
sum all credit to nKply2 for tran_date >= sD .and. tran_date <= eD .and. pagecode = 1
plswait( .f. )
close all
set device to printer
set printer on
set printer to E_CASH.TXT
@ line,  0 say padc( "Wintech Computers", 35 )         
line ++
@ line,  0 say padc( "Cash Flow between " + dtoc( sD ) + " and " + dtoc( eD ), 40 )         
line ++
line ++
@ line,  0 say "Branch"          
@ line, 24 say "Income"          
@ line, 34 say "Expense"         
line ++
@ line,  0 say "Pulliman (Software)"         
@ line, 20 say str( nPlSf1, 10, 2 )          
@ line, 30 say str( nPlSf2, 10, 2 )          
line ++
@ line,  0 say "Pulliman (Hardware)"         
@ line, 20 say str( nPlHw1, 10, 2 )          
@ line, 30 say str( nPlHw2, 10, 2 )          
line ++
@ line,  0 say "Adv. Lane"                  
@ line, 20 say str( nKply1, 10, 2 )         
@ line, 30 say str( nKply2, 10, 2 )         
line ++
@ line,  0 say "Kayamkulam"                 
@ line, 20 say str( nKylm1, 10, 2 )         
@ line, 30 say str( nKylm2, 10, 2 )         
line ++
@ line, 20 say repli( '-', 20 )         
line ++
@ line, 20 say str( nKylm1 + nKply1 + nPlHw1 + nPlSf1, 10, 2 )         
@ line, 30 say str( nKylm2 + nKply2 + nPlHw2 + nPlSf2, 10, 2 )         
line ++
@ line,  5 say "Balance : "                                                                                    
@ line, 20 say str( nKylm1 + nKply1 + nPlHw1 + nPlSf1 - ( nKylm2 + nKply2 + nPlHw2 + nPlSf2 ), 10, 2 )         
line ++
@ line,  1 say repli( '-', 60 )         
line ++
set device to screen
set printer off
set printer to
close all
fileread( 4, 4, 23, 66, 'E_CASH.TXT', 'Education Fee Collection Report' )
return nil
//====================
