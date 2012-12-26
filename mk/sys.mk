# -*- Makefile -*-

.SUFFIXES: .o .c .a .asm

CC= clang
CFLAGS= -target i686 -std=c99 -fno-builtin -Os

AS= i686-elf-as
LD= i686-elf-ld

NASM= nasm
NASMFLAGS= -f elf

.asm.o:
	${NASM} ${NASMFLAGS} -o ${.TARGET} ${.IMPSRC}

.c.o:
	$(CC) $(CFLAGS) -c -S -o ${.IMPSRC}.S ${.IMPSRC}
	$(AS) $(ASFLAGS) -o ${.TARGET} ${.IMPSRC}.S
