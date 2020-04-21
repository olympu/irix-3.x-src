/*
**	stsub.c		- Copyright (C), JCS Computer Services 1983
**			- Author: chase
**			- Date: January 1985
**			- Any use, copying or alteration is prohibited
**			- and morally inexcusable,
**			- unless authorized in writing by JCS.
**	$Source: /d2/3.7/src/stand/cmd/sifex/RCS/sisub.c,v $
**	$Revision: 1.1 $
**	$Date: 89/03/27 17:13:21 $
** 	Subroutines for the Interphase Storage Disk controller
**
*/
/*
** NOTES:
** there is a bug in the storager firmware in which the status is
** not valid for a short time after done is posted in the register.
** This is a problem in formatting the drive
*/

#define FMTWAIT 0

#include "types.h"
#include <sys/dklabel.h>
#include "disk.h"
#include "streg.h"
#include "fex.h"
#ifdef juniper
#include "mbenv.h"
#endif
extern char *stcmdlist[];
extern char *sterrlist[];
extern long tape_flags;
extern char fmtflag;

iopb_t *iop;
iopb_t *tiop;
uib_t *uib;

#define	ST_INIT	0x02		/* Controller Initted */
#define CMDOFFSET	0x80
#define ERROFFSET	0x10
#define WAIT(time)	for(i=time; i; i--)
#ifdef	SGI
extern u_long st_ioaddr;
#endif	SGI

int initializing = 0;
u_long dmacount = 0;

