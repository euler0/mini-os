AS = nasm
ASFLAGS = -f bin

all: kernel

kernel: build_dir
	$(AS) $(ASFLAGS) src/boot.s -o build/boot
	$(AS) $(ASFLAGS) src/kernel.s -o build/kernel
	@cat build/boot build/kernel > build/kernel.img

build_dir:
	@mkdir -p build

clean:
	@rm -r build
