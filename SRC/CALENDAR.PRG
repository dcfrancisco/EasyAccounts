#include "std.ch"
#include "inkey.ch"
#include "box.ch"
//
#command DEFAULT <a> := <b> => <a> := if( <a> = nil, <b>, <a> )

#define MY_HSEP  'Í'
#define MY_CSEP  ' '
//
// Scroll back/fwd 1 month ?
static lMonthFwd  := .f.                // Logical: Skip Month +1 ?
static lMonthBck  := .f.                // Logical: Skip Month -1 ?
static ctColor    := "w+/rb+,r+/w+,,,w+/rb+"                // Default Calendar Color
static gnYear     := 1992               // Default Year()
static gdMinDate  := 0100               // Min Date Value
static gdMaxDate  := 2999               // Max Date Value
static gnMonth    := 1                  // Default Month()
static gnEpoch    := 1900               // Default Century
static gnDateDoM  := 1                  // Default Target Day
static gcMonthSel := " SELECT MONTH "   // Default GetMonth() title
static gaMonthStr := {}                 // Month String array
static gaDayStr   := {}                 // Day of Week String array
//
func CALENDAR()

local mOldCol    := setcolor()
local aOldSets   := FT_SAVESETS()
local mOldScr    := savescreen( 00, 00, maxrow(), maxcol() )
local dStartDate := date()
local nTRow
local nLCol
local cColorStr
local nCountry
local cKey       := 0
local dOrigDate  := date()
local cSaveWin
local cOldColr
local nOEpoch
local lOScorBrd  := .T.
local cODateFmt
local tDate
priv nTargRow
priv nTargCol
priv aMonth
//
DEFAULT nTRow      := 09
DEFAULT nLCol      := 54
DEFAULT dStartDate := date()
DEFAULT nCountry   := 1                 // Default to U.S. Month/Day str format
DEFAULT cColorStr  := msgcolor()
DEFAULT ctColor    := msgcolor()        // Default Calendar Color
//
nTRow := iif( nTRow > ( maxrow() - 7 ), ( maxrow() - 7 ), nTRow )
nLCol := iif( nLCol > ( maxcol() - 23 ), ( maxcol() - 23 ), nLCol )
//
nBRow     := nTRow + 7
nRCol     := nLCol + 21
ctColor   := cColorStr
cOldColr  := setcolor()                 // Save Calling func State
lOScorBrd := set( _SET_SCOREBOARD, .f. )                    // Disable Read Messages
// Save old format, force American
cODateFmt := set( _SET_DATEFORMAT, "mm/dd/yy" )
cSaveWin  := savescreen( nTRow, nLCol, nBRow + 2, nRCol + 2 )
cOldColr  := setcolor( ctColor )
lDone     := .F.
// Declare Min/Max Date values...
gdMinDate := ctod( '01/01/0100' )
gdMaxDate := ctod( '12/31/2999' )
//
SETMONTHSTR( nCountry )
DISPWIN( nTRow, nLCol, nBRow + 2, nRCol + 2, ctColor )      // Disp Calendar Box
//
do while ( !lDone )
   lMonthBck := .F.                     // Scroll back 1 month
   lMonthFwd := .F.                     // Scroll fore 1 month
   // Check for out-of-range dates...
   if ( ( dStartDate < gdMinDate ) .or. ( dStartDate > gdMaxDate ) )
      dStartDate := date()
   endif
   gnDateDoM  := day( dStartDate )      // Highlite Day of Month
   m1stDay    := FirstDay( dStartDate )                     // First Day of Mo. (#)
   mLastDay   := LastDay( dStartDate )  // Last Date of Month
   mWeeksInMo := WeeksInMo( m1stDay, mLastDay )             // No. of Weeks (rows)
   gnYear     := year( dStartDate )
   gnMonth    := month( dStartDate )
   // Build Calendar Array
   aMonth := MAKCALARR( m1stDay, mLastDay, mWeeksInMo, gnDateDoM )
   DSPCALHEAD( dStartDate, nTRow, nLCol, nRCol )            // Show Month and Year
   // Perform Calendar Browse
   dStartDate := CALBROWSE( dStartDate, nTRow + 1, nLCol + 1, nBRow + 1, nRCol + 1 )
   cKey       := lastkey()
   //
   do case
   case ( cKey == K_F1 )
      HELPSCR()
   case ( cKey == K_RETURN )
      exit
   case ( chr( cKey ) == " " )          // Return Blank Date
      dStartDate := ctod( space( 8 ) )
      exit
   case ( ( cKey == K_LEFT ) .and. ( gnDateDoM == 1 ) )     // Move Back 1 month
      dStartDate --
   case ( ( cKey == K_RIGHT ) .and. ( gnDateDoM == LastDay( gnMonth ) ) )
      dStartDate ++
   case ( cKey == K_UP )
      dStartDate -= 7
   case ( cKey == K_DOWN )
      dStartDate += 7
   case ( ( cKey == K_PGDN ) .or. lMonthFwd )
      dStartDate := MOVEMONTH( dStartDate, 1, gnYear )      // Month Forward
   case cKey == K_PGUP .or. lMonthBck
      dStartDate := MOVEMONTH( dStartDate, - 1, gnYear )    // Month Back
   case cKey == K_HOME                  // Goto Beginning of Month
      dStartDate := NUM2DATE( gnMonth, 1, gnYear )
   case cKey == K_END                   // Goto End of Month
      dStartDate := NUM2DATE( gnMonth, LastDay( gnMonth ), gnYear )
   case cKey == K_CTRL_PGDN
      dStartDate += 365                 // Increment Year by 1
   case cKey == K_CTRL_PGUP
      dStartDate -= 365                 // Decrement Year by 1
   case ( cKey == K_CTRL_HOME )         // First day of Year
      dStartDate := NUM2DATE( 1, 1, gnYear )
   case ( cKey == K_CTRL_END )
      dStartDate := NUM2DATE( 12, 31, gnYear )
   case ( cKey == K_ALT_M )             // Get New Month
      gnMonth := GetMonth( gnMonth, nTrow + 1, nRCol + 3, ctColor )
      tDate   := NUM2DATE( gnMonth, gnDateDoM, gnYear )
      if empty( tDate )                 // Ensure Valid date
         tDate := NUM2DATE( gnMonth, 1, gnYear )
      endif
      dStartDate := tDate
   case ( cKey == K_ALT_Y )             // Get New Year
      gnYear := GetYear( gnYear, nTrow + 1, nRCol + 3, ctColor )
      tDate  := NUM2DATE( gnMonth, gnDateDoM, gnYear )
      if empty( tDate )                 // Ensure Valid date
         tDate := NUM2DATE( gnMonth, 1, gnYear )
      endif
      dStartDate := tDate
   case ( cKey == K_ESC )
      dStartDate := dOrigDate           // Return Original Date
      exit
   endcase
