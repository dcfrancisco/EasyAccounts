#include "inkey.ch"

function AssetFlow
local dFrom, dTo, aRep := {}, nChoice := 0,x

local nSysProfit, nSpareProfit, nServIncome, nIncome, nExpense

dFrom := date()
dTo := date()
popread(.f.,'þ ASSETS FLOW þ From : ',@dFrom,'@D',;
            '                  To : ',@dTo,'@D')

if empty(dFrom) .or. empty(dTo) .or. dFrom > dTo
  msg('Invalid dates..')
  return .f.
endif

close all

prdGrpBal( dFrom, dTo, .f., 'Income' )
close all
eUse("acbals")
sum all balance to nIncome
nIncome := nIncome*-1
// Since ACBALS treats debit as positive and credit as negative.
// So, we have to make it * -1 so as to make it positive and display
// in the credit column..
use

prdGrpBal( dFrom, dTo, .f., 'Expense' )
close all
eUse("acbals")
sum all balance to nExpense
use

prdGrpBal( dFrom, dTo, .f., 'Service Engg.' )
close all
eUse("acbals")
sum all balance to nServIncome
use

if ReqInv()
// Below, nInclude =3, which means do not include Gen.sales or transfer...
nSysProfit := sup_sales( "SYSTEM", dFrom, dTo, .f., 3 )
close all

// nInclude below =2, which means do not include transfer but DO include gen.sales
nSpareProfit := sup_sales( "SPARES", dFrom, dTo, .f.,2 )
close all
else
nSysProfit := 0.00
nSpareProfit := 0.00
endif

aRep := { " ",;
          "System Sales Profit   : "+space(12)+str(nSysProfit,10,2),;
          "Spares Sales Profit   : "+space(12)+str(nSpareProfit,10,2),;
          "Service Engineers     : "+space(12)+str(nServIncome,10,2),;
          "Other Incomes         : "+space(12)+str(nIncome,10,2),;
          "EXPENSES              : "+str(nExpense,10,2),;
          "                        "+repl('-',22),;
          "    Net Flow ==>        "+space(12)+str( nSysProfit+nSpareProfit+nServIncome+nIncome-nExpense,10,2),;
          " "," "}

do while nChoice != 100

   jSaveEnv()

   if nChoice > 1
      keyboard repli(chr(K_DOWN),nChoice-1)
   endif

   setcolor( scrcolor() )
   @ 06, 10 say padc( 'þ ASSETS FLOW þ '+dtoc(dFrom)+' to '+dtoc(dTo), 58 )
   setcolor( boxcolor() )

   nChoice := aPick( 07, 10, 16, 67, aRep )

   if nChoice == 2
      if ReqInv()
         sup_sales( "SYSTEM", dFrom, dTo, .t., 3 )
      endif
   elseif nChoice == 3
      if ReqInv()
         sup_sales( "SPARES", dFrom, dTo, .t.,2 ) // see sup_sales at the top for expl on nInclude=3 and 2
      endif
   elseif nChoice == 4
      prdGrpBal( dFrom, dTo, .t., 'Service Engg.' )
   elseif nChoice == 5
      prdGrpBal( dFrom, dTo, .t., 'Income' )
   elseif nChoice == 6
      prdGrpBal( dFrom, dTo, .t., 'Expense' )
   else
      nChoice := 100
   endif

   jRestEnv()

enddo

close all
if jAlert('þ ASSETS FLOW þ;; Send the report to Printer ?', {'[ No ]', '[ Yes ]'})==2
   if prncheck()
      setprc(0,0)
      set device to printer
      set printer on
      x := 1
      @ x,  0 say padc(eaHead,45)
      @ x+1,0 say padc('ASSETS FLOW from '+dtoc(dFrom)+' to '+ dtoc(dTo),45)
      for x := 4 to 11
        @ x,4 say aRep[x-2]
      next x
      set device to screen
      set printer off
      set printer to
   endif
endif

return nil

