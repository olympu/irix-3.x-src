|	GB - mc68020 FPA 5/19/85
|
#ifndef FPA_DEFS
#define FPA_DEFS
#include "float.h"
include(../DEFS.m4)
#endif

/*
|
|	dcmp.s 	- H/W floating point compare routines for the Juniper
|		  FPA.  The following entries are in this module:
|
|		_d_cmp	-  compare two doubles passed on the stack.
|
|	    register routines:
|		_dr_cmp -  compare two doubles passed in d0/d1.
|
|
|	Floating point exception handling - 
|
|	    When an error is detected in an operation in this module, 
|	a call to the appropriate floating point error handler is made
|	with arguments to indicate the error condition.  This consists
|	of a call to __lraise_fperror or __raise_fperror with the arguments
|	op and type.
|
*/
	.globl	__raise_fperror
	.globl	__lraise_fperror
/*
|
|
|	OPs follow:
|
*/
ADD 	=	1
SUB	=	2
MUL	=	3
DIV	=	4
FIX   	=	5	| precision to integer 
PRECISION =	6	| precision change to given precision 
MOD	=	7
CMP	=	8

|
|	TYPEs
|
INVALID_OP_A	=0x110
INVALID_OP_B2	=0x122
INVALID_OP_C	=0x130
INVALID_OP_D1	=0x141
INVALID_OP_D2	=0x142
INVALID_OP_E1	=0x151
INVALID_OP_E2	=0x152
INVALID_OP_G	=0x170
INVALID_OP_H	=0x180
|
DIVZERO		=0x200
OVERFLOW	=0x300
|
|
ASENTRY(_d_cmp)
|
|	sp@(4)	- first operand	(a of a COMP b)
|	sp@(12)	- second operand
|
|	uses f1 
|
	dwritefpahi(sp@(4),1)	| move first operand to f1 (msl)
	dwritefpalo(sp@(8),1)	| move first operand to f1 (lsl)
	dwritefpalo(sp@(16),0)	| move second operand (lsl) to d0
	dcmpx1(1,sp@(12))	| compare to second operand 
	tstb	FPA_CCR
	rts
