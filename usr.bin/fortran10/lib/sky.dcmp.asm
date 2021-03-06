; File: sky.dcmp.text
; Date: 15-Dec-83

        IDENT   SKY_DCMP
;
; COPYRIGHT 1981 RICHARD E. JAMES III

; COMPARE, MAX, MIN, DIM  FOR DOUBLE PRECISION.

        GLOBAL  %D_MAX,%D_MIN,%D_DIM
        EXTERN  %D_SUB

; MAX AND MIN RETURN ONE OF THEIR ARGUMENTS.
;   IF EITHER ARGUMENT IS A NAN, THEN IT IS RETURNED.
;   (MAX RETURNS THE LAST NAN; MIN RETURNS THE FIRST.)

;
; Parameters: ST.Q - First arg
;             ST.Q - Second arg
;
; Returns: D0/D1
;
; Scratches: Only D0,D1.
;

; DIM(X,Y)=MAX(0,X-Y)
;   PASCAL CALLABLE.

%D_DIM
;------
        move.l  16(sp),-(sp)
        move.l  16(sp),-(sp)
        move.l  16(sp),-(sp)
        move.l  16(sp),-(sp)
        jsr     %D_SUB
        move.l  (sp)+,8(sp)
        move.l  (sp)+,8(sp)
        clr.l   12(sp)
        clr.l   16(sp)
;      (FALL INTO MAX)

; FOR MAX AND MIN:
; INPUT:  2 DOUBLE PRECISION NUMBERS ON STACK
; OUTPUT: 1 DOUBLE PRECISION NUMBER ON STACK

%D_MAX
;------
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        BSR.S   %D_CMP
        BCC.S   MXOK    ;NO NANS
; ONE WAS A NAN OR UNORDERED INF:
        BCLR    #7,12(SP)      ;REMOVE SIGN OF FIRST
        CMPI.L  #$7FF00001,12(SP)
MXOK    BLT.S   MOTHR          ;USE OTHER ARGUMENT
        movem.l 12(sp),d0/d1
        move.l  (sp),16(sp)
        adda.w  #16,sp
        rts

%D_MIN
;------
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        MOVE.L  16(SP),-(SP)  ;COPY ARG
        BSR.S   %D_CMP
        BCC.S   MNOK    ;NO NANS
; ONE WAS A NAN OR UNORDERED INF:
        BCLR    #7,4(SP)     ;REMOVE SIGN
        CMPI.L  #$7FF00000,4(SP)
MNOK    BLE.S   MN9
MOTHR   MOVE.L  4(SP),12(SP) ;OTHER ARG
        MOVE.L  8(SP),16(SP) ;OTHER ARG
MN9     movem.l 12(sp),d0/d1
        move.l  (sp),16(sp)
        adda.w  #16,sp
        rts
        PAGE
; DOUBLE PRECISION FLOATING POINT COMPARE.
;
; INPUT:  2 DOUBLE PRECISION NUMBERS ON STACK
; OUTPUT: CONDITION CODES Z/N/V SET AS
;         IF SIGNED INTEGERS WERE JUST COMPARED.
;         CARRY FLAG SET IFF EITHER OPERAND IS A NAN.
;
; RESTRICTIONS: UNORDERED CASES (E.G.,
;       PROJECTIVE INFINITIES AND NANS)
;       PRODUCE RANDOM RESULTS.
;       A NAN, HOWEVER, DOES COMPARE
;       NOT EQUAL TO ANYTHING.
; REGISTER CONVENTIONS
;       D0/D1   FIRST OPERAND
;       D2/D3   SECOND OPERAND
;       D4      TEMP

NSAVED  EQU     5*4
CODES   EQU     34      ;CONDITION ANSWER

;;;;;;;;GLOBAL  %D_CMP
%D_CMP
;------
        MOVEM.L D0-D4,-(SP)  ;SAVE
        MOVEM.L NSAVED+4(SP),D0-D3
; (END OF ENTRY INTERFACE)
; REGISTERS NOW CONTAIN:
;       D0      FIRST ARGUMENT, MOST SIGNIFICANT 32 BITS
;       D1      FIRST ARGUMENT, LEAST SIGNIFICANT 32 BITS
;       D2      SECOND ARGUMENT, MOST SIGNIFICANT 32 BITS
;       D3      SECOND ARGUMENT, LEAST SIGNIFICANT 32 BITS

        MOVE.L  D2,D4
        AND.L   D0,D4          ;CMP SIGNS
        BMI.S   NBOTHMI 
        EXG     D0,D2          ;BOTH MINUS
        EXG     D1,D3
NBOTHMI CMP.L   D2,D0          ;MAIN COMPARE
        BNE.S   GOTCMP         ;GOT THE ANSWER
        MOVE.L  D1,D4
        SUB.L   D3,D4          ;COMPARE LOWERS
        BEQ.S   GOTCMP         ;ENTIRELY EQUAL
        ROXR.L  #1,D4
        ANDI.B  #$0A,CCR       ;CLEAR Z, IN CASE DIFFER BY 1 ULP
GOTCMP  
; *** The old way ***   ANDI.B  #$0E,CCR       ;CLEAR CARRY
; *** The old way ***   MOVE    SR,CODES(SP)
;;; Fixed to not use MOVE SR ... which is PRIVELEDGED in 68010
        beq.s   xEQ
xNE     bmi.s   xNEMI
xNEPL   bvs.s   xNEPLVS
xNEPLVC move.w  #$00,CODES(sp)
        bra.s   goon
xNEPLVS move.w  #$02,CODES(sp)
        bra.s   goon
xNEMI   bvs.s   xNEMIVS
xNEMIVC move.w  #$08,CODES(sp)
        bra.s   goon
xNEMIVS move.w  #$0A,CODES(sp)
        bra.s   goon
xEQ     bmi.s   xEQMI
xEQPL   bvs.s   xEQPLVS
xEQPLVC move.w  #$04,CODES(sp)
        bra.s   goon
xEQPLVS move.w  #$06,CODES(sp)
        bra.s   goon
xEQMI   bvs.s   xEQMIVS
xEQMIVC move.w  #$0C,CODES(sp)
        bra.s   goon
xEQMIVS move.w  #$0E,CODES(sp)
goon
;;; End of fix
        LSL.L   #1,D0
        LSL.L   #1,D2
        CMP.L   D2,D0
        BCC.S   CMP4
        EXG     D0,D2          ;FIND LARGER IN MAGNITUDE
CMP4    CMPI.L  #$FFE00000,D0
        BLS.S   CMP6           ;NO NAN
        MOVE.W  #$01,CODES(SP) ;C,NZ
        BRA.S   CMP8           ;ONE WAS A NAN
CMP6    OR.L    D1,D0
        OR.L    D2,D0
        OR.L    D3,D0
        BNE.S   CMP8           ;NON-ZERO
        MOVE.W  #$04,CODES(SP) ;-0=0
; (EXIT INTERFACE:)
CMP8    MOVEM.L (SP)+,D0-D4
        MOVE.L  (SP)+,12(SP)
        ADDA.W  #10,SP
        RTR

        END
                                                                                                                                                                                                                                                                                                                                                                                                                                