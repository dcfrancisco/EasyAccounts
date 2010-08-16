/***
*
*  RddSys.prg
*
*  This program is run each time your application is started to setup
*  the proper default driver.  You should modify a copy of this file
*  if you wish to use a default RDD other than DBFNTX.
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

ANNOUNCE RDDSYS     // This line must not change

INIT procedure RddInit

REQUEST DBFNTX
REQUEST COMIX
rddsetDefault('COMIX')

return

// eof: rddsys.prg

*+ EOF: RDDSYS.PRG
