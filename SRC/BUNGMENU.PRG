#include "std.ch"
#include "inkey.ch"
#include "box.ch"

#ifndef K_LBUTTONDOWN
#define K_LBUTTONDOWN   1002   //   mouse left key press
#define K_RBUTTONDOWN   1004   //   mouse right key press
#endif
#define K_MOUSELEFT K_LBUTTONDOWN
#define K_MOUSERIGHT K_RBUTTONDOWN

#define   MENUSIZE         27
#define   MENUBAR          1
#define   MC_MBOX          2
#define   MC_MSEL          3
#define   MC_MUNS          4
#define   MC_MINA          5
#define   MC_MSELTRIG      6
#define   MC_MUNSTRIG      7
#define   MC_FRAMES        8
#define   MENUCURRTOP      9
#define   MENUDROPPED      10
#define   MENUFIRSTLTR     11
#define   MENUHIDEPATH     12
#define   MENUMOUSEHOTS    13
#define   MENUKEYHOTS      14
#define   MENUEXITREQ      15
#define   MENUTOP          16
#define   MENULEFT         17
#define   MENURIGHT        18
#define   MENUCROSS        19
#define   MENUCHECKEXIT    20
#define   MENUIMMEDIATE    21
#define   MENUNEWTOP       22
#define   MENUHIDELEVEL    23
#define   MENUHIDDEN       24
#define   MENUSHADOWPOS    25
#define   MENUSHADOWATT    26
#define   MENUHANDLEALT    27

#define   BOXSIZE          15
#define   BOXLEVEL         1
#define   BOXTOP           2
#define   BOXLEFT          3
#define   BOXBOTTOM        4
#define   BOXRIGHT         5
#define   BOXPROMPTS       6
#define   BOXFIRST         7
#define   BOXDRAWBLOCK     8
#define   BOXRESTBLOCK     9
#define   BOXUNDER         10

#define   PROMPTSIZE       15
#define   PROMPTLEVEL      1
#define   PROMPTTOP        2
#define   PROMPTLEFT       3
#define   PROMPTBOTTOM     4
#define   PROMPTRIGHT      5
#define   PROMPTTEXT       6
#define   PROMPTTRIGGER    7
#define   PROMPTTRIGPOS    8
#define   PROMPTTYPE       9
#define   PROMPTDISPBLOCK  10
#define   PROMPTACTBLOCK   11
#define   PROMPTEXECBLOCK  12
#define   PROMPTDROPBOX    13

#define   TYPEACTION       1
#define   TYPEDROPDOWN     2
#define   TYPECROSSBAR     3

#define   EVENTMOUSER      K_RBUTTONDOWN
#define   EVENTMOUSEL      K_LBUTTONDOWN

#define   MOUSEHOTTOP        1
#define   MOUSEHOTLEFT       2
#define   MOUSEHOTBOTTOM     3
#define   MOUSEHOTRIGHT      4
#define   MOUSEHOTBLOCK      5

#define   KEYHOTVALUE        1
#define   KEYHOTBLOCK        2

static nBungLev := 0
static aBungMen := {}
static aLastOpt := nil

//-----------------------------------------------------------
function BUNGSTART

nBungLev := 0
aBungMen := {}
aLastOpt := nil
return nil
//-----------------------------------------------------------
function BUNGOPTION( cPrompt, expAction, bActive )

local nLevel := nBungLev
local aNow   := aBungMen
local i
expAction := iif( expAction == nil, {}, expAction )
for i := 1 to nLevel
   aNow := atail( aNow )
   aNow := aNow[ 2 ]
next
if valtype( aNow ) <> "A"
   aNow := {}
endif
aadd( aNow, { cPrompt, expAction, bActive, nil, nil } )
aLastOpt := atail( aNow )
return nil
//-----------------------------------------------------------
function BUNGEND()

local aMenu := aclone( aBungMen )
aBungMen := {}
nBungLev := 0
aLastOpt := nil
return aMenu
//-----------------------------------------------------------
function bungdrop( nDown, nOver )

aLastOpt[ 4 ] := nDown
aLastOpt[ 5 ] := nOver
nBungLev ++
return nil
//-----------------------------------------------------------
function bungundrop

nBungLev --
return nil
//----------------------------------------------------------
function BUNGEE( nTop, nLeft, nRight, aInPrompts, aColumns, ;
                 aColors, aMouseHots, aKeyHots, bCheckExit, ;
                 lImmediate, lDropped, nHideLevel, nShadowpos, ;
                 nShadowAtt, lHandleAlt )

local aMenu

lDropped := .t.

aMenu := MENUDEF( nTop, nLeft, nRight, aInPrompts, aColumns, ;
                  aColors, aMouseHots, aKeyHots, bCheckExit, ;
                  lImmediate, lDropped, nHideLevel, nShadowPos, ;
                  nShadowAtt, lHandleAlt )
logmenu( aMenu )
MHANDLER( aMenu[ MENUBAR ], aMenu )
logmenu( "" )
return nil
//---------------------------------------------------------
static function MHANDLER( aCurrentBox, aMenu )

local nCount
local nEventCode
local cEventCode
local nNewTopPosit
local nNewBoxPosit
local nMouseR
local nMouseC
local nMouseHotPress
local nKeyHotPress
local nCursor        := setcursor( 0 )

local aTopMenuBar     := aMenu[ MENUBAR ]
local aCurrentPrompts := aCurrentBox[ BOXPROMPTS ]

// find first active option
local nCurrentOption := ascan( aCurrentPrompts, ;
                               { | a | eval( a[ PROMPTACTBLOCK ] ) } )
local nNumberofPrompts := len( aCurrentPrompts )
local lAnyActive       := nCurrentOption > 0
local lDone            := .f.
local aTopOptions      := aMenu[ MENUBAR, BOXPROMPTS ]
local cTopLtrs         := aMenu[ MENUFIRSTLTR ]
local nTopOptions      := len( aMenu[ MENUBAR, BOXPROMPTS ] )
local lActionReq       := .f.
local lInTopBar        := ( aCurrentBox == aTopMenuBar )
local lDroptoNextLevel := .f.
local lImmediate       := aMenu[ MENUIMMEDIATE ]
local aAltKeys         := ;
        { K_ALT_A, K_ALT_B, K_ALT_C, K_ALT_D, K_ALT_E, ;
        K_ALT_F, K_ALT_G, K_ALT_H, K_ALT_I, K_ALT_J, ;
        K_ALT_K, K_ALT_L, K_ALT_M, K_ALT_N, K_ALT_O, ;
        K_ALT_P, K_ALT_Q, K_ALT_R, K_ALT_S, K_ALT_T, ;
        K_ALT_U, K_ALT_V, K_ALT_W, K_ALT_X, K_ALT_Y, K_ALT_Z }
