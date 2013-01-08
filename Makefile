all: buildkernel

buildkernel:
	${MAKE} -m ${.CURDIR}/mk -C src
