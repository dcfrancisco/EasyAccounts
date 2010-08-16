@echo off
rmake EA
echo.
echo.

if not errorlevel 1 BLINKER @EA

rem if not errorlevel 1 CALL CAUSEWAY @EA

if not errorlevel 1 CALL cpy


rem CAUSECMP EA.EXE    = To Compress the EXE before final distrib.
