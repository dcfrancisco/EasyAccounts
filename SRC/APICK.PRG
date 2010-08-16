/*
   Program:   APICK.PRG
   System:    GRUMPFISH LIBRARY
   Author:    Greg Lief
   Copyright (c) 1988-93, Greg Lief
   Dialect:   CA-Clipper 5.x
   Compile instructions: clipper apick /n /w

   If you recompile this file, at a minimum you MUST use the /N
   command-line parameter.

   If you are using Clipper 5.2, you may wish to recompile APICK.PRG
   with the "/dCLIPPER52" command-line parameter to take advantage of
   the TBrowse:forceStable() method.

   If you always want up/down arrows visible, recompile APICK.PRG with
   the "/dARROWS_ALWAYS" command-line parameter. (Note that arrows are
   always visible if you are using the mouse.)
*/

#include "std.ch"
#include "inkey.ch"
#include "grump.ch"

#ifdef MOUSE
#ifndef ARROWS_ALWAYS
#define ARROWS_ALWAYS
#endif
#endif

#define ISCHAR(a)        valtype(a) == "C"

//ÄÄÄÄÄ manifest constants used for drawing arrows, search string,
//ÄÄÄÄÄ and restoring the box outline underneath those items
#define S_ROW          cScrnBuff[1]
#define S_LEFT         cScrnBuff[2]
#define S_RIGHT        cScrnBuff[3]
#define S_MID          cScrnBuff[4]
#define S_COLOR        cScrnBuff[5]
#define S_TOPARROW     cScrnBuff[6]
#define S_BOTTOMARROW  cScrnBuff[7]
#define S_BUFFER       cScrnBuff[8]

function apick( nTop, nLeft, nBottom, nRight, aSource, cBoxColor, ;
                cBarColor, cStatColor, nActualLen, aTags, cUnselected, ;
                cHighlight, ele, cSelected, cUnavailable, cTitle, lWrap, ;
                nBox, lMovedown, lDrawbar, lRestore, lTrigger )
local marray      := aclone( aSource )
local browse
local column
local nKey
local xx
local nMaxEle
local cType
local temp
local aOldscrn
local nMaxWidth
local nChoice
local aAvailable
local nBarLine
local nOldRow
local nOldCol
local lTagging
local cSearchstr    // search string for additive searches
local cScrnBuff
local nGroupStart := 0                  // for group marking w/ F7
local nGroupEnd     // likewise

//ÄÄÄÄÄ note: many people use APICK() in conjunction with GRUMPBROW(),
//ÄÄÄÄÄ which remaps the UP and DOWN arrows to do something completely
//ÄÄÄÄÄ different.  Therefore, we will temporarily shut them off so that
//ÄÄÄÄÄ they do what we expect them to do in the context of this function.
local bOldUp   := setkey( K_UP, NIL )
local bOldDown := setkey( K_DOWN, NIL )

#ifdef MOUSE
local nDelta
local aPos
local nMRow
local nMCol
local lResetMouse := .f.
#endif

GFSaveEnv(, 0 )     // shut off cursor

/*
   establish colors for box, status bar, and indicator (see
   COLORSET.PRG for default settings).  Pay attention to the second
   parameter -- this tells ColorSet() to merely return the default
   value rather than actually changing the color
*/

/*
default cBoxColor to ColorSet(C_APICK_BOXOUTLINE, .T.)
default cBarColor to ColorSet(C_APICK_STATUSBAR, .T.)
default cStatColor to ColorSet(C_APICK_INDICATOR, .T.)
default cUnselected to ColorSet(C_APICK_UNSELECTED, .T.)
default cHighlight to ColorSet(C_APICK_CURRENT, .T.)
*/
if cBoxColor = NIL
   cBoxColor := boxcolor()
endif

default cBoxColor to cBoxColor
default cBarColor to cBoxColor
default cStatColor to cBoxColor
default cUnselected to cBoxColor
default cHighlight to cBoxColor
default cSelected to cBoxColor

default cSelected to ColorSet( C_APICK_TAGGED, .T. ) + ',' + ;
                               ColorSet( C_APICK_TAGGEDCURRENT, .T. )

default cUnavailable to ColorSet( C_APICK_UNAVAILABLE, .T. ) + ',' + ;
                                  ColorSet( C_APICK_UNAVAILABLECURRENT, .T. )

