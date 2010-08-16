/*
-------------------------------------------------------------------------
Data Utility - 4.     Create batches in BATCHES.DBF for beginning the
                      Batch System. (Only to be used while introducing
                      BATCH system for the first time in the software)
                      As on 22nd August 2002
-------------------------------------------------------------------------
*/

use BATCHES new
zap
use MASTER new
do while .not. eof()
   sele batches
   append blank
   field->id    := master->id
   field->begin := master->bal
   field->cost  := master->cost
   sele master
   skip
enddo

*+ EOF: D_UTIL4.PRG
