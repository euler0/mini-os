AS= i686-elf-as
ASFLAGS=
CC= clang
CFLAGS= -target i686 -c
LD= i686-elf-ld
LDFLAGS=
OBJCOPY= i686-elf-objcopy
NASMFLAGS= -f bin

bootloader.img: boot.bin loader.bin
	cat $^ > $@

boot.bin: boot.asm
	nasm $(NASMFLAGS) -o $@ $<

loader.bin: loader.elf
	${OBJCOPY} -S -O binary $< $@

loader.elf: loader.o loader.lds
	${LD} ${LDFLAGS} -T loader.lds -o $@ $<

loader.o: loader.s
	${AS} ${ASFLAGS} -o $@ $<

loader.s: loader.c
	${CC} ${CFLAGS} -S -o $@.tmp $<
	sed -e '/align/d' -e '/nop/d' < $@.tmp > $@
	rm -f $@.tmp
