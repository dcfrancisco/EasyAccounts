local a := {}
local y
close all
use ('c:\EA\02\SYSTEM.EA')
do while .not. eof()
   aadd( a, dir )
   skip
enddo
for y := 1 to len( a )
   set default to ( "C:\EA\02\" + a[ y ] )
   gwchDir( 'C:\EA\02\' + a[ y ] )
   dbf_io( .f. )
next y
return .t.

static function dbf_io( lProtect )

local aDir := directory( '*.DBF' )
local y

local handle
local first_byte
local buffer     := " "
local fn

for y := 1 to len( aDIr )
   fn := rtrim( ltrim( aDir[ y ] [ 1 ] ) )
   if ( handle := fopen( fn, FO_READWRITE ) ) > - 1
      fread( handle, @buffer, 1 )
      first_byte := asc( buffer )
      fseek( handle, 0, 0 )
      /*
   BLOODY THINGS. ALL THE TIME I TELL HIM IT IS OKAY.
   AGAIN THESE THINGS REPLACE THE MEMO DBF WITH ORDINARY ONES.
   I HAVE'NT GOT TIME TO DEBUG ALL THESE RUBBISH.

   WHY NOT HAVE MY OWN CODE ?
   */

      /*
   if ! lProtect
      if first_byte = 27              // Is a memo file needed?
         fwrite(handle,chr(131),1)
      else
         fwrite(handle,chr(03),1)
      endif
   else
      if first_byte = 131             // If memo file field
         fwrite(handle,chr(27),1)     // write 27 as the first
      else                            // byte, otherwise write
         fwrite(handle,chr(26),1)     // a 26.
      endif
   endif
   */

      if file( subs( fn, 1, len( fn ) - 3 ) + '.DBT' ) .or. ;
               fn == 'BOOKSTAT.DBF'     // memo file
         fwrite( handle, chr( 131 ), 1 )
      else
         fwrite( handle, chr( 03 ), 1 )
      endif

      /*
   if ! lProtect
      if file( subs(fn,1,len(fn)-3)+'.DBT'  ) .or. ;
         fn == 'BOOKSTAT.DBF'                          // memo file
         fwrite(handle,chr(131),1)
      else
         fwrite(handle,chr(03),1)
      endif
   else
      if first_byte = 131             // If memo file field
         fwrite(handle,chr(27),1)     // write 27 as the first
      else                            // byte, otherwise write
         fwrite(handle,chr(26),1)     // a 26.
      endif
   endif
   */

      fclose( handle )
   endif
next y
close all
return .t.

*+ EOF: OPENDBF.PRG
