#include "std.ch"
#include "inkey.ch"
#include "box.ch"
******************************************************************
*                         Function ARBROW                        *
******************************************************************

//=========================================================
// Look at TRBROW.PRG to see the history of this program.
//
// Browses through an ARRAY of records. Made for use with
// SALES and PURCHASE
//=========================================================

#DEFINE qItemId   aItems[_nCurItem,1]
#DEFINE qItemQty  aItems[_nCurItem,2]
#DEFINE qPrice    aItems[_nCurItem,3]
#DEFINE qDesc     aItems[_nCurItem,4]
#DEFINE qCost     aItems[_nCurItem,5]
#DEFINE qSerial   aItems[_nCurItem,6]
#DEFINE qPrint    aItems[_nCurItem,7]
#DEFINE qSrlCount aItems[_nCurItem,8]

static _nCurItem := 1

function SlTrBrow
local OTbSal,OTbCol, nKey := 0

oTBSal := tbrowsenew(9,2,17,78)

oTBSal:skipblock     := { | n | sl_skip( n ) }
oTBSal:gotopblock    := { || sl_gotop() }
oTBSal:gobottomblock := { || sl_gobott() }
oTBSal:colorspec     := setcolor()
oTBSal:autolite := .f.

oTBSal:headSep   := 'Í'
oTBSal:colSep    := ' '

oTBSal:addcolumn(tbcolumnnew('Srl', {|| str(qSrlCount,3,0) }))
oTBSal:addcolumn(tbcolumnnew('Item Description',{ || qDesc })
oTBSal:addcolumn(tbcolumnnew(' Qty', {|| str(qItemQty,4,0)} )
oTBSal:addcolumn(tbcolumnnew('     Price',{|| str(qPrice,10,2) })
oTBSal:addcolumn(tbcolumnnew('     Total', {|| str(qPrice*qItemQty,10,2)} )

do while nKey <> K_ESC
   dispbegin()
   do while !oTBSal:stabilize()
   enddo
   dispend()
   if oTBSal:stable
      if oTBSal:hitTop
         tone( 300, 2 )
      elseif oTBSal:hitBottom
         tone( 300, 2 )
      endif
      oTBSal:colorRect( { oTBSal:rowPos, oTBSal:leftVisible, oTBSal:rowPos, oTBSal:rightVisible }, { 2, 2 } )
      oTBSal:hilite()
      nKey := inkey( 0 )
      oTBSal:colorRect( { oTBSal:rowPos, oTBSal:leftVisible, oTBSal:rowPos, oTBSal:rightVisible }, { 1, 2 } )
   endif

if nKey == K_UP
   oTBSal:UP()
elseif nKey == K_DOWN
   oTBSal:DOWN()
elseif nKey == K_PGDN
   oTBSal:PAGEDOWN()
elseif nKey == K_PGUP
   oTBSal:PAGEUP()
elseif nKey == K_CTRL_END .OR. nKey == K_END
   oTBSal:goBottom()
elseif nKey == K_CTRL_HOME .OR. nKey == K_HOME
   oTBSal:goTop()
elseif nKey == K_RIGHT
   oTBSal:RIGHT()
elseif nKey == K_LEFT
   oTBSal:left()
endif

enddo

//------------------
static func sl_skip( n )
local nSkipped := 0
if n > 0
  do while _nCurItem <= len( AItems )
     _nCurItem++
     nSkipped++
  enddo
elseif n < 0
  do while _nCurItem >= 1
     _nCurItem--
     nSkipped--
  enddo
endif
return nSkipped
//---------------------
static func sl_gotop
_nCurItem := 1
return .t.
//-----------------
static func sl_gobott
_nCurItem := len(aItems)
return .t.
//-------------------
