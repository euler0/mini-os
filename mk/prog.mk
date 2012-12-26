# -*- Makefile -*-

OBJS= ${SRCS:N*.h:R:S/$/.o/g}

${PROG}: ${OBJS}
	$(LD) $(LDFLAGS) -o ${.TARGET} ${.ALLSRC}

# DEPENDFILE?= .depend
# MKDEP_CFLAGS= -MD
# DPSRCS= ${SRCS:M*.c}

# depend: ${DEPENDFILE}

# ${DEPENDFILE}: ${DPSRCS}
# 	${CC} ${CFLAGS} ${MKDEP_CFLAGS} -c ${.ALLSRC}