local nAltFound

if ( aCurrentBox[ BOXLEVEL ] == 0 )
   TOP_BAR_POSITION( 1, aMenu )
endif

PAINTMENUBOX( aCurrentBox )

aadd( aMenu[ MENUHIDEPATH ], { aCurrentBox, nCurrentOption } )

while !lDone .and. !aMenu[ MENUEXITREQ ] .and. !aMenu[ MENUNEWTOP ]
   lActionReq := .f.

   if lInTopBar
      nCurrentOption := TOP_BAR_POSITION( nil, aMenu )
      // reset menu hide path to top bar only
      aMenu[ MENUHIDEPATH ] := { { aCurrentBox, nCurrentOption } }
   else
      // Set current Menuhidepath option to new box/option
      aMenu[ MENUHIDEPATH, len( aMenu[ MENUHIDEPATH ] ) ] := ;
              { aCurrentBox, nCurrentOption }
   endif

   if nCurrentOption > 0
      //----display current option selected
      eval( aCurrentPrompts[ nCurrentOption, PROMPTDISPBLOCK ], .t., ;
            eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] ) )

   endif

   nMouseR := 0
   nMouseC := 0
   // if in top bar, and menu has dropped, and the current
   // top bar option has a dropbox, and the dropbox has
   // some active prompts
   if lInTopBar .and. aMenu[ MENUDROPPED ] .and. ;
              ! empty( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX ] ) .and. ;
              ascan( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX, BOXPROMPTS ], ;
              { | a | eval( a[ PROMPTACTBLOCK ] ) } ) > 0

      //-- call this same proc recursively to handle the
      //-- dropdown box attached to the current prompt/option
      nEventCode := ;
              MHANDLER( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX ], aMenu )
      nMouseR := rat_eqmrow()
      nMouseC := rat_eqmcol()

   elseif lDroptoNextLevel
      nEventCode := ;
              MHANDLER( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX ], aMenu )
      nMouseR          := rat_eqmrow()
      nMouseC          := rat_eqmcol()
      lDroptoNextLevel := .f.
      //-- refresh the current box
      MREFBOX( aCurrentBox )

   else
      // otherwise, just sit at the top bar prompt and
      // wait for orders...
      nEventCode := RAT_EVENT( 0, .f., .f., @nMouseR, @nMouseC )
   endif
   if lInTopBar
      aMenu[ MENUNEWTOP ] := .f.
   endif
   if nCurrentOption > 0
      // display current option unselected
      eval( aCurrentPrompts[ nCurrentOption, PROMPTDISPBLOCK ], .f., ;
            eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] ) )
   endif

   if aMenu[ MENUHANDLEALT ]
      //-- then convert any ALT+key combinations to just the key
      //-- i.e. ALT+A becomes just "A"

      if ( nAltFound := ascan( aAltKeys, nEventCode ) ) > 0

         if setkey( nEventCode ) == nil
            nEventCode := 64 + nAltFound
            //--  64+1 == 65 == character "A"
         endif
      endif
   endif

   if valtype( nEventCode ) = 'C'
      nEventCode := asc( nEventCode )
   elseif !( valtype( nEventCode ) == 'N' )
      return .f.
   endif

   cEventCode := upper( chr( nEventCode ) )

   do case
   case nEventCode == EVENTMOUSEL
      do case
         //-- either top bar or first level of box, and mouse clicked
         //-- on a top bar option (mouseinbox() checks for active status)

      case ( nNewTopPosit := ;
                MOUSEINBOX( aMenu[ MENUBAR ], aTopOptions, nMouseR, nMouseC, .t. ) ) > 0

         //-- if its the same top option than current
         if nNewTopPosit == TOP_BAR_POSITION( nil, aMenu )

            //-- if the option is an ACTION (block) option
            if aTopOptions[ nNewTopPosit, PROMPTTYPE ] == TYPEACTION
               lActionReq := .t.
            elseif !aMenu[ MENUDROPPED ]
               //-- presume there's a dropdown box
               aMenu[ MENUDROPPED ] := .t.
            endif

         else
            //-- its a different top ooption, so set it
            TOP_BAR_POSITION( nNewTopPosit, aMenu )

            //-- if we are in the first drop level, we need to
            //-- exit back on level of recursion and let the
            //-- top bar handler realize that it has changed
            //-- top bar options. It will also see that it has
            //-- already dropped, and so will drop the box
            //-- under that option
            if aCurrentBox[ BOXLEVEL ] > 0
               lDone               := .t.                   // this causes an exit from this level of recursion
               aMenu[ MENUNEWTOP ] := .T.
            endif
            if aTopOptions[ nNewTopPosit, PROMPTTYPE ] == TYPEACTION ;
                       .and. lImmediate
               keyboard chr( K_ENTER )
            endif

         endif
         //-- not in top bar and mouse clicked on a box option
         //-- (mouseinbox() checks for active status)
      case !lInTopBar .and. ;
                 ( nNewBoxPosit := MOUSEINBOX( aCurrentBox, aCurrentPrompts, nMouseR, nMouseC, .f. ) ) > 0

         if nCurrentOption == nNewBoxPosit
            //-- if current position, its an action request
            lActionReq := .t.
         else
            //-- otherwise, just change box position
            nCurrentOption := nNewBoxPosit
            if lImmediate
               keyboard chr( K_ENTER )
            endif
         endif

         //-- maybe a programmer supplied hot mouse block?
      case ( nMouseHotPress := ;
                ascan( aMenu[ MENUMOUSEHOTS ], ;
                { | e | nMouseR >= e[ MOUSEHOTTOP ] .and. ;
                nMouseR <= e[ MOUSEHOTBOTTOM ] .and. ;
                nMouseC >= e[ MOUSEHOTLEFT ] .and. ;
                nMouseC <= e[ MOUSEHOTRIGHT ] } ) ) > 0

         hide_menu( aMenu )
         setcursor( nCursor )
         eval( aMenu[ MENUMOUSEHOTS, nMouseHotPress, MOUSEHOTBLOCK ] )
         setcursor( 0 )
         bungeeshow()

         //-- refresh the current box
         MREFBOX( aCurrentBox )

         //-- check for active option
         if !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
            nCurrentOption := ascan( aCurrentPrompts, ;
                                     { | a | eval( a[ PROMPTACTBLOCK ] ) } )
            if nCurrentOption == 0
               //-- if everything is now inactive, we have to leave
               lDone := .t.
            endif
         endif
      endcase

   case nEventCode == K_LEFT .and. lInTopBar
      nCurrentOption := iif( nCurrentOption == 1, ;
                             nNumberofPrompts, nCurrentOption - 1 )
      while !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := iif( nCurrentOption == 1, ;
                                nNumberofPrompts, nCurrentOption - 1 )
      end
      TOP_BAR_POSITION( nCurrentOption, aMenu )

   case nEventCode == K_LEFT .and. aCurrentBox[ BOXLEVEL ] == 1
      //-- left key, and box level 1, must exit this proc so that
      //-- previous instance of the proc can reset the top bar
      //-- and move to it
      TOP_BAR_POSITION( iif( aMenu[ MENUCURRTOP ] == 1, ;
                        nTopOptions, TOP_BAR_POSITION( nil, aMenu ) - 1 ), aMenu )

      while !eval( aTopOptions[ TOP_BAR_POSITION( nil, aMenu ), PROMPTACTBLOCK ] )
         TOP_BAR_POSITION( iif( aMenu[ MENUCURRTOP ] == 1, ;
                           nTopOptions, TOP_BAR_POSITION( nil, aMenu ) - 1 ), aMenu )
      end
      lDone := .t.

   case nEventCode == K_LEFT .and. aCurrentBox[ BOXLEVEL ] > 1
      //-- left or right key while in a level 2 or greater box, causes
      //-- and exit back to the parent box
      exit

   case nEventCode == K_RIGHT .and. lInTopBar
      nCurrentOption := iif( nCurrentOption == nNumberofPrompts, ;
                             1, nCurrentOption + 1 )
      while !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := iif( nCurrentOption == nNumberofPrompts, ;
                                1, nCurrentOption + 1 )
      end
      TOP_BAR_POSITION( nCurrentOption, aMenu )

   case nEventCode == K_RIGHT .and. aCurrentBox[ BOXLEVEL ] == 1
      //-- right key, and box level 1, must exit this proc so that
      //-- previous instance of the proc can reset the top bar
      //-- and move to it
      TOP_BAR_POSITION( iif( TOP_BAR_POSITION( nil, aMenu ) == nTopOptions, ;
                        1, TOP_BAR_POSITION( nil, aMenu ) + 1 ), aMenu )
      while !eval( aTopOptions[ TOP_BAR_POSITION( nil, aMenu ), PROMPTACTBLOCK ] )
         TOP_BAR_POSITION( iif( TOP_BAR_POSITION( nil, aMenu ) == nTopOptions, ;
                           1, TOP_BAR_POSITION( nil, aMenu ) + 1 ), aMenu )
      end
      lDone := .t.

   case nEventCode == K_RIGHT .and. aCurrentBox[ BOXLEVEL ] > 1
      //-- left or right key while in a level 2 or greater box, causes
      //-- and exit back to the parent box
      exit

   case ( nEventCode == K_ESC .or. nEventCode == EVENTMOUSER ) .and. ;
             aCurrentBox[ BOXLEVEL ] == 0
      //-- escape (or right mouse) while in top bar causes a
      //-- menu exit
      lDone := .t.

   case ( nEventCode == K_ESC .or. nEventCode == EVENTMOUSER ) .and. ;
             aCurrentBox[ BOXLEVEL ] == 1
      //-- escape (or right mouse) while in 1st level box causes
      //-- the menu dropping flag to be set to false, and an
      //-- exit from this level
      aMenu[ MENUDROPPED ] := .f.
      lDone                := .t.

   case ( nEventCode == K_ESC .or. nEventCode == EVENTMOUSER ) .and. ;
             aCurrentBox[ BOXLEVEL ] > 1
      //-- escape (or right mouse) while in > 1st level box causes
      //-- exit from this level
      lDone := .t.

   case nEventCode == K_UP .and. aCurrentBox[ BOXLEVEL ] > 0 .and. lAnyActive
      nCurrentOption := iif( nCurrentOption == 1, ;
                             nNumberofPrompts, nCurrentOption - 1 )
      //-- then check the active blocks to find the first matching,
      //-- moving in reverse
      while !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := iif( nCurrentOption == 1, ;
                                nNumberofPrompts, nCurrentOption - 1 )
      end

   case nEventCode == K_DOWN .and. aCurrentBox[ BOXLEVEL ] > 0 .and. lAnyActive
      nCurrentOption := iif( nCurrentOption == nNumberofPrompts, 1, nCurrentOption + 1 )
      //-- then check the active blocks to find the first matching
      //-- moving forward
      while !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := iif( nCurrentOption == nNumberofPrompts, ;
                                1, nCurrentOption + 1 )
      end

   case nEventCode == K_ENTER .and. aCurrentBox[ BOXLEVEL ] == 0 .and. ;
              aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEACTION
      //-- enter key or mouse click on top option if it is a
      //-- action type
      lActionReq := .t.

   case nEventCode == K_ENTER .and. aCurrentBox[ BOXLEVEL ] == 0 .and. ;
              ! aMenu[ MENUDROPPED ]
      //-- enter key or mouse click on top option if it is a
      //-- dropdown type
      aMenu[ MENUDROPPED ] := .t.

   case nEventCode == K_ENTER .and. aCurrentBox[ BOXLEVEL ] > 0
      lActionReq := .t.

   case setkey( nEventCode ) # nil

      hide_menu( aMenu )
      setcursor( nCursor )

      eval( setkey( nEventCode ), ;
            "BUNGEE", 0, aCurrentPrompts[ nCurrentOption, PROMPTTEXT ] )
      if downclose()
         return .f.
      endif

      if nEventCode == K_F3  // for switching users..
        keyboard chr(K_ESC)+chr(K_ESC)+chr(K_ENTER)
        // for ex. someone was in SUP user, and had the full menu visible
        // some 'tax' checkers came in, and they press F3 and log on
        // to administrator.. so, the previous menu of SUP must go.
        // the first ESC will exit the pull-down and go to the top bar alone
        // next ESC will exit to the company selec. and the ENTER will
        // select the company and come back to the proper ADM's menu..
      endif

      set key K_F2 to changecomp()
      jSetDefault( comp_add )
      cleanup()

      setcursor( 0 )
      bungeeshow()

      //-- refresh the current box
      MREFBOX( aCurrentBox )

      //-- check for active option
      if !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := ascan( aCurrentPrompts, ;
                                  { | a | eval( a[ PROMPTACTBLOCK ] ) } )
         if nCurrentOption == 0
            //-- if everything is now inactive, we have to leave
            lDone := .t.
         endif
      endif

   case aCurrentBox[ BOXLEVEL ] > 0 .and. ;
              ( nNewBoxPosit := at( cEventCode, aCurrentBox[ BOXFIRST ] ) ) > 0
      //-- a check of the key pressed against the current box
      //-- first letters gets a match
      if nCurrentOption == nNewBoxPosit
         //-- if current option, its an action request
         lActionReq := .t.
      else
         //-- otherwise, if it is active, go there
         if eval( aCurrentPrompts[ nNewBoxPosit, PROMPTACTBLOCK ] )
            nCurrentOption := nNewBoxPosit
            if lImmediate
               keyboard chr( K_ENTER )
            endif
         endif
      endif

   case ( nNewTopPosit := at( cEventCode, cTopLtrs ) ) > 0
      //-- a check of the key pressed against the top bar
      //-- first letters gets a match, and we are in either
      //-- the top bar or the primary dropdown level
      if nNewTopPosit == TOP_BAR_POSITION( nil, aMenu )
         //-- current position, menu not dropped, cause it to drop
         if !aMenu[ MENUDROPPED ]
            aMenu[ MENUDROPPED ] := .t.
         endif
         if aCurrentBox[ BOXLEVEL ] == 0 .and. ;
                    aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEACTION
            lActionReq := .t.
         endif
      elseif eval( aTopOptions[ nNewTopPosit, PROMPTACTBLOCK ] )
         //-- different position, change to it
         TOP_BAR_POSITION( nNewTopPosit, aMenu )
         //-- if we are in the 1st level of dropdown, exit
         //-- back to menu bar level to change positions
         if aCurrentBox[ BOXLEVEL ] > 0
            aMenu[ MENUNEWTOP ] := .T.
         endif
         if aTopOptions[ nNewTopPosit, PROMPTTYPE ] == TYPEACTION
            if lImmediate
               keyboard chr( K_ENTER )
            endif
         endif
      endif

   case ( nEventCode == K_ESC .or. nEventCode == EVENTMOUSER ) .and. ;
             aCurrentBox[ BOXLEVEL ] > 1
      //-- esc or right mouse when in > level 1 box, just exit back
      //-- to parent box
      lDone := .t.

   case ( nKeyHotPress := ;
             ascan( aMenu[ MENUKEYHOTS ], { | e | nEventCode == e[ KEYHOTVALUE ] } ) ) > 0
      //-- programmer supplied hotkey, evaluate it

      hide_menu( aMenu )
      setcursor( nCursor )
      eval( aMenu[ MENUKEYHOTS, nKeyHotPress, KEYHOTBLOCK ] )
      setcursor( 0 )

      bungeeshow()

      //-- refresh the current box
      MREFBOX( aCurrentBox )

      //-- check for active option
      if !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := ascan( aCurrentPrompts, ;
                                  { | a | eval( a[ PROMPTACTBLOCK ] ) } )
         if nCurrentOption == 0
            //-- if everything is now inactive, we have to leave
            lDone := .t.
         endif
      endif
   endcase

   //-- now check for an action request
   if lActionReq

      do case
      case aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEACTION .and. ;
                 valtype( aCurrentPrompts[ nCurrentOption, PROMPTEXECBLOCK ] ) == "B"

         hide_menu( aMenu )
         setcursor( nCursor )
         set key K_F2 to
         eval( aCurrentPrompts[ nCurrentOption, PROMPTEXECBLOCK ] )
         if downclose()
            return .f.
         endif
         set key K_F2 to changecomp()
         jSetDefault( comp_add )
         cleanup()
         dispbegin()
         setcursor( 0 )
         bungeeshow()

         //-- refresh the current box
         MREFBOX( aCurrentBox )

         //-- check for active option
         if !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
            nCurrentOption := ascan( aCurrentPrompts, ;
                                     { | a | eval( a[ PROMPTACTBLOCK ] ) } )
            if nCurrentOption == 0
               //-- if everything is now inactive, we have to leave
               lDone := .t.
            endif
         endif

         PAINTMENUBOX( aMenu[ MENUBAR ] )
         eval( aTopMenuBar[ BOXPROMPTS, aMenu[ MENUCURRTOP ], PROMPTDISPBLOCK ], .t., .t. )
         dispend()

      case aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEACTION
         MSG( "Option disabled!" )

      case aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEDROPDOWN .and. ;
                 ! empty( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX ] ) .and. ;
                 ascan( aCurrentPrompts[ nCurrentOption, PROMPTDROPBOX, BOXPROMPTS ], ;
                 { | a | eval( a[ PROMPTACTBLOCK ] ) } ) > 0
         lDroptoNextLeve := .t.

      case aCurrentPrompts[ nCurrentOption, PROMPTTYPE ] == TYPEDROPDOWN
         MSG( "Submenu currently inactive" )
      endcase

      dispbegin()
      MREFBOX( aCurrentBox )
      if !eval( aCurrentPrompts[ nCurrentOption, PROMPTACTBLOCK ] )
         nCurrentOption := ascan( aCurrentPrompts, { | a | eval( a[ PROMPTACTBLOCK ] ) } )
         if nCurrentOption == 0
            //-- if everything is now inactive, we have to leave
            lDone := .t.
         endif
      endif
      dispend()

   endif
   if ( lDone .or. aMenu[ MENUEXITREQ ] ) .and. lInTopBar .and. ;
        aMenu[ MENUCHECKEXIT ] # nil
      if !eval( aMenu[ MENUCHECKEXIT ] )
         aMenu[ MENUEXITREQ ] := .f.
         lDone                := .f.
      endif
   endif