default ele to 1    // this will serve as our placeholder in the array
default cTitle to ''                    // title for APICK() box
default lWrap to .t.                    // enable wraparound from top to bottom of array
default nBox to 1   // boxtype: default is double line
default lMovedown to .t.                // move down a row after tagging an item
default lRestore to .t.                 // restore screen after APICK() is finished
default lTrigger to .f.                 // allow keypresses to serve as trigger keys
// (like @..PROMPT menu options)

//ÄÄÄÄÄ we will allow tagging only if an array was passed to hold the tags
lTagging   := valtype( aTags ) == "A"
cSearchstr := []    // reset search string for additive search

//ÄÄÄÄÄ determine # of last element by grabbing length of array,
//ÄÄÄÄÄ unless of course the actual length was passed as parameter #9
nMaxEle := if( valtype( nActualLen ) <> "N", len( marray ), nActualLen )

//ÄÄÄÄÄ initialize parallel array that will determine whether each element
//ÄÄÄÄÄ can be selected... will load this in the loop just below
aAvailable := array( nMaxEle )

/*
   Loop through array to determine maximum width for the column.  Starting
   point for width is length of box title + delimiters, or 10 (necessary
   for showing the additive search string on bottom row of box), whichever
   is greater.  We'll also initialize each element in the aAvailable array.
*/
nMaxWidth := max( len( cTitle ) + 4, 10 )
for xx := 1 to nMaxEle
   cType := valtype( marray[ xx ] )
   if cType == "C"
      nMaxWidth        := max( nMaxWidth, len( marray[ xx ] ) )
      aAvailable[ xx ] := ( left( marray[ xx ], 1 ) <> "~" )
   else
      aAvailable[ xx ] := .t.
      do case
      case cType == "D"
         nMaxWidth := max( nMaxWidth, 8 )
      case cType == "N"
         nMaxWidth := max( nMaxWidth, 10 )
      endcase
   endif
next

//ÄÄÄÄÄ if the maximum width was changed in the processing above, and
//ÄÄÄÄÄ if we are allowing tagging, we must increment it by one so
//ÄÄÄÄÄ that the checkmark will actually appear!
if lTagging .and. nMaxWidth > len( cTitle ) + 4
   nMaxWidth ++
endif

//ÄÄÄÄÄ establish coordinates if not passed as parameters
default nTop to if( nMaxEle > maxrow() - 2, 6, int( ( maxrow() - nMaxEle - 1 ) / 2 ) )
default nLeft to int( ( maxcol() - nMaxWidth - 2 ) / 2 )
default nBottom to if( nMaxEle > maxrow() - 2, maxrow() - 6, nTop + nMaxEle + 1 )
default nRight to nLeft + nMaxWidth + 1

if lTagging
   default aTags to {}                  // just in case you didn't pass an array (for shame!)
   //ÄÄÄÄÄ if tags array was empty, initialize it now
   if empty( aTags )
      aTags := afill( array( nMaxEle ), .f. )
   else
      //ÄÄÄÄÄ ensure that blank elements get initialized to false
      for xx := 1 to len( aTags )
         if aTags[ xx ] == NIL
            aTags[ xx ] := .f.
         endif
      next
   endif
endif

//ÄÄÄÄÄ Create tbrowse object set to the appropriate coordinates
browse := TBrowseNew( nTop + 1, nLeft + 1, nBottom - 1, nRight - 1 )
//browse:colorSpec := cUnselected + "," + cHighlight + "," + cSelected + ;
//                    "," + cUnavailable
browse:colorSpec := cBoxColor
//ÄÄÄÄÄ establish navigation blocks for the tbrowse object
browse:skipBlock     := { | SkipCnt | Gilligan( @ele, SkipCnt, nMaxEle ) }
browse:goTopBlock    := { || ele := 1 }
browse:goBottomBlock := { || ele := nMaxEle }

