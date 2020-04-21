



































































































	.globl	_sin
_sin:

	.globl	%_SIN
%_SIN:		linkw	a6,#-4
|	f1 = x, d1 = multiple
		movl	a6@(8),d0
		movl	d0,	0x8000+	0x100+0x10+0x0:w
|	if abs(x) < .7584
		bclr	#0x1F,d0
		movl	d0,	0x8000+	0x100+0x20+0x0:w
		movl	#0x3F490FF9,	0x8000+	0x3200+0x20+0x0:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%MYS_SNCS2A
|	d1 = multiple = 0
		clrl	d1
		bras	%MYS_SNCS3A
|	else
|	x := %mypi_reduce(x, multiple)
|
%MYS_SNCS2A:
|	arg + POFOUR
		movl	#0x3F490FDB,	0x8000+	0xa00+0x10+0x0:w
|	ff = x = (arg+POFOUR)*TWOOP
		movl	#0x3F22F983,	0x8000+	0x1600+0xf0+0x0:w
|	if(x < 0.0)
		movb	d0,	0x8000+	0x3400+0xf0+0xf:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%MYSPI_REDUCE8A

		movl	#0x3F800000,	0x8000+	0xe00+0xf0+0x0:w
|	f2 = multiple = trunc(x-1)
%MYSPI_REDUCE8A:
		movb	d0,	0x8000+0x2900+0x20+0xf:w
		movl		0x8000+	0x200+0x20+0x0:w,d1
		movb	d0,	0x8000+0x2b00+0x20+0x2:w
|	f3 = i = trunc(arg)
		movb	d0,	0x8000+0x2900+0x30+0x1:w
		movb	d0,	0x8000+0x2b00+0x30+0x3:w
|	f1 = x = arg - i
		movb	d0,	0x8000+0x2300+0x10+0x1:w
		movb	d0,	0x8000+0x1100+0x10+0x3:w
|	f3 = i - multiple * (POTWO & 0xffffffff)
		clrl		0x8000+0x400+0x00+0x0:w
		movl	#0x3FF921FB,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x30+0xf:w
|	f1 = x - multiple * y	
		movl	#0x4611A400,	0x8000+0x400+0x00+0x0:w
		movl	#0x3E95110B,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x10+0xf:w
|	f1 = f1 + f3
		movb	d0,	0x8000+0xd00+0x10+0x3:w
		movb	d0,	0x8000+0x2500+0x10+0x1:w
|	f1 = x = mypi_reduce
%MYS_SNCS3A:
|	f2 = x**2
		movb	d0,	0x8000+	0x1600+0x10+0x1:w
		movb	d0,	0x8000+	0x500+0x20+0xf:w
|	d1 = multiple = multiple + sin_cos_flag (== 0 for sin)
|	if odd(multiple)
		movb	d1,d0
		andw	#0x1,d0
		beqs	%MYS_SNCS90
|	then cos
		movl	#0xBAB1FCEB,	0x8000+	0x1600+0x20+0x0:w
		movl	#0x3D2A9DD3,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0xBEFFFFCB,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0x3F800000,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x500+0x10+0xf:w
		subql	#1,d1
		bras	%MYS_SNCSC4
%MYS_SNCS90:
|	else sin
		movl	#0xB94C7DC9,	0x8000+	0x1600+0x20+0x0:w
		movl	#0x3C088302,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0xBE2AAAA0,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movb	d0,	0x8000+	0x1600+0x10+0xf:w
		movb	d0,	0x8000+0xb00+0x10+0xf:w
%MYS_SNCSC4:
		andw	#0x2,d1
		beqs	%MYS_SNCSDE
		movb	d0,	0x8000+0x2f00+0x10+0x1:w
%MYS_SNCSDE:

		movl		0x8000+	0x100+0x10+0x0:w,d0
		unlk	a6
		rts


	.globl	_cos
_cos:

	.globl	%_COS
%_COS:			linkw	a6,#-4
|	f1 = x, d1 = multiple
		movl	a6@(8),d0
		movl	d0,	0x8000+	0x100+0x10+0x0:w
|	if abs(x) < .7584
		bclr	#0x1F,d0
		movl	d0,	0x8000+	0x100+0x20+0x0:w
		movl	#0x3F490FF9,	0x8000+	0x3200+0x20+0x0:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%MYC_SNCS2A
|	d1 = multiple = 0
		clrl	d1
		bras	%MYC_SNCS3A
|	else
|	x := %mypi_reduce(x, multiple)
|
%MYC_SNCS2A:
|	arg + POFOUR
		movl	#0x3F490FDB,	0x8000+	0xa00+0x10+0x0:w
|	ff = x = (arg+POFOUR)*TWOOP
		movl	#0x3F22F983,	0x8000+	0x1600+0xf0+0x0:w
|	if(x < 0.0)
		movb	d0,	0x8000+	0x3400+0xf0+0xf:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%MYCPI_REDUCE8A

		movl	#0x3F800000,	0x8000+	0xe00+0xf0+0x0:w
|	f2 = multiple = trunc(x-1)
%MYCPI_REDUCE8A:
		movb	d0,	0x8000+0x2900+0x20+0xf:w
		movl		0x8000+	0x200+0x20+0x0:w,d1
		movb	d0,	0x8000+0x2b00+0x20+0x2:w
|	f3 = i = trunc(arg)
		movb	d0,	0x8000+0x2900+0x30+0x1:w
		movb	d0,	0x8000+0x2b00+0x30+0x3:w
|	f1 = x = arg - i
		movb	d0,	0x8000+0x2300+0x10+0x1:w
		movb	d0,	0x8000+0x1100+0x10+0x3:w
|	f3 = i - multiple * (POTWO & 0xffffffff)
		clrl		0x8000+0x400+0x00+0x0:w
		movl	#0x3FF921FB,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x30+0xf:w
|	f1 = x - multiple * y	
		movl	#0x4611A400,	0x8000+0x400+0x00+0x0:w
		movl	#0x3E95110B,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x10+0xf:w
|	f1 = f1 + f3
		movb	d0,	0x8000+0xd00+0x10+0x3:w
		movb	d0,	0x8000+0x2500+0x10+0x1:w
|	f1 = x = mypi_reduce
%MYC_SNCS3A:
|	f2 = x**2
		movb	d0,	0x8000+	0x1600+0x10+0x1:w
		movb	d0,	0x8000+	0x500+0x20+0xf:w
|	d1 = multiple = multiple + sin_cos_flag (== 1 for cos)
		addql	#1,d1
|	if odd(multiple)
		movb	d1,d0
		andw	#0x1,d0
		beqs	%MYC_SNCS90
|	then cos
		movl	#0xBAB1FCEB,	0x8000+	0x1600+0x20+0x0:w
		movl	#0x3D2A9DD3,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0xBEFFFFCB,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0x3F800000,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x500+0x10+0xf:w
		subql	#1,d1
		bras	%MYC_SNCSC4
%MYC_SNCS90:
|	else sin
		movl	#0xB94C7DC9,	0x8000+	0x1600+0x20+0x0:w
		movl	#0x3C088302,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0xBE2AAAA0,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movb	d0,	0x8000+	0x1600+0x10+0xf:w
		movb	d0,	0x8000+0xb00+0x10+0xf:w
%MYC_SNCSC4:
		andw	#0x2,d1
		beqs	%MYC_SNCSDE
		movb	d0,	0x8000+0x2f00+0x10+0x1:w
%MYC_SNCSDE:

		movl		0x8000+	0x100+0x10+0x0:w,d0
		unlk	a6
		rts

	.globl	%_ATAN
%_ATAN:

		linkw	a6,#-16
|	d1 = arg
		movl	a6@(8),d1
