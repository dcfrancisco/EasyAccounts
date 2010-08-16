#include "std.ch"
#include "inkey.ch"

static nPos

local DevBy := 'EasyAccounts v2.5 Color System (Real Mode)'
DevBy := '(C) Jasim A Basheer, Wintech Computers'

parameter nWhat,cDataDir, cCommand

// This program cannot be linked in Protected mode.
// What I did was, I made this a seperate executable and RUNned it from
// the program when the menu was invoked.
// Therefore even if I tell QUIT, it returns back to EA.

//
// This is just to make those strings appear in the EXE file.
// 'Cauz the people may think that this is an external utility which I am
// using to increase my functionality. Little do they know about the
// real and extended bluffs.
//


if cCommand = NIL
  cCommand := ""
endif

if nWhat = NIL
   ?
   ? "EasyAccounts v2.5 Colour Controller (Real Mode)"
   ? "(C) Jasim A Basheer, Wintech Computers"
   ?
   ? "ERROR : To be called from EA protected environment."
   ?
   quit
else
   nWhat := val( nWhat )
endif

setblink( .f. )
if nWhat = 1416
   chn_color()
elseif nWhat = 2458
   c_loadIt(cCommand)
elseif nWhat = 3618
   gwEnableColor()
   gwDisableColor()
else
   ?
   ? "EasyAccounts v2.5 Colour Controller (Real Mode)"
   ? "(C) Jasim A Basheer, Wintech Computers"
   ?
   ? "ERROR : To be called from EA protected environment."
   ?
   quit
endif

function chn_color

local nColor := 1
local nKey   := 0
local cScrn

nPos := 1

setcursor( .f. )
c_loadit()

go bott
setColColor()       // if boxcolor, we cant see that part for
// changing the colors.
cScrn := savescreen( 10, 10, 20, 60 )
@  6, 13 clear to 16, 65
@  6, 13 to 16, 65
setcolor( scrcolor() )
@ 07, 14 say padc( 'Change Colors', 51 )         
setColColor()
footline( 08, 14, 51 )
@ 09, 27 say "<R>ed"           
@ 09, 37 say "<G>reen"         
@ 09, 47 say "<B>lue"          
nPos := 1
nRGB := 1
@ 10, 27 say str( gwvgacolor( n_color( nPos ) ) [ nRGB ], 3, 0 )         
nRGB ++
@ 10, 37 say str( gwvgacolor( n_color( nPos ) ) [ nRGB ], 4, 0 )         
nRGB ++
@ 10, 47 say str( gwvgacolor( n_color( nPos ) ) [ nRGB ], 4, 0 )         
nRGB := 1
@ 12, 16 say "Normal"             
@ 12, 24 say "  Title"            
@ 12, 35 say "Foreground"         
@ 12, 46 say "Popup"              
@ 12, 56 say "Feedback"           
footline( 11, 14, 51 )
setcolor( 'N+/W+' )
@ 13, 14 say space( 9 )         
@ 14, 14 say space( 9 )         
@ 13, 14 to 14, 23
setcolor( 'W+/BG*' )
@ 13, 25 say space( 8 )         
@ 14, 25 say space( 8 )         
@ 13, 25 to 14, 33
setcolor( 'W+/N*' )
@ 13, 35 say space( 10 )         
@ 14, 35 say space( 10 )         
@ 13, 35 to 14, 45
setcolor( 'W+/B+' )
@ 13, 46 say space( 8 )         
@ 14, 46 say space( 8 )         
@ 13, 46 to 14, 54
setcolor( 'W+/RB+' )
@ 13, 56 say space( 8 )         
@ 14, 56 say space( 8 )         
@ 13, 56 to 14, 64
do while .t.
   setColColor()
   if nPos = 1
      @ 15, 18 say ""         
   elseif nPos = 2
      @ 15, 29 say ""         
   elseif nPos = 3
      @ 15, 40 say ""         
   elseif nPos = 4
      @ 15, 49 say ""         
   elseif nPos = 5
      @ 15, 60 say ""         
   endif
   setcursor( .f. )
   setcursor( 0 )
   nKey := inkey( 0 )
   setColColor()
   @ 15, 16 say space( 49 )         
   if nKey = K_ENTER .or. nKey = K_ESC
      return .t.
   elseif nKey == K_RIGHT
      if nPos < 5
         nPos ++
      else
         nPos := 1  // Wrap
      endif
      @ 10, 27 say str( gwvgacolor( n_color( nPos ) ) [ 1 ], 3, 0 )         
      @ 10, 37 say str( gwvgacolor( n_color( nPos ) ) [ 2 ], 4, 0 )         
      @ 10, 47 say str( gwvgacolor( n_color( nPos ) ) [ 3 ], 4, 0 )         
   elseif nKey == K_LEFT
      if nPos > 1
         nPos --
      else
         nPos := 5  // Wrap
      endif
      @ 10, 27 say str( gwvgacolor( n_color( nPos ) ) [ 1 ], 3, 0 )         
      @ 10, 37 say str( gwvgacolor( n_color( nPos ) ) [ 2 ], 4, 0 )         
      @ 10, 47 say str( gwvgacolor( n_color( nPos ) ) [ 3 ], 4, 0 )         
   else
      nKey := chr( nKey )
      if nKey == 'R'
         addred()
      elseif nKey == 'G'
         addgreen()
      elseif nKey == 'B'
         addblue()
      elseif nKey == 'r'
         deductred()
      elseif nKey == 'g'
         deductgreen()
      elseif nKey == 'b'
         deductblue()
      endif
      @ 10, 27 say str( gwvgacolor( n_color( nPos ) ) [ 1 ], 3, 0 )         
      @ 10, 37 say str( gwvgacolor( n_color( nPos ) ) [ 2 ], 4, 0 )         
      @ 10, 47 say str( gwvgacolor( n_color( nPos ) ) [ 3 ], 4, 0 )         
   endif
