#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

static clipb1
static clipb2
static clipb3

function EA_APPTS( lOpenDbf )

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors

CLEAR TYPEAHEAD

setcolor( scrcolor() )

if entr_date() = date()
   @  3,  6 say padc( "Today's Programmes", 68 )         
elseif entr_date() = date() + 1
   @  3,  6 say padc( "Tomorrow's Programmes", 68 )         
else
   @  3,  6 say padc( 'Appointments for ' + dtoc( entr_date() ), 68 )         
endif
@ 3, 08 say "þ F2 - Date"
if clipb1 = NIL
   @  3, 58 say 'C:E'         
else
   @  3, 58 say 'C:A'         
endif
@ 300, 300 say ""         
setcursor( 0 )
@ 20,  6 say padc( 'A-Add  C-Copy  P-Paste  D-Delete CtrlPg-DateSkip  M-Move  F3-List', 68 )         
setcolor( boxcolor() )
@  4,  6 clear to 19, 73
@  4,  6, 19, 73 box B_DOUBLE_SINGLE

if lOpenDbf
   use APPTS new
   set filter to date = entr_date()
   go top
endif

oBrowse         := TBrowseDB( 5, 7, 18, 72 )
oBrowse:headSep := 'ÍÑÍ'
oBrowse:colSep  := ' ³ '
oColumn         := TBColumnNew( 'Appointment Details', { || padr( rtrim( ltrim( ;
                DESC ) ) + rtrim( ltrim( details ) ), 63 ) } )

oBrowse:AddColumn( oColumn )
do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 500, 1 )
      elseif oBrowse:hitBottom
         tone( 500, 1 )
      endif
      setcolor( scrcolor() )
      if clipb1 = NIL
         @  3, 58 say 'C:E'         
      else
         @  3, 58 say 'C:A'         
      endif
      setcursor( 0 )
      @ 300, 300 say ""         
      setcolor( boxcolor() )
      nKey := inkey( 0 )
   endif
   applykey( nKey, oBrowse )
enddo
set filter to
ontask( 'Purging Empty records...' )
close all
use appts exclusive
go top
delete all for empty( rtrim( ltrim( desc ) ) + rtrim( ltrim( details ) ) )
pack
use
return nil
/*/ / -- -- -- -- -- -- -- -- -- -
PURGE OLD RECORDS: -

ontask( 'Purging old records...' )
use appts
delete all for date < ( date() - 7 )
pack
ontask()

PURGES all RECORDS ONE WEEK AHEAD.
-- -- -- -- -- -- -- -- -- -- -- */

static function applykey( nKey, b )

local lProcessed := .t.
local dMoveDate
local nOldRec
local line
local x
local y
local z
do case
case nKey == K_ALT_R
   plswait(.t.,'Generating HTML...')
   tb2Html(b,'EARep.HTM','Appointments List')
   plswait(.f.)
   msg('EARep.HTM created!')
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
case nKey == K_CTRL_HOME
   b:goBottom()
case nKey == K_CTRL_END
   b:goTop()
case nKey == K_HOME
   b:home()
case nKey == K_END
   b:end()
case nKey == K_CTRL_LEFT
   b:panLeft()
case nKey == K_CTRL_RIGHT
   b:panRight()
case upper( chr( nKey ) ) == 'C'
   clipb1 := desc
   clipb2 := details
   clipb3 := date
case upper( chr( nKey ) ) == 'D'
   jRLock()
   field->desc    := space( 1 )
   field->details := space( 1 )
   field->date    := ctod( '00/00/0000' )
   jRUnLock()
   go top
   b:refreshall()
case upper( chr( nKey ) ) == 'P'
   if clipb1 != NIL
      append blank
      field->desc    := clipb1
      field->details := clipb2
      field->date    := entr_date()
      jRUnLock()
      go top
      b:refreshall()
   else
      msg( 'Clipboard Empty!' )
   endif
case nKey == K_ENTER .and. b:stable     // edit current cell directly
   x := desc
   y := subs( details, 1, 12 )
   popread( .f., '', @x, '@X', ;
            '', @y, '@XXXXXXXXXXXX' )
   jRLock()
   field->desc    := x
   field->details := y
   jRUnLock()
   b:refreshall()
   do while !b:stabilize()
   enddo
