;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;
; 8259A Programmable Interrupt Controller (PIC)
;

PIC1           equ 0x20  ; master
PIC2           equ 0xA0 ; slave
PIC1_CMD       equ PIC1
PIC2_CMD       equ PIC2
PIC1_DATA      equ PIC1+1
PIC2_DATA      equ PIC2+1

ICW1_ICW4      equ 0x01 ; ICW4 (not) needed
ICW1_SINGLE    equ 0x02 ; single (cascade) mode
ICW1_INTERVAL4 equ 0x04 ; call address interval 4 (8)
ICW1_LEVEL     equ 0x08 ; level triggered (edge) mode
ICW1_INIT      equ 0x10 ; initialization

ICW4_8086       equ 0x01 ; 8086/88 (MCS-80/85) mode
ICW4_AUTO       equ 0x02 ; auto (normal) EOI(end of interrupt)
ICW4_BUF_SLAVE  equ 0x08 ; buffered mode - slave
ICW4_BUF_MASTER equ 0x0C ; buffered mode - master
ICW4_SFNM       equ 0x10 ; special fully nested (not)

pic_init:
  ; ICW1 - start the initialization sequence
  mov al, ICW1_INIT+ICW1_ICW4
  out PIC1_CMD, al
  dw 0x00EB, 0x00EB ; 00EB => jmp $+2 (for IO wait)
  out PIC2_CMD, al
  dw 0x00EB, 0x00EB

  ; ICW2 - remap PIC vector offset
  ; IRQ0 starts at 20h and IRQ8 starts at 28h
  mov al, 0x20
  out PIC1_DATA, al
  dw 0x00EB, 0x00EB
  mov al, 0x28
  out PIC2_DATA, al
  dw 0x00EB, 0x00EB

  ; ICW3
  mov al, 0x04       ; IRQ2 -> connection to slave
  out PIC1_DATA, al
  dw 0x00EB, 0x00EB
  mov al, 02h
  out PIC2_DATA, al
  dw 0x00EB, 0x00EB

  ; ICW4
  mov al, ICW4_8086
  out PIC1_DATA, al
  dw 0x00EB, 0x00EB
  out PIC2_DATA, al
  dw 0x00EB, 0x00EB

  ; disable master PIC except IRQ2
  mov al, 0xFB
  out PIC1_DATA, al
  dw 0x00EB, 0x00EB

  ; disable slave PIC
  mov al, 0xFF
  out PIC2_DATA, al

  ret