stinit()
{
	register int i, s;
	register u_long addr;

	if(drivep->label.d_magic != D_MAGIC) {
		printf("Drive %d not initialized!!\n", dunit);
		return 1;
	}
	if(isinited[dunit]) {
		printf(" already done\n");
		return 0;
	}
	initializing = 1;
	WAIT(20000);
	iop = (iopb_t *)(0x7f000);
#ifdef juniper
	iop = (iopb_t *)mbptov(iop);
#endif
	tiop = (iopb_t *)((char *)iop + sizeof *iop);
	uib = (uib_t *)((char *)tiop + sizeof *tiop);
	/*
	** Write the io registers to the board
	*/
	regload();
	addr = (u_long)uib;

	iop->i_option	= OP_OPTIONS;
	iop->i_status	= 0;
	iop->i_error	= 0;
	iop->i_unit	= dunit;
	iop->i_head	= 0;
	iop->i_cylh	= 0;
	iop->i_cyll	= 0;
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_scch	= 0;
	iop->i_sccl	= 0;
	/*
	iop->i_scch	= MB(drivep->label.d_sectors);
	iop->i_sccl	= LB(drivep->label.d_sectors);
	*/
	/*
	** Make the DMA count at 0 which is maximum.
	*/
	iop->i_dmacount	= dmacount;
	iop->i_bufh	= HB(addr);
	iop->i_bufm	= MB(addr);
	iop->i_bufl	= LB(addr);
	iop->i_ioh	= MB(st_ioport);
	iop->i_iol	= LB(st_ioport);
	iop->i_rell 	= iop->i_relh 	= 0;
	iop->i_linkl 	= iop->i_linkh	= iop->i_linkm = 0;
	iop->i_tapeunit	= 0;
	iop->i_cmd	= C_INIT;

	uib->u_hds	= drivep->label.d_heads;
	uib->u_spt	= drivep->label.d_sectors;
	uib->u_bpsl	= (secsize[dunit] & 0xff);
	uib->u_bpsh	= ((secsize[dunit] >> 8) & 0xff);

	gap1 = (u_char)drivep->label.d_misc[0];
	uib->u_gap1	= gap1;
	gap2	= (u_char)drivep->label.d_misc[1];
	uib->u_gap2	= gap2;
	gap3	= (u_char)drivep->label.d_misc[2];
	uib->u_gap3	= gap3;
	ilv = (u_char)drivep->label.d_interleave;
	if(ilv == 0)
		ilv = 1;
	uib->u_ilv 	= ilv;
	uib->u_retry	= stretries;
	steccon = (u_char)drivep->label.d_misc[9];
	uib->u_eccon = steccon;
	uib->u_reseek	= streseek;
	if(floppy)
		uib->u_reseek = 0;
	uib->u_mvbad	= stmvbad;	/* Move Bad Data */
	uib->u_inchd	= stinchd;	/* Increment by head */
	uib->u_resv0 	= 0;
	uib->u_intron	= 0;		/* Interrupt on status change */
	/* Skew spirial factor */
	uib->u_skew	= (u_char)drivep->label.d_cylskew;
	uib->u_resv1 	= 0;		/* Group Size (2190) */
	uib->u_mohu 	= (u_char)drivep->label.d_misc[10];

	if ((drivep->label.d_misc[13] & 0x40) == 0)
		drivep->label.d_misc[13] |= 0x40;	/* Must be set */
	if (drivep->label.d_misc[13] & 1)
		cacheenable = 1;
	else
		cacheenable = 0;
	if (drivep->label.d_misc[13] & 2)
		zerolatency = 1;
	else
		zerolatency = 0;
	uib->u_options	= (u_char)drivep->label.d_misc[13];
	uib->u_options |= 4;		/* UPDATE IOPB */
	if (floppy)
		uib->u_options &= ~(1);	/* Turn off cache */

	esditype[dunit]	= (u_char)drivep->label.d_misc[11];
	uib->u_ddb	= esditype[dunit];
	uib->u_smc	= (u_char)drivep->label.d_misc[12];
	uib->u_spw	= (u_char)drivep->label.d_misc[3];
	uib->u_spil 	= (((u_short)drivep->label.d_misc[4])&0xff);
	uib->u_spih	= ((((u_short)drivep->label.d_misc[4])>>8)&0xff);
	uib->u_hlst	= (u_char)drivep->label.d_misc[8];
	uib->u_ttst	= (u_char)drivep->label.d_misc[5];
	uib->u_ncl	= LB(drivep->label.d_cylinders);
	uib->u_nch	= MB(drivep->label.d_cylinders);
	uib->u_wpscl = (((u_short)drivep->label.d_misc[6])&0xff);
	uib->u_wpsch = ((((u_short)drivep->label.d_misc[6])>>8)&0xff);
	uib->u_rwcscl = (((u_short)drivep->label.d_misc[7])&0xff);
	uib->u_rwcsch = ((((u_short)drivep->label.d_misc[7])>>8)&0xff);

	if(stcmd()) {
		initializing = 0;
		return 1;
	}
	isinited[dunit] = 1;
	initializing = 0;
	return 0;
}

long	dcyl, dhd, dsec;	/* To be operated on */
explode(lba)
{
	register i;

	i = drivep->label.d_heads*drivep->label.d_sectors;
	dcyl = lba / i;
	dhd  = lba % i;
	dhd /= drivep->label.d_sectors;
	dsec = lba % drivep->label.d_sectors;
}

rdata(ns, lba, memp)
	char *memp;
{
	return rwdata(ns, lba, memp, C_READ);
}

wdata(ns, lba, memp)
	char *memp;
{
	return rwdata(ns, lba, memp, C_WRITE);
}

rwdata(ns, lba, memp, fn)
	char *memp;
{
	register u_long addr = (u_long)memp;

	explode(lba);

	iop->i_cmd	= fn;
	iop->i_unit	= dunit;
	iop->i_cylh	= MB(dcyl);
	iop->i_cyll	= LB(dcyl);
	iop->i_sech	= MB(dsec);
	iop->i_secl	= LB(dsec);
	iop->i_head	= dhd;
	iop->i_sccl	= LB(ns);
	iop->i_scch	= MB(ns);
	iop->i_bufl	= LB(addr);
	iop->i_bufm	= MB(addr);
	iop->i_bufh	= HB(addr);
	iop->i_option 	= OP_OPTIONS;
	iop->i_iol 	= LB(st_ioport);
	iop->i_ioh 	= MB(st_ioport);

	if(stcmd()) {
		if (errhalt) {
			printf("rwdata: Failure at %d/%d/%d\n",
				dcyl, dhd, dsec);
			isinited[dunit] = 0;
		}
		return 1;
	}
	return 0;
}

