/**************************************************************************
 *									  *
 * 		 Copyright (C) 1984, Silicon Graphics, Inc.		  *
 *									  *
 *  These coded instructions, statements, and computer programs  contain  *
 *  unpublished  proprietary  information of Silicon Graphics, Inc., and  *
 *  are protected by Federal copyright law.  They  may  not be disclosed  *
 *  to  third  parties  or copied or duplicated in any form, in whole or  *
 *  in part, without the prior written consent of Silicon Graphics, Inc.  *
 *									  *
 **************************************************************************/
#include "device.h"
#include "sys/types.h"
#include "shmem.h"
#include "window.h"
#include "kb.h"
#include "kfont.h"
#include "gl.h"
#include <sys/printf.h>
#include <sys/sgigsc.h>

/*
 * Decoding structure for translating up/down keyboard strokes into ascii
 * key codes.
 *
 */
struct	kbutton {
	char	b_normal;		/* normal code */
	char	b_shift;		/* shifted code */
	char	b_control;		/* controlified code */
	char	b_controlshift;		/* controlshiftified code */
	char	b_alt;			/* alt code */
	char	b_gs_index;		/* GS char index */
};

/*
 * Decoding structure for translating up/down keyboard strokes into ascii
 * key codes.
 * GS or Extended keyboard character set
 *
 */
struct	ibutton {
	char	gs_normal;		/* normal code */
	char	gs_shift;		/* shifted code */
	char	gs_control;		/* controlified code */
	char	gs_controlshift;	/* controlshiftified code */
	char	gs_alt;			/* alt code */
};

/*
 * Data structure defining the function keys
 *
 */
struct	key_data {
	char	*k_name;
	short	k_len;
};

/*
 * Structure describing each  KEY in each distinct state
 * US and GS KEYboard
 *   Normal, Shifted, Control, Shift+Control, Alt, GS Index
 *   Note:
 *	defined buttons with 0xff values are decoded as their
 *		real KEYcodes and are general ignored 
 *	if a GS keyboard is sense and a keycode is not the same
 *		as that on a US keyboard, then use the GS index
 *		to get proper character.  Zero means no indexing
 *		required.
 */

