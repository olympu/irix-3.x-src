static	char	*Rip_c	= "@(#)rip.c	1.17";
/*
 * File for the fun ends, currently only if you die
 *
 * @(#)rip.c	2.10 (Berkeley) 2/13/81
 */

#ifndef	STAND
#include <pwd.h>
#include <time.h>
#include <signal.h>
#include <ctype.h>
#endif
#include "rogue.h"
#include "mach_dep.h"

#define	TOPNUM	10
#define	NAMELEN	78

/* #define	DEBUGRIP 1 */

#ifndef	SMALL
static	char	killed[] = "Killed by an";
static	char	*rip[] = {
"                       __________",
"                      /          \\",
"                     /    REST    \\",
"                    /      IN      \\",
#ifdef	iris
"                   /                \\",
#else
"                   /     PEACE      \\",
#endif
"                  /                  \\",
"                  |                  |",
"                  |                  |",
"                  |                  |",
"                  |                  |",
"                  |       19xx       |",
"                 *|     *  *  *   *  | *",
"         ________)/\\\\_//(\\/(/\\)/\\//\\/|_)_______",
    0
};
static	char	*space	= "                                                                                                     ";
static	char	*sgspace	= "          ";	/* spaces generated by standout mode */

extern	char	*SO;		/* enter stand out mode			*/
extern	char	*SE;		/* enter stand out mode			*/
struct	passwd	*getpwuid();
#endif	SMALL

/*
 * death:
 *	Do something really fun when he dies
 */

death(monst)
char	monst;
{
#ifndef	SMALL
    reg1 rega1	char	**dp = rip;
    reg2 rega2	struct	tm *lt;
#endif	SMALL
    reg3 rega3	char	*killer;
#ifndef	SMALL
		long date;
		char	buf[80];
		struct	tm *localtime();
		int	i;
		int	j;

    time(&date);
    lt = localtime(&date);
    Clear();
    Move(8, 0);
    while (*dp)
	printw("%s\n", *dp++);
    purse -= purse/10;
    killer = killname(monst);
#ifdef	COLOR
    acolor(stdscr, C_green, Dbackground);
#endif
    sprintf(prbuf, "19%02d", lt->tm_year);
    mvaddstr(18, 26, prbuf);
#ifdef	COLOR
    if (CT) {
	for (i=0; i<NAMELEN; i++) {
	    Move(19, i);
	    if (inch() == '*' && CT) {
		do {
		    j = rnd(Ncolors);
		} while (j==Dbackground || j==Dforeground);
	        acolor(stdscr, j, Dbackground);
	        addch('*');
	    }
        }
	acolor(stdscr, C_green, Dbackground);
        mvaddstr(20, 0, rip[12]);
    }
#endif
    sprintf(buf, "%d Au", purse);
    if (!isvowel(*killer))				/* "Killed by a[n]" */
	killed[11] = '\0';
#ifdef	iris
    if (_iris) {
	Draw(stdscr);
	fcursor((double)25.5,(double)12.0);		/* X,Y */
	charstr("PEACE");
	fcursor(28.0-strlen(killed)/2.0, 16.0);		/* X,Y */
	charstr(killed);
	color(C_blue);
	fcursor(28.0-strlen(whoami)/2.0, 14.0);		/* X,Y */
	charstr(whoami);
	color(C_gold);
	fcursor(28.0-strlen(buf)/2.0, 15.0);		/* X,Y */
	charstr(buf);
	color(C_red);
	fcursor(28.0-strlen(killer)/2.0, 17.0);
	charstr(killer);
	color(WHITE);
    } else
#endif
    {
#ifdef	COLOR
	acolor(stdscr, C_blue, Dbackground);
#endif
	mvaddstr(14, 28-((strlen(whoami)+1)/2), whoami);
#ifdef	COLOR
	acolor(stdscr, C_gold, Dbackground);
#endif
	mvaddstr(15, 28-((strlen(buf)+1)/2), buf);
#ifdef	COLOR
	acolor(stdscr, C_red, Dbackground);
#endif
	mvaddstr(17, 28-((strlen(killer)+1)/2), killer);
#ifdef	COLOR
	acolor(stdscr, Dforeground, Dbackground);
#endif
	mvaddstr(12, 0, "                   /     PEACE      \\");
	mvaddstr(16, 28-((strlen(killed)+1)/2), killed);
    }
/*
 *  Move(LINES-1, 0);
 *  addch(' ');
 */
    Move(LINES-1, 0);
    printw("Hit RETURN to continue:");
    wait_prompt(stdscr,'\n');
    printw("\n");
    Draw(stdscr);
#ifndef	STAND
    score(purse, DIED, monst);
#endif	STAND
/*  gexit(); */
#endif	SMALL
#ifdef	SMALL
    Clear();
    Draw(stdscr);
#endif	SMALL
    endwin();
#ifdef	Curses
#ifdef	BSD
				/* damned if I know */
	if (CN)
		write(1,CN,strlen(CN));
#else
	if (CN)
		printf("%s",CN);
#endif	BSD
    resetty();		/* superstitious */
#endif	Curses
#ifdef	SMALL
    if (monst) {
	purse -= purse/10;
	killer = killname(monst);
	printf("Killed by a%s %s with %d Au\n",
	  isvowel(*killer)?"n":"",killer,purse);
    } else
	printf("Quit with %d Au\n",purse);
#endif	SMALL
    exit(0);
}

