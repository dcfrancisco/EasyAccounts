/*
-------------------------------------------------------------------------
Data Utility - 3.     Update Margin column in SACCOUNT.DBF
-------------------------------------------------------------------------
*/
use sales new index SALE_1
use saccount new index SAC_1
go top
do while .not. eof()
   nMargin := 0.00
   sele sales
   seek saccount->id
   do while id == saccount->id .and. ( !eof() )
      nMargin += ( price - cost ) * qty
      skip
   enddo
   sele saccount
   field->margin := nMargin
   skip
enddo

*+ EOF: D_UTIL3.PRG
