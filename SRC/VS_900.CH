/*
 *
 *   vs_900.ch
 *
 *   Standard definitions for various functions in VS_900.LIB
 *
 *   Copyright (c) 1992 by Vernon E. Six, Jr.
 *   All Rights Reserved World Wide
 *
 */



// Tue  04-21-1992  09:43:32
//
// Replacement for INDEX ON
//
#xcommand VS_INDEX ON <key> TO <file> [<u: UNIQUE>]    ;
      => VS_ShowNtx( <"file">, <(key)>, if( <.u.>,.T.,) )
 

// Fri  10-25-1991  10:17:43
//
// Replacement for FWRITE( n_Handle, string + CHR(13) + CHR(10) )
//
#xcommand FWriteLn( <handle>, <string> )   ;
      => FWrite( <handle>, <string> + CHR(13) + CHR(10) )

#xcommand FWriteLine( <handle>, <string> )   ;
      => FWrite( <handle>, <string> + CHR(13) + CHR(10) )


// Tue  11-12-1991  14:14:35
//
// Compile a code block at runtime
//
#xtranslate vs_compile( <string> ) ;
      => &( "{||" + <string> + "}" )


// Tue  11-19-1991  12:07:42
//
// Push Buttons
//
#xtranslate pbOK  => {" Ok "}

#xtranslate VS_YesNoBox( <string>, <width>, <color> ) ;
      => VS_Alert( {"",PADC(<string>, <width>),""}, {" Yes "," No "}, <color> )

#define pbNO  2
#define pbYES 1



// Sun  03-15-1992  19:09:56
//
// Scatter/Gather
//
#xtranslate  VS_SCATTER TO <array> [FIELDS <fields,...>]  ;
   => <array> := VS_Scatter( {<"fields">} )

#xtranslate  VS_GATHER FROM <array> [FIELDS <fields,...>]  ;
   => VS_Gather( <array>, {<"fields">} )




// Sun  04-26-1992  09:19:19
//
// Assume
//
#xtranslate ASSUME <memvar> IS <value> [IF MISSING] ;
   => <memvar> := IF( <memvar> == NIL, <value>, <memvar> )




// Sun  04-26-1992  09:24:26
//
// Tell a message and wait
//
#xtranslate VS_TELLMSG           ;
          [ PALETTE <palette>  ] ;
          [ SECONDS <seconds>  ] ;
          [ TEXT    <text,...> ] ;
   => VS_Tell( <palette>, <seconds>, <text> )



// Sun  04-26-1992  11:23:01
//
// Alert box message
//
#xtranslate VS_ALERT                ;
            TEXT    <text,...>      ;
            BUTTONS <buttons,...>   ;
          [ PALETTE <palette>     ] ;
          [ ROW     <row>         ] ;
          [ COL     <col>         ] ;
          [ WIDTH   <width>       ] ;
   => VS_Alert( {<text>}, {<buttons>}, <palette>, <row>, <col>, <width> )


// Sun  04-27-1992  17:40:03 - DLP
//
// Alert box message with a result.
//
#xtranslate VS_ALERT                ;
            RESULT  <result>        ;
            TEXT    <text,...>      ;
            BUTTONS <buttons,...>   ;
          [ PALETTE <palette>     ] ;
          [ ROW     <row>         ] ;
          [ COL     <col>         ] ;
          [ WIDTH   <width>       ] ;
   => <result> := VS_Alert( {<text>}, {<buttons>}, <palette>, <row>, <col>, <width> )



#define NULL ""

#xcommand vs_PutScr( [<parm>] ) => vs_PutScrn( <parm> )
#xcommand vs_FakeLck( [<parm>] ) => vs_FakeLock( <parm> )
#xcommand vs_GrabScr() => vs_GrabScrn()
            
#xtranslate vs_Hex2Dec( <hex> ) => vs_Base2Dec( 16, <hex> )




#define VSG_CALC    1
#define VSG_DATE    2
#define VSG_LIST    3
#define VSG_MEMO    4
#define VSG_RIGHT   5
#define VSG_SECRET  6
#define VSG_NORMAL  7





