/*
 * unctrl.h
 *
 * 1/26/81 (Berkeley) @(#)unctrl.h	1.1
 */

/*
 * $Source: /d2/3.7/src/usr.lib/libcurses/RCS/unctrl.h,v $
 * @(#)$Revision: 1.1 $
 * $Date: 89/03/27 18:35:14 $
 */

extern char	*_unctrl[];

# undef		unctrl
# define	unctrl(ch)	(_unctrl[(unsigned) ch])
