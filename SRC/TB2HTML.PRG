// File......: TB2HTML.PRG
// Author....: Jovan Bulajic
// E-mail....: bulaja@sezampro.yu
// Version...: 1.0, 30/Apr/97
//
// Generates HTML tables (documents) from TBrowse objects
//
// SYNTAX :
//    TB2Html( <oTBrowse>, <cHtmlFile>, [<cTitle>] ) -> lSuccess
//
// Changed by Jasim A Basheer on 26/10/2002
// ===============================================================
// Addn parameter : aRepDetails { report title, title, title... }
// --> by DD (jkb jhn) [I know who.]
// ===============================================================
// Addn parameter : lFile
// --> by Jasim A Basheer
// lFile .T. is passed from F_Read to notify that the tBrowse
// object is for a text file (probably a report).
// So it replaces the normal ----- with HTML lines, keeps the alignment
// as same as the text file itself.
// ================================================================
//

#include "fileio.ch"
#define     CR          Chr(13)
#define     LF          Chr(10)
#define     CRLF        CR+LF
#xtranslate FWriteLn (<xHandle>, <cString>) => ;
fwrite( < xHandle >, < cString > + CRLF )
/*
Here are the static variables that keeps basic configuration -
font colors and background image. If you have your set of prefered
colors you may change this variables here, or (maybe better) add
another function e.g. SetTB2Html (<bgColor>, <textColor>, <bgImage>)
to change them. Color codes are in standard RGB form.
*/
static cSetClrBg   := "#FFFFC0"         // BACKGROUND COLOR
static cSetClrTab  := "#FFFF80"         // TABLE BACKGROUND
static cSetClrText := "#0000FF"         // TEXT COLOR (FOR TABLE AND HEADER TEXT)
static cSetBgImage := ""                // background image (.GIF picture)
/*
sample colors:
fffffc0 - light yellow
fffff80 - darker yellow
00000ff - ligth blue
fffffff - white
0000000 - black
*/
//*** ---------------------------------------- ****
function TB2Html( oTB, cHtmlFile, cTitle, aRepDetails, lFile )

local xHtml
local i
local oCol
local nTemp
local uColData
local cAlign
local cCell
//
// argument checking
if valtype( oTB ) != "O"
   return .f.
endif
if empty( cHtmlFile )
   cHtmlFile := RepPath+"TB2HTML.HTM"
else
   cHtmlFile := RepPath+cHtmlFile
endif
// creating new HTML (.HTM) file
xHtml := fcreate( cHtmlFile, FC_NORMAL )
if ferror() != 0
   return .f.
endif
if cTitle = NIL
   cTitle := eaTitle
endif
if lFile = NIL
   lFile := .f.
endif
// HTML header
fwrite( xHtml, '<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.0 TRANSITIONAL//EN">' + CRLF )
fwrite( xHtml, "<HTML>" + CRLF )
fwrite( xHtml, "<HEAD>" + CRLF )
fwrite( xHtml, "<TITLE> " + cTitle + " </TITLE>" + CRLF )
fwrite( xHtml, "</HEAD>" + CRLF )
//
// setting colors - note than we are setting only background (BGCOLOR)
// and text (TEXT) color, not the link colors (LINK/VLINK/ALINK)
fwrite( xHtml, '<BODY BGCOLOR="' + cSetClrBg + '"' )
fwrite( xHtml, ' TEXT="' + cSetClrText + '"' )
if !empty( cSetBgImage )
   // add backround image, if you specified one
   fwrite( xHtml, ' background="' + cSetBgImage + '"' )
endif
fwrite( xHtml, '>' + CRLF )
// all centered (including table) from here
fwrite( xHtml, '<CENTER>' + CRLF )
// Main heading is the company name
fwrite( xHtml, '<H2>' + COMP_ADD + '</H2>' + CRLF )

// The following is by D.Device (jhn jkb)
if !empty( aRepDetails )
   i := 0
   for i := 1 to len( aRepDetails )
      fwrite( xHtml, '<H4>' + aRepDetails[ i ] + '</H4>' )
   next
   fwrite( xHtml, CRLF )
endif
//
// Define table display format (border and cell look)
// and structure (number of columns)
if !lFile
   fwrite( xHtml, '<TABLE ' )           // don't delete space chars from end
   fwrite( xHtml, 'BGCOLOR="' + cSetClrTab + '"' )
   fwrite( xHtml, 'BORDER=2 ' )
   fwrite( xHtml, 'FRAME=ALL ' )
   fwrite( xHtml, 'CellPadding=4 ' )
   fwrite( xHtml, 'CellSpacing=2 ' )
   fwrite( xHtml, 'COLS=' + alltrim( str( oTB:ColCount ) ) )
   fwrite( xHtml, '>' + CRLF )