|	f1 = x = abs(arg)
		movl	d1,d0
		bclr	#0x1F,d0
		movl	d0,	0x8000+	0x100+0x10+0x0:w
|	if x < 1.0
		movl	#0x3F800000,	0x8000+	0x3200+0x10+0x0:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%_ATAN2A
|	d0 = Reduced = FALSE
		clrb	d0
		bras	%_ATAN3C
%_ATAN2A:
|	else
|	f1 = x = 1/x
		movl	#0x3F800000,	0x8000+0x1f00+0x10+0x0:w
|	d0 = Reduced = TRUE
		moveq	#1,d0
%_ATAN3C:
|	f2 = xsq = x**2
		movb	d0,	0x8000+	0x1600+0x10+0x1:w
		movb	d0,	0x8000+	0x500+0x20+0xf:w
|	f1 = x = big long calculation
|	f3 = numerator
		movl	#0xBC2BFF24,	0x8000+	0x1600+0x20+0x0:w
		movl	#0xBF2CDDBC,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movl	#0xBF9B537A,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+	0x1600+0x20+0xf:w
		movb	d0,	0x8000+	0x1600+0x10+0xf:w
		movb	d0,	0x8000+	0x500+0x30+0xf:w
|	f2 = denominator
		movl	#0x4086B4EA,	0x8000+	0xa00+0x20+0x0:w
		movb	d0,	0x8000+0x1700+0x20+0xf:w
		movl	#0x4068FDB6,	0x8000+0xb00+0x20+0x0:w
|	f3 = quotient
		movb	d0,	0x8000+0x1b00+0x30+0x2:w
|	finally, f1 = x
		movb	d0,	0x8000+0xb00+0x10+0x3:w
|	if Reduced
		tstb	d0
		beqs	%_ATANC2
|	if arg < 0
		andl	#0x80000000,d1
		beqs	%_ATANB4
|	atan = x - PIOVER2
		movl	#0x3FC90FDB,	0x8000+0xf00+0x10+0x0:w
		bras	%_ATAND6
%_ATANB4:
|	else atan = x - PIOVER2
		movl	#0x3FC90FDB,	0x8000+0x1300+0x10+0x0:w
		bras	%_ATAND6
%_ATANC2:
|	else if arg < 0
		andl	#0x80000000,d1
		beqs	%_ATAND2
|	atan = -x
		movb	d0,	0x8000+0x2f00+0x10+0x1:w
		bras	%_ATAND6
%_ATAND2:
|	else atan = x
%_ATAND6:
		unlk	a6
		rtd	#4
	.globl	%_EXP
%_EXP:

		linkw	a6,#-40
|	f1 = arg
		movl	a6@(8),d0
		movl	d0,	0x8000+	0x100+0x10+0x0:w
|	f2 = upper = arg & 0xfffff000
		andl	#0xFFFFF000,d0
		movl	d0,	0x8000+	0x100+0x20+0x0:w
|	f3 = lower = arg - upper
		movb	d0,	0x8000+	0xe00+0x10+0x2:w
		movb	d0,	0x8000+	0x500+0x30+0xf:w
|	f2 = x = upper * UPPER_LOG_2_INV
		movl	#0x3FB8A000,	0x8000+0x1700+0x20+0x0:w
|	d1 = ff = multiple = round(x)
		movb		0x8000+	0x600+0x00+0x0:w,d0
		andb	#0xF1,	0x8000+	0x600+0x00+0x0:w
		movb	d0,	0x8000+	0x2800+0x20+0x2:w
		movb	d0,	0x8000+	0x600+0x00+0x0:w
		movl		0x8000+	0x200+0xf0+0x0:w,d1
|	f2 = x = long calculation
|	f2 = x - multiple
		movb	d0,	0x8000+0x2700+0xf0+0xf:w
		movb	d0,	0x8000+0xf00+0x20+0xf:w
|	f1 = lower*UPPER_LOG_2_INV + arg*LOWER_LOG_2_INV
		movl	#0x3FB8A000,	0x8000+0x1700+0x30+0x0:w
		movl	#0x39A3B296,	0x8000+0x1700+0x10+0x0:w
		movb	d0,	0x8000+0xb00+0x10+0x3:w
|	f2 = x = f2 + f1
		movb	d0,	0x8000+0xb00+0x20+0x1:w
|	f1 = x**2
		movb	d0,	0x8000+	0x1600+0x20+0x2:w
		movb	d0,	0x8000+	0x500+0x10+0xf:w
|	f2 = p = stuff
		movl	#0x3D6C5665,	0x8000+	0x1600+0x10+0x0:w
		movl	#0x40E6E1AC,	0x8000+	0xa00+0xf0+0x0:w
		movb	d0,	0x8000+0x1700+0x20+0xf:w
|	f1 = q = more stuff
		movl	#0x41A68BBB,	0x8000+0xb00+0x10+0x0:w
|	f2 = r.r = p's and q's
		movb	d0,	0x8000+0xf00+0x10+0x2:w
		movb	d0,	0x8000+0x1b00+0x20+0x1:w
		movl	#0x3F000000,	0x8000+0xb00+0x20+0x0:w
|	exp = d1 = r.l = r.l + (multiple+1) << 23
		addqw	#1,d1
		movl	#23,d0
		asll	d0,d1
		movl		0x8000+	0x100+0x20+0x0:w,d0
		addl	d0,d1
		movl	d1,	0x8000+	0x100+0x10+0x0:w
endexp:
		unlk	a6
		rtd	#4
	.globl	%_LN
%_LN:

		linkw	a6,#-16
|	d0 = x
		movl	a6@(8),d0
|	d1 = n = (x&0x7f80)>>23
		movw	#0x7F80,d1
		swap	d0
		andw	d0,d1
		asrw	#7,d1
		subw	#0x7F,d1
|	f1 = x = (x&0x807fffff)|0x3f800000
		andw	#0x807F,d0
		orw	#0x3F80,d0
		swap	d0
		movl	d0,	0x8000+	0x100+0x10+0x0:w
|	if (x > 1.414213)
		movl	#0x3FB504EE,	0x8000+	0x3200+0x10+0x0:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bles	%_LN66
|	then f1 = x = x/2
		movl	#0x40000000,	0x8000+0x1b00+0x10+0x0:w
|	and d1 = n = n+1
		addqw	#1,d1
%_LN66:
|	f1 = x = (x-1)/(x+1)
		movl	#0x3F800000,	0x8000+0xf00+0x10+0x0:w
		movl	#0x40000000,	0x8000+	0xa00+0x10+0x0:w
		movb	d0,	0x8000+0x1b00+0x10+0xf:w
|	f2 = xsq = x**2
		movb	d0,	0x8000+	0x1600+0x10+0x1:w
		movb	d0,	0x8000+	0x500+0x20+0xf:w
|	ln = long calculation
|	f3 = n
		extl	d1
		movl	d1,	0x8000+0x2700+0x30+0x0:w
|	f3 = n*LOG_2
		movl	#0x3F317218,	0x8000+0x1700+0x30+0x0:w
|	f3 = f3 + x + x
		movb	d0,	0x8000+0xb00+0x30+0x1:w
		movb	d0,	0x8000+0xb00+0x30+0x1:w
|	
		movl	#0x3FD4114D,	0x8000+0x1200+0x20+0x0:w
		movl	#0x3F8D5EED,	0x8000+0x1e00+0xf0+0x0:w
		movb	d0,	0x8000+0x1700+0x20+0xf:w
		movb	d0,	0x8000+0x1700+0x10+0x2:w
		movb	d0,	0x8000+0xb00+0x10+0x3:w
		unlk	a6
		rtd	#4

	.globl	_sqrt
