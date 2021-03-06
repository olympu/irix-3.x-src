; File: passcomp.text
; Date: 18-Feb-83

        IDENT   PASSCOMP
        
        GLOBAL  %S_EQ,%S_NE,%S_LE,%S_GE,%S_LT,%S_GT
        
;
; String  compares:  The format for all string compares is as follows:
;
; Parameters: ST.L - Address of first string
;             ST.L - Address of second string
;
; Returns:    D0.B - Boolean result
;
; Scratches: Only D0
;

;
; $S_NE - String not equal
;

%S_NE 
        MOVEM.L D1/A0-A1,-(SP)
        MOVEQ   #1,D1           ; D1 get result if strings <>
        BRA.S   S_EQNE

;
; $S_EQ - String equal
;

%S_EQ 
        MOVEM.L D1/A0-A1,-(SP)
        CLR.W   D1              ; D1 gets result if strings <>
S_EQNE  MOVE.L  20(SP),A0       ; Address of first string
        MOVE.L  16(SP),A1       ; Address of second string
        CLR.W   D0
        MOVE.B  (A0)+,D0        ; Length of first string
        CMP.B   (A1)+,D0        ; Compared to length of second
        BNE.S   NOT_EQ
        BRA.S   EQ_TEST
EQ_LOOP CMPM.B  (A0)+,(A1)+
        BNE.S   NOT_EQ
EQ_TEST SUBQ.W  #1,D0
        BPL.S   EQ_LOOP
        EORI.W  #1,D1           ; They are equal. Negate result.
NOT_EQ  MOVE.B  D1,D0           ; Store the result
        MOVEM.L (SP)+,D1/A0-A1
        MOVE.L  (SP),8(SP)
        ADDQ.L  #8,SP
        RTS

;
; $S_GT - String greater than
;

%S_GT 
        MOVEM.L D1-D3/A0-A1,-(SP)
        MOVE.L  28(SP),A1       ; Address of first string
        MOVE.L  24(SP),A0       ; Address of second string
        MOVEQ   #1,D3           ; D3 = result if (A0) < (A1)
        BRA.S   STRCOMP

;
; $S_LE - String less than or equal
;

%S_LE 
        MOVEM.L D1-D3/A0-A1,-(SP)
        MOVE.L  28(SP),A1       ; Address of first string
        MOVE.L  24(SP),A0       ; Address of second string
        CLR.W   D3              ; D3 = result if (A0) < (A1)
        BRA.S   STRCOMP

;
; $S_LT - String less than
;

%S_LT 
        MOVEM.L D1-D3/A0-A1,-(SP)
        MOVE.L  28(SP),A0       ; Address of first string
        MOVE.L  24(SP),A1       ; Address of second string
        MOVEQ   #1,D3           ; D3 = result if (A0) < (A1)
        BRA.S   STRCOMP

;
; $S_GE - String grater than or equal
;

%S_GE 
        MOVEM.L D1-D3/A0-A1,-(SP)
        MOVE.L  28(SP),A0       ; Address of first string
        MOVE.L  24(SP),A1       ; Address of second string
        CLR.W   D3              ; D3 = result if (A0) < (A1)
STRCOMP CLR.W   D0
        MOVE.B  (A0)+,D0        ; D0 = length of (A0)
        CLR.W   D1
        MOVE.B  (A1)+,D1        ; D1 = length of (A1)
        CMP.W   D0,D1
        BLT.S   A1SHORT
        MOVE.W  D0,D2
        BRA.S   X_TEST
A1SHORT MOVE.W  D1,D2           ; D2 gets minimum length
        BRA.S   X_TEST
X_LOOP  CMPM.B  (A0)+,(A1)+
        BNE.S   X_NE
X_TEST  SUBQ.W  #1,D2
        BPL.S   X_LOOP
        CMP.W   D0,D1           ; Common part is equal
        BGT.S   X_DONE          ; So shorter one is less than
X_TRUE  EORI.W  #1,D3           ; Update result
        BRA.S   X_DONE
X_NE    BLS.S   X_TRUE
X_DONE  MOVE.B  D3,D0           ; Store result
        MOVEM.L (SP)+,D1-D3/A0-A1
        MOVE.L  (SP),8(SP)
        ADDQ.L  #8,SP
        RTS

        END

                                                                                                                                                                                                                                                                                                                                                                                                                                                            