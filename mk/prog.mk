# -*- Makefile -*-

OBJS= ${SRCS:N*.h:R:S/$/.o/g}
# Generated assembly files
ASMS= ${SRCS:M*.c:R:S/$/.c.S/g}

DEPENDFILE= .depend
DPSRCS= ${SRCS:M*.c}

all: depend ${PROG}

${PROG}: ${OBJS}
	$(LD) $(LDFLAGS) -o ${.TARGET} ${.ALLSRC}

clean:
	rm -f ${PROG} ${OBJS} ${ASMS} ${DEPENDFILE}

depend: ${DEPENDFILE}

${DEPENDFILE}: ${DPSRCS}
	mkdep -f ${DEPENDFILE} -c ${.ALLSRC}
