; File: paspwr10.text
; Date: 17-Feb-83

        ident   paspwr10
        
        global  %_PWR10

;
; %_PWR10 - Power of Ten: returns 10 ^ i, 0 <= i <= 38
;           If i < 0, returns 0, if i > 38 returns +inf
;
; Parameters: ST.W - Integer
;
; Returns:    D0.L - Result
;
; Scratches: D0
;

%_PWR10
        move.l  a0,-(sp)
        move.w  8(sp),d0
        bmi.s   pwr_zer         ; < 0 --> Return 0
        cmp.w   #38,d0
        bgt.s   pwr_inf         ; > 38 --> return +inf
        lsl.w   #2,d0
        lea     tentbl,a0
        move.l  0(a0,d0.w),d0
pwr_rtn move.l  (sp)+,a0
        move.l  (sp),2(sp)
        addq.w  #2,sp
        rts
pwr_zer clr.l   d0
        bra.s   pwr_rtn
pwr_inf move.l  #$7f800000,d0
        bra.s   pwr_rtn
        page
;
; power of ten table...generated by double precision program
;

tentbl
        data.l  $3F800000      ; 1.0E0
        data.l  $41200000      ; 1.0E1
        data.l  $42C80000      ; 1.0E2
        data.l  $447A0000      ; 1.0E3
        data.l  $461C4000      ; 1.0E4
        data.l  $47C35000      ; 1.0E5
        data.l  $49742400      ; 1.0E6
        data.l  $4B189680      ; 1.0E7
        data.l  $4CBEBC20      ; 1.0E8
        data.l  $4E6E6B28      ; 1.0E9
        data.l  $501502F9      ; 1.0E10
        data.l  $51BA43B7      ; 1.0E11
        data.l  $5368D4A5      ; 1.0E12
        data.l  $551184E7      ; 1.0E13
        data.l  $56B5E621      ; 1.0E14
        data.l  $58635FA9      ; 1.0E15
        data.l  $5A0E1BCA      ; 1.0E16
        data.l  $5BB1A2BC      ; 1.0E17
        data.l  $5D5E0B6B      ; 1.0E18
        data.l  $5F0AC723      ; 1.0E19
        data.l  $60AD78EC      ; 1.0E20
        data.l  $6258D727      ; 1.0E21
        data.l  $64078678      ; 1.0E22
        data.l  $65A96816      ; 1.0E23
        data.l  $6753C21C      ; 1.0E24
        data.l  $69045951      ; 1.0E25
        data.l  $6AA56FA6      ; 1.0E26
        data.l  $6C4ECB8F      ; 1.0E27
        data.l  $6E013F39      ; 1.0E28
        data.l  $6FA18F08      ; 1.0E29
        data.l  $7149F2CA      ; 1.0E30
        data.l  $72FC6F7C      ; 1.0E31
        data.l  $749DC5AE      ; 1.0E32
        data.l  $76453719      ; 1.0E33
        data.l  $77F684DF      ; 1.0E34
        data.l  $799A130C      ; 1.0E35
        data.l  $7B4097CE      ; 1.0E36
        data.l  $7CF0BDC2      ; 1.0E37
        data.l  $7E967699      ; 1.0E38
        
        end
                                                                                                                                                                