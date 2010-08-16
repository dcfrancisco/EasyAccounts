#include "inkey.ch"
#include "box.ch"
** TRBROW.PRG
// ============================
// Browses through a GROUP of records matching a criteria in an
// indexed order (eg. WHILE FIELD->BillNo == MEMVAR->nBillId )
// Beware not FOR (if we need FOR, better SET FILTER. It would
// work but slower for larger databases...)
// Made for use with SALES and PURCHASE but does not work. As
// it works with an array.
// ============================
// I'd made a mistake. After all the below browse routines
// was completed and working super, I made it to the SALES
// But there the technique is different.
// The records of a bill is loaded into an array and that
// array is being played with while editing, adding etc.
//
// At last, when the user says 'Action Go! SAVE !! ',
// only then, and then only, does this poor little chap of a
// program called EasyAccounts made by a still poorer little
// chap called Jasim will save (update/add) the records into
// the SALES.DBF.
//
// So now, let this PRG be here. I'm goin to build a new
// ARBROW.PRG which will browse through arrays.
//
// =============================
static nBill,nItemSrl := 1

function TrBrow
local OTbSal,OTbCol, nKey := 0

oTBSal := tbrowsenew(9,2,17,78)

oTBSal:skipblock     := { | n | sl_skip( n ) }
oTBSal:gotopblock    := { || sl_gotop() }
oTBSal:gobottomblock := { || sl_gobott() }
oTBSal:colorspec     := setcolor()
oTBSal:autolite := .f.
*oTBSal:headSep   := 'ÍÑÍ'
*oTBSal:colSep    := ' ³ '

oTBSal:headSep   := 'Í'
oTBSal:colSep    := ' '

oTBSal:addcolumn(tbcolumnnew('Srl', {|| str(nItemSrl,3,0) }))
oTBSal:addcolumn(tbcolumnnew('Item Description',{ ||sl_masitem() }))
oTBSal:addcolumn(tbcolumnnew(' Qty', { || str(QTY,4,0) }))
oTBSal:addcolumn(tbcolumnnew('     Price', { || str(price,10,2) }))
oTBSal:addcolumn(tbcolumnnew('     Total', { || str(price * Qty,10,2) }))

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
      //ÄÄÄÄ highlight current row

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


static func sl_masitem
local cVal
sele master
seek sales->item_id
cVal := padr(subs( rtrim( ltrim( desc ) ) + iif( !empty( details ), ", ", "" ) + rtrim( ltrim( details ) ), 1, 42 ),42)
sele sales
return cVal
//------------------
static func sl_skip( n )
local nSkipped := 0
if n > 0
  do while (id == nBill) .and. (nSkipped <> n) .and. (! eof() )
     skip
     nSkipped++
     nItemSrl++
  enddo
elseif n < 0
  do while (id == nBill) .and. (nSkipped <> n) .and. (! eof() )
     skip -1
     nSkipped--
     nItemSrl--
  enddo
endif
if id != nBill      // Skipped past the bill.
 if n > 0
   skip -1
   nSkipped --
   nItemSrl--
 elseif n < 0
   skip
   nSkipped++
   nItemSrl++
 endif
endif
return nSkipped
//---------------------
static func sl_gotop
do while id == nBill .and. (!bof())
 skip -1
enddo
skip
nItemSrl := 1
return .t.
//-----------------
static func sl_gobott
do while id == nBill .and. (!eof())
 skip
 nItemSrl++
enddo
skip -1
nItemSrl--
return .t.
//-------------------
