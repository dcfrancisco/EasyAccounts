#include "std.ch"
//==================================================
function srv_report()
local nSrl := 1, nTotAmount := 0, nOpenCalls := 0

private dFrom := date(), dTo := date(), nEngineer

use subheads new index SUB_1,SUB_2,SUB_3
use accounts new index ACC_1,ACC_2
use daybook new index DBK_1,DBK_2,DBK_3,DBK_4,DBK_5,DBK_6
use service new index SRV_1,SRV_2,SRV_3

sele accounts
set filte to alltrim(upper( accounts->type ) ) == 'SERVICE ENGG.'
go top

accview( .t., .f., nil, nil, nil, .f., { || alltrim( upper( accounts->type ) ) == 'SERVICE ENGG.' } )

nEngineer := accounts->id

popread(.f.,'Report From : ',@dFrom,'@D',;
            '         To : ',@dTo,'@D')

if empty(dFrom) .or. empty(dTo) .or. dFrom > dTo
  msg('Invalid dates..')
  close all
  return .f.
endif

JInitRep( "Service Engineer Report", .t., { || ShowSrvRef() }, 'Generating report...', 66 )

jAddData(  0,padc('Service Engineer Report:',77) )
jNextLine()
jAddData(  0,padc(alltrim(upper(accounts->account)),77 ) )
jNextLine()
jAddData(  0,padc(dtoc(dFrom)+" to "+dtoc(dTo),77 ) )
jNextLine()
jAddData(  0,repli('=',77) )
jNextLine()
jAddData(  0, "Srl" )
jAddData(  4, "Type" )
jAddData( 12, "Reported On" )
jAddData( 26, "Attended On" )
jAddData( 40, "Customer" )
jAddData( 70, "Amount" )
jNextLine()
jAddData(  0,repli('-',77) )
jNextLine()

sele service
set filter to (A_DATE >= dFrom .and. A_DATE <= dTo) .AND. engineer == nEngineer
go top
JDgSetPBar( cmFiltCount() )

do while .not. eof()
    jAddData(0, str(nSrl,3,0), str( service->id, 5, 0 ) )

    // the SER format is used in the ref. function of LEDGER which is also
    // used here - ShowRef()...

    if ! closed
      nOpenCalls++
      jAddData(4, service->type+'--' )
    else
      jAddData(4, ' '+service->type+' ')
    endif

    jAddData(12, dtoc(R_Date) )
    jAddData(26, dtoc(A_Date) )
    jAddData(40, subs(ExactCust(),1,28) )   // ExactCust is in SERVICE.prg which shows
                                 // the customer/subhead accordingly to Paid, WA ..
    jAddData(70, str(amount,6,0) )

   jNextLine()

   nTotAmount += amount
   nSrl++

   sele service
   skip

   JDgIncrPBar()

enddo
jAddData(  0,repli('-',77) )
jNextLine()
jAddData( 3, 'Calls not yet closed: '+str(nOpenCalls,3,0) )
jAddData(55, 'Total -->')
jAddData(69, str(nTotAmount,7,0) )
jNextLine()
jNextLine()
jNextLine()
jAddData(0,repli('-',77))
jNextLine()
jAddData(0,'NOTE: A trailing -- in the service type points to a service not yet closed.')
close all

jEndReport()
return .t.
//------------
static function ShowSrvRef
if ! empty(alltrim(jRefData()))
     jSaveEnv()
     Service( val( jRefData() ) )
     close all
     jRestEnv()
endif
return .t.