fmt()
{
	register cyl, hd;
	register int i, j;
	register int timeout = 100000;

	j = 0;
	if (fmtflag)
		j = 1;
	for(cyl = j; cyl < drivep->label.d_cylinders; cyl++) {
		for(hd = 0; hd < drivep->label.d_heads; hd++) {
			iop->i_cmd	= C_FORMAT;
			iop->i_unit	= dunit;
			iop->i_cylh	= MB(cyl);
			iop->i_cyll	= LB(cyl);
			iop->i_sech	= 0;
			iop->i_secl	= 0;
			iop->i_sccl	= LB(drivep->label.d_sectors);
			iop->i_scch	= MB(drivep->label.d_sectors);
			iop->i_head	= hd;
			iop->i_option 	= OP_OPTIONS;
			iop->i_iol = LB(st_ioport);
			iop->i_ioh = MB(st_ioport);

			while((i = STATUS()) & ST_BUSY) {
				if(!(--timeout)) {
					printf("ST%d: Busy fmt()(%x)(%x)\n",
						dunit, i, STATUS());
					isinited[dunit] = 0;
					if (verbose) stpp();
					return 1;
				}
			}
#ifdef NOTDEF
			if(Fmtwait) {
				i = Fmtwait;
				while (--i);
			}
#endif NOTDEF
			iop->i_error = iop->i_status = 0;
			if (verbose) stpp();
			START();
			if(stwait()) {
				printf("ST%d: Fmt error at %d/%d\n",
					dunit, cyl, hd);
				isinited[dunit] = 0;
				if (verbose) stpp();
				return 1;
			}
			/* I have trouble reading the keyboard */
			/* Try it twice */
			if (nwgch() != -1)
				return 1;
			if (nwgch() != -1)
				return 1;
		}
    		if(cyl && (cyl%10) == 0) QP1("%3d ",cyl);
	}
	return 0;
}

fmtb(bad, good)
{
	register int timeout = 1000000;
	register int i;

	explode(bad);
	iop->i_head	= dhd;
	iop->i_cylh	= MB(dcyl);
	iop->i_cyll	= LB(dcyl);
	QP2("bad %d/%d -> good ", dcyl, dhd);

	explode(good);
	iop->i_scch	= MB(dcyl);		/* New Cylinder */
	iop->i_sccl	= LB(dcyl);		/* New Cylinder */
	iop->i_sech	= 0;			/* 0 */
	iop->i_secl	= dhd;			/* New Head */
	iop->i_unit	= dunit;
	iop->i_option 	= OP_OPTIONS;		/* bus buffer word mode */
	iop->i_iol = LB(st_ioport);
	iop->i_ioh = MB(st_ioport);
	QP2("%d/%d\n", dcyl, iop->i_secl);
	
	/*
	 * Now start the formatting
	 */
	iop->i_cmd	= C_MAP;
	while((i = STATUS()) & ST_BUSY) {
		if(!(--timeout)) {
			printf("ST%d: Busy fmt()(%x)(%x)\n",
				dunit, i, STATUS());
			isinited[dunit] = 0;
			return 1;
		}
	}
#ifdef NOTDEF
	if(Fmtwait) {
		i = Fmtwait;
		while (--i);
	}
#endif NOTDEF
	iop->i_error = iop->i_status = 0;
	START();
	if(stwait()) {
		printf("ST%d: fmtb error at %d/%d\n",
			dunit, dcyl, dhd);
		if(verbose) stpp();
		isinited[dunit] = 0;
		return 1;
 	}
	return 0;
}

