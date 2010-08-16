* Header    : BGEVENTS.CH
* Author    : Robert Franklin Lamping
* Company   : FourDim
* Email     : robert@winning.com        (Lifetime Email address)
* Date      : May 8, 1997
* Purpose   : Background Event Definition
//
#DEFINE BGE_NHANDLE         1
#DEFINE BGE_BACTION         2
#DEFINE BGE_BONDEACTIVATION 3
#DEFINE BGE_BONACTIVATION   4
#DEFINE BGE_LACTIVATED      5
#DEFINE BGE_CNAME           6
#DEFINE BGE_LACTIVE         7
#DEFINE BGE_NINTERVAL       8
#DEFINE BGE_BWHEN           9 
#DEFINE BGE_LKILLIT         10 
#DEFINE BGE_LKILLITAFTER    11
#DEFINE BGE_NSECONDS        12
#DEFINE BGE_NTIMER          13  
#DEFINE BGE_LINPROGRESS     14
#DEFINE BGE_NPOSLOCK        15
#DEFINE BGE_LEMPTY          16
#DEFINE BGE_LSTOP           17
#DEFINE BGE_LDIRECT         18
*
#DEFINE BGE_NLENGTH         18
*
#xcommand DEFINE [ BACKGROUNDEVENT][ BGEVENT ]  [<nEventHandle>] ;
        [ NAME     <cResname>  ] ;
        [ ACTION   <uAction >  ] ;
        [ ON ACTIVATE  <uOnActication > ] ;
        [ ON DEACTIVATE  <uDeAction >  ] ;
        [ INTERVAL <nInterval> ] ;
        [ <Direct : DIRECT >] ;
        [ <Inactive : INACTIVE >] ;
        [ WHEN     <bWhen>     ] ;
        [ <Once: ONCE>         ] ;
  =>;
  [<nEventHandle> := ] BGE_NEW( <(cResname)> , <{uAction}>, <nInterval>, <{bWhen}>, <.Once.>, <.Inactive.>, <{uDeAction}>, <{uOnActication}>, <.Direct.>)

#xtranslate ACTIVATE EVENT <xEvent>   => BGE_ACT( <xEvent> )
#xtranslate DEACTIVATE EVENT <xEvent> => BGE_DEACT( <xEvent> )
#xtranslate RELEASE EVENT <xEvent>    => BGE_RELEASE( <xEvent> )
/*
* Background Event System Definitions 
*/
#xtranslate BACKGROUND EVENTS STOP  => BGE_STOP()
#xtranslate BACKGROUND EVENTS START => BGE_START()
#xtranslate BACKGROUND EVENTS CLEAR => BGE_CLEAR()
//
#xtranslate BACKGROUND EVENTS AUTOACTIVATE => BGE_AUTOACTIVE() // clEvent():AutoActive()
#xtranslate BACKGROUND EVENTS INTERVAL <nInterval> => BGE_MAINTICK( <nInterval> ) //clEvent():nMainTick := <nInterval>
#xtranslate BACKGROUND EVENTS EXECUTE ALL => BGE_EXECALL( .T. ) //clEvent():lExecAll := .T.
#xtranslate BACKGROUND EVENTS EXECUTE ONE => BGE_EXECALL( .F. ) //clEvent():lExecAll := .F.

#xtranslate BACKGROUND EVENTS DEBUG OFF => BGE_DEBUG( .F. )
#xtranslate BACKGROUND EVENTS DEBUG ON => BGE_DEBUG( .T. )
//
#command DEFAULT <p> TO <val> [,<pn> TO <valn> ] ;
=> ;
<p> = iif( <p> = NIL, <val>, <p> ) ;
[;<pn> = iif( <pn> = NIL, <valn>, <pn> ) ]
//
#command ADJUST <p> TO <val> [,<pn> TO <valn> ] ;
=> ;
<p> := iif( <val> = NIL, <p>, <val> ) ;
[;<pn> := iif( <valn> = NIL, <pn> ,<valn> ) ]
//
#command ADJUST <p> TO <val> IFNONIL <checkval>  ;
=> ;
<p> := iif( <checkval> = NIL, <p>, <val> )
*
* EOH: BGEVENTS.CH
*