//ÄÄÄÄÄ look for horizontal lines -- any elements like so: "~Ä"
for xx := 1 to nMaxEle
   if ISCHAR( marray[ xx ] ) .and. substr( marray[ xx ], 1, 1 ) == '~'
      marray[ xx ] := substr( marray[ xx ], 2 )

      //ÄÄÄÄÄ do they want to draw a horizontal line? if so, the
      //ÄÄÄÄÄ trimmed length of this array element will now be one.
      if len( trim( marray[ xx ] ) ) == 1
         marray[ xx ] := replicate( trim( marray[ xx ] ), nMaxWidth )

         //ÄÄÄÄÄ if the first and last characters match (and are not letters!),
         //ÄÄÄÄÄ that indicates we are to center the rest of the text on a
         //ÄÄÄÄÄ horizontal line composed of the leftmost character.  For
         //ÄÄÄÄÄ example, "~=text=" would become "=====text====="
      elseif !isalpha( marray[ xx ] ) .and. ;
                          left( marray[ xx ], 1 ) == right( marray[ xx ], 1 )
         marray[ xx ] := padc( substr( marray[ xx ], 2, len( marray[ xx ] ) - 2 ), ;
                               nMaxWidth, left( marray[ xx ], 1 ) )
      endif
   endif
next

//ÄÄÄÄÄ create column for the browse object
column       := TBColumnNew( "", { || marray[ ele ] } )
column:width := nMaxWidth - if( lTagging, 1, 0 )

/*
    establish color setup - use the following pairs for these items:
       unselected/available options  --> {1, 2}
       tagged/available options      --> {3, 4}
       unavailable options           --> {5, 6}

   these numbers correspond to colors as follows:
   1) unselected                    2) hilight
   3) tagged (unselected)           4) tagged (selected)
   5) unavailable (unselected)      6) unavailable (selected)
*/
if lTagging
   column:colorBlock := { || if( !aAvailable[ ele ], { 5, 6 }, ;
                          if( aTags[ ele ], { 3, 4 }, { 1, 2 } ) ) }
else
   column:colorBlock := { || if( !aAvailable[ ele ], { 5, 6 }, { 1, 2 } ) }
endif

//ÄÄÄÄÄ add this column to the browse object and get ready for browsing fun
browse:AddColumn( column )

//ÄÄÄÄÄ if tagging, add a new column to hold everybody's fave checkmark
if lTagging
   column            := TBColumnNew( "", { || if( aTags[ ele ], chr( 251 ), chr( 32 ) ) } )
   column:colorBlock := { || if( !aAvailable[ ele ], { 5, 6 }, ;
                          if( aTags[ ele ], { 3, 4 }, { 1, 2 } ) ) }
   browse:addColumn( column )
   browse:colSep := ''                  // we want the two columns to butt against each other
endif

#ifdef MOUSE
//ÄÄÄÄÄ move cursor out of screen area to be saved
aPos := GetMousePos()
if aPos[ 1 ] >= nTop .and. aPos[ 1 ] < nBottom + 2 ;
           .and. aPos[ 2 ] >= nLeft ;
           .and. aPos[ 2 ] < nRight + 2
   lResetMouse := .t.
   SetMousePos( nTop - 1, nLeft - 1 )
endif
#endif

//ÄÄÄÄÄ draw box and status bar, using box title if it was passed
aOldscrn := ShadowBox( nTop, nLeft, nBottom, nRight, nBox, cTitle,, cBoxColor )

//ÄÄÄÄÄ save bottom row of box and necessary coordinates -- if you use
//ÄÄÄÄÄ the additive search feature, the ShowString() function will
//ÄÄÄÄÄ need to restore the bottom row of the box
cScrnBuff := { nBottom, nLeft, nRight, ;
               nLeft + int( ( nRight - nLeft ) / 2 ) - 4, ;                     // horizontal midpoint
               cBoxColor, ;
               left( savescreen( nTop + 1, nRight, nTop + 1, nRight ), 1 ), ;   // top arrow
               left( savescreen( nBottom - 1, nRight, nBottom - 1, nRight ), 1 ), ;                 // bottom arrow
               savescreen( nBottom, nLeft, nBottom, nRight ) }

#ifdef MOUSE
if lResetMouse
   SetMousePos( aPos[ 1 ], aPos[ 2 ] )
endif
#endif

//ÄÄÄÄÄ draw status bar if not all of the array elements fit in the window
nBarLine := nTop + 3
default lDrawbar to ( nMaxEle > nBottom - nTop - 1 )
if lDrawbar
#ifdef ARROWS_ALWAYS
   @ nTop + 1, nRight    say chr( 24 )         
   @ nBottom - 1, nRight say chr( 25 )         