long sslba;
dseek(cyl)
{
	iop->i_unit	= dunit;
	iop->i_cylh	= MB(cyl);
	iop->i_cyll	= LB(cyl);
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_sccl	= LB(drivep->label.d_sectors);
	iop->i_scch	= MB(drivep->label.d_sectors);
	iop->i_head	= 0;
	iop->i_cmd	= C_SEEK;
	iop->i_option 	= OP_OPTIONS;		/* bus buffer word mode */
	iop->i_iol = LB(st_ioport);
	iop->i_ioh = MB(st_ioport);
	/*
	 * Start the operation
	 */
	if(stcmd()) {
		printf("seek: Failure at %d/%d\n", cyl, iop->i_head);
		isinited[dunit] = 0;
		if(verbose) stpp();
		return 1;
	}
	return 0;
}

report()
{
	iop->i_cmd	= C_REPORT;
	iop->i_unit	= dunit;
	/*
	 * Start the operation
	 */
	if(stcmd()) {
		printf("report: failure\n");
		isinited[dunit] = 0;
		stpp();
		return 1;
	}
	/*
	 * Print out the report Information
	 */
	printf("\nThe Report information on the Storager is:\n");
	printf("\nFirmware Revision: %d.%d, ",
		((iop->i_error>>4)&0xf), iop->i_error&0xf);
	if(iop->i_unit)
		printf("Extension: %c, ", iop->i_unit);
	else
		printf("Extension: %d, ", iop->i_unit);
	printf("Product Code: %x", iop->i_head);
	if(iop->i_cylh || iop->i_cyll)
		printf(", Options: %x %x\n", iop->i_cyll, iop->i_cylh);
	else
		printf("\n");
	return 0;
}

/*
** stcmd() - Command to start and check controller for operation
**	    - It assumes the complete iopb is set up.
*/
stcmd()
{
	register int timeout = 100000;
	register int i;

	while((i = STATUS()) & ST_BUSY) {
		if((--timeout) == 0) {
			printf("ST%d: Busy on entering stcmd()(%x)(%x)\n",
				dunit, i, STATUS());
			return 1;
		}
	}
	iop->i_error = 0;
	iop->i_status = 0;
	if (verbose)
		stpp();
	START();
	timeout = 2000;
	while(--timeout);
	timeout = 400000;
	for(;;) {
		if(iop->i_status == S_OK) {
			if (verbose)
				stpp();
			CLEAR();
			return 0;
		}
		if(iop->i_status == S_ERROR) {
			printf("\nst%d: e: %x s: %x c: %s ERROR: %s\n",
				dunit, iop->i_error,
				iop->i_status,
				stcmdlist[iop->i_cmd - CMDOFFSET],
				sterrlist[iop->i_error - ERROFFSET]);
			if (verbose)
				stpp();
			CLEAR();
			if (!errhalt) {
				streset();
				isinited[dunit] = 0;
				stinit();
			}
			return 1;
		}
		if((--timeout) == 0) {
			printf("\nst%d: TIMEOUT: s %x err %x c: %s\n",
				dunit, iop->i_status, iop->i_error,
				stcmdlist[iop->i_cmd - CMDOFFSET]);
			if (verbose)
				stpp();
			CLEAR();
			if (!errhalt) {
				streset();
				isinited[dunit] = 0;
				stinit();
			}
			return 1;
		}
	}
}

stwait()
{
	register int i;
	register int timeout = 1000000;
	register j = 2000;

	for(;;) {
		if(iop->i_status == S_OK) {
			CLEAR();
			while(--j);
			return 0;
		}
		if(iop->i_status == S_ERROR) {
			printf("ST%d: ERROR(%x) Cmd %s status %x err %s\n",
				dunit, iop->i_error,
				stcmdlist[iop->i_cmd - CMDOFFSET],
				iop->i_status,
				sterrlist[iop->i_error - ERROFFSET]);
			CLEAR();
			while(--j);
			if(verbose) stpp();
			return 1;
		}
		if((--timeout) == 0) {
			switch (iop->i_status) {
		 	case S_BUSY:
		 	case S_ERROR:
				printf("ST%d: Cmd %s timeout: s %x err %x\n",
					dunit,stcmdlist[iop->i_cmd - CMDOFFSET],
					iop->i_status, iop->i_error);
				CLEAR();
				while(--j);
				if(verbose) stpp();
				return 1;
		 	default:
				CLEAR();
				while(--j);
				printf("ST%d: cmd %s Timeout status %x\n",
					dunit,stcmdlist[iop->i_cmd - CMDOFFSET],
					dunit, iop->i_status);
				if(verbose) stpp();
				return 1;
			}	
		}
	}
}

