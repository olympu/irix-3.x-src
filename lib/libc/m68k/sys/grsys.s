| C library -- graphics

| error =  grioctl(cmd, data);

include(../DEFS.m4)

ENTRY(grioctl)
	moveq	#67,d0
	movl	sp@(4),a0	| fetch command
	movl	sp@(8),d1	|   and is data
	trap	#0
	jcs	1$
	rts

1$:	jmp	cerror