_sqrt:

	.globl	%_SQRT
%_SQRT:			linkw	a6,#-20
|			moveml	#<d5,d6,d7>,a7@-
			moveml	#0x0700,a7@-
%_SQRT8:		movl	a6@(8),	0x8000+	0x3400+0x00+0x0:w
%_SQRTE:		tstb		0x8000+	0x700+0x00+0x0:w
%_SQRT12:		bnes	%_SQRT1C
%_SQRT14:		clrl		0x8000+	0x100+0x10+0x0:w
%_SQRT18:		bra	%_SQRT102
%_SQRT1C:		movl	a6@(8),a6@(-20)
%_SQRT22:		movw	#0x7F80,d0
%_SQRT26:		andw	a6@(-20),d0
%_SQRT2A:		extl	d0
			asrl	#7,d0
%_SQRT30:		movw	d0,d7
%_SQRT32:		subw	#0x7F,d7
%_SQRT36:		movl	#0x807FFFFF,d0
%_SQRT3C:		andl	a6@(-20),d0
%_SQRT40:		orl	#0x3F800000,d0
%_SQRT46:		movl	d0,a6@(-20)
%_SQRT4A:		movl	d0,d5
%_SQRT4C:		movl	d7,d1
%_SQRT4E:		andw	#0x1,d1
%_SQRT52:		beqs	%_SQRT80
%_SQRT54:		movl	d5,	0x8000+	0x100+0x10+0x0:w
%_SQRT58:		movl	#0x40000000,	0x8000+0x1b00+0x10+0x0:w
%_SQRT60:		movl		0x8000+	0x100+0x10+0x0:w,d5
%_SQRT64:		addqw	#1,d7
%_SQRT66:		movl	#0x3F1714DD,	0x8000+	0x100+0x10+0x0:w
%_SQRT6E:		movl	d5,	0x8000+0x1700+0x10+0x0:w
%_SQRT72:		movl	#0x3ED5A957,	0x8000+0xb00+0x10+0x0:w
%_SQRT7A:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_SQRT7E:		bras	%_SQRT98
%_SQRT80:		movl	#0x3ED5A957,	0x8000+	0x100+0x10+0x0:w
%_SQRT88:		movl	d5,	0x8000+0x1700+0x10+0x0:w
%_SQRT8C:		movl	#0x3F1714DD,	0x8000+0xb00+0x10+0x0:w
%_SQRT94:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_SQRT98:		movl	d5,	0x8000+	0x100+0x10+0x0:w
%_SQRT9C:		movl	d6,	0x8000+0x1b00+0x10+0x0:w
%_SQRTA0:		movl	d6,	0x8000+0xb00+0x10+0x0:w
%_SQRTA4:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_SQRTA8:		movl	#0x40800000,	0x8000+	0x100+0x10+0x0:w
%_SQRTB0:		movl	d5,	0x8000+0x1700+0x10+0x0:w
%_SQRTB4:		movl	d6,	0x8000+0x1b00+0x10+0x0:w
%_SQRTB8:		movl	d6,	0x8000+0xb00+0x10+0x0:w
%_SQRTBC:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_SQRTC0:		movl	d7,d0
%_SQRTC2:		extl	d0
			asrl	#1,d0
%_SQRTC8:		movw	d0,d7
%_SQRTCA:		subqw	#2,d7
%_SQRTCC:		movl	d6,a6@(-20)
%_SQRTD0:		tstw	d7
%_SQRTD2:		blts	%_SQRTE6
%_SQRTD4:		movl	d7,d0
%_SQRTD6:		extl	d0
%_SQRTD8:		mulsl	#0x800000,d0
%_SQRTE0:		addl	d0,a6@(-20)
%_SQRTE4:		bras	%_SQRTFC
%_SQRTE6:		movw	d7,d0
%_SQRTE8:		negw	d0
%_SQRTEA:		movw	d0,d7
%_SQRTEC:		movl	d7,d0
%_SQRTEE:		extl	d0
%_SQRTF0:		mulsl	#0x800000,d0
%_SQRTF8:		subl	d0,a6@(-20)
%_SQRTFC:		movl	a6@(-20),	0x8000+	0x100+0x10+0x0:w

		movl		0x8000+	0x100+0x10+0x0:w,d0

|			moveml	a7@+,#<d5,d6,d7>
%_SQRT102:		moveml	a7@+,#0x00e0

		unlk	a6
		rts

%S_ASNCS:		linkw	a6,#-8
|			moveml	#<d6,d7>,a7@-
			moveml	#0x0300,a7@-
%S_ASNCS8:		movl	a6@(20),d0
%S_ASNCSC:		bclr	#0x1F,d0
%S_ASNCS10:		movl	d0,d7
%S_ASNCS12:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%S_ASNCS16:		movl	#0x3F350481,	0x8000+	0x3200+0x10+0x0:w
%S_ASNCS1E:		tstb		0x8000+	0x700+0x00+0x0:w
%S_ASNCS22:		bges	%S_ASNCS2C
%S_ASNCS24:		movl	a6@(12),a0
%S_ASNCS28:		clrb	a0@
%S_ASNCS2A:		bras	%S_ASNCS5E
%S_ASNCS2C:		movl	#0x3F800000,	0x8000+	0x100+0x10+0x0:w
%S_ASNCS34:		movl	d7,	0x8000+0xf00+0x10+0x0:w
%S_ASNCS38:		movl	#0x3F800000,	0x8000+	0x100+0x20+0x0:w
%S_ASNCS40:		movl	d7,	0x8000+0xb00+0x20+0x0:w
%S_ASNCS44:		movb	d0,	0x8000+0x1700+0x10+0x2:w
%S_ASNCS48:		movl		0x8000+	0x100+0x10+0x0:w,a7@-
%S_ASNCS4C:		jsr	%_SQRT
%S_ASNCS52:		movl		0x8000+	0x100+0x10+0x0:w,d7
%S_ASNCS56:		movl	a6@(12),a0
%S_ASNCS5A:		moveq	#1,d0
%S_ASNCS5C:		movb	d0,a0@
%S_ASNCS5E:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%S_ASNCS62:		movb	d0,	0x8000+0x1700+0x10+0x1:w
%S_ASNCS66:		movl		0x8000+	0x100+0x10+0x0:w,d6
%S_ASNCS6A:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%S_ASNCS6E:		movl	d6,	0x8000+0x1700+0x10+0x0:w
%S_ASNCS72:		movl	d6,	0x8000+	0x100+0x20+0x0:w
%S_ASNCS76:		movl	#0x3CC32E36,	0x8000+0x1700+0x20+0x0:w
%S_ASNCS7E:		movl	#0xBEC79049,	0x8000+0xb00+0x20+0x0:w
%S_ASNCS86:		movl	d6,	0x8000+0x1700+0x20+0x0:w
%S_ASNCS8A:		movl	#0x3EFBD00F,	0x8000+0xb00+0x20+0x0:w
%S_ASNCS92:		movb	d0,	0x8000+0x1700+0x10+0x2:w
%S_ASNCS96:		movl	#0xC06AA2BF,	0x8000+	0x100+0x20+0x0:w
%S_ASNCS9E:		movl	d6,	0x8000+0xb00+0x20+0x0:w
%S_ASNCSA2:		movl	d6,	0x8000+0x1700+0x20+0x0:w
%S_ASNCSA6:		movl	#0x403CDBB7,	0x8000+0xb00+0x20+0x0:w
%S_ASNCSAE:		movb	d0,	0x8000+0x1b00+0x10+0x2:w
%S_ASNCSB2:		movl	d7,	0x8000+0xb00+0x10+0x0:w
%S_ASNCSB6:		movl	a6@(16),a0
%S_ASNCSBA:		movl		0x8000+	0x100+0x10+0x0:w,a0@
|			moveml	a7@+,#<d6,d7>
			moveml	a7@+,#0x00c0