struct kbutton kbuts[] = {
{0x80, 0x80, 0x80, 0x80, 0x80,  0},	/* BUTTON 0(00) - BREAK KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON 1(01) - SETUP KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON 2(02) - LEFT CTRL KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON 3(03) - CAPSLOCK KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON 4(04) - RIGHTSHIFT KEY*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON 5(05) - LEFTSHIFT KEY	*/
{0x1b, 0x1b, 0x1b, 0x1b, 0x1b,  0},	/* BUTTON 6(06) - ESC KEY	*/
{0x31, 0x21, 0x31, 0x21, 0x31,  0},	/* BUTTON 7(07) - ONE KEY	*/
{0x09, 0x09, 0x09, 0x09, 0x09,  0},	/* BUTTON 8(08) - TAB KEY	*/
{0x71, 0x51, 0x11, 0x11, 0x40,  0},	/* BUTTON 9(09) - Q KEY		*/
{0x61, 0x41, 0x01, 0x01, 0x61,  0},	/* BUTTON10(0a) - A KEY		*/
{0x73, 0x53, 0x13, 0x13, 0x73,  0},	/* BUTTON11(0b) - S KEY		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON12(0c) - NOSCROLL KEY	*/
{0x32, 0x40, 0x32, 0x00, 0xff,  1},	/* BUTTON13(0d) - TWO KEY	*/
{0x33, 0x23, 0x33, 0x23, 0xff,  2},	/* BUTTON14(0e) - THREE KEY	*/
{0x77, 0x57, 0x17, 0x17, 0x77,  0},	/* BUTTON15(0f) - W KEY		*/
{0x65, 0x45, 0x05, 0x05, 0x65,  0},	/* BUTTON16(10) - E KEY		*/
{0x64, 0x44, 0x04, 0x04, 0x64,  0},	/* BUTTON17(11) - D KEY		*/
{0x66, 0x46, 0x06, 0x06, 0x66,  0},	/* BUTTON18(12) - F KEY		*/
{0x7a, 0x5a, 0x1a, 0x1a, 0xff,  3},	/* BUTTON19(13) - Z KEY		*/
{0x78, 0x58, 0x18, 0x18, 0x78,  0},	/* BUTTON20(14) - X KEY		*/
{0x34, 0x24, 0x34, 0x24, 0x34,  0},	/* BUTTON21(15) - FOUR KEY	*/
{0x35, 0x25, 0x35, 0x25, 0x35,  0},	/* BUTTON22(16) - FIVE KEY	*/
{0x72, 0x52, 0x12, 0x12, 0x72,  0},	/* BUTTON23(17) - R KEY		*/
{0x74, 0x54, 0x14, 0x14, 0x74,  0},	/* BUTTON24(18) - T KEY		*/
{0x67, 0x47, 0x07, 0x07, 0x67,  0},	/* BUTTON25(19) - G KEY		*/
{0x68, 0x48, 0x08, 0x08, 0x68,  0},	/* BUTTON26(1a) - H KEY		*/
{0x63, 0x43, 0x03, 0x03, 0x63,  0},	/* BUTTON27(1b) - C KEY		*/
{0x76, 0x56, 0x16, 0x16, 0x76,  0},	/* BUTTON28(1c) - V KEY		*/
{0x36, 0x5e, 0x36, 0x1e, 0x36,  4},	/* BUTTON29(1d) - SIX KEY	*/
{0x37, 0x26, 0x37, 0x26, 0x37,  5},	/* BUTTON30(1e) - SEVEN KEY	*/
{0x79, 0x59, 0x19, 0x19, 0x79,  6},	/* BUTTON31(1f) - Y KEY		*/
{0x75, 0x55, 0x15, 0x15, 0x75,  0},	/* BUTTON32(20) - U KEY		*/
{0x6a, 0x4a, 0x0a, 0x0a, 0x6a,  0},	/* BUTTON33(21) - J KEY		*/
{0x6b, 0x4b, 0x0b, 0x0b, 0x6b,  0},	/* BUTTON34(22) - K KEY		*/
{0x62, 0x42, 0x02, 0x02, 0x62,  0},	/* BUTTON35(23) - B KEY		*/
{0x6e, 0x4e, 0x0e, 0x0e, 0x6e,  0},	/* BUTTON36(24) - N KEY		*/
{0x38, 0x2a, 0x38, 0x2a, 0x38,  7},	/* BUTTON37(25) - EIGHT KEY	*/
{0x39, 0x28, 0x39, 0x28, 0x39,  8},	/* BUTTON38(26) - NINE KEY	*/
{0x69, 0x49, 0x09, 0x09, 0x69,  0},	/* BUTTON39(27) - I KEY		*/
{0x6f, 0x4f, 0x0f, 0x0f, 0x6f,  0},	/* BUTTON40(28) - O KEY		*/
{0x6c, 0x4c, 0x0c, 0x0c, 0x6c,  0},	/* BUTTON41(29) - L KEY		*/
{0x3b, 0x3a, 0x3b, 0x3a, 0x3b,  9},	/* BUTTON42(2a) - SEMICOLON KEY	*/
{0x6d, 0x4d, 0x0d, 0x0d, 0xb5,  0},	/* BUTTON43(2b) - M KEY		*/
{0x2c, 0x3c, 0x2c, 0x3c, 0x2c, 10},	/* BUTTON44(2c) - COMMA KEY	*/
{0x30, 0x29, 0x30, 0x29, 0x30, 11},	/* BUTTON45(2d) - ZERO KEY	*/
{0x2d, 0x5f, 0x2d, 0x1f, 0x2d, 12},	/* BUTTON46(2e) - MINUS KEY	*/
{0x70, 0x50, 0x10, 0x10, 0x70,  0},	/* BUTTON47(2f) - P KEY		*/
{0x5b, 0x7b, 0x1b, 0x1b, 0x5b, 13},	/* BUTTON48(30) - LEFT BRACKET	*/
{0x27, 0x22, 0x27, 0x22, 0x27, 14},	/* BUTTON49(31) - QUOTE KEY	*/
{0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 15},	/* BUTTON50(32) - RETURN KEY	*/
{0x2e, 0x3e, 0x2e, 0x3e, 0x2e, 16},	/* BUTTON51(33) - PERIOD KEY	*/
{0x2f, 0x3f, 0x2f, 0x3f, 0x2f, 17},	/* BUTTON52(34) - VIRGULE KEY	*/
{0x3d, 0x2b, 0x3d, 0x2b, 0x3d, 18},	/* BUTTON53(35) - EQUAL ACCENT 	*/
{0x60, 0x7e, 0x60, 0x7e, 0x60, 19}, 	/* BUTTON54(36) - ACCENTGRAVE KEY*/
{0x5d, 0x7d, 0x1d, 0x7d, 0x5d, 20},	/* BUTTON55(37) - RIGHTBRACKET KEY*/
{0x5c, 0x7c, 0x1c, 0x7c, 0x5c, 21},	/* BUTTON56(38) - BACKSLASH KEY	*/
{0x8a, 0x8a, 0x8a, 0x8a, 0x8a,  0},	/* BUTTON57(39) - PAD ONE KEY	*/
{0x89, 0x89, 0x89, 0x89, 0x89,  0},	/* BUTTON58(3a) - PAD ZERO KEY	*/
{0x0a, 0x0a, 0x0a, 0x0a, 0x0a,  0},	/* BUTTON59(3b) - LINEFEED	*/
{0x08, 0x08, 0x08, 0x08, 0x08,  0},	/* BUTTON60(3c) - BACKSPACE KEY	*/
{0x7f, 0x7f, 0x7f, 0x7f, 0x7f,  0},	/* BUTTON61(3d) - DELETE KEY	*/
{0x8d, 0x8d, 0x8d, 0x8d, 0x8d,  0},	/* BUTTON62(3e) - PAD FOUR KEY	*/
{0x8b, 0x8b, 0x8b, 0x8b, 0x8b,  0},	/* BUTTON63(3f) - PAD TWO KEY	*/
{0x8c, 0x8c, 0x8c, 0x8c, 0x8c,  0},	/* BUTTON64(40) - PAD THREE KEY	*/
{0x95, 0x95, 0x95, 0x95, 0x95,  0},	/* BUTTON65(41) - PAD PERIOD KEY*/
{0x90, 0x90, 0x90, 0x90, 0x90,  0},	/* BUTTON66(42) - PAD SEVEN KEY	*/
{0x91, 0x91, 0x91, 0x91, 0x91,  0},	/* BUTTON67(43) - PAD EIGHT KEY	*/
{0x8e, 0x8e, 0x8e, 0x8e, 0x8e,  0},	/* BUTTON68(44) - PAD FIVE KEY	*/
{0x8f, 0x8f, 0x8f, 0x8f, 0x8f,  0},	/* BUTTON69(45) - PAD SIX KEY	*/
{0x82, 0x82, 0x82, 0x82, 0x82,  0},	/* BUTTON70(46) - PAD PF2 KEY	*/
{0x81, 0x81, 0x81, 0x81, 0x81,  0},	/* BUTTON71(47) - PAD PF1 KEY	*/
{0x88, 0x88, 0x88, 0x88, 0x88,  0},	/* BUTTON72(48) - LEFTARROW KEY	*/
{0x86, 0x86, 0x86, 0x86, 0x86,  0},	/* BUTTON73(49) - DOWNARROW KEY	*/
{0x92, 0x92, 0x92, 0x92, 0x92,  0},	/* BUTTON74(4a) - PAD NINE KEY	*/
{0x93, 0x93, 0x93, 0x93, 0x93,  0},	/* BUTTON75(4b) - PAD MINUS KEY	*/
{0x94, 0x94, 0x94, 0x94, 0x94,  0},	/* BUTTON76(4c) - PAD COMMA KEY	*/
{0x84, 0x84, 0x84, 0x84, 0x84,  0},	/* BUTTON77(4d) - PAD PF4 KEY	*/
{0x83, 0x83, 0x83, 0x83, 0x83,  0},	/* BUTTON78(4e) - PAD PF3 KEY	*/
{0x87, 0x87, 0x87, 0x87, 0x87,  0},	/* BUTTON79(4f) - RIGHTARROW KEY*/
{0x85, 0x85, 0x85, 0x85, 0x85,  0},	/* BUTTON80(50) - UPARROW KEY	*/
{0x96, 0x96, 0x96, 0x96, 0x96,  0},	/* BUTTON81(51) - PAD ENTER KEY	*/
{0x20, 0x20, 0x20, 0x20, 0x20,  0},	/* BUTTON82(52) - SPACK KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON83(53) - LEFT  ALT KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON84(54) - RIGHT ALT KEY	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON85(55) - RIGHT CTRL KEY*/
{0x81, 0x81, 0x81, 0x81, 0x81,  0},	/* BUTTON86(56) - F1->PF1	*/
{0x82, 0x82, 0x82, 0x82, 0x82,  0},	/* BUTTON87(57) - F2->PF2	*/
{0x83, 0x83, 0x83, 0x83, 0x83,  0},	/* BUTTON88(58) - F3->PF3	*/
{0x84, 0x84, 0x84, 0x84, 0x84,  0},	/* BUTTON89(59) - F4->PF4	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON90(5a) - F5->SETUP	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON91(5b) - F6		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON92(5c) - F7		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON93(5d) - F8		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON94(5e) - F9		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON95(5f) - F10		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON96(60) - F11		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON97(61) - F12		*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON98(62) - PRINT SCREEN	*/
{0xff, 0xff, 0xff, 0xff, 0xff,  0},	/* BUTTON99(63) - SCROLL LOCK	*/
{0xff, 0xff, 0xff, 0xff, 0x80,  0},	/* BUTTON100(64) - PAUSE/BREAK	*/
{0x97, 0x97, 0x97, 0x97, 0x97,  0},	/* BUTTON101(65) - INSERT	*/
{0x98, 0x98, 0x98, 0x98, 0x98,  10},	/* BUTTON102(66) - HOME		*/
{0x99, 0x99, 0x99, 0x99, 0x99,  0},	/* BUTTON103(67) - PAGE UP	*/
{0x9a, 0x9a, 0x9a, 0x9a, 0x9a,  0},	/* BUTTON104(68) - END		*/
{0x9b, 0x9b, 0x9b, 0x9b, 0x9b,  0},	/* BUTTON105(69) - PAGE DOWN	*/
{0x9c, 0x9c, 0x9c, 0x9c, 0x9c,  0},	/* BUTTON106(6a) - NUMLOCK	*/
{0xf7, 0xf7, 0xf7, 0xf7, 0xf7,  0},	/* BUTTON107(6b) - DIVISION KEY	*/
{0xd7, 0xd7, 0xd7, 0xd7, 0xd7,  0},	/* BUTTON108(6c) - MULTIPLY KEY	*/
{0x2b, 0x2b, 0x2b, 0x2b, 0x9e,  0},	/* BUTTON109(6d) - PAD PLUS KEY */
{0x3c, 0x3e, 0x3c, 0x3e, 0xa6,  0},	/* BUTTON110(6d) - LESS THAN KEY*/
};

