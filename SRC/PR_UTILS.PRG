//--------------------------------------
// PRICE (Quotation Module)'s Support UTILS.PRG
// Separate old edition.
//---------------------------------------
/*
#
#     Utility System for EasyAccounts v1.5
#     Developed and Tested by Jasim A B
#     E-Mail  : jasimab@hotmail.com
#     Website : jasim.iwarp.com
#
*/

#include "std.ch"
#include "fileio.ch"
#include "ghost.ch"
#include "box.ch"
#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"
#ifndef K_LBUTTONDOWN
#define K_LBUTTONDOWN   1002   //   mouse left key press
#define K_RBUTTONDOWN   1004   //   mouse right key press
#endif
#define K_MOUSELEFT K_LBUTTONDOWN
#define K_MOUSERIGHT K_RBUTTONDOWN

static lJOp := .t.

static aaCursor  := {}
static aaDbfs    := {}
static aaFilters := {}
static aaScreen  := {}
static aaActInd  := {}

static anActWork := {}

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
function jPick( aPicks, heading )

local xx := 1
local yy := 0
local zz := 0
do while .not. xx > len( aPicks )
   zz := max( zz, len( aPicks[ xx ] ) )
   xx ++
enddo
setcolor( boxcolor() )
xx := int( 12 - ( len( aPicks ) / 2 ) )
yy := int( ( 79 / 2 ) - ( zz / 2 ) ) - 5
@ xx - 1, yy clear to xx + len( aPicks ), yy + 2 + zz
@ xx - 1, yy, xx + len( aPicks ), yy + 2 + zz box B_DOUBLE_SINGLE
setcolor( scrcolor() )
@ xx - 2, yy say padc( heading, zz + 3 )         
setcolor( boxcolor() )
return achoice( xx, yy + 1, xx + len( aPicks ), yy + zz + 1, aPicks )
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
@  0,  0 say padc( 'EasyAccounts v1.5', 80 )         

if !file( 'INSTALL.INF' )
   if comp_add != 'LOG ON'
      @ 24,  0 say padc( gPrefix + ', ' + comp_add, 80 )         
   else
      @ 24,  0 say padc( 'Logon Menu', 80 )         
   endif
else
   @ 24,  0 say space( 80 )         
endif

setcolor( 'B*/W*' )
@ 24, 62 say 'F8 - Calculator'         
dispend()
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
function jsfilt( b, nkey, cFilter )

local x    := setcolor()
local osch := "           "
local obox := makebox( 3, 43, 5, 67, menucolor(), 0 )
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
set cursor off
b:forcestable()
b:refreshall()
b:stabilize()
unbox( obox )
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
      devout( "[][] [ENTER=OK] [ESC=Cancel]" )
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
function j_getmemo( nTop, nRight, nBott, nLeft, cStartwith, cHeading )

local cOldScrn
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
cOldScrn := savescreen( nTop, nRight, nBott, nLeft )
@ nTop, nRight clear to nBott, nLeft
@ nTop, nRight, nBott, nLeft box B_DOUBLE_SINGLE
@ nTop, nRight + 3 say '[' + cHeading + ']'         
set escape OFF
@ nBott, nLeft - 30 say '[ CTRL+W - Save & Exit ]'         
cStartwith := memoedit( cStartwith, nTop + 2, nRight + 2, nBott - 2, nLeft - 2 )
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

init procedure SETVARS

local lStart := .t.

dispbegin()
dosetvars( .t. )
p_rdydelay( .1 )
rat_ehh( .t. )
comp_add := 'LOG ON'
clear
dispscrn()
dispend()
if u_getpass()
   dispend()
   dosetvars( .t. )
   prices()
   quit
else
   set colo to w/n
   clear
   ? 'Unauthorized access attempt.'
   ?
   quit
endif

return .t.
//-----------

static function dosetvars( lChangeIS )

local nHandle := 0
local cBuffer := ""
setblink( .f. )
set scoreboard off
set century on
set date british
setcursor( 1 )

public lHandleHot
public lIsMouse
public mouserow   := 0
public mousecol   := 0                  // SUPER VARIABLES
public nLastEvent := 0

loadcmp( lChangeIS )

return nil
//********************
static function loadcmp( lChangeIS )

if lChangeIS = NIL
   lChangeIS := .f.
endif
public comp_add := 'Pulliman Jun.'
public gPrefix  := 'WSS'

SLS_ISCOLOR( pcount() = 0 )
if SLS_ISCOLOR()
   SATTCOLOR()
else
   SATTMONO()
endif

vs_Mono( .f. )
vs_InitVern()       // Assume VS_900.DBF

public oFilter      // My Filter Condition ( it is a codeblock)
public dDate   := date()                // Global Date. ( SHOULD CHANGE USING A FUNC. ONLY)

public scproc
public snline
public scvar

close all

setcolor( boxcolor() )

setkey( K_F8, { || vs_calc() } )

dispscrn()

return .t.

