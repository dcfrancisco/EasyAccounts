//=============================================
// DirectGo
// by Jasim A Basheer
// e-mail : wintech@giasmd01.vsnl.net.in
//
// Jasim A Basheer,
// Wintech Microsolutions
// Pulliman Jn., Karunagappally - 690 518
// Kollam, Kerala, India
// Ph: +91 0476 2621855, 2620146
// --------------------------------------------
// Recommended for use with CA-Clipper 5.2e
// Not tested with Clipper 5.3
//
// --------------------------------------------
// Visit wintechgroup at www.wintechgroup.com
//=============================================
//
// This program was formatted using Phil Barnett's
// Click Source Code reformatter. Please download it
// at www.the-oasis.net
//
// 

#include "std.ch"
#include "inkey.ch"
#include "fileio.ch"

#define FilePos(nHandle)  (FSEEK(nHandle, 0, FS_RELATIVE))

#DEFINE ORHandle      oObject[jnCurRep,1]
#DEFINE ODHandle      oObject[jnCurRep,2]
#DEFINE OReport       oObject[jnCurRep,3]
#DEFINE OLineOffSet   oObject[jnCurRep,4]
#DEFINE OWorking      oObject[jnCurRep,5]
#DEFINE OMarking      oObject[jnCurRep,6]

#DEFINE ORWPosition    oObject[jnCurRep,7]  // Position of current Report
#DEFINE ODWPosition    oObject[jnCurRep,8] // writing (jAddData)

#DEFINE ORBPosition    oObject[jnCurRep, 9] // Position of the current
#DEFINE ODBPosition    oObject[jnCurRep,10] // browse (TBrowse line)

#DEFINE OMarkStart     oObject[jnCurRep,11] // Fileoffsets from where marking
#DEFINE OMarkEnd       oObject[jnCurRep,12] // started and ended.

#DEFINE ORefresh       oObject[jnCurRep,13] // No.of times BROWSE 'refreshed'
// when the Report was working on. It is used only internally.
// 'refreshed' means any navigation key was pressed (UP,DOWN,PGUP,PGDN etc.)

// ORFile is the actual Report's TEXT file
// ODFile contains the reference data for each line.eg-CASHBOOK 23 mean's
// that corresponding line in .RPE is a CASHBOOK entry of record 23 or 
// whatever...

#DEFINE OCol           oObject[jnCurRep,14] // Current Column of the line
// where the report is being written.

#DEFINE OTitle         oObject[jnCurRep,15] // Heading of the report
#DEFINE OShouldCenter  oObject[jnCurRep,16] // Should the report (each and
// every line) be centered in the report using padc(,78)

#DEFINE ORefCBlock     oObject[jnCurRep,17]
// The CODE BLOCK executed when the direct go keypress is found (ENTER)
//

#DEFINE OProgText      oObject[jnCurRep,18]
#DEFINE OMaxLength     oObject[jnCurRep,19]

#DEFINE OPBarOld       oObject[jnCurRep,20]

#DEFINE ORFile         oObject[jnCurRep,21]
#DEFINE ODFile         oObject[jnCurRep,22]


static nCurBar := 0
static nBarCount := 0
static jnCurRep := 0
static oObject := {}
static nLineLen := 77
//-----------------------------------------
function jInitRep(_jTitle,lShouldCenter,bRefCode,cProgress,nMaxLength)

// the jTempFile return value does not include the extension. The extension
// is used by the function only for checking whether the file with such
// an extension is used. Do not change this behaviour of the function since
// this behaviour is extremely utilized in DAYBOOK.PRG's voucher temp. file
// creation and its INDEXING..

if _jTitle=NIL
  _jTitle := "Report"
endif
if nMaxLength=NIL
   nMaxLength := 80
endif
if lShouldCenter=NIL
   lShouldCenter := .f.
endif
if bRefCode = NIL
  bRefCode := {||chr(7)}
endif
jnCurRep ++
setcolor(boxcolor())
@ 1,0 clear to 23,79
@ 1,0 to 23,79
setcolor(scrcolor())
@ 2,1 say padc(_jTitle,78)
setcolor(boxcolor())

