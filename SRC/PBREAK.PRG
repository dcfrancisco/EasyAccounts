//==============================
// Password Breaker for EA v2.5
//        by Jasim A Basheer
//==============================
local cPass := space(20)
local x,y,z
clear
@ 2,4 say "EasyAccounts v3.0 PASSWORD BREAKER"
@ 3,4 say "----------(C) Jasim A Basheer 2002"
@ 5,4 say "Current Key : " get cPass pict '@X'
read
cPass := alltrim(upper(cPass))
if empty(cPass)
 @ 7, 4 say "Aborted.."
 @ 9, 0 say ""
 quit
endif
if len(cPass) < 5  .or. subs(rgKeyAns(cPass),1,3) = '0P0'
 @ 7, 4 say "Invalid key.."
 @ 9, 0 say ""
 quit
endif
errorblock( {|| MyError() })
@ 7, 4 say "The Answer Key is : "
@ 8, 4 say "                    "+rgKeyAns(cPass)
@ 10, 4 say ""
quit
//----------------------------------
function MyError
@ 10, 4 say "Invalid key entered."
@ 12, 4 say ""
quit
return .t.
//--------------------
static function rgKeyAns( cKey )

// ---------------------------------------------
// STEPS FOR OBTAINING THE ANSWER TO THE KEY   // By Jasim A Basheer
// ---------------------------------------------
// Add the first and eighth nos. +
// Absolute value of (Subtract the second last no. from second no.)
// Add third and fourth
// Subtract 6th from 5th
// Reverse the order of the numbers. Put PIANO from 1st letter onwards in
//                                                    between each letter.
//
//
local x
local cAns  := ""
local cAns1 := ""
local y
local cAns2 := ""
cAns += MStr( val( subs( cKey, 1, 1 ) ) + val( subs( cKey, 8, 1 ) ) )           // == 1st Step
cAns += MStr( abs( val( subs( cKey, 2, 1 ) ) - val( subs( cKey, 7, 1 ) ) ) )    // == 2nd Step
cAns += MStr( val( subs( cKey, 3, 1 ) ) + val( subs( cKey, 4, 1 ) ) )           // == 3rd
cAns += MStr( abs( val( subs( cKey, 5, 1 ) ) - val( subs( cKey, 6, 1 ) ) ) )    // == 4th
for x := len( cAns ) to 0 step - 1
   cAns1 += subs( cAns, x, 1 )
   if x - 1 = 0
      exit
   endif
next x
y := 1
for x := 1 to len( cAns1 )
   cAns1 := subs( cAns1, 1, x ) + subs( 'PIANO', y, 1 ) + subs( cAns1, x + 1 )
   y ++
   x ++
next x
// Most often, the Key is 10 lettered.
return rtrim( ltrim( upper( cAns1 ) ) )

static func MStr( nVal )

return rtrim( ltrim( str( nVal ) ) )