%S_ASNCSC2:		unlk	a6
%S_ASNCSC4:		rtd	#16
%MYS_HSNCS:		linkw	a6,#-50
|			moveml	#<d3,d4,d5,d6,d7>,a7@-
			moveml	#0x1f00,a7@-
%MYS_HSNCS8:		movl	a6@(10),d0
%MYS_HSNCSC:		bclr	#0x1F,d0
%MYS_HSNCS10:			movl	d0,d7
%MYS_HSNCS12:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS16:			movl	#0x3F400000,	0x8000+	0x3200+0x10+0x0:w
%MYS_HSNCS1E:			tstb		0x8000+	0x700+0x00+0x0:w
%MYS_HSNCS22:			bges	%MYS_HSNCSA0
%MYS_HSNCS24:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS28:			movb	d0,	0x8000+0x1700+0x10+0x1:w
%MYS_HSNCS2C:			movl		0x8000+	0x100+0x10+0x0:w,d6
%MYS_HSNCS30:			tstw	a6@(8)
%MYS_HSNCS34:			bnes	%MYS_HSNCS6C
%MYS_HSNCS36:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS3A:			movl	d6,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS3E:			movl	d6,	0x8000+	0x100+0x20+0x0:w
%MYS_HSNCS42:			movl	#0x39534C5B,	0x8000+0x1700+0x20+0x0:w
%MYS_HSNCS4A:			movl	#0x3C088402,	0x8000+0xb00+0x20+0x0:w
%MYS_HSNCS52:			movl	d6,	0x8000+0x1700+0x20+0x0:w
%MYS_HSNCS56:			movl	#0x3E2AAAB3,	0x8000+0xb00+0x20+0x0:w
%MYS_HSNCS5E:			movb	d0,	0x8000+0x1700+0x10+0x2:w
%MYS_HSNCS62:			movl	d7,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS66:			movl		0x8000+	0x100+0x10+0x0:w,d5
%MYS_HSNCS6A:			bras	%MYS_HSNCS9C
%MYS_HSNCS6C:			movl	d6,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS70:			movl	#0x3AB9AA6A,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS78:			movl	#0x3D2AA0B8,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS80:			movl	d6,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS84:			movl	#0x3F000011,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS8C:			movl	d6,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS90:			movl	#0x3F800000,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS98:			movl		0x8000+	0x100+0x10+0x0:w,d5
%MYS_HSNCS9C:			bra	%MYS_HSNCS1FE
%MYS_HSNCSA0:			movl	d7,a6@(-50)
%MYS_HSNCSA4:			movl	#0xFFFFF000,d0
%MYS_HSNCSAA:			andl	a6@(-50),d0
%MYS_HSNCSAE:			movl	d0,a6@(-50)
%MYS_HSNCSB2:			movl	d0,a6@(-30)
%MYS_HSNCSB6:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCSBA:			movl	a6@(-30),	0x8000+0xf00+0x10+0x0:w
%MYS_HSNCSC0:			movl		0x8000+	0x100+0x10+0x0:w,a6@(-26)
%MYS_HSNCSC6:			movl	a6@(-30),	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCSCC:			movl	#0x3FB8A000,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCSD4:			movl		0x8000+	0x100+0x10+0x0:w,d4
%MYS_HSNCSD8:			movb		0x8000+	0x600+0x00+0x0:w,d0
%MYS_HSNCSDC:			andb	#0xF1,	0x8000+	0x600+0x00+0x0:w
%MYS_HSNCSE2:			movl	d4,	0x8000+0x2900+0x10+0x0:w
%MYS_HSNCSE6:			movb	d0,	0x8000+	0x600+0x00+0x0:w
%MYS_HSNCSEA:			movl		0x8000+	0x200+0x10+0x0:w,d0
%MYS_HSNCSEE:			movw	d0,d3
%MYS_HSNCSF0:			movl	d3,d0
%MYS_HSNCSF2:			extl	d0
%MYS_HSNCSF4:			movl	d0,	0x8000+0x2700+0x10+0x0:w
%MYS_HSNCSF8:			movl	d4,	0x8000+	0x100+0x20+0x0:w
%MYS_HSNCSFC:			movb	d0,	0x8000+0xf00+0x20+0x1:w
%MYS_HSNCS100:			movl	a6@(-26),	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS106:			movl	#0x3FB8A000,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS10E:			movl	d7,	0x8000+	0x100+0x30+0x0:w
%MYS_HSNCS112:			movl	#0x39A3B296,	0x8000+0x1700+0x30+0x0:w
%MYS_HSNCS11A:			movb	d0,	0x8000+0xb00+0x10+0x3:w
%MYS_HSNCS11E:			movb	d0,	0x8000+0xb00+0x20+0x1:w
%MYS_HSNCS122:			movl		0x8000+	0x100+0x20+0x0:w,d4
%MYS_HSNCS126:			movl	d4,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS12A:			movb	d0,	0x8000+0x1700+0x10+0x1:w
%MYS_HSNCS12E:			movl		0x8000+	0x100+0x10+0x0:w,d6
%MYS_HSNCS132:			movl	#0x3D6C5665,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS13A:			movl	d6,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS13E:			movl	#0x40E6E1AC,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS146:			movl	d4,	0x8000+0x1700+0x10+0x0:w
%MYS_HSNCS14A:			movl		0x8000+	0x100+0x10+0x0:w,a6@(-18)
%MYS_HSNCS150:			movl	#0x41A68BBB,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS158:			movl	d6,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS15C:			movl		0x8000+	0x100+0x10+0x0:w,a6@(-14)
%MYS_HSNCS162:			movl	a6@(-14),	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS168:			movl	a6@(-18),	0x8000+0xf00+0x10+0x0:w
%MYS_HSNCS16E:			movl	a6@(-18),	0x8000+	0x100+0x20+0x0:w
%MYS_HSNCS174:			movb	d0,	0x8000+0x1b00+0x20+0x1:w
%MYS_HSNCS178:			movl		0x8000+	0x100+0x20+0x0:w,d7
%MYS_HSNCS17C:			cmpw	#0xE,d3
%MYS_HSNCS180:			bges	%MYS_HSNCS1D8
%MYS_HSNCS182:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS186:			movl	#0x3F000000,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS18E:			movl	#0x3F000000,	0x8000+	0x100+0x20+0x0:w
%MYS_HSNCS196:			movb	d0,	0x8000+0x1b00+0x20+0x1:w
%MYS_HSNCS19A:			movl		0x8000+	0x100+0x20+0x0:w,a6@(-50)
%MYS_HSNCS1A0:			movl	d3,d0
%MYS_HSNCS1A2:			lslw	#0x1,d0
%MYS_HSNCS1A4:			addqw	#1,d0
%MYS_HSNCS1A6:			extl	d0
%MYS_HSNCS1A8:			mulsl	#0x800000,d0
%MYS_HSNCS1B0:			subl	d0,a6@(-50)
%MYS_HSNCS1B4:			movl	a6@(-50),d6
%MYS_HSNCS1B8:			tstw	a6@(8)
%MYS_HSNCS1BC:			bnes	%MYS_HSNCS1CC
%MYS_HSNCS1BE:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS1C2:			movl	d6,	0x8000+0xf00+0x10+0x0:w
%MYS_HSNCS1C6:			movl		0x8000+	0x100+0x10+0x0:w,d7
%MYS_HSNCS1CA:			bras	%MYS_HSNCS1D8
%MYS_HSNCS1CC:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS1D0:			movl	d6,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS1D4:			movl		0x8000+	0x100+0x10+0x0:w,d7
%MYS_HSNCS1D8:			movl	d7,	0x8000+	0x100+0x10+0x0:w
%MYS_HSNCS1DC:			movl	#0x3F000000,	0x8000+0xb00+0x10+0x0:w
%MYS_HSNCS1E4:			movl		0x8000+	0x100+0x10+0x0:w,a6@(-50)
%MYS_HSNCS1EA:			movl	d3,d0
%MYS_HSNCS1EC:			extl	d0
%MYS_HSNCS1EE:			mulsl	#0x800000,d0
%MYS_HSNCS1F6:			addl	d0,a6@(-50)
%MYS_HSNCS1FA:			movl	a6@(-50),d5
%MYS_HSNCS1FE:			movl	a6@(10),	0x8000+	0x3400+0x00+0x0:w
%MYS_HSNCS204:			tstb		0x8000+	0x700+0x00+0x0:w
%MYS_HSNCS208:			bges	%MYS_HSNCS224
%MYS_HSNCS20A:			movl	d5,d0
%MYS_HSNCS20C:			bclr	#0x1F,d0
%MYS_HSNCS210:			cmpl	#0x7F800000,d0
%MYS_HSNCS216:			bges	%MYS_HSNCS224
%MYS_HSNCS218:			tstw	a6@(8)
%MYS_HSNCS21C:			bnes	%MYS_HSNCS224
%MYS_HSNCS21E:			movl	d5,	0x8000+0x2f00+0x10+0x0:w
%MYS_HSNCS222:			bras	%MYS_HSNCS228
%MYS_HSNCS224:			movl	d5,	0x8000+	0x100+0x10+0x0:w
|			moveml	a7@+,#<d3,d4,d5,d6,d7>
%MYS_HSNCS228:			moveml	a7@+,#0x00f8
%MYS_HSNCS22C:			unlk	a6
%MYS_HSNCS22E:			rtd	#6
	.globl	%_FTAN