footline(3,1,78)
footline(20,1,78)
@ 3,65 say "ALT+F1 - Help"
@ 22, 2 say "þ Creating Report... þ"
if cProgress != NIL
  @ 21, 2 say padr(cProgress,30)
  @ 21,35 say repli("±",30)
endif

dispend()

aadd(oObject, {0, 0, tbrowseNew(4,1,19,78), 1,.t.,.f.,0, 0, 0, 0,0, -1, -1, 0, ;
               _jTitle, lShouldCenter, bRefCode, cProgress, nMaxLength, ;
               MakePBarActive(.t.), "", ""} )

ORFile := alltrim(jTempFile('RP_','RPE'))+'.RPE'
ODFile := alltrim(jTempFile('RP_','RDE'))+'.RDE'

// Refer to the DEFINEs for info on the Array Structure

ORHandle := fcreate(RepPath+ORFile,0)
fclose(ORHandle)
ODHandle := fcreate(RepPath+ODFile,0)
fclose(ODHandle)

ORHandle := fopen(RepPath+ORFile,FO_READWRITE+FO_SHARED)
ODHandle := fopen(RepPath+ODFile,FO_READWRITE+FO_SHARED)

if ! lShouldCenter
   OReport:addcolumn(tbcolumnnew("",{ || ;
           padr(subst( SFREADLINE( MovetoBrPos() ),OLineOffSet),nLineLen)}))
else
   OReport:addcolumn(tbcolumnnew("",{ || ;
           padr(subst( padc( SFREADLINE( MovetoBrPos() ), 78 ),OLineOffSet),nLineLen)}))
endif
OReport:skipblock     := { | n | jFskip( n ) }
OReport:gotopblock    := { || jFtop() }
OReport:gobottomblock := { || jFbot() }

OReport:getcolumn(1):colorblock := {|| iif( Marked(), {2,2},{1,2})}

OReport:autolite := .T.

return .t.
//----------------------------
function jEndReport
local nKey := 0, lDisplayed := .f.
OWorking := .f.
close all        // no databases should be open since this is a wait state.
set console on
setcursor(0)
set device to screen
@ 22, 2 say "  þ Report Created þ   "
@ 21,02 say space(70)

OReport:refreshall()

dispend()

do while nKey <> K_ESC
   dispbegin()
   do while !OReport:stabilize()
   enddo
   dispend()

   if OReport:stable
      do while ( nKey := inkey() ) == 0  .and. (!OReport:stabilize())
      enddo
      if ! jViewReport(nKey)
         exit
      endif
   endif
   if ! lDisplayed
     @ 22, 1 say padc('         ',77)
     lDisplayed := .t.
   endif
enddo

MakePBarActive(OPBarOld)
fclose( ORHandle )
fclose( ODHandle )
erase ( RepPath+ORFile )
erase ( RepPath+ODFile )
ADEL( oObject, jnCurRep)
ASize( oObject, jnCurRep-1)
jnCurRep--
setcursor(1)

return .t.
//--------------------------------------------------------

// Simultaneous report creation and view prototype
/*
do while WritingReport
  do while inkey() == 0
     jAddData( <xyz> )
     if ReportEnded
        WritingReport := .f.
        exit
     endif
  enddo
  jViewReport( lastkey() )
enddo
jEndReport()
*/

function jViewReport(nKey)
local lReturn := .t.,lActionDone := .f.
DispBegin()
if nKey == K_ENTER
   dispend()
   CLEAR GETS
   dispend()
   eval(ORefCBlock)
   CLEAR TYPEAHEAD
elseif nKey == K_UP
   OReport:UP()
elseif nKey == K_DOWN
   OReport:DOWN()
elseif nKey == K_PGDN
   OReport:PAGEDOWN()
elseif nKey == K_PGUP
   OReport:PAGEUP()
elseif nKey == K_CTRL_END .OR. nKey == K_END
   OReport:goBottom()
elseif nKey == K_CTRL_HOME .OR. nKey == K_HOME
   OReport:goTop()
elseif nKey == K_RIGHT
   OLineOffSet += 5
   lActionDone := .t.
