/*
-------------------------------------------------------------------------
Data Utility - 1.     Replace COST in sales.dbf with that in master.dbf
                      made during the introduction of COST in sales.dbf
                      for knowing realtime profit.
-------------------------------------------------------------------------
*/

use MASTER new index MAS_1
use SALES new index SALE_2
do while .not. eof()
   sele master
   seek sales->item_id
   sele sales
   field->cost := master->cost
   skip
enddo

*+ EOF: D_UTIL1.PRG