struct ibutton ibuts[] = {
	{0x00, 0x00, 0x00, 0x00, 0x00}, /*  0-NOT USED			*/
	{0x32, 0x22, 0x32, 0x22, 0xb2},	/*  1-BUTTON13(0d) - TWO KEY	*/
	{0x33, 0xa7, 0x33, 0xa7, 0xb3},	/*  2-BUTTON14(0e) - THREE KEY	*/
	{0x79, 0x59, 0x19, 0x19, 0x79},	/*  3-BUTTON19(13) - Y KEY	*/
	{0x36, 0x26, 0x36, 0x26, 0x36},	/*  4-BUTTON29(1d) - SIX KEY	*/
	{0x37, 0x2f, 0x37, 0x2f, 0x7b},	/*  5-BUTTON30(1e) - SEVEN KEY	*/
	{0x7a, 0x5a, 0x1a, 0x1a, 0x7a},	/*  6-BUTTON31(1f) - Z KEY	*/
	{0x38, 0x28, 0x38, 0x28, 0x5b},	/*  7-BUTTON37(25) - EIGHT KEY	*/
	{0x39, 0x29, 0x39, 0x29, 0x5d},	/*  8-BUTTON38(26) - NINE KEY	*/
	{0xf6, 0xd6, 0xf6, 0xd6, 0xf6},	/*  9-BUTTON42(2a) - O W/DIAERESIS*/
	{0x2c, 0x3b, 0x2c, 0x3b, 0x2c},	/* 10-BUTTON44(2c) - COMMA KEY	*/
	{0x30, 0x3d, 0x30, 0x3d, 0x7d},	/* 11-BUTTON45(2d) - ZERO KEY	*/
	{0xdf, 0x3f, 0xdf, 0x3f, 0x5c},	/* 12-BUTTON46(2e) - SHARPS KEY	*/
	{0xfc, 0xdc, 0xfc, 0xdc, 0xfc},	/* 13-BUTTON48(30) - U W/DIAERESIS*/
	{0xe4, 0xc4, 0xe4, 0xc4, 0xe4},	/* 14-BUTTON49(31) - A W/DIAERESIS*/
	{0x23, 0x27, 0x23, 0x27, 0x23},	/* 15-BUTTON50(32) - NUMBERSIGN KEY*/
	{0x2e, 0x3a, 0x2e, 0x3a, 0x2e},	/* 16-BUTTON51(33) - PERIOD KEY	*/
	{0x2d, 0x5f, 0x2d, 0x5f, 0x2d},	/* 17-BUTTON52(34) - DASH KEY	*/
	{0xb4, 0x60, 0xb4, 0x60, 0x7c},	/* 18-BUTTON53(35) - ACUTE ACCENT*/
	{0x5e, 0xb0, 0x5e, 0xb0, 0x5e}, /* 19-BUTTON54(36) - CIRCUMFLEX ACCENT*/
	{0x2b, 0x2a, 0x2b, 0x2a, 0x7e}, /* 20-BUTTON55(37) - PLUS KEY	*/
	{0x0d, 0x0d, 0x0d, 0x0d, 0x0d},	/* 21-BUTTON56(38) - RETURN KEY	*/
};