***
*   allow SAY and GET in same statement
*
#command @ <row>, <col> SAY    <sayxpr>           ;
                        [<sayClauses,...>]        ;
                        VS_GET  <var>             ;
                        [<getClauses,...>]        ;
                                                  ;
 => @ <row>, <col> SAY <sayxpr> [<sayClauses>]    ;
  ; @ <row>, <col> + len( <sayxpr> ) + 1 VS_GET <var> [<getClauses>]



***
*   @... VS_GET
*

#command @ <row>, <col> VS_GET <var>                ;
                        [NORMAL]                    ;
                        [MSGBLOCK <blkmsg>]         ;
                        [PICTURE <pic>]             ;
                        [VALID <valid>]             ;
                        [WHEN <when>]               ;
                        [SEND <msg>]                ;
                                                    ;
      => SetPos( <row>, <col> )                                          ;
       ; AAdd( GetList,                                                  ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )  )    ;
      ; atail(getlist):reader  := {|g|vs_Reader(g,VSG_NORMAL,,<blkmsg>)} ;
      ; atail(getlist):display()                                         ;
      [; ATail(GetList):<msg>]
      





***
*   @... VS_GET ... COLOR
*
#command @ <row>, <col> VS_GET <var>                     ;
                        [<clauses,...>]                  ;
                        COLOR <color>                    ;
                        [<moreClauses,...>]              ;
                                                         ;
      => @ <row>, <col> VS_GET <var> [<clauses>]         ;
                        SEND colorDisp(<color>)          ;
                        [<moreClauses>]




***
*   allow SAY and MEMO_GET in same statement
*
#command @ <top>, <left>, <bottom>, <right> SAY <sayxpr>  ;
                        [<sayClauses,...>]                ;
                        VS_GET  <var>                     ;
                        MEMO                              ;
                        [<getClauses,...>]                ;
                                                          ;
 => @ <top>, <left> SAY <sayxpr> [<sayClauses>]           ;
  ; @ <top>, <left> + len(<sayxpr>) + 1, <bottom>, <right> VS_GET <var> MEMO [<getClauses>]




***
*   @... VS_GET MEMO
*

#command @ <top>, <left>, <bottom>, <right> VS_GET <var>                ;
                        MEMO                                            ;
                        [MSGBLOCK <blkmsg>]                             ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( <top>, <left> )                                        ;
       ; AAdd( GetList,                                                 ;
               vs_MemoObj():New( <top>, <left>, <bottom>, <right>,      ;
                   {|_1|if(pcount()=0,<var>,<var>:=_1)}, <(var)> )  )   ;
      ; atail(getlist):reader  := {|g|vs_Reader(g,VSG_MEMO,,<blkmsg>)}  ;
      ; atail(getlist):display()                                        ;
      [; ATail(GetList):<msg>]



***
*   @... VS_GET ... MEMO ... COLOR
*

#command @ <top>, <left>, <bottom>, <right> VS_GET <var>                ;
                        MEMO                                            ;
                        COLOR <color>                                   ;
                        [MSGBLOCK <blkmsg>]                             ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( <top>, <left> )                                        ;
       ; AAdd(                                                          ;
               GetList,                                                 ;
               vs_MemoObj():New( <top>, <left>, <bottom>, <right>,      ;
                   {|_1|if(pcount()=0,<var>,<var>:=_1)}, <(var)> )  )   ;
      ; atail(getlist):reader  := {|g|vs_Reader(g,VSG_MEMO,,<blkmsg>)}  ;
      ; atail(getlist):colorspec := <color>                             ;
      ; atail(getlist):display()                                        ;
      [; ATail(GetList):<msg>]



***
*   @... VS_GET SECRET
*

