#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

function ea_phone

local x := 0
do while .t.
   dispbegin()
   dispscrn()
   @ 09, 30, 13, 50 box B_DOUBLE_SINGLE
   setcolor( scrcolor() )
   @ 08, 30 say padc( 'Telephone', 21 )            
   @ 14, 30 say padc( 'þ ESC - Exit', 21 )         
   setcolor( boxcolor() )
   dispend()
   x := achoice( 10, 31, 12, 49, { 'Add/Edit', 'Find Number', 'List Directory' } )
   dispscrn()
   if x = 0 .or. x = nil
      exit
   elseif x = 1
      addedit()
   elseif x = 2
      findnum()
   elseif x = 3
      dispdirec()
   endif
enddo
return .t.
//---------------------------------
static function addedit

local oBrowse
local oColumn
local nKey
@  3,  1, 21, 77 box B_DOUBLE_SINGLE
setcolor( scrcolor() )
@ 02,  1 say padc( 'Add/Edit Phone', 77 )                                                        
@ 22,  1 say padc( 'þ A - Add       þ ALT+S - Search        þ ENTER - Edit       þ ESC - Exit', 78 )         
setcolor( boxcolor() )
setcursor( .f. )
setcursor( 0 )
use PHONE new index PHONE_1
oBrowse           := TBrowseDB( 4, 2, 20, 76 )
oBrowse:colorSpec := boxcolor()
oBrowse:headSep   := 'ÍÑÍ'
oBrowse:colSep    := ' ³ '
oColumn           := TBColumnNew( 'Name', fieldblock( 'NAME' ) )
oBrowse:AddColumn( oColumn )
oColumn := TBColumnNew( 'Phone Number', fieldblock( 'PHONE' ) )
oBrowse:AddColumn( oColumn )
do while nKey <> K_ESC
   dispbegin()
   do while ( nKey := inkey() ) == 0 .and. !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )                 // There is A - To Add
      endif
      nKey := inkey( 0 )
   endif
   applykey( nKey, oBrowse )
enddo
close all
plswait( .t., 'Purging empty records...' )
eUse( "PHONE" )
set index to PHONE_1
delete all for empty( rtrim( ltrim( name + phone ) ) )
pack
close all
plswait( .f. )
setcursor( .t. )
setcursor( 1 )
return nil

static function applykey( nKey, b )

local lProcessed := .t.
local x
do case
case nKey == K_ALT_R
   plswait(.t.,'Generating HTML...')
   tb2Html(b,'EARep.HTM','Phone List')
   plswait(.f.)
   msg('EARep.HTM created!')

case nKey == K_ALT_S     // Search
    oFilter := { || name + ', ' + phone }
    jsfilt( b, 0, { || .t. } )

case nKey == K_UP
   b:up()
case nKey == K_DOWN
   b:down()
case nKey == K_LEFT
   b:left()
case nKey == K_RIGHT
   b:right()
case nKey == K_PGDN
   b:pageDown()
case nKey == K_PGUP
   b:pageUp()
case nKey == K_CTRL_PGDN
   b:goBottom()
case nKey == K_CTRL_PGUP
   b:goTop()
case nKey == K_HOME
   b:home()
case nKey == K_END
   b:end()
case nKey == K_CTRL_HOME
   b:panHome()
case nKey == K_CTRL_END
   b:panEnd()
case nKey == K_CTRL_LEFT
   b:panLeft()
case nKey == K_CTRL_RIGHT
   b:panRight()
case upper( chr( nKey ) ) == 'A'
   append blank
   b:refreshall()
   do while !b:stabilize()
   enddo
   keyboard chr( K_ENTER )              // Create a new record and edit it.
case ( nKey == K_ENTER .or. isalpha( chr( nKey ) ) .or. isdigit( chr( nKey ) ) ) .and. b:stable     // edit current cell directly
   setcursor( .t. )
   setcursor( 1 )
   if isalpha( chr( nKey ) )
      keyboard chr( nKey )
   endif
   if EditCell( b )
      //ÄÄÄÄ force redisplay of current row
      //ÄÄÄÄ note that you might need to do a b:refreshAll()
      //ÄÄÄÄ if you have changed an index key field
      b:refreshall()
   endif
   setcursor( .f. )
   setcursor( 0 )
otherwise
   lProcessed := .f.
endcase
return lProcessed

static function EditCell( oBrowse )

