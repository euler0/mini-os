AS = nasm
ASFLAGS = -f bin -I src/

all: kernel

kernel: build_dir
	$(AS) $(ASFLAGS) src/boot.asm -o build/boot
	$(AS) $(ASFLAGS) src/kernel.asm -o build/kernel
	@cat build/boot build/kernel > build/kernel.img

build_dir:
	@mkdir -p build

clean:
	@rm -r build
