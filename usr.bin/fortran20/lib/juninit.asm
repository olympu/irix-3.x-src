; File: juninit.text
; Date: 31-Jul-85

        ident   JUNINIT
        
        global  %_JUN
        
;
; %_JUN - Initialize the Juniper hardware
;

;
; Set Option Register:
;    Bit 0: 1=Fast mode
;    Bit 1: 1=Round twords zero on convert to integer
;    Bits 2-3: 00=Round twords nearest on rest
;    Bit 4: 1=Not Debug mode - overlapping execution
;
; Set Mask Register:
;    Bits 0-F: 1 to mask exception interrupts
;

%_JUN
        move.b     #$13,$8600.w    ; Set option reg
        move.b     #$FF,$8900.w    ; Set mask reg
        rts
        
        end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                        