local oColumn   := oBrowse:getColumn( oBrowse:colPos )
local xOldvalue := eval( oColumn:block )
local lInsState := set( _SET_INSERT )
//ÄÄÄÄ set insert key to toggle both insert mode & cursor
local lOldins := setkey( K_INS, { || setcursor( ;
        if( readinsert( !readinsert() ), SC_NORMAL, SC_INSERT ) ) } )

//ÄÄÄÄ initial cursor setting based on current mode
local nOldcursor := setcursor( if( readinsert(), SC_INSERT, SC_NORMAL ) )

//ÄÄÄÄ create corresponding GET with GETNEW() and read it now
jRLock()
readmodal( { getnew( row(), col(), oColumn:block, oColumn:heading, ;
             oColumn:picture, oBrowse:colorSpec ) } )
jRUnLock()
setcursor( nOldcursor )                 // turn cursor back off
setkey( K_INS, lOldins )                // reset INS key
set( _SET_INSERT, lInsState )
return ( eval( oColumn:block ) <> xOldvalue )
//----------------------------
function findnum

local cToFind := space( 34 )
local aArray  := {}
local aList   := {}
local nChoice
@ 09, 22 clear to 13, 50
@ 09, 22, 13, 50 box B_DOUBLE_SINGLE
setcolor( scrcolor() )
@ 08, 22 say padc( 'Find Phone Number', 29 )         
@ 14, 22 say padc( 'þ ESC - Exit', 29 )              
setcolor( boxcolor() )
@ 10, 23 say padc( 'Find ?', 26 )                     
@ 11, 23 get cToFind              pict '@!S26'        
read
if !empty( cToFind )
   //plswait(.t.,'Searching...')
   cToFind := rtrim( ltrim( upper( cToFind ) ) )
   use phone index PHONE_1
   set order to 0
   cPrivate := cToFind
   set filter to cPrivate $ upper( rtrim( ltrim( name + phone ) ) )
   go top
   //plswait(.f.)
   if bof() .or. eof()
      msg( "No records matching the query found..." )
      close all
      return .f.
   else
      //plswait(.t.,'Locating records...')
      do while .not. eof()
         aadd( aArray, rtrim( ltrim( name ) ) + ' - ' + rtrim( ltrim( phone ) ) )
         aadd( aList, { name, phone } )
         skip
      enddo
      //plswait(.f.)
      setcolor( scrcolor() )
      @ 04, 12 say padc( 'Find Phone Number', 60 - 11 )          
      @ 18, 12 say padc( 'þ ENTER - Continue', 61 - 12 )         
      setcolor( boxcolor() )
      @ 05, 12 clear to 17, 60
      @ 05, 12, 17, 60 box B_DOUBLE_SINGLE
      nChoice := achoice( 06, 13, 16, 59, aArray )
      if nChoice != 0 .and. nChoice != NIL
         dispscrn()
         /*
     msg('Name  : '+rtrim(ltrim(aList[nChoice,1])),;
         'Phone : '+rtrim(ltrim(aList[nChoice,2])))
     */
         msg( aArray[ nChoice ] )
      endif
      close all
   endif
endif
return .t.
//--------------
static function dispdirec

local cStart   := " "
local cName
local nCurrent := 1
ShowPBar( 'Generating telephone directory...' )
setprc( 0, 0 )
set cursor off
set console off
set device to printer
set printer to (RepPath+'TEL_DIR.TXT')
set printer on
use phone new index PHONE_1
go top
? '---- Telephone Directory ----'
do while .not. eof()
   cStart := upper( subs( name, 1, 1 ) )
   ?
   ? '*****'
   ? "  " + cStart
   ? '*****'
   ?
   do while upper( subs( name, 1, 1 ) ) == cStart .and. ( !eof() )
      ? proper( subs( name, 1, 34 ) )
      ??
      ??
      ?? padr( proper( subs( phone, 1, 34 ) ), 34 )
      skip
      nCurrent ++
      RefreshPBar( ( nCurrent / reccount() ) * 100 )
      // As this is in alphabetic order, the RecNo() cannot show
      // correct perc as at first it will be the 1000th record
      // and next it will be the 1st record.
      // God knows.
   enddo
enddo
?
? '-------- End of list --------'
set console on
set device to screen
set printer off
set printer to
set cursor on
close all
HidePBar()
fileread( 1, 5, 23, 65, RepPath+'TEL_DIR.TXT', 'Telephone Directory' )
return nil
//-----------
// eof: PHONE.PRG

*+ EOF: PHONE.PRG
