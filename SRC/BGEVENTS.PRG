// Program   : BGEVENTS.PRG
// Author    : Robert Franklin Lamping
// Company   : FourDim
// Email     : robert@winning.com        (Lifetime Email address)
// Date      : May 8, 1997
//
#include "std.ch"
#include "inkey.ch"     // Clipper
#include "bgevents.ch"  // Background events
//
// The following Globals Statics are postfixed with _BGE to see the difference
// between LOCAL variables and the global STATICs.
static aEvents_BGE         := {}
static bIdleFunc_BGE       := { | b | FT_OnIdle( b ) }      //{|b| AT_OnIdle( b ) }
static lExecAll_BGE        := .T.
static lInitActive_BGE     := .T.
static lStopped_BGE        := .F.
static lRunning_BGE        := .F.
static lDebug_BGE          := .T.       // .F.: events disabled when debugger linked in.
static nMaintick_BGE       := 0
static nCurEvent_BGE       := 0
static lKillSystem_BGE     := .F.
static bReentrantState_BGE := { || NIL }
static nArrayLock          := 0
static InkeyEvBlock        := { | b | Nil }
static nLevel              := 0
//
static func BGE_Init( aEvent )

aEvent                        := array( BGE_NLENGTH )
AEVENT[ BGE_NHANDLE ]         := 0
AEVENT[ BGE_BACTION ]         := { || NIL }
AEVENT[ BGE_BONDEACTIVATION ] := { || NIL }
AEVENT[ BGE_BONACTIVATION ]   := { || NIL }
AEVENT[ BGE_LACTIVATED ]      := .F.    // Performed Once After Activation?
AEVENT[ BGE_CNAME ]           := ""
AEVENT[ BGE_LACTIVE ]         := .T.
AEVENT[ BGE_NINTERVAL ]       := 0
AEVENT[ BGE_BWHEN ]           := { || .T. }
AEVENT[ BGE_LKILLIT ]         := .F.
AEVENT[ BGE_LKILLITAFTER ]    := .F.
AEVENT[ BGE_NSECONDS ]        := 0      // NEEDED FOR INTERVAL
AEVENT[ BGE_NTIMER ]          := 0
AEVENT[ BGE_LINPROGRESS ]     := .F.
AEVENT[ BGE_NPOSLOCK ]        := BGE_lockkey()
AEVENT[ BGE_LEMPTY ]          := .F.
AEVENT[ BGE_LSTOP ]           := .F.
AEVENT[ BGE_LDIRECT ]         := .F.
return aEvent
/*
* Overruling default event-handler:  Uses Nanforum instead
* Un-comment if needed and link with Nanforum lib
INIT FUNCTION INIT_BGE
bIdleFunc_BGE := {|b| AT_OnIdle( b ) }
Return .T.
*
FUNC AT_onIdle( bBlock )
If Empty( bBlock )
EvhClear( bBlock )
Else
EvhSet( bBlock )
ENdif
Return nil
*
*/
exit function EXIT_BGE

// Stop inclusion of event in main-loop
eval( bIdleFunc_BGE )
return .T.
//
// Find the position of an event, if name is passed.
func BGE_POS( xHandle )

local nPos := 0
if ( valtype( xHandle ) == "N" )        //Numeric
   nPos := ascan( aEvents_BGE, { | el | el[ BGE_NHANDLE ] == xHandle } )
elseif ( valtype( xHandle ) == "C" )    //Name of event
   xHandle := upper( alltrim( xHandle ) )
   nPos    := ascan( aEvents_BGE, { | el | el[ BGE_CNAME ] == xHandle } )
endif
return nPos
//
// Check whether debugger is linked.
func BGE_DEBUG( lDebug )

if valtype( lDebug ) == "L"
   lDebug_BGE := lDebug
