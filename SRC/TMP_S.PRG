//- For initializing KOLLAM users database when they reformatted hdd..

local aSEa := { ;
              { 'USER', 'C', 3, 0 }, { 'USERNAME', 'C', 20, 0 }, { 'PASSWORD', 'C', 10, 0 }, { 'LOGGED', 'L', 1, 0 } ;
              }

public _bEasyKey     := {|| ;
     alltrim(str( USERS->(recno()) )) + subs(bootNum(),2,3) + subs(bootNum(),6,7) + "EasyAccounts by Jasim" }


? 'EasyAccounts Users Initialization'
? '---------(C) Jasim A Basheer 2001'
?
if file('USERS.DBF')
  ferase('USERS.DBF')
endif
dbcreate( 'USERS.DBF', aSEa )
close all
use ("users.dbf")
append blank
field->USER     := 'SUP'
field->USERNAME := 'Supervisor'
field->PASSWORD := jEncrypt( padr('MAREMUNA',10), eval(_bEasyKey) )

// PADR is used to include spaces while encrypting. If not, it will become wrong
field->LOGGED   := .f.

append blank
field->USER     := 'NIZ'
field->USERNAME := 'NIZAR'
field->PASSWORD := jEncrypt( padr('NIZAR',10), eval(_bEasyKey) )
field->LOGGED   := .f.

append blank
field->USER     := 'SAJ'
field->USERNAME := 'SAJIMON'
field->PASSWORD := jEncrypt( padr('SAJIMON',10), eval(_bEasyKey) )
field->LOGGED   := .f.

append blank
field->USER     := 'NAZ'
field->USERNAME := 'NAZLIN'
field->PASSWORD := jEncrypt( padr('NAZLIN',10), eval(_bEasyKey) )
field->LOGGED   := .f.

close all
?
? 'Users successfully reinitialized...'
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
function NoUse      // To hack SEGURO 3 ["Copy Protection"] Library's
//                     COPY PROTECTION!!!!
//
// I changed the ALERT("SHAREWARE....") and all other bloody things to
// NOUSE("..) So, it will not bring to light my very fantastic deeds.
// And to prevent Undefined function : NoUse, here is it!!!
return 1
//----------------------

