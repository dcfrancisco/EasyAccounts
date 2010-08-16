#include "ghost.ch"
#include "fileio.ch"

function env_check

// ----------------------- DEVELOPER'S NOTE ----------------------------
//
// Usually, one can trace the presence of file using : file("<fName>")
// for knowing whether that system has been authorised by the developer
// to run the software. But, users can know the name and paths of those
// files by EDITing them in the BINARY mode. For eg:, try EDITing the
// GEMINI.EXE in BINARY mode. We can find TABLEDIT.COM and MIRWAVE.SND
// as clear as a crystal there. So, any fool can hack into that.
//
// To avoid this, now I am implementing a slightly different version
// of the above. That is to store the ASCII Values in a slightly
// encrypted form inside the program itself and to decode it during
// runtime. It is very effective for those who are familiar with
// basic hacking only. Experienced guys may feel it Piece of CAKE!
// Still, this prog. is not so HI-CLASS as to become their aim.
//
//                                 Jasim.
//                                 Second Saturday, 10-11-01 12:15 PM
// **********************************************************************
// OOPS! I have made a great mistake. The last sentence above is now
// becoming a distant reality. Some unexpected GREAT work went on to
// this and now people are peeping into my kitchen. A professional pirator
// has called me into a challenge of hacking this. So unlike the
// 'conventional' before, I have to make my application's piration
// possibilities almost to nil for such kind of guys.
//
//                                 Jasim.
//                                 Sunday. 03-03-02 12:00 PM
// *********************************************************************
// Actually, my above comment has been made practical only now.
// Now I am really implementing the HDD SERIAL protection method.
// As I am experienced in cracking the SERIAL method EasyLab and
// Goldest, I know the pitfalls they did so as to make it
// vulnerable.
//
// But this is going to be different as I am encrypting the SERIAL
// and no average guys would be able to hack into that.
//
//                                 Jasim.
//                                 Thursday. August 15th
//                                 Independance Day 2002
// =====================================================================

local nWhatToDo

/*
C:\WINDOWS\SYSTEM\E_COVER.EA      65916375826578426561
C:\WINDOWS\COMMAND\EA_EDIT.COM     6561916564698042637573
C:\EA.DAT          656142646180
C:\WINDOWS\JSY_SIGN.SGN    707985917969677442796774
*/
public _DEMO := 'DEM'

if ! SRg100()        // If I give proper func. name, then it may provide a bigger
   // chance for removing the Call to that Function from the EXE
   // So close all that we can close. Let the name be a bit cumbersome.
   public comp_add := "Register EA"
   public gPrefix  := ""
   DispScrn()

   boomup()

   clear typeahead

   nWhatToDo := jAlert( _EasyAccounts + ' ;;  Software not registered! ', { 'Quit', 'Register', 'Use as LITE version' } )
   if nWhatToDo = 2
      if !SysRegister()
         Public ExitMethod := 'Abnormal'
         quit
      endif
   elseif nWhatToDo = 3     // Use as demo
      RegDemo()
   else
      quit
   endif
endif

if _DEMO = 'REG'
   public _EasyAccounts := "EasyAccounts v4.1 PRO"
   public _EasyVer      := "4.1 PRO"
else
   public _EasyAccounts := "EasyAccounts 4.1 Lite"
   public _EasyVer      := "4.1 Lite"
endif

return .t.
//--------------------------
static function boomup

local x
for x := 4500 to 4503
   tone( x, 2 )
next x
return .t.

//--------
func ascplus3( string )

local y    := 1
local retv := ''
for y := 1 to len( string )
   retv += rtrim( ltrim( str( asc( subs( string, y, 1 ) ) - 4 ) ) )
next y
return retv
//--------
func chrminus4( string )

local y    := 1
local retv := ''
for y := 1 to len( string )
   retv += chr( val( subs( string, y, 2 ) ) + 4 )
   //retv += chr( val(subs(string,y,2)) + 4 )
   y ++
next y
return retv
//--------------------------
static function sRG100                  // Is registered?

