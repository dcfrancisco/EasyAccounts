/*
-------------------------------------------------------------------------
Data Utility - 2.     Rearrange Cashbook voucher numbers.
-------------------------------------------------------------------------
*/
use cashbook new
go top
index on date to tmp1
go top
cdate := date
do while .not. eof()
   vouch := 1
   cDate := date
   do while date == cDate .and. ( !eof() )
      field->id := vouch
      vouch ++
      skip
   enddo
enddo

*+ EOF: D_UTIL2.PRG
