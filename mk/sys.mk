# -*- Makefile -*-

.SUFFIXES: .o .c .a .S .asm

CC	?= clang
CFLAGS	?= -target i686 -std=c99 -fno-builtin -Os

AS	?= i686-elf-as
AFLAGS	?=
ACFLAGS	?= -E

LD	?= i686-elf-ld

NASM= nasm
NASMFLAGS= -f elf

.S.o:
	${CC} ${CFLAGS} ${ACFLAGS} -c -o ${.IMPSRC}.s ${.IMPSRC}
	${AS} ${ASFLAGS} -o ${.TARGET} ${.IMPSRC}.s

.asm.o:
	${NASM} ${NASMFLAGS} -o ${.TARGET} ${.IMPSRC}

.c.o:
	${CC} ${CFLAGS} -c -S -o ${.IMPSRC}.s ${.IMPSRC}
	${AS} ${ASFLAGS} -o ${.TARGET} ${.IMPSRC}.s