elseif nKey == K_LEFT
   if OLineOffSet > 5
     OLineOffSet -= 5
   else
     OLineOffSet := 1
   endif
   lActionDone := .t.
elseif upper(chr(nKey)) == 'M'
   if ! OMarking
      OMarking := .t.
      OMarkStart := ORBPosition
      OMarkEnd   := ORBPosition
      @ 22, 65 say "þ Marking.. þ"
   else
      OMarking := .f.
      @ 22, 65 say "              "
      OMarkStart := -1
      OMarkEnd   := -1
      lActionDone := .t.
    endif
elseif nKey == K_ALT_P .and. OMarking
      dispend()
      jDgPrint()
elseif nKey == K_ALT_P .and. (!OMarking)     // Print whole
      dispend()
      OMarkStart := 0
      OMarkEnd := FileSize( ORHandle ) - 2
      jDgPrint()
      OMarkStart := -1
      OMarkEnd := -1
elseif nKey == K_ALT_F .and. OMarking
      dispend()
      jDgCopy()
elseif nKey == K_ALT_F .and. (!OMarking)
      dispend()
      OMarkStart := 0
      OMarkEnd := FileSize( ORHandle ) - 2
      jDgCopy()
      OMarkStart := -1
      OMarkEnd := -1
elseif nKey == K_ALT_S .and. (!OMarking)
      dispend()
      jDgSearch()
elseif nKey == K_ALT_F1
      dispend()
      jDgPopHelp()
elseif nKey == K_F8
      dispend()
      vs_calc()
elseif nKey == K_F9
      dispend()
      calendar()
elseif nKey == K_F5
      dispend()
      pop_menu()
elseif setkey( nKey ) # nil
      dispend()
      eval( setkey( nKey ), procname( 1 ), procline( 1 ), readvar() )
      nKey := 0
elseif nKey == K_ESC
      if ! OMarking
         lReturn := .f.
      else
        OMarking := .f.
        @ 22, 65 say "              "
        OMarkStart := -1
        OMarkEnd   := -1
        lActionDone := .t.
        nKey := 0
      endif
endif
if OReport:hittop()
  OReport:down()
elseif OReport:hitbottom()
  OReport:up()
endif
if OMarking
   OMarkEnd   := ORBPosition
   If OMarkEnd < OMarkStart
      OMarkEnd := -1
      OMarkStart := -1
      OMarking := .f.
   endif
   OReport:refreshall()
   dispbegin()
   while !OReport:stabilize()
   enddo
   dispend()
endif
if lActionDone
   OReport:refreshall()
endif
DispEnd()
return lReturn
//--------------------------------------------------------
function jAddData(nNewCol,cText,cRef)
fseek(ORHandle,ORWPosition,0)
if nNewCol=NIL
  nNewCol := OCol+1
endif
if valType(cText) = 'N'
  cText := str(cText)
elseif valType(cText) = 'L'
  cText := iif(cText,'Y','N')
elseif valType(cText) = 'D'
  cText := dtoc(cText)
endif
fwrite( ORHandle, space(nNewCol-OCol) + cText )
OCol := nNewCol+ len(cText)
ORWPosition := FilePos(ORHandle)
if (cRef!=NIL) .and. (!empty(cRef))
   fseek(ODHandle,ODWPosition,0)
   fwrite( ODHandle, cRef )
   ODWPosition := FilePos(ODHandle)
endif
return .t.
//------------------------------------------------------
function jRefData
local nStByte := fseek(ODHandle)
local cRef
fseek(ODHandle,ODBPosition,0) // Go to actual browse place
cRef := padr( alltrim(SFREADLINE(ODHandle)), 20 )
fseek(ODHandle,ODBPosition,0) // Datapointer changed. Again go to actual browse place
return cRef
//-----------------------------------------
static function Marked()
local lMarked := .f.
if ORBPosition >= OMarkStart .and. ORBPosition <= OMarkEnd
   lMarked := .t.
endif
return lMarked
//-------------------------------
static function jFbot()

@ 21,65 say "þ Moving... þ"