enddo
set( _SET_SCOREBOARD, lOScorBrd )
set( _SET_DATEFORMAT, cODateFmt )
setcolor( cOldColr )
restscreen( nTRow, nLCol, nBRow + 2, nRCol + 2, cSaveWin )
FT_RESTSETS( aOldSets )
return dStartDate   // Return Selected Date
//
/**************************************************************************
* CALBROWSE( <aMonth>, <nTop>, <nLeft>, <nBottom>, <nRight> )             *
*                                                       --> nDaySelect    *
*   This FUNCTION adapted from Nantucket Array.prg contains the TBrowse   *
*   implementation                                                        *
* Revision History:                                                       *
**************************************************************************/
func CALBROWSE( dStartDate, nTop, nLft, nBot, nRit )

local o             // TBrowse object
local k             // used in o:SkipBlock
local nKey    := 0  // keystroke holder
private n     := 1  // browse row index holder
private nACol       // browse column subscript
setcursor( 0 )
// Create the TBrowse object
o         := TBrowseNew( nTop, nLft, nBot, nRit )
o:headsep := MY_HSEP
o:colsep  := MY_CSEP
/******************************************
*  Initialize the TBrowse blocks          *
*  Note: during browse, the current row   *
*        subscript is maintained          *
*        by the blocks in private n       *
*        LEN(aMonth) returns number of    *
*        rows in array                    *
******************************************/
o:SkipBlock     := { | nSkipVal | SkipFunc( @n, nSkipVal, len( aMonth ) ) }
o:GoTopBlock    := { || n := 1 }
o:GoBottomBlock := { || n := len( aMonth ) }
/******************************************
*  Create TBColumn objects, Initialize    *
*  data retrieval blocks, and Add to      *
*  TBrowse object                         *
******************************************/
for nACol := 1 to len( aMonth[ 1 ] )
   o:AddColumn( TBColumnNew( gaDayStr[ nACol ], ABlock( "aMonth[n]", nACol ) ) )