end

REMOVEBOX( aCurrentBox )

asize( aMenu[ MENUHIDEPATH ], len( aMenu[ MENUHIDEPATH ] ) - 1 )
setcursor( nCursor )

return 0
//--------------------
static function logmenu( aNew )

static aThisMenu := {}
if aNew # nil
   if valtype( aNew ) == "A"
      aadd( aThisMenu, aNew )
   else
      asize( aThisMenu, max( 0, len( aThisMenu ) - 1 ) )
   endif
endif
return atail( aThisMenu )

//------------------------------
static function PAINTMENUBOX( aBox )

local aPrompts := aBox[ BOXPROMPTS ]
local aPrompt
local nCount
//-- draw the box/bar
dispbegin()
eval( aBox[ BOXDRAWBLOCK ] )
for nCount := 1 to len( aPrompts )
   aPrompt := aPrompts[ nCount ]
   eval( aPrompt[ PROMPTDISPBLOCK ], .f., eval( aPrompt[ PROMPTACTBLOCK ] ) )
next
dispend()
return nil
//----------------------------------
static function MREFBOX( aBox )

local aPrompts := aBox[ BOXPROMPTS ]
local aPrompt
local nCount
local aSaved   := aBox[ BOXUNDER ]
dispbegin()
//-- draw the box/bar
eval( aBox[ BOXDRAWBLOCK ] )
aBox[ BOXUNDER ] := aSaved
for nCount := 1 to len( aPrompts )
   aPrompt := aPrompts[ nCount ]
   eval( aPrompt[ PROMPTDISPBLOCK ], .f., eval( aPrompt[ PROMPTACTBLOCK ] ) )
