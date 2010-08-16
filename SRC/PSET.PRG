local aSEa := { ;
              { 'USER', 'C', 3, 0 }, { 'USERNAME', 'C', 20, 0 }, { 'PASSWORD', 'C', 10, 0 }, { 'LOGGED', 'L', 1, 0 } ;
              }

public _bEasyKey     := {|| ;
     alltrim(str( USERS->(recno()) )) + subs(bootNum(),2,3) + subs(bootNum(),6,7) + "EasyAccounts by Jasim" }

parameter cWhat
if cWhat=NIL .or. upper(alltrim(cWhat)) != 'PSET'
 ? 'EasyAccounts Users Initialization'
 ? '---------(C) Jasim A Basheer 2001'
 ?
 ? 'Invalid Parameter passed.'
 ?
 quit
endif

? 'EasyAccounts Users Initialization'
? '---------(C) Jasim A Basheer 2001'
?
if file('USERS.DBF')
  ?
  ? 'USERS.DBF already exists. Please erase the file'
  ? 'for reinitializing the registry.'
  ?
  ?
  quit
endif
dbcreate( 'USERS.DBF', aSEa )
close all
use ("users.dbf")
append blank
field->USER     := 'SUP'
field->USERNAME := 'Supervisor'
field->PASSWORD := jEncrypt( padr('SUPERVISOR',10), "This is EasyAccounts PRO.. by Jasim"  )

// PADR is used to include spaces while encrypting. If not, it will become wrong
field->LOGGED   := .f.
close all
?
? 'USERS.DBF successfully created for Supervisor privilege.'
?
?
quit
//=================================================
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
//--------------------------------------------------
static function xStr(nNum)
local retv
if nNum=1
  retv := 'R'
elseif nNum=2
  retv := 'E'
elseif nNum=3
  retv := 'N'
else
  retv := 'A'
endif
//-----------------
function NoUse      // To hack SEGURO 3 ["Copy Protection"] Library's
//                     COPY PROTECTION!!!!
//
// I changed the ALERT("SHAREWARE....") and all other bloody things to
// NOUSE("..) So, it will not bring to light my very fantastic deeds.
// And to prevent Undefined function : NoUse, here is it!!!
return 1
//----------------------