verify()
{
	register cyl, hd;

	printf("Verify disk %d\n", dunit);
	for(cyl = 0; cyl < drivep->label.d_cylinders; cyl++) {
		for(hd = 0; hd < drivep->label.d_heads; hd++) {
			iop->i_cmd	= C_VERIFY;
			iop->i_unit	= dunit;
			iop->i_cylh	= MB(cyl);
			iop->i_cyll	= LB(cyl);
			iop->i_sech	= 0;
			iop->i_secl	= 0;
			iop->i_sccl	= LB(drivep->label.d_sectors);
			iop->i_scch	= MB(drivep->label.d_sectors);
			iop->i_head	= hd;
			iop->i_option   = OP_OPTIONS;
			iop->i_iol = LB(st_ioport);
			iop->i_ioh = MB(st_ioport);

			if(stcmd()) {
				if (errhalt) {
					printf("Failure at %d/%d\n", cyl, hd);
					return 1;
				}
			}
			if(nwgch() != -1) return 1;
			if(nwgch() != -1) return 1;
    		}
    		if(cyl && (cyl%10) == 0) QP1("%3d ",cyl);
	}
	printf("\n");
	return 0;
}

reformat()
{
	register cyl, hd;

	printf("Reformat disk %d\n", dunit);
	for(cyl = 0; cyl < drivep->label.d_cylinders; cyl++) {
		for(hd = 0; hd < drivep->label.d_heads; hd++) {
			iop->i_cmd	= C_REFORMAT;
			iop->i_unit	= dunit;
			iop->i_cylh	= MB(cyl);
			iop->i_cyll	= LB(cyl);
			iop->i_sech	= 0;
			iop->i_secl	= 0;
			iop->i_head	= hd;
			iop->i_option 	= OP_OPTIONS;/* bus buffer word mode */
			iop->i_iol = LB(st_ioport);
			iop->i_ioh = MB(st_ioport);

			if(stcmd()) {
				printf("ST%d: Reformat error at %d/%d\n",
					dunit, cyl, hd);
				isinited[dunit] = 0;
				return 1;
			}
			if(nwgch() != -1) {
				return 1;
			}
		}
    		if(cyl && (cyl%10) == 0) QP1("%3d ",cyl);
	}
	return 0;
}

restor()
{

	iop->i_unit	= dunit;
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_sccl	= LB(drivep->label.d_sectors);
	iop->i_scch	= MB(drivep->label.d_sectors);
	iop->i_option 	= OP_OPTIONS;		/* bus buffer word mode */
	iop->i_iol 	= LB(st_ioport);
	iop->i_ioh 	= MB(st_ioport);

	iop->i_cmd	= C_RESTORE;
	if(stcmd()) {
		printf("Restor: Failure\n");
		if(verbose) stpp();
		isinited[dunit] = 0;
	}
}

