/*
#
#     Utility System for EasyAccounts v1.5
#     Developed and Tested by Jasim A Basheer
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
#    --------------------------------
#          Now, NETWORK ENABLED!!
#           (C) Jasim A Basheer
#    ---------------------------------
#
*/

#include "std.ch"
#include "fileio.ch"
#include "ghost.ch"
#include "box.ch"
#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "bgevents.ch"

#define FilePos(nHandle)  (FSEEK(nHandle, 0, FS_RELATIVE))

#define NUMBER_OF_USERS 1

#define SHADOW_LOWER_LEFT 1
#define SHADOW_LOWER_RIGHT 3
#define SHADOW_UPPER_LEFT  7
#define SHADOW_UPPER_RIGHT 9

#ifndef K_LBUTTONDOWN
#define K_LBUTTONDOWN   1002   //   mouse left key press
#define K_RBUTTONDOWN   1004   //   mouse right key press
#endif
#define K_MOUSELEFT K_LBUTTONDOWN
#define K_MOUSERIGHT K_RBUTTONDOWN


#define LOCK_DELAY 12000
// Jasim's define for jRLock, jFlock, euse etc..

static nnCount
static lJOp        := .t.
static xUser       := ""
static xUserName   := ""
static reqinv_v
static reqserv_v
static cDefaultDir
static eUseErr   := .f.

static aaGets    := {}
static aaCursor  := {}
static aaDbfs    := {}
static aaFilters := {}
static aaScreen  := {}
static aaActInd  := {}
static aaRecord  := {}
static anActWork := {}

static ErrorClose := .f.

static StartDrive
static StartDir
static DataDir
static nOldFont
//-----------
function logo( pcPhrase, pnLine )

// Returns a line of BIG TEXT

local nCntr      := 0
local nPos       := 0
local cRetVal    := ""
local nLength    := 0
static taLetters := {}

