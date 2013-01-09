;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

global gdt_flush
global idt_flush
global halt

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

halt:
  cli
.hang
  hlt
  jmp .hang
