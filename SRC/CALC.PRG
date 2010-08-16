#include "std.ch"
#include "vs_900.ch"
#include "vs_color.ch"

#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"
#include "set.ch"

static tcNmbr := "0"

static tnTotal := 0
static tcOper  := "+"

static tnTop       := 5
static tnLeft      := 5
static tnMemory    := 0
static tlShowTotal := .t.

static taButtons

function vs_Calc( pcPrgName, pnLineNmbr, pcVarName )

local nKey      := 0
local nDigit    := 0
local cDisplay  := "0"
local lLastOper := .f.
local lRedraw   := .t.
local nPos      := 0
local nDecimals := set( _SET_DECIMALS, 8 )
local cKey      := ""

taButtons := { { "0", { 14, 07 } }, ;
               { "1", { 11, 07 } }, ;
               { "2", { 11, 11 } }, ;
               { "3", { 11, 15 } }, ;
               { "4", { 08, 07 } }, ;
               { "5", { 08, 11 } }, ;
               { "6", { 08, 15 } }, ;
               { "7", { 05, 07 } }, ;
               { "8", { 05, 11 } }, ;
               { "9", { 05, 15 } }, ;
               { "P", { 05, 01 } }, ;
               { "%", { 08, 01 } }, ;
               { "E", { 11, 01 } }, ;
               { "C", { 14, 01 } }, ;
               { "+", { 05, 21 } }, ;
               { "-", { 08, 21 } }, ;
               { "/", { 11, 21 } }, ;
               { "*", { 14, 21 } }, ;
               { "=", { 14, 15 } }, ;
               { ".", { 14, 11 } }, ;
               { "MR", { 05, 25 } }, ;
               { "MC", { 08, 25 } }, ;
               { "M+", { 11, 25 } }, ;
               { "M-", { 14, 25 } } }

@ 300, 400 say "Hello!"         
// To refresh the memory and avoid sudden exits.

setblink( .f. )

set key K_F8 to

vs_GrabScrn()

