#include "inkey.ch"
/*
ี์อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
ณ FUNCTION FILEREAD()
ฦออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ 
ณ 
ณ  Short:
ณ  ------
ณ  FILEREAD() Lists a text file of unlimited size
ณ 
ณ  Returns:
ณ  --------
ณ  nothing
ณ 
ณ  Syntax:
ณ  -------
ณ  FILEREAD([nTop,nLeft,nBottom,nRight],[cFileName],[cTitle],;
ณ            [lSearch],[lMark])
ณ
ณ  Description:
ณ  ------------
ณ  Lists text file [cFileName] of unlimited size in a
ณ  programmer definable window of dimensions [nTop..nRight]
ณ 
ณ  Allows up down right left scrolling. Use this for
ณ  reports or output sent to a disk file.
ณ 
ณ  If [cFileName]  is not passed, a box asks for the
ณ  filespec and then allows a picklist of files of that spec. If
ณ  [cFileName] is passed as a wildcard (i.e. "*.DOC"). a picklist
ณ  of files of that spec is presented.
ณ 
ณ  If [nTop..nRight] are not passed, a default window of
ณ  dimensions 2,2,22,78 is used.
ณ 
ณ  [cTitle] is an optional title. This overrides the
ณ  default which is the file name.
ณ 
ณ  [lSearch] is a switch to allow text searches. Default
ณ  is True
ณ
ณ  [lMark] is a switch to allow block marking (with Copy
ณ  to File or Print) Default is True.
ณ 
ณ  Examples:
ณ  ---------
ณ   REPORT FORM summary TO summary.txt
ณ   FILEREAD(2,2,22,78,"SUMMARY.TXT","Summary File")
ณ 
ณ  Notes:
ณ  -------
ณ  Fileread() will use SET DEFAULT if no path is
ณ  specified.
ณ 
ณ  Source:
ณ  -------
ณ  S_FILER.PRG
ณ 
ิํอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*/
function Fileread( nBoxTop, nBoxLeft, nBoxBot, nBoxRight, cFileName, cTitle, lSearch, lMark )

local nLastKey
local nCursor
local cLastKey
local cReadBox
local nTopLine
local nBottLine
local nLeftEdge
local nRightEdge
local nLineLen
local nLineOffset
local nFileOffset
local nHandle
local oTb
local cSeek        := ""
local lMarking     := .f.
local nMarkStart   := 0
local nMarkEnd     := 0
local lMarked      := .f.
local lMarkOrSeach
local nTbottom
local cInstruct1
local cInstruct2
local nInstruct1
local nInstruct2
local nAtArrows
local nAtPgup
local nAtPgdn
local nAtHome
local nAtEnd
local nAtEsc
local nAtSearch
local nAtMark
local nMouseR
local nMouseC
local nCursRow
local nInCreaseLR
local aButtons
local nButton      := 0
local nBrow1
local nBRow2

