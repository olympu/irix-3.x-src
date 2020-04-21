/* NFSSRC @(#)auth_kern.c	2.1 86/04/14 */
#ifndef lint
static char sccsid[] = "@(#)auth_kern.c 1.1 86/02/03 Copyr 1984 Sun Micro";
#endif

/*
 * auth_kern.c, Implements UNIX style authentication parameters in the kernel. 
 *  
 * Copyright (C) 1984, Sun Microsystems, Inc. 
 *
 * Interfaces with svc_auth_unix on the server.  See auth_unix.c for the user
 * level implementation of unix auth.
 *
 */

#ifdef SVR3
# include "sys/debug.h"
# include "sys/sysmacros.h"
# include "sys/param.h"
# include "sys/systm.h"
# include "sys/signal.h"
# include "sys/errno.h"
# include "sys/psw.h"
# include "sys/pcb.h"
# include "sys/user.h"
# include "sys/immu.h"
# include "sys/region.h"
# include "sys/sbd.h"
# include "sys/proc.h"
# include "sys/utsname.h"
# include "rpc/types.h"
# include "rpc/xdr.h"
# include "rpc/auth.h"
# include "rpc/auth_unix.h"
# include "netinet/in.h"
#else
# include "../h/param.h"
# include "../h/systm.h"
# include "../h/user.h"
# ifndef sgi
#  include "../h/kernel.h"
# endif
# include "../h/proc.h"
# include "../rpc/types.h"
# include "../rpc/xdr.h"
# include "../rpc/auth.h"
# include "../rpc/auth_unix.h"
# include "../netinet/in.h"
#endif

/*
 * Unix authenticator operations vector
 */
void	authkern_nextverf();
bool_t	authkern_marshal();
bool_t	authkern_validate();
bool_t	authkern_refresh();
void	authkern_destroy();

static struct auth_ops auth_kern_ops = {
	authkern_nextverf,
	authkern_marshal,
	authkern_validate,
	authkern_refresh,
	authkern_destroy
};


/*
 * Create a kernel unix style authenticator.
 * Returns an auth handle.
 */
AUTH *
authkern_create()
{
	register AUTH *auth;

	/*
	 * Allocate and set up auth handle
	 */
	auth = (AUTH *)kmem_alloc((u_int)sizeof(*auth));
	auth->ah_ops = &auth_kern_ops;
	auth->ah_verf = _null_auth;
	return (auth);
}

/*
 * authkern operations
 */

/*ARGSUSED*/
void
authkern_nextverf(auth)
	AUTH *auth;
{
	/* no action necessary */
}

bool_t
authkern_marshal(auth, xdrs)
	AUTH *auth;
	XDR *xdrs;
{
	char	*sercred;
	XDR	xdrm;
	struct	opaque_auth *cred;
	bool_t	ret = FALSE;
#ifndef sgi
 	register int *gp, *gpend;
#endif
	register int gidlen, credsize;
	register long *ptr;

	/*
	 * First we try a fast path to get through
	 * this very common operation.
	 */
#ifdef sgi
	gidlen = 0;
#else
 	gp = u.u_groups;
 	gpend = &u.u_groups[NGRPS];
 	while (gpend > u.u_groups && gpend[-1] < 0)
 		gpend--;
 	gidlen = gpend - gp;
#endif
	credsize = 4 + 4 + roundup(hostnamelen, 4) + 4 + 4 + 4 + gidlen * 4;
	ptr = XDR_INLINE(xdrs, 4 + 4 + credsize + 4 + 4);
	if (ptr) {
		/*
		 * We can do the fast path.
		 */
		IXDR_PUT_LONG(ptr, AUTH_UNIX);	/* cred flavor */
		IXDR_PUT_LONG(ptr, credsize);	/* cred len */
#ifdef sgi
		IXDR_PUT_LONG(ptr, time);	/* time in seconds */
#else
 		IXDR_PUT_LONG(ptr, time.tv_sec);
#endif
		IXDR_PUT_LONG(ptr, hostnamelen);
		bcopy(hostname, (caddr_t)ptr, (u_int)hostnamelen);
		ptr += roundup(hostnamelen, 4) / 4;
		IXDR_PUT_LONG(ptr, u.u_uid);
		IXDR_PUT_LONG(ptr, u.u_gid);
		IXDR_PUT_LONG(ptr, gidlen);
#ifndef sgi
		while (gp < gpend) {
			IXDR_PUT_LONG(ptr, *gp++);
		}
#endif
		IXDR_PUT_LONG(ptr, AUTH_NULL);	/* verf flavor */
		IXDR_PUT_LONG(ptr, 0);	/* verf len */
		return (TRUE);
	}
	sercred = (char *)kmem_alloc((u_int)MAX_AUTH_BYTES);
	/*
	 * serialize u struct stuff into sercred
	 */
	xdrmem_create(&xdrm, sercred, MAX_AUTH_BYTES, XDR_ENCODE);
	if (! xdr_authkern(&xdrm)) {
		printf("authkern_marshal: xdr_authkern failed\n");
		ret = FALSE;
		goto done;
	}

	/*
	 * Make opaque auth credentials that point at serialized u struct
	 */
	cred = &(auth->ah_cred);
	cred->oa_length = XDR_GETPOS(&xdrm);
	cred->oa_flavor = AUTH_UNIX;
	cred->oa_base = sercred;

	/*
	 * serialize credentials and verifiers (null)
	 */
	if ((xdr_opaque_auth(xdrs, &(auth->ah_cred)))
	    && (xdr_opaque_auth(xdrs, &(auth->ah_verf)))) {
		ret = TRUE;
	} else {
		ret = FALSE;
	}
done:
	kmem_free((caddr_t)sercred, (u_int)MAX_AUTH_BYTES);
	return (ret);
}

/*ARGSUSED*/
bool_t
authkern_validate(auth, verf)
	AUTH *auth;
	struct opaque_auth verf;
{

	return (TRUE);
}

/*ARGSUSED*/
bool_t
authkern_refresh(auth)
	AUTH *auth;
{
}

void
authkern_destroy(auth)
	register AUTH *auth;
{

	kmem_free((caddr_t)auth, (u_int)sizeof(*auth));
}