enddo
return .t.
//---------------------
static function n_color( nPos )

local x
if nPos = 1
   x := 7
elseif nPos = 2
   x := 11
elseif nPos = 3
   x := 8
elseif nPos = 4
   x := 1
elseif nPos = 5
   x := 5
endif
return x
//---------------------
static function addred()

local cVal := str( val( subs( fieldget( nPos ), 1, 2 ) ) + 1, 2, 0 ) + subs( fieldget( nPos ), 3 )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
cVal := c_verify( cVal )
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5, 2 ) ) } )
return .t.

static function deductred()

local cVal := str( val( subs( fieldget( nPos ), 1, 2 ) ) - 1, 2, 0 ) + subs( fieldget( nPos ), 3 )
cVal := c_verify( cVal )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5, 2 ) ) } )
return .t.
//------------------
static function addgreen()

local cVal := subs( fieldget( nPos ), 1, 2 ) + str( val( subs( fieldget( nPos ), 3, 2 ) ) + 1, 2, 0 ) + ;
                    subs( fieldget( nPos ), 5 )
cVal := c_verify( cVal )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5 ) ) } )
return .t.

static function deductgreen()

local cVal := subs( fieldget( nPos ), 1, 2 ) + str( val( subs( fieldget( nPos ), 3, 2 ) ) - 1, 2, 0 ) + ;
                    subs( fieldget( nPos ), 5 )
cVal := c_verify( cVal )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5, 2 ) ) } )
return .t.
//--------------------
static function addblue()

local cVal := subs( fieldget( nPos ), 1, 4 ) + str( val( subs( fieldget( nPos ), 5, 2 ) ) + 1, 2, 0 ) + ;
                    subs( fieldget( nPos ), 6 )
cVal := c_verify( cVal )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5, 2 ) ) } )
return .t.

static function deductblue()

local cVal := subs( fieldget( nPos ), 1, 4 ) + str( val( subs( fieldget( nPos ), 5, 2 ) ) - 1, 2, 0 ) + ;
                    subs( fieldget( nPos ), 6 )
cVal := c_verify( cVal )
jRLock()
fieldput( nPos, cVal )
jRUnLock()
gwvgacolor( n_color( nPos ), { val( subs( cVal, 1, 2 ) ), val( subs( cVal, 3, 2 ) ), ;
        val( subs( cVal, 5, 2 ) ) } )
return .t.

function c_verify( cVal )

local x
local y
local z
x := val( subs( cVal, 1, 2 ) )
y := val( subs( cVal, 3, 2 ) )
z := val( subs( cVal, 5, 2 ) )
if x > 63
   x := 1
elseif x < 0
   x := 63
endif
if y > 63
   y := 1
elseif y < 0
   y := 63
endif
if z > 63
   z := 1
elseif z < 0
   z := 63
endif
cVal := str( x, 2, 0 ) + str( y, 2, 0 ) + str( z, 2, 0 )
return cVal
//-----------------------------
static function setColColor

return setcolor( boxcolor() )
//-----------------------------
function c_loadit(cWhat)

local x1
local x2
local x3
local x4
local x5
GWEnableColor()
close all

if (! file(cDataDir+'\SYSTEM.INT')) .or. (cWhat == 'RESET')
   dbcreate(cDataDir+'\SYSTEM.INT', { { 'SCREEN', 'C', 6, 0 },;
                            { 'TITLE', 'C', 6, 0 },;
                            { 'FOREGROUND', 'C', 6, 0},;
                            { 'GETCOLOR', 'C', 6, 0},;
                            { 'FEEDBACK', 'C', 6, 0} } )
   use (cDataDir+'\SYSTEM.INT')
   appe blank
   field->screen := "424242"
   field->title := "216363"
   field->foreground := "212121"
   field->getcolor := "212163"
   field->feedback := "42 042"
   appe blank
   field->screen := "424242"
   field->title := "216363"
   field->foreground := "212121"
   field->getcolor := "212163"
   field->feedback := "42 042"
   close all
endif

