#include "std.ch"
#include "inkey.ch"

//----------------------------------------
// Create new company
// EasyAccounts v2.1 by Jasim A Basheer
//----------------------------------------

function AddCompany

local oldBox
local lRetVal
local ccName     := space( 45 )
local ccAbbrev   := ""
local ccPrefix   := space( 10 )
local ccHead     := space( 50 )
local ccAdd1     := space( 50 )
local ccAdd2     := space( 50 )
local ccAdd3     := space( 50 )
local cCompType  := 0
local lShowAdd   := .t.
local ccDir      := space( 8 )
local nResp      := 1
local cCommand   := ""
set key K_F2 to
oldBox := makebox( 02, 6, 22, 72, boxgetcolor() )
// OldBox should cover the region where scrcolor() says the title
makebox( 03, 6, 22, 72, boxgetcolor() )
setcolor( scrcolor() )
@ 02,  6 say padc( 'Create new company', 67 )         
setcolor( boxgetcolor() )
@ 04,  8 say "Company Title :"                    get ccName pict '@X'       
@ 05,  8 say "Other Heading (if any) : "                                     
@ 06,  8 say "Abbreviated Name :"                                            
@ 07,  8 say "Prefix (if any) : "                                            
@ 09,  8 say "Address : "                                                    
@ 10,  8 say "        : "                                                    
@ 11,  8 say "        : "                                                    
@ 13,  8 say "Company Type : "                                   
@ 14,  8 say "Show Complete Address in Reports ?"                            
@ 16,  8 say "Company Directory (only name) : "                              

footline( 20, 7, 65 )
read
@ 04,  8 say "Company Title : " + ccName         
ccName := rtrim( ltrim( ccName ) )
if len( ccName ) = 0
   unbox( oldBox )
   return nil       // Nothing happened. Eh?
endif

@ 05,  8 say "Other Heading (if any) :" get ccHead pict '@XS38'       
read
@ 05,  8 say "Other Heading (if any) : " + subs( ccHead, 1, 38 )         

ccAbbrev := padr( subs( ccName, 1, 30 ), 30 )

@ 06,  8 say "Abbreviated Name (max 30 chars.) :" get ccAbbrev pict '@XS27'       
read
@ 06,  8 say "Abbreviated Name (max 30 chars.) : " + subs( ccAbbrev, 1, 28 )         
ccAbbrev := rtrim( ltrim( ccAbbrev ) )

if len( ccAbbrev ) = 0
   unbox( oldBox )
   return nil       // Nothing happened. Eh?
endif

@ 07,  8 say "Prefix (if any) :" get ccPrefix pict '@X'       
read
@ 07,  8 say "Prefix (if any) : " + ccPrefix         

@ 09,  8 say "Address :" get ccAdd1 pict '@X'       
@ 10,  8 say "        :" get ccAdd2 pict '@X'       
@ 11,  8 say "        :" get ccAdd3 pict '@X'       
read
@ 09,  8 say "Address : " + ccAdd1         
@ 10,  8 say "        : " + ccAdd2         
@ 11,  8 say "        : " + ccAdd3         

@ 13,  8 say "Company Type : "

cCompType := menu_v("Company Type: ",;
                    "Accounts and Inventory",;
                    "Accounts only",;
                    "Accounts+Inventory+Service")
if cCompType = 0
  unbox(oldBox)
  close all
  return nil
elseif cCompType = 1
  cCompType := 'I'
  @ 13,  8 say "Company Type : [ Accounts and Inventory ]"
elseif cCompType = 2
  cCompType := 'A'
  @ 13,  8 say "Company Type : [ Accounts only ]"
elseif cCompType = 3
  cCompType := 'S'
  @ 13,  8 say "Company Type : [ Accounts, Inventory and Service ]"
endif

@ 14,  8 say "Show Complete Address in Reports ? <Y/N> "         
lShowAdd := opconfirm()