do while ( fmove2next( ORHandle ) .and. fmove2next( ODHandle ) )
enddo

fmove2prior( ORHandle )
fmove2prior( ODHandle )

ORBPosition := FilePos( ORHandle )
ODBPosition := FilePos( ODHandle )

@ 21,65 say "             "

return ''

static function jFtop()
ORBPosition := fseek( ORHandle,0, 0)
ODBPosition := fseek( ODHandle,0, 0)
return ''

static function jFskip( n )
local nMoved := 0

fseek(ORHandle, ORBPosition, 0)
fseek(ODHandle, ODBPosition, 0)

if n > 0
   while nMoved < n
      if fmove2next( ORHandle ) .and. fmove2next( ODHandle )
         nMoved ++
      else
         exit
      endif
   end
elseif n < 0
   while nMoved > n
      if fmove2prev( ORHandle ) .and. fmove2prev( ODHandle )
         nMoved --
      else
         exit
      endif
   end
endif

ORBPosition := FilePos(ORHandle)
ODBPosition := FilePos(ODHandle)
return nMoved
//-------------------------------
function jGoReport(nKey)
local x

setcursor(0)

@ 21,02 say space(70)

if ! jViewReport(nKey)
    return .f.
endif

if nKey != 0 .or. ORefresh < 24
   dispbegin()
   OReport:refreshall()
   do while ! OReport:stabilize()
   enddo
   dispend()
   ORefresh++
endif

return .t.
//------------------
function jNextLine
fseek(ORHandle,ORWPosition,0)
fseek(ODHandle,ODWPosition,0)
fwrite( ORHandle, chr(13)+chr(10) )
fwrite( ODHandle, space(5)+chr(13)+chr(10) )

// 5 spaces are given for realtime editing.
// FWrite cannot insert text. So, if a change occurs
// eg. if accode changes from 1 to 10, then
// '0' is new and there is not space for '0' in that line. So
// it will overlap on the CTRLFEED and will become a total mess.
// So even if the digit increses to 5 spaces, no problem should occur
// in this case.

ORWPosition := FilePos(ORHandle)
ODWPosition := FilePos(ODHandle)
OCol := 0
return .t.
//----------------------------------
static function MovetoBrPos
fseek(ORHandle, ORBPosition, 0)
fseek(ODHandle, ODBPosition, 0)
return ORHandle
//---------------------
function jRepWorking
return OWorking
//------------------
static function jDGPrint
local lCompress := jAlert('Compress ?', {'No', 'Yes'})
if lCompress == nil .or. lCompress == 0
  return .f.
endif
lCompress := (lCompress==2)
@ 21,2 say "þ Printing... þ"
fseek(ORHandle, OMarkStart)
set printer to LPT1   // If need to be modified,
// the error msg will ask for another printer port

if p_ready("LPT1")
   
   set console OFF
   set device to printer
   set printer on
   setprc(0,0)
   if lCompress
     ?? chr(15)
   else
     ?? chr(18)
   endif
   setprc(0,0)

   if !  OMarking     // We've not marked a part of file(full report print.)
                     // Therefore print the titles also
      if !empty( eaHead )
         ? padc( eaHead, OMaxLength )
      endif
      if !empty( eaTitle )
         ? padc( eaTitle, OMaxLength ) 
      endif
      if eaShowAdd
         if !empty( eaAdd1 )
            ? padc( eaAdd1, OMaxLength )
         endif
         if !empty( eaAdd2 )
            ? padc( eaAdd2, OMaxLength )
         endif
         if !empty( eaAdd3 )
            ? padc( eaAdd3, OMaxLength )
         endif
      endif
      ?
   endif

   do while FilePos( ORHandle ) <= OMarkEnd
     if p_ready("LPT1")
       ? SFREADLINE( ORHandle )
       fmove2next( ORHandle )
     else
       exit
     endif
   enddo
   set device to screen
   set printer off
   set printer to
   setprc(0,0)

endif
@ 21,2 say "               "
MovetoBrPos()
return .t.
//---------------------
static function jDGCopy
static cFileName
local nAppend

