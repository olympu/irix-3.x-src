; File: pastring.text
; Date: 16-Feb-83

        ident   PASTRING
        
        global  %_CAT,%_POS,%_COPY,%_DEL,%_INS
        
;
; %_CAT - Concatenate strings
;
; Parameters: ST.L - Address of 1st string
;             ST.L - Address of 2nd string
;             ...
;             ST.L - Address of Nth string
;             ST.L - Address to put result
;             ST.W - N
;
; Returns: D0.L - Address of result
;
; Scratches: Only D0
;

%_CAT
        movem.l d1-d2/a0-a2,-(sp)
        move.w  24(sp),d0       ; N
        move.l  26(sp),a0       ; Address of result
        lea     30(sp),a1       ; Addr of Addr of Nth parameter
        move.w  d0,d2           ; Incr A1 to point to ...
        lsl.w   #2,d2           ; ... the address of ...
        adda.w  d2,a1           ; ... the first parameter
        clr.w   d1              ; Length of result
        addq.l  #1,a0
        bra.s   c_test
c_loop  move.l  -(a1),a2        ; Address of Kth string
        clr.w   d2
        move.b  (a2)+,d2        ; Length of Kth string
        add.w   d2,d1           ; Update total length
        bra.s   c_test2
c_loop2 move.b  (a2)+,(a0)+
c_test2 subq.w  #1,d2
        bpl.s   c_loop2
c_test  subq.w  #1,d0           ; See if any more strings
        bpl.s   c_loop
        move.l  26(sp),a0       ; Address of result
        move.b  d1,(a0)         ; Store length of result
        lea     30(sp),a1       ; Addr of Addr of Nth parameter
        move.w  24(sp),d0       ; N
        lsl.w   #2,d0           ; Set A1 to the address of ...
        adda.w  d0,a1           ; ... the first parameter
        move.l  a0,d0           ; Set up function result
        move.l  20(sp),-(a1)    ; Set up return address
        move.l  a1,20(sp)       ; Set up final SP
        movem.l (sp)+,d1-d2/a0-a2
        move.l  (sp)+,sp
        rts

;
; %_POS - Position of one string in another
;
; Parameters: ST.L - Address of SubString
;             ST.L - Address of Main String
;
; Returns:    D0.W - Position
;
; Scratches: Only D0
;

%_POS
        movem.l d1-d2/a0-a2,-(sp)
        move.l  24(sp),a0       ; Address of Main String
        clr.w   d0
        move.b  (a0)+,d0        ; Length of Main String
        clr.w   d1              ; Result
pos_top move.l  28(sp),a1       ; Address of SubString
        clr.w   d2
        move.b  (a1)+,d2        ; Length of Substring
        cmp.w   d2,d0           ; Compare lengths
        bge.s   pos_try
        clr.w   d1              ; No match if substring shorter
        bra.s   posdone
pos_try move.l  a0,a2           ; Get fresh copy of main pointer
        addq.l  #1,d1           ; Update result counter
        bra.s   postest
posloop cmpm.b  (a2)+,(a1)+
        bne.s   trynext         ; No Match if not equal
postest subq.w  #1,d2
        bpl.s   posloop
        bra.s   posdone         ; Fall through means found it
trynext addq.l  #1,a0           ; Update main pointer for next try
        subq.w  #1,d0           ; Decrement remaining length of main string
        bra.s   pos_top
posdone move.w  d1,d0           ; Store the result
        move.l  20(sp),28(sp)   ; Set up the return address
        movem.l (sp)+,d1-d2/a0-a2
        addq.l  #8,sp
        rts

;
; %_COPY - Copy a substring
;
; Parameters: ST.L - Source string address
;             ST.W - Starting index
;             ST.W - Size to copy
;             ST.L - Address of result
;
; Returns: D0.L - Address of result
;
; Scratches: Only D0
;

%_COPY
        movem.l d1-d2/a0-a1,-(sp)
        move.l  20(sp),a0       ; Address for result
        move.w  24(sp),d0       ; Size to copy
        ble.s   y_zero          ; '' if size <= 0
        move.w  26(sp),d1       ; Index
        ble.s   y_zero          ; '' if index <= 0
        subq.w  #1,d1
        move.l  28(sp),a1       ; Address of source string
        clr.w   d2              ; to get length of source
        move.b  (a1)+,d2        ;
        sub.w   d1,d2
        ble.s   y_zero          ; '' if index > length(string)
        sub.w   d0,d2
        bge.s   y_ok            ; See if too little source
        add.w   d2,d0           ; Copy only what exists