#endif
   @ nTop + 2, nRight, nBottom - 2, nRight box chr( 176 ) color cBarColor         
endif
browse:autoLite := .f.
do while nChoice == NIL

   dispbegin()

#ifdef MOUSE
   aPos := GetMousePos()
   if aPos[ 1 ] >= browse:nTop .and. aPos[ 1 ] <= browse:nBottom ;
              .and. aPos[ 2 ] >= browse:nLeft ;
              .and. aPos[ 2 ] <= browse:nRight
      lResetMouse := .t.
      setpos( browse:nTop - 1, browse:nLeft - 1 )
   endif
#endif

   do while ( nKey := inkey() ) == 0 .and. !browse:stabilize()
   enddo

   dispend()

#ifdef MOUSE
   if lResetMouse
      setpos( aPos[ 1 ], aPos[ 2 ] )
      lResetMouse := .f.
   endif
#endif

   if browse:stable

      //ÄÄÄÄÄ the next bit of logic ensures that we are not sitting on
      //ÄÄÄÄÄ an unavailable element (does not apply to top and bottom)
      if !aAvailable[ ele ]
         xx := lastkey()
         //ÄÄÄÄÄ note: we must take into account the possibility that
         //ÄÄÄÄÄ the user pressed SPACEBAR to tag and thus automatically
         //ÄÄÄÄÄ moved down to an unavailable item (hence the 32 logic)
         if ( ( xx == K_UP .or. xx == K_PGUP ) .and. ( ele > 1 .or. lWrap ) ) .or. ;
                ( ( xx == K_DOWN .or. xx == K_PGDN .or. xx == 32 ) .and. ;
                ( ele < nMaxEle .or. lWrap ) )
            keyboard chr( if( xx == 32 .or. xx == K_DOWN .or. xx == K_PGDN, ;
                          K_DOWN, K_UP ) )
         elseif ele == 1
            keyboard chr( K_DOWN )
         elseif ele == nMaxEle
            keyboard chr( K_UP )
         endif
      endif

      if lDrawbar
         nOldRow := row()
         nOldCol := col()
#ifndef ARROWS_ALWAYS

         //ÄÄÄÄÄ draw arrows if there are elements beyond top or bottom of window
         //ÄÄÄÄÄ first the bottom
         @ nBottom - 1, nRight ssay if( nMaxEle - ele >= nBottom - nOldRow, ;
                 chr( 25 ), S_BOTTOMARROW ) color cBoxColor
         //ÄÄÄÄÄ then the top
         @ nTop + 1, nRight ssay if( nOldRow - ele < nTop, chr( 24 ), S_TOPARROW ) ;
                 color cBoxColor

#endif

         //ÄÄÄÄÄ if status bar position has changed...
         if nBarLine <> nTop + 2 + ;
                    int( ( ele / nMaxEle ) * ( nBottom - nTop - 4 ) )
            //ÄÄÄÄÄ first, blank out previous status bar
            @ nBarLine, nRight ssay chr( 176 ) color cBarColor         
            //ÄÄÄÄÄ then recalculate position of status bar
            nBarLine := nTop + 2 + int( ( ele / nMaxEle ) * ;
                        ( nBottom - nTop - 4 ) )
            //ÄÄÄÄÄ finally, redraw it
            @ nBarLine, nRight ssay chr( 219 ) color cStatColor         
         endif
         setpos( nOldRow, nOldCol )
      endif
      if nextkey() == 0
         browse:hiLite()
      endif
      nKey := ginkey( 0, str( ele ) )   // pass along array element
      browse:deHilite()
   endif

#ifdef MOUSE
   if nKey == K_LEFT_DBLCLICK
      if GFLastRow() == browse:nTop + browse:rowPos - 1 .and. ;
                 GFLastCol() >= browse:nLeft .and. GFLastCol() <= browse:nRight
         if aAvailable[ ele ]
            if lTagging
               nKey := 32
            else
               nKey := K_ENTER
            endif
         endif
      else
         nKey := K_LEFT_DOWN
      endif
   endif
