| C library -- gethostname

include(../DEFS.m4)

ENTRY(gethostname)
	moveq	#64,d0
	movl	sp@(4),a0	| fetch argument
	movl	sp@(8),d1	| fetch argument
	trap	#0
	jcs	1$
	moveq	#0, d0
	rts

1$:	jmp	cerror