/*
 * score -- figure score and post it.
 */

#ifndef	STAND
#ifndef	SMALL
score(amount, flags, monst)
char	monst;
{
		struct	sc_ent {
			int	sc_score;
			char	sc_name[NAMELEN];
			int	sc_flags;
			int	sc_level;
			int	sc_account;
			char	sc_monster;
		} top_ten[TOPNUM];
		int	endit();
    reg1 regd1	int	fd;
    reg2 regd2	int	i;
    reg3 regd3	int	j;
    reg4 regd4	int	k;
    reg5 rega1	FILE	*outf;
		int	width;
		char	*logname;
		char	*getlogin();
		struct	passwd *pw;
		char	how[80];
		char	*killer;

    Clear();
    Move(1, 0);
    /*
     * Open file and read list
     */
    fd = open(SCOREFILE, 2);
    if (fd < 0)
	return;
    outf = fdopen(fd, "w");

    for (i = 0; i < TOPNUM; i++) {
	top_ten[i].sc_score = 0;
	for (j = 0; j < NAMELEN ; j++)
	    top_ten[i].sc_name[j] = rnd(255);
	top_ten[i].sc_flags = RN;
	top_ten[i].sc_level = RN;
	top_ten[i].sc_account = -1;
	top_ten[i].sc_monster = RN;
    }
    logname = getlogin();	/* what is his login name */

    signal(SIGINT, SIG_IGN);
    encread(top_ten, sizeof top_ten, fd);
    /*
     * Insert her in list if need be
     */
    if (!wizard) {
#ifdef	ROGUE2.6
	if (f_amulet) {
	    amount *= 2;
	    flags = WON;
	}
#endif	ROGUE2.6
	k = 0;
	for (i = 0; i < TOPNUM; i++)
		if (top_ten[i].sc_account==getuid()
/*
 *		  && !strcmp(logname,"guest")
 */
		  || !strcmp(top_ten[i].sc_name,whoami)) {
#ifdef	DEBUGRIP
		    if (!strcmp(whoami,"Bobby")) {
		        printw("i=%d account=%d getuid=%d name='%s' ",
		          i,top_ten[i].sc_account,getuid(),top_ten[i].sc_name);
		        printw("whoami='%s' logname='%s'\n",whoami,logname);
		        printw("  score=%d amount=%d k=%d\n",
		          top_ten[i].sc_score,amount,k);
		    }
#endif
		    if (amount <= top_ten[i].sc_score) {
#ifdef	DEBUGRIP
		    if (!strcmp(whoami,"Bobby"))
			printw("  zeroing out amount\n\n");
#endif
		        amount = 0;	/* suppress insertion */
		    }
		    if (amount > top_ten[i].sc_score || k) {
#ifdef	DEBUGRIP
		        if (!strcmp(whoami,"Bobby"))
			    printw("  removing entry\n");
#endif
			for (j = i; j < TOPNUM-1; j++)
			    top_ten[j] = top_ten[j+1];
			top_ten[TOPNUM-1].sc_score = 0;
		    }
		    k++;		/* remove multiple entries */
		}
	for (i = 0; i < TOPNUM; i++)
	    if (amount > top_ten[i].sc_score) {
	        for (j = TOPNUM-1; j > i; j--)
		    top_ten[j] = top_ten[j-1];
	        top_ten[i].sc_account = getuid();
	        top_ten[i].sc_score = amount;
	        strcpy(top_ten[i].sc_name, whoami);
	        top_ten[i].sc_flags = flags;
	        top_ten[i].sc_level = level;
		top_ten[i].sc_monster = monst;
		break;
	    }
    }
    width = 0;
    for (i = 0; i < TOPNUM; i++)
	if (top_ten[i].sc_score && top_ten[i].sc_name
	  && strlen(top_ten[i].sc_name) > width)
	    width = strlen(top_ten[i].sc_name);
    if (width > strlen(space))
	width = strlen(space);
    space[width] = '\0';
				/* cope with space used by stand out	*/
#ifdef	COLOR
    if (SG < 0 || !SO)
	sgspace[0] = '\0';
    else
	if (SG < 10)
	    sgspace[SG] = '\0';
#endif	COLOR
    /*
     * Print the list
     */
    printw("%sTop Ten Adventurers:\n%s%sRank    Score   Name\n",
      sgspace,
      (wizard?"Account  ":""),
      sgspace);
    for (i = 0; i < TOPNUM; i++)
	if (top_ten[i].sc_score) {
	    if (wizard) {
		pw = getpwuid(top_ten[i].sc_account);
		if (pw)
			printw("%-8s ",pw->pw_name);
		else
			printw("%-8d ",top_ten[i].sc_account);
	    }
	    if (!top_ten[i].sc_flags) {
		killer = killname(top_ten[i].sc_monster);
		sprintf(how," by a%s %s",vowelstr(killer),killer);
	    }
#ifdef	COLOR
	    if (CT && (top_ten[i].sc_flags&WON))
		Dcolor(stdscr,AMULET);
#endif
	    printw("%s%-2d      %-5d   %s%s %-6s on level %2d%s.%s\n",
#ifdef	COLOR
	      ((top_ten[i].sc_flags&WON)&&SO)?(CT?"":SO):sgspace,
#else
	      ((top_ten[i].sc_flags&WON)&&SO)?SO:sgspace,
#endif
	      i+1,						/* rank  */
	      top_ten[i].sc_score,				/* score */
	      top_ten[i].sc_name,				/* name  */
	      space+strlen(top_ten[i].sc_name),
	      (top_ten[i].sc_flags&WON)?"won" :
	        (top_ten[i].sc_flags&QUITIT)?"quit":"killed",	/* how   */
	      top_ten[i].sc_level,				/* level */
	      top_ten[i].sc_flags?"":how,			/* murderer */
#ifdef	COLOR
	      ((top_ten[i].sc_flags&WON)&&SE)?(CT?"":SE):"");
	      acolor(stdscr, Dforeground, Dbackground);
#else
	      ((top_ten[i].sc_flags&WON)&&SE)?SE:"");
#endif
	}
    fseek(outf, 0L, 0);
    /*
     * Update the list file
     */
    encwrite(top_ten, sizeof top_ten, outf);
    fclose(outf);
