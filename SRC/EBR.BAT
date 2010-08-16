@echo off
rmake EA /dDEBUG
echo.
echo.

if not errorlevel 1 BLINKER @EABRD

copy *.prg c:\

if not errorlevel 1 cpy




