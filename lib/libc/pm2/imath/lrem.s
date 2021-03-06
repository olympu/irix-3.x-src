|signed long remainder: a = a % b

include(../DEFS.m4)

ASENTRY(lrem)
	moveml	#0x3800,sp@-	|need d2,d3,d4 registers
	moveq	#1,d4		|sign of result
	movl	sp@(16),d0	|dividend
	jge	1$
	negl	d0
	negb	d4
1$:	movl	d0,d2		|save positive dividend
	movl	sp@(20),d1	|divisor
	jge	golrem
	negl	d1
	jra	golrem

RASENTRY(rlrem)
	moveml	#0x3800,sp@-	|need d2,d3,d4 registers
	moveq	#1,d4		|sign of result
	tstl	d0		|dividend
	jge	8$
	negl	d0
	negb	d4
8$:	movl	d0,d2		|save positive dividend
	tstl	d1		|divisor
	jge	golrem
	negl	d1

golrem:
	cmpl	#0x10000,d1	|divisor < 2 ** 16?
	jge	3$		|no, divisor must be < 2 ** 16
	clrw	d0		|d0 =
	swap	d0		|   dividend high
	divu	d1,d0		|yes, divide
	movw	d2,d0		|d0 = remainder high + quotient low
	divu	d1,d0		|divide
	clrw	d0		|d0 = 
	swap	d0		|   remainder
	jra	6$		|return

3$:	movl	d1,d3		|save divisor
4$:	lsrl	#0x1,d0		|shift dividend
	lsrl	#0x1,d1		|shift divisor
	cmpl	#0x10000,d1	|divisor < 2 ** 16?
	jge	4$		|no, continue shift
	divu	d1,d0		|yes, divide
	andl	#0xFFFF,d0	|erase remainder
	movl	d3,d1		|  and saved divisor on stack
	jbsr	rulmul		|  as arguments
	cmpl	d0,d2		|original dividend >= lmul result?
	jge	5$		|yes, quotient should be correct
	subl	d3,d0		|no, fixup 
5$:	subl	d2,d0		|calculate
	negl	d0		|  remainder

6$:	tstb	d4		|sign of result
	jge	7$
	negl	d0
7$:	moveml	sp@+,#0x1C	|restore registers
	rts
