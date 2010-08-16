#include "std.ch"
#include "inkey.ch"
#include "ghost.ch"

static InstPath
static x        := 1
static y
static nD       := 1
static nC
static nJ
static nEnd
static cPath    := "C:\EA\02"
static cP       := "C:\EA"
static cCurPath
static cOD

function Setup

local cUP  := space( 10 )
local cUP1 := space( 10 )

public _bEasyKey     := {|| ;
     "1" + subs(bootNum(),2,3) + subs(bootNum(),6,7) + "EasyAccounts by Jasim" }

setcursor( 1 )
set score off
?
? repli( 'Í', 40 )
? padc( '** EasyAccounts v4.1 PRO **', 40 )
? padc( '   by jasim.ab@gmail.com   ', 40 )
?
? padc( '(C) Jasim A Basheer',40 )
? padc( 'All Rights Reserved.', 40 )
?
? padc( 'ş INSTALL ş', 40 )
? repli( 'Ä', 40 )
?
/*
if ! file('C:\WINDOWS\WIN.COM')
  ? 'Error: Windows 95 or above should be installed on C:\WINDOWS directory for'
  ? 'EasyAccounts to be setup properly.'
  ?
  ? 'Installation terminated.'
  quit
endif
*/
// No need for this. Security methodology changed.
// Thanks to the Win2k feedback from Ray (alich@..)

? '  Install EasyAccounts in C:\EA ? '
setcursor( 1 )
if opConfirm()
   setcursor( 1 )
   @ row(), col() - 1 say 'YES'         
   ?
   ?
   set cursor off
   setcursor( 0 )
   set colo to W/N,W/N,N/N,W/N
   do while .t.
      keyboard chr( K_INS )             // SET INSERT OFF, CURSOR INSERT OFF
      @ row(), 2 say 'Supervisor Password (max. 10 chars.) : ' get cUP PASSWORD        
      read
      cUP := rtrim( ltrim( upper( cUP ) ) )
      if empty( cUP )
         cUP := space( 10 )
         ?? chr( 7 )
         ?
         ? "  Cannot accept blank password!"
         ?
         ?
         loop
      endif
      exit
   enddo
   ?
   ?
   @ row(), 2 say 'Confirm Password                     : ' get cUP1 PASSWORD        
   read
   ?
   if !cUP == rtrim( ltrim( upper( cUP1 ) ) )
      ?
      ?
      ? '  Retyped password mismatches!'
      ?
      ? '  INSTALL Aborted.'
      ?
      quit
   else
      cUP := jEncrypt( padr(rtrim( ltrim( cUP ) ),10), "This is EasyAccounts PRO.. by Jasim"  )
      ?
      ?
      ? '  Installing, Please wait...'
   endif
else
   @ row(), col() - 1 say 'NO'         
   ?
   ?
   ? '  INSTALL Aborted!'
   ?
   quit
endif

cOD      := gwDrive()
cCurPath := curdir()
InstPath := cOD + ":\" + cCurPath + "\install.dat"
use (InstPath) new
ft_mkdir( "C:\EA" )
ft_mkdir( "C:\EA\02" )
ft_mkdir( "C:\EA\EASYS" )
ft_chDir( "C:\EA\EASYS" )
go top
nEnd := 0
do while .not. eof()
   nC := database
   do while nC == database .and. ( !eof() )
      skip
   enddo
   nEnd ++
enddo
go top

ShowPBar( "Creating databases...",, .T. )
SetPBarCount( nEnd )

for x := 1 to nEnd
   nC := install->database
   set filter to install->database = NC
   go bott
   nJ := recno() + 1
   go top
   copy all to INST.TMP
   create (nC) from INST.TMP
   close all
   use (InstPath) new
   go nJ
   if eof()
      skip - 1
   endif
   IncrPBar()
next x
HidePBar()

AppendSystem( cUP )
use ("C:\EA\EASYS\accounts")
append blank
field->id      := 1
field->account := "Cash"
field->type    := "Assets - Current"
append blank
field->id      := 2
field->account := "Misc. Expense"
field->type    := "Expense"
close all
*GWCOPYFILE("C:\EA\02\SYSTEM.INT","C:\EA\02\SYSTEM.DBF")
gwDrive( 'C' )
ft_chDir( 'C:\EA\02' )

dbcreate("C:\EA\02\LINKS.DBF", ;
 { ;
  { 'DIR',       'C',  8, 0 },;
  { 'COMP',      'C', 30, 0 },;
  { 'GLOBAL_ID', 'N',  6, 0 },;
  { 'ACCOUNT',   'N',  6, 0 },;
  { 'DESC',      'C', 40, 0 } ;
 } )


