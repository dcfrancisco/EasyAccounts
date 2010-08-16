@echo off
rmake EA /dDEBUG
echo.
echo.

if not errorlevel 1 BLINKER @EABD

if not errorlevel 1 copy *.prg c:\

if not errorlevel 1 cpy




