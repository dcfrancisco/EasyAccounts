#COMMAND @ <row>, <col> GET <var> RADIO <boxes>     ;
           [<clauses,...>]                          ;
           [ANSWERS <answers>]                      ;
           [<horizontal:HORIZONTAL>]                ;
           [CHECK <char>]                           ;
           [RADIOCOLOR <color>]                     ;
      => @ <row>, <col> GET <var> NODISPLAY            ;
           [<clauses>]                                 ;
           SEND cargo:={"RADIO", <boxes>, <answers>,   ;
             NIL, <.horizontal.>, <char>, <color>, NIL, "NODISP"};
           SEND reader:={|oGet| GWRadioReader(oGet)} ; ;
           GWRadioDisp(ATAIL(Getlist), <var>)

#COMMAND @ <row>, <col> GET <var> CHECKBOX <boxes>  ;
           [<clauses,...>]                          ;
           [ANSWERS <answers>]                      ;
           [<horizontal:HORIZONTAL>]                ;
           [CHECK <char>]                           ;
           [CHECKCOLOR <color>]                     ;
      => @ <row>, <col> GET <var> NODISPLAY            ;
           [<clauses>]                                 ;
           SEND cargo:={"BOXES", <boxes>, <answers>,   ;
             NIL, <.horizontal.>, <char>, <color>, NIL, "NODISP"};
           SEND reader:={|oGet| GWCheckReader(oGet)} ; ;
           GWCheckDisp(ATAIL(Getlist), <var>)