if len( taLetters ) = 0

   aadd( taLetters, { "A", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      " ßß  ßß" } } )

   aadd( taLetters, { "B", { ;
                      "±±±±±Ü ", ;
                      "±±Ûß±±Ü", ;
                      "±±±±±Ûß", ;
                      "±±Ûß±±Ü", ;
                      "±±±±±Ûß", ;
                      " ßßßßß " } } )

   aadd( taLetters, { "C", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±Û    ", ;
                      "±±Û    ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "D", { ;
                      "±±±±±Ü ", ;
                      "±±Ûß±±Û", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      "±±±±±Ûß", ;
                      " ßßßßß " } } )

   aadd( taLetters, { "E", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±±±±Ü ", ;
                      "±±Ûßßß ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "F", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±±±±Ü ", ;
                      "±±Ûßßß ", ;
                      "±±Û    ", ;
                      " ßß    " } } )

   aadd( taLetters, { "G", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±Û±±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "H", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      "±±Ûß±±Û", ;
                      "±±Û ±±Û", ;
                      " ßß  ßß" } } )

   aadd( taLetters, { "I", { ;
                      "±±Ü", ;
                      "±±Û", ;
                      "±±Û", ;
                      "±±Û", ;
                      "±±Û", ;
                      " ßß" } } )

   aadd( taLetters, { "J", { ;
                      "    ±±Ü", ;
                      "    ±±Û", ;
                      "    ±±Û", ;
                      "±±Ü ±±Û", ;
                      " ±±±±Ûß", ;
                      "  ßßßß " } } )

   aadd( taLetters, { "K", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±±±±Ûß", ;
                      "±±Ûß±±Ü", ;
                      "±±Û ±±Û", ;
                      " ßß  ßß" } } )

   aadd( taLetters, { "L", { ;
                      "±±Ü    ", ;
                      "±±Û    ", ;
                      "±±Û    ", ;
                      "±±Û    ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "M", { ;
                      "±±±ÜÜ±±±Ü", ;
                      "±±Û±±Û±±Û", ;
                      "±±Û ßß±±Û", ;
                      "±±Û   ±±Û", ;
                      "±±Û   ±±Û", ;
                      " ßß    ßß" } } )

   aadd( taLetters, { "N", { ;
                      "±±±ÜÜ ±±Ü", ;
                      "±±Û±±Û±±Û", ;
                      "±±Û ß±±±Û", ;
                      "±±Û   ±±Û", ;
                      "±±Û   ±±Û", ;
                      " ßß    ßß" } } )

   aadd( taLetters, { "O", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "P", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      "±±Ûßßßß", ;
                      "±±Û    ", ;
                      " ßß    " } } )

   aadd( taLetters, { "Q", { ;
                      "±±±±±±Ü ", ;
                      "±±Ûß±±Û ", ;
                      "±±Û ±±Û ", ;
                      "±±Û±±±Û ", ;
                      "±±±±Û±±Ü", ;
                      " ßßßß ßß" } } )

   aadd( taLetters, { "R", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±Ûß", ;
                      "±±Ûß±±Ü", ;
                      "±±Û ±±Û", ;
                      " ßß  ßß" } } )

   aadd( taLetters, { "S", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±±±±±Ü", ;
                      " ßßß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "T", { ;
                      "±±±±±±Ü", ;
                      " ß±±Ûßß", ;
                      "  ±±Û  ", ;
                      "  ±±Û  ", ;
                      "  ±±Û  ", ;
                      "   ßß  " } } )

   aadd( taLetters, { "U", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "V", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      " ±±±±Ûß", ;
                      "  ±±Ûß ", ;
                      "   ßß  " } } )

   aadd( taLetters, { "W", { ;
                      "±±Ü   ±±Ü", ;
                      "±±Û   ±±Û", ;
                      "±±Û   ±±Û", ;
                      "±±Û±±Ü±±Û", ;
                      " ß±±±±Ûßß", ;
                      "   ßßßß  " } } )

   aadd( taLetters, { "X", { ;
                      "±±Ü ±±Ü", ;
                      " ±±±±Û ", ;
                      "  ±±Û  ", ;
                      " ±±±±Ü ", ;
                      "±±Ûß±±Ü", ;
                      " ßß  ßß" } } )

   aadd( taLetters, { "Y", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      " ±±±±Ûß", ;
                      "  ±±Ûß ", ;
                      "  ±±Û  ", ;
                      "   ßß  " } } )

   aadd( taLetters, { "Z", { ;
                      "±±±±±±Ü", ;
                      " ßß±±Ûß", ;
                      "  ±±Û  ", ;
                      " ±±Û   ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "1", { ;
                      " ±±±Ü  ", ;
                      "  ±±Û  ", ;
                      "  ±±Û  ", ;
                      "  ±±Û  ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "2", { ;
                      "±±±±±±Ü", ;
                      " ßßß±±Û", ;
                      "±±±±±±Û", ;
                      "±±Ûßßßß", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "3", { ;
                      "±±±±±±Ü", ;
                      " ßßß±±Û", ;
                      " ±±±±±Û", ;
                      "  ßß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "4", { ;
                      "±±Ü ±±Ü", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      " ßßß±±Û", ;
                      "    ±±Û", ;
                      "     ßß" } } )

   aadd( taLetters, { "5", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±±±±±Ü", ;
                      " ßßß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "6", { ;
                      "±±±±±±Ü", ;
                      "±±Ûßßßß", ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "7", { ;
                      "±±±±±±Ü", ;
                      " ßßß±±Û", ;
                      "    ±±Û", ;
                      "    ±±Û", ;
                      "    ±±Û", ;
                      "     ßß" } } )

   aadd( taLetters, { "8", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "9", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßß±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "0", { ;
                      "±±±±±±Ü", ;
                      "±±Ûß±±Û", ;
                      "±±Û ±±Û", ;
                      "±±Û ±±Û", ;
                      "±±±±±±Û", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { "!", { ;
                      "±±Ü", ;
                      "±±Û", ;
                      "±±Û", ;
                      " ßß", ;
                      "±±Ü", ;
                      " ßß" } } )

   aadd( taLetters, { ".", { ;
                      "   ", ;
                      "   ", ;
                      "   ", ;
                      "   ", ;
                      "±±Ü", ;
                      " ßß" } } )

   aadd( taLetters, { ",", { ;
                      "   ", ;
                      "   ", ;
                      "   ", ;
                      "±±Ü", ;
                      " ±Û", ;
                      "  ß" } } )

   aadd( taLetters, { "'", { ;
                      "±±Ü", ;
                      " ±Û", ;
                      "  ß", ;
                      "   ", ;
                      "   ", ;
                      "   " } } )

   aadd( taLetters, { "?", { ;
                      "±±±±Ü", ;
                      " ßß±Û", ;
                      " ±±±Û", ;
                      "  ßßß", ;
                      " ±±Ü ", ;
                      "  ßß " } } )

   aadd( taLetters, { "-", { ;
                      "       ", ;
                      "       ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß", ;
                      "       ", ;
                      "       " } } )

   aadd( taLetters, { "_", { ;
                      "       ", ;
                      "       ", ;
                      "       ", ;
                      "       ", ;
                      "±±±±±±Ü", ;
                      " ßßßßßß" } } )

   aadd( taLetters, { " ", { ;
                      "     ", ;
                      "     ", ;
                      "     ", ;
                      "     ", ;
                      "     ", ;
                      "     " } } )

   ;

   aadd( taLetters, { "þ", { ;
                      "    ", ;
                      "    ", ;
                      "±±±Ü", ;
                      "±±±Û", ;
                      " ßßß", ;
                      "    " } } )

endif

nLength := len( pcPhrase )

for nCntr := 1 to nLength

   nPos := ascan( taLetters, { | x | upper( x[ 1 ] ) == upper( substr( pcPhrase, nCntr, 1 ) ) } )

   if nPos > 0

      if len( cRetVal ) != 0
         cRetval += " "
      endif

      cRetVal += taLetters[ nPos, 2, pnLine ]

   endif

next nCntr

return cRetVal
//------------
function jPick( aPicks, heading, rowRel, colRel, lCenter, cBoxColor )

local _xx  := savescreen( 0, 0, 24, 79 ),cOldCol := setcolor()
local nRet
local x
local xx   := 1
local yy   := 0
local zz   := 0
if cBoxColor=NIL
  cBoxColor := boxcolor()
endif
set wrap on
zz := len( heading )
do while .not. xx > len( aPicks )
   zz := max( zz, len( aPicks[ xx ] ) )
   xx ++
enddo
if zz > 76
   zz := 75
endif
setcolor( boxcolor() )
xx := int( 12 - ( len( aPicks ) / 2 ) )
yy := int( ( 79 / 2 ) - ( zz / 2 ) ) - 5
yy += 4             // It is leftend by four. Better easy way.
if rowRel != NIL
   xx += rowRel
endif
if colRel != NIL
   colRel += colRel
endif
if lCenter != NIL
   if lCenter
      for x := 1 to len( aPicks )
         aPicks[ x ] := padc( rtrim( ltrim( aPicks[ x ] ) ), zz + 1 )
      next x
   endif
endif
if xx < 2
   xx := 2
endif
if yy < 2
   yy := 2
endif
// The values rowRel and colRel are used to add or subtract(by passing-ve value)
// the CENTER position which is calculated automatically.
// eg.Passing rowRel 3 and colRel -10 makes the box 3 rows down the center
//  and the column 10 columns left. (Positive value RIGHT)
setcolor( cBoxColor )
@ xx - 1, yy clear to xx + len( aPicks ), yy + 2 + zz
@ xx - 1, yy, xx + len( aPicks ), yy + 2 + zz box B_DOUBLE_SINGLE
setcolor( scrColor() )
@ xx - 2, yy say padc( heading, zz + 3 )
setcolor( cBoxColor )
nRet := achoice( xx, yy + 1, xx + len( aPicks ), yy + zz + 1, aPicks )
restscreen( 0, 0, 24, 79, _xx )
setcursor(.t.)
setcursor(1)
setcolor( cOldCol )
return nRet
//--------------------------------------
function dispscrn( lShowLoading )

local cOldColor := setcolor( 'N*/W+' )
local x         := 1
local l         := 2
if lShowLoading = NIL
   lShowLoading := .f.
endif
dispbegin()
clear
setcolor( menucolor() )
@ 01, 00, 23, 79 box replicate( "±", 78 )

setcolor( 'N*/W+' )
@  0,  0 say padc( _EasyAccounts, 80 )

if !file( 'INSTALL.INF' )
   if comp_add != 'LOG ON'
      setcolor( yBoxColor(3) )
      @ 24,  0 say padc( gPrefix + iif( !empty( gPrefix ), ', ', '' ) + comp_add, 80 )
   else
      @ 24,  0 say padc( 'Logon Menu', 80 )
   endif
else
   @ 24,  0 say space( 80 )
endif

setcolor( 'B*/W*' )
dDate := entr_date()
@  0, 02 say "þ F1 Help"
//@  0, 51 say "by Jasim A Basheer"
@  0, 58 say "by jasim.ab@gmail.com"
@ 24, 02 say "User : " + username()
if !file( 'INSTALL.INF' )
   @ 24, 59 say 'Entry Date:' + dtoc( dDate )
endif
dispend()
setcolor( boxcolor() )
setcursor( 1 )
setprc( 0, 0 )
return .t.
//--------------------------------------------
function tellout( caption )

local zz := len( caption )
local xx
local yy
local nC := 1
setcolor( linecolor() )
xx := 11
yy := int( ( 79 / 2 ) - ( zz / 2 ) )
@ xx - 1, yy - 3 clear to xx + 2, yy + 4 + zz
@ xx - 1, yy - 3, xx + 2, yy + 4 + zz box B_DOUBLE_SINGLE
setcolor( scrcolor() )
@ xx - 2, yy - 3 say padc( "Message", zz + 08 )
setcolor( linecolor() )
@ xx, yy - 2 say padc( caption, zz + 06 )
@ xx + 1, yy + 4 prompt "Continue"
menu to nC
return iif( nC = 1, .t., .f. )
//-----------------------------------
function confirm( caption, line, col )

if col = NIL
   col := int( ( 79 / 2 ) - ( len( caption ) / 2 ) )
endif
if line = NIL
   line := 10
endif
return messyn( caption, "Yes", "No", line, col )
//-------------------------------------
function ontask( caption )

static lTherewas := .f.
if caption = NIL
   plswait( .f. )
   lTherewas := .f.
else
   caption += 'ÿ'
   if lTherewas
      plswait( .f. )
   endif
   plswait( .t., caption )
   lTherewas := .t.
endif
return .t.
//-----------------------------------
function jGetdata( cHeading, cForm )

local cOldalias := select()
local aCaptions := {}
local aValues   := {}
local aValids   := {}
local aPictures := {}
local nLongCap  := 0
local nLongVal  := 0

local cOldColor := setcolor()
local cHColor   := scrcolor()
local cCColor   := boxcolor()
local cFColor   := scrcolor()
local cFColor1  := linecolor()

local nTop
local nBottom
local nLeft
local nRight

local nCurrent := 1

local uDummy
local cResponse

local bTempValid

setblink( .f. )

if cHeading = NIL
   cHeading := 'Add/Edit Data'
endif

use (cForm) new
go top
do while .not. eof()
   if ( !empty( rtrim( ltrim( caption ) ) ) .or. !empty( rtrim( ltrim( picture ) ) ) ) .and. ( !empty( rtrim( ltrim( value ) ) ) )
      aadd( aCaptions, rtrim( caption ) )
      if empty( value ) .and. empty( picture )
         aadd( aValues, "" )
         aadd( aValids, "" )
         aadd( aPictures, "" )
      else
         if type( value ) != 'U'
            eValue := eval( { || &value } )
            if isalpha( eValue )
               aadd( aValues, eValue )
            elseif isdigit( eValue ) .and. isdigit( subs( eValue, 2 ) ) .and. ;
                               isdigit( subs( eValue, 3 ) ) .and. isdigit( subs( eValue, 4 ) ) .and. ;
                               isdigit( subs( eValue, 5 ) )
               aadd( aValues, eValue )
            else
               aadd( aValues, eValue )
            endif
            aadd( aPictures, if( empty( rtrim( ltrim( picture ) ) ), '@X', rtrim( ltrim( picture ) ) ) )
            aadd( aValids, if( empty( rtrim( ltrim( valid ) ) ), .t., valid ) )
            //aadd(aValids,if(empty(rtrim(ltrim(valid)),.T.,valid))
            nLongCap := max( len( rtrim( caption ) ), nLongCap )
            if type( value ) != 'N'
               nLongVal := max( len( eValue ), nLongVal )
            endif
         else
            ? "Value not proper"
            ? recno()
            return .f.
         endif
      endif
   else
      aadd( aCaptions, "ÿ" )
      aadd( aValids, "" )
      aadd( aValues, "ÿ" )
      aadd( aPictures, "ÿ" )
   endif
   skip
enddo

if len( aCaptions ) != len( aValues )
   ? 'not safe uNDEF'
   return .f.
endif
if len( aCaptions ) != len( aValids )
   ? 'not safe VALIDS'
   return .f.
endif
nTop  := 12 - int( len( aCaptions ) / 2 )
nLeft := 38 - int( ( nLongCap + 3 + nLongVal ) / 2 )

nBottom := nTop + len( aCaptions )
nRight  := nLeft + ( nLongCap + 3 + nLongVal ) + 3

nTop --

do while .t.

   setcolor( cHColor )
   @ nTop - 3, nLeft - 1 clear to nTop - 1, nRight + 1
   @ nTop - 3, nLeft - 1 to nTop - 1, nRight + 1
   @ nTop - 2, nLeft say padc( cHeading, nRight - nLeft )

   setcolor( cCColor )
   @ nTop, nLeft - 1 clear to nBottom, nRight + 1
   @ nTop, nLeft - 1 to nBottom, nRight + 1

   nCurrent := 1
   do while !nCurrent > len( aCaptions )
      if at( ':', aCaptions[ nCurrent ] ) = 0
         @ nTop + nCurrent, nLeft + 1 say ;
                 aCaptions[ nCurrent ] + space( nLongCap - len( aCaptions[ nCurrent ] ) + 1 ) + ;
                 " : "
      else
         @ nTop + nCurrent, nLeft + 1 say ;
                 aCaptions[ nCurrent ] + space( nLongCap - len( aCaptions[ nCurrent ] ) + 1 )
      endif
      nCurrent ++
   enddo

   nCurrent := 1

   setcolor( cCColor )
   do while !nCurrent > len( aCaptions )
      if !( aCaptions[ nCurrent ] = chr( 255 ) .and. aPictures[ nCurrent ] = chr( 255 ) )
         if !empty( aPictures[ nCurrent ] )
            @ nTop + nCurrent, nLeft + nLongCap + 5 get aValues[ nCurrent ] picture ;
                    aPictures[ nCurrent ]
            read
         endif
         @ nTop + nCurrent, nLeft + nLongCap + 5 say aValues[ nCurrent ] picture ;
                 aPictures[ nCurrent ]
      endif
      nCurrent ++
   enddo

   setcursor( 0 )
   setcolor( cFColor )
   @ nBottom + 1, nLeft - 1 clear to nBottom + 3, nRight + 1
   @ nBottom + 1, nLeft - 1 to nBottom + 3, nRight + 1
   setcolor( cFColor1 )
   @ nBottom + 2, nLeft + len( rtrim( padc( "(E)dit", nRight - nLeft ) ) ) - ;
           len( '(E)dit' ) say "(E)dit"
   @ nBottom + 2, nLeft + 1  say "(S)ave"
   @ nBottom + 2, nRight - 8 say "(A)bort"

   while .t.
      cResponse := upper( chr( inkey( 0 ) ) )
      if cResponse = 'S'
         use
         select( cOldalias )
         return aValues
      elseif cResponse = 'E'
         setcolor( cOldColor )
         @ nBottom + 1, nLeft - 1 clear to nBottom + 3, nRight + 1
         setcolor( cCColor )
         setcursor( 1 )
         exit
      else
         use
         select( cOldalias )
         setcolor( cOldColor )
         return {}
      endif
      setcursor( 1 )
   enddo

   loop
enddo
//----------------------------------
function msg( cMsg1, cMsg2, cMsg3, cMsg4, cMsg5, cMsg6, cMsg7, cMsg8, cMsg9 )

local nMessageLines
local nIterator
local nTop
local nLeft
local nBottom
local nRight
local cUnderScreen
local nOldCursor
local nTimeout
local lIsTimer
local nLongest
local aMessages

local xOldCol := setcolor( scrcolor() )

//- save cursor status, set cursor off
nOldCursor := setcursor( 0 )

//- how many paramaters passed (maximum 9)
if valtype( cMsg1 ) == "N"
   lIsTimer      := .T.
   nTimeout      := cMsg1
   nMessageLines := min( pcount() - 1, 8 )
   aMessages     := { cMsg2, cMsg3, cMsg4, cMsg5, cMsg6, cMsg7, cMsg8, cMsg9 }
else
   lIsTimer      := .F.
   nTimeout      := 0
   nMessageLines := min( pcount(), 9 )
   aMessages     := { cMsg1, cMsg2, cMsg3, cMsg4, cMsg5, cMsg6, cMsg7, cMsg8, cMsg9 }
endif
asize( aMessages, nMessagelines )

//- whats the longest string
nLongest := max( bigelem( aMessages ) + 1, 16 )

//- figure the window coordinates
nTop := 8
// if no lIsTimer value, leave blank line before "Press a key...", else no space
nBottom := iif( nTimeout = 0, nTop + nMessageLines + 3, nTop + nMessageLines + 1 )
nLeft   := int( ( 79 - nLongest ) / 2 - 1 )
nRight  := nLeft + nLongest + 2

//- draw a box
cUnderScreen := savescreen( nTop, nLeft, nBottom, nRight )
@ nTop, nLeft clear to nBottom, nRight
@ nTop, nLeft to nBottom, nRight

// display the message
for nIterator := 1 to nMessageLines
   @  8 + nIterator, nLeft + 2 say aMessages[ nIterator ]
next
// now the results of the lIsTimer value
if nTimeout = 0
   @ nBottom - 1, nLeft + 2 say "Press a key..."
   inkey( 0 )
else
   inkey( nTimeOut )
endif ( nTimeout = 0
//- leave
restscreen( nTop, nLeft, nBottom, nRight, cUnderScreen )
setcolor( xOldCol )
//- set cursor on, if that's where it was
setcursor( nOldCursor )
return ''
//----------------------------------
function bigelem( aArray )

local _x
local _y := 0
for _x := 1 to len( aArray )
   _y := max( _y, len( aArray[ _x ] ) )
next x
return _y
//------------------------------
function jsfilt( bObj, nkey, cFilt )

local x    := setcolor()
local obox := makebox( 3, 43, 5, 67, menucolor(), 0 )

private b := bObj
cFilter := cFilt      // ClipMore cannot use LOCALs

osch := "           "
setcolor( menucolor() )
set cursor on
setcursor( 1 )
@  4, 44 say "Search :" get osch pict '@!'
if nKey != 0
   keyboard if( nextkey() > 0, chr( nextkey() ) + chr( NKEY ), chr( NKEY ) )
endif
read
if osch != " "
   set filte to ( rtrim( ltrim( osch ) ) $ upper( eval( oFilter ) ) ) .and. ;
                  eval( cFilter )
   go top
else
   set filte to eval( cFilter )
endif
go top
unbox( oBox )
b:forcestable()
b:refreshall()
b:stabilize()
//restscreen(1,40,1,70,oBox)
setcolor( x )
return nil
//----------------------------------------
function mchoice( aOptions, nTop, nLeft, nBottom, nRight, cTitle, lAlpha, nStart, nRow, aSelectable )

local lAlphaSelects
local cFirstLetters
local nIterator
local nArrayLength
local cUnderScreen
local nOldCursor
local nLastKey
local cLastKey
local nFound
local nElement      := 1
local oTb
local nMouseR
local nMouseC

//- set cursor off
nOldCursor   := setcursor( 0 )
nArrayLength := aleng( aOptions )
mc_dodim( @nTop, @nLeft, @nBottom, @nRight, aOptions )

if aSelectable == nil
   aSelectable := array( len( aOptions ) )
   afill( aSelectable, .t. )
endif

if valtype( cTitle ) == "C"
   if len( cTitle ) > ( ( nRight - nLeft ) - 1 )
      cTitle := left( cTitle, nRight - nLeft - 1 )
   endif
endif

if nArrayLength > 0
   cFirstLetters := ''
   for nIterator := 1 to nArrayLength
      cFirstLetters += upper( left( aOptions[ nIterator ], 1 ) )
   next

   lAlphaSelects := iif( lAlpha # nil, lAlpha, .f. )

   //- figure out the box dimensions and draw it
   nBottom := min( nBottom, nArrayLength + nTop + 1 )
   //cUnderScreen  :=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
   cUnderScreen := makebox( nTop, nLeft, nBottom, nRight, scrcolor() )
   @ nTop, nLeft + 1 say iif( cTitle # nil, cTitle, '' )
   if sls_ismouse()
      devpos( nBottom, nright - 33 )
      devout( "[ ][ ] [ENTER=OK] [ESC=Cancel]" )
   endif
   oTb := tBrowseNew( nTop + 1, nLeft + 1, nBottom - 1, nRight - 1 )
   oTb:addcolumn( tbcolumnNew( nil, { || aOptions[ nElement ] } ) )
   oTb:getcolumn( 1 ) :width := sbcols( nLeft, nRight, .f. )
   oTb:Skipblock     := { | n | aaskip( n, @nElement, len( aOptions ) ) }
   oTb:goTopBlock    := { || nElement := 1 }
   oTb:goBottomBlock := { || nElement := len( aOptions ) }

   //: here set up the color handling - unselectable items are drawn
   //: as dimmed
   oTb:colorspec := setcolor() + "," + "+N/" + takeout( takeout( setcolor(), ",", 1 ), "/", 2 ) + ",+N/" + takeout( takeout( setcolor(), ",", 2 ), "/", 2 )
   oTb:getcolumn( 1 ) :colorblock := { || iif( aSelectable[ nElement ], { 1, 2 }, { 6, 7 } ) }

   if nStart # nil .and. nStart <= len( aOptions )
      if nRow # nil
         oTb:RowPos := nRow
         nElement   := nStart
         oTb:configure()
      else
         mc_goto( nStart, nElement, oTb )
      endif
   endif

   while .t.
      while !oTb:stabilize()
      end
      nLastKey := rat_event( 0 )
      nMouseR  := rat_eqmrow()
      nMouseC  := rat_eqmcol()
      do case
      case nLastKey = K_UP              // UP ONE ROW
         if nElement > 1
            oTb:UP()
         else
            oTb:gobottom()
         endif
      case nLastKey = K_DOWN            // DOWN ONE ROW
         if nElement < len( aOptions )
            oTb:DOWN()
         else
            oTb:gotop()
         endif
      case nLastKey = K_PGUP            // UP ONE PAGE
         oTb:PAGEUP()
      case nLastKey = K_HOME            // HOME
         oTb:GOTOP()
      case nLastKey = K_PGDN            // DOWN ONE PAGE
         oTb:PAGEdOWN()
      case nLastKey = K_END             // END
         oTb:GOBOTTOM()
      case nLastKey = K_ENTER           // ENTER
         //: Just make sure its selectable
         if aSelectable[ nElement ]
            exit
         else
            tone( 300, 1 )
            tone( 600, 1 )
            tone( 300, 1 )
         endif
      case nLastKey = K_ESC
         nElement := 0
         exit
      case ( cLastKey := upper( chr( nLastkey ) ) ) $ cFirstLetters
         if cLastkey == upper( left( aOptions[ nElement ], 1 ) ) .and. lAlphaSelects
            //: Just make sure its selectable
            if aSelectable[ nElement ]
               exit
            else
               tone( 300, 1 )
               tone( 600, 1 )
               tone( 300, 1 )
            endif
         else
            nFound := at( cLastKey, subst( cFirstLetters, nElement + 1 ) )
            nFound := iif( nFound > 0, nFound + nElement, nFound )
            if nFound == 0 .and. nElement > 1
               nFound := at( cLastKey, cFirstLetters )
            endif
            if nFound > 0
               if nFound <> nElement
                  mc_goto( nFound, nElement, oTb )
               endif
               if lAlphaSelects
                  //: Just make sure its selectable
                  if aSelectable[ nElement ]
                     exit
                  else
                     tone( 300, 1 )
                     tone( 600, 1 )
                     tone( 300, 1 )
                  endif
               endif
            endif
         endif
      case nLastKey == K_MOUSELEFT
         do case
         case ISMOUSEAT( nMouseR, nMouseC, nBottom, nRight - 33, nBottom, nRight - 31 )
            oTb:up()
            IFMOUSEHD( { || oTb:up() }, oTb )
         case ISMOUSEAT( nMouseR, nMouseC, nBottom, nRight - 30, nBottom, nRight - 28 )
            oTb:down()
            IFMOUSEHD( { || oTb:down() }, oTb )
         case ISMOUSEAT( nMouseR, nMouseC, nBottom, nRight - 26, nBottom, nRight - 17 )
            keyboard chr( K_ENTER )
         case ISMOUSEAT( nMouseR, nMouseC, nBottom, nRight - 15, nBottom, nRight - 4 )
            keyboard chr( K_ESC )
         case MBRZMOVE( oTb, nMouseR, nMouseC, nTop + 1, nLeft + 1, nBottom - 1, nRight - 1 )
            keyboard chr( K_ENTER )
         case MBRZCLICK( oTb, nMouseR, nMouseC )
            //: Just make sure its selectable
            if aSelectable[ nElement ]
               exit
            else
               tone( 300, 1 )
               tone( 600, 1 )
               tone( 300, 1 )
            endif
         endcase
      endcase
   end
   unbox( cUnderScreen )
   nRow := oTb:rowpos
else
   nElement := 0
endif
setcursor( nOldCursor )
return nElement

//===============================================================
static function mc_goto( nNew, nCurrent, oTb )

local nIter
local nDiff := abs( nNew - nCurrent )
dispbegin()
if nNew > nCurrent
   for nIter := 1 to nDiff
      oTb:down()
      while !oTb:stabilize()
      end
   next
else
   for nIter := 1 to nDiff
      oTb:up()
      while !oTb:stabilize()
      end
   next
endif
dispend()
return nil

//--------------------------------------------------------------
static function findbigest( aItems )

local aBiggest := 0
local i
for i := 1 to len( aItems )
   aBiggest := max( aBiggest, len( trans( aItems[ i ], "" ) ) )
next
return aBiggest

//--------------------------------------------------------------
static function mc_dodim( nTop, nLeft, nBottom, nRight, aItems )

local nLongest := findbigest( aItems )
if nTop == nil .or. nLeft == Nil
   nTop    := 0
   nLeft   := 0
   nBottom := min( len( aItems ) + 2, maxrow() )
   nRight  := min( nLongest + 2, maxcol() )
   sbcenter( @nTop, @nLeft, @nBottom, @nRight )
elseif nBottom == nil .or. nRight == nil
   nBottom := min( nTop + len( aItems ) + 2, maxrow() )
   nRight  := min( nLeft + nLongest + 2, maxcol() )
endif
if sls_ismouse() .and. ( nRight - nLeft - 1 ) < 34
   nRight   := nLeft + 34
   nLongest := 34
   sbcenter( @nTop, @nLeft, @nBottom, @nRight )
endif
nBottom := min( nBottom, nTop + len( aItems ) + 2 )
return nil
//--------------------------------------------------
function messyn( cMessage, expParam1, expParam2, expParam3, expParam4 )

local nParamCount
local cPrompt1
local cPrompt2
local nTop
local nBottom
local nLeft
local nRight
local nPromptLength
local nMessageLength
local nBoxLength
local nColumn1
local nColumn2
local nSelection
local lYesorNo
local cUnderScreen
local nOldCursor
local aOptions

nParamCount := pcount()
if nParamCount < 1
   return ''
endif

//- save cursor status, set cursor off
nOldCursor := setcursor( 0 )

//- set up defaults for prompts
cPrompt1 := "YES"
cPrompt2 := "NO"

//- default nTop, nLeft
nTop  := 0
nLeft := 0

//- if there are at least 3 params
if nParamCount > 2
   if valtype( expParam1 ) == "C"
      //- if the second param is character
      //- these must be prompts
      cPrompt1 := expParam1
      cPrompt2 := expParam2

      //- and if there are 5 params
      //- the other two params must be dimensions
      if nParamCount = 5
         nTop  := expParam3
         nLeft := expParam4
      endif
   else
      //- if the second param is not character
      //- these must be dimensions
      nTop  := expParam1
      nLeft := expParam2

      //- and if there are 5 params, the other two nParamCount must
      //- be prompts
      if nParamCount = 5
         cPrompt1 := expParam3
         cPrompt2 := expParam4
      endif
   endif
endif

//- figure out the prompt, message, and box lengths
nPromptLength  := 2 + len( cPrompt1 ) + 2 + len( cPrompt2 ) + 2
nMessageLength := 2 + len( cMessage ) + 2
nBoxLength     := max( nPromptLength, nMessageLength )

//- finish up the box dimensions
nBottom := nTop + 3
nRight  := nLeft + nBoxLength

if nTop == 0 .and. nLeft == 0
   sbcenter( @nTop, @nLeft, @nBottom, @nRight )
endif

//- where do we place our 2 prompts
nColumn1 := int( nLeft + int( ( nBoxLength - ( nPromptLength - 4 ) ) / 2 ) )
nColumn2 := nColumn1 + len( cPrompt1 ) + 2

//- ok, draw the box, do the prompts, and MENU TO
cUnderScreen := makebox( nTop, nLeft, nBottom, nRight, scrcolor() )
nSelection   := 1
@ nTop + 1, nLeft + 1 say cMessage
aOptions := { { nTop + 2, nColumn1, cPrompt1 }, ;
              { nTop + 2, nColumn2, cPrompt2 } }

nSelection := RAT_MENU2( aOptions, 1, .t. )

//- if the first prompt is selected, return .t. - otherwise return .f.
//- thus escape returns .f.
if nSelection = 1
   lYesorNo := .T.
else
   lYesorNo := .F.
endif

//- clean up and leave
unbox( cUnderScreen )

//- set cursor on, if that's where it was
setcursor( nOldCursor )

return lYesorNo
//----------------------------------
function OPCONFIRM( echo_on )

memvar fkeyset
local keypress
local old_cursor

if echo_on = NIL
   echo_on := .T.
endif

setcursor( 1 )

keypress := 0

do while .T.
   keypress := inkey( 0 )
   if chr( keypress ) $ 'YNyn'
      exit
   elseif ( keypress <= K_F2 .or. keypress > 256 .or. ;
               keypress = K_F1 ) .and. type( 'fkeyset' ) != 'U'
      if .not. empty( fkeyset )
         &fkeyset( 'OPCONFIRM', 0, readvar(), keypress )
      endif
   else
      tone( 300, 2 )
   endif
enddo
if echo_on
   @ row(), col() say upper( chr( keypress ) )
endif
return ( if( chr( keypress ) $ 'Yy', .T., .F. ) )
//--------------------------------------------
function cleanup

close all
set device to screen
set printer off
set printer to
setprc( 0, 0 )
dispscrn()          // instead of restcr
setcursor( 1 )
return .t.
//-----------
function sayverti( cString, nCol )

local nRow := 2
local x    := 1
local xx
xx := nRow
do while .not. x > len( cString )
   @ nRow, nCol say rtrim( ltrim( subs( cString, x, 1 ) ) )
   nRow ++
   x ++
enddo
return xx
//----------
function leadchar( cString, cChar, lWidth )

local x
x := rtrim( ltrim( cString ) )
x += repli( cChar, lWidth - len( x ) )
return x
//-------
function j_getmemo( nTop, nRight, nBott, nLeft, cStartwith, cHeading, lCanEdit, cEditColor)

local cOldScrn, cOldColor

if cHeading = NIL
   cHeading := 'Edit Memo Field'
endif
if cStartwith = NIL
   cStartwith := ""
endif
if nTop = NIL
   nTop := 01
endif
if nLeft = NIL
   nLeft := 00
endif
if nRight = NIL
   nRight := 79
endif
if nBott = NIL
   nBott := 23
endif
if lCanEdit=NIL
   lCanEdit := .t.
endif
if cEditColor=NIL
   cEditColor := boxcolor()
endif

cOldScrn := savescreen( nTop, nRight, nBott, nLeft )
@ nTop, nRight clear to nBott, nLeft
@ nTop, nRight, nBott, nLeft box B_DOUBLE_SINGLE
@ nTop, nRight + 3 say '[' + cHeading + ']'
set escape OFF
@ nBott, nLeft - 30 say '[ CTRL+W - Save & Exit ]'
if lCanEdit
   cOldColor := setcolor( cEditColor )

   cStartwith := memoedit( cStartwith, nTop + 1, nRight + 1, nBott - 1, nLeft - 1, .t. )
   // Last parameter is WHETHER ALLOW EDIT OR NOT

   setcolor(cOldColor)
else
   memoedit( cStartwith, nTop + 1, nRight + 1, nBott - 1, nLeft - 1, .f. )
endif
set escape on
return cStartwith
//-------------------------
function inwords( nAmount )

local nTemp
local sResult := " "
local nQualNo
local nDiv    := 10 ^ ( int( sol10( nAmount ) / 3 ) * 3 )

local ones := { "", " One", " Two", " Three", " Four", " Five", ;
                " Six", " Seven", " Eight", " Nine" ;
                }

local teens := { " Ten", " Eleven", " Twelve", ;
                 " Thirteen", " Fourteen", " Fifteen", ;
                 " Sixteen", " Seventeen", " Eighteen", ;
                 " Nineteen" ;
                 }

local tens := { "", "", " Twenty", " Thirty", " Forty", " Fifty", ;
                " Sixty", " Seventy", " Eighty", " Ninety" }

local qualifiers := { "", " Thousand", " Million", " Billion", " Trillion" }

nTemp   := int( nAmount % nDiv )
nAmount := int( nAmount / nDiv )
nQualNo := int( sol10( nDiv ) / 3 ) + 1
sResult += grp_to_words( nAmount, qualifiers[ nQualNo ], ones, tens, teens, qualifiers )

if nTemp > ( nDiv /= 1000 ) .and. ( nDiv > 1 )
   sResult += inwords( nTemp )
else
   sResult += grp_to_words( nTemp, "", ones, tens, teens, qualifiers )
endif
return 'Rupees ' + ( ltrim( sResult ) )

static function grp_to_words( nGrp, sQual, ones, tens, teens, qualifiers )

local sResult := ""
local nTemp

nTemp   := int( nGrp % 100 )
nGrp    := int( nGrp / 100 )
sResult += ones[ nGrp + 1 ] + iif( nGrp > 0, " Hundred", "" )

do case
case nTemp > 19
   sResult += tens[ int( nTemp / 10 ) + 1 ]
   sResult += ones[ int( nTemp % 10 ) + 1 ]
case nTemp < 20 .and. nTemp > 9
   sResult += teens[ int( nTemp % 10 ) + 1 ]
case nTemp < 10 .and. nTemp > 0
   sResult += ones[ int( nTemp ) + 1 ]
endcase
return ( sResult + sQual )

static function sol10( nNumber )

local sTemp

sTemp := ltrim( str( int( nNumber ), 0 ) )
return ( len( sTemp ) - 1 )
//---------------------------------------------
function prn_reset

set console off
set prin on
?? chr( 27 ) + chr( 64 )
set prin off
return .t.

function prn_lq

// bringing to LQ MODE
set prin on
?? chr( 27 ) + chr( 120 ) + "1"
set prin OFF
return .t.

function prn_draft

// bringing to DRAFT
set prin on
?? chr( 27 ) + chr( 120 ) + "0"
set prin OFF
return .t.

function prn_bigchar

set prin on
?? chr( 27 ) + chr( 87 ) + "1"
set prin off
return .t.

function prn_smallchar

set prin on
?? chr( 27 ) + chr( 87 ) + "0"
set prin off
return .t.
//---------------------------------------------
static function dosetvars( lChangeIS )

local nHandle := 0
local cBuffer := ""
setblink( .f. )
set scoreboard off
set century on
set date british
setcursor( 1 )

loadcmp( lChangeIS )

return nil
//********************
static function loadcmp( lChangeIS )

if lChangeIS = NIL
   lChangeIS := .f.
endif

dispend()

if !file( "INSTALL.INF" )
   c_loadit()       // SET RGB COLOR DEFINITION
endif

SLS_ISCOLOR( pcount() = 0 )
if SLS_ISCOLOR()
   SATTCOLOR()
else
   SATTMONO()
endif

vs_Mono( .f. )
vs_InitVern()       // Assume VS_900.DBF

public oFilter      // My Filter Condition ( it is a codeblock)
public cFilter

public scproc
public snline
public scvar

close all

env_check()         // SECURITY.PRG

setcolor( boxcolor() )

dispscrn()

return .t.

//------------------------------------------
exit procedure CLOSETHEDOOR             // make the burglar alarm ON, and

close all           // check if all the windows are closed...
set colo to W/N
set console on
set device to screen
set printer to
set printer off

dispend()
dispend()
dispend()
dispend()     // Clear any and all pending screen actions if any...
dispend()
dispend()
dispend()

if ExitMethod = 'Normal'
  clear
  ?
  ? "Logging out network connections... (if any)"
  ?
  UnLog()
  ? "Resetting screen..."
  jRemoveColor()

  ajfont( 0 )

  ?
  ? "Closing databases..."

  if .not. ErrorClose
     use (dir()+'\SYSTEM.EA')
     jFLock()
     replace all open with .f. for COMPANY = 'SYSTEM' + SystemId
     close all
  endif

  ?
  ? "Database Shutdown...Ok"
  gwChDir( dir() )
  if !ErrorClose
     dbf_io( .t. )
  endif
  gwDrive( StartDrive+":" )
  gwChDir( StartDir )

  if !file( 'DEBUG.DVP' )
     ?
     ? "End Run **" + _EasyAccounts + "**"
     ?
     ?
  else
     ?
     ?
     ? "Exit (Normal)"
     ?
     ? "Database Shutdown..Ok"
     ?
  endif
elseif ExitMethod != '--MISSING FILES--'
  clear
  ?
  ?
  ? _EasyAccounts+' Terminated'
  ?
  ?
endif
return .t.
//********************
/*
//     Old MODEL
// Now using GRUMP's INDEX BAR WITH progresssss baaaaaar

function indexfiles
if LogInfo()[NUMBER_OF_USERS] = 1
   SET EXCLUSIVE ON
   close all
   ontask('Recreating Index... Accounts')
   use accounts
   pack
   index on id      to ACC_1
   index on account to ACC_2
   ontask('Recreating Index... Bankbook')
   use bankbook
   dele all for amount=0
   pack
   DoReId()
   index on id      to BNK_1
   index on date    to BNK_2
   index on dtoc(date) + str(id,6,0) to BNK_3
   index on account to BNK_5
   index on b_id    to BNK_6
   ontask('Recreating Index... Cashbook')
   use cashbook
   dele all for amount=0
   pack
   DoReId()
   index on id      to CSH_1
   index on date    to CSH_2
   index on dtoc(date) + str(id,6,0) to CSH_3
   index on inv_id  to CSH_4
   index on account to CSH_5
   ontask('Recreating Index... Daybook')
   use daybook
   dele all for amount=0
   pack
   DoReId()
   index on id      to DBK_1
   index on date    to DBK_2
   index on dtoc(date) + str(id,6,0) to DBK_3
   index on account to DBK_4
   index on inv_id  to DBK_5
   index on account to DBK_6
   ontask('Recreating Index... Master')
   use master
   index on id      to MAS_1
   index on desc    to MAS_2
   ontask('Recreating Index... Sales')
   use sales
   pack
   index on id               to SALE_1
   index on item_id          to SALE_2
   ontask('Recreating Index... Purchase')
   use purchase
   pack
   index on id               to PRCH_1
   index on item_id          to PRCH_2
   *ontask('Recreating Index... Groups')
   *use groups
   *index on parent      to GROUP_1
   ontask('Recreating Index... Sales Summary')
   use saccount
   pack
   index on id          to SAC_1
   index on date        to SAC_2
   index on customer    to SAC_3
   ontask('Recreating Index... Purchase Summary')
   use paccount
   pack
   index on id          to PAC_1
   index on date        to PAC_2
   index on supplier    to PAC_3
   ontask()
   ontask('Recreating Index... Telephone List')
   use phone
   index on name        to PHONE_1
   ontask()
   ontask('Recreating Index... Sales Promoters List')
   use refrs
   index on id          to REFRS_1
   index on name        to REFRS_2
   ontask()
   ontask('Purging marked entries... Reference List')
   use sale_ref
   pack
   ontask()
   ontask('Recreating Index... Reference List')
   index on sale_id     to SREF_1
   index on refrs_id    to SREF_2
   close all
   ontask()
   SET EXCLUSIVE OFF
endif
return .t.
*/

static function ib( cKey, cFile )

indexbar( cFile, cKey )
return .t.

function indexfiles

// IB function is used as a gateway to INDEXBAR func. becuz
// Indexbar rcvs the parameters in the form of Database,Index Key
// but it was easy for me to convert the INDEX TO commands into
// Index Key,Database form
// So IB sends the parameters inverseley to INDEXBAR
if LogInfo() [NUMBER_OF_USERS] = 1
   set exclusive on
   close all
   use accounts
   pack
   ib( 'id', 'ACC_1' )
   ib( 'account', 'ACC_2' )

   use subheads
   pack
   ib( 'id', 'SUB_1' )
   ib( 'str(parent_id,5,0)+subhead', 'SUB_2' )
   ib( 'parent_id', 'SUB_3' )

   ontask( 'Updating bankbook...' )
   use bankbook
   dele all for amount = 0
   pack
   DoReId()
   ontask()

   ib( 'id', 'BNK_1' )
   ib( 'date', 'BNK_2' )
   ib( 'dtoc(date) + str(id,6,0)', 'BNK_3' )
   ib( 'account', 'BNK_5' )
   ib( 'b_id', 'BNK_6' )

   ontask( 'Clearing Cashbook...' )
   use cashbook
   dele all for amount = 0
   pack
   DoReId()
   ontask()

   ib( 'id', 'CSH_1' )
   ib( 'date', 'CSH_2' )
   ib( 'dtoc(date)+str(id,6,0)', 'CSH_3' )
   ib( 'inv_id', 'CSH_4' )
   ib( 'account', 'CSH_5' )

   ontask( 'Rewriting Daybook...' )
   use daybook
   dele all for amount = 0
   pack
   DoReId()
   ontask()

   ib( 'id', 'DBK_1' )
   ib( 'date', 'DBK_2' )
   ib( 'dtoc(date)+str(id,6,0)', 'DBK_3' )
   ib( 'account', 'DBK_4' )
   ib( 'inv_id', 'DBK_5' )
   ib( 'account', 'DBK_6' )

   use phone
   ib( 'name', 'PHONE_1' )

   use bookstat
   ib( 'date', 'BSTAT_1')

   if ReqServ()
      ** Service specific insertion.
      use service
      ib( 'ID', 'SRV_1' )
      ib( 'R_DATE', 'SRV_2' )
      ib( 'A_DATE', 'SRV_3' )
      ib( 'CUSTOMER', 'SRV_4' )
      ib( 'ACC_SUB', 'SRV_5' )
   endif

   if ReqInv()
      use master
      ib( 'id', 'MAS_1' )
      ib( 'desc', 'MAS_2' )

      use sales
      ontask( 'Packing sales...' )
      pack
      ontask()
      ib( 'id', 'SALE_1' )
      ib( 'item_id', 'SALE_2' )

      ontask( 'Packing purchase...' )
      use purchase
      pack
      ontask()
      ib( 'id', 'PRCH_1' )
      ib( 'item_id', 'PRCH_2' )
      ontask()

      ontask( 'Packing sales summary...' )
      use saccount
      pack
      ontask()
      ib( 'id', 'SAC_1' )
      ib( 'date', 'SAC_2' )
      ib( 'customer', 'SAC_3' )

      ontask( 'Packing Purchase summary...' )
      use paccount
      pack
      ontask()
      ib( 'id', 'PAC_1' )
      ib( 'date', 'PAC_2' )
      ib( 'supplier', 'PAC_3' )

      use batches
      ib( 'str(id,4,0)+str(cost,9,2)', 'BAT_1' )
      ib( 'str(id,4,0)', 'BAT_2' )

      use refrs
      ib( 'id', 'REFRS_1' )
      ib( 'name', 'REFRS_2' )

      ontask( 'Purging marked entries... Reference List' )
      use sale_ref
      pack
      ontask()
      ib( 'sale_id', 'SREF_1' )
      ib( 'refrs_id', 'SREF_2' )
      ontask()
   endif
   close all
   set exclusive OFF
endif
return .t.

function invrt_clr( cColor )

return subs( cColor, 7 ) + ',' + subs( cColor, 1, 5 )

function boxgetcolor
setcursor( 1 )
return 'W+/N*,W/R+,,,W+/N*'

function boxcolor

setcursor( 1 )
return 'W+/N*,W/R+'

function yBoxColor(nVal)
local cColor := ""
if nVal=NIL
  cColor := "W*/N+,W*/N+"
elseif nVal=1
  cColor := "GR*/N+,GR*/N+"
elseif nVal=3
  cColor := "R/W*,R/W*"
endif
setcursor( 1 )
return cColor

function nBoxColor
return 'N*/W+,W+/N*'

function menucolor

return 'N+/W+,W+/N*'

function noncolor

setcursor( 1 )
return 'W/N*,W/R+,,,W/N*'

function getcolor(nVal)
if nVAL = nil
 nVal := 1
endif
setcursor( 1 )
if nVal = 1
   return 'W+/R+,W+/R+,,,W+/R+'
endif
return 'W+/N*,W+/R+,,W+/R+'

function scrcolor

setcursor( 1 )
return 'N+/BG*,W+/R+'

function msgcolor

setcursor( 1 )
//return 'W+/BG,N+/R+'
return 'W+/B+,N+/W+'

function linecolor

setcursor( 1 )
return 'W+/N*,W+/R+'                    //'W/BG+'

function browcolor

setcursor( 1 )
return 'N/W+,W+/R+'                     //'W/BG+'

function footline( ROW, col, width )

row   := iif( row = nil, 21, row )
col   := iif( col = nil, 0, col - 1 )
width := iif( width = nil, maxcol(), width )
@ row, col say "Ã" + replicate( 'Ä', width ) + "´"
return nil

static function dointro()

local x
local y
local jx
local jy
setcolor( "N*/W+" )
setblink( .f. )
@  0,  0 say space( 80 )
@ 24,  0 say space( 80 )
jx := _EasyAccounts
jy := '(C) Wintech Computers'
x  := 1
for y := 1 to len( jy )
   @ 24,  0 say padc( subs( jy, 1, y ) + space( len( jy ) - y ), 79 )
   if !y > len( jx )
      @  0,  0 say padc( subs( jx, 1, y ), 79 )
   endif
   if !file( 'ONQ.CMP' )
      for x := 1 to 20000
      next x
   else
      for x := 1 to 12000
      next x
   endif
next y
return .t.
//---------------
function message( cMsg )

msg( cMsg )
return .t.
//---------------
function stockentry

return file( 'BEGIN.INV' )
//-----------------
function u_getpass

local nCount  := 1
local nResult
local xxb     := space( 10 )
local cUser   := "   "

UnLog()

set key K_F1 to
set key K_F5 to
set key K_F4 to GoDOS()
set key K_F6 to SysStatus()
*set key K_F7 to jSetFont()
set key K_F8 to vs_calc()
set key K_F9 to jCal()
set key K_F12 to aboutme()
set key K_ALT_M to

xUser     := "   "
xUsername := space( 10 )
jSaveenv()
dispscrn()

/*
if jBootNum() == 'Server not Licensed!'
   jAlert(jBootNum(), {'QUIT'})
   close all
   quit
endif
*/

setcolor( scrcolor() )
@ 09, 26 say padc( 'USER VERIFICATION', 48 - 23 )
setcolor( 'W+/N*,W+/N*' )
xx := makebox( 10, 26, 15, 50, 'W+/N*,W+/N*' )
MyCredits(0)
do while nCount < 3

   // use (dir()+'\users') new

   cUser := 'SUP'

   @ 11, 27 say "   User   Password  "
   footline( 13, 27, 23 )
   xxb := space( 10 )
   clear typeahead
   @ 12, 30 get cUser        pict '!!!'
   @ 12, 37 get xxb PASSWORD
   read
   xxb := rtrim( ltrim( upper( xxb ) ) )

   nResult := fPassword( cUser, xxb )

   if nResult = 1
      @ 14, 27 say padc( "Invalid Password!", 22 )
      tone( 0290, 1 )
      tone( 2900, 1 )
      tone( 0320, 1 )
      inkey( .3 )
      nCount ++
      @ 14, 27 say padc( "                    ", 22 )
   elseif nResult = 2
      @ 14, 27 say padc( "User Already Logged!", 22 )
      tone( 0290, 1 )
      tone( 2900, 1 )
      tone( 0320, 1 )
      inkey( .3 )
      @ 14, 27 say padc( "                    ", 22 )
      nCount ++
   elseif nResult = - 1
      @ 14, 27 say padc( "User Does Not Exist!", 22 )
      tone( 0290, 1 )
      tone( 2900, 1 )
      tone( 0320, 1 )
      inkey( .3 )
      @ 14, 27 say padc( "                    ", 22 )
      nCount ++
   else
      exit
   endif
enddo

MyCredits(1)

if !nResult = 0
   clear
   ?
   ? "Unauthorized access attempt."
   ?
   quit
endif

if cUser == 'SUP'
   setsp( .t. )
   set key K_ALT_M to ManagerLevel()
else
   setsp( .f. )
   set key K_ALT_M to UserLevel()
endif

set key K_F1 to pop_help()
set key K_F2 to changecomp()
set key K_F3 to u_getpass()
set key K_F4 to GoDOS()
set key K_F5 to pop_menu()
set key K_F6 to SysStatus()
set key K_F9 to jCal()
set key K_F10 to sup_special()
set key K_F12 to aboutme()

if sp_visor()
   set key K_ALT_M to ManagerLevel()
else
   set key K_ALT_M to UserLevel()
endif

jRestEnv()
setcolor( 'B*/W*' )
@ 24, 02 say "User : " + username() + space( 9 )
setcolor( boxcolor() )
setcursor( 0 )
return .t.
//--------------------------
function u_1scramble

local x := 'I'
local y := 'T'
local z := ''
z := x + y + 'S'
x := 'E'
z += x
z += 'A'
x := 'SY'
z += x
return z
//------------------------
function u_2scramble

local x := 'B'
local y := 'A'
local z := ''
z := x + y + 'S'
x := 'U'
z += x
z += 'R'
x := 'EJ'
z += x
x := 'A'
z += x
return z
//--------------------
function dir( cDir )

local cPath

*if !file( 'ONQ.CMP' )
   if cDir = NIL .or. empty( cDir )
      cPath := NetDrive + ':\EA\' + DataDir()
   else
      cDir := upper( cDir )
   endif

   if cDefaultDir <> NIL .and. cDefaultDir <> ""
      cPath := NetDrive + ":\EA\" + DataDir() + "\" + cDefaultDir
   endif

   if cDir = 'KOLLAM'
      cPath := NetDrive + ':\EA\' + DataDir() + '\KOLLAM'
   elseif cDir = 'PULLIMAN'
      cPath := NetDrive + ':\EA\' + DataDir() + '\PULLIMAN'
   elseif cDir = 'GRAPHICS'
      cPath := NetDrive + ':\EA\' + DataDir() + '\GRAPHICS'
   elseif cDir = 'ADM'
      cPath := NetDrive + ':\EA\' + DataDir() + '\ADM'
   elseif cDir = 'KBACK'
      cPath := NetDrive + ':\EA\' + DataDir() + '\KBACK'
   else
      //if cDir <> NIL
      //   cPath := NetDrive+':\EA\'+DataDir()+'\'+cDir
      //endif
   endif
*else
*   cPath := ft_default() + ":\" + curdir()
*   // Ft_Default returns the current drive, and curdir() returns current
*   // directory.
*endif

return cPath
//----------------------
function jSetDefault( desc )

use (dir()+'\SYSTEM.EA')
locate all for upper( rtrim( ltrim( COMP ) ) ) == rtrim( ltrim( upper( desc ) ) )
set default to ( NetDrive+':\EA\' + DataDir() + '\' + rtrim( ltrim( upper( DIR ) ) ) )
GwChDir( dir( rtrim( ltrim( upper( DIR ) ) ) ) )
jDDir( dir() + '\' + rtrim( ltrim( upper( DIR ) ) ) )
close all
return .t.
//------------------------
function checkclose( dDate )

if ac_closed( dDate )
   tone( 2200, 1 )
   tone( 3400, 1 )
   jAlert( 'BOOKS OF THIS DATE ALREADY CLOSED;;Cannot Add/Edit Entries' )
   return .f.
endif
return .t.
//--------------------
function prncheck

local x
if !isprinter()
   for x := 1 to 500
   next x
   if !isprinter()
      setcursor( 0 )
      set cursor off
      setcursor( .f. )
      ontask( 'Printer not ready! Correct or press ESC to abort' )
      tone( 1600, 1 )
      tone( 5100, 1 )
      do while !isprinter()
         if inkey() = K_ESC
            ontask()
            return .f.
         endif
      enddo
      ontask()
   endif
endif
return .t.
//----------------
function openbooks

local dDate := date() - 1
setcolor( scrcolor() )
@ 09, ( 79 / 2 - 12 ) say padc( 'Open Books', 25 )
setcolor( boxcolor() )
xx := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
@ 12, ( 79 / 2 ) - 12 + 3 say "Date :" get dDate
read
if jAlert('þ OPEN BOOKS - '+dtoc(dDate)+' þ;; Continue ?',{ "[No]", "[Yes]" } )==2
   doopen( dDate )
endif

return .t.
//--------------
function opened( cAdd )

local x
local yy
yy   := select()
cAdd := upper( rtrim( ltrim( cAdd ) ) )
use (dir()+'\SYSTEM.EA') new
locate all for rtrim( ltrim( upper( COMP ) ) ) = cAdd
if !found()
   x := .f.
elseif found()
   x := open
endif
use
if yy != NIL .and. !empty( yy )
   select( yy )
endif
return x
//-------------
function OpenDir( cAdd )
cAdd := upper( rtrim( ltrim( Comp_add ) ) )
use (dir()+'\SYSTEM.EA')
set exact off
locate all for rtrim( ltrim( upper( COMP ) ) ) = cAdd
jRLock()
field->open := .t.
jRUnLock()
close all
dbf_io( .f. )
return .t.
//------------
function closedatas( cAdd, lDbfIo )

if lDbfIo = NIL
   lDbfIo := .t.
endif

/*
close all
cAdd := upper(rtrim(ltrim(cAdd)))
if cAdd == 'PULLIMAN'
   cAdd := 'PULLIMAN JUN.'
endif
use (dir()+'\SYSTEM.EA')
locate all for rtrim(ltrim(upper(company)))=cAdd
replace open with .f.
close all
*/
plswait( .t., 'Closing databases...' )
if lDbfIo
   dbf_io( .t. )
endif
plswait( .f. )
//run ('attrib *.dbf +r')
return .t.
//------------
static function dbf_io( lProtect )

local aDir := directory( NetDrive+':*.DBF' )
local y

local handle
local first_byte
local buffer     := " "
local fn, lDoProt := logInfo()[1] = 1

return .f.   // Know WHY? It is dead slow in a network while loading the
// software.

for y := 1 to len( aDir )
   fn := dir() + "\" + rtrim( ltrim( aDir[ y ] [ 1 ] ) )
   if ( handle := fopen( fn, FO_READWRITE ) ) > - 1
      fread( handle, @buffer, 1 )
      first_byte := asc( buffer )
      fseek( handle, 0, 0 )
      if lProtect .and. lDoProt
         return .f.       // Never do any such thing in a Network!
         fwrite( handle, 'd' )
      else
         if file( subs( fn, 1, len( fn ) - 3 ) + '.FPT' ) .or. ;
                  fn == 'BOOKSTAT.DBF'  // memo file
            fwrite( handle, chr( 245 ), 1 )
         elseif file( subs( fn, 1, len( fn ) - 3 ) + '.DBT' )
            fwrite( handle, chr( 131 ), 1 )
         else
            fwrite( handle, chr( 03 ), 1 )
         endif
      endif
      fclose( handle )
   endif
next y
close all
return .t.
//--------------------------------
function exitassup
lJop := .f.
use (dir()+'\system.ea')
jFLock()
replace all open with .f.
quit
return .t.
//------------------
function expand( cString, nSpace )

local x         := 1
local cExpanded := ""
if nSpace = NIL
   nSpace := 1
endif
for x := 1 to len( cString )
   cExpanded += subs( cString, x, 1 ) + space( nSpace )
next x
return cExpanded
//-----------------
function changecomp

local aComps    := {}
local aReq      := {}
local jX
local nLine
local cCurDir   := curdir( NetDrive+":" )
local cCurComp  := comp_add
local aDirs     := {}
local aTitles   := {}
local aHeads    := {}
local aAdds     := {}
local aPrefixes := {}
local nSel
local xx
local xOldBox
local jnComps
local nnP       := 0
local lAddC
//================================
// This is a function which went through many tests of time.
// At first it was only 2 or 3 lines, but it acquired its present form
// through many stages of evolution.
//
// Naturally some complexities are likely to arise and there is one.
// I have implemented seperate arrays for different values of the
// same company. (aTitles,aHeads,aAdds,aPrefixes)
// All this could be included in a single array and that would be
// more easy to programme and memory friendly.
//
// But I cant just change it. Laziness. Let it be there!
//================================
*if file( 'ONQ.CMP' )
*   tone( 5302, 1 )
*   tone( 300, 1 )
*   tone( 3420, 1 )
*   jAlert( "Multiple Company Configuration unavailable" )
*   return .f.
*endif
set key K_F2 to
use (dir()+'\SYSTEM.EA')
count all for subs( comp, 1, 6 ) != 'SYSTEM' to jnComps
if jnComps = 0      // No Companies except system datas. Install a new one.
   lAddC := AddCompany()
   if lAddC = NIL .or. lAddC = .F.
      close all
      quit
   endif
   close all
   use (dir()+'\SYSTEM.EA')
endif
go top
do while .not. eof()
   if rtrim( ltrim( upper( company ) ) ) != 'SYSTEM'
      aadd( aComps, COMP )
      aadd( aPrefixes, PREFIX )
      aadd( aTitles, rtrim( ltrim( COMPANY ) ) + space( 8 ) )
      aadd( aDirs, DIR )
      aadd( aReq, {reqinv,reqserv} )
      aadd( aHeads, head )
      aadd( aAdds, { add1, add2, add3, ShowAdd, LSide1, LSide2, RSide1, RSide2, BillFoot } )
   endif
   skip
enddo
use
close all
do while .t.
   jSaveEnv()
   dispscrn()
   setcolor( scrcolor() )
   @ 04, 22 say padc( 'Select Company', 34 )
   setcolor( boxcolor() )
   @ 05, 22 clear to 16, 55
   @ 05, 22, 16, 55 box B_DOUBLE_SINGLE
   nSel := aPick( 05, 22, 16, 55, aComps, boxColor(), boxColor(), boxColor() )
   jRestEnv()
   if nSel = 0 .or. nSel = NIL
      close all
      tone( 3420, 1 )
      dispscrn()
      setcolor( boxcolor() )
      xOldBox := makebox( 08, 22, 15, 50, boxcolor() )

      @ 09, 24 say " ÛÛ  ** EasyAccounts"
      @ 10, 24 say " ÛÛ        v" + _EasyVer
      @ 11, 24 say " ÛÛ                 "

      @ 13, 24 say " ÛÛ "

      @ 12, 30 say 'SURE TO QUIT ?'
      @ 14, 34 prompt 'Yes'
      @ 14, 40 prompt 'No'
      tone( 4520, 1 )
      tone( 320, 1 )
      menu to nnP
      unbox( xOldBox )
      if nnP = 1
         close all
         quit
      else
         set key K_F2 to changecomp()
         cCurDir := rtrim( ltrim( cCurDir ) )
         if cCurDir = 'EA\'+DataDir()      // Have not loaded any company yet.
            loop
         else
            jSetDefault( cCurComp )
            return
         endif
      endif
   else
      exit
   endif
enddo

public comp_add := rtrim( ltrim( aComps[ nSel ] ) )
public gPrefix   := rtrim( ltrim( aPrefixes[ nSel ] ) )
public eaTitle   := rtrim( ltrim( aTitles[ nSel ] ) )
public eaHead    := rtrim( ltrim( aHeads[ nSel ] ) )        // for eg.Wintech Systems & Services
public eaAdd1    := rtrim( ltrim( aAdds[ nSel, 1 ] ) )
public eaAdd2    := rtrim( ltrim( aAdds[ nSel, 2 ] ) )
public eaAdd3    := rtrim( ltrim( aAdds[ nSel, 3 ] ) )
public eaShowAdd := aAdds[ nSel, 4 ]
public eaLeft1   := rtrim( ltrim( aAdds[ nSel, 5 ] ) )
public eaLeft2   := rtrim( ltrim( aAdds[ nSel, 6 ] ) )
public eaRight1  := rtrim( ltrim( aAdds[ nSel, 7 ] ) )
public eaRight2  := rtrim( ltrim( aAdds[ nSel, 8 ] ) )
public eaBill    := rtrim( ltrim( aAdds[ nSel, 9 ] ) )
public eaCompDir := rtrim( ltrim( aDirs[ nSel ] ))

reqInv_v    := aReq[ nSel, 1 ]
reqServ_v   := aReq[ nSel, 2 ]
cDefaultDir := aDirs[ nSel ]
OpenDir()
set key K_F2 to changecomp
if comp_add = 'Administration'
   plswait( .t., 'Opening accounts...' )
   use (dir()+'\SYSTEM.EA')
   go top
   for x := 1 to reccount()
      gwChDir( dir() + '\' + dir )
      set default to ( dir() + '\' + dir )
      *if LogInfo() [1] = 1
         OpenDir()
      *endif
      use (dir()+'\SYSTEM.EA')
      go x
      skip
   next x
   set default to ( dir() + '\' + aDirs[ nSel ] )
   gwchDir( dir() + '\' + aDirs[ nSel ] )
   plswait( .f. )
endif
close all
downclose( .t. )
keyboard chr( K_ENTER )
keyboard chr( K_ESC )
gwDrive( NetDrive+":" )
set default to ( NetDrive+':\EA\' + DataDir() + '\' + aDirs[ nSel ] )
gwchDir( dir() + '\' + aDirs[ nSel ] )
return .t.
//------------------
function downclose( lDo )

static downed := .f.
if lDo != NIL
   downed := lDo
endif
return downed
//------------------
function openAll

local a := {}
local y
if ljOp
   close all
   use (dir()+'\SYSTEM.EA')
   do while .not. eof()
      aadd( a, dir )
      skip
   enddo
   for y := 1 to len( a )
      set default to ( dir() + "\" + a[ y ] )
      gwchDir( dir() + '\' + a[ y ] )
      OpenDir( a[ y ] )
   next y
endif
return .t.
//------------------
function closeall

local a := {}
local y
if ljOp
   close all
   use (dir()+'\SYSTEM.EA')
   do while .not. eof()
      aadd( a, dir )
      skip
   enddo
   for y := 1 to len( a )
      set default to ( dir() + "\" + a[ y ] )
      gwchDir( dir() + '\' + a[ y ] )
      closedatas( a[ y ] )
   next y
endif
return .t.
//---------------
/*
function openall
set default to (dir()+'\ADM')
gwchDir(dir()+'\ADM')
OpenDir('Administration')

set default to (dir()+'\GRAPHICS')
gwchDir(dir()+'\GRAPHICS')
OpenDir('Graphics')

set default to (dir()+'\PULLIMAN')
gwchDir(dir()+'\PULLIMAN')
OpenDir('Pulliman Jun.')

set default to (dir()+'\MICROS')
gwchDir(dir()+'\MICROS')
OpenDir('Micros')

set default to (dir()+'\KOLLAM')
gwchDir(dir()+'\KOLLAM')
OpenDir('Kollam')

return .t.
*/
//----------------------
function reqinv(lReCheck)
local cOldA
if lReCheck != NIL .and. (lReCheck)
   cOldA := select()
   use (dir()+'\SYSTEM.EA') NEW ALIAS SysNew  // (Sometimes SYSTEM.EA might be already opened.)
   locate all for alltrim(upper(comp))==alltrim(upper(comp_add))
   ReqInv_v := ReqInv
   use
   select (cOldA)
endif
return iif(reqinv_v=NIL,.t.,reqinv_v)
//---------------------
function reqserv(lReCheck)
local cOldA
if lReCheck != NIL .and. (lReCheck)
   cOldA := select()
   use (dir()+'\SYSTEM.EA') NEW ALIAS SysNew  // (Sometimes SYSTEM.EA might be already opened.)
   locate all for alltrim(upper(comp))==alltrim(upper(comp_add))
   ReqServ_v := ReqServ
   use
   select (cOldA)
endif
return iif(ReqServ_v=NIL,.t.,reqserv_v)
//--------------------------------------------------------------

function SCRCENTER( row, msg, width, color )

if width = NIL
   width := maxcol()
endif
if msg = NIL
   return .F.
endif
if color = NIL
   color := setcolor()
endif
devpos( row, int( ( width - len( msg ) ) / 2 ) )
devout( msg, color )
return ( int( ( width - len( msg ) ) / 2 ) ) + len( msg )
//==========================================
function jAlert( cMessage, aOptions, cColor )

local aMessages
local nMessages
local nMsgWidth := 0
local cScreen
local nOCol     := col()
local nORow     := row()
local cOldColor := setcolor()
local nOptions
local nActive   := 1
local lDone     := .F.
local aTriggers
local nPrompt
local nWidth
local nTop
local nLeft
local nRight
local nKey
local nScan
local n
local nMidrow   := int( maxrow() / 2 )

//ÄÄÄÄÄ check for semi-colons in message, which would indicate multi-lines
if ( n := at( ";", cMessage ) ) > 0
   aMessages := {}
   do while n > 0
      aadd( aMessages, substr( cMessage, 1, n - 1 ) )
      nMsgWidth := max( nMsgWidth, len( atail( aMessages ) ) )
      cMessage  := substr( cMessage, n + 1 )
      n         := at( ";", cMessage )
   enddo
   nMsgWidth := max( nMsgWidth, len( cMessage ) )
   aadd( aMessages, cMessage )
else
   aMessages := { cMessage }
   nMsgWidth := len( cMessage )
endif
nMessages := len( aMessages )

if aOptions == NIL
   aOptions := { "Ok" }
endif
nOptions := len( aOptions )
nPrompt  := 1 + len( aOptions[ 1 ] )

aTriggers := { upper( left( aOptions[ 1 ], 1 ) ) }

aeval( aOptions, { | o | aadd( aTriggers, upper( left( o, 1 ) ) ), ;
                   nPrompt := nPrompt + 4 + len( o ) }, 2 )

nWidth  := max( nPrompt + 1, nMsgWidth )
nLeft   := int( ( maxcol() + 1 ) / 2 ) - 4 - ( int( nWidth ) / 2 )
nRight  := nLeft + nWidth + 8
nPrompt := int( ( maxcol() - nPrompt ) / 2 )
nTop    := nMidrow - int( ( nMessages + 1 ) / 2 ) - 1

cScreen := savescreen( nTop - 2, nLeft - 4, nTop + nMessages + 8, nRight + 3 )

if cColor == NIL
  cColor := msgcolor()
endif

setcolor( cColor )

Makebox( nTop, nLeft, nTop + nMessages + 3, nRight, cColor )

for n := 1 to nMessages
   scrcenter( nTop + n, aMessages[ n ], maxcol() + 1 )
next
setcursor( .f. )
setcursor( 0 )
set cursor off

set device to screen
set printer off
set printer to

while .not. lDone
   setpos( nTop + nMessages + 2, nPrompt )
   for n := 1 to nOptions
      if n = nActive
         setcolor( getcolor() )
      else
         setcolor( cColor )
      endif
      dispout( " " + aOptions[ n ] + " " )
      setcolor( cColor )

      if n < nOptions
         dispout( "  " )
      endif
   next

   setcursor( 0 )
   set cursor off
   dispend()
   dispend()
   dispend()
   nKey := rat_event( 0 )

   do case
   case nKey == K_ESC
      nActive := 0
      lDone   := .T.
   case nKey == K_ENTER
      lDone := .T.
   case nKey == K_RIGHT
      if ++ nActive > nOptions
         nActive := 1
      endif
   case nKey == K_LEFT
      if -- nActive < 1
         nActive := nOptions
      endif
   otherwise
      nScan := ascan( aTriggers, upper( chr( nKey ) ) )
      if nScan > 0
         lDone   := .T.
         nActive := nScan
      endif
   endcase
enddo

restscreen( nTop - 2, nLeft - 4, nTop + nMessages + 8, nRight + 3, cScreen )
@ nORow, nOCol say ""
setcolor( cOldColor )
setcursor( 1 )
setcursor( .t. )

return nActive
//---------------------------
function jSaveEnv

local x        := 1
local yy       := {}
local xx
local aDbfs
local aActInd
local aFilters
local nActWork
local aRecord
aadd( aaCursor, setcursor() )
aadd( aaGets, getlist )
aRecord  := {}
aDbfs    := {}
aActInd  := {}
aFilters := {}
aadd( anActWork, select() )

do while !empty( alias( x ) )
   select( alias( x ) )
   xx := 1
   yy := {}
   do while !empty( ordbagname( xx ) )
      aadd( yy, ordbagname( xx ) )
      xx ++
   enddo
   aadd( aDbfs, { alias( x ), yy } )
   aadd( aRecord, recno() )
   x ++
enddo
aadd( aaDbfs, aDbfs )
x := 1
if len( aDbfs ) > 0
  do while !x > len( aDbfs )
     select( aDbfs[ x, 1 ] )
     aadd( aFilters, dbfilter() )
     aadd( aActInd, indexord() )
     x ++
  enddo
else
  aadd( aFilters, "" )
  aadd( aActInd, "" )
endif

aadd( aaFilters, aFilters )
aadd( aaActInd, aActInd )
aadd( aaScreen, { savescreen( 0, 0, 24, 79 ), row(), col(), setcolor() } )
aadd( aaRecord, aRecord )
return .t.
//-----------------------------
function jRestEnv

local x     := 1
local yy    := 1
local jTemp
close all
restscreen( 0, 0, 24, 79, aaScreen[ len( aaScreen ), 1 ] )
@ aaScreen[ len( aaScreen ), 2 ], aaScreen[ len( aaScreen ), 3 ] say ""
getlist := aaGets[ len( aaGets ) ]
asize( aaGets, len( aaGets ) - 1 )
setcursor( aaCursor[ len( aaCursor ) ] )
asize( aaCursor, len( aaCursor ) - 1 )
setcolor( aaScreen[ len( aaScreen ), 4 ] )
if len( aaDbfs ) > 0
   do while !x > len( aaDbfs[ len( aaDbfs ) ] )
      use (aaDbfs[len(aaDbfs),x,1]) new
      yy := 1
      do while .not. yy > len( aaDbfs[ len( aaDbfs ), x, 2 ] )
         dbsetindex( aaDbfs[ len( aaDbfs ) ] [ x, 2, yy ] )
         yy ++
      enddo
      x ++
   enddo
   x := 1
   do while !x > len( aaDbfs[ len( aaDbfs ) ] )
      select( aaDbfs[ len( aaDbfs ) ] [ x, 1 ] )
      if !empty( rtrim( ltrim( aaFilters[ len( aaFilters ), x ] ) ) )
         *jTemp := &( "{||" + aaFilters[ len( aaFilters ), x ] + "}" )
         cmFilter( aaFilters[ len( aaFilters ), x ] )

         //********************************************************
         //     dbGoTop()
         // GRAVE MISTAKE. IF the filter condition contains a LOCAL,
         // then it WILL generate an error as the variable is not
         // present in this context. Also, there is no need
         // for such a stupidity here. Sometimes, man is more
         // much foolish than animal.
         //
         // The old record is automatically positioned when the
         // go aaRecord is done below.
         //*******************************************************
      endif
      if !aaActInd[ len( aaActInd ), x ] = 0
         set order to (aaActInd[len(aaActInd),x])
      endif
      go aaRecord[ len( aaRecord ), x ]
      x ++
   enddo
endif
if len( anActWork ) > 0
   select( anActWork[ len( anActWork ) ] )
   asize( anActWork, len( anActWork ) - 1 )
endif
if len( aaFilters ) > 0
   asize( aaFilters, len( aaFilters ) - 1 )
endif
if len( aaActInd ) > 0
   asize( aaActInd, len( aaActInd ) - 1 )
endif
if len( aaDbfs ) > 0
   asize( aaDbfs, len( aaDbfs ) - 1 )
endif
if len( aaScreen ) > 0
   asize( aaScreen, len( aaScreen ) - 1 )
endif
if len( aaRecord ) > 0
   asize( aaRecord, len( aaRecord ) - 1 )
endif
return .t.
//===========================
function plswait( lBoxOn, cMessage, nTop, nLeft, nBottom, nRight )

local cInColor
local nLenMessage
local nOldRow     := row()
local nOldCol     := col()
local NoldP1      := prow()
local noldp2      := pcol()

static nsTop
static nsLeft
static nsBottom
static nsRight
static cUnder

if !valtype( cMessage ) == "C"
   cMessage := "Please wait..."
endif

nLenMessage := min( len( cMessage ), 76 )
cMessage    := left( cMessage, nLenMessage )

if lBoxOn
   if nsTop != NIL
      plswait( .f. )
      // Unload that message first.
   endif
   if nTop # nil .and. nLeft # nil .and. nRight # nil .and. nBottom # nil
      nsTop    := nTop
      nsLeft   := nLeft
      nsBottom := nBottom
      nsRight  := nRight
   else
      nsTop    := 10
      nsBottom := 12
      nsLeft   := int( ( 79 - nLenMessage ) / 2 - 1 )
      nsRight  := nsLeft + nLenMessage + 2
   endif
endif
if lBoxOn
   cInColor := setcolor()
   cUnder   := makebox( nsTop, nsLeft, nsBottom, nsRight, sls_popcol() )
   @ nsTop + 1, nsLeft + 1 say cMessage color sls_popcol()
   setcolor( cInColor )
else
   if cUnder != NIL
      unbox( cUnder )
      cUnder   := nil
      nsTop    := nil
      nsLeft   := nil
      nsBottom := nil
      nsRight  := nil
   endif            // Else comes errors SUBSTR VRooooooom..
endif
@ nOldRow, nOldCol say ""
setprc( noldp1, noldp2 )
return (cUnder!=NIL)

/*
//===============================
FUNCTION plswait(lBoxOn,cMessage,nTop,nLeft,nBottom,nRight)
local  cInColor,nLenMessage

static nsTop := {},nsLeft := {},nsBottom := {},nsRight := {},cUnder := {}

IF !VALTYPE(cMessage)=="C"
  cMessage := "Please wait..."
ENDIF

nLenMessage := MIN(LEN(cMessage),76)
cMessage    := LEFT(cMessage,nLenMessage)

IF lBoxOn
  IF nTop#nil.and. nLeft#nil .and. nRight#nil .and. nBottom#nil
    aadd(nsTop,nTop)
    aadd(nsLeft,nLeft)
    aadd(nsBottom,nBottom)
    aadd(nsRight,nRight)
  ELSE
    aadd(nsTop,10)
    aadd(nsBottom, 12)
    aadd(nsLeft,INT((79-nLenMessage)/2 - 1))
    aadd(nsRight,nsLeft[len(nsTop)]+nLenMessage+2)
  ENDIF
ENDIF
IF lBoxOn
  cInColor  := Setcolor()
  aadd(cUnder,makebox(nsTop[len(nsTop)],nsLeft[len(nsLeft)],nsBottom[len(nsBottom)],nsRight[len(nsRight)],sls_popcol()))
  @nsTop[len(nsTop)]+1,nsLeft[len(nsTop)]+1 SAY cMessage color sls_popcol()
  Setcolor(cInColor)
ELSE
 if len(nsTop)>1
  unbox(cUnder[len(nsTop)])
  asize(cUnder,len(nsTop)-1)
  asize(nsTop,len(nsTop)-1)
  asize(nsLeft,len(nsTop)-1)
  asize(nsBottom,len(nsTop)-1)
  asize(nsRight,len(nsTop)-1)
 endif
ENDIF
RETURN ''
//--------------------------------
*/
function fPassword( cUser, cPass )

local lRet
use (dir()+'\users') new

locate all for user == cUser
if found()
   if jEncrypt(padr(alltrim(upper(cPass)),10), "This is EasyAccounts PRO.. by Jasim" )  == USERS->PASSWORD
      if user == 'SUP'
         setsp( .t. )
      endif
      sele users
      xUser     := users->user
      xUserName := rtrim( ltrim( users->username ) )
      if !Logged
         jRLock()
         field->logged := .t.
         jRUnLock()
         lRet := 0
      else
         xUser     := space( 3 )
         xUserName := space( len( users->username ) )
         lRet      := 2
      endif
   else
      lRet := 1
   endif
else
   lRet := - 1
endif
use
return lRet
//---------------------------------------------------
//*************************
// IMPORTANT COMMENT :
// Do not change the 'EasyAccounts v1.5' to '2.1' or newer version numbers
// as it is the password encryption/decryption key and can affect
// the passwords of the users and they wont be able to access the
// program.
//**************************
function jEncrypt( cPass, cKey )

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
function jDecrypt( cPass, cKey )

local x := ""
local y
local z := ""
// See Comment Above jEncrypt
if cKey == NIL
   cKey := "EasyAccounts v1.5"
endif
cPass := gwDecrypt( cPass, cKey )
for y := 1 to len( cPass )
   x += chr( asc( subs( cPass, y, 1 ) ) + ( y * 2 ) )
next y
for y := 1 to len( x )
   z += chr( asc( subs( x, y, 1 ) ) + ( y * 2 ) )
next y
return z
//====================================================
init procedure SETVARS

local lStart := .t.

public NetDrive := ""

set score off
setcancel( .f. )

if type('ExitMethod') == 'U'     // Means it has'nt been defined.
   public ExitMethod := "Normal" // Chance of defining it in SECURITY.PRG
endif

StartDrive := gwDrive()
StartDir   := curdir()

/*
public _EasyAccounts := "EasyAccounts v4.0 PRO"
public _EasyVer      := "4.0 PRO"
*/

// NOW, the _EasyAccounts variables etc. are being kept in SECURITY.PRG
// due to, 'security' reasons :) 

public _EasyAccounts := "EasyAccounts"
public _EasyVer      := ""

public _bEasyKey     := {|| ;
     alltrim(str( USERS->(recno()) )) + subs(jBootNum(),2,3) + subs(jBootNum(),6,7) + "EasyAccounts by Jasim" }

public lHandleHot
public lIsMouse
public mouserow   := 0
public mousecol   := 0                  // SUPER VARIABLES
public nLastEvent := 0

public __aTypes:= { 'Assets - Current', ;   // 1   D
                    'Fixed Assets',;        // 2   D
                    'Bank',;                // 3   D
                    'Expense',;             // 4   D
                    'Income',;              // 5   C
                    'Tax Collected',;       // 6   C
                    'Purchase',;            // 7   D
                    'Sales',;               // 8   C
                    'Sundry Creditor',;     // 9   C
                    'Debtor',;              // 10  D
                    'Capital',;             // 11  C
                    'Staff Loan',;          // 12  D
                    'Associate',;           // 13  C
                    'Standby',;             // 14  C
                    'Replacement',;         // 15  C
                    'BDE',;                 // 16  D
                    'Service Engg.',;       // 17  D
                    'Loans Received',;      // 18  C
                    'Deposit' }            // 19  D

public __aDrCrs := { 'D', 'D', 'D', 'D', 'C', 'C', 'D', 'C', 'C','D','C','D','C','C','C','D','D','C', 'D'}

public __aTypeDescs := { "Assets - Current",;
"Fixed Assets",;
"Bank Accounts",;
"Expenses",;
"Income A/Cs",;
"Tax Collected",;
"Purchase A/Cs",;
"Sales A/Cs",;
"Sundry Creditors",;
"Sundry Debtors",;
"Capital A/Cs",;
"Staff Loan A/Cs",;
"Associates",;
"Standby A/Cs",;
"Replacement A/Cs",;
"B.D.E A/Cs",;
"Service Engg. A/Cs",;
"Loan A/Cs",;
"Deposit A/Cs" }

public dDate   := date()  // Global Date. ( SHOULD CHANGE USING A FUNC. ONLY)

? _EasyAccounts+ " [ Accounts Made Easy! ]"
?
? "þ (C) Wintech Group. All rights reserved."
?
? "(DPMI/VCPI/XMS compatible)"
? "      Free Memory Available : " + rtrim( ltrim( str( bliMemAvl() / 10 ^ 6, 10, 2 ) ) ) + " MB"
? "      Free Conventional Memory : " + rtrim( ltrim( str( memory( 2 ), 10, 0 ) ) ) + " KB"
?
? 'Hosting application...'
?

setblink( .f. )

set exclusive OFF

if file( 'NETWORK.DAT' )
   use Network.DAT
   NetDrive := drive
   public SystemId := SysId
   public RepPath  := alltrim(WorkPath)+'\'
else
   NetDrive := ft_default()
   public SystemId := "_0"
   public RepPath := ".\"
endif

if file( 'CONFIG.EA' )
   use CONFIG.EA
   DataDir := alltrim(upper(PathDir))
   use
else
   DataDir := '02'
endif

public gPrefix := iif( file( 'CUSTOM.SYS' ), "EA", "WSS" )

gwDrive( NetDrive + ":" )
set default to ( dir() )
gwChDir( dir() )
run( NetDrive+":" )
run( 'CD\EA\' + DataDir() )

if ! ( file('SYSTEM.EA') .and. file('USERS.DBF') )
   ?
   ? 'ERROR: Required files missing! Cannot load EA...'
   ? '(Configured Directory: '+NetDrive+':\EA\'+DataDir()+')'
   ?
   ?
   ExitMethod := '--MISSING FILES--'
   quit
endif

env_check()         // SECURITY.PRG

dbf_io( .f. )
comp_add := GPrefix + " Login"

uOpen( NetDrive+":\EA\" + DataDir() + "\USERS.DBF" )

public osch := "           "

LoadConfig()

OpenUsers()

*if !file( 'ONQ.CMP' )
   if opened( 'SYSTEM' + SystemId )
      if !jAlert( 'Previous session of EA v' + _EasyVer + ' already active;;', { 'Exit', 'Force Continue' } ) = 2
         ljOp       := .f.
         ErrorClose := .t.
         dbf_io( .t. )
         quit
      endif
   endif

   use (dir()+'\SYSTEM.EA')
   jFLock()
   replace all open with .t. for COMPANY = 'SYSTEM' + SystemId
   go top
   locate all for COMPANY = 'SYSTEM' + SystemId
   /*
   if count < 31
      field->count := count + 1
   endif
   nnCount := count
   */
   ljOp := .t.
   close all

   ErrorClose := .f.
   ? 'Starting database...'
   ?
   openall()

   dispbegin()
   dosetvars( .t. )
   p_rdydelay( .1 )
   rat_ehh( .t. )
   comp_add := 'LOG ON'
   clear

   dispbegin()
   dispscrn()
   dispend()

   dispscrn()
   dispend()
   dispend()

   /*
   #ifndef DEBUG
     DEFINE BACKGROUNDEVENT ACTION GT_Shufl() NAME "ScreenSav" INTERVAL 360
     // 360/60 = 6 Minutes. Interval is 6 Minutes.
     BACKGROUND EVENTS AUTOACTIVATE
     BACKGROUND EVENTS START
   #endif
   */

   if u_getpass()
      do while .t.
         dispend()
         if !downclose()
            downclose( .f. )
            comp_add := 'LOG ON'
            set key K_F2 to
            changecomp()
            downclose( .f. )
         else
            downclose( .f. )
         endif
         dosetvars( .t. )
         pullMenu()
      enddo
      quit
   else
      set colo to w/n
      clear
      ? 'Unauthorized access attempt.'
      ? '****************************'
      //closeall()
      quit
   endif
/*
else
   eUse( dir() + "\system.ea" )
   repl all OPEN with .T.
   go bott
   comp_add    := rtrim( ltrim( company ) )
   reqInv_v    := ReqInv
   cDefaultDir := "."
   close all
   eUse( dir() + "\users" )
   repl all LOGGED with .f.

   dosetvars( .t. )
   ? 'Starting database...'
   dbf_io( .f. )
   dispbegin()
   p_rdydelay( .1 )
   rat_ehh( .t. )
   dispscrn()
   dispend()
   dispend()
   if u_getpass()
      pullMenu()
   endif
endif
*/
return .t.
//-----------
function pop_help
local x
local xHelp
xHelp := makebox( 02, 01, 22, 42, boxcolor() )
setcolor( scrcolor() )
@ 03, 02 say padc( 'POPUP KEYS HELP', 40 )
setcolor( boxcolor() )
footline( 4, 02, 40 )
x := -2
@ 07+x, 06 say "þ F1   - This Screen"
@ 08+x, 06 say "þ F2   - Change Company"
@ 09+x, 06 say "þ F3   - Users"
@ 10+x, 06 say "þ F4   - DOS Prompt"
@ 11+x, 06 say "þ F5   - Actions Menu"
@ 12+x, 06 say "þ F6   - Show Memory Status"

// @ 13+x, 06 say "þ F7   - Change Screen Font"

@ 14+x, 06 say "þ F8   - Calculator"
@ 15+x, 06 say "þ F9   - Calendar"
if sp_visor()
   @ 16+x, 06 say "þF10   - Manage Users"
   if reqInv()
      @ 17+x, 06 say "þF11   - Batch Details"
   endif
   @ 18+x, 06 say "þF12   - About"
   @ 19+x, 06 say "þALT+M - MIS Reports"
   @ 21+x, 06 say "þALT+R - Create and run an HTML for"
   @ 22+x, 06 say "         the current browse window."
else
   @ 16+x, 06 say "þF11   - Batch Details"
   @ 17+x, 06 say "þF12   - About"
   @ 18+x, 06 say "þALT+M - MIS Menu"
   @ 20+x, 06 say "þALT+R - Create and run an HTML for"
   @ 21+x, 06 say "         the current browse window."

endif
setcursor( 0 )
inkey( 0 )
unbox( xHelp )
return .t.
//---------------
function username
return rtrim( ltrim( xUserName ) )
//-------------------------------------
function user
return xUser
//--------------------------------------
function dispuser

local x := setcolor( 'B*/W*' ), oldrow := row(), oldcol := col()
@  0, 02 say padr( 'Entry:' + uName( iif(user() != 'ADM', user, 'ADM') ), 16 )
setcolor( x )
@ oldrow, oldcol say ""
return .t.
//===============
function uName( cC )

local cN := ascan( aUsers, { | cUA | cUA[ 1 ] == cC } )
if cN = 0
   cN := "Auto"
else
   cN := rtrim( ltrim( aUsers[ cN, 2 ] ) )
endif
return cN
//==============
function sameuser

local lVal
if user() = 'SUP' .or. user() == 'ADM'       // NO SORT of a user-oriented
                                             // entry should be shown while
                                            //  using ADM.. those Tax people should not know
                                             // there are other users..
   lVal := .t.
else
   if user == user()
      lVal := .t.
   else
      lVal := .f.
   endif
endif
return lVal
//===================
function chnpword

local cOld    := space( 10 )
local cNew    := space( 10 )
local nResult
local cRt     := space( 10 )
use (dir()+'\users')
locate all for user == user()
if !found()
   jAlert( 'User Registry Error' )
else
   dispscrn()
   setcolor( scrcolor() )
   @ 09, 24 say padc( 'CHANGE PASSWORD', 56 - 23 )
   setcolor( 'W+/N*,W+/N*' )
   makebox( 10, 24, 16, 56, 'W+/N*,W+/N*' )

   @ 11, 25 say "Old Password : " get cOld pict '@!' PASSWORD
   @ 12, 25 say "New Password : " get cNew pict '@!' PASSWORD
   @ 13, 25 say "Retype       : " get cRT  pict '@!' PASSWORD
   footline( 14, 25, 56 - 25 )
   read
   cOld := rtrim( ltrim( upper(cOld) ) )
   cNew := rtrim( ltrim( upper(cNew) ) )
   cRT  := rtrim( ltrim( upper(cRT) ) )
   if !cNew == cRT
      @ 15, 25 say padc( "Retyped Password Mismatches", 56 - 27 )
      tone( 0290, 1 )
      tone( 2900, 1 )
      tone( 0320, 1 )
      inkey( .3 )
      @ 15, 25 say padc( "                    ", 56 - 27 )
      return
   endif
   if ! jEncrypt( padr(alltrim(cOld),10), "This is EasyAccounts PRO.. by Jasim" ) == password
      @ 15, 25 say padc( "Old Password Invalid", 56 - 27 )
      tone( 0290, 1 )
      tone( 2900, 1 )
      tone( 0320, 1 )
      inkey( .3 )
      @ 15, 25 say padc( "                    ", 56 - 27 )
   else
      if !subs( cNew, 1, 1 ) = ' '
         if jAlert( 'PASSWORD CHANGE;; Sure to Save ?', { 'Yes', 'No' } ) = 1
            jRLock()
            field->password := jEncrypt( padr(rtrim( ltrim( upper( cNew ) ) ),10), "This is EasyAccounts PRO.. by Jasim" )
            jRUnLock()
            jAlert( 'Password Successfully Changed!', { 'Continue' } )
         else
            jAlert( 'Password change aborted.' )
         endif
      else
         @ 15, 25 say padc( "Cannot accept blank password", 56 - 27 )
         tone( 0290, 1 )
         tone( 2900, 1 )
         tone( 0320, 1 )
         inkey( .3 )
         @ 15, 25 say padc( "                    ", 56 - 27 )
         jAlert( 'Password change aborted.' )
      endif
   endif
   dispscrn()
endif
close all
setcursor( 0 )
return .t.
//---------------------------
function jdDir( cDef )

if cDefaultDir = NIL
   cDefaultDir := ""
endif
if !cDef = NIL
   cDefaultDir := cDef
endif
return rtrim( ltrim( upper( cDefaultDir ) ) )
//--------------------------
function aboutme

local xAbout
local nn
jSaveEnv()
xAbout := makebox( 03, 15, 20, 60, boxcolor() )
setcursor( 0 )
setcolor( scrcolor() )
@ 04, 16 say padc( "About EA v" + _EasyVer, 60 - 16 )
setcolor( boxcolor() )
footline( 5, 16, 60 - 16 )
@ 06, 17 say "*" + _EasyAccounts + " (Network Edition)*"
//@ 07,17 say "         Featuring Quick Access Popup Menu"
setcolor( msgcolor() )
@ 08, 17 say "Developed by :"
setcolor( boxcolor() )
@ 10, 17 say "Jasim A Basheer"
@ 12, 17 say "Visit me at: www.jabpaacet.blogspot.com"
@ 13, 17 say "     e-mail: jasim.ab@gmail.com"
//@ 12, 17 say "Phone : (0476) 2620146, 2621855"
//@ 13, 17 say "e-mail:info@wintechgroup.com"
//@ 14, 17 say "Visit us at : www.wintechgroup.com"
setcolor( invrt_clr( boxcolor() ) )
@ 16, 28 say "Press a key..."
setcolor( boxcolor() )
footline( 18, 16, 60 - 16 )
setcursor( 0 )
moveLR( { 'Simpler...', 'Easier...', ;
          'Powerful and Flexible...', ;
          "More than Accounting, it is EasyAccounting!  ", ;
          _EasyAccounts + ' (With Network Support)' }, 19, 16, 60 - 16 )

inkey( 0 )          // a keyboard K_ENTER should be pending if moveLR is to terminate.
// so to absorb that thing.

setcursor( 0 )
unbox( xAbout )
jRestEnv()
return .t.
//---------------
function moveLR( msgs, row, col, width )

local x  := 1
local y
local yy
do while nextkey() == 0
   for x := 1 to len( msgs )
      for y := 1 to len( msgs[ x ] )
         if x = 1 .or. x = 4 .or. x = 7
            @ row, col say padl( space( width / 2 - len( subs( msgs[ x ], 1, y ) ) / 2 ) + subs( msgs[ x ], 1, y ), width )
         elseif x = 2 .or. x = 5 .or. x = 8
            @ row, col say padc( subs( msgs[ x ], 1, y ), width )
         elseif x = 3 .or. x = 9
            @ row, col say padr( subs( msgs[ x ], 1, y ), width )
         endif
         yy := 1
         do while ( yy != 14000 .and. nextkey() == 0 )
            yy ++
         enddo
      next y
      do while ( yy != 142000 .and. nextkey() == 0 )
         yy ++
      enddo
   next x
enddo
return .t.
//-------------------
function pwordlist

local xHelp := makebox( 03, 01, 15, 36 )
setcolor( scrcolor() )
@ 04, 02 say padc( 'PASSWORDS LIST', 34 )
setcolor( boxcolor() )
footline( 5, 02, 34 )
use (dir()+'\USERS')
@ 06, 04 say 'ID'
@ 06, 10 say 'User Name'
@ 06, 22 say 'Password'
do while .not. eof()
   @ 06 + recno(), 04 say user
   @ 06 + recno(), 10 say username
   @ 06 + recno(), 22 say padr( jDecrypt(  password , "This is EasyAccounts PRO.. by Jasim" ), 10 )
   skip
enddo
setcursor( 0 )
inkey( 0 )
unbox( xHelp )
return .t.
//---------------
/*
ÕìÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
³ FUNCTION XBXX()
ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
³
³  Short:
³  ------
³  XBXX() Draws an exploding box on the screen of a given color
³
³  Returns:
³  --------
³  Nothing
³
³  Syntax:
³  -------
³  XBxx(nTop,nLeft,nBottom,nRight,[nColor],[nShadow];
³                      [nShadowColor],[cFrame])
³
³  Description:
³  ------------
³  <nTop >      - top row
³  <nLeft>      - left col
³  <nBottom>    - bottom row
³  <nRight>     - right column
³  [nColor]     - attribute to box default setcolor()
³  [nShadow]    - numeric shadow type  (default 0)
³                    follow numeric keypad
³                        7 = upper left
³                        1 = lower left
³                        3 = lower right
³                        9 = upper right
³                        0 = no shadow
³
³  [nShadowColor]   - shadow attribute (default 7 - grey on black)
³
³  [cFrame ]    - frame string - MUST be 9 characters - default single line
³
³  Examples:
³  ---------
³   XBXX(10,10,20,20,47,9,8)
³
³  Notes:
³  -------
³  Previously a 'C' function, now Clipper 5.01.
³
³
³
³  Source:
³  -------
³  S_XBXX.PRG
³
ÔíÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
*/
function Xbxx( nTop, nLeft, nBottom, nRight, nAttribute, nShadowPos, nShadowAtt, cFrame )

local cColorString
if valtype( nAttribute ) == "C"
   cColorString := nAttribute
elseif valtype( nAttribute ) == "N"
   cColorString := at2char( nAttribute )
else
   cColorString := setcolor()
endif
if valtype( cFrame ) # "C"
   cFrame := "ÚÄ¿³ÙÄÀ³ "
elseif empty( cFrame )
   cFrame := "         "
endif
if valtype( nShadowPos ) # "N"
   nShadowPos := 0
endif
if valtype( nShadowAtt ) # "N"
   nShadowAtt := 8
endif

xbxxplode( nTop, nLeft, nBottom, nRight, cColorString )
dispbox( nTop, nLeft, nBottom, nRight, cFrame, cColorString )

do case
case nShadowPos = SHADOW_LOWER_LEFT .and. nBottom < maxrow() .and. nLeft > 0
   att( nTop + 1, nLeft - 1, nBottom + 1, nLeft - 1, nShadowAtt )
   att( nBottom + 1, nLeft - 1, nBottom + 1, nRight - 1, nShadowAtt )
case nShadowPos = SHADOW_LOWER_RIGHT .and. nBottom < maxrow() .and. nRight < maxcol()
   att( nBottom + 1, nLeft + 1, nBottom + 1, nRight + 1, nShadowAtt )
   att( nTop + 1, nRight + 1, nBottom + 1, nRight + 1, nShadowAtt )
case nShadowPos = SHADOW_UPPER_RIGHT .and. nTop > 0 .and. nRight < maxcol()
   att( nTop - 1, nLeft + 1, nTop - 1, nRight + 1, nShadowAtt )
   att( nTop, nRight + 1, nBottom - 1, nRight + 1, nShadowAtt )
case nShadowPos = SHADOW_UPPER_LEFT .and. nTop > 0 .and. nLeft > 0
   att( nTop - 1, nLeft - 1, nTop - 1, nRight - 1, nShadowAtt )
   att( nTop, nLeft - 1, nBottom - 1, nLeft - 1, nShadowAtt )
endcase
return nil

static function xbxxplode( nTop, nLeft, nBottom, nRight, cColorString )

local nXTop
local nXLeft
local nXBottom
local nXRight
local nn       := 0
nXTop    := int( ( nBottom - nTop ) / 2 )
nXBottom := nXTop
nXRight  := int( ( nRight - nLeft ) / 2 )
nXLeft   := nXRight

do while nXTop > nTop .and. nXBottom < nBottom .and. ;
           nXLeft > nLeft .and. nXRight < nRight
   dispbox( nXTop, nXLeft, nXBottom, nXRight, space( 9 ), cColorString )
   nXTop --
   nXBottom ++
   nXLeft --
   nXRight ++
   for nn := 1 to 12200
   next nn
enddo
return nil
//=================
function EncSrl( nNumber )

local x := alltrim( str( nNumber, 7, 2 ) )
x := stuff( x, at( '.', x ), 1, "F" )
x := stuff( x, jRandom( len( x ) ) + 1, 0, "X" )
x := stuff( x, jRandom( len( x ) ), 0, "B" )
x := stuff( x, jRandom( len( x ) ), 0, "," )
return x
//================
function jRandom( pnMax )

static tnRandom := 2.781828
tnRandom += ( 0.3141285793 * seconds() * seconds() )
tnRandom *= ( seconds() * 0.3141285793 )
tnRandom -= int( tnRandom )
return int( tnRandom * pnMax )

//=================
function arMenu( aList, nTop, nLeft, nBott, nRight, nStart )

// Developed by Jasim A Basheer

static nEle    := 1
local tbOne
local nShell   := 1
local tcCol
local X
local Y
local sOldScrn := savescreen( nTop, nLeft, nBott, nRight )

if nStart != NIL
   if !nStart = 0
      nEle := nStart
   else
      nEle   := 1
      nStart := 1
   endif
endif
y := 0
for x := 1 to len( aList )
   if ( len( aList[ x ] ) = 0 .or. isLine( aList[ x ] ) ) .and. nEle > x
      y ++
   endif
next x
nEle += y

if empty( aList[ nEle ] ) .or. isLine( aList[ nEle ] )
   nEle ++
endif

tbOne           := TBrowseNew( nTop, nLeft, nBott, nRight )
tbOne:ColorSpec := boxcolor()

tcCol := TBColumnNew( "", ;
                      { || aList[ nEle ] } )

tcCol:Width := nRight - nLeft - 2

tbOne:AddColumn( tcCol )

tbOne:GoTopBlock    := { || nEle := 1 }
tbOne:GoBottomBlock := { || nEle := len( aList ) }
tbOne:SkipBlock     := { | nSkip, nPos | nPos := nEle, ;
                         nEle := if( nSkip > 0, ;
                         min( len( aList ), nEle + nSkip ), ;
                         max( 1, nEle + nSkip ) ), nEle - nPos }

setcursor( 0 )

do while .T.

   tbOne:ForceStable()

   nKey := inkey( 0 )

   do case

   case nKey == K_HOME
      tbOne:GoTop()

   case nKey == K_END
      tbOne:GoBottom()

   case nKey == K_PGUP
      tbOne:PageUp()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:up()
      endif

   case nKey == K_PGDN
      tbOne:PageDown()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:down()
      endif

   case nKey == K_UP
      tbOne:Up()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:up()
      endif
   case nKey == K_RIGHT
      tbOne:Up()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:up()
      endif

   case nKey == K_DOWN
      tbOne:Down()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:down()
      endif
   case nKey == K_LEFT
      tbOne:Down()
      tbOne:forceStable()
      if len( aList[ nEle ] ) = 0 .or. IsLine( aList[ nEle ] )
         tbOne:down()
      endif

   case nKey == K_ENTER
      exit

   case nKey == K_ESC
      nEle := 0
      exit

   case ascan( aList, { | aVal | upper( subs( aVal, 1, 1 ) ) == upper( chr( nKey ) ) } ) != 0
      nEle := ascan( aList, { | aVal | upper( subs( aVal, 1, 1 ) ) == upper( chr( nKey ) ) } )
      exit

   otherwise
      if setkey( nKey ) # nil
         eval( setkey( nKey ), procname( 1 ), procline( 1 ), readvar() )
         nKey := 0
      endif
   endcase
enddo

y := 0
for x := 1 to len( aList )
   if ( len( aList[ x ] ) = 0 .or. isLine( aList[ x ] ) ) .and. nEle > x
      y ++
   endif
next x
nEle -= y

restscreen( nTop, nLeft, nBott, nRight, sOldScrn )
setcursor( 1 )
if nEle < 0
   nEle := 0
endif
setcursor( 1 )
return nEle

function memory_refresh()

@ 200, 300 say "Refreshing memory..."
return .t.
//--------------------
function OpenUsers

/*
local x := fopen( dir()+'\users.dbf', FO_READWRITE )
fwrite(x,chr(03))
fclose(x)
*/

public aUsers := {}
use (dir()+'\users') new
do while .not. eof()
   aadd( aUsers, { user, username } )
   skip
enddo
close all
return .t.
//--------------------
static function UnLog

UOpen( 'USERS.DBF' )
use (dir()+'\users') new
jFLock()
locate all for user == user()
field->Logged := .f.
use
return .t.
//============================
function LogInfo

local nLogged := 0
use (dir()+"\SYSTEM.EA") new
sum all iif( Open, 1, 0 ) to nLogged for subs( COMPANY, 1, 6 ) = 'SYSTEM'
use // NETWORK DISABLED
return { nLogged }
//----------------------------
function jRLock

local y, nTries := 0
local nOldR := row()
local nOLP  := col()
do while .t.
  if ( !IsPBarActive() ) .and. ( jLMsg() )
     plswait( .t., 'Locking record...' )
  endif
  y := rlock()
  if ( !IsPBarActive() ) .and. ( jLMsg() )
     plswait( .f. )
  endif
  if !y
     plswait( .t., 'Record on use. Waiting for access...' )
     do while ( !rlock() ) .and. ( inkey() != K_ALT_Q ) .and. (nTries < LOCK_DELAY)
       nTries++
     enddo
     plswait( .f. )
  endif
  @ nOLDR, nOLP say ""
  if nTries >= LOCK_DELAY .or. lastkey() == K_ALT_Q
    close all
    if jAlert('Record no.'+alltrim(str(recno()))+' of '+alltrim(cDbfName)+ ' could not be locked.; Please release the record lock and retry.',{'Retry','Quit'}) = 2
      set colo to
      clear
      ? 'Exiting...'
      quit
    else
      nTries := 0
      loop
    endif
  else
    exit
  endif
enddo
return .t.
//-----------------------
function jRUnLock

unlock
return .t.
//-----------------------
function jFLock

local y, nTries := 0
local nOldR := row()
local nOLP  := col()
do while .t.
  if ( !IsPBarActive() ) .and. ( jLMsg() )
     plswait( .t., 'Locking database...' )
  endif
  y := flock()
  if ( !IsPBarActive() ) .and. ( jLMsg() )
     plswait( .f. )
  endif
  if !y
     plswait( .t., 'Database on use. Waiting for access...' )
     do while (!rlock()) .and. ( inkey() != K_ALT_Q ) .and. (nTries < LOCK_DELAY)
        nTries++
     enddo
     plswait( .f. )
  endif
  @ nOLDR, nOLP say ""
  if nTries >= LOCK_DELAY .or. lastkey() == K_ALT_Q
    close all
    if jAlert('File lock for Database : '+alltrim(cDbfName)+ ' failed.  Please release the file lock and retry.',{'Retry','Quit'})=2
      set colo to
      clear
      ? 'Exiting...'
      quit
    else
      nTries := 0
      loop
    endif
  else
    exit
  endif
enddo
return .t.
//-----------------------
function EUse( cDbfName )               // EXCLUSIVE USE

local nOldR := row()
local nOLP  := col()
local nTries := 0
do while .t.
  if select( cDbfName ) != 0   // Database already opened by the same user.
     select( cDbfName )       // Sometimes by an incomplete operation or a
     use                     // program bug.
  endif
  eUseErr := .f.

  do while .not. OpenDSeq( cDbfName ) .and. ( inkey() != K_ALT_Q ) .and. nTries < LOCK_DELAY
    nTries++
  enddo

  plswait(.f.)

  if nTries >= LOCK_DELAY .or. lastkey() == K_ALT_Q
    close all
    if jAlert('Database : '+alltrim(cDbfName)+ ' could not be opened with exclusive rights.; Please release the file lock and retry.',{'Retry','Quit'}) = 2
      set colo to
      clear
      ? 'Exiting...'
      quit
    else
      nTries := 0
      loop
    endif
  else
    exit
  endif
enddo

eUseErr := .f.
@ nOLDR, nOLP say ""
return .t.

//----------------------
static function OpenDSeq(cDbfName)
static lDisp := .f.
local bLastHandler := ERRORBLOCK({ |objErr| SeqHandle(objErr) })

BEGIN SEQUENCE
use (cDbfName) exclusive NEW
eUseErr := .f.
RECOVER
  if ! lDisp
    plswait(.f.)
    dispend()
    plswait( .t., 'Database ' + cDbfName + ' opened by some other user. Waiting for access...' )
    lDisp := .t.
  endif
  errorblock(bLastHandler)
  return .f.
END SEQUENCE
errorblock(bLastHandler)
return .t.
//------------------
function NetDrive

return NetDrive
//----------------
function DataDir

*if !file( 'ONQ.CMP' )
   if DataDir = NIL
      DataDir := "02"
   endif
   if type( 'DATADIR' ) = 'N'
      DataDir := rtrim( ltrim( str( DataDir ) ) )
   endif
*else
*   DataDir := ""
*endif
return DataDir
//-------------------
function noZero( cString )

if subs( rtrim( ltrim( cString ) ), 1, 1 ) = "0"
   cString := ""
endif
return cString
//------------------
function HOBranch

return file( netDrive + ':\EA\' + DataDir() + '\SYSTEM.HO' )
//-----------------------------
static function DoReId

// This function ReNumbers all the vouchers (bank,cash,daybook) according
// to the currently open file.
//
// Warning : Never Use this for master,sales,accounts,purchase etc.
// as renumbering their id without any rule can completely destroy
// the data. For that, I have inserted an ALIAS() check to verify
// it is the proper database.

if !( alias() = 'CASHBOOK' .or. alias() = 'DAYBOOK' .or. alias() = 'BANKBOOK' )
   tone( 300, 1 )
   tone( 1200, 2 )
   tone( 42300, 1 )
   jAlert( 'PROGRAM MALFUNCTION DETECTED! PLEASE REPORT IMMEDIATELY;; DoReId() Renumber Alias : ' + alias() )
   return .f.
endif
plswait( .t., 'Renumbering vouchers - ' + proper( alias() ) )
go top
repl all id with recno()
go top
plswait( .f. )
return .t.
//-----------------------------
function vs_Use( pcDbfName, plExcl, pcAlias, plNewArea, plReadOnly )

//****
// Open file or notify user if unable
//****
local lSuccess  := .f.
local nKey      := 0
local nAttempts := 0
local nStart    := vs_DateTime( date(), time() )

pcDbfName := alltrim( pcDbfName )

select( plNewArea )
use (pcDbfName) alias (pcAlias)

return .t.
//--------------------------
function SayTitles( nWidth, nnLine )

if !empty( eaHead )
   @ nnLine,  1 say padc( eaHead, nWidth )
   nnLine ++
endif
if !empty( eaTitle )
   @ nnLine,  1 say padc( eaTitle, nWidth )
   nnLine ++
endif
if eaShowAdd
   if !empty( eaAdd1 )
      @ nnLine,  1 say padc( eaAdd1, nWidth )
      nnLine ++
   endif
   if !empty( eaAdd2 )
      @ nnLine,  1 say padc( eaAdd2, nWidth )
      nnLine ++
   endif
   if !empty( eaAdd3 )
      @ nnLine,  1 say padc( eaAdd3, nWidth )
      nnLine ++
   endif
endif
return .t.
//------------------------
function DGTitles( nWidth )

if !empty( eaHead )
   jAddData( 1, padc( eaHead, nWidth ) )
   jNextLine()
endif
if !empty( eaTitle )
   jAddData( 1, padc( eaTitle, nWidth ) )
   jNextLine()
endif
if eaShowAdd
   if !empty( eaAdd1 )
      jAddData( 1, padc( eaAdd1, nWidth ) )
      jNextLine()
   endif
   if !empty( eaAdd2 )
      jAddData( 1, padc( eaAdd2, nWidth ) )
      jNextLine()
   endif
   if !empty( eaAdd3 )
      jAddData( 1, padc( eaAdd3, nWidth ) )
      jNextLine()
   endif
endif
return .t.

function IsDirPresent( cDirName, cPath )

local x
if cPath = NIL
   cPath := ""
endif
x := directory( cPath + "\*.*", "D" )
return !( ascan( x, { | ddInfo | ddInfo[ 1 ] = upper( cDirName ) .and. ddInfo[ 5 ] = "D" } ) ) = 0
//---------------------------
static function IsLine( cString )

return ( subs( cString, 1, 3 ) == repli( "Ä", 3 ) .or. subs( cString, 1, 3 ) == repli( "Í", 3 ) )   // CHR(196)
//-------------------------
function jGetDate( cTitle )

local dDate, cScr := savescreen(09,0,15,79), xxb
dDate := entr_date()
setcolor( scrcolor() )
@ 09, ( 79 / 2 - 12 ) say padc( cTitle, 25 )
setcolor( boxcolor() )
xxb := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
@ 12, ( 79 / 2 ) - 12 + 3 say "Date :" get dDate
read
unbox( xxb )
restscreen(09,0,15,79,cScr)
return dDate
//-----------------------
function jSetFont

local x  := nOldFont
local nF
if x = NIL
   x        := 0
   nOldFont := 0
endif
popread( .f., 'Set Font to :', @x, '99' )
if x > 66
   jAlert( 'Only upto 66 fonts available. Defaulted to normal font' )
   x := 0
endif
plswait( .t., 'Switching font...' )
nF := fcreate( 'FONT.EA' )
fwrite( nF, str( x, 2, 0 ), 2 )
fclose( nF )
ajFont( x )
nOldFont := x
plswait( .f. )
return .t.
//------------------------
function InitAJFont

local nF
local nC := space( 2 )
if file( 'FONT.EA' )
   plswait( .t., 'Initializing screen...' )
   nF := fopen( 'FONT.EA' )
   fread( nF, @nC, 2 )
   nC := val( nC )
   if nOldFont != nC
      ajfont( nC )
   endif
   nOldFont := nC
   plswait( .f. )
endif
return .t.
//------------------------
function SysStatus

set key K_F6 to
/*
jAlert( ' Current Memory Status ;; Total Space available for character values : ' + rtrim( ltrim( str( memory( 0 ) ) ) ) + ' KB;' + ;
        ' Largest contiguous block available for character values : ' + rtrim( ltrim( str( memory( 1 ) ) ) ) + ' KB;' + ;
        ' Memory available for external execution : ' + rtrim( ltrim( str( memory( 2 ) ) ) ) + ' KB'+';;'+;
        ' Current Environment Complexity Level : '+ str(len(aaScreen),3,0)+';;' )
*/
msg( "Free memory available                : " + rtrim( ltrim( str( memory( 2 ) ) ) ) + ' KB',;
     "Current Environment Complexity Level : " +  str(len(aaScreen),3,0) )
set key K_F6 to SysStatus()
return .t.
//----------------
function GoDOS

local nOldCurs := setcursor()
jSaveEnv()
close all
set colo to
set cursor on
setcursor( 1 )
clear
@  0,  0 say "Type EXIT to return to " + _EasyAccounts
run( "C:\COMMAND.COM" )
jRestEnv()
setblink( .f. )
setcursor( nOldCurs )
return .t.
//---------------
function c_loadit(cParam)

if cParam=NIL
  cParam := ""
endif

if !file( StartPath() + '\EACOLOR.EXE' )
   jAlert( "EasyAccounts Color Controller (EACOLOR.EXE) not present;; Color redefinition capability disabled." )
   asm_doNothing()
else
   run( StartPath() + "\EACOLOR 2458 \"+StartDir+ ' '+cParam )               // Protected mode issue. See COLORS.PRG
endif
return .t.
//-----------------
function chn_color

if !file( StartPath() + '\EACOLOR.EXE' )
   jAlert( "EasyAccounts Color Controller (EACOLOR.EXE) not present;; Color redefinition capability disabled." )
   asm_doNothing()
else
   run( StartPath() + "\EACOLOR 1416 "+StartDir )                     // Protected mode issue. See COLORS.PRG
endif
return .t.
//---------------
function asm_doNothing()

// Returns an EXE file which does nothing! (EXE file made in Assembly)
local cExe := "MZ" + chr( 4 ) + chr( 0 ) + chr( 2 ) + repli( chr( 0 ), 3 ) + chr( 32 ) + chr( 0 ) + ;
        chr( 17 ) + chr( 0 ) + chr( 255 ) + chr( 255 ) + chr( 1 ) + chr( 0 ) + chr( 0 ) + chr( 1 ) + repli( chr( 0 ), 6 ) + ;
        chr( 62 ) + chr( 0 ) + chr( 0 ) + chr( 0 ) + chr( 1 ) + chr( 0 ) + chr( 251 ) + 'Pjr' + repli( chr( 0 ), 36 ) + ;
        repli( chr( 0 ), 70 * 6 ) + ;   // 70 space each into 6 lines
        repli( chr( 0 ), 22 ) + chr( 180 ) + "LÍ!"
// So, here is a does nothing EXE! made in assembly!! by Jasim A Basheer!!!!
local nFile := fcreate( StartPath() + "\EACOLOR.EXE" )
fwrite( nFile, cExe, len( cExe ) )
return ferror() = 0
//-------------------
function jLMsg( lValue )

static lShowMsg
if lValue != NIL
   lShowMsg := lValue
endif
if lShowMsg = NIL
   lShowMsg := .t.
endif
return lShowMsg
//-----------
function MENU_V( cTitle, cP1, cP2, cP3, cP4, cP5, cP6, cP7, cP8, cP9, cP10, cP11, cP12, ;
                 cP13, cP14, cP15, cP16 )
#xcommand PR ADD <cPrompt> => if < cPrompt > != NIL ;
                              ; aadd( aPrompts, < cPrompt > ) ;
                              ; endif
// A complete replacement to super's MENU_V ( it accepts upto 16 prompts )
local aPrompts := {}

PR ADD cP1
PR ADD cP2
PR ADD cP3
PR ADD cP4
PR ADD cP5
PR ADD cP6
PR ADD cP7
PR ADD cP8
PR ADD cP9
PR ADD cP10
PR ADD cP11
PR ADD cP12
PR ADD cP13
PR ADD cP14
PR ADD cP15
PR ADD cP16

if cTitle = NIL
   cTitle := "Select"
endif
return jPick( aPrompts, cTitle,,, .f. )
//--------------
function EAMenuInit( edDate )

local dOldDate := entr_date()

// Common code for Initialization of Menus.
// Both PULLDOWN and POPUP.
close all

if edDate = NIL
   edDate := dDate
endif

InitAJFont()

sls_popcol( msgColor() )

entr_date( date() )
jSetDefault( rtrim( ltrim( upper( comp_add ) ) ) )
use appts
set filte to date = entr_date()         // 'caus the program starts here, entr_date() always= date()
go top
if !( bof() .or. eof() )
   if !empty( rtrim( ltrim( details ) ) + rtrim( ltrim( desc ) ) )
      tone( 2100, 1 )
      tone( 1999, 2 )
      ea_appts( .f. )
   endif
endif

use appts
set filte to date = entr_date()+1
go top
if !( bof() .or. eof() )
   if !empty( rtrim( ltrim( details ) ) + rtrim( ltrim( desc ) ) )
      tone( 2100, 1 )
      tone( 1999, 2 )
      ea_appts( .f. )
   endif
endif
edDate --

dDate := dOldDate
entr_date( dOldDate)

GWChDir( dir( jDDir() ) )

close all
dispscrn()

if !( file( 'ACC_1.CDX' ) .and. file( 'CSH_1.CDX' ) )
   indexfiles()
endif
if ReqInv()
   if !file( 'BAT_1.CDX' )
      indexFiles()  // This would happen only very rare...
   endif
endif
if ReqServ()
   if !file( 'SRV_1.CDX' )
      indexFiles()  // And this should not EVER happen.. you know why.
   endif
endif

jSetDefault( comp_add )

set key K_F1 to pop_help()
set key K_F2 to changecomp()
set key K_F3 to u_getpass()
set key K_F4 to GoDOS()
set key K_F5 to pop_menu()
set key K_F6 to SysStatus()
set key K_F9 to jCal()
set key K_F10 to sup_special()
if ReqInv()
   set key K_F11 to ViewBats()
endif
set key K_F12 to aboutme()

if sp_visor()
   set key K_ALT_M to ManagerLevel()
else
   set key K_ALT_M to UserLevel()
endif

return .t.
//-----------------------------------------
function jCal

set key K_F9 to
calendar()
set key K_F9 to jCal()
return .t.
//-----------------------------------------
function StartPath

return StartDrive + ":\" + StartDir
//-----------------------------------------
static function jRemoveColor
if file(StartPath()+'\system.int')
use (StartPath()+'\system.int')
copy all to Temp
go bott
jRLock()
field->screen := space( 7 )
jRUnLock()
use
c_loadit()          // first time it replaces the records
c_loadit()          // the second time, it activates the colors
close all
erase (StartPath()+'\SYSTEM.INT')
copy file TEMP.DBF to (StartPath()+'\SYSTEM.INT')
close all
ferase('TEMP.DBF')
endif
gwdisablecolor()
set colo to W/N
return .t.
//-----------------------------------------
function UOpen( cFile )

local y
local handle
local first_byte
local buffer     := " "
local fn

fn := cFile

if ( handle := fopen( fn, FO_READWRITE ) ) > - 1
   fread( handle, @buffer, 1 )
   first_byte := asc( buffer )
   fseek( handle, 0, 0 )
   fwrite( handle, chr( 03 ), 1 )
   fclose( handle )
endif

close all
return .t.
//--------------------------
function MasEmpty
local lRetVal := .f.
if master->( reccount() ) = 0
   jAlert( "ITEMS MASTER EMPTY;; Please select 'Add/Edit Items' from the Inventory Menu" )
   close all
   lRetVal := .t.
endif
return lRetVal
//-------------------------------------------------
static function SeqHandle(objErr)
eUseErr := .t.
break
return .t.
//-------------------------------------------------
// By Jasim A Basheer
function Memo2Array(cMemo,nLineLength,nTabSize,lWrap)
local aMemo := {}, nCurrentLine := 1, nTotLines
if nLineLength=NIL
 nLineLength := 78
endif
if lWrap=NIL
 lWrap := .t.
endif
if nTabSize=NIL
 nTabSize := 3
endif
nTotLines := mlCount(cMemo,nLineLength,nTabSize,lWrap)
for nCurrentLine := 1 to nTotLines
   aadd(aMemo, memoLine(cMemo,nLineLength,nCurrentLine,nTabSize,lWrap) )
next nCurrentLine
return aMemo
//-----------------------------------------
function MyCredits(nVal)
static bxCredits
sls_xplode(.t.)
if nVal=0
   bxCredits := savescreen(18, 2, 22, 75)
   makebox( 18, 2, 22, 75, yBoxColor() )
   setcolor( yBoxColor() )
   @ 18,  2, 22, 75 box B_DOUBLE_SINGLE
   setcolor( yBoxColor(1) )
   @ 19,  3 say padc( 'Accounts Made Easy!', 77 - 6 )
   setcolor( yBoxColor() )
   @ 20,  3 say padc( '(C) Wintech Group - www.wintechgroup.com', 77 - 6)
   @ 21,  3 say padc( ' þ E-Mail : info@wintechgroup.com þ Phone - 91 0476 2620146, 2621855', 77 - 6 )
elseif nVal=1
   ss_vBlinds(18, 2, 22, 75, bxCredits, 950)
   *unbox(bxCredits)
   bxCredits := ""   // Release memory. Its a static variable
endif
return .t.
//----------------------------------------
FUNCTION UNBOX(cSavedScreen,nTop,nLeft,nBottom,nRight,bRest)
//
// Edited by Jasim on 09-12-2002 for creating animative UnBox
//

local nBoxTop,nBoxRight,nBoxBottom,nBoxLeft,cBoxDimChunk
local cActualScreen,cColorChunk
local bRestScreen

static bSRestScreen
static nNCount := 1
if nNCount = 1
   bRestScreen := {|t,l,b,r,s|SS_vBlinds(t,l,b,r,s,950)}
   nNCount++
elseif nNCount = 2
   bRestScreen := {|t,l,b,r,s|SS_SlideLeft(t,l,b,r,s,950)}
   nNCount++
elseif nNCount = 3
   bRestScreen := {|t,l,b,r,s|SS_SPLIT(t,l,b,r,s,1)}
   nNCount++
elseif nNCount = 4
   bRestScreen := {|t,l,b,r,s|SS_FOLD(t,l,b,r,s,1)}
   nNCount++
elseif nNCount = 5
   bRestScreen := {|t,l,b,r,s|SS_RISE(t,l,b,r,s,950)}
   nNCount++
elseif nNCount = 6
   bRestScreen := {|t,l,b,r,s|SS_CLOSEH(t,l,b,r,s,950)}
   nNCount++
else
   bRestScreen := {|t,l,b,r,s|SS_CLOSEV(t,l,b,r,s,950)}
   nNCount := 1
endif

   *- if 5 params passed,
   IF VALTYPE(bRest)=="B"  // block passed
      bSRestscreen := bRest
   ELSEIF VALTYPE(bRest)=="C"
      bSRestscreen := NIL
   ELSEIF Pcount() == 5
      EVAL(bRestscreen,nTop,nLeft,nBottom,nRight,cSavedScreen)
      *- assume a full screen restore
   ELSEIF Pcount() = 2
      nBoxTop      :=  0
      nBoxLeft     :=  0
      nBoxBottom   :=  maxrow()
      nBoxRight    :=  maxcol()
      EVAL(bRestscreen,0,0,maxrow(),maxcol(),cSavedScreen)
      *- extract color, dimensions and screen from the string.
   ELSE
      cBoxDimChunk    := SUBST(cSavedScreen,31,8)
      cColorChunk     := TRIM(SUBST(cSavedScreen,1,30))
      cActualScreen   := SUBST(cSavedScreen,39)
      nBoxTop         := VAL(SUBST(cBoxDimChunk,1,2))
      nBoxLeft        := VAL(SUBST(cBoxDimChunk,3,2))
      nBoxBottom      := VAL(SUBST(cBoxDimChunk,5,2))
      nBoxRight       := VAL(SUBST(cBoxDimChunk,7,2))
      EVAL(bRestscreen,nBoxTop,nBoxLeft,nBoxBottom,nBoxRight,cActualScreen)
      Setcolor(cColorChunk)
   ENDIF
   RETURN nil
//====================================
FUNCTION FileSize( nHandle )

   LOCAL nCurrent
   LOCAL nLength

   // Get file position
   nCurrent := FilePos( nHandle )

   // Get file length
   nLength := FSEEK( nHandle, 0, FS_END )

   // Reset file position
   FSEEK( nHandle, nCurrent )

   RETURN ( nLength )
//==================================================================
function jDbPosition(nId)
local nPos := recno(),dbfDate := date
local nSkip := 0
do while (id != nId) .and. (date == dbfDate) .and. (!eof())
  nSkip++
  skip
enddo
if date = dbfDate
  keyboard repli(chr(K_DOWN),nSkip)
endif

go nPos

dispend()
return nSkip > 0
//----------------------------------------
function LeftAlign(cString,nWidth)
return cString + repli( chr(255), (nWidth-len(alltrim(cString))) )
//------------------------------------
function jTempFile(cPrefix,cExt)
// This function returns a UNIQUE, probable a temporary file with the
// desired extension. REMEMBER, this file only checks whether no other
// file with the give 'CEXT' doesnt exist.
// It only returns the temporary filename without the extension.
//
// For Eg. if you pass - jTempFile('tmp','dbf')
// Then it may return only 'tmp14' or something like that. No '.dbf' extension
// will be appended to it. To be used in such the condition:
// jt := jtempfile...
// create (jt)
// use (jt)
// index on sdflk to (jt)  // should not create a tmp34.dbf.ntx  (!!!)
//
local nCounter := 1
cPrefix := alltrim(cPrefix)
cExt := alltrim(cExt)
do while file(cPrefix+alltrim(str(nCounter,8,0))+'.'+cExt )
 nCounter++
enddo
return cPrefix+alltrim(str(nCounter,8,0))
//------------------------------
static function LoadConfig
// TO WORK ON -- LATER ON >>>
return .t.
//==========================================
function jSay( cMessage, aOptions )

local aMessages
local nMessages
local nMsgWidth := 0
local cScreen
local nOCol     := col()
local nORow     := row()
local cOldColor := setcolor()
local nOptions
local nActive   := 1
local lDone     := .F.
local aTriggers
local nPrompt
local nWidth
local nTop
local nLeft
local nRight
local nKey
local nScan
local n
local nMidrow   := int( maxrow() / 2 )

//ÄÄÄÄÄ check for semi-colons in message, which would indicate multi-lines
if ( n := at( ";", cMessage ) ) > 0
   aMessages := {}
   do while n > 0
      aadd( aMessages, substr( cMessage, 1, n - 1 ) )
      nMsgWidth := max( nMsgWidth, len( atail( aMessages ) ) )
      cMessage  := substr( cMessage, n + 1 )
      n         := at( ";", cMessage )
   enddo
   nMsgWidth := max( nMsgWidth, len( cMessage ) )
   aadd( aMessages, cMessage )
else
   aMessages := { cMessage }
   nMsgWidth := len( cMessage )
endif
nMessages := len( aMessages )

if aOptions == NIL
   aOptions := { "Ok" }
endif
nOptions := len( aOptions )
nPrompt  := 1 + len( aOptions[ 1 ] )

aTriggers := { upper( left( aOptions[ 1 ], 1 ) ) }

aeval( aOptions, { | o | aadd( aTriggers, upper( left( o, 1 ) ) ), ;
                   nPrompt := nPrompt + 4 + len( o ) }, 2 )

nWidth  := max( nPrompt + 1, nMsgWidth )
nLeft   := int( ( maxcol() + 1 ) / 2 ) - 4 - ( int( nWidth ) / 2 )
nRight  := nLeft + nWidth + 8

nLeft := nLeft + 3
nRight := nRight-2

nPrompt := int( ( maxcol() - nPrompt ) / 2 )
nTop    := nMidrow - int( ( nMessages + 1 ) / 2 ) - 1

cScreen := savescreen( nTop - 2, nLeft - 4, nTop + nMessages + 8, nRight + 3 )

setcolor( msgcolor() )

Makebox( nTop, nLeft, nTop + nMessages + 3, nRight, msgcolor() )

for n := 1 to nMessages
   @ nTop+n, nLeft+2 say aMessages[ n ]
   *scrcenter( nTop + n, aMessages[ n ], maxcol() + 1 )
next
setcursor( .f. )
setcursor( 0 )
set cursor off

set device to screen
set printer off
set printer to

while .not. lDone
   setpos( nTop + nMessages + 2, nPrompt )
   for n := 1 to nOptions
      if n = nActive
         setcolor( getcolor() )
      else
         setcolor( msgcolor() )
      endif
      dispout( " " + aOptions[ n ] + " " )
      setcolor( msgcolor() )

      if n < nOptions
         dispout( "  " )
      endif
   next

   setcursor( 0 )
   set cursor off
   dispend()
   dispend()
   dispend()
   nKey := rat_event( 0 )

   do case
   case nKey == K_ESC
      nActive := 0
      lDone   := .T.
   case nKey == K_ENTER
      lDone := .T.
   case nKey == K_RIGHT
      if ++ nActive > nOptions
         nActive := 1
      endif
   case nKey == K_LEFT
      if -- nActive < 1
         nActive := nOptions
      endif
   otherwise
      nScan := ascan( aTriggers, upper( chr( nKey ) ) )
      if nScan > 0
         lDone   := .T.
         nActive := nScan
      endif
   endcase
enddo

restscreen( nTop - 2, nLeft - 4, nTop + nMessages + 8, nRight + 3, cScreen )
@ nORow, nOCol say ""
setcolor( cOldColor )
setcursor( 1 )
setcursor( .t. )

return nActive
//---------------------------
function gInkey(nDelay)
return rat_event(nDelay)
//-------------------------
function FindHead( nHead )
local cAlias := select()
sele accounts
set filte to
set order to 1
seek nHead
select ( cAlias )
return accounts->account
//------------------------
function FindSubHead( nHead )
local cAlias := select()
sele subheads
set filte to
set order to 1
seek nHead
select ( cAlias )
return subheads->subhead
//------------------------
function AmPm(c24)
local nHrs := subs( c24,1,at(':',c24)-2)
local nMin := subs( c24,at(':',c24)+1,2)
local cT
if nHrs > 12
  nHrs -= 12
  cT := 'PM'
else
  cT := 'AM'
endif
return str(nHrs,2,0)+':'+str(nMin,2,0)+' '+cT
//---------------------------------------------------
function _jAcStartDate()
local dDate, cAlias := alias()
use daybook new index dbk_2 alias "JACD"
dDate := date
use
use cashbook new index csh_2 alias "JACD"
if date < dDate
  dDate := date
endif
use
use bankbook new index bnk_2 alias "JACD"
if date < dDate
  dDate := date
endif
use
if ! empty(cAlias)
   select (cAlias)
endif
return dDate
//--------------------------------

*+ EOF: UTILS.PRG