case upper( chr( nKey ) ) = 'A'
   set filter to
   append blank
   field->date := entr_date()
   set filter to date = entr_date()
   b:down()
   b:refreshall()
   do while !b:stabilize()
   enddo
   x := desc
   y := subs( details, 1, 12 )

   popread( .f., '', @x, '@X', ;
            '', @y, '@XXXXXXXXXXXX' )
   jRLock()
   field->desc    := x
   field->details := y
   jRUnLock()
   b:refreshall()
   do while !b:stabilize()
   enddo
case nKey == K_F2
   z := savescreen()
   chndate()
   restscreen( 0, 0, 24, 79, z )
   b:gotop()
   do while !b:stabilize()
   enddo
   setcolor( scrcolor() )
if entr_date() = date()
   @  3,  6 say padc( "Today's Programmes", 68 )         
elseif entr_date() = date() + 1
   @  3,  6 say padc( "Tomorrow's Programmes", 68 )         
else
   @  3,  6 say padc( 'Appointments for ' + dtoc( entr_date() ), 68 )         
endif
   if clipb1 = NIL
      @  3, 58 say 'C:E'         
   else
      @  3, 58 say 'C:A'         
   endif
   @ 3, 07 say "þF2-Set Date"
   setcolor( boxcolor() )
case nKey == K_F3
   jSaveEnv()
   nOldRec := recno()
   set filter to
   go top
   index on date to APPTS_1
   go top
   set device to printer
   set printer to (RepPath+'APPTLST.TXT')
   set printer on
   line := 1
   @ line,  1 say padc( 'Appointments List', 77 )         
   line ++
   line ++
   @ line,  1 say "Date    Appointment Details"         
   do while .not. eof()
      x := date
      @ line,  1 say date         
      do while date == x .and. ( !eof() )
         @ line, 12 say rtrim( ltrim( desc ) ) + ' ' + rtrim( ltrim( details ) )         
         line ++
         skip
      enddo
   enddo
   line ++
   line ++
   line ++
   @ line, 01 say padc( '*** END OF LIST ***', 77 )         
   set device to screen
   set printer off
   set printer to
   fileread( 1, 0, 23, 79, RepPath+'APPTLST.TXT', 'Appointments List' )
   set filter to date = entr_date()
   go nOldRec
   jRestEnv()
case upper( chr( nKey ) ) = 'M'
   dMoveDate := entr_date() + 1
   popread( .f., 'Move current Appointment to Date : ', @dMoveDate, '@D' )
   jRLock()
   field->date := dMoveDate
   JRUnLock()
   b:gotop()
   do while !b:stabilize()
   enddo
case nKey == K_CTRL_PGUP
   entr_date(entr_date()-1)
   b:gotop()
   do while !b:stabilize()
   enddo
   setcolor( scrcolor() )
if entr_date() = date()
   @  3,  6 say padc( "Today's Programmes", 68 )         
elseif entr_date() = date() + 1
   @  3,  6 say padc( "Tomorrow's Programmes", 68 )         
else
   @  3,  6 say padc( 'Appointments for ' + dtoc( entr_date() ), 68 )         
endif
      if clipb1 = NIL
         @  3, 58 say 'C:E'         
      else
         @  3, 58 say 'C:A'         
      endif
   @ 3, 07 say "þF2-Set Date"
   setcolor( boxcolor() )

case nKey == K_CTRL_PGDN
   entr_date(entr_date()+1)
   b:gotop()
   do while !b:stabilize()
   enddo
   setcolor( scrcolor() )
if entr_date() = date()
   @  3,  6 say padc( "Today's Programmes", 68 )         
elseif entr_date() = date() + 1
   @  3,  6 say padc( "Tomorrow's Programmes", 68 )         
else
   @  3,  6 say padc( 'Appointments for ' + dtoc( entr_date() ), 68 )         
endif
      if clipb1 = NIL
         @  3, 58 say 'C:E'         
      else
         @  3, 58 say 'C:A'         
      endif
   @ 3, 07 say "þF2-Set Date"
   setcolor( boxcolor() )
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
readmodal( { getnew( row(), col(), oColumn:block, oColumn:heading, ;
             oColumn:picture, oBrowse:colorSpec ) } )
setcursor( nOldcursor )                 // turn cursor back off
setkey( K_INS, lOldins )                // reset INS key
set( _SET_INSERT, lInsState )
return ( eval( oColumn:block ) <> xOldvalue )

// eof: APPTS.PRG

*+ EOF: APPTS.PRG
