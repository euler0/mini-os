PROG= kernel
SRCS= support.S multiboot.S 8259a.asm isr.asm x86.asm libc.c machdep.c kernel.c

LDFLAGS+= -T kernel.ld

.include <prog.mk>
