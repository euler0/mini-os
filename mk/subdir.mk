# -*- Makefile -*-

${SUBDIR}: .PHONY
	${MAKE} -m ${.CURDIR}/mk -C ${.TARGET}
