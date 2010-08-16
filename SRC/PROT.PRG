#include "FILEIO.CH"

local aDir := directory( '*.DBF' )
local y

local handle
local first_byte
local buffer     := " "
local fn

for y := 1 to len( aDir )
   fn := rtrim( ltrim( aDir[ y ] [ 1 ] ) )
   if ( handle := fopen( fn, FO_READWRITE ) ) > - 1
      fread( handle, @buffer, 1 )
      first_byte := asc( buffer )
      fseek( handle, 0, 0 )
         if file( subs( fn, 1, len( fn ) - 3 ) + '.FPT' ) .or. ;
                  fn == 'BOOKSTAT.DBF'  // memo file
            fwrite( handle, chr( 245 ), 1 )
         elseif file( subs( fn, 1, len( fn ) - 3 ) + '.DBT' )
            fwrite( handle, chr( 131 ), 1 )
         else
            fwrite( handle, chr( 03 ), 1 )
         endif
      endif
      fclose( handle )
next y
close all
return .t.
