; File: ugotoxy.text
; Date: 05-Apr-83

        ident   ugotoxy
        
        global  %_GOTOXY
        
;
; %_GOTOXY - gotoxy
;
; Parameters: ST.W - X coordinate
;             ST.W - Y coordinate
;
; All registers are preserved
;

%_GOTOXY
        move.l  (sp)+,(sp)
        rts

        end

                                                                                                                                                                                                                        