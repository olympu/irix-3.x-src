| C library --  select

include(../DEFS.m4)

ENTRY(select)
	moveq	#114,d0
	movl	sp@(4),a0	| fetch argument
	movl	sp@(8),d1	| fetch argument
	movl	sp@(12),a1	| fetch argument
	movl	d2,saved2	| save d2 register
	movl	a2,savea2	|   and the a2 register
	movl	sp@(16),d2	| fetch argument
	movl	sp@(20),a2	| fetch argument
	trap	#0
	jcs	1$
	movl	saved2,d2	| restore d2 register
	movl	savea2,a2	|   and the a2 register
	rts

1$:
	movl	saved2,d2	| restore d2 register
	movl	savea2,a2	|   and the a2 register
	jmp	cerror

	.bss
saved2:	.space	4
savea2:	.space	4
