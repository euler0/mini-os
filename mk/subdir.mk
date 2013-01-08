# -*- Makefile -*-

${SUBDIR}: .PHONY
	${MAKE} -C ${.TARGET}
