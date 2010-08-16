#include "std.ch"
#DEFINE _RL 3+

function EditCompany
local cBox
close all

use ( NetDrive+':\EA\' + DataDir() + '\SYSTEM.EA' )
locate all for comp=comp_add
if eof()
  jAlert('ERROR : Current company information missing from file...!')
  close all
  return .f.
endif


makebox(03,10,21,70,boxgetcolor(),0)

setcolor(scrcolor())
@ 02,10 say padc('þ Edit Company Information þ',61)
@ 22,10 say padc('® Warning : Record locked exclusively ¯',61)
setcolor(boxgetcolor())
jRLock()
@ _RL 1, 12 say ' Company Name : ' get company pict '@XS40' valid ( !empty(alltrim(company)) )
@ _RL 2, 12 say '   Short Name : ' get comp    pict '@XS40' valid ( !empty(alltrim(comp)) )
@ _RL 3, 12 say '       Prefix : ' get prefix  pict '@XS40'
@ _RL 4, 12 say 'Other Heading : ' get head    pict '@XS40'
@ _RL 5, 12 say '      Address : ' get add1    pict '@XS40'
@ _RL 6, 12 say '                ' get add2    pict '@XS40'
@ _RL 7, 12 say '                ' get add3    pict '@XS40'

@ _RL 9, 12 say 'Include Address in Reports <Y/N> : ' get ShowAdd pict 'Y'

@ _RL 12, 12 say 'Left  Heading 1: ' get LSide1   pict '@XS32'
@ _RL 13, 12 say 'Right Heading 1: ' get RSide1   pict '@XS32'
@ _RL 15, 12 say 'Left  Heading 2: ' get LSide2   pict '@XS32'
@ _RL 16, 12 say 'Right Heading 2: ' get RSide2   pict '@XS32'
@ _RL 17, 12 say '  Bill Footing : ' get BillFoot pict '@XS32'
read
public comp_add  := rtrim( ltrim( comp ) )
public eaTitle   := rtrim( ltrim( company ) )
public eaHead    := rtrim( ltrim( head ) )                  // for eg.Wintech Systems & Services
public eaAdd1    := rtrim( ltrim( Add1 ) )
public eaAdd2    := rtrim( ltrim( Add2 ) )
public eaAdd3    := rtrim( ltrim( Add3 ) )
public eaLeft1   := rtrim( ltrim( LSide1) )
public eaLeft2   := rtrim( ltrim( LSide2) )
public eaRight1  := rtrim( ltrim( RSide1) )
public eaRight2  := rtrim( ltrim( RSide2) )
public eaBill    := rtrim( ltrim( BillFoot) )

public eaShowAdd := ShowAdd

jRUnLock()
DispScrn()
jAlert('Company information updated successfully..')
close all
return .t.

