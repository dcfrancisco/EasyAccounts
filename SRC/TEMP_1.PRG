clear
set talk off
use test
x=1
do while .not. x > 100000
  appe blank
  repl bigstring with str(x,7,0)
  x=x+1
  @ 3,0 say str(x)
enddo