#endif

   //ÄÄÄÄÄ deal with the keypress
   do case
#ifdef MOUSE
   case nKey == K_RIGHT_DOWN
      nChoice := 0

   case nKey == K_LEFT_DOWN
      if GFLastCol() == nRight
         if GFLastRow() == nTop + 1
            if .not. empty( cSearchstr )
               //ÄÄÄÄÄ clear search string
               cSearchstr := []
               showstring( cSearchstr, cScrnBuff )
            endif
            browse:up()
         elseif GFLastRow() == nBottom - 1
            if .not. empty( cSearchstr )
               //ÄÄÄÄÄ clear search string
               cSearchstr := []
               showstring( cSearchstr, cScrnBuff )
            endif
            browse:down()
         elseif GFLastRow() == nBarLine
            ShowMouseCursor()
            enableDrag( .T. )           // Enable mouse dragging
            nMRow := GFLastRow()
            do while inkey() <> K_LEFT_UP
               aPos := GetMousePos()
               if aPos[ 1 ] == nMRow .and. aPos[ 2 ] == nRight
                  loop
               elseif aPos[ 1 ] < nTop + 2 .or. ;
                          aPos[ 1 ] > nBottom - 2 .or. ;
                          aPos[ 2 ] <> nRight
                  SetMousePos( nMRow, nRight )
                  loop
               endif

               dispbegin()
               nMRow := aPos[ 1 ]
               @ nBarLine, nRight ssay chr( 176 ) color cBarColor         
               nBarLine := nMRow
               @ nBarLine, nRight ssay chr( 219 ) color cStatColor         
               dispend()

            enddo
            ele := int( ( nBarLine - nTop - 2 ) / ( nBottom - nTop - 4 ) * nMaxEle )
            HideMouseCursor()
            browse:refreshAll()
            enableDrag( .F. )           // Disable mouse dragging

         endif

      elseif GFLastRow() >= browse:nTop .and. GFLastRow() <= browse:nBottom .and. ;
                            GFLastCol() >= browse:nLeft .and. GFLastCol() <= browse:nRight
         if .not. empty( cSearchstr )
            //ÄÄÄÄÄ clear search string
            cSearchstr := []
            showstring( cSearchstr, cScrnBuff )
         endif

         nDelta := GFLastRow() - browse:nTop + 1 - browse:rowPos

         while nDelta <> 0
            if nDelta < 0
               browse:up()
               nDelta ++
            else
               browse:down()
               nDelta --
            endif
         end
      endif