endif
//
/* write table title (in bold face)
if ! Empty(cTitle)
    FWrite (xHtml, '<CAPTION ALIGN=TOP><B>' + cTitle + '</B></CAPTION>')
    FWrite (xHtml, CRLF)
endif
*/
if !lFile
   // Output column headers
   fwrite( xHtml, "<TR>" )
   i := 0
   for i := 1 to oTB:ColCount
      oCol  := oTB:GetColumn( i )
      cCell := oCol:Heading
      // For multi-line headings (those with semicolons in
      // header string) we are adding line break
      cCell := strtran( cCell, ";", "<BR>" )
      fwrite( xHtml, "<TH COLSPAN=1 VALIGN=BOTTOM>" + cCell )
   next
   fwrite( xHtml, "</TH>" + CRLF )
   // here comes the main loop which generate the table body
   fwrite( xHtml, '<TBODY>' + CRLF )
else
   fwrite( xHtml, "<PRE> " + '<font face="Courier New" size="3">' + CRLF)
endif

eval( oTB:goTopBlock )                  // start from the top
do while .t.
   if ! lFile
     fwrite( xHtml, "<TR>" )              // new table row
   endif
   for i := 1 to oTB:ColCount
      oCol     := oTB:GetColumn( i )
      if !lFile
         uColData := eval( oCol:Block )    // column data (of yet unknown type)
         do case
         case valtype( uColData ) == "C"                    // characters
            if empty( uColData )
               // if empty, display non-breaking space (&nbsp)
               // to prevent displaying "hole" in table
               cCell := "&nbsp"
            else
               cCell := uColData
            endif
            // text fields are left aligned
            cAlign := "<TD Align=Left>"
            // numbers
         case valtype( uColData ) == "N"
            if !empty( oCol:picture )
               // display numbers according to column picture
               cCell := transform( uColData, oCol:picture )
            else
               cCell := str( uColData )
            endif
            if empty( cCell )
               cCell := "&nbsp"         // non-breaking space
            endif
            cAlign := "<TD Align=Right>"
            /*
            Sometimes you may prefer aligning cell contents
            to specific character (e.g. decimal point/comma).
            In that cases, you can use something like this:
            if "," $ cCell
                cAlign := "<TD Align=Char Char=,>"
            endif
            */
            // logicals
         case valtype( uColData ) == "L"
            cCell := if( uColData, "Yes", "No" )
            // NOTE: if you prefer T/F style, change above line to
            //     cCell := if (uColData, "T", "F")
            cAlign := "<TD ALIGN=CENTER>"
            // dates
         case valtype( uColData ) == "D"
            if empty( uColData )        // empty dates
               cCell := "&nbsp"
            else
               cCell := dtoc( uColData )
            endif
            cAlign := "<TD ALIGN=CENTER>"
         otherwise
            cCell  := "error"
            cAlign := "<TD ALIGN=CENTER>"
         endcase
         fwrite( xHtml, cAlign + cCell + "</TD>" )          // write cell
      else
         cCell  := jProcess( eval(oCol:cargo) )
         *fwrite( xHtml, cCell + "<BR>"+ CRLF )   // write cell
         fwrite( xHtml, cCell + CRLF )   // write cell
      endif
      //If (valtype(&(oCol:cargo))=="B") .and. eval(&(oCol:cargo))
      //    FWrite (xHtml, cAlign + "<B>"+cCell+"</B>"+"</TD>")  // write cell
      //Else
      //Endif
   next
   if !lFile
      fwrite( xHtml, "</TR>" + CRLF )   // end of row
   endif
   nTemp := eval( oTB:SkipBlock, 1 )
   if nTemp != 1    // it's the end, so we are getting out
      exit
   endif
enddo               // main loop
eval( oTB:goTopBlock )                  // set TBrowse back to top
// writing HTML tail
if !lFile
   FWriteLn( xHtml, "</TABLE>" )
   FWriteLn( xHtml, "</CENTER>" )
else
   fwrite( xHtml, "</PRE> " + '</FONT>' + CRLF)
endif
FWriteLn( xHtml, "</BODY>" )
FWriteLn( xHtml, "</HTML>" )
fclose( xHtml )
run( "START " + cHtmlFile )
return .T.
//--------------------------
static function jProcess(uString)
uString := strtran( uString,"&","&amp;" )
uString := strtran( uString," ","&nbsp;" )
return uString
//---------------------
*+ EOF: TB2HTML.PRG