lSearch       := iif( lSearch # nil, lSearch, .t. )
lMark         := iif( lMark # nil, lMark, .t. )
lMarkOrSearch := ( lSearch .or. lMark )

//- if FileName not passed, get one
if cFileName == nil .or. "*" $ cFilename
   if cFileName == nil
      cFileName := space( 40 )
      popread( .t., "File to list - leave empty or use *? for picklist", @cFileName, "" )
   endif
   if lastkey() = 27
      return .F.
   endif
   if empty( cFileName ) .or. at( '*', cFileName ) > 0
      if empty( cFileName )
         cFileName := getdfp() + "*.*"
      else
         if !( "\" $ cFileName .or. ":" $ cFileName )
            cFileName := getdfp() + cFileName
         endif
      endif
      if adir( cFileName ) > 0
         cFileName := popex( cFileName )
      endif
   endif
   if lastkey() = 27
      return .F.
   endif
else
   if !( "\" $ cFileName .or. ":" $ cFileName )
      cFileName := getdfp() + cFileName
   endif
endif

//- assign box dimensions if need be
//IF nBoxTop==nil
nBoxTop   := 2
nBoxLeft  := 2
nBoxBot   := 22
nBoxRight := 78
//ENDIF

//- check for file's existence
if empty( cFileName ) .or. !file( cFileName )
   return .F.
endif
cTitle := iif( cTitle # nil, cTitle, cFileName )
//- open the file, check for errors
nHandle := fopen( cFileName, 64 )
if ferror() <> 0
   msg( "Error opening file : " + cFileName )
   return ''
endif

//- set cursor off
nCursor := setcursor( 0 )

//- draw screen
cReadBox := makebox( nBoxTop, nBoxLeft, nBoxBot, nBoxRight, sls_popcol(), 0, 0 )
nTbottom := iif( lMarkOrSearch, 3, 2 )
@ nBoxBot - nTbottom, nBoxLeft to nBoxBot - nTBottom, nBoxRight
@ nBoxBot - nTBottom, nBoxLeft  say chr( 195 )         
@ nBoxBot - nTBottom, nBoxRight say chr( 180 )         

@ nBoxTop, nBoxLeft + 2 say '[' + cTitle + ']'         

cInstruct1 := padc( "[][][][]  [PGUP]  [PGDN]  [HOME]  [END]   [ESC=Quit] ", ;
                    SBCOLS( nBoxLeft, nboxRight, .f. ) )
@ nBoxBot - ( nTBottom ) + 1, nBoxLeft + 1 say cInstruct1         
nInstruct1 := nBoxBot - ( nTBottom ) + 1

if lMarkOrSearch
   cInstruct2 := PADC( iif( lSearch, " [S=Search]  ", "" ) + iif( lMark, "[M=Mark/Endmark]", "" ), ;
                       SBCOLS( nBoxLeft, nboxRight, .f. ) )
else
   cInstruct2 := ""
endif

@ nBoxbot - 1, nBoxLeft + 1 say cInstruct2         
nInstruct2 := nBoxBot - 1

//-
nBrow1 := nBoxBot - ( nTBottom ) + 1
nBrow2 := nBoxBot - 1

nAtArrows := nBoxLeft + at( "[", cInstruct1 )
nAtPgup   := nBoxLeft + at( "[PGUP", cInstruct1 )
nAtPgdn   := nBoxLeft + at( "[PGDN", cInstruct1 )
nAtHome   := nBoxLeft + at( "[HOME", cInstruct1 )
nAtEnd    := nBoxLeft + at( "[END", cInstruct1 )
nAtEsc    := nBoxLeft + at( "[ESC", cInstruct1 )
nAtSearch := nBoxLeft + at( "[S=", cInstruct2 )
nAtMark   := nBoxLeft + at( "[M=", cInstruct2 )

aButtons := { ;
              { nBrow1, nAtArrows, nBrow1, nAtArrows + 2, K_UP }, ;
              { nBrow1, nAtArrows + 3, nBrow1, nAtArrows + 5, K_DOWN }, ;
              { nBrow1, nAtArrows + 6, nBrow1, nAtArrows + 8, K_RIGHT }, ;
              { nBrow1, nAtArrows + 9, nBrow1, nAtArrows + 11, K_LEFT }, ;
              { nBrow1, nAtPgUp, nBrow1, nAtPgUp + 5, K_PGUP }, ;
              { nBrow1, nAtPgDn, nBrow1, nAtPgDn + 5, K_PGDN }, ;
              { nBrow1, nAtHome, nBrow1, nAtHome + 5, K_HOME }, ;
              { nBrow1, nAtEnd, nBrow1, nAtEnd + 3, K_END }, ;
              { nBrow1, nAtEsc, nBrow1, nAtEsc + 9, K_ESC } ;
              }
if lMark
   aadd( aButtons, ;
         { nBrow2, nAtMark, nBrow2, nAtMark + 15, asc( "M" ) } )
endif
if lSearch
   aadd( aButtons, ;
         { nBrow2, nAtSearch, nBrow2, nAtSearch + 9, asc( "S" ) } )
endif

//- initialize dimensions for screen output of file
nTopLine   := nBoxTop + 1
nBottLine  := nBoxBot - ( nTBottom ) - 1
nLeftEdge  := nBoxLeft + 1
nRightEdge := nBoxRight - 1

//- get line length, number of lines in box, and starting line offset
nLineLen    := nBoxRight - nBoxLeft - 1
nLineOffset := 1

oTb := tbrowsenew( ntopLine, nLeftEdge, nBottLine, nRightEdge )
oTb:addcolumn( tbcolumnnew( "", { || padr( subst( sfreadline( nHandle ), nLineOffset ), nLineLen ) } ) )
oTb:getcolumn( 1 ) :cargo     := { || sfreadline( nHandle ) } 
oTb:skipblock     := { | n | fi_tskip( n, nHandle ) }
oTb:gotopblock    := { || fi_ftop( nHandle ) }
oTb:gobottomblock := { || fi_fbot( nHandle ) }
oTb:getcolumn( 1 ) :colorblock := { || iif( Marked( nMarkStart, nMarkEnd, lMarking, nHandle ), { 2, 2 }, { 1, 2 } ) }

while .t.
   dispbegin()
   if lMarking
      @ nBoxBot - 1, nBoxLeft + 1 say "Marking..." color "*" + setcolor()        
   else
      @ nBoxBot - 1, nBoxLeft + 1 say space( 10 )         
   endif
   while !oTb:stabilize()
   end
   nCursRow := row()
   dispend()
   nFileOffset := fseek( nHandle, 0, 1 )
   if lMarking .and. nextkey() = 0
      if nFileOffset # nMarkEnd
         nMarkEnd := nFileOffset
         if nMarkEnd < nMarkStart
            lMarking := .f.
         endif
         oTb:refreshall()
         dispbegin()
         while !oTb:stabilize()
         end
         dispend()
      endif
   endif
   nLastKey := RAT_EVENT( 0, .f. )
   cLastKey := upper( chr( nLastKey ) )
   nMouseR  := rat_eqmrow()
   nMouseC  := rat_eqmcol()
   nButton  := MOUSEHOTAT( nMouseR, nMouseC, aButtons )
   if nButton > 0
      cLastKey := upper( chr( nButton ) )
   endif

   do case
   case nLastKey == K_ALT_R
     if lMark
      plswait(.t.,'Generating HTML...')
      tb2Html(oTb,'EARep.HTM',cTitle,, .t.)
      plswait(.f.)
      msg('EARep.HTM created!')
     endif
   case nLastKey == K_UP .or. nButton == K_UP
      oTb:UP()
      if nButton == K_UP
         IFMOUSEHD( { || oTb:UP() }, oTb )
      endif
   case nLastKey == K_DOWN .or. nButton == K_DOWN
      oTb:down()
      if nButton == K_DOWN
         IFMOUSEHD( { || oTb:down() }, oTb )
      endif
   case nLastKey == K_PGUP .or. nButton == K_PGUP
      oTb:PAGEUP()
   case nLastKey == K_PGDN .or. nButton == K_PGDN
      oTb:PAGEdown()
   case nLastKey == K_HOME .or. nButton == K_HOME
      oTb:gotop()
   case nLastKey == K_END .or. nButton == K_END
      oTb:gobottom()
   case ( nLastKey == K_LEFT .or. nButton == K_LEFT ) .and. nLineOffset > 5
      nLineOffset -= 5
      oTb:refreshall()
      if nButton == K_LEFT
         IFMOUSEHD( { || iif( nLineOffset > 5, nLineOffset -= 5, nLineOffset := 1 ), oTb:refreshall() }, oTb )
      endif
   case ( nLastKey == K_LEFT .or. nButton == K_LEFT ) .and. nLineOffset > 1
      nLineOffset := 1
      oTb:refreshall()
   case nLastKey == K_RIGHT .or. nButton == K_RIGHT
      nLineOffset += 5
      oTb:refreshall()
      if nButton == K_RIGHT
         IFMOUSEHD( { || nLineOffset += 5, oTb:refreshall() }, oTb )
      endif
   case nLastKey == K_CTRL_ENTER
        DirectGo( eval(oTb:getcolumn(1):block) )
   case nLastkey == K_ESC .or. nButton == K_ESC
      if lMarking
         lMarking := .f.
         oTb:refreshall()
         dispbegin()
         while !oTb:stabilize()
         end
         dispend()
      else
         exit
      endif
   case cLastKey == "M" .and. lMark
      if !lMarking
         lMarking   := .t.
         nMarkStart := nFileOffset
         nMarkEnd   := nFileOffset
      else
         lMarking := .f.
         docopy( nMarkStart, nMarkEnd, cFileName, nHandle )
         fseek( nHandle, 0, nFileOffset )
         nMarkStart := 0
         nMarkEnd   := 0
         oTb:refreshall()
      endif

   case cLastKey == "S" .and. lSearch
      cSeek := padr( cSeek, 30 )
      popread( .t., "Search for text:", @cSeek, "@K" )
      if !empty( cSeek )
         cSeek := trim( cSeek )
         if frseek( nHandle, cSeek )
            oTb:refreshall()
         else
            msg( "Not found" )
            fseek( nHandle, nFileOffset, 0 )
         endif
      endif
   case MBRZMOVE( oTB, nMouseR, nMousec, ntopLine, nLeftEdge, nBottLine, nRightEdge )
   endcase
end
//- set cursor on
fclose( nHandle )
setcursor( nCursor )
unbox( cReadBox )
return ''

//=======================================================
static function fi_fbot( nHandle )
fseek( nHandle, 0, 2 )
return ''

//=======================================================
static function fi_ftop( nHandle )

fseek( nHandle, 0 )
return ''

//--------------------------------------------------------------
static function fi_tskip( n, nHandle )

local nMoved := 0
if n > 0
   while nMoved < n
      if fmove2next( nHandle )
         nMoved ++
      else
         exit
      endif
   end
elseif n < 0
   while nMoved > n
      if fmove2prev( nHandle )
         nMoved --
      else
         exit
      endif
   end
endif
return nMoved

//-------------------------------------------------------------
static function frseek( nHandle, cSeek )

local lFound := .f.
local cuSeek := upper( cSeek )
while fmove2next( nHandle )
   if cuSeek $ upper( sfreadline( nHandle ) )
      lFound := .t.
      exit
   endif
end
return lFound

//-------------------------------------------------------------
static function Marked( nMarkStart, nMarkEnd, lMarking, nHandle )

local lMarked := .f.
local nOffset
if lMarking
   nOffset := fseek( nHandle, 0, 1 )
   if nOffset >= nMarkStart .and. nOffset <= nMarkEnd
      lMarked := .t.
   endif
endif
return lMarked

//-------------------------------------------------------------
static function docopy( nMarkStart, nMarkEnd, cInFile, nHandle )

local nDevice
local cFileName := space( 30 )
local cPrinter
local cMessage  := ""
local nAppend
fseek( nHandle, nMarkEnd, 0 )
if fmove2next( nHandle )
   nMarkEnd := fseek( nHandle, 0, 1 )
endif
if nMarkStart <= nMarkEnd
   while .t.
      cFileName := space( 30 )
      nDevice   := menu_v( "Copy Marked to", "Printer", "File", "Cancel" )
      do case
      case nDevice == 1                 // printer
         cPrinter := PRNPORT()
         toprint( cPrinter, nMarkStart, nMarkEnd, nHandle )
      case nDevice == 2                 // file
         popread( .t., "File Name", @cFileName, "@K" )
         cFileName := upper( trim( cFileName ) )
         cInfile   := upper( cInFile )
         if !ISVALFILE( cFileName, .f., @cMessage )
            msg( "Invalid file name", cMessage )
         elseif cFileName == cInFile
            msg( "Can't write to this file" )
         elseif file( cFileName )
            nAppend := menu_v( "File Exists", "OverWrite", "Append", "Cancel" )
            do case
            case nAppend == 1
               tofile( cFileName, .f., nMarkStart, nMarkEnd, nHandle )
            case nAppend == 2
               tofile( cFileName, .t., nMarkStart, nMarkEnd, nHandle )
            endcase
         else
            tofile( cFileName, .f., nMarkStart, nMarkEnd, nHandle )
         endif
      otherwise
         exit
      endcase
   end
endif
return nil

//-------------------------------------------------------------
static function toprint( cPrinter, nMarkStart, nMarkEnd, nHandle )

local nLpp   := 60
local nLines := 0
local lComp  := jAlert( 'Print Compressed ?', { 'Yes', 'No' } ) = 1
set printer to (cPrinter )
fseek( nHandle, nMarkStart, 0 )
set printer on
if lComp
   ?? chr( 15 )
endif
while fseek( nHandle, 0, 1 ) < nMarkEnd
   set console OFF
   if p_ready( cPrinter )
      ? sfreadline( nHandle )
      nLines ++
   else
      exit
   endif
   fmove2next( nHandle )
   set console on
end
eject
set printer to
set printer OFF
set console on
MSG( "Marked lines written" )
return NIL

//-------------------------------------------------------------
function tofile( cFileName, lAppend, nMarkStart, nMarkEnd, nHandle )

if lAppend
   set printer to (RepPath+ cFileName ) additive
else
   set printer to (RepPath+ cFileName )
endif
fseek( nHandle, nMarkStart, 0 )

set printer on
do while ( fseek( nHandle, 0, 1 ) < nMarkEnd ) .and. (! FEof(nHandle))
   set console OFF
   ? sfreadline( nHandle )
   set console on
   if ! fmove2next( nHandle )
     exit
   endif
enddo
set printer to
set printer OFF
*MSG( "Marked lines written" )
return NIL
//------------------------------
static function DirectGo(cRow)
local cBillNo
if subs(cRow,12,13) == 'Sales Bill : '
   cBillNo := alltrim(subs(cRow,25,5))
   if val(cBillNo) <> 0
      jSaveEnv()
      close all
      keyboard ( cBillNo + CHR(K_ENTER) )
      Sales()
      close all
      jRestEnv()
      getlist := {}
   endif
/*
elseif at(
   cBillNo := alltrim(subs(cRow,25,5))
   if val(cBillNo) <> 0
      jSaveEnv()
      close all
      keyboard ( cBillNo + CHR(K_ENTER) )
      Sales()
      close all
      jRestEnv()
   endif
*/
endif
return .t.

//
//

// === MARK (DirectGOO)
// Jasim
//
//
//

//
//=========================================
*+ EOF: F_READ.PRG