stpp()
{
	printf("iop%d: c:%s o:%x %d/%d/%d s:%x e:%x scc:%d buf:%x\n",
		iop->i_unit, stcmdlist[iop->i_cmd - CMDOFFSET], iop->i_option,
		((iop->i_cylh << 8) | iop->i_cyll), iop->i_head,
		((iop->i_sech << 8) | iop->i_secl), iop->i_status,
		iop->i_error, ((iop->i_scch << 8) | iop->i_sccl),
		(((iop->i_bufh << 16) | (iop->i_bufm << 8)) | iop->i_bufl));
	if (!initializing)
		return;

	printf("uib: h %d, s %d, bps %d, gaps %d %d %d, ilv %d ret %d\n",
		uib->u_hds, uib->u_spt, ((uib->u_bpsh <<8) | uib->u_bpsl),
		uib->u_gap1, uib->u_gap2, uib->u_gap3, uib->u_ilv,
		uib->u_retry);

	printf("uib: ecc %x rsk %x mvbad %x inchd %x res %x intst %x sk %x\n",
		uib->u_eccon, uib->u_reseek, uib->u_mvbad, uib->u_inchd,
		uib->u_resv0, uib->u_intron, uib->u_skew);

	printf("uib2: mohu %x, opt %x, ddb %x, smc %x, spw %x, spi %x\n",
		uib->u_mohu, uib->u_options, uib->u_ddb, uib->u_smc,
		uib->u_spw, ((uib->u_spih <<8) | uib->u_spil));
	printf("uib3: hlst %x ttst %x nc %d wpsc %x rwcsc %x \n",
		uib->u_hlst, uib->u_ttst, ((uib->u_nch<<8) | uib->u_ncl),
		((uib->u_wpsch<<8) | uib->u_wpscl),
		((uib->u_rwcsch<<8) | uib->u_rwcscl));
#ifdef NOTDEF
	printf("error iopb stat %x iopb err %x reg0 %x\n",
			iop->i_status, iop->i_error,
			STATUS());
#endif
}

ippp(name, ptr, len)
	u_char *name, *ptr;
{
	int i,nwords;

	printf("\n%s (swapped words):\n",name);
	nwords = len/2;
	for (i=0;i<nwords;i++)
	{
		printf("[%d] = 0x%x  ",i*2, *(ptr+1));
		printf("[%d] = 0x%x  ",i*2+1, *ptr);
		ptr+=2;
	}
	printf("\n");
}

streset()
{
	register i;
	register timeout;

	RESET();
	i = 20000;
	while (--i);
	ZERO();
	timeout = 100000;
	/* Wait for the done bit to go away */
	while ((STATUS() & ST_DONE) && --timeout) ;
	if (!timeout)
		return 1;

	timeout = 100000;
	/* Wait for the done bit to come true */
	while (((STATUS() & ST_DONE) == 0) && --timeout);
	if (!timeout)
		return 1;

	CLEAR();
	i = 20000;
	while (--i);
	TCLEAR();
	timeout = 1000000;
	while ((STATUS() & ST_DONE) && --timeout) ;
	if (!timeout)
		return 1;
	isinited[dunit] = 0;
	tape_flags = 0;
	printf("\n");
	return 0;
}

/*
** Reload or load up the three registers with the IOPB Address
** Adjusted to set up both iopb's.......
*/
regload()
{
	register u_long addr = (u_long)iop;

	(*((char *)(st_ioaddr+ST_R1))) = HB(addr);
	(*((char *)(st_ioaddr+ST_R2))) = MB(addr);
	(*((char *)(st_ioaddr+ST_R3))) = LB(addr);
	addr = (u_long)tiop;
	(*((char *)(st_ioaddr+ST_R5))) = HB(addr);
	(*((char *)(st_ioaddr+ST_R6))) = MB(addr);
	(*((char *)(st_ioaddr+ST_R7))) = LB(addr);
}

recalibrate()
{
	iop->i_cmd	= C_RESTORE;
	iop->i_unit	= dunit;
	iop->i_cylh	= 0;
	iop->i_cyll	= 0;
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_head	= 0;
	iop->i_option 	= OP_OPTIONS;
	iop->i_iol = LB(st_ioport);
	iop->i_ioh = MB(st_ioport);

	printf("\n");
	if (stcmd()) {
		printf("st%d: error in recalibration\n", dunit);
		return 1;
	}
	return 0;
}