next
// Position Cursor to start
o:ColPos := nTargCol
o:RowPos := nTargRow
// Start event handler loop
do while nKey != K_ESC .and. nKey != K_RETURN
   nKey := 0
   // Start stabilization loop
   do while !o:Stabilize()
      nKey := inkey()
      if nKey != 0
         exit
      endif
   enddo
   dStartDate := ctod( strzero( gnMonth, 2, 0 ) + '/' + ;
                       aMonth[ n, o:ColPos ] + '/' + ;
                       str( gnYear, 4, 0 ) ;
                       )
   // Check for out-of-range dates...
   if dStartDate < gdMinDate .or. dStartDate > gdMaxDate
      dStartDate := date()
   endif
   gnDateDoM := day( dStartDate )       // Highlite Date
   if nKey == 0
      nKey := inkey( 0 )
   endif
   // Process directional keys
   if o:Stable
      do case
      case ( nKey == K_F1 )
         HELPSCR()
      case ( nKey == K_UP )
         if n > 1
            if !empty( aMonth[ n - 1, o:ColPos ] )
               o:Up()
            else
               return dStartDate
            endif
         else
            return dStartDate
         endif
      case ( nKey == K_DOWN )
         if n < len( aMonth )
            if !empty( aMonth[ n + 1, o:ColPos ] )
               o:Down()
            else
               return dStartDate
            endif
         else
            return dStartDate
         endif
      case ( nKey == K_RIGHT )
         if o:colPos == 7
            // Last day of month
            if val( aMonth[ n, o:ColPos ] ) != LastDay( gnMonth )
               o:down()
               o:home()
            else
               return dStartDate
            endif
         else
            // Last day of month
            if val( aMonth[ n, o:ColPos ] ) != LastDay( gnMonth )
               o:Right()
            else
               return dStartDate
            endif
         endif
      case ( nKey == K_LEFT )
         if o:colPos == 1
            if n > 1 /* NOTE: */
               o:up()
               o:end()
            else
               return dStartDate
            endif
         else
            if aMonth[ n, o:ColPos ] != " 1"                // 1rst of month
               o:Left()
            else
               return dStartDate
            endif
         endif
      case ( nKey == K_PGDN .or. nKey == K_CTRL_PGDN )
         return dStartDate
      case ( nKey == K_PGUP .or. nKey == K_CTRL_PGUP )
         return dStartDate
      case ( nKey == K_HOME )           // Return first DOM()
         return dStartDate
      case ( nKey == K_END )
         return dStartDate
      case ( nKey == K_CTRL_HOME )      // First day of Year
         return dStartDate
      case ( nKey == K_CTRL_END )
         return dStartDate
      case ( nKey == K_ALT_Y )
         return dStartDate
      case ( nKey == K_ALT_M )
         return dStartDate
      case ( chr( nKey ) == " " )
         return dStartDate
      endcase
   endif
enddo
setcursor( 1 )
return dStartDate
/**************************************************************************
* SkipFunc                                                                *
*  I don't know about you but I had to dissect the skipblock routine      *
*  in order to understand what it does.                                   *
*  - JP Steffen                                                           *
* Revision History:                                                       *
**************************************************************************/
static function SkipFunc( n, nSkip_Val, nMaxVal )

local nMove := 0    // Return Value
if nSkip_Val > 0
   do while n + nMove < nMaxVal .and. nMove < nSkip_Val
      nMove ++
   enddo
elseif nSkip_Val < 0
   do while n + nMove > 1 .and. nMove > nSkip_Val
      nMove --
   enddo
endif
n += nMove
return nMove
/**************************************************************************
*  FUNCTION DISPWIN                                                       *
*       clear window area and draw box for window                         *
*       Parameters:                                                       *
*       nTop            Top Row of Box                                    *
*       nLft            Left Column of Box                                *
*       nBot            Bottom Row of Box                                 *
*       nRit            Right Column of Box                               *
**************************************************************************/
static function DISPWIN( nTop, nLft, nBot, nRit, cClr )

