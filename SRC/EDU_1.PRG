static line    := 1
static nTotCashBal   := 0.00
static nDayCashBal  := 0.00
static wprint
static seldate
static jAdd

function edu_dprn()

local cPath := curdir()
local x
local cAdd

set exclusive on

line := 1

cAdd   := comp_add
nTotCashBal  := 0.00
nDayCashBal := 0.00

seldate := entr_date()
close all
setprc( 0, 0 )
setcolor( scrcolor() )
@ 09, ( 79 / 2 - 12 ) say padc( 'Daily Sheet', 25 )         
setcolor( boxcolor() )
xx := makebox( 10, ( ( 79 / 2 ) - 12 ), 14, ( ( 79 / 2 ) + 12 ), boxcolor() )
@ 12, ( 79 / 2 ) - 12 + 3 say "Date :" get seldate        
read
if seldate > date()
   close all
   set exclusive off
   return .f.
else
   if ac_closed( seldate )
      @ 12, ( 79 / 2 ) - 11 say space( 23 )            
      @ 11, ( 79 / 2 ) - 11 say '  PRINT TO ?'         
      @ 12, ( 79 / 2 ) - 11 + 5 prompt "Screen"
      @ 13, ( 79 / 2 ) - 11 + 5 prompt "Printer"
      menu to xxb
      if xxb = 0
         close all
         set exclusive OFF
         return .f.
      elseif xxb = 1
         wprint := 1
      else
         wprint := 2
      endif
   else
      wprint := 1
   endif

   @ 11, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 13, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 12, ( 79 / 2 ) - 11 say space( 23 )                              
   @ 12, ( 79 / 2 ) - 11 say padc( 'Printing report...', 22 )         
endif

if wprint = 2
   if prncheck()
      set device to printer
      set printer on
      ?? chr( 15 )
   else
      close all
      set exclusive OFF
      return nil
   endif
else
   set printer to (RepPath+'DBK_GEN.TXT')
   set device to printer
   set printer on
endif

@ line,  1 say padc( "Daily Sheet : " + dtoc( seldate ) + ' ' + cdow( seldate ), 78 )         
line ++
@ line,  1 say repli( "-", 78 )         
line ++
@ line,  1 say "Student/Account Name                                    Debit         Credit"         
line ++
@ line,  1 say repli( "-", 78 )         
line ++
jAdd := 'City Center, Kayamkulam'
setpaths( jAdd )
d_general( jAdd )
jAdd := 'Advocates Lane, Karunagappally'
setpaths( jAdd )
d_general( jAdd )
jAdd := 'Pulliman Jun. (SOFTWARE)'
setpaths( jAdd )
d_general( jAdd )
jAdd := 'Pulliman Jun. (HARDWARE)'
setpaths( jAdd )
d_general( jAdd )
set default to ( dir() + '\GRAPHICS' )
comp_add := 'Graphics'
x        := smm_doit( line + 1, seldate )
nTotCashBal    += x[ 1 ]
nDayCashBal   += x[ 2 ]
line     := x[ 3 ]
set default to ( dir() + '\MICROS' )
comp_add := 'Microsolutions'
x        := smm_doit( line + 1, seldate )
nTotCashBal    += x[ 1 ]
nDayCashBal   += x[ 2 ]
line     := x[ 3 ]
@ line,  0 say repli( '-', 78 )         
line ++
@ line, 01 say "T/Cash Bal.: " + rtrim( ltrim( str( nTotCashBal, 11, 2 ) ) )          
@ line, 50 say "D/Cash Bal.: " + rtrim( ltrim( str( nDayCashBal, 11, 2 ) ) )         
line ++
line ++
if wprint = 2
   line ++
   line ++
   @ line,  0 say "            Prepared by            Verified by" + ;         
           "            Accountant             Manager"
   line ++
   line ++
