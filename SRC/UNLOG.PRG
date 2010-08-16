#include "fileio.ch"

? "Total Network Unlog by Jasim A Basheer"
? "Component of EasyAccounts v2.5 PRO (Network Edition)"
?
if !( file( 'SYSTEM.EA' ) .and. file( 'USERS.DBF' ) )
   ? "Fatal Error : Log File not present."
   ?
   quit
endif
uOpen( 'SYSTEM.EA' )
uOpen( 'USERS.DBF' )
use system.ea
repl all open with .f.
use users
repl all logged with .f.
? "All users,systems and companies unlogged from EA."
?
?

static func UOpen( cFile )

local y
local handle
local first_byte
local buffer     := " "
local fn

fn := cFile

if ( handle := fopen( fn, FO_READWRITE ) ) > - 1
   fread( handle, @buffer, 1 )
   first_byte := asc( buffer )
   fseek( handle, 0, 0 )
   fwrite( handle, chr( 03 ), 1 )
   fclose( handle )
endif

close all
return .t.

*+ EOF: UNLOG.PRG