cls
?
?
? 'EasyAccounts v4.1 PRO Installation Successfully Completed!'
?
? "Press any key to view the author's note.."
?
inkey(0)
showauthor()
return .t.

static function AppendSystem( cPass )

local aSEa := { ;
                { "COMP", "C", 30, 0 }, ;
                { "COMPANY", "C", 30, 0 }, ;
                { "PREFIX", "C", 10, 0 }, ;
                { "HEAD", "C", 50, 0 }, ;
                { "ADD1", "C", 50, 0 }, ;
                { "ADD2", "C", 50, 0 }, ;
                { "ADD3", "C", 50, 0 }, ;
                { "OPEN", "L", 1, 0 }, ;
                { "DIR", "C", 8, 0 }, ;
                { "REQINV", "L", 1, 0 }, ;
                { "REQSERV", "L", 1, 0}, ;
                { "COUNT", "N", 8, 0 }, ;
                { "SHOWADD", "L", 1, 0 }, ;
                { "BACKUP", "L", 1, 0 }, ;
                { "POPMENU", "L", 1, 0 },;
                { "LSIDE1", "C",30, 0 }, ;
                { "RSIDE1", "C",30, 0 }, ;
                { "LSIDE2", "C",30, 0 }, ;
                { "RSIDE2", "C",30, 0 }, ;
                { "BILLFOOT", "C",75, 0 }  }

dbcreate( cPath + '\SYSTEM.EA', aSEa )
close all
use ("C:\ea\02\system.ea")
append blank
field->company := "SYSTEM_0"
field->comp    := company
field->open    := .f.
field->head    := company
close all
aSEa := { ;
          { 'USER', 'C', 3, 0 }, { 'USERNAME', 'C', 20, 0 }, { 'PASSWORD', 'C', 10, 0 }, { 'LOGGED', 'L', 1, 0 } ;
          }
dbcreate( cPath + '\USERS.DBF', aSEa )
close all
use ("C:\ea\02\users.dbf")
append blank
field->USER     := 'SUP'
field->USERNAME := 'Supervisor'
field->PASSWORD := cPass                // It is already encrypted in SETUP()
field->LOGGED   := .f.
close all

Copy file (cOD+":\"+cCurPath+"\SYSTEM.INT") to (cPath+"\SYSTEM.INT")
COPY file (cOD+":\"+cCurPath+"\EA.DAT") to (cPath+"\EA.EXE")
Copy file (cOD+":\"+cCurPath+"\EXTHOST.EA") to (cPath+"\VS_900.DBF")
Copy file (cOD+":\"+cCurPath+"\EAC.DAT") to (cPath+"\EACOLOR.EXE")

Copy file (cOD+":\"+cCurPath+"\EXTHOST.EA") to (cP+"\EASYS\VS_900.DBF")

if file(cOD+":\"+cCurPath+"\EA.PIF")
  Copy file (cOD+":\"+cCurPath+"\EA.PIF") to C:\WINDOWS\DESKTOP\EA.PIF
  Copy file (cOD+":\"+cCurPath+"\EA.PIF") to C:\EA\EA.PIF
endif

// EaSys DIR. is in C:\EA not in C:\EA\02 (.:., we use cP instead of cPath)

return .t.

static function jEncrypt( cPass, cKey )

local x := ""
local y
local z := ""
// cKey is optional
if cKey == NIL
   cKey := "EasyAccounts v1.5"
endif
// My own encryption....
for y := 1 to len( cPass )
   x += chr( asc( subs( cPass, y, 1 ) ) - ( y * 2 ) )
next y
for y := 1 to len( x )
   z += chr( asc( subs( x, y, 1 ) ) - ( y * 2 ) )
next y
// Comes, Ghost! encryption...
z := gwEncrypt( z, cKey )
return z

function NoUse

return 1
//--------------------------------------
static function showauthor
clear
text                     

                           ÛÛ Welcome to EasyAccounts! ÛÛ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Thank you for downloading the entire bundle of EasyAccounts. This contains a
setup module, executable version of the software, required databases and to
top everything, has the entire source code and some sparse documentation too.

Please browse through the documentation file (WHATSNEW.DOC) to view the
history of this application.

All are welcome to use,adapt or play with it.

Thanks.

JASIM A BASHEER

blog: http://jabpaacet.blogspot.com     Û   email: jasim.ab@gmail.com
                                        Û   mob#: 9349 892969 (ISD Code 91)
                                        Û
                                        Û    [ please visit my blog to
                                        Û      see the updated number if this
                                        Û      does not work ]
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDTEXT
inkey(0)
text

Please run C:\EA\EA.PIF to start the application.

endtext

RUN ("START C:\EA")

return .t.


*+ EOF: SETUP.PRG
