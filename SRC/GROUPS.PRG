#include "std.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"

function m_cmpgroup( nStock, nBatch, lEdit, nParentId )

local _x
local _y
local _xx
local oBrow
local oCol
local nKey
local nSubscript
local cScreen

local aCmp := { "CABINET   ", "M/B", "PROCESSOR", "MEMORY", ;
                "HDD", "CDD", ;
                "FDD", "AGP", "SOUND CARD", "DVD", "SPEAKER", "MONITOR", "KEYBOARD", ;
                "MOUSE", "I/MODEM", "E/MODEM" }

local aDet := {}

sele groups
_xx := recno()

sele master
set filter to
set order to 2

if lEdit = NIL
   lEdit := .f.
endif
if !lEdit
   for _x := 1 to 16
      aadd( aDet, { padc( "-", 25 ), 0 } )
   next x
else
   sele groups
   set order to 1
   seek nParentId
   if !found()
      msg( "Data Corrupt...!" )
      return .f.
   else
      do while parent == nParentId .and. ( !eof() )
         aadd( aDet, { docut( subs( m_finddesc( nStock ), 1, 25 ), aCmp ), id } )
         skip
      enddo
   endif
endif

// Array subscript starts with first element
nSubscript := 1

cScreen := savescreen()
dispscrn()
setcolor( boxcolor() )
// STEP 1
@  2, 02 to 21, 41
setcolor( scrcolor() )
@ 22, 02 say padc( rtrim( ltrim( master->desc ) ) + ' Stock : ' + rtrim( ltrim( str( master->bal ) ) ), 39 )         
setcolor( boxcolor() )
oBrow               := TBROWSENEW( 3, 03, 20, 40 )
oBrow:skipBlock     := { | nReq | JumpIt( nReq, @nSubscript, aCmp ) }
oBrow:goTopBlock    := { || nSubscript := 1 }
oBrow:goBottomBlock := { || nSubscript := len( aCmp ) }
oBrow:colorSpec     := boxcolor()
oBrow:headSep       := 'อออ'
oBrow:colSep        := ' : '

oCol := TBCOLUMNNEW( 'Component', { || aCmp[ nSubscript ] } )
oBrow:addColumn( oCol )

oCol := TBCOLUMNNEW( '  Configuration', { || aDet[ nSubscript, 1 ] } )
oBrow:addColumn( oCol )

oBrow:colpos := 2

do while .T.

   dispbegin()
   do while !oBrow:stabilize()
   enddo

   dispend()

   nKey := inkey( 0 )

   if !TBMoveCursor( nKey, oBrow )
      if nKey == K_ESC
         exit
      elseif nKey == K_ENTER
         if oBrow:colPos = 1
            oBrow:right()
            oBrow:stabilize()
         endif
         aDet := m_component( nSubScript, aDet, nStock )
         oBrow:refreshcurrent()
         keyboard chr( K_DOWN )
      endif
   endif
enddo

restscreen(,,,, cScreen )
if !lEdit
   sele groups
   _x := 1
   do while .not. _x > len( aDet )
      appe blank
      field->id     := aDet[ _x, 2 ]
      field->qty    := nStock
      field->parent := nParentId
      sele master
      set order to 1
      seek aDet[ _x, 2 ]
      set order to 2
      field->g_stock := g_stock + nStock
      field->bal     := bal + nStock
      field->group   := .t.
      sele groups
      _x ++
   enddo
else
   sele groups
   go top
   seek nParentId
   _X := 1
   do while parent == nParentId .and. ( !eof() )
      field->qty    := nStock
      field->id     := aDet[ _x, 2 ]
      field->parent := nParentId
      sele master
      set order to 1
      seek aDet[ _x, 2 ]
      set order to 2
      field->g_stock := g_Stock + nStock
      field->bal     := bal + nStock
      field->parent  := .f.
      field->group   := .t.
      _x ++
      sele groups
      skip
   enddo
endif

sele groups
go _xx

return aDet
//---------------------------------
static function JumpIt( nRequest, nSubscript, aCmp )

local nActually := 0

// Show current
if nRequest == 0
   nActually := 0   // When browsing databases it was a matter
   // of SKIP 0.  Return 0 and your array
   // element will be painted on screen
elseif nRequest > 0
   if nRequest < ( len( aCmp ) - nSubscript )
      nActually := nRequest

   else
      nActually := len( aCmp ) - nSubscript

   endif

elseif nRequest < 0
   // Skip backwards
   if nRequest < ( 1 - nSubscript )
      // Skip several elements
      nActually := 1 - nSubscript

   else
      nActually := nRequest

   endif

endif

