;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

global loader
global gdt_flush
global idt_flush

extern start

; Multiboot
MB_PAGEALIGN equ 1<<0 ; Align all boot modules on i386 page (4KB) boundaries.
MB_MEMINFO   equ 1<<1 ; Pass memory information to OS.
MB_FLAGS     equ MB_PAGEALIGN | MB_MEMINFO
MB_MAGIC     equ 0x1BADB002
MB_CHECKSUM  equ -(MB_MAGIC + MB_FLAGS)

bits 32

section .text

align 4
  dd MB_MAGIC
  dd MB_FLAGS
  dd MB_CHECKSUM

STACKSIZE equ 0x4000

loader:
  mov esp, stack + STACKSIZE
  push eax ; Multiboot magic number
  push ebx ; Multiboot information structure

  cli
  call start

  cli
.hang:
  hlt
  jmp .hang

gdt_flush:
  mov eax, [esp+4]
  lgdt [eax]

  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  jmp 0x08:.flush
.flush:
  ret

idt_flush:
  mov eax, [esp+4]
  lidt [eax]
  ret

section .bss

align 4
stack: resb STACKSIZE