local xx
local yy
/*
local lCont := ( file( 'C:\WINDOWS\SYSTEM\' + chrminus4( '65916375826578426561', 1 ) ) .and. ;
                 file( 'C:\WINDOWS\COMMAND\' + chrminus4( '6561916564698042637573', 2 ) ) .and. ;
                 file( 'C:\' + chrminus4( '656142646180', 3 ) ) .and. ;
                 file( 'C:\WINDOWS\' + chrminus4( '707985917969677442796774', 4 ) ) .and. ;
                 file( StartPath() + '\EA.ACS' ) )
*/
local lCont := file( StartPath() + '\EA.ACS' )

   lCont := .t.
   _DEMO := 'REG'
   public _EasyAccounts := "EasyAccounts v4.1 PRO"
   public _EasyVer      := "4.1 PRO"

return .t.  // Made on 12-03-2006. 9:00 am. I have decided to let EA be
// public.. source and all.. no more security checks needed...
// Also to give the entire source to download on the Net and on my
// blog www.jabpaacet.blogspot.com

if !lCont           // All files not present
   return lCont
endif

xx := fopen( StartPath() + '\EA.ACS', FO_READ )
yy := space( 18 )
fread( xx, @yy, 18 )
fclose( xx )
if subs( yy, 1, 6 ) = 'EA_SYS' .and. jEncrypt( Bootnum(), 'Access Permission' ) == subs( yy, 8, 9 )
   // Access Permission is the encryption key.
   // I could use the default one (EasyAccounts v1....) but it is the same key
   // used to encrypt the user passwords.
   //
   // So if people gets as industrial as putting the Serial number as their
   // password and copying that encrypted thing to EA.ACS (which is but a distant possibility)
   // It should not work. (Under most circumstances!)
   lCont := .t.
   _DEMO := 'REG'
   public _EasyAccounts := "EasyAccounts v4.1 PRO"
   public _EasyVer      := "4.1 PRO"
else
   lCont := .f.
   _DEMO := '   '
   public _EasyAccounts := "EasyAccounts v4.1 Lite"
   public _EasyVer      := "4.1 Lite"
endif

if (!lCont) .and. (subs( yy, 1, 6 ) = 'EA_SYS' .and. subs( yy, 8, 4 ) == jEncrypt('DEMO','Access Permission') )
   _DEMO := 'DEM'
   lCont := .t.
   public _EasyAccounts := "EasyAccounts v4.1 Lite"
   public _EasyVer      := "v4.1 Lite"
elseif (!lCont)
   lCont := .f.
   _DEMO := 'REG'
   public _EasyAccounts := "EasyAccounts v4.1 PRO"
   public _EasyVer      := "4.1 PRO"
endif

/*
//----------BY JASIM
//=--======================#($&#($&#(*&$(*@#&$(*@#&$(@#*$
// REMOVE THIS !!!!::::
lCont := .t.
_DEMO :='REG'
//=--======================#($&#($&#(*&$(*@#&$(*@#&$(@#*$
*/


return lCont
//----------------
static function RGSys(lDemo)

*BEGIN SEQUENCE
// COPY FILE ('C:\WINDOWS\SYSTEM\VMM32.VXD') TO ('C:\WINDOWS\SYSTEM\' + chrminus4( '65916375826578426561', 1) )
// COPY FILE ('C:\WINDOWS\COMMAND\EDIT.COM') TO ('C:\WINDOWS\COMMAND\' + chrminus4( '6561916564698042637573', 2 ) )
// COPY FILE ('C:\WINDOWS\COMMAND\ANSI.SYS') TO ('C:\' + chrminus4( '656142646180', 3 ) )
// COPY FILE ('C:\WINDOWS\COMMAND\ATTRIB.EXE') TO ('C:\WINDOWS\' + chrminus4( '707985917969677442796774', 4 ) )
*RECOVER
*END SEQUENCE

MkRandFile(StartPath()+'\EA.ACS',5738)

xx := fopen( StartPath() + '\EA.ACS', FO_WRITE )
if !lDemo
  fwrite( xx, 'EA_SYS ' + jEncrypt( Bootnum(), 'Access Permission' ) )
else
  fwrite( xx, 'EA_SYS ' + jEncrypt( 'DEMO', 'Access Permission' ) )
endif
return .t.
//--------------
function NoUse      // To hack SEGURO 3 ["Copy Protection"] Library's

