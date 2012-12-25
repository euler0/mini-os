AS= i686-elf-as
ASFLAGS=
CC= clang
CFLAGS= -target i686 -std=c99 -fno-builtin -O2 -c
LD= i686-elf-ld
LDFLAGS=
OBJCOPY= i686-elf-objcopy
NASMFLAGS= -f bin

kernel.img: kernel.elf
	cat $^ > $@

boot.bin: boot.asm
	nasm $(NASMFLAGS) -o $@ $<

#kernel.bin: kernel.elf
#	${OBJCOPY} -S -O binary $< $@

kernel.elf: multiboot.o kernel.o libc.o kernel.lds
	${LD} ${LDFLAGS} -T kernel.lds -o $@ $< kernel.o libc.o

libc.o: libc.s
	${AS} ${ASFLAGS} -o $@ $<

libc.s: libc.c libc.h
	${CC} ${CFLAGS} -S -o $@.tmp $<
	sed -e '/align/d' -e '/nop/d' < $@.tmp > $@
	rm -f $@.tmp

kernel.o: kernel.s
	${AS} ${ASFLAGS} -o $@ $<

kernel.s: kernel.c
	${CC} ${CFLAGS} -S -Wno-main-return-type -o $@.tmp $<
	sed -e '/align/d' -e '/nop/d' < $@.tmp > $@
	rm -f $@.tmp

multiboot.o: multiboot.asm
	nasm -f elf -o $@ $<
