//------------------------------------------------------------------
// Open System
//   Refreshes an active EA session to continue normal operation
//   (a leftover of an abnormal exit or things like that.)
//
//  TO BE USED ONLY BY THE SUPERVISOR
//-----------------------------------------------------------------
local i := " "

set date brit
set centu on

?
? 'EA v1.5 Utility Application - Open System'
? '========================================='
?
? ' Sure to refresh the active session ? '
do while i != 'Y' .and. i != 'N'
   i := upper( chr( inkey( 0 ) ) )
enddo
if i == 'Y'
   ? '     Closing all active sessions...'
   jas := ""
   accept "Reason for opening : " to jas
   use (dir()+'\SYSTEM.EA')
   replace all open with .f. for rtrim( ltrim( company ) ) = 'SYSTEM'
   close all
   ?
   ? ' Sessions closed.'
   ?
   ?
else
   ? 'Operation terminated.'
   ?
   ?
endif

function dir

return "C:\EA\02"

*+ EOF: OPENSYS.PRG
