all: multiboot.o isr.o libc.o kernel.o

multiboot.o: multiboot.asm
	nasm $(NASMFLAGS) -o $@ $<

isr.o: isr.asm
	nasm $(NASMFLAGS) -o $@ $<

libc.o: libc.c libc.h
	$(CC) $(CFLAGS) -S -o $<.S $<
	$(AS) $(ASFLAGS) -o $@ $<.S

kernel.o: kernel.c kernel.h libc.h
	$(CC) $(CFLAGS) -S -o $<.S $<
	$(AS) $(ASFLAGS) -o $@ $<.S
	OBJS+= $@
