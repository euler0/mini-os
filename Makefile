all: buildkernel

buildkernel:
	${MAKE} -m ${.CURDIR}/mk -C src

clean depend:
	${MAKE} -m ${.CURDIR}/mk -C src ${.TARGET}