y_ok    adda.w  d1,a1           ; Point to first byte to copy
        move.b  d0,(a0)+        ; Store result length
        bra.s   y_test
y_loop  move.b  (a1)+,(a0)+
y_test  subq.w  #1,d0
        bpl.s   y_loop
y_leave move.l  20(sp),d0       ; Set up function result
        move.l  16(sp),28(sp)   ; Set up return address
        movem.l (sp)+,d1-d2/a0-a1
        adda.w  #12,sp          ; Pop parameters
        rts
y_zero  clr.b   (a0)            ; Return null string
        bra.s   y_leave

;
; %_DEL - Delete a substring form a string
;
; Parameters: ST.L - Address of string
;             ST.W - Position to start deleting
;             ST.W - Number bytes to delete
;
; Scratches: D0,D1,D2,A0,A1
;

%_DEL
        move.l  (sp)+,a1        ; Pop return address
        move.w  (sp)+,d0        ; Pop Number bytes
        move.w  (sp)+,d1        ; Pop position
        move.l  (sp)+,a0        ; Pop string address
        move.l  a1,-(sp)
        move.w  d3,-(sp)        ; Save D3
        cmpi.w  #0,d0           ; Exit if bytes to delete
        ble.s   d_done          ; is <= 0
        cmpi.w  #0,d1           ; or if starting position
        ble.s   d_done          ; is <= 0
        clr.w   d2              ; Fetch ...
        move.b  (a0),d2         ; ... string size
        cmp.w   d1,d2           ; Exit if starting position
        blt.s   d_done          ; is > string size
        move.w  d1,d3           ; Compare position
        add.w   d0,d3           ; plus number bytes
        subq.w  #1,d3           ; minus 1
        sub.w   d2,d3           ; to string size
        ble.s   d_setup
        subq.w  #1,d1           ; Compute result size
        move.b  d1,(a0)         ; and store it
        bra.s   d_done
d_setup sub.w   d0,d2           ; Compute result size
        move.b  d2,(a0)         ; and store it
        adda.w  d1,a0           ; Point to first char to delete
        move.l  a0,a1
        adda.w  d0,a1           ; Point to first char to move
        bra.s   d_test
d_loop  move.b  (a1)+,(a0)+
d_test  addq.w  #1,d3
        ble.s   d_loop
d_done  move.w  (sp)+,d3        ; Restore D3
        rts

;
; %_INS - Insert a string in another
;
; Parameters: ST.L - Address of string to insert
;             ST.L - Address of main string
;             ST.W - Position in main string to insert
;
; Scratches: D0,D1,D2,A0,A1
;

%_INS
        move.l  (sp)+,d1        ; Pop return address
        move.w  (sp)+,d0        ; Pop index
        move.l  (sp)+,a1        ; Pop address of main string
        move.l  (sp)+,a0        ; Pop address of string to insert
        move.l  d1,-(sp)
        movem.l d3/a2/a3,-(sp)
        subq.w  #1,d0
        blt.s   i_done          ; Exit if index < 0
        clr.w   d1
        move.b  (a0)+,d1        ; Length of substring
        clr.w   d2
        move.b  (a1),d2         ; Length of Main String
        cmp.w   d0,d2           ; Exit if index
        blt.s   i_done          ; not in main string
        move.w  d1,d3
        add.w   d2,d3           ; Final string size
        move.b  d3,(a1)+
        move.l  a1,a2
        adda.w  d3,a2           ; points to last byte in result string +1
        move.l  a1,a3
        adda.w  d2,a3           ; points to last byte of main string +1
        sub.w   d0,d2           ; How many bytes to move
        bra.s   i_test
i_loop  move.b  -(a3),-(a2)
i_test  subq.w  #1,d2
        bpl.s   i_loop
        adda.w  d0,a1           ; Address of hole
        bra.s   i_test2
i_loop2 move.b  (a0)+,(a1)+
i_test2 subq.w  #1,d1
        bpl.s   i_loop2
i_done  movem.l (sp)+,d3/a2/a3
        rts

        end

                                                                                                                                                                                                                                                                                                                                                                                                                                                           