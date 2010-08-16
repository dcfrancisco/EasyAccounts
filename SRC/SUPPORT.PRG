#include "std.ch"
static sp_visor
//----------------------
function whatcolor

local x := menu_v( "Colors", "Change Current Settings", "Reset to default settings" )
if x = 0
   return .f.
elseif x = 1
   chn_color()
elseif x = 2
   close all
   use system.int
   go bott
   jRLock()
   field->screen := space( 7 )
   jRUnLock()
   use
   c_loadit()       // first time it replaces the records
   gwdisablecolor()
   c_loadit()       // the second time, it activates the colors
endif
return .t.
//------------------
function m_standby

local x := 1
do while x != 0
   dispbegin()
   dispscrn()
   dispend()
   x := menu_v( "อออออออ STANDBY ออออออ", "Add/Edit Standby Details", "Print/View Report" )
   if x = 1
      sbBrowse()
   elseif x = 2
      sbDues()
   endif
enddo
return .t.
//-------------
function m_replace

local x := 1
do while x != 0
   dispbegin()
   dispscrn()
   dispend()
   x := menu_v( "อออออออ REPLACEMENT ออออออ", "Add/Edit Replacement Details", "Print/View Report" )
   if x = 1
      rpBrowse()
   elseif x = 2
      rpDues()
   endif
enddo
return .t.
//-------------
function setsp( lLogic )

sp_visor := lLogic
return sp_visor
//-------------
function sp_visor

if sp_visor = NIL
   sp_visor := .f.
endif
return sp_visor
//-------------
function pop_menu

if .not. empty( rtrim( ltrim( userName() ) ) )
   if ReqInv()
      InvPopMenu()
   else
      AccPopMenu()
   endif
else

   jSaveEnv()

   set default to ( dir() + "\PULLIMAN" )
   gwchdir( dir() + "\PULLIMAN" )
   OpenDir()

   keyboard "F" + chr( K_ENTER )        // to directly go to search phone.
   ea_phone()
   set default to ( dir() )
   close all
   jRestEnv()
   return nil
endif
return .t.
//-------------------------------------------