fmtsel(cyl,hd)
	u_long cyl, hd;
{
	register int i;
	register int timeout = 100000;

	iop->i_cmd	= C_FORMAT;
	iop->i_unit	= dunit;
	iop->i_cylh	= MB(cyl);
	iop->i_cyll	= LB(cyl);
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_head	= hd;
	iop->i_option 	= OP_OPTIONS;
	iop->i_iol = LB(st_ioport);
	iop->i_ioh = MB(st_ioport);

	while((i = STATUS()) & ST_BUSY) {
		if(!(--timeout)) {
			printf("ST%d: Busy fmt()(%x)(%x)\n",
				dunit, i, STATUS());
			isinited[dunit] = 0;
			return 1;
		}
	}
#ifdef NOTDEF
	if(Fmtwait) {
		i = Fmtwait;
		while (--i);
	}
#endif NOTDEF
	iop->i_error = iop->i_status = 0;
	if (verbose) stpp();
	START();
	if(stwait()) {
		printf("ST%d: Fmt error at %d/%d\n",
			dunit, cyl, hd);
		isinited[dunit] = 0;
		return 1;
	}
	return 0;
}

rdheaders(cyl,hd)
	u_long cyl, hd;
{
	register int i;
	register int timeout = 100000;
	register u_long addr = (u_long)BUF0;

	iop->i_cmd	= C_RDHDRS;
	iop->i_unit	= dunit;
	iop->i_cylh	= MB(cyl);
	iop->i_cyll	= LB(cyl);
	iop->i_sech	= 0;
	iop->i_secl	= 0;
	iop->i_head	= hd;
	iop->i_bufl	= LB(addr);
	iop->i_bufm	= MB(addr);
	iop->i_bufh	= HB(addr);
	iop->i_option 	= OP_OPTIONS;
	iop->i_iol 	= LB(st_ioport);
	iop->i_ioh 	= MB(st_ioport);

	while((i = STATUS()) & ST_BUSY) {
		if(!(--timeout)) {
			printf("ST%d: Busy fmt()(%x)(%x)\n",
				dunit, i, STATUS());
			isinited[dunit] = 0;
			return 1;
		}
	}
	iop->i_error = iop->i_status = 0;
	if (verbose) stpp();
	START();
	if(stwait()) {
		printf("sd%d: read header error at %d/%d\n",
			dunit, cyl, hd);
		isinited[dunit] = 0;
		return 1;
	}
	return 0;
}

selverify(lba,count)
	register lba, count;
{

	explode(lba);
	iop->i_cmd	= C_VERIFY;
	iop->i_unit	= dunit;
	iop->i_cylh	= MB(dcyl);
	iop->i_cyll	= LB(dcyl);
	iop->i_sech	= LB(dsec);
	iop->i_secl	= MB(dsec);
	iop->i_sccl	= LB(count);
	iop->i_scch	= MB(count);
	iop->i_head	= dhd;
	iop->i_option   = OP_OPTIONS;
	iop->i_iol 	= LB(st_ioport);
	iop->i_ioh 	= MB(st_ioport);

	if(stcmd()) {
		if (errhalt)
			printf("selverify: Failure at %d/%d/%d\n",
				dcyl, dhd, dsec);
		return 1;
	}
	return 0;
}

spindown()
{

	iop->i_cmd	= C_SPINUP;
	iop->i_unit	= dunit;
	iop->i_error = iop->i_status = 0;
	if (verbose) stpp();
	START();
	if(stwait()) {
		printf("si%d: spin down Error\n", dunit);
		stpp();
		isinited[dunit] = 0;
		return 1;
	}
	return 0;
}

spinup()
{

	iop->i_cmd	= C_SPINUP;
	iop->i_unit	= dunit;
	iop->i_cyll	= 1;
	iop->i_error = iop->i_status = 0;
	if (verbose) stpp();
	START();
	if(stwait()) {
		printf("si%d: spin up Error\n", dunit);
		stpp();
		isinited[dunit] = 0;
		return 1;
	}
	return 0;
}