use (cDataDir+'\SYSTEM.INT')
if fieldpos('FEEDBACK') == 0
   copy all to system.tms
   copy stru extended to systmp.tmp
   use systmp.tmp
   appe blank
   field->FIELD_NAME := 'FEEDBACK'
   field->FIELD_TYPE := 'C'
   field->FIELD_LEN  :=  6
   field->FIELD_DEC  :=  0
   close all
   CREATE (cDataDir+'\SYSTEM.INT') from SYSTMP.TMP
   close all
   use (cDataDir+'\SYSTEM.INT')
   appe from system.tms
   do while ! eof()
      field->FEEDBACK := '42 042'
      skip
   enddo
   close all
   ferase('SYSTMP.TMP')
   ferase('SYSTEM.TMS')
endif
close all

use (cDataDir+'\SYSTEM.INT')
go bott
if !empty( screen )
   gwvgacolor( 7, { val( subs( screen, 1, 2 ) ), val( subs( screen, 3, 2 ) ), ;
                    val( subs( screen, 5, 2 ) ) } )
   // WHITE

   gwvgacolor( 11, { val( subs( title, 1, 2 ) ), val( subs( title, 3, 2 ) ), ;
                     val( subs( title, 5, 2 ) ) } )
   // SCRCOLOR (N*/BG+) TITLE BACKGROUND

   gwvgacolor( 8, { val( subs( foreground, 1, 2 ) ), val( subs( foreground, 3, 2 ) ), ;
                    val( subs( foreground, 5, 2 ) ) } )

   // BOXCOLOR (N*)

   gwvgacolor( 9, { val( subs( getcolor, 1, 2 ) ), val( subs( getcolor, 3, 2 ) ), ;
                    val( subs( getcolor, 5, 2 ) ) } )
   // B

   gwvgacolor( 5, { val( subs( feedback, 1, 2 ) ), val( subs( feedback, 3, 2 ) ), ;
                    val( subs( feedback, 5, 2 ) ) } )
   // BR+

else

   if reccount() != 0
      go top
      x1 := screen
      x2 := title
      x3 := foreground
      x4 := getcolor
      x5 := feedback
      skip
      jRLock()
      field->screen := x1
      field->title  := x2
      replace foreground with x3
      field->getcolor := x4
      field->feedback := x5
      jRUnLock()
   else
      append blank
      field->screen := str( gwvgacolor( 7 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 7 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 7 ) [ 3 ], 2, 0 )
      field->title  := str( gwvgacolor( 11 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 11 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 11 ) [ 3 ], 2, 0 )
      replace foreground with str( gwvgacolor( 8 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 8 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 8 ) [ 3 ], 2, 0 )
      field->getcolor := str( gwvgacolor( 9 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 9 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 9 ) [ 3 ], 2, 0 )
      field->feedback := str( gwvgacolor( 5 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 5 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 5 ) [ 3 ], 2, 0 )
      append blank
      field->screen := str( gwvgacolor( 7 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 7 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 7 ) [ 3 ], 2, 0 )
      field->title  := str( gwvgacolor( 11 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 11 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 11 ) [ 3 ], 2, 0 )
      replace foreground with str( gwvgacolor( 8 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 8 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 8 ) [ 3 ], 2, 0 )
      field->getcolor := str( gwvgacolor( 9 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 9 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 9 ) [ 3 ], 2, 0 )
      field->feedback := str( gwvgacolor( 5 ) [ 1 ], 2, 0 ) + str( gwvgacolor( 5 ) [ 2 ], 2, 0 ) + str( gwvgacolor( 5 ) [ 3 ], 2, 0 )
      jRUnLock()
   endif

endif
use

return .t.
//=============================== FUNCTIONS FROM UTILS.PRG
function boxcolor

setcursor( 1 )
return 'W+/N*,W/R+'

function jRLock

local y
local nOldR := row()
local nOLP  := col()
plswait( .t., 'Locking record...' )
y := rlock()
plswait( .f. )
if !y
   plswait( .t., 'Record on use. Waiting for access...' )
   do while !rlock()
   enddo
   plswait( .f. )
endif
@ nOLDR, nOLP say ""         
return .t.
//-----------------------
function jRUnLock

unlock
return .t.
//-----------------------
function jFLock

local y
local nOldR := row()
local nOLP  := col()
plswait( .t., 'Locking database...' )
y := flock()
plswait( .f. )
if !y
   plswait( .t., 'Database on use. Waiting for access...' )
   do while !rlock()
   enddo
   plswait( .f. )
endif
@ nOLDR, nOLP say ""         
return .t.
//-----------------------
function scrcolor

setcursor( 1 )
return 'N+/BG*,W+/R+'
//-------------------------
function footline( ROW, col, width )

row   := iif( row = nil, 21, row )
col   := iif( col = nil, 0, col - 1 )
width := iif( width = nil, maxcol(), width )
@ row, col say "Ã" + replicate( 'Ä', width ) + "´"         
return nil

*+ EOF: COLORS.PRG