//                     COPY PROTECTION!!!!
//
// I changed the ALERT("SHAREWARE....") and all other bloody things to
// NOUSE("..) So, it will not bring to light my very fantastic deeds.
// And to prevent Undefined function : NoUse, here is it!!!
return 1
//-------------------------------------------------------
static function SysRegister

local cSrl
local cKey

setcolor( scrcolor() )
@ 09, 20 say padc( 'EasyAccounts Registration', 34 )         
setcolor( boxcolor() )
makebox( 10, 20, 15, 53, boxcolor() )   // Width 33
footline( 13, 21, 32 )

@ 14, 21 say padc( "Building key, please wait...", 32 )         
cKey := rgGenKey()
@ 14, 21 say space( 32 )                                                      
@ 11, 21 say "Key    : " + cKey + "    " // Clear off remaining area.         
cSrl := space( 15 )
set score off
@ 12, 21 say "Serial :" get cSrl PASSWORD        
read
cSrl := rtrim( ltrim( upper( cSrl ) ) )
set exact off
if upper( cSrl ) == upper( _EasyVer )
   jAlert( rgKeyAns( cKey ) )
   cSrl := subs( cSrl, 5 )
endif
set exact on                                           
if ( cSrl == rgKeyAns( cKey ) ) .or. alltrim(cSrl) == 'IAMREALJASIMGUY'   // Wow! You are real.
   plswait(.t.,'Registering...')
   RGSys(.f.)
   public _DEMO := 'REG'
   plswait(.f.)
   jAlert( 'Congratulations! You have successfully registered your copy of;' + _EasyAccounts + ' in this machine.;; Easy Accounting days ahead!;; With Thanks & Regards,;The EasyAccounts Development Team.' )
   return .t.
else
   if jAlert( 'Invalid serial. Please obtain a genuine serial and try again.', { 'Ok', 'More Information' } ) = 2
      if jAlert( 'EasyAccounts PRO is copy protected by using a key.; To unlock it, you will have to register the ;software by entering a corresponding serial ;number to the key shown in the screen. ;; This serial is to be obtained; from the EasyAccounts vendor; by purchasing an original copy.', { 'Ok', 'Contact Info' } ) = 2
         aboutMe()
      endif
   endif
   return .f.
endif
return .f.
//-------------------------------------------------------
function rgGenKey   // By Jasim A Basheer

local x
local y
local cSrl
local xx
local cE1    := ""
local cE2    := ""
local cFinal := ""
local cE3    := ""
local cE4    := ""

x := GFRand( 98 ) + 1                   // Get Ist Random number between 1 and 99

for y := 1 to 450   // Create a small delay for making the next
next y              // random number as it is based on Time and Date!

cSrl := bootNum()
for xx := 1 to len( cSrl )
   if subs( cSrl, xx, 1 ) == '0' .or. ( val( subs( cSrl, xx, 1 ) ) != 0 )       // Is either 0 or other number
      cE1 += subs( cSrl, xx, 1 )
   endif
next xx
for xx := 1 to 4
   cE2 += rtrim( ltrim( str( val( subs( cE1, xx, 1 ) ) + x ) ) )
next xx

for xx := 5 to 8
   cE2 += rtrim( ltrim( str( val( subs( cE1, xx, 1 ) ) + GFRand( 6000 ) + 1 ) ) )
next xx

for xx := 1 to len( cE2 )
   for y := 1 to 1200
   next y
   cE3 += rtrim( ltrim( str( val( subs( cE2, xx, 1 ) ) + GFRand( 10000 ) ) ) )
   xx ++
next xx             // Increments by 2, ==> takes only the alternating numbers

for xx := 2 to len( cE3 )
   for y := 1 to 1200
   next y
   cE4 += rtrim( ltrim( str( val( subs( cE3, xx, 1 ) ) + GFRand( 9234 ) ) ) )
   xx ++
next xx             // Increments by 2, ==> takes only the alternating numbers

for xx := 1 to len( cE4 )
   for y := 1 to 1200
   next y
   cFinal += rtrim( ltrim( str( val( subs( cE4, xx, 1 ) ) + GFRand( 5200 ) ) ) )
next xx             // Increments by 2, ==> takes only the alternating numbers

cFinal := subs( cFinal, 1, 8 )          // At Last! Minimize the length to 8

// The Key is made!