/*
 * Data for the default function keys
 *
 */
struct key_data funcnumeric[] = {	/* numeric function keys */
	{ "\033P", 2 },	/* PF1 */
	{ "\033Q", 2 },	/* PF2 */
	{ "\033R", 2 },	/* PF3 */
	{ "\033S", 2 },	/* PF4 */
	{ "\033A", 2 },	/* uparrow */
	{ "\033B", 2 },	/* downarrow */
	{ "\033C", 2 },	/* rightarrow */
	{ "\033D", 2 },	/* left arrow */
	{ "0", 1 },	/* 0 key */
	{ "1", 1 },	/* 1 key */
	{ "2", 1 },	/* 2 key */
	{ "3", 1 },	/* 3 key */
	{ "4", 1 },	/* 4 key */
	{ "5", 1 },	/* 5 key */
	{ "6", 1 },	/* 6 key */
	{ "7", 1 },	/* 7 key */
	{ "8", 1 },	/* 8 key */
	{ "9", 1 },	/* 9 key */
	{ "-", 1 },	/* dash key */
	{ ",", 1 },	/* comma key */
	{ ".", 1 },	/* period */
	{ "\r", 1 },	/* return */
	{ "\033?p", 3 },	/* insert key */
	{ "\033?w", 3 },	/* home key */
	{ "\033?y", 3 },	/* page up key */
	{ "\033?q", 3 },	/* end key */
	{ "\033?s", 3 },	/* page down key */
	{ "\033=",  2 },	/* reset NUMLOCK */
	{ "\033>",  2 },	/* set   NUMLOCK */

};

