#include "std.ch"
#include "inkey.ch"
#xcommand SAYSTAT => saystat()
local nFile
local nQF
local aDirs := {}
local xx

//               {'ADV','ADM','GRAPHICS',;
//               'PULLIMAN','KOLLAM','MICROS'}

local i

parameter EaDir

setblink(.f.)

if EaDir==NIL
  EaDir := ""
endif

if empty(EaDir)
  EaDir := 'C:\EA\02\'
endif

EaDir := alltrim(EaDir)

if subs(EaDir,len(EaDir),1) != '\'
   EaDir := EaDir+'\'
endif

use (EaDir)+'SYSTEM.EA'
set filte to backup
go top

do while .not. eof()
   if subs( company, 1, 7 ) != 'SYSTEM_'
      aadd( aDirs, dir )
   endif
   skip
enddo
close all

saystat

@ 24, 25 say 'THIS WILL QUICK-FORMAT DRIVE A: CONTINUE ? '         
if opConfirm()

   @ 24, 25 say 'Checking Drive Status...                       '         

   CheckFloppy()    // It implements a good floppy presence check.

   //==========
   // Here Is Another Super DOS Technique.
   //    I had wasted long hours for finding a method to
   //    pass keyboard input to a dos command. But while desigining this
   //    prog., I fell into it.(not accidently,but desperately!)
   //
   // This RUN command will delete all files in the drive without
   // asking for input(ie., y/n) and without showing any reflection in the
   // screen whatsoever.
   //===========

   saystat

   @ 24, 25 say 'Quick-formatting Drive A:'         

   nQF := fcreate('C:\TEMP.EA')
   fwrite(nQF,chr(13)+chr(10)+'EA BACKUP'+chr(13)+chr(10)+'N'+chr(13)+chr(10)+'N'+chr(13)+chr(10)+'N')
   fclose(nQF)

   // This is a good technic of creating a Predefined file which has
   // all the responses to the FORMAT's question.
   // In the normal order, it will be an ENTER confirmation, disk label which is EA BACKUP,
   // then Quickformat another Y/N.
   // Even if there is an error for the floppy, the program has issued some more addtional Ns
   // to cope up with such unassummed queries. If it is not sufficient for
   // QuickFormat then there is a **HAZARD** of the current operation being
   // locked out (it can be quitted by Hitting CLOSE through windows. If DOS,
   // CTRL+ALT+DEL will suffice.) This is because it accepts only inputs passed
   // from the file referred as STDIN and will not care a SHIT about the keyboard.

   run( "FORMAT A: /Q /U < c:\temp.ea > c:\backup.log" )

   saystat

   @ 24, 25 say 'Organizing backup directories...               '         
   run( "MD A:\DATA > C:\BACKUP.LOG" )
   run( "MD A:\INF > C:\BACKUP.LOG" )

   CheckFloppy()    // It implements a good floppy presence check.

   @ 24, 25 say 'Creating system log...                         '         

   USE (EaDir+"system.ea")
   copy all to ('A:\INF\BACKUP.SYS') for BACKUP

   @ 24, 25 say 'Initializing Backup...                         '         

   if len( aDirs ) = 0
      alert('Error : No directories configured for backup...')
      close all
      set color to
      clear
      ?
      ? 'EA Backup aborted : No directories configured for backup..'
      ?
      ?
      quit
   endif

   for i := 1 to len( aDirs )
      gwChDir( EaDir + aDirs[ i ] )
      if !checkfloppy()
         abortexit()
      endif
      saystat
      @ 24, 25 say 'Backing Up Data - ' + aDirs[ i ] + '                              '         
      if i != len( aDirs )
         if len( aDirs ) - i = 1
            @ 24, 53 say " ³ 1 more company to go!                      "         
         else
            @ 24, 53 say " ³ " + rtrim( ltrim( str( len( aDirs ) - i ) ) ) + ' more companies to go!         '
         endif
      else
         @ 24, 53 say " ³ Finishing off...                                         "         
      endif
      run( "PKZIP a:\DATA\" + aDirs[ i ] + " c:*.DBF c:*.FPT c:COMP*.* c:*.SYS -SFLOPPYDRIVE > c:\backup.log" )
   next i
   saystat
   @ 24, 53 say " ³ Writing Backup Log...                       "         
   set date brit
   set centu on
   nFile := fcreate( 'A:\BACKUP.LOG' )
   fwrite( nFile, chr(13)+chr(10)+'============================================'+chr(13)+chr(10)+'EasyAccounts v4.1 Backup LOG' + chr( 13 ) + chr( 10 )  + ;
           'Backup On : ' + cdow( date() ) + ', ' + dtoc( date() ) + chr( 13 ) + chr( 10 ) + ;
           'Directory : ' + EaDir + chr(13)+chr(10)+;
           '============================================' + chr( 13 ) + chr( 10 ) )
   fclose( nFile )
   if file( "A:\INF\BACKUP.EA" )
      erase A:\INF\BACKUP.EA
   endif
   dbcreate( "A:\INF\BACKUP.EA", { { "FNAME", "C", 8, 0 }, { "Dir", "C", 8, 0 } } )
   use a:\INF\backup.ea
   for xx := 1 to len( aDirs )
      append blank
      field->FNAME := subs( rtrim( ltrim( "j" + aDirs[ xx ] ) ), 1, 8 )
      field->dir   := aDirs[ xx ]
   next xx
   close all
   @ 24, 53 say " ³ Labelling Floppy...                    "         
   run( "LABEL A: EA BACKUP" )
endif
close all
set colo to
clear
return .t.

static func saystat

dispbegin()
set color to W/N
clear
setcolor( 'N*/W*' )
@ 24,  0 say space( 79 )                        
@ 24,  0 say 'EA v3.0 Backup Module ³ '         
dispend()
return .t.

function CheckFloppy

fopen( 'A:\' )
if ferror() != 0
   saystat
   @ 24, 25 say "Drive not ready. Insert floppy or press ESC to abort."         
   do while inkey() != K_ESC
      fopen( 'A:\SOMETHING' )
      if ferror() = 2
         exit
      endif
   enddo
endif
if ferror() != 2
   abortexit()
endif
saystat
return .t.

function abortexit

close all
set color to W/N
clear
quit
return .t.

*+ EOF: BACKUP.PRG