//------------------------------------------
exit procedure CLOSETHEDOOR             // make the burglar alarm ON, and

GWDisableColor()
close all           // check if all the windows are closed...
set colo to W/N

if !file( 'DEBUG.DVP' )
   clear
   ?
   ? "Closing databases..."
   ?
   ? "Database Shutdown...Ok"
   ?
   ? "End Run **EasyAccounts v1.5**"
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
return .t.
//********************

function boxcolor

setcursor( 1 )
return 'W+/N*,W/R+'

function menucolor

return 'N+/W+,W+/N*'

function noncolor

setcursor( 1 )
return 'W/N*,W/R+,,,W/N*'

function getcolor

setcursor( 1 )
return 'W+/N*,W+/R+,,,W+/N*'

function scrcolor

setcursor( 1 )
return 'N+/BG*,W+/R+'

function msgcolor

setcursor( 1 )
//return scrcolor()
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
jx := 'EasyAccounts v1.5'
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

local xxb := space( 10 )
setcolor( scrcolor() )
@ 09, ( 79 / 2 - 12 ) say padc( 'USER VERIFICATION', 25 )         
setcolor( boxcolor() )
xx := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
@ 11, ( 79 / 2 ) - 12 + 07 say "Password : "         
@ 12, ( 79 / 2 ) - 12 + 07 get xxb PASSWORD          
read
xxb := rtrim( ltrim( upper( xxb ) ) )
if ( xxb != u_1scramble() ) .and. ( xxb != u_2scramble() )
   set color to W/N
   clear
   ?
   ? "Invalid Password"
   ? "Load attempt failed."
   ?
   ? "**EA 1.0**"
   ?
   ?
   return .f.
endif
if xxb == u_2scramble()
   setsp( .t. )
else
   setsp( .f. )
endif
dispscrn()
return .t.
//--------------------------
function u_1scramble

local x := 'T'
local y := 'H'
local z := ''
z := x + y + 'A'
x := 'N'
z += x
z += 'K'
x := 'S'
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

if !file( 'ONQ.CMP' )
   if cDir = NIL .or. empty( cDir )
      cPath := 'C:\EA\02'
   else
      cDir := upper( cDir )
   endif

   if cDir = 'KOLLAM'
      cPath := 'C:\EA\02\KOLLAM'
   elseif cDir = 'PULLIMAN'
      cPath := 'C:\EA\02\PULLIMAN'
   elseif cDir = 'GRAPHICS'
      cPath := 'C:\EA\02\GRAPHICS'
   elseif cDir = 'ADM'
      cPath := 'C:\EA\02\ADM'
   endif
else
   cPath := 'C:\EA'
endif

return cPath
//----------------------
function setpaths

if comp_add = 'Graphics'
   set default to ( dir( 'GRAPHICS' ) )
elseif comp_add = 'Administration'
   set default to ( dir( 'ADM' ) )
elseif comp_add = 'Pulliman'
   set default to ( dir( 'Pulliman' ) )
elseif comp_add = 'Kollam'
   set default to ( dir( 'Kollam' ) )
elseif comp_add = 'Microsolutions'
   set default to ( dir( 'Micros' ) )
elseif comp_add = 'R&D'
   set default to ( dir( 'RnD' ) )
endif
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
if !file( 'ONQ.CMP' )
   open_ac( dDate )
else
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
locate all for rtrim( ltrim( upper( comp ) ) ) = cAdd
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
static function opendatas( cAdd )

//run ('attrib *.dbf -r')
/*
cAdd := upper(rtrim(ltrim(cAdd)))
use (dir()+'\SYSTEM.EA')
set exact off
locate all for rtrim(ltrim(upper(comp)))=cAdd
replace open with .t.
close all
*/

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
locate all for rtrim(ltrim(upper(comp)))=cAdd
replace open with .f.
close all
*/

//run ('attrib *.dbf +r')
return .t.
//------------
function exitassup

lJop := .f.
use (dir()+'\system.ea')
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

local aCompanies := {}
local aComps     := {}
local nLine
local aDirs      := {}
local nSel
local nnP        := 0
jSaveEnv()
dispscrn()
set key K_F2 to
use (dir()+'\SYSTEM.EA')
do while .not. eof()
   if rtrim( ltrim( upper( company ) ) ) != rtrim( ltrim( upper( comp_add ) ) ) .and. ;
             rtrim( ltrim( upper( company ) ) ) != 'SYSTEM'
      aadd( aCompanies, proper( DESC ) )
      aadd( aComps, COMPANY )
      aadd( aDirs, DIR )
   endif
   skip