#ifdef	COLOR
    acolor(stdscr, C_magenta, Dbackground);
#endif
    printw("\nHit RETURN to continue:");
#ifdef	COLOR
    acolor(stdscr, Dforeground, Dbackground);
#endif
    wait_prompt(stdscr, '\n');
    printw("\n");
    Draw(stdscr);
    Clear();
    Draw(stdscr);
#ifdef	iris
    if (_iris) {
	doublebuffer();
	color(BLACK);
	glclear();
	swapbuffers();
	glclear();
	gexit();
	unlink(MUTEX);
	_iris = 0;
	printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\
\n\n\n\n\n\n\n\n\n\n");
    }
#endif
}
#endif	SMALL

total_winner()
{
#ifdef	SMALL
    Clear();
    endwin();
    printf("\nCongratulations, you have made it to the light of day!\n");
    exit(0);
#else	SMALL
    reg1 rega1	struct	linked_list *item;
    reg2 rega2	struct	object	*obj;
    reg3 regd1	int	worth;
    reg4 regd2	char	c;
    reg5 regd3	int	oldpurse;

#ifdef	iris
    if (_iris) {
	acolor(cw, C_blue, C_red);
	Clear();
	addch('\n');
    } else
#endif
    {
	Clear();
	standout();
    }
    addstr("                                                               \n");
    addstr("  @   @               @   @           @          @@@  @     @  \n");
    addstr("  @   @               @@ @@           @           @   @     @  \n");
    addstr("  @   @  @@@  @   @   @ @ @  @@@   @@@@  @@@      @  @@@    @  \n");
    addstr("   @@@@ @   @ @   @   @   @     @ @   @ @   @     @   @     @  \n");
    addstr("      @ @   @ @   @   @   @  @@@@ @   @ @@@@@     @   @     @  \n");
    addstr("  @   @ @   @ @  @@   @   @ @   @ @   @ @         @   @  @     \n");
    addstr("   @@@   @@@   @@ @   @   @  @@@@  @@@@  @@@     @@@   @@   @  \n");
    addstr("                                                               \n");
    addstr("     Congratulations, you have made it to the light of day!    \n");
#ifdef	iris
    if (_iris) {
	acolor(cw, C_red, C_blue);
    } else
#endif
    standend();
    addstr("\nYou have joined the elite ranks of those who have escaped the\n");
    addstr("Dungeons of Doom alive.  You journey home and sell all your loot at\n");
    addstr("a great profit and are admitted to the fighters guild.\n");
#ifdef	iris
    if (_iris)
	mvaddstr(LINES - 1, 0, "--Press space to continue--");
    else
#endif
	mvaddstr(0, 0, "Press space to continue");
    refresh();
    wait_for(' ');
    Clear();
    mvaddstr(1, 0, "   Worth  Item");
    oldpurse = purse;
    for (c = 'a', item = pack; item != NULL; c++, item = next(item)) {
	obj = (struct object *) ldata(item);
	switch (obj->o_type) {
	    case FOOD:
		worth = 2 * obj->o_count;
	    when WEAPON:
		switch (obj->o_which) {
		    case MACE: worth = 8;
		    when SWORD: worth = 15;
		    when BOW: worth = 75;
		    when ARROW: worth = 1;
		    when DAGGER: worth = 2;
		    when ROCK: worth = 1;
		    when TWOSWORD: worth = 30;
		    when SLING: worth = 1;
		    when DART: worth = 1;
		    when CROSSBOW: worth = 15;
		    when BOLT: worth = 1;
		    when SPEAR: worth = 2;
		    otherwise: worth = 0;
		}
		worth *= (1 + (10 * obj->o_hplus + 10 * obj->o_dplus));
		worth *= obj->o_count;
		obj->o_flags |= ISKNOW;
	    when ARMOR:
		switch (obj->o_which) {
		    case LEATHER: worth = 5;
		    when RING_MAIL: worth = 30;
		    when STUDDED_LEATHER: worth = 15;
		    when SCALE_MAIL: worth = 3;
		    when CHAIN_MAIL: worth = 75;
		    when SPLINT_MAIL: worth = 80;
		    when BANDED_MAIL: worth = 90;
		    when PLATE_MAIL: worth = 400;
		    otherwise: worth = 0;
		}
		worth *= (1 + (10 * (a_class[obj->o_which] - obj->o_ac)));
		obj->o_flags |= ISKNOW;
	    when SCROLL:
		s_know[obj->o_which] = TRUE;
		worth = s_magic[obj->o_which].mi_worth;
		worth *= obj->o_count;
	    when POTION:
		p_know[obj->o_which] = TRUE;
		worth = p_magic[obj->o_which].mi_worth;
		worth *= obj->o_count;
	    when RING:
		obj->o_flags |= ISKNOW;
		r_know[obj->o_which] = TRUE;
		worth = r_magic[obj->o_which].mi_worth;
		if (obj->o_which == R_ADDSTR || obj->o_which == R_ADDDAM ||
		    obj->o_which == R_PROTECT || obj->o_which == R_ADDHIT)
			if (obj->o_ac > 0)
			    worth += obj->o_ac * 20;
			else
			    worth = 50;
	    when WAND:
		obj->o_flags |= ISKNOW;
		W_know[obj->o_which] = TRUE;
		worth = W_magic[obj->o_which].mi_worth;
		worth += 20 * obj->o_charges;
	    when AMULET:
		worth = 1000;
	}
	mvprintw(c - 'a' + 2, 0, "%c) %5d  %s", c, worth, inv_name(obj, FALSE));
	purse += worth;
    }
    mvprintw(c - 'a' + 2, 0,"   %5d  Gold Peices          ", oldpurse);
    refresh();
    score(purse, 2);
    exit(0);
#endif	SMALL
}

char	*
killname(monst)
reg1 regd1	char	monst;
{
    if (isupper(monst))
	return monsters[monst-'A'].m_name;
    else
	switch (monst) {
	    case 'a':
		return "arrow";
	    case 'd':
		return "dart";
	    case 'b':
		return "bolt";
	}
    return "something odd";
}
#endif	STAND