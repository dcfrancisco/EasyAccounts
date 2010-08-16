#INCLUDE "INKEY.CH"

// A couple of in-line replacement functions from use with GT_SpotLight().

#xtranslate ScrnOffset(<nRow>,<nCol>) => ;
            ((((<nRow>)*((maxcol()+1)*2))+((<nCol>+1)*2))-1)

#xtranslate GrabScrnLine(<cScreen>,<nRow>,<nCol>,<nWidth>) => ;
            substr(<cScreen>,ScrnOffset(<nRow>,<nCol>),(<nWidth>)*2)

function GT_Shufl(nDelay)
local cScreen    := savescreen()      ,;
      nTop       := 0                 ,;
      nLeft      := 0                 ,;
      nBottom    := 4                 ,;
      nRight     := 12                ,;
      nXMove     := 1                 ,;
      nYMove     := 1                 ,;
      nLine      := 0                 ,;
      cSpotLight := ""              ,;
      hOldScreen := savescreen(0,0,24,79)      ,;
      nOldCursor := setcursor(0),;
      cOldColour := setcolor("w/n")  

local nJDebug := .t.

if nDelay=NIL
 nDelay := 0
endif

scroll()
do while nJDebug
   cSpotLight := ""
   for nLine := nTop to nBottom
      cSpotLight += GrabScrnLine(cScreen,nLine,nLeft,(nRight-nLeft)+1)
   next
   dispbegin()
   scroll()
   ShowAboutMe()
   restscreen(nTop,nLeft,nBottom,nRight,cSpotLight)
   dispend()
   MakeDelay()
   if nXMove == 1
      nXMove := if(nRight == maxcol(),-1,nXMove)
   else
      nXMove := if(nLeft == 0,1,nXMove)
   endif
   if nYMove == 1
      nYMove := if(nBottom == maxrow(),-1,nYMove)
   else
      nYMove := if(nTop == 0,1,nYMove)
   endif
   nJDebug := inkey()=0

   nTop    += nYMove
   nLeft   += nXMove
   nBottom += nYMove
   nRight  += nXMove
enddo
setcolor(cOldColour)
restscreen(0,0,24,79,hOldScreen)
setcursor(nOldCursor)
return(NIL)
//--------------------------------
static function ShowAboutMe
setcolor('B*/B*')
@ 08,20 clear to 16,51
@ 08,20 to 16,51
setcolor('GR*/B+')
//             123456789012345678901234567890
@ 09,21 say '    EasyAccounts v3.0 PRO     '
@ 10,21 say '      (Network Edition)       '
setcolor('BG*/B+')
@ 12,21 say ' Developed by Jasim A Basheer '
@ 13,21 say '    jasimab@hotmail.com       '
setcolor('GR*/B+')
@ 15,21 say '     Accounts made Easy!      '
set colo to
return .t.
//----------------------
static function MakeDelay
local x
for x:=1 to 20000
next x
return .t.
//----------------------