enddo
use
close all
setcolor( scrcolor() )
@ 07, 22 say padc( 'Select Company', 34 )         
@ 16, 22 say padc( 'þ ESC - Quit', 34 )           
setcolor( boxcolor() )
@ 08, 22 clear to 15, 55
@ 08, 22, 15, 55 box B_DOUBLE_SINGLE
nSel := achoice( 09, 23, 14, 54, aCompanies )
if nSel = 0 .or. nSel = NIL
   close all
   tone( 3420, 1 )
   dispscrn()
   setcolor( boxcolor() )
   makebox( 08, 22, 15, 50, boxcolor() )
   @ 09, 24 say "Û  ** EasyAccounts"           
   @ 10, 24 say "Û             v1.5  "         
   @ 11, 24 say "Û                "            

   @ 13, 24 say "Û"         

   @ 12, 30 say 'SURE TO QUIT ?'         
   @ 14, 34 prompt 'Yes'
   @ 14, 40 prompt 'No'
   tone( 4520, 1 )
   tone( 320, 1 )
   menu to nnP
   if nnP = 1
      close all
      quit
   else
      jRestEnv()
      return
   endif
endif
set default to ( dir() + '\' + aDirs[ nSel ] )
gwchDir( dir() + '\' + aDirs[ nSel ] )
comp_add := aComps[ nSel ]
set key K_F2 to changecomp
downclose( .t. )
keyboard chr( K_ENTER )
jRestEnv()
close all
return .t.

//------------------
function downclose( lDo )

static downed := .f.
if lDo != NIL
   downed := lDo
endif
return downed
//------------------
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
function jAlert( cMessage, aOptions )

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

setcolor( msgcolor() )

Makebox( nTop, nLeft, nTop + nMessages + 3, nRight, msgcolor() )

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
   nKey := inkey( 0 )

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

restscreen( nTop - 2, nLeft - 4, nTop + nMessages + 8, nRight + 3 )
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
aadd( aaCursor, setcursor() )
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
   x ++
enddo
if len( aDbfs ) > 0
   aadd( aaDbfs, aDbfs )
endif
x := 1
do while !x > len( aDbfs )
   select( aDbfs[ x, 1 ] )
   aadd( aFilters, dbfilter() )
   aadd( aActInd, indexord() )
   x ++
enddo
aadd( aaFilters, aFilters )
aadd( aaActInd, aActInd )
aadd( aaScreen, { savescreen( 0, 0, 24, 79 ), row(), col(), setcolor() } )
return .t.
//-----------------------------
function jRestEnv

local x     := 1
local yy    := 1
local jTemp
close all
restscreen( 0, 0, 24, 79, aaScreen[ len( aaScreen ), 1 ] )
@ aaScreen[ len( aaScreen ), 2 ], aaScreen[ len( aaScreen ), 3 ] say ""         
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
   do while !x > len( aaDbfs )
      select( aaDbfs[ len( aaDbfs ) ] [ x, 1 ] )
      if !empty( rtrim( ltrim( aaFilters[ len( aaFilters ), x ] ) ) )
         jTemp := &( "{||" + aaFilters[ len( aaFilters ), x ] + "}" )
         dbsetfilter( jTemp, aaFilters[ len( aaFilters ), x ] )
      endif
      if !aaActInd[ len( aaActInd ), x ] = 0
         set order to (aaActInd[len(aaActInd),x])
      endif
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
return .t.
//===============================
function plswait( lBoxOn, cMessage, nTop, nLeft, nBottom, nRight )

local cInColor
local nLenMessage

static nsTop    := {}
static nsLeft   := {}
static nsBottom := {}
static nsRight  := {}
static cUnder   := {}

if !valtype( cMessage ) == "C"
   cMessage := "Please wait..."
endif

nLenMessage := min( len( cMessage ), 76 )
cMessage    := left( cMessage, nLenMessage )

if lBoxOn
   if nTop # nil .and. nLeft # nil .and. nRight # nil .and. nBottom # nil
      aadd( nsTop, nTop )
      aadd( nsLeft, nLeft )
      aadd( nsBottom, nBottom )
      aadd( nsRight, nRight )
   else
      aadd( nsTop, 10 )
      aadd( nsBottom, 12 )
      aadd( nsLeft, int( ( 79 - nLenMessage ) / 2 - 1 ) )
      aadd( nsRight, nsLeft[ len( nsTop ) ] + nLenMessage + 2 )
   endif
endif
if lBoxOn
   cInColor := setcolor()
   aadd( cUnder, makebox( nsTop[ len( nsTop ) ], nsLeft[ len( nsLeft ) ], nsBottom[ len( nsBottom ) ], nsRight[ len( nsRight ) ], sls_popcol() ) )
   @ nsTop[ len( nsTop ) ] + 1, nsLeft[ len( nsTop ) ] + 1 say cMessage color sls_popcol()        
   setcolor( cInColor )
else
   if len( nsTop ) > 0
      unbox( cUnder[ len( nsTop ) ] )
      asize( cUnder, len( nsTop ) - 1 )
      asize( nsTop, len( nsTop ) - 1 )
      asize( nsLeft, len( nsTop ) - 1 )
      asize( nsBottom, len( nsTop ) - 1 )
      asize( nsRight, len( nsTop ) - 1 )
   endif
endif
return ''

*+ EOF: PR_UTILS.PRG
