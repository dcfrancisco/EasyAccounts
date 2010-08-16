// -- Replaces the password of ALL users with 'EA'

use users
skip
//replace rest password with jEncrypt( rtrim( ltrim( upper( password ) ) ) )
replace rest password with jEncrypt( "EA" )

function jEncrypt( cPass )

local x := ""
local y
local z := ""
for y := 1 to len( cPass )
   x += chr( asc( subs( cPass, y, 1 ) ) - ( y * 2 ) )
next y
for y := 1 to len( x )
   z += chr( asc( subs( x, y, 1 ) ) - ( y * 2 ) )
next y
z := gwEncrypt( z, "This is EasyAccounts PRO.. by Jasim" )
return z
//--------------------------------------------------
function jDecrypt( cPass )

local x := ""
local y
local z := ""
cPass := gwDecrypt( cPass, "This is EasyAccounts PRO.. by Jasim")
for y := 1 to len( cPass )
   x += chr( asc( subs( cPass, y, 1 ) ) + ( y * 2 ) )
next y
for y := 1 to len( x )
   z += chr( asc( subs( x, y, 1 ) ) + ( y * 2 ) )
next y
return z
//====================================================

*+ EOF: U_PASS.PRG