struct key_data funckeypad[] = {	/* keypadmode functions keys */
	{ "\033P", 2 },	/* PF1 */
	{ "\033Q", 2 },	/* PF2 */
	{ "\033R", 2 },	/* PF3 */
	{ "\033S", 2 },	/* PF4 */
	{ "\033A", 2 },	/* uparrow */
	{ "\033B", 2 },	/* downarrow */
	{ "\033C", 2 },	/* rightarrow */
	{ "\033D", 2 },	/* left arrow */
	{ "\033?p", 3 },	/* 0 key */
	{ "\033?q", 3 },	/* 1 key */
	{ "\033?r", 3 },	/* 2 key */
	{ "\033?s", 3 },	/* 3 key */
	{ "\033?t", 3 },	/* 4 key */
	{ "\033?u", 3 },	/* 5 key */
	{ "\033?v", 3 },	/* 6 key */
	{ "\033?w", 3 },	/* 7 key */
	{ "\033?x", 3 },	/* 8 key */
	{ "\033?y", 3 },	/* 9 key */
	{ "\033?m", 3 },	/* dash key */
	{ "\033?l", 3 },	/* comma key */
	{ "\033?n", 3 },	/* period */
	{ "\033?M", 3 },	/* return */
	{ "\033?p", 3 },	/* insert key */
	{ "\033?w", 3 },	/* home key */
	{ "\033?y", 3 },	/* page up key */
	{ "\033?q", 3 },	/* end key */
	{ "\033?s", 3 },	/* page down key */
	{ "\033=",  2 },	/* reset NUMLOCK */
	{ "\033>",  2 },	/* set   NUMLOCK */
};

#define	NKEYS		(sizeof(funcnumeric) / sizeof(struct key_data))

int kybrd_init, kb_type;

struct key_resp_tbl {
	short ktype;
	char *resp;
	char *desc;
} ktbl[] = {
	KB_US, KB_IRIS_STD, "IRIS 3000 Keyboard",
	KB_GS, KB_IRIS_ISO, "GS Keyboard",
	KB_DBG, KB_4D_STD, "US Extended Keyboard"
};
#define def_kbd 0	/* index 0 into ktbl is the default kbd type */
int nkeyboards = sizeof (ktbl) / sizeof (struct key_resp_tbl);

#ifdef GSDEBUG
int gs_debug = 0;
#endif

static int (*softintr[4])();

/*
 * kb_reset:
 *	- perform whatever initialization is needed to reset the keyboard
 *	  to a known state
 */
kb_reset()
{
    kb_setclick(0);
}

int kb_softchar();

kb_init()
{
    static short firsted = 0;

    if(!firsted) {
	kb_reset();
	gl_setporthandler(0,kb_softchar);
	firsted++;
	kybrd_init = 1;			/* kbd init in progress */
	kb_putc(WHO_RU_0);		/* request KB ID */
	kb_putc(WHO_RU_1);
    }
}

gl_portinuse(port)
	short port;
{
	return softintr[port] ? 1 : 0;
}

gl_softintr(port, c)
	short port;
	char c;
{
	int (*fp)();

	if (fp = softintr[port]) {
		(*fp)(c);
		return 1;
	}
	return 0;
}

