SUBDIR= src

COMMANDS= depend

${COMMANDS}: ${SUBDIR}
# 	@echo ${.TARGET}
# 	${MAKE} -m ${.CURDIR}/mk -C . ${.TARGET}

${SUBDIR}: .PHONY
	${MAKE} -m ${.CURDIR}/mk -C ${.TARGET}