endif
line ++
@ line,  1 say " "         
close all
if wprint = 1
   line ++
   @ line,  0 say ""         
   set device to screen
   set printer off
   set printer to
   comp_add := cAdd
   set default to ( NetDrive() + ':\' + cPath )
   fileread( 1, 0, 23, 79, "DBK_GEN.TXT", "Daily Sheets - Education",, .F. )
else
   ?? chr( 18 )
   ?? chr( 10 ) + chr( 10 ) + chr( 10 )
   line ++
   line ++
   @ line,  0 say ""         
   set device to screen
   set printer off
   set printer to
   comp_add := cAdd
   set default to ( NetDrive() + ':\' + cPath )
endif
set exclusive OFF
return .t.

static function d_general( address )

local aarr                     := {}
local oldr
local tstart
local ti                       := te := 0.00
local bf                       := 0.00
local tr
local td
local totcr
local totdr
local nOp                      := 0.00
local number_of_lines_per_page := 0
totcr := totdr := 0.00
nOp   := 0.00
close all
use subheads VIA "DBFNTX" new inde accdata SHARED
use newd VIA "DBFNTX" NEW inde trno SHARED
go top
sum all debit - credit to nOp for pagecode = 1 .and. ( tran_date < seldate )
copy all for tran_date=seldate to nTemp
use
use ntemp new
index on tran_no to nTr
go top
cpyfor( { || pagecode = 1 } )
sele ntemp
@ line,  1 say upper( address )         
line ++
sele ntemp
go top

if eof()
   @ line,  2 say "Op.Balance B/F (No Transactions)"         
   if nOp > 0
      @ line, 52 say str( nOp, 10, 2 )         
      totdr += nOp
   else
      nOp := abs( nOp )
      @ line, 67 say str( nOp, 10, 2 )         
      totcr += nOp
   endif
   line ++
   line ++
   nTotCashBal += totdr
   nTotCashBal -= totcr
   close all
   return nil
endif

/*
if nOP != 0
@ line, 2 say "Op.Balance B/F"
if nOp > 0
@ line,52 say str(nOp,10,2)
totdr+= nOp
else
nOp := abs(nOp)
@ line,67 say str(nOp,10,2)
totcr+= nOp
endif
endif
*/

do while !eof()
   tr := tran_no
   if tran_date = seldate
      do while tran_no = tr .and. ( !eof() )
         mpage := pagecode
         sele subheads
         seek mpage
         if found()
            if !nTemp->processed
               if ntemp->byorto == 'By'
                  @ line, 01 say subs( ntemp->byorto + " " + rtrim( ltrim( proper( acchead ) ) ), 1, 46 )         
               elseif nTemp->byorto == 'To'
                  @ line, 01 say subs( ntemp->byorto + " " + rtrim( ltrim( proper( acchead ) ) ), 1, 46 )         
               endif
               sele ntemp
               @ line, if( debit > 0, 52, 67 ) say str( debit + credit, 10, 2 )         
               line ++
               if narration != "   "
                  @ line, 04 say "(" + rtrim( ltrim( proper( narration ) ) ) + ")"         
                  line ++
               endif
               if debit > 0
                  totdr  += debit
                  ti     += debit
               else
                  totcr  += credit
                  te     += credit
               endif                    // here it's fair
            elseif nTemp->processed
               if ntemp->byorto == 'To' .and. ( nTemp->pagecode != 1 )
                  if nTemp->narration != "   " .and. proper( rtrim( ltrim( nTemp->narration ) ) ) != 'Fee Paid'
                     @ line, 01 say subs( 'By ' + " " + rtrim( ltrim( proper( acchead ) ) ) + "(" + rtrim( ltrim( nTemp->narration ) ), 1, 41 ) + ')'         
                  else
                     @ line, 01 say subs( 'By ' + " " + rtrim( ltrim( proper( acchead ) ) ), 1, 41 )         
                  endif
               elseif nTemp->byorto == 'By' .and. nTemp->pagecode == 1          // cash a/c
                  sele nTemp
                  skip
                  loop                  // if processed, then it is a cash tran. by Cash not needed.
               elseif ( nTemp->pagecode == 1 .and. nTemp->byorto = 'To' )
                  sele nTemp
                  skip
                  loop
               elseif ntemp->byorto == 'By' .and. ( nTemp->pagecode != 1 )
                  if nTemp->narration != "   " .and. proper( rtrim( ltrim( nTemp->narration ) ) ) != 'Fee Paid'
                     @ line, 01 say subs( 'To ' + " " + rtrim( ltrim( proper( acchead ) ) ) + "(" + rtrim( ltrim( nTemp->narration ) ), 1, 41 ) + ')'         
                  else
                     @ line, 01 say subs( 'To ' + " " + rtrim( ltrim( proper( acchead ) ) ), 1, 41 )         
                  endif
               endif
               sele ntemp
               @ line, if( debit > 0, 67, 52 ) say str( debit + credit, 10, 2 )         
               line ++
               if credit > 0
                  totdr  += credit
                  ti     += credit
               else
                  totcr  += debit
                  te     += debit
               endif                    // here it's fair
            endif
         else
            @ line,  1 say "Account head not found"         
         endif
         sele nTemp
         skip
      enddo
   else
      do while tran_no = tr .and. ( !eof() )
         skip
      enddo
   endif
enddo
@ line, 54 say repli( "-", 8 )         
@ line, 69 say repli( "-", 8 )         
line ++

if nOP != 0
   @ line,  2 say "Op.Bal:" + str( nOp, 10, 2 ) + "  Cl.Bal:" + str( nOp + ( totdr - totcr ), 10, 2 )
endif

nDayCashBal += (totDr-totCr)
nTotCashBal += nOp+(totDr-totCr)

@ line, 52 say str( totdr, 10, 2 )
@ line, 67 say str( totcr, 10, 2 )                                   
@ line, 80 say "Bal : "                                              
@ line, 87 say rtrim( ltrim( str( totdr - totcr, 10, 2 ) ) )         
line ++
line ++

close all
return nil
//----------------------------------
function cpyfor( exp, fn )

local oalias := alias()
local fc     := fcount()
local cur    := 1
local subc
local tt
local trn
local oldr
local tm1
sele( oalias )
go top
do while .not. eof()
   cur := 1
   if eval( exp )
      trn  := tran_no
      oldr := recno()
      go top
      seek trn
      if found()
         do while tran_no = trn .and. ( !eof() )
            field->processed := .T.
            skip
         enddo
      else
         set device to screen
         set printer off
         set printer to
         msg( "Voucher index corrupt.., Vch No." + rtrim( ltrim( str( trn ) ) ) )
         quit
      endif
      go oldr
   endif
   skip
enddo
sele( oalias )
return nil

function reminc( ahead )

local inc
local exp
local bo
local bc
inc := at( "(INCOME)", ahead )
if inc != 0
   ahead := subs( ahead, 1, inc - 1 ) + subs( ahead, inc + 9 )
endif
inc := at( "INCOME", ahead )
if inc != 0
   ahead := subs( ahead, 1, inc - 1 ) + subs( ahead, inc + 9 )
endif
exp := at( "A/C", ahead )
if exp != 0
   ahead := subs( ahead, 1, exp - 1 ) + subs( ahead, exp + 3 )
endif
return ahead

//--------------------------
static function setpaths( address )

if address == 'City Center, Kayamkulam'
   set default to ( NetDrive() + ":\cManage\EDU\Kylm" )
elseif address == 'Advocates Lane, Karunagappally'
   set default to ( NetDrive() + ":\cManage\EDU\KPLY" )
elseif address == 'Pulliman Jun. (SOFTWARE)'
   set default to ( NetDrive() + ":\cManage\EDU\PLLSF" )
elseif address == 'Pulliman Jun. (HARDWARE)'
   set default to ( NetDrive() + ":\cManage\EDU\HW" )
endif
return .t.
//------------------------------

*+ EOF: EDU_1.PRG