cClr := iif( cClr = NIL, setcolor(), cClr )
setcolor( cClr )
dispbegin()
@ nTop, nLft CLEAR to nBot, nRit
@ nTop, nLft, nBot, nRit box B_DOUBLE_SINGLE color cClr         
dispend()
return NIL
//
/***************************************************************************
*  FUNCTION DSPCALHEAD                                                     *
*  create a centered Month and Year String                                 *
*       Parameters:                                                        *
*       dStartD         Date to derive month and Year from                 *
*       nLine           Line to display Calenday header on                 *
*       nBeg            Beginning Column which to display header           *
*       nEnd            Ending Column which to display header.             *
* Revision History:                                                        *
* 03-18-96 11:02am   RJC   Modified to use file-wide STATIC gaMonthStr[]   *
*                          to grab Month text from array instead of Clipper*
*                          internals.                                      *
***************************************************************************/
func DSPCALHEAD( dStartD, nLine, nBeg, nEnd )

nBeg ++
nEnd --
//  cStr     := " " + Upper(Trim(CMonth(dStartd)) + " " +                   ;
//              LTrim(Str(Year(dStartD))))  + " "
cStr := " " + upper( trim( gaMonthStr[ month( dStartd ) ] ) ) + " " + ;
        ltrim( str( year( dStartD ) ) ) + " "
nLineLen := ( nEnd - 1 ) - ( nBeg + 1 )
nSpace   := int( ( nLineLen - len( cStr ) + 2 ) / 2 ) + 2   // Centered title
dispbegin()
@ nLine, nBeg          say replicate( chr( 205 ), nEnd - nBeg + 3 ) color ctColor        
@ nLine, nBeg + nSpace say cStr                                     color ctColor        
dispend()
return NIL
/**************************************************************************
*  FUNCTION MAKCALARR                                                     *
*       Builds the data structure for the TBrowse in CALBROWSE.  This is  *
*       the key to the program & can no doubt be done better ie. faster.  *
*       Parameters:                                                       *
*       m1day                                                             *
*       mLastD          Last Day of month                                 *
*       mWeeks          Number of weeks in the month                      *
*       mTargD          Target Date                                       *
* Revision History:                                                       *
* 03-18-96 11:23am   RJC   Cleaned up code and made nRow, nCol and        *
*                          nDayOfMo LOCAL variables.                      *
**************************************************************************/
function MAKCALARR( m1day, mLastd, mWeeks, mTargd )

local dArray[ mWeeks ] [ 7 ]            // Called by other funcs
local nRow     := 0
local nCol
local nDayOfMo
nDayOfMo := 1
for nRow := 1 to mWeeks
   for nCol := 1 to 7
      // row & col of target day
      if nDayOfMo == mTargd
         nTargRow := nRow               // put browse cursor here
         nTargCol := nCol
      endif
      if nCol + ( nRow - 1 ) * 7 < m1Day .or. nDayOfMo > mLastD
         dArray[ nRow ] [ nCol ] := "  "
      else
         dArray[ nRow ] [ nCol ] := PadNumber( nDayOfMo, 2 )                    // convert to str len=2
         nDayOfMo ++
      endif
   next nCol
next nRow
return dArray
/**************************************************************************
* PadNumber()                                                             *
*     convert from num., trim, & apply leading Space                      *
* Revision History:                                                       *
**************************************************************************/
function PadNumber( In_Num, Out_len )

local Num_Len := len( ltrim( str( In_Num ) ) )
return space( Out_Len - Num_Len ) + ltrim( str( In_Num ) )
/**************************************************************************
*  FUNCTION MOVEMONTH()                                                   *
*  Simply adds or subtracts 30 days from date.  You may want to add more  *
*  sophistication to this to insure new day of month is same as current   *
*  day of month.                                                          *
*                       dStartD = Input Date                              *
*                       nMove   = +1 or -1 (times 30 days)                *
* Revision History:                                                       *
**************************************************************************/
function MOVEMONTH( dStartD, nMove, nYear )

local nLastMnth, nLastDay, nLastYear, ;
        nCurrMnth, nCurrDay, nCurrYear, ;
        nNextMnth, nNextDay, nNextYear, ;
        dTemp, nAbsMove