gl_setporthandler(port, fp)
	short port;
	int (*fp)();
{
	softintr[port] = fp;
}

char kbd_resp[10];
short pass = 0;

kb_softchar(c)
    unsigned char c;
{
    short normal_char = 1;
    short kbd_set = 0;

    if (kybrd_init) {
	/*
	 * kbd init in progress (should only happen once after bootup)
	 * - characters read will tell us the keyboard type;
	 * - unrecognized characters will be passed through
	 *     as normal keyed characters.
	 */
	struct key_resp_tbl *k;
	int i;

	kbd_resp[pass++] = c;
	kbd_resp[pass] = '\0';
#ifdef GSDEBUG
	if (gs_debug)
		printf("\nRESP = %x", (u_int) c);
#endif
	for (i = 0; i < nkeyboards; i++) {
		if (strncmp(kbd_resp, ktbl[i].resp, pass) == 0) {
#ifdef GSDEBUG
			if (gs_debug)
			    printf("\tpass = %d, match with %x %x\n", pass,
				(u_char) kbd_resp[0], (u_char) kbd_resp[1]);
#endif
			/* match found up to pass characters */
			break;
		}
	}
	if (i == nkeyboards) {
		/*
		 * No match found.
		 */
		printf("Unknown Keyboard - assuming %s\n",
			ktbl[def_kbd].desc);
		kb_type = ktbl[def_kbd].ktype;
		++kbd_set;
	} else if (pass == 2 || strcmp(kbd_resp, KB_IRIS_STD) == 0) {
		/*
		 * Match found. An IRIS kbd only requires a 1-char match.
		 */
		normal_char = 0;
		kb_type = ktbl[i].ktype;
		++kbd_set;
		printf("%s\n", ktbl[i].desc);
	} else {
		/*
		 * A partial match found.  Keep going.
		 */
		normal_char = 0;
	}

	if (kbd_set) {
		kybrd_init = 0;
		if (kb_type == KB_GS) {
			defont_nc = MAXFONTNC;
			defont_nr = max_defont_nr;
		} else {
			defont_nc = MINFONTNC;
			defont_nr = min_defont_nr;
		}
		kb_setclick(0);
	}
    }
    if (normal_char) {
	if (gl_kbport && (gl_kbport->ic_doqueue & DQ_RAWKEYBOARD))
		gr_qenter(gl_kbport, RAWKEYBD, c);
	else
		kb_translate(c);
    }
}

/*
 * kb_translate:
 *	- translate a key code into a given string of characters, returning
 *	  the number of characters returned, or -1 indicating no key to send
 *	- return 0 for the break key
 *	- holding down SETUP inhibits queue entries
 * TODO	- add in SETUP RESET for zapping running graphics process and
 *	  reset'ing things
 * TODO	- add in funny key support for queue's
 */
