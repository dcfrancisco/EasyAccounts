//===============
// DB PATCH 2
//
// To change the ADM. ID from 0 to -1 in all related databases.
//
//==============

===================
This program  is put here just as a template for future
SUBDIRECTORY patches. All other patch programs have been deleted from
the EA directory due to their destructive nature to online data (which has
already been patched.)

To refer to them, check out the REVS/SAFE directories..
===========================



local xx                                       
local x, y

// DO NOT DO ANYTHING.........
QUIT

cls
? "EA Patch2 - Cr/Ma - ACCOUNTS.DBF, CASHBOOK.DBF, DAYBOOK.DBF, BANKBOK.DBF"
?
? "Patch Desc : Update Administration ID from 0 to -1"
?
ALTD(.T.)
xx := directory("*.*","D")
for x := 1 to len(xx)
 if ( subs(alltrim( xx[x,1] ),1,1) != "." ) .and. ( at('D',upper(xx[x,5]) ) != 0 )
   ? "Dir: "+xx[x,1]
   run ("cd "+alltrim(xx[x,1]) )
   doPatch("ACCOUNTS")
   run ("cd..")
 endif
next x
close all
?
? 'EA Patch2 with subdirectory loop completed.'
?
? 'Press any key to return...'
? 
inkey(0)
?
?
?
return .t.
//========================================
static function doPatch(cFile)
if file(cFile+'.dbf')
  use accounts
  replace all id with -1 for id=0
  use cashbook
  replace all account with -1 for account=0
  use daybook
  replace all account with -1 for account=0
  use bankbook
  replace all account with -1 for account=0
  replace all b_id with -1 for account=0
else
  ?? "  - ACCOUNTS.DBF not present."
endif
return .t.

