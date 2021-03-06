#	lib450.a make file
#	SCCS:	@(#)t450.mk	1.3

CC = cc$(SYS)

OL = /
SL = /usr/src/lib
INSDIR = $(OL)usr/lib
RDIR = $(SL)/libplot/t450
REL = current
INS = :
LIST = lp
TESTDIR = .
CFLAGS = -OB
SOURCE = con.h arc.c box.c circle.c close.c dot.c erase.c label.c \
	 line.c linmod.c move.c open.c point.c space.c subr.c
OFILES = arc.o box.o circle.o close.o dot.o erase.o label.o \
	 line.o linmod.o move.o open.o point.o space.o subr.o
MAKE = make

all:	lib$(SYS)450.a
	:

lib$(SYS)450.a:	$(OFILES)
	$(AR) r $(TESTDIR)/lib$(SYS)450.a $(OFILES)
	$(INS) $(TESTDIR)/lib$(SYS)450.a $(INSDIR)
	chmod 664 $(INSDIR)/lib$(SYS)450.a
	@if [ "$(OL)" = "/" ]; \
		then cd $(INSDIR); chown bin lib$(SYS)450.a; chgrp bin lib$(SYS)450.a; \
	 fi

install:
	$(MAKE) -f t450.mk INS=cp OL=$(OL) SYS=$(SYS) AR=$(AR)

build:	bldmk
	get -p -r`gsid t450 $(REL)` s.t450.src $(REWIRE) | ntar -d $(RDIR) -g
bldmk:
	get -p -r`gsid t450.mk $(REL)` s.t450.mk > $(RDIR)/t450.mk

listing:
	pr t450.mk $(SOURCE) | $(LIST)
listmk:
	pr t450.mk | $(LIST)

edit:
	get -p -e s.t450.src | ntar -g

delta:
	ntar -p $(SOURCE) > t450.src
	delta s.t450.src
	rm -f $(SOURCE)

mkedit:  ;  get -e s.t450.mk
mkdelta: ;  delta s.t450.mk

clean:
	-rm -f $(OFILES)

clobber: clean
	-rm -f $(TESTDIR)/lib450.a

delete:	clobber
	rm -f $(SOURCE)
