#include "std.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

/*
+------------------------------+
| Replacement Module           |
|                              |
| Database :      RPSYS.DBF    |
|                              |
| Field        Type    Width   |
| ==========================   |
| Desc          C       60     |
| (Includes Serial No.)        |
| Customer      C       40     |
| Address       C       40     |
| Complaint     C      100     |
| Sentto        C       40     |
| Senton        D       10     |
| Rcvdon        D       10     |
| Dlvrdon       D       10     |
| Status        L        1     |
| Remarks       C      254     |
| (64 Char each line, 4 lines) |
|                              |
+------------------------------+ */

function rpBROWSE

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
@  2,  1 say padc( 'Replacement', 78 )         
setcolor( boxcolor() )
@  3,  1 say repli( "м", 78 )                       
@  4,  1 say padc( 'Add/Edit Entries', 78 )         
@  5,  1 say repli( "м", 78 )                       
use RPSYS new
index on senton to rpsys
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
oColumn         := TBColumnNew( 'Sent To', { | | subs( SENTTO, 1, 20 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'On', fieldblock( 'SENTON' ) )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )
oColumn         := TBColumnNew( 'Rcvd Back', fieldblock( 'RCVDON' ) )
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
            rpnew( .t. )
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
   rpnew( .f. )
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
otherwise
   lProcessed := .f.
endcase
return lProcessed

static function rpnew( new )

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
local mstatus
local mremarks
setcursor( 1 )
setcolor( sls_popcol() )
dispscrn()
sele rpsys
oldrec := recno()
if new
   go bott
   skip
endif
mdesc      := desc
mcustomer  := customer
maddress   := address
msentto    := sentto
msenton    := senton
mrcvdon    := rcvdon
mcomplaint := complaint
mdlvrdon   := dlvrdon
mstatus    := status
mremarks   := remarks
@  1,  0 clear to 23, 79
@  1,  0 to 23, 79
setcolor( scrcolor() )
@  2,  1 say padc( 'Replacement', 78 )         
setcolor( boxcolor() )
@  3,  1 say repli( 'м', 78 )         
if new
   @  4,  1 say padc( "Create Entry", 78 )         
else
   @  4,  1 say padc( "Edit Entry", 78 )         
endif
@  5,  1 say repli( 'м', 78 )         

@  6,  1 say "Item Sent    :"         
@  8,  1 say "Customer     :"         
@  9,  1 say "Address      :"         
@ 10,  1 say "Complaint    :"         
@ 12,  1 say "Sent To      :"         
@ 13,  1 say "On           :"         
@ 15,  1 say "Rcvd Back On :"         
@ 16,  1 say "Delivered On :"         
@ 17,  1 say "Status       :"         
@ 19,  1 say "Remarks      :"         

@  6,  1 say "Item Sent    :"         
@  6, 18 get mDESC                    
read
if empty( mDESC )
   go oldrec
   restscreen( 0, 0, 24, 79, oldscrn )
   return nil
endif
@  8,  1 say "Customer     :"                      
@  8, 18 get mCUSTOMER                             
@  9,  1 say "Address      :"                      
@  9, 18 get mADDRESS                              
@ 10,  1 say "Complaint    :"                      
@ 10, 18 get mCOMPLAINT       pict '@X@S60'        
read
if empty( mCUSTOMER )
   go oldrec
   restscreen( 0, 0, 24, 79, oldscrn )
   return nil
endif
if empty( mSENTON ) .and. ( new )
   mSENTON := date()
endif
@ 12,  1 say "Sent To      :"                         
@ 12, 18 get mSENTTO                                  
@ 13,  1 say "On           :"                         
@ 13, 18 get mSENTON                                  
@ 15,  1 say "Rcvd Back On :"                         
@ 15, 18 get mRCVDON                                  
@ 16,  1 say "Delivered On :"                         
@ 16, 18 get mDLVRDON                                 
@ 18,  1 say "Status       :"                         
@ 18, 18 get mSTATUS                                  
@ 19,  1 say "Remarks      :"                         
@ 19, 18 get mREMARKS         picture "@S58@X"        
read
if Confirm( "Save Data <Y/N> ? ", 21,, sls_normcol() )
   if new
      appe blank
   endif
   jRLock()
   field->desc      := mdesc
   field->customer  := mcustomer
   field->address   := maddress
   field->sentto    := msentto
   field->senton    := msenton
   field->complaint := mcomplaint
   field->rcvdon    := mrcvdon
   field->dlvrdon   := mdlvrdon
   field->status    := mstatus
   field->remarks   := mremarks
   jRUnLock()
endif
go oldrec
restscreen( 0, 0, 24, 79, oldscrn )
return nil
//---------------------------------------------------------
function rpDues

local line := 1
set printer to (RepPath+'RPREP.TXT')
set device to printer
set printer on
use rpsys
set filter to !status
go top
SayTitles( 129, @line )
@ line,  1 say padc( 'Items sent for Replacement', 129 )         
line ++
@ line,  1 say repli( '-', 129 )         
line ++
@ line,  1 say "Item Description"         
@ line, 22 say "Customer Name"            
@ line, 48 say "Sent To"                  
@ line, 65 say "On"                       
@ line, 89 say "Remarks"                  
line ++
@ line,  1 say repli( '-', 129 )         
line ++
do while .not. eof()
   @ line,  1 say subs( desc, 1, 20 )                                                                  
   @ line, 22 say subs( rtrim( ltrim( customer ) ) + ', ' + rtrim( ltrim( address ) ), 1, 24 )         
   @ line, 48 say subs( rtrim( ltrim( sentto ) ), 1, 20 )                                              
   @ line, 65 say dtoc( senton )                                                                       
   @ line, 77 say sentto                                                                               
   @ line, 89 say subs( remarks, 1, 30 )                                                               
   skip
   line ++
enddo
line ++
line ++
line ++
@ line,  1 say padc( '** End Report **', 129 )         
set device to screen
set printer off
set printer to
close all
fileread( 1, 1, 23, 78, RepPath+'RPREP.TXT', 'Replacement Details' )
return nil
//=========================

*+ EOF: RPSYS.PRG