%_FTAN:			linkw	a6,#-20
|			moveml	#<d5,d6,d7,a4>,a7@-
			moveml	#0x0708,a7@-
%_FTAN8:		movl	a6@(8),a4
%_FTANC:		movl	a4@,d0
%_FTANE:		bclr	#0x1F,d0
%_FTAN12:		movl	d0,	0x8000+	0x100+0x10+0x0:w
%_FTAN16:		movl	#0x3F490FF9,	0x8000+	0x3200+0x10+0x0:w
%_FTAN1E:		tstb		0x8000+	0x700+0x00+0x0:w
%_FTAN22:		bges	%_FTAN2C
%_FTAN24:		clrl	a6@(-20)
%_FTAN28:		movl	a4@,d7
%_FTAN2A:		bras	%_FTAN3C
%_FTAN2C:
		movl	a4@,d0
|	f1 = arg
		movl	d0,	0x8000+	0x100+0x10+0x0:w
%MYTPI_REDUCE30:
|	arg + POFOUR
		movl	#0x3F490FDB,	0x8000+	0xa00+0x10+0x0:w
|	ff = x = (arg+POFOUR)*TWOOP
		movl	#0x3F22F983,	0x8000+	0x1600+0xf0+0x0:w
|	if(x < 0.0)
		movb	d0,	0x8000+	0x3400+0xf0+0xf:w
		tstb		0x8000+	0x700+0x00+0x0:w
		bges	%MYTPI_REDUCE8A

		movl	#0x3F800000,	0x8000+	0xe00+0xf0+0x0:w
|	f2 = multiple = trunc(x-1)
%MYTPI_REDUCE8A:
		movb	d0,	0x8000+0x2900+0x20+0xf:w
		movl		0x8000+	0x200+0x20+0x0:w,a6@(-20)
		movb	d0,	0x8000+0x2b00+0x20+0x2:w
%MYTPI_REDUCE9C:
|	f3 = i = trunc(arg)
		movb	d0,	0x8000+0x2900+0x30+0x1:w
		movb	d0,	0x8000+0x2b00+0x30+0x3:w
|	f1 = x = arg - i
		movb	d0,	0x8000+0x2300+0x10+0x1:w
		movb	d0,	0x8000+0x1100+0x10+0x3:w
|	f3 = i - multiple * (POTWO & 0xffffffff)
		clrl		0x8000+0x400+0x00+0x0:w
		movl	#0x3FF921FB,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x30+0xf:w
|	f1 = x - multiple * y	
		movl	#0x4611A400,	0x8000+0x400+0x00+0x0:w
		movl	#0x3E95110B,	0x8000+	0x1800+0x20+0x0:w
		movb	d0,	0x8000+0x1100+0x10+0xf:w
|	f1 = f1 + f3
		movb	d0,	0x8000+0xd00+0x10+0x3:w
		movb	d0,	0x8000+0x2500+0x10+0x1:w

%_FTAN38:		movl		0x8000+	0x100+0x10+0x0:w,d7
%_FTAN3C:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTAN40:		movb	d0,	0x8000+0x1700+0x10+0x1:w
%_FTAN44:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_FTAN48:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTAN4C:		movl	d6,	0x8000+0x1700+0x10+0x0:w
%_FTAN50:		movl	d6,	0x8000+	0x100+0x20+0x0:w
%_FTAN54:		movl	#0x401E093A,	0x8000+0xf00+0x20+0x0:w
%_FTAN5C:		movl	#0x3EA88E8D,	0x8000+	0x100+0x30+0x0:w
%_FTAN64:		movb	d0,	0x8000+0x1b00+0x30+0x2:w
%_FTAN68:		movl	d6,	0x8000+0x1700+0x30+0x0:w
%_FTAN6C:		movl	#0x3EAAAAE4,	0x8000+	0x100+0x20+0x0:w
%_FTAN74:		movb	d0,	0x8000+0xf00+0x20+0x3:w
%_FTAN78:		movb	d0,	0x8000+0x1700+0x10+0x2:w
%_FTAN7C:		movl	d7,	0x8000+0xb00+0x10+0x0:w
%_FTAN80:		movl		0x8000+	0x100+0x10+0x0:w,d5
%_FTAN84:		movb	a6@(-17),d0
%_FTAN88:		andw	#0x1,d0
%_FTAN8C:		beqs	%_FTANA4
%_FTAN8E:		movl	#0x3F800000,	0x8000+	0x100+0x10+0x0:w
%_FTAN96:		movl	d5,	0x8000+0x1b00+0x10+0x0:w
%_FTAN9A:		movb	d0,	0x8000+0x2f00+0x20+0x1:w
%_FTAN9E:		movb	d0,	0x8000+	0x500+0x10+0x2:w
%_FTANA2:		bras	%_FTANA8
%_FTANA4:		movl	d5,	0x8000+	0x100+0x10+0x0:w
|			moveml	a7@+,#<d5,d6,d7,a4>
%_FTANA8:		moveml	a7@+,#0x10e0
%_FTANAC:		unlk	a6
%_FTANAE:		rtd	#4
	.globl	%_FASIN