next
dispend()
return nil
//-----------------------------
function MENUDEF( nTop, nLeft, nRight, aInPrompts, aColumns, ;
                  aColors, aMouseHots, aKeyHots, bCheckExit, lImmediate, ;
                  lDropped, nHideLevel, nShadowPos, nShadowAtt, lHandleAlt )
local nCount
local cPrompt
local cTrigger
local nAtTrigger
local aBar        := array( BOXSIZE )
local aMenu       := array( MENUSIZE )
local aThisPrompt
local nColumn
local lCross
local aWork
local i
local nBarSpace
local nDown
local nOver

nShadowPos := iif( nShadowPos == nil, SLS_SHADPOS(), nShadowPos )
nShadowPos := iif( ispart( nShadowPos, 1, 3, 0 ), nShadowPos, 0 )
nShadowAtt := iif( nShadowAtt # nil, nShadowAtt, SLS_SHADATT() )
nBarSpace  := 2
aColors    := iif( aColors # nil, aColors, array( 7 ) )
asize( aColors, 7 )
lHandleAlt := iif( lHandleAlt == nil, .f., lHandleAlt )

aColumns := iif( aColumns # nil, aColumns, array( len( aInPrompts ) ) )
asize( aColumns, len( aInPrompts ) )

if nTop == nil .or. nLeft == nil .or. nRight == nil
   nTop   := 0
   nLeft  := 0
   nRight := maxcol()
endif

aMenu[ MENUCURRTOP ]   := 1
aMenu[ MENUHIDDEN ]    := .F.
aMenu[ MENUHIDELEVEL ] := iif( nHideLevel # nil, nHideLevel, 1 )
aMenu[ MENUDROPPED ]   := iif( lDropped # nil, lDropped, .t. )
aMenu[ MENUIMMEDIATE ] := iif( lImmediate # nil, lImmediate, .t. )
aMenu[ MENUFIRSTLTR ]  := ""
aMenu[ MENUMOUSEHOTS ] := iif( aMouseHots # nil, aMouseHots, {} )
aMenu[ MENUKEYHOTS ]   := iif( aKeyHots # nil, aKeyHots, {} )
aMenu[ MENUNEWTOP ]    := .f.
aMenu[ MENUHIDEPATH ]  := {}
aMenu[ MENUEXITREQ ]   := .f.
aMenu[ MENUTOP ]       := nTop
aMenu[ MENULEFT ]      := nLeft
aMenu[ MENURIGHT ]     := nRight
aMenu[ MENUSHADOWPOS ] := nShadowPos
aMenu[ MENUSHADOWATT ] := nShadowAtt
aMenu[ MENUHANDLEALT ] := lHandleAlt

MCOLORSET( aColors, aMenu )

aMenu[ MENUCROSS ]     := figurecross( aMenu[ MC_FRAMES ] )
aMenu[ MENUCHECKEXIT ] := bCheckExit

aBar[ BOXLEVEL ]   := 0
aBar[ BOXTOP ]     := nTop
aBar[ BOXLEFT ]    := nLeft
aBar[ BOXBOTTOM ]  := nTop
aBar[ BOXRIGHT ]   := nRight
aBar[ BOXPROMPTS ] := {}
aBar[ BOXFIRST ]   := ""

nColumn := nLeft

// determine the top level bar prompts
for nCount := 1 to len( aInPrompts )
   aWork := aInPrompts[ nCount ]
   asize( aWork, 5 )

   nDown := iif( aWork[ 4 ] # nil, awork[ 4 ], 1 )
   nOver := iif( aWork[ 5 ] # nil, awork[ 5 ], 0 )

   cPrompt    := alltrim( strtran( aWork[ 1 ], "~" ) )
   nAtTrigger := at( "~", aWork[ 1 ] )
   nAtTrigger := max( 1, nAtTrigger )
   cTrigger   := subst( cPrompt, nAtTrigger, 1 )
   aMenu[ MENUFIRSTLTR ] += upper( cTrigger )
   aBar[ BOXFIRST ] += upper( cTrigger )
   nAtTrigger --
   if aColumns[ nCount ] # nil
      nColumn := aColumns[ nCount ]
   elseif nCount > 1
      nColumn += nBarSpace + 1
   endif
   aThisPrompt                    := array( PROMPTSIZE )
   aThisPrompt[ PROMPTLEVEL ]     := 0
   aThisPrompt[ PROMPTTOP ]       := nTop
   aThisPrompt[ PROMPTLEFT ]      := nColumn
   aThisPrompt[ PROMPTBOTTOM ]    := nTop
   aThisPrompt[ PROMPTRIGHT ]     := nColumn + len( cPrompt ) - 1
   aThisPrompt[ PROMPTTYPE ]      := figuretype( aWork )
   aThisPrompt[ PROMPTTEXT ]      := cPrompt
   aThisPrompt[ PROMPTTRIGGER ]   := cTrigger
   aThisPrompt[ PROMPTTRIGPOS ]   := nAtTrigger
   aThisPrompt[ PROMPTDISPBLOCK ] := MAKEDB( aThisPrompt, aMenu )

   aThisPrompt[ PROMPTACTBLOCK ] := iif( aWork[ 3 ] == nil, { || .t. }, aWork[ 3 ] )

   aThisPrompt[ PROMPTEXECBLOCK ] := iif( aThisPrompt[ PROMPTTYPE ] == TYPEACTION, ;
                                          aWork[ 2 ], nil )

   if aThisPrompt[ PROMPTTYPE ] == TYPEDROPDOWN
      aThisPrompt[ PROMPTDROPBOX ] := ;
              figurebox( aMenu, aThisPrompt, aWork[ 2 ], nDown, nOver )

      aThisPrompt[ PROMPTACTBLOCK ] := aBlockP( aThisPrompt )
   endif

   aadd( aBar[ BOXPROMPTS ], aThisPrompt )

   nColumn += len( cPrompt ) - 1
next

aBar[ BOXDRAWBLOCK ] := { || DRAWBOX( aBar, space( 9 ), aMenu ) }
aBar[ BOXRESTBLOCK ] := { | c | REMOVEBOX( aBar ) }
aBar[ BOXUNDER ]     := nil

aMenu[ MENUBAR ] := aBar

return aMenu

static function ablockp( ap )

return { || ( ascan( ap[ PROMPTDROPBOX, BOXPROMPTS ], ;
         { | a | eval( a[ PROMPTACTBLOCK ] ) } ) > 0 ) }
//--------------------------------------
static function figurebox( aMenu, aParentPrompt, aBoxPrompts, nDown, nOver )

local nCount
local aBox
local lCross
local nRows
local nCols
local aThisPrompt
local nColumn
local aWork
local nAtTrigger
local cTrigger
local cPrompt
local nWidth
local nDownSub
local nOverSub

nDown := iif( nDown # nil, nDown, 1 )
nOver := iif( nOver # nil, nOver, iif( aParentPrompt[ PROMPTLEVEL ] == 0, 0, 1 ) )
nRows := len( aBoxPrompts )
nCols := 1

for nCount := 1 to len( aBoxPrompts )
   aBoxPrompts[ nCount, 1 ] := alltrim( aBoxPrompts[ nCount, 1 ] )
   if len( aBoxPrompts[ nCount, 1 ] ) + 2 > nCols .and. ;
           upper( aBoxPrompts[ nCount, 1 ] ) # "CROSSBAR"
      nCols := len( strtran( aBoxPrompts[ nCount, 1 ], "~" ) ) + 2
   endif
next

aBox               := array( BOXSIZE )
aBox[ BOXLEVEL ]   := aParentPrompt[ PROMPTLEVEL ] + 1
aBox[ BOXTOP ]     := aParentPrompt[ PROMPTTOP ] + nDown
aBox[ BOXLEFT ]    := aParentPrompt[ PROMPTLEFT ] + nOver
aBox[ BOXBOTTOM ]  := aBox[ BOXTOP ] + nRows + 1
aBox[ BOXRIGHT ]   := aBox[ BOXLEFT ] + nCols + 1
aBox[ BOXPROMPTS ] := {}
aBox[ BOXFIRST ]   := ""

while aBox[ BOXBOTTOM ] > maxrow()
   aBox[ BOXBOTTOM ] --
   aBox[ BOXTOP ] --
end

while aBox[ BOXRIGHT ] > maxcol()
   aBox[ BOXRIGHT ] --
   aBox[ BOXLEFT ] --
end
nWidth := aBox[ BOXRIGHT ] - aBox[ BOXLEFT ] - 3

nColumn := aBox[ BOXLEFT ] + 2
for nCount := 1 to len( aBoxPrompts )
   aWork := aBoxPrompts[ nCount ]
   asize( aWork, 5 )

   nDownSub := iif( aWork[ 4 ] # nil, awork[ 4 ], 1 )
   nOverSub := iif( aWork[ 5 ] # nil, awork[ 5 ], 1 )
   lCross   := upper( aWork[ 1 ] ) == "CROSSBAR"
   if !lCross
      cPrompt    := strtran( aWork[ 1 ], "~" )
      nAtTrigger := at( "~", aWork[ 1 ] )
      nAtTrigger := max( 1, nAtTrigger )
      cTrigger   := subst( cPrompt, nAtTrigger, 1 )
      aBox[ BOXFIRST ] += upper( cTrigger )
      nAtTrigger --
   else
      cPrompt    := aWork[ 1 ]
      nAtTrigger := 0
      cTrigger   := chr( 254 )
      aBox[ BOXFIRST ] += upper( cTrigger )
   endif

   aThisPrompt                 := array( PROMPTSIZE )
   aThisPrompt[ PROMPTLEVEL ]  := aBox[ BOXLEVEL ]
   aThisPrompt[ PROMPTTOP ]    := aBox[ BOXTOP ] + nCount
   aThisPrompt[ PROMPTLEFT ]   := iif( lCross, aBox[ BOXLEFT ], nColumn )
   aThisPrompt[ PROMPTBOTTOM ] := aThisPrompt[ PROMPTTOP ]
   aThisPrompt[ PROMPTRIGHT ]  := iif( lCross, aBox[ BOXRIGHT ], ;
                                      nColumn + len( cPRompt ) - 1 )
   aThisPrompt[ PROMPTTYPE ]    := figuretype( aWork )
   aThisPrompt[ PROMPTTEXT ]    := cPrompt
   aThisPrompt[ PROMPTTRIGGER ] := cTrigger
   aThisPrompt[ PROMPTTRIGPOS ] := nAtTrigger
   if lCross
      aThisPrompt[ PROMPTDISPBLOCK ] := MAKECROSS( aThisPrompt[ PROMPTTOP ], ;
                                                   aThisPrompt[ PROMPTLEFT ], ;
                                                   aThisPrompt[ PROMPTRIGHT ], aMenu[ MENUCROSS ], aMenu )
   else
      aThisPrompt[ PROMPTDISPBLOCK ] := MAKEDB( aThisPrompt, aMenu, nWidth )
   endif

   aThisPrompt[ PROMPTACTBLOCK ] := iif( aWork[ 3 ] == nil, ;
                                         iif( lCross, { || .f. }, { || .t. } ), aWork[ 3 ] )

   aThisPrompt[ PROMPTEXECBLOCK ] := iif( aThisPrompt[ PROMPTTYPE ] == TYPEACTION, ;
                                          aWork[ 2 ], nil )

   if aThisPrompt[ PROMPTTYPE ] == TYPEDROPDOWN
      aThisPrompt[ PROMPTDROPBOX ] := ;
              figurebox( aMenu, aThisPrompt, aWork[ 2 ], nDownSub, nOverSub )
      aThisPrompt[ PROMPTACTBLOCK ] := aBlockP( aThisPrompt )
   endif

   aadd( aBox[ BOXPROMPTS ], aThisPrompt )

next

aBox[ BOXDRAWBLOCK ] := { || DRAWBOX( aBox, aMenu[ MC_FRAMES ], aMenu ) }
aBox[ BOXRESTBLOCK ] := { | c | REMOVEBOX( aBox ) }
aBox[ BOXUNDER ]     := nil

//aParentPrompt[PROMPTDROPBOX] := aBox
return aBox
//------------------------
static function figuretype( aPassed )

local nType
if valtype( aPassed[ 2 ] ) == "B"
   nType := TYPEACTION
elseif valtype( aPassed[ 2 ] ) == "A"
   nType := TYPEDROPDOWN
else
   nType := TYPECROSSBAR
endif
return nType
//-------------------------------------------------------
static function DRAWBOX( aBox, cFrame, aMenu )

local lIsBar := ( aBox == aMenu[ MENUBAR ] )
cFrame := iif( cFrame # nil, cFrame, aMenu[ MC_FRAMES ] )
dispbegin()
if aBox[ BOXUNDER ] # nil
   REMOVEBOX( aBox )
endif
if lIsBar
   aBox[ BOXUNDER ] := savescreen( aBox[ BOXTOP ], aBox[ BOXLEFT ], ;
                                   aBox[ BOXBOTTOM ], aBox[ BOXRIGHT ] + 1 )
else
   aBox[ BOXUNDER ] := savescreen( aBox[ BOXTOP ], max( aBox[ BOXLEFT ] - 1, 0 ), ;
                                   min( aBox[ BOXBOTTOM ] + 1, maxrow() ), min( aBox[ BOXRIGHT ] + 1, maxcol() ) )
endif
dispbox( aBox[ BOXTOP ], aBox[ BOXLEFT ], ;
         aBox[ BOXBOTTOM ], aBox[ BOXRIGHT ], cFrame, ;
         aMenu[ MC_MBOX ] )
if !lIsbar
   if aMenu[ MENUSHADOWPOS ] > 0
      SBSHADOW( aBox[ BOXTOP ], aBox[ BOXLEFT ], ;
                aBox[ BOXBOTTOM ], aBox[ BOXRIGHT ], aMenu[ MENUSHADOWPOS ], ;
                aMenu[ MENUSHADOWATT ] )
   endif
endif
dispend()
return aBox[ BOXUNDER ]
//-------------------------------------------------------
static function REMOVEBOX( aBox )

local lIsBar := ( aBox == logmenu() [MENUBAR] )
if !empty( aBox[ BOXUNDER ] )
   dispbegin()
   if lIsBar
      restscreen( aBox[ BOXTOP ], aBox[ BOXLEFT ], ;
                  aBox[ BOXBOTTOM ], aBox[ BOXRIGHT ], ;
                  aBox[ BOXUNDER ] )
   else
      restscreen( aBox[ BOXTOP ], max( aBox[ BOXLEFT ] - 1, 0 ), ;
                  min( aBox[ BOXBOTTOM ] + 1, maxrow() ), min( aBox[ BOXRIGHT ] + 1, maxcol() ), ;
                  aBox[ BOXUNDER ] )
   endif
   aBox[ BOXUNDER ] := nil
   dispend()
endif
return nil

//-------------------------------------------------------
static function RTVCOLOR( aMenu, nPosition )

return aMenu[ nPosition ]

//-------------------------------------------------------
static function MAKEDB( aPrompt, aMenu, nWidth )

if nWidth == nil
   return { | lSel, lActi | dispbegin(), ;
            devpos( aPRompt[ PROMPTTOP ], aPrompt[ PROMPTLEFT ] ), ;
            devout( aPrompt[ PROMPTTEXT ], ;
            aMenu[ iif( lSel, iif( lActi, MC_MSEL, MC_MINA ), iif( lActi, MC_MUNS, MC_MINA ) ) ] ), ;
            devpos( aPrompt[ PROMPTTOP ], ;
            aPrompt[ PROMPTLEFT ] + aPRompt[ PROMPTTRIGPOS ] ), ;
            devout( aPrompt[ PROMPTTRIGGER ], ;
            aMenu[ iif( lSel, iif( lActi, MC_MSELTRIG, MC_MINA ), iif( lActi, MC_MUNSTRIG, MC_MINA ) ) ] ), ;
            dispend() }
else
   return { | lSel, lActi | dispbegin(), ;
            devpos( aPRompt[ PROMPTTOP ], aPrompt[ PROMPTLEFT ] ), ;
            devout( padr( aPrompt[ PROMPTTEXT ], nWidth ), ;
            aMenu[ iif( lSel, iif( lActi, MC_MSEL, MC_MINA ), iif( lActi, MC_MUNS, MC_MINA ) ) ] ), ;
            devpos( aPrompt[ PROMPTTOP ], ;
            aPrompt[ PROMPTLEFT ] + aPRompt[ PROMPTTRIGPOS ] ), ;
            devout( aPrompt[ PROMPTTRIGGER ], ;
            aMenu[ iif( lSel, iif( lActi, MC_MSELTRIG, MC_MINA ), iif( lActi, MC_MUNSTRIG, MC_MINA ) ) ] ), ;
            dispend() }
endif
return nil

//-------------------------------------------------------

static function MAKECROSS( nTop, nLeft, nRight, aCross, aMenu )

memvar _1
return { || _1 := aMenu[ MC_MBOX ], ;
         devpos( nTop, nLeft ), ;
         devout( aCross[ 1 ], _1 ), ;
         devpos( nTop, nLeft + 1 ), ;
         devout( repl( aCross[ 2 ], nRight - nLeft - 1 ), _1 ), ;
         devpos( nTop, nRight ), ;
         devout( aCross[ 3 ], _1 ) }

//-------------------------------------------------------
static function TOP_BAR_POSITION( nCurrent, aMenu )

return ( aMenu[ MENUCURRTOP ] := iif( nCurrent # nil, ;
         nCurrent, aMenu[ MENUCURRTOP ] ) )
//-------------------------------------------------------
static function MOUSEINBOX( aBox, aPrompts, nMouseR, nMouseC, lTop )

local nCount

do case
case lTop
   if nMouseR == aBox[ BOXTOP ]
      for nCount := 1 to len( aPrompts )
         if nMouseC >= ( aPrompts[ nCount, PROMPTLEFT ] ) .and. ;
                    nMouseC <= ( aPrompts[ nCount, PROMPTRIGHT ] )
            return nCount
         endif
      next
   endif
case nMouseR > aBox[ BOXTOP ] .and. nMouseR < aBox[ BOXBOTTOM ] .and. ;
           nMouseC > aBox[ BOXLEFT ] .and. nMouseC < aBox[ BOXRIGHT ]
   for nCount := 1 to len( aPrompts )
      if ( aPrompts[ nCount, PROMPTTOP ] ) == nMouseR
         if eval( aPrompts[ nCount, PROMPTACTBLOCK ] )
            return nCount
         endif
      endif
   next
endcase
return 0
//-------------------------------------------------------
static function figurecross( cFrame )

local aCross := array( 3 )
aCross[ 2 ] := "Ä"
do case
case subst( cFrame, 8, 1 ) == "³"
   aCross[ 1 ] := "Ã"
case subst( cFrame, 8, 1 ) == "º"
   aCross[ 1 ] := "Ç"
otherwise
   aCross[ 1 ] := ""
endcase
do case
case subst( cFrame, 4, 1 ) == "³"
   aCross[ 3 ] := "´"
case subst( cFrame, 4, 1 ) == "º"
   aCross[ 3 ] := "¶"
otherwise
   aCross[ 3 ] := ""
endcase
return aCross
//-------------------------------------------------------
static function hide_menu( aMenu )

//do case
//case aMenu[ MENUHIDELEVEL ] == 1
//   bungeehide( .f. )
//case aMenu[ MENUHIDELEVEL ] == 2
bungeehide( .t. )
//endcase
return nil
//-------------------------------------------------------
function BUNGEEHIDE( lHideBar )

local aScreens  := {}
local nCount
local nHideTo
local aHidden
local aMenu
local cOldColor := setcolor( menucolor() )

lHideBar := iif( lHideBar # nil, lHideBar, .t. )
nHideTo  := iif( lHideBar, 1, 2 )
aMenu    := LOGMENU()
if !aMenu[ MENUHIDDEN ]
   aHidden := aMenu[ MENUHIDEPATH ]
   if aMenu # nil
      dispbegin()
      for nCount := len( aHidden ) to nHideTo step - 1
         REMOVEBOX( aHidden[ nCount, 1 ] )
      next
      dispend()
   endif
endif
aMenu[ MENUHIDDEN ] := .T.

setcolor( menuColor() )
@ 01, 00 say repli( '±', 80 )         
@ 02, 00 say repli( '±', 80 )         
@ 03, 00 say repli( '±', 80 )         
setcolor( cOldColor )

return nil
//-------------------------------------------------------
function BUNGEESHOW()

local nCount
local aPrompt
local aHidden
local aMenu

@  1,  0 clear to 3, 79
@  1,  0, 3, 79 box B_SINGLE

//@ 1,0 to 1,79
//@ 2,0 say space(80)
//@ 3,0 to 3,79

aMenu   := LOGMENU()
aHidden := aMenu[ MENUHIDEPATH ]
if aMenu # nil
   dispbegin()
   for nCount := 1 to len( aHidden )
      aPrompt := aHidden[ nCount, 1, BOXPROMPTS, aHidden[ nCount, 2 ] ]
      if aHidden[ nCount, 1, BOXUNDER ] == nil
         PAINTMENUBOX( aHidden[ nCount, 1 ] )
         eval( aPrompt[ PROMPTDISPBLOCK ], .t., .t. )
      endif
   next
   dispend()
endif
aMenu[ MENUHIDDEN ] := .F.
return nil
//-------------------------------------------------------
function BUNGEEQUIT()

local aMenu := logmenu()
if aMenu # nil
   aMenu[ MENUEXITREQ ] := .t.
endif
return nil
//-------------------------------------------------------
function BUNGEETOP()

local aMenu := logmenu()
if aMenu # nil
   aMenu[ MENUNEWTOP ] := .t.
endif
return nil
//-------------------------------------------------------
static function MCOLORSET( aColors, aMenu )

local c     := setcolor()
local cStd  := takeout( c, ",", 1 )
local cUns  := takeout( c, ",", 5 )
local cEnh  := takeout( c, ",", 2 )
local cWork
local cFg
local cBg
aMenu[ MC_MBOX ]     := iif( aColors[ 1 ] # nil, aColors[ 1 ], cStd )
aMenu[ MC_MSEL ]     := iif( aColors[ 2 ] # nil, aColors[ 2 ], cEnh )
aMenu[ MC_MUNS ]     := iif( aColors[ 3 ] # nil, aColors[ 3 ], cStd )
aMenu[ MC_MINA ]     := iif( aColors[ 4 ] # nil, aColors[ 4 ], "+N/" + takeout( cStd, "/", 2 ) )
aMenu[ MC_MSELTRIG ] := iif( aColors[ 5 ] # nil, aColors[ 5 ], nil )
if aMenu[ MC_MSELTRIG ] == nil
   cBg := takeout( cEnh, "/", 2 )
   if left( cEnh, 2 ) <> "W+" .and. cBg <> "W*"
      cFg := "W+"
   else
      if cBg $ "N~B~"
         cFg := "GR+"
      else
         cFg := "N"
      endif
   endif
   aMenu[ MC_MSELTRIG ] := cFg + "/" + cBg
endif
aMenu[ MC_MUNSTRIG ] := iif( aColors[ 6 ] # nil, aColors[ 6 ], nil )
if aMenu[ MC_MUNSTRIG ] == nil
   cBg := takeout( cStd, "/", 2 )
   if left( cStd, 2 ) <> "W+" .and. !cBg == "W*"
      cFg := "W+"
   else
      if cBg $ "N~B~"
         cFg := "W"
      else
         cFg := "N"
      endif
   endif
   aMenu[ MC_MUNSTRIG ] := cFg + "/" + cBg
endif
aMenu[ MC_FRAMES ] := iif( aColors[ 7 ] # nil, aColors[ 7 ], B_SINGLE + " " )
return NIL
//-------------------------------------------------------
function bungredraw( aColors, nShadowPos, nShadowAtt )

local aMenu := logmenu()
aColors := iif( aColors # nil, aColors, array( 7 ) )
if aMenu # nil
   BUNGEEHIDE( .T. )
   MCOLORSET( aColors, aMenu )
   nShadowPos             := iif( nShadowPos == nil, SLS_SHADPOS(), nShadowPos )
   nShadowPos             := iif( ispart( nShadowPos, 1, 3, 0 ), nShadowPos, 0 )
   nShadowAtt             := iif( nShadowAtt # nil, nShadowAtt, SLS_SHADATT() )
   aMenu[ MENUSHADOWPOS ] := nShadowPos
   aMenu[ MENUSHADOWATT ] := nShadowAtt
   BUNGEESHOW()
endif
return NIL
//-------------------------------------------------------

*+ EOF: BUNGMENU.PRG
