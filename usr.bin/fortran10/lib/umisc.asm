; File: umisc.text
; Date: 28-Nov-83
;

        upper
        ident   idmisc
        
        global  %_halt,%_haltf,%_goto,%_lstsg,%_iochk
        global  %_setior,%_panic,%_prloc
        extern  %w_x,%_break
        
        lower
        extern  _write
        upper
        
;
; System EQU's
;

iores   equ     26

;
; %_panic - write a panic message to the screen
;
; Parameters: D0.W - Length of message
;             A0.L - Address of message
;

%_panic
        movem.l d0-d7/a0-a6,-(sp)
        ext.l   d0
        move.l  d0,-(sp)        ; count
        move.l  a0,-(sp)        ; pointer to message
        move.l  #1,-(sp)        ; file descriptor 1, stdout
        lower
        jsr     _write
        upper
        adda.w  #12,sp          ; Discard parameters
        movem.l (sp)+,d0-d7/a0-a6
        rts
        
;
; %_HALT - Halt
;
; Parameters: ST.W - Halt error code
;

%_HALT
        move.l  (sp)+,a1        ; Discard return address
        move.w  (sp)+,d0        ; Get error code into d0.w
        ext.l   d0              ; Make it a long in d0
        movea.l 4(a5),a1        ; Get exit address of program
        jmp     (a1)            ; Exit the program

        
;
; %_PRLOC - Print "at location 0xDDDDDDDD<cr>"
;
; Parameters: ST.L - Location to be printed
;
; Preserves all registers.
;

%_PRLOC MOVEM.L D0-D7/A0-A6,-(SP)
        LEA     PRLMES,A0
        MOVEQ   #14,D0          ; D0 = Message length
        BSR.S   %_PANIC
        MOVE.L  12(A5),-(SP)    ; Address of Output
        MOVE.L  68(SP),-(SP)    ; Address to be printed
        MOVE.W  #8,-(SP)        ; Length
        JSR     %W_X            ; Print it
        LEA     PRLMES2,A0
        MOVEQ   #1,D0           ; D0 = Message length
        BSR.S   %_PANIC
        MOVE.L  10(A4),A0       ; Point to beginning of data area
        TST.W   (A0)+           ; Check the being debugged flag
        BEQ.S   NODEBUG
        ADDQ.W  #1,(A0)+        ; Indicate that not restartable
        MOVE.L  64(SP),-(SP)    ; Error address pushed
        JMP     %_BREAK         ; Never to return
NODEBUG MOVEM.L (SP)+,D0-D7/A0-A6
        MOVE.L  (SP)+,(SP)      ; Position return address
        RTS
        
PRLMES  DATA.B  'at location 0x'
PRLMES2 DATA.B  $0a,0           ; Final 0 is for alignment
        
;
; %_HALTF - Halt failing
;

%_HALTF
        move.w  #-1,-(sp)
        bsr.s   %_halt
        
;
; %_iochk - Check IORESULT - if not zero, error
;

%_iochk
        move.w  iores(a5),d0    ; D0 = ioresult
        bne.s   oops            ; <> 0 is an error
        rts
oops    lea     mess,a0         ;
        ext.l   d0              ;
        divu    #10,d0          ;
        ;add.b   d0,11(a0)       ;
        swap    d0              ;
        ;add.b   d0,12(a0)       ;
        moveq   #15,D0          ; D0 = Message length
        bsr     %_panic
        move.l  (sp),-(sp)      ; address of error
        jsr     %_prloc         ; print out the location
        jsr     %_haltf
        
mess    data.b  'IORESULT ERROR',$0a,0  ; Final 0 is for alignment
        
;
;%_setior - Set IORESULT variable
;
; Parameters: ST.W - IORESULT value
;

%_setior
        move.l  (sp)+,a0
        move.w  (sp)+,iores(a5)
        jmp     (a0)
        
;
; %_LSTSG - Returns the address of the last segment loaded.
;            Not utilized under IDRIS.
;

%_LSTSG
        RTS                     ; Noop since all loaded

;
; %_GOTO - Global GOTO code segment remover
;
; Parameters: ST.L - Unitialized under IDRIS
;

%_GOTO
        MOVE.L  (SP)+,(SP)
        RTS

        END

                               