%_FASIN:		linkw	a6,#-12
%_FASIN4:		movl	a6@(8),a0
%_FASIN8:		movl	a0@,a7@-
%_FASINA:		pea	a6@(-8)
%_FASINE:		pea	a6@(-10)
%_FASIN12:		pea	a6@(-9)
%_FASIN16:		jsr	%S_ASNCS
%_FASIN1C:		movb	a6@(-10),d0
%_FASIN20:		beqs	%_FASIN36
%_FASIN22:		movl	#0x3FC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FASIN2A:		movl	a6@(-8),	0x8000+0xf00+0x10+0x0:w
%_FASIN30:		movl		0x8000+	0x100+0x10+0x0:w,a6@(-8)
%_FASIN36:		movl	a6@(8),a0
%_FASIN3A:		movl	a0@,	0x8000+	0x3400+0x00+0x0:w
%_FASIN3E:		tstb		0x8000+	0x700+0x00+0x0:w
%_FASIN42:		bges	%_FASIN50
%_FASIN44:		movl	a6@(-8),	0x8000+0x2f00+0x10+0x0:w
%_FASIN4A:		movl		0x8000+	0x100+0x10+0x0:w,a6@(-8)
%_FASIN50:		movl	a6@(-8),	0x8000+	0x100+0x10+0x0:w
%_FASIN56:		unlk	a6
%_FASIN58:		rtd	#4
	.globl	%_FACOS
%_FACOS:		linkw	a6,#-12
%_FACOS4:		movl	a6@(8),a0
%_FACOS8:		movl	a0@,a7@-
%_FACOSA:		pea	a6@(-8)
%_FACOSE:		pea	a6@(-10)
%_FACOS12:		pea	a6@(-9)
%_FACOS16:		jsr	%S_ASNCS
%_FACOS1C:		movl	a6@(8),a0
%_FACOS20:		movl	a0@,	0x8000+	0x3400+0x00+0x0:w
%_FACOS24:		tstb		0x8000+	0x700+0x00+0x0:w
%_FACOS28:		bges	%_FACOS50
%_FACOS2A:		movb	a6@(-10),d0
%_FACOS2E:		beqs	%_FACOS40
%_FACOS30:		movl	#0x40490FDB,	0x8000+	0x100+0x10+0x0:w
%_FACOS38:		movl	a6@(-8),	0x8000+0xf00+0x10+0x0:w
%_FACOS3E:		bras	%_FACOS6C
%_FACOS40:		movl	#0x3FC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FACOS48:		movl	a6@(-8),	0x8000+0xb00+0x10+0x0:w
%_FACOS4E:		bras	%_FACOS6C
%_FACOS50:		movb	a6@(-10),d0
%_FACOS54:		beqs	%_FACOS5E
%_FACOS56:		movl	a6@(-8),	0x8000+	0x100+0x10+0x0:w
%_FACOS5C:		bras	%_FACOS6C
%_FACOS5E:		movl	#0x3FC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FACOS66:		movl	a6@(-8),	0x8000+0xf00+0x10+0x0:w
%_FACOS6C:		unlk	a6
%_FACOS6E:		rtd	#4
	.globl	%_FATAN2
%_FATAN2:		linkw	a6,#-24
%_FATAN24:		movl	d7,a7@-
%_FATAN26:		movl	a6@(8),a0
%_FATAN2A:		movl	a0@,a6@(-24)
%_FATAN2E:		movl	a6@(12),a1
%_FATAN212:		movl	a1@,a6@(-20)
%_FATAN216:		movl	a6@(-24),	0x8000+	0x3400+0x00+0x0:w
%_FATAN21C:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN220:		bnes	%_FATAN256
%_FATAN222:		movl	a6@(-20),	0x8000+	0x3400+0x00+0x0:w
%_FATAN228:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN22C:		beqs	%_FATAN252
%_FATAN22E:		movl	a6@(-20),	0x8000+	0x3400+0x00+0x0:w
%_FATAN234:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN238:		bges	%_FATAN246
%_FATAN23A:		movl	#0xBFC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FATAN242:		bra	%_FATAN2EE
%_FATAN246:		movl	#0x3FC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FATAN24E:		bra	%_FATAN2EE
%_FATAN252:		bra	%_FATAN2E8
%_FATAN256:		movl	#0x7F800000,d0
%_FATAN25C:		andl	a6@(-20),d0
%_FATAN260:		movl	#0x7F800000,d1
%_FATAN266:		andl	a6@(-24),d1
%_FATAN26A:		subl	d1,d0
%_FATAN26C:		cmpl	#0xD000000,d0
%_FATAN272:		bles	%_FATAN294
%_FATAN274:		movl	a6@(-20),	0x8000+	0x3400+0x00+0x0:w
%_FATAN27A:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN27E:		bges	%_FATAN28A
%_FATAN280:		movl	#0xBFC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FATAN288:		bras	%_FATAN2EE
%_FATAN28A:		movl	#0x3FC90FDB,	0x8000+	0x100+0x10+0x0:w
%_FATAN292:		bras	%_FATAN2EE
%_FATAN294:		movl	a6@(-20),	0x8000+	0x100+0x10+0x0:w
%_FATAN29A:		movl	a6@(-24),	0x8000+0x1b00+0x10+0x0:w
%_FATAN2A0:		movl		0x8000+	0x100+0x10+0x0:w,a7@-
%_FATAN2A4:		jsr	%_ATAN
%_FATAN2AA:		movl		0x8000+	0x100+0x10+0x0:w,d7
%_FATAN2AE:		movl	a6@(-24),	0x8000+	0x3400+0x00+0x0:w
%_FATAN2B4:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN2B8:		bges	%_FATAN2E2
%_FATAN2BA:		movl	a6@(-20),	0x8000+	0x3400+0x00+0x0:w
%_FATAN2C0:		tstb		0x8000+	0x700+0x00+0x0:w
%_FATAN2C4:		bges	%_FATAN2D4
%_FATAN2C6:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FATAN2CA:		movl	#0x40490FDB,	0x8000+0xf00+0x10+0x0:w
%_FATAN2D2:		bras	%_FATAN2EE
%_FATAN2D4:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FATAN2D8:		movl	#0x40490FDB,	0x8000+0xb00+0x10+0x0:w
%_FATAN2E0:		bras	%_FATAN2EE
%_FATAN2E2:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FATAN2E6:		bras	%_FATAN2EE
%_FATAN2E8:		movl	a6@(-4),	0x8000+	0x100+0x10+0x0:w
%_FATAN2EE:		movl	a7@+,d7
%_FATAN2F0:		unlk	a6
%_FATAN2F2:		rtd	#8
	.globl	%_FSINH
%_FSINH:		linkw	a6,#-4
%_FSINH4:		movl	a6@(8),a0
%_FSINH8:		movl	a0@,a7@-
%_FSINHA:		clrw	a7@-
%_FSINHC:		jsr	%MYS_HSNCS
%_FSINH12:		unlk	a6
%_FSINH14:		rtd	#4
	.globl	%_FCOSH
%_FCOSH:		linkw	a6,#-4
%_FCOSH4:		movl	a6@(8),a0
%_FCOSH8:		movl	a0@,a7@-
%_FCOSHA:		movw	#0x1,a7@-
%_FCOSHE:		jsr	%MYS_HSNCS
%_FCOSH14:		unlk	a6
%_FCOSH16:		rtd	#4
	.globl	%_FTANH
%_FTANH:		linkw	a6,#-36
|			moveml	#<d3,d4,d5,d6,d7,a4>,a7@-
			moveml	#0x1f08,a7@-
