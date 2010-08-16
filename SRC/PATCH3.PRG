//===============
// DB PATCH (BillDate)
//
// To insert the BILL DATE (bdate) field in PACCOUNT.DBF
//    18-May-2004 Jasim
//
//==============

local xx                                       
local x, y

cls
? "EA Patch - Put BDATE - PACCOUNT.DBF"
?
? "Patch Desc : Put BDATE (Bill Date) field in PACCOUNT.DBF"
?
? "Warning: If you have already applied this patch and has filled in"
? "         the BILL DATE for purchase bills, applying this patch again"
? "         would destroy all the existing BILL DATE entries."
?
? "Press '*' to continue with the patch. Any other key to exit"
if inkey(0) != asc("*")
  ?
  ? '     Patch aborted..'
  quit
endif

xx := directory("*.*","D")
for x := 1 to len(xx)
 if ( subs(alltrim( xx[x,1] ),1,1) != "." ) .and. ( at('D',upper(xx[x,5]) ) != 0 )
   ? "Patching Dir: "+xx[x,1]
   run ("cd "+alltrim(xx[x,1]) )
   doPatch("PACCOUNT")
   run ("cd..")
 endif
next x
close all
?
? 'EA Patch with subdirectory loop completed.'
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
local aStru 
if file(cFile+'.dbf')
use (cFile)
copy stru extended to TMP1
use tmp1
dele all for alltrim(FIELD_NAME) == 'BDATE'
appe blank
replace FIELD_NAME with 'BDATE'
replace FIELD_LEN  with 10
replace FIELD_TYPE with 'D'
pack
use
create tmp2 from tmp1
use tmp2
appe from (cFile)
close all
ferase(cFile+'.DBF')
frename('tmp2.dbf',cFile+'.DBF')
ferase('TMP1.DBF')
ferase('TMP2.DBF')
else
  ?? "  - PACCOUNT.DBF not present."
endif
return .t.