nResp := .f.
do while !nResp
   @ 16,  8 say "Company Directory (only name) :" get ccDir pict '@!'       
   read
   @ 16,  8 say "Company Directory (only name) : " + ccDir         
   ccDir := rtrim( ltrim( ccDir ) )
   if len( ccDir ) = 0
      unbox( oldBox )
      return nil
   endif
   nResp := !IsDirPresent( ccDir, NetDrive+":\EA\" + DataDir() )
   if !nResp
      @ 21, 08 say padc( 'Directory already exists. Specify another one', 64 )         
      tone( 300, 2 )
      tone( 330, 3 )
      tone( 312, 1 )
      @ 21, 08 say space( 64 )         
      ccDir := space( 8 )
   endif
enddo

nResp := 1

@ 21, 25 prompt "<Proceed>"
@ 21, 40 prompt "<Abort>"
menu to nResp
if nResp = 1
   @ 21, 08 say space( 64 )                                 
   @ 21, 08 say padc( 'Creating directory...', 64 )         
   ft_mkdir( NetDrive+":\EA\" + DataDir() + "\" + ccDir )
   @ 21, 08 say padc( 'Creating databases...', 64 )
   GWCopyFile( NetDrive+":\EA\EaSys\*.*", NetDrive +":\EA\" + DataDir() + "\" + ccDir,,.T. )
   GWCopyFile( NetDrive + ":\EA\" + DataDir() + "\SYSTEM.INT", NetDrive +":\EA\" + DataDir() + "\" + ccDir,,.T.)

   dbcreate( NetDrive+":\EA\"+ DataDir() + "\"+ ccDir+"\BOOKSTAT.DBF",;
           { ;
              { 'Date', 'D', 10, 0},;
              { 'Closed', 'L', 1, 0},;
              { 'Remarks', 'M', 10, 0},;
              { 'Sale','N',10,2 },;
              { 'Purchase','N',10,2 },;
              { 'Profit','N',10,2 },;
              { 'Discount','N',10,2 } ;
           } )

   if cCompType == 'S'     // With Service also
      dbcreate( NetDrive+":\EA\"+ DataDir() + "\"+ ccDir+"\SERVICE.DBF",;
           { ;
              { 'ID',       'N', 5, 0 },;
              { 'TYPE',     'C', 2, 0 },;
              { 'CUSTOMER', 'N', 5, 0 },;
              { 'ACC_SUB',  'N', 5, 0 },;
              { 'ENGINEER', 'N', 5, 0 },;
              { 'R_DATE',   'D',10, 0 },;
              { 'R_TIME',   'C', 4, 0 },;
              { 'A_DATE',   'D',10, 0 },;
              { 'A_TIME',   'C', 4, 0 },;
              { 'PROBLEM',  'M',10, 0 },;
              { 'SOLUTION', 'M',10, 0 },;
              { 'AMOUNT',   'N', 7, 0 },;
              { 'DBK_ID',   'N', 6, 0 },;
              { 'CLOSED',   'L', 1, 0 },;
              { 'NEW_NO',   'N', 5, 0 } ;
           } )

   endif

   // WE HAVE NOT INCLUDES THESE FILES IN the ;install.dat; installation
   // database repository since they includes the FPT memo, which renders
   // those dbs unable to be opened by normal ICREATE which uses only
   // native DBFNTX support. So, in order to eliminate the task of
   // including COMIX support too to ICREATE, for the time being,
   // the database is directly created here.

   @ 21, 08 say padc( 'Writing company information...', 64 )         
   use ( NetDrive+":\EA\"+DataDir()+"\SYSTEM.EA" )
   append blank
   field->COMP    := ccAbbrev
   field->COMPANY := ccName
   field->HEAD    := ccHead
   field->ADD1    := ccAdd1
   field->ADD2    := ccAdd2
   field->ADD3    := ccAdd3
   field->PREFIX  := ccPrefix

   if cCompType = 'A'
      field->reqinv := .f.
      field->reqserv := .f.
   elseif cCompType = 'I'
      field->reqinv := .t.
      field->reqserv := .f.
   else
      field->reqinv := .t.
      field->reqserv := .t.
   endif

   field->SHOWADD := lShowAdd
   field->dir     := ccDir
   field->count   := - 9999999
   close all

   if cCompType == 'S'      // In the case of normal companies,
   // the SETUP.PRG by default creates the cash account. But here,
   // we just ZAP and create every a/c from scratch..

      EUse( NetDrive+":\EA\"+ DataDir() + "\"+ ccDir+"\ACCOUNTS.DBF" )
      zap
   append blank
   field->id := 1
   field->account := "Cash"
   field->type := "Assets - Current"
   appe blank
   field->id := 2
   field->account := "Unallocated Service"
   field->type := "Service Engg."
   appe blank
   field->id := 3
   field->account := "Warranty A/C"
   field->type := "Income"
   field->group := .t.
   appe blank
   field->id := 4
   field->account := "Annual Maintenance A/C (AMC)"
   field->type := "Income"
   field->group := .t.
   appe blank
   field->id := 5
   field->account := "Annual Service A/C (ASC)"
   field->type := "Income"
   field->group := .t.
   use
   endif

   close all
   UOpen( NetDrive +":\EA\"+DataDir()+"\"+cCDir+"\VS_900.DBF" )
   @ 21, 08 say padc( "Company Creation Over." )         
   jAlert( "Company created successfully..." )
   lRetVal := .t.
else
   lRetVal := .f.
endif
unbox( oldbox )

return lRetVal

*+ EOF: INSTALL.PRG