%_FTANH8:		movl	a6@(8),a4
%_FTANHC:		movl	a4@,d0
%_FTANHE:		bclr	#0x1F,d0
%_FTANH12:		movl	d0,d7
%_FTANH14:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTANH18:		movl	#0x3F400000,	0x8000+	0x3200+0x10+0x0:w
%_FTANH20:		tstb		0x8000+	0x700+0x00+0x0:w
%_FTANH24:		bges	%_FTANH6A
%_FTANH26:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTANH2A:		movb	d0,	0x8000+0x1700+0x10+0x1:w
%_FTANH2E:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_FTANH32:		movl	a4@,	0x8000+	0x100+0x10+0x0:w
%_FTANH36:		movl	d6,	0x8000+0x1700+0x10+0x0:w
%_FTANH3A:		movl	d6,	0x8000+	0x100+0x20+0x0:w
%_FTANH3E:		movl	#0xBB763D74,	0x8000+0x1700+0x20+0x0:w
%_FTANH46:		movl	#0xBF52F16C,	0x8000+0xb00+0x20+0x0:w
%_FTANH4E:		movb	d0,	0x8000+0x1700+0x10+0x2:w
%_FTANH52:		movl	#0x401E352F,	0x8000+	0x100+0x20+0x0:w
%_FTANH5A:		movl	d6,	0x8000+0xb00+0x20+0x0:w
%_FTANH5E:		movb	d0,	0x8000+0x1b00+0x10+0x2:w
%_FTANH62:		movl	a4@,	0x8000+0xb00+0x10+0x0:w
%_FTANH66:		bra	%_FTANH166
%_FTANH6A:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTANH6E:		movl	#0x41102D0E,	0x8000+	0x3200+0x10+0x0:w
%_FTANH76:		tstb		0x8000+	0x700+0x00+0x0:w
%_FTANH7A:		bles	%_FTANH86
%_FTANH7C:		movl	#0x3F800000,d3
%_FTANH82:		bra	%_FTANH152
%_FTANH86:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTANH8A:		movl	#0x4038AA3B,	0x8000+0x1700+0x10+0x0:w
%_FTANH92:		movl		0x8000+	0x100+0x10+0x0:w,d7
%_FTANH96:		movb		0x8000+	0x600+0x00+0x0:w,d0
%_FTANH9A:		andb	#0xF1,	0x8000+	0x600+0x00+0x0:w
%_FTANHA0:		movl	d7,	0x8000+0x2900+0x10+0x0:w
%_FTANHA4:		movb	d0,	0x8000+	0x600+0x00+0x0:w
%_FTANHA8:		movl		0x8000+	0x200+0x10+0x0:w,d0
%_FTANHAC:		movw	d0,a6@(-32)
%_FTANHB0:		extl	d0
%_FTANHB2:		movl	d0,	0x8000+0x2700+0x10+0x0:w
%_FTANHB6:		movl	d7,	0x8000+	0x100+0x20+0x0:w
%_FTANHBA:		movb	d0,	0x8000+0xf00+0x20+0x1:w
%_FTANHBE:		movl		0x8000+	0x100+0x20+0x0:w,d7
%_FTANHC2:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FTANHC6:		movb	d0,	0x8000+0x1700+0x10+0x1:w
%_FTANHCA:		movl		0x8000+	0x100+0x10+0x0:w,d6
%_FTANHCE:		movl	d6,	0x8000+	0x100+0x10+0x0:w
%_FTANHD2:		movl	#0x3D6C5665,	0x8000+0x1700+0x10+0x0:w
%_FTANHDA:		movl	#0x40E6E1AC,	0x8000+0xb00+0x10+0x0:w
%_FTANHE2:		movl	d7,	0x8000+0x1700+0x10+0x0:w
%_FTANHE6:		movl		0x8000+	0x100+0x10+0x0:w,d5
%_FTANHEA:		movl	#0x41A68BBB,	0x8000+	0x100+0x10+0x0:w
%_FTANHF2:		movl	d6,	0x8000+0xb00+0x10+0x0:w
%_FTANHF6:		movl		0x8000+	0x100+0x10+0x0:w,d4
%_FTANHFA:		movl	d4,	0x8000+	0x100+0x10+0x0:w
%_FTANHFE:		movl	d5,	0x8000+0xb00+0x10+0x0:w
%_FTANH102:		movl		0x8000+	0x100+0x10+0x0:w,a6@(-36)
%_FTANH108:		movw	a6@(-32),d0
%_FTANH10C:		extl	d0
%_FTANH10E:		mulsl	#0x800000,d0
%_FTANH116:		addl	d0,a6@(-36)
%_FTANH11A:		movl	a6@(-36),a6@(-12)
%_FTANH120:		movl	d4,	0x8000+	0x100+0x10+0x0:w
%_FTANH124:		movl	d5,	0x8000+0xf00+0x10+0x0:w
%_FTANH128:		movl	#0x40000000,	0x8000+0x1700+0x10+0x0:w
%_FTANH130:		movl	d4,	0x8000+	0x100+0x20+0x0:w
%_FTANH134:		movl	d5,	0x8000+0xf00+0x20+0x0:w
%_FTANH138:		movl	a6@(-12),	0x8000+0xb00+0x20+0x0:w
%_FTANH13E:		movb	d0,	0x8000+0x1b00+0x10+0x2:w
%_FTANH142:		movl	#0x3F800000,	0x8000+	0x100+0x20+0x0:w
%_FTANH14A:		movb	d0,	0x8000+0xf00+0x20+0x1:w
%_FTANH14E:		movl		0x8000+	0x100+0x20+0x0:w,d3
%_FTANH152:		movl	a4@,	0x8000+	0x3400+0x00+0x0:w
%_FTANH156:		tstb		0x8000+	0x700+0x00+0x0:w
%_FTANH15A:		bges	%_FTANH162
%_FTANH15C:		movl	d3,	0x8000+0x2f00+0x10+0x0:w
%_FTANH160:		bras	%_FTANH166
%_FTANH162:		movl	d3,	0x8000+	0x100+0x10+0x0:w
|			moveml	a7@+,#<d3,d4,d5,d6,d7,a4>
%_FTANH166:		moveml	a7@+,#0x10f8
%_FTANH16A:		unlk	a6
%_FTANH16C:		rtd	#4
	.globl	%_FLOG10
%_FLOG10:		linkw	a6,#-8
%_FLOG104:		movl	d7,a7@-
%_FLOG106:		movl	a6@(8),a0
%_FLOG10A:		movl	a0@,a7@-
%_FLOG10C:		jsr	%_LN
%_FLOG1012:		movl		0x8000+	0x100+0x10+0x0:w,d7
%_FLOG1016:		movl	d7,d0
%_FLOG1018:		bclr	#0x1F,d0
%_FLOG101C:		cmpl	#0x7F800000,d0
%_FLOG1022:		bges	%_FLOG1032
%_FLOG1024:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FLOG1028:		movl	#0x40135D8E,	0x8000+0x1b00+0x10+0x0:w
%_FLOG1030:		bras	%_FLOG1036
%_FLOG1032:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_FLOG1036:		movl	a7@+,d7
%_FLOG1038:		unlk	a6
%_FLOG103A:		rtd	#4
	.globl	%_UP_I
%_UP_I:			linkw	a6,#-16
|			moveml	#<d3,d4,d5,d6,d7>,a7@-
			moveml	#0x1f00,a7@-