// Grab values...
nAbsMove  := abs( nMove )
nDay      := day( dStartD )
nCurrMnth := month( dStartD )
nCurrDay  := LastDay( nCurrMnth )
nCurrYear := year( dStartD )
nLastMnth := ( 12 + nCurrMnth - nAbsMove ) % 12
nLastDay  := LastDay( nLastMnth )
nLastYear := nCurrYear - int( ( nCurrMnth - nAbsMove ) / 12 )
nNextMnth := ( nCurrMnth + nAbsMove ) % 12
nNextDay  := LastDay( nNextMnth )
nNextYear := nCurrYear - int( ( nCurrMnth + nAbsMove ) / 12 )
if nMove > 0
   // Check if curr month longer than next
   // If so, go to end of next month
   if nDay <= nNextDay
      dStartD += nCurrDay
   else
      dTemp := NUM2DATE( nNextMnth, nNextDay, nNextYear )
      if !empty( dTemp )
         dStartD := dTemp
      endif
   endif
else
   // Check if curr month longer than next
   // If so, go to end of next month
   if nDay <= nLastDay
      dStartD -= nLastDay
   else
      dTemp := NUM2DATE( nLastMnth, nLastDay, nLastYear )
      if !empty( dTemp )
         dStartD := dTemp
      endif
   endif
endif
return dStartD
/**************************************************************************
*  NUM2DATE( nMonth, nDay, nYear ) => ctod('XX/XX/XX')                    *
*       FUNCTION converts the given numeric fields into date format.      *
*       Returns Empty(dDate) if invalid combination.                      *
* Revision History:                                                       *
**************************************************************************/
function NUM2DATE( nMonth, nDay, nYear )

local dDate
if LastDay( nMonth ) < nDay             // Invalid combination
   return ctod( space( 8 ) )
endif
if nYear < 100 .or. nYear > 2999        // Invalid year
   return ctod( space( 8 ) )
endif
dDate := ctod( strzero( nMonth, 2, 0 ) + '/' + ;
               strzero( nDay, 2, 0 ) + '/' + ;
               str( nYear, 4, 0 ) ;
               )
return dDate
/**************************************************************************
*  LastDay()                                                              *
*       Returns the last date of month for input date                     *
*       Modified parameter so that it may either be date or month number  *
*       Parameters:                                                       *
*       nMnth           Either Numeric Month number of Date from which    *
*                       to calculate the month from.                      *
* Revision History:                                                       *
**************************************************************************/
function LastDay( nMnth )

local nMonth := iif( valtype( nMnth ) = "D", month( nMnth ), nMnth )
local nDays  := 30
do case
case nMonth = 0     // Allow previous year, December
   nDays := 31
   // January
case nMonth = 1
   nDays := 31
   // February
case nMonth = 2     // Is this leap year ?
   if !empty( day( ctod( "02/29/" + str( gnYear, 4, 0 ) ) ) )
      nDays := 29
   else
      nDays := 28
   endif
   // March
case nMonth = 3
   nDays := 31
   // April
case nMonth = 4
   nDays := 30
   // May
case nMonth = 5
   nDays := 31
   // June
case nMonth = 6
   nDays := 30
   // July
case nMonth = 7
   nDays := 31
   // August
case nMonth = 8
   nDays := 31
   // September
case nMonth = 9
   nDays := 30
   // October
case nMonth = 10
   nDays := 31
   // November
case nMonth = 11
   nDays := 30
   // December
case nMonth = 12
   nDays := 31
endcase
return nDays
/**************************************************************************
*  FirstDay()                                                             *
*       Returns the day of week for first day of month                    *
* Revision History:                                                       *
**************************************************************************/
function FirstDay( nStartD )

return dow( nStartD - day( nStartD ) + 1 )
/**************************************************************************
*  WeeksInMo()                                                            *
*       Calculates the number of rows needed for array                    *
*       Parameters:                                                       *
*       nBegDoW         Beginning Date Day of Week                        *
*       nDays           Number of days in the month.                      *
* Revision History:                                                       *
**************************************************************************/
function WeeksInMo( nBegDoW, nDays )

do case
case nDays == 31    // 31 day month
   if nBegDoW >= 6
      return 6
   else
      return 5
   endif
case nDays == 30    // 30 day month
   if nBegDoW == 7
      return 6
   else
      return 5
   endif
case nDays == 29    // February - leap year
   return 5
case nDays == 28    // February - 28 days
   if nBegDoW == 1
      return 4
   else
      return 5
   endif
