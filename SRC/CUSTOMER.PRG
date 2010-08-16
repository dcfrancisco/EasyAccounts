#include "std.ch"
#include "setcurs.ch"
#include "box.ch"
#include "inkey.ch"

function custlist( lView )

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
setcolor( scrcolor() )
if lView
   @ 05, 11 say padc( 'Select Customer', 61 )                              
   @ 19, 11 say padc( 'Ч ENTER - Select        Ч S - Search', 61 )         
else
   @ 05, 11 say padc( 'Add/Edit Customer', 61 )                            
   @ 19, 11 say padc( 'Ч A - Add   Ч E - Edit  Ч ESC - Exit', 61 )         
endif
setcolor( browcolor() )
@ 06, 11, 18, 71 box B_DOUBLE_SINGLE + chr( 32 )
if !lView
   use accounts new index ACC_1,ACC_2
   set order to 2
   go top
elseif lView
   sele ACCOUNTS
   set order to 2
endif
oBrowse         := TBrowseDB( 07, 12, 17, 70 )
oBrowse:headSep := 'мям'
oBrowse:colSep  := ' Ё '
oColumn         := TBColumnNew( '         Customer Name & Address', { || padr( rtrim( ltrim( subs( rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", " + details, space( 60 ) ), 1, 60 ) ) ), 47 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

do while .t.
   dispbegin()
   do while ( nKey := inkey() ) == 0 .and. !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      nKey := inkey( 0 )
   endif
   do case
   case nKey == K_ALT_R
      plswait(.t.,'Generating HTML...')
      tb2Html(oBrowse,'EARep.HTM','Customers List')
      plswait(.f.)
      msg('EARep.HTM created!')
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_RIGHT
      oBrowse:right()
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case upper( chr( nKey ) ) == 'A'
      addaccount( 'Debtor' )
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E'
      editaccount( 'Debtor' )
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || subs( rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", " + details, space( 60 ) ), 1, 60 ) }
      jsfilt( oBrowse, 0, { || .t. } )
   case nKey == K_ESC .and. ( !lView )
      exit
   case nKey == K_ENTER .and. ( lView )
      exit
   endcase
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
if !lView
   close all
endif
setcolor( boxcolor() )
return nil

function suplist( lView )

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
@  1,  0 to 23, 79
setcolor( scrcolor() )
if lView
   @ 08, 01 say padc( 'Select Supplier', 78 )                              
   @ 22, 01 say padc( 'Ч ENTER - Select        Ч S - Search', 78 )         
else
   @ 08,  1 say padc( 'Add/Edit Supplier', 78 )                                          
   @ 22,  1 say padc( 'Ч A - Add   Ч R - Report  Ч E - Edit  Ч ESC - Exit', 78 )         
endif
setcolor( linecolor() )
@ 09,  1, 21, 78 box B_DOUBLE + chr( 32 )
if !lView
   use accounts new index ACC_1,ACC_2
   set order to 2
   go top
elseif lView
   sele ACCOUNTS
   set order to 2
endif
oBrowse         := TBrowseDB( 10, 2, 20, 77 )
oBrowse:headSep := 'мям'
oBrowse:colSep  := ' Ё '
oColumn         := TBColumnNew( '         Customer Name & Address', { || subs( rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", " + details, space( 60 ) ), 1, 60 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

do while .t.
   dispbegin()
   do while ( nKey := inkey() ) == 0 .and. !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         tone( 300, 2 )
      endif
      nKey := inkey( 0 )
   endif
   do case
   case nKey == K_UP
      oBrowse:up()
   case nKey == K_DOWN
      oBrowse:down()
   case nKey == K_LEFT
      oBrowse:left()
   case nKey == K_RIGHT
      oBrowse:right()
   case nKey == K_PGDN
      oBrowse:pageDown()
   case nKey == K_PGUP
      oBrowse:pageUp()
   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
   case nKey == K_HOME
      oBrowse:home()
   case nKey == K_END
      oBrowse:end()
   case nKey == K_CTRL_HOME
      oBrowse:panHome()
   case nKey == K_CTRL_END
      oBrowse:panEnd()
   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()
   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()
   case upper( chr( nKey ) ) == 'A'
      addaccount( 'Sundry Creditor' )
   case upper( chr( nKey ) ) == 'E'
      editaccount( 'Sundry Creditor' )
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || subs( rtrim( ltrim( proper( account ) ) ) + iif( !empty( rtrim( ltrim( details ) ) ), ", " + details, space( 60 ) ), 1, 60 ) }
      jsfilt( oBrowse, 0, { || .t. } )
   case nKey == K_ESC .and. ( !lView )
      exit
   case nKey == K_ENTER .and. ( lView )
      exit
   endcase
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
if !lView
   close all
endif
setcolor( boxcolor() )
return nil

*+ EOF: CUSTOMER.PRG
