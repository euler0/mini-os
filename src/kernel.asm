;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;
org 0h
bits 16

start:
  ; DS = CS
  mov ax, cs
  mov ds, ax

  mov si, hello
  call println

pmode:
  cli
  lgdt [gdtr]

  mov eax, cr0
  or eax, 00000001h
  mov cr0, eax

  jmp $+2
  nop
  nop

  jmp dword SysCodeSelector:pmodeStart

; welcome to Protected Mode

[bits 32]

pmodeStart:
  mov bx, SysDataSelector
  mov ds, bx
  mov es, bx
  mov fs, bx
  mov gs, bx
  mov ss, bx

  jmp $

; GDT Table

gdtr:
  dw gdtEnd - gdt - 1
  dd gdt+10000h

gdt:
; null descriptor (unused)
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0

; code segment descriptor
SysCodeSelector equ 08h
  dw 0FFFFh
  dw 0000h
  db 01h
  db 9Ah
  db 0CFh
  db 00h

; data segment descriptor
SysDataSelector equ 10h
  dw 0FFFFh
  dw 0000h
  db 01h
  db 92h
  db 0CFh
  db 00h

; video segment descriptor
VideoSelector equ 18h
  dw 0FFFFh
  dw 8000h
  db 0Bh
  db 92h
  db 40h
  db 00h

gdtEnd: ; end of GDT

println:
  lodsb
  or al, al
  jz printlnDone
  mov ah, 0Eh ; teletype output
  int 10h
  jmp println
printlnDone:
  mov al, 0Dh
  int 10h
  mov al, 0Ah
  int 10h
  ret

hello db "Hello, world!", 0

times 512 - ($-$$) db 0
