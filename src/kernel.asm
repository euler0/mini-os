;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

%include "inc/system.asm"

org 10000h
bits 16

start:
  mov ax, cs
  mov ds, ax

  mov si, msgHello
  call println

  ; switch off the floppy drive motor
  mov dx, 3F2h
  xor al, al
  out dx, al

  ;
  ; setup PIC (Programmable Interrupt Controller, 8259A)
  ;

  cli

  ; ICW1 - start the initialization sequence
  mov al, ICW1_INIT+ICW1_ICW4
  out PIC1_CMD, al
  dw 00EBh, 00EBh ; 00EB => jmp $+2 (for IO wait)
  out PIC2_CMD, al
  dw 00EBh, 00EBh

  ; ICW2 - remap PIC vector offset
  ; IRQ0 starts at 20h and IRQ8 starts at 28h
  mov al, 20h
  out PIC1_DATA, al
  dw 00EBh, 00EBh
  mov al, 28h
  out PIC2_DATA, al
  dw 00EBh, 00EBh

  ; ICW3
  mov al, 04h       ; IRQ2 -> connection to slave
  out PIC1_DATA, al
  dw 00EBh, 00EBh
  mov al, 02h
  out PIC2_DATA, al
  dw 00EBh, 00EBh

  ; ICW4
  mov al, ICW4_8086
  out PIC1_DATA, al
  dw 00EBh, 00EBh
  out PIC2_DATA, al
  dw 00EBh, 00EBh

  ; disable master PIC except IRQ2
  mov al, 0FBh
  out PIC1_DATA, al
  dw 00EBh, 00EBh

  ; disable slave PIC
  mov al, 0FFh
  out PIC2_DATA, al

pmode:
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

  lea esp, [start]

  mov edi, 80*2*0 + 2*0
  lea esi, [msgPmode]
  call print

  ; copy IDT (Interrupt Descriptor Table) to 0000:0000

  cld
  mov ax, SysDataSelector
  mov es, ax
  xor eax, eax
  xor ecx, ecx
  mov ax, 256
  mov edi, 0

idtCopyLoop:
  lea esi, [idtIgnore]
  mov cx, 8
  rep movsb
  dec ax
  jnz idtCopyLoop

  ; install timer ISR
  mov edi, 8*20h
  lea esi, [idtTimer]
  mov cx, 8
  rep movsb

  lidt [idtr]

  mov al, 0FEh
  out 21h, al

  sti

  jmp $ ; Hammer time!

; IDT register
idtr:
  dw 256*8 - 1 ; limit
  dd 0         ; base address

idtTimer:
  dw isrTimer
  dw 08h
  db 00h
  db 8Eh
  dw 0001h

isrTimer:
  push gs
  push fs
  push es
  push ds
  pushad
  pushfd

  mov al, 20h
  out 20h, al
  mov edi, 80*2*2
  lea esi, [msgTest]
  call print
  inc byte [msgTest]

  popfd
  popad
  pop ds
  pop es
  pop fs
  pop gs

  iret

idtIgnore:
  dw isrIgnore
  dw SysCodeSelector
  db 00h
  db 8Eh
  dw 0001h

isrIgnore:
  push gs
  push fs
  push es
  push ds
  pushad
  pushfd

  mov edi, 80*0*2
  lea esi, [msgTest]
  call print

  popfd
  popad
  pop ds
  pop es
  pop fs
  pop gs

  iret

print:
  push eax
  push es
  mov ax, VideoSelector
  mov es, ax

printLoop:
  mov al, byte [esi]
  or al, al
  jz printEnd
  mov byte [es:edi], al
  inc edi
  mov byte [es:edi], 06h
  inc edi
  inc esi
  jmp printLoop

printEnd:
  pop es
  pop eax
  ret

; GDT register
;
; The limit is the size of the table subtracted by 1 because the GDT can be up
; to 65536 bytes (a maximum of 8192 entries).
gdtr:
  dw gdtEnd - gdt - 1 ; limit
  dd gdt              ; base address

; GDT (Global Descriptor Table)
; 3.4.5 Segment Descriptors (Intel's System Programming Guide)
; or http://wiki.osdev.org/Global_Descriptor_Table
;
; common values - P(segment-present):1, S(descriptor type):1
;   D/B(default operation size):1(32-bit segment)

gdt:
; null descriptor (unused)
  dw 0 ; segment limit  0:15
  dw 0 ; base address   0:15
  db 0 ; base address  16:23
  db 0 ; access byte
  db 0 ; flags, segment limit 16:19
  db 0 ; base address  24:31

; code segment descriptor (base: 0, limit: FFFFF 1 MB)
SysCodeSelector equ 08h
  dw 0FFFFh
  dw 0000h
  db 00h
  db 9Ah  ; DPL:0, type:[code, execute/read]
  db 0CFh ; G:1
  db 00h

; data segment descriptor (base: 0, limit: FFFFF 1 MB)
SysDataSelector equ 10h
  dw 0FFFFh
  dw 0000h
  db 00h
  db 92h  ; DPL:0, type:[data, expand-up, read/write]
  db 0CFh ; G:1
  db 00h

; video segment descriptor (base: B8000, limit: FFFF 64 kB)
VideoSelector equ 18h
  dw 0FFFFh
  dw 8000h
  db 0Bh
  db 92h ; DPL:0, type:[data, expand-up, read/write]
  db 40h ; G:0
  db 00h

gdtEnd: ; end of GDT

%include "inc/print.asm"

msgHello db "Hello, world!", 0
msgPmode db "Protected mode enabled.", 0
msgTest  db "Interrupt operational!", 0

times 512 - ($-$$) db 0