kb_translate(key)
	register unsigned char key;
{
	register short stroke;
	register unsigned char ascii, nu_key;
 	register short i;
 	register unsigned char *cptr;
	register short isstatekey;
	register short state_mask;

	/* turn display on again */
	kunblanklater();

	{
		struct sgigsc_qentry qe;

		qe.event = SGE_KB;
		qe.ev.ascii = key;
		sgqenter(&qe);
	}

	stroke = KB_SCANCTOUPDN(key);
	key    = KB_SCANCTOKEYC(key);
	isstatekey = 0;
	/*
	 * Map F5 key (GS kbd only) to SETUP
	 */
	if (key == F5KEY)
		key = KEY_SETUP;

#ifdef GSDEBUG
#ifdef 0
	if ( (key == 0x0c || key == 0x63) && stroke == 0) {/* no scroll key */
		kb_type = (++kb_type) % (KB_DBG+1);
		if (kb_type == KB_US) {
			gs_debug = 0;
			defont_nc = MINFONTNC;
			defont_nr = min_defont_nr;
			printf("\nUS keyboard\n");
		} else if (kb_type == KB_GS) {
			gs_debug = 0;
			defont_nc = MAXFONTNC;
			defont_nr = max_defont_nr;
			printf("\nGS keyboard\n");
		} else if (kb_type == KB_DBG) {
			gs_debug = 1;
			defont_nc = MINFONTNC;
			defont_nr = min_defont_nr;
			printf("\nUS Extended keyboard w/key echo\n");
		}
	}

	if (key == 0x0c || key == 0x63)
		isstatekey++;
	if (gs_debug)
		printf("\n KEY:STROKE(hex)>> %x:%x\n",key,stroke);
#endif
#endif

	/*
	 * handle shift, control, and caps lock, & alt keys
	 */
	if (key == KEY_LEFT_SHIFT) {
		if (stroke)
		    gl_kbdstate |= STATE_LEFTSHIFT;
		else
		    gl_kbdstate &= ~STATE_LEFTSHIFT;
		isstatekey++;
	}
	if (key == KEY_RIGHT_SHIFT) {
		if (stroke)
		    gl_kbdstate |= STATE_RIGHTSHIFT;
		else
		    gl_kbdstate &= ~STATE_RIGHTSHIFT;
		isstatekey++;
	}
	if (key == KEY_CTRL) {
		if (stroke)
		    gl_kbdstate |= STATE_CTRL;
		else
		    gl_kbdstate &= ~STATE_CTRL;
	  	isstatekey++;
	}
	if (key == KEY_CAPSLOCK) {
		if (stroke == 0)
		    	gl_kbdstate ^= STATE_CAPSLOCK;
	  	isstatekey++;
	}
	/*
	 * The following keys apply only to the GS keyboard
	 */
	if (key == KEY_RIGHT_CTRL) {
		if (stroke)
		    gl_kbdstate |= STATE_RIGHTCTRL;
		else
		    gl_kbdstate &= ~STATE_RIGHTCTRL;
	  	isstatekey++;
	}
	if (key == KEY_LEFT_ALT) {
		if (stroke)
		    gl_kbdstate |= STATE_LEFTALT;
		else
		    gl_kbdstate &= ~STATE_LEFTALT;
		isstatekey++;
	}
	if (key == KEY_RIGHT_ALT) {
		if (stroke)
		    gl_kbdstate |= STATE_RIGHTALT;
		else
		    gl_kbdstate &= ~STATE_RIGHTALT;
		isstatekey++;
	}
    
	/*
	 * If button is queue'd add it to the queue.
	 * Add in button offset (HACK) 
	 * If the gl used this button, don't give it to UNIX.
	 */
	if(ChangeButton(KB_KEYCTODEV(key),stroke))
		return;			

	/* throw away key releases and invalid key codes */
	if (isstatekey || (stroke == 0) || (key > BUTCOUNT)
	               || (key == KEY_SETUP))
		return;

	/*
	 * Use state_mask for saving a copy of gl_kbdstate with
	 * the NUMLOCK bit cleared.  gl_kbdstate will be restored
	 * immediately after checking for various states.
	 *
	 */
	state_mask = gl_kbdstate; 
	gl_kbdstate &= ~STATE_NUMLOCK;

	/*
	 * If GS keyboard, ibuts[] as well as kbuts[] is used for
	 * looking up ascii values.
	 */
	switch (gl_kbdstate) {
	  case 0:			/* normal key */
		if (kb_type == KB_GS) {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_normal;
		    else
		        ascii = kbuts[key].b_normal;
		} else
		    ascii = kbuts[key].b_normal;

		break;

	  case STATE_LEFTSHIFT:
	  case STATE_RIGHTSHIFT:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT:
	  case STATE_LEFTSHIFT+STATE_CAPSLOCK:
	  case STATE_RIGHTSHIFT+STATE_CAPSLOCK:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_CAPSLOCK:
		if (kb_type == KB_GS) {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_shift;
		    else
		        ascii = kbuts[key].b_shift;
		} else
		    ascii = kbuts[key].b_shift;
	  	break;

	  case STATE_CTRL:
	  case STATE_RIGHTCTRL:
	  case STATE_CTRL+STATE_CAPSLOCK:
	  case STATE_RIGHTCTRL+STATE_CAPSLOCK:
	  case STATE_CTRL+STATE_RIGHTCTRL+STATE_CAPSLOCK:
		if (kb_type == KB_GS) {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_control;
		    else
		        ascii = kbuts[key].b_control;
		} else
		    ascii = kbuts[key].b_control;
		break;

	  case STATE_LEFTSHIFT+STATE_CTRL:
	  case STATE_LEFTSHIFT+STATE_RIGHTCTRL:
	  case STATE_LEFTSHIFT+STATE_CTRL+STATE_CAPSLOCK:
	  case STATE_LEFTSHIFT+STATE_RIGHTCTRL+STATE_CAPSLOCK:
	  case STATE_RIGHTSHIFT+STATE_CTRL:
	  case STATE_RIGHTSHIFT+STATE_RIGHTCTRL:
	  case STATE_RIGHTSHIFT+STATE_CTRL+STATE_CAPSLOCK:
	  case STATE_RIGHTSHIFT+STATE_RIGHTCTRL+STATE_CAPSLOCK:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_CTRL:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_RIGHTCTRL:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_CTRL+STATE_CAPSLOCK:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_RIGHTCTRL+STATE_CAPSLOCK:
	  case STATE_LEFTSHIFT+STATE_RIGHTSHIFT+STATE_CTRL+STATE_RIGHTCTRL+STATE_CAPSLOCK:
		if (kb_type == KB_GS) {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_controlshift;
		    else
		        ascii = kbuts[key].b_controlshift;
		} else
		    ascii = kbuts[key].b_controlshift;
		break;

	  case STATE_CAPSLOCK:
		if (kb_type == KB_GS)  {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_normal;
		    else
		        ascii = kbuts[key].b_normal;
		    
		    if ( ((ascii >= 'a') && (ascii <= 'z')) ||
		    		((ascii >= '\340') && (ascii <= '\377')) )
			ascii = ascii - 32;
		} else {
		    ascii = kbuts[key].b_normal;
		    if ((ascii >= 'a') && (ascii <= 'z'))
			ascii = ascii - 32;
		}
		break;

	  case STATE_RIGHTALT:
	  case STATE_LEFTALT:
	  case STATE_LEFTALT+STATE_RIGHTALT:
		/*
		 * ALT key sensed: 
		 *  If GS, then process using gs_index.
		 *  If KEY equals 0x64, then ALT-PAUSE is a BREAK and
		 *    is valid, else reject all ALT states.
		 */
		if (kb_type == KB_GS) {
		    if ((nu_key = kbuts[key].b_gs_index) != 0)
			ascii = ibuts[nu_key].gs_alt;
		    else
		        ascii = kbuts[key].b_alt;
		} else if (key == 0x64)
		    ascii = kbuts[key].b_alt;
		else
		    ascii = 0xff;
		break;

	  default:
		/*
		 * Cases with shift/alt/control or any illegal
		 * combination will be ignored
		 */
		kb_ringbell();
		return;
	}
	gl_kbdstate = state_mask;	/* restore NUMLOCK bit */

#ifdef	UNIX
{
	extern short kdebug;
	if (kdebug && (key == 66) && (gl_kbdstate & STATE_CTRL) &&
	   (gl_kbdstate & (STATE_LEFTSHIFT | STATE_RIGHTSHIFT))) {
		setConsole(CONSOLE_NOT_ON_PTY);
		resetConsole();
		debug("you rang?");
	}
}
#endif

	/*
	 * Filter out ascii values of 0xff.  These are nops and are
	 * meant to be ignored
	 */
	if (ascii == 0xff)
		 return;

	/*
	 * Return "normal" keycode
	 */
	if (((ascii & 0x80) == 0)
	   || ((ascii & 0x7f) > NKEYS)) {
		/* don't queue it if SETUP key is down */
        	if (gl_curric && gl_curric->ic_shmemptr && 
			(gl_curric->ic_doqueue & DQ_KEYBOARD) &&
					!gl_buttons[SETUPKEY].state)
			inter_qenter(KEYBD, ascii);
		else if(gl_textportno >= 0)
			win_softintr(gl_textportno,ascii,0);
		return;
	}

	if(gl_textportno < 0)
		return;

	/*
	 * if a break key, just return 0
	 */
	if (ascii == 0x80) {
		win_softintr(gl_textportno, 0, 1);
		return;
	}

	/*
	 * See if key is a special key (function key)
	 */
	if ((ascii & 0x7f) <= NKEYS) {
		register struct key_data *kp;

		if (key == KEY_NUMLOCK) {
			gl_kbdstate ^= STATE_NUMLOCK;
		        if ( (gl_kbdstate & STATE_NUMLOCK) != 0)
			    ascii = 0x9d;	/* numeric keypad mode */
		}
		if (txport[gl_textportno].tx_keypadmode) 
		    kp = &funckeypad[(ascii & 0x7F) - 1];
		else
		    kp = &funcnumeric[(ascii & 0x7F) - 1];
		cptr = (u_char *)kp->k_name;
		for(i=kp->k_len; i--;)
			win_softintr(gl_textportno,*cptr++,0);
		return;
	}
}

static int clickstate = 0;
static int bellstate = KBD_SHORTBEEP;
static int lightstate = 0;

kb_ringbell()
{
    kb_putc(bellstate|clickstate);
}

kb_setclick(state)
short state;
{
    if(state)
	clickstate = 0;
    else
	clickstate = KBD_CLICK;
    kb_putc(clickstate);
}

kb_setlamp(state,arg)
short state;
short arg;
{
    arg &= 0x3f;
    arg = (arg>>4) | (arg<<2);
    arg <<= 1;
    if(state) 
        lightstate |= arg;
    else
	lightstate &= ~arg;
    kb_putc(lightstate | KBD_LEDCMD);
}

kb_setbell(arg)
short arg;
{
    switch(arg) {
	case 0: bellstate = 0;
		break;
	case 1: bellstate = KBD_SHORTBEEP;
		break;
	case 2: bellstate = KBD_LONGBEEP;
		break;
    } 
}
