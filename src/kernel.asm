;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

org 0h
bits 16

start:
  mov ax, cs
  mov ds, ax

  mov si, msgHello
  call println

pmode:
  cli
  lgdt [gdtr]

  mov eax, cr0
  or eax, 00000001h ; PE(protected mode enable) bit set to 1
  mov cr0, eax

  jmp $+2
  nop
  nop

  jmp dword SysCodeSelector:pmodeStart

; welcome to Protected Mode

bits 32

pmodeStart:
  mov bx, SysDataSelector
  mov ds, bx
  mov es, bx
  mov fs, bx
  mov gs, bx
  mov ss, bx

  xor eax, eax
  mov ax, VideoSelector
  mov es, ax
  mov edi, 80*2*0 + 2*0
  lea esi, [msgPmode]
  call print

  jmp $

print:
  push eax

printLoop:
  or al, al
  jz printEnd
  mov al, byte [esi]
  mov byte [es:edi], al
  inc edi
  mov byte [es:edi], 06h
  inc edi
  inc esi
  jmp printLoop

printEnd:
  pop eax
  ret

; GDT register
gdtr:
  dw gdtEnd - gdt - 1 ; limit
  dd gdt+10000h       ; base address. 10000h means DS(CS)

; GDT (Global Descriptor Table)
; 3.4.5 Segment Descriptors (Intel's System Programming Guide)
;
; common values - P(segment-present):1, S(descriptor type):1
;   D/B(default operation size):1(32-bit segment)

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
  db 9Ah  ; DPL:0, type:[code, execute/read]
  db 0CFh ; G:1
  db 00h

; data segment descriptor
SysDataSelector equ 10h
  dw 0FFFFh
  dw 0000h
  db 01h
  db 92h  ; DPL:0, type:[data, expand-up, read/write]
  db 0CFh ; G:1
  db 00h

; video segment descriptor (B8000 - FFFF)
VideoSelector equ 18h
  dw 0FFFFh
  dw 8000h
  db 0Bh
  db 92h ; DPL:0, type:[data, expand-up, read/write]
  db 40h ; G:0
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

msgHello db "Hello, world!", 0
msgPmode db "Protected mode enabled.", 0

times 512 - ($-$$) db 0