// Position in the proper element
nSubscript += nActually
return ( nActually )
//---------------------------------
static function TBMoveCursor( nKey, oObj )

local nFound
static aKeys := ;
        { K_DOWN, { | b | b:down() }, ;
        K_UP, { | b | b:up() }, ;
        K_PGDN, { | b | b:pageDown() }, ;
        K_PGUP, { | b | b:pageUp() }, ;
        K_CTRL_PGUP, { | b | b:goTop() }, ;
        K_CTRL_PGDN, { | b | b:goBottom() }, ;
        K_HOME, { | b | b:home() }, ;
        K_END, { | b | b:end() }, ;
        K_CTRL_LEFT, { | b | b:panLeft() }, ;
        K_CTRL_RIGHT, { | b | b:panRight() }, ;
        K_CTRL_HOME, { | b | b:panHome() }, ;
        K_CTRL_END, { | b | b:panEnd() } }

//   K_RIGHT     , {|b| b:right()},;   && Only one column should be
//   K_LEFT      , {|b| b:left()},;    && browsed here.

nFound := ascan( aKeys, nKey )
if ( nFound != 0 )
   eval( aKeys[ ++ nFound ], oObj )

endif
return ( nFound != 0 )
//---------------------------
function m_component( nPos, aDet, nStk )

local _xx  := savescreen()
local _yy
local cCmp := { "CABINET   ", "M/B", "PROCESSOR", "MEMORY", ;
                "HDD", "CDD", ;
                "FDD", "AGP", "SOUND CARD", "DVD", "SPEAKER", "MONITOR", "KEYBOARD", ;
                "MOUSE", "I/MODEM", "E/MODEM" } [nPos]
sele master
set filter to
if aDet[ nPos, 2 ] != 0
   set order to 1
   seek aDet[ nPos, 2 ]
   if !found()
      go top
   endif
   set order to 2
endif
_yy  := recno()
cCmp := rtrim( ltrim( cCmp ) )
set filter to subs( desc, 1, len( cCmp ) ) == cCmp
go top
if cmp_sel( len( cCmp ) )
   if master->id != 0
      aDet[ nPos, 1 ] = rtrim( ltrim( strtran( desc, cCmp, space( 1 ) ) ) )
      aDet[ nPos, 2 ] = master->id
   endif
else
   aDet[ nPos, 1 ] = padc( '-', 25 )
   aDet[ nPos, 2 ] = 0
endif
sele master
set filter to
go _yy
restscreen( 0, 0, 24, 79, _xx )
return aDet
//-------------------------------
function cmp_sel( nLen )

local oBrowse
local nKey    := 0
@  3, 43 clear to 21, 78
@  3, 43 to 21, 78
oBrowse         := TBrowseDB( 4, 44, 20, 77 )
oBrowse:headSep := 'อัอ'
oBrowse:colSep  := ' ณ '
oColumn         := TBColumnNew( 'Component', { || subs( DESC, nLen + 2 ) } )
oColumn:footing := ''
oBrowse:AddColumn( oColumn )

// DO NOT SHOW STOCK. AS IT MAY MAKE CONFUSION BETWEEN
// LOOSE STOCK AND GROUP STOCK.
//
// ACTUALLY IN THE BAL. FIELD, ONLY THE LOOSE STOCK COMES. (IN SCREEN)
// THE BAL FIELD IS THE SUM OF G_STOCK AND LOOSE STOCK.
// SO WE TAKE BAL - G_STOCK IN 'MASTER.PRG'

//oColumn := TBColumnNew('Stock', fieldblock('BAL'))
//oColumn:footing := ''
//oBrowse:AddColumn(oColumn)

do while nKey <> K_ENTER .and. nKey <> K_ESC
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
   endcase
enddo
return nKey == K_ENTER
//------------------------------------
function m_finddesc( nStock )

local _x
local _y
if groups->id != 0
   //alert(str(id)+"  record "+str(recno()))
   sele master
   set order to 1
   go top
   _x := recno()
   seek groups->id
   if found()
      _y := desc
   else
      _y := 'Data Corrupt..!'
   endif
   field->g_stock := g_stock - nStock
   field->bal     := bal - nStock
   field->group   := .t.
   field->parent  := .f.
   set order to 2
   go _x
   sele groups
else
   _y := padc( '-', 25 )
endif
return _y
//--------------------------------
static function docut( cString, aFind )

local x := 1
do while .not. x > len( aFind )
   if subs( cString, 1, len( aFind[ x ] ) ) == aFind[ x ]
      cString := subs( cString, len( aFind[ x ] ) + 1 )
      exit
   endif
   x ++
enddo
return cString
//------------------------------

*+ EOF: GROUPS.PRG