while .t.

   dispbegin()

   if lRedraw

      vs_PutScrn( .t. )

      setcursor( SC_NONE )

      vs_Palette( VSP_MESSAGE )
      setcolor( COL1() )

      vs_Wind( tnTop + 1, tnLeft, tnTop + 17, tnLeft + 29, "Calculator", "", VSP_MESSAGE )
      @ tnTop + 03, tnLeft + 01 say "                          "          
      @ tnTop + 04, tnLeft + 01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"         

      /*/ -- -- -- -- -- -- -- -- -- -- -- -- -- --
      P 5, 1 % 8, 1 E 11, 1 C 14, 1
      7 5, 7 4 8, 7 1 11, 7 0 14, 7
      8 5, 11 5 8, 11 2 11, 11 . 14, 11
      9 5, 15 6 8, 15 3 11, 15 = 14, 15
      + 5, 21 - 8, 21 / 11, 21 * 14, 21
      MR 5, 25 MC 8, 25 M + 11, 25 M - 14, 25
      /////---------------------------

      @ tnTop + 05, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 06, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 07, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 08, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 09, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 10, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 11, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 12, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 13, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 14, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 15, tnLeft + 02 say "   ³             ³       "         
      @ tnTop + 16, tnLeft + 02 say "   ³             ³       "         
      /*
               //                        1   5 7   1   5   9 1   5
               @ tnTop+05,tnLeft+02 say "ÚÄ¿ ³ ÚÄ¿ ÚÄ¿ ÚÄ¿ ³ ÚÄ¿ ÚÄÄ¿"
               @ tnTop+06,tnLeft+02 say "³P³ ³ ³7³ ³8³ ³9³ ³ ³+³ ³MR³"
               @ tnTop+07,tnLeft+02 say "ÀÄÙ ³ ÀÄÙ ÀÄÙ ÀÄÙ ³ ÀÄÙ ÀÄÄÙ"
               @ tnTop+08,tnLeft+02 say "ÚÄ¿ ³ ÚÄ¿ ÚÄ¿ ÚÄ¿ ³ ÚÄ¿ ÚÄÄ¿"
               @ tnTop+09,tnLeft+02 say "³%³ ³ ³4³ ³5³ ³6³ ³ ³-³ ³MC³"
               @ tnTop+10,tnLeft+02 say "ÀÄÙ ³ ÀÄÙ ÀÄÙ ÀÄÙ ³ ÀÄÙ ÀÄÄÙ"
               @ tnTop+11,tnLeft+02 say "ÚÄ¿ ³ ÚÄ¿ ÚÄ¿ ÚÄ¿ ³ ÚÄ¿ ÚÄÄ¿"
               @ tnTop+12,tnLeft+02 say "³E³ ³ ³1³ ³2³ ³3³ ³ ³/³ ³M+³"
               @ tnTop+13,tnLeft+02 say "ÀÄÙ ³ ÀÄÙ ÀÄÙ ÀÄÙ ³ ÀÄÙ ÀÄÄÙ"
               @ tnTop+14,tnLeft+02 say "ÚÄ¿ ³ ÚÄ¿ ÚÄ¿ ÚÄ¿ ³ ÚÄ¿ ÚÄÄ¿"
               @ tnTop+15,tnLeft+02 say "³C³ ³ ³0³ ³.³ ³=³ ³ ³*³ ³M-³"
               @ tnTop+16,tnLeft+02 say "ÀÄÙ ³ ÀÄÙ ÀÄÙ ÀÄÙ ³ ÀÄÙ ÀÄÄÙ"
              */
      for x := 1 to len( taButtons )
         c_dispord( taButtons[ x, 1 ], tnTop + tabuttons[ x, 2, 1 ], tnLeft + tabuttons[ x, 2, 2 ] )
      next x

      lRedraw := .f.

   end

   // Display the letter M if number is in memory
   //
   @ tnTop + 02, tnLeft + 2 say if( tnMemory = 0, space( 6 ), "M+" )         

   // Display the number
   //
   if tlShowTotal

      cDisplay := alltrim( str( tnTotal ) )

      while right( cDisplay, 1 ) == "0" .and. at( ".", cDisplay ) != 0

         if cDisplay == "0"
            exit
         end

         cDisplay := left( cDisplay, len( cDisplay ) - 1 )

      end

      if right( cDisplay, 1 ) == "."
         cDisplay := left( cDisplay, len( cDisplay ) - 1 )
      end

   else

      cDisplay := tcNmbr

   end

   cDisplay := padl( cDisplay, 20 )

   @ tnTop + 03, tnLeft + 4 say cDisplay color 'W+/R*'        

   dispend()

   // Do the fancy key press B.S.
   //
   nPos := ascan( taButtons, { | x | x[ 1 ] == upper( cKey ) } )

   if nPos > 0
      c_disphii( taButtons[ nPos, 1 ], tnTop + tabuttons[ nPos, 2, 1 ], tnLeft + tabuttons[ nPos, 2, 2 ] )
      nKey := inkey( .1 )
      c_dispord( taButtons[ nPos, 1 ], tnTop + tabuttons[ nPos, 2, 1 ], tnLeft + tabuttons[ nPos, 2, 2 ] )

      /*
            DispBox( tnTop+taButtons[nPos,2,1], tnLeft+taButtons[nPos,2,2], ;
                     tnTop+taButtons[nPos,2,3], tnLeft+taButtons[nPos,2,4], ;
                     "ÜÜÜÞßßßÝ" )

            nKey := inkey(.25)

            DispBox( tnTop+taButtons[nPos,2,1], tnLeft+taButtons[nPos,2,2], ;
                     tnTop+taButtons[nPos,2,3], tnLeft+taButtons[nPos,2,4], ;
                     B_SINGLE )
            */

   endif

   // Wait for the key
   //
   if nKey == 0
      nKey := inkey( 0 )
   endif

   cKey := chr( nKey )

   // By Jas. To simulate ENTER into EQUALs
   if asc( cKey ) == K_ENTER
      cKey := '='
      nKey := asc( '=' )
   endif

   do case

   case nKey >= 48 .and. nKey <= 57 .and. len( tcNmbr ) <= 20

      if tcNmbr == "0"
         tcNmbr := chr( nKey )
      else
         tcNmbr += chr( nKey )
      endif

      tlShowTotal := .f.
      lLastOper   := .f.

   case nKey = K_BS

      if len( tcNmbr ) = 1
         tcNmbr := "0"
      else
         tcNmbr := left( tcNmbr, len( tcNmbr ) - 1 )
      endif

      tlShowTotal := .f.
      lLastOper   := .f.

   case nKey == asc( "." ) .and. at( ".", tcNmbr ) == 0

      tcNmbr += "."

      tlShowTotal := .f.
      lLastOper   := .f.

      nKey := 0

   case at( chr( nKey ), "+-/*=" + chr( K_ENTER ) ) > 0

      if .not. lLastOper

         do case
         case tcOper == "+"
            tnTotal += val( tcNmbr )
         case tcOper == "-"
            tnTotal -= val( tcNmbr )
         case tcOper == "/"
            tnTotal /= val( tcNmbr )
         case tcOper == "*"
            tnTotal *= val( tcNmbr )
         endcase

      end

      tcOper := chr( nKey )
      tcNmbr := "0"

      tlShowTotal := .t.
      lLastOper   := .t.

   case chr( nKey ) = "%"

      tcNmbr := alltrim( str( tnTotal * ( val( tcNmbr ) / 100 ) ) )

      keyboard chr( K_ENTER )

   case chr( nKey ) $ "Cc"

      tcNmbr    := "0"
      tnTotal   := 0
      lLastOper := .f.
      tcOper    := "+"

   case chr( nKey ) $ "Ee"

      tcNmbr    := "0"
      lLastOper := .f.

   case chr( nKey ) $ "Mm"              // Memory functions

      nKey := inkey( 0 )

      cKey := "M" + chr( nKey )

      do case

      case chr( nKey ) $ "rR"

         tcNmbr := alltrim( str( tnMemory ) )

         do case
         case tcOper == "/"
            tnTotal /= val( tcNmbr )
         case tcOper == "*"
            tnTotal *= val( tcNmbr )
         case tcOper == "+"
            tnTotal += val( tcNmbr )
         case tcOper == "-"
            tnTotal -= val( tcNmbr )
         endcase

         tlShowTotal := .f.
         tcOper      := "="

      case chr( nKey ) $ "cC"
         tnMemory := 0

      case chr( nKey ) == "+" .or. chr( nKey ) == "-"

         do case
         case tcOper == "/"
            tnTotal /= val( tcNmbr )
         case tcOper == "*"
            tnTotal *= val( tcNmbr )
         case tcOper == "+"
            tnTotal += val( tcNmbr )
         case tcOper == "-"
            tnTotal -= val( tcNmbr )
         endcase

         tcOper := "+"

         tcNmbr := "0"

         tlShowTotal := .t.

         lLastOper := .f.

         if chr( nKey ) == "+"
            tnMemory += tnTotal
         else
            tnMemory -= tnTotal
         endif

      endcase

   case chr( nKey ) $ "Pp"

      if tlShowTotal
         keyboard alltrim( str( tnTotal ) )
      else
         keyboard alltrim( str( val( tcNmbr ) ) )
         // To Avoid EXCESS decimals, if present - STR(VAL(...))
         // By Jasim.
      endif

      exit

   case nKey == K_UP

      tnTop --

      if tnTop < 0
         tnTop := 0
      end

      lRedraw := .t.

   case nKey == K_DOWN

      tnTop ++

      if tnTop > ( maxrow() - 18 )
         tnTop := maxrow() - 18
      end

      lRedraw := .t.

   case nKey == K_LEFT

      tnLeft --

      if tnLeft < 0
         tnLeft := 0
      end

      lRedraw := .t.

   case nKey == K_RIGHT

      tnLeft ++

      if tnLeft > ( maxcol() - 29 )
         tnLeft := maxcol() - 29
      end

      lRedraw := .t.

   case nKey == K_ESC

      exit

   endcase

   // Reset the key press
   //
   nKey := 0