#command @ <row>, <col> VS_GET <var>                                      ;
                        SECRET <char>                                     ;
                        [MSGBLOCK <blkmsg>]                               ;
                        [VALID <valid>]                                   ;
                        [WHEN <when>]                                     ;
                        [SEND <msg>]                                      ;
                                                                          ;
      => SetPos( <row>, <col> )                                           ;
       ; AAdd(                                                            ;
               GetList,                                                   ;
               vs_SecretObj():New( <row>, <col>,                          ;
                   {|_1|if(pcount()=0,<var>,<var>:=_1)}, <(var)>,, alltrim(<var>) )  )     ;
      ; atail(getlist):reader   := {|g|vs_Reader(g,VSG_SECRET,,<blkmsg>)} ;
      ; atail(getlist):block    := { |_1|if(_1=nil,replicate( <char> ,len(<var>)), ( <var>:=_1,replicate( <char>,len(<var>)) ) )} ;
      ; atail(getlist):passchar := <char>                               ;
      ; atail(getlist):display()                                        ;
      [; ATail(GetList):<msg>]
      

***
*   @... VS_GET ... SECRET ... COLOR
*
#command @ <row>, <col> VS_GET <var>                     ;
                        SECRET                           ;
                        [<clauses,...>]                  ;
                        COLOR <color>                    ;
                        [<moreClauses,...>]              ;
                                                         ;
      => @ <row>, <col> VS_GET <var> SECRET [<clauses>]  ;
                        SEND colorDisp(<color>)          ;
                        [<moreClauses>]
      



***
*   @... VS_GET ... CALC
*
#command @ <row>, <col> VS_GET <var>                                        ;
                        [<clauses,...>]                                     ;
                        CALC                                                ;
                        [MSGBLOCK <blkmsg>]                                   ;
                        [<moreClauses,...>]                                 ;
                                                                            ;
      => @ <row>, <col> GET <var>                                           ;
                        [<clauses>]                                         ;
                        SEND reader := { |g| vs_Reader(g,VSG_CALC,,<blkmsg>) } ;
						[<moreClauses>]



***
*   @... VS_GET ... RIGHT
*
#command @ <row>, <col> VS_GET <var>                                        ;
                        [<clauses,...>]                                     ;
                        RIGHT                                               ;
                        [MSGBLOCK <blkmsg>]                                   ;
                        [<moreClauses,...>]                                 ;
                                                                            ;
      => @ <row>, <col> GET <var>                                           ;
                        [<clauses>]                                         ;
                        SEND reader := { |g| vs_Reader(g,VSG_RIGHT,,<blkmsg>) } ;
						[<moreClauses>]



***
*   @... VS_GET ... DATE
*
#command @ <row>, <col> VS_GET <var>                                    ;
						[<clauses,...>] 								;
                        DATE                                            ;
                        [MSGBLOCK <blkmsg>]                               ;
                        [<moreClauses,...>]                             ;
																		;
	  => @ <row>, <col> GET <var>										;
						[<clauses>] 									;
                        SEND reader := { |g| vs_Reader(g,VSG_DATE,,<blkmsg>) } ;
						[<moreClauses>]



***
*   @... VS_GET ... LIST
*
#command @ <row>, <col> VS_GET <var>                                    ;
						[<clauses,...>] 								;
                        LIST <choices>                                  ;
                        [MSGBLOCK <blkmsg>]                             ;
                        [<moreClauses,...>]                             ;
																		;
	  => @ <row>, <col> GET <var>										;
						[<clauses>] 									;
                        SEND reader := { |g| vs_Reader(g,VSG_LIST,<choices>,<blkmsg>) } ;
						[<moreClauses>]


#command VS_READ TIME <secs>  ;
      => vs_ReadTime( <secs>, .t. )       ;
      ; ReadModal(GetList)                ;
      ; clear typeahead                   ;
      ; vs_ReadTime( 0, .t. )             ;

#command VS_READ SAVE                                                      ;
      => ReadModal(GetList) ; clear typeahead

#command VS_READ                                                           ;
      => ReadModal(GetList) ; clear typeahead                           ;
       ; GetList := {}




*****
* Shrink an array by one element
*****
#xtranslate vs_aShrink( <array> ) ;
    => ADEL ( <array>, LEN( <array> ) )        ;
    ;  ASIZE( <array>, LEN( <array> ) - 1 )






// End of File          
