#include "std.ch"
#include "ghost.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

/*-----------------------------------------------------------
Reference Guys (refrs.prg)
==========================
To Maintain the Sales Promoters list
and to track monthly performance in marketing activities.

PIECE OF CAKE!! - But it needs to be baked thoroughly.
------------------------------------------------------------*/

function refrs_view( lView, lOpen )

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
setcolor( scrcolor() )
if lView = NIL
   lView := .f.
endif
if lOpen = NIL
   lOpen := .t.
endif
@  4, 11 say padc( 'Sales Promotors List', 58 )         
if ( !lView .and. lOpen )
   @ 18, 11 say padc( 'þA-Add þE-Edit þS-Search þESC-Abort', 58 )         
elseif ( !lView .and. !lOpen )
   @ 18, 11 say padc( 'þA-Add þE-Edit þS-Search þENTER-Select', 58 )         
else
   @ 18, 11 say padc( 'þENTER - Select  þS-Search', 58 )         
   setcolor( boxcolor() )
endif
setcolor( boxcolor() )
@  5, 11 clear to 17, 68
@  5, 11, 17, 68 box B_DOUBLE_SINGLE
if lOpen
   use refrs new index refrs_1,refrs_2
   set order to 2
   go top
else
   sele refrs
   set order to 2
endif
oBrowse         := TBrowseDB( 6, 12, 16, 67 )
oBrowse:headSep := 'ÍÑÍ'
oBrowse:colSep  := ' ³ '
oColumn         := TBColumnNew( 'Name of Individual/Company', fieldblock( 'NAME' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Type', { || type } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
nKey := 0
do while .t.

   if ( !lView .and. lOpen )
      if nKey == K_ESC
         exit
      endif
   else
      if nKey == K_ENTER
         exit
      endif
   endif
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
   case upper( chr( nKey ) ) == 'A' .and. ( !lView )
      m_addrefrs()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E' .and. ( !lView )
      m_editrefrs()
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'S'
      oFilter := { || name }
      jsfilt( oBrowse, 0, { || .t. } )
   endcase
   if !lOpen
      if nKey == K_ENTER
         if eof()
            jAlert( "CANNOT ACCEPT BLANK RECORD;;" + ;
                    "Please Re-Enter" )
            nKey := 0
            loop
         endif
      endif
   elseif lOpen
      if nKey == K_ESC
         if eof()
            jAlert( "CANNOT ACCEPT BLANK RECORD;;" + ;
                    "Please Re-Enter" )
            nKey := 0
            loop
         endif
      endif
   endif
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
return nil
//------------------------------------------------------------------
static function m_addrefrs

local _xx      := savescreen()
local _oldrec
local aTypes   := { 'Direct', 'Marketing Executive', 'Service Engineer', 'Faculty Member', 'Office Staff', 'Others' }
local nId
local cName    := space( len( name ) )
local cType    := space( len( type ) )
local _yesorno := ' '

sele refrs
_oldrec := recno()

dispscrn()
setcolor( scrcolor() )
@  8,  8 say padc( 'Add Sales Promoter', 53 )         
setcolor( getcolor() )
_yesorno := ' '
@  9, 08 clear to 12, 60
@  9, 08 to 12, 60

@ 10, 09 say "Name.......:" get cName pict '@!'       
@ 11, 09 say "Type.......:"                           
read
@ 10, 09 say "Name.......: " + cName         
if empty( rtrim( ltrim( cName ) ) )
   restscreen( 0, 0, 24, 79, _xx )
   return
endif
cType := apick( 9, 50, 15, 73, aTypes,,,,,,,, 1 )
if cType != 0
   cType := aTypes[ cType ]
   @ 11,  9 say "Type.......: " + cType         
else
   restscreen( 0, 0, 24, 79, _xx )
   return
endif
if confirm( "Save Details", 14 )
   sele refrs
   set order to 1
   set filter to
   go bottom
   nId := id + 1
   append blank
   field->id := substr( cType, 1, 1 ) + substr( cType, at( ' ', cType ) + 1, 1 ) + ;
                        strtran( str( recno(), 3, 0 ), ' ', '0' ) + ;
                        strtran( str( day( date() ), 2, 0 ), ' ', '0' ) + ;
                        strtran( str( month( date() ), 2, 0 ), ' ', '0' ) + ;
                        strtran( str( year( date() ), 4, 0 ), ' ', '0' )
   field->id   := nId
   field->name := cName
   field->type := cType
   sele refrs
else
   sele refrs
   go _oldrec
endif
restscreen( 0, 0, 24, 79, _xx )
return nil
//---------------------------------------
static function m_editrefrs

local _xx      := savescreen()
local _oldrec
local nId
local cName    := name
local cType    := type
local aTypes   := { 'Direct', 'Marketing Executive', 'Service Engineer', 'Faculty Member', 'Office Staff', 'Others' }
local _yesorno := ' '
local nFRec

sele refrs

dispscrn()
setcolor( scrcolor() )
@  8,  8 say padc( 'Edit Sales Promoter', 53 )         
setcolor( getcolor() )

_yesorno := ' '
@  9,  8 clear to 12, 60
@  9,  8 to 12, 60

@ 10,  9 say "Name.......:" get cName pict '@!'       
@ 11,  9 say "Type.......:"                           
read
@ 10,  9 say "Name.......: " + cName         
if empty( rtrim( ltrim( cName ) ) )
   restscreen( 0, 0, 24, 79, _xx )
   return
endif
cType := rtrim( ltrim( cType ) )
nFRec := ascan( aTypes, cType )
if nFRec = 0
   nFRec := 1
endif
cType := apick( 9, 50, 15, 73, aTypes,,,,,,,, nFRec )
if cType != 0
   cType := aTypes[ cType ]
   @ 11,  9 say "Type.......: " + cType         
else
   restscreen( 0, 0, 24, 79, _xx )
   return
endif
if confirm( "Save Details", 14 )
   if empty( rtrim( ltrim( id ) ) )
      field->id := substr( cType, 1, 1 ) + substr( cType, at( ' ', cType ) + 1, 1 ) + ;
                           strtran( str( recno(), 3, 0 ), ' ', '0' ) + ;
                           strtran( str( day( date() ), 2, 0 ), ' ', '0' ) + ;
                           strtran( str( month( date() ), 2, 0 ), ' ', '0' ) + ;
                           strtran( str( year( date() ), 4, 0 ), ' ', '0' )
   else
      field->id := substr( cType, 1, 1 ) + substr( cType, at( ' ', cType ) + 1, 1 ) + ;
                           subs( id, 3 )
   endif
   field->name := cName
   field->type := cType
endif
restscreen( 0, 0, 24, 79, _xx )
return nil
//=====================================================================
function viewindacc                     // View Individual References Account.

local line     := 0
local nTMargin := 0
local nTCredit := 0
local nTPaid   := 0
use SACCOUNT new index SAC_1
use SALE_REF new index SREF_2
use REFRS new index REFRS_1,REFRS_2
refrs_view( .t., .f. )
sele SALE_REF
seek REFRS->id
if !found()
   jalert( 'Selected account have no balance.' )
   close all
   return .f.
endif
set device to PRINTER
set printer to (RepPath+'REFRS.TXT')
set printer on
if !sp_visor()
   SayTitles( 48, @line )
   line ++
   @ line,  0 say padc( 'Marketing Analysis : ' + refrs->id + ', ' + proper( refrs->name ), 48 )         
   line ++
   @ line,  0 say repli( '-', 48 )         
   line ++
   @ line,  0 say 'Date'            
   @ line, 12 say 'Bill'            
   @ line, 18 say 'Total'           
   @ line, 30 say '%' // 36         
   @ line, 37 say 'Debit'           
   @ line, 43 say 'Credit'          
   line ++
   @ line,  0 say repli( '-', 48 )         
   line ++
   do while refrs->id == sale_ref->refrs_id
      if debit = 0
         sele saccount
         seek sale_ref->sale_id
         @ line,  0 say date                                  
         @ line, 12 say str( id, 4, 0 )                       
         @ line, 18 say str( total - discount, 8, 0 )         
         sele sale_ref
         @ line, 29 say str( perc, 3, 0 )                                                              
         @ line, 43 say str( round( ( saccount->margin * .15 ) * ( perc / 100 ), - 1 ), 5, 0 )         
         nTCredit += round( ( saccount->margin * .15 ) * ( perc / 100 ), - 1 )
      else
         @ line,  0 say date                
         @ line, 12 say 'Cash Paid'         
         sele sale_ref
         @ line, 37 say str( debit, 5, 0 )         
         nTPaid += debit
      endif
      line ++
      sele sale_ref
      skip
   enddo
   if nTPaid > 0
      @ line, 37 say repli( '-', 5 )         
   endif
   @ line, 43 say repli( '-', 5 )         
   line ++
   @ line, 20 say 'Totals -->'         
   if nTPaid > 0
      @ line, 37 say str( nTPaid, 5, 0 )         
   endif
   @ line, 43 say str( nTCredit, 5, 0 )         
   line ++
   if nTPaid > 0
      @ line, 20 say 'Balance : '                           
      @ line, 43 say str( nTCredit - nTPaid, 4, 0 )         
      line ++
   endif
else
   SayTitles( 55, @line )
   line ++
   @ line,  0 say padc( 'Marketing Analysis : ' + refrs->id + ', ' + proper( refrs->name ), 55 )         
   line ++
   @ line,  0 say repli( '-', 55 )         
   line ++
   @ line,  0 say 'Date'            
   @ line, 12 say 'Bill'            
   @ line, 18 say 'Total'           
   @ line, 28 say 'Margin'          
   @ line, 36 say '%' // 36         
   @ line, 43 say 'Debit'           
   @ line, 49 say 'Credit'          
   line ++
   @ line,  0 say repli( '-', 55 )         
   line ++
   do while refrs->id == sale_ref->refrs_id
      if debit = 0
         sele saccount
         seek sale_ref->sale_id
         @ line,  0 say date                                  
         @ line, 12 say str( id, 4, 0 )                       
         @ line, 18 say str( total - discount, 8, 0 )         
         sele sale_ref
         @ line, 28 say str( saccount->margin, 6, 0 )         
         nTMargin += saccount->margin
         @ line, 35 say str( perc, 3, 0 )                                                              
         @ line, 50 say str( round( ( saccount->margin * .15 ) * ( perc / 100 ), - 1 ), 5, 0 )         
         nTCredit += round( ( saccount->margin * .15 ) * ( perc / 100 ), - 1 )
      else
         @ line,  0 say date                
         @ line, 12 say 'Cash Paid'         
         sele sale_ref
         @ line, 43 say str( debit, 5, 0 )         
         nTPaid += debit
      endif
      line ++
      sele sale_ref
      skip
   enddo
   @ line, 29 say repli( '-', 5 )         
   if nTPaid > 0
      @ line, 43 say repli( '-', 5 )         
   endif
   @ line, 50 say repli( '-', 5 )         
   line ++
   @ line, 15 say 'Totals -->'                  
   @ line, 28 say str( nTMargin, 6, 0 )         
   if nTPaid > 0
      @ line, 43 say str( nTPaid, 5, 0 )         
   endif
   @ line, 49 say str( nTCredit, 6, 0 )         
   line ++
   if nTPaid > 0
      @ line, 15 say 'Balance : '                           
      @ line, 49 say str( nTCredit - nTPaid, 6, 0 )         
      line ++
   endif
endif
line ++
line ++
line ++
@ line,  0 say padc( '** END REPORT **', 79 )         
set device to screen
set printer off
set printer to
close all
fileread( 01, 04, 23, 72, RepPath+'REFRS.TXT', 'Individual Marketing Analysis' )
//===================================================================
function addeditpays

local dDate   := date()
local nAmount := 0.00
close all
refrs_view( .t., .t. )
dispscrn()
setcolor( scrcolor() )
@ 05, 15 say padc( 'Marketing Incentive Payment', 64 - 14 )                   
@ 17, 15 say padc( 'þ A - Add   þ E - Edit   þ ESC - Exit', 64 - 14 )         
setcolor( boxcolor() )
@ 06, 15 clear to 16, 64
@ 06, 15, 16, 64 box B_DOUBLE_SINGLE
@ 07, 17 say 'Promoter : ' + refrs->id + ', ' + subs( refrs->name, 1, 24 )         
footline( 08, 16, 64 - 16 )
use sale_ref new index SREF_1,SREF_2
set filter to refrs->id == sale_ref->refrs_id
go top
set order to 1
oBrowse         := TBrowseDB( 09, 16, 15, 63 )
oBrowse:headSep := 'ÍÑÍ'
oBrowse:colSep  := ' ³ '
oColumn         := TBColumnNew( 'Date', fieldblock( 'DATE' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Bill', { || sale_id } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( '%', { || perc } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Paid', { || debit } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
nKey := 0
do while .t.
   if nKey == K_ESC
      exit
   endif
   sele sale_ref
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
      dDate   := date()
      nAmount := 0
      popread( .f., 'Date : ', @dDate, '@D', ;
               'Paid : ', @nAmount, '99999' )
      if nAmount > 0
         append blank
         field->date     := dDate
         field->refrs_id := refrs->id
         field->debit    := nAmount
      endif
      oBrowse:refreshall()
   case upper( chr( nKey ) ) == 'E'
      if debit = 0
         jAlert( 'Cannot edit entries other than Cash Payment in this menu' )
      else
         dDate   := date
         nAmount := debit
         popread( .f., 'Date : ', @dDate, '@D', ;
                  'Paid : ', @nAmount, '99999' )
         if nAmount > 0
            field->date  := dDate
            field->debit := nAmount
         endif
         oBrowse:refreshall()
      endif
   endcase
enddo
close all
dispscrn()
return .t.

*+ EOF: REFRS.PRG