enddo

vs_PutScrn()

set( _SET_DECIMALS, nDecimals )

set key K_F8 to vs_calc()

return nil

static function c_dispord( z, x, y )

local x1
local y1
//y++
Z := rtrim( ltrim( Z ) )
/*
col1()
IF LEN(Z) > 1
@ x,y   say "ÚÄÄ¿"
@ x+1,y say "³"+iif(len(z) > 1,padc(z,2),padc(z,1))+"³"
@ x+2,y say ""
ELSE
@ x,y   say "ÚÄ¿"
@ x+1,y say "³"+iif(len(z) > 1,padc(z,2),padc(z,1))+"³"
@ x+2,y say ""
ENDIF
col2()
IF LEN(Z) > 1  
@ x,y+1   say "   "
@ x+1,y+1 say "   ³" // or else, it will remove the R of MR, for instance.
@ x+2,y+1 say "ÀÄÄÙ"
elseif len(z)==1
@ x,y+2   say "  "
@ x+1,y+2 say "  ³"
@ x+2,y+2 say "ÀÄÙ"
endif
*/
col1()
if len( Z ) > 1
   @ x, y     say "ÚÄÄ"                                                               
   @ x + 1, y say "³" + iif( len( z ) > 1, padc( z, 2 ), padc( z, 1 ) ) + "³"         
   @ x + 2, y say "ÀÄÄ"                                                               
