#include "inkey.ch"
//------------
// DirectGo
// Test App
//-----------
clear
setblink(.f.)
setcolor("W+/N*,GR+/W+")
jInitRep()
use TEST
do while (!eof() .and. (lastkey() <> K_ESC) )
  do while (!eof())
     jAddData( 0, "0123456789" )
     jAddData(30, alltrim(BIGSTRING) )
     jNextLine()
     skip
     if ! jGoReport(inkey())
        clear
        @ 2,0 say "ESC aborted"
        exit
     endif
  enddo 
enddo
if lastkey() != K_ESC
   jEndReport()
endif
return .t.
