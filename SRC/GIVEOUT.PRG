x  := 'E_COVER.EA'
x1 := 'EA_EDIT.COM'
x2 := 'EA.DAT'
x3 := 'JSY_SIGN.SGN'
? x + '     '
?? ascplus3( x ) + '   '
?? chrminus4( ascplus3( x ) ) + '   '
? x1 + '     '
?? ascplus3( x1 ) + '   '
?? chrminus4( ascplus3( x1 ) )
? x2 + '     '
?? ascplus3( x2 ) + '   '
?? chrminus4( ascplus3( x2 ) )
? x3 + '     '
?? ascplus3( x3 ) + '   '
?? chrminus4( ascplus3( x3 ) )

//--------
func ascplus3( string )

local y    := 1
local retv := ''
for y := 1 to len( string )
   retv += rtrim( ltrim( str( asc( subs( string, y, 1 ) ) - 4 ) ) )
next y
return retv
//--------
func chrminus4( string )

local y    := 1
local retv := ''
for y := 1 to len( string )
   retv += chr( val( subs( string, y, 2 ) ) + 4 )
   //retv += chr( val(subs(string,y,2)) + 4 )
   y ++
next y
return retv

*+ EOF: GIVEOUT.PRG