endcase
return 4
/**************************************************************************
*   ABlock( <cName>, <nSubx> ) -> bABlock                                 *
*       Given an array name and subscript, return a set-get block for     *
*       the array element indicated.                                      *
* Revision History:                                                       *
**************************************************************************/
function ABlock( cName, nSubx )

local caExpr
local bRetVal
caExpr  := cName + "[" + ltrim( str( nSubx ) ) + "]"
bRetVal := &( "{||" + caExpr + "}" )
return bRetVal
/**************************************************************************
*  SETMONTHSTR(nCountry)                                                  *
*     FUNCTION sets the file-wide STATIC arrays for Month and Day string  *
*     for the appropriate text.  The following codes are valid (so far):  *
*     nCountry =        Language for Month & Day Strings:                 *
*     ----------        ---------------------------------                 *
*     1 or undef        English (default) - American format               *
*     2                 Dutch                                             *
*                                                                         *
**************************************************************************/
static function SETMONTHSTR( nCountry )

if !( 0 < nCountry .and. nCountry <= 2 )                    // Not valid value - def = 1
   nCountry := 1
endif
do case
case nCountry == 1  // English - American
   gcMonthSel := " SELECT MONTH "
   gaMonthStr := { ;
                   "January", ;
                   "February", ;
                   "March", ;
                   "April", ;
                   "May", ;
                   "June", ;
                   "July", ;
                   "August", ;
                   "September", ;
                   "October", ;
                   "November", ;
                   "December" ;
                   }
   gaDayStr := { ;
                 "Su", ;
                 "Mo", ;
                 "Tu", ;
                 "We", ;
                 "Th", ;
                 "Fr", ;
                 "Sa" ;
                 }
case nCountry == 2  // Dutch
   gcMonthSel := " NIEUWE MAAND "
   gaMonthStr := { ;
                   "Januari", ;
                   "Februari", ;
                   "Maart", ;
                   "April", ;
                   "Mei", ;
                   "Juni", ;
                   "Juli", ;
                   "Augustus", ;
                   "September", ;
                   "Oktober", ;
                   "November", ;
                   "December" ;
                   }
   gaDayStr := { ;
                 "Zo", ;
                 "Ma", ;
                 "Di", ;
                 "Wo", ;
                 "Do", ;
                 "Vr", ;
                 "Za" ;
                 }
endcase
return NIL
/**************************************************************************
*  GetMonth( )                                                            *
*       Pop - Up Menu for Month Selection.  Returns Selected Month        *
* Revision History:                                                       *
* 03-19-96 09:20am   Rod   Converted to file-wide STATIC vars for month   *
*                          and box title; allowing for alternate languages*
**************************************************************************/
static function GetMonth( nDefaultMnth, nTop, nLft, cColor )

local nMonth := nDefaultMnth
local sWin   := ""
local tTop   := 11
local tLft   := 63
local coColr := setcolor()
// Establish Calendar box coordinates
tTop := iif( nTop == NIL, 0, iif( nTop > maxrow() - 13, maxrow() - 13, nTop ) )
tLft := iif( nLft == NIL, 0, iif( nLft > maxcol() - 17, maxcol() - 17, nLft ) )
keyboard chr( K_HOME ) + replicate( chr( K_DOWN ), nDefaultMnth - 1 )
sWin := savescreen( tTop, tLft, tTop + 13, tLft + 15 )
dispbegin()
setcolor( cColor )
DISPWIN( tTop, tLft, tTop + 13, tLft + 15, cColor )
@ tTop + 0, tLft + 1 say gcMonthSel color cColor        
@ tTop + 1, tLft + 1 prompt "1)  " + padr( gaMonthStr[ 1 ], 9 )
@ tTop + 2, tLft + 1 prompt "2)  " + padr( gaMonthStr[ 2 ], 9 )
@ tTop + 3, tLft + 1 prompt "3)  " + padr( gaMonthStr[ 3 ], 9 )
@ tTop + 4, tLft + 1 prompt "4)  " + padr( gaMonthStr[ 4 ], 9 )
@ tTop + 5, tLft + 1 prompt "5)  " + padr( gaMonthStr[ 5 ], 9 )
@ tTop + 6, tLft + 1 prompt "6)  " + padr( gaMonthStr[ 6 ], 9 )
@ tTop + 7, tLft + 1 prompt "7)  " + padr( gaMonthStr[ 7 ], 9 )
@ tTop + 8, tLft + 1 prompt "8)  " + padr( gaMonthStr[ 8 ], 9 )
@ tTop + 9, tLft + 1 prompt "9)  " + padr( gaMonthStr[ 9 ], 9 )
@ tTop + 10, tLft + 1 prompt "A)  " + padr( gaMonthStr[ 10 ], 9 )
@ tTop + 11, tLft + 1 prompt "B)  " + padr( gaMonthStr[ 11 ], 9 )
@ tTop + 12, tLft + 1 prompt "C)  " + padr( gaMonthStr[ 12 ], 9 )
dispend()
menu to nMonth
setcolor( coColr )
restscreen( tTop, tLft, tTop + 13, tLft + 15, sWin )
return iif( empty( nMonth ), 1, nMonth )
/**************************************************************************
*  GetYear( nDefaultYear )                                                *
*       Pop - Up Alert() for Year  selection.  Returns Selected Year.     *
**************************************************************************/
static function GetYear( nDefaultYear, nTop, nLft, cColor )