endif
return 0
//
static func BGE_DSeconds( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if nPos > 0
   return aEvents_BGE[ nPos, BGE_NSECONDS ]
endif
return 0
//
static func BGE_Seconds( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )
   return aEvents_BGE[ nPos, BGE_NSECONDS ]
endif
return 0
//
static func BGE_Timer( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
// Return value of nTimer
if ( nPos > 0 )
   return aEvents_BGE[ nPos, BGE_NTIMER ]
endif
return Nil
//
func BGE_Interval( xHandle, nPos, nNewValue )

local nOldvalue := 0
ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )     //Return value of nTimer
   nOldValue := aEvents_BGE[ nPos, BGE_NINTERVAL ]
   if ( valtype( nNewValue ) == "N" )
      aEvents_BGE[ nPos, BGE_NINTERVAL ] := nNewValue
   endif
endif
return nOldValue
//
static func BGE_ResetTimer( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )
   aEvents_BGE[ nPos, BGE_NSECONDS ] := DSeconds()
   aEvents_BGE[ nPos, BGE_NTIMER ]   := DSeconds()
endif
return Nil
//
func BGE_Start()

if ( .not. lRunning_BGE )
   if ( len( aEvents_BGE ) > 0 )
      if lDebug_BGE
         eval( bIdleFunc_BGE )
         eval( bIdleFunc_BGE, { || BGE_EXEC() } )
      endif
      lRunning_BGE := .T.
      lStopped_BGE := .F.
   endif
endif
return .T.
//
func BGE_Stop()

local lOldvalue := lRunning_BGE
eval( bIdleFunc_BGE )
lStopped_BGE := .T.
lRunning_BGE := .F.
return lOldValue
//
//Set Initial Activness of the events
func BGE_AutoActive( lActive )

DEFAULT lActive to .T.
lInitActive_BGE := lActive
return Nil
//
func BGE_MAINTICK( nInterval )

if ( valtype( nInterval ) == "N" )
   nMainTick_BGE := nInterval
endif
return Nil
//
function BGE_EXECALL( lLogic )

if valtype( lLogic ) == "L"
   lExecAll_BGE := lLogic
endif
return Nil
//
func BGE_IDLEFUNC( bIdle )

local xOldValue := bIdleFunc_BGE
if ( valtype( bIdle ) == "B" )
   bIdleFunc_BGE := bIdle
endif
return xOldValue
//
static func BGE_BRESTATE( bBlock )

local xOldValue := bReentrantState_BGE
if ( valtype( bBlock ) == "B" )
   bReentrantState_BGE := bBlock
endif
return xOldValue
//
static func BGE_STALL( XhANDLE, NpOS )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if aEvents_BGE[ nPos, BGE_LACTIVE ]
   eval( aEvents_BGE[ nPos, BGE_BONDEACTIVATION ] )
endif
aEvents_BGE[ nPos, BGE_LSTOP ]      := .T.
aEvents_BGE[ nPos, BGE_LACTIVE ]    := .F.
aEvents_BGE[ nPos, BGE_LACTIVATED ] := .T.
return .T.
//
static func BGE_Cloack( xHandle, nPos )                     // nPos overrules xHandle

// Make sure nPos is ok since there is no range-check
ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
aEvents_BGE[ nPos, BGE_LACTIVE ] := .F.
return .T.
//
static func BGE_DECLOACK( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if !aEvents_BGE[ nPos, BGE_LSTOP ]
   aEvents_BGE[ nPos, BGE_LACTIVE ] := .T.
endif
return .T.
//
static func BGE_RESUME( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
aEvents_BGE[ nPos, BGE_LSTOP ]      := .F.
aEvents_BGE[ nPos, BGE_LACTIVE ]    := .T.
aEvents_BGE[ nPos, BGE_LACTIVATED ] := .F.
return .T.
//
func BGE_ONACT( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( .not. aEvents_BGE[ nPos, BGE_LACTIVATED ] )
   aEvents_BGE[ nPos, BGE_LACTIVATED ] := .T.
   eval( aEvents_BGE[ nPos, BGE_BONACTIVATION ] )
   // Reset timers: interval-timer and start-timer
   aEvents_BGE[ nPos, BGE_NSECONDS ] := Dseconds()
   aEvents_BGE[ nPos, BGE_NTIMER ]   := aEvents_BGE[ nPos, BGE_NSECONDS ]
endif
return .T.
//
// Create new Event
func BGE_NEW( pcName, pbBlock, pnInterval, pbWhen, plOnce, plInActive, pbDeaction, pbOnActivation, lDirect )

local nHandle := 0
local aEvent  := {}
local nPos    := 0
//
BGE_INIT( @aEvent )                     // set initial values
if BGE_ARRAYLOCK()  // keep trying forever
   do while .T.
      nPos := ascan( aEvents_BGE, { | el | el[ BGE_LEMPTY ] } )
      if nPos == 0
         exit
      elseif BGE_POSLOCK( nPos, 5 )
         // Try to claim array element position
         exit
      endif
   enddo
   if nPos = 0
      aadd( aEvents_BGE, aEvent )
      nPos := len( aEvents_BGE )
   else
      aEvents_BGE[ nPos ] := aEvent
   endif
   // Array Element is still locked
   // Create new handle by looking up highest nHandle
   aeval( aEvents_BGE, { | el | nHandle := max( nHandle, el[ BGE_NHANDLE ] ) } )
   nHandle ++
   // ADJUSTing values
   ADJUST aEvent[ BGE_BACTION ] to pbBlock
   ADJUST aEvent[ BGE_BONDEACTIVATION ] to pbDeAction
   ADJUST aEvent[ BGE_BONACTIVATION ] to pbOnActivation
   if !empty( pcName )
      ADJUST aEvent[ BGE_CNAME ] to upper( alltrim( pcName ) )
   endif
   ADJUST aEvent[ BGE_BWHEN ] to pbWhen
   ADJUST aEvent[ BGE_NINTERVAL ] to pnInterval
   ADJUST aEvent[ BGE_LDIRECT ] to lDirect
   if valtype( plInActive ) == "L"
      aEvent[ BGE_LACTIVE ] := !plInActive
   else
      ADJUST aEvent[ BGE_LACTIVE ] to lInitActive_BGE
   endif
   ADJUST aEvent[ BGE_LKILLITAFTER ] to plOnce
   aEvent[ BGE_NSECONDS ] := Dseconds()
   BGE_Start()
   BGE_POSUNLOCK( nPos )
   BGE_ARRAYUNLOCK()
endif
return ( aEvent[ BGE_NHANDLE ] )
//-----------------------------------------------------------------
function BGE_FindByName( cName )        // obsolete

local nPos := BGE_POS( cName )
if nPos > 0
   return aEvents_BGE[ nPos ]
endif
return Nil
function BGE_Kill( xHandle, nPos )

// Deactivate event first
// Lock array .. try forever
local lDone := .F.
ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if BGE_PosLock( nPos )
   aEvents_BGE[ nPos, BGE_LEMPTY ]  := .T.                  // may be reused by BGE_NEW
   aEvents_BGE[ nPos, BGE_LACTIVE ] := .T.
   aEvents_BGE[ nPos, BGE_NHANDLE ] := 0
   lDone                            := .T.
   BGE_PosUnLock( nPos )
endif
return lDone
static function BGE_PosLock( nPos, nWait )

// Locking an array element is necessary, because of the event-handler
// is reentrant and more procedure might want to approach the same element.
// Try to lock array element forever
local nLock    := BGE_lockkey()
local nSeconds := Dseconds()
local lForever
local lLocked  := .F.
Default nWait to 0
lForever := ( nWait == 0 )
if nPos > 0
   while .T.
      if aEvents_BGE[ nPos, BGE_NPOSLOCK ] != nLock
         if aEvents_BGE[ nPos, BGE_NPOSLOCK ] = 0
            aEvents_BGE[ nPos, BGE_NPOSLOCK ] := nLock
            if aEvents_BGE[ nPos, BGE_NPOSLOCK ] == nLock
               lLocked := .T.
               exit
            endif
         endif
      endif
      if !lForEver
         if DSeconds() - nSeconds > nWait
            exit
         endif
      endif
   end
endif
return lLocked
static function BGE_PosUnLock( nPos )

// Unlock array element
aEvents_BGE[ nPos, BGE_NPOSLOCK ] := 0
return .T.
static function BGE_ARRAYUNLOCK()

// Unlock array element
nArrayLock := 0
return .T.
//
static function BGE_ARRAYLOCK()

// Try to lock array forever
local nLock := BGE_LockKey()
do while ( nArrayLock != nLock )
   if ( nArrayLock = 0 )
      nArrayLock := nLock
      if ( nArrayLock == nLock )
         exit
      endif
   endif
enddo
return .T.
return .F.
//
func BGE_RELEVEL()

/*
* Return Reentrance Level
*/
return nLevel
//
func BGE_Exec()

local nCol      := col()
local nRow      := row()
local nCurSor   := setcursor()
local lAllow    := .F.
static nSeconds
if valtype( nSeconds ) != "N"
   nSeconds := DSeconds()
endif
++ nLevel
if Dseconds() - nSeconds > nMainTick_BGE
   nSeconds := Dseconds()
   lAllow   := .T.
endif
if lAllow
   eval( BGE_BRESTATE(), nLevel )
   devpos( nRow, nCol )
   if lExecAll_BGE
      aeval( aEvents_BGE, { | el, pos | BGE_BEXEC( pos ) } )
   else
      if nCurEvent_BGE = 0
         nCurEvent_BGE := 1
      endif
      BGE_BEXEC( nCurEvent_BGE )
      if ++ nCurEvent_BGE > len( aEvents_BGE )
         nCurEvent_BGE := 1
      endif
   endif
   devpos( nRow, nCol )
   setcursor( nCursor )
endif
nLevel --
return ( 0 )
//
func BGE_BEXEC( nPos )

local nSec   := 0
local aEvent := aEvents_BGE[ nPos ]
aEvent[ BGE_LINPROGRESS ] := .T.
if aEvent[ BGE_LKILLIT ]
   BGE_Kill(, nPos )
elseif aEvent[ BGE_LACTIVE ]
   if eval( aEvent[ BGE_BWHEN ] )
      if aEvent[ BGE_NINTERVAL ] > 0
         nSec := Dseconds()
         if ( nSec - aEvent[ BGE_NSECONDS ] > aEvent[ BGE_NINTERVAL ] ) .or. ;
              ( aEvent[ BGE_LDIRECT ] .and. !aEvent[ BGE_LACTIVATED ] )
            aEvent[ BGE_NSECONDS ] := nSec
            BGE_Cloack(, nPos )
            BGE_OnAct(, nPos )
            eval( aEvent[ BGE_BACTION ] )
            BGE_DeCloack(, nPos )
         endif
      else
         BGE_Cloack(, nPos )
         BGE_OnAct(, nPos )
         eval( aEvent[ BGE_BACTION ] )
         BGE_DeCloack(, nPos )
      endif
   endif
endif
if ( nPos <= len( aEvents_BGE ) )
   aEvent[ BGE_LINPROGRESS ] := .F.
endif
return .T.
//
func BGE_RELEASE( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )
   aEvents_BGE[ nPos, BGE_LKILLIT ] := .T.
endif
return ( nPos > 0 )
//
func BGE_ACT( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )
   BGE_Resume(, nPos )
endif
return ( nPos > 0 )
//
func BGE_DEACT( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
if ( nPos > 0 )
   BGE_Stall(, nPos )
endif
return ( nPos > 0 )
//
func BGE_EVENT( xHandle, nPos )

ADJUST nPos to BGE_POS( xHandle ) IFNONIL xHandle
return aEvents_BGE[ nPos ]
//
func BGE_CLEAR()    // not active et

lKILLSYSTEM_BGE := .T.
return .T.
static func BGE_LockKey()

static nLockKey := 0
nLockKey ++
if ( nLockKey > 65000 )
   nLockKey := 1
endif
return nLockKey
//
func DSECONDS()

return int( date() - ctod( "01/01/1000" ) ) * 86400 + seconds()
//
func Inkey_onIdle( bBlock )

if empty( bBlock )
   InkeyEvBlock := { || Nil }
else
   InkeyEvBlock := bBlock
endif
return nil
//
func InkeyEvents()

// Call this FUNCTION in your FUNCTION MyInkey() or whereever you like!
return InkeyEvBlock

*+ EOF: BGEVENTS.PRG