else
   @ x, y     say "ÚÄ"                                                                
   @ x + 1, y say "³" + iif( len( z ) > 1, padc( z, 2 ), padc( z, 1 ) ) + "³"         
   @ x + 2, y say "ÀÄ"                                                                
endif
col2()
if len( Z ) > 1
   @ x, y + 3     say "¿"                                                               
   @ x + 1, y + 3 say "³" // or else, it will remove the R of MR, for instance.         
   @ x + 2, y + 3 say "Ù"                                                               
elseif len( z ) == 1
   @ x, y + 2     say "¿"         
   @ x + 1, y + 2 say "³"         
   @ x + 2, y + 2 say "Ù"         
endif

return .t.

static function c_disphii( z, x, y )

local x1
local y1
//y++
Z := rtrim( ltrim( Z ) )

col2()
if len( Z ) > 1
   @ x, y     say "ÚÄÄ"                                                               
   @ x + 1, y say "³" + iif( len( z ) > 1, padc( z, 2 ), padc( z, 1 ) ) + "³"         
   @ x + 2, y say "ÀÄÄ"                                                               
else
   @ x, y     say "ÚÄ"                                                                
   @ x + 1, y say "³" + iif( len( z ) > 1, padc( z, 2 ), padc( z, 1 ) ) + "³"         
   @ x + 2, y say "ÀÄ"                                                                
endif

col1()
if len( Z ) > 1
   @ x, y + 3     say "¿"         
   @ x + 1, y + 3 say "³"         
   @ x + 2, y + 3 say "Ù"         
elseif len( z ) == 1
   @ x, y + 2     say "¿"         
   @ x + 1, y + 2 say "³"         
   @ x + 2, y + 2 say "Ù"         
endif
/*
col2()
IF LEN(Z) > 1
@ x,y   say "ÚÄÄ¿"
@ x+1,y say "³"+iif(len(z) > 1,padc(z,2),padc(z,1))+"³"
@ x+2,y say ""
ELSE
@ x,y   say "ÚÄ¿"
@ x+1,y say "³"+iif(len(z) > 1,padc(z,2),padc(z,1))+"³"
@ x+2,y say ""
ENDIF

col1()
IF LEN(Z) > 1
@ x,Y+2   say "   "
@ x+1,y+2 say "   ³"
@ x+2,y+2 say "ÀÄÄÙ"
elseif len(z)==1
*@ x,y+1  say "  "
@ x+1,y+1 say "  ³"
@ x+2,y+1 say "ÀÄÙ"
endif
*/
return .t.

static function c_waitfor

local x
for x := 1 to 50000
next x
return .t.

function col1

setcolor( 'W+/N*' )
function col2

setcolor( 'N/N*' )
function col3

setcolor( 'W*/R' )

*+ EOF: CALC.PRG