%_UP_I8:		movl	a6@(8),d5
%_UP_IC:		movl	a6@(12),d4
%_UP_I10:		tstl	d5
%_UP_I12:		slt	d3
%_UP_I14:		negb	d3
%_UP_I16:		movl	d5,d0
%_UP_I18:		bpls	%_UP_I1C
%_UP_I1A:		negl	d0
%_UP_I1C:		movl	d0,d5
%_UP_I1E:		movl	#0x3F800000,d7
%_UP_I24:		tstl	d5
%_UP_I26:		bles	%_UP_I5A
%_UP_I28:		movl	d5,d0
%_UP_I2A:		andw	#0x1,d0
%_UP_I2E:		beqs	%_UP_I32
%_UP_I30:		movl	d4,d7
%_UP_I32:		moveq	#2,d6
%_UP_I34:		bras	%_UP_I56
%_UP_I36:		movl	d4,	0x8000+	0x100+0x10+0x0:w
%_UP_I3A:		movl	d4,	0x8000+0x1700+0x10+0x0:w
%_UP_I3E:		movl		0x8000+	0x100+0x10+0x0:w,d4
%_UP_I42:		movl	d5,d0
%_UP_I44:		andl	d6,d0
%_UP_I46:		beqs	%_UP_I54
%_UP_I48:		movl	d7,	0x8000+	0x100+0x10+0x0:w
%_UP_I4C:		movl	d4,	0x8000+0x1700+0x10+0x0:w
%_UP_I50:		movl		0x8000+	0x100+0x10+0x0:w,d7
%_UP_I54:		addl	d6,d6
%_UP_I56:		cmpl	d5,d6
%_UP_I58:		bles	%_UP_I36
%_UP_I5A:		tstb	d3
%_UP_I5C:		beqs	%_UP_I6C
%_UP_I5E:		movl	#0x3F800000,	0x8000+	0x100+0x10+0x0:w
%_UP_I66:		movl	d7,	0x8000+0x1b00+0x10+0x0:w
%_UP_I6A:		bras	%_UP_I70
%_UP_I6C:		movl	d7,	0x8000+	0x100+0x10+0x0:w
|			moveml	a7@+,#<d3,d4,d5,d6,d7>
%_UP_I70:		moveml	a7@+,#0x00f8
%_UP_I74:		unlk	a6
%_UP_I76:		rtd	#8
	.globl	%_UP_R
%_UP_R:			linkw	a6,#-8
|			moveml	#<d6,d7>,a7@-
			moveml	#0x300,a7@-
%_UP_R8:		movl	a6@(12),d7
%_UP_RC:		movl	d7,	0x8000+	0x3400+0x00+0x0:w
%_UP_R10:		tstb		0x8000+	0x700+0x00+0x0:w
%_UP_R14:		bgts	%_UP_R3E
%_UP_R16:		movl	d7,	0x8000+	0x3400+0x00+0x0:w
%_UP_R1A:		tstb		0x8000+	0x700+0x00+0x0:w
%_UP_R1E:		bges	%_UP_R38
%_UP_R20:		movl	a6@(8),	0x8000+0x2900+0x10+0x0:w
%_UP_R26:		movl		0x8000+	0x200+0x10+0x0:w,d0
%_UP_R2A:		movl	d0,d6
%_UP_R2C:		movl	d7,a7@-
%_UP_R2E:		movl	d6,a7@-
%_UP_R30:		jsr	%_UP_I
%_UP_R36:		bras	%_UP_R56
%_UP_R38:		clrl		0x8000+	0x100+0x10+0x0:w
%_UP_R3C:		bras	%_UP_R56
%_UP_R3E:		movl	d7,a7@-
%_UP_R40:		jsr	%_LN
%_UP_R46:		movl	a6@(8),	0x8000+0x1700+0x10+0x0:w
%_UP_R4C:		movl		0x8000+	0x100+0x10+0x0:w,a7@-
%_UP_R50:		jsr	%_EXP
|			moveml	a7@+,#<d6,d7>
%_UP_R56:		moveml	a7@+,#0x00c0
%_UP_R5A:		unlk	a6
%_UP_R5C:		rtd	#8
	.globl	%_FSIN
%_FSIN:			linkw	a6,#-4
%_FSIN4:		movl	a6@(8),a0
%_FSIN8:		movl	a0@,a7@-
%_FSINA:		jsr	%_SIN
%_FSIN10:		unlk	a6
%_FSIN12:		rtd	#4
	.globl	%_FCOS
%_FCOS:			linkw	a6,#-4
%_FCOS4:		movl	a6@(8),a0
%_FCOS8:		movl	a0@,a7@-
%_FCOSA:		jsr	%_COS
%_FCOS10:		unlk	a6
%_FCOS12:		rtd	#4
	.globl	%_FATAN
%_FATAN:		linkw	a6,#-4
%_FATAN4:		movl	a6@(8),a0
%_FATAN8:		movl	a0@,a7@-
%_FATANA:		jsr	%_ATAN
%_FATAN10:		unlk	a6
%_FATAN12:		rtd	#4
	.globl	%_FEXP
%_FEXP:			linkw	a6,#-4
%_FEXP4:		movl	a6@(8),a0
%_FEXP8:		movl	a0@,a7@-
%_FEXPA:		jsr	%_EXP
%_FEXP10:		unlk	a6
%_FEXP12:		rtd	#4
	.globl	%_FLN
%_FLN:			linkw	a6,#-4
%_FLN4:		movl	a6@(8),a0
%_FLN8:		movl	a0@,a7@-
%_FLNA:		jsr	%_LN
%_FLN10:		unlk	a6
%_FLN12:		rtd	#4
	.globl	%_FSQRT
%_FSQRT:		linkw	a6,#-4
%_FSQRT4:		movl	a6@(8),a0
%_FSQRT8:		movl	a0@,a7@-
%_FSQRTA:		jsr	%_SQRT
%_FSQRT10:		unlk	a6
%_FSQRT12:		rtd	#4
	.globl	%I_UP_I
%I_UP_I:		linkw	a6,#-12
|			moveml	#<d3,d4,d5,d6,d7>,a7@-
			moveml	#0x1f00,a7@-
%I_UP_I8:		movl	a6@(8),d6
%I_UP_IC:		movl	a6@(12),d5
%I_UP_I10:		slt	d0
%I_UP_I12:		movl	d6,d1
%I_UP_I14:		andw	#0x1,d1
%I_UP_I18:		andb	d1,d0
%I_UP_I1A:		movb	d0,d3
%I_UP_I1C:		tstl	d6
%I_UP_I1E:		slt	d4
%I_UP_I20:		negb	d4
%I_UP_I22:		movl	d5,d0
%I_UP_I24:		bpls	%I_UP_I28
%I_UP_I26:		negl	d0
%I_UP_I28:		movl	d0,d5
%I_UP_I2A:		movl	d6,d0
%I_UP_I2C:		bpls	%I_UP_I30
%I_UP_I2E:		negl	d0
%I_UP_I30:		movl	d0,d6
%I_UP_I32:		moveq	#1,d7
%I_UP_I34:		bras	%I_UP_I5A
%I_UP_I36:		movl	d6,d0
%I_UP_I38:		andw	#0x1,d0
%I_UP_I3C:		beqs	%I_UP_I46
%I_UP_I3E:		movl	d5,d0
%I_UP_I40:		mulsl	d7,d0
%I_UP_I44:		movl	d0,d7
%I_UP_I46:		movl	d5,d0
%I_UP_I48:		mulsl	d5,d0
%I_UP_I4C:		movl	d0,d5
%I_UP_I4E:		movl	d6,d0
			asrl	#1,d0
%I_UP_I58:		movl	d0,d6
%I_UP_I5A:		tstl	d6
%I_UP_I5C:		bgts	%I_UP_I36
%I_UP_I5E:		tstb	d3
%I_UP_I60:		beqs	%I_UP_I68
%I_UP_I62:		movl	d7,d0
%I_UP_I64:		negl	d0
%I_UP_I66:		movl	d0,d7
%I_UP_I68:		tstb	d4
%I_UP_I6A:		beqs	%I_UP_I74
%I_UP_I6C:		moveq	#1,d0
%I_UP_I6E:		divsl	d7,d0
			movl	d0,d7
%I_UP_I74:
			movl	d7,d0
|			moveml	a7@+,#<d3,d4,d5,d6,d7>
			moveml	a7@+,#0x00f8
%I_UP_I7A:		unlk	a6
%I_UP_I7C:		rtd	#8