if cFileName = NIL
   cFileName := space(12)
else
   cFileName := padr(alltrim(cFileName),12)
endif

@ 21,2 say "þ Copying text... þ"
popread( .t., "File Name", @cFileName, "@XS25" )
cFileName := upper( trim( cFileName ) )
if empty(cFileName)
  msg("File name empty. Copy aborted...")
  return .f.
endif
if file( cFileName )
  nAppend := menu_v( "File Exists", "Overwrite", "Append", "Cancel" )
  do case
  case nAppend == 1
     tofile( cFileName, .f., OMarkStart, OMarkEnd, ORHandle )
     msg("Text copied to "+cFileName+"...")
  case nAppend == 2
     tofile( cFileName, .t., OMarkStart, OMarkEnd, ORHandle )
     msg("Text copied to "+cFileName+"...")
  endcase
else
   tofile( cFileName, .f., OMarkStart, OMarkEnd, ORHandle )
   msg("Text copied to "+cFileName+"...")
endif
MovetoBrPos()
@ 21,2 say "                      "
return .t.
//--------------------
function jDGRefPBar(nBar)
nBar *= 30        // There are only 30 columns..
@ 21,35 say repli("²",nBar)
return .t.
//----------------------
function jDGSetPBar(nBar)
nCurBar := 0
nBarCount := nBar
if nBar = 0
 jDGRefPBar(1)
endif
return .t.
//-----------------------
function jDGIncrPBar
nCurBar++
jDGRefPBar(nCurBar/nBarCount)
return .t.
//------------------
static function jDGSearch
static cSearch
local lFound := .f., nLinesMoved := 0

if cSearch = NIL
   cSearch := space(60)
else
   cSearch := padr(alltrim(upper(cSearch)),60)
endif

popread(.f.,'Search for : ',@cSearch,"@S20")
cSearch := upper(alltrim(cSearch))
if empty(cSearch)
 msg("Cannot search for empty string")
 return .f.
endif
@ 21,2 say "þ Searching for text... þ"
do while inkey() != K_ESC .and. fmove2next( ORHandle )
   if cSearch $ upper( SFREADLINE( ORHandle ) )
      lFound := .t.
      exit
   endif
   nLinesMoved++
enddo
@ 21,2 say "                           "
if lFound
   jFSkip(nLinesMoved+1)
   OReport:refreshall()
else
  if lastkey() != K_ESC
     msg("Search string not found...")
  endif
  MoveToBrPos()
endif
return .t.

static function jDgPopHelp()
jPick( { "ÿ",;
        "   Jump to the detailed view",;
        "    of the highlighted entry  :- ENTER        ",;
        "ÿ",;
        "         Mark / End Mark Text :- 'M'         ",;
        "ÿ",;
        "              Search for Text :- ALT+S       ",;
        "ÿ",;
        "   Print marked portion/whole",;
        "                       report :- ALT+P        ",;
        "ÿ",;
        "    Copy marked portion/whole ",;
        "               report to file :- ALT+F       ",;
        "ÿ",;                                         
        "                         Exit :- ESC          ",;
        "ÿ"},;
         "þ Help þ",2,-4,.F.,msgcolor() )
return .t.

//----------------------------------
function dgLine( cText,cRef )
local cOldLine := SFREADLINE( MovetoBrPos() )
local nRW, nDW, nOldCol := OCol

if cText != NIL


  MoveToBrPos()       // The pointer will be at the end of line as one
               // SFREADLINE is completed during stabilize.
               // So bring it back to the start of the line.

  fwrite( ORHandle, padr(cText,len(cOldLine)) )

  if cRef != NIL
     fwrite( ODHandle, cRef )
  endif

  MoveToBrPos()

  OReport:refreshcurrent()

endif

return cOldLine
//=================================
function jNewPBar(cText)
setcolor(boxcolor())
@ 21, 2 say padr(cText,30)
@ 21,35 say repli("±",30)
nCurBar := 0
return .t.
//===================
FUNCTION FEof( nHandle )
   RETURN ( IF( FileSize( nHandle ) == FilePos( nHandle ), .T., .F. ))
//=====================================
