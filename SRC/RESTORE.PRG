#include "box.ch"
local nKey,cPath, nRow
local nMyWin, nDosWin,lWait := .t., lErase := .f.

parameter cCatalog

if cCatalog == NIL .or. empty(cCatalog)
   cCatalog := space(8)
endif

clear
@ 0,0 say 'EasyAccounts v3.0  - Restore from Floppy'
@ 1,0 say '(Console Version)    ** by Jasim A Basheer'

if empty(alltrim(cCatalog))
   @ 3,0 say 'Catalog Directory :' get cCatalog pict '@!'
   read
   cCatalog := upper(alltrim(cCatalog))
   @ 3,0 say 'Catalog Directory : ' + cCatalog + "               "
else
   cCatalog := alltrim(cCatalog)
   @ 3,0 say 'Catalog Directory : ' + cCatalog + "               "
endif

if empty(cCatalog)
  @ 5,0 say 'Invalid catalog.'
  QuitProg()
endif

if ascan(directory(cCatalog,"D"),{|aVal| aVal[5]=='D'}) == 0
   if ! file( FT_Default()+':\EA\'+cCatalog+'\RESTORE.EA')
     @ 5,0 say 'Catalog does not permit restore.'
     QuitProg()
   endif
elseif a
endif
if ! file('A:\BACKUP.LOG')
  @ 5,0 say 'EasyAccounts backup floppy not in drive A'
  QuitProg()
endif

cPath := FT_Default()+":\EA\"+alltrim(cCatalog)+"\"

@ 5, 0 say 'Please make sure you have read A:\BACKUP.LOG to verify'
@ 6, 0 say 'the usability of the data which you are going to restore.'
@ 8, 0 say 'The data from the floppy will be restored to : '
@ 9, 0 say '  '+upper(cPath)
@11, 0 say "Press the '*' key to continue. Any other key to exit"

nKey := chr(inkey(0))
if ! nKey=='*'
  @10,0 say 'Restore aborted.'
  QuitProg()
endif
WBOARD()
nDosWin := WOPEN( 17,0,24,79 )
nMyWin := WOPEN( 10,0, 16, 79 )
WSELECT(nMyWin)
WBOX( B_DOUBLE_SINGLE )
@ 0,0 say 'Copying files...'
@ 1,0 say 'SYSTEM.EA'
COPY FILE ("A:\INF\BACKUP.SYS") to (FT_Default()+":\EA\"+cCatalog+"\SYSTEM.EA")
cPath := FT_Default()+":\EA\"+alltrim(cCatalog)+"\"
use (cPath+"SYSTEM.EA") new
dele all for (! backup)  // We've configured some for backup, while some not.
pack
go top
WSELECT(nDosWin)
WBOX( B_SINGLE_DOUBLE )
do while .not. eof()
 IF ! (UPPER(SUBS(COMP,1,6)) = 'SYSTEM')
   WSELECT(nMyWin)
   ? ALLTRIM(DIR)+"\*.*"
   WSELECT(nDosWin)

   run ("del "+ALLTRIM(cPath)+ALLTRIM(DIR)+"\*.NTX" )
   run ("del "+ALLTRIM(cPath)+ALLTRIM(DIR)+"\*.CDX" )
   run ("del "+ALLTRIM(cPath)+ALLTRIM(DIR)+"\*.DBF" )
   run ("del "+ALLTRIM(cPath)+ALLTRIM(DIR)+"\*.FPT" )

   // run ("pkunzip "+ "a:\DATA\"+subs(DIR,1,7)+" "+cPath+ALLTRIM(DIR)+" -sFLOPPYDRIVE -d")
   // Change later. the J prefix has been removed in the backup here.
   // Exe needs to be copied to WSS.
   //   11-07-04 JAS
   run ("pkunzip "+ "a:\DATA\J"+subs(DIR,1,7)+" "+cPath+ALLTRIM(DIR)+" -sFLOPPYDRIVE -d")
   

  // subs(1,8) ==> dir length only till 8.
  // ** CHANCE OF BUG ** CLEAR LATER **
  // If the directories are identical till the last seven characters,
  // the backup may copy only one directory. because,
  // in j12345678 and j12345679, only the j1234567 are taken as they
  // fall in the 8 letter directory limit of DOS (visibly, CA-Clipper 5.2)
  //
 ENDIF
 skip
enddo
use (cPath+"SYSTEM.EA")
appe blank
replace company with 'SYSTEM_0'
replace comp with company
appe blank
replace company with 'SYSTEM_1'
replace comp with company
appe blank
replace company with 'SYSTEM_2'
replace comp with company
appe blank
replace company with 'SYSTEM_3'
replace comp with company
use
WCLOSE(nDosWin)
WCLOSE(nMyWin)
?
? 'EasyAccounts Restore completed...!'
?
?
close all
quit
//------------------------------        
static function QuitProg
@ row()+2,0 say ""
quit
return .t.