#endif

   case nKey == 32 .and. aAvailable[ ele ] .and. lTagging   // tag 'em, Dan-O
      aTags[ ele ] = !aTags[ ele ]
      if !empty( cSearchstr )
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      //ÄÄÄÄÄ force redrawing this item to change its color
      browse:refreshCurrent()
      //ÄÄÄÄÄ move down a row if user requested it
      if lMovedown
         browse:down()
      endif

   case nKey == K_F7 .and. lTagging     // group tag
      if nGroupStart == 0
         nGroupStart := ele
      else
         nGroupEnd := ele
         if nGroupEnd < nGroupStart
            nGroupEnd   := nGroupStart
            nGroupStart := ele
         endif
         for xx := nGroupStart to nGroupEnd
            if aAvailable[ xx ]
               aTags[ xx ] := .t.
            endif
         next
         //ÄÄÄÄÄ force redrawing entire window to change color of all items
         browse:refreshAll()
         nGroupStart := nGroupEnd := 0
      endif

   case nKey == K_F8 .and. lTagging     // tag 'em all, Dan-O
      for xx := 1 to nMaxEle
         if aAvailable[ xx ]
            aTags[ xx ] := .t.
         endif
      next
      //ÄÄÄÄÄ force redrawing entire window to change color of all items
      browse:refreshAll()

   case nKey == K_F9 .and. lTagging     // set 'em free, Dan-O
      afill( aTags, .f. )
      //ÄÄÄÄÄ force redrawing entire window to change color of all items
      browse:refreshAll()

   case nKey == K_F10 .and. lTagging    // switch all tags (Chinese Fire Drill)
      for xx := 1 to nMaxEle
         if aAvailable[ xx ]
            aTags[ xx ] := !aTags[ xx ]
         endif
      next
      //ÄÄÄÄÄ force redrawing entire window to change color of all items
      browse:refreshAll()

   case nKey == K_UP                    // up one row
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      //ÄÄÄÄÄ if at the top element, wrap to bottom if wrap is enabled
      if ele == 1 .and. lWrap
         browse:goBottom()
      else
         browse:up()
      endif

   case nKey == K_DOWN                  // down one row
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      //ÄÄÄÄÄ if at the bottom element, wrap to top if wrap is enabled
      if ele == nMaxEle .and. lWrap
         browse:goTop()
      else
         browse:down()
      endif

   case nKey == K_CTRL_PGUP             // take it to the top, Jerome!
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      browse:goTop()

   case nKey == K_CTRL_PGDN             // goin' down.... down.... down ........
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      browse:goBottom()

   case nKey == K_PGUP .or. nKey == K_HOME                  // top o' window
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      browse:pageUp()

   case nKey == K_PGDN .or. nKey == K_END                   // bottom o' window
      if !empty( cSearchstr )
         //ÄÄÄÄÄ clear search string
         cSearchstr := []
         showstring( cSearchstr, cScrnBuff )
      endif
      browse:pageDown()

   case nKey == K_ESC                   // aloha, you quitter
      nChoice := 0

   case nKey > 31 .and. nKey < 255      // search 'em
      if lTrigger .and. ( temp := Ascan2( marray, chr( nKey ), aAvailable ) ) > 0
         nChoice := temp
      elseif ( temp := Ascan2( marray, cSearchstr + chr( nKey ), aAvailable ) ) > 0
         cSearchstr += chr( nKey )
         //ÄÄÄÄÄ if moving backwards (up) through the array,
         //ÄÄÄÄÄ we have to handle it manually
         if ele > temp
            for xx := 1 to ele - temp
               browse:up()
            next
         elseif ele <> temp
            ele := temp
            browse:refreshAll()
#ifdef CLIPPER52
            browse:forceStable()
#else
            do while !browse:stabilize()
            enddo
#endif
         endif
         showstring( cSearchstr, cScrnBuff )
      endif

   case nKey == K_BS .or. nKey == K_LEFT                    // truncate the search string
      if len( cSearchstr ) > 0
         cSearchstr := substr( cSearchstr, 1, len( cSearchstr ) - 1 )
         if ( temp := Ascan2( marray, cSearchstr, aAvailable ) ) > 0
            ele := temp
            browse:refreshAll()
#ifdef CLIPPER52
            browse:forceStable()
#else
            do while !browse:stabilize()
            enddo
#endif
         endif
         showstring( cSearchstr, cScrnBuff )
      endif

   case nKey == K_ENTER .and. aAvailable[ ele ]             // select if available
      nChoice := ele

   endcase
enddo
if lRestore
   ByeByeBox( aOldscrn )
else
   browse:hiLite()  // leave selected option highlighted for reference
endif
GFRestEnv()
setkey( K_UP, bOldUp )
setkey( K_DOWN, bOldDown )
return nChoice

// end function APick()
//--------------------------------------------------------------------*

/*
   Function: ShowString()
   Purpose:  Display the search string
*/

static function showstring( cSearchstr, cScrnBuff )

if len( cSearchstr ) > 0
   @ S_ROW, S_MID ssay "[" + ;
           padr( substr( cSearchstr, max( 1, len( cSearchstr ) - 7 ) ), 8 ) + "]" ;
           color S_COLOR
else
   restscreen( S_ROW, S_LEFT, S_ROW, S_RIGHT, S_BUFFER )
endif
return NIL

// end static function ShowString()
//--------------------------------------------------------------------*

/*
     Function: AScan2()
     Purpose:  Perform case-insensitive ASCAN()
*/
static function AScan2( array, value, aAvailable )

local counter   := 1
local lOldExact := set( _SET_EXACT, .f. )
local nRetval   := ascan( array, { | a | if( ISCHAR( a ) .and. aAvailable[ counter ++ ], ;
        ltrim( upper( a ) ) = upper( value ), .F. ) }, 1 )
set( _SET_EXACT, lOldExact )
return nRetval

// end static function AScan2()
//--------------------------------------------------------------------*

// eof apick.prg

*+ EOF: APICK.PRG
