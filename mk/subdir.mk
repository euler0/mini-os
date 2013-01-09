# -*- Makefile -*-

all clean depend:
.for dir in ${SUBDIR}
	${MAKE} -C ${dir} ${.TARGET}
.endfor
