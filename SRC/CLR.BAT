@ECHO OFF
ECHO.
ECHO     Clearing temporary files...
DEL *.ZIP
DEL *.BIF
DEL *.OBJ
DEL *.TXT
DEL *.PPO
DEL *.MAP
DEL *.EXE
DEL *.NTX
DEL ERRORS.DAT
DEL *.BAK
DEL *.OLD
ECHO.
ECHO       Proceeding to backup...
pkzip eaback *.* -ex
zip2exe eaback
copy eaback.exe C:\Drive2\ea_back\ea
copy eaback.exe D:\
