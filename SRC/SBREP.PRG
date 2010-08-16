#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

/*
+------------------------------+
| Standby Module               |
+------------------------------+
*/

function sbBROWSE

local oBrowse
local oColumn
local nKey
local lOldscore := set( _SET_SCOREBOARD, .f. )
local lOldblink := setblink( .f. )      // to enable bright background colors
local nOldcurs  := setcursor( SC_NONE )
local cOldscrn  := savescreen()
setcolor( boxcolor() )
@  1,  0, 23, 79 box B_SINGLE + chr( 32 ) color setcolor()         
setcolor( scrcolor() )
@  2,  1 say padc( 'Standby', 78 )         
setcolor( boxcolor() )
@  3,  1 say repli( "м", 78 )                       
@  4,  1 say padc( 'Add/Edit Entries', 78 )         
@  5,  1 say repli( "м", 78 )                       
use SBREP new
index on senton to SBSYS
//set filter to !status
go bottom
oBrowse           := TBrowseDB( 6, 1, 22, 78 )
oBrowse:colorSpec := boxcolor()
oBrowse:headSep   := 'мям'
oBrowse:colSep    := ' Ё '
oColumn           := TBColumnNew( 'Item Description', { | | subs( DESC, 1, 20 ) } )
oColumn:footing   := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Customer', { | | subs( CUSTOMER, 1, 20 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'On', fieldblock( 'SENTON' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Qty', { | | str( qty, 3, 0 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'U/Price', { || str( uPrice, 8, 2 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Status', fieldblock( 'STATUS' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Any Other Remarks', fieldblock( 'REMARKS' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
do while nKey <> K_ESC
   dispbegin()
   do while !oBrowse:stabilize()
   enddo
   dispend()
   if oBrowse:stable
      if oBrowse:hitTop
         tone( 300, 2 )
      elseif oBrowse:hitBottom
         if confirm( 'Create new entry <Y/N> ? ' )
            sbnew( .t. )
            setcursor( SC_NONE )
            oBrowse:refreshall()
            do while !oBrowse:stabilize()
            enddo
            oBrowse:hilite()
         endif
      endif
      nKey := inkey( 0 )
   endif
   applykey( nKey, oBrowse )
enddo
set( _SET_SCOREBOARD, lOldscore )       // restore previous SCOREBOARD
setblink( lOldblink )
setcursor( nOldcurs )                   // restore previous cursor
restscreen(,,,, cOldscrn )
close all
use
return nil

static function applykey( nKey, b )

local lProcessed := .t.
do case
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
case nKey == K_ENTER
   sbnew( .f. )
   setcursor( SC_NONE )
   if status
      b:refreshall()
      do while eof()
         skip - 1
      enddo
   else
      b:refreshcurrent()
   endif
   do while !b:stabilize()
   enddo
   b:hilite()
case upper( chr( nKey ) ) == 'V'
   vertview()
otherwise
   lProcessed := .f.
endcase
return lProcessed

static function sbnew( new )

local oldscrn    := savescreen( 0, 0, 24, 79 )
local oldrec
local mdesc
local mcustomer
local maddress
local msentto
local msenton
local mrcvdon
local mcomplaint
local mdlvrdon
local mqty
local mprice
local mstatus
local mremarks
setcursor( 1 )
setcolor( sls_popcol() )
dispscrn()
sele SBREP
oldrec := recno()
if new
   go bott
   skip
endif

mdesc     := desc
mcustomer := customer
maddress  := address
msenton   := senton
mrcvdon   := rcvdon
mqty      := qty
mprice    := uprice
mstatus   := status
mremarks  := remarks
@  1,  0 clear to 23, 79
@  1,  0 to 23, 79
setcolor( scrcolor() )
@  2,  1 say padc( 'Standby', 78 )         
setcolor( boxcolor() )
@  3,  1 say repli( 'м', 78 )         
if new
   @  4,  1 say padc( "Create Entry", 78 )         
else
   @  4,  1 say padc( "Edit Entry", 78 )         
endif
@  5,  1 say repli( 'м', 78 )         

@  7,  1 say "Item Sent    :"         
@  8,  1 say "On           :"         
@ 10,  1 say "Customer     :"         
@ 11,  1 say "Address      :"         
@ 13,  1 say "Qty          :"         
@ 14,  1 say "Unit Price   :"         
@ 16,  1 say "Rcvd Back On :"         
@ 18,  1 say "Status       :"         
@ 19,  1 say "Remarks      :"         

@  7, 18 get mDESC         
read
if empty( mDESC )
   go oldrec
   restscreen( 0, 0, 24, 79, oldscrn )
   return nil
endif
@  8, 18 get mSENTON         
read
if empty( mSENTON ) .and. ( new )
   mSENTON := date()
endif
@  8, 18 say MSENTON         

@ 10, 18 get mCUSTOMER         
@ 11, 18 get mADDRESS          
read
if empty( mCUSTOMER )
   go oldrec
   restscreen( 0, 0, 24, 79, oldscrn )
   return nil
endif
@ 13, 18 get mQTY         
read
if mQTY = 0 .and. ( new )
   mQTY := 1
elseif mqty = 0
   go oldrec
   restscreen( 0, 0, 24, 79, oldscrn )
   return nil
endif
@ 13, 18 say mqty         

@ 14, 18 get mPRICE           valid ( mPRICE != 0 )        
@ 16, 18 get mRCVDON                                       
@ 18, 18 get mSTATUS                                       
@ 19,  1 say "Remarks      :"                              
@ 19, 18 get mREMARKS         picture "@S58@X"             
read

if Confirm( "Save Data <Y/N> ? ", 21,, sls_normcol() )
   if new
      appe blank
   endif
   jRLock()
   field->desc     := mdesc
   field->customer := mcustomer
   field->address  := maddress
   field->senton   := msenton
   field->rcvdon   := mrcvdon
   field->status   := mstatus
   field->remarks  := mremarks
   field->qty      := mqty
   field->uprice   := mprice
   jRUnLock()
endif
go oldrec
restscreen( 0, 0, 24, 79, oldscrn )
return nil
//---------------------------------------------------------
function sbDues

local line := 1
local nTot := 0.00
set printer to (RepPath+'SBREP.TXT')
set device to printer
set printer on
use SBREP
set filter to !status
go top
SayTitles( 129, @line )
line ++
@ line,  1 say padc( 'Items on Standby', 129 )         
line ++
@ line,  1 say repli( '-', 129 )         
line ++
@ line,  1 say "Item Description"         
@ line, 22 say "Customer Name"            
@ line, 48 say "Sent On"                  
@ line, 59 say "Qty"                      
@ line, 64 say "U.Price"                  
@ line, 72 say "Total"                    
@ line, 82 say "Remarks"                  
line ++
@ line,  1 say repli( '-', 129 )         
line ++
do while .not. eof()
   @ line,  1 say subs( desc, 1, 20 )                                                                  
   @ line, 22 say subs( rtrim( ltrim( customer ) ) + ', ' + rtrim( ltrim( address ) ), 1, 24 )         
   @ line, 48 say dtoc( senton )                                                                       
   @ line, 59 say str( qty, 3, 0 )                                                                     
   @ line, 64 say str( uprice, 5, 0 )                                                                  
   @ line, 72 say str( uprice * qty, 5, 0 )                                                            
   @ line, 82 say subs( remarks, 1, 30 )                                                               
   nTot += uprice * qty
   skip
   line ++
enddo
@ line, 01 say repli( '-', 129 )         
line ++
@ line, 40 say 'Value of Items on Standby -->'         
@ line, 70 say str( nTot, 7, 0 )                       
line ++
line ++
line ++
line ++
@ line,  1 say padc( '** End Report **', 129 )         
set device to screen
set printer off
set printer to
close all
fileread( 1, 1, 23, 78, RepPath+'SBREP.TXT', 'Standby Report' )
return nil
//=========================

*+ EOF: SBREP.PRG