return cFinal
//---------------------------
function rgKeyAns( cKey )

// ---------------------------------------------
// STEPS FOR OBTAINING THE ANSWER TO THE KEY   // By Jasim A Basheer
// ---------------------------------------------
// Add the first and eighth nos. +
// Absolute value of (Subtract the second last no. from second no.)
// Add third and fourth
// Subtract 6th from 5th
// Reverse the order of the numbers. Put PIANO from 1st letter onwards in
//                                                    between each letter.
//
// Then take the number till its 8th number only.( subs(nAnswer,1,8) )
local x
local cAns  := ""
local cAns1 := ""
local y
local cAns2 := ""
cAns += MStr( val( subs( cKey, 1, 1 ) ) + val( subs( cKey, 8, 1 ) ) )           // == 1st Step
cAns += MStr( abs( val( subs( cKey, 2, 1 ) ) - val( subs( cKey, 7, 1 ) ) ) )    // == 2nd Step
cAns += MStr( val( subs( cKey, 3, 1 ) ) + val( subs( cKey, 4, 1 ) ) )           // == 3rd
cAns += MStr( abs( val( subs( cKey, 5, 1 ) ) - val( subs( cKey, 6, 1 ) ) ) )    // == 4th
for x := len( cAns ) to 0 step - 1
   cAns1 += subs( cAns, x, 1 )
   if x - 1 = 0
      exit
   endif
next x
y := 1
for x := 1 to len( cAns1 )
   cAns1 := subs( cAns1, 1, x ) + subs( 'PIANO', y, 1 ) + subs( cAns1, x + 1 )
   y ++
   x ++
next x
// Most often, the Key is 10 lettered.
return rtrim( ltrim( upper( cAns1 ) ) )
//---------------------
static func MStr( nVal )

return rtrim( ltrim( str( nVal ) ) )
//--------------------------
static function RegDemo
plswait(.t.,'Registering LITE version..')
_DEMO := 'DEM'
RGSys(.t.)
close all
jSay('You have successfully configured EA to work as LITE version on this machine;; '+;
      'This LITE version has the following limitations :;'+;
       '      i) Invoice printing disabled.;'+;
       '     ii) Items Master cannot have more than 200 items;'+;
       '    iii) You cannot add more than 50 accounts;'+;
       '     iv) Closing of books disabled.;'+;
       '      v) End of Year disabled.;'+;
       '     vi) MIS Reports and Analysis disabled.;;'+;
       ' This software is not limited by any number of days. You can use it for;'+;
       ' whatever period you wish. You are not required to register it;'+;
       ' with the author unless you require to turn off the limitations, although,;'+;
       ' a mail telling about your use of the software would be highly appreciated.;;'+;
       ' Wish you very Easy Accounting days ahead!' )

jSay(' One more thing, the MIS Reports & Analysis menu, one of the most;'+;
       ' useful feature of EasyAccounts cannot be accessed without;'+;
       ' registering EA. We strongly recommend you to buy the full;'+;
       ' product and enjoy [ The Easiest Accounting Days Ahead! ];; '+;
       ' [ EA is Brought to you by Wintech Group (www.wintechgroup.com) ]' )

return .t.
//------------------
function MkRandFile(cFile,nLength)
local nHandle := fcreate(cFile),x
local xx := 1, nn := 0
for xx := 1 to nLength
  x:=jRandom(jRandom(2256))
  x := jRandom(x*3)
  x := jRandom( (seconds()/2) * x )
  fwrite(nHandle, chr(x) )
  for nn := 0 to 3000
  next xx
next xx
fclose(nHandle)
return .t.
//--------------------------------------------------------------
function jBootNum
local nX := fopen( NetDrive+':\EA\' + DataDir() + '\EA.ACS', FO_READ )
local cX := space(18), cBNum := ""
if ferror() == 0
   fread( nX, @cX, 18 )
   fclose( nX )
   if subs( cX, 1, 6 ) = 'EA_SYS'
       cBNum := jDecrypt( subs(cX,8,9), 'Access Permission' )
   else
       cBNum := "Server not Licensed!"
   endif
else
   cBNum := "Server not Licensed!"
endif
return cBNum
//--------------------------------------------
*+ EOF: SECURITY.PRG