local nYear    := nDefaultYear
local sWin     := ""
local tTop     := 10
local tLft     := 50
local oGetList := GetList
// Establish Calendar box coordinates
tTop    := iif( nTop == NIL, 0, iif( nTop > maxrow() - 2, maxrow() - 2, nTop ) )
tLft    := iif( nLft == NIL, 0, iif( nLft > maxcol() - 19, maxcol() - 19, nLft ) )
GetList := {}       // Save old GetList, Reset
sWin    := savescreen( tTop, tLft, tTop + 2, tLft + 18 )
DISPWIN( tTop, tLft, tTop + 2, tLft + 18, cColor )
@ tTop + 0, tLft + 3 say " SELECT YEAR " color cColor                        
@ tTop + 1, tLft + 1 say "ENTER YEAR "   get nYear    picture "9999" ;       
        valid ( 0100 <= nYear .and. nYear <= 2999 ) color cColor
read
restscreen( tTop, tLft, tTop + 2, tLft + 18, sWin )
GetList := oGetList                     // Restore prior GetList
return iif( empty( nYear ), 1992, nYear )
//
static func HELPSCR()

local xScreen   := savescreen( 00, 00, 24, 79 )
local xColor    := setcolor( boxcolor() )
local xPrompLen := 0
local xTemp     := 0
local mAxKeys   := 0
local mAxLen    := 0
local xRow      := 03
local aHelpKeys := { "Home/^Home: 1st day of the current month/year", ;
                     "End/^End  : 1st day of the current month/year", ;
                     padr( chr( 24 ) + "/" + chr( 25 ), 10 ) + ": Up/Down a week", ;
                     padr( chr( 27 ) + "/" + chr( 26 ), 10 ) + ": Left/Right a date", ;
                     "PgUp      : Previous month", "^PgUp     : Previous year", ;
                     "PgDn      : Next month", "^PgDn     : Next year", ;
                     "Alt_Y     : Ask for a year", "Alt_M     : Ask for a month ", ;
                     "Space     : Return a blank date", "Enter     : Select the current date", ;
                     "Esc       : Abort" }
xPrompLen := len( aHelpKeys )
xTemp     := mAxDesc := mAxKeys := mAxLen := 0
aeval( aHelpKeys, { || xTemp ++, mAxKeys := max( mAxKeys, len( aHelpKeys[ xTemp ] ) ) } )
xTemp  := 0
mAxLen := mAxKeys + 2
aeval( aHelpKeys, { || xTemp ++, ;
                    aHelpKeys[ xTemp ] := padr( aHelpKeys[ xTemp ], mAxKeys ) } )
xTemp := 0
//
makebox( 02, 02, 03 + len( aHelpKeys ), 03 + mAxLen )
@ 02, 09 say[ Help keys for Calendar ]         
//
xTemp := 0
for xTemp := 1 to xPrompLen
   @ xRow, 04 say aHelpKeys[ xTemp ]         
   xRow ++
next
inkey( 100 )
restscreen( 00, 00, 24, 79, xScreen )
setcolor( xColor )
return ( NIL )      // HELPSCR()
//====================================

*+ EOF: CALENDAR.PRG
